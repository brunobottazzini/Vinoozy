import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/app/locale_resolution.dart';

// Language chosen from the phone settings among the 25 interface languages
// (wine-culture-languages FR1.4, FR2.1).
void main() {
  group('offered languages (FR1.1)', () {
    test('there are 25, without duplicates, English included', () {
      expect(appLocales, hasLength(25));
      expect(appLocales.toSet(), hasLength(25));
      expect(appLocales, contains(fallbackLocale));
    });

    test('every offered language resolves to itself', () {
      for (final locale in appLocales) {
        expect(resolveAppLocale([locale]), locale);
      }
    });
  });

  group('regional variants receive the base language (FR1.4)', () {
    test('fr-CA receives fr', () {
      expect(resolveAppLocale([const Locale('fr', 'CA')]), const Locale('fr'));
    });

    test('es-AR receives es', () {
      expect(resolveAppLocale([const Locale('es', 'AR')]), const Locale('es'));
    });

    test('de-AT receives de', () {
      expect(resolveAppLocale([const Locale('de', 'AT')]), const Locale('de'));
    });

    test('a script subtag does not matter', () {
      expect(
        resolveAppLocale([
          const Locale.fromSubtags(
            languageCode: 'sr',
            scriptCode: 'Cyrl',
            countryCode: 'RS',
          ),
        ]),
        const Locale('sr'),
      );
    });
  });

  group('Portuguese (FR1.3, FR1.4)', () {
    test('pt-BR stays Brazilian Portuguese', () {
      expect(
        resolveAppLocale([const Locale('pt', 'BR')]),
        const Locale('pt', 'BR'),
      );
    });

    test('pt-PT receives European Portuguese', () {
      expect(resolveAppLocale([const Locale('pt', 'PT')]), const Locale('pt'));
    });

    test('any other Portuguese receives European Portuguese', () {
      expect(resolveAppLocale([const Locale('pt', 'AO')]), const Locale('pt'));
      expect(resolveAppLocale([const Locale('pt')]), const Locale('pt'));
    });
  });

  group(
    'languages chosen in the Android app settings (FR2.2, loop-back 1)',
    () {
      Locale fromAndroid(String language, {String? script, String? country}) =>
          Locale.fromSubtags(
            languageCode: language,
            scriptCode: script,
            countryCode: country,
          );

      test('pt-PT gives European Portuguese', () {
        expect(
          resolveAppLocale([fromAndroid('pt', country: 'PT')]),
          const Locale('pt'),
        );
      });

      test('pt-BR gives Brazilian Portuguese, with or without the script', () {
        expect(
          resolveAppLocale([fromAndroid('pt', country: 'BR')]),
          const Locale('pt', 'BR'),
        );
        expect(
          resolveAppLocale([fromAndroid('pt', script: 'Latn', country: 'BR')]),
          const Locale('pt', 'BR'),
        );
      });

      test('sr-Cyrl gives Serbian', () {
        expect(
          resolveAppLocale([fromAndroid('sr', script: 'Cyrl')]),
          const Locale('sr'),
        );
      });

      test('sr-Cyrl-RS gives Serbian', () {
        expect(
          resolveAppLocale([fromAndroid('sr', script: 'Cyrl', country: 'RS')]),
          const Locale('sr'),
        );
      });

      test('sr-Latn-RS gives Serbian in Cyrillic, the only one offered', () {
        expect(
          resolveAppLocale([fromAndroid('sr', script: 'Latn', country: 'RS')]),
          const Locale('sr'),
        );
        expect(
          resolveAppLocale([fromAndroid('sr', script: 'Latn')]),
          const Locale('sr'),
        );
      });

      test('the Android tags of the app are pt-PT and sr-Cyrl', () {
        expect(androidLocaleTagOf(const Locale('pt')), 'pt-PT');
        expect(androidLocaleTagOf(const Locale('pt', 'BR')), 'pt-BR');
        expect(androidLocaleTagOf(const Locale('sr')), 'sr-Cyrl');
        expect(androidLocaleTagOf(const Locale('fr')), 'fr');
      });
    },
  );

  group('Norwegian (FR1.4)', () {
    test('nn receives nb', () {
      expect(resolveAppLocale([const Locale('nn', 'NO')]), const Locale('nb'));
    });

    test('no receives nb', () {
      expect(resolveAppLocale([const Locale('no')]), const Locale('nb'));
      expect(resolveAppLocale([const Locale('no', 'NO')]), const Locale('nb'));
    });

    test('nb stays nb', () {
      expect(resolveAppLocale([const Locale('nb', 'NO')]), const Locale('nb'));
    });
  });

  group('fallback (FR1.4)', () {
    test('a language that is not offered receives English', () {
      expect(resolveAppLocale([const Locale('ja', 'JP')]), fallbackLocale);
      expect(resolveAppLocale([const Locale('tr')]), fallbackLocale);
      expect(resolveAppLocale([const Locale('ru', 'RU')]), fallbackLocale);
    });

    test('an empty list receives English', () {
      expect(resolveAppLocale(const []), fallbackLocale);
    });

    test('no list receives English', () {
      expect(resolveAppLocale(null), fallbackLocale);
    });
  });

  group('order of preference of the phone (FR2.1)', () {
    test('the first offered language wins', () {
      expect(
        resolveAppLocale([const Locale('el', 'GR'), const Locale('it', 'IT')]),
        const Locale('el'),
      );
    });

    test('languages that are not offered are skipped', () {
      expect(
        resolveAppLocale([
          const Locale('ja'),
          const Locale('zh', 'CN'),
          const Locale('ka', 'GE'),
          const Locale('en'),
        ]),
        const Locale('ka'),
      );
    });

    test('English first stays English', () {
      expect(
        resolveAppLocale([const Locale('en', 'GB'), const Locale('fr')]),
        const Locale('en'),
      );
    });
  });
}
