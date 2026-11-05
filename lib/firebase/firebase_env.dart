import 'package:firebase_core/firebase_core.dart';

import 'options_demo.dart';
import 'options_prod.dart' as prod;

/// Which Firebase backend the app talks to.
enum FirebaseEnv {
  /// Firebase Emulator Suite with the `demo-vinoozy` project (default).
  demo,

  /// The real production project; options come from `--dart-define` values.
  prod;

  /// Parses the `FIREBASE_ENV` dart-define. Anything but `prod` is `demo`, so
  /// a build without defines can never reach production by accident.
  static FirebaseEnv parse(String raw) =>
      raw.trim().toLowerCase() == 'prod' ? FirebaseEnv.prod : FirebaseEnv.demo;
}

/// Build-time configuration read from `--dart-define` values.
class FirebaseEnvConfig {
  const FirebaseEnvConfig({
    required this.env,
    required this.isE2E,
    required this.emulatorHost,
  });

  /// Reads the configuration compiled into this build.
  factory FirebaseEnvConfig.fromEnvironment() => FirebaseEnvConfig(
    env: FirebaseEnv.parse(
      const String.fromEnvironment('FIREBASE_ENV', defaultValue: 'demo'),
    ),
    isE2E: kIsE2EBuild,
    emulatorHost: const String.fromEnvironment(
      'EMULATOR_HOST',
      // 10.0.2.2 is the host loopback seen from the Android emulator.
      defaultValue: '10.0.2.2',
    ),
  );

  final FirebaseEnv env;

  /// True only in builds made with `--dart-define=E2E=true`.
  final bool isE2E;

  /// Host where the Firebase emulators listen (demo builds only).
  final String emulatorHost;

  static const int authEmulatorPort = 9099;
  static const int firestoreEmulatorPort = 8080;

  bool get usesEmulators => env == FirebaseEnv.demo;

  /// Options for [Firebase.initializeApp]. Throws
  /// [MissingProductionOptionsError] for a prod build without the production
  /// options.
  FirebaseOptions get options =>
      env == FirebaseEnv.demo ? demoFirebaseOptions : prod.prodFirebaseOptions;
}

/// Compile-time flag: the end-to-end test hooks are compiled in only when
/// this is true, so release builds tree-shake them away.
const bool kIsE2EBuild = bool.fromEnvironment('E2E');
