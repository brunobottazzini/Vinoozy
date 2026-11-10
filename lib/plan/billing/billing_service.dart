import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/error_reporter.dart';
import '../../app/providers.dart';
import 'billing_client.dart';
import 'purchase_verifier.dart';

/// The store (Google Play), created at start-up; null in tests that do not
/// need it.
final billingClientProvider = Provider<BillingClient?>((ref) => null);

/// The backend check of a purchase (`verifyPurchase`), created at start-up.
final purchaseVerifierProvider = Provider<PurchaseVerifier?>((ref) => null);

/// Where the Plus purchase is (freemium-plus FR3.1-FR3.3).
enum BillingPhase {
  /// Nothing asked yet.
  idle,

  /// Reading the offers from the store.
  loading,

  /// The offers with their store prices are known.
  ready,

  /// The store did not answer: an error, never invented prices (FR3.1).
  unavailable,

  /// The Google Play purchase flow is open.
  purchasing,

  /// Google Play has not confirmed the payment: nothing is unlocked (FR3.3).
  pending,

  /// The backend is verifying the purchase.
  verifying,

  /// The backend verified it: Plus arrives through the entitlement listener.
  verified,

  /// The purchase or its verification failed; see [BillingState.problem].
  failed,
}

/// Why a purchase failed.
enum BillingProblem {
  purchaseFailed,
  invalidPurchase,
  ownedByAnotherAccount,
  verificationUnavailable,
}

class BillingState {
  const BillingState({
    this.phase = BillingPhase.idle,
    this.offers = const [],
    this.problem,
  });

  final BillingPhase phase;
  final List<PlusOffer> offers;
  final BillingProblem? problem;

  BillingState copyWith({BillingPhase? phase, BillingProblem? problem}) =>
      BillingState(
        phase: phase ?? this.phase,
        offers: offers,
        problem: problem,
      );
}

/// The Plus purchase: offers from the store, the purchase flow, and every
/// purchase update sent to the backend before anything is unlocked
/// (freemium-plus FR3.1-FR3.3, study §5.2).
///
/// - A `pending` purchase unlocks nothing.
/// - A purchased or restored Plus is sent to `verifyPurchase`; the store is
///   told it was handled only after the backend verified it, so a purchase
///   that is not verified is never acknowledged by the phone.
/// - Plus itself arrives through the entitlement listener, written by the
///   backend: this service never grants anything.
final billingServiceProvider = NotifierProvider<BillingService, BillingState>(
  BillingService.new,
);

class BillingService extends Notifier<BillingState> {
  StreamSubscription<List<BillingPurchase>>? _purchases;
  String? _basePlanInFlight;

  BillingClient? get _client => ref.read(billingClientProvider);
  PurchaseVerifier? get _verifier => ref.read(purchaseVerifierProvider);
  ErrorReporter get _reporter => ref.read(errorReporterProvider);

  @override
  BillingState build() {
    ref.onDispose(() => _purchases?.cancel());
    return const BillingState();
  }

  /// Reads the offers and starts listening to the purchase updates. Called
  /// only when purchases are on (`purchasesEnabled`, FR3.5).
  Future<void> load() async {
    final client = _client;
    if (client == null) {
      state = const BillingState(phase: BillingPhase.unavailable);
      return;
    }
    _purchases ??= client.purchases.listen(
      (updates) => unawaited(_onPurchases(updates)),
      onError: (Object error, StackTrace stack) =>
          _reporter.report(error, stack, reason: 'BillingStreamFailed'),
    );
    state = const BillingState(phase: BillingPhase.loading);
    try {
      if (!await client.isAvailable()) {
        state = const BillingState(phase: BillingPhase.unavailable);
        return;
      }
      final offers = await client.queryOffers();
      if (!ref.mounted) return;
      state = BillingState(
        phase: offers.isEmpty ? BillingPhase.unavailable : BillingPhase.ready,
        offers: offers,
      );
    } catch (error, stack) {
      await _reporter.report(error, stack, reason: 'BillingQueryFailed');
      if (ref.mounted) {
        state = const BillingState(phase: BillingPhase.unavailable);
      }
    }
  }

  /// "Subscribe" on an offer: opens the Google Play flow.
  Future<void> buy(PlusOffer offer) async {
    final client = _client;
    if (client == null || state.phase == BillingPhase.purchasing) return;
    _basePlanInFlight = offer.basePlanId;
    state = state.copyWith(phase: BillingPhase.purchasing);
    try {
      if (!await client.buy(offer)) {
        state = state.copyWith(
          phase: BillingPhase.failed,
          problem: BillingProblem.purchaseFailed,
        );
      }
    } catch (error, stack) {
      await _reporter.report(error, stack, reason: 'BillingBuyFailed');
      state = state.copyWith(
        phase: BillingPhase.failed,
        problem: BillingProblem.purchaseFailed,
      );
    }
  }

  /// "Restore purchases" (FR3.2): the owned purchases come back on the
  /// purchase stream and are verified like new ones.
  Future<void> restore() async {
    final client = _client;
    if (client == null) return;
    try {
      await client.restore();
    } catch (error, stack) {
      await _reporter.report(error, stack, reason: 'BillingRestoreFailed');
      state = state.copyWith(
        phase: BillingPhase.failed,
        problem: BillingProblem.purchaseFailed,
      );
    }
  }

  Future<void> _onPurchases(List<BillingPurchase> updates) async {
    for (final purchase in updates) {
      if (purchase.productId != plusProductId) continue;
      await _onPurchase(purchase);
    }
  }

  Future<void> _onPurchase(BillingPurchase purchase) async {
    switch (purchase.status) {
      case BillingPurchaseStatus.pending:
        _set(BillingPhase.pending);
      case BillingPurchaseStatus.canceled:
        _set(state.offers.isEmpty ? BillingPhase.idle : BillingPhase.ready);
      case BillingPurchaseStatus.error:
        _set(BillingPhase.failed, BillingProblem.purchaseFailed);
      case BillingPurchaseStatus.purchased || BillingPurchaseStatus.restored:
        await _verify(purchase);
    }
  }

  Future<void> _verify(BillingPurchase purchase) async {
    final verifier = _verifier;
    if (verifier == null) {
      _set(BillingPhase.failed, BillingProblem.verificationUnavailable);
      return;
    }
    _set(BillingPhase.verifying);
    final PurchaseVerificationResult result;
    try {
      result = await verifier.verify(
        productId: purchase.productId,
        purchaseToken: purchase.token,
        basePlanId: _basePlanInFlight,
      );
    } catch (error, stack) {
      // Never the token in the report (NFR6).
      await _reporter.report(error, stack, reason: 'BillingVerifyFailed');
      _set(BillingPhase.failed, BillingProblem.verificationUnavailable);
      return;
    }
    switch (result) {
      case PurchaseVerificationResult.verified:
        if (purchase.needsCompletion) await _complete(purchase);
        _set(BillingPhase.verified);
      case PurchaseVerificationResult.pending:
        _set(BillingPhase.pending);
      case PurchaseVerificationResult.invalid:
        _set(BillingPhase.failed, BillingProblem.invalidPurchase);
      case PurchaseVerificationResult.ownedByAnotherAccount:
        _set(BillingPhase.failed, BillingProblem.ownedByAnotherAccount);
      case PurchaseVerificationResult.unavailable:
        _set(BillingPhase.failed, BillingProblem.verificationUnavailable);
    }
  }

  Future<void> _complete(BillingPurchase purchase) async {
    try {
      await _client?.complete(purchase);
    } catch (error, stack) {
      // The backend already acknowledged it on Google Play (FR3.3).
      await _reporter.report(error, stack, reason: 'BillingCompleteFailed');
    }
  }

  void _set(BillingPhase phase, [BillingProblem? problem]) {
    if (!ref.mounted) return;
    state = state.copyWith(phase: phase, problem: problem);
  }
}
