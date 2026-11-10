import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'cloud_usage_meter.dart';

/// Adapters between the Firestore SDK and [CloudUsageMeter] (study §7.5):
/// they read the snapshot metadata and changes before the repositories map
/// the documents to domain models, where origin and changes are lost.

/// A query listener counted by [meter]: the same snapshots, with the meter
/// told about each of them. Listeners with the same [key] count once. With
/// no meter, [source] is returned as it is.
Stream<QuerySnapshot<Map<String, dynamic>>> meteredQuerySnapshots(
  Stream<QuerySnapshot<Map<String, dynamic>>> source,
  CloudUsageMeter? meter, {
  UsageScope scope = UsageScope.personal,
  String? key,
}) {
  if (meter == null) return source;
  return _metered(source, meter, scope, key, (counter, snapshot) {
    if (snapshot.metadata.isFromCache) {
      return counter.onQuerySnapshot(
        fromCache: true,
        documents: 0,
        changed: 0,
        removed: 0,
      );
    }
    var changed = 0;
    var removed = 0;
    for (final change in snapshot.docChanges) {
      // A change made by this phone and not yet confirmed is no server read.
      if (change.doc.metadata.hasPendingWrites) continue;
      if (change.type == DocumentChangeType.removed) {
        removed++;
      } else {
        changed++;
      }
    }
    counter.onQuerySnapshot(
      fromCache: false,
      documents: snapshot.docs.length,
      changed: changed,
      removed: removed,
    );
  });
}

/// A document listener counted by [meter]; see [meteredQuerySnapshots].
Stream<DocumentSnapshot<Map<String, dynamic>>> meteredDocumentSnapshots(
  Stream<DocumentSnapshot<Map<String, dynamic>>> source,
  CloudUsageMeter? meter, {
  UsageScope scope = UsageScope.personal,
  String? key,
}) {
  if (meter == null) return source;
  return _metered(
    source,
    meter,
    scope,
    key,
    (counter, snapshot) => counter.onDocumentSnapshot(
      exists: snapshot.exists,
      fromCache: snapshot.metadata.isFromCache,
      pending: snapshot.metadata.hasPendingWrites,
    ),
  );
}

/// A one-off query result: counted when it came from the server.
void recordQueryRead(
  CloudUsageMeter? meter,
  QuerySnapshot<Map<String, dynamic>> snapshot, {
  UsageScope scope = UsageScope.personal,
}) {
  if (meter == null || snapshot.metadata.isFromCache) return;
  meter.recordQuery(documents: snapshot.docs.length, scope: scope);
}

/// A one-off document read: counted when it came from the server.
void recordDocumentRead(
  CloudUsageMeter? meter,
  DocumentSnapshot<Map<String, dynamic>> snapshot, {
  UsageScope scope = UsageScope.personal,
}) {
  if (meter == null || snapshot.metadata.isFromCache) return;
  meter.recordDocument(exists: snapshot.exists, scope: scope);
}

Stream<T> _metered<T>(
  Stream<T> source,
  CloudUsageMeter meter,
  UsageScope scope,
  String? key,
  void Function(MeteredSubscription counter, T snapshot) count,
) {
  late final StreamController<T> controller;
  StreamSubscription<T>? subscription;
  MeteredSubscription? counter;
  controller = StreamController<T>(
    onListen: () {
      final current = meter.subscription(scope, key: key);
      counter = current;
      subscription = source.listen(
        (snapshot) {
          count(current, snapshot);
          controller.add(snapshot);
        },
        onError: controller.addError,
        onDone: () {
          current.close();
          controller.close();
        },
      );
    },
    onPause: () => subscription?.pause(),
    onResume: () => subscription?.resume(),
    onCancel: () {
      counter?.close();
      return subscription?.cancel();
    },
  );
  return controller.stream;
}
