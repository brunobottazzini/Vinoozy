import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

import 'purchase_verifier.dart';

/// The billing period of a Plus base plan (freemium-plus FR3.1).
enum PlusPeriod { monthly, annual, unknown }

/// One way to buy Plus as Google Play offers it: a base plan with its price
/// in the local currency, read from the store and never written in the code
/// (FR3.1).
class PlusOffer {
  const PlusOffer({
    required this.key,
    required this.period,
    required this.price,
    this.basePlanId,
  });

  /// Identifies the offer for [BillingClient.buy].
  final String key;
  final PlusPeriod period;

  /// The price as the store formats it (e.g. "1,99 €").
  final String price;

  /// `monthly` or `annual` on Google Play; null when the store did not say.
  final String? basePlanId;
}

/// The state of a purchase as the store reports it.
enum BillingPurchaseStatus { pending, purchased, restored, canceled, error }

/// A purchase update of the store.
class BillingPurchase {
  const BillingPurchase({
    required this.productId,
    required this.status,
    required this.token,
    required this.needsCompletion,
    this.native,
  });

  final String productId;
  final BillingPurchaseStatus status;

  /// The purchase token, sent only to `verifyPurchase`; never logged
  /// (NFR6).
  final String token;

  /// The store waits for [BillingClient.complete].
  final bool needsCompletion;

  /// The plugin's own object, for [BillingClient.complete].
  final Object? native;
}

/// The store, behind an interface so the billing service is tested without
/// Google Play (unit-test-instructions.md, "Mock e stub").
abstract interface class BillingClient {
  Future<bool> isAvailable();

  /// The Plus offers; throws when the store cannot answer.
  Future<List<PlusOffer>> queryOffers();

  /// Opens the Google Play purchase flow; false when it could not start.
  Future<bool> buy(PlusOffer offer);

  /// "Restore purchases": the store sends the owned purchases again on
  /// [purchases].
  Future<void> restore();

  Stream<List<BillingPurchase>> get purchases;

  /// Tells the store the purchase was handled (the backend acknowledges it
  /// on Google Play, FR3.3).
  Future<void> complete(BillingPurchase purchase);
}

/// [BillingClient] over the `in_app_purchase` plugin (plan decision D6).
/// The plugin is reached only when a method is called: with purchases off
/// (`purchasesEnabled=false`) nothing touches the store.
class InAppPurchaseBillingClient implements BillingClient {
  InAppPurchaseBillingClient({InAppPurchase Function()? store})
    : _store = store ?? (() => InAppPurchase.instance);

  final InAppPurchase Function() _store;
  final Map<String, ProductDetails> _details = {};

  @override
  Future<bool> isAvailable() => _store().isAvailable();

  @override
  Future<List<PlusOffer>> queryOffers() async {
    final response = await _store().queryProductDetails({plusProductId});
    final error = response.error;
    if (error != null) throw StateError('store error ${error.code}');
    _details.clear();
    final offers = <PlusOffer>[];
    for (final (index, details) in response.productDetails.indexed) {
      final basePlanId = _basePlanIdOf(details);
      final key = '${details.id}#${basePlanId ?? index}';
      _details[key] = details;
      offers.add(
        PlusOffer(
          key: key,
          period: switch (basePlanId) {
            'monthly' => PlusPeriod.monthly,
            'annual' => PlusPeriod.annual,
            _ => PlusPeriod.unknown,
          },
          price: details.price,
          basePlanId: basePlanId,
        ),
      );
    }
    return offers;
  }

  /// The base plan of an Android subscription offer. The type that carries
  /// it belongs to `in_app_purchase_android`, which this app does not depend
  /// on directly: read it dynamically and fall back to null.
  static String? _basePlanIdOf(ProductDetails details) {
    try {
      final dynamic android = details;
      final int? index = android.subscriptionIndex as int?;
      final List<dynamic>? offers =
          android.productDetails.subscriptionOfferDetails as List<dynamic>?;
      if (index == null || offers == null || index >= offers.length) {
        return null;
      }
      return offers[index].basePlanId as String?;
    } on Object {
      return null;
    }
  }

  @override
  Future<bool> buy(PlusOffer offer) {
    final details = _details[offer.key];
    if (details == null) return Future.value(false);
    return _store().buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: details),
    );
  }

  @override
  Future<void> restore() => _store().restorePurchases();

  @override
  Stream<List<BillingPurchase>> get purchases => _store().purchaseStream.map(
    (updates) => [for (final update in updates) _purchaseOf(update)],
  );

  static BillingPurchase _purchaseOf(PurchaseDetails details) =>
      BillingPurchase(
        productId: details.productID,
        status: switch (details.status) {
          PurchaseStatus.pending => BillingPurchaseStatus.pending,
          PurchaseStatus.purchased => BillingPurchaseStatus.purchased,
          PurchaseStatus.restored => BillingPurchaseStatus.restored,
          PurchaseStatus.canceled => BillingPurchaseStatus.canceled,
          PurchaseStatus.error => BillingPurchaseStatus.error,
        },
        token: details.verificationData.serverVerificationData,
        needsCompletion: details.pendingCompletePurchase,
        native: details,
      );

  @override
  Future<void> complete(BillingPurchase purchase) async {
    final native = purchase.native;
    if (native is PurchaseDetails) await _store().completePurchase(native);
  }
}
