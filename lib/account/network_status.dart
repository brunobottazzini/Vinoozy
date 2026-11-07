import 'package:connectivity_plus/connectivity_plus.dart';

/// Whether the phone has any network. U1 uses it only to explain a failed
/// first sign-in (NFR2.5), and the sync state never depends on it. Since
/// u7-sharing it also enables the sharing commands, which need the server's
/// confirmation (BR1.11): [onChanged] re-enables them when the network
/// returns, [hasNetwork] is checked again before every operation.
abstract interface class NetworkStatus {
  Future<bool> hasNetwork();

  /// Emits whether there is a network every time the connection changes.
  Stream<bool> get onChanged;
}

/// [NetworkStatus] backed by `connectivity_plus`.
class ConnectivityNetworkStatus implements NetworkStatus {
  ConnectivityNetworkStatus([Connectivity? connectivity])
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  static bool _online(List<ConnectivityResult> results) =>
      results.any((result) => result != ConnectivityResult.none);

  @override
  Future<bool> hasNetwork() async {
    try {
      return _online(await _connectivity.checkConnectivity());
    } catch (_) {
      // Unknown state: let the sign-in try; its own error is shown if it fails.
      return true;
    }
  }

  @override
  Stream<bool> get onChanged =>
      _connectivity.onConnectivityChanged.map(_online).distinct();
}
