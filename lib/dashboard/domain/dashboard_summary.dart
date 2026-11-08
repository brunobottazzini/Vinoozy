// View models of the Dashboard (u5-dashboard functional-spec.md,
// frontend-components.md). Immutable values compared by value: the widgets
// never count or sort, they only show what the calculator prepared.
//
// Pure Dart: no Flutter, Firebase or shared_preferences import
// (tool/check_dashboard_readonly.sh), so the benchmark runs with `dart run`.

import 'package:estimation/estimation.dart';

/// Wine families of the type breakdown (BR1.6).
enum WineFamily { red, white, rose, sparkling, sweet }

/// What a bar of the third chart stands for.
enum BreakdownKind {
  /// One of the five [WineFamily] values.
  family,

  /// One region, with its most frequent written form.
  region,

  /// "Others": the regions after the first eight (BR1.6).
  otherRegions,

  /// "Not specified": no type, or no region (BR1.6).
  unspecified,
}

/// What a column of the peak chart stands for (BR1.5).
enum PeakColumnKind {
  /// Peak before the current year.
  pastPeak,

  /// Peak in [PeakYearBar.year], from the current year to 10 years later.
  year,

  /// Peak more than 10 years after the current year.
  beyond,
}

/// One row of "Drink soon" (BR1.3).
class DrinkSoonRow {
  const DrinkSoonRow({
    required this.wineId,
    required this.name,
    required this.quantity,
    required this.endYear,
    this.vintage,
    this.producer,
    this.country,
  });

  final String wineId;
  final String name;
  final int? vintage;
  final String? producer;

  /// ISO code shown as a flag (ux-redesign FR1.4, FR3.3), or `null`.
  final String? country;

  /// Bottles of this wine, never below 1 (wines with 0 are excluded).
  final int quantity;
  final int endYear;

  @override
  bool operator ==(Object other) =>
      other is DrinkSoonRow &&
      other.wineId == wineId &&
      other.name == name &&
      other.vintage == vintage &&
      other.producer == producer &&
      other.country == country &&
      other.quantity == quantity &&
      other.endYear == endYear;

  @override
  int get hashCode =>
      Object.hash(wineId, name, vintage, producer, country, quantity, endYear);

  @override
  String toString() => 'DrinkSoonRow($wineId, end $endYear, x$quantity)';
}

/// One column of the peak chart (BR1.5).
class PeakYearBar {
  const PeakYearBar({required this.kind, required this.bottles, this.year});

  final PeakColumnKind kind;

  /// Set only when [kind] is [PeakColumnKind.year].
  final int? year;
  final int bottles;

  @override
  bool operator ==(Object other) =>
      other is PeakYearBar &&
      other.kind == kind &&
      other.year == year &&
      other.bottles == bottles;

  @override
  int get hashCode => Object.hash(kind, year, bottles);

  @override
  String toString() => 'PeakYearBar(${kind.name}, $year, $bottles)';
}

/// One bar of the type or region chart (BR1.6).
class BreakdownBar {
  const BreakdownBar({
    required this.kind,
    required this.bottles,
    this.family,
    this.region,
    this.country,
  });

  final BreakdownKind kind;

  /// Set only when [kind] is [BreakdownKind.family].
  final WineFamily? family;

  /// Written form shown for the region; set only when [kind] is
  /// [BreakdownKind.region].
  final String? region;

  /// The most frequent country of the region's wines (ux-redesign FR3.3),
  /// shown as a flag; `null` for "others", "not specified" and regions
  /// whose wines have no country.
  final String? country;
  final int bottles;

  @override
  bool operator ==(Object other) =>
      other is BreakdownBar &&
      other.kind == kind &&
      other.family == family &&
      other.region == region &&
      other.country == country &&
      other.bottles == bottles;

  @override
  int get hashCode => Object.hash(kind, family, region, country, bottles);

  @override
  String toString() =>
      'BreakdownBar(${kind.name}, ${family?.name ?? region}, $bottles)';
}

/// Everything the Dashboard shows, computed in one pass over the wines.
class DashboardSummary {
  const DashboardSummary({
    required this.totalBottles,
    required this.waitingBottles,
    required this.readyBottles,
    required this.drinkSoonBottles,
    required this.pastWindowBottles,
    required this.toEstimateBottles,
    required this.drinkSoon,
    required this.drinkSoonTotal,
    required this.peakYears,
    required this.byType,
    required this.byRegion,
    required this.invalidWindowCount,
  });

  /// Maximum rows of "Drink soon"; more show "See all (N)" (BR1.3).
  static const int maxDrinkSoonRows = 10;

  /// Regions shown by name before "others" (BR1.6).
  static const int maxRegions = 8;

  /// Every bottle with quantity above 0 (BR1.1).
  final int totalBottles;
  final int waitingBottles;
  final int readyBottles;
  final int drinkSoonBottles;
  final int pastWindowBottles;

  /// Bottles without a valid window: outside the status and peak charts,
  /// shown as "N bottles to estimate" (BR1.4, BR1.5).
  final int toEstimateBottles;

  /// At most [maxDrinkSoonRows] rows, already sorted (BR1.3).
  final List<DrinkSoonRow> drinkSoon;

  /// Wines in the "drink soon" status, also beyond the rows shown.
  final int drinkSoonTotal;

  /// "Past peak", the current year to +10, "beyond": always 13 columns.
  final List<PeakYearBar> peakYears;

  /// The five families in a fixed order, then "not specified" when above 0.
  final List<BreakdownBar> byType;

  /// Up to 8 regions, then "others" and "not specified" when above 0.
  final List<BreakdownBar> byRegion;

  /// Wines whose window made `statusOf` throw (BR1.2). The provider reports
  /// it once per process; the summary itself never logs.
  final int invalidWindowCount;

  /// Bottles of the status chart bar of [status] (BR1.4).
  int bottlesWith(WineStatus status) => switch (status) {
    WineStatus.waiting => waitingBottles,
    WineStatus.ready => readyBottles,
    WineStatus.drinkSoon => drinkSoonBottles,
    WineStatus.pastWindow => pastWindowBottles,
  };

  @override
  bool operator ==(Object other) =>
      other is DashboardSummary &&
      other.totalBottles == totalBottles &&
      other.waitingBottles == waitingBottles &&
      other.readyBottles == readyBottles &&
      other.drinkSoonBottles == drinkSoonBottles &&
      other.pastWindowBottles == pastWindowBottles &&
      other.toEstimateBottles == toEstimateBottles &&
      _listEquals(other.drinkSoon, drinkSoon) &&
      other.drinkSoonTotal == drinkSoonTotal &&
      _listEquals(other.peakYears, peakYears) &&
      _listEquals(other.byType, byType) &&
      _listEquals(other.byRegion, byRegion) &&
      other.invalidWindowCount == invalidWindowCount;

  @override
  int get hashCode => Object.hash(
    totalBottles,
    waitingBottles,
    readyBottles,
    drinkSoonBottles,
    pastWindowBottles,
    toEstimateBottles,
    Object.hashAll(drinkSoon),
    drinkSoonTotal,
    Object.hashAll(peakYears),
    Object.hashAll(byType),
    Object.hashAll(byRegion),
    invalidWindowCount,
  );

  @override
  String toString() =>
      'DashboardSummary(total: $totalBottles, waiting: $waitingBottles, '
      'ready: $readyBottles, drinkSoon: $drinkSoonBottles, '
      'pastWindow: $pastWindowBottles, toEstimate: $toEstimateBottles, '
      'invalid: $invalidWindowCount)';
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
