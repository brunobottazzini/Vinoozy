// Fakes of freemium-plus Step 17 (unit-test-instructions.md, "Mock e stub"):
// the store (BillingClient), the backend check (PurchaseVerifier), the ad
// SDK (AdsGateway) and the ad slot backend (AdSlotClient). Nothing reaches
// Google Play, AdMob or the network.
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:vinoozy/ads/ad_slot_client.dart';
import 'package:vinoozy/ads/ads_gateway.dart';
import 'package:vinoozy/plan/billing/billing_client.dart';
import 'package:vinoozy/plan/billing/purchase_verifier.dart';

const PlusOffer monthlyOffer = PlusOffer(
  key: 'vinoozy_plus#monthly',
  period: PlusPeriod.monthly,
  price: '1,99 €',
  basePlanId: 'monthly',
);
const PlusOffer annualOffer = PlusOffer(
  key: 'vinoozy_plus#annual',
  period: PlusPeriod.annual,
  price: '14,99 €',
  basePlanId: 'annual',
);

class FakeBillingClient implements BillingClient {
  bool available = true;
  bool failQuery = false;
  List<PlusOffer> offers = const [monthlyOffer, annualOffer];
  int availabilityCalls = 0;
  int queryCalls = 0;
  int restoreCalls = 0;
  final List<PlusOffer> bought = [];
  final List<BillingPurchase> completed = [];
  final StreamController<List<BillingPurchase>> updates =
      StreamController<List<BillingPurchase>>.broadcast();

  @override
  Future<bool> isAvailable() async {
    availabilityCalls++;
    return available;
  }

  @override
  Future<List<PlusOffer>> queryOffers() async {
    queryCalls++;
    if (failQuery) throw StateError('store down');
    return offers;
  }

  @override
  Future<bool> buy(PlusOffer offer) async {
    bought.add(offer);
    return true;
  }

  @override
  Future<void> restore() async => restoreCalls++;

  @override
  Stream<List<BillingPurchase>> get purchases => updates.stream;

  @override
  Future<void> complete(BillingPurchase purchase) async =>
      completed.add(purchase);

  void emit(BillingPurchaseStatus status, {String token = 'token-1'}) =>
      updates.add([
        BillingPurchase(
          productId: plusProductId,
          status: status,
          token: token,
          needsCompletion: true,
        ),
      ]);
}

class FakePurchaseVerifier implements PurchaseVerifier {
  PurchaseVerificationResult result = PurchaseVerificationResult.verified;
  final List<String> tokens = [];

  @override
  Future<PurchaseVerificationResult> verify({
    required String productId,
    required String purchaseToken,
    String? basePlanId,
  }) async {
    tokens.add(purchaseToken);
    return result;
  }
}

class FakeBanner implements AdBannerHandle {
  FakeBanner(this.callbacks);

  final AdBannerCallbacks callbacks;
  bool disposed = false;

  @override
  Widget buildView() =>
      const SizedBox(key: Key('fake-banner'), width: 320, height: 50);

  @override
  Future<void> dispose() async => disposed = true;
}

/// Records every SDK call; the test drives the banner callbacks.
class FakeAdsGateway implements AdsGateway {
  bool consent = true;
  final List<String> calls = [];
  final List<FakeBanner> banners = [];

  @override
  Future<bool> gatherConsent() async {
    calls.add('consent');
    return consent;
  }

  @override
  Future<void> initialize() async => calls.add('initialize');

  @override
  AdBannerHandle loadBanner(AdBannerCallbacks callbacks) {
    calls.add('load');
    final banner = FakeBanner(callbacks);
    banners.add(banner);
    return banner;
  }
}

class FakeAdSlotClient implements AdSlotClient {
  AdSlotReservation answer = const AdSlotReservation(
    granted: true,
    reservationId: 'slot-1',
    day: '2026-11-10',
  );
  Object? failWith;
  int reserveCalls = 0;
  final List<AdOutcome> outcomes = [];

  @override
  Future<AdSlotReservation> reserve() async {
    reserveCalls++;
    final failure = failWith;
    if (failure != null) throw failure;
    return answer;
  }

  @override
  Future<void> logOutcome(
    AdSlotReservation reservation,
    AdOutcome outcome, {
    double? valueMicros,
    String? currencyCode,
    String? precision,
  }) async => outcomes.add(outcome);
}
