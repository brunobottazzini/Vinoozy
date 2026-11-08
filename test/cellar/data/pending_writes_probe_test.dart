// PendingWritesProbe (security-design.md §4; NFR6.6; pending-banner-fix
// FR1.1-FR1.3, FR2): the drinks keep the banner "pending" until every
// tracked commit future has completed, with no waitForPendingWrites; the
// start-up check still waits for the queue and waits 300 ms before showing
// it. Time is the fake time of testWidgets.
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

  test('FR1.1 a drink write is pending until that write completes, '
      'with no queue wait', () async {
    final write = Completer<void>();
    unawaited(probe.trackWrite(write.future));
    expect(changes, [true]);
    expect(probe.isPending, isTrue);

    await pumpEventQueue();
    expect(probe.isPending, isTrue, reason: 'the write is still open');

    write.complete();
    await pumpEventQueue();

    expect(changes, [true, false]);
    expect(probe.isPending, isFalse);
    expect(waits, isEmpty, reason: 'waitForPendingWrites is never called');
  });

  test(
    'FR1.2 two writes, the first completes first: pending until the second',
    () async {
      final first = Completer<void>();
      final second = Completer<void>();
      unawaited(probe.trackWrite(first.future));
      unawaited(probe.trackWrite(second.future));

      first.complete();
      await pumpEventQueue();
      expect(changes, [true], reason: 'a later write is still open');

      second.complete();
      await pumpEventQueue();
      expect(changes, [true, false]);
    },
  );

  test(
    'FR1.2 two writes, the second completes first: pending until the first',
    () async {
      final first = Completer<void>();
      final second = Completer<void>();
      unawaited(probe.trackWrite(first.future));
      unawaited(probe.trackWrite(second.future));

      second.complete();
      await pumpEventQueue();
      expect(changes, [true], reason: 'an earlier write is still open');

      first.complete();
      await pumpEventQueue();
      expect(changes, [true, false]);
    },
  );

  test(
    'FR1.3 a failed write clears the banner with no pending_probe_failed',
    () async {
      final write = Completer<void>();
      unawaited(probe.trackWrite(write.future));
      write.completeError(StateError('permission-denied'));
      await pumpEventQueue();

      expect(changes, [true, false]);
      expect(sink.reasons, isEmpty, reason: 'the writer reports it, once');
    },
  );

  test('FR1.3 the first write fails while the second is open: '
      'pending until the second', () async {
    final first = Completer<void>();
    final second = Completer<void>();
    unawaited(probe.trackWrite(first.future));
    unawaited(probe.trackWrite(second.future));

    first.completeError(StateError('invalid-argument'));
    await pumpEventQueue();
    expect(changes, [true], reason: 'the second write is still open');

    second.complete();
    await pumpEventQueue();
    expect(changes, [true, false]);
    expect(sink.reasons, isEmpty);
  });

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
