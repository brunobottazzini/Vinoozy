import 'package:cloud_firestore/cloud_firestore.dart';

import '../cellar/data/firestore_codec.dart';
import '../usage/cloud_usage_meter.dart';
import '../usage/firestore_metering.dart';

/// Result of reading a journaled wine from the server.
enum ServerCheck {
  /// The wine is on the server: the creation arrived.
  exists,

  /// The queue is drained and the wine is not there: the write was lost or
  /// rejected (NFR6.3).
  missing,

  /// The read itself was refused (permission-denied).
  denied,

  /// The server is unreachable: try again at the next trigger.
  unavailable,
}

/// What the phone's local Firestore cache knows about a journaled wine.
enum LocalCheck {
  /// Not in the cache: the write never reached Firestore or was rolled back.
  absent,

  /// In the cache with a write still queued for the server.
  pending,

  /// In the cache and acknowledged by the server.
  synced,
}

/// The Firestore operations SyncWatcher needs, behind an interface so the
/// watcher's logic is unit-tested without the SDK.
abstract interface class SyncGateway {
  /// Completes when every write queued so far is acknowledged by the server.
  Future<void> waitForPendingWrites();

  /// Reads the wine from the server (never from the cache). Errors other than
  /// those mapped to [ServerCheck] are thrown.
  Future<ServerCheck> checkWine({
    required String cellarId,
    required String wineId,
  });

  /// Reads the wine from the local cache only (works offline). A cache miss
  /// is [LocalCheck.absent]; other errors are thrown.
  Future<LocalCheck> checkLocal({
    required String cellarId,
    required String wineId,
  });
}

/// [SyncGateway] over Cloud Firestore.
class FirestoreSyncGateway implements SyncGateway {
  FirestoreSyncGateway(this._db, {this.meter});

  final FirebaseFirestore Function() _db;

  /// freemium-plus FR6.4: the server checks of the sync recovery are system
  /// usage (study §7.5).
  final CloudUsageMeter? meter;

  @override
  Future<void> waitForPendingWrites() => _db().waitForPendingWrites();

  @override
  Future<ServerCheck> checkWine({
    required String cellarId,
    required String wineId,
  }) async {
    try {
      final snapshot = await _db()
          .doc(winePath(cellarId, wineId))
          .get(const GetOptions(source: Source.server));
      recordDocumentRead(meter, snapshot, scope: UsageScope.system);
      return snapshot.exists ? ServerCheck.exists : ServerCheck.missing;
    } on FirebaseException catch (error) {
      if (error.code == 'permission-denied') return ServerCheck.denied;
      if (error.code == 'unavailable') return ServerCheck.unavailable;
      rethrow;
    }
  }

  @override
  Future<LocalCheck> checkLocal({
    required String cellarId,
    required String wineId,
  }) async {
    try {
      final snapshot = await _db()
          .doc(winePath(cellarId, wineId))
          .get(const GetOptions(source: Source.cache));
      if (!snapshot.exists) return LocalCheck.absent;
      return snapshot.metadata.hasPendingWrites
          ? LocalCheck.pending
          : LocalCheck.synced;
    } on FirebaseException catch (error) {
      // The SDK reports a document missing from the cache as "unavailable".
      if (error.code == 'unavailable') return LocalCheck.absent;
      rethrow;
    }
  }
}
