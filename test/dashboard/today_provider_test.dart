// todayProvider (u5-dashboard BR1.9, NFR6.4): midnight timer, return to the
// foreground, days of the clock change. Timers run in the fake time of
// testWidgets (tester.pump), never with real waiting.
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/app/providers.dart';
import 'package:vinoozy/dashboard/today_provider.dart';

import '../helpers/fakes.dart';

/// A container whose clock starts at a given time; [advance] moves the clock
/// and the fake timers together.
class _Harness {
  _Harness(this.tester, DateTime start) : clock = FakeClock(start) {
    container = ProviderContainer(
      overrides: [clockProvider.overrideWithValue(clock)],
    );
    subscription = container.listen<DateTime>(
      todayProvider,
      (_, next) => changes.add(next),
      fireImmediately: true,
    );
  }

  final WidgetTester tester;
  final FakeClock clock;
  late final ProviderContainer container;
  late final ProviderSubscription<DateTime> subscription;
  final List<DateTime> changes = [];

  DateTime get today => container.read(todayProvider);

  Future<void> advance(Duration duration) async {
    clock.current = clock.current.add(duration);
    await tester.pump(duration);
  }

  void resumeApp() {
    tester.binding
      ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
      ..handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  }

  /// Disposes the container, which must cancel the midnight timer: the test
  /// fails if a timer is still pending when it ends.
  void dispose() {
    subscription.close();
    container.dispose();
  }
}

/// Runs [body] with a harness started at [start], then disposes it.
Future<void> _withHarness(
  WidgetTester tester,
  DateTime start,
  Future<void> Function(_Harness harness) body,
) async {
  final harness = _Harness(tester, start);
  try {
    await body(harness);
  } finally {
    harness.dispose();
  }
}

void main() {
  testWidgets('today is the local date without time', (tester) async {
    await _withHarness(tester, DateTime(2026, 11, 6, 15, 42, 7), (h) async {
      expect(h.today, DateTime(2026, 11, 6));
    });
    expect(
      TodayNotifier.dateOf(DateTime(2026, 1, 2, 23, 59)),
      DateTime(2026, 1, 2),
    );
  });

  testWidgets('the date changes at local midnight, and again the next one', (
    tester,
  ) async {
    await _withHarness(tester, DateTime(2026, 11, 6, 23, 59, 30), (h) async {
      await h.advance(const Duration(seconds: 29));
      expect(h.today, DateTime(2026, 11, 6), reason: 'not yet midnight');

      await h.advance(const Duration(seconds: 1));
      expect(h.today, DateTime(2026, 11, 7));

      final nextDay = DateTime(2026, 11, 8).difference(DateTime(2026, 11, 7));
      await h.advance(nextDay);
      expect(h.today, DateTime(2026, 11, 8), reason: 'timer rescheduled');
      expect(h.changes, [
        DateTime(2026, 11, 6),
        DateTime(2026, 11, 7),
        DateTime(2026, 11, 8),
      ]);
    });
  });

  // The test machine may not be in Europe/Rome: the expected length of the
  // day comes from local DateTime arithmetic, which in Europe/Rome is 23 h on
  // 29 March 2026 and 25 h on 25 October 2026. A fixed 24 h timer would be
  // off by one hour on those days.
  for (final (label, day, next) in [
    (
      'spring forward (29 March 2026)',
      DateTime(2026, 3, 29),
      DateTime(2026, 3, 30),
    ),
    (
      'fall back (25 October 2026)',
      DateTime(2026, 10, 25),
      DateTime(2026, 10, 26),
    ),
  ]) {
    testWidgets('clock change, $label: the timer fires at the real midnight', (
      tester,
    ) async {
      await _withHarness(tester, day, (h) async {
        final dayLength = next.difference(day);

        await h.advance(dayLength - const Duration(seconds: 1));
        expect(h.today, day);

        await h.advance(const Duration(seconds: 1));
        expect(h.today, next);
      });
    });
  }

  testWidgets('back to the foreground the date is read again', (tester) async {
    await _withHarness(tester, DateTime(2026, 11, 6, 22), (h) async {
      // The app was in the background past midnight: the clock moved, the
      // midnight timer has not run in this fake zone yet.
      h.clock.current = DateTime(2026, 11, 7, 8);
      h.resumeApp();

      expect(h.today, DateTime(2026, 11, 7));
    });
  });

  testWidgets('returning on the same day changes nothing', (tester) async {
    await _withHarness(tester, DateTime(2026, 11, 6, 10), (h) async {
      h.clock.current = DateTime(2026, 11, 6, 11);
      h.resumeApp();

      expect(h.changes, [DateTime(2026, 11, 6)]);
    });
  });

  testWidgets('disposing the provider cancels the timer', (tester) async {
    final harness = _Harness(tester, DateTime(2026, 11, 6, 23));
    final notifier = harness.container.read(todayProvider.notifier);
    harness.dispose();

    // A late refresh is ignored and leaves no timer behind (testWidgets
    // fails when a timer is still pending at the end).
    notifier.refresh();
    await tester.pump(const Duration(hours: 2));
  });
}
