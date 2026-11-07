// Pure calculation of the Dashboard (u5-dashboard performance-design.md,
// "Calcolo in un solo passaggio"; BR1.1-BR1.7, NFR2.2, NFR6.1).
//
// `compute` walks the wines once and never throws for a damaged wine: a
// window that makes `statusOf` throw counts as "to estimate" and increments
// `invalidWindowCount`; negative quantities are 0 and unknown types are
// "not specified". It never logs: the provider reports invalid windows.
//
// Pure Dart (no Flutter, Firebase or shared_preferences), so the CI
// benchmark runs it with `dart run` (tool/check_dashboard_readonly.sh).

import 'package:estimation/estimation.dart';

import '../../cellar/domain/wine.dart';
import 'dashboard_summary.dart';

/// Builds the [DashboardSummary] of a cellar on a given day.
class DashboardCalculator {
  const DashboardCalculator();

  /// Columns after the current year in the peak chart (BR1.5).
  static const int peakYearsAhead = 10;

  /// Summary of [wines] on [today], a local date whose time is ignored
  /// (BR1.2). One pass over the wines, then two small sorts.
  DashboardSummary compute(List<Wine> wines, DateTime today) {
    final tally = _Tally(today);
    for (final wine in wines) {
      tally.add(wine);
    }
    return tally.build();
  }

  /// Family of a stored `wineType` string, or `null` when it is absent or
  /// not recognised by `WineType.tryParse` (BR1.6).
  static WineFamily? familyOf(String? wineType) => switch (WineType.tryParse(
    wineType,
  )) {
    null => null,
    WineType.redLight || WineType.redStructured => WineFamily.red,
    WineType.white => WineFamily.white,
    WineType.rose => WineFamily.rose,
    WineType.sparklingClassic || WineType.sparklingTank => WineFamily.sparkling,
    WineType.sweet || WineType.fortified => WineFamily.sweet,
  };
}

/// A "drink soon" wine with its sort keys (BR1.3).
class _DrinkSoonCandidate {
  _DrinkSoonCandidate(this.row, this.sortName);

  final DrinkSoonRow row;
  final String sortName;

  static int compare(_DrinkSoonCandidate a, _DrinkSoonCandidate b) {
    final byEnd = a.row.endYear.compareTo(b.row.endYear);
    if (byEnd != 0) return byEnd;
    final byName = a.sortName.compareTo(b.sortName);
    if (byName != 0) return byName;
    final byVintage = (a.row.vintage ?? 0).compareTo(b.row.vintage ?? 0);
    if (byVintage != 0) return byVintage;
    return a.row.wineId.compareTo(b.row.wineId);
  }
}

/// Bottles of one region (compared without case and accents) and how often
/// each written form appears (BR1.6).
class _RegionTally {
  _RegionTally(this.key);

  final String key;
  int bottles = 0;
  final Map<String, int> forms = {};

  /// The most frequent written form; on a tie, the first alphabetically.
  String get displayForm {
    String? best;
    var bestCount = 0;
    forms.forEach((form, count) {
      if (best == null ||
          count > bestCount ||
          (count == bestCount && form.compareTo(best!) < 0)) {
        best = form;
        bestCount = count;
      }
    });
    return best!;
  }
}

/// Mutable counters of one [DashboardCalculator.compute] call.
class _Tally {
  _Tally(this.today) : year = today.year;

  final DateTime today;
  final int year;

  int total = 0;
  int waiting = 0;
  int ready = 0;
  int drinkSoonBottles = 0;
  int pastWindow = 0;
  int toEstimate = 0;
  int invalid = 0;
  final List<_DrinkSoonCandidate> drinkSoon = [];

  int pastPeak = 0;
  final List<int> peakYears = List.filled(
    DashboardCalculator.peakYearsAhead + 1,
    0,
  );
  int beyondPeak = 0;

  final List<int> families = List.filled(WineFamily.values.length, 0);
  int typeUnspecified = 0;

  final Map<String, _RegionTally> regions = {};
  int regionUnspecified = 0;

  /// Region of each denomination string, recognised once per call.
  final Map<String, String?> denominationRegions = {};

  /// Normalised key of each written region form, computed once per call.
  final Map<String, String> regionKeys = {};

  void add(Wine wine) {
    // BR1.1: bottles, not rows; negative quantities are already 0.
    final bottles = wine.quantity;
    if (bottles <= 0) return;
    total += bottles;
    _addStatus(wine, bottles);
    _addType(wine, bottles);
    _addRegion(wine, bottles);
  }

  void _addStatus(Wine wine, int bottles) {
    final window = wine.window;
    if (window == null) {
      toEstimate += bottles;
      return;
    }
    final WineStatus status;
    try {
      status = statusOf(window, today);
    } on ArgumentError {
      // BR1.2: an invalid window never blocks the Dashboard. The error is
      // not forwarded (its message may carry the years, NFR8.1): only the
      // count leaves this function.
      invalid++;
      toEstimate += bottles;
      return;
    }
    switch (status) {
      case WineStatus.waiting:
        waiting += bottles;
      case WineStatus.ready:
        ready += bottles;
      case WineStatus.drinkSoon:
        drinkSoonBottles += bottles;
        drinkSoon.add(
          _DrinkSoonCandidate(
            DrinkSoonRow(
              wineId: wine.id,
              name: wine.name,
              vintage: wine.vintage,
              producer: _textOrNull(wine.producer),
              quantity: bottles,
              endYear: window.endYear,
            ),
            normalizeWineText(wine.name),
          ),
        );
      case WineStatus.pastWindow:
        pastWindow += bottles;
    }
    _addPeak(window.peakYear, bottles);
  }

  void _addPeak(int peakYear, int bottles) {
    if (peakYear < year) {
      pastPeak += bottles;
    } else if (peakYear > year + DashboardCalculator.peakYearsAhead) {
      beyondPeak += bottles;
    } else {
      peakYears[peakYear - year] += bottles;
    }
  }

  void _addType(Wine wine, int bottles) {
    final family = DashboardCalculator.familyOf(wine.wineType);
    if (family == null) {
      typeUnspecified += bottles;
    } else {
      families[family.index] += bottles;
    }
  }

  void _addRegion(Wine wine, int bottles) {
    final form = _regionOf(wine);
    if (form == null) {
      regionUnspecified += bottles;
      return;
    }
    final key = regionKeys.putIfAbsent(form, () => normalizeWineText(form));
    final tally = regions.putIfAbsent(key, () => _RegionTally(key));
    tally.bottles += bottles;
    tally.forms.update(form, (count) => count + 1, ifAbsent: () => 1);
  }

  /// The wine's own region, else the region of its denomination, else
  /// `null` ("not specified", BR1.6).
  String? _regionOf(Wine wine) {
    final own = _textOrNull(wine.region);
    if (own != null && _normalisedKey(own).isNotEmpty) return own;
    final denomination = _textOrNull(wine.denomination);
    if (denomination == null) return null;
    return denominationRegions.putIfAbsent(
      denomination,
      () => recognizeDenomination(denomination)?.region,
    );
  }

  String _normalisedKey(String form) =>
      regionKeys.putIfAbsent(form, () => normalizeWineText(form));

  static String? _textOrNull(String? text) {
    final trimmed = text?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  DashboardSummary build() {
    drinkSoon.sort(_DrinkSoonCandidate.compare);
    return DashboardSummary(
      totalBottles: total,
      waitingBottles: waiting,
      readyBottles: ready,
      drinkSoonBottles: drinkSoonBottles,
      pastWindowBottles: pastWindow,
      toEstimateBottles: toEstimate,
      drinkSoon: List.unmodifiable(
        drinkSoon.take(DashboardSummary.maxDrinkSoonRows).map((c) => c.row),
      ),
      drinkSoonTotal: drinkSoon.length,
      peakYears: List.unmodifiable(_peakBars()),
      byType: List.unmodifiable(_typeBars()),
      byRegion: List.unmodifiable(_regionBars()),
      invalidWindowCount: invalid,
    );
  }

  List<PeakYearBar> _peakBars() => [
    PeakYearBar(kind: PeakColumnKind.pastPeak, bottles: pastPeak),
    for (var i = 0; i < peakYears.length; i++)
      PeakYearBar(
        kind: PeakColumnKind.year,
        year: year + i,
        bottles: peakYears[i],
      ),
    PeakYearBar(kind: PeakColumnKind.beyond, bottles: beyondPeak),
  ];

  /// The five families in a fixed order (a fixed axis, like the peaks),
  /// then "not specified" only when it has bottles.
  List<BreakdownBar> _typeBars() => [
    for (final family in WineFamily.values)
      BreakdownBar(
        kind: BreakdownKind.family,
        family: family,
        bottles: families[family.index],
      ),
    if (typeUnspecified > 0)
      BreakdownBar(kind: BreakdownKind.unspecified, bottles: typeUnspecified),
  ];

  /// The 8 regions with most bottles (on a tie, alphabetical without case
  /// and accents), then "others" and "not specified" when above 0.
  List<BreakdownBar> _regionBars() {
    final ranked = regions.values.toList()
      ..sort((a, b) {
        final byBottles = b.bottles.compareTo(a.bottles);
        return byBottles != 0 ? byBottles : a.key.compareTo(b.key);
      });
    final shown = ranked.take(DashboardSummary.maxRegions);
    final others = ranked
        .skip(DashboardSummary.maxRegions)
        .fold<int>(0, (sum, tally) => sum + tally.bottles);
    return [
      for (final tally in shown)
        BreakdownBar(
          kind: BreakdownKind.region,
          region: tally.displayForm,
          bottles: tally.bottles,
        ),
      if (others > 0)
        BreakdownBar(kind: BreakdownKind.otherRegions, bottles: others),
      if (regionUnspecified > 0)
        BreakdownBar(
          kind: BreakdownKind.unspecified,
          bottles: regionUnspecified,
        ),
    ];
  }
}
