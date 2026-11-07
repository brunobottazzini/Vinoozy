// Internal catalog (BR1.1, performance-design.md): the denominations of C2
// with their name variants, built once per session, plus the cellar wines
// U4 passes in. Matching is by word prefix on normalised text, so results
// follow the typing letter by letter without any network.

import 'package:estimation/estimation.dart';

import 'wine_catalog.dart';

/// Most cellar wines searched (NFR2); U4 decides their order.
const int maxCellarWines = 500;

/// Most suggestions returned (C1).
const int maxSuggestions = 10;

/// C1 type of a C2 type.
CatalogWineType catalogTypeOf(WineType type) => switch (type) {
  WineType.redLight || WineType.redStructured => CatalogWineType.red,
  WineType.white => CatalogWineType.white,
  WineType.rose => CatalogWineType.rose,
  WineType.sparklingClassic ||
  WineType.sparklingTank => CatalogWineType.sparkling,
  WineType.sweet || WineType.fortified => CatalogWineType.sweet,
};

/// True for a 4-digit word between 1900 and 2200: a vintage, not a name.
bool isVintageWord(String word) {
  if (word.length != 4) return false;
  final year = int.tryParse(word);
  return year != null && year >= 1900 && year <= 2200;
}

/// A normalised query split into the words to match and the vintage.
class ParsedQuery {
  ParsedQuery(String normalized)
    : words = [
        for (final word in normalized.split(' '))
          if (word.isNotEmpty && !isVintageWord(word)) word,
      ],
      vintage = _firstVintage(normalized);

  /// Words compared with the entries, vintage words excluded.
  final List<String> words;

  /// First vintage word of the query, copied into the proposals.
  final int? vintage;

  static int? _firstVintage(String normalized) {
    for (final word in normalized.split(' ')) {
      if (isVintageWord(word)) return int.parse(word);
    }
    return null;
  }
}

/// One denomination of the internal catalog (entities.md `CatalogEntry`).
class CatalogEntry {
  CatalogEntry({
    required this.displayName,
    required this.denominationKey,
    required this.searchTerms,
    required this.wineType,
    required this.region,
  }) : words = {for (final term in searchTerms) ...term.split(' ')}
           .toList(growable: false);

  final String displayName;
  final String denominationKey;

  /// Display name and aliases, normalised.
  final List<String> searchTerms;
  final CatalogWineType wineType;
  final String? region;

  /// Every word of [searchTerms], prepared once.
  final List<String> words;
}

class _Scored {
  _Scored(this.candidate, this.fullMatches);

  final WineCandidate candidate;
  final int fullMatches;
}

class _CellarItem {
  _CellarItem(this.wine, this.words);

  final CellarWineRef wine;
  final List<String> words;
}

/// Denominations and cellar wines searched by word prefix (BR1.1).
class InternalCatalog {
  InternalCatalog._(this.entries);

  /// Builds the index from the C2 denomination list; done once per session
  /// (NFR1.5).
  factory InternalCatalog.build() => InternalCatalog._(
    List.unmodifiable([
      for (final info in denominationCatalog)
        CatalogEntry(
          displayName: info.displayName,
          denominationKey: info.key,
          searchTerms: List.unmodifiable({
            normalizeWineText(info.displayName),
            for (final alias in info.aliases) normalizeWineText(alias),
          }),
          wineType: catalogTypeOf(info.wineType),
          region: info.region,
        ),
    ]),
  );

  final List<CatalogEntry> entries;

  List<CellarWineRef>? _cellarSource;
  List<_CellarItem> _cellarItems = const [];

  /// Cellar wines first, then denominations; within each group more whole
  /// matching words first, then the display name in alphabetical order. The
  /// query vintage is copied into the proposals; at most [maxSuggestions],
  /// without duplicates (BR1.1, BR1.4).
  List<WineCandidate> suggest(
    ParsedQuery query, {
    List<CellarWineRef>? cellarWines,
  }) {
    if (query.words.isEmpty) return const [];
    final cellar = <_Scored>[];
    for (final item in _cellarIndex(cellarWines)) {
      final full = _fullMatches(query.words, item.words);
      if (full == null) continue;
      final wine = item.wine;
      cellar.add(
        _Scored(
          WineCandidate(
            name: wine.name,
            source: CandidateSource.cellar,
            producer: wine.producer,
            vintage: wine.vintage ?? query.vintage,
            wineType: wine.wineType,
          ),
          full,
        ),
      );
    }
    final denominations = <_Scored>[];
    for (final entry in entries) {
      final full = _fullMatches(query.words, entry.words);
      if (full == null) continue;
      denominations.add(
        _Scored(
          WineCandidate(
            name: entry.displayName,
            source: CandidateSource.internal,
            vintage: query.vintage,
            wineType: entry.wineType,
            region: entry.region,
            denomination: entry.displayName,
          ),
          full,
        ),
      );
    }
    return mergeCandidates([..._sorted(cellar), ..._sorted(denominations)]);
  }

  /// Normalised cellar wines, recomputed only when U4 passes a different
  /// list object (performance-design.md).
  List<_CellarItem> _cellarIndex(List<CellarWineRef>? wines) {
    if (wines == null || wines.isEmpty) return const [];
    if (identical(wines, _cellarSource)) return _cellarItems;
    _cellarSource = wines;
    _cellarItems = [
      for (final wine in wines.take(maxCellarWines))
        _CellarItem(wine, [
          ...normalizeWineText(wine.name).split(' '),
          if (wine.producer != null)
            ...normalizeWineText(wine.producer!).split(' '),
        ]),
    ];
    return _cellarItems;
  }

  /// Number of query words equal to a whole word, or `null` when some query
  /// word is not the start of any word of [words].
  static int? _fullMatches(List<String> query, List<String> words) {
    var full = 0;
    for (final queryWord in query) {
      var prefix = false;
      for (final word in words) {
        if (word == queryWord) {
          full++;
          prefix = true;
          break;
        }
        if (word.startsWith(queryWord)) prefix = true;
      }
      if (!prefix) return null;
    }
    return full;
  }

  static List<WineCandidate> _sorted(List<_Scored> scored) {
    scored.sort((a, b) {
      final byMatches = b.fullMatches.compareTo(a.fullMatches);
      if (byMatches != 0) return byMatches;
      return a.candidate.name.toLowerCase().compareTo(
        b.candidate.name.toLowerCase(),
      );
    });
    return [for (final item in scored) item.candidate];
  }
}

/// Removes duplicates (BR1.4): two proposals are the same wine when
/// normalised name, normalised producer and vintage match; the one with the
/// highest source (cellar, then internal, then Open Food Facts) stays, in
/// the place of the first one. At most [limit] are kept.
List<WineCandidate> mergeCandidates(
  Iterable<WineCandidate> candidates, {
  int limit = maxSuggestions,
}) {
  final result = <WineCandidate>[];
  final positions = <(String, String, int?), int>{};
  for (final candidate in candidates) {
    final key = (
      normalizeWineText(candidate.name),
      normalizeWineText(candidate.producer ?? ''),
      candidate.vintage,
    );
    final existing = positions[key];
    if (existing == null) {
      positions[key] = result.length;
      result.add(candidate);
    } else if (candidate.source.rank < result[existing].source.rank) {
      result[existing] = candidate;
    }
  }
  return result.length <= limit ? result : result.sublist(0, limit);
}
