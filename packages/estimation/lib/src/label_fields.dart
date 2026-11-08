// The fields of a wine read from the text of its label (label-autofill-windows
// D1, BR1.1-BR1.9, ENT-003): name, producer, denomination, vintage, type,
// country, region and the suggested level. Pure and deterministic: the same
// text and year give the same fields, with no network and no clock.
//
// The text is untrusted data (NFR3.4): it is only cut, cleaned and read as
// words, never interpreted. Nothing here keeps or logs it (FR2.3, NFR3.2).
//
// "No invented field" (FR1.1): every value is either text of the label or
// comes from a table entry named by a word of the label; a field that cannot
// be read with confidence stays empty.
//
// The library is split in parts (D7): the lines, words and vocabulary shared
// with the analysis of the guided check (label_lines.dart), its weights
// (label_scoring.dart), its candidates (label_candidates.dart) and the words
// a value is composed from (label_words.dart).

import 'appellations.dart';
import 'country_names.dart';
import 'grapes.dart';
import 'label_line_picker.dart';
import 'models.dart';
import 'qualifiers.dart';
import 'recognizer.dart';
import 'tables.dart';
import 'vintage_parser.dart';

part 'label_candidates.dart';
part 'label_lines.dart';
part 'label_scoring.dart';
part 'label_words.dart';

/// Longest text read (FR2.3): the rest is dropped.
const int maxLabelTextLength = 4000;

/// Longest name and producer filled in (ENT-003).
const int maxExtractedNameLength = 60;
const int maxExtractedProducerLength = 80;

/// The qualifier of [text] (a name and appellation typed in the add or edit
/// form) when it suggests the "aging" level (BR1.8, FR4.3), as the
/// extractor reads it: the most specific qualifier wins, "Vintage" counts
/// only for an appellation that has it (Porto), and a qualifier that does
/// not suggest "aging" ("Crianza", "Superiore") gives `null`.
Qualifier? agingQualifierIn(String text) {
  final words = tokenizeAll(sanitizeLabelText(text));
  if (words.isEmpty) return null;
  final match = findAlias(words);
  final row = match == null ? null : denominationTable[match.denominationKey];
  for (final qualifier in qualifiersOf(qualifierMaskOf(words))) {
    if (qualifier == Qualifier.vintage &&
        !(row?.qualifierOffsets.containsKey(Qualifier.vintage) ?? false)) {
      continue;
    }
    return agingQualifiers.contains(qualifier) ? qualifier : null;
  }
  return null;
}

/// Names of the fields of [LabelFields.sourceKeys].
abstract final class LabelFieldKeys {
  static const String name = 'name';
  static const String producer = 'producer';
  static const String denomination = 'denomination';
  static const String vintage = 'vintage';
  static const String wineType = 'wineType';
  static const String country = 'country';
  static const String region = 'region';
}

/// What a label text gives (ENT-003). Kept in memory only.
class LabelFields {
  const LabelFields({
    this.name,
    this.producer,
    this.denomination,
    this.denominationKey,
    this.vintage,
    this.wineType,
    this.country,
    this.region,
    this.suggestedLevel,
    this.qualifier,
  });

  static const LabelFields empty = LabelFields();

  final String? name;
  final String? producer;

  /// Display name of the table row ("Saint-Estèphe", "Barolo DOCG").
  final String? denomination;

  /// Key of that row.
  final String? denominationKey;
  final int? vintage;
  final WineType? wineType;

  /// ISO 3166-1 alpha-2 code.
  final String? country;

  /// Canonical region of `WineOrigins`.
  final String? region;

  /// Only `aging`, from a qualifier (BR1.8, FR4.3).
  final WineLevel? suggestedLevel;

  /// The qualifier that suggested the level, for its reason in the form.
  final Qualifier? qualifier;

  /// The fields filled in, named as [LabelFieldKeys].
  Set<String> get sourceKeys => {
    if (name != null) LabelFieldKeys.name,
    if (producer != null) LabelFieldKeys.producer,
    if (denomination != null) LabelFieldKeys.denomination,
    if (vintage != null) LabelFieldKeys.vintage,
    if (wineType != null) LabelFieldKeys.wineType,
    if (country != null) LabelFieldKeys.country,
    if (region != null) LabelFieldKeys.region,
  };

  /// True when no field was filled in.
  bool get isEmpty => sourceKeys.isEmpty;

  // No text in the string form: it may end up in a log (NFR3.2).
  @override
  String toString() => 'LabelFields(${sourceKeys.join(', ')})';
}

/// [text] cut to [maxLabelTextLength] characters and cleaned (NFR3.4):
/// control characters, unusual spaces and markup tags become spaces,
/// zero-width characters are removed, line breaks stay.
String sanitizeLabelText(String text) {
  var cut = text.length <= maxLabelTextLength
      ? text
      : text.substring(0, maxLabelTextLength);
  if (cut.isNotEmpty) {
    final last = cut.codeUnitAt(cut.length - 1);
    if (last >= 0xD800 && last <= 0xDBFF) {
      cut = cut.substring(0, cut.length - 1);
    }
  }
  final buffer = StringBuffer();
  for (final unit in cut.codeUnits) {
    if (unit == 0x0A) {
      buffer.writeCharCode(unit);
    } else if (unit == 0x0D) {
      buffer.write('\n');
    } else if (_zeroWidth.contains(unit)) {
      continue;
    } else if (unit < 0x20 || (unit >= 0x7F && unit <= 0x9F)) {
      buffer.write(' ');
    } else if (_unusualSpaces.contains(unit) ||
        (unit >= 0x2000 && unit <= 0x200A)) {
      buffer.write(' ');
    } else {
      buffer.writeCharCode(unit);
    }
  }
  return buffer.toString().replaceAll(_tag, ' ');
}

const Set<int> _zeroWidth = {0x200B, 0x200C, 0x200D, 0x2060, 0xFEFF, 0x00AD};
const Set<int> _unusualSpaces = {
  0x00A0,
  0x1680,
  0x2028,
  0x2029,
  0x202F,
  0x205F,
  0x3000,
};
final RegExp _tag = RegExp(r'<[^<>\n]{0,60}>');

/// Reads the fields of the label [text] (BR1.1-BR1.9). [currentYear] bounds
/// the vintage (BR1.3).
LabelFields extractLabelFields(String text, {required int currentYear}) {
  final lines = _linesOf(sanitizeLabelText(text));
  if (lines.isEmpty) return LabelFields.empty;
  final reader = _Reader(lines, currentYear);
  return reader.read();
}

// ---------------------------------------------------------------------------
// The reader.

class _DenominationHit {
  const _DenominationHit(this.line, this.match, this.info);

  final _Line line;
  final AliasMatch match;
  final AppellationInfo info;
}

class _Reader {
  _Reader(this.lines, this.currentYear);

  final List<_Line> lines;
  final int currentYear;

  Iterable<_Line> get _useful => lines.where((line) => !line.address);

  LabelFields read() {
    final denomination = _denomination();
    final row = denomination == null
        ? null
        : denominationTable[denomination.info.key];
    final vintage = _vintage();
    final producer = _producer(denomination);
    final qualifier = _qualifier(row);
    final type = _type(denomination, qualifier);
    final origin = _origin(denomination);
    final name = _name(denomination, producer, qualifier);
    return _validated(
      LabelFields(
        name: name,
        producer: producer?.text,
        denomination: denomination?.info.displayName,
        denominationKey: denomination?.info.key,
        vintage: vintage,
        wineType: type,
        country: origin.$1,
        region: origin.$2,
        suggestedLevel: qualifier != null && agingQualifiers.contains(qualifier)
            ? WineLevel.aging
            : null,
        qualifier: qualifier,
      ),
    );
  }

  // BR1.2 -------------------------------------------------------------------

  _DenominationHit? _denomination() {
    _DenominationHit? best;
    for (final line in _useful) {
      for (final match in findAliasMatches(line.words)) {
        final info = appellationOf(match.denominationKey);
        if (info == null) continue;
        if (match.weak && !_hasIndicatorNear(line, info.country)) continue;
        if (best == null || match.wordCount > best.match.wordCount) {
          best = _DenominationHit(line, match, info);
        }
      }
    }
    return best;
  }

  bool _hasIndicatorNear(_Line line, String country) {
    for (final other in lines) {
      if ((other.index - line.index).abs() > 1) continue;
      if (weakAliasCountsIn(other.words, country)) return true;
    }
    return false;
  }

  // BR1.3 -------------------------------------------------------------------

  int? _vintage() => const VintageParser().parse(
    [for (final line in lines) line.text].join('\n'),
    currentYear: currentYear,
    ambiguousAsNull: true,
  );

  // BR1.4 -------------------------------------------------------------------

  _Producer? _producer(_DenominationHit? denomination) {
    for (final line in lines) {
      final match = _bottledBy.firstMatch(line.folded);
      if (match == null) continue;
      final rest = _cutProducer(line.text.substring(match.end));
      if (rest != null) return _Producer(rest, null);
    }
    for (final line in _useful) {
      if (!_canBeProducerLine(line, denomination)) continue;
      if (_hasProducerWord(line.words)) {
        final text = _cutProducer(line.text);
        if (text != null) return _Producer(text, line.index);
      }
    }
    final estate = lines.any(
      (line) =>
          _estateBottled.any((phrase) => _containsPhrase(line.words, phrase)),
    );
    if (!estate) return null;
    for (final line in _useful) {
      if (!_canBeProducerLine(line, denomination)) continue;
      if (_isPlainLine(line, denomination)) {
        return _Producer(_smartCase(line.text), line.index);
      }
    }
    return null;
  }

  bool _canBeProducerLine(_Line line, _DenominationHit? denomination) {
    if (identical(line, denomination?.line)) return false;
    final words = line.words;
    if (words.any(_bottlingWords.contains)) return false;
    if (words.any(VintageParser.foundingWords.contains)) return false;
    if (_hasIndicator(words)) return false;
    return !words.any(_isYear);
  }

  /// A line that is only a name: not the denomination, a grape, a style, a
  /// classification, a qualifier or a year.
  bool _isPlainLine(_Line line, _DenominationHit? denomination) {
    final residual = _residual(line, denomination);
    if (residual.isEmpty) return false;
    return !_isGrapeLine(line, residual);
  }

  // BR1.8 -------------------------------------------------------------------

  Qualifier? _qualifier(DenominationProfile? row) => _qualifierOf(_useful, row);

  // BR1.6 -------------------------------------------------------------------

  WineType? _type(_DenominationHit? denomination, Qualifier? qualifier) {
    final words = [for (final line in _useful) ...line.words];
    final rowTypes = denomination?.info.types ?? const <WineType>[];
    final grapeType = _grapeType();
    if (words.any(_fortifiedWords.contains)) return WineType.fortified;
    if (words.any(_sweetWords.contains)) {
      return rowTypes.contains(WineType.fortified)
          ? WineType.fortified
          : WineType.sweet;
    }
    if (words.any(_sparklingWords.contains)) {
      for (final type in rowTypes) {
        if (type.isSparkling) return type;
      }
      final classic =
          words.any(_classicWords.contains) ||
          _classicPhrases.any((phrase) => _containsPhrase(words, phrase));
      return classic ? WineType.sparklingClassic : WineType.sparklingTank;
    }
    if (words.any(_roseWords.contains)) return WineType.rose;
    if (words.any(_whiteWords.contains)) return WineType.white;
    if (words.any(_redWords.contains)) {
      if (qualifier != null && agingQualifiers.contains(qualifier)) {
        return WineType.redStructured;
      }
      final reds = [
        for (final type in [...rowTypes, ?grapeType])
          if (type == WineType.redLight || type == WineType.redStructured) type,
      ];
      return reds.isEmpty ? WineType.redLight : reds.first;
    }
    if (rowTypes.length == 1) return rowTypes.single;
    return grapeType;
  }

  WineType? _grapeType() {
    for (final line in _useful) {
      final match = findGrape(line.words);
      if (match != null) return grapeTable[match.denominationKey]?.wineType;
    }
    return null;
  }

  // BR1.7 -------------------------------------------------------------------

  (String?, String?) _origin(_DenominationHit? denomination) {
    if (denomination != null) {
      return (denomination.info.country, denomination.info.region);
    }
    return (_productOfCountry(_useful), null);
  }

  // BR1.5 -------------------------------------------------------------------

  String? _name(
    _DenominationHit? denomination,
    _Producer? producer,
    Qualifier? qualifier,
  ) {
    final producerWords = producer == null
        ? const <String>{}
        : tokenizeAll(producer.text).toSet();
    final brands = <_Line>[];
    _Line? grapeLine;
    _Line? houseLine;
    for (final line in _useful) {
      if (!_canBeName(line)) continue;
      final words = line.words;
      if (houseLine == null &&
          words.isNotEmpty &&
          _houseWords.contains(words.first)) {
        houseLine = line;
      }
      // The producer is never the name: its line, a line of its words or
      // any line naming a company (BR1.4, BR1.5).
      if (line.index == producer?.line) continue;
      if (_hasProducerWord(words)) continue;
      if (producerWords.isNotEmpty && words.every(producerWords.contains)) {
        continue;
      }
      final residual = _residual(line, denomination);
      if (residual.isEmpty) continue;
      if (_isGrapeLine(line, residual)) {
        grapeLine ??= line;
      } else {
        brands.add(line);
      }
    }
    final brandText = const LabelLinePicker().longest([
      for (final line in brands) _withoutYears(line.text),
    ]);
    final brand = brandText == null ? null : _smartCase(brandText);
    final grape = grapeLine == null ? null : _smartCase(grapeLine.text);
    if (brand == null) {
      if (grape != null) return _cutName(grape);
      final producerText = producer?.text;
      if (producerText != null &&
          _houseWords.contains(tokenizeAll(producerText).firstOrNull)) {
        return _cutName(
          houseLine == null ? producerText : _smartCase(houseLine.text),
        );
      }
      if (denomination != null) {
        return _cutName(_denominationText(denomination));
      }
      return null;
    }
    if (grape != null && tokenizeAll(brand).length <= 3) {
      return _cutName('$brand $grape');
    }
    // BR1.5: an Italian (and, for the crus and climats, a French) dedicated
    // denomination comes before a short brand: "Barolo Ravera", "Chablis
    // Premier Cru Montmains".
    if (denomination != null &&
        const {'IT', 'FR'}.contains(denomination.info.country) &&
        denomination.info.dedicated &&
        tokenizeAll(brand).length <= 3 &&
        !_sharesWords(brand, denomination)) {
      return _cutName('${_denominationText(denomination)} $brand');
    }
    return _cutName(brand);
  }

  /// The words of [line] that could be a name: without the words of any
  /// denomination of the tables (a line split by Lens may hold half of one),
  /// classification, style, qualifier, vintage and country words.
  List<String> _residual(_Line line, _DenominationHit? denomination) =>
      _residualOf(
        line,
        identical(line, denomination?.line) ? denomination!.match : null,
      );

  bool _sharesWords(String brand, _DenominationHit denomination) =>
      _brandSharesWords(brand, denomination.info);

  String _denominationText(_DenominationHit denomination) =>
      _aliasText(denomination.line, denomination.match);

  // BR1.9 -------------------------------------------------------------------

  LabelFields _validated(LabelFields fields) {
    String? text(String? value, int max) {
      if (value == null) return null;
      final trimmed = value.trim();
      if (!hasLetters(trimmed, minLetters: 1) || trimmed.length > max) {
        return null;
      }
      return trimmed;
    }

    final vintage = fields.vintage;
    final country = fields.country;
    return LabelFields(
      name: text(fields.name, maxExtractedNameLength),
      producer: text(fields.producer, maxExtractedProducerLength),
      denomination: fields.denomination,
      denominationKey: fields.denominationKey,
      vintage:
          vintage != null &&
              vintage >= VintageParser.minYear &&
              vintage <= currentYear + 1
          ? vintage
          : null,
      wineType: fields.wineType,
      country: country != null && country.length == 2 ? country : null,
      region: text(fields.region, 120),
      suggestedLevel: fields.suggestedLevel,
      qualifier: fields.qualifier,
    );
  }
}

class _Producer {
  const _Producer(this.text, this.line);

  final String text;

  /// The line the producer is, `null` when it came after a phrase.
  final int? line;
}

// ---------------------------------------------------------------------------
// Rules shared by the reader and the analysis (BR1.4-BR1.8).

/// Whether [words] hold a producer word or a company form (BR1.4).
bool _hasProducerWord(List<String> words) {
  if (words.any(_producerWords.contains)) return true;
  if (_producerPhrasesInLine.any((phrase) => _containsPhrase(words, phrase))) {
    return true;
  }
  return _producerEndings.any((ending) => _endsWith(words, ending));
}

/// The producer text of [raw]: cut at the first separator or postal code,
/// in title case when all capitals, at most [maxExtractedProducerLength]
/// characters; `null` without at least two letters.
String? _cutProducer(String raw) {
  final text = _cutProducerRaw(raw);
  if (text == null) return null;
  final cased = _smartCase(text);
  return cased.length <= maxExtractedProducerLength
      ? cased
      : cased.substring(0, maxExtractedProducerLength).trimRight();
}

/// [raw] cut at the first separator or postal code and trimmed at the end,
/// as written; `null` without at least two letters. Starts where [raw]
/// starts when [raw] has no leading space (the analysis strips it first, to
/// know where the value is in its line).
String? _cutProducerRaw(String raw) {
  var text = raw;
  for (final stop in [',', ';', '(', ' - ', ' – ', ' — ', ' / ']) {
    final at = text.indexOf(stop);
    if (at >= 0) text = text.substring(0, at);
  }
  final digits = RegExp(r'\s\d{4,5}\b').firstMatch(text);
  if (digits != null) text = text.substring(0, digits.start);
  text = text.trim().replaceAll(RegExp(r'[\s:]+$'), '');
  if (!hasLetters(text, minLetters: 2)) return null;
  return text;
}

/// The qualifier of BR1.8 in [lines]: the most specific one, "Vintage" only
/// when [row] has it.
Qualifier? _qualifierOf(Iterable<_Line> lines, DenominationProfile? row) {
  var mask = 0;
  for (final line in lines) {
    mask |= qualifierMaskOf(line.words);
  }
  for (final qualifier in qualifiersOf(mask)) {
    if (qualifier == Qualifier.vintage &&
        !(row?.qualifierOffsets.containsKey(Qualifier.vintage) ?? false)) {
      continue;
    }
    return qualifier;
  }
  return null;
}

/// The country of a "product of X" phrase in [lines] (BR1.7), or `null`.
String? _productOfCountry(Iterable<_Line> lines) {
  for (final line in lines) {
    final words = line.words;
    for (final phrase in _originPhrases) {
      final at = _indexOfPhrase(words, phrase);
      if (at < 0) continue;
      var from = at + phrase.length;
      if (from < words.length &&
          const {'the', 'la', 'l'}.contains(words[from])) {
        from++;
      }
      final code = _countryAt(words, from);
      if (code != null) return code;
    }
  }
  return null;
}

String? _countryAt(List<String> words, int from) {
  for (var length = 4; length >= 1; length--) {
    if (from + length > words.length) continue;
    final code = wineCountryNames[words.sublist(from, from + length).join(' ')];
    if (code != null) return code;
  }
  return null;
}

/// Whether [line] may give a name: no bottling, founding, estate-bottled or
/// "product of" words (BR1.5).
bool _canBeName(_Line line) {
  final words = line.words;
  if (words.any(_bottlingWords.contains)) return false;
  if (words.any(VintageParser.foundingWords.contains)) return false;
  if (_estateBottled.any((phrase) => _containsPhrase(words, phrase))) {
    return false;
  }
  return !_originPhrases.any((phrase) => _containsPhrase(words, phrase));
}

/// The words of [line] that could be a name: without [skip] (the alias of
/// the denomination), the words of any denomination of the tables (a line
/// split by Lens may hold half of one), classification, style, qualifier,
/// vintage and country words.
List<String> _residualOf(_Line line, AliasMatch? skip) {
  final words = line.words;
  final drop = List<bool>.filled(words.length, false);
  void dropRange(int start, int count) {
    for (var i = start; i < start + count; i++) {
      drop[i] = true;
    }
  }

  if (skip != null) dropRange(skip.start, skip.wordCount);
  for (final match in findAliasMatches(words)) {
    dropRange(match.start, match.wordCount);
  }
  for (var i = 0; i < words.length; i++) {
    for (final phrase in qualifierPhrases) {
      if (_phraseAt(words, i, phrase.words)) {
        dropRange(i, phrase.words.length);
      }
    }
  }
  for (var i = 0; i < words.length; i++) {
    for (var length = 4; length >= 1; length--) {
      if (i + length > words.length) continue;
      if (wineCountryNames.containsKey(
        words.sublist(i, i + length).join(' '),
      )) {
        dropRange(i, length);
        break;
      }
    }
  }
  return [
    for (var i = 0; i < words.length; i++)
      if (!drop[i] && _isNameWord(words[i])) words[i],
  ];
}

bool _isNameWord(String word) {
  if (_classificationWords.contains(word) || _styleWords.contains(word)) {
    return false;
  }
  if (VintageParser.vintageWords.contains(word) || _isYear(word)) {
    return false;
  }
  return word.length >= 2 ||
      word.codeUnitAt(0) >= 0x30 && word.codeUnitAt(0) <= 0x39;
}

/// Whether the [residual] words of [line] are all words of a grape.
bool _isGrapeLine(_Line line, List<String> residual) {
  final covered = _grapeWordsOf(line.words);
  return covered.isNotEmpty && residual.every(covered.contains);
}

/// The words of [words] that belong to a grape name.
Set<String> _grapeWordsOf(List<String> words) {
  final covered = <String>{};
  for (var i = 0; i < words.length; i++) {
    final candidates = grapeIndex[words[i]];
    if (candidates == null) continue;
    for (final candidate in candidates) {
      if (_phraseAt(words, i, candidate.words)) {
        covered.addAll(candidate.words);
        break;
      }
    }
  }
  return covered;
}

/// Whether the words of [brand] already hold a form of [info].
bool _brandSharesWords(String brand, AppellationInfo info) {
  final brandWords = tokenizeAll(brand).toSet();
  return info.forms.any((form) => form.split(' ').every(brandWords.contains));
}

/// The original text of [match] in [line], with a qualifier written right
/// after it ("Barbera d'Asti Superiore").
String _aliasText(_Line line, AliasMatch match) {
  final words = line.words;
  final start = match.start;
  var end = match.start + match.wordCount;
  for (final phrase in qualifierPhrases) {
    if (end < words.length && _phraseAt(words, end, phrase.words)) {
      end += phrase.words.length;
      break;
    }
  }
  return _smartCase(line.original(start, end - start));
}
