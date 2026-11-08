import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/label/platform/label_error_reporter.dart';

import '../../helpers/fakes.dart';
import '../label_harness.dart';

void main() {
  group('BR1.14 fixed reasons', () {
    // label-autofill-windows NFR4.16 adds `appellations_index_failed`.
    test('BR1.14 the reasons are fixed strings', () {
      expect(LabelFailure.values.map((failure) => failure.reason), [
        'label_read_failed',
        'label_pick_failed',
        'label_lookup_failed',
        'label_cleanup_failed',
        'appellations_index_failed',
      ]);
    });

    test('BR1.14 only the exception type leaves the app, never its message '
        '(NFR8.2)', () async {
      final sink = RecordingErrorSink();
      final reporter = LabelErrorReporter(recordingReporter(sink));
      for (final failure in LabelFailure.values) {
        await reporter.report(
          failure,
          FormatException(labelMarkers.join(' ')),
          StackTrace.current,
        );
      }
      expect(sink.reasons, [for (final f in LabelFailure.values) f.reason]);
      for (final recorded in sink.recorded) {
        expect(recorded.error.toString(), contains('FormatException'));
        for (final marker in labelMarkers) {
          expect(recorded.error.toString(), isNot(contains(marker)));
        }
        expect(recorded.fatal, isFalse);
      }
      expect(const LabelReportedError('X').toString(), 'LabelReportedError(X)');
    });

    test('BR1.14 a failing sink never breaks the reading', () async {
      final sink = RecordingErrorSink()..fail = true;
      final reporter = LabelErrorReporter(recordingReporter(sink));
      await expectLater(
        reporter.report(LabelFailure.readFailed, StateError('x'), null),
        completes,
      );
    });
  });
}
