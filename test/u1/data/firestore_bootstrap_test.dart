import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/firebase/firebase_env.dart';
import 'package:vinoozy/firebase/firestore_bootstrap.dart';
import 'package:vinoozy/firebase/options_demo.dart';
import 'package:vinoozy/firebase/options_prod.dart';
import 'package:vinoozy/sync/ledger/local_ledger.dart';

import '../../helpers/fakes.dart';
import '../../helpers/firestore_mocks.dart';

void main() {
  setUpAll(registerFirestoreFallbacks);

  const demo = FirebaseEnvConfig(
    env: FirebaseEnv.demo,
    isE2E: false,
    emulatorHost: '10.0.2.2',
  );
  const prod = FirebaseEnvConfig(
    env: FirebaseEnv.prod,
    isE2E: false,
    emulatorHost: '10.0.2.2',
  );
  late MockFirestore db;
  late List<String> calls;

  setUp(() {
    db = MockFirestore();
    calls = [];
    when(() => db.terminate()).thenAnswer((_) async => calls.add('terminate'));
    when(() => db.clearPersistence())
        .thenAnswer((_) async => calls.add('clear'));
    when(
      () => db.useFirestoreEmulator(
        any(),
        any(),
        automaticHostMapping: any(named: 'automaticHostMapping'),
      ),
    ).thenAnswer((_) => calls.add('emulator'));
  });

  test('configure enables persistence with an unlimited cache and the '
      'emulator in demo builds', () {
    FirestoreBootstrap(firestore: () => db, config: demo).configure();

    final settings =
        verify(() => db.settings = captureAny()).captured.single as Settings;
    expect(settings.persistenceEnabled, isTrue);
    expect(settings.cacheSizeBytes, Settings.CACHE_SIZE_UNLIMITED);
    verify(
      () => db.useFirestoreEmulator(
        '10.0.2.2',
        8080,
        automaticHostMapping: false,
      ),
    ).called(1);
  });

  test('prod builds never point at the emulator', () {
    FirestoreBootstrap(firestore: () => db, config: prod).configure();

    verifyNever(
      () => db.useFirestoreEmulator(
        any(),
        any(),
        automaticHostMapping: any(named: 'automaticHostMapping'),
      ),
    );
  });

  test('resetPersistence terminates, clears, then configures again', () async {
    await FirestoreBootstrap(
      firestore: () => db,
      config: demo,
    ).resetPersistence();

    expect(calls, ['terminate', 'clear', 'emulator']);
  });

  test('a failing clear is wrapped in PersistenceResetException', () async {
    when(() => db.clearPersistence())
        .thenThrow(firestoreError('failed-precondition'));

    await expectLater(
      FirestoreBootstrap(firestore: () => db, config: demo).resetPersistence(),
      throwsA(isA<PersistenceResetException>()),
    );
  });

  group('completePendingReset (plan B)', () {
    late LocalLedger ledger;

    setUp(() {
      ledger = LocalLedger(
        store: InMemoryKeyValueStore(),
        reporter: recordingReporter(RecordingErrorSink()),
      );
    });

    test('clears persistence and the flag when a reset is pending', () async {
      await ledger.setResetPending(true);

      await FirestoreBootstrap(
        firestore: () => db,
        config: demo,
      ).completePendingReset(ledger);

      expect(calls, ['clear']);
      expect((await ledger.read()).resetPending, isFalse);
    });

    test('does nothing without a pending reset', () async {
      await FirestoreBootstrap(
        firestore: () => db,
        config: demo,
      ).completePendingReset(ledger);

      expect(calls, isEmpty);
    });

    test('a failed clear keeps the flag and throws', () async {
      await ledger.setResetPending(true);
      when(() => db.clearPersistence()).thenThrow(firestoreError('internal'));

      await expectLater(
        FirestoreBootstrap(
          firestore: () => db,
          config: demo,
        ).completePendingReset(ledger),
        throwsA(isA<PersistenceResetException>()),
      );
      expect((await ledger.read()).resetPending, isTrue);
    });
  });

  group('FirebaseEnvConfig', () {
    test('only "prod" selects production; demo is the default', () {
      expect(FirebaseEnv.parse('prod'), FirebaseEnv.prod);
      expect(FirebaseEnv.parse(' PROD '), FirebaseEnv.prod);
      expect(FirebaseEnv.parse(''), FirebaseEnv.demo);
      expect(FirebaseEnv.parse('production'), FirebaseEnv.demo);
      expect(FirebaseEnvConfig.fromEnvironment().env, FirebaseEnv.demo);
    });

    test('demo options point at demo-vinoozy without real credentials', () {
      expect(demo.options, demoFirebaseOptions);
      expect(demo.options.projectId, 'demo-vinoozy');
      expect(demo.usesEmulators, isTrue);
      expect(prod.usesEmulators, isFalse);
    });

    test('a prod build without production defines fails fast', () {
      expect(() => prod.options, throwsA(isA<MissingProductionOptionsError>()));
      expect(
        () => prod.options,
        throwsA(
          predicate(
            (Object e) =>
                e.toString().contains('FIREBASE_API_KEY') &&
                e.toString().contains('config/firebase_prod.json'),
          ),
        ),
      );
    });

    test('production options are built from complete values', () {
      final options = prodFirebaseOptionsFrom(
        apiKey: 'key',
        appId: '1:2:android:3',
        messagingSenderId: '2',
        projectId: 'vinoozy-test',
        storageBucket: 'vinoozy-test.firebasestorage.app',
      );
      expect(options.projectId, 'vinoozy-test');
      expect(options.appId, '1:2:android:3');
      expect(options.storageBucket, 'vinoozy-test.firebasestorage.app');
    });

    test('missing production values are all named, bucket is optional', () {
      expect(
        () => prodFirebaseOptionsFrom(
          apiKey: '',
          appId: '1:2:android:3',
          messagingSenderId: '',
          projectId: 'p',
        ),
        throwsA(
          predicate(
            (Object e) =>
                e is MissingProductionOptionsError &&
                e.toString().contains('FIREBASE_API_KEY') &&
                e.toString().contains('FIREBASE_MESSAGING_SENDER_ID') &&
                !e.toString().contains('FIREBASE_APP_ID'),
          ),
        ),
      );
      final noBucket = prodFirebaseOptionsFrom(
        apiKey: 'k',
        appId: 'a',
        messagingSenderId: 's',
        projectId: 'p',
      );
      expect(noBucket.storageBucket, isNull);
    });
  });
}
