import 'package:firebase_core/firebase_core.dart';

/// Project id of the demo project used with the Firebase Emulator Suite.
///
/// Projects whose id starts with `demo-` only work against the emulators and
/// have no real credentials, so this configuration is safe to keep in the
/// repository (NFR4.7).
const String demoProjectId = 'demo-vinoozy';

/// Firebase options for the `demo-vinoozy` emulator project.
///
/// The values are the placeholders FlutterFire itself uses for demo projects:
/// they are not secrets and they do not reach any real Firebase project.
const FirebaseOptions demoFirebaseOptions = FirebaseOptions(
  apiKey: 'ADemoProjectApiKey000000000000000000000',
  appId: '1:1:android:1',
  messagingSenderId: '1',
  projectId: demoProjectId,
);
