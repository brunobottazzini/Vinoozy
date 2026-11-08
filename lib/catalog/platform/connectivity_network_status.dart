// The catalog's network check with connectivity_plus (label-recognition
// BR6.1, tech-stack-decisions.md TS2): kept in platform/ so the core stays
// pure.

import 'package:connectivity_plus/connectivity_plus.dart';

import '../core/network_status.dart';

/// [CatalogNetworkStatus] backed by `connectivity_plus`.
class ConnectivityCatalogNetworkStatus implements CatalogNetworkStatus {
  ConnectivityCatalogNetworkStatus([Connectivity? connectivity])
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  /// True when any connection other than `none` is reported. When the
  /// platform cannot tell, Open Food Facts is tried as before the fix: a
  /// failure then counts as one (BR6.1, residual case).
  @override
  Future<bool> hasNetwork() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.any((result) => result != ConnectivityResult.none);
    } catch (_) {
      return true;
    }
  }
}
