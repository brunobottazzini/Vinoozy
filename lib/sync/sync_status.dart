import 'snapshot_meta.dart';

/// What the offline banner shows (functional-spec.md, "Stato della
/// sincronizzazione").
enum SyncState {
  /// No pending writes: banner hidden.
  synced,

  /// Pending writes and the SDK is talking to the server: "Syncing".
  syncing,

  /// Pending writes and snapshots come from the cache: "Offline - sync
  /// pending".
  offline,
}

/// The two listeners that feed the sync state (performance-design.md).
enum SyncSource { cellar, wines }

/// Result of feeding one snapshot to [SyncStatusTracker].
class SyncUpdate {
  const SyncUpdate({required this.state, required this.backOnline});

  final SyncState state;

  /// A source moved from cache to server snapshots: the network is back and
  /// SyncWatcher should run (security-design.md §4).
  final bool backOnline;
}

/// Computes [SyncState] from the metadata of the cellar and wines snapshots
/// (BR3.2, NFR2.4), without opening any listener of its own (NFR5.1).
///
/// - pending: at least one source's latest snapshot has pending writes;
/// - offline: pending and a source's latest snapshot is from the cache;
/// - syncing: pending otherwise.
///
/// The first snapshot of each listener always comes from the cache when the
/// listener opens, even online: its `isFromCache` is ignored, so the banner
/// does not flash "offline" at start-up. Every later snapshot is followed at
/// once, with no extra delay (NFR Design review 2).
class SyncStatusTracker {
  final Map<SyncSource, SnapshotMeta> _latest = {};
  final Map<SyncSource, bool> _effectiveFromCache = {};

  SyncState get state {
    final pending = _latest.values.any((meta) => meta.hasPendingWrites);
    if (!pending) return SyncState.synced;
    final offline = _effectiveFromCache.values.any((fromCache) => fromCache);
    return offline ? SyncState.offline : SyncState.syncing;
  }

  SyncUpdate onSnapshot(SyncSource source, SnapshotMeta meta) {
    final previous = _latest[source];
    final isFirst = previous == null;
    final backOnline = !isFirst && previous.isFromCache && !meta.isFromCache;
    _latest[source] = meta;
    _effectiveFromCache[source] = isFirst ? false : meta.isFromCache;
    return SyncUpdate(state: state, backOnline: backOnline);
  }

  /// Forget a source whose listener was closed; its next snapshot counts as
  /// the first one again.
  void forget(SyncSource source) {
    _latest.remove(source);
    _effectiveFromCache.remove(source);
  }
}
