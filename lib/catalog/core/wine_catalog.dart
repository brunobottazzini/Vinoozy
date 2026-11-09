// Contract C1 v1 as a Dart interface (contract-summary.md, updated on
// 2026-11-05): the WineCatalog operations and their value types, with the
// compatible additions suggestExternal, lookupBarcode, cellarWines, source
// and barcode. No type here carries personal data, and the only exception the
// module throws is [CatalogArgumentError], which carries a code and a fixed
// message, never the rejected value (NFR4.5, NFR8.3).
//
// label-recognition (2026-11-07): the offline wine database is a new source,
// candidates carry a country, matchLabelText became matchLabel (sure
// proposal, candidates or nothing, BR3.1-BR3.4) and searchOnline serves
// "Cerca online" (BR4.1-BR4.3).

import 'package:estimation/estimation.dart' show WineLevel, WineStyle, WineType;

/// C1 `wineType` values.
enum CatalogWineType { red, white, rose, sparkling, sweet }

/// Where a proposal comes from (BR1.4 priority: cellar, offline database,
/// internal, OFF; label-recognition BR3.3: the offline database wins over
/// Open Food Facts).
///
/// `offline` and `openFoodFacts` proposals must be shown with the ODbL
/// attribution (BR5.2, label-recognition BR6.2).
enum CandidateSource {
  cellar(0),
  internal(2),
  openFoodFacts(3),
  offline(1);

  const CandidateSource(this.rank);

  /// Lower is preferred when two proposals are the same wine (BR1.4).
  final int rank;
}

/// App language of a request: `it`, `en` or `pt-BR`. Open Food Facts
/// receives only the language code [offLanguage] (NFR4.2).
enum CatalogLocale {
  it('it'),
  en('en'),
  ptBR('pt');

  const CatalogLocale(this.offLanguage);

  final String offLanguage;

  /// Maps a language tag such as `pt-BR`, `pt_BR` or `it-IT`; any other
  /// language falls back to English.
  static CatalogLocale fromLanguageTag(String tag) {
    final language = tag.split(RegExp('[-_]')).first.toLowerCase();
    return switch (language) {
      'it' => CatalogLocale.it,
      'pt' => CatalogLocale.ptBR,
      _ => CatalogLocale.en,
    };
  }
}

/// A wine proposed to the user (C1 `WineCandidate`). No personal data.
class WineCandidate {
  const WineCandidate({
    required this.name,
    required this.source,
    this.producer,
    this.vintage,
    this.wineType,
    this.region,
    this.denomination,
    this.barcode,
    this.country,
    this.exactType,
    this.level,
    this.style,
  });

  /// 1 to 120 characters.
  final String name;
  final String? producer;
  final int? vintage;
  final CatalogWineType? wineType;
  final String? region;

  /// Display name of the recognised denomination, such as "Barolo DOCG".
  final String? denomination;
  final CandidateSource source;

  /// 8 or 13 digits; only for [CandidateSource.openFoodFacts] and
  /// [CandidateSource.offline].
  final String? barcode;

  /// ISO 3166-1 alpha-2 code of the country, when the source knows it
  /// (offline database, label-recognition FR2.1).
  final String? country;

  /// wine-style-profiles (BR3.5, BR9.2): the Type of the 8 values when the
  /// source knows it (offline database, internal catalog), never reduced to
  /// the 5 families of [wineType]; and the Level and Style the offline
  /// database preselected.
  final WineType? exactType;
  final WineLevel? level;
  final WineStyle? style;

  WineCandidate copyWith({int? vintage}) => WineCandidate(
    name: name,
    source: source,
    producer: producer,
    vintage: vintage ?? this.vintage,
    wineType: wineType,
    region: region,
    denomination: denomination,
    barcode: barcode,
    country: country,
    exactType: exactType,
    level: level,
    style: style,
  );

  /// Compact form stored in the catalog cache (short keys keep the worst
  /// case under 3 MB, NFR2.3). Absent fields are left out.
  Map<String, Object> toJson() => {
    'n': name,
    's': source.name,
    'p': ?producer,
    'v': ?vintage,
    't': ?wineType?.name,
    'r': ?region,
    'd': ?denomination,
    'b': ?barcode,
    'c': ?country,
    'x': ?exactType?.name,
    'l': ?level?.name,
    'y': ?style?.name,
  };

  /// Reads the form written by [toJson]; `null` when [json] is not one,
  /// so a damaged cache entry is dropped instead of throwing (NFR6.4).
  static WineCandidate? fromJson(Object? json) {
    if (json is! Map) return null;
    final name = json['n'];
    final source = _enumByName(CandidateSource.values, json['s']);
    if (name is! String || name.isEmpty || source == null) return null;
    final vintage = json['v'];
    return WineCandidate(
      name: name,
      source: source,
      producer: _stringOrNull(json['p']),
      vintage: vintage is int ? vintage : null,
      wineType: _enumByName(CatalogWineType.values, json['t']),
      region: _stringOrNull(json['r']),
      denomination: _stringOrNull(json['d']),
      barcode: _stringOrNull(json['b']),
      country: _stringOrNull(json['c']),
      exactType: WineType.tryParse(_stringOrNull(json['x'])),
      level: WineLevel.tryParse(json['l']),
      style: WineStyle.tryParse(json['y']),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is WineCandidate &&
      other.name == name &&
      other.producer == producer &&
      other.vintage == vintage &&
      other.wineType == wineType &&
      other.region == region &&
      other.denomination == denomination &&
      other.source == source &&
      other.barcode == barcode &&
      other.country == country &&
      other.exactType == exactType &&
      other.level == level &&
      other.style == style;

  @override
  int get hashCode => Object.hash(
    name,
    producer,
    vintage,
    wineType,
    region,
    denomination,
    source,
    barcode,
    country,
    exactType,
    level,
    style,
  );

  @override
  String toString() => 'WineCandidate(${source.name})';
}

/// A wine already in the cellar, passed by U4 to [WineCatalog.suggestWines]
/// (compatible addition `cellarWines`). U3 never reads the cellar itself.
class CellarWineRef {
  const CellarWineRef({
    required this.name,
    this.producer,
    this.vintage,
    this.wineType,
  });

  final String name;
  final String? producer;
  final int? vintage;
  final CatalogWineType? wineType;

  @override
  bool operator ==(Object other) =>
      other is CellarWineRef &&
      other.name == name &&
      other.producer == producer &&
      other.vintage == vintage &&
      other.wineType == wineType;

  @override
  int get hashCode => Object.hash(name, producer, vintage, wineType);

  @override
  String toString() => 'CellarWineRef()';
}

/// Answer of [WineCatalog.suggestWines] and [WineCatalog.suggestExternal].
class SuggestResult {
  const SuggestResult({
    required this.suggestions,
    required this.externalIncluded,
  });

  static const SuggestResult empty = SuggestResult(
    suggestions: [],
    externalIncluded: false,
  );

  /// At most 10, without duplicates (BR1.4).
  final List<WineCandidate> suggestions;

  /// True when [suggestions] holds Open Food Facts results.
  final bool externalIncluded;

  @override
  bool operator ==(Object other) =>
      other is SuggestResult &&
      other.externalIncluded == externalIncluded &&
      _listEquals(other.suggestions, suggestions);

  @override
  int get hashCode =>
      Object.hash(externalIncluded, Object.hashAll(suggestions));

  @override
  String toString() =>
      'SuggestResult(${suggestions.length}, external: $externalIncluded)';
}

/// The step of the lookup order that decided a label outcome
/// (label-recognition BR3.1): `offlineBarcode` (1), `offlineText` (2),
/// `internalDenomination` (3), `onlineBarcode` and `onlineText` (4), `none`
/// (5, nothing found).
enum LabelMatchStep {
  offlineBarcode,
  offlineText,
  internalDenomination,
  onlineBarcode,
  onlineText,
  none,
}

/// Kind of a [LabelMatchResult] (label-recognition BR3.2).
enum LabelMatchKind { sure, candidates, none }

/// Answer of [WineCatalog.matchLabel] (label-recognition BR3.1-BR3.3):
/// - [LabelMatchKind.sure]: one wine is certain ([candidate]); the other
///   candidates, if any, are kept in [candidates] for "Non è questo" (BR3.5);
/// - [LabelMatchKind.candidates]: up to 10 similar wines, best first;
/// - [LabelMatchKind.none]: nothing similar.
///
/// Nothing is ever saved without the user's confirmation.
class LabelMatchResult {
  const LabelMatchResult.sure(
    WineCandidate this.candidate, {
    required this.step,
    this.candidates = const [],
  }) : kind = LabelMatchKind.sure;

  const LabelMatchResult.candidates(this.candidates, {required this.step})
    : kind = LabelMatchKind.candidates,
      candidate = null;

  const LabelMatchResult.none()
    : kind = LabelMatchKind.none,
      candidate = null,
      candidates = const [],
      step = LabelMatchStep.none;

  final LabelMatchKind kind;

  /// The certain wine; only for [LabelMatchKind.sure].
  final WineCandidate? candidate;

  /// The candidates, best first, without duplicates; for a sure result the
  /// other candidates (the certain one excluded).
  final List<WineCandidate> candidates;
  final LabelMatchStep step;

  @override
  bool operator ==(Object other) =>
      other is LabelMatchResult &&
      other.kind == kind &&
      other.candidate == candidate &&
      other.step == step &&
      _listEquals(other.candidates, candidates);

  @override
  int get hashCode =>
      Object.hash(kind, candidate, step, Object.hashAll(candidates));

  @override
  String toString() =>
      'LabelMatchResult(${kind.name}, ${candidates.length}, ${step.name})';
}

/// What "Cerca online" could do (label-recognition BR4.2, BR4.3).
enum OnlineSearchStatus {
  /// Offline and online results were asked.
  ok,

  /// No network: only the offline database was searched.
  offline,

  /// Open Food Facts is suspended, over its budget or it failed: only the
  /// offline database was searched, and trying again later may work.
  rateLimited,

  /// Open Food Facts is off in this build (no contact, BR5.1): only the
  /// offline database was searched, and trying again later will not help
  /// (code-generation review R-03).
  unavailable,
}

/// Answer of [WineCatalog.searchOnline].
class OnlineSearchResult {
  const OnlineSearchResult({required this.candidates, required this.status});

  /// Offline results first, then online ones; at most 10, without
  /// duplicates (BR3.3).
  final List<WineCandidate> candidates;
  final OnlineSearchStatus status;

  @override
  bool operator ==(Object other) =>
      other is OnlineSearchResult &&
      other.status == status &&
      _listEquals(other.candidates, candidates);

  @override
  int get hashCode => Object.hash(status, Object.hashAll(candidates));

  @override
  String toString() =>
      'OnlineSearchResult(${candidates.length}, ${status.name})';
}

/// C1 confidence of an external window.
enum ProfileConfidence { high, medium, low }

/// Drinking window of an external profile (C1 `window`).
class ProfileWindow {
  const ProfileWindow({
    required this.startYear,
    required this.peakYear,
    required this.endYear,
  });

  final int startYear;
  final int peakYear;
  final int endYear;

  @override
  bool operator ==(Object other) =>
      other is ProfileWindow &&
      other.startYear == startYear &&
      other.peakYear == peakYear &&
      other.endYear == endYear;

  @override
  int get hashCode => Object.hash(startYear, peakYear, endYear);
}

/// Answer of [WineCatalog.getWineProfile] (C1). With the current sources
/// [found] is always false, [window] absent and [pairings] empty (BR3.1):
/// U4 then copies [wineType], [region] and [denomination] into the empty
/// fields of `WineFacts` instead of passing an `ExternalProfile` to C2.
class WineProfileResult {
  const WineProfileResult({
    required this.found,
    this.window,
    this.confidence,
    this.pairings = const [],
    this.wineType,
    this.region,
    this.denomination,
  });

  final bool found;
  final ProfileWindow? window;
  final ProfileConfidence? confidence;
  final List<String> pairings;
  final CatalogWineType? wineType;
  final String? region;
  final String? denomination;

  @override
  bool operator ==(Object other) =>
      other is WineProfileResult &&
      other.found == found &&
      other.window == window &&
      other.confidence == confidence &&
      _listEquals(other.pairings, pairings) &&
      other.wineType == wineType &&
      other.region == region &&
      other.denomination == denomination;

  @override
  int get hashCode => Object.hash(
    found,
    window,
    confidence,
    Object.hashAll(pairings),
    wineType,
    region,
    denomination,
  );

  @override
  String toString() => 'WineProfileResult(found: $found)';
}

/// Why an input was rejected (C1 errors).
enum CatalogErrorCode {
  queryTooShort,
  queryTooLong,
  textTooLong,
  invalidBarcode,
}

/// The only exception of the catalog: an invalid input. It carries [code]
/// and a fixed English message, never the value received, so it cannot
/// bring user text into a log (NFR4.5, NFR8.3).
class CatalogArgumentError extends ArgumentError {
  CatalogArgumentError(this.code) : super(_messages[code]);

  final CatalogErrorCode code;

  static const Map<CatalogErrorCode, String> _messages = {
    CatalogErrorCode.queryTooShort:
        'query shorter than 2 characters after normalisation',
    CatalogErrorCode.queryTooLong: 'query longer than 120 characters',
    CatalogErrorCode.textTooLong: 'label text longer than 4000 characters',
    CatalogErrorCode.invalidBarcode: 'barcode must have 8, 12 or 13 digits',
  };

  @override
  String toString() => 'CatalogArgumentError(${code.name}): $message';
}

/// The wine catalog (C1 v1). Implemented by `CatalogCoordinator`.
///
/// Only [CatalogArgumentError] is ever thrown. A missing network, a slow or
/// failing Open Food Facts give internal-only results, `matched: false` or
/// `null`, never an error (BR2.2).
abstract interface class WineCatalog {
  /// Immediate, internal-only suggestions while typing (BR1.1): cellar
  /// wines first, then denominations; at most 10.
  SuggestResult suggestWines(
    String query, {
    CatalogLocale locale = CatalogLocale.en,
    List<CellarWineRef>? cellarWines,
  });

  /// Open Food Facts suggestions only, from the cache or within the request
  /// budget (BR1.2). U4 calls it after a 600 ms pause in typing.
  Future<SuggestResult> suggestExternal(
    String query, {
    CatalogLocale locale = CatalogLocale.en,
  });

  /// The wine of a label (label-recognition BR3.1-BR3.4): the merged text
  /// of front and back (at most 4000 characters) and the barcode read, if
  /// any, through the lookup order offline barcode, offline text, internal
  /// denomination and, only with a network and Open Food Facts on, online
  /// barcode then text.
  Future<LabelMatchResult> matchLabel(
    String text, {
    String? barcode,
    CatalogLocale locale = CatalogLocale.en,
  });

  /// "Cerca online" (label-recognition BR4.2, BR4.3): [query] is 1 to 120
  /// characters of words or a barcode. Offline results first, then Open
  /// Food Facts ones when possible.
  Future<OnlineSearchResult> searchOnline(
    String query, {
    CatalogLocale locale = CatalogLocale.en,
  });

  /// Type, region and denomination known for a wine (BR3.1). Never calls
  /// Open Food Facts.
  Future<WineProfileResult> getWineProfile(
    String name, {
    String? producer,
    int? vintage,
  });

  /// The wine with this EAN-8, UPC-A or EAN-13 barcode, or `null` (BR1.5).
  Future<WineCandidate?> lookupBarcode(String code);
}

String? _stringOrNull(Object? value) =>
    value is String && value.isNotEmpty ? value : null;

T? _enumByName<T extends Enum>(List<T> values, Object? name) {
  if (name is! String) return null;
  for (final value in values) {
    if (value.name == name) return value;
  }
  return null;
}

bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
