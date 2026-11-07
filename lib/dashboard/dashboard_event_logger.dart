import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/error_reporter.dart';
import '../app/providers.dart';

/// The only event the Dashboard sends out of the phone (u5-dashboard
/// security-design.md §2, NFR8.1).
///
/// [invalidWindow] has no parameters, so no wine data can ever be passed.
abstract interface class DashboardEventLogger {
  /// At least one wine has a window that `statusOf` rejected (BR1.2).
  void invalidWindow();
}

/// Error recorded for [DashboardEventLogger.invalidWindow]. Its message is
/// fixed and carries only the C2 error code: no name, year, uid or id.
class DashboardInvalidWindow implements Exception {
  const DashboardInvalidWindow();

  static const String message =
      'dashboard_invalid_window: estimation_error=invalidWindow';

  @override
  String toString() => message;
}

/// [DashboardEventLogger] through the single error exit of U1
/// ([ErrorReporter], NFR8.2), never Crashlytics directly. It sends at most
/// one event per process: its provider is not auto-disposed, so it lives as
/// long as the app.
class ReporterDashboardEventLogger implements DashboardEventLogger {
  ReporterDashboardEventLogger(this._reporter);

  final ErrorReporter _reporter;
  bool _sent = false;

  /// Reason of the recorded error, searchable among the non-fatal events.
  static const String reason = 'dashboard_invalid_window';

  @override
  void invalidWindow() {
    if (_sent) return;
    _sent = true;
    // ErrorReporter.report never throws: a failing sink is logged locally.
    unawaited(
      _reporter.report(
        const DashboardInvalidWindow(),
        null,
        reason: reason,
        fatal: false,
      ),
    );
  }
}

/// Not auto-disposed on purpose: one logger, hence one event, per process.
final dashboardEventLoggerProvider = Provider<DashboardEventLogger>(
  (ref) => ReporterDashboardEventLogger(ref.watch(errorReporterProvider)),
);
