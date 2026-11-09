// The words of a label text the owner taps to compose a value (FR7.5,
// label-autofill-windows BR7.14-BR7.16, ENT-011): what a word is, which
// words are shown, how the chosen words become a value and how a composed
// appellation is matched with the tables.

part of 'label_fields.dart';

/// Most words shown (BR7.14).
const int maxLabelWords = 120;

/// Most words of a composed value (BR7.15).
const int maxComposedWords = 8;

/// Most characters of a composed value (BR7.15).
const int maxComposedLength = 80;

/// One word of the label text (ENT-011). Kept in memory only (FR7.9).
class LabelWord {
  const LabelWord({
    required this.id,
    required this.text,
    required this.line,
    required this.folded,
  });

  /// Index in the list, in the order of the text (BR7.14, BR7.15).
  final int id;

  /// The original text, without leading and trailing punctuation.
  final String text;

  /// Index of the line, for the grouping "Line 2 of 6" (A21).
  final int line;

  /// `tokenizeAll(text).join(' ')`, to compare with the tables (BR7.16).
  final String folded;

  // No text in the string form: it may end up in a log (BR7.22).
  @override
  String toString() => 'LabelWord($id, line $line)';
}

/// A word with its place in its line, to find the words of a candidate.
class _WordRef {
  const _WordRef(this.id, this.line, this.start, this.end);

  final int id;
  final int line;
  final int start;
  final int end;
}

/// Characters stripped at the start and end of a word (BR7.14).
const String _wordPunctuation = '.,;:!?()[]{}"«»“”„*/';
const Set<String> _dashes = {'-', '–', '—', '‐'};
final RegExp _volumeWord = RegExp(
  r'^\d+([.,]\d+)?(cl|ml|l|lt|%)$',
  caseSensitive: false,
);

/// The words of [lines] (BR7.14): groups of characters between spaces,
/// leading and trailing punctuation stripped, apostrophes and inner dashes
/// kept; one-letter words, numbers that are not a plausible year and
/// volumes dropped; at most [maxLabelWords], in the order of the text.
(List<LabelWord>, List<_WordRef>) _wordsOf(List<_Line> lines, int currentYear) {
  final words = <LabelWord>[];
  final refs = <_WordRef>[];
  for (final line in lines) {
    final text = line.text;
    var i = 0;
    while (i < text.length) {
      while (i < text.length && text[i] == ' ') {
        i++;
      }
      var end = i;
      while (end < text.length && text[end] != ' ') {
        end++;
      }
      var start = i;
      var stop = end;
      i = end;
      while (start < stop && _wordPunctuation.contains(text[start])) {
        start++;
      }
      while (stop > start && _wordPunctuation.contains(text[stop - 1])) {
        stop--;
      }
      if (stop <= start) continue;
      final word = text.substring(start, stop);
      if (!_isShownWord(word, currentYear)) continue;
      if (words.length >= maxLabelWords) return (words, refs);
      final id = words.length;
      words.add(
        LabelWord(
          id: id,
          text: word,
          line: line.index,
          folded: tokenizeAll(word).join(' '),
        ),
      );
      refs.add(_WordRef(id, line.index, start, stop));
    }
  }
  return (words, refs);
}

bool _isShownWord(String word, int currentYear) {
  if (_dashes.contains(word)) return false;
  if (word.runes.length < 2) return false;
  if (_volumeWord.hasMatch(word)) return false;
  final hasDigit = word.codeUnits.any((u) => u >= 0x30 && u <= 0x39);
  if (!hasDigit) return hasLetters(word, minLetters: 1);
  if (hasLetters(word, minLetters: 1)) return true;
  return _isSavableYear(word, currentYear);
}

/// A 4-digit year from 1900 to [currentYear]: the range the add form saves
/// (`WineRules.validateVintage`), for the candidates and the words alike.
bool _isSavableYear(String word, int currentYear) {
  if (!_isYear(word)) return false;
  final year = int.parse(word);
  return year >= VintageParser.minYear && year <= currentYear;
}

/// The value composed from the words [selected] of [words] (BR7.15): the
/// chosen words in the order of the text, whatever the order of the taps,
/// joined by one space; in title case when it is all capitals, as the
/// values read from the text.
String composeValue(List<LabelWord> words, Set<int> selected) {
  final chosen = [
    for (final word in words)
      if (selected.contains(word.id)) word.text,
  ];
  return _smartCase(chosen.join(' '));
}

/// Whether the word [id] can be tapped with [selected] already chosen
/// (BR7.15): a chosen word can always be removed; a free word only while the
/// value stays within [maxComposedWords] words and [maxComposedLength]
/// characters.
bool canSelect(List<LabelWord> words, Set<int> selected, int id) {
  if (selected.contains(id)) return true;
  if (selected.length >= maxComposedWords) return false;
  return composeValue(words, {...selected, id}).length <= maxComposedLength;
}

/// The qualifiers a composed appellation may end with (BR7.16): the aging
/// ones and "Superiore", "Crianza". "Classico" is part of names ("Chianti
/// Classico") and is never stripped.
final Set<Qualifier> _trailingQualifiers = {
  ...selectionQualifiers,
  Qualifier.superiore,
  Qualifier.crianza,
};

/// How many trailing words of [words] are a mark of BR7.16: an indicator
/// ("DOCG", "D.O.C.G.") or a qualifier phrase ("Riserva", "Gran
/// Selezione"); 0 when the value ends with none.
int _trailingMarkLength(List<String> words) {
  if (_indicators.contains(words.last)) return 1;
  var letters = 0;
  while (letters < words.length &&
      letters < 5 &&
      words[words.length - 1 - letters].length == 1) {
    letters++;
  }
  for (var n = letters; n >= 2; n--) {
    final joined = words.sublist(words.length - n).join();
    if (_dottedIndicators.contains(joined)) return n;
  }
  var best = 0;
  for (final phrase in qualifierPhrases) {
    if (!_trailingQualifiers.contains(phrase.qualifier)) continue;
    final length = phrase.words.length;
    if (length <= best || length >= words.length) continue;
    if (_phraseAt(words, words.length - length, phrase.words)) best = length;
  }
  return best;
}

/// Table order of the rows, for the last tie-break of BR7.16.
final Map<String, int> _tableOrder = {
  for (final (index, key) in denominationTable.keys.indexed) key: index,
};

/// The table row whose name or alias is the composed [composed] (BR7.16),
/// compared without case and accents: the whole value first, then without
/// its trailing indicators and qualifiers one at a time, so the longest
/// match wins ("Chianti Classico" is Chianti Classico, never Chianti).
/// With several rows, the estimate's choice (BR3.1): the row that makes
/// [type], then a dedicated row, then the row of [country], then the first
/// of the table. `null` without a match.
AppellationInfo? matchDenomination(
  String composed, {
  WineType? type,
  String? country,
}) {
  var words = tokenizeAll(composed);
  while (words.isNotEmpty) {
    final row = _rowOf(words, type, country);
    if (row != null) return row;
    final cut = _trailingMarkLength(words);
    if (cut == 0) return null;
    words = words.sublist(0, words.length - cut);
  }
  return null;
}

AppellationInfo? _rowOf(List<String> words, WineType? type, String? country) {
  final rows = <AppellationInfo>[];
  for (final entry in aliasIndex[words.first] ?? const <AliasEntry>[]) {
    if (entry.words.length != words.length) continue;
    if (!_phraseAt(words, 0, entry.words)) continue;
    final info = appellationOf(entry.denominationKey);
    if (info != null && !rows.any((row) => row.key == info.key)) {
      rows.add(info);
    }
  }
  if (rows.isEmpty) return null;
  int rank(AppellationInfo row) =>
      (type != null && row.types.contains(type) ? 0 : 4) +
      (row.dedicated ? 0 : 2) +
      (country != null && row.country == country ? 0 : 1);
  rows.sort((a, b) {
    final byRank = rank(a).compareTo(rank(b));
    if (byRank != 0) return byRank;
    return (_tableOrder[a.key] ?? 0).compareTo(_tableOrder[b.key] ?? 0);
  });
  return rows.first;
}
