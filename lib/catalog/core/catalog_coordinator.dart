// The WineCatalog of contract C1 (logical-components.md): validation, order
// of the sources, merge without duplicates and the user's session. Open Food
// Facts is reached only through the cache, the circuit breaker and the
// request budget, and its failures never leave this class: callers get
// internal results, `none` or `null` (BR2.2, NFR6.1). The only exception is
// CatalogArgumentError for invalid inputs (NFR4.5).
//
// label-recognition (BR3.1-BR3.4, BR4.2, BR4.3, BR6.1, FR5): the offline
// wine database comes first; without a network Open Food Facts is not asked
// and nothing counts as a failure; matchLabel decides between a sure
// proposal, candidates and nothing; searchOnline serves "Cerca online".

import 'dart:async';

import 'package:estimation/estimation.dart';

import 'catalog_cache_store.dart';
import 'catalog_event_logger.dart';
import 'internal_catalog.dart';
import 'network_status.dart';
import 'off/open_food_facts_source.dart';
import 'off_circuit_breaker.dart';
import 'offline/text_score.dart';
import 'offline/wine_db_index.dart';
import 'request_budget.dart';
import 'wine_catalog.dart';

/// Longest query accepted, in characters (C1).
const int maxQueryLength = 120;

/// Shortest normalised query accepted (C1).
const int minQueryLength = 2;

/// Shortest normalised query sent to Open Food Facts (BR1.2).
const int minExternalQueryLength = 3;

/// Longest label text accepted, in characters: front and back merged
/// (label-recognition BR1.2; 2000 before).
const int maxLabelTextLength = 4000;

/// Most label words sent to Open Food Facts (BR1.3, NFR4.2).
const int maxLabelSearchWords = 6;

/// Opens the offline wine database at first use; `null` when it is
/// unavailable (label-recognition NFR4.5).
typedef WineDbOpener = Future<OfflineWineDb?> Function();

Future<OfflineWineDb?> _noWineDb() async => null;

/// Implementation of [WineCatalog].
class CatalogCoordinator implements WineCatalog {
  CatalogCoordinator({
    required this._internal,
    required this._cache,
    required this._budget,
    required this._breaker,
    required this._logger,
    Future<OpenFoodFactsSource?>? offSource,
    WineDbOpener? wineDb,
    this._network = const AssumeOnlineNetworkStatus(),
  }) : _offSource = offSource ?? Future.value(),
       _wineDb = wineDb ?? _noWineDb;

  final InternalCatalog _internal;
  final CatalogCacheStore _cache;
  final RequestBudget _budget;
  final OffCircuitBreaker _breaker;
  final CatalogEventLogger _logger;

  /// `null` when the build has no Open Food Facts contact (BR5.1).
  final Future<OpenFoodFactsSource?> _offSource;
  final WineDbOpener _wineDb;
  final CatalogNetworkStatus _network;

  bool _sessionStarted = false;
  String? _ownerHash;

  /// Starts the session of [ownerHash] (SHA-256 of the signed-in uid, or
  /// `null` with nobody signed in). On a change of user the previous
  /// user's cache is cleared before anything of the new one is served
  /// (NFR8.1).
  Future<void> startSession(String? ownerHash) {
    if (_sessionStarted && ownerHash == _ownerHash) return _cache.ready;
    final hadSession = _sessionStarted;
    _sessionStarted = true;
    _ownerHash = ownerHash;
    if (hadSession) unawaited(_cache.clear());
    return _cache.open(ownerHash);
  }

  /// Deletes the cache and the profile hints of the current user, file
  /// included (sign-out, account deletion by U8).
  Future<void> clear() => _cache.clear();

  /// Stops the pending cache save.
  void dispose() => _cache.dispose();

  @override
  SuggestResult suggestWines(
    String query, {
    CatalogLocale locale = CatalogLocale.en,
    List<CellarWineRef>? cellarWines,
  }) {
    final normalized = _validateQuery(query);
    return SuggestResult(
      suggestions: _internal.suggest(
        ParsedQuery(normalized),
        cellarWines: cellarWines,
      ),
      externalIncluded: false,
    );
  }

  @override
  Future<SuggestResult> suggestExternal(
    String query, {
    CatalogLocale locale = CatalogLocale.en,
  }) async {
    final normalized = _validateQuery(query);
    if (normalized.length < minExternalQueryLength) return SuggestResult.empty;
    final found = (await _external(
      OffRequestKind.search,
      'search:$normalized',
      (source) => source.search(normalized, locale),
    )).found;
    if (found == null || found.isEmpty) return SuggestResult.empty;
    return SuggestResult(
      suggestions: mergeCandidates(found),
      externalIncluded: true,
    );
  }

  /// The lookup order of a label (label-recognition BR3.1):
  /// 1. barcode in the offline database: sure;
  /// 2. text in the offline database: sure when BR3.2 holds;
  /// 3. a denomination of the internal catalog: a candidate at 0.70;
  /// 4. only with a network and Open Food Facts on: the barcode (sure), then
  ///    the text (candidates scored with BR3.6);
  /// 5. otherwise the candidates gathered, best first, or nothing.
  @override
  Future<LabelMatchResult> matchLabel(
    String text, {
    String? barcode,
    CatalogLocale locale = CatalogLocale.en,
  }) async {
    if (text.length > maxLabelTextLength) {
      throw CatalogArgumentError(CatalogErrorCode.textTooLong);
    }
    final code = barcode == null ? null : normalizeBarcode(barcode);
    if (barcode != null && code == null) {
      throw CatalogArgumentError(CatalogErrorCode.invalidBarcode);
    }
    final db = await _wineDb();
    final label = LabelWords.of(text);
    final pool = <_Scored>[
      if (db != null)
        for (final found in db.index.matchText(text))
          _Scored(
            found.record.toCandidate(),
            found.match,
            LabelMatchStep.offlineText,
          ),
    ];
    if (code != null) {
      final record = db?.index.byBarcode(code);
      if (record != null) {
        return _sure(record.toCandidate(), LabelMatchStep.offlineBarcode, pool);
      }
    }
    final offlineSure = _sureOf(_dedupe(pool));
    if (offlineSure != null) return offlineSure;
    final denomination = recognizeDenomination(text);
    final vintage = ParsedQuery(normalizeWineText(text)).vintage;
    if (denomination != null) {
      pool.add(_internalCandidate(denomination, vintage));
    }
    if (code != null) {
      final online = (await _external(
        OffRequestKind.product,
        'product:$code',
        (source) => source.product(code),
      )).found;
      final first = online?.firstOrNull;
      if (first != null) {
        return _sure(first, LabelMatchStep.onlineBarcode, pool);
      }
    }
    pool.addAll(await _onlineText(text, label, denomination, locale));
    final merged = _dedupe(pool);
    final sure = _sureOf(merged);
    if (sure != null) return sure;
    if (merged.isEmpty) return const LabelMatchResult.none();
    return LabelMatchResult.candidates([
      for (final scored in merged) scored.candidate,
    ], step: merged.first.step);
  }

  @override
  Future<OnlineSearchResult> searchOnline(
    String query, {
    CatalogLocale locale = CatalogLocale.en,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      throw CatalogArgumentError(CatalogErrorCode.queryTooShort);
    }
    if (trimmed.length > maxQueryLength) {
      throw CatalogArgumentError(CatalogErrorCode.queryTooLong);
    }
    final db = await _wineDb();
    final code = normalizeBarcode(trimmed.replaceAll(' ', ''));
    final offline = <WineCandidate>[
      if (db != null && code != null) ?db.index.byBarcode(code)?.toCandidate(),
      if (db != null && code == null)
        for (final found in db.index.search(trimmed))
          found.record.toCandidate(),
    ];
    final normalized = normalizeWineText(trimmed);
    final _ExternalAnswer answer;
    if (code != null) {
      answer = await _external(
        OffRequestKind.product,
        'product:$code',
        (source) => source.product(code),
      );
    } else if (normalized.length >= minExternalQueryLength) {
      answer = await _external(
        OffRequestKind.search,
        'search:$normalized',
        (source) => source.search(normalized, locale),
      );
    } else {
      answer = const _ExternalAnswer(_ExternalStatus.notAsked);
    }
    final online = answer.found ?? const <WineCandidate>[];
    // Offline results first, then online ones, each in the order found:
    // decreasing pseudo-scores keep that order through the merge.
    final candidates = [
      for (final scored in _dedupe([
        for (final (i, candidate) in offline.indexed)
          _Scored(
            candidate,
            TextMatch(2 - i / 100, 0),
            LabelMatchStep.offlineText,
          ),
        for (final (i, candidate) in online.indexed)
          _Scored(
            candidate,
            TextMatch(1 - i / 100, 0),
            LabelMatchStep.onlineText,
          ),
      ]))
        scored.candidate,
    ];
    final status = switch (answer.status) {
      _ExternalStatus.offline => OnlineSearchStatus.offline,
      // BR4.3: Open Food Facts off in this build has its own message; a
      // limit or a failure asks to try again later.
      _ExternalStatus.disabled => OnlineSearchStatus.unavailable,
      _ExternalStatus.limited ||
      _ExternalStatus.failed => OnlineSearchStatus.rateLimited,
      _ExternalStatus.answered ||
      _ExternalStatus.discarded ||
      _ExternalStatus.notAsked => OnlineSearchStatus.ok,
    };
    _logger.onlineSearch(
      offline.length,
      online.length,
      // NFR4.13: whether Open Food Facts could not be asked, for any reason
      // but the network.
      limited:
          status == OnlineSearchStatus.rateLimited ||
          status == OnlineSearchStatus.unavailable,
    );
    return OnlineSearchResult(candidates: candidates, status: status);
  }

  @override
  Future<WineProfileResult> getWineProfile(
    String name, {
    String? producer,
    int? vintage,
  }) async {
    await _cache.ready;
    final hint = _cache.hint(normalizeWineText(name));
    final recognized = recognizeDenomination(name);
    // No current source has windows or pairings: found is always false
    // (BR3.1), and Open Food Facts is never called from here.
    return WineProfileResult(
      found: false,
      wineType:
          hint?.wineType ??
          (recognized == null ? null : catalogTypeOf(recognized.wineType)),
      region: hint?.region ?? recognized?.region,
      denomination: hint?.denomination ?? recognized?.displayName,
    );
  }

  /// The offline database first (label-recognition FR2.3), then Open Food
  /// Facts when possible.
  @override
  Future<WineCandidate?> lookupBarcode(String code) async {
    final barcode = normalizeBarcode(code);
    if (barcode == null) {
      throw CatalogArgumentError(CatalogErrorCode.invalidBarcode);
    }
    final offline = (await _wineDb())?.index.byBarcode(barcode);
    if (offline != null) return offline.toCandidate();
    final found = (await _external(
      OffRequestKind.product,
      'product:$barcode',
      (source) => source.product(barcode),
    )).found;
    return found?.firstOrNull;
  }

  /// The normalised query, or [CatalogArgumentError] (BR1.1).
  String _validateQuery(String query) {
    if (query.length > maxQueryLength) {
      throw CatalogArgumentError(CatalogErrorCode.queryTooLong);
    }
    final normalized = normalizeWineText(query);
    if (normalized.length < minQueryLength) {
      throw CatalogArgumentError(CatalogErrorCode.queryTooShort);
    }
    return normalized;
  }

  /// Step 4 text: the Open Food Facts search with the label words, each
  /// result scored against the text (BR3.6). With a denomination in the
  /// text only results of that denomination are kept, completed with its
  /// type and region (BR1.3).
  Future<List<_Scored>> _onlineText(
    String text,
    LabelWords label,
    RecognizedDenomination? denomination,
    CatalogLocale locale,
  ) async {
    final terms = labelSearchWords(normalizeWineText(text).split(' '));
    if (terms.isEmpty) return const [];
    final joined = terms.join(' ');
    final found = (await _external(
      OffRequestKind.search,
      'search:$joined',
      (source) => source.search(joined, locale),
    )).found;
    final scored = <_Scored>[];
    for (final candidate in found ?? const <WineCandidate>[]) {
      if (denomination != null &&
          recognizeDenomination(candidate.name)?.key != denomination.key) {
        continue;
      }
      final match = scoreWine(
        WineWords.of(
          name: candidate.name,
          producer: candidate.producer,
          denomination: candidate.denomination,
          vintage: candidate.vintage,
        ),
        label,
      );
      if (match.score < LabelMatchThresholds.candidate) continue;
      scored.add(
        _Scored(
          denomination == null
              ? candidate
              : WineCandidate(
                  name: candidate.name,
                  source: candidate.source,
                  producer: candidate.producer,
                  vintage: candidate.vintage,
                  wineType: catalogTypeOf(denomination.wineType),
                  region: denomination.region,
                  denomination: denomination.displayName,
                  barcode: candidate.barcode,
                  country: candidate.country,
                  // wine-style-profiles BR3.5: the Type is not reduced.
                  exactType: denomination.wineType,
                ),
          match,
          LabelMatchStep.onlineText,
        ),
      );
    }
    return scored;
  }

  /// Step 3: the denomination alone, never a sure proposal (BR3.1).
  static _Scored _internalCandidate(
    RecognizedDenomination denomination,
    int? vintage,
  ) => _Scored(
    WineCandidate(
      name: denomination.displayName,
      source: CandidateSource.internal,
      vintage: vintage,
      wineType: catalogTypeOf(denomination.wineType),
      region: denomination.region,
      denomination: denomination.displayName,
      exactType: denomination.wineType,
    ),
    const TextMatch(LabelMatchThresholds.internalDenomination, 1),
    LabelMatchStep.internalDenomination,
  );

  /// A sure proposal by barcode, with the other candidates for "Non è
  /// questo" (BR3.5).
  static LabelMatchResult _sure(
    WineCandidate candidate,
    LabelMatchStep step,
    List<_Scored> others,
  ) {
    final alternatives = _dedupe([_Scored(candidate, _exact, step), ...others]);
    return LabelMatchResult.sure(
      candidate,
      step: step,
      candidates: [for (final scored in alternatives.skip(1)) scored.candidate],
    );
  }

  static const TextMatch _exact = TextMatch(2, 99);

  /// The sure proposal of a merged list (BR3.2), or `null`.
  static LabelMatchResult? _sureOf(List<_Scored> merged) {
    if (merged.isEmpty) return null;
    final best = merged.first;
    final second = merged.length > 1 ? merged[1].match.score : null;
    if (!isSureTextMatch(best.match, second)) return null;
    return LabelMatchResult.sure(
      best.candidate,
      step: best.step,
      candidates: [for (final scored in merged.skip(1)) scored.candidate],
    );
  }

  /// BR3.3: the same barcode, or the same normalised name and producer,
  /// appears once; the offline source wins, with the best score of the
  /// two. Best score first, then the source rank; at most 10.
  static List<_Scored> _dedupe(List<_Scored> scored) {
    final sorted = [...scored]
      ..sort((a, b) {
        final byScore = b.match.score.compareTo(a.match.score);
        if (byScore != 0) return byScore;
        final byRank = a.candidate.source.rank.compareTo(
          b.candidate.source.rank,
        );
        return byRank != 0
            ? byRank
            : a.candidate.name.compareTo(b.candidate.name);
      });
    final result = <_Scored>[];
    for (final item in sorted) {
      final index = result.indexWhere((kept) => _sameWine(kept, item));
      if (index < 0) {
        result.add(item);
      } else if (item.candidate.source.rank <
          result[index].candidate.source.rank) {
        result[index] = _Scored(item.candidate, result[index].match, item.step);
      }
    }
    return result.length <= LabelMatchThresholds.maxCandidates
        ? result
        : result.sublist(0, LabelMatchThresholds.maxCandidates);
  }

  static bool _sameWine(_Scored a, _Scored b) {
    final codeA = a.candidate.barcode;
    if (codeA != null && codeA == b.candidate.barcode) return true;
    return normalizeWineText(a.candidate.name) ==
            normalizeWineText(b.candidate.name) &&
        normalizeWineText(a.candidate.producer ?? '') ==
            normalizeWineText(b.candidate.producer ?? '');
  }

  /// Cached answer for [key], else one Open Food Facts request within the
  /// network check, the breaker and the budget. [_ExternalAnswer.found] is
  /// `null` when nothing could be asked or the request failed, an empty
  /// list for "nothing found" (BR2.1, BR2.2). Without a network nothing is
  /// asked and nothing counts as a failure (label-recognition FR5).
  Future<_ExternalAnswer> _external(
    OffRequestKind kind,
    String key,
    Future<OffOutcome> Function(OpenFoodFactsSource source) request,
  ) async {
    await _cache.ready;
    final cached = _cache.lookup(key);
    if (cached != null) {
      return _ExternalAnswer(_ExternalStatus.answered, cached);
    }
    final source = await _offSource;
    if (source == null) {
      _logger.debug(CatalogDebugEvent.offDisabled);
      return const _ExternalAnswer(_ExternalStatus.disabled);
    }
    if (!await _hasNetwork()) {
      _logger.debug(CatalogDebugEvent.offSkippedOffline);
      return const _ExternalAnswer(_ExternalStatus.offline);
    }
    if (!_breaker.allowRequest()) {
      _logger.debug(CatalogDebugEvent.offSkippedSuspended);
      return const _ExternalAnswer(_ExternalStatus.limited);
    }
    if (!_budget.tryAcquire(kind)) {
      _logger.debug(CatalogDebugEvent.offSkippedBudget);
      return const _ExternalAnswer(_ExternalStatus.limited);
    }
    final epoch = _cache.epoch;
    final outcome = await request(source);
    final List<WineCandidate> answer;
    switch (outcome) {
      case OffFound(:final candidates):
        _breaker.recordSuccess();
        _logger.debug(CatalogDebugEvent.offFound);
        answer = candidates;
      case OffNotFound():
        _breaker.recordSuccess();
        _logger.debug(CatalogDebugEvent.offNotFound);
        answer = const [];
      case OffFailed(:final failure):
        _logger.debug(CatalogDebugEvent.offFailed, failure: failure);
        _breaker.recordFailure(failure);
        return const _ExternalAnswer(_ExternalStatus.failed);
    }
    // The user changed while the request was in flight: the answer belongs
    // to nobody now, it is neither cached nor returned (NFR8.1).
    if (_cache.epoch != epoch) {
      _logger.debug(CatalogDebugEvent.offResponseDiscarded);
      return const _ExternalAnswer(_ExternalStatus.discarded);
    }
    _cache.put(key, answer, hintKeyOf: normalizeWineText);
    return _ExternalAnswer(_ExternalStatus.answered, answer);
  }

  /// A failing check counts as a network: Open Food Facts is tried, as
  /// before the fix (BR6.1).
  Future<bool> _hasNetwork() async {
    try {
      return await _network.hasNetwork();
    } catch (_) {
      return true;
    }
  }
}

enum _ExternalStatus {
  answered,
  disabled,
  offline,
  limited,
  failed,
  discarded,
  notAsked,
}

class _ExternalAnswer {
  const _ExternalAnswer(this.status, [this.found]);

  final _ExternalStatus status;
  final List<WineCandidate>? found;
}

/// A candidate with its score and the step that found it.
class _Scored {
  const _Scored(this.candidate, this.match, this.step);

  final WineCandidate candidate;
  final TextMatch match;
  final LabelMatchStep step;
}

/// Words of a label sent to Open Food Facts (BR1.3): the
/// [maxLabelSearchWords] longest normalised words of at least 3 letters and
/// no digits; on equal length the first in the text wins. Returned in text
/// order.
List<String> labelSearchWords(List<String> normalizedWords) {
  final letters = RegExp(r'^[a-z]{3,}$');
  final indexed = [
    for (var i = 0; i < normalizedWords.length; i++)
      if (letters.hasMatch(normalizedWords[i])) (i, normalizedWords[i]),
  ];
  final longest = [...indexed]
    ..sort((a, b) {
      final byLength = b.$2.length.compareTo(a.$2.length);
      return byLength != 0 ? byLength : a.$1.compareTo(b.$1);
    });
  final chosen = longest.take(maxLabelSearchWords).toList()
    ..sort((a, b) => a.$1.compareTo(b.$1));
  return [for (final (_, word) in chosen) word];
}
