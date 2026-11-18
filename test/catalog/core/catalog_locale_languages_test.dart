// The language of an online catalog search in the 25 interface languages
// (wine-culture-languages FR3.4). The real Open Food Facts is never called.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:vinoozy/app/locale_resolution.dart';
import 'package:vinoozy/catalog/core/catalog_config.dart';
import 'package:vinoozy/catalog/core/off/open_food_facts_source.dart';
import 'package:vinoozy/catalog/core/wine_catalog.dart';

import '../catalog_test_helpers.dart';

const _config = CatalogConfig(appVersion: '1.2.3', offContact: 'team.example');

Map<String, Object?> _wine(Map<String, Object?> names) => {
  'code': '3760000000017',
  'brands': 'Domaine Exemple',
  'categories_tags': ['en:wines', 'en:red-wines'],
  ...names,
};

/// The names proposed by a search in [locale] answered with [products].
Future<List<String>> _searchNames(
  CatalogLocale locale,
  List<Map<String, Object?>> products, {
  List<http.BaseRequest>? requests,
}) async {
  final source = OpenFoodFactsSource(
    client: MockClient((request) async {
      requests?.add(request);
      return http.Response.bytes(
        utf8.encode(jsonEncode({'products': products})),
        200,
      );
    }),
    config: _config,
    timerFactory: FakeTimers().call,
  );
  final outcome = await source.search('vin rouge', locale);
  return switch (outcome) {
    OffFound(:final candidates) => [for (final c in candidates) c.name],
    _ => const [],
  };
}

void main() {
  group('language sent to the catalog (FR3.4)', () {
    test('a new language sends its own code', () async {
      final requests = <http.BaseRequest>[];
      await _searchNames(
        CatalogLocale.fromLanguageTag('fr'),
        const [],
        requests: requests,
      );
      final parameters = requests.single.url.queryParameters;
      expect(parameters['lc'], 'fr');
      expect(
        parameters['fields'],
        'code,product_name,product_name_fr,product_name_en,brands,'
        'categories_tags,origins',
      );
    });

    test('every interface language maps to its language code', () {
      for (final locale in appLocales) {
        final catalogLocale = CatalogLocale.fromLanguageTag(
          locale.toLanguageTag(),
        );
        expect(catalogLocale.offLanguage, locale.languageCode);
        expect(
          OpenFoodFactsSource.searchUri(
            'x',
            catalogLocale,
          ).queryParameters['lc'],
          locale.languageCode,
        );
      }
    });

    test('only the language is sent, never the country or the script', () {
      expect(CatalogLocale.fromLanguageTag('pt-PT').offLanguage, 'pt');
      expect(CatalogLocale.fromLanguageTag('pt-BR'), CatalogLocale.ptBR);
      expect(CatalogLocale.fromLanguageTag('sr-Cyrl-RS').offLanguage, 'sr');
      expect(CatalogLocale.fromLanguageTag('de_AT').offLanguage, 'de');
      expect(CatalogLocale.fromLanguageTag('EL').offLanguage, 'el');
    });

    test('a tag that is not a language falls back to English', () {
      expect(CatalogLocale.fromLanguageTag(''), CatalogLocale.en);
      expect(CatalogLocale.fromLanguageTag('12'), CatalogLocale.en);
      expect(CatalogLocale.fromLanguageTag('x&lc=it'), CatalogLocale.en);
      expect(CatalogLocale.fromLanguageTag('toolong'), CatalogLocale.en);
    });

    test('English asks for the English name once', () {
      expect(
        OpenFoodFactsSource.searchFields(CatalogLocale.en),
        'code,product_name,product_name_en,brands,categories_tags,origins',
      );
    });

    test('equal languages are equal values', () {
      final greek = CatalogLocale.fromLanguageTag('el');
      expect(greek, CatalogLocale.fromLanguageTag('el-GR'));
      expect(greek.hashCode, CatalogLocale.fromLanguageTag('el-GR').hashCode);
      expect(greek, isNot(CatalogLocale.en));
      expect('$greek', 'CatalogLocale(el)');
    });
  });

  group('texts of a product (FR3.4)', () {
    final greek = CatalogLocale.fromLanguageTag('el');

    test('the name in the language of the app is shown', () async {
      final names = await _searchNames(greek, [
        _wine({
          'product_name': 'Vin rouge',
          'product_name_el': 'Κόκκινο κρασί',
          'product_name_en': 'Red wine',
        }),
      ]);
      expect(names, ['Κόκκινο κρασί']);
    });

    test(
      'a product without texts in that language shows the English ones',
      () async {
        final names = await _searchNames(greek, [
          _wine({'product_name': 'Vin rouge', 'product_name_en': 'Red wine'}),
          _wine({
            'product_name': 'Vin blanc',
            'product_name_el': '   ',
            'product_name_en': 'White wine',
          }),
          _wine({
            'product_name': 'Vin doux',
            'product_name_el': 7,
            'product_name_en': 'Sweet wine',
          }),
        ]);
        expect(names, ['Red wine', 'White wine', 'Sweet wine']);
      },
    );

    test('without English texts either, the name without a language', () async {
      final names = await _searchNames(greek, [
        _wine({'product_name': 'Vin rouge'}),
      ]);
      expect(names, ['Vin rouge']);
    });

    test('a product without any name is left out', () async {
      final names = await _searchNames(greek, [
        _wine({'product_name_fr': 'Vin rouge'}),
        _wine({}),
      ]);
      expect(names, isEmpty);
    });

    test('a product read by barcode keeps the name without a language', () {
      final candidate = OpenFoodFactsSource.mapProduct(
        _wine({'product_name': 'Vin rouge', 'product_name_en': 'Red wine'}),
      );
      expect(candidate?.name, 'Vin rouge');
    });
  });
}
