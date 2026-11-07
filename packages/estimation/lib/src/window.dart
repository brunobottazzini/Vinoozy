// W1, drinking-window estimate (BR1.3-BR1.7, BR2.1, BR2.2, BR3.1), and W4,
// needsRefinement (BR1.5).

import 'models.dart';
import 'recognizer.dart';
import 'validation.dart';

/// Estimates the drinking window of [wine] (C2 `estimateWindow`).
///
/// A usable catalog window in [external] wins (BR1.4); otherwise the window
/// comes from the internal tables. Throws [EstimationArgumentError] for the
/// invalid inputs of BR4.5 and nothing else.
DrinkingWindow estimateWindow(WineFacts wine, [ExternalProfile? external]) {
  validateWineFacts(wine);
  if (external != null && hasUsableCatalogWindow(external)) {
    return _catalogWindow(wine, external);
  }

  final resolved = resolveWine(wine, external);
  final base = _baseYear(wine, resolved.effectiveType);
  final offsets = resolved.offsets;
  final hasVintage = wine.vintage != null;
  return DrinkingWindow(
    startYear: base + offsets.start,
    peakYear: base + offsets.peak,
    endYear: base + offsets.end,
    confidence: resolved.basis == EstimationBasis.denomination && hasVintage
        ? Confidence.medium
        : Confidence.low,
    source: WindowSource.internalRules,
    basis: resolved.basis,
    qualifier: resolved.qualifier,
  );
}

/// True when [window] comes from the internal rules and must be estimated
/// again with the catalog once online (BR1.5). Never throws.
bool needsRefinement(DrinkingWindow window) =>
    window.source == WindowSource.internalRules;

DrinkingWindow _catalogWindow(WineFacts wine, ExternalProfile external) {
  // A profile requested without vintage is at most low (C2 rule, BR3.1).
  final withoutVintage = external.vintage == null && wine.vintage == null;
  return DrinkingWindow(
    startYear: external.startYear!,
    peakYear: external.peakYear!,
    endYear: external.endYear!,
    confidence: withoutVintage
        ? Confidence.low
        : external.confidence ?? Confidence.high,
    source: WindowSource.catalog,
    basis: EstimationBasis.catalog,
  );
}

/// Base year of BR1.3: the vintage, else the reference year for sparkling
/// and generic estimates, else the year before it for still and sweet wines.
/// [validateWineFacts] guarantees one of the two years is present.
int _baseYear(WineFacts wine, WineType? type) {
  final vintage = wine.vintage;
  if (vintage != null) return vintage;
  final referenceYear = wine.referenceYear!;
  if (type == null || type.isSparkling) return referenceYear;
  return referenceYear - 1;
}
