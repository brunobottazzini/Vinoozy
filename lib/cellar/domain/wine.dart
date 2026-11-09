import 'package:estimation/estimation.dart';

import 'firestore_values.dart';
import 'quantity.dart';
import 'window_adjuster.dart';
import 'window_override.dart';
import 'wine_origins.dart';

export 'window_override.dart';

/// Field names of `cellars/{cellarId}/wines/{wineId}` (C3).
abstract final class WineFields {
  static const String name = 'name';
  static const String producer = 'producer';
  static const String vintage = 'vintage';
  static const String wineType = 'wineType';
  static const String region = 'region';
  static const String denomination = 'denomination';
  static const String quantity = 'quantity';
  static const String window = 'window';
  static const String pairings = 'pairings';
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';
  static const String updatedBy = 'updatedBy';

  /// Compatible additions of u4-cellar (C3 v1, 2026-11-06).
  static const String matchKey = 'matchKey';
  static const String baseWindow = 'baseWindow';
  static const String windowAdjustment = 'windowAdjustment';

  /// Compatible addition of ux-redesign (FR1.5): ISO 3166-1 alpha-2 code,
  /// optional.
  static const String country = 'country';

  /// Compatible additions of label-autofill-windows (ENT-001): the level
  /// (`everyday`, `good`, `aging`) and the manual end of the window.
  static const String level = 'level';
  static const String windowOverride = 'windowOverride';

  /// Compatible additions of wine-style-profiles (ENT-108): the style, where
  /// Type, Level and Style come from, the disgorgement or bottling date and
  /// the version of the one-off migration.
  static const String style = 'style';
  static const String typeSource = 'typeSource';
  static const String levelSource = 'levelSource';
  static const String styleSource = 'styleSource';
  static const String agingStartMonth = 'agingStartMonth';
  static const String migrationVersion = 'migrationVersion';
}

/// Where a Type, Level or Style comes from (wine-style-profiles BR7.1):
/// chosen by the user, or filled by the preselection.
enum FieldSource {
  user,
  auto;

  /// The source stored as [raw], or `null` for anything else.
  static FieldSource? tryParse(Object? raw) {
    for (final source in values) {
      if (source.name == raw) return source;
    }
    return null;
  }
}

/// Field names of the `agingStartMonth` map of a wine (BR8.1).
abstract final class AgingStartFields {
  static const String year = 'year';
  static const String month = 'month';
}

/// The disgorgement or bottling date of a wine (BR8.1): month and year.
class AgingStart {
  const AgingStart(this.year, this.month);

  /// Reads a stored `agingStartMonth`, or `null` when it is not a map with
  /// an integer year in 1900-2200 and a month in 1-12.
  static AgingStart? fromMap(Object? raw) {
    if (raw is! Map) return null;
    final year = FirestoreValues.integer(raw[AgingStartFields.year]);
    final month = FirestoreValues.integer(raw[AgingStartFields.month]);
    if (year == null || month == null) return null;
    if (year < 1900 || year > 2200 || month < 1 || month > 12) return null;
    return AgingStart(year, month);
  }

  final int year;
  final int month;

  Map<String, Object> toMap() => {
    AgingStartFields.year: year,
    AgingStartFields.month: month,
  };

  @override
  bool operator ==(Object other) =>
      other is AgingStart && other.year == year && other.month == month;

  @override
  int get hashCode => Object.hash(year, month);

  @override
  String toString() => 'AgingStart($year-$month)';
}

/// Field names of the `window` map of a wine (C3 `DrinkingWindow`).
abstract final class WindowFields {
  static const String startYear = 'startYear';
  static const String peakYear = 'peakYear';
  static const String endYear = 'endYear';
  static const String confidence = 'confidence';
  static const String source = 'source';
  static const String basis = 'basis';
  static const String qualifier = 'qualifier';

  /// label-autofill-windows ENT-002: the table row used and the version of
  /// the tables (BR3.9).
  static const String denominationKey = 'denominationKey';
  static const String tablesVersion = 'tablesVersion';

  /// wine-style-profiles ENT-106: unit, months, profile and anchor.
  static const String unit = 'unit';
  static const String startMonth = 'startMonth';
  static const String peakMonth = 'peakMonth';
  static const String endMonth = 'endMonth';
  static const String profile = 'profile';
  static const String anchor = 'anchor';
  static const String anchorFallback = 'anchorFallback';
  static const String indicative = 'indicative';
}

/// Field names of the `pairings` map of a wine (C3 `Pairings`).
abstract final class PairingsFields {
  static const String items = 'items';
  static const String categoryKeys = 'categoryKeys';
  static const String source = 'source';
}

/// A wine of a cellar as read from Firestore.
///
/// U1 writes name, vintage, quantity and the audit fields; u4-cellar also
/// writes producer, type, region, denomination, the estimate (`baseWindow`,
/// the effective `window`, `windowAdjustment`), `pairings` and `matchKey`.
/// The Dashboard (u5-dashboard) reads, never writes. Unknown fields are
/// ignored (C3: consumers ignore unknown fields).
class Wine {
  const Wine({
    required this.id,
    required this.name,
    required this.vintage,
    required this.storedQuantity,
    this.producer,
    this.wineType,
    this.region,
    this.denomination,
    this.country,
    this.window,
    this.baseWindow,
    this.windowAdjustment,
    this.pairings,
    this.matchKey,
    this.createdAt,
    this.updatedAt,
    this.updatedBy,
    this.level,
    this.windowOverride,
    this.style,
    this.typeSource,
    this.levelSource,
    this.styleSource,
    this.agingStart,
    this.migrationVersion,
  });

  /// Builds a wine from document data. Never throws: a malformed field falls
  /// back to an empty name, no vintage, quantity 0, `null` for the optional
  /// texts, and no window ("to estimate") for a malformed `window`. The same
  /// holds for `baseWindow`, `windowAdjustment`, `pairings` and `matchKey`.
  factory Wine.fromMap(String id, Map<String, Object?> data) => Wine(
    id: id,
    name: FirestoreValues.string(data[WineFields.name]) ?? '',
    vintage: FirestoreValues.integer(data[WineFields.vintage]),
    storedQuantity: FirestoreValues.integer(data[WineFields.quantity]) ?? 0,
    producer: FirestoreValues.string(data[WineFields.producer]),
    wineType: FirestoreValues.string(data[WineFields.wineType]),
    region: FirestoreValues.string(data[WineFields.region]),
    denomination: FirestoreValues.string(data[WineFields.denomination]),
    country: _countryFrom(data[WineFields.country]),
    window: windowFrom(data[WineFields.window]),
    baseWindow: windowFrom(data[WineFields.baseWindow]),
    windowAdjustment: WindowAdjustment.fromMap(
      data[WineFields.windowAdjustment],
    ),
    pairings: pairingsFrom(data[WineFields.pairings]),
    matchKey: FirestoreValues.string(data[WineFields.matchKey]),
    createdAt: FirestoreValues.dateTime(data[WineFields.createdAt]),
    updatedAt: FirestoreValues.dateTime(data[WineFields.updatedAt]),
    updatedBy: FirestoreValues.string(data[WineFields.updatedBy]),
    level: WineLevel.tryParse(data[WineFields.level]),
    windowOverride: WindowOverride.fromMap(data[WineFields.windowOverride]),
    style: WineStyle.tryParse(data[WineFields.style]),
    typeSource: FieldSource.tryParse(data[WineFields.typeSource]),
    levelSource: FieldSource.tryParse(data[WineFields.levelSource]),
    styleSource: FieldSource.tryParse(data[WineFields.styleSource]),
    agingStart: AgingStart.fromMap(data[WineFields.agingStartMonth]),
    migrationVersion: FirestoreValues.integer(
      data[WineFields.migrationVersion],
    ),
  );

  /// Converts a stored `window` into a [DrinkingWindow], or `null` ("to
  /// estimate") when it is not a map or when `startYear` is missing or not
  /// an integer. wine-style-profiles (D2, NFR2.1): `peakYear` and `endYear`
  /// may be missing (not estimated); `unit` missing is years; the months,
  /// profile and anchor are read when present.
  ///
  /// `confidence`, `source` and `qualifier` are read by name; a missing or
  /// unknown value falls back to `low`, `internalRules` and no qualifier.
  /// `basis` is read by name, else derived with
  /// [EstimationBasis.resolveStoredBasis]. The year order is not checked
  /// here: an inconsistent window makes `statusOf` throw, and the Dashboard
  /// counts it as invalid (u5 BR1.2).
  static DrinkingWindow? windowFrom(Object? raw) {
    if (raw is! Map) return null;
    final startYear = FirestoreValues.integer(raw[WindowFields.startYear]);
    final peakYear = FirestoreValues.integer(raw[WindowFields.peakYear]);
    final endYear = FirestoreValues.integer(raw[WindowFields.endYear]);
    if (startYear == null) return null;
    final unit =
        _byName(WindowUnit.values, raw[WindowFields.unit]) ?? WindowUnit.years;
    final months = unit == WindowUnit.months;
    int? month(String key) {
      if (!months) return null;
      final value = FirestoreValues.integer(raw[key]);
      return value != null && value >= 1 && value <= 12 ? value : null;
    }

    final source =
        _byName(WindowSource.values, raw[WindowFields.source]) ??
        WindowSource.internalRules;
    return DrinkingWindow(
      startYear: startYear,
      peakYear: peakYear,
      endYear: endYear,
      confidence:
          _byName(Confidence.values, raw[WindowFields.confidence]) ??
          Confidence.low,
      source: source,
      basis: EstimationBasis.resolveStoredBasis(
        source,
        _byName(EstimationBasis.values, raw[WindowFields.basis]),
      ),
      qualifier: _byName(Qualifier.values, raw[WindowFields.qualifier]),
      denominationKey: _key(raw[WindowFields.denominationKey]),
      tablesVersion: FirestoreValues.integer(raw[WindowFields.tablesVersion]),
      unit: unit,
      startMonth: month(WindowFields.startMonth),
      peakMonth: peakYear == null ? null : month(WindowFields.peakMonth),
      endMonth: endYear == null ? null : month(WindowFields.endMonth),
      profile: StyleProfile.tryParse(raw[WindowFields.profile]),
      anchor: _byName(AgingAnchor.values, raw[WindowFields.anchor]),
      anchorFallback: raw[WindowFields.anchorFallback] == true,
      indicative: raw[WindowFields.indicative] == true,
    );
  }

  static String? _key(Object? raw) {
    final key = FirestoreValues.string(raw);
    return key == null || key.isEmpty || key.length > 60 ? null : key;
  }

  /// The stored form of [window], accepted by `validWindow` of the rules
  /// (security-design.md §1): `qualifier`, `denominationKey` and
  /// `tablesVersion` only when present.
  static Map<String, Object> windowToMap(DrinkingWindow window) => {
    WindowFields.startYear: window.startYear,
    if (window.peakYear != null) WindowFields.peakYear: window.peakYear!,
    if (window.endYear != null) WindowFields.endYear: window.endYear!,
    WindowFields.confidence: window.confidence.name,
    WindowFields.source: window.source.name,
    WindowFields.basis: window.basis.name,
    if (window.qualifier != null)
      WindowFields.qualifier: window.qualifier!.name,
    if (window.denominationKey != null)
      WindowFields.denominationKey: window.denominationKey!,
    if (window.tablesVersion != null)
      WindowFields.tablesVersion: window.tablesVersion!,
    // wine-style-profiles: only the new fields that carry information, so a
    // window in years written by this app keeps the shape of before.
    if (window.inMonths) ...{
      WindowFields.unit: window.unit.name,
      if (window.startMonth != null)
        WindowFields.startMonth: window.startMonth!,
      if (window.peakMonth != null && window.peakYear != null)
        WindowFields.peakMonth: window.peakMonth!,
      if (window.endMonth != null && window.endYear != null)
        WindowFields.endMonth: window.endMonth!,
    },
    if (window.profile != null) WindowFields.profile: window.profile!.id,
    if (window.anchor != null) WindowFields.anchor: window.anchor!.name,
    if (window.anchorFallback) WindowFields.anchorFallback: true,
    if (window.indicative) WindowFields.indicative: true,
  };

  /// Converts a stored `pairings` map, or `null` when it is not one.
  /// Unknown category keys and non-text items are dropped.
  static Pairings? pairingsFrom(Object? raw) {
    if (raw is! Map) return null;
    final source = _byName(WindowSource.values, raw[PairingsFields.source]);
    if (source == null) return null;
    final items = raw[PairingsFields.items];
    final keys = raw[PairingsFields.categoryKeys];
    return Pairings(
      items: [
        if (items is List)
          for (final item in items)
            if (item is String && item.trim().isNotEmpty) item,
      ],
      categoryKeys: [
        if (keys is List)
          for (final key in keys) ?_byName(PairingCategory.values, key),
      ],
      source: source,
    );
  }

  /// The stored form of [pairings].
  static Map<String, Object> pairingsToMap(Pairings pairings) => {
    PairingsFields.items: pairings.items,
    PairingsFields.categoryKeys: [
      for (final key in pairings.categoryKeys) key.name,
    ],
    PairingsFields.source: pairings.source.name,
  };

  /// A stored `country`, or `null` when it is not an ISO 3166-1 code.
  static String? _countryFrom(Object? raw) {
    final code = FirestoreValues.string(raw);
    return WineOrigins.isCountryCode(code) ? code : null;
  }

  static T? _byName<T extends Enum>(List<T> values, Object? raw) {
    if (raw is! String) return null;
    for (final value in values) {
      if (value.name == raw) return value;
    }
    return null;
  }

  final String id;
  final String name;

  /// Null means "no vintage".
  final int? vintage;

  /// Raw stored value; may be negative after concurrent decrements (ADR-004).
  final int storedQuantity;

  /// Optional C3 fields written by U4. `wineType` is the raw stored string,
  /// mapped with `WineType.tryParse` by its consumers.
  final String? producer;
  final String? wineType;
  final String? region;
  final String? denomination;

  /// ISO 3166-1 alpha-2 code (FR1.5); `null` for wines saved without one.
  final String? country;

  /// The country shown for this wine: [country], else Italy when [region]
  /// is an Italian region (review R-06); the document is not rewritten.
  String? get displayCountry => WineOrigins.effectiveCountry(country, region);

  /// Effective drinking window (base estimate plus the drink feedback,
  /// BR1.12); `null` while the wine is not estimated yet or when the stored
  /// window is malformed. Cellar and Dashboard read this one.
  final DrinkingWindow? window;

  /// Base estimate without feedback (BR1.5); `null` for wines saved before
  /// u4-cellar.
  final DrinkingWindow? baseWindow;

  /// Feedback applied to [baseWindow] (BR1.12).
  final WindowAdjustment? windowAdjustment;
  final Pairings? pairings;

  /// Duplicate key (BR1.4); `null` for wines created before u4-cellar until
  /// the backfill writes it.
  final String? matchKey;

  /// Null while the server timestamp of a pending write is not resolved.
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? updatedBy;

  /// The level saved (FR4); `null` is "not chosen", estimated as good.
  final WineLevel? level;

  /// The owner's "Recommended until" (FR5); `null` without a correction.
  final WindowOverride? windowOverride;

  /// The style saved (wine-style-profiles BR1.4); `null` when none.
  final WineStyle? style;

  /// Where Type, Level and Style come from (BR7.1); `null` for a wine saved
  /// before wine-style-profiles or a field left empty.
  final FieldSource? typeSource;
  final FieldSource? levelSource;
  final FieldSource? styleSource;

  /// Disgorgement or bottling date (BR8.1); `null` when not given.
  final AgingStart? agingStart;

  /// Version of the one-off migration done on this wine (BR7.6); `null` or
  /// below 3 means "to migrate".
  final int? migrationVersion;

  /// Quantity for display, never below 0 (ADR-004).
  int get quantity => displayQuantity(storedQuantity);

  /// Orders wines by name (case-insensitive), then by vintage, then by id, so
  /// the list is stable (performance-design.md: client-side sort).
  static int compareByName(Wine a, Wine b) {
    final byName = a.name.toLowerCase().compareTo(b.name.toLowerCase());
    if (byName != 0) return byName;
    final byVintage = (a.vintage ?? 0).compareTo(b.vintage ?? 0);
    if (byVintage != 0) return byVintage;
    return a.id.compareTo(b.id);
  }

  /// Orders two entries of the same wine from the oldest (BR1.20): by
  /// `createdAt`, a pending one (no timestamp yet) being the newest, then by
  /// id.
  static int compareByAge(Wine a, Wine b) {
    final aTime = a.createdAt;
    final bTime = b.createdAt;
    if (aTime != null && bTime != null) {
      final byTime = aTime.compareTo(bTime);
      if (byTime != 0) return byTime;
    } else if (aTime != bTime) {
      return aTime == null ? 1 : -1;
    }
    return a.id.compareTo(b.id);
  }
}
