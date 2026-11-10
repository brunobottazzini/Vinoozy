import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ad_slot_client.dart';
import 'ads_gateway.dart';

/// The ad SDK (FR7.1), created at start-up; null in tests that do not need
/// it, and then no ad is ever tried.
final adsGatewayProvider = Provider<AdsGateway?>((ref) => null);

/// The backend slot of the day (FR7.2), created at start-up.
final adSlotClientProvider = Provider<AdSlotClient?>((ref) => null);

/// Whether the Dashboard tab is the one shown by the home shell (FR7.2,
/// FR7.3): the ad slot lives only there.
final dashboardTabVisibleProvider = NotifierProvider<DashboardTabVisible, bool>(
  DashboardTabVisible.new,
);

class DashboardTabVisible extends Notifier<bool> {
  @override
  bool build() => true;

  void set(bool visible) {
    if (state != visible) state = visible;
  }
}
