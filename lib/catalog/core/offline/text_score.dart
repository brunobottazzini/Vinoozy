// Similarity of a label text with a wine (label-recognition BR3.6,
// functional-spec.md D3) and the thresholds of the outcome (BR3.1, BR3.2).
// Every threshold and the list of common words live here, in one place.
// Wine knowledge decided at Functional Design (project.md correction of
// 2026-11-04): a wine recorded only as "Barolo" must never become a sure
// proposal for every label with that word on it.

import 'package:estimation/estimation.dart' show normalizeWineText;

/// The thresholds of the label outcome (BR3.1, BR3.2, BR3.6).
abstract final class LabelMatchThresholds {
  /// A text score at least this high can be a sure proposal.
  static const double sure = 0.85;

  /// ...when the second candidate is at least this much lower.
  static const double margin = 0.15;

  /// ...and at least this many distinctive words of the wine were found.
  static const int minMatchedWords = 2;

  /// Candidates below this score are not shown.
  static const double candidate = 0.45;

  /// Most candidates shown.
  static const int maxCandidates = 10;

  /// Fixed score of a denomination of the internal catalog (step 3): a
  /// candidate, never a sure proposal on its own.
  static const double internalDenomination = 0.70;

  /// Highest score of a wine with fewer than 2 distinctive words.
  static const double fewWordsCap = 0.60;

  /// Added when the wine's vintage is in the text; the total stays <= 1.
  static const double vintageBonus = 0.05;
}

/// Words that say nothing about which wine it is (BR3.6): colours,
/// classifications, generic estate words and articles in the label
/// languages. Normalised: lower case, no accents.
const Set<String> commonWineWords = {
  'vino', 'vin', 'wine', 'wein', 'vinho', 'vinos', //
  'rosso', 'rouge', 'red', 'bianco', 'blanc', 'white', 'rosato', 'rose',
  'doc', 'docg', 'igt', 'aoc', 'aop', 'do', 'doca', 'igp', 'dop',
  'cuvee', 'reserve', 'riserva', 'reserva', 'gran', 'grand', 'cru',
  'chateau', 'domaine', 'tenuta', 'cantina', 'bodega', 'estate',
  'the', 'del', 'della', 'di', 'de', 'la', 'le', 'les', 'el', 'and', 'et',
  'e',
};

/// The distinctive words of a wine, prepared once (BR3.6): the words of
/// name, producer and denomination, normalised, without words of 1-2
/// letters, common words and words without letters, each once.
class WineWords {
  WineWords._(this.words, this.totalWeight, this.vintage);

  factory WineWords.of({
    required String name,
    String? producer,
    String? denomination,
    int? vintage,
  }) {
    final words = <String>[];
    final seen = <String>{};
    for (final text in [name, producer, denomination]) {
      if (text == null) continue;
      for (final word in normalizeWineText(text).split(' ')) {
        if (isDistinctiveWord(word) && seen.add(word)) words.add(word);
      }
    }
    var total = 0;
    for (final word in words) {
      total += letterCount(word);
    }
    return WineWords._(List.unmodifiable(words), total, vintage);
  }

  /// Distinctive words in the order they first appear.
  final List<String> words;

  /// Sum of the weights (letters) of [words].
  final int totalWeight;
  final int? vintage;
}

/// The normalised words of a label text and the 4-digit years in it.
class LabelWords {
  LabelWords._(this.words, this.years);

  factory LabelWords.of(String text) {
    final words = <String>{};
    final years = <int>{};
    for (final word in normalizeWineText(text).split(' ')) {
      if (word.isEmpty) continue;
      words.add(word);
      if (word.length == 4) {
        final year = int.tryParse(word);
        if (year != null) years.add(year);
      }
    }
    return LabelWords._(words, years);
  }

  final Set<String> words;
  final Set<int> years;

  bool get isEmpty => words.isEmpty;
}

/// The score of one wine against a text: 0 to 1, and how many distinctive
/// words of the wine were found.
class TextMatch {
  const TextMatch(this.score, this.matchedWords);

  static const TextMatch zero = TextMatch(0, 0);

  final double score;
  final int matchedWords;
}

/// BR3.6: weight of a word = its letters; score = weight of the wine words
/// found in the text / weight of all its distinctive words; at most 0.60
/// with fewer than 2 distinctive words; +0.05 when the wine's vintage is in
/// the text (only with some word found), never above 1.
TextMatch scoreWine(WineWords wine, LabelWords text) {
  if (wine.totalWeight == 0) return TextMatch.zero;
  var found = 0;
  var matched = 0;
  for (final word in wine.words) {
    if (text.words.contains(word)) {
      found += letterCount(word);
      matched++;
    }
  }
  if (matched == 0) return TextMatch.zero;
  var score = found / wine.totalWeight;
  if (wine.words.length < LabelMatchThresholds.minMatchedWords &&
      score > LabelMatchThresholds.fewWordsCap) {
    score = LabelMatchThresholds.fewWordsCap;
  }
  final vintage = wine.vintage;
  if (vintage != null && text.years.contains(vintage)) {
    score += LabelMatchThresholds.vintageBonus;
  }
  return TextMatch(score > 1 ? 1 : score, matched);
}

/// Whether the best of a list sorted by score is a sure proposal (BR3.2):
/// score >= 0.85, at least 2 distinctive words found, and the next one
/// (if any) at least 0.15 lower.
bool isSureTextMatch(TextMatch best, double? secondScore) =>
    best.score >= LabelMatchThresholds.sure &&
    best.matchedWords >= LabelMatchThresholds.minMatchedWords &&
    (secondScore == null ||
        best.score - secondScore >= LabelMatchThresholds.margin - 1e-9);

/// A normalised word that counts for the score (BR3.6).
bool isDistinctiveWord(String word) =>
    word.length > 2 && !commonWineWords.contains(word) && letterCount(word) > 0;

/// Letters a-z of a normalised word: digits weigh nothing.
int letterCount(String word) {
  var count = 0;
  for (final unit in word.codeUnits) {
    if (unit >= 0x61 && unit <= 0x7A) count++;
  }
  return count;
}
