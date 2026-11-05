import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/account/reset_coordinator.dart';
import 'package:vinoozy/firebase/firestore_bootstrap.dart';
import 'package:vinoozy/sync/ledger/local_ledger.dart';

import '../../helpers/fakes.dart';
import '../../helpers/service_mocks.dart';

void main() {
  late InMemoryKeyValueStore store;
  late LocalLedger ledger;
  late MockFirestoreBootstrap bootstrap;
  late MockSyncWatcher watcher;
  late RecordingErrorSink sink;
  late List<String> calls;

  ResetCoordinator coordinator({bool inProcess = true}) => ResetCoordinator(
    ledger: ledger,
    bootstrap: bootstrap,
    watcher: watcher,
    reporter: recordingReporter(sink),
    invalidateListeners: () => calls.add('invalidate'),
    inProcessReset: inProcess,
  );

  setUp(() async {
    store = InMemoryKeyValueStore();
    sink = RecordingErrorSink();
    ledger = LocalLedger(store: store, reporter: recordingReporter(sink));
    bootstrap = MockFirestoreBootstrap();
    watcher = MockSyncWatcher();
    calls = [];
    when(() => watcher.stop()).thenAnswer((_) => calls.add('stop'));
    when(() => bootstrap.resetPersistence()).thenAnswer((_) async {
      final state = await ledger.read();
      calls.add(
        'clear(generation=${state.generation}, '
        'pending=${state.resetPending})',
      );
    });
    await ledger.beginWrite(uid: 'user-a', email: 'a@example.com');
  });

  test(
    'stops, invalidates, resets the ledger and only then clears Firestore',
    () async {
      final outcome = await coordinator().reset('user-b');

      expect(outcome, ResetOutcome.completed);
      expect(calls, [
        'stop',
        'invalidate',
        'clear(generation=1, pending=true)',
      ]);
      final state = await ledger.read();
      expect(state.owner, isNull);
      expect(state.lastUid, 'user-b');
      expect(state.resetPending, isFalse);
    },
  );

  test('plan B keeps resetPending and asks for a restart', () async {
    final outcome = await coordinator(inProcess: false).reset('user-b');

    expect(outcome, ResetOutcome.restartRequired);
    verifyNever(() => bootstrap.resetPersistence());
    expect((await ledger.read()).resetPending, isTrue);
  });

  test(
    'a failed clear reports and fails, keeping resetPending for next start',
    () async {
      when(() => bootstrap.resetPersistence())
          .thenThrow(PersistenceResetException(StateError('busy')));

      final outcome = await coordinator().reset('user-b');

      expect(outcome, ResetOutcome.failed);
      expect(sink.reasons, ['ResetPersistenceFailed']);
      expect((await ledger.read()).resetPending, isTrue);
    },
  );

  test('a ledger failure fails before touching Firestore', () async {
    store.failNextWrite = Exception('prefs');

    final outcome = await coordinator().reset('user-b');

    expect(outcome, ResetOutcome.failed);
    verifyNever(() => bootstrap.resetPersistence());
    expect(sink.reasons, ['ResetLedgerFailed']);
  });

  test('a failure to clear the flag after clearing still completes', () async {
    when(() => bootstrap.resetPersistence()).thenAnswer((_) async {
      store.failNextWrite = Exception('prefs');
    });

    final outcome = await coordinator().reset('user-b');

    expect(outcome, ResetOutcome.completed);
    expect(sink.reasons, ['ResetLedgerFailed']);
  });
}
