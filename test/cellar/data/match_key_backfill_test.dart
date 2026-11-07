// MatchKeyBackfill (BR1.4; NFR5.3, NFR4.2, NFR4.9): once per cellar, parts
// of 400, the flag only after the last part, resumed without rewrites.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/cellar/data/match_key_backfill.dart';

import '../../helpers/fakes.dart';
import '../../helpers/firestore_mocks.dart';
import '../cellar_harness.dart';

void main() {
  setUpAll(registerFirestoreFallbacks);

  late MockFirestore db;
  late BatchRecorder batches;
  late RecordingErrorSink sink;
  late MockDocRef cellarRef;
  late MockCollectionRef wines;
  late Map<String, Map<String, dynamic>> stored;
  late List<Map<Object, Object?>> cellarUpdates;
  late MatchKeyBackfill backfill;
  Map<String, dynamic>? cellarData;

  setUp(() {
    db = MockFirestore();
    batches = BatchRecorder(db);
    sink = RecordingErrorSink();
    cellarRef = MockDocRef();
    wines = MockCollectionRef();
    stored = {};
    cellarUpdates = [];
    cellarData = {'ownerId': 'user-a', 'name': 'Cantina'};
    when(() => db.doc('cellars/user-a')).thenReturn(cellarRef);
    when(() => cellarRef.get(any()))
        .thenAnswer((_) async => docSnapshot(exists: true, data: cellarData));
    when(() => cellarRef.update(any())).thenAnswer((invocation) async {
      cellarUpdates.add(
        invocation.positionalArguments.single as Map<Object, Object?>,
      );
    });
    when(() => db.collection('cellars/user-a/wines')).thenReturn(wines);
    when(() => wines.get(any())).thenAnswer((invocation) async {
      final options = invocation.positionalArguments.single as GetOptions;
      expect(options.source, Source.server);
      return querySnapshotOf(stored);
    });
    backfill = MatchKeyBackfill(db: db, reporter: recordingReporter(sink));
  });

  void seedWines(int count, {int withKey = 0}) {
    for (var i = 0; i < count; i++) {
      stored['w$i'] = {
        'name': 'Vino $i',
        'producer': 'Cantina',
        'vintage': 2016,
        'quantity': i % 3,
        if (i < withKey) 'matchKey': 'vino $i|cantina|2016',
      };
    }
  }

  test('BR1.4 NFR5.3 1500 wines: 4 parts, then the flag', () async {
    seedWines(1500);

    expect(await backfill.run('user-a'), BackfillOutcome.completed);

    expect(batches.batches.map((b) => b.ops.length), [400, 400, 400, 300]);
    final op = batches.batches.first.ops.first;
    expect(op.kind, 'update');
    expect(op.data, {'matchKey': 'vino 0|cantina|2016'});
    expect(cellarUpdates, [
      {'matchKeyBackfill': true},
    ]);
  });

  test('NFR5.3 interrupted after the second part: no flag; resumed without rewrites', () async {
    seedWines(1500);
    batches.commitWith = (index, result) => index == 2
        ? result.completeError(firestoreError('unavailable'))
        : result.complete();

    expect(await backfill.run('user-a'), BackfillOutcome.failed);
    expect(cellarUpdates, isEmpty, reason: 'the flag only after the last part');
    expect(sink.reasons, ['match_key_backfill_failed']);

    // The first two parts reached the server: those wines have the key now.
    seedWines(1500, withKey: 800);
    batches.commitWith = null;
    final before = batches.batches.length;

    expect(await backfill.run('user-a'), BackfillOutcome.completed);
    final resumed = batches.batches.skip(before).toList();
    expect(resumed.map((b) => b.ops.length), [400, 300]);
    expect(resumed.first.ops.first.path, 'cellars/user-a/wines/w800');
    expect(cellarUpdates, hasLength(1));
  });

  test('BR1.4 a cellar with the flag is not read again', () async {
    cellarData = {'matchKeyBackfill': true};

    expect(await backfill.run('user-a'), BackfillOutcome.alreadyDone);
    expect(await backfill.run('user-a'), BackfillOutcome.alreadyDone);

    verifyNever(() => wines.get(any()));
    verify(() => cellarRef.get(any())).called(1);
  });

  test('BR1.4 every wine already keyed: only the flag is written', () async {
    seedWines(3, withKey: 3);

    expect(await backfill.run('user-a'), BackfillOutcome.completed);
    expect(batches.batches, isEmpty);
    expect(cellarUpdates, hasLength(1));
  });

  test('BR1.4 a loaded wine without a key gets it, without reads', () async {
    await backfill.keyLoaded('user-a', [
      cellarWine('w1', name: 'Barolo', producer: null, vintage: null),
      cellarWine('w2', matchKey: 'barolo||'),
    ]);

    expect(batches.single.ops.single.path, 'cellars/user-a/wines/w1');
    expect(batches.single.ops.single.data, {'matchKey': 'barolo||'});
    verifyNever(() => wines.get(any()));
  });

  test('a failure of the loaded-wine keys is reported, not thrown', () async {
    batches.commitWith = (_, result) =>
        result.completeError(firestoreError('permission-denied'));

    await backfill.keyLoaded('user-a', [cellarWine('w1')]);

    expect(sink.reasons, ['match_key_backfill_failed']);
  });
}
