import 'package:firebase_core/firebase_core.dart';

/// Error raised when a production build was compiled without the production
/// Firebase configuration.
class MissingProductionOptionsError extends StateError {
  MissingProductionOptionsError(List<String> missing)
    : super(
        'FIREBASE_ENV=prod but the production Firebase options are missing '
        '(${missing.join(', ')}). Build with '
        '--dart-define-from-file=config/firebase_prod.json; the file is '
        'written by release.yml from GitHub Actions secrets and is never '
        'committed (see docs/firebase-setup.md).',
      );
}

/// Production Firebase options, compiled in from `--dart-define` values
/// (normally `--dart-define-from-file=config/firebase_prod.json`).
///
/// No value lives in the repository (NFR4.7). A build without them still
/// compiles, and a production start-up fails immediately with a clear error
/// instead of talking to the wrong project.
FirebaseOptions get prodFirebaseOptions => prodFirebaseOptionsFrom(
  apiKey: const String.fromEnvironment('FIREBASE_API_KEY'),
  appId: const String.fromEnvironment('FIREBASE_APP_ID'),
  messagingSenderId: const String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
  ),
  projectId: const String.fromEnvironment('FIREBASE_PROJECT_ID'),
  storageBucket: const String.fromEnvironment('FIREBASE_STORAGE_BUCKET'),
);

/// Builds the options from raw values; throws [MissingProductionOptionsError]
/// naming every required value that is empty.
FirebaseOptions prodFirebaseOptionsFrom({
  required String apiKey,
  required String appId,
  required String messagingSenderId,
  required String projectId,
  String storageBucket = '',
}) {
  final missing = [
    if (apiKey.isEmpty) 'FIREBASE_API_KEY',
    if (appId.isEmpty) 'FIREBASE_APP_ID',
    if (messagingSenderId.isEmpty) 'FIREBASE_MESSAGING_SENDER_ID',
    if (projectId.isEmpty) 'FIREBASE_PROJECT_ID',
  ];
  if (missing.isNotEmpty) throw MissingProductionOptionsError(missing);
  return FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    messagingSenderId: messagingSenderId,
    projectId: projectId,
    storageBucket: storageBucket.isEmpty ? null : storageBucket,
  );
}
