// ConnectivityCatalogNetworkStatus (label-recognition BR6.1, FR5) with a
// fake connectivity_plus platform: no real network state is read.
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/catalog/platform/connectivity_network_status.dart';

class _MockConnectivity extends Mock implements Connectivity {}

void main() {
  late _MockConnectivity connectivity;
  late ConnectivityCatalogNetworkStatus status;

  setUp(() {
    connectivity = _MockConnectivity();
    status = ConnectivityCatalogNetworkStatus(connectivity);
  });

  void reports(List<ConnectivityResult> results) =>
      when(() => connectivity.checkConnectivity())
          .thenAnswer((_) async => results);

  test('BR6.1 wifi or mobile data is a network', () async {
    reports([ConnectivityResult.wifi]);
    expect(await status.hasNetwork(), isTrue);
    reports([ConnectivityResult.none, ConnectivityResult.mobile]);
    expect(await status.hasNetwork(), isTrue);
  });

  test('FR5 "none" or nothing reported is no network', () async {
    reports([ConnectivityResult.none]);
    expect(await status.hasNetwork(), isFalse);
    reports([]);
    expect(await status.hasNetwork(), isFalse);
  });

  test('BR6.1 an unknown state lets Open Food Facts try, as before', () async {
    when(() => connectivity.checkConnectivity()).thenThrow(StateError('x'));
    expect(await status.hasNetwork(), isTrue);
  });
}
