// W1, drinking-window estimate (BR1.3-BR1.7, BR2.1, BR2.2, BR3.1), and W4,
// needsRefinement (BR1.5). label-autofill-windows adds the world tables, the
// grapes, the level (BR4.1, BR4.2) and the key and version of the tables in
// the window (ENT-002, BR3.9).

import 'models.dart';
import 'recognizer.dart';
import 'tables.dart' show estimationTablesVersion;
import 'validation.dart';

/// Estimates the drinking window of [wine] (C2 `estimateWindow`).
///
/// A usable catalog window in [external] wins (BR1.4) and is never changed
/// by the level (BR4.2); otherwise the window comes from the internal tables
/// with `wine.level` applied to the offsets before the base year is added
/// (BR4.1). Throws [EstimationArgumentError] for the invalid inputs of BR4.5
/// and nothing else.
DrinkingWindow estimateWindow(WineFacts wine, [ExternalProfile? external]) {
  validateWineFacts(wine);
  if (external != null && hasUsableCatalogWindow(external)) {
    return _catalogWindow(wine, external);
  }

  final resolved = resolveWine(wine, external);
  final base = _baseYear(wine, resolved.effectiveType);
  final level = wine.level;
  final offsets = level == null
      ? resolved.offsets
      : level.apply(
          resolved.offsets,
          qualifierUsed: resolved.qualifier != null,
        );
  final hasVintage = wine.vintage != null;
  return DrinkingWindow(
    startYear: base + offsets.start,
    peakYear: base + offsets.peak,
    endYear: base + offsets.end,
    // BR3.4: a dedicated denomination with a vintage is medium; a model,
    // a grape or a type is low; the level never changes it.
    confidence: resolved.isDedicatedDenomination && hasVintage
        ? Confidence.medium
        : Confidence.low,
    source: WindowSource.internalRules,
    basis: resolved.basis,
    qualifier: resolved.qualifier,
    denominationKey: resolved.key,
    tablesVersion: estimationTablesVersion,
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
