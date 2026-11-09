// Builds the offline wine database of the app from the public Open Food
// Facts export (label-recognition FR2.1, functional-spec.md D2, BR2.1-BR2.4,
// NFR1.2, NFR2.8, NFR4.7, NFR5.8).
//
//   dart run tool/build_wine_db.dart --input <export.csv.gz> \
//     --output assets/wine_db/ [--export-date YYYY-MM-DD] \
//     [--skip-freshness-check] [--allow-small-sample]
//
// - The export (tab-separated CSV, gzip or plain) is read line by line, never
//   loaded whole: the full export is over 9 GB uncompressed (NFR2.8).
// - It is downloaded by hand by the owner, at most once per release, from the
//   file Open Food Facts publishes for full downloads; no CI job downloads it
//   and the API is never paged through (NFR5.8).
// - Only wines are kept (BR2.1); type, denomination, country and vintage are
//   derived (BR2.2, BR2.3); the result must pass the plausibility check
//   (BR2.4) and the size limits: 3 MB compressed (NFR1.2) and 30 MB
//   uncompressed (owner's decision, message 38a2e81d; never raised without
//   the owner). Otherwise nothing is written and the previous database stays
//   (NFR4.7).
// - Output: wines.jsonl.gz and manifest.json, only public product fields
//   (NFR3.7).
//
// `--allow-small-sample` lowers the 5000-wine floor to 1: only for the
// hand-written sample of tool/fixtures/, never for a release database. It
// also writes `"source": "sample"` (and no licence) in the manifest, so the
// app never attributes the sample to Open Food Facts and
// tool/check_wine_db_release.sh refuses it before production (review R-02).
//
// wine-style-profiles (F3, BR9.1-BR9.4): every wine kept is classified with
// `classifyWine` of the estimation package, the same function as the form
// and the migration: the type of the tags is only its "database type"; the
// record stores the Type, Level and Style preselected (format 2), and the
// manifest the share of wines with a Type (`classifiedTypeShare`). Products
// that are not wine (seltzer, cider...) are dropped as excluded categories.
//
// The wine knowledge below (type tags, excluded categories, denomination
// markers) is decided at Code Generation (project.md correction of
// 2026-11-04); the reasons are in code-summary.md of the intent.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:estimation/estimation.dart'
    show WineType, classifyWine, findAppellation, recognizeDenomination;
import 'package:vinoozy/catalog/core/off/open_food_facts_source.dart'
    show normalizeBarcode;
import 'package:vinoozy/catalog/core/offline/wine_db_record.dart';
import 'package:vinoozy/cellar/domain/wine_origins.dart' show WineOrigins;
import 'package:vinoozy/label/core/barcode_filter.dart' show BarcodeFilter;

/// File names written in the output folder.
const String winesFileName = 'wines.jsonl.gz';
const String manifestFileName = 'manifest.json';

/// The limits of a build. The defaults are the decided ones; tests inject
/// small values to prove each check.
class BuildLimits {
  const BuildLimits({
    this.maxCompressedBytes = 3 * 1024 * 1024,
    this.maxUncompressedBytes = 30 * 1024 * 1024,
    this.minWines = 5000,
    this.maxExportAge = const Duration(days: 180),
  });

  /// NFR1.2: `wines.jsonl.gz` at most 3 MB.
  final int maxCompressedBytes;

  /// Owner's decision (38a2e81d): the Open Food Facts data at most 30 MB
  /// uncompressed.
  final int maxUncompressedBytes;

  /// BR2.4: fewer wines means a broken export or filter.
  final int minWines;

  /// BR2.4: an older export is refused unless the check is skipped.
  final Duration maxExportAge;
}

/// Why a row of the export was not kept.
enum DropReason {
  notWine,
  excludedCategory,
  invalidBarcode,
  invalidName,
  duplicate,
}

/// Categories that make a product "not a wine" even with `en:wines` (BR2.1):
/// jams, juices, vinegars, sauces and foods mis-tagged as wine.
const Set<String> excludedCategories = {
  'en:jams',
  'en:fruit-preserves',
  'en:spreads',
  'en:juices',
  'en:fruit-juices',
  'en:grape-juices',
  'en:vinegars',
  'en:wine-vinegars',
  'en:balsamic-vinegars',
  'en:sauces',
  'en:condiments',
  'en:cooking-helpers',
  'en:meals',
  'en:soups',
};

/// Markers of an appellation at the end of a category tag (BR2.3), such as
/// `fr:pomerol-aoc`.
const List<String> denominationMarkers = [
  'docg',
  'doc',
  'doca',
  'aoc',
  'aop',
  'igt',
  'igp',
  'dop',
  'do',
  'pdo',
  'pgi',
];

/// The wine of one row of the export, or why it is dropped (BR2.1-BR2.3).
/// Only public product fields are read; every other column, such as the
/// contributor, is ignored (NFR3.7).
({WineDbRecord? record, DropReason? reason}) recordOfRow(
  Map<String, String> row,
) {
  final tags = _tags(row['categories_tags']);
  if (!tags.contains('en:wines')) {
    return (record: null, reason: DropReason.notWine);
  }
  if (tags.any(excludedCategories.contains)) {
    return (record: null, reason: DropReason.excludedCategory);
  }
  final code = normalizeBarcode((row['code'] ?? '').trim());
  if (code == null || !BarcodeFilter.hasValidCheckDigit(code)) {
    return (record: null, reason: DropReason.invalidBarcode);
  }
  final name = _clean(row['product_name']);
  if (name == null ||
      name.length < WineDbRecord.minName ||
      name.length > WineDbRecord.maxName) {
    return (record: null, reason: DropReason.invalidName);
  }
  final producer = _firstBrand(row['brands']);
  final denomination = denominationOf(name, tags);
  final country = countryOfTags(row['countries_tags']);
  final vintage = vintageOf(name, row['quantity']);
  final preselection = classifyWine(
    name,
    producer: producer,
    denomination: denomination,
    dbType: wineTypeOfTags(tags),
    country: country,
    vintage: vintage,
  );
  if (preselection.nonWine) {
    return (record: null, reason: DropReason.excludedCategory);
  }
  return (
    record: WineDbRecord(
      code: code,
      name: name,
      producer: producer,
      wineType: preselection.wineType,
      denomination: denomination,
      country: country,
      vintage: vintage,
      level: preselection.wineType == null ? null : preselection.level,
      style: preselection.style,
    ),
    reason: null,
  );
}

/// BR9.5: the share of [records] with a Type, rounded to 4 decimals.
double classifiedTypeShareOf(List<WineDbRecord> records) {
  if (records.isEmpty) return 0;
  final typed = records.where((r) => r.wineType != null).length;
  return (typed * 10000 / records.length).round() / 10000;
}

/// BR2.2: the type from the category tags; style before colour (a fortified
/// or sweet wine ages like one whatever its colour, a sparkling one is a
/// sparkling wine first). `null` when the tags say nothing.
WineType? wineTypeOfTags(Set<String> tags) {
  // Whole words of the tags, so `en:portuguese-wines` is not a port.
  final words = {for (final tag in tags) ..._tagWords(tag)};
  bool any(Set<String> needles) => words.any(needles.contains);
  if (any(const {
    'port',
    'ports',
    'porto',
    'sherry',
    'sherries',
    'marsala',
    'fortified',
    'madeira',
  })) {
    return WineType.fortified;
  }
  if (any(const {'sweet', 'dessert', 'passito', 'icewines', 'icewine'})) {
    return WineType.sweet;
  }
  if (any(const {
    'champagne',
    'champagnes',
    'cremant',
    'cremants',
    'cava',
    'cavas',
    'franciacorta',
    'traditional',
  })) {
    return WineType.sparklingClassic;
  }
  if (any(const {'sparkling', 'prosecco', 'proseccos', 'frizzante'})) {
    return WineType.sparklingTank;
  }
  if (any(const {'rose', 'rosato', 'rosados'})) return WineType.rose;
  if (any(const {'white'})) return WineType.white;
  if (any(const {'red'})) {
    return any(const {'light', 'young', 'nouveau', 'primeur', 'primeurs'})
        ? WineType.redLight
        : WineType.redStructured;
  }
  return null;
}

/// BR2.3: a denomination of the internal catalog named in the product name
/// or a category; otherwise a category ending with an appellation marker
/// (`fr:pomerol-aoc` gives "Pomerol AOC"); otherwise `null`.
String? denominationOf(String name, Set<String> tags) {
  final fromName = recognizeDenomination(name);
  if (fromName != null) return fromName.displayName;
  // wine-style-profiles BR9.1: the whole appellation table (2424 rows), not
  // only the Italian catalog; weak names (common words) do not count here.
  final world = findAppellation(name, includeWeak: false);
  if (world != null) return world.displayName;
  for (final tag in tags) {
    final words = _tagWords(tag);
    if (words.isEmpty) continue;
    final known = recognizeDenomination(words.join(' '));
    if (known != null) return known.displayName;
    final marker = words.last;
    if (words.length > 1 && denominationMarkers.contains(marker)) {
      final place = words
          .sublist(0, words.length - 1)
          .map((w) => w[0].toUpperCase() + w.substring(1))
          .join(' ');
      return '$place ${marker.toUpperCase()}';
    }
  }
  return null;
}

/// BR2.3: the ISO code of the first country tag (`en:italy` gives `IT`), or
/// `null` when it is not a known country.
String? countryOfTags(String? countriesTags) {
  final first = _tags(countriesTags).firstOrNull;
  if (first == null) return null;
  final words = _tagWords(first);
  if (words.isEmpty) return null;
  return WineOrigins.countryNamed(words.join(' '))?.code;
}

/// BR2.3: four digits 1900-2100 in the name, else in the quantity.
int? vintageOf(String name, String? quantity) {
  for (final text in [name, quantity]) {
    if (text == null) continue;
    for (final match in RegExp(r'(?<!\d)(\d{4})(?!\d)').allMatches(text)) {
      final year = int.parse(match.group(1)!);
      if (year >= WineDbRecord.minVintage && year <= WineDbRecord.maxVintage) {
        return year;
      }
    }
  }
  return null;
}

final RegExp _wineTag = RegExp('en:wines', caseSensitive: false);

/// Whether the raw [line] of the export may be a wine: it holds `en:wines`
/// in any case. Conservative: every row recordOfRow keeps passes it.
bool mayBeWineLine(String line) => _wineTag.hasMatch(line);

/// The wines of an export read line by line, with the dropped rows counted
/// by reason. The first line is the header; a duplicated barcode keeps the
/// first row (BR2.4).
class ExportReader {
  final List<WineDbRecord> records = [];
  final Map<DropReason, int> dropped = {};
  final Set<String> _codes = {};
  List<String>? _header;
  int rows = 0;

  void addLine(String line) {
    if (line.trim().isEmpty) return;
    final cells = line.split('\t');
    final header = _header;
    if (header == null) {
      _header = [for (final cell in cells) cell.trim()];
      return;
    }
    rows++;
    // wine-style-profiles NFR3.3 (loop-back 1): a row is a wine only with
    // the tag `en:wines` (recordOfRow, compared lower-case), so a line whose
    // raw text does not hold it, in any case, is dropped as notWine before
    // it is split into a map: same result, without the cost of the 4.9
    // million rows of other products.
    if (!mayBeWineLine(line)) {
      _drop(DropReason.notWine);
      return;
    }
    final row = <String, String>{
      for (var i = 0; i < header.length && i < cells.length; i++)
        header[i]: cells[i],
    };
    final result = recordOfRow(row);
    final record = result.record;
    if (record == null) {
      _drop(result.reason!);
    } else if (!_codes.add(record.code)) {
      _drop(DropReason.duplicate);
    } else {
      records.add(record);
    }
  }

  /// A row known not to be a wine without reading it (RawLineFilter): the
  /// same count as [addLine] gives it.
  void addNonWineRow() {
    rows++;
    _drop(DropReason.notWine);
  }

  void _drop(DropReason reason) => dropped[reason] = (dropped[reason] ?? 0) + 1;
}

/// Reads [input] (gzip detected by its first bytes, else plain text) as a
/// stream of lines (NFR2.8). wine-style-profiles NFR3.3 (loop-back 1): the
/// lines are split on the bytes by [RawLineFilter], and only the header and
/// the lines that may be a wine are decoded and parsed.
Future<ExportReader> readExport(File input) async {
  final reader = ExportReader();
  final head = await input
      .openRead(0, 2)
      .fold<List<int>>([], (all, chunk) => all..addAll(chunk));
  Stream<List<int>> bytes = input.openRead();
  if (head.length == 2 && head[0] == 0x1f && head[1] == 0x8b) {
    bytes = bytes.transform(gzip.decoder);
  }
  final filter = RawLineFilter(reader);
  await bytes.forEach(filter.add);
  filter.close();
  return reader;
}

/// Splits the bytes of an export into lines as `LineSplitter` does (`\n`,
/// `\r` and `\r\n` end a line) and hands to [reader] only the lines it
/// must read: the header, the lines holding `en:wines` in any case (the
/// only ones that may be a wine, [mayBeWineLine]) and the rare lines
/// without a visible ASCII character (decoded, so blank lines stay
/// uncounted as before). Every other line is counted as a non-wine row
/// without being decoded: the result is the one of reading every line
/// (wine-style-profiles NFR3.3), at a fraction of the time.
class RawLineFilter {
  RawLineFilter(this.reader);

  final ExportReader reader;

  static const List<int> _needle = [
    0x65, 0x6e, 0x3a, 0x77, 0x69, 0x6e, 0x65, 0x73, // en:wines
  ];

  /// KMP fallback of [_needle].
  static final List<int> _fallback = () {
    final table = List<int>.filled(_needle.length, 0);
    var k = 0;
    for (var i = 1; i < _needle.length; i++) {
      while (k > 0 && _needle[i] != _needle[k]) {
        k = table[k - 1];
      }
      if (_needle[i] == _needle[k]) k++;
      table[i] = k;
    }
    return table;
  }();

  final BytesBuilder _line = BytesBuilder(copy: false);
  bool _headerDone = false;
  bool _matched = false;
  bool _visible = false;
  bool _afterCr = false;
  int _state = 0;

  void add(List<int> chunk) {
    var start = 0;
    final length = chunk.length;
    for (var i = 0; i < length; i++) {
      final byte = chunk[i];
      if (byte == 0x0a || byte == 0x0d) {
        if (byte == 0x0a && _afterCr && i == start && _line.isEmpty) {
          // The \n of a \r\n: the line already ended.
          _afterCr = false;
          start = i + 1;
          continue;
        }
        _end(chunk, start, i);
        _afterCr = byte == 0x0d;
        start = i + 1;
        continue;
      }
      _afterCr = false;
      if (byte > 0x20 && byte < 0x7f) _visible = true;
      if (!_matched) {
        final lower = byte >= 0x41 && byte <= 0x5a ? byte | 0x20 : byte;
        while (_state > 0 && lower != _needle[_state]) {
          _state = _fallback[_state - 1];
        }
        if (lower == _needle[_state]) _state++;
        if (_state == _needle.length) _matched = true;
      }
    }
    if (start < length) _line.add(chunk.sublist(start));
  }

  /// The last line, when the export does not end with a line break.
  void close() {
    if (_line.isNotEmpty || _matched || _visible) _end(const [], 0, 0);
  }

  void _end(List<int> chunk, int start, int end) {
    final needsText = !_headerDone || _matched || !_visible;
    if (needsText) {
      if (end > start) _line.add(chunk.sublist(start, end));
      reader.addLine(
        const Utf8Decoder(allowMalformed: true).convert(_line.takeBytes()),
      );
      _headerDone = true;
    } else {
      _line.clear();
      reader.addNonWineRow();
    }
    _matched = false;
    _visible = false;
    _state = 0;
  }
}

/// The encoded database, ready to be written.
class EncodedWineDb {
  const EncodedWineDb(this.uncompressed, this.compressed, this.manifest);

  final List<int> uncompressed;
  final List<int> compressed;
  final WineDbManifest manifest;
}

/// Encodes [records] as `wines.jsonl` and gzip; [source] goes in the
/// manifest (`sample` for a build with `--allow-small-sample`).
EncodedWineDb encodeWineDb(
  List<WineDbRecord> records,
  DateTime exportDate, {
  WineDbSource source = WineDbSource.openFoodFacts,
}) {
  final buffer = StringBuffer();
  for (final record in records) {
    buffer.writeln(record.toJsonLine());
  }
  final uncompressed = utf8.encode(buffer.toString());
  return EncodedWineDb(
    uncompressed,
    GZipCodec(level: 9).encode(uncompressed),
    WineDbManifest(
      exportDate: exportDate,
      wineCount: records.length,
      source: source,
      classifiedTypeShare: classifiedTypeShareOf(records),
    ),
  );
}

/// BR2.4 and the size limits: the list of failures, empty when the
/// database may be written.
List<String> checkWineDb(
  ExportReader export,
  EncodedWineDb encoded, {
  required DateTime now,
  required BuildLimits limits,
  required bool skipFreshnessCheck,
}) {
  final failures = <String>[];
  final count = export.records.length;
  if (count < limits.minWines) {
    failures.add('only $count wines, at least ${limits.minWines} expected');
  }
  final codes = {for (final record in export.records) record.code};
  if (codes.length != count) failures.add('duplicated barcodes');
  final badNames = export.records.where(
    (r) =>
        r.name.length < WineDbRecord.minName ||
        r.name.length > WineDbRecord.maxName,
  );
  if (badNames.isNotEmpty) failures.add('invalid names');
  final age = now.difference(encoded.manifest.exportDate);
  if (!skipFreshnessCheck && age > limits.maxExportAge) {
    failures.add(
      'export of ${age.inDays} days ago, at most '
      '${limits.maxExportAge.inDays} (use --skip-freshness-check)',
    );
  }
  if (encoded.uncompressed.length > limits.maxUncompressedBytes) {
    failures.add(
      'uncompressed data ${encoded.uncompressed.length} bytes, over '
      '${limits.maxUncompressedBytes} (30 MB limit set by the owner)',
    );
  }
  if (encoded.compressed.length > limits.maxCompressedBytes) {
    failures.add(
      '$winesFileName ${encoded.compressed.length} bytes, over '
      '${limits.maxCompressedBytes} (NFR1.2)',
    );
  }
  return failures;
}

/// Writes the two files through temporary names and renames them, so a
/// failed write leaves the previous database whole.
Future<void> writeWineDb(Directory output, EncodedWineDb encoded) async {
  await output.create(recursive: true);
  final wines = File('${output.path}/$winesFileName');
  final manifest = File('${output.path}/$manifestFileName');
  final winesTemp = File('${wines.path}.tmp');
  final manifestTemp = File('${manifest.path}.tmp');
  await winesTemp.writeAsBytes(encoded.compressed, flush: true);
  await manifestTemp.writeAsString(
    '${const JsonEncoder.withIndent('  ').convert(encoded.manifest.toJson())}\n',
    flush: true,
  );
  await winesTemp.rename(wines.path);
  await manifestTemp.rename(manifest.path);
}

/// The command line; returns the exit code (0 written, 1 refused, 2 usage).
Future<int> runBuildWineDb(
  List<String> args, {
  DateTime? now,
  BuildLimits limits = const BuildLimits(),
  StringSink? out,
  StringSink? err,
}) async {
  final stdoutSink = out ?? stdout;
  final stderrSink = err ?? stderr;
  final options = _Options.parse(args);
  if (options == null) {
    stderrSink.writeln(
      'usage: dart run tool/build_wine_db.dart --input <export.csv.gz> '
      '--output <folder> [--export-date YYYY-MM-DD] '
      '[--skip-freshness-check] [--allow-small-sample]',
    );
    return 2;
  }
  final input = File(options.input);
  if (!input.existsSync()) {
    stderrSink.writeln('build_wine_db: input ${options.input} not found');
    return 2;
  }
  final exportDate = options.exportDate ?? _dateOf(input.lastModifiedSync());
  final effective = options.allowSmallSample
      ? BuildLimits(
          maxCompressedBytes: limits.maxCompressedBytes,
          maxUncompressedBytes: limits.maxUncompressedBytes,
          minWines: 1,
          maxExportAge: limits.maxExportAge,
        )
      : limits;
  final ExportReader export;
  try {
    export = await readExport(input);
  } on FormatException catch (error) {
    stderrSink.writeln('build_wine_db: unreadable export (${error.message})');
    return 1;
  }
  final encoded = encodeWineDb(
    export.records,
    exportDate,
    source: options.allowSmallSample
        ? WineDbSource.sample
        : WineDbSource.openFoodFacts,
  );
  final failures = checkWineDb(
    export,
    encoded,
    now: now ?? DateTime.now().toUtc(),
    limits: effective,
    skipFreshnessCheck: options.skipFreshnessCheck,
  );
  final summary =
      '${export.rows} rows, ${export.records.length} wines kept, dropped: '
      '${[for (final e in export.dropped.entries) '${e.key.name} ${e.value}'].join(', ')}';
  if (failures.isNotEmpty) {
    stderrSink
      ..writeln('build_wine_db: FAILED, the database is not updated')
      ..writeln(summary);
    for (final failure in failures) {
      stderrSink.writeln('  - $failure');
    }
    return 1;
  }
  await writeWineDb(Directory(options.output), encoded);
  stdoutSink
    ..writeln('build_wine_db: OK, ${options.output}')
    ..writeln(summary)
    ..writeln(
      '$winesFileName ${encoded.compressed.length} bytes '
      '(${encoded.uncompressed.length} uncompressed), export date '
      '${encoded.manifest.toJson()['exportDate']}, source '
      '${encoded.manifest.source.wireName}',
    )
    // BR9.5: the share is recorded; 90% is the target of FR2.1.
    ..writeln(
      'classifiedTypeShare ${encoded.manifest.classifiedTypeShare} '
      '(target 0.9)',
    );
  return 0;
}

Future<void> main(List<String> args) async {
  exitCode = await runBuildWineDb(args);
}

class _Options {
  _Options({
    required this.input,
    required this.output,
    this.exportDate,
    this.skipFreshnessCheck = false,
    this.allowSmallSample = false,
  });

  final String input;
  final String output;
  final DateTime? exportDate;
  final bool skipFreshnessCheck;
  final bool allowSmallSample;

  static _Options? parse(List<String> args) {
    String? input;
    String? output;
    DateTime? exportDate;
    var skip = false;
    var small = false;
    for (var i = 0; i < args.length; i++) {
      final arg = args[i];
      String? next() => i + 1 < args.length ? args[++i] : null;
      switch (arg) {
        case '--input':
          input = next();
        case '--output':
          output = next();
        case '--export-date':
          final value = next();
          final parsed = value == null ? null : DateTime.tryParse(value);
          if (parsed == null) return null;
          exportDate = _dateOf(parsed);
        case '--skip-freshness-check':
          skip = true;
        case '--allow-small-sample':
          small = true;
        default:
          return null;
      }
    }
    if (input == null || output == null) return null;
    return _Options(
      input: input,
      output: output,
      exportDate: exportDate,
      skipFreshnessCheck: skip,
      allowSmallSample: small,
    );
  }
}

DateTime _dateOf(DateTime moment) =>
    DateTime.utc(moment.year, moment.month, moment.day);

Set<String> _tags(String? value) => {
  for (final tag in (value ?? '').split(','))
    if (tag.trim().isNotEmpty) tag.trim().toLowerCase(),
};

/// `fr:pomerol-aoc` as `[pomerol, aoc]`.
List<String> _tagWords(String tag) {
  final colon = tag.indexOf(':');
  final body = colon < 0 ? tag : tag.substring(colon + 1);
  return [
    for (final word in body.split('-'))
      if (word.isNotEmpty) word,
  ];
}

String? _clean(String? value) {
  if (value == null) return null;
  final cleaned = String.fromCharCodes(
    value.runes.where((rune) => rune > 0x1F && (rune < 0x7F || rune > 0x9F)),
  ).trim().replaceAll(RegExp(r'\s+'), ' ');
  return cleaned.isEmpty ? null : cleaned;
}

String? _firstBrand(String? brands) {
  for (final brand in (brands ?? '').split(',')) {
    final cleaned = _clean(brand);
    if (cleaned != null && cleaned.length <= WineDbRecord.maxText) {
      return cleaned;
    }
  }
  return null;
}
