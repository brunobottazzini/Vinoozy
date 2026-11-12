import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/sync/ledger/local_ledger.dart';

import '../../helpers/fakes.dart';

void main() {
  late InMemoryKeyValueStore store;
  late RecordingErrorSink sink;
  late LocalLedger ledger;

  JournalEntry entry(String wineId, {String uid = 'user-a'}) => JournalEntry(
    wineId: wineId,
    cellarId: uid,
    name: 'Wine $wineId',
    ownerUid: uid,
  );

  Map<String, Object?> stored() =>
      jsonDecode(store.values[LocalLedger.storageKey]!) as Map<String, Object?>;

  setUp(() {
    store = InMemoryKeyValueStore(latency: const Duration(milliseconds: 1));
    sink = RecordingErrorSink();
    ledger = LocalLedger(store: store, reporter: recordingReporter(sink));
  });

  test('concurrent mutations are serialized without losing updates', () async {
    await Future.wait([
      for (var i = 0; i < 40; i++)
        ledger.beginWrite(
          uid: 'user-a',
          email: 'a@example.com',
          entry: entry('w$i'),
        ),
      ledger.setLastUid('user-a'),
    ]);

    final state = await ledger.read();
    expect(state.owner!.seq, 40);
    expect(state.journal, hasLength(40));
    expect(state.lastUid, 'user-a');
    // A fresh ledger over the same store sees the same persisted value.
    final reopened = LocalLedger(
      store: store,
      reporter: recordingReporter(sink),
    );
    expect((await reopened.read()).journal, hasLength(40));
  });

  test(
    'beginWrite creates the owner, increments seq and adds an open entry',
    () async {
      final first = await ledger.beginWrite(
        uid: 'user-a',
        email: 'a@example.com',
        entry: entry('w1'),
      );
      final second = await ledger.beginWrite(
        uid: 'user-a',
        email: 'a@example.com',
      );

      expect(first.seq, 1);
      expect(second.seq, 2);
      expect(first.generation, 0);
      final owner = stored()['owner'] as Map<String, Object?>;
      expect(owner, {'uid': 'user-a', 'email': 'a@example.com', 'seq': 2});
      final state = await ledger.read();
      expect(state.openEntriesOf('user-a').single.wineId, 'w1');
    },
  );

  test(
    'beginWrite refuses a write for another account and keeps the ledger',
    () async {
      await ledger.beginWrite(uid: 'user-a', email: 'a@example.com');

      await expectLater(
        ledger.beginWrite(uid: 'user-b', email: 'b@example.com'),
        throwsA(isA<LedgerOwnerConflict>()),
      );
      expect((await ledger.read()).owner!.uid, 'user-a');
    },
  );

  group('tryReleaseOwner', () {
    test(
      'does not release when seq changed, uid differs or entries remain',
      () async {
        await ledger.beginWrite(
          uid: 'user-a',
          email: 'a@example.com',
          entry: entry('w1'),
        );

        expect(
          await ledger.tryReleaseOwner(0, 'user-a'),
          ReleaseOutcome.seqChanged,
        );
        expect(
          await ledger.tryReleaseOwner(1, 'user-b'),
          ReleaseOutcome.otherOwner,
        );
        expect(
          await ledger.tryReleaseOwner(1, 'user-a'),
          ReleaseOutcome.entriesRemaining,
        );
        await ledger.markRejected('w1');
        expect(
          await ledger.tryReleaseOwner(1, 'user-a'),
          ReleaseOutcome.entriesRemaining,
        );
        expect((await ledger.read()).owner, isNotNull);
      },
    );

    test(
      'releases once the entries are confirmed and seq is unchanged',
      () async {
        final ticket = await ledger.beginWrite(
          uid: 'user-a',
          email: 'a@example.com',
          entry: entry('w1'),
        );
        await ledger.markConfirmed('w1');

        expect(
          await ledger.tryReleaseOwner(ticket.seq, 'user-a'),
          ReleaseOutcome.released,
        );
        expect((await ledger.read()).owner, isNull);
        expect(
          await ledger.tryReleaseOwner(ticket.seq, 'user-a'),
          ReleaseOutcome.noOwner,
        );
      },
    );
  });

  test(
    'dismiss and noticeShown release the owner when nothing remains',
    () async {
      await ledger.beginWrite(
        uid: 'user-a',
        email: 'a@example.com',
        entry: entry('w1'),
      );
      await ledger.beginWrite(
        uid: 'user-a',
        email: 'a@example.com',
        entry: entry('w2'),
      );
      await ledger.markRejected('w1');
      await ledger.markRejected('w2');

      await ledger.dismiss('w1');
      expect((await ledger.read()).owner, isNotNull, reason: 'w2 still there');

      for (var i = 0; i < 3; i++) {
        await ledger.noticeShown('w2');
      }
      final state = await ledger.read();
      expect(state.journal, isEmpty);
      expect(state.owner, isNull);
    },
  );

  test('noticeShown counts views and removes the entry at the third', () async {
    await ledger.beginWrite(
      uid: 'user-a',
      email: 'a@example.com',
      entry: entry('w1'),
    );
    await ledger.markRejected('w1');

    await ledger.noticeShown('w1');
    await ledger.noticeShown('w1');
    final afterTwo = await ledger.read();
    expect(afterTwo.rejectedEntriesOf('user-a').single.notices, 2);

    await ledger.noticeShown('w1');
    expect((await ledger.read()).journal, isEmpty);
    // Unknown ids are ignored.
    await ledger.noticeShown('missing');
    await ledger.markConfirmed('missing');
  });

  test('reset increments generation, clears owner and journal, keeps '
      'resetPending', () async {
    await ledger.beginWrite(
      uid: 'user-a',
      email: 'a@example.com',
      entry: entry('w1'),
    );
    await ledger.setResetPending(true);

    await ledger.reset('user-b');

    final state = await ledger.read();
    expect(state.generation, 1);
    expect(await ledger.generation(), 1);
    expect(state.owner, isNull);
    expect(state.journal, isEmpty);
    expect(state.lastUid, 'user-b');
    expect(state.resetPending, isTrue);
    expect(stored()['resetPending'], isTrue);
  });

  test('corrupted JSON is replaced by an empty ledger and reported', () async {
    store.values[LocalLedger.storageKey] = '{"owner": 3, "journal": [';

    final state = await ledger.read();

    expect(state.owner, isNull);
    expect(state.journal, isEmpty);
    expect(sink.reasons, ['LedgerCorrupted']);
    expect(stored()['journal'], isEmpty);
  });

  test('wrong field types are treated as corruption too', () async {
    store.values[LocalLedger.storageKey] = jsonEncode({
      'generation': 'two',
      'journal': <Object>[],
    });

    expect((await ledger.read()).generation, 0);
    expect(sink.reasons, ['LedgerCorrupted']);
  });

  test(
    'a failed store write is surfaced and leaves the state unchanged',
    () async {
      store.failNextWrite = Exception('disk full');

      await expectLater(
        ledger.beginWrite(
          uid: 'user-a',
          email: 'a@example.com',
          entry: entry('w1'),
        ),
        throwsException,
      );

      final state = await ledger.read();
      expect(state.owner, isNull);
      expect(state.journal, isEmpty);
      // The queue keeps working after a failure.
      final ticket = await ledger.beginWrite(
        uid: 'user-a',
        email: 'a@example.com',
      );
      expect(ticket.seq, 1);
    },
  );

  test('watch emits the current state and then every change', () async {
    final events = <LedgerState>[];
    final subscription = ledger.watch().listen(events.add);
    await pumpEventQueue();

    await ledger.setLastUid('user-a');
    await pumpEventQueue();
    await subscription.cancel();

    expect(events.first.lastUid, isNull);
    expect(events.last.lastUid, 'user-a');
  });

  group('actions-release-fix: writes of an account no longer active', () {
    test(
      'a write of the deleted account is refused and sets no owner',
      () async {
        await ledger.reset(null, closedUid: 'user-a');

        await expectLater(
          ledger.beginWrite(uid: 'user-a', email: 'a@example.com'),
          throwsA(isA<LedgerSessionClosed>()),
        );
        final state = await ledger.read();
        expect(state.owner, isNull);
        // The next account (any other uid) writes normally.
        await ledger.beginWrite(uid: 'user-b', email: 'b@example.com');
        expect((await ledger.read()).owner!.uid, 'user-b');
      },
    );

    test('after a reset for another account the old one is refused', () async {
      await ledger.setLastUid('user-a');
      await ledger.reset('user-b');

      await expectLater(
        ledger.beginWrite(uid: 'user-a', email: 'a@example.com'),
        throwsA(isA<LedgerSessionClosed>()),
      );
      await ledger.beginWrite(uid: 'user-b', email: 'b@example.com');
      expect((await ledger.read()).owner!.uid, 'user-b');
    });

    test('the active account and a fresh ledger keep writing', () async {
      await ledger.beginWrite(uid: 'user-a', email: 'a@example.com');
      await ledger.setLastUid('user-a');
      await ledger.beginWrite(uid: 'user-a', email: 'a@example.com');
      expect((await ledger.read()).owner!.seq, 2);
    });

    test(
      'closedUid is saved, read back and absent from older values',
      () async {
        await ledger.reset(null, closedUid: 'user-a');
        expect(stored()['closedUid'], 'user-a');
        final reopened = LocalLedger(
          store: store,
          reporter: recordingReporter(sink),
        );
        expect((await reopened.read()).closedUid, 'user-a');

        store.values[LocalLedger.storageKey] = jsonEncode({
          'lastUid': 'user-a',
          'generation': 3,
          'owner': null,
          'journal': <Object?>[],
          'resetPending': false,
        });
        final older = LocalLedger(
          store: store,
          reporter: recordingReporter(sink),
        );
        expect((await older.read()).closedUid, isNull);
      },
    );
  });
}
