import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/app/error_reporter.dart';

import '../../helpers/fakes.dart';

void main() {
  group('ErrorReporter.sanitize (NFR8.2)', () {
    test('removes email addresses', () {
      expect(
        ErrorReporter.sanitize('denied for user-a@example.com and X.Y@mail.it'),
        'denied for <email> and <email>',
      );
    });

    test('removes document ids from paths', () {
      expect(
        ErrorReporter.sanitize(
          'write to cellars/abc123/wines/w9 failed; read users/u-1 ok',
        ),
        'write to cellars/<id>/wines/<id> failed; read users/<id> ok',
      );
    });

    test('removes the given sensitive values, longest first', () {
      expect(
        ErrorReporter.sanitize(
          'Barolo Riserva rejected (Barolo)',
          sensitive: ['Barolo', 'Barolo Riserva', '  '],
        ),
        '<redacted> rejected (<redacted>)',
      );
    });

    test('removes id-like tokens but keeps long words', () {
      expect(
        ErrorReporter.sanitize(
          'uid Xb3kP9qL2mN7vR1sT4wY6zA8cD0e LocalCacheWriteFailed',
        ),
        'uid <id> LocalCacheWriteFailed',
      );
    });

    test('leaves a message without personal data unchanged', () {
      const message = 'FirebaseException: [cloud_firestore/unavailable]';
      expect(ErrorReporter.sanitize(message), message);
    });
  });

  group('ErrorReporter.report', () {
    test(
      'records the type and the sanitized message with the reason',
      () async {
        final sink = RecordingErrorSink();
        final reporter = recordingReporter(sink);

        await reporter.report(
          StateError('cellars/user-a/wines/w1 by a@b.com: Barolo'),
          StackTrace.current,
          reason: 'SyncRejected',
          sensitive: ['Barolo'],
        );

        final recorded = sink.recorded.single;
        expect(recorded.reason, 'SyncRejected');
        expect(recorded.fatal, isFalse);
        expect(recorded.error.type, 'StateError');
        expect(recorded.error.message, isNot(contains('Barolo')));
        expect(recorded.error.message, isNot(contains('a@b.com')));
        expect(recorded.error.message, isNot(contains('user-a')));
        expect(recorded.error.toString(), startsWith('StateError: '));
      },
    );

    test('a failing sink is logged and never thrown', () async {
      final sink = RecordingErrorSink()..fail = true;
      final logs = <String>[];

      await recordingReporter(
        sink,
        logs: logs,
      ).report(Exception('x@y.com'), null, reason: 'WriteFailed');

      expect(logs.single, contains('sink failed'));
      expect(logs.single, isNot(contains('x@y.com')));
    });

    test('DebugLogSink accepts errors without throwing', () async {
      await const DebugLogSink().record(
        const SanitizedError('StateError', 'message'),
        null,
        reason: 'Test',
        fatal: true,
      );
    });
  });
}
