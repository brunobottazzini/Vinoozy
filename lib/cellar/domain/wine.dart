import 'package:estimation/estimation.dart';

import 'firestore_values.dart';
import 'quantity.dart';
import 'window_adjuster.dart';

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
    this.window,
    this.baseWindow,
    this.windowAdjustment,
    this.pairings,
    this.matchKey,
    this.createdAt,
    this.updatedAt,
    this.updatedBy,
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
  );

  /// Converts a stored `window` into a [DrinkingWindow], or `null` ("to
  /// estimate") when it is not a map or when `startYear`, `peakYear` or
  /// `endYear` is missing or not an integer.
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
    if (startYear == null || peakYear == null || endYear == null) return null;
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
    );
  }

  /// The stored form of [window], accepted by `validWindow` of the rules
  /// (security-design.md §1): `qualifier` only when present.
  static Map<String, Object> windowToMap(DrinkingWindow window) => {
    WindowFields.startYear: window.startYear,
    WindowFields.peakYear: window.peakYear,
    WindowFields.endYear: window.endYear,
    WindowFields.confidence: window.confidence.name,
    WindowFields.source: window.source.name,
    WindowFields.basis: window.basis.name,
    if (window.qualifier != null)
      WindowFields.qualifier: window.qualifier!.name,
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
