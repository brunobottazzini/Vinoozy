import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/sync/sync_gateway.dart';

import '../../helpers/firestore_mocks.dart';

void main() {
  setUpAll(registerFirestoreFallbacks);

  late MockFirestore db;
  late MockDocRef wineRef;
  late FirestoreSyncGateway gateway;

  setUp(() {
    db = MockFirestore();
    wineRef = MockDocRef();
    when(() => db.doc('cellars/c1/wines/w1')).thenReturn(wineRef);
    gateway = FirestoreSyncGateway(() => db);
  });

  Future<ServerCheck> check() =>
      gateway.checkWine(cellarId: 'c1', wineId: 'w1');

  test('reads the server, never the cache', () async {
    when(() => wineRef.get(any()))
        .thenAnswer((_) async => docSnapshot(exists: true, data: {}));

    expect(await check(), ServerCheck.exists);
    final options =
        verify(() => wineRef.get(captureAny())).captured.single as GetOptions;
    expect(options.source, Source.server);
  });

  test('a missing document after the drain is "missing"', () async {
    when(() => wineRef.get(any()))
        .thenAnswer((_) async => docSnapshot(exists: false));

    expect(await check(), ServerCheck.missing);
  });

  test('permission-denied and unavailable are mapped', () async {
    when(() => wineRef.get(any()))
        .thenThrow(firestoreError('permission-denied'));
    expect(await check(), ServerCheck.denied);

    when(() => wineRef.get(any())).thenThrow(firestoreError('unavailable'));
    expect(await check(), ServerCheck.unavailable);
  });

  test('other errors are thrown to SyncWatcher', () async {
    when(() => wineRef.get(any())).thenThrow(firestoreError('internal'));

    await expectLater(check(), throwsA(isA<FirebaseException>()));
  });

  test('waitForPendingWrites delegates to Firestore', () async {
    when(() => db.waitForPendingWrites()).thenAnswer((_) async {});

    await gateway.waitForPendingWrites();

    verify(() => db.waitForPendingWrites()).called(1);
  });

  group('checkLocal', () {
    Future<LocalCheck> local() =>
        gateway.checkLocal(cellarId: 'c1', wineId: 'w1');

    test('reads the cache only', () async {
      when(() => wineRef.get(any())).thenAnswer(
        (_) async => docSnapshot(exists: true, data: {}, fromCache: true),
      );

      expect(await local(), LocalCheck.synced);
      final options =
          verify(() => wineRef.get(captureAny())).captured.single as GetOptions;
      expect(options.source, Source.cache);
    });

    test('a write still queued is "pending"', () async {
      when(() => wineRef.get(any())).thenAnswer(
        (_) async => docSnapshot(exists: true, data: {}, pending: true),
      );

      expect(await local(), LocalCheck.pending);
    });

    test('a missing document or a cache miss is "absent"', () async {
      when(() => wineRef.get(any()))
          .thenAnswer((_) async => docSnapshot(exists: false));
      expect(await local(), LocalCheck.absent);

      when(() => wineRef.get(any())).thenThrow(firestoreError('unavailable'));
      expect(await local(), LocalCheck.absent);
    });

    test('other errors are thrown', () async {
      when(() => wineRef.get(any())).thenThrow(firestoreError('internal'));

      await expectLater(local(), throwsA(isA<FirebaseException>()));
    });
  });
}
