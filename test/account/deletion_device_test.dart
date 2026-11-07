import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/account/deletion/deletion_device.dart';
import 'package:vinoozy/account/reset_coordinator.dart';
import 'package:vinoozy/core/clock.dart';
import 'package:vinoozy/label/platform/label_error_reporter.dart';
import 'package:vinoozy/label/platform/temp_label_store.dart';
import 'package:vinoozy/sync/ledger/local_ledger.dart';

import '../helpers/fakes.dart';
import '../helpers/service_mocks.dart';

class _MemoryLabelFiles implements LabelFileSystem {
  final List<LabelFileEntry> files = [
    LabelFileEntry('/tmp/label/a.jpg', DateTime(2026)),
    LabelFileEntry('/tmp/label/b.jpg', DateTime(2026)),
  ];

  @override
  Future<List<LabelFileEntry>> list() async => [...files];

  @override
  Future<void> delete(String path) async =>
      files.removeWhere((file) => file.path == path);
}

class _MockLabelReporter extends Mock implements LabelErrorReporter {}

void main() {
  late MockSyncWatcher watcher;
  late MockResetCoordinator resets;
  late LocalLedger ledger;
  late _MemoryLabelFiles labelFiles;
  late int invalidated;
  late int waited;
  late AppDeletionDevice device;

  setUp(() {
    watcher = MockSyncWatcher();
    resets = MockResetCoordinator();
    ledger = LocalLedger(
      store: InMemoryKeyValueStore(),
      reporter: recordingReporter(RecordingErrorSink()),
    );
    labelFiles = _MemoryLabelFiles();
    invalidated = 0;
    waited = 0;
    device = AppDeletionDevice(
      watcher: watcher,
      invalidateListeners: () => invalidated++,
      waitForPendingWrites: () async => waited++,
      ledger: ledger,
      resets: resets,
      labels: () => TempLabelStore(
        files: labelFiles,
        clock: const SystemClock(),
        reporter: _MockLabelReporter(),
      ),
    );
  });

  test('BR1.13 step 0 stops SyncWatcher and every listener', () {
    device.stopSyncAndListeners();
    verify(() => watcher.stop()).called(1);
    expect(invalidated, 1);
  });

  test(
    'BR1.13 step 0 waits for the Firestore queue and clears the ledger',
    () async {
      await ledger.beginWrite(uid: 'uid-1', email: 'a@example.com');
      await device.waitForPendingWrites();
      await device.clearLedger('uid-1');
      expect(waited, 1);
      final state = await ledger.read();
      expect(state.owner, isNull);
      expect(state.generation, 1);
    },
  );

  test('BR1.7 step 7 resets the phone without opening a cellar', () async {
    when(() => resets.reset('uid-1', openCellar: false))
        .thenAnswer((_) async => ResetOutcome.completed);
    expect(await device.resetPhone('uid-1'), ResetOutcome.completed);
    verify(() => resets.reset('uid-1', openCellar: false)).called(1);
  });

  group('ResetCoordinator at step 7 (BR1.7, NFR8.3)', () {
    late MockFirestoreBootstrap bootstrap;
    late RecordingErrorSink sink;

    ResetCoordinator coordinator({bool inProcess = true}) => ResetCoordinator(
      ledger: ledger,
      bootstrap: bootstrap,
      watcher: watcher,
      reporter: recordingReporter(sink),
      invalidateListeners: () => invalidated++,
      inProcessReset: inProcess,
    );

    setUp(() {
      bootstrap = MockFirestoreBootstrap();
      sink = RecordingErrorSink();
      when(() => bootstrap.resetPersistence()).thenAnswer((_) async {});
    });

    test(
      'BR1.7 the deleted account is not recorded as the last user',
      () async {
        await ledger.setLastUid('uid-1');
        final outcome = await coordinator().reset('uid-1', openCellar: false);
        expect(outcome, ResetOutcome.completed);
        expect((await ledger.read()).lastUid, isNull);
        expect((await ledger.read()).resetPending, isFalse);
        expect(invalidated, 1);
      },
    );

    test('plan B asks for a restart; a failed clear is reported', () async {
      expect(
        await coordinator(inProcess: false).reset('uid-1', openCellar: false),
        ResetOutcome.restartRequired,
      );
      when(() => bootstrap.resetPersistence()).thenThrow(StateError('x'));
      expect(
        await coordinator().reset('uid-1', openCellar: false),
        ResetOutcome.failed,
      );
      expect(sink.reasons, ['ResetPersistenceFailed']);
    });
  });

  test('NFR8.3 step 7 empties the label folder of U6', () async {
    await device.clearLabelFiles();
    expect(labelFiles.files, isEmpty);
  });
}
