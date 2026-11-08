// The read-only view of the appellations (label-autofill-windows BR3.5,
// BR3.6), the parser of the generated rows and the country names (BR1.7).
import 'package:estimation/estimation.dart';
import 'package:estimation/src/country_names.dart';
import 'package:estimation/src/tables.dart';
import 'package:test/test.dart';

void main() {
  group('parseGeneratedRow (BR3.6, BR3.7)', () {
    test('a full row', () {
      final row = parseGeneratedRow(
        'langheIT|Langhe|IT|Piemonte|IT-DOC|redLight,white|langa;langhe doc|langa',
      )!;
      expect(row.key, 'langheIT');
      expect(row.name, 'Langhe');
      expect(row.country, 'IT');
      expect(row.region, 'Piemonte');
      expect(row.templateKey, 'IT-DOC');
      expect(row.types, [WineType.redLight, WineType.white]);
      expect(row.offsets, const YearOffsets(1, 3, 6));
      expect(row.offsetsFor(WineType.white), const YearOffsets(1, 2, 5));
      expect(row.aliases, ['langa', 'langhe doc']);
      expect(row.weakAliases, ['langa']);
      expect(row.dedicated, isFalse);
    });

    test('an empty region and lists read as none', () {
      final row = parseGeneratedRow('xUS|X|US||NEW-WORLD|redLight||')!;
      expect(row.region, isNull);
      expect(row.aliases, isEmpty);
      expect(row.weakAliases, isEmpty);
    });

    test('types the model lacks are dropped; none left is no row', () {
      final row = parseGeneratedRow('xCH|X|CH||CH|sweet,white||')!;
      expect(row.types, [WineType.white]);
      expect(parseGeneratedRow('xCH|X|CH||CH|sweet||'), isNull);
      expect(parseGeneratedRow('xCH|X|CH||CH|red||'), isNull);
    });

    test('malformed rows are refused', () {
      expect(parseGeneratedRow('only|three|fields'), isNull);
      expect(parseGeneratedRow('|X|IT||IT-DOC|white||'), isNull);
      expect(parseGeneratedRow('k||IT||IT-DOC|white||'), isNull);
      expect(parseGeneratedRow('k|X|ITA||IT-DOC|white||'), isNull);
      expect(parseGeneratedRow('k|X|IT||NOPE|white||'), isNull);
    });
  });

  group('appellations view (BR3.5)', () {
    test('one entry per table row, in table order', () {
      expect(appellations.map((a) => a.key), denominationTable.keys);
    });

    test('an Italian row has its catalog name and region', () {
      final barolo = appellationOf('barolo')!;
      expect(barolo.displayName, 'Barolo DOCG');
      expect(barolo.country, 'IT');
      expect(barolo.region, 'Piemonte');
      expect(barolo.dedicated, isTrue);
      expect(barolo.types, [WineType.redStructured]);
      expect(barolo.forms, contains('barolo'));
      expect(barolo.toString(), contains('barolo'));
    });

    test('a world row has its name, types and weak forms', () {
      final napa = appellationOf('napaValley')!;
      expect(napa.displayName, 'Napa Valley');
      expect(napa.country, 'US');
      expect(napa.types, [WineType.redStructured, WineType.white]);
      expect(napa.weakForms, {'napa'});
      expect(appellationOf('nope'), isNull);
      expect(appellationOf(null), isNull);
    });

    test('findAppellation: longest form, weak forms only when asked', () {
      expect(findAppellation('Chablis Premier Cru')!.key, 'chablis');
      expect(findAppellation('Toro Loco')!.key, 'toro');
      expect(findAppellation('Toro Loco', includeWeak: false), isNull);
      expect(
        findAppellation('Vinho do Porto', includeWeak: false)!.key,
        'porto',
      );
      expect(findAppellation('   '), isNull);
      expect(findAppellation('Vigna del nonno'), isNull);
    });

    test('grape forms are known and never a denomination', () {
      expect(grapeForms, containsAll(['malbec', 'cabernet sauvignon']));
      for (final form in grapeForms) {
        expect(findAppellation(form), isNull, reason: form);
      }
    });
  });

  group('country names (BR1.7)', () {
    test('names in six languages and the native ones', () {
      expect(countryCodeOfName('Italia'), 'IT');
      expect(countryCodeOfName('Deutschland'), 'DE');
      expect(countryCodeOfName('Afrique du Sud'), 'ZA');
      expect(countryCodeOfName('ESPAÑA'), 'ES');
      expect(countryCodeOfName('Neverland'), isNull);
    });

    test('codes of the names in a list of words', () {
      expect(countryCodesIn(['product', 'of', 'new', 'zealand']), {'NZ'});
      expect(countryCodesIn(['wine', 'of', 'the', 'usa']), {'US'});
      expect(countryCodesIn(['nothing']), isEmpty);
    });
  });
}
