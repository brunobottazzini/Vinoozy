import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'error_reporter.dart';

/// Sends sanitized errors to Crashlytics (release builds only, NFR8.2).
///
/// No `setUserIdentifier` and no custom keys: Crashlytics only knows its own
/// installation id, which is not linked to the account.
class CrashlyticsErrorSink implements ErrorSink {
  CrashlyticsErrorSink(this._crashlytics);

  final FirebaseCrashlytics _crashlytics;

  @override
  Future<void> record(
    SanitizedError error,
    StackTrace? stack, {
    required String reason,
    required bool fatal,
  }) => _crashlytics.recordError(error, stack, reason: reason, fatal: fatal);
}
