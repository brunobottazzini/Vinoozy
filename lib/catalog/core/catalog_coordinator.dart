// The WineCatalog of contract C1 (logical-components.md): validation, order
// of the sources, merge without duplicates and the user's session. Open Food
// Facts is reached only through the cache, the circuit breaker and the
// request budget, and its failures never leave this class: callers get
// internal results, `matched: false` or `null` (BR2.2, NFR6.1). The only
// exception is CatalogArgumentError for invalid inputs (NFR4.5).

import 'dart:async';

import 'package:estimation/estimation.dart';

import 'catalog_cache_store.dart';
import 'catalog_event_logger.dart';
import 'internal_catalog.dart';
import 'off/open_food_facts_source.dart';
import 'off_circuit_breaker.dart';
import 'request_budget.dart';
import 'wine_catalog.dart';

/// Longest query accepted, in characters (C1).
const int maxQueryLength = 120;

/// Shortest normalised query accepted (C1).
const int minQueryLength = 2;

/// Shortest normalised query sent to Open Food Facts (BR1.2).
const int minExternalQueryLength = 3;

/// Longest label text accepted, in characters (C1).
const int maxLabelTextLength = 2000;

/// Most label words sent to Open Food Facts (BR1.3, NFR4.2).
const int maxLabelSearchWords = 6;

/// Implementation of [WineCatalog].
class CatalogCoordinator implements WineCatalog {
  CatalogCoordinator({
    required this._internal,
    required this._cache,
    required this._budget,
    required this._breaker,
    required this._logger,
    Future<OpenFoodFactsSource?>? offSource,
  }) : _offSource = offSource ?? Future.value();

  final InternalCatalog _internal;
  final CatalogCacheStore _cache;
  final RequestBudget _budget;
  final OffCircuitBreaker _breaker;
  final CatalogEventLogger _logger;

  /// `null` when the build has no Open Food Facts contact (BR5.1).
  final Future<OpenFoodFactsSource?> _offSource;

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
    final found = await _external(
      OffRequestKind.search,
      'search:$normalized',
      (source) => source.search(normalized, locale),
    );
    if (found == null || found.isEmpty) return SuggestResult.empty;
    return SuggestResult(
      suggestions: mergeCandidates(found),
      externalIncluded: true,
    );
  }

  @override
  Future<LabelMatch> matchLabelText(
    String text, {
    CatalogLocale locale = CatalogLocale.en,
  }) async {
    if (text.length > maxLabelTextLength) {
      throw CatalogArgumentError(CatalogErrorCode.textTooLong);
    }
    final words = normalizeWineText(text).split(' ');
    final denomination = recognizeDenomination(text);
    final vintage = ParsedQuery(words.join(' ')).vintage;
    final terms = labelSearchWords(words);
    WineCandidate? chosen;
    if (terms.isNotEmpty) {
      final joined = terms.join(' ');
      final found = await _external(
        OffRequestKind.search,
        'search:$joined',
        (source) => source.search(joined, locale),
      );
      chosen = found?.where((candidate) {
        if (denomination == null) return true;
        return recognizeDenomination(candidate.name)?.key == denomination.key;
      }).firstOrNull;
    }
    if (chosen != null) {
      return LabelMatch.matched(
        WineCandidate(
          name: chosen.name,
          source: CandidateSource.openFoodFacts,
          producer: chosen.producer,
          vintage: vintage,
          wineType: denomination == null
              ? chosen.wineType
              : catalogTypeOf(denomination.wineType),
          region: denomination?.region ?? chosen.region,
          denomination: denomination?.displayName ?? chosen.denomination,
          barcode: chosen.barcode,
        ),
      );
    }
    if (denomination == null) return const LabelMatch.none();
    return LabelMatch.matched(
      WineCandidate(
        name: denomination.displayName,
        source: CandidateSource.internal,
        vintage: vintage,
        wineType: catalogTypeOf(denomination.wineType),
        region: denomination.region,
        denomination: denomination.displayName,
      ),
    );
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

  @override
  Future<WineCandidate?> lookupBarcode(String code) async {
    final barcode = normalizeBarcode(code);
    if (barcode == null) {
      throw CatalogArgumentError(CatalogErrorCode.invalidBarcode);
    }
    final found = await _external(
      OffRequestKind.product,
      'product:$barcode',
      (source) => source.product(barcode),
    );
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

  /// Cached answer for [key], else one Open Food Facts request within the
  /// breaker and the budget. `null` when nothing could be asked or the
  /// request failed; an empty list for "nothing found" (BR2.1, BR2.2).
  Future<List<WineCandidate>?> _external(
    OffRequestKind kind,
    String key,
    Future<OffOutcome> Function(OpenFoodFactsSource source) request,
  ) async {
    await _cache.ready;
    final cached = _cache.lookup(key);
    if (cached != null) return cached;
    final source = await _offSource;
    if (source == null) {
      _logger.debug(CatalogDebugEvent.offDisabled);
      return null;
    }
    if (!_breaker.allowRequest()) {
      _logger.debug(CatalogDebugEvent.offSkippedSuspended);
      return null;
    }
    if (!_budget.tryAcquire(kind)) {
      _logger.debug(CatalogDebugEvent.offSkippedBudget);
      return null;
    }
    final epoch = _cache.epoch;
    final outcome = await request(source);
    final List<WineCandidate>? answer;
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
        return null;
    }
    // The user changed while the request was in flight: the answer belongs
    // to nobody now, it is neither cached nor returned (NFR8.1).
    if (_cache.epoch != epoch) {
      _logger.debug(CatalogDebugEvent.offResponseDiscarded);
      return null;
    }
    _cache.put(key, answer, hintKeyOf: normalizeWineText);
    return answer;
  }
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
