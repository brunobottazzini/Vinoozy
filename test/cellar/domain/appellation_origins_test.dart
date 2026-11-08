// BR3.5 (label-autofill-windows): the world tables of the estimation package
// and the origins of the app stay coherent, row by row; the origin guess of
// WineOrigins reads the package table, the only source.
import 'package:estimation/estimation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/cellar/domain/wine_origins.dart';

void main() {
  test('every row has an ISO country and a region of that country or none '
      '(BR3.5)', () {
    final wrong = <String>[];
    for (final info in appellations) {
      if (!WineOrigins.isCountryCode(info.country)) {
        wrong.add('${info.key}: country ${info.country}');
        continue;
      }
      final region = info.region;
      if (region == null) continue;
      final listed = WineOrigins.findRegion(info.country, region);
      if (listed == null || listed.canonical != region) {
        wrong.add('${info.key}: region $region of ${info.country}');
      }
    }
    expect(wrong, isEmpty);
  });

  test('every foreign dedicated row has its country in the origin grid or '
      'in the full list (FR3.4)', () {
    for (final info in appellations.where((a) => a.dedicated)) {
      expect(WineOrigins.country(info.country), isNotNull, reason: info.key);
    }
  });

  group('guess reads the package table', () {
    test('world denominations give country and region', () {
      expect(
        WineOrigins.guess(name: 'Château Meyney Saint-Estèphe'),
        const OriginGuess(country: 'FR', region: 'Bordeaux'),
      );
      expect(
        WineOrigins.guess(denomination: 'Mendoza'),
        const OriginGuess(country: 'AR', region: 'Mendoza'),
      );
      expect(
        WineOrigins.guess(name: 'Bandol Rouge'),
        const OriginGuess(country: 'FR', region: 'Provence'),
      );
      expect(
        WineOrigins.guess(name: 'Vintage Port 2017'),
        const OriginGuess(country: 'PT', region: 'Douro'),
      );
    });

    test('a weak word counts in the denomination field, not in a name', () {
      expect(
        WineOrigins.guess(denomination: 'Toro'),
        const OriginGuess(country: 'ES', region: 'Toro'),
      );
      expect(WineOrigins.guess(name: 'Toro Loco'), OriginGuess.none);
      expect(WineOrigins.guess(name: 'Orange Wine'), OriginGuess.none);
    });

    test('the weak names known before keep working in names', () {
      expect(
        WineOrigins.guess(name: 'Napa Cabernet'),
        const OriginGuess(country: 'US', region: 'Napa Valley'),
      );
      expect(
        WineOrigins.guess(name: 'Cava Brut Nature'),
        const OriginGuess(country: 'ES', region: 'Penedès'),
      );
    });

    test('a generated row without a region gives its country', () {
      final generated = appellations.firstWhere(
        (a) => !a.dedicated && a.region == null && a.weakForms.isEmpty,
      );
      expect(
        WineOrigins.guess(denomination: generated.displayName).country,
        generated.country,
      );
    });

    test('label names of countries in more languages (D1)', () {
      expect(WineOrigins.countryNamed('Afrique du Sud')!.code, 'ZA');
      expect(WineOrigins.countryNamed('Neuseeland')!.code, 'NZ');
    });
  });
}
