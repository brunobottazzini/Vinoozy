import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../account/app_user.dart';
import '../../app/error_reporter.dart';
import '../../core/id_generator.dart';
import '../../sync/ledger/local_ledger.dart';
import '../../sync/sync_error_bus.dart';
import '../domain/drinking_record.dart';
import '../domain/quantity_delta.dart';
import '../domain/wine.dart';
import 'cellar_errors.dart';
import 'firestore_codec.dart';
import 'pending_writes_probe.dart';
import 'server_or_cache.dart';
import 'wine_repository.dart';

/// Result of [DrinkingRecordRepository.drink].
sealed class DrinkOutcome {
  const DrinkOutcome();
}

/// Saved on the phone; [recordId] is the drink "Undo" removes.
class DrinkAccepted extends DrinkOutcome {
  const DrinkAccepted(this.recordId);

  final String recordId;
}

/// Not saved: no bottle shown, or the local write failed.
class DrinkFailed extends DrinkOutcome {
  const DrinkFailed(this.cause);

  final Object cause;
}

/// Result of [DrinkingRecordRepository.undo] (BR1.10, NFR6.5).
enum UndoResult {
  /// The drink is deleted and the bottle is back, on the phone at once.
  undone,

  /// The drink no longer exists: "Nothing left to undo", no write.
  nothingToUndo,

  /// The local write failed.
  failed,
}

/// Opaque position after the last drink of a History page (BR1.16).
class HistoryCursor {
  const HistoryCursor(this.lastDocument);

  final DocumentSnapshot<Map<String, dynamic>> lastDocument;
}

/// One page of the History.
class HistoryPage {
  const HistoryPage({
    required this.records,
    required this.cursor,
    required this.hasMore,
  });

  final List<DrinkingRecord> records;

  /// Null when the page is empty.
  final HistoryCursor? cursor;

  /// False when this page was shorter than requested: nothing after it.
  final bool hasMore;
}

/// The drinks of one wine, with where they were read.
class WineRecords {
  const WineRecords({required this.records, required this.fromServer});

  /// Most recent first (drankOn, then createdAt).
  final List<DrinkingRecord> records;
  final bool fromServer;
}

/// Where [DrinkingRecordRepository.recordsOfWine] reads.
enum RecordsSource {
  /// The server within the timeout, else the cache (BR1.12, BR1.14).
  serverOrCache,

  /// The cache only: the last drinks of the detail (performance-design §3).
  cache,

  /// The server only: the recovery after the network (NFR6.6).
  server,
}

/// Drinks of a cellar (logical-components.md: DrinkingRecordRepository).
///
/// Writes are committed without waiting for the network, like the wine
/// writes of U1; [PendingWritesProbe] keeps the sync banner "pending" until
/// they are confirmed. A refused "Undo" is not a lost access: it is
/// reported as `cellar_undo_failed` and announced with [CellarNotice],
/// never through `reportWriteRejected` (security-design.md §4).
class DrinkingRecordRepository {
  DrinkingRecordRepository({
    required this._db,
    required this._ledger,
    required this._bus,
    required this._reporter,
    required this._probe,
    required this._ids,
    this._onWriteStarted,
    this._readTimeout = const Duration(seconds: 1),
  });

  final FirebaseFirestore _db;
  final LocalLedger _ledger;
  final SyncErrorBus _bus;
  final ErrorReporter _reporter;
  final PendingWritesProbe _probe;
  final IdGenerator _ids;
  final void Function()? _onWriteStarted;
  final Duration _readTimeout;

  /// "Drunk" (BR1.10, FR6.1): one batch with quantity −1 (an increment,
  /// BR1.15) and a drink dated [today]. Refused while the shown quantity
  /// is 0.
  ///
  /// ux-redesign FR2.3 (review R-04): the optional [rating] of the
  /// confirmation sheet travels in the same batch, so there is no second
  /// write; a rating outside 1-5 is refused before any write.
  Future<DrinkOutcome> drink({
    required String cellarId,
    required AppUser user,
    required Wine wine,
    required DateTime today,
    int? rating,
  }) async {
    if (!QuantityDelta.canDecrease(wine.storedQuantity)) {
      return DrinkFailed(StateError('no bottle to drink'));
    }
    if (rating != null &&
        (rating < RecordRules.minRating || rating > RecordRules.maxRating)) {
      return DrinkFailed(
        RangeError.range(
          rating,
          RecordRules.minRating,
          RecordRules.maxRating,
          'rating',
        ),
      );
    }
    final recordId = _ids.newId();
    final outcome = await _commit(
      user: user,
      reason: CellarErrorReasons.drinkFailed,
      sensitive: sensitiveOfWine(wine),
      build: (batch) => batch
        ..update(_db.doc(winePath(cellarId, wine.id)), {
          WineFields.quantity: FieldValue.increment(-1),
          WineFields.updatedAt: FieldValue.serverTimestamp(),
          WineFields.updatedBy: user.uid,
        })
        ..set(_db.doc(drinkingRecordPath(cellarId, recordId)), {
          DrinkingRecordFields.wineId: wine.id,
          DrinkingRecordFields.wineName: wine.name,
          DrinkingRecordFields.vintage: wine.vintage,
          DrinkingRecordFields.drankOn: formatDrankOn(today),
          DrinkingRecordFields.rating: ?rating,
          DrinkingRecordFields.recordedBy: user.uid,
          DrinkingRecordFields.createdAt: FieldValue.serverTimestamp(),
        }),
      onError: (error) => _onRejected(
        error,
        cellarId: cellarId,
        uid: user.uid,
        wineId: wine.id,
        wineName: wine.name,
      ),
    );
    return outcome == null ? DrinkAccepted(recordId) : DrinkFailed(outcome);
  }

  /// "Undo" (BR1.10, NFR6.5): reads the drink from the cache; when it still
  /// exists, deletes it and adds the bottle back (BR1.15) in one batch.
  Future<UndoResult> undo({
    required String cellarId,
    required AppUser user,
    required Wine wine,
    required String recordId,
  }) async {
    final ref = _db.doc(drinkingRecordPath(cellarId, recordId));
    try {
      final cached = await ref.get(const GetOptions(source: Source.cache));
      if (!cached.exists) return UndoResult.nothingToUndo;
    } on FirebaseException {
      // Not in the cache: it was deleted or never reached this phone.
      return UndoResult.nothingToUndo;
    }
    final failure = await _commit(
      user: user,
      reason: CellarErrorReasons.undoFailed,
      sensitive: sensitiveOfWine(wine),
      build: (batch) => batch
        ..delete(ref)
        ..update(_db.doc(winePath(cellarId, wine.id)), {
          WineFields.quantity: FieldValue.increment(
            QuantityDelta.forIncrease(wine.storedQuantity, 1),
          ),
          WineFields.updatedAt: FieldValue.serverTimestamp(),
          WineFields.updatedBy: user.uid,
        }),
      onError: (_) =>
          _bus.publish(const CellarNotice(CellarNoticeKind.undoRejected)),
    );
    return failure == null ? UndoResult.undone : UndoResult.failed;
  }

  /// Rating, notes, date and "How was it?" (BR1.11): by the author or the
  /// owner, as the rules require.
  Future<SaveOutcome> updateRecord({
    required String cellarId,
    required AppUser user,
    required DrinkingRecord record,
    required int? rating,
    required String? notes,
    required DateTime drankOn,
    required DrinkCondition? condition,
  }) async {
    final trimmed = notes?.trim();
    final failure = await _commit(
      user: user,
      reason: CellarErrorReasons.recordUpdateFailed,
      sensitive: [record.wineName, ?record.notes, ?trimmed],
      build: (batch) =>
          batch.update(_db.doc(drinkingRecordPath(cellarId, record.id)), {
            DrinkingRecordFields.rating: rating,
            DrinkingRecordFields.notes: trimmed == null || trimmed.isEmpty
                ? null
                : trimmed,
            DrinkingRecordFields.drankOn: formatDrankOn(drankOn),
            DrinkingRecordFields.condition: condition?.name,
            DrinkingRecordFields.updatedAt: FieldValue.serverTimestamp(),
          }),
      onError: (error) => _onRejected(
        error,
        cellarId: cellarId,
        uid: user.uid,
        wineId: record.wineId,
      ),
    );
    return failure == null ? const SaveAccepted() : SaveFailure(failure);
  }

  /// One History page (BR1.16, NFR5.2): the drinks of the cellar by
  /// `drankOn`, then `createdAt`, both descending (composite index), after
  /// [after].
  Future<HistoryPage> pageHistory(
    String cellarId, {
    HistoryCursor? after,
    int limit = 30,
  }) async {
    var query = _db
        .collection(drinkingRecordsPath(cellarId))
        .orderBy(DrinkingRecordFields.drankOn, descending: true)
        .orderBy(DrinkingRecordFields.createdAt, descending: true);
    if (after != null) query = query.startAfterDocument(after.lastDocument);
    final snapshot = await query.limit(limit).get();
    final docs = snapshot.docs;
    return HistoryPage(
      records: [
        for (final doc in docs)
          ?DrinkingRecord.fromMap(doc.id, decodeDocument(doc.data())),
      ],
      cursor: docs.isEmpty ? null : HistoryCursor(docs.last),
      hasMore: docs.length >= limit,
    );
  }

  /// The drinks of [wineId] (BR1.9, BR1.12, BR1.14): `where wineId == …`,
  /// sorted in memory, so no composite index is needed (NFR4.8).
  Future<WineRecords> recordsOfWine(
    String cellarId,
    String wineId, {
    RecordsSource source = RecordsSource.serverOrCache,
  }) async {
    final query = _db
        .collection(drinkingRecordsPath(cellarId))
        .where(DrinkingRecordFields.wineId, isEqualTo: wineId);
    final QueryRead read = switch (source) {
      RecordsSource.serverOrCache => await readServerOrCache(
        query,
        _readTimeout,
      ),
      RecordsSource.cache => QueryRead(
        await query.get(const GetOptions(source: Source.cache)),
        fromServer: false,
      ),
      RecordsSource.server => QueryRead(
        await query.get(const GetOptions(source: Source.server)),
        fromServer: true,
      ),
    };
    return WineRecords(
      records: [
        for (final doc in read.snapshot.docs)
          ?DrinkingRecord.fromMap(doc.id, decodeDocument(doc.data())),
      ]..sort(DrinkingRecord.compareRecentFirst),
      fromServer: read.fromServer,
    );
  }

  /// Ledger first, then one batch committed without waiting; returns the
  /// local failure, or `null` when the write is on its way. [onError] runs
  /// for a server refusal after the fixed-reason report.
  Future<Object?> _commit({
    required AppUser user,
    required String reason,
    required List<String> sensitive,
    required void Function(WriteBatch batch) build,
    required void Function(Object error) onError,
  }) async {
    final all = [user.uid, user.email, ...sensitive];
    final WriteTicket ticket;
    try {
      ticket = await _ledger.beginWrite(uid: user.uid, email: user.email);
    } catch (error, stack) {
      await _reporter.report(error, stack, reason: reason, sensitive: all);
      return error;
    }
    final Future<void> write;
    try {
      final batch = _db.batch();
      build(batch);
      write = batch.commit();
    } catch (error, stack) {
      await _reporter.report(error, stack, reason: reason, sensitive: all);
      return error;
    }
    unawaited(
      write.then(
        (_) {},
        onError: (Object error, StackTrace stack) async {
          if (!await _isCurrent(ticket)) return;
          if (classifyWriteError(error) == WriteErrorKind.unauthenticated) {
            _bus.publish(const SessionExpired());
            return;
          }
          onError(error);
          await _reporter.report(error, stack, reason: reason, sensitive: all);
        },
      ),
    );
    unawaited(_probe.trackWrite(write));
    _onWriteStarted?.call();
    return null;
  }

  /// A refused drink write on a shared cellar may be a lost access
  /// (u7-sharing BR1.14): [reportWriteRejected], with the wine for the
  /// "not saved" notice when known.
  void _onRejected(
    Object error, {
    required String cellarId,
    required String uid,
    required String wineId,
    String? wineName,
  }) {
    if (classifyWriteError(error) == WriteErrorKind.rejected) {
      reportWriteRejected(
        _bus,
        cellarId: cellarId,
        uid: uid,
        error: error,
        wineId: wineName == null ? null : wineId,
        wineName: wineName,
      );
    } else {
      _bus.publish(WriteFailed(wineId: wineId));
    }
  }

  Future<bool> _isCurrent(WriteTicket ticket) async {
    try {
      return await _ledger.generation() == ticket.generation;
    } catch (_) {
      return true;
    }
  }
}
