import 'dart:async';
import 'dart:convert';

import '../../app/error_reporter.dart';
import 'key_value_store.dart';
import 'ledger_state.dart';

export 'ledger_state.dart';

/// Proof that [LocalLedger.beginWrite] completed: the Firestore write may
/// start, and its callback must carry this generation (security-design.md §3).
class WriteTicket {
  const WriteTicket({required this.generation, required this.seq});

  final int generation;
  final int seq;
}

/// Outcome of [LocalLedger.tryReleaseOwner].
enum ReleaseOutcome {
  /// The owner was cleared: another account may now sign in freely.
  released,

  /// A write started meanwhile (`seq` moved): check again.
  seqChanged,

  /// No owner was set.
  noOwner,

  /// The owner is another account.
  otherOwner,

  /// The owner still has open or rejected journal entries.
  entriesRemaining,
}

/// Raised when a write is attempted for an account other than the ledger
/// owner. AccountGate prevents this; reaching it is a programming error.
class LedgerOwnerConflict extends StateError {
  LedgerOwnerConflict() : super('pending writes belong to another account');
}

/// Local ledger of pending writes, stored as the single JSON value
/// `ledger.v1` (NFR4.9, NFR6.3, NFR8.1).
///
/// Every read-modify-write goes through one serial queue ([_mutate]), a chain
/// of futures in a single isolate, so concurrent callers (repository,
/// callbacks, SyncWatcher, UI) never lose each other's updates.
class LocalLedger {
  LocalLedger({required this._store, required this._reporter});

  static const String storageKey = 'ledger.v1';

  final KeyValueStore _store;
  final ErrorReporter _reporter;
  final StreamController<LedgerState> _changes =
      StreamController<LedgerState>.broadcast();

  Future<void> _tail = Future<void>.value();
  LedgerState? _state;

  /// Current state, then every change (used by the rejected-wine notice).
  Stream<LedgerState> watch() {
    late final StreamController<LedgerState> controller;
    StreamSubscription<LedgerState>? subscription;
    controller = StreamController<LedgerState>(
      onListen: () {
        subscription = _changes.stream.listen(
          controller.add,
          onError: controller.addError,
        );
        read().then(controller.add, onError: controller.addError);
      },
      onCancel: () => subscription?.cancel(),
    );
    return controller.stream;
  }

  /// Reads the state after every mutation queued so far.
  Future<LedgerState> read() => _enqueue(_load);

  /// Called before every Firestore write, which starts only after this
  /// completes: sets the owner if missing, increments `seq` and, for a
  /// creation, adds an `open` journal entry. Throws [LedgerOwnerConflict] if
  /// another account owns the pending writes, or the store's error.
  Future<WriteTicket> beginWrite({
    required String uid,
    required String email,
    JournalEntry? entry,
  }) {
    if (entry != null && entry.ownerUid != uid) {
      throw ArgumentError.value(entry.ownerUid, 'entry.ownerUid');
    }
    return _mutate((state) {
      final owner = state.owner;
      if (owner != null && owner.uid != uid) throw LedgerOwnerConflict();
      final nextOwner = LedgerOwner(
        uid: uid,
        email: owner?.email ?? email,
        seq: (owner?.seq ?? 0) + 1,
      );
      final journal = [
        for (final existing in state.journal)
          if (existing.wineId != entry?.wineId) existing,
        ?entry,
      ];
      final next = state.copyWith(owner: nextOwner, journal: journal);
      return (
        next,
        WriteTicket(generation: state.generation, seq: nextOwner.seq),
      );
    });
  }

  /// The server confirmed the wine: forget its entry.
  Future<void> markConfirmed(String wineId) =>
      _mutate((state) => (_without(state, wineId), null));

  /// The server rejected the wine: keep the entry to tell the user.
  Future<void> markRejected(String wineId) => _mutate(
    (state) => (
      _update(state, wineId, (e) => e.copyWith(state: JournalState.rejected)),
      null,
    ),
  );

  /// A rejected wine turned out to be still queued on the phone: track it
  /// again as `open`, so the next verification pass checks it.
  Future<void> reopen(String wineId) => _mutate(
    (state) => (
      _update(
        state,
        wineId,
        (e) => e.copyWith(state: JournalState.open, notices: 0),
      ),
      null,
    ),
  );

  /// The "not saved" notice was shown once more; at the third time the entry
  /// is removed. Then tries to release the owner.
  Future<void> noticeShown(String wineId) => _mutate((state) {
    final entry = _find(state, wineId);
    if (entry == null) return (state, null);
    final notices = entry.notices + 1;
    final next = notices >= maxNotices
        ? _without(state, wineId)
        : _update(state, wineId, (e) => e.copyWith(notices: notices));
    return (_releaseIfFree(next), null);
  });

  /// "Ignore" or "Add again": remove the entry, then try to release the owner.
  Future<void> dismiss(String wineId) =>
      _mutate((state) => (_releaseIfFree(_without(state, wineId)), null));

  /// Clears the owner only if `owner.seq == seqAtStart`, the owner is [uid],
  /// and no journal entry of [uid] remains (security-design.md §3).
  Future<ReleaseOutcome> tryReleaseOwner(int seqAtStart, String uid) =>
      _mutate((state) {
        final owner = state.owner;
        if (owner == null) return (state, ReleaseOutcome.noOwner);
        if (owner.uid != uid) return (state, ReleaseOutcome.otherOwner);
        if (owner.seq != seqAtStart) return (state, ReleaseOutcome.seqChanged);
        if (state.entriesOf(uid).isNotEmpty) {
          return (state, ReleaseOutcome.entriesRemaining);
        }
        return (state.copyWith(clearOwner: true), ReleaseOutcome.released);
      });

  /// Local reset (NFR4.10): empties owner and journal, records [newUid] as the
  /// last user and increments `generation`, so callbacks of earlier writes are
  /// ignored. `resetPending` is kept until the reset is completed.
  Future<void> reset(String newUid) => _mutate(
    (state) => (
      LedgerState(
        lastUid: newUid,
        generation: state.generation + 1,
        resetPending: state.resetPending,
      ),
      null,
    ),
  );

  Future<void> setLastUid(String uid) =>
      _mutate((state) => (state.copyWith(lastUid: uid), null));

  Future<void> setResetPending(bool pending) =>
      _mutate((state) => (state.copyWith(resetPending: pending), null));

  /// Current generation, read through the queue.
  Future<int> generation() async => (await read()).generation;

  static const int maxNotices = 3;

  Future<T> _enqueue<T>(Future<T> Function() operation) {
    final result = _tail.then((_) => operation());
    _tail = result.then<void>((_) {}, onError: (Object _) {});
    return result;
  }

  Future<T> _mutate<T>((LedgerState, T) Function(LedgerState state) change) =>
      _enqueue(() async {
        final state = await _load();
        final (next, result) = change(state);
        if (!identical(next, state)) await _save(next);
        return result;
      });

  Future<LedgerState> _load() async {
    final cached = _state;
    if (cached != null) return cached;
    final raw = await _store.read(storageKey);
    if (raw == null) return _state = LedgerState.empty;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, Object?>) {
        throw const FormatException('ledger.v1 is not a JSON object');
      }
      return _state = LedgerState.fromJson(decoded);
    } on FormatException catch (error, stack) {
      await _reporter.report(error, stack, reason: 'LedgerCorrupted');
      await _save(LedgerState.empty);
      return LedgerState.empty;
    }
  }

  /// Persists first, then updates the in-memory copy, so a failed write leaves
  /// memory and disk consistent.
  Future<void> _save(LedgerState next) async {
    await _store.write(storageKey, jsonEncode(next.toJson()));
    _state = next;
    _changes.add(next);
  }

  static JournalEntry? _find(LedgerState state, String wineId) {
    for (final entry in state.journal) {
      if (entry.wineId == wineId) return entry;
    }
    return null;
  }

  static LedgerState _without(LedgerState state, String wineId) =>
      _find(state, wineId) == null
      ? state
      : state.copyWith(
          journal: [
            for (final entry in state.journal)
              if (entry.wineId != wineId) entry,
          ],
        );

  static LedgerState _update(
    LedgerState state,
    String wineId,
    JournalEntry Function(JournalEntry entry) change,
  ) => _find(state, wineId) == null
      ? state
      : state.copyWith(
          journal: [
            for (final entry in state.journal)
              entry.wineId == wineId ? change(entry) : entry,
          ],
        );

  /// In-queue release used after dismiss/noticeShown: same checks as
  /// [tryReleaseOwner] with the current `seq`, atomic with the change.
  static LedgerState _releaseIfFree(LedgerState state) {
    final owner = state.owner;
    if (owner == null || state.entriesOf(owner.uid).isNotEmpty) return state;
    return state.copyWith(clearOwner: true);
  }
}
