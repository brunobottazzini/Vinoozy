// W1, drinking-window estimate (BR1.3-BR1.7, BR2.1, BR2.2, BR3.1), and W4,
// needsRefinement (BR1.5). label-autofill-windows adds the world tables, the
// grapes, the level (BR4.1, BR4.2) and the key and version of the tables in
// the window (ENT-002, BR3.9). wine-style-profiles (F1) estimates from the
// style profiles: windows in years or months, a peak or an end that may be
// missing, the indicative estimates and "To estimate" (no window).

import 'models.dart';
import 'style_resolver.dart';
import 'tables.dart' show YearOffsets, estimationTablesVersion;
import 'validation.dart';

/// Estimates the drinking window of [wine] (C2 `estimateWindow`).
///
/// A usable catalog window in [external] wins (BR1.4) and is never changed
/// by the level (BR4.2); otherwise the window comes from the style profile
/// resolved by [resolveStyle] (F1), with `wine.level` applied to the year
/// offsets that have a peak and an end (BR4.1). Returns `null` when the
/// wine cannot be estimated without its style ("To estimate", BR2.9).
/// Throws [EstimationArgumentError] for the invalid inputs of BR4.5 and
/// nothing else.
DrinkingWindow? estimateWindow(WineFacts wine, [ExternalProfile? external]) {
  validateWineFacts(wine);
  if (external != null && hasUsableCatalogWindow(external)) {
    return _catalogWindow(wine, external);
  }
  return windowOfResolution(resolveStyle(wine, external), wine);
}

/// The window of [resolution] for [wine] (F1 steps 5-7), or `null` for a
/// resolution without a window.
DrinkingWindow? windowOfResolution(StyleResolution resolution, WineFacts wine) {
  final start = resolution.start;
  if (resolution.hasNoWindow || start == null) return null;
  return resolution.unit == WindowUnit.months
      ? _monthsWindow(resolution, wine, start)
      : _yearsWindow(resolution, wine, start);
}

DrinkingWindow _yearsWindow(StyleResolution r, WineFacts wine, int start) {
  final base = _baseYear(wine, r.wineType);
  var peak = r.peak;
  var end = r.end;
  var first = start;
  final level = wine.level;
  if (level != null && peak != null && end != null) {
    final applied = level.apply(
      YearOffsets(start, peak, end),
      qualifierUsed: r.qualifier != null,
    );
    first = applied.start;
    peak = applied.peak;
    end = applied.end;
  }
  final hasVintage = wine.vintage != null;
  return DrinkingWindow(
    startYear: base + first,
    peakYear: peak == null ? null : base + peak,
    endYear: end == null ? null : base + end,
    // BR3.4: a dedicated denomination with a vintage is medium; a model,
    // a grape, a type or an indicative estimate is low; the level never
    // changes it.
    confidence: r.dedicated && hasVintage && !r.indicative
        ? Confidence.medium
        : Confidence.low,
    source: WindowSource.internalRules,
    basis: r.basis,
    qualifier: r.qualifier,
    denominationKey: r.denominationKey,
    tablesVersion: estimationTablesVersion,
    profile: r.profile,
    anchor: r.anchor ?? AgingAnchor.vintage,
    anchorFallback: !hasVintage,
    indicative: r.indicative,
  );
}

DrinkingWindow _monthsWindow(StyleResolution r, WineFacts wine, int start) {
  final agingYear = wine.agingStartYear;
  final agingMonth = wine.agingStartMonth;
  final hasDate = agingYear != null && agingMonth != null;
  final int base;
  var first = start;
  if (hasDate) {
    base = monthIndex(agingYear, agingMonth);
  } else {
    // BR6.2, BR8.3: the month the wine entered the cellar; a bottle bought
    // is already ready, so the start is 0.
    final year = wine.referenceYear ?? wine.vintage!;
    base = monthIndex(year, wine.referenceMonth ?? 1);
    first = 0;
  }
  final s = monthOfIndex(base + first);
  final p = r.peak == null ? null : monthOfIndex(base + r.peak!);
  final e = r.end == null ? null : monthOfIndex(base + r.end!);
  return DrinkingWindow(
    startYear: s.year,
    startMonth: s.month,
    peakYear: p?.year,
    peakMonth: p?.month,
    endYear: e?.year,
    endMonth: e?.month,
    unit: WindowUnit.months,
    confidence: r.dedicated && hasDate && !r.indicative
        ? Confidence.medium
        : Confidence.low,
    source: WindowSource.internalRules,
    basis: r.basis,
    qualifier: r.qualifier,
    denominationKey: r.denominationKey,
    tablesVersion: estimationTablesVersion,
    profile: r.profile,
    anchor: r.anchor,
    anchorFallback: !hasDate,
    indicative: r.indicative,
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
