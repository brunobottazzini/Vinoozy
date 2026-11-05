import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../account/app_user.dart';
import '../../app/error_reporter.dart';
import '../../sync/ledger/local_ledger.dart';
import '../../sync/snapshot_meta.dart';
import '../../sync/sync_error_bus.dart';
import '../domain/wine.dart';
import '../domain/wine_draft.dart';
import 'firestore_codec.dart';

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
  });

  final FirebaseFirestore _db;
  final LocalLedger _ledger;
  final SyncErrorBus _bus;
  final ErrorReporter _reporter;
  final void Function()? _onWriteStarted;

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

  /// The single listener of the wines of [cellarId], with metadata changes
  /// (NFR5.1, NFR2.4). Wines are sorted by name on the client.
  Stream<WinesSnapshot> watchWines(String cellarId) => _db
      .collection(winesPath(cellarId))
      .snapshots(includeMetadataChanges: true)
      .map(
        (snapshot) => WinesSnapshot(
          wines: [
            for (final doc in snapshot.docs)
              Wine.fromMap(doc.id, decodeDocument(doc.data())),
          ]..sort(Wine.compareByName),
          meta: SnapshotMeta(
            hasPendingWrites: snapshot.metadata.hasPendingWrites,
            isFromCache: snapshot.metadata.isFromCache,
          ),
        ),
      );

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

  Future<void> _onWriteError({
    required WriteTicket ticket,
    required String wineId,
    required String wineName,
    required Object error,
    required StackTrace stack,
    required List<String> sensitive,
    required bool journaled,
  }) async {
    try {
      // A reset happened after this write started: its outcome is obsolete.
      if (!await _isCurrentGeneration(ticket)) return;
      switch (classifyWriteError(error)) {
        case WriteErrorKind.rejected:
          if (journaled) await _ledger.markRejected(wineId);
          _bus.publish(WriteRejected(wineId: wineId, wineName: wineName));
          await _reporter.report(
            error,
            stack,
            reason: 'SyncRejected',
            sensitive: sensitive,
          );
        case WriteErrorKind.unauthenticated:
          _bus.publish(const SessionExpired());
        case WriteErrorKind.transient:
          _bus.publish(WriteFailed(wineId: wineId));
          await _reporter.report(
            error,
            stack,
            reason: 'WriteFailed',
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
