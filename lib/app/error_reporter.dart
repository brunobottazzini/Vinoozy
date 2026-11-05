import 'package:flutter/foundation.dart';

/// Error forwarded to the crash backend after sanitizing: it carries only the
/// original type name and a message stripped of personal data (NFR8.2).
class SanitizedError implements Exception {
  const SanitizedError(this.type, this.message);

  final String type;
  final String message;

  @override
  String toString() => '$type: $message';
}

/// Destination of sanitized errors (Crashlytics in release, console in debug).
abstract interface class ErrorSink {
  Future<void> record(
    SanitizedError error,
    StackTrace? stack, {
    required String reason,
    required bool fatal,
  });
}

/// Development sink: prints to the local console only.
class DebugLogSink implements ErrorSink {
  const DebugLogSink();

  @override
  Future<void> record(
    SanitizedError error,
    StackTrace? stack, {
    required String reason,
    required bool fatal,
  }) async {
    debugPrint('[${fatal ? 'FATAL' : 'error'}] $reason: $error');
  }
}

/// Single exit for every error the app reports (logical-components.md).
///
/// Before anything leaves the app, [sanitize] removes uids, emails, document
/// paths and wine names, so crash reports never carry user data (NFR8.2).
/// Reporting never throws: a failing sink must not break the caller.
class ErrorReporter {
  ErrorReporter(this._sink, {void Function(String message)? log})
    : _log = log ?? debugPrint;

  final ErrorSink _sink;
  final void Function(String message) _log;

  static final RegExp _email = RegExp(
    r'[A-Za-z0-9._%+\-]+@[A-Za-z0-9\-]+(\.[A-Za-z0-9\-]+)+',
  );
  static final RegExp _documentPath = RegExp(
    r'\b(users|cellars|wines|drinkingRecords|members)/[^/\s"'
    "'"
    r')\]}]+',
  );
  // Generated ids (Firebase uids: 28 chars, Firestore ids: 20 chars) mix
  // letters and digits; requiring a digit keeps long English words such as
  // fixed error labels intact.
  static final RegExp _longId = RegExp(
    r'\b(?=[A-Za-z0-9_\-]*[0-9])(?=[A-Za-z0-9_\-]*[A-Za-z])[A-Za-z0-9_\-]{20,}\b',
  );

  /// Removes personal data from [text]:
  /// - each value in [sensitive] (uid, wine names) becomes `<redacted>`;
  /// - email addresses become `<email>`;
  /// - document ids after `users/`, `cellars/`, `wines/`... become `<id>`;
  /// - any other id-like token (20+ characters mixing letters and digits)
  ///   becomes `<id>`.
  static String sanitize(String text, {Iterable<String> sensitive = const []}) {
    var result = text;
    final values =
        sensitive.where((value) => value.trim().isNotEmpty).toSet().toList()
          ..sort((a, b) => b.length.compareTo(a.length));
    for (final value in values) {
      result = result.replaceAll(value, '<redacted>');
    }
    return result
        .replaceAll(_email, '<email>')
        .replaceAllMapped(_documentPath, (m) => '${m[1]}/<id>')
        .replaceAll(_longId, '<id>');
  }

  /// Sanitizes and records [error]. [reason] is a fixed, data-free label such
  /// as `SyncRejected`; [sensitive] lists values to strip from the message.
  Future<void> report(
    Object error,
    StackTrace? stack, {
    required String reason,
    Iterable<String> sensitive = const [],
    bool fatal = false,
  }) async {
    final sanitized = SanitizedError(
      error.runtimeType.toString(),
      sanitize(error.toString(), sensitive: sensitive),
    );
    try {
      await _sink.record(
        sanitized,
        stack,
        reason: sanitize(reason, sensitive: sensitive),
        fatal: fatal,
      );
    } catch (sinkError) {
      _log('ErrorReporter: sink failed (${sinkError.runtimeType}): $sanitized');
    }
  }
}
