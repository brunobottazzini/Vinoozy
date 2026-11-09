// One wine of the offline database and its manifest (label-recognition
// entities.md `OfflineWine`, `OfflineWineDb`; functional-spec.md D1). Pure
// Dart: the record is written by tool/build_wine_db.dart and read by the app
// in a background isolate. A damaged line is dropped, never thrown
// (NFR4.6).

import 'dart:convert';

import 'package:estimation/estimation.dart' show WineLevel, WineStyle, WineType;

import '../internal_catalog.dart' show catalogTypeOf;
import '../off/open_food_facts_source.dart' show normalizeBarcode;
import '../wine_catalog.dart';

/// Version of the line format written by the build tool and read by the
/// app; a manifest with another version is refused.
// wine-style-profiles (BR9.2): format 2 adds the level `l` and the style
// `s`, and `t` is the Type preselected by `classifyWine`. The loader reads
// format 1 too, without them.
const int wineDbFormatVersion = 2;

/// One wine of the offline database. Only public product data: barcode,
/// name, producer, type, denomination, country and vintage (NFR3.7).
class WineDbRecord {
  const WineDbRecord({
    required this.code,
    required this.name,
    this.producer,
    this.wineType,
    this.denomination,
    this.country,
    this.vintage,
    this.level,
    this.style,
  });

  /// Shortest and longest name kept (BR2.1).
  static const int minName = 2;
  static const int maxName = 120;

  /// Longest producer and denomination kept.
  static const int maxText = 120;

  /// Vintages accepted (BR2.3).
  static const int minVintage = 1900;
  static const int maxVintage = 2100;

  /// Normalised EAN-8 or EAN-13 barcode (8 or 13 digits).
  final String code;
  final String name;
  final String? producer;
  final WineType? wineType;
  final String? denomination;

  /// ISO 3166-1 alpha-2 code, upper case.
  final String? country;
  final int? vintage;

  /// Level and Style preselected by the tool (BR9.2); `null` in format 1.
  final WineLevel? level;
  final WineStyle? style;

  /// The compact form of one line (short keys keep the file small, D1);
  /// absent fields are left out.
  Map<String, Object> toJson() => {
    'b': code,
    'n': name,
    'p': ?producer,
    't': ?wineType?.name,
    'd': ?denomination,
    'c': ?country,
    'v': ?vintage,
    'l': ?level?.name,
    // BR9.2: a style only with a Type.
    if (wineType != null) 's': ?style?.name,
  };

  /// One line of `wines.jsonl`.
  String toJsonLine() => jsonEncode(toJson());

  /// The record of [json], or `null` when a required field is missing or a
  /// field is out of range (a damaged line, NFR4.6). Optional fields of the
  /// wrong type count as absent.
  static WineDbRecord? fromJson(Object? json) {
    if (json is! Map) return null;
    final rawCode = json['b'];
    final code = rawCode is String ? normalizeBarcode(rawCode) : null;
    final name = _text(json['n'], maxName);
    if (code == null || name == null || name.length < minName) return null;
    final vintage = json['v'];
    final country = json['c'];
    return WineDbRecord(
      code: code,
      name: name,
      producer: _text(json['p'], maxText),
      wineType: WineType.tryParse(json['t'] is String ? json['t'] : null),
      denomination: _text(json['d'], maxText),
      country: country is String && _isCountryCode(country) ? country : null,
      vintage: vintage is int && vintage >= minVintage && vintage <= maxVintage
          ? vintage
          : null,
      level: WineLevel.tryParse(json['l']),
      style: WineStyle.tryParse(json['s']),
    );
  }

  /// The record of one JSON line, or `null` for a damaged line.
  static WineDbRecord? fromJsonLine(String line) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) return null;
    try {
      return fromJson(jsonDecode(trimmed));
    } on FormatException {
      return null;
    }
  }

  /// The record as a proposal of the offline source.
  WineCandidate toCandidate() => WineCandidate(
    name: name,
    source: CandidateSource.offline,
    producer: producer,
    vintage: vintage,
    wineType: wineType == null ? null : catalogTypeOf(wineType!),
    denomination: denomination,
    barcode: code,
    country: country,
    // wine-style-profiles BR3.5: the Type as it is, never reduced.
    exactType: wineType,
    level: level,
    style: style,
  );

  static String? _text(Object? value, int maxLength) {
    if (value is! String) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.length > maxLength) return null;
    return trimmed;
  }

  static bool _isCountryCode(String value) =>
      RegExp(r'^[A-Z]{2}$').hasMatch(value);

  @override
  bool operator ==(Object other) =>
      other is WineDbRecord &&
      other.code == code &&
      other.name == name &&
      other.producer == producer &&
      other.wineType == wineType &&
      other.denomination == denomination &&
      other.country == country &&
      other.vintage == vintage &&
      other.level == level &&
      other.style == style;

  @override
  int get hashCode => Object.hash(
    code,
    name,
    producer,
    wineType,
    denomination,
    country,
    vintage,
    level,
    style,
  );

  // No name in the string form: it may end up in a log.
  @override
  String toString() => 'WineDbRecord()';
}

/// Where the wines of the database come from (`source` of `manifest.json`).
enum WineDbSource {
  /// The real Open Food Facts export: its data carry the ODbL attribution.
  openFoodFacts('Open Food Facts'),

  /// The hand-written sample of tool/fixtures/ (built with
  /// `--allow-small-sample`): invented data, never attributed to Open Food
  /// Facts and never promoted to production (code-generation review R-02).
  sample('sample');

  const WineDbSource(this.wireName);

  /// The value written in `manifest.json`.
  final String wireName;

  /// The source of [value]: `Open Food Facts`, or absent in a manifest
  /// written before the field had a choice, is the real export; `sample`
  /// and any unknown value are the sample, so unknown data are never
  /// attributed to Open Food Facts.
  static WineDbSource fromWire(Object? value) =>
      value == null || value == openFoodFacts.wireName ? openFoodFacts : sample;
}

/// `manifest.json` of the database: export date, number of wines, source
/// and format version (entities.md `OfflineWineDb`).
class WineDbManifest {
  const WineDbManifest({
    required this.exportDate,
    required this.wineCount,
    this.formatVersion = wineDbFormatVersion,
    this.source = WineDbSource.openFoodFacts,
    this.classifiedTypeShare,
  });

  /// Date of the Open Food Facts export the database was built from.
  final DateTime exportDate;
  final int wineCount;
  final int formatVersion;
  final WineDbSource source;

  /// Share of the wines with a Type, measured by the tool (BR9.3, BR9.5);
  /// `null` in format 1.
  final double? classifiedTypeShare;

  /// Whether the database is the hand-written sample (R-02).
  bool get isSample => source == WineDbSource.sample;

  Map<String, Object> toJson() => {
    'formatVersion': formatVersion,
    'exportDate': _date(exportDate),
    'wineCount': wineCount,
    'source': source.wireName,
    'classifiedTypeShare': ?classifiedTypeShare,
    // The sample is invented: no Open Food Facts licence applies to it.
    if (!isSample) 'license': 'ODbL-1.0',
  };

  /// The manifest of [json], or `null` when it is not a valid one.
  static WineDbManifest? fromJson(Object? json) {
    if (json is! Map) return null;
    final version = json['formatVersion'];
    final count = json['wineCount'];
    final date = json['exportDate'];
    if (version is! int || count is! int || date is! String) return null;
    final parsed = DateTime.tryParse(date);
    if (parsed == null || count < 0) return null;
    return WineDbManifest(
      exportDate: DateTime.utc(parsed.year, parsed.month, parsed.day),
      wineCount: count,
      formatVersion: version,
      source: WineDbSource.fromWire(json['source']),
      classifiedTypeShare: switch (json['classifiedTypeShare']) {
        final num share when share >= 0 && share <= 1 => share.toDouble(),
        _ => null,
      },
    );
  }

  static String _date(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

/// The records of the lines of `wines.jsonl` and how many were dropped as
/// damaged (NFR4.6).
({List<WineDbRecord> records, int skipped}) parseWineDbLines(
  Iterable<String> lines,
) {
  final records = <WineDbRecord>[];
  var skipped = 0;
  for (final line in lines) {
    if (line.trim().isEmpty) continue;
    final record = WineDbRecord.fromJsonLine(line);
    if (record == null) {
      skipped++;
    } else {
      records.add(record);
    }
  }
  return (records: records, skipped: skipped);
}
