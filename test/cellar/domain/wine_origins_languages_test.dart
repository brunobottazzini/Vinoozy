import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/cellar/domain/origin_country_names.g.dart';
import 'package:vinoozy/cellar/domain/wine_origins.dart';

// Country and region names in the 25 interface languages
// (wine-culture-languages FR3.1, FR3.2, FR3.3).
void main() {
  group('country names (FR3.1)', () {
    test('there is one origin language tag per interface language', () {
      expect(originLanguageTags, hasLength(25));
      expect(originLanguageTags.toSet(), hasLength(25));
      expect(originLanguageTags, containsAll(['it', 'en', 'pt', 'pt-PT']));
    });

    test('every country has a name of its own in each language', () {
      for (final tag in originLanguageTags) {
        final generated = originCountryNames[tag];
        for (final country in WineOrigins.allCountries) {
          final name = country.nameIn(tag);
          expect(name.trim(), isNotEmpty, reason: '${country.code} in $tag');
          if (generated != null) {
            // The name comes from the table of the language, not from the
            // English fallback.
            expect(generated[country.code], name, reason: country.code);
          }
        }
      }
    });

    test('the generated tables list exactly the 249 countries', () {
      final codes = {for (final c in WineOrigins.allCountries) c.code};
      expect(codes, hasLength(249));
      for (final MapEntry(key: tag, value: names)
          in originCountryNames.entries) {
        expect(names.keys.toSet(), codes, reason: tag);
      }
    });

    test('a few known names', () {
      final germany = WineOrigins.country('DE')!;
      expect(germany.nameIn('fr'), 'Allemagne');
      expect(germany.nameIn('es'), 'Alemania');
      expect(germany.nameIn('de'), 'Deutschland');
      expect(germany.nameIn('el'), 'Γερμανία');
      expect(germany.nameIn('uk'), 'Німеччина');
      expect(germany.nameIn('ka'), 'გერმანია');
      expect(WineOrigins.country('HK')!.nameIn('fr'), 'Hong Kong');
    });

    test('Brazilian and European Portuguese keep their own names', () {
      final czechia = WineOrigins.country('CZ')!;
      expect(czechia.nameIn('pt'), 'Tchéquia');
      expect(czechia.nameIn('pt-PT'), 'Chéquia');
    });

    test('an unknown language tag falls back to English', () {
      expect(WineOrigins.country('IT')!.nameIn('xx'), 'Italy');
      expect(WineOrigins.country('IT')!.nameIn(''), 'Italy');
    });

    test('the list is sorted by the name in the language', () {
      final greek = WineOrigins.sortedFor('el');
      expect(greek, hasLength(249));
      final keys = [for (final c in greek) foldOriginText(c.nameIn('el'))];
      expect(keys, [...keys]..sort());
    });
  });

  group('region names (FR3.2)', () {
    test('a region shows the name in common use of the language', () {
      final burgundy = WineOrigins.findRegion('FR', 'Bourgogne')!;
      expect(burgundy.nameIn('de'), 'Burgund');
      expect(burgundy.nameIn('es'), 'Borgoña');
      expect(burgundy.nameIn('uk'), 'Бургундія');
      expect(WineOrigins.findRegion('IT', 'Toscana')!.nameIn('de'), 'Toskana');
      expect(WineOrigins.findRegion('GR', 'Kriti')!.nameIn('el'), 'Κρήτη');
      expect(WineOrigins.findRegion('GE', 'Kakheti')!.nameIn('ka'), 'კახეთი');
    });

    test('a language without a name in common use shows the canonical', () {
      final burgundy = WineOrigins.findRegion('FR', 'Bourgogne')!;
      expect(burgundy.nameIn('da'), 'Bourgogne');
      expect(burgundy.nameIn('xx'), 'Bourgogne');
      expect(WineOrigins.findRegion('IT', 'Molise')!.nameIn('fi'), 'Molise');
    });

    test('European Portuguese uses its spelling, else the Brazilian form', () {
      expect(
        WineOrigins.findRegion('DE', 'Franken')!.nameIn('pt-PT'),
        'Francónia',
      );
      expect(
        WineOrigins.findRegion('DE', 'Franken')!.nameIn('pt'),
        'Francônia',
      );
      expect(
        WineOrigins.findRegion('FR', 'Bourgogne')!.nameIn('pt-PT'),
        'Borgonha',
      );
      expect(WineOrigins.findRegion('PT', 'Douro')!.nameIn('pt-PT'), 'Douro');
    });

    test('the stored value is the same whatever the language', () {
      // A wine saved while the app was in German or Greek...
      expect(WineOrigins.canonicalRegion('FR', 'Burgund'), 'Bourgogne');
      expect(WineOrigins.canonicalRegion('FR', 'βουργουνδία'), 'Bourgogne');
      expect(WineOrigins.canonicalRegion('IT', 'ТОСКАНА'), 'Toscana');
      // ...shows its region in the language the app is in now.
      for (final tag in originLanguageTags) {
        final shown = WineOrigins.regionDisplayName('FR', 'Bourgogne', tag);
        expect(shown, isNotEmpty, reason: tag);
        expect(
          WineOrigins.canonicalRegion('FR', shown),
          'Bourgogne',
          reason: tag,
        );
      }
      expect(
        WineOrigins.regionDisplayName('FR', 'Bourgogne', 'pl'),
        'Burgundia',
      );
      // A free text that is not a listed region is shown as stored.
      expect(WineOrigins.regionDisplayName('FR', 'Savoie', 'de'), 'Savoie');
    });

    test('every translated name leads back to its own region', () {
      for (final code in WineOrigins.wineCountryCodes) {
        for (final region in WineOrigins.regionsOf(code)) {
          for (final form in region.forms) {
            expect(
              WineOrigins.findRegion(code, form),
              same(region),
              reason: '$form of ${region.canonical} ($code)',
            );
          }
        }
      }
    });

    test('a translated name belongs to the regions of one country only', () {
      final owners = <String, Set<String>>{};
      for (final code in WineOrigins.wineCountryCodes) {
        for (final region in WineOrigins.regionsOf(code)) {
          for (final name in region.names?.values ?? const <String>[]) {
            owners.putIfAbsent(foldOriginText(name), () => {}).add(code);
          }
        }
      }
      final shared = {
        for (final MapEntry(:key, :value) in owners.entries)
          if (value.length > 1) key: value,
      };
      expect(shared, isEmpty);
      // The Slovenian region keeps matching alone (Austrian Styria has a
      // qualified Slovenian name).
      expect(
        WineOrigins.guess(region: 'Štajerska'),
        const OriginGuess(country: 'SI', region: 'Štajerska'),
      );
    });

    test('names are keyed by a known origin language tag', () {
      for (final code in WineOrigins.wineCountryCodes) {
        for (final region in WineOrigins.regionsOf(code)) {
          for (final MapEntry(key: tag, value: name)
              in (region.names ?? const <String, String>{}).entries) {
            expect(originCountryNames.keys, contains(tag));
            expect(name.trim(), isNotEmpty);
            expect(name, isNot(region.canonical), reason: '$tag $name');
          }
        }
      }
    });
  });

  group('search in every script (FR3.3)', () {
    List<String> codes(String query, String tag) => [
      for (final c in WineOrigins.searchCountries(query, languageCode: tag))
        c.code,
    ];

    test('Greek: accents, final sigma and capitals do not matter', () {
      expect(codes('Ελλάδα', 'el'), contains('GR'));
      expect(codes('ελλαδα', 'el'), contains('GR'));
      expect(codes('ΕΛΛΑΔΑ', 'el'), contains('GR'));
      // Κύπρος ends with a final sigma.
      expect(codes('κυπρος', 'el'), contains('CY'));
      expect(codes('ΚΥΠΡΟΣ', 'el'), contains('CY'));
      expect(foldOriginText('Κύπρος'), foldOriginText('ΚΥΠΡΟΣ'));
    });

    test('Cyrillic: diacritics and capitals do not matter', () {
      expect(codes('Україна', 'uk'), contains('UA'));
      expect(codes('украіна', 'uk'), contains('UA'));
      expect(codes('УКРАЇНА', 'uk'), contains('UA'));
      expect(codes('Италия', 'bg'), contains('IT'));
      expect(codes('ИТАЛИЯ', 'bg'), contains('IT'));
      expect(codes('србија', 'sr'), contains('RS'));
      // й and и, ё and е are the same letter for the search.
      expect(foldOriginText('Йорк'), foldOriginText('иорк'));
      expect(foldOriginText('Ёлка'), foldOriginText('елка'));
    });

    test('Georgian is found as written', () {
      expect(codes('საქართველო', 'ka'), ['GE']);
      expect(codes('საფრანგ', 'ka'), contains('FR'));
      expect(foldOriginText('საქართველო'), 'საქართველო');
    });

    test('Latin: the letters of the new languages are folded', () {
      expect(codes('cesko', 'cs'), contains('CZ'));
      expect(codes('ČESKO', 'cs'), contains('CZ'));
      expect(codes('osterreich', 'de'), contains('AT'));
      expect(codes('espana', 'es'), contains('ES'));
      expect(foldOriginText('Mosel·la'), 'mosella');
      expect(foldOriginText('Ľubľana ďaleko'), 'lublana daleko');
    });

    test('a combining accent is the same as the accented letter', () {
      // "é" as e + U+0301.
      expect(foldOriginText('Géorgie'), 'georgie');
      expect(foldOriginText('Ελλάδα'), foldOriginText('Ελλάδα'));
    });

    test('names in Italian, English and Brazilian Portuguese still match', () {
      expect(codes('germania', 'el'), contains('DE'));
      expect(codes('germany', 'ka'), contains('DE'));
      expect(codes('alemanha', 'fr'), contains('DE'));
    });

    test('a name of another new language does not match', () {
      expect(codes('Deutschland', 'fr'), isEmpty);
    });

    test('the code comes first and an empty query lists every country', () {
      expect(codes('fr', 'el').first, 'FR');
      expect(codes('', 'ka'), hasLength(249));
      expect(codes('   ', 'ka'), hasLength(249));
    });

    test('regions are found by their name in another script', () {
      expect(WineOrigins.findRegion('GR', 'κρητη')?.canonical, 'Kriti');
      expect(WineOrigins.findRegion('GR', 'ΚΡΗΤΗ')?.canonical, 'Kriti');
      expect(WineOrigins.findRegion('GE', 'კახეთი')?.canonical, 'Kakheti');
      expect(WineOrigins.findRegion('FR', 'бургундия')?.canonical, 'Bourgogne');
      expect(WineOrigins.findRegion('FR', 'nowhere'), isNull);
    });
  });
}
