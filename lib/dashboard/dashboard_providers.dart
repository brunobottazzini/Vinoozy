import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/providers.dart';
import 'dashboard_event_logger.dart';
import 'domain/dashboard_calculator.dart';
import 'domain/dashboard_summary.dart';
import 'today_provider.dart';

/// What the Dashboard shows once the cellar is ready (u5-dashboard
/// frontend-components.md, "Stati di caricamento ed errore").
sealed class DashboardState {
  const DashboardState();
}

/// The wines listener has not delivered its first snapshot yet.
final class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

/// The cellar or wines listener failed: the U1 error with "Try again"
/// (NFR6.2, security-design.md §4).
final class DashboardFailed extends DashboardState {
  const DashboardFailed();
}

/// 0 bottles read from the local cache only: the first sync is still
/// running, so the empty state is not shown yet (BR1.8, BR1.9, NFR6.3).
final class DashboardSyncing extends DashboardState {
  const DashboardSyncing();
}

/// 0 bottles confirmed by the server: the invitation to add the first wine
/// (BR1.8).
final class DashboardEmpty extends DashboardState {
  const DashboardEmpty();
}

/// The list and the three charts.
final class DashboardReady extends DashboardState {
  const DashboardReady(this.summary);

  final DashboardSummary summary;

  @override
  bool operator ==(Object other) =>
      other is DashboardReady && other.summary == summary;

  @override
  int get hashCode => summary.hashCode;
}

/// The pure calculator; tests override it with a counting fake (NFR2.3).
final dashboardCalculatorProvider = Provider<DashboardCalculator>(
  (ref) => const DashboardCalculator(),
);

/// The summary of the wines of the cellar [cellarId] (the active cellar
/// since u7-sharing; the personal one is the uid), recomputed only when the
/// wines or the day change, never for the breakdown selector or the cellar
/// document (NFR2.3). `null` until the first wines snapshot.
///
/// It reuses the wines listener of the Cellar screen (same family argument,
/// so one Firestore listener, NFR5.1 of U1). When the summary has invalid
/// windows it tells the event logger, which sends one event per process.
final dashboardComputedProvider = Provider.autoDispose
    .family<DashboardSummary?, String>((ref, cellarId) {
      final wines = ref.watch(
        winesStreamProvider(cellarId).select((async) => async.value?.wines),
      );
      if (wines == null) return null;
      final today = ref.watch(todayProvider);
      final summary = ref
          .watch(dashboardCalculatorProvider)
          .compute(wines, today);
      if (summary.invalidWindowCount > 0) {
        ref.read(dashboardEventLoggerProvider).invalidWindow();
      }
      return summary;
    });

/// The state of the Dashboard of the cellar [cellarId] (BR1.8, BR1.9;
/// NFR6.2, NFR6.3), the active cellar since u7-sharing.
///
/// Only read access: the cellar and wines listeners of U1, never a
/// repository (NFR4.1, tool/check_dashboard_readonly.sh).
final dashboardSummaryProvider = Provider.autoDispose
    .family<DashboardState, String>((ref, cellarId) {
      final cellar = ref.watch(cellarStreamProvider(cellarId));
      final wines = ref.watch(winesStreamProvider(cellarId));
      // A listener closed by an error (e.g. permission-denied) is the same
      // failure as a failed setup, as in CellarScreen.
      if (cellar.hasError || wines.hasError) return const DashboardFailed();
      final snapshot = wines.value;
      final summary = ref.watch(dashboardComputedProvider(cellarId));
      if (snapshot == null || summary == null) return const DashboardLoading();
      if (summary.totalBottles == 0) {
        return snapshot.meta.isFromCache
            ? const DashboardSyncing()
            : const DashboardEmpty();
      }
      return DashboardReady(summary);
    });

/// The two views of the third chart (BR1.6).
enum BreakdownMode {
  type,
  region;

  /// The stored value, or `null` when it is absent or unknown.
  static BreakdownMode? parse(Object? raw) {
    for (final mode in values) {
      if (mode.name == raw) return mode;
    }
    return null;
  }
}

/// Key of the breakdown choice in `shared_preferences`: the only value the
/// Dashboard writes, and only on the phone (NFR4.1).
const String breakdownModeKey = 'dashboard.breakdownMode';

/// Opens `shared_preferences`; tests override it to simulate failures.
final dashboardPreferencesProvider =
    Provider<Future<SharedPreferences> Function()>(
      (ref) => SharedPreferences.getInstance,
    );

/// The breakdown selector, starting from "Type" and remembering the last
/// choice on the phone (BR1.6). It only picks which of the two lists already
/// computed is shown: it never triggers a new calculation (NFR2.3).
final breakdownModeProvider =
    NotifierProvider<BreakdownModeNotifier, BreakdownMode>(
      BreakdownModeNotifier.new,
    );

class BreakdownModeNotifier extends Notifier<BreakdownMode> {
  /// Set once the user chooses: a slower restore must not override it.
  bool _chosen = false;

  @override
  BreakdownMode build() {
    unawaited(_restore());
    return BreakdownMode.type;
  }

  Future<void> _restore() async {
    final open = ref.read(dashboardPreferencesProvider);
    try {
      final prefs = await open();
      final stored = BreakdownMode.parse(prefs.get(breakdownModeKey));
      if (stored != null && !_chosen && ref.mounted) state = stored;
    } catch (error) {
      // A missing preference is optional: "Type" stays (infrastructure
      // spec §5). Logged locally only, never sent out (NFR8.1).
      debugPrint('Dashboard: breakdown choice not read (${error.runtimeType})');
    }
  }

  /// Shows [mode] at once and remembers it on the phone.
  Future<void> select(BreakdownMode mode) async {
    _chosen = true;
    state = mode;
    final open = ref.read(dashboardPreferencesProvider);
    try {
      final prefs = await open();
      await prefs.setString(breakdownModeKey, mode.name);
    } catch (error) {
      debugPrint(
        'Dashboard: breakdown choice not saved (${error.runtimeType})',
      );
    }
  }
}
