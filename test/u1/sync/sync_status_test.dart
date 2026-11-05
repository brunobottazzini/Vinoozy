import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/sync/snapshot_meta.dart';
import 'package:vinoozy/sync/sync_status.dart';

void main() {
  const cacheClean = SnapshotMeta(hasPendingWrites: false, isFromCache: true);
  const cachePending = SnapshotMeta(hasPendingWrites: true, isFromCache: true);
  const serverClean = SnapshotMeta(hasPendingWrites: false, isFromCache: false);
  const serverPending = SnapshotMeta(
    hasPendingWrites: true,
    isFromCache: false,
  );

  late SyncStatusTracker tracker;

  setUp(() => tracker = SyncStatusTracker());

  test('no pending writes means synced, whatever the source', () {
    expect(tracker.state, SyncState.synced);
    tracker.onSnapshot(SyncSource.wines, cacheClean);
    tracker.onSnapshot(SyncSource.wines, cacheClean);

    expect(tracker.state, SyncState.synced);
  });

  test('the first cache snapshot of a listener is not taken as offline', () {
    final update = tracker.onSnapshot(SyncSource.wines, cachePending);

    expect(update.state, SyncState.syncing);
    expect(update.backOnline, isFalse);
  });

  test('a later cache snapshot with pending writes is offline at once', () {
    tracker.onSnapshot(SyncSource.wines, serverClean);

    final update = tracker.onSnapshot(SyncSource.wines, cachePending);

    expect(update.state, SyncState.offline);
  });

  test('pending writes from the server side are "syncing"', () {
    tracker.onSnapshot(SyncSource.wines, serverClean);

    expect(
      tracker.onSnapshot(SyncSource.wines, serverPending).state,
      SyncState.syncing,
    );
  });

  test('cache to server is reported as "back online" and clears offline', () {
    tracker.onSnapshot(SyncSource.wines, serverClean);
    tracker.onSnapshot(SyncSource.wines, cachePending);

    final back = tracker.onSnapshot(SyncSource.wines, serverPending);
    expect(back.backOnline, isTrue);
    expect(back.state, SyncState.syncing);

    final drained = tracker.onSnapshot(SyncSource.wines, serverClean);
    expect(drained.backOnline, isFalse);
    expect(drained.state, SyncState.synced);
  });

  test('both sources count: pending in one, cache in the other', () {
    tracker.onSnapshot(SyncSource.cellar, serverClean);
    tracker.onSnapshot(SyncSource.wines, serverClean);
    tracker.onSnapshot(SyncSource.cellar, cacheClean);

    expect(
      tracker.onSnapshot(SyncSource.wines, serverPending).state,
      SyncState.offline,
    );
  });

  test('forget makes the next snapshot of a source a first one again', () {
    tracker.onSnapshot(SyncSource.wines, serverClean);
    tracker.forget(SyncSource.wines);

    final update = tracker.onSnapshot(SyncSource.wines, cachePending);

    expect(update.state, SyncState.syncing);
    expect(update.backOnline, isFalse);
  });

  test('SnapshotMeta has value equality', () {
    expect(
      const SnapshotMeta(hasPendingWrites: true, isFromCache: false),
      serverPending,
    );
    expect(serverPending.hashCode, isNot(cachePending.hashCode));
    expect(serverPending.toString(), contains('pending: true'));
  });
}
