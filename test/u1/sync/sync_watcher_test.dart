import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/sync/ledger/local_ledger.dart';
import 'package:vinoozy/sync/sync_gateway.dart';
import 'package:vinoozy/sync/sync_watcher.dart';

import '../../helpers/fakes.dart';

/// Scriptable [SyncGateway].
class FakeGateway implements SyncGateway {
  Map<String, ServerCheck> results = {};
  Object? checkError;
  Completer<void>? drainBlocker;
  Future<void> Function()? onDrain;
  int drainCalls = 0;
  int activeDrains = 0;
  int maxActiveDrains = 0;
  final List<String> checked = [];
  Duration? checkDelay;
  Map<String, LocalCheck> localResults = {};
  Object? localError;
  final List<String> checkedLocally = [];

  @override
  Future<void> waitForPendingWrites() async {
    drainCalls++;
    activeDrains++;
    if (activeDrains > maxActiveDrains) maxActiveDrains = activeDrains;
    try {
      await onDrain?.call();
      if (drainBlocker != null) await drainBlocker!.future;
      await Future<void>.delayed(Duration.zero);
    } finally {
      activeDrains--;
    }
  }

  @override
  Future<ServerCheck> checkWine({
    required String cellarId,
    required String wineId,
  }) async {
    checked.add(wineId);
    if (checkDelay != null) await Future<void>.delayed(checkDelay!);
    if (checkError != null) throw checkError!;
    return results[wineId] ?? ServerCheck.exists;
  }

  @override
  Future<LocalCheck> checkLocal({
    required String cellarId,
    required String wineId,
  }) async {
    checkedLocally.add(wineId);
    if (localError != null) throw localError!;
    return localResults[wineId] ?? LocalCheck.absent;
  }
}

void main() {
  late LocalLedger ledger;
  late RecordingErrorSink sink;
  late FakeGateway gateway;
  late SyncWatcher watcher;

  JournalEntry entry(String wineId) => JournalEntry(
    wineId: wineId,
    cellarId: 'user-a',
    name: 'Wine $wineId',
    ownerUid: 'user-a',
  );

  Future<void> write(String wineId) => ledger.beginWrite(
    uid: 'user-a',
    email: 'a@example.com',
    entry: entry(wineId),
  );

  setUp(() {
    sink = RecordingErrorSink();
    ledger = LocalLedger(
      store: InMemoryKeyValueStore(),
      reporter: recordingReporter(sink),
    );
    gateway = FakeGateway();
    watcher = SyncWatcher(
      ledger: ledger,
      gateway: gateway,
      reporter: recordingReporter(sink),
      drainTimeout: const Duration(milliseconds: 50),
      serverTimeout: const Duration(milliseconds: 50),
    );
  });

  test(
    'confirms the wines found on the server and releases the owner',
    () async {
      await write('w1');
      await write('w2');

      await watcher.start('user-a');

      final state = await ledger.read();
      expect(state.journal, isEmpty);
      expect(state.owner, isNull);
      expect(gateway.checked, ['w1', 'w2']);
    },
  );

  test(
    'a missing or denied wine becomes rejected and keeps the owner',
    () async {
      await write('w1');
      await write('w2');
      gateway.results = {'w1': ServerCheck.missing, 'w2': ServerCheck.denied};

      await watcher.start('user-a');

      final state = await ledger.read();
      expect(state.rejectedEntriesOf('user-a'), hasLength(2));
      expect(state.owner, isNotNull);
      expect(sink.reasons, ['SyncRejected', 'SyncRejected']);
      expect(sink.recorded.first.error.message, isNot(contains('Wine w1')));
    },
  );

  test('a drain timeout ends the pass without touching the ledger', () async {
    await write('w1');
    gateway.drainBlocker = Completer<void>();

    await watcher.start('user-a');

    expect(watcher.isRunning, isFalse, reason: 'single-run slot is freed');
    expect(gateway.checked, isEmpty);
    expect((await ledger.read()).openEntriesOf('user-a'), hasLength(1));
    gateway.drainBlocker!.complete();
  });

  test(
    'unavailable or a server timeout stops the pass, entry stays open',
    () async {
      await write('w1');
      await write('w2');
      gateway.results = {'w1': ServerCheck.unavailable};

      await watcher.start('user-a');
      expect(gateway.checked, ['w1'], reason: 'w2 is not checked');
      expect((await ledger.read()).openEntriesOf('user-a'), hasLength(2));

      gateway
        ..results = {}
        ..checkDelay = const Duration(milliseconds: 200);
      await watcher.trigger();
      expect((await ledger.read()).openEntriesOf('user-a'), hasLength(2));
      expect(sink.reasons, isEmpty);
    },
  );

  test('other server errors are reported and the entry stays open', () async {
    await write('w1');
    gateway.checkError = StateError('boom');

    await watcher.start('user-a');

    expect(sink.reasons, ['ServerCheckFailed']);
    final state = await ledger.read();
    expect(state.openEntriesOf('user-a'), hasLength(1));
    expect(state.owner, isNotNull);
  });

  test(
    'only one pass runs at a time; a trigger during it repeats once',
    () async {
      await write('w1');
      // Rejected entry: the owner stays, so the repeated pass drains again.
      gateway
        ..results = {'w1': ServerCheck.denied}
        ..drainBlocker = Completer<void>();

      final first = watcher.start('user-a');
      await pumpEventQueue();
      final second = watcher.trigger();
      final third = watcher.trigger();
      gateway.drainBlocker!.complete();
      await Future.wait([first, second, third]);

      expect(gateway.maxActiveDrains, 1);
      expect(gateway.drainCalls, 2, reason: 'the run plus one repeat');
    },
  );

  test('a write during the pass repeats at once, at most 3 times', () async {
    await write('w0');
    var next = 1;
    gateway.onDrain = () => write('w${next++}');

    await watcher.start('user-a');

    expect(gateway.drainCalls, 4, reason: '1 pass + 3 immediate repeats');
    expect((await ledger.read()).owner, isNotNull);
  });

  test('stop during a pass leaves the ledger untouched', () async {
    await write('w1');
    gateway.drainBlocker = Completer<void>();

    final run = watcher.start('user-a');
    await pumpEventQueue();
    watcher.stop();
    gateway.drainBlocker!.complete();
    await run;

    expect(gateway.checked, isEmpty);
    expect((await ledger.read()).openEntriesOf('user-a'), hasLength(1));
    await watcher.trigger();
    expect(gateway.drainCalls, 1, reason: 'stopped watcher ignores triggers');
  });

  test('nothing to do when the ledger has no owner or another owner', () async {
    await watcher.start('user-a');
    expect(gateway.drainCalls, 0);

    await ledger.beginWrite(uid: 'user-b', email: 'b@example.com');
    await watcher.trigger();
    expect(gateway.drainCalls, 0);
  });

  test('a failing drain is reported and the pass ends', () async {
    await write('w1');
    gateway.onDrain = () async => throw StateError('user changed');

    await watcher.start('user-a');

    expect(sink.reasons, ['PendingWritesWaitFailed']);
    expect(gateway.checked, isEmpty);
  });

  group('entries added or still in flight during a pass (review R-01)', () {
    test('an entry journaled during the drain is verified only in the next '
        'pass, after its own drain', () async {
      await write('w1');
      var drains = 0;
      gateway.onDrain = () async {
        drains++;
        if (drains == 1) {
          // Second wine added offline while the first drain runs: its write
          // is not covered by this drain and is not on the server yet.
          await write('w2');
          gateway.results['w2'] = ServerCheck.missing;
        } else {
          // The next drain covers it: the server now has it.
          gateway.results['w2'] = ServerCheck.exists;
        }
      };

      await watcher.start('user-a');

      final state = await ledger.read();
      expect(state.journal, isEmpty, reason: 'both wines confirmed');
      expect(state.owner, isNull);
      expect(sink.reasons, isEmpty, reason: 'no SyncRejected for w2');
      expect(gateway.checked, ['w1', 'w2']);
    });

    test('an open entry found missing is re-checked after a second drain '
        'before it becomes rejected', () async {
      await write('w1');
      gateway.results = {'w1': ServerCheck.missing};
      var drains = 0;
      gateway.onDrain = () async {
        if (++drains == 2) gateway.results['w1'] = ServerCheck.exists;
      };

      await watcher.start('user-a');

      final state = await ledger.read();
      expect(state.journal, isEmpty);
      expect(sink.reasons, isEmpty);
      expect(gateway.drainCalls, 2);
      expect(gateway.checked, ['w1', 'w1']);
    });

    test('still missing after the second drain: rejected once', () async {
      await write('w1');
      gateway.results = {'w1': ServerCheck.missing};

      await watcher.start('user-a');

      final state = await ledger.read();
      expect(state.rejectedEntriesOf('user-a').single.wineId, 'w1');
      expect(sink.reasons, ['SyncRejected']);
      expect(gateway.drainCalls, 2);
    });

    test('a timeout on the second drain leaves the entry open', () async {
      await write('w1');
      gateway.results = {'w1': ServerCheck.missing};
      var drains = 0;
      gateway.onDrain = () async {
        if (++drains == 2) gateway.drainBlocker = Completer<void>();
      };

      await watcher.start('user-a');

      expect((await ledger.read()).openEntriesOf('user-a'), hasLength(1));
      expect(sink.reasons, isEmpty);
      gateway.drainBlocker!.complete();
    });

    test('a rejected wine that later reaches the server is confirmed, so '
        'its notice goes', () async {
      await write('w1');
      await ledger.markRejected('w1');
      gateway.results = {'w1': ServerCheck.exists};

      await watcher.start('user-a');

      final state = await ledger.read();
      expect(state.journal, isEmpty);
      expect(state.owner, isNull);
      expect(sink.reasons, isEmpty);
    });

    test(
      'a rejected wine still missing stays rejected, not reported again',
      () async {
        await write('w1');
        await ledger.markRejected('w1');
        gateway.results = {'w1': ServerCheck.missing};

        await watcher.start('user-a');

        final state = await ledger.read();
        expect(state.rejectedEntriesOf('user-a'), hasLength(1));
        expect(sink.reasons, isEmpty);
        expect(gateway.drainCalls, 1, reason: 'no second drain for rejected');
      },
    );
  });

  group('reconcileRejected before "Add again" (review R-01)', () {
    Future<JournalEntry> rejected(String wineId) async {
      await write(wineId);
      await ledger.markRejected(wineId);
      return (await ledger.read()).rejectedEntriesOf('user-a').single;
    }

    test('synced in the local cache: confirmed, nothing to re-add', () async {
      final entry = await rejected('w1');
      gateway.localResults = {'w1': LocalCheck.synced};

      expect(await watcher.reconcileRejected(entry), isTrue);
      expect((await ledger.read()).journal, isEmpty);
      expect(gateway.checked, isEmpty, reason: 'works offline');
    });

    test('still queued on the phone: open again and verified', () async {
      final entry = await rejected('w1');
      await ledger.noticeShown('w1');
      gateway
        ..localResults = {'w1': LocalCheck.pending}
        ..results = {'w1': ServerCheck.missing};
      await watcher.start('user-a');
      expect((await ledger.read()).rejectedEntriesOf('user-a'), hasLength(1));
      gateway
        ..checked.clear()
        ..results = {'w1': ServerCheck.exists};

      expect(await watcher.reconcileRejected(entry), isTrue);
      await pumpEventQueue();
      await watcher.trigger();

      expect((await ledger.read()).journal, isEmpty);
      expect(gateway.checked, contains('w1'));
    });

    test('reopen resets the notice count and keeps the entry', () async {
      final entry = await rejected('w1');
      await ledger.noticeShown('w1');
      gateway.localResults = {'w1': LocalCheck.pending};

      expect(await watcher.reconcileRejected(entry), isTrue);

      final reopened = (await ledger.read()).openEntriesOf('user-a').single;
      expect(reopened.notices, 0);
    });

    test('not on the phone but on the server: confirmed', () async {
      final entry = await rejected('w1');
      gateway.results = {'w1': ServerCheck.exists};

      expect(await watcher.reconcileRejected(entry), isTrue);
      expect((await ledger.read()).journal, isEmpty);
    });

    test('nowhere: false, the entry is left for the caller', () async {
      final entry = await rejected('w1');
      gateway.results = {'w1': ServerCheck.missing};

      expect(await watcher.reconcileRejected(entry), isFalse);
      expect((await ledger.read()).rejectedEntriesOf('user-a'), hasLength(1));
    });

    test(
      'a cache error is reported; an unreachable server gives false',
      () async {
        final entry = await rejected('w1');
        gateway
          ..localError = StateError('cache')
          ..results = {'w1': ServerCheck.unavailable};

        expect(await watcher.reconcileRejected(entry), isFalse);
        expect(sink.reasons, ['LocalCheckFailed']);
      },
    );
  });
}
