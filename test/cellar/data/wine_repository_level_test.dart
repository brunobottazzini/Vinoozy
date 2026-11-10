// WineRepository, label-autofill-windows additions (BR4.3, BR4.6, F5,
// NFR4.14, NFR4.8a): the level written only when chosen, the correction and
// its restore in one update, the quiet writes of the one-off migration.
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:estimation/estimation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/cellar/data/wine_repository.dart';
import 'package:vinoozy/cellar/domain/wine.dart';
import 'package:vinoozy/cellar/domain/wine_draft.dart';
import 'package:vinoozy/cellar/domain/wine_estimate.dart';
import 'package:vinoozy/cellar/domain/wine_validator.dart';
import 'package:vinoozy/sync/ledger/local_ledger.dart';
import 'package:vinoozy/sync/sync_error_bus.dart';

import '../../helpers/fakes.dart';
import '../../helpers/firestore_mocks.dart';
import '../cellar_harness.dart';

void main() {
  setUpAll(registerFirestoreFallbacks);

  const user = cellarOwner;
  late MockFirestore db;
  late BatchRecorder batches;
  late RecordingErrorSink sink;
  late List<SyncEvent> events;
  late WineRepository repository;

  setUp(() {
    db = MockFirestore();
    batches = BatchRecorder(db);
    sink = RecordingErrorSink();
    final bus = SyncErrorBus();
    events = [];
    bus.events.listen(events.add);
    repository = WineRepository(
      db: db,
      ledger: LocalLedger(
        store: InMemoryKeyValueStore(),
        reporter: recordingReporter(sink),
      ),
      bus: bus,
      reporter: recordingReporter(sink),
    );
  });

  const path = 'cellars/user-a/wines/w1';

  WineInput input({WineLevel? level}) => WineInput(
    id: 'w1',
    name: 'Rioja',
    vintage: '2020',
    noVintage: false,
    quantity: 1,
    level: level,
  );

  Map<String, Object?> single() => batches.single.ops.single.data!;

  group('BR4.3 level', () {
    test('a chosen level is written on create, "not chosen" is not', () async {
      await repository.addWine(
        cellarId: 'user-a',
        user: user,
        draft: WineValidator.validate(
          input(level: WineLevel.everyday),
          currentYear: 2026,
        ).draft!,
      );
      // freemium-plus FR2.2: a create also moves the cellar counter, so the
      // wine is picked by its path.
      const winePath = 'cellars/user-a/wines/w1';
      expect(
        batches.batches.last.opAt(winePath).data![WineFields.level],
        'everyday',
      );

      await repository.addWine(
        cellarId: 'user-a',
        user: user,
        draft: WineValidator.validate(input(), currentYear: 2026).draft!,
      );
      expect(
        batches.batches.last.opAt(winePath).data!.containsKey(WineFields.level),
        isFalse,
      );
    });

    test('an edit writes the level, "None" deletes a saved one, a wine '
        'without one stays without', () async {
      WineDraft draftOf(WineLevel? level) =>
          WineValidator.validate(input(level: level), currentYear: 2026).draft!;

      await repository.updateWine(
        cellarId: 'user-a',
        user: user,
        before: cellarWine('w1'),
        draft: draftOf(WineLevel.aging),
        targetQuantity: 2,
        estimate: WineEstimate.none,
      );
      expect(batches.batches.last.ops.single.data![WineFields.level], 'aging');

      await repository.updateWine(
        cellarId: 'user-a',
        user: user,
        before: cellarWine('w1', level: WineLevel.aging),
        draft: draftOf(null),
        targetQuantity: 2,
        estimate: WineEstimate.none,
      );
      expect(
        batches.batches.last.ops.single.data![WineFields.level],
        FieldValue.delete(),
      );

      await repository.updateWine(
        cellarId: 'user-a',
        user: user,
        before: cellarWine('w1'),
        draft: draftOf(null),
        targetQuantity: 2,
        estimate: WineEstimate.none,
      );
      expect(
        batches.batches.last.ops.single.data!.containsKey(WineFields.level),
        isFalse,
      );
    });
  });

  group('F5 NFR4.14 correction in one update', () {
    final window = windowOf(2024, 2028, 2028);

    test(
      'setOverride writes endYear, the server time and the window',
      () async {
        await repository.setOverride(
          cellarId: 'user-a',
          user: user,
          wine: cellarWine('w1'),
          endYear: 2028,
          window: window,
        );

        final op = batches.single.ops.single;
        expect(op.kind, 'update');
        expect(op.path, path);
        final override = single()[WineFields.windowOverride]! as Map;
        expect(override[OverrideFields.endYear], 2028);
        expect(override[OverrideFields.setAt], FieldValue.serverTimestamp());
        expect(single()[WineFields.window], Wine.windowToMap(window));
        expect(single()[WineFields.updatedBy], user.uid);
      },
    );

    test(
      'clearOverride deletes the correction and writes the window',
      () async {
        await repository.clearOverride(
          cellarId: 'user-a',
          user: user,
          wine: cellarWine('w1'),
          window: window,
        );

        expect(single()[WineFields.windowOverride], FieldValue.delete());
        expect(single()[WineFields.window], Wine.windowToMap(window));
      },
    );
  });

  group('NFR4.8a quiet writes', () {
    test('a refused quiet write is told to its caller only', () async {
      batches.commitWith = (_, result) => scheduleMicrotask(
        () => result.completeError(firestoreError('permission-denied')),
      );
      final kinds = <WriteErrorKind>[];

      await repository.setEstimate(
        cellarId: 'user-a',
        user: user,
        wine: cellarWine('w1'),
        estimate: WineEstimate.none,
        quiet: true,
        onFailure: kinds.add,
      );
      await pumpEventQueue();

      expect(kinds, [WriteErrorKind.rejected]);
      expect(events, isEmpty);
      expect(sink.reasons, isEmpty);
    });

    test('a transient quiet failure is told as transient', () async {
      batches.commitWith = (_, result) =>
          scheduleMicrotask(() => result.completeError(StateError('io')));
      final kinds = <WriteErrorKind>[];

      await repository.setEstimate(
        cellarId: 'user-a',
        user: user,
        wine: cellarWine('w1'),
        estimate: WineEstimate.none,
        quiet: true,
        onFailure: kinds.add,
      );
      await pumpEventQueue();

      expect(kinds, [WriteErrorKind.transient]);
      expect(events, isEmpty);
    });

    test('a loud write still shows its refusal', () async {
      batches.commitWith = (_, result) => scheduleMicrotask(
        () => result.completeError(firestoreError('permission-denied')),
      );

      await repository.setEstimate(
        cellarId: 'user-a',
        user: user,
        wine: cellarWine('w1'),
        estimate: WineEstimate.none,
      );
      await pumpEventQueue();

      expect(events, isNotEmpty);
    });
  });
}
