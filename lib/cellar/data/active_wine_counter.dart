import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../sync/capacity_rejection.dart';
import '../../usage/cloud_usage_meter.dart';
import '../domain/cellar.dart';
import '../domain/firestore_values.dart';
import '../domain/wine.dart';
import 'firestore_codec.dart';

/// Whether a stored quantity makes a wine active (freemium-plus FR2.1): only
/// a wine with more than 0 bottles is; a missing wine, 0 and the negative
/// values of concurrent decrements (ADR-004) are not.
bool isActiveQuantity(int? stored) => stored != null && stored > 0;

/// How a write changes the number of active wines: +1 when it makes the wine
/// active, -1 when it makes it inactive (or deletes an active one), 0 when the
/// active state stays. [before] and [after] are stored quantities, null for a
/// wine that does not exist (before a create, after a delete).
int activeDelta(int? before, int? after) =>
    (isActiveQuantity(after) ? 1 : 0) - (isActiveQuantity(before) ? 1 : 0);

/// One wine write whose effect on the active state is known from the wine's
/// stored quantity. Both functions take that quantity (null when the wine
/// does not exist), so the write can be built again for the quantity read
/// from the server after a conflict (D1).
class CountedWineWrite {
  const CountedWineWrite({
    required this.cellarId,
    required this.wineId,
    required this.stored,
    required this.after,
    required this.write,
    this.updates = 1,
  });

  final String cellarId;
  final String wineId;

  /// The stored quantity the phone knows when the write starts.
  final int? stored;

  /// The stored quantity the write leaves; null when it deletes the wine.
  final int? Function(int? stored) after;

  /// Adds the wine operations (and any other operation of the same batch) to
  /// the batch.
  final void Function(WriteBatch batch, int? stored) write;

  /// How many documents [write] sets or updates (deletes excluded): the
  /// writes the usage meter counts once the server confirms them (FR6.1).
  final int updates;

  /// The documents set or updated by a confirmed attempt that moved the
  /// counter by [delta]: [updates] plus the cellar when it moved.
  int writtenDocuments(int delta) => updates + (delta == 0 ? 0 : 1);

  /// The active change of this write for [stored].
  int deltaFor(int? stored) => activeDelta(stored, after(stored));
}

/// The active-wine counter of the owner's cellar on the client side
/// (freemium-plus FR2.2, FR2.5, plan decision D1).
///
/// Every batch that changes whether a wine is active also writes
/// `cellars/{cellarId}` with `activeWineCount` ±1 and `activeOpWineId` = that
/// wine, so the rules can check the change with `getAfter`. A shared cellar
/// is the owner's cellar: its document is the same `cellars/{cellarId}`. A
/// batch that keeps the active state never carries the counter: the rules
/// refuse a counter change without an active change.
class ActiveWineCounter {
  ActiveWineCounter({
    required this._db,
    bool Function()? capacityLimitEnabled,
    this._readTimeout = const Duration(seconds: 5),
    this._meter,
  }) : _capacityLimitEnabled = capacityLimitEnabled ?? _off;

  static bool _off() => false;

  final FirebaseFirestore _db;
  final CloudUsageMeter? _meter;

  /// Whether `config/policy.capacityLimitEnabled` is on, as last read: only
  /// then is a refused +1 explained as the capacity limit.
  final bool Function() _capacityLimitEnabled;

  /// How long the single re-read of a refused wine waits for the server.
  final Duration _readTimeout;

  /// Adds the counter update to [batch] when [delta] is not 0; returns
  /// [delta].
  int addTo(
    WriteBatch batch, {
    required String cellarId,
    required String wineId,
    required int delta,
  }) {
    if (delta == 0) return 0;
    batch.update(_db.doc(cellarPath(cellarId)), {
      CellarFields.activeWineCount: FieldValue.increment(delta),
      CellarFields.activeOpWineId: wineId,
    });
    return delta;
  }

  /// Builds and commits [counted] for its known stored quantity. A local
  /// failure (cache, batch) throws synchronously, like `WriteBatch.commit`;
  /// the returned future completes when the server confirms the write.
  ///
  /// When the server refuses it, the wine is read once from the server: if
  /// its active change differs from the one sent (a conflict, D1), the write
  /// is built again for the server quantity and committed once more. A final
  /// refusal is a [CapacityRejectedException] when it is a conflict or a +1
  /// while the capacity limit is on (FR2.5); any other error is the original
  /// one (a lost access, a validation error, the network).
  ///
  /// Completes with the counter change of the attempt the server confirmed.
  Future<int> commit(CountedWineWrite counted) {
    final write = _commitFor(counted, counted.stored);
    return write.catchError(
      (Object error) => _afterRefusal(counted, error as FirebaseException),
      test: _isRulesRefusal,
    );
  }

  Future<int> _commitFor(CountedWineWrite counted, int? stored) {
    final batch = _db.batch();
    counted.write(batch, stored);
    final delta = addTo(
      batch,
      cellarId: counted.cellarId,
      wineId: counted.wineId,
      delta: counted.deltaFor(stored),
    );
    return batch.commit().then((_) => delta);
  }

  static bool _isRulesRefusal(Object error) =>
      error is FirebaseException &&
      error is! CapacityRejectedException &&
      error.code == 'permission-denied';

  Future<int> _afterRefusal(
    CountedWineWrite counted,
    FirebaseException refusal,
  ) async {
    final sentDelta = counted.deltaFor(counted.stored);
    final int? serverStored;
    try {
      serverStored = await serverQuantity(counted.cellarId, counted.wineId);
    } catch (_) {
      // The wine cannot be read again (offline, or the access was lost):
      // the original refusal stands, with its own handling.
      throw refusal;
    }
    final serverDelta = counted.deltaFor(serverStored);
    if (serverDelta == sentDelta) throw _explained(refusal, sentDelta);
    try {
      return await _commitFor(counted, serverStored);
    } on FirebaseException catch (again) {
      if (again.code != 'permission-denied') rethrow;
      throw CapacityRejectedException(
        serverDelta > 0 && _capacityLimitEnabled()
            ? CapacityRejection.capacityLimit
            : CapacityRejection.capacityConflict,
        again,
      );
    }
  }

  /// A refusal of the write as sent: the capacity limit when it added an
  /// active wine while the limit is on, otherwise the original refusal.
  FirebaseException _explained(FirebaseException refusal, int delta) =>
      delta > 0 && _capacityLimitEnabled()
      ? CapacityRejectedException(CapacityRejection.capacityLimit, refusal)
      : refusal;

  /// The stored quantity of [wineId] on the server, null when the wine does
  /// not exist there. Throws when the server cannot be read in time.
  ///
  /// A recovery read: counted by the meter as system usage (FR6.4).
  Future<int?> serverQuantity(String cellarId, String wineId) async {
    final snapshot = await _db
        .doc(winePath(cellarId, wineId))
        .get(const GetOptions(source: Source.server))
        .timeout(_readTimeout);
    _meter?.recordDocument(exists: snapshot.exists, scope: UsageScope.system);
    if (!snapshot.exists) return null;
    return FirestoreValues.integer(snapshot.data()?[WineFields.quantity]) ?? 0;
  }
}
