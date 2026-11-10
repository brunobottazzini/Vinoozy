// freemium-plus FR2.4, FR3.5, FR7.1, NFR4: the policy repository. Before
// the server answers, the local copy or the safe defaults (no ads, no limit,
// no purchases); a failed listener keeps the last value; a policy missing on
// the server is the safe one.
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/plan/data/policy_repository.dart';
import 'package:vinoozy/plan/domain/plan_policy.dart';

import '../../helpers/fakes.dart';
import '../../helpers/firestore_mocks.dart';

void main() {
  setUpAll(registerFirestoreFallbacks);

  late MockFirestore db;
  late MockDocRef ref;
  late StreamController<DocumentSnapshot<Map<String, dynamic>>> snapshots;
  late InMemoryKeyValueStore store;
  late RecordingErrorSink sink;

  PolicyRepository repository() =>
      PolicyRepository(db: db, store: store, reporter: recordingReporter(sink));

  setUp(() {
    db = MockFirestore();
    ref = MockDocRef();
    snapshots = StreamController.broadcast();
    store = InMemoryKeyValueStore();
    sink = RecordingErrorSink();
    when(() => db.doc('config/policy')).thenReturn(ref);
    when(() => ref.snapshots()).thenAnswer((_) => snapshots.stream);
  });

  Future<List<PlanPolicy>> listen(PolicyRepository repo) async {
    final values = <PlanPolicy>[];
    repo.watch().listen(values.add);
    await pumpEventQueue();
    return values;
  }

  const live = {
    'adsEnabled': true,
    'capacityLimitEnabled': true,
    'purchasesEnabled': true,
    'policyVersion': 'freemium-v1',
    'usageBudgetEuro': '0.005',
    'freeActiveWineLimit': 15,
  };

  test('NFR4 before any answer: the safe defaults', () async {
    final repo = repository();
    expect(repo.current, PlanPolicy.safeDefaults);

    expect(await listen(repo), [PlanPolicy.safeDefaults]);
  });

  test(
    'NFR4 a failed listener is reported and keeps the safe defaults',
    () async {
      final repo = repository();
      final values = await listen(repo);

      snapshots.addError(firestoreError('unavailable'));
      await pumpEventQueue();

      expect(values, [PlanPolicy.safeDefaults]);
      expect(repo.current, PlanPolicy.safeDefaults);
      expect(sink.reasons, contains('PolicyFailed'));
    },
  );

  test('FR7.1 a server policy applies at once and is saved', () async {
    final repo = repository();
    final values = await listen(repo);

    snapshots.add(docSnapshot(exists: true, data: live));
    await pumpEventQueue();

    expect(values.last.adsEnabled, isTrue);
    expect(repo.current.capacityLimitEnabled, isTrue);

    // Turned off by the owner: the listener brings it at once.
    snapshots.add(
      docSnapshot(exists: true, data: {...live, 'adsEnabled': false}),
    );
    await pumpEventQueue();
    expect(repo.current.adsEnabled, isFalse);

    final restarted = repository();
    expect((await listen(restarted)).single.capacityLimitEnabled, isTrue);
  });

  test('a policy missing on the server is the safe one', () async {
    store.values[PolicyRepository.storageKey] =
        '{"capacityLimitEnabled": true}';
    final repo = repository();
    final values = await listen(repo);
    expect(values.single.capacityLimitEnabled, isTrue, reason: 'the copy');

    snapshots.add(docSnapshot(exists: false));
    await pumpEventQueue();

    expect(values.last, PlanPolicy.safeDefaults);
  });

  test('a cache snapshot without the document keeps the copy', () async {
    store.values[PolicyRepository.storageKey] =
        '{"capacityLimitEnabled": true}';
    final repo = repository();
    final values = await listen(repo);

    snapshots.add(docSnapshot(exists: false, fromCache: true));
    await pumpEventQueue();

    expect(values, hasLength(1));
    expect(repo.current.capacityLimitEnabled, isTrue);
  });

  test('a damaged copy reads as the safe defaults', () async {
    store.values[PolicyRepository.storageKey] = 'not json';

    expect(await listen(repository()), [PlanPolicy.safeDefaults]);
  });
}
