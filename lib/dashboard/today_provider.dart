import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';

/// Today's local date, without time (u5-dashboard BR1.2, BR1.9; NFR6.4).
///
/// It reads the time from `clockProvider` of U1, so tests use a fake clock.
/// A [Timer] fires at the next local midnight, computed as
/// `DateTime(y, m, d + 1)`: that is the real next midnight also on the days
/// the clock changes (23 or 25 hours in Europe/Rome), not "now + 24 h". The
/// timer is rescheduled on every tick and when the app comes back to the
/// foreground, which also refreshes the date after a long background stay.
final todayProvider = NotifierProvider.autoDispose<TodayNotifier, DateTime>(
  TodayNotifier.new,
);

class TodayNotifier extends Notifier<DateTime> {
  Timer? _timer;

  @override
  DateTime build() {
    final listener = AppLifecycleListener(onResume: refresh);
    ref.onDispose(() {
      _timer?.cancel();
      listener.dispose();
    });
    final now = ref.watch(clockProvider).now();
    _scheduleAfter(now);
    return dateOf(now);
  }

  /// Local calendar date of [time], at 00:00.
  static DateTime dateOf(DateTime time) =>
      DateTime(time.year, time.month, time.day);

  /// Re-reads the clock: updates the date when it changed and reschedules
  /// the midnight timer. Called by the timer and on return to foreground.
  void refresh() {
    if (!ref.mounted) return;
    final now = ref.read(clockProvider).now();
    final today = dateOf(now);
    if (today != state) state = today;
    _scheduleAfter(now);
  }

  void _scheduleAfter(DateTime now) {
    _timer?.cancel();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    _timer = Timer(nextMidnight.difference(now), refresh);
  }
}
