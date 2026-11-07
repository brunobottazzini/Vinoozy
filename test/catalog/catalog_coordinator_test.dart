// CatalogCoordinator, the WineCatalog of C1: one test per rule with its ID
// (NFR7.2), simulated clock and timers, MockClient instead of Open Food
// Facts, marker values to prove no user text reaches the logger (NFR8.3).
import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:vinoozy/catalog/core/catalog_cache_store.dart';
import 'package:vinoozy/catalog/core/catalog_config.dart';
import 'package:vinoozy/catalog/core/catalog_coordinator.dart';
import 'package:vinoozy/catalog/core/catalog_event_logger.dart';
import 'package:vinoozy/catalog/core/internal_catalog.dart';
import 'package:vinoozy/catalog/core/off/open_food_facts_source.dart';
import 'package:vinoozy/catalog/core/off_circuit_breaker.dart';
import 'package:vinoozy/catalog/core/request_budget.dart';
import 'package:vinoozy/catalog/core/wine_catalog.dart';

import 'catalog_test_helpers.dart';

const _owner = 'owner-hash-a';
const _marker = 'zqxmarkerzq';

typedef _Server = FutureOr<http.Response> Function(http.Request request);

http.Response _json(String body, [int status = 200]) =>
    http.Response.bytes(utf8.encode(body), status);

class _Harness {
  _Harness({_Server? server, bool offEnabled = true, InMemoryCacheFile? file})
    : file = file ?? InMemoryCacheFile() {
    this.server = server ?? (_) => _json(fixture('search_empty.json'));
    final client = MockClient((request) async {
      requests.add(request);
      return this.server(request);
    });
    cache = CatalogCacheStore(
      file: this.file,
      clock: clock,
      health: health,
      logger: logger,
      timerFactory: timers.call,
    );
    coordinator = CatalogCoordinator(
      internal: InternalCatalog.build(),
      cache: cache,
      budget: RequestBudget(clock),
      breaker: OffCircuitBreaker(clock: clock, logger: logger, health: health),
      logger: logger,
      offSource: Future.value(
        offEnabled
            ? OpenFoodFactsSource(
                client: client,
                config: const CatalogConfig(
                  appVersion: '1.0.0',
                  offContact: 'team.example',
                ),
                timerFactory: timers.call,
              )
            : null,
      ),
    );
  }

  late _Server server;
  final InMemoryCacheFile file;
  final requests = <http.Request>[];
  final clock = FakeClock();
  final timers = FakeTimers();
  final logger = RecordingLogger();
  final health = CatalogHealth();
  late final CatalogCacheStore cache;
  late final CatalogCoordinator coordinator;

  Future<void> start() => coordinator.startSession(_owner);
}

Matcher _throwsCode(CatalogErrorCode code) =>
    throwsA(isA<CatalogArgumentError>().having((e) => e.code, 'code', code));

void main() {
  group('BR1.1 suggestWines', () {
    test(
      'BR1.1 internal suggestions arrive at once, without any request',
      () async {
        final h = _Harness();
        await h.start();
        final result = h.coordinator.suggestWines(
          'Barolo 2016',
          cellarWines: const [CellarWineRef(name: 'Barolo di casa')],
        );
        expect(result.externalIncluded, isFalse);
        expect(result.suggestions.first.source, CandidateSource.cellar);
        expect(result.suggestions[1].name, 'Barolo DOCG');
        expect(result.suggestions[1].vintage, 2016);
        expect(h.requests, isEmpty);
      },
    );

    test('BR1.1 queries outside 2 to 120 characters are rejected', () {
      final h = _Harness();
      expect(
        () => h.coordinator.suggestWines('b'),
        _throwsCode(CatalogErrorCode.queryTooShort),
      );
      expect(
        () => h.coordinator.suggestWines(" ' . "),
        _throwsCode(CatalogErrorCode.queryTooShort),
      );
      expect(
        () => h.coordinator.suggestWines('a' * 121),
        _throwsCode(CatalogErrorCode.queryTooLong),
      );
      expect(h.coordinator.suggestWines('ba').suggestions, isNotEmpty);
      expect(h.coordinator.suggestWines('a' * 120).suggestions, isEmpty);
    });
  });

  group('BR1.2 suggestExternal', () {
    test('BR1.2 Open Food Facts results with their source, then the cache '
        '(NFR1.4)', () async {
      final h = _Harness(server: (_) => _json(fixture('search_wines.json')));
      await h.start();
      final first = await h.coordinator.suggestExternal(
        'Barolo',
        locale: CatalogLocale.it,
      );
      expect(first.externalIncluded, isTrue);
      expect(first.suggestions, hasLength(3));
      expect(
        first.suggestions.every(
          (c) => c.source == CandidateSource.openFoodFacts,
        ),
        isTrue,
        reason: 'BR5.2 attribution needs the source',
      );
      expect(h.requests.single.url.queryParameters['search_terms'], 'barolo');
      expect(h.requests.single.url.queryParameters['lc'], 'it');
      final second = await h.coordinator.suggestExternal('BAROLO!');
      expect(second, first);
      expect(h.requests, hasLength(1), reason: 'served from the cache');
    });

    test('BR1.2 queries shorter than 3 characters never reach Open Food '
        'Facts', () async {
      final h = _Harness();
      await h.start();
      expect(await h.coordinator.suggestExternal('ba'), SuggestResult.empty);
      expect(h.requests, isEmpty);
      expect(
        () => h.coordinator.suggestExternal('x'),
        _throwsCode(CatalogErrorCode.queryTooShort),
      );
    });

    test('BR1.2 nothing found is an empty answer, not an error', () async {
      final h = _Harness(server: (_) => _json(fixture('search_empty.json')));
      await h.start();
      expect(
        await h.coordinator.suggestExternal('vino raro'),
        SuggestResult.empty,
      );
      expect(h.cache.lookup('search:vino raro'), isEmpty);
    });
  });

  group('BR1.3 matchLabelText', () {
    test('BR1.3 denomination and vintage from the text, name and producer '
        'from Open Food Facts', () async {
      final h = _Harness(server: (_) => _json(fixture('search_wines.json')));
      await h.start();
      final match = await h.coordinator.matchLabelText(
        'LANGHE NEBBIOLO\nDenominazione di Origine Controllata\n2019\n'
        'Imbottigliato da Azienda Agricola Prova',
      );
      expect(match.matched, isTrue);
      final wine = match.candidate!;
      expect(wine.name, 'Langhe Nebbiolo');
      expect(wine.producer, 'Azienda Agricola Prova');
      expect(wine.denomination, 'Langhe Nebbiolo DOC');
      expect(wine.wineType, CatalogWineType.red);
      expect(wine.region, 'Piemonte');
      expect(wine.vintage, 2019);
      expect(wine.source, CandidateSource.openFoodFacts);
      // The six longest words of 3+ letters, no digits, in text order.
      expect(
        h.requests.single.url.queryParameters['search_terms'],
        'nebbiolo denominazione origine controllata imbottigliato agricola',
      );
    });

    test('BR1.3 without a denomination the first result is chosen', () async {
      final h = _Harness(server: (_) => _json(fixture('search_wines.json')));
      await h.start();
      final match = await h.coordinator.matchLabelText('Cannubi Esempio');
      expect(match.candidate?.name, 'Barolo Cannubi 2016');
      expect(match.candidate?.denomination, 'Barolo DOCG');
    });

    test(
      'BR1.3 with no matching result the denomination alone is proposed',
      () async {
        final h = _Harness(server: (_) => _json(fixture('search_wines.json')));
        await h.start();
        final match = await h.coordinator.matchLabelText('Soave Classico 2021');
        expect(
          match.candidate,
          const WineCandidate(
            name: 'Soave DOC',
            source: CandidateSource.internal,
            vintage: 2021,
            wineType: CatalogWineType.white,
            region: 'Veneto',
            denomination: 'Soave DOC',
          ),
        );
      },
    );

    test('BR1.3 nothing recognised gives matched = false; too long text is '
        'rejected', () async {
      final h = _Harness();
      await h.start();
      expect(await h.coordinator.matchLabelText(''), const LabelMatch.none());
      expect(
        await h.coordinator.matchLabelText('12 34 ab'),
        const LabelMatch.none(),
      );
      expect(h.requests, isEmpty, reason: 'no word worth a search');
      expect(
        await h.coordinator.matchLabelText('Vino rosso da tavola'),
        const LabelMatch.none(),
      );
      expect(
        () => h.coordinator.matchLabelText('a' * 2001),
        _throwsCode(CatalogErrorCode.textTooLong),
      );
      expect(labelSearchWords(['abc', 'abcd', 'a1b2c', 'xyz']), [
        'abc',
        'abcd',
        'xyz',
      ]);
    });
  });

  group('BR1.5 lookupBarcode', () {
    test('BR1.5 a 12-digit code is read as 13 digits and cached', () async {
      final h = _Harness(server: (_) => _json(fixture('product_wine.json')));
      await h.start();
      final wine = await h.coordinator.lookupBarcode('801234567890');
      expect(wine?.name, "Barbera d'Asti Superiore");
      expect(h.requests.single.url.path, '/api/v2/product/0801234567890.json');
      expect(await h.coordinator.lookupBarcode('0801234567890'), wine);
      expect(h.requests, hasLength(1));
    });

    test('BR1.5 not a wine, not found or unavailable gives null', () async {
      for (final response in [
        _json(fixture('product_not_wine.json')),
        _json(fixture('product_not_found.json')),
        _json('{}', 404),
        _json('', 503),
      ]) {
        final h = _Harness(server: (_) => response);
        await h.start();
        expect(await h.coordinator.lookupBarcode('80012345'), isNull);
      }
    });

    test('BR1.5 other characters or lengths are invalidBarcode', () {
      final h = _Harness();
      for (final code in [
        '',
        '1234567',
        '80012345678901',
        '8001234567x9',
        ' 80012345',
      ]) {
        expect(
          () => h.coordinator.lookupBarcode(code),
          _throwsCode(CatalogErrorCode.invalidBarcode),
          reason: code,
        );
      }
    });
  });

  group('BR2.1 cache', () {
    test('BR2.1 successes are kept and saved, failures are not', () async {
      var status = 503;
      final h = _Harness(
        server: (_) => status == 200
            ? _json(fixture('search_wines.json'))
            : _json('', status),
      );
      await h.start();
      expect(
        await h.coordinator.suggestExternal('barolo'),
        SuggestResult.empty,
      );
      expect(h.cache.entryCount, 0);
      status = 200;
      await h.coordinator.suggestExternal('barolo');
      expect(h.cache.entryCount, 1);
      h.timers.fireAll(CatalogCacheStore.saveDelay);
      await h.cache.flush();
      expect(h.file.contents, contains('search:barolo'));
      expect(h.file.contents, isNot(contains('cellar')));
    });

    test('BR2.1 clear() deletes cache, hints and file', () async {
      final h = _Harness(server: (_) => _json(fixture('search_wines.json')));
      await h.start();
      await h.coordinator.suggestExternal('barolo');
      await h.cache.flush();
      await h.coordinator.clear();
      expect(h.cache.entryCount, 0);
      expect(h.cache.hintCount, 0);
      expect(h.file.contents, isNull);
      expect(h.file.temp, isNull);
      h.coordinator.dispose();
    });
  });

  group('BR2.2 Open Food Facts never blocks', () {
    test(
      'BR2.2 three 503 suspend it for 5 minutes, then a request starts',
      () async {
        final h = _Harness(server: (_) => _json('', 503));
        await h.start();
        for (final query in ['aaa', 'bbb', 'ccc']) {
          expect(
            await h.coordinator.suggestExternal(query),
            SuggestResult.empty,
          );
        }
        expect(
          h.requests,
          hasLength(3),
          reason: 'one request per call (NFR6.3)',
        );
        expect(h.logger.suspensions.single.$1.label, 'http_503');
        await h.coordinator.suggestExternal('ddd');
        expect(h.requests, hasLength(3), reason: 'suspended');
        expect(
          h.logger.debugEvents,
          contains(CatalogDebugEvent.offSkippedSuspended),
        );
        h.clock.advance(const Duration(minutes: 5));
        await h.coordinator.suggestExternal('eee');
        expect(h.requests, hasLength(4));
      },
    );

    test('BR2.2 three barcodes not found (404) do not suspend it', () async {
      final h = _Harness(server: (_) => _json('{}', 404));
      await h.start();
      for (final code in ['80000001', '80000002', '80000003', '80000004']) {
        expect(await h.coordinator.lookupBarcode(code), isNull);
      }
      expect(h.requests, hasLength(4));
      expect(h.logger.suspensions, isEmpty);
    });

    test('NFR6.1 without network every operation still answers', () async {
      final h = _Harness(
        server: (_) => throw http.ClientException('no network'),
      );
      await h.start();
      expect(h.coordinator.suggestWines('soave').suggestions, isNotEmpty);
      expect(await h.coordinator.suggestExternal('soave'), SuggestResult.empty);
      final label = await h.coordinator.matchLabelText('Soave 2020');
      expect(label.candidate?.denomination, 'Soave DOC');
      expect(await h.coordinator.lookupBarcode('80012345'), isNull);
      final profile = await h.coordinator.getWineProfile('Soave');
      expect(profile.region, 'Veneto');
      expect(h.logger.suspensions.single.$1.label, 'network');
    });

    test(
      'NFR1.3 a server slower than 5 s gives internal results only',
      () async {
        final never = Completer<http.Response>();
        final h = _Harness(server: (_) => never.future);
        await h.start();
        final pending = h.coordinator.matchLabelText('Barolo Riserva 2015');
        await settle();
        expect(h.requests, hasLength(1));
        final deadline = h.timers.active.single;
        expect(deadline.duration, const Duration(seconds: 5));
        deadline.fire();
        final match = await pending;
        expect(match.candidate?.source, CandidateSource.internal);
        expect(match.candidate?.name, 'Barolo DOCG');
      },
    );
  });

  group('BR2.3 request budget', () {
    test('BR2.3 the ninth search within 60 s is skipped, cache answers do '
        'not count', () async {
      final h = _Harness();
      await h.start();
      for (var i = 0; i < 8; i++) {
        await h.coordinator.suggestExternal('vino$i');
      }
      // Cached: no budget used.
      await h.coordinator.suggestExternal('vino0');
      expect(h.requests, hasLength(8));
      await h.coordinator.suggestExternal('vino8');
      expect(h.requests, hasLength(8));
      expect(
        h.logger.debugEvents,
        contains(CatalogDebugEvent.offSkippedBudget),
      );
      h.clock.advance(const Duration(seconds: 60));
      await h.coordinator.suggestExternal('vino8');
      expect(h.requests, hasLength(9));
    });
  });

  group('BR3.1 getWineProfile', () {
    test('BR3.1 never found, no window, no pairings, no request', () async {
      final h = _Harness();
      await h.start();
      final profile = await h.coordinator.getWineProfile(
        "Barbera d'Asti Superiore",
        producer: 'Cantina',
        vintage: 2019,
      );
      expect(profile.found, isFalse);
      expect(profile.window, isNull);
      expect(profile.pairings, isEmpty);
      expect(profile.wineType, CatalogWineType.red);
      expect(profile.region, 'Piemonte');
      expect(profile.denomination, "Barbera d'Asti DOCG");
      expect(h.requests, isEmpty);
      final unknown = await h.coordinator.getWineProfile('Vino della casa');
      expect(unknown, const WineProfileResult(found: false));
    });

    test('BR3.1 a hint learnt from Open Food Facts wins', () async {
      final h = _Harness(server: (_) => _json(fixture('search_wines.json')));
      await h.start();
      await h.coordinator.suggestExternal('champagne');
      final profile = await h.coordinator.getWineProfile('Champagne Brut');
      expect(profile.wineType, CatalogWineType.sparkling);
      expect(profile.region, 'France');
      expect(profile.found, isFalse);
      expect(h.requests, hasLength(1));
    });
  });

  group('BR5.1 no personal data and Open Food Facts off without contact', () {
    test('BR5.1 without a contact no request is ever made (NFR4.3)', () async {
      final h = _Harness(offEnabled: false);
      await h.start();
      expect(
        await h.coordinator.suggestExternal('barolo'),
        SuggestResult.empty,
      );
      expect(await h.coordinator.lookupBarcode('80012345'), isNull);
      expect(
        (await h.coordinator.matchLabelText('Barolo 2016')).candidate?.source,
        CandidateSource.internal,
      );
      expect(h.requests, isEmpty);
      expect(h.logger.debugEvents, contains(CatalogDebugEvent.offDisabled));
      expect(const CatalogConfig(appVersion: '1').offEnabled, isFalse);
      expect(
        const CatalogConfig(appVersion: '1', offContact: '  ').offEnabled,
        isFalse,
      );
    });

    test('BR5.1 cellar wines never reach a request (NFR4.2)', () async {
      final h = _Harness();
      await h.start();
      final cellar = [
        const CellarWineRef(name: 'Barolo ${_marker}name', producer: _marker),
      ];
      h.coordinator.suggestWines('barolo', cellarWines: cellar);
      await h.coordinator.suggestExternal('barolo');
      for (final request in h.requests) {
        expect(request.url.toString(), isNot(contains(_marker)));
        expect(request.headers.values.join(), isNot(contains(_marker)));
        expect(request.body, isEmpty);
      }
    });

    test('NFR8.3 no user text reaches the logger or an error', () async {
      final h = _Harness(server: (_) => _json('', 503));
      await h.start();
      await h.coordinator.suggestExternal('barolo $_marker');
      await h.coordinator.matchLabelText('Barolo $_marker 2016');
      await h.coordinator.suggestExternal('$_marker barolo');
      final errors = <String>[];
      for (final call in <Future<Object?> Function()>[
        () async => h.coordinator.suggestWines('${_marker * 20}x'),
        () => h.coordinator.lookupBarcode('${_marker}1'),
        () => h.coordinator.matchLabelText(_marker * 200),
      ]) {
        try {
          await call();
        } on CatalogArgumentError catch (error) {
          errors.add('$error ${error.message}');
        }
      }
      expect(errors, hasLength(3));
      expect(h.logger.suspensions, hasLength(1));
      expect(h.logger.everything, isNot(contains(_marker)));
      expect(errors.join(), isNot(contains(_marker)));
    });
  });

  group('session and change of user (NFR8.1)', () {
    test('an answer arriving after a change of user is dropped', () async {
      final slow = Completer<http.Response>();
      final h = _Harness(server: (_) => slow.future);
      await h.start();
      final pending = h.coordinator.suggestExternal('barolo');
      await settle();
      await h.coordinator.startSession('owner-hash-b');
      slow.complete(_json(fixture('search_wines.json')));
      expect(await pending, SuggestResult.empty);
      expect(h.cache.entryCount, 0);
      expect(
        h.logger.debugEvents,
        contains(CatalogDebugEvent.offResponseDiscarded),
      );
    });

    test(
      'the same user keeps the cache; another user clears the file',
      () async {
        final h = _Harness(server: (_) => _json(fixture('search_wines.json')));
        await h.start();
        await h.coordinator.suggestExternal('barolo');
        await h.cache.flush();
        await h.coordinator.startSession(_owner);
        expect(h.cache.entryCount, 1);
        await h.coordinator.startSession(null);
        expect(h.cache.entryCount, 0);
        expect(h.file.contents, isNull);
        // Signed out: nothing is saved any more.
        await h.coordinator.suggestExternal('soave');
        await h.cache.flush();
        expect(h.file.contents, isNull);
      },
    );

    test(
      'a cache file of the previous user is never served to a new one',
      () async {
        final first = _Harness(
          server: (_) => _json(fixture('search_wines.json')),
        );
        await first.start();
        await first.coordinator.suggestExternal('barolo');
        await first.cache.flush();

        final next = _Harness(file: first.file, offEnabled: false);
        await next.coordinator.startSession('owner-hash-b');
        expect(
          await next.coordinator.suggestExternal('barolo'),
          SuggestResult.empty,
        );
        expect(first.file.contents, isNull);
      },
    );
  });
}
