// Builds the generated appellation table of the estimation package from the
// official registers (label-autofill-windows D2, BR3.6, BR3.7, BR6.3,
// NFR4.5, NFR4.12, NFR4.13, NFR5.6).
//
//   dart run tool/build_appellations.dart --eambrosia <export.json|.csv> \
//     [--data tool/data/appellations] [--export-date YYYY-MM-DD] \
//     [--output packages/estimation/lib/src/generated/appellations.g.dart] \
//     [--manifest packages/estimation/lib/src/generated/appellations_manifest.json] \
//     [--allow-sample]
//
// - Inputs: the export of the public EU register eAmbrosia (wine PDOs and
//   PGIs; the JSON of its public API,
//   https://webgate.ec.europa.eu/eambrosia-api/api/geographical-indications,
//   or a CSV export; downloaded by hand into .cache/eambrosia/, never by a
//   CI job) and
//   the CSV files of tool/data/appellations/ for the countries outside the
//   EU (US AVAs, AU and NZ GIs, ZA Wine of Origin, AR, CL, BR and UY DOs,
//   CH AOCs). Only names are read: public geographical data.
// - Each row gets its country, its region when it is a region of
//   `WineOrigins`, its types and the model of its country and level
//   (BR3.7). A register gives no type: words of the name ("Spumante",
//   "Rosso", "Passito"...) choose them, otherwise light red, white and rosé.
// - The dedicated rows of the package win: a register row whose name is
//   already a dedicated form, or a grape (BR3.2), is left out.
// - Checks (BR3.6, NFR4.12): at least 1500 appellations in all, no
//   duplicate key, every model exists, every region valid; otherwise
//   nothing is written and the previous table stays. A row left without any
//   type of its model is dropped and counted (NFR4.13).
// - The output is sorted and stable: the same inputs give the same file,
//   already in `dart format` layout (NFR4.5).
//
// `--allow-sample` lifts the 1500 floor for the sample of tool/fixtures/
// (eambrosia_sample.csv) until the real export is downloaded in Build and
// Test; it writes `"source": "sample"` in the manifest, which
// tool/check_appellations_release.sh refuses before production, as the
// sample wine database (review R-02 of label-recognition).
//
// The wine knowledge below (type words of the names, models per country,
// weak names) is decided at Code Generation (project.md correction of
// 2026-11-04); the reasons are in code-summary.md of the intent.
import 'dart:convert';
import 'dart:io';

import 'package:estimation/estimation.dart';
import 'package:vinoozy/cellar/domain/wine_origins.dart' show WineOrigins;

/// Default paths, from the repository root.
const String defaultDataDir = 'tool/data/appellations';
const String defaultOutput =
    'packages/estimation/lib/src/generated/appellations.g.dart';
const String defaultManifest =
    'packages/estimation/lib/src/generated/appellations_manifest.json';

/// The least number of appellations, dedicated and generated (FR3.1).
const int minAppellations = 1500;

/// `source` of a build from the sample (refused before production).
const String sampleSource = 'sample';

/// `source` of a build from the real registers.
const String registerSource = 'eAmbrosia and official national registers';

/// One appellation read from a register.
class RegisterRow {
  const RegisterRow({
    required this.name,
    required this.country,
    required this.protection,
    this.region,
    this.types = const [],
    this.weak = false,
    this.aliases = const [],
  });

  final String name;

  /// ISO 3166-1 alpha-2 code.
  final String country;

  /// `PDO` or `PGI`; the non-EU registers are read as `PDO`.
  final String protection;

  /// A region given by the register file, checked against `WineOrigins`.
  final String? region;
  final List<WineType> types;
  final bool weak;
  final List<String> aliases;
}

/// Why the build stopped (NFR4.12).
class BuildFailure {
  const BuildFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// The result of [buildAppellations].
class AppellationBuild {
  const AppellationBuild({
    required this.rows,
    required this.failures,
    required this.dedicated,
    required this.read,
    required this.leftOut,
    required this.dropped,
  });

  /// The generated rows, sorted, in the format of `parseGeneratedRow`.
  final List<String> rows;
  final List<BuildFailure> failures;

  /// Dedicated rows of the package.
  final int dedicated;

  /// Register rows read.
  final int read;

  /// Rows left out because a dedicated row, a grape or an earlier row
  /// already has their name.
  final int leftOut;

  /// Rows dropped because none of their types is in their model (NFR4.13).
  final int dropped;

  int get total => dedicated + rows.length;
  bool get ok => failures.isEmpty;
}

/// Countries of the European Union read from eAmbrosia, by English name.
const Map<String, String> _countryNames = {
  'austria': 'AT', 'belgium': 'BE', 'bulgaria': 'BG', 'croatia': 'HR', //
  'cyprus': 'CY', 'czechia': 'CZ', 'czech republic': 'CZ', 'denmark': 'DK',
  'estonia': 'EE', 'finland': 'FI', 'france': 'FR', 'germany': 'DE', //
  'greece': 'GR', 'hungary': 'HU', 'ireland': 'IE', 'italy': 'IT', //
  'latvia': 'LV', 'lithuania': 'LT', 'luxembourg': 'LU', 'malta': 'MT', //
  'netherlands': 'NL', 'poland': 'PL', 'portugal': 'PT', 'romania': 'RO', //
  'slovakia': 'SK', 'slovenia': 'SI', 'spain': 'ES', 'sweden': 'SE', //
  'united kingdom': 'GB', 'united states': 'US', 'switzerland': 'CH', //
};

const Set<String> _newWorld = {'US', 'AU', 'NZ', 'ZA', 'AR', 'CL', 'BR', 'UY'};

/// The model of a row (BR3.7): country and level of protection.
String templateOf(String country, String protection) {
  final pgi = protection == 'PGI';
  return switch (country) {
    'IT' => pgi ? TemplateKeys.italyIgt : TemplateKeys.italyDoc,
    'FR' => pgi ? TemplateKeys.franceIgp : TemplateKeys.franceAoc,
    'ES' || 'PT' => TemplateKeys.iberia,
    'DE' || 'AT' => TemplateKeys.germanAustrian,
    'CH' => TemplateKeys.switzerland,
    _ when _newWorld.contains(country) => TemplateKeys.newWorld,
    _ => TemplateKeys.otherEu,
  };
}

/// Types chosen by the words of a name, `[]` when none says it.
List<WineType> typesFromName(String name) {
  final words = normalizeWineText(name).split(' ').toSet();
  bool any(Set<String> set) => words.any(set.contains);
  if (any(const {'liquoroso', 'porto', 'madeira', 'marsala', 'jerez'}) ||
      normalizeWineText(name).contains('vin doux naturel') ||
      normalizeWineText(name).contains('vino generoso')) {
    return const [WineType.fortified];
  }
  if (any(const {'passito', 'dolce', 'recioto', 'vinsanto'}) ||
      normalizeWineText(name).contains('vin santo')) {
    return const [WineType.sweet];
  }
  if (any(const {
    'spumante',
    'sekt',
    'cremant',
    'cava',
    'espumoso',
    'espumante',
    'mousseux',
    'franciacorta',
  })) {
    return any(const {'cremant', 'cava', 'franciacorta'}) ||
            normalizeWineText(name).contains('metodo classico')
        ? const [WineType.sparklingClassic]
        : const [WineType.sparklingTank];
  }
  if (any(const {'rosato', 'rose', 'rosado', 'chiaretto'})) {
    return const [WineType.rose];
  }
  if (any(const {'bianco', 'blanc', 'blanco', 'branco'})) {
    return const [WineType.white];
  }
  if (any(const {'rosso', 'rouge', 'tinto'})) {
    return const [WineType.redLight];
  }
  return const [];
}

/// Common words that a generated name may be: they count on a label only
/// next to an indicator (BR1.2).
const Set<String> _commonWords = {
  'terre',
  'colli',
  'valle',
  'monte',
  'isola',
  'costa',
  'riviera',
  'castello',
  'campagna',
  'collina',
  'mar',
  'sol',
  'cote',
  'cotes',
  // Register names of the real eAmbrosia export (Build and Test) that are
  // common words of a label text, or large cities of a producer's address:
  // with an indicator ("English Quality Wine PDO", "Verona IGT") they
  // still count.
  'english',
  'welsh',
  'drama',
  'agora',
  'atlantique',
  'mediterranee',
  'montana',
  'malta',
  'roma',
  'venezia',
  'verona',
  'modena',
};

bool _isWeakForm(String form, Set<String> regionForms) {
  if (wineCountryNames.containsKey(form)) return true;
  if (regionForms.contains(form)) return true;
  if (_commonWords.contains(form)) return true;
  final words = form.split(' ');
  return words.length == 1 && words.single.length <= 3;
}

/// Whether [form] is whole words inside a longer grape name: "avola" in
/// "nero d avola". On a label or in a name it is the grape, and a grape is
/// never a denomination (BR3.2), so the register row is left out like a
/// row named as a grape.
bool _isInsideGrapeName(String form) {
  final padded = ' $form ';
  return grapeForms.any(
    (grape) => grape != form && ' $grape '.contains(padded),
  );
}

/// Every form of every region of `WineOrigins`, normalised.
Set<String> _regionForms() => {
  for (final country in WineOrigins.wineCountryCodes)
    for (final region in WineOrigins.regionsOf(country))
      for (final form in region.forms) normalizeWineText(form),
};

/// Builds the generated rows from [rows] (BR3.6). Pure: the caller reads
/// and writes the files.
AppellationBuild buildAppellations(
  List<RegisterRow> rows, {
  bool allowSample = false,
}) {
  final failures = <BuildFailure>[];
  final dedicated = [
    for (final info in appellations)
      if (info.dedicated) info,
  ];
  final taken = <String>{
    for (final info in dedicated) ...info.forms,
    ...grapeForms,
  };
  final takenKeys = {for (final info in dedicated) info.key};
  final regionForms = _regionForms();
  final sorted = [for (final row in rows) _preferRegionName(row)]
    ..sort((a, b) {
      final byCountry = a.country.compareTo(b.country);
      if (byCountry != 0) return byCountry;
      final byName = normalizeWineText(a.name)
          .compareTo(normalizeWineText(b.name));
      if (byName != 0) return byName;
      return a.protection.compareTo(b.protection);
    });
  final out = <String>[];
  final keys = <String>{};
  var leftOut = 0;
  var dropped = 0;
  final dedicatedForms = {for (final info in dedicated) ...info.forms};
  for (final row in sorted) {
    final form = normalizeWineText(row.name);
    // A GI whose other name is a dedicated form is that dedicated row
    // (eAmbrosia "Toscano / Toscana" is the dedicated Toscana).
    if (form.isEmpty ||
        taken.contains(form) ||
        _startsWithAny(form, dedicatedForms) ||
        _isInsideGrapeName(form) ||
        row.aliases.any(
          (alias) => dedicatedForms.contains(normalizeWineText(alias)),
        )) {
      leftOut++;
      continue;
    }
    final model = templateOf(row.country, row.protection);
    final offsets = appellationTemplates[model];
    if (offsets == null) {
      failures.add(BuildFailure('model $model of ${row.name} does not exist'));
      continue;
    }
    final wanted = row.types.isNotEmpty
        ? row.types
        : (typesFromName(row.name).isNotEmpty
              ? typesFromName(row.name)
              : const [WineType.redLight, WineType.white, WineType.rose]);
    final types = [
      for (final type in wanted)
        if (offsets.containsKey(type)) type,
    ];
    if (types.isEmpty) {
      dropped++;
      continue;
    }
    String? region;
    final given = row.region;
    if (given != null && given.isNotEmpty) {
      region = WineOrigins.findRegion(row.country, given)?.canonical;
      if (region == null) {
        failures.add(
          BuildFailure(
            'region "$given" of ${row.name} is not a region of '
            '${row.country}',
          ),
        );
        continue;
      }
    } else {
      region = WineOrigins.findRegion(row.country, row.name)?.canonical;
    }
    final aliases = <String>[
      for (final alias in row.aliases)
        if (normalizeWineText(alias) case final normal
            when normal.isNotEmpty && normal != form && !taken.contains(normal))
          normal,
    ];
    final weak = <String>[
      for (final candidate in [form, ...aliases])
        if (row.weak || _isWeakForm(candidate, regionForms)) candidate,
    ];
    final key = _keyOf(form, row.country);
    if (!keys.add(key) || takenKeys.contains(key)) {
      failures.add(BuildFailure('duplicate key $key (${row.name})'));
      continue;
    }
    taken
      ..add(form)
      ..addAll(aliases);
    out.add(
      [
        key,
        row.name.trim(),
        row.country,
        region ?? '',
        model,
        types.map((type) => type.name).join(','),
        aliases.join(generatedListSeparator),
        weak.join(generatedListSeparator),
      ].join(generatedFieldSeparator),
    );
  }
  final total = dedicated.length + out.length;
  if (!allowSample && total < minAppellations) {
    failures.add(
      BuildFailure(
        'only $total appellations, at least $minAppellations expected: '
        'build from the real eAmbrosia export (docs/release-checklist.md)',
      ),
    );
  }
  return AppellationBuild(
    rows: out,
    failures: failures,
    dedicated: dedicated.length,
    read: rows.length,
    leftOut: leftOut,
    dropped: dropped,
  );
}

/// [row] named with the spelling of a region of the app when one of its
/// other names is that region: eAmbrosia lists "Toscano / Toscana", the
/// app shows "Toscana" as the region the user picks. The first name
/// becomes an alias. Other rows are returned as they are.
RegisterRow _preferRegionName(RegisterRow row) {
  for (final alias in row.aliases) {
    final region = WineOrigins.findRegion(row.country, alias)?.canonical;
    if (region == null ||
        normalizeWineText(region) != normalizeWineText(alias)) {
      continue;
    }
    return RegisterRow(
      name: alias,
      country: row.country,
      protection: row.protection,
      region: row.region,
      types: row.types,
      weak: row.weak,
      aliases: [
        row.name,
        for (final other in row.aliases)
          if (other != alias) other,
      ],
    );
  }
  return row;
}

/// Whether the words of [form] start with one of [forms]: "saint emilion
/// grand cru" starts with the dedicated "saint emilion", whose qualifiers
/// already cover it, so the register row is left out.
bool _startsWithAny(String form, Set<String> forms) {
  final words = form.split(' ');
  for (var length = 1; length < words.length; length++) {
    if (forms.contains(words.take(length).join(' '))) return true;
  }
  return false;
}

String _keyOf(String form, String country) {
  final words = form.split(' ');
  final buffer = StringBuffer(words.first);
  for (final word in words.skip(1)) {
    buffer
      ..write(word[0].toUpperCase())
      ..write(word.substring(1));
  }
  final base = buffer.toString();
  final cut = base.length > 58 ? base.substring(0, 58) : base;
  return '$cut$country';
}

// ---------------------------------------------------------------------------
// Reading the registers.

/// Splits one CSV line with [separator], `"` quoting and `""` escapes.
List<String> splitCsvLine(String line, String separator) {
  final fields = <String>[];
  final current = StringBuffer();
  var quoted = false;
  for (var i = 0; i < line.length; i++) {
    final char = line[i];
    if (quoted) {
      if (char == '"' && i + 1 < line.length && line[i + 1] == '"') {
        current.write('"');
        i++;
      } else if (char == '"') {
        quoted = false;
      } else {
        current.write(char);
      }
    } else if (char == '"') {
      quoted = true;
    } else if (char == separator) {
      fields.add(current.toString().trim());
      current.clear();
    } else {
      current.write(char);
    }
  }
  fields.add(current.toString().trim());
  return fields;
}

/// The data lines of a CSV text: no blank lines and no `#` comments.
List<String> _dataLines(String text) => [
  for (final line in const LineSplitter().convert(text))
    if (line.trim().isNotEmpty && !line.trimLeft().startsWith('#')) line,
];

int _column(List<String> header, List<String> names) {
  for (final name in names) {
    final at = header.indexOf(name);
    if (at >= 0) return at;
  }
  return -1;
}

/// Reads the eAmbrosia wine export: the columns name, country, GI type,
/// product category and status, whatever their order, separated by `,` or
/// `;`. Only registered wine rows are kept. Names with several language
/// versions ("Alto Adige / Südtirol") give one row with aliases.
List<RegisterRow> readEAmbrosia(String text) {
  final lines = _dataLines(text);
  if (lines.isEmpty) throw const FormatException('empty eAmbrosia export');
  final separator = lines.first.contains(';') ? ';' : ',';
  final header = [
    for (final field in splitCsvLine(lines.first, separator))
      field.toLowerCase(),
  ];
  final name = _column(header, const ['gi name', 'name', 'denomination']);
  final country = _column(header, const [
    'country',
    'country code',
    'countries',
  ]);
  final type = _column(header, const ['gi type', 'type', 'protection type']);
  final category = _column(header, const ['product category', 'category']);
  final status = _column(header, const ['status']);
  if (name < 0 || country < 0 || type < 0) {
    throw const FormatException(
      'eAmbrosia export without name, country or GI type',
    );
  }
  final rows = <RegisterRow>[];
  for (final line in lines.skip(1)) {
    final fields = splitCsvLine(line, separator);
    String field(int at) => at >= 0 && at < fields.length ? fields[at] : '';
    if (category >= 0 && !field(category).toLowerCase().contains('wine')) {
      continue;
    }
    if (status >= 0 && field(status).toLowerCase() != 'registered') continue;
    final code = _countryCode(field(country));
    final protection = _protection(field(type));
    if (code == null || protection == null) continue;
    final names = [
      for (final part in field(name).split(RegExp(r'\s+/\s+|;')))
        if (part.trim().isNotEmpty) part.trim(),
    ];
    if (names.isEmpty) continue;
    rows.add(
      RegisterRow(
        name: names.first,
        country: code,
        protection: protection,
        aliases: names.skip(1).toList(),
      ),
    );
  }
  return rows;
}

/// Reads the eAmbrosia register as its public API serves it
/// (https://webgate.ec.europa.eu/eambrosia-api/api/geographical-indications):
/// a JSON array with one object per GI. Only registered wines that are not
/// removed are kept. Only `protectedNames`, `transcriptions`, `countries`,
/// `giType`, `productType`, `status` and `removedFlag` are read: the
/// producer group fields of the export are never read.
///
/// A name in another script (Greek, Cyrillic, Chinese) has no form the app
/// can match, so the first name in Latin letters is the display name: a
/// protected name when one is in Latin letters, else its transcription
/// ("Τριφυλία" gives "Trifilia"). The other names are aliases. A GI of two
/// countries ("Maasvallei Limburg", BE and NL) takes the first one.
List<RegisterRow> readEAmbrosiaJson(String text) {
  final decoded = jsonDecode(text);
  if (decoded is! List) {
    throw const FormatException('eAmbrosia JSON export is not a list');
  }
  final rows = <RegisterRow>[];
  for (final item in decoded) {
    if (item is! Map) continue;
    final row = _jsonRow(item);
    if (row != null) rows.add(row);
  }
  return rows;
}

RegisterRow? _jsonRow(Map<dynamic, dynamic> item) {
  String text(String key) => (item[key] is String) ? item[key] as String : '';
  List<String> strings(String key) => [
    if (item[key] case final List<dynamic> list)
      for (final value in list)
        if (value is String && value.trim().isNotEmpty) value.trim(),
  ];
  if (text('productType').toUpperCase() != 'WINE') return null;
  if (text('status').toLowerCase() != 'registered') return null;
  if (item['removedFlag'] == true) return null;
  final countries = strings('countries');
  final code = countries.isEmpty ? null : _countryCode(countries.first);
  final protection = _protection(text('giType'));
  if (code == null || protection == null) return null;
  final names = [...strings('protectedNames'), ...strings('transcriptions')];
  final display = names.where(_isLatinName).firstOrNull;
  if (display == null) return null;
  return RegisterRow(
    name: display,
    country: code,
    protection: protection,
    aliases: [
      for (final name in names)
        if (name != display) name,
    ],
  );
}

/// Whether [name] is written in Latin letters (Latin-1 and Latin
/// Extended-A and B) and has a form the app can match.
bool _isLatinName(String name) {
  if (normalizeWineText(name).isEmpty) return false;
  for (final rune in name.runes) {
    final isLetter =
        String.fromCharCode(rune).toLowerCase() !=
        String.fromCharCode(rune).toUpperCase();
    if (isLetter && rune >= 0x250) return false;
  }
  return true;
}

/// Reads an eAmbrosia export in either format: the JSON of the public API
/// (text starting with `[`) or a CSV export (see [readEAmbrosia]).
List<RegisterRow> readEAmbrosiaExport(String text) =>
    text.trimLeft().startsWith('[')
    ? readEAmbrosiaJson(text)
    : readEAmbrosia(text);

String? _countryCode(String value) {
  final trimmed = value.trim();
  if (RegExp(r'^[A-Z]{2}$').hasMatch(trimmed)) return trimmed;
  return _countryNames[trimmed.toLowerCase()];
}

String? _protection(String value) => switch (value.trim().toUpperCase()) {
  'PDO' || 'DOP' || 'AOP' => 'PDO',
  'PGI' || 'IGP' => 'PGI',
  _ => null,
};

const Map<String, WineType> _typeCodes = {
  'rL': WineType.redLight,
  'rS': WineType.redStructured,
  'B': WineType.white,
  'Ro': WineType.rose,
  'SpC': WineType.sparklingClassic,
  'SpT': WineType.sparklingTank,
  'D': WineType.sweet,
  'F': WineType.fortified,
};

/// Reads one CSV of tool/data/appellations/: `name,country,region,types,
/// weak` with `#` comment lines on top (source, date, licence). Types are
/// codes separated by `|` (rL, rS, B, Ro, SpC, SpT, D, F); `weak` marks a
/// common word.
List<RegisterRow> readNonEuCsv(String text) {
  final lines = _dataLines(text);
  if (lines.isEmpty) return const [];
  final header = splitCsvLine(lines.first, ',');
  if (header.length < 2 || header[0] != 'name' || header[1] != 'country') {
    throw const FormatException(
      'expected the header name,country,region,types,weak',
    );
  }
  return [
    for (final line in lines.skip(1))
      if (splitCsvLine(line, ',') case final fields
          when fields.first.isNotEmpty)
        RegisterRow(
          name: fields[0],
          country: fields.length > 1 ? fields[1] : '',
          protection: 'PDO',
          region: fields.length > 2 && fields[2].isNotEmpty ? fields[2] : null,
          types: [
            if (fields.length > 3)
              for (final code in fields[3].split('|')) ?_typeCodes[code.trim()],
          ],
          weak: fields.length > 4 && fields[4] == 'weak',
        ),
  ];
}

// ---------------------------------------------------------------------------
// Output.

/// The generated Dart file for [build], in `dart format` layout.
String renderGeneratedFile(AppellationBuild build, {required String source}) {
  final buffer = StringBuffer()
    ..writeln(
      '// GENERATED by tool/build_appellations.dart: do not edit by hand.',
    )
    ..writeln('//')
    ..writeln('// Source: $source.')
    ..writeln(
      '// ${build.rows.length} generated rows, ${build.dedicated} dedicated '
      'rows in the package, ${build.total} in all.',
    )
    ..writeln('// Row format: key|name|country|region|model|types|aliases|weak')
    ..writeln('// (see parseGeneratedRow in appellations.dart).')
    ..writeln()
    ..writeln('/// Where the rows below come from.')
    ..writeln(_sourceDeclaration(source))
    ..writeln()
    ..writeln('/// Rows of the generated appellation table.');
  if (build.rows.isEmpty) {
    buffer.writeln('const List<String> generatedAppellationRows = [];');
  } else {
    buffer.writeln('const List<String> generatedAppellationRows = [');
    for (final row in build.rows) {
      buffer.writeln("  '${_escape(row)}',");
    }
    buffer.writeln('];');
  }
  return buffer.toString();
}

/// The `generatedAppellationsSource` declaration, on one line when it fits
/// in 80 columns, else split after `=` as `dart format` does.
String _sourceDeclaration(String source) {
  const head = 'const String generatedAppellationsSource =';
  final literal = "'${_escape(source)}';";
  final oneLine = '$head $literal';
  return oneLine.length <= 80 ? oneLine : '$head\n    $literal';
}

String _escape(String text) =>
    text.replaceAll(r'\', r'\\').replaceAll("'", r"\'").replaceAll(r'$', r'\$');

/// The manifest next to the generated file, read by
/// tool/check_appellations_release.sh.
String renderManifest(
  AppellationBuild build, {
  required String source,
  required String exportDate,
}) =>
    '${const JsonEncoder.withIndent('  ').convert({'formatVersion': 1, 'source': source, 'exportDate': exportDate, 'dedicatedRows': build.dedicated, 'generatedRows': build.rows.length, 'appellationCount': build.total, 'registerRows': build.read, 'leftOut': build.leftOut, 'droppedWithoutType': build.dropped})}\n';

// ---------------------------------------------------------------------------
// Command line.

class _Options {
  const _Options({
    required this.eambrosia,
    required this.data,
    required this.output,
    required this.manifest,
    required this.allowSample,
    this.exportDate,
  });

  final String eambrosia;
  final String data;
  final String output;
  final String manifest;
  final bool allowSample;
  final String? exportDate;

  static _Options? parse(List<String> args) {
    String? eambrosia;
    var data = defaultDataDir;
    var output = defaultOutput;
    var manifest = defaultManifest;
    var allowSample = false;
    String? exportDate;
    for (var i = 0; i < args.length; i++) {
      final arg = args[i];
      String? next() => i + 1 < args.length ? args[++i] : null;
      switch (arg) {
        case '--eambrosia':
          eambrosia = next();
        case '--data':
          data = next() ?? data;
        case '--output':
          output = next() ?? output;
        case '--manifest':
          manifest = next() ?? manifest;
        case '--export-date':
          exportDate = next();
        case '--allow-sample':
          allowSample = true;
        default:
          return null;
      }
    }
    if (eambrosia == null) return null;
    if (exportDate != null &&
        !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(exportDate)) {
      return null;
    }
    return _Options(
      eambrosia: eambrosia,
      data: data,
      output: output,
      manifest: manifest,
      allowSample: allowSample,
      exportDate: exportDate,
    );
  }
}

/// Runs the build; 0 when written, 1 when a check failed (nothing written),
/// 2 for a usage or input error.
Future<int> runBuildAppellations(
  List<String> args, {
  StringSink? out,
  StringSink? err,
}) async {
  final stdoutSink = out ?? stdout;
  final stderrSink = err ?? stderr;
  final options = _Options.parse(args);
  if (options == null) {
    stderrSink.writeln(
      'usage: dart run tool/build_appellations.dart '
      '--eambrosia <export.json|.csv> '
      '[--data <folder>] [--output <file>] [--manifest <file>] '
      '[--export-date YYYY-MM-DD] [--allow-sample]',
    );
    return 2;
  }
  final export = File(options.eambrosia);
  final dataDir = Directory(options.data);
  if (!export.existsSync() || !dataDir.existsSync()) {
    stderrSink.writeln('build_appellations: input not found');
    return 2;
  }
  final List<RegisterRow> rows;
  try {
    rows = [
      ...readEAmbrosiaExport(await export.readAsString()),
      for (final file
          in (dataDir.listSync().whereType<File>().toList()
            ..sort((a, b) => a.path.compareTo(b.path))))
        if (file.path.endsWith('.csv'))
          ...readNonEuCsv(await file.readAsString()),
    ];
  } on FormatException catch (error) {
    stderrSink.writeln(
      'build_appellations: unreadable input (${error.message})',
    );
    return 2;
  }
  final build = buildAppellations(rows, allowSample: options.allowSample);
  final summary =
      '${build.read} register rows, ${build.rows.length} generated, '
      '${build.leftOut} already dedicated or repeated, '
      '${build.dropped} without a type of their model; '
      '${build.total} appellations in all';
  if (!build.ok) {
    stderrSink
      ..writeln('build_appellations: FAILED, the table is not updated')
      ..writeln(summary);
    for (final failure in build.failures) {
      stderrSink.writeln('  - $failure');
    }
    return 1;
  }
  final source = options.allowSample ? sampleSource : registerSource;
  final exportDate =
      options.exportDate ??
      export.lastModifiedSync().toUtc().toIso8601String().substring(0, 10);
  await File(options.output)
      .writeAsString(renderGeneratedFile(build, source: source));
  await File(options.manifest).writeAsString(
    renderManifest(build, source: source, exportDate: exportDate),
  );
  stdoutSink
    ..writeln('build_appellations: OK, ${options.output} written')
    ..writeln(summary);
  return 0;
}

Future<void> main(List<String> args) async {
  exitCode = await runBuildAppellations(args);
}
