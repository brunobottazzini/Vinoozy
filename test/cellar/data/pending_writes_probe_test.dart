// PendingWritesProbe (security-design.md §4; NFR6.6): the drinks keep the
// banner "pending" until waitForPendingWrites completes; the start-up check
// waits 300 ms before showing it. Time is the fake time of testWidgets.
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/cellar/data/pending_writes_probe.dart';

import '../../helpers/fakes.dart';

void main() {
  late List<Completer<void>> waits;
  late List<bool> changes;
  late RecordingErrorSink sink;
  late PendingWritesProbe probe;

  setUp(() {
    waits = [];
    changes = [];
    sink = RecordingErrorSink();
    probe = PendingWritesProbe(
      waitForPendingWrites: () {
        final wait = Completer<void>();
        waits.add(wait);
        return wait.future;
      },
      onPendingChanged: changes.add,
      reporter: recordingReporter(sink),
    );
  });

  test(
    'NFR6.6 a drink write is pending until the queue is confirmed',
    () async {
      unawaited(probe.trackWrite());
      expect(changes, [true]);
      expect(probe.isPending, isTrue);

      waits.single.complete();
      await pumpEventQueue();

      expect(changes, [true, false]);
    },
  );

  test('NFR6.6 only the latest wait clears the banner', () async {
    unawaited(probe.trackWrite());
    unawaited(probe.trackWrite());
    waits.first.complete();
    await pumpEventQueue();
    expect(changes, [true], reason: 'a later write is still queued');

    waits.last.complete();
    await pumpEventQueue();
    expect(changes, [true, false]);
  });

  test(
    'a failed wait clears the banner and reports pending_probe_failed',
    () async {
      unawaited(probe.trackWrite());
      waits.single.completeError(StateError('signed out'));
      await pumpEventQueue();

      expect(changes, [true, false]);
      expect(sink.reasons, ['pending_probe_failed']);
    },
  );

  testWidgets('a start-up wait within 300 ms never shows the banner', (
    tester,
  ) async {
    unawaited(probe.checkAtStartup());
    await tester.pump(const Duration(milliseconds: 299));
    waits.single.complete();
    await tester.pump(const Duration(milliseconds: 10));

    expect(changes, isEmpty);
  });

  testWidgets(
    'a start-up wait over 300 ms shows it until the queue is confirmed',
    (tester) async {
      unawaited(probe.checkAtStartup());
      await tester.pump(const Duration(milliseconds: 301));
      expect(changes, [true]);

      waits.single.complete();
      await tester.pump();
      expect(changes, [true, false]);
    },
  );
}
