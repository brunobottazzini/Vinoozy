import 'package:cloud_firestore/cloud_firestore.dart';

/// Network switch for the end-to-end tests (`E2E=true` builds only,
/// cicd-pipeline.md §1). Firestore behaves as offline: writes stay queued and
/// snapshots come from the cache with pending writes, while the emulators on
/// 10.0.2.2 stay reachable for the test's own checks.
class TestNetworkControl {
  TestNetworkControl(this._db);

  final FirebaseFirestore Function() _db;

  Future<void> disableNetwork() => _db().disableNetwork();

  Future<void> enableNetwork() => _db().enableNetwork();
}
