// Catalog functions of C2 (compatible additions of 2026-11-05, requested by
// u3-wine-catalog): the same normalisation and denomination recognition the
// estimate uses, exposed so the wine catalog never keeps a second copy that
// could drift (tech-stack-decisions.md of U3).
//
// Display names and regions are wine knowledge decided by the team (project
// rule: wine-domain choices are made autonomously, with their reason, and
// can be corrected): the display name is the name on the label with the
// highest classification the row covers; the region is the Italian region
// where the denomination is produced.

import 'models.dart';
import 'recognizer.dart';
import 'tables.dart';

/// Display name and region of one denomination of [denominationTable].
class DenominationLabel {
  const DenominationLabel(this.displayName, this.region);

  final String displayName;
  final String region;
}

/// Display name and region of every row of [denominationTable], same keys.
const Map<String, DenominationLabel> denominationLabels = {
  'barolo': DenominationLabel('Barolo DOCG', 'Piemonte'),
  'barbaresco': DenominationLabel('Barbaresco DOCG', 'Piemonte'),
  'brunelloDiMontalcino': DenominationLabel(
    'Brunello di Montalcino DOCG',
    'Toscana',
  ),
  'rossoDiMontalcino': DenominationLabel('Rosso di Montalcino DOC', 'Toscana'),
  'amaroneDellaValpolicella': DenominationLabel(
    'Amarone della Valpolicella DOCG',
    'Veneto',
  ),
  'valpolicellaRipasso': DenominationLabel(
    'Valpolicella Ripasso DOC',
    'Veneto',
  ),
  'valpolicella': DenominationLabel('Valpolicella DOC', 'Veneto'),
  'chiantiClassico': DenominationLabel('Chianti Classico DOCG', 'Toscana'),
  'chianti': DenominationLabel('Chianti DOCG', 'Toscana'),
  'vinoNobileDiMontepulciano': DenominationLabel(
    'Vino Nobile di Montepulciano DOCG',
    'Toscana',
  ),
  'bolgheri': DenominationLabel('Bolgheri DOC', 'Toscana'),
  'taurasi': DenominationLabel('Taurasi DOCG', 'Campania'),
  'aglianicoDelVulture': DenominationLabel(
    'Aglianico del Vulture DOC',
    'Basilicata',
  ),
  'sagrantinoDiMontefalco': DenominationLabel(
    'Montefalco Sagrantino DOCG',
    'Umbria',
  ),
  'etnaRosso': DenominationLabel('Etna Rosso DOC', 'Sicilia'),
  'langheNebbiolo': DenominationLabel('Langhe Nebbiolo DOC', 'Piemonte'),
  'gattinara': DenominationLabel('Gattinara DOCG', 'Piemonte'),
  'valtellinaSuperiore': DenominationLabel(
    'Valtellina Superiore DOCG',
    'Lombardia',
  ),
  'sforzatoDiValtellina': DenominationLabel(
    'Sforzato di Valtellina DOCG',
    'Lombardia',
  ),
  'barberaDAsti': DenominationLabel("Barbera d'Asti DOCG", 'Piemonte'),
  'nizza': DenominationLabel('Nizza DOCG', 'Piemonte'),
  'barberaDAlba': DenominationLabel("Barbera d'Alba DOC", 'Piemonte'),
  'dolcetto': DenominationLabel('Dolcetto DOC', 'Piemonte'),
  'montepulcianoDAbruzzo': DenominationLabel(
    "Montepulciano d'Abruzzo DOC",
    'Abruzzo',
  ),
  'primitivoDiManduria': DenominationLabel(
    'Primitivo di Manduria DOC',
    'Puglia',
  ),
  'cannonauDiSardegna': DenominationLabel(
    'Cannonau di Sardegna DOC',
    'Sardegna',
  ),
  'teroldegoRotaliano': DenominationLabel(
    'Teroldego Rotaliano DOC',
    'Trentino-Alto Adige',
  ),
  'lagrein': DenominationLabel('Alto Adige Lagrein DOC', 'Trentino-Alto Adige'),
  'lambrusco': DenominationLabel('Lambrusco DOC', 'Emilia-Romagna'),
  'soave': DenominationLabel('Soave DOC', 'Veneto'),
  'verdicchioDeiCastelliDiJesi': DenominationLabel(
    'Verdicchio dei Castelli di Jesi DOC',
    'Marche',
  ),
  'fianoDiAvellino': DenominationLabel('Fiano di Avellino DOCG', 'Campania'),
  'grecoDiTufo': DenominationLabel('Greco di Tufo DOCG', 'Campania'),
  'vermentinoDiGallura': DenominationLabel(
    'Vermentino di Gallura DOCG',
    'Sardegna',
  ),
  'gavi': DenominationLabel('Gavi DOCG', 'Piemonte'),
  'lugana': DenominationLabel('Lugana DOC', 'Lombardia'),
  'etnaBianco': DenominationLabel('Etna Bianco DOC', 'Sicilia'),
  'trebbianoDAbruzzo': DenominationLabel("Trebbiano d'Abruzzo DOC", 'Abruzzo'),
  'derthona': DenominationLabel('Colli Tortonesi Derthona DOC', 'Piemonte'),
  'franciacorta': DenominationLabel('Franciacorta DOCG', 'Lombardia'),
  'trento': DenominationLabel('Trento DOC', 'Trentino-Alto Adige'),
  'prosecco': DenominationLabel('Prosecco DOC', 'Veneto'),
  'asti': DenominationLabel('Asti DOCG', 'Piemonte'),
  'reciotoDellaValpolicella': DenominationLabel(
    'Recioto della Valpolicella DOCG',
    'Veneto',
  ),
  'passitoDiPantelleria': DenominationLabel(
    'Passito di Pantelleria DOC',
    'Sicilia',
  ),
  'vinSanto': DenominationLabel('Vin Santo del Chianti DOC', 'Toscana'),
  'marsala': DenominationLabel('Marsala DOC', 'Sicilia'),
};

/// One denomination of the catalog (C2 `DenominationInfo`).
class DenominationInfo {
  const DenominationInfo({
    required this.key,
    required this.displayName,
    required this.aliases,
    required this.wineType,
    required this.region,
  });

  /// Stable key, the same the estimate uses.
  final String key;

  /// Name shown to people, for example "Barolo DOCG".
  final String displayName;

  /// Name variants, already normalised as [normalizeWineText] does.
  final List<String> aliases;
  final WineType wineType;
  final String region;

  @override
  bool operator ==(Object other) =>
      other is DenominationInfo &&
      other.key == key &&
      other.displayName == displayName &&
      _sameList(other.aliases, aliases) &&
      other.wineType == wineType &&
      other.region == region;

  @override
  int get hashCode =>
      Object.hash(key, displayName, Object.hashAll(aliases), wineType, region);

  @override
  String toString() => 'DenominationInfo($key)';
}

/// A denomination found in a text (C2 `RecognizedDenomination`).
class RecognizedDenomination {
  const RecognizedDenomination({
    required this.key,
    required this.displayName,
    required this.wineType,
    required this.region,
    this.qualifier,
  });

  final String key;
  final String displayName;
  final WineType wineType;
  final String region;

  /// Qualifier with its own year offsets found next to the name, if any.
  final Qualifier? qualifier;

  @override
  bool operator ==(Object other) =>
      other is RecognizedDenomination &&
      other.key == key &&
      other.displayName == displayName &&
      other.wineType == wineType &&
      other.region == region &&
      other.qualifier == qualifier;

  @override
  int get hashCode =>
      Object.hash(key, displayName, wineType, region, qualifier);

  @override
  String toString() => 'RecognizedDenomination($key, ${qualifier?.name})';
}

/// Normalised form of [text], with no length limit: lowercase, accents
/// removed, apostrophes and punctuation turned into single spaces, no
/// leading or trailing space. The same normalisation used to recognise
/// names, so `normalizeWineText("Barbera d'Asti")` is `barbera d asti`.
String normalizeWineText(String text) => tokenizeAll(text).join(' ');

/// The denomination named in [text] by whole words, the longest alias
/// first and, on a tie, the first one in the text; `null` when none.
/// Works on any length of text, such as the text read on a label.
RecognizedDenomination? recognizeDenomination(String text) {
  final recognized = recognizeWords(tokenizeAll(text));
  if (recognized == null) return null;
  final label = denominationLabels[recognized.denominationKey];
  if (label == null) return null;
  return RecognizedDenomination(
    key: recognized.denominationKey,
    displayName: label.displayName,
    wineType: recognized.wineType,
    region: label.region,
    qualifier: recognized.qualifier,
  );
}

/// Every denomination of the table, in table order, built once.
final List<DenominationInfo> denominationCatalog = List.unmodifiable([
  for (final entry in denominationTable.entries)
    if (denominationLabels[entry.key] case final label?)
      DenominationInfo(
        key: entry.key,
        displayName: label.displayName,
        aliases: List.unmodifiable(entry.value.aliases),
        wineType: entry.value.wineType,
        region: label.region,
      ),
]);

bool _sameList(List<String> a, List<String> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
