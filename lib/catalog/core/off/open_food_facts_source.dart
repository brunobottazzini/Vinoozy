// Adapter of contract C5: the only code that knows the Open Food Facts format
// (BR4.1). It never throws: every request ends in a typed outcome
// (reliability-design.md), and the format never leaves this file.
//
// Requests (security-design.md §1, NFR4.1, NFR4.2): HTTPS to a fixed host,
// URLs built with Uri.https (parameters encoded), no redirects, only the
// User-Agent header, one 5-second deadline over sending, waiting and reading
// the body, and a streamed read stopped as soon as it passes 1 MB.

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:estimation/estimation.dart';
import 'package:http/http.dart' as http;

import '../catalog_config.dart';
import '../catalog_event_logger.dart';
import '../wine_catalog.dart';

/// Result of one request to Open Food Facts.
sealed class OffOutcome {
  const OffOutcome();
}

/// HTTP 200 with at least one valid wine.
final class OffFound extends OffOutcome {
  const OffFound(this.candidates);

  final List<WineCandidate> candidates;
}

/// HTTP 404, product absent (`status: 0`), not a wine, or no results: a
/// successful answer, cached as an empty list (NFR6.2).
final class OffNotFound extends OffOutcome {
  const OffNotFound();
}

/// A failure: never cached, counted by the circuit breaker.
final class OffFailed extends OffOutcome {
  const OffFailed(this.failure);

  final OffFailure failure;
}

/// Normalises an EAN-8, UPC-A or EAN-13 barcode (BR1.5): digits only, 8, 12
/// or 13 of them; 12 digits get a leading zero. `null` for anything else.
String? normalizeBarcode(String code) {
  if (!RegExp(r'^\d+$').hasMatch(code)) return null;
  return switch (code.length) {
    8 || 13 => code,
    12 => '0$code',
    _ => null,
  };
}

/// Search and product reads on Open Food Facts.
class OpenFoodFactsSource {
  OpenFoodFactsSource({
    required this._client,
    required this._config,
    this._timerFactory = Timer.new,
  });

  /// One deadline for the whole request (C5).
  static const Duration deadline = Duration(seconds: 5);

  /// Larger bodies are a `too_large` failure (NFR4.1).
  static const int maxBodyBytes = 1024 * 1024;

  /// Most results asked to a search.
  static const int pageSize = 10;

  /// The only fields read (BR4.1).
  static const String fields =
      'code,product_name,brands,categories_tags,origins';

  /// Field limits in characters (NFR2.3, NFR4.4).
  static const int maxName = 120;
  static const int maxProducer = 80;
  static const int maxRegion = 60;
  static const int maxDenomination = 60;

  final http.Client _client;
  final CatalogConfig _config;
  final CatalogTimerFactory _timerFactory;

  /// Search in the wine category, preferring names in [locale].
  static Uri searchUri(String terms, CatalogLocale locale) =>
      Uri.https(CatalogConfig.offHost, '/cgi/search.pl', {
        'search_terms': terms,
        'tagtype_0': 'categories',
        'tag_contains_0': 'contains',
        'tag_0': 'wines',
        'json': '1',
        'page_size': '$pageSize',
        'lc': locale.offLanguage,
        'fields': fields,
      });

  /// Product read; [barcode] is already normalised (digits only).
  static Uri productUri(String barcode) => Uri.https(
    CatalogConfig.offHost,
    '/api/v2/product/$barcode.json',
    {'fields': fields},
  );

  /// Wines matching [terms] (BR1.2, BR1.3).
  Future<OffOutcome> search(String terms, CatalogLocale locale) =>
      _fetch(searchUri(terms, locale), _parseSearch);

  /// The product with the normalised [barcode] (BR1.5).
  Future<OffOutcome> product(String barcode) =>
      _fetch(productUri(barcode), _parseProduct);

  Future<OffOutcome> _fetch(Uri uri, OffOutcome Function(Object?) parse) {
    final request = http.Request('GET', uri)
      ..followRedirects = false
      ..headers['User-Agent'] = _config.userAgent;
    final result = Completer<OffOutcome>();
    StreamSubscription<List<int>>? subscription;
    Timer? timer;

    void finish(OffOutcome outcome) {
      if (result.isCompleted) return;
      timer?.cancel();
      // Stops reading the body; the late answer, if any, is ignored.
      unawaited(subscription?.cancel());
      result.complete(outcome);
    }

    timer = _timerFactory(
      deadline,
      () => finish(const OffFailed(OffFailure(OffFailureKind.timeout))),
    );
    void onResponse(http.StreamedResponse response) {
      if (result.isCompleted) {
        // Arrived after the deadline: ignored.
        _discard(response);
        return;
      }
      final status = response.statusCode;
      if (status != 200) {
        // 3xx are failures too: redirects are never followed.
        _discard(response);
        finish(
          status == 404
              ? const OffNotFound()
              : OffFailed(OffFailure.http(status)),
        );
        return;
      }
      final body = BytesBuilder(copy: false);
      subscription = response.stream.listen(
        (chunk) {
          body.add(chunk);
          if (body.length > maxBodyBytes) {
            finish(const OffFailed(OffFailure(OffFailureKind.tooLarge)));
          }
        },
        onError: (Object _) => finish(_networkFailure),
        onDone: () => finish(_decode(body.takeBytes(), parse)),
        cancelOnError: true,
      );
    }

    // Errors of the send, or late ones after the deadline, end here and
    // never become unhandled errors.
    unawaited(
      Future<http.StreamedResponse>.sync(() => _client.send(request))
          .then(onResponse)
          .catchError((Object _) => finish(_networkFailure)),
    );
    return result.future;
  }

  static const OffFailed _networkFailure = OffFailed(
    OffFailure(OffFailureKind.network),
  );

  void _discard(http.StreamedResponse response) {
    unawaited(response.stream.listen(null).cancel());
  }

  OffOutcome _decode(Uint8List bytes, OffOutcome Function(Object?) parse) {
    try {
      return parse(jsonDecode(utf8.decode(bytes)));
    } on FormatException {
      return const OffFailed(OffFailure(OffFailureKind.invalidJson));
    }
  }

  static OffOutcome _parseSearch(Object? json) {
    if (json is! Map || json['products'] is! List) {
      return const OffFailed(OffFailure(OffFailureKind.invalidJson));
    }
    final candidates = (json['products'] as List)
        .map(mapProduct)
        .nonNulls
        .take(pageSize)
        .toList(growable: false);
    return candidates.isEmpty ? const OffNotFound() : OffFound(candidates);
  }

  static OffOutcome _parseProduct(Object? json) {
    if (json is! Map) {
      return const OffFailed(OffFailure(OffFailureKind.invalidJson));
    }
    final status = json['status'];
    if (status == 0) return const OffNotFound();
    if (status != 1 || json['product'] is! Map) {
      return const OffFailed(OffFailure(OffFailureKind.invalidJson));
    }
    final candidate = mapProduct(json['product']);
    return candidate == null ? const OffNotFound() : OffFound([candidate]);
  }

  /// One Open Food Facts product as a proposal (BR4.1), or `null` when it is
  /// not a wine or has no usable name. Fields of the wrong type count as
  /// absent; texts are cleaned of control characters and shortened
  /// (NFR4.4).
  static WineCandidate? mapProduct(Object? product) {
    if (product is! Map) return null;
    final rawTags = product['categories_tags'];
    final tags = rawTags is List
        ? rawTags.whereType<String>().toSet()
        : const <String>{};
    if (!tags.contains('en:wines')) return null;
    final name = cleanText(product['product_name'], maxName);
    if (name == null) return null;
    final denomination = recognizeDenomination(name)?.displayName;
    final code = product['code'];
    return WineCandidate(
      name: name,
      source: CandidateSource.openFoodFacts,
      producer: _firstBrand(product['brands']),
      wineType: wineTypeFromTags(tags),
      region: cleanText(product['origins'], maxRegion),
      denomination: cleanText(denomination, maxDenomination),
      barcode: code is String ? normalizeBarcode(code) : null,
    );
  }

  /// C1 type from the English category tags. The style (sparkling, sweet)
  /// wins over the colour, because it decides how the wine ages and what it
  /// goes with: a sparkling rosé is `sparkling`, a fortified red is `sweet`.
  static CatalogWineType? wineTypeFromTags(Set<String> tags) {
    if (tags.contains('en:sparkling-wines') || tags.contains('en:champagnes')) {
      return CatalogWineType.sparkling;
    }
    if (tags.contains('en:sweet-wines') ||
        tags.contains('en:dessert-wines') ||
        tags.contains('en:fortified-wines')) {
      return CatalogWineType.sweet;
    }
    if (tags.contains('en:rose-wines')) return CatalogWineType.rose;
    if (tags.contains('en:white-wines')) return CatalogWineType.white;
    if (tags.contains('en:red-wines')) return CatalogWineType.red;
    return null;
  }

  /// [value] without control characters (U+0000–U+001F, U+007F–U+009F),
  /// trimmed and cut to [maxLength] characters; `null` when it is not a
  /// string or nothing is left.
  static String? cleanText(Object? value, int maxLength) {
    if (value is! String) return null;
    final cleaned = String.fromCharCodes(
      value.runes.where((rune) => rune > 0x1F && (rune < 0x7F || rune > 0x9F)),
    ).trim();
    if (cleaned.isEmpty) return null;
    final runes = cleaned.runes;
    if (runes.length <= maxLength) return cleaned;
    return String.fromCharCodes(runes.take(maxLength)).trim();
  }

  static String? _firstBrand(Object? brands) {
    if (brands is! String) return null;
    for (final brand in brands.split(',')) {
      final cleaned = cleanText(brand, maxProducer);
      if (cleaned != null) return cleaned;
    }
    return null;
  }
}
