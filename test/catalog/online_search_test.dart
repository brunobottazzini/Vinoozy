// "Cerca online" in the catalog (label-recognition FR3.2, FR3.4, BR4.2,
// BR4.3, NFR3.8, NFR4.9, NFR5.5): offline and online results merged, the
// existing budget and breaker, no network, timeout, 429 and 500 giving
// offline results only. MockClient instead of Open Food Facts.
import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:vinoozy/catalog/core/catalog_cache_store.dart';
import 'package:vinoozy/catalog/core/catalog_config.dart';
import 'package:vinoozy/catalog/core/catalog_coordinator.dart';
import 'package:vinoozy/catalog/core/internal_catalog.dart';
import 'package:vinoozy/catalog/core/network_status.dart';
import 'package:vinoozy/catalog/core/off/open_food_facts_source.dart';
import 'package:vinoozy/catalog/core/off_circuit_breaker.dart';
import 'package:vinoozy/catalog/core/offline/wine_db_index.dart';
import 'package:vinoozy/catalog/core/offline/wine_db_record.dart';
import 'package:vinoozy/catalog/core/request_budget.dart';
import 'package:vinoozy/catalog/core/wine_catalog.dart';

import 'catalog_test_helpers.dart';

const _cannubi = WineDbRecord(
  code: '8001234567890',
  name: 'Barolo Cannubi 2016',
  producer: 'Cantina Esempio',
);
const _ravera = WineDbRecord(
  code: '8001234567897',
  name: 'Barolo Ravera',
  producer: 'Elvio Cogno',
);

class _Network implements CatalogNetworkStatus {
  bool online = true;

  @override
  Future<bool> hasNetwork() async => online;
}

class _Search {
  _Search({
    FutureOr<http.Response> Function(http.Request)? server,
    bool offEnabled = true,
    bool withDb = true,
  }) {
    final client = MockClient((request) async {
      requests.add(request);
      return (server ?? (_) => _ok('search_wines.json'))(request);
    });
    final health = CatalogHealth();
    coordinator = CatalogCoordinator(
      internal: InternalCatalog.build(),
      cache: CatalogCacheStore(
        file: InMemoryCacheFile(),
        clock: clock,
        health: health,
        logger: logger,
        timerFactory: timers.call,
      ),
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
      wineDb: () async => withDb
          ? OfflineWineDb(
              manifest: WineDbManifest(
                exportDate: DateTime.utc(2026, 11, 7),
                wineCount: 2,
              ),
              index: WineDbIndex.build(const [_cannubi, _ravera]),
            )
          : null,
      network: network,
    );
  }

  final requests = <http.Request>[];
  final clock = FakeClock();
  final timers = FakeTimers();
  final logger = RecordingLogger();
  final network = _Network();
  late final CatalogCoordinator coordinator;

  Future<OnlineSearchResult> search(String query) async {
    await coordinator.startSession('owner');
    return coordinator.searchOnline(query, locale: CatalogLocale.it);
  }
}

http.Response _ok(String name) =>
    http.Response.bytes(utf8.encode(fixture(name)), 200);

void main() {
  test('BR4.2 offline results first, then online ones, without duplicates '
      '(BR3.3)', () async {
    final h = _Search();
    final result = await h.search('Barolo');
    expect(result.status, OnlineSearchStatus.ok);
    expect(result.candidates.first.source, CandidateSource.offline);
    final cannubi = result.candidates.where(
      (c) => c.barcode == '8001234567890',
    );
    expect(cannubi.single.source, CandidateSource.offline);
    expect(
      result.candidates.map((c) => c.source),
      contains(CandidateSource.openFoodFacts),
    );
    expect(result.candidates.length, lessThanOrEqualTo(10));
    expect(h.logger.onlineSearches.single, (2, 3, false));
  });

  test(
    'NFR3.8 only the query text goes to Open Food Facts, wines only',
    () async {
      final h = _Search();
      await h.search('Château Musar 2015');
      final params = h.requests.single.url.queryParameters;
      expect(params['search_terms'], 'chateau musar 2015');
      expect(params['tag_0'], 'wines');
      expect(params['page_size'], '10');
      expect(h.requests.single.headers, hasLength(1));
      expect(h.requests.single.body, isEmpty);
    },
  );

  test(
    'FR3.2 a barcode query looks the barcode up offline and online',
    () async {
      final h = _Search(server: (_) => _ok('product_wine.json'));
      final result = await h.search(' 8001234567897 ');
      expect(result.candidates.first.name, 'Barolo Ravera');
      expect(h.requests.single.url.path, '/api/v2/product/8001234567897.json');
    },
  );

  test('BR4.3 NFR5.5 the existing budget: the ninth search in a minute is '
      'rateLimited with the offline results', () async {
    final h = _Search();
    for (var i = 0; i < 8; i++) {
      expect((await h.search('vino$i')).status, OnlineSearchStatus.ok);
    }
    final ninth = await h.search('barolo');
    expect(ninth.status, OnlineSearchStatus.rateLimited);
    expect(
      ninth.candidates.every((c) => c.source == CandidateSource.offline),
      isTrue,
    );
    expect(ninth.candidates, isNotEmpty);
    expect(h.requests, hasLength(8));
    expect(h.logger.onlineSearches.last.$3, isTrue);
  });

  test('FR3.4 without network: offline only, no request', () async {
    final h = _Search()..network.online = false;
    final result = await h.search('barolo');
    expect(result.status, OnlineSearchStatus.offline);
    expect(result.candidates, hasLength(2));
    expect(h.requests, isEmpty);
  });

  test('NFR4.9 timeout, 429 and 500 give the offline results only', () async {
    for (final status in [429, 500]) {
      final h = _Search(server: (_) => http.Response('', status));
      final result = await h.search('barolo');
      expect(result.status, OnlineSearchStatus.rateLimited, reason: '$status');
      expect(result.candidates, hasLength(2));
    }
    final never = Completer<http.Response>();
    final h = _Search(server: (_) => never.future);
    final pending = h.search('barolo');
    await settle();
    await settle();
    h.timers.active.single.fire();
    final result = await pending;
    expect(result.status, OnlineSearchStatus.rateLimited);
    expect(result.candidates, hasLength(2));
  });

  test(
    'BR4.3 Open Food Facts off in the build is "unavailable", not '
    '"rateLimited" (review R-03): offline results only, no request',
    () async {
      final off = _Search(offEnabled: false);
      final result = await off.search('barolo');
      expect(result.status, OnlineSearchStatus.unavailable);
      expect(result.candidates, hasLength(2));
      expect(
        result.candidates.every((c) => c.source == CandidateSource.offline),
        isTrue,
      );
      expect(off.requests, isEmpty);
      // NFR4.13: still logged as Open Food Facts not asked.
      expect(off.logger.onlineSearches.last.$3, isTrue);
      // A barcode, too.
      expect(
        (await off.search('8001234567897')).status,
        OnlineSearchStatus.unavailable,
      );
    },
  );

  test('BR4.3 without a database only online results', () async {
    final noDb = _Search(withDb: false);
    final result = await noDb.search('barolo');
    expect(
      result.candidates.every((c) => c.source != CandidateSource.offline),
      isTrue,
    );
  });

  test('BR4.2 an empty or too long query is refused', () async {
    final h = _Search();
    await h.coordinator.startSession('owner');
    expect(
      () => h.coordinator.searchOnline('   '),
      throwsA(isA<CatalogArgumentError>()),
    );
    expect(
      () => h.coordinator.searchOnline('a' * 121),
      throwsA(isA<CatalogArgumentError>()),
    );
    expect((await h.search('ab')).status, OnlineSearchStatus.ok);
    expect(h.requests, isEmpty, reason: 'too short for Open Food Facts');
  });
}
