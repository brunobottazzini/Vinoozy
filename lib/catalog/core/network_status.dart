// Whether the phone has a network, as the catalog sees it (label-recognition
// BR6.1, functional-spec.md D5). An interface, so lib/catalog/core stays
// pure: the implementation with connectivity_plus is in platform/.

/// The network check injected into `CatalogCoordinator`. Without a network
/// Open Food Facts is not called and nothing counts as a failure (FR5).
abstract interface class CatalogNetworkStatus {
  /// True when some network is connected. A network without Internet (a
  /// captive portal) still says true: that residual case counts as a
  /// failure, as before (BR6.1).
  Future<bool> hasNetwork();
}

/// The default of the coordinator when no check is injected: always
/// online, the behaviour before label-recognition.
class AssumeOnlineNetworkStatus implements CatalogNetworkStatus {
  const AssumeOnlineNetworkStatus();

  @override
  Future<bool> hasNetwork() async => true;
}
