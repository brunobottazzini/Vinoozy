// The analysis of a label text for the guided check (label-autofill-windows
// FR7.3, D7, D8, BR7.1-BR7.8, ENT-007-ENT-010): for each key field an
// ordered list of at most 5 candidates with an integer score, the certainty
// of the field, the view the form fills without the guide and the words the
// owner can compose a value from.
//
// Candidates come only from the text (FR1.1, FR7.5): producer, name and
// vintage are text of the label, the denomination is a table row named by
// words of the label. Nothing here keeps or logs the text (BR7.22).

part of 'label_fields.dart';

/// The key fields, in the order of the questions (ENT-007, FR7.2).
enum KeyField {
  denomination,
  producer,
  name,
  vintage;

  /// The name of the field in [LabelFieldKeys], for the mark "from the
  /// text" (FR1.3).
  String get labelFieldKey => switch (this) {
    KeyField.denomination => LabelFieldKeys.denomination,
    KeyField.producer => LabelFieldKeys.producer,
    KeyField.name => LabelFieldKeys.name,
    KeyField.vintage => LabelFieldKeys.vintage,
  };
}

/// Certain, uncertain or absent (BR7.8, ENT-009).
enum FieldCertainty { certain, uncertain, absent }

/// The signals a candidate received (ENT-008). For the tests and the
/// tuning: they never hold text.
enum CandidateSignal {
  strongAlias,
  weakAlias,
  indicatorNear,
  indicatorTwoLines,
  indicatorElsewhere,
  multiWordAlias,
  countryInText,
  containedAlias,
  aliasInProducerLine,
  aliasIsGrape,
  shortTextHead,
  bottlingPhrase,
  bottlingVerb,
  producerLine,
  weakProducerLine,
  firstLines,
  estateBottled,
  producerInLongLine,
  producerInAddress,
  plainFirstLine,
  uniqueProducer,
  twoSources,
  foundingCut,
  onlyProducerWords,
  denominationAndBrand,
  singleBrand,
  brandAndGrape,
  brandAlone,
  grapeAlone,
  severalBrands,
  longestBrand,
  houseLine,
  denominationAndGrape,
  denominationLine,
  shortTextDenominationLine,
  aliasOnly,
  producerAsName,
  producerAndGrape,
  uppercaseBrand,
  year,
  vintageWord,
  yearAlone,
  uniqueYear,
  foundingYear,
  bottlingYear,
  awardOrAddressYear,
  cuveeYear,
}

/// One candidate value of a key field (ENT-008).
class FieldCandidate {
  const FieldCandidate({
    required this.field,
    required this.value,
    required this.score,
    this.year,
    this.denominationKey,
    this.wordIds = const [],
    this.signals = const {},
  });

  final KeyField field;

  /// The text the field gets: the 4 digits of a vintage, the name of the
  /// table row of a denomination.
  final String value;

  /// Only for the vintage.
  final int? year;

  /// Only for the denomination: the key of the table row.
  final String? denominationKey;

  /// Integer hundredths, 0 to 100 (BR7.1): 80 means 0,80.
  final int score;

  /// Ids of the [LabelWord]s the value comes from (BR7.15).
  final List<int> wordIds;

  /// The signals applied (no text).
  final Set<CandidateSignal> signals;

  /// The folded value: two candidates of a field with the same one are the
  /// same (BR7.1).
  String get folded => tokenizeAll(value).join(' ');

  @override
  bool operator ==(Object other) =>
      other is FieldCandidate && other.field == field && other.folded == folded;

  @override
  int get hashCode => Object.hash(field, folded);

  // No text in the string form (BR7.22).
  @override
  String toString() => 'FieldCandidate(${field.name}, $score)';
}

/// The analysis of one key field (ENT-009).
class KeyFieldAnalysis {
  const KeyFieldAnalysis({
    required this.field,
    required this.candidates,
    required this.certainty,
  });

  final KeyField field;

  /// Ordered, at most 5 (BR7.1).
  final List<FieldCandidate> candidates;
  final FieldCertainty certainty;

  /// The first candidate, if any.
  FieldCandidate? get top => candidates.isEmpty ? null : candidates.first;

  /// [top] when the field is certain.
  FieldCandidate? get value =>
      certainty == FieldCertainty.certain ? candidates.first : null;

  @override
  String toString() =>
      'KeyFieldAnalysis(${field.name}, ${certainty.name}, '
      '${candidates.length})';
}

/// What the type of a wine can be read from (BR1.6), without the text.
class _TypeEvidence {
  const _TypeEvidence({
    this.fortified = false,
    this.sweet = false,
    this.sparkling = false,
    this.classic = false,
    this.rose = false,
    this.white = false,
    this.red = false,
    this.grapeType,
    this.grapeTypeOutsideAliases,
    this.qualifierMask = 0,
    this.productOfCountry,
  });

  final bool fortified;
  final bool sweet;
  final bool sparkling;
  final bool classic;
  final bool rose;
  final bool white;
  final bool red;

  /// The first grape of the text (BR1.6 with the denomination).
  final WineType? grapeType;

  /// The first grape outside every alias of a denomination (BR7.8 b).
  final WineType? grapeTypeOutsideAliases;
  final int qualifierMask;

  /// The country of a "product of" phrase (BR1.7).
  final String? productOfCountry;

  Qualifier? qualifierFor(DenominationProfile? row) {
    for (final qualifier in qualifiersOf(qualifierMask)) {
      if (qualifier == Qualifier.vintage &&
          !(row?.qualifierOffsets.containsKey(Qualifier.vintage) ?? false)) {
        continue;
      }
      return qualifier;
    }
    return null;
  }

  /// The type of BR1.6 with the table row [info]; without it (BR7.8 b) a
  /// red wine without a grape keeps no type.
  WineType? typeFor(AppellationInfo? info, Qualifier? qualifier) {
    final rowTypes = info?.types ?? const <WineType>[];
    final grape = info == null ? grapeTypeOutsideAliases : grapeType;
    if (fortified) return WineType.fortified;
    if (sweet) {
      return rowTypes.contains(WineType.fortified)
          ? WineType.fortified
          : WineType.sweet;
    }
    if (sparkling) {
      for (final type in rowTypes) {
        if (type.isSparkling) return type;
      }
      return classic ? WineType.sparklingClassic : WineType.sparklingTank;
    }
    if (rose) return WineType.rose;
    if (white) return WineType.white;
    if (red) {
      if (qualifier != null && agingQualifiers.contains(qualifier)) {
        return WineType.redStructured;
      }
      final reds = [
        for (final type in [...rowTypes, ?grape])
          if (type == WineType.redLight || type == WineType.redStructured) type,
      ];
      if (reds.isNotEmpty) return reds.first;
      return info == null ? null : WineType.redLight;
    }
    if (rowTypes.length == 1) return rowTypes.single;
    return grape;
  }
}

/// The result of [analyzeLabelText] (ENT-010). Kept in memory only.
class LabelAnalysis {
  const LabelAnalysis._({
    required this.fields,
    required this.certainFields,
    required this.typeDerivedFromDenomination,
    required this.words,
    required this.qualifier,
    required _TypeEvidence evidence,
  }) : _evidence = evidence; // ignore: prefer_initializing_formals

  /// The analysis of an empty text, or of a reader error.
  static const LabelAnalysis empty = LabelAnalysis._(
    fields: {
      KeyField.denomination: KeyFieldAnalysis(
        field: KeyField.denomination,
        candidates: [],
        certainty: FieldCertainty.absent,
      ),
      KeyField.producer: KeyFieldAnalysis(
        field: KeyField.producer,
        candidates: [],
        certainty: FieldCertainty.absent,
      ),
      KeyField.name: KeyFieldAnalysis(
        field: KeyField.name,
        candidates: [],
        certainty: FieldCertainty.absent,
      ),
      KeyField.vintage: KeyFieldAnalysis(
        field: KeyField.vintage,
        candidates: [],
        certainty: FieldCertainty.uncertain,
      ),
    },
    certainFields: LabelFields.empty,
    typeDerivedFromDenomination: false,
    words: [],
    qualifier: null,
    evidence: _TypeEvidence(),
  );

  /// Always the 4 key fields.
  final Map<KeyField, KeyFieldAnalysis> fields;

  /// What the form fills without the guide (BR7.8): key fields only when
  /// certain, country and region of the denomination only when it is
  /// certain, the type with BR7.8 (b).
  final LabelFields certainFields;

  /// Whether the type of [certainFields] comes from the denomination row.
  final bool typeDerivedFromDenomination;

  /// The words of FR7.5, at most [maxLabelWords] (BR7.14).
  final List<LabelWord> words;

  /// The qualifier of the text (BR1.8), for the suggested level (BR7.8 c).
  final Qualifier? qualifier;

  final _TypeEvidence _evidence;

  /// The analysis of [field].
  KeyFieldAnalysis operator [](KeyField field) => fields[field]!;

  /// The uncertain fields, in the order of [KeyField].
  List<KeyField> get uncertainFields => [
    for (final field in KeyField.values)
      if (fields[field]!.certainty == FieldCertainty.uncertain) field,
  ];

  /// True with no certain field and no candidate.
  bool get isEmpty => fields.values.every(
    (field) =>
        field.candidates.isEmpty && field.certainty != FieldCertainty.certain,
  );

  /// Whether the text gives anything to ask about (BR7.10): a certain field
  /// or a candidate for the denomination, the producer or the name. A text
  /// like "750 ml / 13% vol" never asks the vintage alone.
  bool get hasClues =>
      fields.values.any((field) => field.certainty == FieldCertainty.certain) ||
      [
        KeyField.denomination,
        KeyField.producer,
        KeyField.name,
      ].any((field) => fields[field]!.candidates.isNotEmpty);

  /// The fields that follow from the table row [denominationKey] once it is
  /// confirmed (BR7.20): type (BR1.6 with the row), country, region,
  /// qualifier and suggested level. Empty for an unknown key.
  LabelFields fieldsForDenomination(String denominationKey) {
    final info = appellationOf(denominationKey);
    if (info == null) return LabelFields.empty;
    final row = denominationTable[denominationKey];
    final qualifier = _evidence.qualifierFor(row);
    return LabelFields(
      denomination: info.displayName,
      denominationKey: info.key,
      wineType: _evidence.typeFor(info, qualifier),
      country: info.country,
      region: info.region,
      qualifier: qualifier,
      suggestedLevel: qualifier != null && agingQualifiers.contains(qualifier)
          ? WineLevel.aging
          : null,
    );
  }

  // No text in the string form (BR7.22).
  @override
  String toString() =>
      'LabelAnalysis(certain: ${certainFields.sourceKeys.join(', ')}; '
      'uncertain: ${uncertainFields.map((f) => f.name).join(', ')})';
}

/// Analyses the label [text] for the guided check (BR7.1-BR7.8, D7).
/// [currentYear] bounds the vintage. Pure and deterministic.
LabelAnalysis analyzeLabelText(String text, {required int currentYear}) {
  final lines = _analysisLinesOf(sanitizeLabelText(text));
  if (lines.isEmpty) return LabelAnalysis.empty;
  return _Analyzer(lines, currentYear).analyze();
}

// ---------------------------------------------------------------------------
// Lines of the analysis (BR7.2).

/// Most words of a service line dropped whole (BR7.2 a).
const int _maxServiceWords = 8;

/// The pieces of a service line removed from a long line (BR7.2 a).
final List<RegExp> _servicePieces = [
  RegExp(r'\d+([.,]\d+)?\s*%\s*(vol|alc|abv)\.?'),
  RegExp(r'\b(alc|vol|abv)\.?\s*\d+([.,]\d+)?\s*%?'),
  RegExp(r'\d+([.,]\d+)?\s*(cl|ml|l|lt|litri|litre|litres|liter|liters)\b'),
  RegExp(r'\b\d{8,14}\b'),
  RegExp(r'\S*(https?:|www\.|@)\S*'),
  RegExp(r'\S+\.(com|it|fr|es|pt|de|net|org|wine|vin|ch|at)\b\S*'),
  RegExp(r'(^|\s)(lotto|lote|lot|l)\s*[.:]\s*[a-z0-9]*\d\S*'),
  RegExp(r'(^|\s)l\d{3,}\b'),
  RegExp(
    r'(contiene|contains|contient|contem|enthalt)\s+(des\s+)?(solfiti|sulfites|sulphites|sulfitos|sulfite|solfito)',
  ),
];

/// The lines of BR1.1 for the analysis: a service line of at most
/// [_maxServiceWords] words is dropped, a longer one (Lens text pasted
/// without line breaks) only loses its service pieces (BR7.2 a).
List<_Line> _analysisLinesOf(String text) {
  final lines = <_Line>[];
  for (final raw in text.split(_lineBreak)) {
    final collapsed = raw.trim().replaceAll(_spaces, ' ');
    if (collapsed.isEmpty) continue;
    var line = _Line(collapsed, lines.length);
    if (line.spans.isEmpty) continue;
    if (_isService(line)) {
      if (line.spans.length <= _maxServiceWords) continue;
      final cleaned = _withoutServicePieces(line);
      if (cleaned.isEmpty) continue;
      line = _Line(cleaned, lines.length);
      if (line.spans.isEmpty) continue;
    }
    // A founding year is not a postal code ("depuis 1885").
    line.address =
        _isAddress(line) &&
        !line.words.any(VintageParser.foundingWords.contains);
    lines.add(line);
  }
  return lines;
}

/// Whether [line] names its producer after a bottling phrase or verb.
bool _isBottlingPhraseLine(_Line line) =>
    _bottledBy.hasMatch(line.folded) ||
    _producerPhrase.hasMatch(line.folded) ||
    _bottlingVerbBy.hasMatch(line.folded);

String _withoutServicePieces(_Line line) {
  final keep = List<bool>.filled(line.text.length, true);
  for (final pattern in _servicePieces) {
    for (final match in pattern.allMatches(line.folded)) {
      for (var i = match.start; i < match.end; i++) {
        keep[i] = false;
      }
    }
  }
  final buffer = StringBuffer();
  for (var i = 0; i < line.text.length; i++) {
    buffer.write(keep[i] ? line.text[i] : ' ');
  }
  return buffer.toString().trim().replaceAll(_spaces, ' ');
}

/// Award and anniversary words (BR7.2 d).
const Set<String> _awardWords = {
  'medaglia',
  'medal',
  'medaille',
  'medalla',
  'medalha',
  'concorso',
  'concours',
  'concurso',
  'wettbewerb',
  'award',
  'punti',
  'points',
  'anni',
  'years',
  'ans',
  'anos',
  'jahre',
  'anniversario',
  'anniversary',
  'anniversaire',
};

/// Indicators of BR7.3 written as phrases.
const List<List<String>> _indicatorPhrases = [
  ['wine', 'of', 'origin'],
  ['vinho', 'regional'],
  ['jatorri', 'deitura'],
  ['appellation'],
];

/// Words of the indicator phrases, never a name or the text of a
/// denomination line (BR7.5 NG).
const Set<String> _indicatorPhraseWords = {
  ..._indicators,
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
  'qualificada',
  'protegida',
  'origem',
  'controlada',
  'procedencia',
  'jatorri',
  'deitura',
  'regional',
  'wine',
  'origin',
  'vinho',
  'vin',
  'vino',
  'mit',
  'pradikat',
  'of',
  'di',
  'de',
  'd',
  'e',
  'y',
  'et',
  'du',
  'des',
  'del',
  'della',
  'la',
  'le',
  'el',
};

/// Producer words of BR7.4 added to [_producerWords].
const Set<String> _moreProducerWords = {
  'cooperativa',
  'cooperative',
  'domane',
  'schlossgut',
  'sektkellerei',
  'winzergenossenschaft',
  'weinmanufaktur',
  'winzerkeller',
  'cellars',
  'wines',
  'sas',
  'eg',
  'sa',
  'sl',
  'spa',
};

/// Weak producer words (BR7.4 PC).
const Set<String> _weakProducerWords = {
  'cascina',
  'castello',
  'masseria',
  'villa',
  'casa',
  'mas',
  'pazo',
  'finca',
  'pago',
  'senorio',
  'schloss',
  'famiglia',
  'familia',
  'family',
  'fratelli',
  'hermanos',
  'irmaos',
};

/// Small words a producer value may hold beside its producer words.
const Set<String> _articles = {
  'de',
  'di',
  'da',
  'do',
  'dos',
  'das',
  'du',
  'des',
  'del',
  'della',
  'dei',
  'la',
  'le',
  'les',
  'los',
  'las',
  'el',
  'the',
  'of',
  'von',
  'van',
  'der',
  'd',
  'l',
  'e',
  'et',
  'y',
  'and',
  'agricola',
  'azienda',
  'societa',
  'az',
  'agr',
  'soc',
  'r',
  'p',
  's',
  'a',
};

/// Bottling phrases of BR7.4 PA: BR1.4 plus "élaboré par", "elaborado por",
/// "hergestellt von", "elaborado e engarrafado por".
final RegExp _producerPhrase = RegExp(
  r'\b(elabore\s+par|elaborado\s+e\s+engarrafado\s+por|elaborado\s+por|hergestellt\s+von)\b',
);

/// A bottling verb, at most 4 words, then "by" (BR7.4 PA').
final RegExp _bottlingVerbBy = RegExp(
  r'\b(imbottigliato|imbottigliata|bottled|embotellado|engarrafado|abgefullt|bouteille)\b(\s+[^\s]+){0,4}?\s+(da|par|por|by|von)\s',
);

/// Words after which a year is part of a name (BR7.5) or not a vintage
/// (BR7.6).
const Set<String> _cuveeWords = {'cuvee', 'bin', 'no', 'n', 'nr'};

/// Bottling words a year may follow (BR7.6).
const Set<String> _bottlingYearWords = {
  'imbottigliato',
  'imbottigliata',
  'bottled',
  'bouteille',
  'embotellado',
  'engarrafado',
  'abgefullt',
};

/// Vintage words of BR7.6 beyond [VintageParser.vintageWords].
const Set<String> _moreVintageWords = {'anada', 'collita', 'verema'};

/// Grape names often printed alone on a label that the grape table of
/// FR3.2 does not hold (it keeps only the grapes with a window of their
/// own). They only tell a grape line from a brand line (BR7.5), never give
/// a window or a type. Wine knowledge decided by the team (project.md,
/// Corrections of 2026-11-04): the common grapes of the six languages of the
/// reference set.
const List<List<String>> _labelGrapeNames = [
  ['grauburgunder'],
  ['grauer', 'burgunder'],
  ['weissburgunder'],
  ['silvaner'],
  ['sylvaner'],
  ['trollinger'],
  ['schiava'],
  ['muller', 'thurgau'],
  ['kerner'],
  ['scheurebe'],
  ['dornfelder'],
  ['portugieser'],
  ['sankt', 'laurent'],
  ['st', 'laurent'],
  ['welschriesling'],
  ['loureiro'],
  ['castelao'],
  ['malvasia'],
  ['arinto'],
  ['baga'],
  ['encruzado'],
  ['trincadeira'],
  ['aragonez'],
  ['touriga', 'franca'],
  ['tinta', 'barroca'],
  ['fernao', 'pires'],
  ['verdelho'],
  ['sercial'],
  ['boal'],
  ['bual'],
  ['tinta', 'negra'],
  ['carignan'],
  ['carignano'],
  ['cinsault'],
  ['melon'],
  ['picpoul'],
  ['dolcetto'],
  ['lagrein'],
  ['nerello', 'mascalese'],
  ['frappato'],
  ['falanghina'],
  ['fiano'],
  ['greco'],
  ['trebbiano'],
  ['garganega'],
  ['cortese'],
  ['arneis'],
  ['verdicchio'],
  ['negroamaro'],
  ['corvina'],
  ['macabeo'],
  ['viura'],
  ['xarel', 'lo'],
  ['parellada'],
  ['bobal'],
  ['prieto', 'picudo'],
  ['petite', 'sirah'],
  ['zinfandel'],
];

/// Style words of a name in Portuguese beyond [_styleWords] (BR7.5).
const Set<String> _moreStyleWords = {'doce', 'suave', 'meio'};

/// Words of a qualifier line (BR7.5 NG).
const Set<String> _qualifierLineWords = {
  'riserva',
  'reserva',
  'reserve',
  'crianza',
  'superiore',
  'classico',
  'gran',
  'selezione',
};

/// Style words of a name that are not a brand (BR7.5).
const List<List<String>> _stylePhrases = [
  ['grand', 'vin'],
  ['vendanges', 'tardives'],
  ['selection', 'de', 'grains', 'nobles'],
];

/// Style words without the classic method phrases (BR7.5 NG).
final Set<String> _plainStyleWords = {
  ..._redWords,
  ..._whiteWords,
  ..._roseWords,
  ..._sparklingWords,
  ..._sweetWords,
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
  'blanc',
  'de',
};

/// Countries of the European Union (BR7.3: the indicator is usually
/// printed there, so the country name counts less).
const Set<String> _euCountries = {
  'AT',
  'BE',
  'BG',
  'CY',
  'CZ',
  'DE',
  'DK',
  'EE',
  'ES',
  'FI',
  'FR',
  'GR',
  'HR',
  'HU',
  'IE',
  'IT',
  'LT',
  'LU',
  'LV',
  'MT',
  'NL',
  'PL',
  'PT',
  'RO',
  'SE',
  'SI',
  'SK',
};

// ---------------------------------------------------------------------------
// Drafts.

enum _Source { pa, paVerb, pb, pc, pd, pg, ph, pe }

/// A candidate while it is built: its value, score, signals and the places
/// in the text it comes from.
class _Draft {
  _Draft(
    this.field,
    this.value,
    this.score,
    this.line,
    this.word, {
    this.year,
    this.info,
    this.aliasWords = 0,
    Set<CandidateSignal>? signals,
    List<(int, int, int)>? ranges,
  }) : signals = signals ?? <CandidateSignal>{},
       ranges = ranges ?? <(int, int, int)>[];

  final KeyField field;
  String value;
  int score;
  final int line;
  final int word;
  final int? year;
  final AppellationInfo? info;
  final int aliasWords;
  final Set<CandidateSignal> signals;

  /// (line, start, end) character ranges of the value in the lines.
  final List<(int, int, int)> ranges;
  final Set<_Source> sources = {};

  void add(int weight, CandidateSignal signal) {
    score += weight;
    signals.add(signal);
  }

  Set<String> get words => tokenizeAll(value).toSet();
}

/// The denomination found in a line.
class _AliasHit {
  const _AliasHit(this.line, this.match, this.info);

  final _Line line;
  final AliasMatch match;
  final AppellationInfo info;

  List<String> get words =>
      line.words.sublist(match.start, match.start + match.wordCount);
}

// ---------------------------------------------------------------------------
// The analyzer.

class _Analyzer {
  _Analyzer(this.lines, this.currentYear) {
    for (final line in lines) {
      final kind = _noiseOf(line);
      noise.add(kind);
      if (!kind) {
        position[line.index] = useful.length;
        useful.add(line);
      }
      if (_hasAnalysisIndicator(line.words)) indicatorLines.add(line.index);
    }
    textCountries = countryCodesIn([for (final line in lines) ...line.words]);
    final (shownWords, wordRefs) = _wordsOf(lines, currentYear);
    words = shownWords;
    refs = wordRefs;
  }

  final List<_Line> lines;
  final int currentYear;
  final List<bool> noise = [];
  final List<_Line> useful = [];
  final Map<int, int> position = {};
  final Set<int> indicatorLines = {};
  late final Set<String> textCountries;
  late final List<LabelWord> words;
  late final List<_WordRef> refs;

  bool get shortText => useful.length <= 3;

  LabelAnalysis analyze() {
    final hits = _aliasHits();
    final denominations = _rankedDrafts(_denominations(hits));
    final producers = _rankedDrafts(_producers());
    final denominationField = _field(KeyField.denomination, [
      for (final draft in denominations) _candidateOf(draft),
    ], () => indicatorLines.isEmpty);
    final producerField = _field(KeyField.producer, [
      for (final draft in producers) _candidateOf(draft),
    ], () => !_hasProducerClue());
    final names = _ranked(
      _names(
        hits,
        denominations.firstOrNull,
        denominationField.certainty == FieldCertainty.certain,
        producers,
      ),
    );
    final nameField = _field(KeyField.name, names, () => useful.isEmpty);
    final vintageField = _field(
      KeyField.vintage,
      _ranked(_vintages()),
      () => false,
    );
    final evidence = _evidence(hits);
    final certainInfo = denominationField.value == null
        ? null
        : appellationOf(denominationField.value!.denominationKey!);
    final row = certainInfo == null ? null : denominationTable[certainInfo.key];
    final qualifier = evidence.qualifierFor(row);
    final type = evidence.typeFor(certainInfo, qualifier);
    final typeWithout = evidence.typeFor(null, evidence.qualifierFor(null));
    return LabelAnalysis._(
      fields: {
        KeyField.denomination: denominationField,
        KeyField.producer: producerField,
        KeyField.name: nameField,
        KeyField.vintage: vintageField,
      },
      certainFields: LabelFields(
        name: nameField.value?.value,
        producer: producerField.value?.value,
        denomination: certainInfo?.displayName,
        denominationKey: certainInfo?.key,
        vintage: vintageField.value?.year,
        wineType: type,
        country: certainInfo?.country ?? evidence.productOfCountry,
        region: certainInfo?.region,
        qualifier: qualifier,
        suggestedLevel: qualifier != null && agingQualifiers.contains(qualifier)
            ? WineLevel.aging
            : null,
      ),
      typeDerivedFromDenomination: certainInfo != null && type != typeWithout,
      words: List.unmodifiable(words),
      qualifier: qualifier,
      evidence: evidence,
    );
  }

  // Noise and indicators (BR7.2) ---------------------------------------------

  /// Whether [line] is one of the noise lines (b)-(f) of BR7.2.
  bool _noiseOf(_Line line) {
    if (line.address) return true;
    final words = line.words;
    if (line.index > 0 &&
        countryCodesIn(words).isNotEmpty &&
        !_isBottlingPhraseLine(line)) {
      return true;
    }
    if (words.any(_awardWords.contains)) return true;
    if (_isProse(line)) return true;
    var letterWords = 0;
    var numbers = 0;
    for (final word in words) {
      if (_isDigits(word)) {
        if (!_isPlausibleYear(word)) numbers++;
      } else if (_letterCount(word) >= 2) {
        letterWords++;
      }
    }
    return letterWords < numbers;
  }

  bool _isProse(_Line line) {
    if (line.text.endsWith('.') && line.spans.length > 1) return true;
    if (line.spans.length <= 6) return false;
    var lower = 0;
    var upper = 0;
    for (final span in line.spans) {
      final char = line.text[span.start];
      if (char.toLowerCase() == char.toUpperCase()) continue;
      if (char == char.toUpperCase()) {
        upper++;
      } else {
        lower++;
      }
    }
    return lower > upper;
  }

  /// A vintage the form saves: 1900 .. [currentYear], the range of
  /// `WineRules.validateVintage` of the app, so a certain vintage never
  /// fails on "Save" (deviation from the "+1" of BR7.6, noted in rules.md).
  bool _isPlausibleYear(String word) => _isSavableYear(word, currentYear);

  /// Distance in lines from [lineIndex] to the closest indicator line.
  int? _indicatorDistance(int lineIndex) {
    int? best;
    for (final other in indicatorLines) {
      final distance = (other - lineIndex).abs();
      if (best == null || distance < best) best = distance;
    }
    return best;
  }

  bool _hasProducerClue() {
    for (final line in lines) {
      final words = line.words;
      if (_isBottlingPhraseLine(line)) return true;
      if (_isStrongProducerLine(words)) return true;
      if (words.any(_weakProducerWords.contains)) return true;
    }
    return false;
  }

  // Denomination (BR7.3) -----------------------------------------------------

  List<_AliasHit> _aliasHits() => [
    for (final line in useful)
      for (final match in findAliasMatches(line.words))
        if (appellationOf(match.denominationKey) case final info?)
          _AliasHit(line, match, info),
  ];

  List<_Draft> _denominations(List<_AliasHit> hits) {
    final best = <String, _Draft>{};
    for (final hit in hits) {
      final draft = _denominationDraft(hit, hits);
      final current = best[hit.info.key];
      if (current == null || draft.score > current.score) {
        best[hit.info.key] = draft;
      }
    }
    return best.values.toList();
  }

  _Draft _denominationDraft(_AliasHit hit, List<_AliasHit> hits) {
    final line = hit.line;
    final match = hit.match;
    final info = hit.info;
    final distance = _indicatorDistance(line.index);
    final countryInText = textCountries.contains(info.country);
    final draft = _Draft(
      KeyField.denomination,
      info.displayName,
      0,
      line.index,
      match.start,
      info: info,
      aliasWords: match.wordCount,
      ranges: [
        (
          line.index,
          line.spans[match.start].start,
          line.spans[match.start + match.wordCount - 1].end,
        ),
      ],
    );
    final weakCounts =
        !match.weak || (distance != null && distance <= 1) || countryInText;
    if (weakCounts) {
      draft.add(
        _W.strongAlias,
        match.weak ? CandidateSignal.weakAlias : CandidateSignal.strongAlias,
      );
    } else {
      draft.add(_W.weakAlias, CandidateSignal.weakAlias);
    }
    if (distance != null) {
      if (distance <= 1) {
        draft.add(_W.indicatorNear, CandidateSignal.indicatorNear);
      } else if (distance == 2) {
        draft.add(_W.indicatorTwoLines, CandidateSignal.indicatorTwoLines);
      } else {
        draft.add(_W.indicatorElsewhere, CandidateSignal.indicatorElsewhere);
      }
    }
    if (match.wordCount >= 2) {
      draft.add(_W.multiWordAlias, CandidateSignal.multiWordAlias);
    }
    if (countryInText) {
      draft.add(
        _euCountries.contains(info.country)
            ? _W.countryEu
            : _W.countryOutsideEu,
        CandidateSignal.countryInText,
      );
    }
    final words = hit.words;
    final contained = hits.any(
      (other) =>
          other.info.key != info.key &&
          other.match.wordCount > match.wordCount &&
          _indexOfPhrase(other.words, words) >= 0,
    );
    if (contained) draft.add(_W.containedAlias, CandidateSignal.containedAlias);
    if (_isStrongProducerLine(line.words)) {
      draft.add(_W.aliasInProducerLine, CandidateSignal.aliasInProducerLine);
    }
    final isGrape =
        (grapeIndex[words.first] ?? const <AliasEntry>[]).any(
          (entry) =>
              entry.words.length == words.length &&
              _phraseAt(words, 0, entry.words),
        ) ||
        _labelGrapeNames.any(
          (phrase) =>
              phrase.length == words.length && _phraseAt(words, 0, phrase),
        );
    if (isGrape && (distance == null || distance > 1)) {
      draft.add(_W.aliasIsGrape, CandidateSignal.aliasIsGrape);
    }
    if (shortText &&
        !match.weak &&
        (match.start == 0 || match.wordCount == line.spans.length)) {
      draft.add(_W.shortTextHead, CandidateSignal.shortTextHead);
    }
    return draft;
  }

  // Producer (BR7.4) ---------------------------------------------------------

  bool _isStrongProducerLine(List<String> words) =>
      _hasProducerWord(words) ||
      words.any(
        (word) =>
            _moreProducerWords.contains(word) ||
            (word.endsWith('s') &&
                _producerWords.contains(word.substring(0, word.length - 1))),
      ) ||
      _containsPhrase(words, const ['cantina', 'sociale']);

  bool _isProducerValueWord(String word) =>
      _producerWords.contains(word) ||
      _moreProducerWords.contains(word) ||
      _weakProducerWords.contains(word) ||
      _articles.contains(word) ||
      (word.endsWith('s') &&
          _producerWords.contains(word.substring(0, word.length - 1)));

  /// Whether [line] may be a producer line (BR7.4): no indicator, no
  /// bottling words.
  bool _isProducerEligible(_Line line) {
    final words = line.words;
    if (_hasAnalysisIndicator(words)) return false;
    if (words.any(_bottlingWords.contains)) return false;
    return !_bottledBy.hasMatch(line.folded) &&
        !_producerPhrase.hasMatch(line.folded);
  }

  List<_Draft> _producers() {
    final drafts = <_Draft>[];
    final phraseLines = <int>{};
    for (final line in lines) {
      final phrase = _phraseProducer(line);
      if (phrase != null) {
        drafts.add(phrase);
        phraseLines.add(line.index);
      }
    }
    for (final line in useful) {
      final draft =
          (_isProducerEligible(line) ? _lineProducer(line) : null) ??
          _longLineProducer(line);
      if (draft != null) drafts.add(draft);
    }
    for (final line in lines) {
      if (!line.address || phraseLines.contains(line.index)) continue;
      if (line.words.any(_bottlingWords.contains)) continue;
      final draft = _addressProducer(line);
      if (draft != null) drafts.add(draft);
    }
    final estate = _estateProducer(phraseLines);
    if (estate != null) drafts.add(estate);
    final first = _firstLineProducer();
    if (first != null) drafts.add(first);
    return _mergedProducers(drafts, phraseLines);
  }

  _Draft? _phraseProducer(_Line line) {
    var source = _Source.pa;
    var end = _bottledBy.firstMatch(line.folded)?.end;
    end ??= _producerPhrase.firstMatch(line.folded)?.end;
    if (end == null) {
      final verb = _bottlingVerbBy.firstMatch(line.folded);
      if (verb == null) return null;
      source = _Source.paVerb;
      end = verb.end;
    }
    var start = end;
    while (start < line.text.length && ' :,.;-'.contains(line.text[start])) {
      start++;
    }
    final raw = _cutProducerRaw(line.text.substring(start));
    if (raw == null) return null;
    final draft = _Draft(
      KeyField.producer,
      _producerValue(raw),
      0,
      line.index,
      0,
      ranges: [(line.index, start, start + raw.length)],
    );
    if (source == _Source.pa) {
      draft.add(_W.bottlingPhrase, CandidateSignal.bottlingPhrase);
    } else {
      draft.add(_W.bottlingVerb, CandidateSignal.bottlingVerb);
    }
    draft.sources.add(source);
    return draft;
  }

  /// PB or PC: a short line with a producer word (BR7.4).
  _Draft? _lineProducer(_Line line) {
    final words = line.words;
    final strong = _isStrongProducerLine(words);
    final weak = !strong && words.any(_weakProducerWords.contains);
    if (!strong && !weak) return null;
    var end = line.text.length;
    var founding = false;
    for (final (index, span) in line.spans.indexed) {
      if (index > 0 &&
          (VintageParser.foundingWords.contains(span.word) ||
              _isYear(span.word))) {
        end = span.start;
        founding = true;
        break;
      }
    }
    final raw = _cutProducerRaw(line.text.substring(0, end));
    if (raw == null || tokenizeAll(raw).length > 6) return null;
    final draft = _Draft(
      KeyField.producer,
      _producerValue(raw),
      0,
      line.index,
      0,
      ranges: [(line.index, 0, raw.length)],
    );
    final first = (position[line.index] ?? 99) <= 1;
    if (strong) {
      draft.add(_W.producerLine, CandidateSignal.producerLine);
      draft.sources.add(_Source.pb);
    } else {
      draft.add(_W.weakProducerLine, CandidateSignal.weakProducerLine);
      draft.sources.add(_Source.pc);
    }
    if (first) draft.add(_W.firstLines, CandidateSignal.firstLines);
    if (founding) draft.add(_W.foundingCut, CandidateSignal.foundingCut);
    _penaliseOnlyProducerWords(draft);
    return draft;
  }

  /// PG: a producer word inside a long line, with its capitalised words.
  _Draft? _longLineProducer(_Line line) {
    if (line.spans.length <= 6 || _isBottlingPhraseLine(line)) return null;
    final spans = line.spans;
    for (var i = 0; i < spans.length; i++) {
      if (!_isStrongProducerLine([spans[i].word])) continue;
      var last = i;
      for (var j = i + 1; j < spans.length && j <= i + 4; j++) {
        final between = line.text.substring(spans[j - 1].end, spans[j].start);
        if (between.contains(RegExp('[,;()]'))) break;
        final char = line.text[spans[j].start];
        final capital =
            char.toLowerCase() != char.toUpperCase() &&
            char == char.toUpperCase();
        if (!capital && !_articles.contains(spans[j].word)) break;
        last = j;
      }
      while (last > i && _articles.contains(spans[last].word)) {
        last--;
      }
      if (last == i) continue;
      final raw = line.original(i, last - i + 1);
      final draft = _Draft(
        KeyField.producer,
        _producerValue(raw),
        0,
        line.index,
        i,
        ranges: [(line.index, spans[i].start, spans[last].end)],
      );
      draft.add(_W.producerInLongLine, CandidateSignal.producerInLongLine);
      draft.sources.add(_Source.pg);
      return draft;
    }
    return null;
  }

  /// PH: the company named in an address line (BR7.4).
  _Draft? _addressProducer(_Line line) {
    var end = line.text.indexOf(',');
    if (end < 0) end = line.text.length;
    final postal = _postalCode.firstMatch(line.folded);
    if (postal != null && postal.start < end) end = postal.start;
    final raw = _cutProducerRaw(line.text.substring(0, end));
    if (raw == null || !_isStrongProducerLine(tokenizeAll(raw))) return null;
    final draft = _Draft(
      KeyField.producer,
      _producerValue(raw),
      0,
      line.index,
      0,
      ranges: [(line.index, 0, raw.length)],
    );
    draft.add(_W.producerInAddress, CandidateSignal.producerInAddress);
    draft.sources.add(_Source.ph);
    _penaliseOnlyProducerWords(draft);
    return draft;
  }

  /// PD: "estate bottled" without a name, and the first plain line.
  _Draft? _estateProducer(Set<int> phraseLines) {
    final estate = lines.any(
      (line) =>
          !phraseLines.contains(line.index) &&
          _estateBottled.any((phrase) => _containsPhrase(line.words, phrase)),
    );
    if (!estate) return null;
    for (final line in useful) {
      if (!_isProducerEligible(line)) continue;
      if (line.words.any(VintageParser.foundingWords.contains)) continue;
      final residual = _nameResidual(line);
      if (residual.isEmpty || _isNameGrapeLine(line, residual)) continue;
      final raw = _cutProducerRaw(_withoutYears(line.text));
      if (raw == null) return null;
      final draft = _Draft(
        KeyField.producer,
        _producerValue(raw),
        0,
        line.index,
        0,
        ranges: [(line.index, 0, raw.length)],
      );
      draft.add(_W.estateBottled, CandidateSignal.estateBottled);
      draft.sources.add(_Source.pd);
      return draft;
    }
    return null;
  }

  /// PE: a plain first line of at most 3 words.
  _Draft? _firstLineProducer() {
    if (useful.isEmpty) return null;
    final line = useful.first;
    if (!_isProducerEligible(line) || line.spans.length > 3) return null;
    if (findAliasMatches(line.words).isNotEmpty) return null;
    final residual = _nameResidual(line);
    if (residual.isEmpty || _isNameGrapeLine(line, residual)) return null;
    if (line.words.any(VintageParser.foundingWords.contains)) return null;
    final raw = _cutProducerRaw(line.text);
    if (raw == null) return null;
    final draft = _Draft(
      KeyField.producer,
      _producerValue(raw),
      0,
      line.index,
      0,
      ranges: [(line.index, 0, raw.length)],
    );
    draft.add(_W.plainFirstLine, CandidateSignal.plainFirstLine);
    draft.sources.add(_Source.pe);
    return draft;
  }

  void _penaliseOnlyProducerWords(_Draft draft) {
    if (draft.words.every(_isProducerValueWord)) {
      draft.add(_W.onlyProducerWords, CandidateSignal.onlyProducerWords);
    }
  }

  /// The same producer from several sources becomes one candidate with the
  /// longer text (BR7.4), then the signals "unique" and "two sources".
  List<_Draft> _mergedProducers(List<_Draft> drafts, Set<int> phraseLines) {
    drafts.sort((a, b) => b.score.compareTo(a.score));
    final groups = <_Draft>[];
    for (final draft in drafts) {
      final words = draft.words;
      final group = groups.where((g) {
        final other = g.words;
        return words.isNotEmpty &&
            other.isNotEmpty &&
            (other.containsAll(words) || words.containsAll(other));
      }).firstOrNull;
      if (group == null) {
        groups.add(draft);
        continue;
      }
      if (_longer(draft.value, group.value)) group.value = draft.value;
      group.sources.addAll(draft.sources);
      group.ranges.addAll(draft.ranges);
      group.signals.addAll(draft.signals);
    }
    for (final group in groups) {
      final phrase =
          group.sources.contains(_Source.pa) ||
          group.sources.contains(_Source.paVerb);
      // Two sources are two lines: a line read twice is one clue.
      final lineCount = {for (final (line, _, _) in group.ranges) line}.length;
      if ((group.sources.length >= 2 && lineCount >= 2) ||
          (phrase && _plainLineRepeats(group, phraseLines))) {
        group.add(_W.twoSources, CandidateSignal.twoSources);
      }
    }
    const lineSources = {_Source.pb, _Source.pc, _Source.pg, _Source.ph};
    final lineGroups = groups
        .where((g) => g.sources.any(lineSources.contains))
        .toList();
    if (lineGroups.length == 1) {
      lineGroups.single.add(_W.uniqueProducer, CandidateSignal.uniqueProducer);
    }
    return groups;
  }

  /// Whether a plain line other than the bottling line holds only words of
  /// the producer of [group] ("Corte Sasso Nero" above "Imbottigliato nel
  /// 2022 da Corte Sasso Nero").
  bool _plainLineRepeats(_Draft group, Set<int> phraseLines) {
    final words = group.words;
    for (final line in useful) {
      if (phraseLines.contains(line.index)) continue;
      final lineWords = line.words;
      if (lineWords.isEmpty) continue;
      if (lineWords.where((w) => !_articles.contains(w)).isEmpty) continue;
      if (words.containsAll(lineWords)) return true;
    }
    return false;
  }

  // Name (BR7.5) -------------------------------------------------------------

  /// The words of [line] that could be a name (BR1.5), without the style
  /// phrases of BR7.5 and the indicator phrases of BR7.3.
  List<String> _nameResidual(_Line line) {
    final words = line.words;
    final styled = <String>{
      for (final phrase in _stylePhrases)
        if (_containsPhrase(words, phrase)) ...phrase,
    };
    return [
      for (final word in _residualOf(line, null))
        if (!styled.contains(word) &&
            !_indicatorPhraseWords.contains(word) &&
            !_moreStyleWords.contains(word) &&
            !_moreVintageWords.contains(word) &&
            !_isNumberNoise(word))
          word,
    ];
  }

  /// A number that is no name: "’24", "2022er", "MMXVIII".
  bool _isNumberNoise(String word) {
    if (_isDigits(word) && word.length <= 2) return true;
    if (word.length == 6 &&
        word.endsWith('er') &&
        _isDigits(word.substring(0, 4))) {
      return true;
    }
    return word.length >= 4 && word.split('').every('mdclxvi'.contains);
  }

  /// Whether [line] is only an alias that is also a grape name, with no
  /// indicator: "Malvasia" under "Madeira".
  bool _isAliasGrapeLine(_Line line) {
    if (_hasAnalysisIndicator(line.words)) return false;
    final named = [
      for (final word in line.words)
        if (_isNameWord(word) && !_indicatorPhraseWords.contains(word)) word,
    ];
    return named.isNotEmpty && _isNameGrapeLine(line, named);
  }

  /// Whether the [residual] words of [line] are all words of a grape, of
  /// the table or of [_labelGrapeNames].
  bool _isNameGrapeLine(_Line line, List<String> residual) {
    final words = line.words;
    final covered = _grapeWordsOf(words);
    for (final phrase in _labelGrapeNames) {
      if (_containsPhrase(words, phrase)) covered.addAll(phrase);
    }
    return covered.isNotEmpty && residual.every(covered.contains);
  }

  List<_Draft> _names(
    List<_AliasHit> hits,
    _Draft? denomination,
    bool denominationCertain,
    List<_Draft> producers,
  ) {
    final producerLines = <int>{};
    // A noise line naming a company ("E. Guigal, propriétaire-négociant à
    // Ampuis, France") gives no candidate (BR7.2) but tells that its words
    // are the producer's, not a brand.
    final producerWords = <String>{
      for (final line in lines)
        if (noise[line.index] && _isStrongProducerLine(line.words))
          ...line.words,
    };
    for (final producer in producers) {
      if (producer.sources.every((s) => s == _Source.pe)) continue;
      producerWords.addAll(producer.words);
      if (producer.sources.contains(_Source.pb) ||
          producer.sources.contains(_Source.pc)) {
        for (final (line, _, _) in producer.ranges) {
          producerLines.add(line);
        }
      }
    }
    final brands = <_Line>[];
    final grapes = <_Line>[];
    _Line? weakBrand;
    for (final line in useful) {
      if (!_canBeName(line) || _isBottlingPhraseLine(line)) continue;
      final residual = _nameResidual(line);
      if (residual.isEmpty) {
        // An alias that is also a grape ("Malvasia") names the grape.
        if (_isAliasGrapeLine(line)) grapes.add(line);
        continue;
      }
      if (_isNameGrapeLine(line, residual)) {
        grapes.add(line);
        continue;
      }
      final isProducerLine = producerLines.contains(line.index);
      if (isProducerLine || residual.every(producerWords.contains)) {
        if (isProducerLine &&
            weakBrand == null &&
            line.words.any(_weakProducerWords.contains) &&
            !_isStrongProducerLine(line.words)) {
          weakBrand = line;
        }
        continue;
      }
      if (_isStrongProducerLine(line.words)) continue;
      brands.add(line);
    }
    final producerSure = producers.any((p) => p.score >= 80);
    final builder = _NameBuilder(this, producerSure, {
      for (final line in brands) line.index,
      ?weakBrand?.index,
    });
    final hit = denomination == null ? null : _hitOf(hits, denomination);
    final grape = grapes.firstOrNull;
    final drafts = <_Draft>[];
    // NA, NB, NC, ND.
    final single = brands.length == 1 ? brands.single : null;
    final singleShort = single != null && _brandWordCount(single) <= 3;
    var na = false;
    if (single != null && singleShort && hit != null) {
      final info = hit.info;
      final brand = _nameText(single);
      // A cuvée is a name of its own ("Cuvée 2000"), never preceded by the
      // denomination.
      final cuvee = _cuveeWords.contains(single.words.first);
      if (const {'IT', 'FR'}.contains(info.country) &&
          info.dedicated &&
          !cuvee &&
          !_brandSharesWords(brand, info)) {
        na = true;
        drafts.add(
          builder.from(
            [(hit.line, _aliasRange(hit)), (single, null)],
            denominationCertain
                ? _W.denominationAndBrandCertain
                : _W.denominationAndBrandUncertain,
            CandidateSignal.denominationAndBrand,
          ),
        );
        drafts.add(
          builder.from(
            [(single, null)],
            _W.brandBesideDenomination,
            CandidateSignal.brandAlone,
          ),
        );
      }
    }
    final ncBrand = single != null && singleShort
        ? single
        : (brands.isEmpty ? weakBrand : null);
    final nc = ncBrand != null && grape != null;
    if (nc) {
      drafts.add(
        builder.from(
          [(ncBrand, null), (grape, null)],
          _W.brandAndGrape,
          CandidateSignal.brandAndGrape,
        ),
      );
      if (!na) {
        drafts.add(
          builder.from(
            [(ncBrand, null)],
            _W.brandBesideGrape,
            CandidateSignal.brandAlone,
          ),
        );
      }
    } else if (single != null && !na) {
      final p = position[single.index] ?? 99;
      drafts.add(
        builder.from(
          [(single, null)],
          singleShort && p <= 2 ? _W.singleShortBrand : _W.singleBrand,
          CandidateSignal.singleBrand,
        ),
      );
    }
    if (brands.length >= 2) {
      final longest = const LabelLinePicker().longest([
        for (final line in brands) _withoutYears(line.text),
      ]);
      for (final line in brands) {
        final draft = builder.from(
          [(line, null)],
          _W.severalBrands,
          CandidateSignal.severalBrands,
        );
        if (_withoutYears(line.text) == longest) {
          draft.add(_W.longestBrand, CandidateSignal.longestBrand);
        }
        drafts.add(draft);
      }
    }
    // NE.
    if (brands.isEmpty && grapes.isEmpty) {
      for (final line in useful) {
        final words = line.words;
        if (words.isEmpty) continue;
        if (!const {
          'chateau',
          'domaine',
          'clos',
          'quinta',
          'herdade',
        }.contains(words.first)) {
          continue;
        }
        final raw = _cutProducerRaw(line.text);
        if (raw == null) continue;
        drafts.add(
          builder.text(
            _smartCase(raw),
            [(line.index, 0, raw.length)],
            line,
            _W.houseLine,
            CandidateSignal.houseLine,
          ),
        );
        break;
      }
    }
    // NF.
    if (grape != null) {
      drafts.add(
        builder.from(
          [(grape, null)],
          nc
              ? _W.grapeBesideBrand
              : (brands.isNotEmpty ? _W.grapeWithBrands : _W.grapeAlone),
          CandidateSignal.grapeAlone,
        ),
      );
    }
    if (hit != null) {
      // NI.
      if (grape != null && brands.isEmpty) {
        drafts.add(
          builder.from(
            [(hit.line, _aliasRange(hit)), (grape, null)],
            _W.denominationAndGrape,
            CandidateSignal.denominationAndGrape,
          ),
        );
      }
      // NG and NH.
      drafts.addAll(_denominationNames(hit, brands, grapes, builder));
    }
    // NJ.
    final producer = producers.firstOrNull;
    if (producer != null) {
      final head = _headLineOf(producer);
      final parts = head == null ? null : <(_Line, (int, int)?)>[(head, null)];
      drafts.add(
        parts == null
            ? builder.text(
                producer.value,
                producer.ranges,
                null,
                _W.producerAsName,
                CandidateSignal.producerAsName,
              )
            : builder.from(
                parts,
                _W.producerAsName,
                CandidateSignal.producerAsName,
              ),
      );
      if (grape != null && brands.isEmpty) {
        drafts.add(
          parts == null
              ? builder.text(
                  '${producer.value} ${_nameText(grape)}',
                  [...producer.ranges, (grape.index, 0, grape.text.length)],
                  grape,
                  _W.producerAndGrape,
                  CandidateSignal.producerAndGrape,
                )
              : builder.from(
                  [...parts, (grape, null)],
                  _W.producerAndGrape,
                  CandidateSignal.producerAndGrape,
                ),
        );
      }
    }
    return drafts;
  }

  _AliasHit? _hitOf(List<_AliasHit> hits, _Draft denomination) {
    for (final hit in hits) {
      if (hit.info.key == denomination.info?.key &&
          hit.line.index == denomination.line &&
          hit.match.start == denomination.word) {
        return hit;
      }
    }
    return null;
  }

  (int, int) _aliasRange(_AliasHit hit) {
    final words = hit.line.words;
    var end = hit.match.start + hit.match.wordCount;
    for (final phrase in qualifierPhrases) {
      if (end < words.length && _phraseAt(words, end, phrase.words)) {
        end += phrase.words.length;
        break;
      }
    }
    return (hit.match.start, end);
  }

  int _brandWordCount(_Line line) =>
      tokenizeAll(_withoutYears(line.text)).length;

  /// A line near the top holding part of a producer read after a bottling
  /// phrase ("HOLLOW OAK" of "Hollow Oak Cellars", BR7.5 NJ).
  _Line? _headLineOf(_Draft producer) {
    if (!producer.sources.contains(_Source.pa) &&
        !producer.sources.contains(_Source.paVerb)) {
      return null;
    }
    final words = producer.words;
    for (final line in useful) {
      if ((position[line.index] ?? 99) > 1) break;
      final lineWords = line.words.where((w) => !_articles.contains(w));
      if (lineWords.isEmpty) continue;
      if (words.containsAll(lineWords) && line.words.length < words.length) {
        return line;
      }
    }
    return null;
  }

  /// NG and NH (BR7.5): the text of the denomination line with its
  /// qualifier and style lines, and the alias alone.
  List<_Draft> _denominationNames(
    _AliasHit hit,
    List<_Line> brands,
    List<_Line> grapes,
    _NameBuilder builder,
  ) {
    final line = hit.line;
    final match = hit.match;
    final long = line.spans.length > 6;
    var start = match.start;
    var end = match.start + match.wordCount;
    if (!long) {
      start = 0;
      end = line.spans.length;
      while (start < match.start &&
          _indicatorPhraseWords.contains(line.spans[start].word)) {
        start++;
      }
      while (end > match.start + match.wordCount &&
          (_indicatorPhraseWords.contains(line.spans[end - 1].word) ||
              _isYear(line.spans[end - 1].word))) {
        end--;
      }
    }
    final parts = <(_Line, (int, int)?)>[(line, (start, end))];
    final row = denominationTable[hit.info.key];
    final qualifierWords = {
      ..._qualifierLineWords,
      if (row?.qualifierOffsets.containsKey(Qualifier.vintage) ?? false)
        'vintage',
    };
    _Line? qualifierLine;
    _Line? styleLine;
    for (final other in useful) {
      if (identical(other, line)) continue;
      final words = other.words.where((w) => !_isYear(w)).toList();
      if (words.isEmpty) continue;
      final qualifier = words.any(qualifierWords.contains);
      final allKnown = words.every(
        (w) => qualifierWords.contains(w) || _plainStyleWords.contains(w),
      );
      if (!allKnown) continue;
      if (qualifier) {
        qualifierLine ??= other;
      } else {
        styleLine ??= other;
      }
    }
    final extra = [?qualifierLine, ?styleLine]
      ..sort((a, b) => a.index.compareTo(b.index));
    for (final other in extra) {
      parts.add((other, null));
    }
    final ng = builder.from(
      parts,
      extra.isEmpty ? _W.denominationLine : _W.denominationLinePlus,
      CandidateSignal.denominationLine,
    );
    // Only the denomination line names the wine: no brand, grape or
    // producer line beside it ("Chianti Classico Riserva / 2018").
    final alone = useful.every(
      (other) =>
          identical(other, line) ||
          identical(other, qualifierLine) ||
          identical(other, styleLine) ||
          _nameResidual(other).isEmpty,
    );
    // A name assembled from several lines stays a guess: only the
    // denomination line alone gets the bonus.
    if (shortText &&
        alone &&
        extra.isEmpty &&
        brands.isEmpty &&
        grapes.isEmpty &&
        match.start == 0 &&
        line.spans.length <= 6) {
      ng.add(
        _W.shortTextDenominationLine,
        CandidateSignal.shortTextDenominationLine,
      );
    }
    final nh = builder.from(
      [(line, (match.start, match.start + match.wordCount))],
      _W.aliasOnly,
      CandidateSignal.aliasOnly,
    );
    return [ng, nh];
  }

  // Vintage (BR7.6) ----------------------------------------------------------

  List<_Draft> _vintages() {
    final drafts = <_Draft>[];
    for (final line in lines) {
      final spans = line.spans;
      for (var i = 0; i < spans.length; i++) {
        final year = _yearOfWord(spans[i].word);
        if (year == null) continue;
        final draft = _Draft(
          KeyField.vintage,
          '$year',
          0,
          line.index,
          i,
          year: year,
          ranges: [(line.index, spans[i].start, spans[i].end)],
        );
        draft.add(_W.year, CandidateSignal.year);
        _yearSignals(draft, line, i);
        drafts.add(draft);
      }
    }
    const negative = {
      CandidateSignal.foundingYear,
      CandidateSignal.bottlingYear,
      CandidateSignal.awardOrAddressYear,
      CandidateSignal.cuveeYear,
    };
    final clean = drafts
        .where((d) => !d.signals.any(negative.contains))
        .map((d) => d.year)
        .toSet();
    if (clean.length == 1) {
      for (final draft in drafts) {
        if (draft.year == clean.single &&
            !draft.signals.any(negative.contains)) {
          draft.add(_W.uniqueYear, CandidateSignal.uniqueYear);
        }
      }
    }
    return drafts;
  }

  int? _yearOfWord(String word) {
    final digits = word.length == 6 && word.endsWith('er')
        ? word.substring(0, 4)
        : word;
    if (!_isPlausibleYear(digits)) return null;
    return int.parse(digits);
  }

  void _yearSignals(_Draft draft, _Line line, int i) {
    final words = line.words;
    bool isVintageWord(String word) =>
        VintageParser.vintageWords.contains(word) ||
        _moreVintageWords.contains(word);
    var vintage = false;
    for (var d = 1; d <= 3; d++) {
      if (i - d >= 0 && isVintageWord(words[i - d])) vintage = true;
      if (i + d < words.length && isVintageWord(words[i + d])) vintage = true;
    }
    if (!vintage && line.index > 0) {
      final previous = lines[line.index - 1].words;
      vintage = previous.length == 1 && isVintageWord(previous.single);
    }
    if (vintage) draft.add(_W.vintageWord, CandidateSignal.vintageWord);
    if (words.length == 1) draft.add(_W.yearAlone, CandidateSignal.yearAlone);
    for (var d = 1; d <= 3 && i - d >= 0; d++) {
      if (VintageParser.foundingWords.contains(words[i - d])) {
        draft.add(_W.foundingYear, CandidateSignal.foundingYear);
        break;
      }
    }
    for (var d = 1; d <= 5 && i - d >= 0; d++) {
      if (_bottlingYearWords.contains(words[i - d])) {
        draft.add(_W.bottlingYear, CandidateSignal.bottlingYear);
        break;
      }
    }
    if (line.address ||
        words.any(_awardWords.contains) ||
        _inYearRange(line, i)) {
      draft.add(_W.awardOrAddressYear, CandidateSignal.awardOrAddressYear);
    }
    if (i > 0 && _cuveeWords.contains(words[i - 1])) {
      draft.add(_W.cuveeYear, CandidateSignal.cuveeYear);
    }
  }

  /// Whether the year at [i] is an end of a range "1890 - 2025".
  bool _inYearRange(_Line line, int i) {
    final spans = line.spans;
    bool dashBetween(int a, int b) {
      final between = line.text.substring(spans[a].end, spans[b].start).trim();
      return between == '-' || between == '–' || between == '—';
    }

    if (i > 0 && _isYear(spans[i - 1].word) && dashBetween(i - 1, i)) {
      return true;
    }
    return i + 1 < spans.length &&
        _isYear(spans[i + 1].word) &&
        dashBetween(i, i + 1);
  }

  // Ranking and certainty (BR7.1, BR7.7, BR7.8) ------------------------------

  /// The drafts validated (BR1.9), merged by folded value with the higher
  /// score, ordered and cut to 5 (BR7.1).
  List<FieldCandidate> _ranked(List<_Draft> drafts) => [
    for (final draft in _rankedDrafts(drafts)) _candidateOf(draft),
  ];

  List<_Draft> _rankedDrafts(List<_Draft> drafts) {
    final merged = <String, _Draft>{};
    for (final draft in drafts) {
      draft.score = draft.score.clamp(0, 100);
      if (!_isValid(draft)) continue;
      final key = tokenizeAll(draft.value).join(' ');
      final current = merged[key];
      if (current == null || _before(draft, current)) merged[key] = draft;
    }
    final ordered = merged.values.toList()..sort((a, b) => _compare(a, b));
    return ordered.take(5).toList();
  }

  bool _before(_Draft a, _Draft b) => _compare(a, b) < 0;

  int _compare(_Draft a, _Draft b) {
    final byScore = b.score.compareTo(a.score);
    if (byScore != 0) return byScore;
    final byAlias = b.aliasWords.compareTo(a.aliasWords);
    if (byAlias != 0) return byAlias;
    final byLine = a.line.compareTo(b.line);
    if (byLine != 0) return byLine;
    return a.word.compareTo(b.word);
  }

  bool _isValid(_Draft draft) {
    final value = draft.value.trim();
    draft.value = value;
    return switch (draft.field) {
      KeyField.vintage => draft.year != null,
      KeyField.denomination => draft.info != null,
      KeyField.name =>
        hasLetters(value, minLetters: 1) &&
            value.length <= maxExtractedNameLength,
      KeyField.producer =>
        hasLetters(value, minLetters: 1) &&
            value.length <= maxExtractedProducerLength,
    };
  }

  FieldCandidate _candidateOf(_Draft draft) {
    final ids = <int>{};
    for (final (line, start, end) in draft.ranges) {
      for (final ref in refs) {
        if (ref.line == line && ref.start < end && ref.end > start) {
          ids.add(ref.id);
        }
      }
    }
    return FieldCandidate(
      field: draft.field,
      value: draft.value,
      score: draft.score,
      year: draft.year,
      denominationKey: draft.info?.key,
      wordIds: List.unmodifiable(ids.toList()..sort()),
      signals: Set.unmodifiable(draft.signals),
    );
  }

  KeyFieldAnalysis _field(
    KeyField field,
    List<FieldCandidate> candidates,
    bool Function() noClue,
  ) {
    final FieldCertainty certainty;
    if (candidates.isNotEmpty &&
        isCertainScore(
          candidates.first.score,
          candidates.length > 1 ? candidates[1].score : null,
        )) {
      certainty = FieldCertainty.certain;
    } else if (candidates.isEmpty && field != KeyField.vintage && noClue()) {
      certainty = FieldCertainty.absent;
    } else {
      certainty = FieldCertainty.uncertain;
    }
    return KeyFieldAnalysis(
      field: field,
      candidates: List.unmodifiable(candidates),
      certainty: certainty,
    );
  }

  // Type evidence (BR1.6, BR7.8 b) -------------------------------------------

  _TypeEvidence _evidence(List<_AliasHit> hits) {
    final read = [
      for (final line in lines)
        if (!line.address) line,
    ];
    final words = [for (final line in read) ...line.words];
    WineType? grapeType;
    WineType? outside;
    for (final line in read) {
      grapeType ??= switch (findGrape(line.words)) {
        final match? => grapeTable[match.denominationKey]?.wineType,
        null => null,
      };
      if (outside == null) {
        final masked = [...line.words];
        for (final match in findAliasMatches(line.words)) {
          for (var i = match.start; i < match.start + match.wordCount; i++) {
            masked[i] = '';
          }
        }
        final match = findGrape(masked);
        if (match != null) {
          outside = grapeTable[match.denominationKey]?.wineType;
        }
      }
    }
    var mask = 0;
    for (final line in read) {
      mask |= qualifierMaskOf(line.words);
    }
    return _TypeEvidence(
      fortified: words.any(_fortifiedWords.contains),
      sweet: words.any(_sweetWords.contains),
      sparkling: words.any(_sparklingWords.contains),
      classic:
          words.any(_classicWords.contains) ||
          _classicPhrases.any((phrase) => _containsPhrase(words, phrase)),
      rose: words.any(_roseWords.contains),
      white: words.any(_whiteWords.contains),
      red: words.any(_redWords.contains),
      grapeType: grapeType,
      grapeTypeOutsideAliases: outside,
      qualifierMask: mask,
      productOfCountry: _productOfCountry(read),
    );
  }
}

/// Builds the name candidates from parts of lines (BR7.5), with the
/// penalty Q on an all-capitals brand of 1 or 2 words at the top.
class _NameBuilder {
  _NameBuilder(this.analyzer, this.producerSure, this.brandLines);

  final _Analyzer analyzer;
  final bool producerSure;

  /// The brand lines, the only ones the penalty Q applies to.
  final Set<int> brandLines;

  /// A name made of [parts]: a line with a word range, or the whole name
  /// text of a line (`null` range).
  _Draft from(
    List<(_Line, (int, int)?)> parts,
    int weight,
    CandidateSignal signal,
  ) {
    final texts = <String>[];
    final ranges = <(int, int, int)>[];
    for (final (line, range) in parts) {
      if (range == null) {
        texts.add(_nameText(line));
        ranges.add((line.index, 0, line.text.length));
      } else {
        final (start, end) = range;
        texts.add(_smartCase(line.original(start, end - start)));
        ranges.add((
          line.index,
          line.spans[start].start,
          line.spans[end - 1].end,
        ));
      }
    }
    final first = parts.first.$1;
    final draft = _Draft(
      KeyField.name,
      _cutName(texts.join(' ')),
      0,
      first.index,
      0,
      ranges: ranges,
    );
    draft.add(weight, signal);
    for (final (line, range) in parts) {
      if (range == null && _isUppercaseHead(line)) {
        draft.add(_W.uppercaseBrand, CandidateSignal.uppercaseBrand);
        break;
      }
    }
    return draft;
  }

  /// A name of a given [value].
  _Draft text(
    String value,
    List<(int, int, int)> ranges,
    _Line? line,
    int weight,
    CandidateSignal signal,
  ) {
    final draft = _Draft(
      KeyField.name,
      _cutName(value),
      0,
      ranges.isEmpty ? 0 : ranges.first.$1,
      0,
      ranges: [...ranges],
    );
    draft.add(weight, signal);
    return draft;
  }

  bool _isUppercaseHead(_Line line) {
    if (producerSure || !brandLines.contains(line.index)) return false;
    if ((analyzer.position[line.index] ?? 99) > 1) return false;
    final count = tokenizeAll(_withoutYears(line.text)).length;
    if (count < 1 || count > 2) return false;
    return _isUppercaseLine(line.text);
  }
}

// ---------------------------------------------------------------------------
// Helpers of the analysis.

/// Whether [words] hold an indicator of BR7.3; "do" counts only at the end
/// of the line (Portuguese "do" is "of the": "Quinta do Vale").
bool _hasAnalysisIndicator(List<String> words) {
  final filtered = [
    for (final (index, word) in words.indexed)
      if (word != 'do' || index == words.length - 1) word,
  ];
  if (_hasIndicator(filtered)) return true;
  return _indicatorPhrases.any((phrase) => _containsPhrase(words, phrase));
}

/// A line of at least 3 letters, all capitals (BR7.2).
bool _isUppercaseLine(String text) {
  var letters = 0;
  for (final rune in text.runes) {
    final char = String.fromCharCode(rune);
    if (char.toLowerCase() == char.toUpperCase()) continue;
    if (char != char.toUpperCase()) return false;
    letters++;
  }
  return letters >= 3;
}

/// The text of [line] as a name (BR7.5): years removed, except after
/// cuvée, bin, no; "’24" removed; in title case when all capitals.
String _nameText(_Line line) {
  final kept = <String>[];
  String? previous;
  for (final token in line.text.split(' ')) {
    final word = tokenizeAll(token);
    final isYear = word.length == 1 && _isYear(word.single);
    final isShortYear = RegExp(r"^['’]\d{2}$").hasMatch(token);
    if (isShortYear) continue;
    if (isYear && !(previous != null && _cuveeWords.contains(previous))) {
      continue;
    }
    kept.add(token);
    previous = word.isEmpty ? previous : word.last;
  }
  return _smartCase(kept.join(' ').trim());
}

bool _isDigits(String word) =>
    word.isNotEmpty && word.codeUnits.every((u) => u >= 0x30 && u <= 0x39);

int _letterCount(String word) =>
    word.codeUnits.where((u) => u < 0x30 || u > 0x39).length;

bool _longer(String a, String b) {
  final byWords = tokenizeAll(a).length.compareTo(tokenizeAll(b).length);
  if (byWords != 0) return byWords > 0;
  return a.length > b.length;
}

/// The producer value of the raw text [raw] (BR7.4): title case when all
/// capitals, at most [maxExtractedProducerLength] characters.
String _producerValue(String raw) {
  final cased = _smartCase(raw);
  return cased.length <= maxExtractedProducerLength
      ? cased
      : cased.substring(0, maxExtractedProducerLength).trimRight();
}
