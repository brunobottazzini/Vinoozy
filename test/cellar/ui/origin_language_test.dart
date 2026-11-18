import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/app/locale_resolution.dart';
import 'package:vinoozy/app/ui/country_flag.dart';
import 'package:vinoozy/cellar/domain/wine_origins.dart';
import 'package:vinoozy/cellar/ui/origin_language.dart';

import '../../helpers/ui_harness.dart';

// The language under which the screens look up country and region names
// (wine-culture-languages FR3.1, FR3.2) and name the locale for dates and
// numbers (FR3.5).
void main() {
  group('origin language tag', () {
    test('Brazilian Portuguese keeps the tag of the first release', () {
      expect(originLanguageOf(const Locale('pt', 'BR')), 'pt');
    });

    test('European and any other Portuguese is pt-PT', () {
      expect(originLanguageOf(const Locale('pt')), 'pt-PT');
      expect(originLanguageOf(const Locale('pt', 'PT')), 'pt-PT');
      expect(originLanguageOf(const Locale('pt', 'AO')), 'pt-PT');
    });

    test('every other language is its code, whatever the country', () {
      expect(originLanguageOf(const Locale('it')), 'it');
      expect(originLanguageOf(const Locale('de', 'AT')), 'de');
      expect(originLanguageOf(const Locale('ka')), 'ka');
    });

    test('every interface language has its own country names', () {
      final tags = {for (final locale in appLocales) originLanguageOf(locale)};
      expect(tags, originLanguageTags.toSet());
    });
  });

  group('intl locale name (FR3.5)', () {
    test('European Portuguese is pt_PT, Brazilian pt_BR', () {
      expect(intlLocaleNameOf(const Locale('pt')), 'pt_PT');
      expect(intlLocaleNameOf(const Locale('pt', 'BR')), 'pt_BR');
    });

    test('the other languages keep their name', () {
      expect(intlLocaleNameOf(const Locale('el')), 'el');
      expect(intlLocaleNameOf(const Locale('nb')), 'nb');
    });
  });

  group('screens read the name in the language of the app', () {
    Future<String?> flagLabel(WidgetTester tester, Locale locale) async {
      final handle = tester.ensureSemantics();
      await pumpScreen(
        tester,
        const Scaffold(body: CountryFlag(code: 'DE')),
        locale: locale,
      );
      final label = tester.getSemantics(find.byType(CountryFlag)).label;
      handle.dispose();
      return label;
    }

    testWidgets('German', (tester) async {
      expect(await flagLabel(tester, const Locale('de')), 'Deutschland');
    });

    testWidgets('Greek', (tester) async {
      expect(await flagLabel(tester, const Locale('el')), 'Γερμανία');
    });

    testWidgets('Georgian', (tester) async {
      expect(await flagLabel(tester, const Locale('ka')), 'გერმანია');
    });

    testWidgets('European and Brazilian Portuguese', (tester) async {
      expect(await flagLabel(tester, const Locale('pt')), 'Alemanha');
      expect(await flagLabel(tester, const Locale('pt', 'BR')), 'Alemanha');
    });

    testWidgets('an unknown code shows the code', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpScreen(
        tester,
        const Scaffold(body: CountryFlag(code: 'ZZ')),
        locale: const Locale('uk'),
      );
      expect(tester.getSemantics(find.byType(CountryFlag)).label, 'ZZ');
      handle.dispose();
    });
  });
}
