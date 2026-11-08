import 'package:estimation/estimation.dart';
import 'package:estimation/src/recognizer.dart';
import 'package:estimation/src/tables.dart';
import 'package:test/test.dart';

void main() {
  group('normalisation (BR1.1)', () {
    test('lowercase, accents removed, apostrophes and punctuation split', () {
      expect(normalizeName("  Barbera d'Asti  "), 'barbera d asti');
      expect(normalizeName('NEBBIOLO D’ALBA'), 'nebbiolo d alba');
      expect(normalizeName('Rosé-Côtes, Ñandú!'), 'rose cotes nandu');
      expect(normalizeName('Vin Santo (2019)'), 'vin santo 2019');
    });

    test('blank or punctuation-only text has no words', () {
      expect(tokenize('   '), isEmpty);
      expect(tokenize("'-.,"), isEmpty);
    });

    test('only the first 60 characters are examined', () {
      final name = '${'x' * 59} barolo';
      expect(recognize(name), isNull);
      expect(normalizeName('a' * 70).length, maxNameLength);
    });
  });

  group('recognize (BR1.1)', () {
    test('finds a denomination and its type', () {
      final wine = recognize('Barolo Cannubi')!;
      expect(wine.denominationKey, 'barolo');
      expect(wine.wineType, WineType.redStructured);
      expect(wine.qualifier, isNull);
    });

    test('matches whole words only: "Castiglione" is not Asti', () {
      expect(recognize('Castiglione Falletto'), isNull);
      expect(recognize('Pastiglia'), isNull);
    });

    test('the alias with the most words wins', () {
      expect(
        recognize("Barbera d'Asti o Barolo")!.denominationKey,
        'barberaDAsti',
      );
      expect(recognize("Moscato d'Asti")!.denominationKey, 'asti');
      expect(
        recognize('Chianti Classico Riserva')!.denominationKey,
        'chiantiClassico',
      );
      expect(
        recognize('Amarone della Valpolicella')!.denominationKey,
        'amaroneDellaValpolicella',
      );
    });

    test('on a tie the first alias in the name wins', () {
      expect(recognize('Barolo o Barbaresco')!.denominationKey, 'barolo');
      expect(recognize('Barbaresco o Barolo')!.denominationKey, 'barbaresco');
    });

    test('a qualifier with its own offsets is recognised', () {
      expect(recognize('Barolo Riserva')!.qualifier, Qualifier.riserva);
      expect(
        recognize('Chianti Classico Gran Selezione')!.qualifier,
        Qualifier.granSelezione,
      );
      expect(
        recognize("Barbera d'Asti Superiore DOCG")!.qualifier,
        Qualifier.superiore,
      );
    });

    test('a qualifier without its own offsets is ignored', () {
      final wine = recognize('Barolo Superiore')!;
      expect(wine.denominationKey, 'barolo');
      expect(wine.qualifier, isNull);
    });

    test('words of the alias itself are not a qualifier', () {
      final wine = recognize('Valtellina Superiore')!;
      expect(wine.denominationKey, 'valtellinaSuperiore');
      expect(wine.qualifier, isNull);
      expect(
        recognize('Valtellina Superiore Riserva')!.qualifier,
        Qualifier.riserva,
      );
    });

    test('with two qualifiers the most specific with offsets wins', () {
      expect(
        recognize('Marsala Superiore Riserva')!.qualifier,
        Qualifier.riserva,
      );
      expect(recognize('Marsala Superiore')!.qualifier, Qualifier.superiore);
    });

    test('accented and apostrophised names are recognised', () {
      expect(
        recognize('MONTEPULCIANO D’ABRUZZO')!.denominationKey,
        'montepulcianoDAbruzzo',
      );
      expect(recognize('Vin Santo del Chianti')!.denominationKey, 'vinSanto');
      expect(recognize('Lagréin')!.denominationKey, 'lagrein');
    });

    test('no alias gives null', () {
      expect(recognize('Vino di Mario'), isNull);
      expect(recognize(''), isNull);
    });
  });

  group('alias index', () {
    test('indexes every alias under its first word, longest first', () {
      var aliases = 0;
      for (final entries in aliasIndex.values) {
        aliases += entries.length;
        for (var i = 1; i < entries.length; i++) {
          expect(
            entries[i - 1].words.length,
            greaterThanOrEqualTo(entries[i].words.length),
          );
        }
      }
      // label-autofill-windows: a row's forms are its display name (world
      // and generated rows) and its aliases.
      final expected = denominationTable.values.fold<int>(
        0,
        (sum, row) => sum + formsOf(row).length,
      );
      expect(aliases, expected);
    });

    test('a rebuilt index has the same content and cannot be modified', () {
      final rebuilt = buildAliasIndex();
      expect(rebuilt.keys.toSet(), aliasIndex.keys.toSet());
      expect(
        () => rebuilt['barolo'] = const [],
        throwsA(isA<UnsupportedError>()),
      );
      expect(
        () => rebuilt['barolo']!.add(const AliasEntry(['x'], 'barolo')),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });

  group('resolveWine precedences (BR1.2, BR1.7)', () {
    test("the user's denomination wins over the name", () {
      final resolved = resolveWine(
        const WineFacts(
          name: 'Barolo',
          denomination: 'Barbaresco DOCG',
          vintage: 2018,
        ),
        null,
      );
      expect(resolved.basis, EstimationBasis.denomination);
      expect(resolved.denomination, same(denominationTable['barbaresco']));
    });

    test('an unknown user denomination falls back to the name', () {
      // "Langhe" became a row of the world tables (label-autofill-windows):
      // a text that is in no table keeps the meaning of this test.
      final resolved = resolveWine(
        const WineFacts(
          name: 'Barolo',
          denomination: 'Vigna del nonno',
          vintage: 2018,
        ),
        null,
      );
      expect(resolved.denomination, same(denominationTable['barolo']));
    });

    test("a qualifier is read from the user's denomination text", () {
      final resolved = resolveWine(
        const WineFacts(
          name: 'Cannubi',
          denomination: 'Barolo Riserva',
          vintage: 2016,
        ),
        null,
      );
      expect(resolved.qualifier, Qualifier.riserva);
    });

    test('a user type different from the recognised one discards it', () {
      final resolved = resolveWine(
        const WineFacts(
          name: 'Barolo bianco della casa',
          wineType: WineType.white,
          vintage: 2024,
        ),
        null,
      );
      expect(resolved.basis, EstimationBasis.wineType);
      expect(resolved.wineType, WineType.white);
      expect(resolved.denomination, isNull);
    });

    test('a user type equal to the recognised one keeps the denomination', () {
      final resolved = resolveWine(
        const WineFacts(
          name: 'Barolo',
          wineType: WineType.redStructured,
          vintage: 2016,
        ),
        null,
      );
      expect(resolved.basis, EstimationBasis.denomination);
    });

    test('the catalog denomination wins over the name', () {
      final resolved = resolveWine(
        const WineFacts(name: 'Cuvée speciale', vintage: 2020),
        const ExternalProfile(denomination: 'Franciacorta DOCG'),
      );
      expect(resolved.denomination, same(denominationTable['franciacorta']));
    });

    test('the catalog type discards a name denomination of another type', () {
      final resolved = resolveWine(
        const WineFacts(name: 'Barolo rosé', vintage: 2024),
        const ExternalProfile(wineType: 'rose'),
      );
      expect(resolved.basis, EstimationBasis.wineType);
      expect(resolved.wineType, WineType.rose);
    });

    test('the user type wins over the catalog type', () {
      final resolved = resolveWine(
        const WineFacts(
          name: 'Cuvée',
          wineType: WineType.sparklingTank,
          vintage: 2024,
        ),
        const ExternalProfile(wineType: 'sparkling'),
      );
      expect(resolved.wineType, WineType.sparklingTank);
    });

    test('an unknown catalog type is absent and the name decides', () {
      final resolved = resolveWine(
        const WineFacts(name: 'Soave Classico', vintage: 2024),
        const ExternalProfile(wineType: 'orange', denomination: 'IGT'),
      );
      expect(resolved.denomination, same(denominationTable['soave']));
    });

    test('nothing known gives the generic row', () {
      final resolved = resolveWine(
        const WineFacts(name: 'Vino di Mario', vintage: 2022),
        null,
      );
      expect(resolved.basis, EstimationBasis.generic);
      expect(resolved.effectiveType, isNull);
      expect(resolved.offsets, same(genericTypeProfile.offsets));
    });
  });
}
