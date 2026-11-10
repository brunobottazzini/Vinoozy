// WineRepository, u4-cellar extension (logical-components.md; BR1.4, BR1.7,
// BR1.13-BR1.15, BR1.20; NFR5.1, NFR5.3, NFR5.5, NFR6.2, NFR8.2): batches
// checked operation by operation, increments with the negative correction,
// the deletion in parts with its retry.
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/account/app_user.dart';
import 'package:vinoozy/cellar/data/wine_repository.dart';
import 'package:vinoozy/cellar/domain/wine.dart';
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
  late LocalLedger ledger;
  late RecordingErrorSink sink;
  late SyncErrorBus bus;
  late List<SyncEvent> events;
  late WineRepository repository;
  late int started;

  setUp(() {
    db = MockFirestore();
    batches = BatchRecorder(db);
    sink = RecordingErrorSink();
    ledger = LocalLedger(
      store: InMemoryKeyValueStore(),
      reporter: recordingReporter(sink),
    );
    bus = SyncErrorBus();
    events = [];
    bus.events.listen(events.add);
    started = 0;
    repository = WineRepository(
      db: db,
      ledger: ledger,
      bus: bus,
      reporter: recordingReporter(sink),
      onWriteStarted: () => started++,
      maxBatchWrites: 400,
    );
  });

  String path(String id) => 'cellars/user-a/wines/$id';

  /// `collection(path).where(field, ...)` returning [query].
  MockQuery stubWhere(
    String collectionPath,
    MockQuery Function(MockCollectionRef collection) where,
  ) {
    final collection = MockCollectionRef();
    when(() => db.collection(collectionPath)).thenReturn(collection);
    return where(collection);
  }

  group('BR1.7 NFR5.1 watchCellarWines', () {
    test(
      'BR1.7 listens with quantity > 0, sorts by name, keeps the metadata',
      () async {
        final query = stubWhere('cellars/user-a/wines', (collection) {
          final query = MockQuery();
          when(() => collection.where('quantity', isGreaterThan: 0))
              .thenReturn(query);
          return query;
        });
        when(() => query.snapshots(includeMetadataChanges: true)).thenAnswer(
          (_) => Stream.value(
            querySnapshotOf(
              {
                'w2': {'name': 'Soave', 'quantity': 1},
                'w1': {'name': 'Barolo', 'quantity': 2, 'matchKey': 'barolo||'},
              },
              fromCache: true,
              pending: true,
            ),
          ),
        );

        final snapshot = await repository.watchCellarWines('user-a').first;

        expect(snapshot.wines.map((w) => w.name), ['Barolo', 'Soave']);
        expect(snapshot.wines.first.matchKey, 'barolo||');
        expect(snapshot.meta.isFromCache, isTrue);
        expect(snapshot.meta.hasPendingWrites, isTrue);
      },
    );

    test('BR1.7 the archive reads quantity <= 0 once', () async {
      final query = stubWhere('cellars/user-a/wines', (collection) {
        final query = MockQuery();
        when(() => collection.where('quantity', isLessThanOrEqualTo: 0))
            .thenReturn(query);
        return query;
      });
      when(() => query.get(any())).thenAnswer(
        (_) async => querySnapshotOf({
          'w3': {'name': 'Vermentino', 'quantity': 0},
          'w4': {'name': 'Arneis', 'quantity': -1},
        }),
      );

      final archived = await repository.fetchArchived('user-a');

      expect(archived.map((w) => w.name), ['Arneis', 'Vermentino']);
      expect(archived.first.quantity, 0);
    });

    test('watchWine maps a document and a missing one', () async {
      final ref = MockDocRef();
      when(() => db.doc(path('w1'))).thenReturn(ref);
      final present = docSnapshot(exists: true, data: {'name': 'Barolo'});
      when(() => present.id).thenReturn('w1');
      final missing = docSnapshot(exists: false);
      when(() => ref.snapshots())
          .thenAnswer((_) => Stream.fromIterable([present, missing]));

      final wines = await repository.watchWine('user-a', 'w1').toList();

      expect(wines.first!.name, 'Barolo');
      expect(wines.last, isNull);
    });
  });

  group('BR1.4 findByMatchKey', () {
    late MockQuery query;

    setUp(() {
      query = stubWhere('cellars/user-a/wines', (collection) {
        final query = MockQuery();
        when(() => collection.where('matchKey', isEqualTo: 'barolo||2016'))
            .thenReturn(query);
        return query;
      });
    });

    test(
      'BR1.4 the server answers: oldest entry first, finished ones too',
      () async {
        when(() => query.get(any())).thenAnswer((invocation) async {
          final options = invocation.positionalArguments.first as GetOptions;
          expect(options.source, Source.server);
          return querySnapshotOf({
            'new': {
              'name': 'Barolo',
              'quantity': 0,
              'createdAt': DateTime.utc(2026, 2),
            },
            'old': {
              'name': 'Barolo',
              'quantity': 2,
              'createdAt': DateTime.utc(2026, 1),
            },
          });
        });

        final found = await repository.findByMatchKey('user-a', 'barolo||2016');

        expect(found.map((w) => w.id), ['old', 'new']);
      },
    );

    test('BR1.4 offline the cache answers', () async {
      when(() => query.get(any())).thenAnswer((invocation) async {
        final options = invocation.positionalArguments.first as GetOptions;
        if (options.source == Source.server) {
          throw firestoreError('unavailable');
        }
        return querySnapshotOf({
          'w1': {'name': 'Barolo', 'quantity': 1},
        });
      });

      final found = await repository.findByMatchKey('user-a', 'barolo||2016');

      expect(found.single.id, 'w1');
    });

    testWidgets('BR1.4 a slow server is abandoned after 1 s for the cache', (
      tester,
    ) async {
      final never = Completer<QuerySnapshot<Map<String, dynamic>>>();
      when(() => query.get(any())).thenAnswer((invocation) {
        final options = invocation.positionalArguments.first as GetOptions;
        if (options.source == Source.server) return never.future;
        return Future.value(querySnapshotOf({}));
      });

      List<Object>? found;
      unawaited(
        repository
            .findByMatchKey('user-a', 'barolo||2016')
            .then((value) => found = value),
      );
      await tester.pump(const Duration(milliseconds: 999));
      expect(found, isNull);
      await tester.pump(const Duration(milliseconds: 2));

      expect(found, isEmpty);
    });
  });

  group('BR1.4 BR1.5 addWine', () {
    final draft = WineValidator.validate(
      const WineInput(
        id: 'w9',
        name: 'Barolo',
        producer: 'Cantina Esempio',
        vintage: '2016',
        noVintage: false,
        quantity: 2,
        wineType: 'redStructured',
        denomination: 'Barolo DOCG',
      ),
      currentYear: 2026,
    ).draft!;
    final estimate = WineEstimate(
      baseWindow: windowOf(2024, 2028, 2034),
      window: windowOf(2024, 2028, 2034),
    );

    test(
      'BR1.5 writes the details, matchKey and the estimate in one batch',
      () async {
        final outcome = await repository.addWine(
          cellarId: 'user-a',
          user: user,
          draft: draft,
          estimate: estimate,
        );
        await pumpEventQueue();

        expect(outcome, isA<SaveAccepted>());
        final op = batches.single.opAt(path('w9'));
        expect(op.kind, 'set');
        expect(op.data!['name'], 'Barolo');
        expect(op.data!['producer'], 'Cantina Esempio');
        expect(op.data!['wineType'], 'redStructured');
        expect(op.data!['denomination'], 'Barolo DOCG');
        expect(op.data!.containsKey('region'), isFalse);
        expect(op.data!['matchKey'], 'barolo|cantina esempio|2016');
        expect((op.data!['window'] as Map)['startYear'], 2024);
        expect((op.data!['baseWindow'] as Map)['basis'], 'denomination');
        expect(op.data!.containsKey('windowAdjustment'), isFalse);
        expect(op.data!['quantity'], 2);
        expect(op.data!['createdAt'], FieldValue.serverTimestamp());
        expect(started, 1);
        expect((await ledger.read()).journal, isEmpty, reason: 'confirmed');
      },
    );

    test('ux FR1.5 writes the country and the canonical region', () async {
      final withCountry = WineValidator.validate(
        const WineInput(
          id: 'w8',
          name: 'Malbec Reserva',
          vintage: '2019',
          noVintage: false,
          quantity: 1,
          country: 'AR',
          region: ' mendoza ',
        ),
        currentYear: 2026,
      ).draft!;

      await repository.addWine(
        cellarId: 'user-a',
        user: user,
        draft: withCountry,
      );

      final data = batches.single.opAt(path('w8')).data!;
      expect(data['country'], 'AR');
      expect(data['region'], 'Mendoza');
    });

    test('ux NFR4 a wine without country has no country key', () async {
      await repository.addWine(cellarId: 'user-a', user: user, draft: draft);

      expect(
        batches.single.opAt(path('w9')).data!.containsKey('country'),
        isFalse,
      );
    });

    test(
      'NFR8.2 a refused creation is reported with a fixed reason, no names',
      () async {
        batches.commitWith = (_, result) =>
            result.completeError(firestoreError('permission-denied'));
        final marked = WineValidator.validate(
          WineInput(
            id: 'w9',
            name: sensitiveMarkers[0],
            producer: sensitiveMarkers[1],
            vintage: '',
            noVintage: true,
            quantity: 1,
            denomination: sensitiveMarkers[2],
          ),
          currentYear: 2026,
        ).draft!;

        await repository.addWine(cellarId: 'user-a', user: user, draft: marked);
        await pumpEventQueue();

        expect(sink.reasons, ['cellar_save_failed']);
        final reported = '${sink.recorded.single.error}';
        for (final marker in sensitiveMarkers) {
          expect(reported, isNot(contains(marker)));
        }
        expect(events.whereType<WriteRejected>().single.wineId, 'w9');
        expect(
          (await ledger.read()).rejectedEntriesOf('user-a').single.wineId,
          'w9',
        );
      },
    );
  });

  group('BR1.15 NFR6.2 quantities as increments', () {
    Future<Object?> addThree(int stored) async {
      await repository.addBottles(
        cellarId: 'user-a',
        user: user,
        wine: cellarWine('w1', quantity: stored),
        n: 3,
      );
      return batches.batches.last.opAt(path('w1')).data!['quantity'];
    }

    test('BR1.15 +3 on stored −2, 0 and 3', () async {
      expect(await addThree(-2), FieldValue.increment(5));
      expect(await addThree(0), FieldValue.increment(3));
      expect(await addThree(3), FieldValue.increment(3));
      expect(
        batches.batches.last.single(path('w1')).data!['updatedBy'],
        'user-a',
      );
    });

    test('BR1.3 R-05 no addition over 99 bottles, no write', () async {
      final refused = await repository.addBottles(
        cellarId: 'user-a',
        user: user,
        wine: cellarWine('w1', quantity: 98),
        n: 2,
      );
      expect(refused, isA<SaveFailure>());
      expect(batches.batches, isEmpty);

      final accepted = await repository.addBottles(
        cellarId: 'user-a',
        user: user,
        wine: cellarWine('w1', quantity: 98),
        n: 1,
      );
      expect(accepted, isA<SaveAccepted>());

      final merge = await repository.mergeInto(
        cellarId: 'user-a',
        user: user,
        older: cellarWine('old', quantity: 60),
        newer: cellarWine('new', quantity: 40),
      );
      expect(merge, isA<SaveFailure>());
      expect(batches.batches, hasLength(1));
    });

    test('BR1.15 "−" only while the shown quantity is above 0', () async {
      for (final stored in [-2, 0]) {
        final outcome = await repository.removeBottle(
          cellarId: 'user-a',
          user: user,
          wine: cellarWine('w1', quantity: stored),
        );
        expect(outcome, isA<SaveFailure>());
      }
      expect(batches.batches, isEmpty);

      await repository.removeBottle(
        cellarId: 'user-a',
        user: user,
        wine: cellarWine('w1', quantity: 3),
      );
      expect(
        batches.single.opAt(path('w1')).data!['quantity'],
        FieldValue.increment(-1),
      );
    });
  });

  group('BR1.13 updateWine', () {
    WineValidation edited() => WineValidator.validate(
      const WineInput(
        id: 'w1',
        name: 'Barolo Riserva',
        producer: '',
        vintage: '2016',
        noVintage: false,
        quantity: 1,
      ),
      currentYear: 2026,
    );

    test('BR1.13 texts, matchKey, estimate and the quantity change', () async {
      await repository.updateWine(
        cellarId: 'user-a',
        user: user,
        before: cellarWine('w1', quantity: 3),
        draft: edited().draft!,
        targetQuantity: 1,
        estimate: WineEstimate.none,
      );

      final data = batches.single.opAt(path('w1')).data!;
      expect(data['name'], 'Barolo Riserva');
      expect(data['producer'], isNull);
      expect(data['matchKey'], 'barolo riserva||2016');
      expect(data['quantity'], FieldValue.increment(-2));
      expect(data.containsKey('window'), isTrue);
      expect(data['window'], isNull);
      expect(data['updatedAt'], FieldValue.serverTimestamp());
    });

    WineValidation withOrigin({String? country, String? region}) =>
        WineValidator.validate(
          WineInput(
            id: 'w1',
            name: 'Barolo',
            vintage: '2016',
            noVintage: false,
            quantity: 2,
            country: country,
            region: region,
          ),
          currentYear: 2026,
        );

    Future<Map<String, Object?>> update(
      Wine before,
      WineValidation input,
    ) async {
      await repository.updateWine(
        cellarId: 'user-a',
        user: user,
        before: before,
        draft: input.draft!,
        targetQuantity: before.quantity,
        estimate: WineEstimate.none,
      );
      return batches.batches.last.opAt(path(before.id)).data!;
    }

    test(
      'ux R-06 an earlier wine with an Italian region saves country IT',
      () async {
        final data = await update(
          cellarWine('w1', region: 'piemonte'),
          withOrigin(region: 'piemonte'),
        );
        expect(data['country'], 'IT');
        expect(data['region'], 'Piemonte');
      },
    );

    test(
      'ux FR1.5 NFR4 a wine that never had a country gets no country key',
      () async {
        final data = await update(
          cellarWine('w1', region: 'Somewhere'),
          withOrigin(region: 'Somewhere'),
        );
        expect(data.containsKey('country'), isFalse);
        expect(data['region'], 'Somewhere');
      },
    );

    test('ux FR1.5 a country can be changed and cleared', () async {
      final changed = await update(
        cellarWine('w1', country: 'AR', region: 'Mendoza'),
        withOrigin(country: 'CL', region: 'Maipo'),
      );
      expect(changed['country'], 'CL');
      expect(changed['region'], 'Valle del Maipo');
      final cleared = await update(
        cellarWine('w1', country: 'AR', region: 'Mendoza'),
        withOrigin(),
      );
      expect(cleared.containsKey('country'), isTrue);
      expect(cleared['country'], isNull);
      expect(cleared['region'], isNull);
    });

    test('BR1.13 an unchanged quantity is not written', () async {
      await repository.updateWine(
        cellarId: 'user-a',
        user: user,
        before: cellarWine('w1', quantity: 1),
        draft: edited().draft!,
        targetQuantity: 1,
        estimate: WineEstimate.none,
      );

      expect(
        batches.single.opAt(path('w1')).data!.containsKey('quantity'),
        isFalse,
      );
    });
  });

  test(
    'BR1.20 mergeInto moves the bottles to the older and deletes the newer',
    () async {
      await repository.mergeInto(
        cellarId: 'user-a',
        user: user,
        older: cellarWine('old', quantity: -1),
        newer: cellarWine('new', quantity: 2),
      );
      await pumpEventQueue();

      // freemium-plus FR2.2: the finished older entry becomes active and the
      // newer one stops being active. The rules pair the counter with one
      // wine per batch, so the bottles move first (+1) and the newer entry
      // goes only after that was confirmed (-1): no bottle is ever lost.
      expect(batches.batches, hasLength(2));
      final move = batches.batches.first;
      expect(move.opAt(path('old')).data!['quantity'], FieldValue.increment(3));
      expect(move.opAt('cellars/user-a').data, {
        'activeWineCount': FieldValue.increment(1),
        'activeOpWineId': 'old',
      });
      final remove = batches.batches.last;
      expect(remove.opAt(path('new')).kind, 'delete');
      expect(remove.opAt('cellars/user-a').data, {
        'activeWineCount': FieldValue.increment(-1),
        'activeOpWineId': 'new',
      });
    },
  );

  group('BR1.14 NFR5.5 deleteWineWithRecords', () {
    late MockQuery records;
    late List<Map<String, Map<String, dynamic>>> serverAnswers;
    var cacheOnly = false;

    Map<String, Map<String, dynamic>> drinks(int count, [int from = 0]) => {
      for (var i = from; i < from + count; i++)
        'r$i': {'wineId': 'w1', 'drankOn': '2026-11-06'},
    };

    setUp(() {
      cacheOnly = false;
      serverAnswers = [];
      records = stubWhere('cellars/user-a/drinkingRecords', (collection) {
        final query = MockQuery();
        when(() => collection.where('wineId', isEqualTo: 'w1'))
            .thenReturn(query);
        return query;
      });
      when(() => records.get(any())).thenAnswer((invocation) async {
        final options = invocation.positionalArguments.first as GetOptions;
        if (options.source == Source.server) {
          if (cacheOnly) throw firestoreError('unavailable');
          return querySnapshotOf(serverAnswers.removeAt(0));
        }
        return querySnapshotOf(drinks(2));
      });
      // freemium-plus FR2.2: the retry and purgeRecords read the wine from
      // the server for the counter; it is still active with 2 bottles.
      final wineRef = MockDocRef();
      when(() => wineRef.path).thenReturn(path('w1'));
      when(() => wineRef.get(any())).thenAnswer((_) async {
        if (cacheOnly) throw firestoreError('unavailable');
        return docSnapshot(exists: true, data: {'quantity': 2});
      });
      when(() => db.doc(path('w1'))).thenReturn(wineRef);
    });

    /// The counter -1 of the active wine, last in the last part.
    void expectCounterLast() {
      final last = batches.batches.last.ops.last;
      expect(last.path, 'cellars/user-a');
      expect(last.data, {
        'activeWineCount': FieldValue.increment(-1),
        'activeOpWineId': 'w1',
      });
    }

    Future<DeleteOutcome> delete() => repository.deleteWineWithRecords(
      cellarId: 'user-a',
      user: user,
      wine: cellarWine('w1'),
    );

    test('BR1.14 NFR5.5 900 drinks: parts of 400, the wine last', () async {
      serverAnswers.add(drinks(900));

      expect(await delete(), DeleteOutcome.deleted);

      expect(batches.batches.map((b) => b.ops.length), [400, 400, 102]);
      expect(batches.batches.last.opAt(path('w1')).kind, 'delete');
      expectCounterLast();
      expect(batches.batches.every((b) => b.committed), isTrue);
    });

    test(
      'BR1.14 exactly 400 drinks: the wine goes in a part of its own',
      () async {
        serverAnswers.add(drinks(400));

        expect(await delete(), DeleteOutcome.deleted);
        expect(batches.batches.map((b) => b.ops.length), [400, 2]);
        expectCounterLast();
      },
    );

    test(
      'BR1.14 a refused part is retried once with the drinks read again',
      () async {
        serverAnswers
          ..add(drinks(3))
          ..add(drinks(2, 1));
        batches.commitWith = (index, result) => index == 0
            ? result.completeError(firestoreError('permission-denied'))
            : result.complete();

        expect(await delete(), DeleteOutcome.deleted);
        expect(batches.batches.last.ops.map((op) => op.path), [
          'cellars/user-a/drinkingRecords/r1',
          'cellars/user-a/drinkingRecords/r2',
          path('w1'),
          'cellars/user-a',
        ]);
        expect(sink.recorded, isEmpty);
      },
    );

    test(
      'BR1.14 refused twice: the wine stays and the failure is reported',
      () async {
        serverAnswers
          ..add(drinks(1))
          ..add(drinks(1));
        batches.commitWith = (_, result) =>
            result.completeError(firestoreError('permission-denied'));

        expect(await delete(), DeleteOutcome.failed);
        expect(sink.reasons, ['cellar_delete_failed']);
      },
    );

    test(
      'BR1.14 NFR6.6 offline: everything queued on the phone at once',
      () async {
        cacheOnly = true;
        batches.commitWith = (_, result) {}; // never confirmed offline

        expect(await delete(), DeleteOutcome.queued);
        expect(batches.single.ops.map((op) => op.kind), [
          'delete',
          'delete',
          'delete',
          'update',
        ]);
        expectCounterLast();
        expect(batches.single.committed, isTrue);
      },
    );

    test('BR1.14 R-06 the wine is deleted only after every drink part '
        'succeeded', () async {
      serverAnswers.add(drinks(401));
      batches.commitWith = (index, result) => index == 0
          ? result.completeError(firestoreError('permission-denied'))
          : result.complete();

      await expectLater(
        repository.purgeRecords('user-a', 'w1'),
        throwsA(isA<FirebaseException>()),
      );

      final committed = batches.batches.where((b) => b.committed).toList();
      expect(committed, hasLength(1), reason: 'stopped at the refused part');
      expect(
        committed.single.ops.any((op) => op.path == path('w1')),
        isFalse,
        reason: 'the wine stays while drinks remain',
      );
    });

    test(
      'NFR6.6 purgeRecords reads the server and deletes what is left',
      () async {
        serverAnswers.add(drinks(1, 5));

        await repository.purgeRecords('user-a', 'w1');

        expect(batches.single.ops.map((op) => op.path), [
          'cellars/user-a/drinkingRecords/r5',
          path('w1'),
          'cellars/user-a',
        ]);
        expectCounterLast();
      },
    );
  });

  test('a ledger failure returns SaveFailure and writes nothing', () async {
    final failing = InMemoryKeyValueStore()..failReads = StateError('disk');
    final broken = WineRepository(
      db: db,
      ledger: LocalLedger(store: failing, reporter: recordingReporter(sink)),
      bus: bus,
      reporter: recordingReporter(sink),
    );

    final outcome = await broken.setEstimate(
      cellarId: 'user-a',
      user: const AppUser(
        uid: 'user-a',
        email: 'a@example.com',
        displayName: 'A',
      ),
      wine: cellarWine('w1'),
      estimate: WineEstimate.none,
    );

    expect(outcome, isA<SaveFailure>());
    expect(batches.batches, isEmpty);
    expect(sink.reasons, contains('estimate_refresh_failed'));
  });
}

extension on RecordingBatch {
  BatchOp single(String path) => opAt(path);
}
