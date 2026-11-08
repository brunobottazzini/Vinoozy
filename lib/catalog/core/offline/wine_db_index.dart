// The offline wine database in memory (label-recognition BR2.5,
// functional-spec.md D1): a map by barcode and, for the text, the
// distinctive words of each wine with an inverted index from word to wines,
// so a 4000-character label is compared only with the wines that share a
// word with it (NFR2.1, NFR2.2, NFR2.7). Pure Dart, built in a background
// isolate by the loader and sent back whole.

import 'package:estimation/estimation.dart' show normalizeWineText;

import 'text_score.dart';
import 'wine_db_record.dart';

/// One wine with its score against a text.
class ScoredRecord {
  const ScoredRecord(this.record, this.match);

  final WineDbRecord record;
  final TextMatch match;

  double get score => match.score;
}

/// Exact barcode lookup and text matching over the offline wines.
class WineDbIndex {
  WineDbIndex._(this._records, this._words, this._byCode, this._postings);

  /// Builds the index; the first record of a barcode wins (the build tool
  /// never writes two, BR2.4).
  factory WineDbIndex.build(List<WineDbRecord> records) {
    final kept = <WineDbRecord>[];
    final words = <WineWords>[];
    final byCode = <String, int>{};
    final postings = <String, List<int>>{};
    for (final record in records) {
      if (byCode.containsKey(record.code)) continue;
      final index = kept.length;
      byCode[record.code] = index;
      kept.add(record);
      final prepared = WineWords.of(
        name: record.name,
        producer: record.producer,
        denomination: record.denomination,
        vintage: record.vintage,
      );
      words.add(prepared);
      for (final word in prepared.words) {
        (postings[word] ??= <int>[]).add(index);
      }
    }
    return WineDbIndex._(kept, words, byCode, postings);
  }

  final List<WineDbRecord> _records;
  final List<WineWords> _words;
  final Map<String, int> _byCode;
  final Map<String, List<int>> _postings;

  /// Number of wines in the index.
  int get length => _records.length;

  /// The wine with this normalised barcode (8 or 13 digits), or `null`.
  WineDbRecord? byBarcode(String code) {
    final index = _byCode[code];
    return index == null ? null : _records[index];
  }

  /// The wines similar to a label [text] (BR3.6), best first: only scores of
  /// at least [minScore], at most [limit]; on equal score the name in
  /// alphabetical order.
  List<ScoredRecord> matchText(
    String text, {
    int limit = LabelMatchThresholds.maxCandidates,
    double minScore = LabelMatchThresholds.candidate,
  }) {
    final label = LabelWords.of(text);
    if (label.isEmpty) return const [];
    final seen = <int>{};
    final scored = <ScoredRecord>[];
    for (final word in label.words) {
      final wines = _postings[word];
      if (wines == null) continue;
      for (final index in wines) {
        if (!seen.add(index)) continue;
        final match = scoreWine(_words[index], label);
        if (match.score >= minScore) {
          scored.add(ScoredRecord(_records[index], match));
        }
      }
    }
    return _best(scored, limit);
  }

  /// "Cerca online" in the offline wines (BR4.2): every distinctive word of
  /// [query] must start a distinctive word of the wine; best text score
  /// first, at most [limit]. A query without distinctive words finds
  /// nothing.
  List<ScoredRecord> search(
    String query, {
    int limit = LabelMatchThresholds.maxCandidates,
  }) {
    final queryWords = [
      for (final word in normalizeWineText(query).split(' '))
        if (isDistinctiveWord(word)) word,
    ];
    if (queryWords.isEmpty) return const [];
    final label = LabelWords.of(query);
    final scored = <ScoredRecord>[];
    for (var i = 0; i < _records.length; i++) {
      final wine = _words[i];
      if (!queryWords.every((q) => wine.words.any((w) => w.startsWith(q)))) {
        continue;
      }
      scored.add(ScoredRecord(_records[i], scoreWine(wine, label)));
    }
    return _best(scored, limit);
  }

  static List<ScoredRecord> _best(List<ScoredRecord> scored, int limit) {
    scored.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      return byScore != 0 ? byScore : a.record.name.compareTo(b.record.name);
    });
    return scored.length <= limit ? scored : scored.sublist(0, limit);
  }
}

/// The offline database once opened: its manifest, the index and how many
/// lines were dropped as damaged (NFR4.6).
class OfflineWineDb {
  const OfflineWineDb({
    required this.manifest,
    required this.index,
    this.skippedRows = 0,
  });

  /// Builds the database from the lines of `wines.jsonl`.
  factory OfflineWineDb.fromLines(
    WineDbManifest manifest,
    Iterable<String> lines,
  ) {
    final parsed = parseWineDbLines(lines);
    return OfflineWineDb(
      manifest: manifest,
      index: WineDbIndex.build(parsed.records),
      skippedRows: parsed.skipped,
    );
  }

  final WineDbManifest manifest;
  final WineDbIndex index;
  final int skippedRows;

  /// Wines actually loaded.
  int get wineCount => index.length;
}
