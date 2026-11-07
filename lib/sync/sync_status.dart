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

/// The sources of the sync state (performance-design.md): the cellar and
/// wines listeners, and since u4-cellar the drinks, whose pending state comes
/// from `PendingWritesProbe` rather than from a snapshot (security-design.md
/// §4 of u4-cellar).
enum SyncSource { cellar, wines, drinkingRecords }

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
  final Set<SyncSource> _pendingOnly = {};

  SyncState get state {
    final pending =
        _pendingOnly.isNotEmpty ||
        _latest.values.any((meta) => meta.hasPendingWrites);
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

  /// Marks [source] as having writes waiting for the server, or not
  /// (u4-cellar NFR6.6). Only the "pending" part changes: whether the app
  /// is offline still comes from the snapshots, and this never counts as a
  /// move from cache to server, so it never starts SyncWatcher.
  SyncState setPending(SyncSource source, bool pending) {
    if (pending) {
      _pendingOnly.add(source);
    } else {
      _pendingOnly.remove(source);
    }
    return state;
  }

  /// Forget a source whose listener was closed; its next snapshot counts as
  /// the first one again.
  void forget(SyncSource source) {
    _latest.remove(source);
    _effectiveFromCache.remove(source);
    _pendingOnly.remove(source);
  }
}
