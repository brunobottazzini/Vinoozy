import 'dart:async';

import '../app/error_reporter.dart';
import 'ledger/local_ledger.dart';
import 'sync_gateway.dart';

/// A journaled creation that never reached the server; recorded as the
/// non-fatal `SyncRejected` event (monitoring-design.md).
class WineNotOnServer implements Exception {
  const WineNotOnServer(this.check);

  final ServerCheck check;

  @override
  String toString() => 'WineNotOnServer: ${check.name}';
}

/// How one verification pass ended.
enum _RunOutcome { done, seqChanged, aborted }

/// Background verification of pending writes (security-design.md §4, NFR6.3).
///
/// Triggers: start after AccountGate, every write, network back. Only one run
/// at a time: a trigger during a run marks it "to repeat". A run takes the
/// journal entries present at its start, waits for the Firestore queue (30 s
/// timeout), then checks only those entries on the server (10 s timeout
/// each): an open entry found missing is re-checked after a second drain
/// before it becomes rejected, and a rejected entry found on the server is
/// confirmed. Then it tries to release the ledger owner; if a new write moved
/// `seq` meanwhile it repeats at once, at most 3 times in a row, then waits
/// for the next trigger. No tight loops.
class SyncWatcher {
  SyncWatcher({
    required this._ledger,
    required this._gateway,
    required this._reporter,
    this._drainTimeout = const Duration(seconds: 30),
    this._serverTimeout = const Duration(seconds: 10),
    this._maxImmediateRepeats = 3,
  });

  final LocalLedger _ledger;
  final SyncGateway _gateway;
  final ErrorReporter _reporter;
  final Duration _drainTimeout;
  final Duration _serverTimeout;
  final int _maxImmediateRepeats;

  String? _uid;
  int _epoch = 0;
  bool _running = false;
  bool _rerunRequested = false;
  Future<void> _current = Future<void>.value();

  bool get isRunning => _running;

  /// Starts watching for [uid] and runs a first pass.
  Future<void> start(String uid) {
    _uid = uid;
    _epoch++;
    return trigger();
  }

  /// Stops watching (sign-out, reset). A pass in progress ends at its next
  /// step without touching the ledger.
  void stop() {
    _uid = null;
    _epoch++;
    _rerunRequested = false;
  }

  /// Asks for a pass. Returns the future of the pass that will serve it.
  Future<void> trigger() {
    if (_uid == null) return Future<void>.value();
    if (_running) {
      _rerunRequested = true;
      return _current;
    }
    _running = true;
    return _current = _loop().whenComplete(() => _running = false);
  }

  Future<void> _loop() async {
    final epoch = _epoch;
    var immediateRepeats = 0;
    while (true) {
      _rerunRequested = false;
      final outcome = await _runOnce(epoch);
      if (epoch != _epoch) return;
      if (outcome == _RunOutcome.seqChanged &&
          immediateRepeats < _maxImmediateRepeats) {
        immediateRepeats++;
        continue;
      }
      if (_rerunRequested) {
        immediateRepeats = 0;
        continue;
      }
      return;
    }
  }

  Future<_RunOutcome> _runOnce(int epoch) async {
    final uid = _uid;
    if (uid == null) return _RunOutcome.done;
    try {
      final before = await _ledger.read();
      final owner = before.owner;
      if (owner == null || owner.uid != uid) return _RunOutcome.done;
      final seqAtStart = owner.seq;
      // Only the entries journaled before the drain started are verified:
      // their writes were issued before waitForPendingWrites() was called, so
      // the drain covers them. Later entries stay open for the next pass,
      // which the `seq` change below starts at once (review R-01).
      final covered = {for (final e in before.entriesOf(uid)) e.wineId};
      if (!await _drain(uid)) return _RunOutcome.aborted;
      if (epoch != _epoch) return _RunOutcome.aborted;

      final toVerify = (await _ledger.read())
          .entriesOf(uid)
          .where((entry) => covered.contains(entry.wineId))
          .toList();
      for (final entry in toVerify) {
        final check = entry.state == JournalState.open
            ? await _checkOpen(entry, uid, epoch)
            : await _check(entry, uid);
        if (epoch != _epoch || check == ServerCheck.unavailable) {
          return _RunOutcome.aborted;
        }
        await _apply(entry, check, uid);
      }

      return await _release(seqAtStart, uid);
    } catch (error, stack) {
      await _reporter.report(
        error,
        stack,
        reason: 'SyncWatcherFailed',
        sensitive: [uid],
      );
      return _RunOutcome.aborted;
    }
  }

  Future<_RunOutcome> _release(int seqAtStart, String uid) async {
    final release = await _ledger.tryReleaseOwner(seqAtStart, uid);
    return release == ReleaseOutcome.seqChanged
        ? _RunOutcome.seqChanged
        : _RunOutcome.done;
  }

  /// An open entry is declared missing only after a second drain and a
  /// second server read, so a write still in flight is never rejected.
  Future<ServerCheck?> _checkOpen(
    JournalEntry entry,
    String uid,
    int epoch,
  ) async {
    final first = await _check(entry, uid);
    if (first != ServerCheck.missing) return first;
    if (!await _drain(uid) || epoch != _epoch) return ServerCheck.unavailable;
    return _check(entry, uid);
  }

  /// "Add again" on a rejected wine (review R-01). Returns true when the wine
  /// turned out not to be lost, so no new wine must be created:
  /// - in the local cache and acknowledged, or found on the server: the entry
  ///   is confirmed and the notice goes;
  /// - in the local cache with its write still queued: the entry is open
  ///   again and a verification pass is triggered.
  /// Returns false (the caller dismisses the entry and opens the form) when
  /// the wine is neither on the phone nor on the server, or the server cannot
  /// be reached and the phone does not have it.
  Future<bool> reconcileRejected(JournalEntry entry) async {
    final uid = entry.ownerUid;
    final local = await _checkLocal(entry, uid);
    switch (local) {
      case LocalCheck.synced:
        await _ledger.markConfirmed(entry.wineId);
        return true;
      case LocalCheck.pending:
        await _ledger.reopen(entry.wineId);
        unawaited(trigger());
        return true;
      case LocalCheck.absent || null:
        if (await _check(entry, uid) == ServerCheck.exists) {
          await _ledger.markConfirmed(entry.wineId);
          return true;
        }
        return false;
    }
  }

  /// Null means "could not read the cache": reported, treated as absent.
  Future<LocalCheck?> _checkLocal(JournalEntry entry, String uid) async {
    try {
      return await _gateway
          .checkLocal(cellarId: entry.cellarId, wineId: entry.wineId)
          .timeout(_serverTimeout);
    } catch (error, stack) {
      await _reporter.report(
        error,
        stack,
        reason: 'LocalCheckFailed',
        sensitive: [uid, entry.name],
      );
      return null;
    }
  }

  /// Waits for the Firestore queue. False when it timed out or failed: the
  /// pass ends and the single-run slot is freed.
  Future<bool> _drain(String uid) async {
    try {
      await _gateway.waitForPendingWrites().timeout(_drainTimeout);
      return true;
    } on TimeoutException {
      return false;
    } catch (error, stack) {
      await _reporter.report(
        error,
        stack,
        reason: 'PendingWritesWaitFailed',
        sensitive: [uid],
      );
      return false;
    }
  }

  /// Null means "other error": reported, the entry stays open.
  Future<ServerCheck?> _check(JournalEntry entry, String uid) async {
    try {
      return await _gateway
          .checkWine(cellarId: entry.cellarId, wineId: entry.wineId)
          .timeout(_serverTimeout);
    } on TimeoutException {
      return ServerCheck.unavailable;
    } catch (error, stack) {
      await _reporter.report(
        error,
        stack,
        reason: 'ServerCheckFailed',
        sensitive: [uid, entry.name],
      );
      return null;
    }
  }

  Future<void> _apply(
    JournalEntry entry,
    ServerCheck? check,
    String uid,
  ) async {
    // A rejected entry is re-checked only to clear a stale notice: if the
    // wine arrived after all, it is confirmed; otherwise it stays as it is.
    if (entry.state == JournalState.rejected) {
      if (check == ServerCheck.exists) {
        await _ledger.markConfirmed(entry.wineId);
      }
      return;
    }
    switch (check) {
      case ServerCheck.exists:
        await _ledger.markConfirmed(entry.wineId);
      case ServerCheck.missing || ServerCheck.denied:
        await _ledger.markRejected(entry.wineId);
        await _reporter.report(
          WineNotOnServer(check!),
          StackTrace.current,
          reason: 'SyncRejected',
          sensitive: [uid, entry.name],
        );
      case ServerCheck.unavailable || null:
        break;
    }
  }
}
