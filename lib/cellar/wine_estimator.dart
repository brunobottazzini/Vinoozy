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
    this.level,
    this.referenceMonth,
    this.style,
    this.styleChosen = false,
    this.agingStart,
  });

  /// [fallbackMonth] is the month of [fallbackYear] used while `createdAt`
  /// is pending (wine-style-profiles BR8.3).
  factory WineFactsInput.ofWine(
    Wine wine, {
    required int fallbackYear,
    int? fallbackMonth,
  }) {
    final created = wine.createdAt?.toLocal();
    return WineFactsInput(
      name: wine.name,
      producer: wine.producer,
      vintage: wine.vintage,
      wineType: wine.wineType,
      region: wine.region,
      denomination: wine.denomination,
      referenceYear: created?.year ?? fallbackYear,
      referenceMonth: created?.month ?? fallbackMonth,
      level: wine.level,
      style: wine.style,
      styleChosen: wine.styleSource == FieldSource.user,
      agingStart: wine.agingStart,
    );
  }

  final String name;
  final String? producer;
  final int? vintage;

  /// Raw stored type, mapped with `WineType.tryParse`.
  final String? wineType;
  final String? region;
  final String? denomination;

  /// Year the wine entered the cellar: the base year without a vintage.
  final int referenceYear;

  /// The level of the wine (label-autofill-windows BR4.1): applied inside
  /// the estimate, so the base window already holds it.
  final WineLevel? level;

  /// Month the wine entered the cellar (BR8.3): the start of a months
  /// profile without a date.
  final int? referenceMonth;

  /// The style saved and whether the user chose it (BR2.15).
  final WineStyle? style;
  final bool styleChosen;

  /// Disgorgement or bottling date (BR8.1).
  final AgingStart? agingStart;

  WineFacts toFacts() => WineFacts(
    name: name,
    producer: producer,
    vintage: vintage,
    wineType: WineType.tryParse(wineType),
    region: region,
    denomination: denomination,
    referenceYear: referenceYear,
    level: level,
    referenceMonth: referenceMonth,
    style: style,
    styleChosen: styleChosen,
    agingStartYear: agingStart?.year,
    agingStartMonth: agingStart?.month,
  );
}

/// Computes the estimate of a wine (BR1.5, BR1.6, BR1.12) with the C2
/// library, on the phone and without network.
///
/// The base window comes from `estimateWindow` (internal rules with the
/// level, or the catalog profile when U3 has one); the effective window
/// applies the drink feedback and then the owner's "Recommended until"
/// with [WindowAdjuster.effectiveOf] (label-autofill-windows BR4.4, BR4.5);
/// the pairings come from `pairingsFor`. An estimation error never blocks a
/// save: the wine stays "to estimate".
class WineEstimator {
  const WineEstimator();

  /// The internal estimate of [input] with [adjustment] and [override], or
  /// [WineEstimate.none] when C2 refuses the input.
  WineEstimate estimate(
    WineFactsInput input, {
    WindowAdjustment? adjustment,
    WindowOverride? override,
  }) => _estimate(input.toFacts(), null, adjustment, override);

  /// The estimate improved by a catalog [profile] (BR1.5, BR1.6). With a
  /// window, the profile is the C2 `ExternalProfile`; without one (the
  /// current sources, C1 BR3.1), its type, region and denomination fill the
  /// empty facts and the internal rules run again.
  WineEstimate refine(
    WineFactsInput input,
    WineProfileResult profile, {
    WindowAdjustment? adjustment,
    WindowOverride? override,
  }) {
    final facts = input.toFacts();
    if (!profile.found) return _estimate(facts, null, adjustment, override);
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
      return _estimate(facts, external, adjustment, override);
    }
    final filled = WineFacts(
      name: facts.name,
      producer: facts.producer,
      vintage: facts.vintage,
      wineType: facts.wineType ?? WineType.tryParse(profile.wineType?.name),
      region: facts.region ?? profile.region,
      denomination: facts.denomination ?? profile.denomination,
      referenceYear: facts.referenceYear,
      level: facts.level,
      referenceMonth: facts.referenceMonth,
      style: facts.style,
      styleChosen: facts.styleChosen,
      agingStartYear: facts.agingStartYear,
      agingStartMonth: facts.agingStartMonth,
    );
    return _estimate(filled, null, adjustment, override);
  }

  /// The estimate shown for [wine] (BR1.19, BR4.7): the stored one, or one
  /// computed in memory with its level and correction and never written
  /// when the window is missing.
  WineEstimate displayed(Wine wine, {required int fallbackYear}) {
    if (wine.window != null) return WineEstimate.of(wine);
    final computed = estimate(
      WineFactsInput.ofWine(wine, fallbackYear: fallbackYear),
      adjustment: wine.windowAdjustment,
      override: wine.windowOverride,
    );
    return WineEstimate(
      baseWindow: computed.baseWindow,
      window: computed.window,
      adjustment: computed.adjustment,
      pairings: wine.pairings ?? computed.pairings,
    );
  }

  /// [base] with [adjustment] and then [override] applied (BR1.12, BR4.4),
  /// keeping [pairings].
  WineEstimate withAdjustment(
    DrinkingWindow base,
    WindowAdjustment? adjustment,
    Pairings? pairings, {
    WindowOverride? override,
  }) => WineEstimate(
    baseWindow: base,
    window: WindowAdjuster.effectiveOf(base, adjustment, override),
    adjustment: adjustment,
    pairings: pairings,
  );

  WineEstimate _estimate(
    WineFacts facts,
    ExternalProfile? external,
    WindowAdjustment? adjustment,
    WindowOverride? override,
  ) {
    try {
      final base = estimateWindow(facts, external);
      if (base == null) {
        // "To estimate" (wine-style-profiles BR2.9): no window until the
        // style is chosen; the pairings still help.
        return WineEstimate(
          adjustment: adjustment,
          pairings: pairingsFor(facts, external),
        );
      }
      return withAdjustment(
        base,
        adjustment,
        pairingsFor(facts, external),
        override: override,
      );
    } on EstimationArgumentError {
      return adjustment == null
          ? WineEstimate.none
          : WineEstimate(adjustment: adjustment);
    }
  }
}
