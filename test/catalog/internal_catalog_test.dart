// InternalCatalog and mergeCandidates (BR1.1, BR1.4, NFR1.5, NFR2.1).
import 'package:estimation/estimation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/catalog/core/internal_catalog.dart';
import 'package:vinoozy/catalog/core/wine_catalog.dart';

List<WineCandidate> _suggest(
  InternalCatalog catalog,
  String query, [
  List<CellarWineRef>? cellar,
]) =>
    catalog.suggest(ParsedQuery(normalizeWineText(query)), cellarWines: cellar);

void main() {
  final catalog = InternalCatalog.build();

  group('build (NFR1.5)', () {
    test('one entry per C2 denomination, with normalised search terms', () {
      expect(catalog.entries, hasLength(denominationCatalog.length));
      final barbera = catalog.entries.firstWhere(
        (e) => e.denominationKey == 'barberaDAsti',
      );
      expect(barbera.displayName, "Barbera d'Asti DOCG");
      expect(barbera.searchTerms, ['barbera d asti docg', 'barbera d asti']);
      expect(barbera.words, containsAll(['barbera', 'd', 'asti', 'docg']));
      expect(barbera.wineType, CatalogWineType.red);
      expect(barbera.region, 'Piemonte');
    });

    test('C2 types map to the five C1 types', () {
      expect(catalogTypeOf(WineType.redLight), CatalogWineType.red);
      expect(catalogTypeOf(WineType.redStructured), CatalogWineType.red);
      expect(catalogTypeOf(WineType.white), CatalogWineType.white);
      expect(catalogTypeOf(WineType.rose), CatalogWineType.rose);
      expect(
        catalogTypeOf(WineType.sparklingClassic),
        CatalogWineType.sparkling,
      );
      expect(catalogTypeOf(WineType.sparklingTank), CatalogWineType.sparkling);
      expect(catalogTypeOf(WineType.sweet), CatalogWineType.sweet);
      expect(catalogTypeOf(WineType.fortified), CatalogWineType.sweet);
    });
  });

  group('BR1.1 suggestions by word prefix', () {
    test('BR1.1 every query word must start a word of the entry', () {
      final names = _suggest(catalog, 'barb as').map((c) => c.name).toList();
      expect(names, ["Barbera d'Asti DOCG"]);
      expect(
        _suggest(catalog, 'nebbiolo alba').single.name,
        'Langhe Nebbiolo DOC',
      );
      expect(_suggest(catalog, 'xyzw'), isEmpty);
    });

    test("BR1.1 name variants find their denomination (Moscato d'Asti)", () {
      final asti = _suggest(catalog, 'moscato');
      expect(asti.single.name, 'Asti DOCG');
      expect(asti.single.denomination, 'Asti DOCG');
      expect(asti.single.source, CandidateSource.internal);
      expect(asti.single.wineType, CatalogWineType.sweet);
    });

    test('BR1.1 a vintage word is not matched and becomes the vintage', () {
      final barolo = _suggest(catalog, 'Barolo 2016');
      expect(barolo.first.name, 'Barolo DOCG');
      expect(barolo.first.vintage, 2016);
      expect(ParsedQuery('barolo 1899 2016 2201').words, [
        'barolo',
        '1899',
        '2201',
      ]);
      expect(ParsedQuery('barolo 1899 2016 2201').vintage, 2016);
      expect(ParsedQuery('2016').words, isEmpty);
      expect(_suggest(catalog, '2016'), isEmpty);
      expect(isVintageWord('20a6'), isFalse);
    });

    test('BR1.1 more whole words first, then alphabetical order', () {
      final names = _suggest(catalog, 'valpolicella').map((c) => c.name);
      // All four share the whole word: alphabetical order decides.
      expect(names.toList(), [
        'Amarone della Valpolicella DOCG',
        'Recioto della Valpolicella DOCG',
        'Valpolicella DOC',
        'Valpolicella Ripasso DOC',
      ]);
      final prefix = _suggest(catalog, 'chianti cl').map((c) => c.name);
      expect(prefix.first, 'Chianti Classico DOCG');
      final ranked = _suggest(catalog, 'vin').map((c) => c.name).toList();
      expect(ranked.first, 'Vin Santo del Chianti DOC');
    });

    test('BR1.1 cellar wines come first, matched on name and producer', () {
      final cellar = [
        const CellarWineRef(name: 'Barolo di Mario', producer: 'Rossi'),
        const CellarWineRef(name: 'Soave', producer: 'Bianchi', vintage: 2020),
        const CellarWineRef(name: 'Rosso della casa'),
      ];
      final result = _suggest(catalog, 'barolo', cellar);
      expect(result.first.source, CandidateSource.cellar);
      expect(result.first.name, 'Barolo di Mario');
      expect(result[1].name, 'Barolo DOCG');
      final byProducer = _suggest(catalog, 'bianchi', cellar);
      expect(byProducer.single.name, 'Soave');
      expect(byProducer.single.vintage, 2020);
      final withVintage = _suggest(catalog, 'rosso 2018', cellar);
      expect(withVintage.first.vintage, 2018);
    });

    test('NFR2.1 only the first 500 cellar wines are searched, and the same '
        'list object is normalised once', () {
      final wines = [
        for (var i = 0; i < 600; i++) CellarWineRef(name: 'Vino numero$i'),
      ];
      expect(
        _suggest(catalog, 'numero499', wines).single.name,
        'Vino numero499',
      );
      expect(_suggest(catalog, 'numero500', wines), isEmpty);
      // A different list is indexed again.
      final other = [const CellarWineRef(name: 'Vino numero500')];
      expect(_suggest(catalog, 'numero500', other), hasLength(1));
      expect(_suggest(catalog, 'numero', const []), isEmpty);
    });

    test('at most 10 suggestions', () {
      final wines = [
        for (var i = 0; i < 30; i++) CellarWineRef(name: 'Barolo $i'),
      ];
      expect(_suggest(catalog, 'barolo', wines), hasLength(maxSuggestions));
    });
  });

  group('BR1.4 no duplicates', () {
    test('BR1.4 same name, producer and vintage keeps the highest source', () {
      const off = WineCandidate(
        name: 'Barolo DOCG',
        source: CandidateSource.openFoodFacts,
        vintage: 2016,
      );
      const internal = WineCandidate(
        name: 'barolo docg',
        source: CandidateSource.internal,
        vintage: 2016,
      );
      const cellar = WineCandidate(
        name: 'Barolo, DOCG',
        source: CandidateSource.cellar,
        vintage: 2016,
      );
      const otherVintage = WineCandidate(
        name: 'Barolo DOCG',
        source: CandidateSource.openFoodFacts,
        vintage: 2017,
      );
      const otherProducer = WineCandidate(
        name: 'Barolo DOCG',
        source: CandidateSource.openFoodFacts,
        producer: 'Rossi',
        vintage: 2016,
      );
      final merged = mergeCandidates([
        off,
        otherVintage,
        internal,
        cellar,
        otherProducer,
      ]);
      expect(merged, [cellar, otherVintage, otherProducer]);
      expect(mergeCandidates([internal, off]), [internal]);
    });

    test('BR1.4 the limit applies after removing duplicates', () {
      final many = [
        for (var i = 0; i < 15; i++)
          WineCandidate(name: 'Vino $i', source: CandidateSource.openFoodFacts),
      ];
      expect(mergeCandidates([...many, ...many]), hasLength(10));
      expect(mergeCandidates(many, limit: 3), hasLength(3));
      expect(mergeCandidates(const []), isEmpty);
    });
  });
}
