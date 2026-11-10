// freemium-plus FR7.2, study §7.7: who is eligible for ads and when an
// attempt may start.
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/ads/ad_eligibility.dart';

void main() {
  const eligibleInput = AdEligibilityInput(
    adsEnabled: true,
    stateVerified: true,
    plusActive: false,
    aboveThreshold: true,
  );
  const goodMoment = AdAttemptContext(
    dashboardVisible: true,
    consentAllowsAds: true,
    networkAvailable: true,
    sensitiveOperationInProgress: false,
    reservedTodayUtc: false,
  );

  AdEligibilityInput input({
    bool adsEnabled = true,
    bool stateVerified = true,
    bool plusActive = false,
    bool aboveThreshold = true,
  }) => AdEligibilityInput(
    adsEnabled: adsEnabled,
    stateVerified: stateVerified,
    plusActive: plusActive,
    aboveThreshold: aboveThreshold,
  );

  AdAttemptContext moment({
    bool dashboardVisible = true,
    bool consentAllowsAds = true,
    bool networkAvailable = true,
    bool sensitiveOperationInProgress = false,
    bool reservedTodayUtc = false,
  }) => AdAttemptContext(
    dashboardVisible: dashboardVisible,
    consentAllowsAds: consentAllowsAds,
    networkAvailable: networkAvailable,
    sensitiveOperationInProgress: sensitiveOperationInProgress,
    reservedTodayUtc: reservedTodayUtc,
  );

  test('eligible only with every condition', () {
    expect(AdEligibility.eligible(eligibleInput), isTrue);
    expect(AdEligibility.eligible(input(adsEnabled: false)), isFalse);
    expect(AdEligibility.eligible(input(stateVerified: false)), isFalse);
    expect(AdEligibility.eligible(input(plusActive: true)), isFalse);
    expect(AdEligibility.eligible(input(aboveThreshold: false)), isFalse);
  });

  test(
    'an attempt needs the Dashboard, consent, network, calm and no slot today',
    () {
      expect(AdEligibility.canAttemptAd(eligibleInput, goodMoment), isTrue);
      for (final bad in [
        moment(dashboardVisible: false),
        moment(consentAllowsAds: false),
        moment(networkAvailable: false),
        moment(sensitiveOperationInProgress: true),
        moment(reservedTodayUtc: true),
      ]) {
        expect(AdEligibility.canAttemptAd(eligibleInput, bad), isFalse);
      }
      expect(
        AdEligibility.canAttemptAd(input(plusActive: true), goodMoment),
        isFalse,
      );
    },
  );

  test('the banner loads only with the slot granted, and stops for Plus', () {
    expect(
      AdEligibility.canLoadAd(eligibleInput, goodMoment, slotGranted: true),
      isTrue,
    );
    expect(
      AdEligibility.canLoadAd(eligibleInput, goodMoment, slotGranted: false),
      isFalse,
    );
    // FR7.4: Plus arrives while the slot is granted.
    expect(
      AdEligibility.canLoadAd(
        input(plusActive: true),
        goodMoment,
        slotGranted: true,
      ),
      isFalse,
    );
    // The reservation of today is the granted slot itself: it loads once.
    expect(
      AdEligibility.canLoadAd(
        eligibleInput,
        moment(reservedTodayUtc: true),
        slotGranted: true,
      ),
      isTrue,
    );
  });
}
