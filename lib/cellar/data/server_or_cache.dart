import 'package:cloud_firestore/cloud_firestore.dart';

/// A query read with where it came from.
class QueryRead {
  const QueryRead(this.snapshot, {required this.fromServer});

  final QuerySnapshot<Map<String, dynamic>> snapshot;

  /// False when the server did not answer within the timeout and the cache
  /// was read instead (performance-design.md §1).
  final bool fromServer;
}

/// Reads [query] from the server within [timeout], else from the local cache
/// (BR1.4, BR1.12, BR1.14: "dal server con la rete, dalla cache senza").
///
/// The SDK default would wait for the backend for several seconds before
/// falling back to the cache; the timeout keeps a save or an "Undo" quick
/// offline. An error of the cache read reaches the caller.
Future<QueryRead> readServerOrCache(
  Query<Map<String, dynamic>> query,
  Duration timeout,
) async {
  try {
    final snapshot = await query
        .get(const GetOptions(source: Source.server))
        .timeout(timeout);
    return QueryRead(snapshot, fromServer: true);
  } catch (_) {
    // Offline, slow or refused by the server: the cache answers instead.
    final snapshot = await query.get(const GetOptions(source: Source.cache));
    return QueryRead(snapshot, fromServer: false);
  }
}
