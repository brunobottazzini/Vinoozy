// Read-only extension of the U1 Wine mapper for the Dashboard
// (u5-dashboard logical-components.md, security-design.md §4; NFR4.1,
// NFR6.1): the new C3 fields are read, a malformed window is "to estimate",
// and the mapper never throws.
import 'package:estimation/estimation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/cellar/domain/drinking_record.dart';
import 'package:vinoozy/cellar/domain/wine.dart';

void main() {
  Map<String, Object?> validWindow() => {
    WindowFields.startYear: 2024,
    WindowFields.peakYear: 2028,
    WindowFields.endYear: 2034,
    WindowFields.confidence: 'high',
    WindowFields.source: 'catalog',
    WindowFields.basis: 'denomination',
    WindowFields.qualifier: 'riserva',
  };

  Map<String, Object?> document({Object? window}) => {
    WineFields.name: 'Barolo',
    WineFields.producer: 'Cantina Esempio',
    WineFields.vintage: 2016,
    WineFields.wineType: 'redStructured',
    WineFields.region: 'Piemonte',
    WineFields.denomination: 'Barolo DOCG',
    WineFields.quantity: 3,
    WineFields.window: window,
  };

  group('Wine.fromMap, Dashboard fields', () {
    test('reads producer, type, region, denomination and window', () {
      final wine = Wine.fromMap('w1', document(window: validWindow()));

      expect(wine.producer, 'Cantina Esempio');
      expect(wine.wineType, 'redStructured');
      expect(wine.region, 'Piemonte');
      expect(wine.denomination, 'Barolo DOCG');
      expect(
        wine.window,
        const DrinkingWindow(
          startYear: 2024,
          peakYear: 2028,
          endYear: 2034,
          confidence: Confidence.high,
          source: WindowSource.catalog,
          basis: EstimationBasis.denomination,
          qualifier: Qualifier.riserva,
        ),
      );
    });

    test('a U1 document without the new fields reads them as null', () {
      final wine = Wine.fromMap('w1', {WineFields.name: 'Barolo'});

      expect(wine.producer, isNull);
      expect(wine.wineType, isNull);
      expect(wine.region, isNull);
      expect(wine.denomination, isNull);
      expect(wine.window, isNull);
    });

    test('texts of the wrong type are null, not an exception', () {
      final wine = Wine.fromMap('w1', {
        WineFields.producer: 12,
        WineFields.wineType: true,
        WineFields.region: ['Piemonte'],
        WineFields.denomination: {'name': 'Barolo'},
      });

      expect(wine.producer, isNull);
      expect(wine.wineType, isNull);
      expect(wine.region, isNull);
      expect(wine.denomination, isNull);
    });
  });

  group('window mapper (never throws)', () {
    test('absent window: to estimate', () {
      expect(Wine.fromMap('w1', document()).window, isNull);
    });

    test('a window that is not a map: to estimate', () {
      expect(Wine.fromMap('w1', document(window: '2024-2034')).window, isNull);
      expect(Wine.fromMap('w1', document(window: [2024, 2034])).window, isNull);
    });

    test('incomplete window: to estimate', () {
      for (final missing in [
        WindowFields.startYear,
        WindowFields.peakYear,
        WindowFields.endYear,
      ]) {
        final raw = validWindow()..remove(missing);
        expect(
          Wine.fromMap('w1', document(window: raw)).window,
          isNull,
          reason: 'without $missing',
        );
      }
    });

    test('years of the wrong type: to estimate', () {
      expect(
        Wine.windowFrom(validWindow()..[WindowFields.startYear] = '2024'),
        isNull,
      );
      expect(
        Wine.windowFrom(validWindow()..[WindowFields.peakYear] = 2028.5),
        isNull,
      );
      expect(
        Wine.windowFrom(validWindow()..[WindowFields.endYear] = null),
        isNull,
      );
    });

    test('integral doubles are accepted as years, like other C3 integers', () {
      final window = Wine.windowFrom(
        validWindow()..[WindowFields.endYear] = 2034.0,
      );

      expect(window?.endYear, 2034);
    });

    test(
      'unknown confidence and source fall back to low and internalRules',
      () {
        final window = Wine.windowFrom(
          validWindow()
            ..[WindowFields.confidence] = 'certain'
            ..[WindowFields.source] = 7
            ..remove(WindowFields.basis),
        );

        expect(window!.confidence, Confidence.low);
        expect(window.source, WindowSource.internalRules);
        expect(
          window.basis,
          EstimationBasis.wineType,
          reason: 'resolved basis',
        );
      },
    );

    test('missing basis is resolved from the source (catalog)', () {
      final window = Wine.windowFrom(validWindow()..remove(WindowFields.basis));

      expect(window!.basis, EstimationBasis.catalog);
    });

    test('unknown basis and qualifier are not exceptions', () {
      // label-autofill-windows made grandCru a known qualifier (ENT-002).
      final window = Wine.windowFrom(
        validWindow()
          ..[WindowFields.basis] = 'guess'
          ..[WindowFields.qualifier] = 'premierGrandCruClasse',
      );

      expect(window!.basis, EstimationBasis.catalog);
      expect(window.qualifier, isNull);
    });

    test('years out of order are kept: statusOf decides (BR1.2)', () {
      final window = Wine.windowFrom(
        validWindow()..[WindowFields.startYear] = 2040,
      );

      expect(window!.startYear, 2040);
      expect(
        () => statusOf(window, DateTime(2026, 11, 6)),
        throwsA(isA<EstimationArgumentError>()),
      );
    });

    test('a map with keys of another type is read without errors', () {
      final raw = <Object?, Object?>{
        1: 'x',
        WindowFields.startYear: 2024,
        WindowFields.peakYear: 2025,
        WindowFields.endYear: 2026,
      };

      expect(Wine.windowFrom(raw)?.peakYear, 2025);
    });
  });

  group('u4-cellar fields (BR1.4, BR1.5, BR1.12)', () {
    test('BR1.12 reads matchKey, baseWindow, windowAdjustment, pairings', () {
      final wine = Wine.fromMap('w1', {
        ...document(window: validWindow()),
        WineFields.matchKey: 'barolo|cantina esempio|2016',
        WineFields.baseWindow: validWindow(),
        WineFields.windowAdjustment: {
          'kind': 'tooYoung',
          'year': 2026,
          'recordId': 'r1',
        },
        WineFields.pairings: {
          'items': ['Brasato', 3],
          'categoryKeys': ['game', 'unknown'],
          'source': 'internalRules',
        },
      });

      expect(wine.matchKey, 'barolo|cantina esempio|2016');
      expect(wine.baseWindow, wine.window);
      expect(wine.windowAdjustment!.kind, DrinkCondition.tooYoung);
      expect(wine.windowAdjustment!.recordId, 'r1');
      expect(wine.pairings!.items, ['Brasato']);
      expect(wine.pairings!.categoryKeys, [PairingCategory.game]);
      expect(wine.pairings!.source, WindowSource.internalRules);
    });

    test('malformed new fields are null, never thrown', () {
      final wine = Wine.fromMap('w1', {
        WineFields.name: 'Barolo',
        WineFields.matchKey: 42,
        WineFields.baseWindow: 'x',
        WineFields.windowAdjustment: {'kind': 'tooYoung'},
        WineFields.pairings: {'items': [], 'source': 'oracle'},
      });

      expect(wine.matchKey, isNull);
      expect(wine.baseWindow, isNull);
      expect(wine.windowAdjustment, isNull);
      expect(wine.pairings, isNull);
    });

    test('BR1.5 window and pairings round trip through the stored form', () {
      final window = Wine.windowFrom(validWindow())!;
      const pairings = Pairings(
        items: [],
        categoryKeys: [PairingCategory.agedCheese],
        source: WindowSource.internalRules,
      );

      expect(Wine.windowFrom(Wine.windowToMap(window)), window);
      expect(Wine.pairingsFrom(Wine.pairingsToMap(pairings)), pairings);
      final plain = Wine.windowToMap(
        const DrinkingWindow(
          startYear: 2024,
          peakYear: 2026,
          endYear: 2030,
          confidence: Confidence.low,
          source: WindowSource.internalRules,
          basis: EstimationBasis.wineType,
        ),
      );
      expect(plain.containsKey(WindowFields.qualifier), isFalse);
    });

    test('BR1.20 the oldest entry comes first, a pending one last', () {
      Wine at(String id, DateTime? created) => Wine(
        id: id,
        name: 'B',
        vintage: null,
        storedQuantity: 1,
        createdAt: created,
      );
      final wines = [
        at('c', null),
        at('b', DateTime.utc(2026, 2)),
        at('a', DateTime.utc(2026, 1)),
        at('d', DateTime.utc(2026, 1)),
      ]..sort(Wine.compareByAge);

      expect(wines.map((w) => w.id), ['a', 'd', 'b', 'c']);
    });
  });
}
