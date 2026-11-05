// Restart probe (security-design.md §5, NFR4.10): can FlutterFire terminate
// Firestore, clear its persistence and reuse the instance in the same
// process? Plan A of the local reset depends on it; if this test fails, the
// app uses plan B (kInProcessFirestoreReset = false: "Restart the app to
// finish").
//
// Run on the Android emulator with the Firebase emulators started:
//   npx firebase emulators:exec --only auth,firestore --project demo-vinoozy \
//     "flutter test integration_test/firestore_restart_probe_test.dart \
//      --dart-define=FIREBASE_ENV=demo --dart-define=E2E=true"
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vinoozy/cellar/domain/cellar.dart';
import 'package:vinoozy/firebase/firebase_env.dart';
import 'package:vinoozy/firebase/firestore_bootstrap.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final config = FirebaseEnvConfig.fromEnvironment();
  late FirestoreBootstrap bootstrap;
  late String uid;

  setUpAll(() async {
    expect(config.usesEmulators, isTrue, reason: 'run with FIREBASE_ENV=demo');
    await Firebase.initializeApp(options: config.options);
    await FirebaseAuth.instance.useAuthEmulator(
      config.emulatorHost,
      FirebaseEnvConfig.authEmulatorPort,
      automaticHostMapping: false,
    );
    bootstrap = FirestoreBootstrap(
      firestore: () => FirebaseFirestore.instance,
      config: config,
    );
    bootstrap.configure();
    // Unsigned Google id token, accepted only by the Auth Emulator.
    final credential = GoogleAuthProvider.credential(
      idToken: jsonEncode({
        'sub': 'probe-user',
        'email': 'probe@example.com',
        'email_verified': true,
      }),
    );
    final result = await FirebaseAuth.instance.signInWithCredential(credential);
    uid = result.user!.uid;
  });

  testWidgets('terminate + clearPersistence + configure, then a server read', (
    tester,
  ) async {
    final db = FirebaseFirestore.instance;
    final cellarRef = db.doc('cellars/$uid');

    // A real document on the emulator.
    await db.runTransaction<void>((tx) async {
      final snapshot = await tx.get(cellarRef);
      if (!snapshot.exists) {
        tx.set(cellarRef, {
          ...Cellar.createFields(uid: uid, name: 'Probe cellar'),
          CellarFields.createdAt: FieldValue.serverTimestamp(),
        });
      }
    });

    // A queued write that only exists locally.
    await db.disableNetwork();
    final pendingRef = db.doc('cellars/$uid/wines/probe-pending');
    final queued = pendingRef.set({
      'name': 'Pending',
      'vintage': null,
      'quantity': 1,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedBy': uid,
    });
    queued.ignore();
    // set() is not awaited (it completes only on the server): poll the cache
    // until the local write is applied.
    var inCache = false;
    for (var i = 0; i < 50 && !inCache; i++) {
      try {
        inCache = (await pendingRef.get(const GetOptions(source: Source.cache)))
            .exists;
      } on FirebaseException {
        // Not applied locally yet.
      }
      if (!inCache) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
    }
    expect(inCache, isTrue, reason: 'write is in the local cache');

    // Step 4 of the reset, exactly as the app runs it.
    await bootstrap.resetPersistence();

    // The same instance works again and reaches the emulator...
    final fromServer = await FirebaseFirestore.instance
        .doc('cellars/$uid')
        .get(const GetOptions(source: Source.server));
    expect(fromServer.exists, isTrue);
    expect(fromServer.data()![CellarFields.ownerId], uid);

    // ...the settings survived (persistence on, unlimited cache)...
    final settings = FirebaseFirestore.instance.settings;
    expect(settings.persistenceEnabled, isTrue);
    expect(settings.cacheSizeBytes, Settings.CACHE_SIZE_UNLIMITED);

    // ...and the queued write is gone from the cache and never reached the
    // server.
    Object? cacheError;
    DocumentSnapshot<Map<String, dynamic>>? afterReset;
    try {
      afterReset = await FirebaseFirestore.instance
          .doc('cellars/$uid/wines/probe-pending')
          .get(const GetOptions(source: Source.cache));
    } on FirebaseException catch (error) {
      cacheError = error;
    }
    expect(
      cacheError != null || afterReset?.exists == false,
      isTrue,
      reason: 'the pending write must be cleared',
    );
    final pendingOnServer = await FirebaseFirestore.instance
        .doc('cellars/$uid/wines/probe-pending')
        .get(const GetOptions(source: Source.server));
    expect(pendingOnServer.exists, isFalse);
    expect(kInProcessFirestoreReset, isTrue);
  });
}
