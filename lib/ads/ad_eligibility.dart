/// The state the ad decision reads (study §7.7, freemium-plus FR7.2).
class AdEligibilityInput {
  const AdEligibilityInput({
    required this.adsEnabled,
    required this.stateVerified,
    required this.plusActive,
    required this.aboveThreshold,
  });

  /// `config/policy.adsEnabled`.
  final bool adsEnabled;

  /// Account state, server time, counters and entitlement are verified: an
  /// uncertain state never leads to ads (NFR4, study §7.6).
  final bool stateVerified;

  /// A valid Plus (or the developer's test Plus): never ads.
  final bool plusActive;

  /// `C_hat` of the current UTC month strictly above `usageBudgetEuro`.
  final bool aboveThreshold;
}

/// The moment an ad could be tried (study §7.7).
class AdAttemptContext {
  const AdAttemptContext({
    required this.dashboardVisible,
    required this.consentAllowsAds,
    required this.networkAvailable,
    required this.sensitiveOperationInProgress,
    required this.reservedTodayUtc,
  });

  /// The Dashboard is the visible screen: the only place of the banner.
  final bool dashboardVisible;

  /// The consent flow (CMP) allows ad requests.
  final bool consentAllowsAds;
  final bool networkAvailable;

  /// A save, a scan, an export or an account deletion is running.
  final bool sensitiveOperationInProgress;

  /// A slot was already reserved for this account and UTC day (on any
  /// device): one attempt per day, used even with no fill or an error.
  final bool reservedTodayUtc;
}

/// The ad decision of study §7.7 (freemium-plus FR7.2), pure:
///
/// ```text
/// eligible     = adsEnabled AND stateVerified AND NOT plusActive
///                AND C_hat > usageBudgetEuro
/// canAttemptAd = eligible AND dashboardVisible AND consentAllowsAds
///                AND networkAvailable AND NOT sensitiveOperationInProgress
///                AND NOT reservedTodayUtc
/// ```
///
/// [canAttemptAd] only allows asking the backend for the day's slot
/// (`reserveAdSlot`); the SDK may load the banner only with the slot
/// granted ([canLoadAd]).
abstract final class AdEligibility {
  static bool eligible(AdEligibilityInput input) =>
      input.adsEnabled &&
      input.stateVerified &&
      !input.plusActive &&
      input.aboveThreshold;

  static bool canAttemptAd(
    AdEligibilityInput input,
    AdAttemptContext context,
  ) =>
      eligible(input) &&
      context.dashboardVisible &&
      context.consentAllowsAds &&
      context.networkAvailable &&
      !context.sensitiveOperationInProgress &&
      !context.reservedTodayUtc;

  /// The banner loads only after the backend granted the slot of the day,
  /// and only while every other condition still holds (FR7.4: a Plus that
  /// arrives meanwhile cancels the load).
  static bool canLoadAd(
    AdEligibilityInput input,
    AdAttemptContext context, {
    required bool slotGranted,
  }) =>
      slotGranted &&
      eligible(input) &&
      context.dashboardVisible &&
      context.consentAllowsAds &&
      context.networkAvailable &&
      !context.sensitiveOperationInProgress;
}
