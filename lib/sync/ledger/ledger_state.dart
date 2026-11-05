/// Data of the local ledger `ledger.v1` (security-design.md §3).
///
/// It holds only what NFR8.1 allows outside Firestore: the last uid, the
/// owner of the pending writes, a counter, and a journal of creations with
/// wine id, cellar id, name, owner and state.
library;

/// State of a journal entry.
enum JournalState {
  /// Written locally, not yet confirmed by the server.
  open,

  /// The server rejected it, or it never arrived: the user is told.
  rejected,
}

/// One wine creation tracked until the server confirms it (NFR6.3).
class JournalEntry {
  const JournalEntry({
    required this.wineId,
    required this.cellarId,
    required this.name,
    required this.ownerUid,
    this.state = JournalState.open,
    this.notices = 0,
  });

  factory JournalEntry.fromJson(Map<String, Object?> json) => JournalEntry(
    wineId: _string(json, 'wineId'),
    cellarId: _string(json, 'cellarId'),
    name: _string(json, 'name'),
    ownerUid: _string(json, 'ownerUid'),
    state: switch (json['state']) {
      'open' => JournalState.open,
      'rejected' => JournalState.rejected,
      final other => throw FormatException('unknown journal state $other'),
    },
    notices: _int(json, 'notices'),
  );

  final String wineId;
  final String cellarId;
  final String name;
  final String ownerUid;
  final JournalState state;

  /// How many times the "not saved" notice was shown; at 3 the entry goes.
  final int notices;

  JournalEntry copyWith({JournalState? state, int? notices}) => JournalEntry(
    wineId: wineId,
    cellarId: cellarId,
    name: name,
    ownerUid: ownerUid,
    state: state ?? this.state,
    notices: notices ?? this.notices,
  );

  Map<String, Object?> toJson() => {
    'wineId': wineId,
    'cellarId': cellarId,
    'name': name,
    'ownerUid': ownerUid,
    'state': state.name,
    'notices': notices,
  };
}

/// Account that owns the writes still queued in Firestore (BR1.4, NFR4.9).
class LedgerOwner {
  const LedgerOwner({
    required this.uid,
    required this.email,
    required this.seq,
  });

  factory LedgerOwner.fromJson(Map<String, Object?> json) => LedgerOwner(
    uid: _string(json, 'uid'),
    email: _string(json, 'email'),
    seq: _int(json, 'seq'),
  );

  final String uid;
  final String email;

  /// Incremented before every write; lets a background check notice that a
  /// new write started while it was waiting.
  final int seq;

  Map<String, Object?> toJson() => {'uid': uid, 'email': email, 'seq': seq};
}

/// The whole `ledger.v1` value.
class LedgerState {
  const LedgerState({
    this.lastUid,
    this.generation = 0,
    this.owner,
    this.journal = const [],
    this.resetPending = false,
  });

  static const LedgerState empty = LedgerState();

  /// Strict parser: any type mismatch throws [FormatException], so a corrupted
  /// value is detected instead of being half-read.
  factory LedgerState.fromJson(Map<String, Object?> json) {
    final rawOwner = json['owner'];
    final journal = json['journal'];
    final lastUid = json['lastUid'];
    final resetPending = json['resetPending'] ?? false;
    final Map<String, Object?>? owner = switch (rawOwner) {
      null => null,
      final Map<String, Object?> map => map,
      _ => throw const FormatException('owner must be an object'),
    };
    if (journal is! List) throw const FormatException('journal must be a list');
    if (lastUid != null && lastUid is! String) {
      throw const FormatException('lastUid must be a string');
    }
    if (resetPending is! bool) {
      throw const FormatException('resetPending must be a bool');
    }
    return LedgerState(
      lastUid: lastUid as String?,
      generation: _int(json, 'generation'),
      owner: owner == null ? null : LedgerOwner.fromJson(owner),
      journal: [
        for (final item in journal)
          if (item is Map<String, Object?>)
            JournalEntry.fromJson(item)
          else
            throw const FormatException('journal entries must be objects'),
      ],
      resetPending: resetPending,
    );
  }

  /// Uid of the last signed-in user on this phone (BR1.4).
  final String? lastUid;

  /// Incremented by every reset; write callbacks of an older generation are
  /// ignored (security-design.md §3).
  final int generation;
  final LedgerOwner? owner;
  final List<JournalEntry> journal;

  /// Set before a local reset and cleared once Firestore's persistence has
  /// been cleared (plan B of security-design.md §5).
  final bool resetPending;

  Iterable<JournalEntry> entriesOf(String uid) =>
      journal.where((entry) => entry.ownerUid == uid);

  Iterable<JournalEntry> openEntriesOf(String uid) =>
      entriesOf(uid).where((entry) => entry.state == JournalState.open);

  Iterable<JournalEntry> rejectedEntriesOf(String uid) =>
      entriesOf(uid).where((entry) => entry.state == JournalState.rejected);

  LedgerState copyWith({
    String? lastUid,
    int? generation,
    LedgerOwner? owner,
    bool clearOwner = false,
    List<JournalEntry>? journal,
    bool? resetPending,
  }) => LedgerState(
    lastUid: lastUid ?? this.lastUid,
    generation: generation ?? this.generation,
    owner: clearOwner ? null : owner ?? this.owner,
    journal: journal ?? this.journal,
    resetPending: resetPending ?? this.resetPending,
  );

  Map<String, Object?> toJson() => {
    'lastUid': lastUid,
    'generation': generation,
    'owner': owner?.toJson(),
    'journal': [for (final entry in journal) entry.toJson()],
    'resetPending': resetPending,
  };
}

String _string(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! String) throw FormatException('$key must be a string');
  return value;
}

int _int(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! int) throw FormatException('$key must be an int');
  return value;
}
