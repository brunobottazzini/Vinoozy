// The services replaced in the label end-to-end test (label-recognition
// NFR4.3, NFR4.4): a catalog whose Open Food Facts is a MockClient and whose
// network the test switches, and a Google Lens channel that records instead
// of opening the Google app. The offline wine database is the e2e one of
// support/e2e_wine_db.dart (rows of tool/fixtures/off_wines_sample.csv),
// never the shipped asset, whose content changes at every release; ML Kit
// and the native preparer are the real ones.
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:vinoozy/catalog/core/catalog_cache_store.dart';
import 'package:vinoozy/catalog/core/catalog_config.dart';
import 'package:vinoozy/catalog/core/catalog_coordinator.dart';
import 'package:vinoozy/catalog/core/catalog_event_logger.dart';
import 'package:vinoozy/catalog/core/internal_catalog.dart';
import 'package:vinoozy/catalog/core/network_status.dart';
import 'package:vinoozy/catalog/core/off/open_food_facts_source.dart';
import 'package:vinoozy/catalog/core/off_circuit_breaker.dart';
import 'package:vinoozy/catalog/core/request_budget.dart';
import 'package:vinoozy/catalog/platform/wine_db_loader.dart';
import 'package:vinoozy/core/clock.dart';
import 'package:vinoozy/label/core/lens_launcher.dart';

import 'e2e_wine_db.dart';

const _logger = ConsoleCatalogEventLogger(debugLogging: false);

/// The offline database of every e2e catalog, opened once per run like the
/// app's one. The label screens read it too (offline attribution), so the
/// tests override `wineDbLoaderProvider` with this same loader.
final WineDbLoader e2eWineDb = e2eWineDbLoader(_logger);

/// The network as the catalog sees it, switched by the test.
class SwitchableNetwork implements CatalogNetworkStatus {
  bool online = true;

  @override
  Future<bool> hasNetwork() async => online;
}

/// The cache file kept in memory: nothing is written on the phone.
class MemoryCacheFile implements CacheFile {
  String? _contents;
  String? _temp;

  @override
  Future<String?> read() async => _contents;

  @override
  Future<void> writeTemp(String contents) async => _temp = contents;

  @override
  Future<void> commitTemp() async {
    _contents = _temp;
    _temp = null;
  }

  @override
  Future<void> deleteTemp() async => _temp = null;

  @override
  Future<void> deleteAll() async {
    _contents = null;
    _temp = null;
  }
}

/// Every request that would have gone to Open Food Facts; the answer is an
/// empty search or "product not found". Never the real service.
final List<Uri> offRequests = [];

final http.Client fakeOffClient = MockClient((request) async {
  offRequests.add(request.url);
  final body = request.url.path.startsWith('/api/')
      ? '{"status": 0}'
      : '{"count": 0, "products": []}';
  return http.Response.bytes(utf8.encode(body), 200);
});

/// The coordinator of the app with the fake Open Food Facts, the
/// switchable network and the e2e offline database.
CatalogCoordinator e2eCatalog(SwitchableNetwork network) {
  const logger = _logger;
  const clock = SystemClock();
  final health = CatalogHealth();
  return CatalogCoordinator(
    internal: InternalCatalog.build(),
    cache: CatalogCacheStore(
      file: MemoryCacheFile(),
      clock: clock,
      health: health,
      logger: logger,
    ),
    budget: RequestBudget(clock),
    breaker: OffCircuitBreaker(clock: clock, logger: logger, health: health),
    logger: logger,
    offSource: Future.value(
      OpenFoodFactsSource(
        client: fakeOffClient,
        config: const CatalogConfig(
          appVersion: 'e2e',
          offContact: 'e2e.invalid',
        ),
      ),
    ),
    wineDb: e2eWineDb.openDb,
    network: network,
  );
}

/// The `vinoozy/lens` launcher of the test: it records the path and
/// answers "direct" without opening anything.
class RecordingLensLauncher implements LensLauncher {
  final List<String> paths = [];

  @override
  Future<LensRoute> open(String path) async {
    paths.add(path);
    return LensRoute.direct;
  }
}
