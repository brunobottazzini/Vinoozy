// The vintage printed on a label, moved here from lib/label/core by
// label-autofill-windows (D1) so the label-text extractor of this package
// can use it; lib/label/core/vintage_parser.dart re-exports it.

/// The vintage printed on a label (BR1.8 step 3 and "Chiarimenti dopo la
/// revisione": the year read on the label replaces the candidate's).
///
/// - A year is an isolated 4-digit number between [minYear] and the current
///   year: "2016" in "Barolo 2016", never "120162" nor a future year.
/// - A year right after a founding word ("dal 1952", "since 1890", "desde",
///   "fondata nel", "est.") is the winery's, not the wine's, and is skipped.
/// - With several years, the one closest to a vintage word ("vendemmia",
///   "annata", "vintage", "harvest", "safra", "colheita", "millesimo") or to
///   a denomination marker (DOC, DOCG, IGT...) wins, a year on the same line
///   as such a word first; with no such word, the
///   most recent one, since labels repeat the vintage and older numbers are
///   usually anniversaries or awards.
///
/// With `ambiguousAsNull` (label-autofill-windows BR1.3, used by
/// `extractLabelFields`) the rule is the stricter one of the form filled
/// from a text: years up to the current year + 1, founding years skipped
/// within 3 words, a single year left is the vintage, several are decided
/// only by a vintage word within 3 words, otherwise no vintage at all: an
/// empty field is better than a wrong one (FR1.1).
///
/// These are choices of the team (project.md, Corrections): they can be
/// corrected in the form before saving.
class VintageParser {
  const VintageParser();

  static const int minYear = 1900;

  static final RegExp _year = RegExp(r'(?<![\d.,])(\d{4})(?![\d]|[.,]\d)');
  static final RegExp _founding = RegExp(
    r'(\bdal|\bsince|\bdesde|\bfondat[ao]\s+nel|\bfounded(\s+in)?|\best\.?|\bfundad[ao]\s+em)\s*$',
    caseSensitive: false,
  );
  static final RegExp _vintageWord = RegExp(
    r'\b(vendemmia|annata|vintage|harvest|safra|colheita|millesimo|docg|doc|igt|igp|doca|dop|riserva|reserva)\b',
    caseSensitive: false,
  );

  /// BR1.3: words after which a year is the winery's.
  static const Set<String> foundingWords = {
    'dal',
    'since',
    'depuis',
    'desde',
    'seit',
    'fondata',
    'fondato',
    'founded',
    'fondee',
    'fonde',
    'fundada',
    'fundado',
    'gegrundet',
    'est',
  };

  /// BR1.3: words that name the vintage.
  static const Set<String> vintageWords = {
    'vendemmia',
    'millesime',
    'millesimo',
    'cosecha',
    'vintage',
    'jahrgang',
    'colheita',
    'safra',
    'annata',
    'harvest',
  };

  /// The vintage in [text], or `null` when there is none.
  int? parse(
    String text, {
    required int currentYear,
    bool ambiguousAsNull = false,
  }) {
    if (ambiguousAsNull) return _parseStrict(text, currentYear);
    final years = <RegExpMatch>[];
    for (final match in _year.allMatches(text)) {
      final year = int.parse(match.group(1)!);
      if (year < minYear || year > currentYear) continue;
      if (_founding.hasMatch(text.substring(0, match.start))) continue;
      years.add(match);
    }
    if (years.isEmpty) return null;
    int yearOf(RegExpMatch match) => int.parse(match.group(1)!);
    final anchors = _vintageWord.allMatches(text).toList();
    if (years.length == 1 || anchors.isEmpty) {
      return years.map(yearOf).reduce((a, b) => a > b ? a : b);
    }
    // A year on the same line as a vintage word comes first, then the
    // shortest gap to such a word; a tie keeps the most recent year.
    (int, int) rank(RegExpMatch year) {
      var best = (2, 1 << 30);
      for (final anchor in anchors) {
        final sameLine = !text
            .substring(
              year.start < anchor.start ? year.end : anchor.end,
              year.start < anchor.start ? anchor.start : year.start,
            )
            .contains('\n');
        final gap = year.start < anchor.start
            ? anchor.start - year.end
            : year.start - anchor.end;
        final candidate = (sameLine ? 0 : 1, gap);
        if (_before(candidate, best)) best = candidate;
      }
      return best;
    }

    RegExpMatch? chosen;
    (int, int)? chosenRank;
    for (final year in years) {
      final current = rank(year);
      final better = chosenRank == null || _before(current, chosenRank);
      final tieMoreRecent =
          chosenRank == current && yearOf(year) > yearOf(chosen!);
      if (better || tieMoreRecent) {
        chosen = year;
        chosenRank = current;
      }
    }
    return yearOf(chosen!);
  }

  static bool _before((int, int) a, (int, int) b) =>
      a.$1 < b.$1 || (a.$1 == b.$1 && a.$2 < b.$2);

  /// BR1.3 on the words of [text] (lowercase, accents and punctuation
  /// removed, so "Gegründet 1898" and "fondée en 1898" read alike).
  int? _parseStrict(String text, int currentYear) {
    // Words of the whole text (a vintage word may be on the line before the
    // year, as Lens splits lines) and the line of each word (a founding
    // word counts only on the year's own line).
    final words = <String>[];
    final lineOf = <int>[];
    for (final (index, line) in text.split('\n').indexed) {
      for (final word in _words(line)) {
        words.add(word);
        lineOf.add(index);
      }
    }
    final candidates = <(int, int)>[];
    for (var i = 0; i < words.length; i++) {
      final year = _yearOf(words[i]);
      if (year == null || year < minYear || year > currentYear + 1) continue;
      if (_foundingBefore(words, lineOf, i)) continue;
      candidates.add((i, year));
    }
    final distinct = {for (final (_, year) in candidates) year};
    if (distinct.isEmpty) return null;
    if (distinct.length == 1) return distinct.single;
    // Several years: the one closest to a vintage word, when it is strictly
    // the closest (FR1.1: in doubt, no vintage).
    int? best;
    var bestGap = 4;
    var tie = false;
    for (final (index, year) in candidates) {
      final gap = _gapToVintageWord(words, index);
      if (gap == null) continue;
      if (gap < bestGap) {
        best = year;
        bestGap = gap;
        tie = false;
      } else if (gap == bestGap && year != best) {
        tie = true;
      }
    }
    return tie ? null : best;
  }

  /// Whether a founding word is within 3 words before [index], on its line.
  static bool _foundingBefore(List<String> words, List<int> lineOf, int index) {
    for (var i = index - 1; i >= 0 && i >= index - 3; i--) {
      if (lineOf[i] != lineOf[index]) return false;
      if (foundingWords.contains(words[i])) return true;
    }
    return false;
  }

  /// Words between [index] and the closest vintage word within 3 words, or
  /// `null` when there is none.
  static int? _gapToVintageWord(List<String> words, int index) {
    for (var gap = 1; gap <= 3; gap++) {
      final before = index - gap;
      final after = index + gap;
      if (before >= 0 && vintageWords.contains(words[before])) return gap;
      if (after < words.length && vintageWords.contains(words[after])) {
        return gap;
      }
    }
    return null;
  }

  static int? _yearOf(String word) {
    if (word.length != 4) return null;
    for (final unit in word.codeUnits) {
      if (unit < 0x30 || unit > 0x39) return null;
    }
    return int.parse(word);
  }

  /// Lowercase ASCII words of [text]: letters with Latin-1 accents folded,
  /// digits; anything else separates.
  static List<String> _words(String text) {
    final words = <String>[];
    final current = StringBuffer();
    for (final unit in text.toLowerCase().codeUnits) {
      final folded = _fold(unit);
      if (folded != null) {
        current.writeCharCode(folded);
      } else if (current.isNotEmpty) {
        words.add(current.toString());
        current.clear();
      }
    }
    if (current.isNotEmpty) words.add(current.toString());
    return words;
  }

  static int? _fold(int unit) {
    if ((unit >= 0x61 && unit <= 0x7A) || (unit >= 0x30 && unit <= 0x39)) {
      return unit;
    }
    const accents = 'àáâãäåçèéêëìíîïñòóôõöùúûüýÿ';
    const plain = 'aaaaaaceeeeiiiinooooouuuuyy';
    final at = accents.indexOf(String.fromCharCode(unit));
    return at < 0 ? null : plain.codeUnitAt(at);
  }
}
