// freemium-plus FR1.1, FR1.4, FR4.3, NFR4: the entitlement repository. A
// server-confirmed snapshot is kept as a local copy with the time of the
// confirmation; offline the copy stands for at most 7 days; a cache snapshot
// never refreshes it; a failed listener keeps the last value.
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/plan/data/entitlement_repository.dart';
import 'package:vinoozy/plan/domain/entitlement.dart';
import 'package:vinoozy/usage/cloud_usage_meter.dart';
import 'package:vinoozy/usage/domain/usage_counters.dart';

import '../../helpers/fakes.dart';
import '../../helpers/firestore_mocks.dart';

void main() {
  setUpAll(registerFirestoreFallbacks);

  final now = DateTime.utc(2026, 11, 10, 12);
  late MockFirestore db;
  late MockDocRef ref;
  late StreamController<DocumentSnapshot<Map<String, dynamic>>> snapshots;
  late InMemoryKeyValueStore store;
  late RecordingErrorSink sink;
  late FakeClock clock;

  EntitlementRepository repository({CloudUsageMeter? meter}) =>
      EntitlementRepository(
        db: db,
        store: store,
        reporter: recordingReporter(sink),
        clock: clock,
        meter: meter,
      );

  setUp(() {
    db = MockFirestore();
    ref = MockDocRef();
    snapshots = StreamController.broadcast();
    store = InMemoryKeyValueStore();
    sink = RecordingErrorSink();
    clock = FakeClock(now);
    when(() => db.doc('entitlements/user-a')).thenReturn(ref);
    when(() => ref.snapshots(includeMetadataChanges: true))
        .thenAnswer((_) => snapshots.stream);
  });

  Map<String, dynamic> plus({DateTime? expiresAt}) => {
    'plan': 'plus',
    'source': 'play_purchase',
    'status': 'active',
    'expiresAt': Timestamp.fromDate(expiresAt ?? DateTime.utc(2026, 12, 10)),
    'updatedAt': Timestamp.fromDate(now),
    // Never kept in the copy: only the known entitlement fields are.
    'purchaseToken': 'secret',
  };

  /// Collects every value of the stream of user-a.
  Future<List<Entitlement?>> listen(EntitlementRepository repo) async {
    final values = <Entitlement?>[];
    repo.watch('user-a').listen(values.add);
    await pumpEventQueue();
    return values;
  }

  test('FR1.1 FR4.3 a server snapshot gives the entitlement and saves the '
      'copy without the token', () async {
    final values = await listen(repository());
    expect(values, [null], reason: 'no copy yet');

    snapshots.add(docSnapshot(exists: true, data: plus()));
    await pumpEventQueue();

    expect(values.last!.isPlusValidAt(now), isTrue);
    final raw = store.values[EntitlementRepository.storageKey]!;
    expect(raw, isNot(contains('secret')));
    final copy = EntitlementCopy.tryParse(raw)!;
    expect(copy.uid, 'user-a');
    expect(copy.confirmedAt, now);
  });

  test('FR1.4 offline for 3 days the copy keeps Plus', () async {
    await listen(repository());
    snapshots.add(docSnapshot(exists: true, data: plus()));
    await pumpEventQueue();

    clock.current = now.add(const Duration(days: 3));
    final offline = await listen(repository());
    snapshots.add(docSnapshot(exists: true, data: plus(), fromCache: true));
    await pumpEventQueue();

    expect(offline, hasLength(2));
    expect(offline.every((e) => e!.isPlusValidAt(clock.current)), isTrue);
  });

  test('FR1.4 a copy confirmed more than 7 days ago gives nothing', () async {
    await listen(repository());
    snapshots.add(docSnapshot(exists: true, data: plus()));
    await pumpEventQueue();

    clock.current = now.add(const Duration(days: 7, minutes: 1));
    final values = await listen(repository());
    // The Firestore cache still has the document: it is not trusted.
    snapshots.add(docSnapshot(exists: true, data: plus(), fromCache: true));
    await pumpEventQueue();

    expect(values, [null, null]);
  });

  test('FR1.4 the copy never outlives expiresAt', () async {
    await listen(repository());
    snapshots.add(
      docSnapshot(
        exists: true,
        data: plus(expiresAt: now.add(const Duration(days: 1))),
      ),
    );
    await pumpEventQueue();

    clock.current = now.add(const Duration(days: 2));
    final values = await listen(repository());

    expect(values.single, isNotNull);
    expect(values.single!.isPlusValidAt(clock.current), isFalse);
  });

  test('the copy of another account, or a damaged one, is ignored', () async {
    store.values[EntitlementRepository.storageKey] = EntitlementCopy(
      uid: 'user-b',
      confirmedAt: now,
      data: const {
        'plan': 'plus',
        'status': 'active',
        'source': 'manual_grant',
      },
    ).encode();
    expect(await listen(repository()), [null]);

    store.values[EntitlementRepository.storageKey] = '{not json';
    expect(await listen(repository()), [null]);
  });

  test('a confirmed missing document is the free plan, and is saved', () async {
    final values = await listen(repository());

    snapshots.add(docSnapshot(exists: false));
    await pumpEventQueue();

    expect(values.last, isNull);
    final copy = EntitlementCopy.tryParse(
      store.values[EntitlementRepository.storageKey]!,
    )!;
    expect(copy.data, isNull);
  });

  test('NFR4 a failed listener is reported and keeps the last value', () async {
    await listen(repository());
    snapshots.add(docSnapshot(exists: true, data: plus()));
    await pumpEventQueue();

    final values = await listen(repository());
    snapshots.addError(firestoreError('permission-denied'));
    await pumpEventQueue();

    expect(values, hasLength(1));
    expect(values.single!.isPlusValidAt(now), isTrue);
    expect(sink.reasons, contains('EntitlementFailed'));
  });

  test(
    'a copy that cannot be saved is reported; the plan still applies',
    () async {
      final values = await listen(repository());
      store.failNextWrite = StateError('disk full');

      snapshots.add(docSnapshot(exists: true, data: plus()));
      await pumpEventQueue();

      expect(values.last!.isPlusValidAt(now), isTrue);
      expect(sink.reasons, contains('EntitlementCopyFailed'));
    },
  );

  test('FR1.4 clear() forgets the copy (sign-out)', () async {
    final repo = repository();
    await listen(repo);
    snapshots.add(docSnapshot(exists: true, data: plus()));
    await pumpEventQueue();

    await repo.clear();

    expect(await listen(repository()), [null]);
  });

  test('FR6.1 the listener is one personal read per server snapshot', () async {
    final meter = CloudUsageMeter(
      store: InMemoryKeyValueStore(),
      reporter: recordingReporter(sink),
      clock: clock,
    );
    await meter.start('user-a');
    await listen(repository(meter: meter));

    snapshots
      ..add(docSnapshot(exists: true, data: plus(), fromCache: true))
      ..add(docSnapshot(exists: true, data: plus()));
    await pumpEventQueue();

    expect(
      meter.periods['2026-11']!.personal,
      const UsageCounters(reads: 1, egressBytes: 2048),
    );
  });
}
