/// Metadata of a Firestore snapshot, without SDK types, used to compute the
/// sync state (BR3.2, NFR2.4).
class SnapshotMeta {
  const SnapshotMeta({
    required this.hasPendingWrites,
    required this.isFromCache,
  });

  /// At least one document of the snapshot has local writes not yet
  /// acknowledged by the server.
  final bool hasPendingWrites;

  /// The snapshot comes from the local cache, not from the server.
  final bool isFromCache;

  @override
  bool operator ==(Object other) =>
      other is SnapshotMeta &&
      other.hasPendingWrites == hasPendingWrites &&
      other.isFromCache == isFromCache;

  @override
  int get hashCode => Object.hash(hasPendingWrites, isFromCache);

  @override
  String toString() =>
      'SnapshotMeta(pending: $hasPendingWrites, fromCache: $isFromCache)';
}
