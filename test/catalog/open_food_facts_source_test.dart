// OpenFoodFactsSource with MockClient and recorded answers: outcomes, request
// shape, deadline, streamed size limit and defensive mapping (BR2.2, BR4.1,
// BR5.1, NFR1.3, NFR4.1-NFR4.4, NFR6.2). The real Open Food Facts is never
// called.
import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:vinoozy/catalog/core/catalog_config.dart';
import 'package:vinoozy/catalog/core/catalog_event_logger.dart';
import 'package:vinoozy/catalog/core/off/open_food_facts_source.dart';
import 'package:vinoozy/catalog/core/wine_catalog.dart';

import 'catalog_test_helpers.dart';

const _config = CatalogConfig(appVersion: '1.2.3', offContact: 'team.example');

class _Harness {
  _Harness(MockClientHandler handler) {
    client = MockClient((request) {
      requests.add(request);
      return handler(request);
    });
    source = OpenFoodFactsSource(
      client: client,
      config: _config,
      timerFactory: timers.call,
    );
  }

  _Harness.streaming(MockClientStreamHandler handler) {
    client = MockClient.streaming((request, body) {
      requests.add(request);
      return handler(request, body);
    });
    source = OpenFoodFactsSource(
      client: client,
      config: _config,
      timerFactory: timers.call,
    );
  }

  final requests = <http.BaseRequest>[];
  final timers = FakeTimers();
  late final http.Client client;
  late final OpenFoodFactsSource source;
}

http.Response _json(String body, [int status = 200]) =>
    http.Response.bytes(utf8.encode(body), status);

OffFailure? _failureOf(OffOutcome outcome) =>
    outcome is OffFailed ? outcome.failure : null;

void main() {
  group('outcomes (BR2.2, NFR6.2)', () {
    test('BR4.1 a search maps wines and drops what is not a wine', () async {
      final h = _Harness((_) async => _json(fixture('search_wines.json')));
      final outcome = await h.source.search('barolo', CatalogLocale.it);
      expect(outcome, isA<OffFound>());
      final wines = (outcome as OffFound).candidates;
      expect(wines, hasLength(3));
      expect(
        wines.first,
        const WineCandidate(
          name: 'Barolo Cannubi 2016',
          source: CandidateSource.openFoodFacts,
          producer: 'Cantina Esempio',
          wineType: CatalogWineType.red,
          region: 'Piemonte',
          denomination: 'Barolo DOCG',
          barcode: '8001234567890',
        ),
      );
      expect(wines[1].denomination, 'Langhe Nebbiolo DOC');
      expect(wines[1].region, isNull);
      expect(wines[2].wineType, CatalogWineType.sparkling);
      expect(wines[2].denomination, isNull);
      expect(
        wines.every((w) => w.source == CandidateSource.openFoodFacts),
        isTrue,
      );
      expect(h.timers.active, isEmpty, reason: 'deadline cancelled');
    });

    test('a product read maps the wine', () async {
      final h = _Harness((_) async => _json(fixture('product_wine.json')));
      final outcome = await h.source.product('8001234567890');
      final wine = (outcome as OffFound).candidates.single;
      expect(wine.name, "Barbera d'Asti Superiore");
      expect(wine.denomination, "Barbera d'Asti DOCG");
      expect(wine.region, 'Italia');
    });

    test('404, status 0, not a wine and zero results are notFound', () async {
      for (final response in [
        _json('{}', 404),
        _json(fixture('product_not_found.json')),
        _json(fixture('product_not_wine.json')),
      ]) {
        final h = _Harness((_) async => response);
        expect(await h.source.product('8000000000000'), isA<OffNotFound>());
      }
      final empty = _Harness((_) async => _json(fixture('search_empty.json')));
      expect(
        await empty.source.search('xyz', CatalogLocale.en),
        isA<OffNotFound>(),
      );
    });

    test('429, 503, any other code and a 301 redirect are failures', () async {
      for (final status in [429, 503, 500, 204, 301, 302]) {
        final h = _Harness(
          (_) async => http.Response('', status, headers: {'location': 'x'}),
        );
        final outcome = await h.source.product('8000000000000');
        expect(_failureOf(outcome), OffFailure.http(status));
        expect(_failureOf(outcome)!.label, 'http_$status');
      }
    });

    test('invalid JSON, wrong shapes and bad UTF-8 are invalid_json', () async {
      final bodies = <List<int>>[
        utf8.encode(fixture('invalid_json.txt')),
        utf8.encode('[1, 2]'),
        utf8.encode('{"products": "none"}'),
        [0xff, 0xfe, 0x7b],
      ];
      for (final body in bodies) {
        final h = _Harness((_) async => http.Response.bytes(body, 200));
        final outcome = await h.source.search('barolo', CatalogLocale.en);
        expect(
          _failureOf(outcome),
          const OffFailure(OffFailureKind.invalidJson),
        );
      }
      for (final body in ['"text"', '{"status": 1}', '{"status": "x"}']) {
        final h = _Harness((_) async => _json(body));
        expect(
          _failureOf(await h.source.product('8000000000000'))?.label,
          'invalid_json',
          reason: body,
        );
      }
    });

    test('a network error, before or during the body, is network', () async {
      final h = _Harness((_) async => throw http.ClientException('offline'));
      expect(
        _failureOf(await h.source.search('barolo', CatalogLocale.en))?.label,
        'network',
      );

      final midBody = _Harness.streaming((request, body) async {
        final controller = StreamController<List<int>>();
        controller
          ..add(utf8.encode('{"products": ['))
          ..addError(const SocketExceptionLike())
          ..close();
        return http.StreamedResponse(controller.stream, 200);
      });
      expect(
        _failureOf(await midBody.source.search('barolo', CatalogLocale.en)),
        const OffFailure(OffFailureKind.network),
      );
    });
  });

  group('limits of the request (NFR1.3, NFR4.1)', () {
    test('a 2 MB body is too_large and gives no proposals', () async {
      final big = '{"products": [${List.filled(2 * 1024 * 1024, ' ').join()}]}';
      final h = _Harness((_) async => _json(big));
      expect(
        _failureOf(await h.source.search('barolo', CatalogLocale.en))?.label,
        'too_large',
      );
    });

    test('the streamed read stops as soon as it passes 1 MB', () async {
      var cancelled = false;
      var chunksSent = 0;
      final h = _Harness.streaming((request, body) async {
        late final StreamController<List<int>> controller;
        controller = StreamController<List<int>>(
          onListen: () {
            for (var i = 0; i < 4; i++) {
              chunksSent++;
              controller.add(List.filled(400 * 1024, 0x20));
            }
          },
          onCancel: () => cancelled = true,
        );
        return http.StreamedResponse(controller.stream, 200);
      });
      final outcome = await h.source.search('barolo', CatalogLocale.en);
      expect(_failureOf(outcome)?.kind, OffFailureKind.tooLarge);
      expect(cancelled, isTrue);
      expect(chunksSent, 4);
    });

    test('NFR1.3 one 5 s deadline: a slow answer is a timeout and the late '
        'answer is ignored', () async {
      final late = Completer<http.Response>();
      final h = _Harness((_) => late.future);
      final pending = h.source.search('barolo', CatalogLocale.en);
      expect(h.timers.created.single.duration, const Duration(seconds: 5));
      h.timers.fireAll();
      expect(
        _failureOf(await pending),
        const OffFailure(OffFailureKind.timeout),
      );
      // Arrives after 6 s of simulated time: no error, nothing changes.
      late.complete(_json(fixture('search_wines.json')));
      await settle();
    });

    test('the deadline also covers the body: reading is cancelled', () async {
      var cancelled = false;
      final h = _Harness.streaming((request, body) async {
        final controller = StreamController<List<int>>(
          onCancel: () => cancelled = true,
        );
        controller.add(utf8.encode('{"products": ['));
        return http.StreamedResponse(controller.stream, 200);
      });
      final pending = h.source.search('barolo', CatalogLocale.en);
      await settle();
      h.timers.fireAll();
      expect(_failureOf(await pending)?.label, 'timeout');
      expect(cancelled, isTrue);
    });

    test(
      'a late failure after the deadline is not an unhandled error',
      () async {
        final late = Completer<http.Response>();
        final h = _Harness((_) => late.future);
        final pending = h.source.product('8000000000000');
        // The request reaches the server, which answers only after 5 s.
        await settle();
        expect(h.requests, hasLength(1));
        h.timers.fireAll();
        expect(_failureOf(await pending)?.label, 'timeout');
        late.completeError(http.ClientException('late'));
        await settle();
      },
    );
  });

  group('what is sent (BR5.1, NFR4.1, NFR4.2)', () {
    test(
      'BR5.1 a search sends only the expected parameters and the '
      'User-Agent, over HTTPS to the fixed host, without redirects',
      () async {
        final h = _Harness((_) async => _json(fixture('search_empty.json')));
        await h.source.search('barolo 2016', CatalogLocale.ptBR);
        final request = h.requests.single;
        expect(request.method, 'GET');
        expect(request.url.scheme, 'https');
        expect(request.url.host, 'world.openfoodfacts.org');
        expect(request.url.path, '/cgi/search.pl');
        expect(request.url.queryParameters, {
          'search_terms': 'barolo 2016',
          'tagtype_0': 'categories',
          'tag_contains_0': 'contains',
          'tag_0': 'wines',
          'json': '1',
          'page_size': '10',
          'lc': 'pt',
          'fields': 'code,product_name,brands,categories_tags,origins',
        });
        expect(request.followRedirects, isFalse);
        expect(request.headers.keys.map((k) => k.toLowerCase()).toSet(), {
          'user-agent',
        });
        expect(request.headers['User-Agent'], 'Vinoozy/1.2.3 (team.example)');
        expect((request as http.Request).body, isEmpty);
      },
    );

    test(
      'a product read uses the product path and encodes nothing else',
      () async {
        final h = _Harness(
          (_) async => _json(fixture('product_not_found.json')),
        );
        await h.source.product('8001234567890');
        final url = h.requests.single.url;
        expect(url.toString(), startsWith('https://world.openfoodfacts.org/'));
        expect(url.path, '/api/v2/product/8001234567890.json');
        expect(url.queryParameters.keys, ['fields']);
      },
    );

    test('query text is encoded as a parameter, never as part of the URL', () {
      final uri = OpenFoodFactsSource.searchUri(
        'a/b?c=d&e#f',
        CatalogLocale.en,
      );
      expect(uri.host, 'world.openfoodfacts.org');
      expect(uri.path, '/cgi/search.pl');
      expect(uri.queryParameters['search_terms'], 'a/b?c=d&e#f');
    });
  });

  group('untrusted answers (BR4.1, NFR4.4)', () {
    test(
      'fields of the wrong type are absent, control characters removed',
      () async {
        final h = _Harness(
          (_) async => _json(fixture('search_malformed_fields.json')),
        );
        final outcome = await h.source.search('vino', CatalogLocale.it);
        final wines = (outcome as OffFound).candidates;
        expect(wines.map((w) => w.name), [
          'Vino con controlli',
          'Rosato del Salento',
          'Passito di Pantelleria',
        ]);
        expect(wines[0].producer, isNull);
        expect(wines[0].region, isNull);
        expect(wines[0].barcode, isNull);
        expect(wines[0].wineType, CatalogWineType.white);
        expect(wines[1].producer, 'Produttore Secondo');
        expect(wines[1].wineType, CatalogWineType.rose);
        expect(wines[1].barcode, isNull);
        expect(wines[2].wineType, CatalogWineType.sweet);
        expect(wines[2].barcode, '0012345678905');
        expect(wines[2].denomination, 'Passito di Pantelleria DOC');
      },
    );

    test('texts are cut to 120, 80 and 60 characters', () async {
      final product = {
        'code': '8001234567890',
        'product_name': '${'N' * 200} end',
        'brands': 'P' * 200,
        'origins': '𝔅' * 200,
        'categories_tags': ['en:wines'],
      };
      final h = _Harness(
        (_) async => _json(jsonEncode({'status': 1, 'product': product})),
      );
      final wine = ((await h.source.product(
        '8001234567890',
      )) as OffFound).candidates.single;
      expect(wine.name.runes.length, 120);
      expect(wine.producer!.runes.length, 80);
      expect(wine.region!.runes.length, 60);
      expect(wine.region, '𝔅' * 60);
    });

    test('BR4.1 category tags map to the C1 types, style before colour', () {
      CatalogWineType? type(List<String> tags) =>
          OpenFoodFactsSource.wineTypeFromTags(tags.toSet());
      expect(type(['en:red-wines']), CatalogWineType.red);
      expect(type(['en:white-wines']), CatalogWineType.white);
      expect(type(['en:rose-wines']), CatalogWineType.rose);
      expect(type(['en:sparkling-wines']), CatalogWineType.sparkling);
      expect(type(['en:champagnes']), CatalogWineType.sparkling);
      expect(type(['en:sweet-wines']), CatalogWineType.sweet);
      expect(type(['en:dessert-wines']), CatalogWineType.sweet);
      expect(
        type(['en:fortified-wines', 'en:red-wines']),
        CatalogWineType.sweet,
      );
      expect(
        type(['en:rose-wines', 'en:sparkling-wines']),
        CatalogWineType.sparkling,
      );
      expect(type(['en:wines']), isNull);
      expect(OpenFoodFactsSource.mapProduct('x'), isNull);
    });

    test('BR1.5 barcodes are normalised to 8 or 13 digits', () {
      expect(normalizeBarcode('80012345'), '80012345');
      expect(normalizeBarcode('8001234567890'), '8001234567890');
      expect(normalizeBarcode('012345678905'), '0012345678905');
      expect(normalizeBarcode('1234567'), isNull);
      expect(normalizeBarcode('80012345678901'), isNull);
      expect(normalizeBarcode('8001234 67890'), isNull);
      expect(normalizeBarcode(''), isNull);
    });
  });
}

/// Error type standing in for a socket failure mid-body.
class SocketExceptionLike implements Exception {
  const SocketExceptionLike();
}
