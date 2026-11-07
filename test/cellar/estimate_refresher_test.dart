// EstimateRefresher (BR1.5, BR1.6, BR1.19; NFR5.4, NFR6.4): at most 20 wines
// per network return, one at a time, only with canEdit, an error on one wine
// does not stop the others.
import 'package:estimation/estimation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/catalog/core/wine_catalog.dart';
import 'package:vinoozy/cellar/data/wine_repository.dart';
import 'package:vinoozy/cellar/domain/wine.dart';
import 'package:vinoozy/cellar/domain/wine_estimate.dart';
import 'package:vinoozy/cellar/estimate_refresher.dart';

import '../helpers/fakes.dart';
import '../helpers/service_mocks.dart';
import 'cellar_harness.dart';

void main() {
  setUpAll(registerCellarFallbacks);

  late MockWineRepository wines;
  late FakeWineCatalog catalog;
  late FakeCellarNetwork network;
  late RecordingErrorSink sink;
  late EstimateRefresher refresher;
  late List<(Wine, WineEstimate)> written;

  setUp(() {
    wines = MockWineRepository();
    catalog = FakeWineCatalog();
    network = FakeCellarNetwork();
    sink = RecordingErrorSink();
    written = [];
    when(
      () => wines.setEstimate(
        cellarId: any(named: 'cellarId'),
        user: any(named: 'user'),
        wine: any(named: 'wine'),
        estimate: any(named: 'estimate'),
        reason: any(named: 'reason'),
      ),
    ).thenAnswer((invocation) async {
      written.add((
        invocation.namedArguments[#wine] as Wine,
        invocation.namedArguments[#estimate] as WineEstimate,
      ));
      return const SaveAccepted();
    });
    refresher = EstimateRefresher(
      wines: wines,
      catalog: catalog,
      network: network,
      reporter: recordingReporter(sink),
      clock: FakeClock(DateTime(2026, 11, 6)),
    );
  });

  /// A wine estimated by the internal rules, or without estimate.
  Wine internal(String id, {String name = 'Barolo', bool estimated = true}) =>
      cellarWine(
        id,
        name: name,
        wineType: null,
        window: estimated ? windowOf(2018, 2022, 2026) : null,
        baseWindow: estimated ? windowOf(2018, 2022, 2026) : null,
      );

  const catalogWindow = WineProfileResult(
    found: true,
    window: ProfileWindow(startYear: 2022, peakYear: 2026, endYear: 2036),
    confidence: ProfileConfidence.high,
  );

  test('BR1.6 the catalog window replaces the internal one', () async {
    catalog.profile = catalogWindow;

    expect(
      await refresher.refresh(ownerCellar, cellarOwner, [internal('w1')]),
      1,
    );

    final (wine, estimate) = written.single;
    expect(wine.id, 'w1');
    expect(estimate.baseWindow!.source, WindowSource.catalog);
    expect(estimate.window!.startYear, 2022);
  });

  test('NFR5.4 at most 20 wines per network return, one at a time', () async {
    catalog.profile = catalogWindow;
    final cellar = [
      for (var i = 0; i < 25; i++) internal('w$i', name: 'Vino $i'),
    ];

    expect(await refresher.refresh(ownerCellar, cellarOwner, cellar), 20);
    expect(catalog.profileNames, hasLength(20));

    // The next return goes on with the remaining 5 (each wine once).
    expect(await refresher.refresh(ownerCellar, cellarOwner, cellar), 5);
  });

  test('BR1.19 no write and no catalog call without canEdit', () async {
    catalog.profile = catalogWindow;

    expect(
      await refresher.refresh(readCellar, cellarEditor, [internal('w1')]),
      0,
    );
    expect(
      await refresher.refreshWine(readCellar, cellarEditor, internal('w2')),
      isFalse,
    );
    expect(catalog.profileNames, isEmpty);
    expect(written, isEmpty);
  });

  test(
    'NFR6.4 an error on one wine does not stop the others; it is retried',
    () async {
      catalog
        ..profile = catalogWindow
        ..failingNames.add(sensitiveMarkers[0]);
      final cellar = [
        internal('bad', name: sensitiveMarkers[0]),
        internal('ok', name: 'Soave'),
      ];

      expect(await refresher.refresh(ownerCellar, cellarOwner, cellar), 1);
      expect(written.single.$1.id, 'ok');
      expect(sink.reasons, ['estimate_refresh_failed']);
      expect(
        '${sink.recorded.single.error}',
        isNot(contains(sensitiveMarkers[0])),
      );

      catalog.failingNames.clear();
      expect(await refresher.refresh(ownerCellar, cellarOwner, cellar), 1);
      expect(written.last.$1.id, 'bad');
    },
  );

  test('BR1.5 a profile without window fills the facts; same result writes nothing', () async {
    // The type from the catalog changes the internal estimate of a wine
    // without type; the second run has nothing new to write.
    catalog.profile = const WineProfileResult(
      found: true,
      wineType: CatalogWineType.sparkling,
    );
    final wine = cellarWine('w1', name: 'Vino', wineType: null, vintage: 2020);

    expect(await refresher.refreshWine(ownerCellar, cellarOwner, wine), isTrue);
    final estimate = written.single.$2;
    expect(estimate.window, isNotNull);

    final same = cellarWine(
      'w2',
      name: 'Vino',
      wineType: null,
      vintage: 2020,
      window: estimate.window,
      baseWindow: estimate.baseWindow,
      pairings: estimate.pairings,
    );
    expect(
      await refresher.refreshWine(ownerCellar, cellarOwner, same),
      isFalse,
    );
    expect(written, hasLength(1));
  });

  test(
    'BR1.6 offline nothing runs; catalog wines are not candidates',
    () async {
      network.online = false;
      expect(
        await refresher.refresh(ownerCellar, cellarOwner, [internal('w1')]),
        0,
      );
      expect(catalog.profileNames, isEmpty);

      final fromCatalog = cellarWine(
        'w2',
        baseWindow: windowOf(2020, 2024, 2030, source: WindowSource.catalog),
        window: windowOf(2020, 2024, 2030, source: WindowSource.catalog),
      );
      expect(EstimateRefresher.isCandidate(fromCatalog), isFalse);
      expect(
        EstimateRefresher.isCandidate(internal('w3', estimated: false)),
        isTrue,
      );
    },
  );
}
