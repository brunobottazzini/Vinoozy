import 'package:cloud_firestore/cloud_firestore.dart';

import '../../sync/snapshot_meta.dart';
import '../domain/cellar.dart';
import 'firestore_codec.dart';
import 'retry.dart';

/// The personal cellar could not be read or created (BR1.3): the cellar
/// screen shows "Could not prepare the cellar" with "Try again".
class CellarSetupException implements Exception {
  CellarSetupException(this.cause);

  final Object cause;

  @override
  String toString() => 'CellarSetupException: $cause';
}

/// A snapshot of the cellar document with its sync metadata.
class CellarSnapshot {
  const CellarSnapshot({required this.cellar, required this.meta});

  /// Null while the document does not exist (not created yet or not cached).
  final Cellar? cellar;
  final SnapshotMeta meta;
}

/// Access to `cellars/{uid}` (logical-components.md: CellarRepository).
class CellarRepository {
  CellarRepository({required this._db, this._sleep = realSleep});

  final FirebaseFirestore _db;
  final Sleep _sleep;

  /// Makes sure the personal cellar `cellars/{uid}` exists (BR1.3, NFR4.11).
  ///
  /// A server transaction reads the document and creates it only if missing,
  /// so two phones racing on the first sign-in end with one cellar and one
  /// `createdAt`. Up to 3 attempts with growing waits on transient errors.
  /// Throws [CellarSetupException] when it cannot succeed.
  Future<void> ensurePersonalCellar({
    required String uid,
    required String defaultName,
  }) async {
    final ref = _db.doc(cellarPath(Cellar.personalCellarId(uid)));
    final fields = Cellar.createFields(uid: uid, name: defaultName);
    try {
      await retryTransient(
        () => _db.runTransaction<void>((transaction) async {
          final snapshot = await transaction.get(ref);
          if (!snapshot.exists) {
            transaction.set<Map<String, dynamic>>(ref, {
              ...fields,
              CellarFields.createdAt: FieldValue.serverTimestamp(),
            });
          }
        }),
        sleep: _sleep,
      );
    } catch (error) {
      throw CellarSetupException(error);
    }
  }

  /// True when the cellar is in the offline cache: without network the app
  /// can still open it (security-design.md §6).
  Future<bool> isCached(String uid) async {
    try {
      final snapshot = await _db
          .doc(cellarPath(Cellar.personalCellarId(uid)))
          .get(const GetOptions(source: Source.cache));
      return snapshot.exists;
    } on FirebaseException {
      // The SDK reports "not in cache" as an error (unavailable).
      return false;
    }
  }

  /// The single listener of the cellar document, with metadata changes so
  /// pending writes are visible (NFR5.1, NFR2.4).
  Stream<CellarSnapshot> watchCellar(String uid) {
    final cellarId = Cellar.personalCellarId(uid);
    return _db
        .doc(cellarPath(cellarId))
        .snapshots(includeMetadataChanges: true)
        .map(
          (snapshot) => CellarSnapshot(
            cellar: snapshot.exists
                ? Cellar.fromMap(cellarId, decodeDocument(snapshot.data()))
                : null,
            meta: SnapshotMeta(
              hasPendingWrites: snapshot.metadata.hasPendingWrites,
              isFromCache: snapshot.metadata.isFromCache,
            ),
          ),
        );
  }
}
