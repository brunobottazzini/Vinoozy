import 'package:connectivity_plus/connectivity_plus.dart';

/// Whether the phone has any network, used only to explain a failed first
/// sign-in (NFR2.5). The sync state never depends on it.
abstract interface class NetworkStatus {
  Future<bool> hasNetwork();
}

/// [NetworkStatus] backed by `connectivity_plus`.
class ConnectivityNetworkStatus implements NetworkStatus {
  ConnectivityNetworkStatus([Connectivity? connectivity])
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  @override
  Future<bool> hasNetwork() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.any((result) => result != ConnectivityResult.none);
    } catch (_) {
      // Unknown state: let the sign-in try; its own error is shown if it fails.
      return true;
    }
  }
}
