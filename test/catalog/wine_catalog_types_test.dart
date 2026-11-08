// C1 value types and CatalogArgumentError (wine_catalog.dart).
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/catalog/core/wine_catalog.dart';

const _offWine = WineCandidate(
  name: 'Barolo Cannubi',
  source: CandidateSource.openFoodFacts,
  producer: 'Cantina Esempio',
  vintage: 2016,
  wineType: CatalogWineType.red,
  region: 'Piemonte',
  denomination: 'Barolo DOCG',
  barcode: '8001234567890',
);

void main() {
  group('WineCandidate', () {
    test('value equality covers every field', () {
      const same = WineCandidate(
        name: 'Barolo Cannubi',
        source: CandidateSource.openFoodFacts,
        producer: 'Cantina Esempio',
        vintage: 2016,
        wineType: CatalogWineType.red,
        region: 'Piemonte',
        denomination: 'Barolo DOCG',
        barcode: '8001234567890',
      );
      expect(same, _offWine);
      expect(same.hashCode, _offWine.hashCode);
      expect(_offWine.copyWith(vintage: 2017), isNot(_offWine));
      expect(
        const WineCandidate(
          name: 'Barolo Cannubi',
          source: CandidateSource.internal,
        ),
        isNot(_offWine),
      );
    });

    test('toJson and fromJson round-trip, absent fields left out', () {
      expect(WineCandidate.fromJson(_offWine.toJson()), _offWine);
      const minimal = WineCandidate(
        name: 'Soave',
        source: CandidateSource.internal,
      );
      expect(minimal.toJson(), {'n': 'Soave', 's': 'internal'});
      expect(WineCandidate.fromJson(minimal.toJson()), minimal);
    });

    test('fromJson drops damaged entries instead of throwing (NFR6.4)', () {
      expect(WineCandidate.fromJson(null), isNull);
      expect(WineCandidate.fromJson('Barolo'), isNull);
      expect(WineCandidate.fromJson({'n': '', 's': 'internal'}), isNull);
      expect(WineCandidate.fromJson({'n': 'Barolo', 's': 'unknown'}), isNull);
      expect(WineCandidate.fromJson({'n': 3, 's': 'internal'}), isNull);
      final lenient = WineCandidate.fromJson({
        'n': 'Barolo',
        's': 'cellar',
        'v': '2016',
        't': 'purple',
        'p': 7,
        'r': '',
      });
      expect(
        lenient,
        const WineCandidate(name: 'Barolo', source: CandidateSource.cellar),
      );
    });

    test('toString carries no wine data (NFR8.3)', () {
      expect(_offWine.toString(), 'WineCandidate(openFoodFacts)');
      expect(_offWine.toString(), isNot(contains('Barolo')));
    });

    test('copyWith keeps the vintage when none is given', () {
      expect(_offWine.copyWith(), _offWine);
      expect(_offWine.copyWith(vintage: 2010).vintage, 2010);
    });
  });

  group('CandidateSource', () {
    test('BR1.4 priority: cellar, then internal, then Open Food Facts', () {
      expect(
        CandidateSource.cellar.rank,
        lessThan(CandidateSource.internal.rank),
      );
      expect(
        CandidateSource.internal.rank,
        lessThan(CandidateSource.openFoodFacts.rank),
      );
    });
  });

  group('CatalogLocale', () {
    test('maps app language tags and sends only the language code', () {
      expect(CatalogLocale.fromLanguageTag('it'), CatalogLocale.it);
      expect(CatalogLocale.fromLanguageTag('it-IT'), CatalogLocale.it);
      expect(CatalogLocale.fromLanguageTag('pt-BR'), CatalogLocale.ptBR);
      expect(CatalogLocale.fromLanguageTag('pt_BR'), CatalogLocale.ptBR);
      expect(CatalogLocale.fromLanguageTag('EN'), CatalogLocale.en);
      expect(CatalogLocale.fromLanguageTag('fr'), CatalogLocale.en);
      expect(CatalogLocale.ptBR.offLanguage, 'pt');
    });
  });

  group('other C1 values', () {
    test('CellarWineRef equality and a toString without data', () {
      const a = CellarWineRef(
        name: 'Rosso di casa',
        producer: 'Mario',
        vintage: 2020,
      );
      const b = CellarWineRef(
        name: 'Rosso di casa',
        producer: 'Mario',
        vintage: 2020,
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(const CellarWineRef(name: 'Rosso di casa')));
      expect(a.toString(), isNot(contains('Mario')));
    });

    test('SuggestResult equality', () {
      const a = SuggestResult(suggestions: [_offWine], externalIncluded: true);
      const b = SuggestResult(suggestions: [_offWine], externalIncluded: true);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(SuggestResult.empty));
      expect(
        a,
        isNot(
          const SuggestResult(suggestions: [_offWine], externalIncluded: false),
        ),
      );
      expect(a.toString(), 'SuggestResult(1, external: true)');
    });

    test('LabelMatchResult has a candidate only when sure (label-recognition '
        'BR3.2)', () {
      const sure = LabelMatchResult.sure(
        _offWine,
        step: LabelMatchStep.onlineBarcode,
      );
      expect(sure.kind, LabelMatchKind.sure);
      expect(sure.candidate, _offWine);
      expect(sure.candidates, isEmpty);
      const none = LabelMatchResult.none();
      expect(none.kind, LabelMatchKind.none);
      expect(none.candidate, isNull);
      expect(none.step, LabelMatchStep.none);
      const list = LabelMatchResult.candidates([
        _offWine,
      ], step: LabelMatchStep.onlineText);
      expect(list.candidate, isNull);
      expect(
        sure,
        const LabelMatchResult.sure(
          _offWine,
          step: LabelMatchStep.onlineBarcode,
        ),
      );
      expect(
        sure.hashCode,
        const LabelMatchResult.sure(
          _offWine,
          step: LabelMatchStep.onlineBarcode,
        ).hashCode,
      );
      expect(sure, isNot(none));
      expect(list, isNot(sure));
      expect(none.toString(), 'LabelMatchResult(none, 0, none)');
    });

    test('OnlineSearchResult equality (label-recognition BR4.2)', () {
      const a = OnlineSearchResult(
        candidates: [_offWine],
        status: OnlineSearchStatus.ok,
      );
      expect(
        a,
        const OnlineSearchResult(
          candidates: [_offWine],
          status: OnlineSearchStatus.ok,
        ),
      );
      expect(
        a.hashCode,
        const OnlineSearchResult(
          candidates: [_offWine],
          status: OnlineSearchStatus.ok,
        ).hashCode,
      );
      expect(
        a,
        isNot(
          const OnlineSearchResult(
            candidates: [_offWine],
            status: OnlineSearchStatus.offline,
          ),
        ),
      );
      expect(a.toString(), 'OnlineSearchResult(1, ok)');
    });

    test('a candidate keeps its country through the cache form', () {
      const offline = WineCandidate(
        name: 'Barolo Ravera',
        source: CandidateSource.offline,
        barcode: '8001234567897',
        country: 'IT',
      );
      expect(WineCandidate.fromJson(offline.toJson()), offline);
      expect(offline.copyWith(vintage: 2016).country, 'IT');
      expect(
        CandidateSource.offline.rank,
        lessThan(CandidateSource.internal.rank),
      );
      expect(
        CandidateSource.offline.rank,
        lessThan(CandidateSource.openFoodFacts.rank),
      );
    });

    test('WineProfileResult and ProfileWindow equality', () {
      const window = ProfileWindow(
        startYear: 2024,
        peakYear: 2030,
        endYear: 2040,
      );
      const a = WineProfileResult(
        found: true,
        window: window,
        confidence: ProfileConfidence.high,
        pairings: ['game'],
        wineType: CatalogWineType.red,
        region: 'Piemonte',
        denomination: 'Barolo DOCG',
      );
      const b = WineProfileResult(
        found: true,
        window: ProfileWindow(startYear: 2024, peakYear: 2030, endYear: 2040),
        confidence: ProfileConfidence.high,
        pairings: ['game'],
        wineType: CatalogWineType.red,
        region: 'Piemonte',
        denomination: 'Barolo DOCG',
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(window.hashCode, b.window.hashCode);
      expect(a, isNot(const WineProfileResult(found: false)));
      expect(
        a,
        isNot(
          const WineProfileResult(
            found: true,
            window: window,
            confidence: ProfileConfidence.high,
            pairings: ['fish'],
            wineType: CatalogWineType.red,
            region: 'Piemonte',
            denomination: 'Barolo DOCG',
          ),
        ),
      );
      expect(const WineProfileResult(found: false).pairings, isEmpty);
      expect(a.toString(), 'WineProfileResult(found: true)');
    });
  });

  group('CatalogArgumentError (NFR4.5, NFR8.3)', () {
    test('carries a code and a fixed message, never the value', () {
      for (final code in CatalogErrorCode.values) {
        final error = CatalogArgumentError(code);
        expect(error, isA<ArgumentError>());
        expect(error.code, code);
        expect(error.message, isA<String>());
        expect((error.message as String).isNotEmpty, isTrue);
        expect(error.invalidValue, isNull);
        expect(
          error.toString(),
          startsWith('CatalogArgumentError(${code.name})'),
        );
      }
    });
  });
}
