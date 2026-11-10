import 'package:cloud_functions/cloud_functions.dart';

import 'firebase_env.dart';

/// Region of the Cloud Functions, the same as Firestore (freemium-plus
/// FR9.3, docs/firebase-setup.md).
const String functionsRegion = 'europe-west8';

/// Port of the Functions emulator (firebase.json).
const int functionsEmulatorPort = 5001;

bool _functionsEmulatorConfigured = false;

/// The callable functions of the backend (verifyPurchase, reportUsage,
/// reserveAdSlot, logAdOutcome) in [functionsRegion]. In the demo
/// environment they are served by the Functions emulator, next to the Auth
/// and Firestore emulators (freemium-plus D4); the real project is never
/// reached from a demo build.
FirebaseFunctions configuredFunctions(FirebaseEnvConfig env) {
  final functions = FirebaseFunctions.instanceFor(region: functionsRegion);
  if (env.usesEmulators && !_functionsEmulatorConfigured) {
    functions.useFunctionsEmulator(
      env.emulatorHost,
      functionsEmulatorPort,
      automaticHostMapping: false,
    );
    _functionsEmulatorConfigured = true;
  }
  return functions;
}

/// Reads a time sent by a callable: milliseconds since the epoch or an
/// ISO-8601 string. Null when it is neither (the caller decides the safe
/// value).
DateTime? callableTime(Object? value) => switch (value) {
  final int millis => DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true),
  final double millis => DateTime.fromMillisecondsSinceEpoch(
    millis.round(),
    isUtc: true,
  ),
  final String text => DateTime.tryParse(text)?.toUtc(),
  _ => null,
};

/// Reads a non-negative count sent by a callable; 0 for anything else.
int callableCount(Object? value) => switch (value) {
  final int count when count >= 0 => count,
  final double count when count >= 0 && count == count.roundToDouble() =>
    count.toInt(),
  _ => 0,
};

/// The map a callable answered with; empty for anything else.
Map<String, Object?> callableMap(Object? value) => value is Map
    ? {for (final entry in value.entries) '${entry.key}': entry.value}
    : const {};
