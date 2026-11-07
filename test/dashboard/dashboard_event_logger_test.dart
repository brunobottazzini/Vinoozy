// DashboardEventLogger (u5-dashboard security-design.md §2, NFR8.1): one
// event per process, fixed message, no wine data.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinoozy/app/providers.dart';
import 'package:vinoozy/dashboard/dashboard_event_logger.dart';
import 'package:vinoozy/dashboard/dashboard_providers.dart';

import '../helpers/fakes.dart';
import 'dashboard_harness.dart';
import 'fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> settle() => pumpEventQueue();

  test('a wine with marker years and name reaches the sink with the fixed '
      'message only, once', () async {
    SharedPreferences.setMockInitialValues({});
    final streams = DashboardStreams();
    final container = ProviderContainer(overrides: streams.overrides);
    addTearDown(() async {
      container.dispose();
      await streams.close();
    });
    container.listen(dashboardSummaryProvider(dashboardUser.uid), (_, _) {});

    // Two recalculations, each with invalid windows.
    streams.emitWines([
      wineOf(
        'marker-id',
        name: 'Marcatore Segreto',
        producer: 'Cantina Marcatore',
        vintage: 1999,
        window: window(2088, 1999, 2077),
      ),
    ]);
    await settle();
    streams.emitWines([
      wineOf(
        'marker-id',
        name: 'Marcatore Segreto',
        window: window(2088, 1999, 2077),
      ),
      wineOf(
        'other',
        name: 'Altro Marcatore',
        window: window(2099, 2001, 2050),
      ),
    ]);
    await settle();
    await settle();

    expect(streams.sink.recorded, hasLength(1));
    final recorded = streams.sink.recorded.single;
    expect(recorded.reason, 'dashboard_invalid_window');
    expect(recorded.fatal, isFalse);
    expect(recorded.error.type, 'DashboardInvalidWindow');
    expect(
      recorded.error.message,
      'dashboard_invalid_window: estimation_error=invalidWindow',
    );
    final everything = '${recorded.error} ${recorded.reason}';
    for (final marker in [
      '1999',
      '2088',
      '2077',
      'Marcatore',
      'marker-id',
      'user-a',
    ]) {
      expect(everything, isNot(contains(marker)), reason: marker);
    }
  });

  test('the logger sends at most one event, even when called again', () async {
    final sink = RecordingErrorSink();
    final logger = ReporterDashboardEventLogger(recordingReporter(sink));

    logger
      ..invalidWindow()
      ..invalidWindow()
      ..invalidWindow();
    await settle();

    expect(sink.reasons, [ReporterDashboardEventLogger.reason]);
  });

  test('a failing sink does not break the Dashboard', () async {
    final sink = RecordingErrorSink()..fail = true;
    final logs = <String>[];
    final logger = ReporterDashboardEventLogger(
      recordingReporter(sink, logs: logs),
    );

    expect(logger.invalidWindow, returnsNormally);
    await settle();

    expect(sink.recorded, isEmpty);
    expect(logs.single, contains('sink failed'));
    expect(logs.single, isNot(contains('1999')));
  });

  test('the provider lives as long as the app (one logger per process)', () {
    final sink = RecordingErrorSink();
    final container = ProviderContainer(
      overrides: [
        errorReporterProvider.overrideWithValue(recordingReporter(sink)),
      ],
    );
    addTearDown(container.dispose);

    final first = container.read(dashboardEventLoggerProvider);
    final second = container.read(dashboardEventLoggerProvider);

    expect(identical(first, second), isTrue);
    expect(
      const DashboardInvalidWindow().toString(),
      DashboardInvalidWindow.message,
    );
  });
}
