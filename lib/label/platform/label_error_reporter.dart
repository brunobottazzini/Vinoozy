import '../../app/error_reporter.dart';

/// The four fixed reasons of the label photo (BR1.14, NFR8.2).
enum LabelFailure {
  readFailed('label_read_failed'),
  pickFailed('label_pick_failed'),
  lookupFailed('label_lookup_failed'),
  cleanupFailed('label_cleanup_failed');

  const LabelFailure(this.reason);

  final String reason;
}

/// What leaves the app for a label failure: the type of the original
/// exception and nothing else, so neither the text read, nor a barcode, nor
/// a file path can reach a report (NFR8.2).
class LabelReportedError implements Exception {
  const LabelReportedError(this.type);

  final String type;

  @override
  String toString() => 'LabelReportedError($type)';
}

/// The only place where U6 reports an error (logical-components.md).
///
/// Reporting never throws: a failing sink must not break the reading.
class LabelErrorReporter {
  const LabelErrorReporter(this._reporter);

  final ErrorReporter _reporter;

  Future<void> report(
    LabelFailure failure,
    Object error,
    StackTrace? stack,
  ) async {
    try {
      await _reporter.report(
        LabelReportedError(error.runtimeType.toString()),
        stack,
        reason: failure.reason,
      );
    } catch (_) {
      // ErrorReporter already swallows sink failures; nothing else to do.
    }
  }
}
