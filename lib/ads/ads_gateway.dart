import 'dart:async';

import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Google's test banner unit: the only one used outside release builds
/// (freemium-plus FR7.3, study §7.7).
const String testBannerUnitId = 'ca-app-pub-3940256099942544/6300978111';

/// The banner unit of the release build, from
/// `--dart-define=ADMOB_BANNER_UNIT_ID=...`; the test unit when absent.
String bannerUnitId() {
  const configured = String.fromEnvironment('ADMOB_BANNER_UNIT_ID');
  return kReleaseMode && configured.isNotEmpty ? configured : testBannerUnitId;
}

/// What a loading banner reports.
class AdBannerCallbacks {
  const AdBannerCallbacks({
    required this.onLoaded,
    required this.onFailed,
    required this.onImpression,
    required this.onPaid,
  });

  final void Function() onLoaded;
  final void Function() onFailed;

  /// The ad was seen: never the same as loaded (FR7.6).
  final void Function() onImpression;

  /// An estimated revenue with its currency and precision.
  final void Function(double valueMicros, String currencyCode, String precision)
  onPaid;
}

/// One banner of the SDK.
abstract interface class AdBannerHandle {
  /// The banner view; only after `onLoaded`.
  Widget buildView();

  /// Removes and destroys the banner (leaving the Dashboard, background,
  /// Plus, ads turned off: FR7.1, FR7.3, FR7.4).
  Future<void> dispose();
}

/// The ad SDK behind an interface (unit-test-instructions.md, "Mock e
/// stub"): consent, initialisation, banner. Nothing here runs unless the
/// Dashboard ad slot asks, and the slot never asks while `adsEnabled` is
/// false (FR7.1).
abstract interface class AdsGateway {
  /// The consent flow (UMP, the CMP of study §7.7) before any ad request;
  /// true when the SDK may request ads.
  Future<bool> gatherConsent();

  /// Initialises the SDK, once.
  Future<void> initialize();

  /// Loads one banner, with no automatic refresh by the app.
  AdBannerHandle loadBanner(AdBannerCallbacks callbacks);
}

/// [AdsGateway] over `google_mobile_ads` (plan decision D6).
class GoogleMobileAdsGateway implements AdsGateway {
  Future<void>? _initialized;

  @override
  Future<bool> gatherConsent() async {
    final updated = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      updated.complete,
      (FormError error) => updated.complete(),
    );
    await updated.future;
    final shown = Completer<void>();
    await ConsentForm.loadAndShowConsentFormIfRequired(
      (FormError? error) => shown.complete(),
    );
    await shown.future;
    return ConsentInformation.instance.canRequestAds();
  }

  @override
  Future<void> initialize() =>
      _initialized ??= MobileAds.instance.initialize().then((_) {});

  @override
  AdBannerHandle loadBanner(AdBannerCallbacks callbacks) {
    final banner = BannerAd(
      adUnitId: bannerUnitId(),
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => callbacks.onLoaded(),
        onAdFailedToLoad: (ad, _) {
          unawaited(ad.dispose());
          callbacks.onFailed();
        },
        onAdImpression: (_) => callbacks.onImpression(),
        onPaidEvent: (_, valueMicros, precision, currencyCode) =>
            callbacks.onPaid(valueMicros, currencyCode, precision.name),
      ),
    );
    unawaited(banner.load());
    return _GoogleBanner(banner);
  }
}

class _GoogleBanner implements AdBannerHandle {
  _GoogleBanner(this._banner);

  final BannerAd _banner;

  @override
  Widget buildView() => SizedBox(
    width: _banner.size.width.toDouble(),
    height: _banner.size.height.toDouble(),
    child: AdWidget(ad: _banner),
  );

  @override
  Future<void> dispose() => _banner.dispose();
}
