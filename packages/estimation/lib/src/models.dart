// Value types of contract C2 v1 plus the compatible additions of entities.md.
// Every type is immutable and compares by value (NFR4.4), and none of them has
// a field for personal data such as email, uid, location or device (NFR8.1).

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
enum Qualifier { riserva, superiore, granSelezione }

/// Confidence level of an estimate (BR3.1).
enum Confidence { high, medium, low }

/// Where a window comes from (C2).
enum WindowSource { catalog, internalRules }

/// What an estimate is based on (entities.md, addition to C2).
enum EstimationBasis {
  catalog,
  denomination,
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

  @override
  bool operator ==(Object other) =>
      other is WineFacts &&
      other.name == name &&
      other.producer == producer &&
      other.vintage == vintage &&
      other.wineType == wineType &&
      other.region == region &&
      other.denomination == denomination &&
      other.referenceYear == referenceYear;

  @override
  int get hashCode => Object.hash(
    name,
    producer,
    vintage,
    wineType,
    region,
    denomination,
    referenceYear,
  );

  @override
  String toString() =>
      'WineFacts(name: $name, producer: $producer, vintage: $vintage, '
      'wineType: ${wineType?.name}, region: $region, '
      'denomination: $denomination, referenceYear: $referenceYear)';
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
class DrinkingWindow {
  const DrinkingWindow({
    required this.startYear,
    required this.peakYear,
    required this.endYear,
    required this.confidence,
    required this.source,
    required this.basis,
    this.qualifier,
  });

  final int startYear;
  final int peakYear;
  final int endYear;
  final Confidence confidence;
  final WindowSource source;
  final EstimationBasis basis;

  /// Qualifier whose own offsets were used, if any.
  final Qualifier? qualifier;

  /// [genericEstimateWarningCode] when the estimate is generic, else `null`.
  String? get warningCode =>
      basis == EstimationBasis.generic ? genericEstimateWarningCode : null;

  @override
  bool operator ==(Object other) =>
      other is DrinkingWindow &&
      other.startYear == startYear &&
      other.peakYear == peakYear &&
      other.endYear == endYear &&
      other.confidence == confidence &&
      other.source == source &&
      other.basis == basis &&
      other.qualifier == qualifier;

  @override
  int get hashCode => Object.hash(
    startYear,
    peakYear,
    endYear,
    confidence,
    source,
    basis,
    qualifier,
  );

  @override
  String toString() =>
      'DrinkingWindow($startYear/$peakYear/$endYear, '
      'confidence: ${confidence.name}, source: ${source.name}, '
      'basis: ${basis.name}, qualifier: ${qualifier?.name})';
}

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
