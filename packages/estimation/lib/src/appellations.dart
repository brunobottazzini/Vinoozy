// The joined appellation table of label-autofill-windows (D2, BR3.5, BR3.6):
// the 47 Italian rows of tables.dart, the hand-written world rows and the
// rows generated from the official registers, with the read-only view the
// app uses for the origin of a wine (`WineOrigins`, BR3.5) and the
// generator uses to leave out what the dedicated rows already cover.

import 'catalog.dart' show denominationLabels;
import 'generated/appellations.g.dart';
import 'grapes.dart';
import 'models.dart';
import 'recognizer.dart';
import 'tables.dart';
import 'world_tables.dart';

/// Separator of the fields of a generated row.
const String generatedFieldSeparator = '|';

/// Separator of the list fields (types use ',') of a generated row.
const String generatedListSeparator = ';';

/// Parses one row of `generatedAppellationRows`:
/// `key|name|country|region|model|types|aliases|weak aliases`, types
/// separated by ',' and aliases by ';'. Only the types the model has are
/// kept (BR3.7). Returns `null` for a malformed row or one left without a
/// type, which the generator never writes.
DenominationProfile? parseGeneratedRow(String row) {
  final parts = row.split(generatedFieldSeparator);
  if (parts.length != 8) return null;
  final [key, name, country, region, model, types, aliases, weak] = parts;
  final offsets = appellationTemplates[model];
  if (key.isEmpty || name.isEmpty || country.length != 2 || offsets == null) {
    return null;
  }
  final rowTypes = <WineType>[
    for (final name in types.split(','))
      if (WineType.tryParse(name) case final type?
          when offsets.containsKey(type) && type.name == name)
        type,
  ];
  if (rowTypes.isEmpty) return null;
  return DenominationProfile(
    aliases: _list(aliases),
    wineType: rowTypes.first,
    offsets: offsets[rowTypes.first]!,
    otherTypes: {for (final type in rowTypes.skip(1)) type: offsets[type]!},
    key: key,
    name: name,
    country: country,
    region: region.isEmpty ? null : region,
    weakAliases: _list(weak),
    templateKey: model,
  );
}

List<String> _list(String field) => [
  for (final item in field.split(generatedListSeparator))
    if (item.isNotEmpty) item,
];

/// The joined table: Italian rows, then world rows, then the generated rows
/// whose key and forms no earlier row has (BR3.6: dedicated rows win).
Map<String, DenominationProfile> buildDenominationTable() {
  final table = <String, DenominationProfile>{};
  final forms = <String>{};
  void add(String key, DenominationProfile row) {
    table[key] = row;
    for (final (form, _) in formsOf(row)) {
      forms.add(form);
    }
  }

  italianDenominationTable.forEach((key, row) {
    add(
      key,
      row.withOrigin(
        key: key,
        name: null,
        country: 'IT',
        region: denominationLabels[key]?.region,
      ),
    );
  });
  for (final row in worldDenominations) {
    final key = row.key ?? keyOfWords(tokenizeAll(row.name!));
    if (table.containsKey(key)) continue;
    add(
      key,
      row.withOrigin(
        key: key,
        name: row.name,
        country: row.country,
        region: row.region,
      ),
    );
  }
  for (final raw in generatedAppellationRows) {
    final row = parseGeneratedRow(raw);
    if (row == null || table.containsKey(row.key)) continue;
    if (formsOf(row).any((form) => forms.contains(form.$1))) continue;
    add(row.key!, row);
  }
  return Map.unmodifiable(table);
}

/// One appellation as the app and the generator see it.
class AppellationInfo {
  const AppellationInfo({
    required this.key,
    required this.displayName,
    required this.country,
    required this.types,
    required this.dedicated,
    required this.forms,
    required this.weakForms,
    this.region,
    this.templateKey,
  });

  /// Stable key, the same the estimate stores in `denominationKey`.
  final String key;

  /// Name shown to people ("Saint-Estèphe", "Barolo DOCG").
  final String displayName;

  /// ISO 3166-1 alpha-2 code.
  final String country;

  /// Canonical region of `WineOrigins`, or `null`.
  final String? region;

  /// Every type the row makes, the main one first.
  final List<WineType> types;

  /// True for a row with values decided one by one.
  final bool dedicated;

  /// The model of a generated row (BR3.7).
  final String? templateKey;

  /// Normalised forms recognised as this appellation.
  final List<String> forms;

  /// The forms of [forms] that count on a label only next to an indicator.
  final Set<String> weakForms;

  @override
  String toString() => 'AppellationInfo($key, $country)';
}

/// Every appellation of [denominationTable], in table order, built once.
final List<AppellationInfo> appellations = List.unmodifiable([
  for (final MapEntry(:key, value: row) in denominationTable.entries)
    _infoOf(key, row),
]);

final Map<String, AppellationInfo> _byKey = {
  for (final info in appellations) info.key: info,
};

AppellationInfo _infoOf(String key, DenominationProfile row) {
  final forms = formsOf(row);
  return AppellationInfo(
    key: key,
    displayName: row.name ?? denominationLabels[key]?.displayName ?? key,
    country: row.country ?? 'IT',
    region: row.region,
    types: List.unmodifiable(row.types),
    dedicated: row.dedicated,
    templateKey: row.templateKey,
    forms: List.unmodifiable([for (final (form, _) in forms) form]),
    weakForms: Set.unmodifiable({
      for (final (form, weak) in forms)
        if (weak) form,
    }),
  );
}

/// The appellation of [key], or `null`.
AppellationInfo? appellationOf(String? key) => key == null ? null : _byKey[key];

/// The appellation named in [text] by whole words, the longest form first
/// and, on a tie, the first one in the text; `null` when none. With
/// [includeWeak] false a weak form (a common word, BR1.2) never matches.
AppellationInfo? findAppellation(String text, {bool includeWeak = true}) {
  final words = tokenizeAll(text);
  if (words.isEmpty) return null;
  if (includeWeak) return appellationOf(findAlias(words)?.denominationKey);
  AliasMatch? best;
  for (final match in findAliasMatches(words)) {
    if (match.weak) continue;
    if (best == null || match.wordCount > best.wordCount) best = match;
  }
  return appellationOf(best?.denominationKey);
}

/// The display name of the grape of [key] ("Malbec"), or `null`.
String? grapeNameOf(String? key) => key == null ? null : grapeTable[key]?.name;

/// Every normalised grape form (BR3.2: never a denomination form).
final Set<String> grapeForms = Set.unmodifiable({
  for (final grape in grapeTable.values) ...grapeFormsOf(grape),
});

/// Where the generated rows come from: `sample` until the real registers
/// are downloaded (BR6.3).
String get appellationsSource => generatedAppellationsSource;
