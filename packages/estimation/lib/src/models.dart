// Value types of contract C2 v1 plus the compatible additions of entities.md.
// Every type is immutable and compares by value (NFR4.4), and none of them has
// a field for personal data such as email, uid, location or device (NFR8.1).

import 'profiles.dart';
import 'wine_level.dart';

export 'profiles.dart'
    show AgingAnchor, ProfileEvidence, StyleProfile, WindowUnit, WineStyle;
export 'wine_level.dart' show WineLevel;

/// Warning code exposed when an estimate has `basis == generic` (BR4.3).
const String genericEstimateWarningCode = 'GENERIC_ESTIMATE';

/// Wine type as stored in `WineFacts.wineType` (entities.md).
enum WineType {
  redLight,
  redStructured,
  white,
  rose,
  sparklingClassic,
  sparklingTank,
  sweet,
  fortified;

  /// True for the two sparkling types, which count from the reference year
  /// itself when the vintage is missing (BR1.3).
  bool get isSparkling => this == sparklingClassic || this == sparklingTank;

  /// Maps a stored or catalog string to a [WineType] (BR1.7).
  ///
  /// Accepts the enum names as they are and the C1 values `red`, `white`,
  /// `rose`, `sparkling` and `sweet`. Any other value, `null` included, is an
  /// absent type: it never throws.
  static WineType? tryParse(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    for (final type in WineType.values) {
      if (type.name == trimmed) return type;
    }
    return _catalogWineTypes[trimmed];
  }
}

/// C1 `wineType` values mapped to [WineType] (BR1.7).
const Map<String, WineType> _catalogWineTypes = {
  'red': WineType.redStructured,
  'white': WineType.white,
  'rose': WineType.rose,
  'sparkling': WineType.sparklingClassic,
  'sweet': WineType.sweet,
};

/// Qualifier found in the name that has its own year offsets (BR1.1, BR2.1).
///
/// label-autofill-windows (ENT-002, BR1.8) adds the foreign qualifiers after
/// the three Italian ones, so the stored names of the first three never
/// change.
enum Qualifier {
  riserva,
  superiore,
  granSelezione,
  crianza,
  reserva,
  granReserva,
  premierCru,
  grandCru,
  kabinett,
  spatlese,
  auslese,
  vintage,
  lbv,
  colheita,

  /// wine-style-profiles (ENT-104, BR2.6): the higher Prädikat and the ice
  /// wine, added at the end so the indexes of the masks above never change.
  beerenauslese,
  trockenbeerenauslese,
  eiswein,
}

/// Confidence level of an estimate (BR3.1).
enum Confidence { high, medium, low }

/// Where a window comes from (C2).
enum WindowSource { catalog, internalRules }

/// What an estimate is based on (entities.md, addition to C2).
///
/// `grape` (label-autofill-windows ENT-002, FR3.2): the window of a grape
/// variety, used when no denomination is recognised.
enum EstimationBasis {
  catalog,
  denomination,
  grape,
  wineType,
  generic;

  /// Basis to use for a window stored without one (functional-spec.md W4):
  /// [stored] when present, otherwise `catalog` for catalog windows and
  /// `wineType` (no warning) for internal ones.
  static EstimationBasis resolveStoredBasis(
    WindowSource source,
    EstimationBasis? stored,
  ) {
    if (stored != null) return stored;
    return source == WindowSource.catalog
        ? EstimationBasis.catalog
        : EstimationBasis.wineType;
  }
}

/// Status of a wine on a given day (FR4.5, BR3.2).
enum WineStatus { waiting, ready, drinkSoon, pastWindow }

/// Stable food category key; the app translates it into it, en and pt-BR.
enum PairingCategory {
  braisedRedMeat,
  grilledRedMeat,
  game,
  roastPoultry,
  poultry,
  pork,
  curedMeats,
  pastaMeatSauce,
  mushroomsTruffle,
  agedCheese,
  freshCheese,
  blueCheese,
  fish,
  seafood,
  rawSeafood,
  friedFood,
  vegetables,
  risotto,
  pizza,
  aperitif,
  pastries,
  dryBiscuits,
  chocolate,
  driedFruit,
  spicyDishes,
}

/// Wine data passed to the estimate (C2 `WineFacts`). No personal data.
class WineFacts {
  const WineFacts({
    required this.name,
    this.producer,
    this.vintage,
    this.wineType,
    this.region,
    this.denomination,
    this.referenceYear,
    this.level,
    this.referenceMonth,
    this.style,
    this.styleChosen = false,
    this.agingStartYear,
    this.agingStartMonth,
  });

  /// Wine name as typed by the user (1-60 characters after trimming, C3).
  final String name;
  final String? producer;

  /// Vintage year; `null` means a non-vintage wine.
  final int? vintage;

  /// Type chosen by the user; it wins over anything derived from the name.
  final WineType? wineType;
  final String? region;

  /// Denomination given by the user or by the catalog.
  final String? denomination;

  /// Year the wine entered the cellar (`createdAt` of C3); required when
  /// [vintage] is missing (BR1.3, BR4.5).
  final int? referenceYear;

  /// "Level" of the wine (label-autofill-windows FR4, BR4.1); `null` is "not
  /// chosen", which estimates as [WineLevel.good]. It is a field of the facts
  /// rather than a named parameter of `estimateWindow` because that function
  /// already has an optional positional parameter, which Dart cannot mix
  /// with named ones.
  final WineLevel? level;

  /// Month (1-12) the wine entered the cellar, with [referenceYear]: the
  /// start of a months profile without a disgorgement or bottling date
  /// (wine-style-profiles BR8.3).
  final int? referenceMonth;

  /// Style saved on the wine (ENT-107, BR1.4); `null` when none.
  final WineStyle? style;

  /// True when the user chose [style] (`styleSource == user`): its profile
  /// then decides the window (BR2.15).
  final bool styleChosen;

  /// Disgorgement or bottling date (BR8.1): year and month, both or none.
  final int? agingStartYear;
  final int? agingStartMonth;

  @override
  bool operator ==(Object other) =>
      other is WineFacts &&
      other.name == name &&
      other.producer == producer &&
      other.vintage == vintage &&
      other.wineType == wineType &&
      other.region == region &&
      other.denomination == denomination &&
      other.referenceYear == referenceYear &&
      other.level == level &&
      other.referenceMonth == referenceMonth &&
      other.style == style &&
      other.styleChosen == styleChosen &&
      other.agingStartYear == agingStartYear &&
      other.agingStartMonth == agingStartMonth;

  @override
  int get hashCode => Object.hash(
    name,
    producer,
    vintage,
    wineType,
    region,
    denomination,
    referenceYear,
    level,
    referenceMonth,
    style,
    styleChosen,
    agingStartYear,
    agingStartMonth,
  );

  @override
  String toString() =>
      'WineFacts(name: $name, producer: $producer, vintage: $vintage, '
      'wineType: ${wineType?.name}, region: $region, '
      'denomination: $denomination, referenceYear: $referenceYear, '
      'level: ${level?.name}'
      '${referenceMonth == null ? '' : ', referenceMonth: $referenceMonth'}'
      '${style == null ? '' : ', style: ${style!.name}'}'
      '${styleChosen ? ', styleChosen' : ''}'
      '${agingStartYear == null ? '' : ', agingStart: $agingStartYear-$agingStartMonth'}'
      ')';
}

/// Catalog profile from C1 `v1-getWineProfile` with `found = true`.
///
/// The window years are nullable because C1 may answer without a window
/// (BR1.6); [wineType] is the raw C1 string, mapped by [WineType.tryParse].
class ExternalProfile {
  const ExternalProfile({
    this.startYear,
    this.peakYear,
    this.endYear,
    this.confidence,
    this.vintage,
    this.pairings = const [],
    this.wineType,
    this.region,
    this.denomination,
  });

  final int? startYear;
  final int? peakYear;
  final int? endYear;
  final Confidence? confidence;

  /// Vintage the profile was requested with; `null` means without vintage.
  final int? vintage;
  final List<String> pairings;
  final String? wineType;
  final String? region;
  final String? denomination;

  @override
  bool operator ==(Object other) =>
      other is ExternalProfile &&
      other.startYear == startYear &&
      other.peakYear == peakYear &&
      other.endYear == endYear &&
      other.confidence == confidence &&
      other.vintage == vintage &&
      _listEquals(other.pairings, pairings) &&
      other.wineType == wineType &&
      other.region == region &&
      other.denomination == denomination;

  @override
  int get hashCode => Object.hash(
    startYear,
    peakYear,
    endYear,
    confidence,
    vintage,
    Object.hashAll(pairings),
    wineType,
    region,
    denomination,
  );

  @override
  String toString() =>
      'ExternalProfile(window: $startYear/$peakYear/$endYear, '
      'confidence: ${confidence?.name}, vintage: $vintage, '
      'pairings: $pairings, wineType: $wineType, region: $region, '
      'denomination: $denomination)';
}

/// Estimated drinking window (C2 `DrinkingWindow`).
///
/// wine-style-profiles (D2, ENT-106) adds optional fields: the [unit], the
/// months of a window in months, the [profile] and [anchor] used, whether the
/// anchor date was missing ([anchorFallback]) and whether the estimate is
/// only indicative ([indicative]). [peakYear] and [endYear] may be `null`:
/// a peak or an end the study does not estimate (BR1.2). Every comparison
/// goes through the month indexes ([startIndex], [peakIndex], [endIndex],
/// BR6.1), which give today's result for the windows in years.
class DrinkingWindow {
  const DrinkingWindow({
    required this.startYear,
    this.peakYear,
    this.endYear,
    required this.confidence,
    required this.source,
    required this.basis,
    this.qualifier,
    this.denominationKey,
    this.tablesVersion,
    this.unit = WindowUnit.years,
    this.startMonth,
    this.peakMonth,
    this.endMonth,
    this.profile,
    this.anchor,
    this.anchorFallback = false,
    this.indicative = false,
  });

  final int startYear;

  /// `null` when the peak is not estimated (BR6.4).
  final int? peakYear;

  /// `null` when no end is estimated (BR6.5).
  final int? endYear;
  final Confidence confidence;
  final WindowSource source;
  final EstimationBasis basis;

  /// Qualifier whose own offsets were used, if any.
  final Qualifier? qualifier;

  /// Stable key of the table row used: a denomination (`rioja`) or a grape
  /// (`malbec`); `null` for type, generic and catalog windows
  /// (label-autofill-windows ENT-002).
  final String? denominationKey;

  /// Version of the internal tables that computed the window
  /// ([estimationTablesVersion]); `null` for windows saved before it existed.
  /// A different version makes the app estimate the wine again once (BR3.9).
  final int? tablesVersion;

  /// Unit of the window; windows saved before wine-style-profiles are years.
  final WindowUnit unit;

  /// Months (1-12) of a window in months; `null` for a window in years.
  final int? startMonth;
  final int? peakMonth;
  final int? endMonth;

  /// Profile used (BR2.1); `null` for catalog windows and older windows.
  final StyleProfile? profile;

  /// What the window counts from; `null` for catalog and older windows.
  final AgingAnchor? anchor;

  /// True when the vintage or the disgorgement/bottling date was missing and
  /// the date the wine entered the cellar was used (BR6.2, BR8.3).
  final bool anchorFallback;

  /// True when the style is not clear and the estimate is only indicative
  /// (BR2.14).
  final bool indicative;

  /// True for a window in months.
  bool get inMonths => unit == WindowUnit.months;

  /// Month index of the start (BR6.1): year * 12 + month - 1; January of
  /// [startYear] for a window in years.
  int get startIndex => monthIndex(startYear, inMonths ? startMonth ?? 1 : 1);

  /// Month index of the peak, `null` without a peak; January of [peakYear]
  /// for a window in years (used only to order).
  int? get peakIndex {
    final year = peakYear;
    if (year == null) return null;
    return monthIndex(year, inMonths ? peakMonth ?? 1 : 1);
  }

  /// Month index of the end, `null` without an end; December of [endYear]
  /// for a window in years.
  int? get endIndex {
    final year = endYear;
    if (year == null) return null;
    return monthIndex(year, inMonths ? endMonth ?? 12 : 12);
  }

  /// [genericEstimateWarningCode] when the estimate is generic, else `null`.
  String? get warningCode =>
      basis == EstimationBasis.generic ? genericEstimateWarningCode : null;

  /// This window with other years, everything else kept. The months stay
  /// as they are: use [withIndexes] for a window in months.
  DrinkingWindow withYears(int start, int? peak, int? end) => _copy(
    startYear: start,
    peakYear: peak,
    endYear: end,
    startMonth: startMonth,
    peakMonth: peak == null ? null : peakMonth,
    endMonth: end == null ? null : endMonth,
  );

  /// This window with other month indexes (BR6.1), everything else kept. A
  /// window in years keeps only the years of the indexes.
  DrinkingWindow withIndexes(int start, int? peak, int? end) {
    final s = monthOfIndex(start);
    final p = peak == null ? null : monthOfIndex(peak);
    final e = end == null ? null : monthOfIndex(end);
    return _copy(
      startYear: s.year,
      peakYear: p?.year,
      endYear: e?.year,
      startMonth: inMonths ? s.month : null,
      peakMonth: inMonths ? p?.month : null,
      endMonth: inMonths ? e?.month : null,
    );
  }

  DrinkingWindow _copy({
    required int startYear,
    required int? peakYear,
    required int? endYear,
    required int? startMonth,
    required int? peakMonth,
    required int? endMonth,
  }) => DrinkingWindow(
    startYear: startYear,
    peakYear: peakYear,
    endYear: endYear,
    confidence: confidence,
    source: source,
    basis: basis,
    qualifier: qualifier,
    denominationKey: denominationKey,
    tablesVersion: tablesVersion,
    unit: unit,
    startMonth: startMonth,
    peakMonth: peakMonth,
    endMonth: endMonth,
    profile: profile,
    anchor: anchor,
    anchorFallback: anchorFallback,
    indicative: indicative,
  );

  @override
  bool operator ==(Object other) =>
      other is DrinkingWindow &&
      other.startYear == startYear &&
      other.peakYear == peakYear &&
      other.endYear == endYear &&
      other.confidence == confidence &&
      other.source == source &&
      other.basis == basis &&
      other.qualifier == qualifier &&
      other.denominationKey == denominationKey &&
      other.tablesVersion == tablesVersion &&
      other.unit == unit &&
      other.startMonth == startMonth &&
      other.peakMonth == peakMonth &&
      other.endMonth == endMonth &&
      other.profile == profile &&
      other.anchor == anchor &&
      other.anchorFallback == anchorFallback &&
      other.indicative == indicative;

  @override
  int get hashCode => Object.hash(
    startYear,
    peakYear,
    endYear,
    confidence,
    source,
    basis,
    qualifier,
    denominationKey,
    tablesVersion,
    unit,
    startMonth,
    peakMonth,
    endMonth,
    profile,
    anchor,
    anchorFallback,
    indicative,
  );

  @override
  String toString() {
    String at(int? year, int? month) =>
        year == null ? '-' : (inMonths ? '$year-$month' : '$year');
    return 'DrinkingWindow(${at(startYear, startMonth)}/'
        '${at(peakYear, peakMonth)}/${at(endYear, endMonth)}, '
        'confidence: ${confidence.name}, source: ${source.name}, '
        'basis: ${basis.name}, qualifier: ${qualifier?.name}'
        '${denominationKey == null ? '' : ', denominationKey: $denominationKey'}'
        '${tablesVersion == null ? '' : ', tablesVersion: $tablesVersion'}'
        '${profile == null ? '' : ', profile: ${profile!.id}'}'
        '${anchorFallback ? ', anchorFallback' : ''}'
        '${indicative ? ', indicative' : ''})';
  }
}

/// Absolute month index of [month] (1-12) of [year] (BR6.1).
int monthIndex(int year, int month) => year * 12 + month - 1;

/// The year and month (1-12) of a month [index] (BR6.1).
({int year, int month}) monthOfIndex(int index) =>
    (year: index ~/ 12, month: index % 12 + 1);

/// Pairings (C2 `Pairings`): catalog texts in [items], or internal category
/// keys in [categoryKeys].
class Pairings {
  const Pairings({
    required this.items,
    required this.categoryKeys,
    required this.source,
  });

  /// 1-5 catalog texts when `source == catalog`, empty otherwise.
  final List<String> items;

  /// 3-5 category keys when `source == internalRules`, empty otherwise.
  final List<PairingCategory> categoryKeys;
  final WindowSource source;

  @override
  bool operator ==(Object other) =>
      other is Pairings &&
      _listEquals(other.items, items) &&
      _listEquals(other.categoryKeys, categoryKeys) &&
      other.source == source;

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(items), Object.hashAll(categoryKeys), source);

  @override
  String toString() =>
      'Pairings(items: $items, '
      'categoryKeys: ${categoryKeys.map((c) => c.name).toList()}, '
      'source: ${source.name})';
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
