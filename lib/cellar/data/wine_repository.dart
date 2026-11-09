import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:estimation/estimation.dart'
    show DrinkingWindow, estimationTablesVersion;

import '../../account/app_user.dart';
import '../../app/error_reporter.dart';
import '../../sync/ledger/local_ledger.dart';
import '../../sync/snapshot_meta.dart';
import '../../sync/sync_error_bus.dart';
import '../domain/drinking_record.dart';
import '../domain/firestore_values.dart';
import '../domain/match_key.dart';
import '../domain/quantity.dart';
import '../domain/quantity_delta.dart';
import '../domain/wine.dart';
import '../domain/wine_classification.dart';
import '../domain/wine_draft.dart';
import '../domain/wine_estimate.dart';
import 'cellar_errors.dart';
import 'firestore_codec.dart';
import 'server_or_cache.dart';

/// Outcome of the transaction of one migrated wine (wine-style-profiles
/// BR7.4, BR7.6).
enum MigrationWrite {
  /// Written with `migrationVersion` 3.
  written,

  /// Changed by someone else since it was read, or gone: retried at the
  /// next start.
  skipped,

  /// Refused by the rules: the migration stops for this start.
  rejected,

  /// Another error (network, server): the migration stops for this start.
  failed,
}

/// Result of a save attempt as seen by the form.
sealed class SaveOutcome {
  const SaveOutcome();
}

/// Saved on the phone; the cloud write continues in the background (BR3.1).
class SaveAccepted extends SaveOutcome {
  const SaveAccepted();
}

/// The local save failed immediately (ledger or cache): the form stays open
/// with its data and shows "Could not save, try again" (NFR6.4).
class SaveFailure extends SaveOutcome {
  const SaveFailure(this.cause);

  final Object cause;
}

/// How a failed Firestore write is handled (security-design.md §3).
enum WriteErrorKind {
  /// permission-denied, invalid-argument, failed-precondition: the server
  /// refused it; the entry becomes `rejected`.
  rejected,

  /// The session is no longer valid: back to sign-in; the write stays queued.
  unauthenticated,

  /// unknown, internal, resource-exhausted...: the entry stays `open`, the
  /// user sees "Could not save" and SyncWatcher checks it later.
  transient,
}

const Set<String> _rejectionCodes = {
  'permission-denied',
  'invalid-argument',
  'failed-precondition',
};

WriteErrorKind classifyWriteError(Object error) {
  if (error is FirebaseException) {
    if (_rejectionCodes.contains(error.code)) return WriteErrorKind.rejected;
    if (error.code == 'unauthenticated') return WriteErrorKind.unauthenticated;
  }
  return WriteErrorKind.transient;
}

/// Result of [WineRepository.deleteWineWithRecords] (BR1.14).
enum DeleteOutcome {
  /// The wine and its drinks are deleted on the server.
  deleted,

  /// Deleted on the phone, offline: the drinks not downloaded yet are purged
  /// when the network is back.
  queued,

  /// A part was refused twice: the wine stays.
  failed,
}

/// What one u4-cellar wine write needs for its ledger ticket and errors.
class _WriteContext {
  const _WriteContext({
    required this.cellarId,
    required this.user,
    required this.wineId,
    required this.wineName,
    required this.sensitive,
    required this.reason,
    this.entry,
    this.quiet = false,
    this.onFailure,
  });

  final String cellarId;
  final AppUser user;
  final String wineId;
  final String wineName;
  final List<String> sensitive;
  final String reason;

  /// A journal entry for a creation (the rejected-wine notice of U1).
  final JournalEntry? entry;

  /// A background write the person did not ask for (the one-off estimate
  /// migration, label-autofill-windows NFR4.8a): a failure is told to
  /// [onFailure] only, never shown nor reported per wine.
  final bool quiet;
  final void Function(WriteErrorKind kind)? onFailure;
}

/// A snapshot of the wines of a cellar, sorted by name, with its metadata.
class WinesSnapshot {
  const WinesSnapshot({required this.wines, required this.meta});

  final List<Wine> wines;
  final SnapshotMeta meta;
}

/// Wines of a cellar (logical-components.md: WineRepository).
///
/// Every write passes from here: the ledger is updated first, then the
/// Firestore write starts without being awaited, and its outcome is routed
/// to the ledger and to [SyncErrorBus] (NFR6.2, NFR6.3).
class WineRepository {
  WineRepository({
    required this._db,
    required this._ledger,
    required this._bus,
    required this._reporter,
    this._onWriteStarted,
    this._readTimeout = const Duration(seconds: 1),
    this._maxBatchWrites = 400,
  });

  final FirebaseFirestore _db;
  final LocalLedger _ledger;
  final SyncErrorBus _bus;
  final ErrorReporter _reporter;
  final void Function()? _onWriteStarted;

  /// How long a duplicate or drinks query waits for the server before it
  /// reads the cache (performance-design.md §1: 1 s).
  final Duration _readTimeout;

  /// Operations per batch of a deletion (NFR5.5: 400).
  final int _maxBatchWrites;

  /// Creates [draft] in [cellarId] (BR2.4, BR3.1).
  ///
  /// Awaits only the ledger (a few ms), then calls `set()` without awaiting
  /// it: the form closes at once and the list shows the wine from the local
  /// snapshot (NFR1.1). Synchronous failures of the ledger or of the local
  /// cache return [SaveFailure] (NFR6.4).
  Future<SaveOutcome> create({
    required String cellarId,
    required AppUser user,
    required WineDraft draft,
  }) async {
    final sensitive = [user.uid, user.email, draft.name];
    final WriteTicket ticket;
    try {
      ticket = await _ledger.beginWrite(
        uid: user.uid,
        email: user.email,
        entry: JournalEntry(
          wineId: draft.id,
          cellarId: cellarId,
          name: draft.name,
          ownerUid: user.uid,
        ),
      );
    } catch (error, stack) {
      await _reporter.report(
        error,
        stack,
        reason: 'LedgerWriteFailed',
        sensitive: sensitive,
      );
      return SaveFailure(error);
    }

    final Future<void> write;
    try {
      write = _db.doc(winePath(cellarId, draft.id)).set({
        ...draft.toCreateFields(uid: user.uid),
        WineFields.createdAt: FieldValue.serverTimestamp(),
        WineFields.updatedAt: FieldValue.serverTimestamp(),
      });
    } catch (error, stack) {
      await _reporter.report(
        error,
        stack,
        reason: 'LocalCacheWriteFailed',
        sensitive: sensitive,
      );
      // Nothing reached Firestore: drop the journal entry so a retry from the
      // still-open form starts clean.
      await _dismissQuietly(draft.id, sensitive);
      return SaveFailure(error);
    }

    unawaited(
      write.then(
        (_) => _onCreateConfirmed(ticket, draft.id),
        onError: (Object error, StackTrace stack) => _onWriteError(
          ticket: ticket,
          cellarId: cellarId,
          uid: user.uid,
          wineId: draft.id,
          wineName: draft.name,
          error: error,
          stack: stack,
          sensitive: sensitive,
          journaled: true,
        ),
      ),
    );
    _onWriteStarted?.call();
    return const SaveAccepted();
  }

  /// Changes the quantity by [delta] as an increment, so concurrent changes
  /// add up (BR3.4). U1 has no screen for it: data-level only.
  Future<SaveOutcome> incrementQuantity({
    required String cellarId,
    required String wineId,
    required String wineName,
    required AppUser user,
    required int delta,
  }) async {
    if (delta == 0) throw ArgumentError.value(delta, 'delta');
    final sensitive = [user.uid, user.email, wineName];
    final WriteTicket ticket;
    try {
      ticket = await _ledger.beginWrite(uid: user.uid, email: user.email);
    } catch (error, stack) {
      await _reporter.report(
        error,
        stack,
        reason: 'LedgerWriteFailed',
        sensitive: sensitive,
      );
      return SaveFailure(error);
    }
    final Future<void> write;
    try {
      write = _db.doc(winePath(cellarId, wineId)).update({
        WineFields.quantity: FieldValue.increment(delta),
        WineFields.updatedAt: FieldValue.serverTimestamp(),
        WineFields.updatedBy: user.uid,
      });
    } catch (error, stack) {
      await _reporter.report(
        error,
        stack,
        reason: 'LocalCacheWriteFailed',
        sensitive: sensitive,
      );
      return SaveFailure(error);
    }
    unawaited(
      write.then(
        (_) {},
        onError: (Object error, StackTrace stack) => _onWriteError(
          ticket: ticket,
          cellarId: cellarId,
          uid: user.uid,
          wineId: wineId,
          wineName: wineName,
          error: error,
          stack: stack,
          sensitive: sensitive,
          journaled: false,
        ),
      ),
    );
    _onWriteStarted?.call();
    return const SaveAccepted();
  }

  /// The single listener of the wines still in [cellarId], with metadata
  /// changes (NFR5.1, NFR2.4): `where quantity > 0` since u4-cellar (BR1.7),
  /// so the finished wines are never read in daily use. A negative stored
  /// value, shown as 0, is a finished wine too. Wines are sorted by name on
  /// the client. It replaces `watchWines` of U1 for every consumer (Cellar,
  /// Dashboard, sharing).
  Stream<WinesSnapshot> watchCellarWines(String cellarId) => _db
      .collection(winesPath(cellarId))
      .where(WineFields.quantity, isGreaterThan: 0)
      .snapshots(includeMetadataChanges: true)
      .map(
        (snapshot) => WinesSnapshot(
          wines: _winesOf(snapshot.docs)..sort(Wine.compareByName),
          meta: SnapshotMeta(
            hasPendingWrites: snapshot.metadata.hasPendingWrites,
            isFromCache: snapshot.metadata.isFromCache,
          ),
        ),
      );

  static List<Wine> _winesOf(
    Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) => [
    for (final doc in docs) Wine.fromMap(doc.id, decodeDocument(doc.data())),
  ];

  /// One wine, present or finished (BR1.7 archive, BR1.16): a single
  /// document listener; `null` while it does not exist.
  Stream<Wine?> watchWine(String cellarId, String wineId) => _db
      .doc(winePath(cellarId, wineId))
      .snapshots()
      .map(
        (doc) => doc.exists
            ? Wine.fromMap(doc.id, decodeDocument(doc.data()))
            : null,
      );

  /// The finished wines of [cellarId] ("Drunk", BR1.7), read once and only
  /// when the archive is opened, sorted by name.
  Future<List<Wine>> fetchArchived(String cellarId) async {
    final snapshot = await _db
        .collection(winesPath(cellarId))
        .where(WineFields.quantity, isLessThanOrEqualTo: 0)
        .get();
    return _winesOf(snapshot.docs)..sort(Wine.compareByName);
  }

  /// The wines of [cellarId] with [matchKey], finished ones included (BR1.4),
  /// oldest first: from the server within [_readTimeout], else from the
  /// unlimited cache (NFR5.3: one query per save).
  Future<List<Wine>> findByMatchKey(String cellarId, String matchKey) async {
    final query = _db
        .collection(winesPath(cellarId))
        .where(WineFields.matchKey, isEqualTo: matchKey);
    final read = await readServerOrCache(query, _readTimeout);
    return _winesOf(read.snapshot.docs)..sort(Wine.compareByAge);
  }

  /// Creates [draft] with its u4-cellar details, `matchKey` and [estimate]
  /// (BR1.1-BR1.5, BR1.18). Like [create]: awaits only the ledger, then
  /// writes without waiting for the network.
  Future<SaveOutcome> addWine({
    required String cellarId,
    required AppUser user,
    required WineDraft draft,
    WineEstimate estimate = WineEstimate.none,
  }) {
    final fields = <String, Object?>{
      ...draft.toCreateFields(uid: user.uid),
      WineFields.producer: ?draft.producer,
      WineFields.wineType: ?draft.wineType,
      WineFields.region: ?draft.region,
      WineFields.denomination: ?draft.denomination,
      // ux-redesign FR1.5: only when known, so a wine without a country
      // keeps the shape the earlier rules accept (NFR4).
      WineFields.country: ?draft.country,
      // label-autofill-windows BR4.3: only a level chosen or accepted.
      WineFields.level: ?draft.level?.name,
      // wine-style-profiles BR7.1: style, sources and date when known; a new
      // wine needs no migration (BR7.6).
      ...draft.classificationFields(),
      WineFields.migrationVersion: estimationTablesVersion,
      WineFields.matchKey: matchKeyOf(
        draft.name,
        draft.producer,
        draft.vintage,
      ),
      for (final entry in estimate.toFields().entries)
        if (entry.value != null) entry.key: entry.value,
      WineFields.createdAt: FieldValue.serverTimestamp(),
      WineFields.updatedAt: FieldValue.serverTimestamp(),
    };
    return _commit(
      _WriteContext(
        cellarId: cellarId,
        user: user,
        wineId: draft.id,
        wineName: draft.name,
        sensitive: [draft.name, ?draft.producer, ?draft.denomination],
        reason: CellarErrorReasons.saveFailed,
        entry: JournalEntry(
          wineId: draft.id,
          cellarId: cellarId,
          name: draft.name,
          ownerUid: user.uid,
        ),
      ),
      (batch) => batch.set(_db.doc(winePath(cellarId, draft.id)), fields),
    );
  }

  /// Adds [n] bottles to [wine] (BR1.15): `increment(n − s)` when the stored
  /// value s is negative, so the result is n. Used by "+", by the duplicate
  /// dialog and by "Undo".
  ///
  /// Refused, with no write, when the shown quantity would go over 99
  /// (BR1.3 cap, review R-05).
  Future<SaveOutcome> addBottles({
    required String cellarId,
    required AppUser user,
    required Wine wine,
    required int n,
  }) async {
    if (!QuantityDelta.canIncrease(wine.storedQuantity, n)) {
      return SaveFailure(
        RangeError.range(
          wine.quantity + n,
          QuantityLimits.min,
          QuantityLimits.max,
          'quantity',
        ),
      );
    }
    return _updateWine(cellarId, user, wine, CellarErrorReasons.saveFailed, {
      WineFields.quantity: FieldValue.increment(
        QuantityDelta.forIncrease(wine.storedQuantity, n),
      ),
    });
  }

  /// Removes one bottle ("−", BR1.15). Refused while the shown value is 0.
  Future<SaveOutcome> removeBottle({
    required String cellarId,
    required AppUser user,
    required Wine wine,
  }) async {
    if (!QuantityDelta.canDecrease(wine.storedQuantity)) {
      return SaveFailure(StateError('no bottle to remove'));
    }
    return _updateWine(cellarId, user, wine, CellarErrorReasons.saveFailed, {
      WineFields.quantity: FieldValue.increment(-1),
    });
  }

  /// Saves the edit form (BR1.13): the texts, `matchKey`, [estimate] and the
  /// quantity as a change towards [targetQuantity], never below 0.
  ///
  /// ux-redesign FR1.5: `country` is written when the draft has one (an
  /// earlier wine with an Italian region gets `IT` from the validator,
  /// review R-06) or to clear the one [before] had; an edit of a wine that
  /// never had a country does not add the field.
  Future<SaveOutcome> updateWine({
    required String cellarId,
    required AppUser user,
    required Wine before,
    required WineDraft draft,
    required int targetQuantity,
    required WineEstimate estimate,
  }) async {
    final delta = QuantityDelta.forEdit(before.storedQuantity, targetQuantity);
    final details = <String, Object?>{
      WineFields.name: draft.name,
      WineFields.producer: draft.producer,
      WineFields.vintage: draft.vintage,
      WineFields.wineType: draft.wineType,
      WineFields.region: draft.region,
      WineFields.denomination: draft.denomination,
      if (draft.country != null || before.country != null)
        WineFields.country: draft.country,
      // label-autofill-windows BR4.3: a level chosen is written; "None"
      // removes a saved one; a wine that never had one stays without.
      if (draft.level != null)
        WineFields.level: draft.level!.name
      else if (before.level != null)
        WineFields.level: FieldValue.delete(),
      // wine-style-profiles BR7.1, BR8.1: the same rule for the new fields.
      ..._classificationUpdate(before, draft),
      WineFields.matchKey: matchKeyOf(
        draft.name,
        draft.producer,
        draft.vintage,
      ),
      if (delta != 0) WineFields.quantity: FieldValue.increment(delta),
    };
    final sensitive = [draft.name, ?draft.producer, ?draft.denomination];
    // wine-style-profiles: with a drink feedback the window differs from
    // the base window and the rules check both; with the texts and the
    // classification in the same update the request would pass the 1000
    // expressions Firestore evaluates. The edit is then written in two
    // updates, in order: details, then the estimate.
    final base = estimate.baseWindow;
    final split =
        base != null && estimate.window != null && estimate.window != base;
    if (!split) {
      return _updateWine(
        cellarId,
        user,
        before,
        CellarErrorReasons.saveFailed,
        {...details, ...estimate.toFields()},
        sensitive: sensitive,
      );
    }
    final first = await _updateWine(
      cellarId,
      user,
      before,
      CellarErrorReasons.saveFailed,
      details,
      sensitive: sensitive,
    );
    if (first is! SaveAccepted) return first;
    return _updateWine(
      cellarId,
      user,
      before,
      CellarErrorReasons.saveFailed,
      estimate.toFields(),
      sensitive: sensitive,
    );
  }

  /// The classification fields of an edit (wine-style-profiles BR7.1): a
  /// value written, or deleted when [before] had one and the draft has
  /// none; a wine that never had a field stays without it.
  static Map<String, Object?> _classificationUpdate(
    Wine before,
    WineDraft draft,
  ) {
    Object? value(Object? now, Object? was) =>
        now ?? (was != null ? FieldValue.delete() : null);
    final fields = <String, Object?>{
      WineFields.style: value(draft.style?.name, before.style),
      WineFields.typeSource: value(draft.typeSource?.name, before.typeSource),
      WineFields.levelSource: value(
        draft.levelSource?.name,
        before.levelSource,
      ),
      WineFields.styleSource: value(
        draft.styleSource?.name,
        before.styleSource,
      ),
      WineFields.agingStartMonth: value(
        draft.agingStart?.toMap(),
        before.agingStart,
      ),
    };
    fields.removeWhere((_, v) => v == null);
    return fields;
  }

  /// Writes the classification chosen in the detail (wine-style-profiles
  /// F5): Type, Level, Style with their sources and the new estimate, in
  /// one update.
  Future<SaveOutcome> updateClassification({
    required String cellarId,
    required AppUser user,
    required Wine wine,
    required WineClassification classification,
    required WineEstimate estimate,
  }) => _updateWine(cellarId, user, wine, CellarErrorReasons.saveFailed, {
    ...classification.toFields(),
    ...estimate.toFields(),
  });

  /// The one-off migration of a wine (wine-style-profiles BR7.4, D4): in a
  /// transaction the document is read again; when its `updatedAt` differs
  /// from [seenUpdatedAt] (another member changed it) the wine is skipped
  /// and stays to migrate; otherwise the classification, the estimate and
  /// `migrationVersion` are updated with `updatedAt` and `updatedBy`, so the
  /// write passes `validWineUpdate`. A transaction needs the server: the
  /// caller runs it online only.
  Future<MigrationWrite> migrateWine({
    required String cellarId,
    required AppUser user,
    required String wineId,
    required DateTime? seenUpdatedAt,
    required Map<String, Object?> fields,
  }) async {
    final ref = _db.doc(winePath(cellarId, wineId));
    try {
      return await _db.runTransaction((transaction) async {
        final snapshot = await transaction.get(ref);
        final data = snapshot.data();
        if (!snapshot.exists || data == null) return MigrationWrite.skipped;
        final now = FirestoreValues.dateTime(
          decodeDocument(data)[WineFields.updatedAt],
        );
        final unchanged = now == null || seenUpdatedAt == null
            ? now == seenUpdatedAt
            : now.isAtSameMomentAs(seenUpdatedAt);
        if (!unchanged) return MigrationWrite.skipped;
        transaction.update(ref, {
          ...fields,
          WineFields.updatedAt: FieldValue.serverTimestamp(),
          WineFields.updatedBy: user.uid,
        });
        return MigrationWrite.written;
      });
    } on FirebaseException catch (error) {
      return error.code == 'permission-denied'
          ? MigrationWrite.rejected
          : MigrationWrite.failed;
    }
  }

  /// Writes the estimate of [wine] (BR1.5, BR1.6, BR1.12). Callers write
  /// only with `canEdit` (BR1.19). A [quiet] write (the one-off migration
  /// of label-autofill-windows, NFR4.8a) tells its failure to [onFailure]
  /// only.
  Future<SaveOutcome> setEstimate({
    required String cellarId,
    required AppUser user,
    required Wine wine,
    required WineEstimate estimate,
    String reason = CellarErrorReasons.estimateRefreshFailed,
    bool quiet = false,
    void Function(WriteErrorKind kind)? onFailure,
  }) => _updateWine(
    cellarId,
    user,
    wine,
    reason,
    estimate.toFields(),
    quiet: quiet,
    onFailure: onFailure,
  );

  /// "Save correction" of "Recommended until" (label-autofill-windows F5,
  /// NFR4.14): `windowOverride` with the server time and the effective
  /// [window] in one update, so both are written or neither.
  Future<SaveOutcome> setOverride({
    required String cellarId,
    required AppUser user,
    required Wine wine,
    required int endYear,
    required DrinkingWindow window,
    int? endMonth,
  }) => _updateWine(cellarId, user, wine, CellarErrorReasons.saveFailed, {
    WineFields.windowOverride: {
      OverrideFields.endYear: endYear,
      // wine-style-profiles BR6.8: the month of a window in months.
      OverrideFields.endMonth: ?endMonth,
      OverrideFields.setAt: FieldValue.serverTimestamp(),
    },
    WineFields.window: Wine.windowToMap(window),
  });

  /// "Restore the estimate" (FR5.4, BR4.6): `windowOverride` deleted and
  /// the effective [window] without it, in one update; the drink feedback
  /// stays.
  Future<SaveOutcome> clearOverride({
    required String cellarId,
    required AppUser user,
    required Wine wine,
    required DrinkingWindow window,
  }) => _updateWine(cellarId, user, wine, CellarErrorReasons.saveFailed, {
    WineFields.windowOverride: FieldValue.delete(),
    WineFields.window: Wine.windowToMap(window),
  });

  /// Merges a possible duplicate (BR1.20) in one batch: the bottles of
  /// [newer] go to [older] (BR1.15), then [newer] is deleted. The caller
  /// checks that the user is the owner and that [newer] has no drinks.
  Future<SaveOutcome> mergeInto({
    required String cellarId,
    required AppUser user,
    required Wine older,
    required Wine newer,
  }) async {
    final moved = newer.quantity;
    // The merged entry keeps the 99-bottle cap (BR1.3, review R-05).
    if (moved > 0 && !QuantityDelta.canIncrease(older.storedQuantity, moved)) {
      return SaveFailure(
        RangeError.range(
          older.quantity + moved,
          QuantityLimits.min,
          QuantityLimits.max,
          'quantity',
        ),
      );
    }
    final increment = moved > 0
        ? QuantityDelta.forIncrease(older.storedQuantity, moved)
        : QuantityDelta.forEdit(older.storedQuantity, older.quantity);
    return _commit(
      _WriteContext(
        cellarId: cellarId,
        user: user,
        wineId: older.id,
        wineName: older.name,
        sensitive: [...sensitiveOfWine(older), ...sensitiveOfWine(newer)],
        reason: CellarErrorReasons.mergeFailed,
      ),
      (batch) => batch
        ..update(_db.doc(winePath(cellarId, older.id)), {
          WineFields.quantity: FieldValue.increment(increment),
          WineFields.updatedAt: FieldValue.serverTimestamp(),
          WineFields.updatedBy: user.uid,
        })
        ..delete(_db.doc(winePath(cellarId, newer.id))),
    );
  }

  /// Deletes [wine] and all its drinks (BR1.14, NFR5.5): batches of at most
  /// [_maxBatchWrites] operations, the wine last.
  ///
  /// - Online (the drinks were read from the server): each part is awaited.
  ///   A refused part, e.g. a drink deleted meanwhile by an "Undo" on another
  ///   phone, is retried once with the drinks read again from the server.
  ///   A second failure stops, reports `cellar_delete_failed` and returns
  ///   [DeleteOutcome.failed]: the wine stays, the caller queues a purge.
  /// - Offline (cache read): every part is queued on the phone at once and
  ///   [DeleteOutcome.queued] asks the caller to purge the drinks this phone
  ///   has not downloaded yet when the network is back (NFR6.6).
  Future<DeleteOutcome> deleteWineWithRecords({
    required String cellarId,
    required AppUser user,
    required Wine wine,
  }) async {
    final sensitive = [user.uid, user.email, ...sensitiveOfWine(wine)];
    final WriteTicket ticket;
    try {
      ticket = await _ledger.beginWrite(uid: user.uid, email: user.email);
    } catch (error, stack) {
      await _report(error, stack, CellarErrorReasons.deleteFailed, sensitive);
      return DeleteOutcome.failed;
    }
    try {
      final read = await _recordIdsOf(cellarId, wine.id, serverOnly: false);
      if (!read.fromServer) {
        for (final batch in _deleteBatches(cellarId, wine.id, read.ids)) {
          unawaited(
            batch.commit().then(
              (_) {},
              onError: (Object error, StackTrace stack) =>
                  _onDeleteError(ticket, error, stack, sensitive),
            ),
          );
        }
        _onWriteStarted?.call();
        return DeleteOutcome.queued;
      }
      if (await _commitAll(cellarId, wine.id, read.ids)) {
        return DeleteOutcome.deleted;
      }
      final again = await _recordIdsOf(cellarId, wine.id, serverOnly: true);
      if (await _commitAll(cellarId, wine.id, again.ids)) {
        return DeleteOutcome.deleted;
      }
      await _report(
        StateError('delete part refused twice'),
        StackTrace.current,
        CellarErrorReasons.deleteFailed,
        sensitive,
      );
      return DeleteOutcome.failed;
    } catch (error, stack) {
      await _report(error, stack, CellarErrorReasons.deleteFailed, sensitive);
      return DeleteOutcome.failed;
    }
  }

  /// Completes a deletion left half done (RecordReconciler `purgeRecords`,
  /// NFR6.6): reads the drinks of [wineId] from the server, deletes them in
  /// parts and then the wine. Throws when a part fails, so the entry stays.
  Future<void> purgeRecords(String cellarId, String wineId) async {
    final read = await _recordIdsOf(cellarId, wineId, serverOnly: true);
    for (final batch in _deleteBatches(cellarId, wineId, read.ids)) {
      await batch.commit();
    }
  }

  Future<bool> _commitAll(
    String cellarId,
    String wineId,
    List<String> recordIds,
  ) async {
    try {
      for (final batch in _deleteBatches(cellarId, wineId, recordIds)) {
        await batch.commit();
      }
      _onWriteStarted?.call();
      return true;
    } on FirebaseException {
      return false;
    }
  }

  /// The delete batches: drinks in parts of [_maxBatchWrites], the wine in
  /// the last part.
  List<WriteBatch> _deleteBatches(
    String cellarId,
    String wineId,
    List<String> recordIds,
  ) {
    final batches = <WriteBatch>[];
    var current = _db.batch();
    var count = 0;
    for (final id in recordIds) {
      if (count == _maxBatchWrites) {
        batches.add(current);
        current = _db.batch();
        count = 0;
      }
      current.delete(_db.doc(drinkingRecordPath(cellarId, id)));
      count++;
    }
    if (count == _maxBatchWrites) {
      batches.add(current);
      current = _db.batch();
    }
    current.delete(_db.doc(winePath(cellarId, wineId)));
    batches.add(current);
    return batches;
  }

  Future<({List<String> ids, bool fromServer})> _recordIdsOf(
    String cellarId,
    String wineId, {
    required bool serverOnly,
  }) async {
    final query = _db
        .collection(drinkingRecordsPath(cellarId))
        .where(DrinkingRecordFields.wineId, isEqualTo: wineId);
    if (serverOnly) {
      final snapshot = await query.get(const GetOptions(source: Source.server));
      return (ids: [for (final doc in snapshot.docs) doc.id], fromServer: true);
    }
    final read = await readServerOrCache(query, _readTimeout);
    return (
      ids: [for (final doc in read.snapshot.docs) doc.id],
      fromServer: read.fromServer,
    );
  }

  Future<void> _onDeleteError(
    WriteTicket ticket,
    Object error,
    StackTrace stack,
    List<String> sensitive,
  ) async {
    if (!await _isCurrentGenerationQuietly(ticket)) return;
    await _report(error, stack, CellarErrorReasons.deleteFailed, sensitive);
  }

  Future<SaveOutcome> _updateWine(
    String cellarId,
    AppUser user,
    Wine wine,
    String reason,
    Map<String, Object?> fields, {
    List<String>? sensitive,
    bool quiet = false,
    void Function(WriteErrorKind kind)? onFailure,
  }) => _commit(
    _WriteContext(
      cellarId: cellarId,
      user: user,
      wineId: wine.id,
      wineName: wine.name,
      sensitive: [...sensitiveOfWine(wine), ...?sensitive],
      reason: reason,
      quiet: quiet,
      onFailure: onFailure,
    ),
    (batch) => batch.update(_db.doc(winePath(cellarId, wine.id)), {
      ...fields,
      WineFields.updatedAt: FieldValue.serverTimestamp(),
      WineFields.updatedBy: user.uid,
    }),
  );

  /// The common path of the u4-cellar wine writes: the ledger first, then
  /// one batch committed without waiting for the network; its outcome goes
  /// to the ledger and to [SyncErrorBus] with a fixed reason.
  Future<SaveOutcome> _commit(
    _WriteContext context,
    void Function(WriteBatch batch) build,
  ) async {
    final sensitive = [
      context.user.uid,
      context.user.email,
      ...context.sensitive,
    ];
    final WriteTicket ticket;
    try {
      ticket = await _ledger.beginWrite(
        uid: context.user.uid,
        email: context.user.email,
        entry: context.entry,
      );
    } catch (error, stack) {
      await _report(error, stack, context.reason, sensitive);
      return SaveFailure(error);
    }
    final Future<void> write;
    try {
      final batch = _db.batch();
      build(batch);
      write = batch.commit();
    } catch (error, stack) {
      await _report(error, stack, context.reason, sensitive);
      final entry = context.entry;
      if (entry != null) await _dismissQuietly(entry.wineId, sensitive);
      return SaveFailure(error);
    }
    unawaited(
      write.then(
        (_) async {
          if (context.entry != null) {
            await _onCreateConfirmed(ticket, context.wineId);
          }
        },
        onError: (Object error, StackTrace stack) => context.quiet
            ? _onQuietWriteError(ticket, context, error)
            : _onWriteError(
                ticket: ticket,
                cellarId: context.cellarId,
                uid: context.user.uid,
                wineId: context.wineId,
                wineName: context.wineName,
                error: error,
                stack: stack,
                sensitive: sensitive,
                journaled: context.entry != null,
                reason: context.reason,
              ),
      ),
    );
    _onWriteStarted?.call();
    return const SaveAccepted();
  }

  Future<void> _report(
    Object error,
    StackTrace stack,
    String reason,
    List<String> sensitive,
  ) => _reporter.report(error, stack, reason: reason, sensitive: sensitive);

  Future<bool> _isCurrentGenerationQuietly(WriteTicket ticket) async {
    try {
      return await _isCurrentGeneration(ticket);
    } catch (_) {
      return true;
    }
  }

  Future<bool> _isCurrentGeneration(WriteTicket ticket) async =>
      await _ledger.generation() == ticket.generation;

  Future<void> _onCreateConfirmed(WriteTicket ticket, String wineId) async {
    try {
      if (!await _isCurrentGeneration(ticket)) return;
      await _ledger.markConfirmed(wineId);
    } catch (error, stack) {
      await _reporter.report(error, stack, reason: 'LedgerUpdateFailed');
    }
  }

  /// A quiet write failed: only its caller hears of it, and only while the
  /// write belongs to the current ledger generation.
  Future<void> _onQuietWriteError(
    WriteTicket ticket,
    _WriteContext context,
    Object error,
  ) async {
    if (!await _isCurrentGenerationQuietly(ticket)) return;
    context.onFailure?.call(classifyWriteError(error));
  }

  /// [cellarId] is the cellar of the written path: a refusal on a shared
  /// cellar also tells the app that the access was lost (u7-sharing BR1.14).
  Future<void> _onWriteError({
    required WriteTicket ticket,
    required String cellarId,
    required String uid,
    required String wineId,
    required String wineName,
    required Object error,
    required StackTrace stack,
    required List<String> sensitive,
    required bool journaled,
    String? reason,
  }) async {
    try {
      // A reset happened after this write started: its outcome is obsolete.
      if (!await _isCurrentGeneration(ticket)) return;
      switch (classifyWriteError(error)) {
        case WriteErrorKind.rejected:
          if (journaled) await _ledger.markRejected(wineId);
          reportWriteRejected(
            _bus,
            cellarId: cellarId,
            uid: uid,
            error: error,
            wineId: wineId,
            wineName: wineName,
          );
          await _reporter.report(
            error,
            stack,
            reason: reason ?? 'SyncRejected',
            sensitive: sensitive,
          );
        case WriteErrorKind.unauthenticated:
          _bus.publish(const SessionExpired());
        case WriteErrorKind.transient:
          _bus.publish(WriteFailed(wineId: wineId));
          await _reporter.report(
            error,
            stack,
            reason: reason ?? 'WriteFailed',
            sensitive: sensitive,
          );
      }
    } catch (handlerError, handlerStack) {
      await _reporter.report(
        handlerError,
        handlerStack,
        reason: 'LedgerUpdateFailed',
        sensitive: sensitive,
      );
    }
  }

  Future<void> _dismissQuietly(String wineId, List<String> sensitive) async {
    try {
      await _ledger.dismiss(wineId);
    } catch (error, stack) {
      await _reporter.report(
        error,
        stack,
        reason: 'LedgerUpdateFailed',
        sensitive: sensitive,
      );
    }
  }
}
