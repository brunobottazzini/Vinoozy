import 'package:cloud_firestore/cloud_firestore.dart';

import '../sync/ledger/local_ledger.dart';
import 'firebase_env.dart';

/// Whether Firestore can be terminated, cleared and reused in the same
/// process. Set from the outcome of the restart probe
/// (integration_test/firestore_restart_probe_test.dart, NFR4.10); when false,
/// the reset follows plan B ("Restart the app to finish").
const bool kInProcessFirestoreReset = true;

/// The local Firestore data could not be cleared (NFR4.10): the account stays
/// blocked with "Try again".
class PersistenceResetException implements Exception {
  PersistenceResetException(this.cause);

  final Object cause;

  @override
  String toString() => 'PersistenceResetException: $cause';
}

/// Owns the Firestore settings so they are identical at start-up and after a
/// reset (security-design.md §5, NFR6.1, NFR4.10).
class FirestoreBootstrap {
  FirestoreBootstrap({required this._firestore, required this._config});

  /// Returns the Firestore instance; a function so a re-created instance is
  /// always picked up.
  final FirebaseFirestore Function() _firestore;
  final FirebaseEnvConfig _config;

  /// Offline persistence with an unlimited cache, so queued writes are never
  /// evicted (NFR6.1); the emulator in demo builds.
  void configure() {
    final db = _firestore();
    db.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    if (_config.usesEmulators) {
      db.useFirestoreEmulator(
        _config.emulatorHost,
        FirebaseEnvConfig.firestoreEmulatorPort,
        automaticHostMapping: false,
      );
    }
  }

  /// Start-up step of plan B: when a previous reset could not clear the local
  /// data in-process, clear it now, before any other Firestore use, then mark
  /// the reset as completed. Throws [PersistenceResetException] on failure.
  Future<void> completePendingReset(LocalLedger ledger) async {
    final state = await ledger.read();
    if (!state.resetPending) return;
    try {
      await _firestore().clearPersistence();
    } catch (error) {
      throw PersistenceResetException(error);
    }
    await ledger.setResetPending(false);
  }

  /// In-process reset: `terminate()`, `clearPersistence()`, then the same
  /// settings again (security-design.md §5 step 4). Throws
  /// [PersistenceResetException] when any step fails.
  Future<void> resetPersistence() async {
    try {
      final db = _firestore();
      await db.terminate();
      await db.clearPersistence();
      configure();
    } catch (error) {
      throw PersistenceResetException(error);
    }
  }
}
