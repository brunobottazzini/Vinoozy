import 'package:cloud_functions/cloud_functions.dart';

import '../../firebase/functions_config.dart';

/// Android package checked by the backend (freemium-plus FR3.3): the Google
/// Play package, `applicationId` of android/app/build.gradle.kts, not the
/// Kotlin namespace `com.vinoozy.vinoozy`.
const String plusPackageName = 'com.vinoozy.app';

/// The Plus subscription on Google Play, with the base plans `monthly` and
/// `annual` (FR3.1). Prices are always read from the store.
const String plusProductId = 'vinoozy_plus';

/// What the backend answered for a purchase (FR3.3).
enum PurchaseVerificationResult {
  /// Paid and verified: the backend wrote the entitlement, which reaches the
  /// app through its listener.
  verified,

  /// Google Play has not confirmed the payment yet: nothing is unlocked.
  pending,

  /// The token is not a valid Plus purchase of this app.
  invalid,

  /// The purchase already belongs to another account.
  ownedByAnotherAccount,

  /// The backend could not be reached or failed: try again later; the
  /// purchase stays on Google Play and is verified again then.
  unavailable,
}

/// The call to `verifyPurchase` (authenticated, App Check). Injected, so the
/// billing service is tested without the network.
abstract interface class PurchaseVerifier {
  Future<PurchaseVerificationResult> verify({
    required String productId,
    required String purchaseToken,
    String? basePlanId,
  });
}

/// [PurchaseVerifier] over the callable `verifyPurchase` (FR3.3).
///
/// Contract in functions/README.md. Request: `purchaseToken`, `productId`,
/// `packageName` (the base plan is read by the backend from Play). Answer:
/// `state` and `plusActive`; `pending` grants nothing. The token is never
/// logged (NFR6).
class FunctionsPurchaseVerifier implements PurchaseVerifier {
  FunctionsPurchaseVerifier(this._functions);

  final FirebaseFunctions Function() _functions;

  static const String callableName = 'verifyPurchase';

  @override
  Future<PurchaseVerificationResult> verify({
    required String productId,
    required String purchaseToken,
    String? basePlanId,
  }) async {
    try {
      final result = await _functions()
          .httpsCallable(callableName)
          .call<Object?>({
            'purchaseToken': purchaseToken,
            'productId': productId,
            'packageName': plusPackageName,
          });
      return verificationOf(result.data);
    } on FirebaseFunctionsException catch (error) {
      return verificationOfError(error.code, reasonOf(error.details));
    }
  }
}

/// `details.reason` of a callable error; null when absent.
String? reasonOf(Object? details) {
  final reason = callableMap(details)['reason'];
  return reason is String ? reason : null;
}

/// The answer of `verifyPurchase`, read leniently.
PurchaseVerificationResult verificationOf(Object? data) {
  final answer = callableMap(data);
  if (answer['plusActive'] == true) return PurchaseVerificationResult.verified;
  return switch (answer['state']) {
    'active' || 'grace' => PurchaseVerificationResult.verified,
    'pending' => PurchaseVerificationResult.pending,
    _ => PurchaseVerificationResult.invalid,
  };
}

/// A refused `verifyPurchase`, by `details.reason` first, then by code.
PurchaseVerificationResult verificationOfError(String code, [String? reason]) {
  switch (reason) {
    case 'TOKEN_IN_USE':
      return PurchaseVerificationResult.ownedByAnotherAccount;
    case 'INVALID_TOKEN' ||
        'WRONG_PACKAGE' ||
        'WRONG_PRODUCT' ||
        'PURCHASE_NOT_FOUND':
      return PurchaseVerificationResult.invalid;
    case 'PLAY_UNAVAILABLE' || 'INTERNAL' || 'UNAUTHENTICATED':
      return PurchaseVerificationResult.unavailable;
  }
  return switch (code) {
    'invalid-argument' ||
    'failed-precondition' ||
    'not-found' => PurchaseVerificationResult.invalid,
    // App Check or the session refused, the network, the server: the
    // purchase stays on Google Play and is verified again later.
    _ => PurchaseVerificationResult.unavailable,
  };
}
