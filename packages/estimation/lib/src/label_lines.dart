// Lines, words, noise and vocabulary of a label text, shared by the reader
// of BR1 (`extractLabelFields`) and the analysis of the guided check
// (`analyzeLabelText`, label-autofill-windows D7, BR1.1, BR7.2). Both read
// the same lines and the same words, so their values differ only in the
// final choice (BR1 always picks one, the analysis fills only certain ones).

part of 'label_fields.dart';

// ---------------------------------------------------------------------------
// Lines (BR1.1).

/// One line of the label: its text, words and the position of each word.
class _Line {
  _Line(this.text, this.index)
    : spans = _spansOf(text),
      folded = _foldKeepingLength(text);

  final String text;
  final int index;
  final List<_Span> spans;

  /// [text] lowercase with accents folded, same length, for phrase search.
  final String folded;
  bool address = false;

  List<String> get words => [for (final span in spans) span.word];

  /// The original text of the words [start] to [start] + [count].
  String original(int start, int count) =>
      text.substring(spans[start].start, spans[start + count - 1].end);
}

class _Span {
  const _Span(this.word, this.start, this.end);

  final String word;
  final int start;
  final int end;
}

List<_Span> _spansOf(String text) {
  final spans = <_Span>[];
  final current = StringBuffer();
  var start = 0;
  for (var i = 0; i < text.length; i++) {
    final folded = foldCodeUnit(text.codeUnitAt(i));
    if (folded != 0) {
      if (current.isEmpty) start = i;
      current.writeCharCode(folded);
    } else if (current.isNotEmpty) {
      spans.add(_Span(current.toString(), start, i));
      current.clear();
    }
  }
  if (current.isNotEmpty) {
    spans.add(_Span(current.toString(), start, text.length));
  }
  return spans;
}

String _foldKeepingLength(String text) {
  final buffer = StringBuffer();
  for (final unit in text.codeUnits) {
    final folded = foldCodeUnit(unit);
    buffer.writeCharCode(folded == 0 ? (unit < 0x80 ? unit : 0x20) : folded);
  }
  return buffer.toString().toLowerCase();
}

final RegExp _lineBreak = RegExp('[\n·•|]');
final RegExp _spaces = RegExp(r'\s+');

List<_Line> _linesOf(String text) {
  final lines = <_Line>[];
  for (final raw in text.split(_lineBreak)) {
    final collapsed = raw.trim().replaceAll(_spaces, ' ');
    if (collapsed.isEmpty) continue;
    final line = _Line(collapsed, lines.length);
    if (line.spans.isEmpty || _isService(line)) continue;
    line.address = _isAddress(line);
    lines.add(line);
  }
  return lines;
}

final List<RegExp> _service = [
  RegExp(
    r'(^|[^\d])\d+([.,]\d+)?\s*(cl|ml|l|lt|litri|litre|litres|liter|liters)\b',
  ),
  RegExp(r'\d\s*%\s*(vol|alc|abv)'),
  RegExp(r'\b(alc|vol|abv)\.?\s*\d'),
  RegExp(r'\b\d{8,14}\b'),
  RegExp(r'(https?:|www\.|@|\.(com|it|fr|es|pt|de|net|org|wine|vin|ch|at)\b)'),
  RegExp(r'(^|\s)(lotto|lote|lot|l)\s*[.:]\s*[a-z0-9]*\d'),
  RegExp(r'(^|\s)l\d{3,}\b'),
  RegExp(
    r'(contiene|contains|contient|contem|enthalt)\s+(des\s+)?(solfiti|sulfites|sulphites|sulfitos|sulfite|solfito)',
  ),
];

bool _isService(_Line line) =>
    _service.any((pattern) => pattern.hasMatch(line.folded));

/// A postal code: 5 digits (IT, FR, ES, DE), 4+3 (PT), or 4 digits that
/// cannot be a year (AT, CH, AU), never a vintage.
final RegExp _postalCode = RegExp(
  r'(^|[\s,(-])(\d{5}|\d{4}-\d{3}|(?!19|20)\d{4})(\s|$|[,)])',
);
const Set<String> _addressWords = {
  'via',
  'viale',
  'piazza',
  'loc',
  'localita',
  'frazione',
  'fraz',
  'rue',
  'route',
  'chemin',
  'calle',
  'avenida',
  'carretera',
  'strasse',
  'str',
  'road',
  'street',
  'rua',
  'estrada',
  'tel',
  'fax',
};

bool _isAddress(_Line line) {
  if (_postalCode.hasMatch(line.folded) && line.spans.length > 2) return true;
  final words = line.words;
  for (var i = 0; i + 1 < words.length; i++) {
    if (_addressWords.contains(words[i]) && _hasDigit(words.skip(i + 1))) {
      return true;
    }
  }
  return words.isNotEmpty && (words.first == 'tel' || words.first == 'fax');
}

bool _hasDigit(Iterable<String> words) =>
    words.any((word) => word.codeUnits.any((u) => u >= 0x30 && u <= 0x39));

// ---------------------------------------------------------------------------
// Vocabulary (BR1.2, BR1.4, BR1.6, BR1.7).

/// Words next to which a weak alias counts (BR1.2).
const Set<String> _indicators = {
  'doc',
  'docg',
  'aoc',
  'aop',
  'do',
  'doca',
  'dop',
  'igp',
  'igt',
  'ava',
  'dac',
  'appellation',
  'denominazione',
  'denominacion',
  'denominacao',
  'denominacio',
  'indicazione',
  'indicacion',
  'indicacao',
  'geographical',
  'qualitatswein',
  'pradikatswein',
};

/// Indicators written with dots ("D.O.", "D.O.C.G.", "A.O.C."): the letters
/// of consecutive one-letter words.
const Set<String> _dottedIndicators = {
  'do',
  'doc',
  'docg',
  'doca',
  'dop',
  'aoc',
  'aop',
  'igt',
  'igp',
  'ava',
  'dac',
};

/// Whether a weak alias (a common word: toro, cava, port, rioja, napa...)
/// found in [words] counts (BR1.2): [words] hold an indicator ("DOC",
/// "D.O.", "AVA", "wine of origin"...) or the name of [country], the
/// country of the alias' denomination. Used for a line of a label and its
/// neighbours, and for a wine name typed by hand (resolveWine).
bool weakAliasCountsIn(List<String> words, String? country) {
  if (_hasIndicator(words)) return true;
  if (_containsPhrase(words, const ['wine', 'of', 'origin'])) return true;
  return country != null && countryCodesIn(words).contains(country);
}

/// Whether [words] hold an indicator of BR1.2, dotted forms included.
bool _hasIndicator(List<String> words) {
  if (words.any(_indicators.contains)) return true;
  final letters = StringBuffer();
  for (final word in [...words, '']) {
    if (word.length == 1) {
      letters.write(word);
      continue;
    }
    if (_dottedIndicators.contains(letters.toString())) return true;
    letters.clear();
  }
  return false;
}

/// Words of the classification phrases, never part of a name.
const Set<String> _classificationWords = {
  ..._indicators,
  'qualificada',
  'classico',
  'classic',
  'mit',
  'pradikat',
  'vi',
  'di',
  'origine',
  'controllata',
  'controllate',
  'garantita',
  'protetta',
  'geografica',
  'tipica',
  'controlee',
  'protegee',
  'origen',
  'calificada',
  'protegida',
  'origem',
  'controlada',
  'wine',
  'of',
  'origin',
  'vin',
  'vino',
  'vinho',
  'wein',
  'weine',
  'de',
  'pays',
  'la',
  'le',
  'el',
  'du',
  'des',
  'del',
  'della',
  'dell',
  'd',
  'e',
  'y',
  'et',
  'and',
  'und',
  'b',
  'a',
  'bestimmter',
  'anbaugebiete',
  'product',
  'produit',
  'prodotto',
  'producto',
  'produto',
  'produce',
  'made',
  'in',
  'aus',
  'the',
  'en',
  'da',
  'vqa',
  'wo',
  'grown',
};

const Set<String> _redWords = {
  'rosso',
  'red',
  'rouge',
  'tinto',
  'rot',
  'rotwein',
  'vermelho',
  'negre',
};
const Set<String> _whiteWords = {
  'bianco',
  'white',
  'blanc',
  'blanco',
  'weiss',
  'weisswein',
  'branco',
};
const Set<String> _roseWords = {'rosato', 'rose', 'rosado', 'roze', 'rosat'};
const Set<String> _sparklingWords = {
  'spumante',
  'brut',
  'sekt',
  'espumante',
  'espumoso',
  'cremant',
  'cava',
  'champagne',
  'franciacorta',
  'mousseux',
  'frizzante',
  'petillant',
};

/// Sparkling words that already mean the classic method.
const Set<String> _classicWords = {
  'cremant',
  'cava',
  'champagne',
  'franciacorta',
};
const List<List<String>> _classicPhrases = [
  ['metodo', 'classico'],
  ['methode', 'traditionnelle'],
  ['methode', 'champenoise'],
  ['methode', 'classique'],
  ['traditional', 'method'],
  ['metodo', 'tradicional'],
  ['metodo', 'classico'],
];
const Set<String> _sweetWords = {
  'passito',
  'dolce',
  'sweet',
  'moelleux',
  'liquoreux',
  'dulce',
  'suss',
};
const Set<String> _fortifiedWords = {
  'porto',
  'port',
  'sherry',
  'jerez',
  'madeira',
  'marsala',
};

/// Style words that are never a name: the type words and the classic
/// method phrases.
final Set<String> _styleWords = {
  ..._redWords,
  ..._whiteWords,
  ..._roseWords,
  ..._sparklingWords,
  ..._sweetWords,
  ..._fortifiedWords,
  for (final phrase in _classicPhrases) ...phrase,
  'extra',
  'nature',
  'pas',
  'dose',
  'dosage',
  'zero',
  'sec',
  'secco',
  'demi',
  'seco',
  'trocken',
  'halbtrocken',
  'feinherb',
  'dry',
  'blancs',
  'noirs',
};

/// Producer words of BR1.4, plus company forms (S.A., S.r.l., GmbH...),
/// which name the company of the label.
const Set<String> _producerWords = {
  'chateau',
  'domaine',
  'clos',
  'tenuta',
  'cantina',
  'cantine',
  'bodega',
  'bodegas',
  'quinta',
  'weingut',
  'winery',
  'estate',
  'vineyards',
  'cave',
  'caves',
  'fattoria',
  'podere',
  'vinicola',
  'vinicole',
  'adega',
  'herdade',
  'kellerei',
  'weinbau',
  'gmbh',
  'ltd',
  'inc',
  'lda',
  'sarl',
  'earl',
  'gaec',
  'srl',
  'maison',
  'vignobles',
  'vignoble',
  'vigneron',
  'vignerons',
  'viticoltori',
  'vignaioli',
  'winegrowers',
  'marchesi',
  'marchese',
  'negociant',
  'proprietaire',
  'recoltant',
  'eleveur',
};
const List<List<String>> _producerPhrasesInLine = [
  ['azienda', 'agricola'],
  ['societa', 'agricola'],
  ['az', 'agr'],
  ['soc', 'agr'],
  ['s', 'r', 'l'],
  ['s', 'p', 'a'],
  ['s', 'a', 's'],
];
const List<List<String>> _producerEndings = [
  ['s', 'a'],
  ['s', 'l'],
  ['sa'],
  ['sl'],
  ['spa'],
  ['sas'],
];

/// Words that start a producer that is also the name (BR1.5).
const Set<String> _houseWords = {'chateau', 'domaine', 'clos', 'quinta'};

/// Bottling phrases followed by the producer (BR1.4).
final RegExp _bottledBy = RegExp(
  r"\b(prodotto\s+e\s+imbottigliato\s+da|imbottigliato\s+all\s*'?\s*origine\s+da|imbottigliato\s+da|mis\s+en\s+bouteille\s+(?:a\s+la\s+propriete\s+|au\s+chateau\s+|au\s+domaine\s+)?par|embotellado\s+(?:en\s+origen\s+)?por|engarrafado\s+(?:na\s+origem\s+)?por|abgefullt\s+(?:von|durch)|gutsabfullung\s+(?:von|durch)|erzeugerabfullung\s+(?:von|durch)|produced\s+and\s+bottled\s+by|vinified\s+and\s+bottled\s+by|grown\s+produced\s+and\s+bottled\s+by|estate\s+bottled\s+by|bottled\s+by)\b",
);

/// Bottling words without a producer after them: the estate itself bottled
/// the wine, so the first plain line names it.
const List<List<String>> _estateBottled = [
  ['gutsabfullung'],
  ['erzeugerabfullung'],
  ['estate', 'bottled'],
  ['mis', 'en', 'bouteille', 'au', 'chateau'],
  ['mis', 'en', 'bouteille', 'au', 'domaine'],
  ['mis', 'en', 'bouteille', 'a', 'la', 'propriete'],
  ['imbottigliato', 'all', 'origine'],
  ['engarrafado', 'na', 'origem'],
  ['embotellado', 'en', 'origen'],
];

/// Words of a bottling line, never a name or a producer line.
const Set<String> _bottlingWords = {
  'imbottigliato',
  'imbottigliata',
  'bouteille',
  'embotellado',
  'engarrafado',
  'abgefullt',
  'gutsabfullung',
  'erzeugerabfullung',
  'bottled',
  'imbottigliatore',
};

/// "Product of X" phrases (BR1.7), followed by a country name.
const List<List<String>> _originPhrases = [
  ['prodotto', 'in'],
  ['product', 'of'],
  ['produce', 'of'],
  ['produit', 'de'],
  ['produit', 'en'],
  ['producto', 'de'],
  ['produto', 'de'],
  ['produto', 'do'],
  ['wein', 'aus'],
  ['wine', 'of'],
  ['made', 'in'],
];

// ---------------------------------------------------------------------------
// Helpers.

bool _isYear(String word) =>
    word.length == 4 && word.codeUnits.every((u) => u >= 0x30 && u <= 0x39);

bool _phraseAt(List<String> words, int start, List<String> phrase) {
  if (start + phrase.length > words.length) return false;
  for (var j = 0; j < phrase.length; j++) {
    if (words[start + j] != phrase[j]) return false;
  }
  return true;
}

int _indexOfPhrase(List<String> words, List<String> phrase) {
  for (var i = 0; i < words.length; i++) {
    if (_phraseAt(words, i, phrase)) return i;
  }
  return -1;
}

bool _containsPhrase(List<String> words, List<String> phrase) =>
    _indexOfPhrase(words, phrase) >= 0;

bool _endsWith(List<String> words, List<String> ending) =>
    words.length > ending.length &&
    _phraseAt(words, words.length - ending.length, ending);

final RegExp _yearToken = RegExp(r'(?<![\d])\d{4}(?![\d])');

String _withoutYears(String text) =>
    text.replaceAll(_yearToken, ' ').replaceAll(_spaces, ' ').trim();

String _cutName(String text) {
  final trimmed = text.trim();
  if (trimmed.length <= maxExtractedNameLength) return trimmed;
  final cut = trimmed.substring(0, maxExtractedNameLength);
  final space = cut.lastIndexOf(' ');
  return (space > 20 ? cut.substring(0, space) : cut).trimRight();
}

/// Small words written in lower case inside a title-cased line.
const Set<String> _lowerWords = {
  'di',
  'de',
  'del',
  'della',
  'dei',
  'delle',
  'du',
  'des',
  'da',
  'do',
  'dos',
  'la',
  'le',
  'les',
  'e',
  'et',
  'y',
  'and',
  'of',
  'en',
  'sur',
  'von',
  'am',
};

/// [text] as written, or in title case when it is all capitals ("CHÂTEAU
/// MEYNEY" gives "Château Meyney"): labels often print names in capitals.
String _smartCase(String text) {
  var letters = 0;
  var upper = 0;
  for (final rune in text.runes) {
    final char = String.fromCharCode(rune);
    if (char.toLowerCase() == char.toUpperCase()) continue;
    letters++;
    if (char == char.toUpperCase()) upper++;
  }
  if (letters < 2 || upper != letters) return text;
  final lower = text.toLowerCase();
  final buffer = StringBuffer();
  var wordIndex = 0;
  var current = StringBuffer();
  void flush() {
    if (current.isEmpty) return;
    final word = current.toString();
    final keepLower = wordIndex > 0 && _lowerWords.contains(word);
    buffer.write(
      keepLower ? word : '${word[0].toUpperCase()}${word.substring(1)}',
    );
    wordIndex++;
    current = StringBuffer();
  }

  for (final rune in lower.runes) {
    final char = String.fromCharCode(rune);
    final isLetter = char.toLowerCase() != char.toUpperCase();
    final isDigit = rune >= 0x30 && rune <= 0x39;
    if (isLetter || isDigit) {
      current.write(char);
    } else {
      final apostrophe = char == "'" || char == '’';
      final elided = apostrophe && current.length == 1;
      if (elided) {
        // "D'ASTI" gives "d'Asti", "L'ÉTOILE" at the start "L'Étoile".
        final letter = current.toString();
        buffer.write(wordIndex == 0 ? letter.toUpperCase() : letter);
        current = StringBuffer();
        buffer.write(char);
        continue;
      }
      flush();
      buffer.write(char);
    }
  }
  flush();
  return buffer.toString();
}
