// Words of a wine name that decide a type or a style (wine-style-profiles
// BR2.16, BR3.2, BR3.8, BR3.9, BR4.5). Matching is on whole words of the
// normalised text (as qualifierMaskOf), so "rosa" is never "rosato" and
// "Rosa dei Venti" gives no type.
//
// The word lists are wine knowledge decided at Functional Design (rules.md
// BR2.16, BR3.2; project.md correction of 2026-11-04).

/// True when the normalised [words] hold [phrase] (normalised words joined
/// by single spaces) as consecutive whole words.
bool hasPhrase(List<String> words, String phrase) {
  final parts = phrase.split(' ');
  for (var i = 0; i + parts.length <= words.length; i++) {
    if (words[i] != parts.first) continue;
    var match = true;
    for (var j = 1; j < parts.length; j++) {
      if (words[i + j] != parts[j]) {
        match = false;
        break;
      }
    }
    if (match) return true;
  }
  return false;
}

/// The first phrase of [phrases] found in [words], or `null`.
String? firstPhrase(List<String> words, Iterable<String> phrases) {
  for (final phrase in phrases) {
    if (hasPhrase(words, phrase)) return phrase;
  }
  return null;
}

/// BR3.9: words of products that are not wine.
const List<String> nonWineWords = [
  'seltzer',
  'cider',
  'cidre',
  'sidra',
  'calvados',
  'gluhwein',
  'sangria',
  'spritz',
  'vermouth',
  'beer',
  'biere',
  'birra',
  'cocktail',
  'punch',
];

/// BR3.9: "liqueur" is not wine unless it is a "vin de liqueur".
bool isNonWine(List<String> words) =>
    firstPhrase(words, nonWineWords) != null ||
    (hasPhrase(words, 'liqueur') && !hasPhrase(words, 'vin de liqueur'));

/// BR3.2: fortified wine words.
const List<String> fortifiedWords = [
  'porto',
  'port',
  'sherry',
  'jerez',
  'xeres',
  'marsala',
  'madeira',
  'liquoroso',
  'fortified',
  'vin doux naturel',
  'vdn',
  'vin de liqueur',
  'pineau',
  'generoso',
  'vinho generoso',
  'likorwein',
  'fino',
  'manzanilla',
  'amontillado',
  'oloroso',
  'pedro ximenez',
  'tawny',
  'ruby',
];

/// BR3.2: sweet category words (not the dosage words).
const List<String> sweetCategoryWords = [
  'passito',
  'liquoreux',
  'edelsuss',
  'dessert',
  'vendange tardive',
  'vendanges tardives',
  'late harvest',
  'eiswein',
  'icewine',
  'recioto',
  'vin santo',
  'tokaji aszu',
  'commandaria',
  'moelleux',
];

/// BR3.2: dosage words. They give "sweet" only when nothing else says what
/// the wine is, and never change a sparkling or Lambrusco profile.
const List<String> dosageWords = [
  'dolce',
  'doux',
  'sweet',
  'dulce',
  'demi sec',
  'amabile',
  'abboccato',
  'lieblich',
  'suss',
  'medium dry',
  'semi seco',
];

/// True when [words] hold a dosage word ("doux" of "vin doux naturel" not).
bool hasDosageWord(List<String> words) {
  for (final word in dosageWords) {
    if (!hasPhrase(words, word)) continue;
    if (word == 'doux' && hasPhrase(words, 'vin doux naturel')) continue;
    return true;
  }
  return false;
}

/// BR3.2: traditional-method sparkling words.
const List<String> classicMethodWords = [
  'champagne',
  'cremant',
  'cava',
  'franciacorta',
  'trento doc',
  'alta langa',
  'metodo classico',
  'methode traditionnelle',
  'methode champenoise',
  'traditional method',
  'espumante natural',
];

/// BR2.4: words of a Lambrusco made with the traditional method.
const List<String> lambruscoClassicWords = [
  'metodo classico',
  'rifermentato in bottiglia',
  'ancestrale',
];

/// BR3.2: tank-method sparkling words.
const List<String> tankMethodWords = [
  'prosecco',
  'spumante',
  'frizzante',
  'sekt',
  'mousseux',
  'petillant',
  'espumoso',
  'lambrusco',
];

/// BR3.2: rosé words ("rosa" is not one: brands such as "Rosa dei Venti").
const List<String> roseWords = [
  'rosato',
  'rose',
  'rosado',
  'roze',
  'vin gris',
  'gris de gris',
  'clairet',
  'blush',
  'cerasuolo d abruzzo',
  'weissherbst',
];

/// BR3.2: white words.
const List<String> whiteWords = [
  'bianco',
  'blanc',
  'blanco',
  'branco',
  'white',
  'weiss',
  'weisswein',
  'wit',
  'blanca',
];

/// BR3.2: red words.
const List<String> redWords = [
  'rosso',
  'rouge',
  'red',
  'tinto',
  'tinta',
  'rot',
  'rotwein',
  'vermelho',
  'rood',
  'negre',
];

/// Colour named by [words] (BR3.2): `rose`, `white`, `red` or `null`.
/// "Pinot gris" and "pinot grigio" are white grapes, not a rosé.
String? colourOf(List<String> words) {
  if (firstPhrase(words, roseWords) != null &&
      !hasPhrase(words, 'pinot gris') &&
      !hasPhrase(words, 'pinot grigio')) {
    return 'rose';
  }
  if (firstPhrase(words, whiteWords) != null) return 'white';
  if (firstPhrase(words, redWords) != null) return 'red';
  return null;
}

/// True when [words] name a colour (BR3.2).
bool hasColourWord(List<String> words) =>
    firstPhrase(words, roseWords) != null ||
    firstPhrase(words, whiteWords) != null ||
    firstPhrase(words, redWords) != null;

/// BR3.8 and BR4.5: table-wine words.
const List<String> tableWineWords = [
  'vino da tavola',
  'vin de table',
  'vin de france',
  'vino de mesa',
  'tafelwein',
  'table wine',
  'bag in box',
  'bib',
  'fontaine',
  'cubi',
  'brick',
  'tetra',
  'novello',
  'nouveau',
  'primeur',
  'joven',
];

/// BR4.3: regional-wine (IGT, IGP) words.
const List<String> regionalWineWords = [
  'igp',
  'igt',
  'vin de pays',
  'pays d oc',
  'landwein',
  'vino de la tierra',
];

/// BR3.4: words of a young light red.
const List<String> youngRedWords = ['nouveau', 'primeur', 'novello', 'joven'];

/// BR3.8: first words of a generic designation.
const List<String> genericDesignations = [
  'vin',
  'vino',
  'wine',
  'vinho',
  'wein',
];

/// BR2.3: words of a vintage traditional-method sparkling wine.
const List<String> vintageSparklingWords = [
  'millesimato',
  'millesime',
  'vintage',
];

/// BR2.16: words of the sweet categories.
const List<String> passitoWords = [
  'passito',
  'appassimento',
  'vendemmia tardiva',
  'vendange tardive',
  'vendanges tardives',
  'late harvest',
  'spatlese edelsuss',
  'recioto',
  'vin santo',
  'commandaria',
  'eiswein',
  'icewine',
  'vin de glace',
];
const List<String> botrytisWords = [
  'selection de grains nobles',
  'botrytis',
  'muffa nobile',
  'aszu',
  'ausbruch',
  'beerenauslese',
  'trockenbeerenauslese',
];
const List<String> aromaticSweetWords = [
  'moscato d asti',
  'moscatel',
  'muscat',
  'moscato',
];

/// BR2.6: "trocken" next to an Auslese makes it a dry white.
const List<String> dryWords = ['sec', 'secco', 'dry', 'trocken', 'seco'];
