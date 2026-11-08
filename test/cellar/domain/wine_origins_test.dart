// WineOrigins (ux-redesign FR1.1-FR1.5, NFR3; reviews R-02, R-05, R-06):
// the 249 ISO countries with their names in it/en/pt-BR, the 21 wine
// countries, the regions, the accent-free search, the denomination and
// Open Food Facts matching and the "Italian region means Italy" rule.
import 'package:estimation/estimation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/cellar/domain/wine.dart';
import 'package:vinoozy/cellar/domain/wine_origins.dart';
import 'package:vinoozy/cellar/ui/wine_badges.dart';

void main() {
  group('NFR3 the ISO 3166-1 table', () {
    test('has 249 distinct two-letter codes, each with three names', () {
      final countries = WineOrigins.allCountries;
      expect(countries, hasLength(249));
      expect({for (final c in countries) c.code}, hasLength(249));
      for (final country in countries) {
        expect(country.code, matches(RegExp(r'^[A-Z]{2}$')));
        expect(country.it.trim(), isNotEmpty);
        expect(country.en.trim(), isNotEmpty);
        expect(country.pt.trim(), isNotEmpty);
        expect(WineOrigins.isCountryCode(country.code), isTrue);
      }
    });

    test('nameIn picks the language, English for any other', () {
      final japan = WineOrigins.country('JP')!;
      expect(japan.nameIn('it'), 'Giappone');
      expect(japan.nameIn('en'), 'Japan');
      expect(japan.nameIn('pt'), 'Japão');
      expect(japan.nameIn('de'), 'Japan');
    });

    test('rejects unknown, lower-case and missing codes', () {
      expect(WineOrigins.isCountryCode('XX'), isFalse);
      expect(WineOrigins.isCountryCode('it'), isFalse);
      expect(WineOrigins.isCountryCode(null), isFalse);
      expect(WineOrigins.country('ZZ'), isNull);
    });
  });

  group('flags', () {
    test('the emoji is built from the two regional indicators', () {
      expect(WineOrigins.flagEmoji('IT'), '\u{1F1EE}\u{1F1F9}');
      expect(WineOrigins.country('MP')!.flag, '\u{1F1F2}\u{1F1F5}');
    });

    test('a malformed code has no emoji: the fallback shows the code', () {
      expect(WineOrigins.flagEmoji('1A'), isNull);
      expect(WineOrigins.flagEmoji('ITA'), isNull);
      expect(WineOrigins.flagEmoji('it'), isNull);
      expect(WineOrigins.flagEmoji(null), isNull);
    });
  });

  group('FR1.1 search', () {
    test('Giappone, Japan and Japão all find JP, with or without accents', () {
      for (final query in ['Giappone', 'Japan', 'Japão', 'japao', ' JAPÃO ']) {
        final found = WineOrigins.searchCountries(query, languageCode: 'it');
        expect(found.map((c) => c.code), contains('JP'), reason: query);
      }
    });

    test('"marian" finds the Northern Mariana Islands (MP)', () {
      final found = WineOrigins.searchCountries('marian', languageCode: 'it');
      expect(found.map((c) => c.code), contains('MP'));
      expect(found.first.nameIn('it'), 'Isole Marianne Settentrionali');
    });

    test('the code finds its country and nothing matches nonsense', () {
      final nz = WineOrigins.searchCountries('nz').map((c) => c.code);
      expect(nz.first, 'NZ', reason: 'the code first');
      expect(nz, contains('TZ'), reason: 'then names containing "nz"');
      expect(WineOrigins.searchCountries('qwxz'), isEmpty);
    });

    test('an empty query lists all 249, sorted by the language', () {
      final it = WineOrigins.searchCountries('', languageCode: 'it');
      expect(it, hasLength(249));
      expect(it.first.code, 'AF');
      final pt = WineOrigins.sortedFor('pt');
      expect(pt.first.code, 'AF');
      expect(pt.map((c) => c.code), contains('ZA'));
    });
  });

  group('FR1.1 FR1.2 wine countries and regions', () {
    test('the 21 wine countries in the order of the specification', () {
      expect(WineOrigins.wineCountryCodes, [
        'IT', 'FR', 'ES', 'PT', 'DE', 'AT', 'CH', 'GR', 'HU', 'SI', 'HR', //
        'GE', 'US', 'CA', 'AR', 'CL', 'BR', 'UY', 'AU', 'NZ', 'ZA',
      ]);
      for (final code in WineOrigins.wineCountryCodes) {
        expect(WineOrigins.regionsOf(code), isNotEmpty, reason: code);
      }
    });

    test('"Rare for wine" are real countries outside the grid', () {
      final rare = WineOrigins.countriesOf(WineOrigins.rareWineCountryCodes);
      expect(rare, hasLength(WineOrigins.rareWineCountryCodes.length));
      for (final country in rare) {
        expect(WineOrigins.wineCountryCodes, isNot(contains(country.code)));
      }
      expect(WineOrigins.countriesOf(['IT', 'XX']).single.code, 'IT');
    });

    test('Italy has all 20 regions with their canonical names', () {
      final italy = [
        for (final region in WineOrigins.regionsOf('IT')) region.canonical,
      ];
      expect(italy, hasLength(20));
      expect(
        italy,
        containsAll([
          'Abruzzo', 'Basilicata', 'Calabria', 'Campania', 'Emilia-Romagna', //
          'Friuli-Venezia Giulia', 'Lazio', 'Liguria', 'Lombardia', 'Marche',
          'Molise', 'Piemonte', 'Puglia', 'Sardegna', 'Sicilia', 'Toscana',
          'Trentino-Alto Adige', 'Umbria', "Valle d'Aosta", 'Veneto',
        ]),
      );
    });

    test('France has the 11 regions of FR1.2, shown in each language', () {
      final france = WineOrigins.regionsOf('FR');
      expect(france, hasLength(11));
      final burgundy = france[1];
      expect(burgundy.canonical, 'Bourgogne');
      expect(burgundy.nameIn('it'), 'Borgogna');
      expect(burgundy.nameIn('en'), 'Burgundy');
      expect(burgundy.nameIn('pt'), 'Borgonha');
      expect(france.first.nameIn('it'), 'Bordeaux', reason: 'no translation');
    });

    test('New World examples of FR1.2 are listed', () {
      String names(String code) =>
          [for (final region in WineOrigins.regionsOf(code)) region.canonical]
              .join('|');
      expect(names('AR'), contains('Mendoza|Salta|San Juan'));
      expect(names('AR'), contains('Patagonia'));
      expect(names('BR'), contains('Serra Gaúcha'));
      expect(names('BR'), contains('Vale do São Francisco'));
    });

    test('a country without listed regions and no country give none', () {
      expect(WineOrigins.regionsOf('MP'), isEmpty);
      expect(WineOrigins.regionsOf(null), isEmpty);
    });

    test('changing the country clears the region, the same one keeps it', () {
      const chosen = OriginSelection(country: 'IT', region: 'Piemonte');
      expect(chosen.withCountry('IT'), chosen);
      expect(chosen.withCountry('FR'), const OriginSelection(country: 'FR'));
      expect(chosen.withCountry(null), const OriginSelection());
      expect(
        chosen.withRegion('  Langhe '),
        const OriginSelection(country: 'IT', region: 'Langhe'),
      );
      expect(chosen.withRegion('  ').region, isNull);
    });
  });

  group('R-02 R-07 canonical names', () {
    test('a listed region in any language is stored canonical', () {
      expect(WineOrigins.canonicalRegion('FR', 'Borgogna'), 'Bourgogne');
      expect(WineOrigins.canonicalRegion('FR', ' burgundy '), 'Bourgogne');
      expect(
        WineOrigins.canonicalRegion('CL', 'Colchagua'),
        'Valle de Colchagua',
      );
      expect(WineOrigins.canonicalRegion(null, 'sicilia'), 'Sicilia');
    });

    test('free text stays as written, without outer spaces', () {
      expect(WineOrigins.canonicalRegion('FR', '  Corse '), 'Corse');
      expect(WineOrigins.canonicalRegion(null, 'Borgogna'), 'Borgogna');
      expect(WineOrigins.canonicalRegion('IT', '   '), isNull);
      expect(WineOrigins.canonicalRegion('IT', null), isNull);
    });

    test('the region is shown translated, free text as stored', () {
      expect(
        WineOrigins.regionDisplayName('FR', 'Bourgogne', 'it'),
        'Borgogna',
      );
      expect(WineOrigins.regionDisplayName(null, 'Piemonte', 'en'), 'Piedmont');
      expect(WineOrigins.regionDisplayName('FR', 'Corse', 'it'), 'Corse');
    });
  });

  group('R-06 an Italian region means Italy', () {
    test('ignoring accents and case, translations and aliases included', () {
      for (final region in [
        'piemonte',
        'PIEMONTE',
        'Trentino Alto Adige',
        'Alto Adige',
        'Sicily',
        "valle d'aosta",
      ]) {
        expect(
          WineOrigins.effectiveCountry(null, region),
          'IT',
          reason: region,
        );
      }
    });

    test('a country already set wins; other regions give no country', () {
      expect(WineOrigins.effectiveCountry('FR', 'Piemonte'), 'FR');
      expect(WineOrigins.effectiveCountry(null, 'Bordeaux'), isNull);
      expect(WineOrigins.effectiveCountry(null, null), isNull);
      expect(WineOrigins.effectiveCountry('xx', 'Toscana'), 'IT');
    });

    test('an old wine read without country shows Italy, unchanged', () {
      final wine = Wine.fromMap('w1', {
        'name': 'Barolo',
        'quantity': 2,
        'region': 'piemonte',
      });
      expect(wine.country, isNull);
      expect(wine.displayCountry, 'IT');
    });

    test('a stored country is read; a malformed one is ignored', () {
      final argentine = Wine.fromMap('w1', {'name': 'Malbec', 'country': 'AR'});
      expect(argentine.country, 'AR');
      expect(argentine.displayCountry, 'AR');
      final malformed = Wine.fromMap('w2', {'name': 'X', 'country': 'arg'});
      expect(malformed.country, isNull);
      expect(Wine.fromMap('w3', {'name': 'X', 'country': 7}).country, isNull);
    });
  });

  group('FR1.3 automatic country and region', () {
    test('Barolo DOCG → Piemonte → Italy (internal catalog)', () {
      expect(
        WineOrigins.guess(denomination: 'Barolo DOCG'),
        const OriginGuess(country: 'IT', region: 'Piemonte'),
      );
      expect(
        WineOrigins.guess(name: 'Brunello di Montalcino Riserva 2015'),
        const OriginGuess(country: 'IT', region: 'Toscana'),
      );
    });

    test('Chablis → Bourgogne → France; Rioja → Spain; Tokaji → Hungary', () {
      expect(
        WineOrigins.guess(name: 'Chablis Premier Cru'),
        const OriginGuess(country: 'FR', region: 'Bourgogne'),
      );
      expect(
        WineOrigins.guess(denomination: 'Rioja Reserva'),
        const OriginGuess(country: 'ES', region: 'Rioja'),
      );
      expect(
        WineOrigins.guess(name: 'Tokaji Aszú 5 puttonyos'),
        const OriginGuess(country: 'HU', region: 'Tokaj'),
      );
    });

    test('Open Food Facts origins with a country and no region', () {
      expect(
        WineOrigins.guess(region: 'Argentina'),
        const OriginGuess(country: 'AR'),
      );
      expect(
        WineOrigins.guess(region: 'Itália'),
        const OriginGuess(country: 'IT'),
      );
      expect(
        WineOrigins.guess(region: 'USA'),
        const OriginGuess(country: 'US'),
      );
    });

    test('origins with region and country, or a region of one country', () {
      expect(
        WineOrigins.guess(region: 'Mendoza, Argentina'),
        const OriginGuess(country: 'AR', region: 'Mendoza'),
      );
      expect(
        WineOrigins.guess(region: 'Serra Gaúcha'),
        const OriginGuess(country: 'BR', region: 'Serra Gaúcha'),
      );
      expect(
        WineOrigins.guess(region: 'France, Corse'),
        const OriginGuess(country: 'FR'),
      );
    });

    test('unknown text stays a free region; nothing gives nothing', () {
      expect(
        WineOrigins.guess(region: 'Vigna del nonno'),
        const OriginGuess(region: 'Vigna del nonno'),
      );
      expect(WineOrigins.guess(), OriginGuess.none);
      expect(WineOrigins.guess(name: '  ', region: ' '), OriginGuess.none);
      expect(WineOrigins.countryNamed('Neverland'), isNull);
      expect(WineOrigins.countryNamed('JP')!.code, 'JP');
    });
  });

  test('accent folding covers the names of the lists', () {
    expect(foldOriginText('Štajerska'), 'stajerska');
    expect(foldOriginText("Côte d'Ivoire"), 'cote d ivoire');
    expect(foldOriginText('Isole Fær Øer'), 'isole faer oer');
    expect(foldOriginText('Hessische Bergstraße'), 'hessische bergstrasse');
    expect(foldOriginText('  --  '), '');
  });

  test('every graphic family groups its WineType values (review Major 1)', () {
    expect(
      {for (final type in WineType.values) type: WineTypeFamily.ofType(type)},
      {
        WineType.redLight: WineTypeFamily.red,
        WineType.redStructured: WineTypeFamily.red,
        WineType.white: WineTypeFamily.white,
        WineType.rose: WineTypeFamily.rose,
        WineType.sparklingClassic: WineTypeFamily.sparkling,
        WineType.sparklingTank: WineTypeFamily.sparkling,
        WineType.sweet: WineTypeFamily.sweet,
        WineType.fortified: WineTypeFamily.sweet,
      },
    );
    expect(WineTypeFamily.of('red'), WineTypeFamily.red);
    expect(WineTypeFamily.of('unknown'), isNull);
    expect(WineTypeFamily.of(null), isNull);
  });
}
