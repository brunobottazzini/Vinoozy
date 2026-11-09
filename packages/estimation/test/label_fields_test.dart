// extractLabelFields (label-autofill-windows D1, BR1.1-BR1.10, NFR3.4): the
// reference set of test/fixtures/label_texts.json, its thresholds, and the
// rules one by one.
import 'dart:convert';
import 'dart:io';

import 'package:estimation/estimation.dart';
import 'package:test/test.dart';

const _fields = [
  'name',
  'producer',
  'denomination',
  'vintage',
  'wineType',
  'country',
  'region',
  'suggestedLevel',
];

Object? _valueOf(LabelFields fields, String field) => switch (field) {
  'name' => fields.name,
  'producer' => fields.producer,
  'denomination' => fields.denomination,
  'vintage' => fields.vintage,
  'wineType' => fields.wineType?.name,
  'country' => fields.country,
  'region' => fields.region,
  'suggestedLevel' => fields.suggestedLevel?.name,
  _ => throw ArgumentError(field),
};

LabelFields _read(String text) => extractLabelFields(text, currentYear: 2026);

void main() {
  final fixture = jsonDecode(
    File('test/fixtures/label_texts.json').readAsStringSync(),
  ) as Map<String, Object?>;
  final year = fixture['currentYear']! as int;
  final texts = [
    for (final raw in fixture['texts']! as List<Object?>)
      raw! as Map<String, Object?>,
  ];

  group('reference set (BR1.10)', () {
    test('at least 30 texts in 6 languages', () {
      expect(texts.length, greaterThanOrEqualTo(30));
      expect(
        {for (final t in texts) t['lang']},
        {'it', 'fr', 'es', 'en', 'de', 'pt'},
      );
    });

    for (final entry in texts) {
      test('${entry['id']}: every field as expected, none invented', () {
        final fields = extractLabelFields(
          entry['text']! as String,
          currentYear: year,
        );
        final expected = entry['expected']! as Map<String, Object?>;
        for (final field in _fields) {
          expect(
            _valueOf(fields, field),
            expected[field],
            reason: '${entry['id']} $field',
          );
        }
      });
    }

    test('thresholds: 0 wrong fields, name and vintage >= 90%, '
        'denomination >= 80%', () {
      var wrong = 0;
      final filled = {'name': 0, 'vintage': 0, 'denomination': 0};
      final present = {'name': 0, 'vintage': 0, 'denomination': 0};
      for (final entry in texts) {
        final fields = extractLabelFields(
          entry['text']! as String,
          currentYear: year,
        );
        final expected = entry['expected']! as Map<String, Object?>;
        final contains = (entry['contains'] as Map<String, Object?>?) ?? {};
        for (final field in _fields) {
          final value = _valueOf(fields, field);
          if (value != null && value != expected[field]) wrong++;
        }
        for (final field in filled.keys) {
          final holds =
              (contains[field] as bool?) ?? expected.containsKey(field);
          if (!holds) continue;
          present[field] = present[field]! + 1;
          if (_valueOf(fields, field) != null) {
            filled[field] = filled[field]! + 1;
          }
        }
      }
      expect(wrong, 0);
      expect(filled['name']! / present['name']!, greaterThanOrEqualTo(0.9));
      expect(
        filled['vintage']! / present['vintage']!,
        greaterThanOrEqualTo(0.9),
      );
      expect(
        filled['denomination']! / present['denomination']!,
        greaterThanOrEqualTo(0.8),
      );
    });
  });

  group('BR1.1 lines and service lines', () {
    test(
      'volume, alcohol, sulphites, barcodes, links and lots are dropped',
      () {
        final fields = _read(
          'Contiene solfiti\n750 ml\n13,5% vol\n8001234567890\n'
          'www.esempio.it\nL.12345\nContains sulfites',
        );
        expect(fields.isEmpty, isTrue);
      },
    );

    test('lines split on "·" and "|" as on Lens', () {
      final fields = _read('Barolo · Denominazione di Origine | Vietti · 2016');
      expect(fields.denomination, 'Barolo DOCG');
      expect(fields.vintage, 2016);
    });

    test('an empty or blank text gives nothing', () {
      expect(_read('').isEmpty, isTrue);
      expect(_read('   \n \n').isEmpty, isTrue);
      expect(LabelFields.empty.sourceKeys, isEmpty);
    });
  });

  group('BR1.2 weak aliases', () {
    test('"Toro" alone is not a denomination, next to an indicator it is', () {
      expect(_read('Toro Loco\nVino tinto').denomination, isNull);
      expect(
        _read('Bodega Ejemplo\nToro\nDenominación de Origen').denomination,
        'Toro',
      );
    });

    test('a weak alias counts next to its country name', () {
      expect(_read('Cava\nProduct of Spain').denomination, 'Cava');
      expect(_read('Cava\nProduct of Italy').denomination, isNull);
    });

    test('a dotted indicator counts ("D.O.C.G.")', () {
      expect(_read('Toro\nD.O.').denomination, 'Toro');
    });

    test('a word outside the tables never becomes a denomination', () {
      expect(_read('Vigna del Nonno\nIGT').denomination, isNull);
    });

    test('the longest alias wins: "Crémant d\'Alsace" before "Alsace"', () {
      expect(_read("Crémant d'Alsace").denominationKey, 'cremantDAlsace');
    });
  });

  group('BR1.3 vintage', () {
    test('a founding year is skipped, the vintage kept', () {
      expect(_read('Fondata nel 1898\nBarolo 2016').vintage, 2016);
      expect(_read('Since 1890\nNapa Valley 2019').vintage, 2019);
      expect(_read('Gegründet 1850\nRiesling 2020').vintage, 2020);
    });

    test('several years: a vintage word decides, otherwise empty', () {
      expect(_read('Vendemmia 2018\nPremio 2020').vintage, 2018);
      expect(_read('Rosso 2018 2019').vintage, isNull);
      expect(_read('Cosecha 2015\nMedalla 2017').vintage, 2015);
    });

    test('the same year twice is that year; next year is accepted', () {
      expect(_read('Barolo 2016\nVintage 2016').vintage, 2016);
      expect(_read('Novello 2027').vintage, 2027);
      expect(_read('Barolo 2028').vintage, isNull);
      expect(_read('Barolo 1899').vintage, isNull);
    });
  });

  group('BR1.4 producer', () {
    test('after a bottling phrase, up to the comma', () {
      expect(
        _read('Barolo\nImbottigliato da Cantina Rossi, Barolo').producer,
        'Cantina Rossi',
      );
      expect(
        _read('Abgefüllt von Weingut Keller, Flörsheim').producer,
        'Weingut Keller',
      );
    });

    test('else the first line with a producer word', () {
      expect(_read('Tenuta San Guido\nBolgheri').producer, 'Tenuta San Guido');
    });

    test('a founding line is never the producer', () {
      expect(_read('Cantina fondata nel 1898\nBarolo').producer, isNull);
    });

    test('at most 80 characters', () {
      final long = 'Tenuta ${'x' * 100}';
      expect(_read(long).producer!.length, lessThanOrEqualTo(80));
    });
  });

  group('BR1.6 type', () {
    test('colour and style words', () {
      expect(_read('Vino Rosato').wineType, WineType.rose);
      expect(_read('Bianco della casa').wineType, WineType.white);
      expect(_read('Prosecco Spumante').wineType, WineType.sparklingTank);
      expect(
        _read('Spumante Metodo Classico').wineType,
        WineType.sparklingClassic,
      );
      expect(_read('Passito di casa').wineType, WineType.sweet);
      expect(_read('Sherry fino').wineType, WineType.fortified);
    });

    test('a red with an aging qualifier is structured', () {
      expect(_read('Rosso Riserva').wineType, WineType.redStructured);
      expect(_read('Rosso della casa').wineType, WineType.redLight);
    });

    test('without words: the only type of the row, then the grape', () {
      expect(_read('Barolo').wineType, WineType.redStructured);
      expect(_read('Merlot').wineType, WineType.redLight);
      expect(_read('Chardonnay\nNapa Valley').wineType, WineType.white);
      expect(_read('Napa Valley').wineType, isNull);
    });

    test('"Grande" is not "gran": no structured red', () {
      expect(_read('Grande Rosso').wineType, WineType.redLight);
    });
  });

  group('BR1.7 country and region', () {
    test('from the denomination', () {
      final fields = _read('Rioja\nDOCa');
      expect(fields.country, 'ES');
      expect(fields.region, 'Rioja');
    });

    test('from "product of" phrases in six languages', () {
      expect(_read('Vino X\nProdotto in Italia').country, 'IT');
      expect(_read('Vin X\nProduit de France').country, 'FR');
      expect(_read('Vino X\nProducto de Chile').country, 'CL');
      expect(_read('Vinho X\nProduto de Portugal').country, 'PT');
      expect(_read('Wein X\nWein aus Österreich').country, 'AT');
      expect(_read('Wine X\nWine of South Africa').country, 'ZA');
      expect(_read('Wine X\nProduct of the USA').country, 'US');
    });

    test('a grape never gives a country', () {
      final fields = _read('Malbec');
      expect(fields.country, isNull);
      expect(fields.region, isNull);
    });
  });

  group('BR1.8 qualifiers and suggested level', () {
    const cases = {
      'Chianti Classico Gran Selezione': Qualifier.granSelezione,
      'Rioja Gran Reserva': Qualifier.granReserva,
      'Margaux Grand Cru Classé': Qualifier.grandCru,
      'Saint-Émilion Premier Grand Cru Classé': Qualifier.premierCru,
      'Chablis 1er Cru': Qualifier.premierCru,
      'Barolo Riserva': Qualifier.riserva,
      'Douro Reserva': Qualifier.reserva,
      'Napa Valley Reserve': Qualifier.reserva,
      'Rioja Crianza': Qualifier.crianza,
      'Soave Superiore': Qualifier.superiore,
      // wine-style-profiles BR2.6: BA is its own category, never Auslese.
      'Riesling Beerenauslese': Qualifier.beerenauslese,
      'Riesling Spätlese': Qualifier.spatlese,
      'Riesling Kabinett': Qualifier.kabinett,
      'Late Bottled Vintage Port': Qualifier.lbv,
      'Porto Colheita': Qualifier.colheita,
      'Vintage Port': Qualifier.vintage,
    };
    for (final MapEntry(key: text, value: qualifier) in cases.entries) {
      test('"$text" gives ${qualifier.name}', () {
        final fields = _read(text);
        expect(fields.qualifier, qualifier);
        expect(
          fields.suggestedLevel,
          suggestsAgingLevel(qualifier, fields.denominationKey)
              ? WineLevel.aging
              : isNull,
        );
      });
    }

    test('"vintage" counts only where the row has it', () {
      expect(_read('Napa Valley\nVintage 2019').qualifier, isNull);
    });
  });

  group('BR1.9 and NFR3.4: untrusted text', () {
    test('a name over 60 characters is cut at a word', () {
      final fields = _read('Tignanello ${'Selezione ' * 10}\nIGT Toscana');
      expect(fields.name!.length, lessThanOrEqualTo(60));
    });

    test('control characters, unusual spaces and tags are removed', () {
      final clean = sanitizeLabelText(
        'Bar\u0000olo\u0007 DOCG​<b>2016</b>\r\nVietti',
      );
      expect(clean, isNot(contains('\u0000')));
      expect(clean, isNot(contains('​')));
      expect(clean, isNot(contains('<b>')));
      expect(clean, contains('\n'));
      final fields = _read('<script>Barolo</script>\u0000\n2016');
      expect(fields.vintage, 2016);
    });

    test('the text is cut to 4000 characters, never a broken surrogate', () {
      final long = '${'a' * 3999}🍷 Barolo';
      final clean = sanitizeLabelText(long);
      expect(clean.length, lessThanOrEqualTo(maxLabelTextLength));
      expect(
        clean.codeUnitAt(clean.length - 1),
        isNot(inInclusiveRange(0xD800, 0xDBFF)),
      );
      expect(sanitizeLabelText('x' * 10000), hasLength(maxLabelTextLength));
    });

    test('a huge text with only noise gives nothing and does not fail', () {
      final noise = List.filled(5000, r'%$#@!').join('\n');
      expect(_read(noise).isEmpty, isTrue);
    });

    test('the string form never holds the text (NFR3.2)', () {
      final fields = _read('Barolo\nRavera\n2016');
      expect(fields.toString(), isNot(contains('Ravera')));
      expect(fields.toString(), contains('name'));
    });
  });
}
