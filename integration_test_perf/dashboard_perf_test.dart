// On-phone measures of the Dashboard (u5-dashboard performance-design.md,
// cicd-pipeline.md §2; NFR2.2 phone part, NFR2.4), run by the owner once
// per version before approving production, never in CI:
//
//   flutter drive --profile --driver=test_driver/perf_driver.dart \
//     --target=integration_test_perf/dashboard_perf_test.dart \
//     --dart-define=FIREBASE_ENV=demo --dart-define=E2E=true \
//     --dart-define=PERF=true --dart-define=EMULATOR_HOST=127.0.0.1
//
// 1. DashboardCalculator.compute on 500 wines generated in memory: median
//    of 10 rounds after 3 warm-up rounds, at most 25 ms (NFR2.2).
// 2. A full scroll of the Dashboard with the 500 wines left by
//    integration_test_perf/dashboard_seed.dart (run it first, with the
//    Firebase emulators reachable through `adb reverse`): the 99th
//    percentile of the frame build and raster times stays under the display
//    period (8.3 ms at 120 Hz, 16.7 ms at 60 Hz), FrameTimingSummarizer.
//
// Both results go in docs/release-checklist.md, §1-ter.
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vinoozy/dashboard/domain/dashboard_calculator.dart';

import '../integration_test/e2e_helpers.dart';
import 'dashboard_seed.dart' show perfCellar, perfWineCount;

const _warmupRounds = 3;
const _timedRounds = 10;
const _computeLimitMs = 25.0;

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('compute on 500 wines within 25 ms (NFR2.2)', (tester) async {
    final today = DateTime.now();
    final wines = perfCellar(today.year);
    const calculator = DashboardCalculator();
    for (var i = 0; i < _warmupRounds; i++) {
      calculator.compute(wines, today);
    }
    final samples = <double>[];
    final watch = Stopwatch();
    for (var i = 0; i < _timedRounds; i++) {
      watch
        ..reset()
        ..start();
      calculator.compute(wines, today);
      watch.stop();
      samples.add(watch.elapsedMicroseconds / 1000);
    }
    samples.sort();
    final median = (samples[4] + samples[5]) / 2;

    debugPrint(
      'dashboard_perf: compute median ${median.toStringAsFixed(2)} ms over '
      '$_timedRounds rounds of $perfWineCount wines (limit $_computeLimitMs)',
    );
    binding.reportData = {
      ...?binding.reportData,
      'dashboard_compute_median_ms': median,
      'dashboard_compute_limit_ms': _computeLimitMs,
    };
    expect(median, lessThanOrEqualTo(_computeLimitMs));
  });

  testWidgets('full scroll: p99 frame times under the display period '
      '(NFR2.4)', (tester) async {
    binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
    await launchApp(tester);
    final content = find.byKey(const Key('dashboard-content'));
    await waitFor(
      tester,
      content,
      timeout: const Duration(seconds: 30),
      viaCellarTab: false,
    );

    final timings = <FrameTiming>[];
    void collect(List<FrameTiming> batch) => timings.addAll(batch);
    SchedulerBinding.instance.addTimingsCallback(collect);
    for (var i = 0; i < 2; i++) {
      await tester.fling(content, const Offset(0, -1500), 3000);
      await tester.pumpAndSettle();
      await tester.fling(content, const Offset(0, 1500), 3000);
      await tester.pumpAndSettle();
    }
    // Let the engine deliver the last timings.
    await tester.pump(const Duration(seconds: 1));
    SchedulerBinding.instance.removeTimingsCallback(collect);

    final refreshRate = PlatformDispatcher.instance.displays.first.refreshRate;
    final periodMs = 1000 / refreshRate;
    final summary = FrameTimingSummarizer(timings);
    final buildP99 = summary.p99FrameBuildTime.inMicroseconds / 1000;
    final rasterP99 = summary.p99FrameRasterizerTime.inMicroseconds / 1000;
    debugPrint(
      'dashboard_perf: ${timings.length} frames at '
      '${refreshRate.toStringAsFixed(0)} Hz, p99 build '
      '${buildP99.toStringAsFixed(2)} ms, p99 raster '
      '${rasterP99.toStringAsFixed(2)} ms (limit '
      '${periodMs.toStringAsFixed(1)} ms)',
    );
    binding.reportData = {
      ...?binding.reportData,
      'dashboard_scroll_frames': timings.length,
      'dashboard_scroll_p99_build_ms': buildP99,
      'dashboard_scroll_p99_raster_ms': rasterP99,
      'dashboard_display_period_ms': periodMs,
    };
    expect(buildP99, lessThan(periodMs));
    expect(rasterP99, lessThan(periodMs));
  });
}
