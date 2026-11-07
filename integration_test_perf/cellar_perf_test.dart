// On-phone scroll measure of the Cellar and the History (u4-cellar
// performance-design.md §6; NFR2.3), run by the owner once per version
// before approving production, never in CI (cicd-pipeline.md §1):
//
//   flutter drive --profile --driver=test_driver/perf_driver.dart \
//     --target=integration_test_perf/cellar_perf_test.dart \
//     --dart-define=FIREBASE_ENV=demo --dart-define=E2E=true \
//     --dart-define=PERF=true --dart-define=EMULATOR_HOST=127.0.0.1
//
// The phone reaches the Firebase emulators of the computer through
// `adb reverse`. The test signs in as userA, creates 500 wines and 2,000
// drinks in the emulator (REST, as admin), then scrolls the Cellar and the
// History: the 99th percentile of the frame build and raster times must
// stay under the display period (FrameTimingSummarizer). The results go in
// docs/release-checklist.md, §1-quinquies.
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vinoozy/cellar/domain/drinking_record.dart';

import '../integration_test/e2e_helpers.dart';
import 'dashboard_seed.dart' show perfCellar, perfWineCount;

const _drinkCount = 2000;

/// 2,000 drinks of the 500 wines, in commits of at most 500 writes.
Future<void> _seedDrinks(String cellarId) async {
  final today = DateTime.now();
  for (var start = 0; start < _drinkCount; start += 500) {
    await commitWrites([
      for (var i = start; i < start + 500; i++)
        {
          'update': {
            'name':
                'projects/demo-vinoozy/databases/(default)/documents/'
                'cellars/$cellarId/drinkingRecords/perf-r$i',
            'fields': {
              'wineId': {
                'stringValue':
                    'perf-${(i % perfWineCount).toString().padLeft(3, '0')}',
              },
              'wineName': {'stringValue': 'Vino Misura ${i % perfWineCount}'},
              'drankOn': {
                'stringValue': formatDrankOn(
                  today.subtract(Duration(days: i % 700)),
                ),
              },
              'recordedBy': {'stringValue': cellarId},
              'rating': {'integerValue': '${1 + i % 5}'},
              'createdAt': {'timestampValue': '2026-11-06T10:00:00Z'},
            },
          },
        },
    ]);
  }
}

/// Scrolls [list] down and up twice; returns the p99 build and raster times
/// in ms and the display period.
Future<(double, double, double, int)> _scroll(
  WidgetTester tester,
  Finder list,
) async {
  final timings = <FrameTiming>[];
  void collect(List<FrameTiming> batch) => timings.addAll(batch);
  SchedulerBinding.instance.addTimingsCallback(collect);
  for (var i = 0; i < 2; i++) {
    await tester.fling(list, const Offset(0, -3000), 4000);
    await tester.pumpAndSettle();
    await tester.fling(list, const Offset(0, 3000), 4000);
    await tester.pumpAndSettle();
  }
  await tester.pump(const Duration(seconds: 1));
  SchedulerBinding.instance.removeTimingsCallback(collect);
  final summary = FrameTimingSummarizer(timings);
  final period = 1000 / PlatformDispatcher.instance.displays.first.refreshRate;
  return (
    summary.p99FrameBuildTime.inMicroseconds / 1000,
    summary.p99FrameRasterizerTime.inMicroseconds / 1000,
    period,
    timings.length,
  );
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Cellar (500 wines) and History (2,000 drinks) scroll under '
      'the display period (NFR2.3)', (tester) async {
    binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
    await clearPhone();
    await clearEmulators();
    await launchApp(tester);
    await signIn(
      tester,
      userA,
      then: find.byKey(const Key('dashboard-screen')),
      viaCellarTab: false,
    );
    final uid = currentUid;
    await seedCloudWines(uid, perfCellar(DateTime.now().year));
    await _seedDrinks(uid);

    await tester.tap(find.byKey(const Key('home-nav-cellar')));
    final cellarList = find.byKey(const Key('cellar-wine-list'));
    await waitFor(tester, cellarList, timeout: const Duration(seconds: 60));
    final (cellarBuild, cellarRaster, period, cellarFrames) = await _scroll(
      tester,
      cellarList,
    );

    await tester.tap(find.byKey(const Key('home-nav-history')));
    final historyList = find.byKey(const Key('history-list'));
    await waitFor(tester, historyList, timeout: const Duration(seconds: 60));
    final (historyBuild, historyRaster, _, historyFrames) = await _scroll(
      tester,
      historyList,
    );

    debugPrint(
      'cellar_perf: Cellar $cellarFrames frames p99 build '
      '${cellarBuild.toStringAsFixed(2)} ms raster '
      '${cellarRaster.toStringAsFixed(2)} ms; History $historyFrames frames '
      'p99 build ${historyBuild.toStringAsFixed(2)} ms raster '
      '${historyRaster.toStringAsFixed(2)} ms (limit '
      '${period.toStringAsFixed(1)} ms)',
    );
    binding.reportData = {
      ...?binding.reportData,
      'cellar_scroll_p99_build_ms': cellarBuild,
      'cellar_scroll_p99_raster_ms': cellarRaster,
      'history_scroll_p99_build_ms': historyBuild,
      'history_scroll_p99_raster_ms': historyRaster,
      'display_period_ms': period,
    };
    expect(cellarBuild, lessThan(period));
    expect(cellarRaster, lessThan(period));
    expect(historyBuild, lessThan(period));
    expect(historyRaster, lessThan(period));
  });
}
