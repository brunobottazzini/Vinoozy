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

  /// The vintage in [text], or `null` when there is none.
  int? parse(String text, {required int currentYear}) {
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
}
