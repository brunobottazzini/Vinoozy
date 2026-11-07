import 'package:estimation/estimation.dart';

import '../catalog/core/wine_catalog.dart';
import 'domain/window_adjuster.dart';
import 'domain/wine.dart';
import 'domain/wine_estimate.dart';

/// The facts of a wine for the C2 estimate.
class WineFactsInput {
  const WineFactsInput({
    required this.name,
    this.producer,
    this.vintage,
    this.wineType,
    this.region,
    this.denomination,
    required this.referenceYear,
  });

  factory WineFactsInput.ofWine(Wine wine, {required int fallbackYear}) =>
      WineFactsInput(
        name: wine.name,
        producer: wine.producer,
        vintage: wine.vintage,
        wineType: wine.wineType,
        region: wine.region,
        denomination: wine.denomination,
        referenceYear: wine.createdAt?.toLocal().year ?? fallbackYear,
      );

  final String name;
  final String? producer;
  final int? vintage;

  /// Raw stored type, mapped with `WineType.tryParse`.
  final String? wineType;
  final String? region;
  final String? denomination;

  /// Year the wine entered the cellar: the base year without a vintage.
  final int referenceYear;

  WineFacts toFacts() => WineFacts(
    name: name,
    producer: producer,
    vintage: vintage,
    wineType: WineType.tryParse(wineType),
    region: region,
    denomination: denomination,
    referenceYear: referenceYear,
  );
}

/// Computes the estimate of a wine (BR1.5, BR1.6, BR1.12) with the C2
/// library, on the phone and without network.
///
/// The base window comes from `estimateWindow` (internal rules, or the
/// catalog profile when U3 has one), the effective window applies the drink
/// feedback with [WindowAdjuster], the pairings come from `pairingsFor`. An
/// estimation error never blocks a save: the wine stays "to estimate".
class WineEstimator {
  const WineEstimator();

  /// The internal estimate of [input] with [adjustment], or
  /// [WineEstimate.none] when C2 refuses the input.
  WineEstimate estimate(WineFactsInput input, {WindowAdjustment? adjustment}) =>
      _estimate(input.toFacts(), null, adjustment);

  /// The estimate improved by a catalog [profile] (BR1.5, BR1.6). With a
  /// window, the profile is the C2 `ExternalProfile`; without one (the
  /// current sources, C1 BR3.1), its type, region and denomination fill the
  /// empty facts and the internal rules run again.
  WineEstimate refine(
    WineFactsInput input,
    WineProfileResult profile, {
    WindowAdjustment? adjustment,
  }) {
    final facts = input.toFacts();
    if (!profile.found) return _estimate(facts, null, adjustment);
    final window = profile.window;
    if (window != null) {
      final external = ExternalProfile(
        startYear: window.startYear,
        peakYear: window.peakYear,
        endYear: window.endYear,
        confidence: switch (profile.confidence) {
          ProfileConfidence.high => Confidence.high,
          ProfileConfidence.medium => Confidence.medium,
          ProfileConfidence.low => Confidence.low,
          null => null,
        },
        vintage: facts.vintage,
        pairings: profile.pairings,
        wineType: profile.wineType?.name,
        region: profile.region,
        denomination: profile.denomination,
      );
      return _estimate(facts, external, adjustment);
    }
    final filled = WineFacts(
      name: facts.name,
      producer: facts.producer,
      vintage: facts.vintage,
      wineType: facts.wineType ?? WineType.tryParse(profile.wineType?.name),
      region: facts.region ?? profile.region,
      denomination: facts.denomination ?? profile.denomination,
      referenceYear: facts.referenceYear,
    );
    return _estimate(filled, null, adjustment);
  }

  /// The estimate shown for [wine] (BR1.19): the stored one, or one computed
  /// in memory and never written when the window is missing.
  WineEstimate displayed(Wine wine, {required int fallbackYear}) {
    if (wine.window != null) return WineEstimate.of(wine);
    final computed = estimate(
      WineFactsInput.ofWine(wine, fallbackYear: fallbackYear),
      adjustment: wine.windowAdjustment,
    );
    return WineEstimate(
      baseWindow: computed.baseWindow,
      window: computed.window,
      adjustment: computed.adjustment,
      pairings: wine.pairings ?? computed.pairings,
    );
  }

  /// [base] with [adjustment] applied (BR1.12), keeping [pairings].
  WineEstimate withAdjustment(
    DrinkingWindow base,
    WindowAdjustment? adjustment,
    Pairings? pairings,
  ) => WineEstimate(
    baseWindow: base,
    window: WindowAdjuster.effective(base, adjustment),
    adjustment: adjustment,
    pairings: pairings,
  );

  WineEstimate _estimate(
    WineFacts facts,
    ExternalProfile? external,
    WindowAdjustment? adjustment,
  ) {
    try {
      final base = estimateWindow(facts, external);
      return withAdjustment(base, adjustment, pairingsFor(facts, external));
    } on EstimationArgumentError {
      return adjustment == null
          ? WineEstimate.none
          : WineEstimate(adjustment: adjustment);
    }
  }
}
