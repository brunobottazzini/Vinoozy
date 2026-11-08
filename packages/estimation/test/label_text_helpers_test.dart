// VintageParser and LabelLinePicker, moved here from lib/label/core by
// label-autofill-windows (D1) with their tests: the behaviour of the label
// photo (u6, label-recognition BR1.8, BR1.11, BR1.12) is unchanged.
import 'package:estimation/estimation.dart';
import 'package:test/test.dart';

bool _never(String line) => false;

void main() {
  const parser = VintageParser();
  int? parse(String text) => parser.parse(text, currentYear: 2026);

  group('VintageParser, photo reading (ambiguousAsNull false)', () {
    test('one year between 1900 and this year', () {
      expect(parse('Barolo DOCG 2016'), 2016);
      expect(parse('Vendemmia 1900'), 1900);
      expect(parse('Annata 2026'), 2026);
    });

    test('a future year or one before 1900 is not a vintage', () {
      expect(parse('Barolo 2031'), isNull);
      expect(parse('Barolo 1899'), isNull);
    });

    test('a year inside a longer number is not a vintage', () {
      expect(parse('Lotto 120162 L.2016.3'), isNull);
      expect(parse('Codice 20161'), isNull);
      expect(parse('13,5% vol 750 ml'), isNull);
    });

    test('a founding year is skipped', () {
      expect(parse('Cantina dal 1952\nBarolo 2016'), 2016);
      expect(parse('Since 1890'), isNull);
      expect(parse('Fondata nel 1975 Rosso 2020'), 2020);
    });

    test('with several years, the one closest to a vintage word', () {
      expect(parse('Premio 2022\nVendemmia 2018'), 2018);
      expect(parse('2019 harvest, awarded 2023'), 2019);
    });

    test('several years and no vintage word: the most recent', () {
      expect(parse('2015 2019 2017'), 2019);
    });

    test('a tie on distance keeps the most recent', () {
      expect(parse('2015 DOC 2017'), 2017);
      expect(parse('2017 DOC 2015'), 2017);
    });
  });

  group('VintageParser, text of the form (ambiguousAsNull, BR1.3)', () {
    int? strict(String text) =>
        parser.parse(text, currentYear: 2026, ambiguousAsNull: true);

    test('one year, next year included', () {
      expect(strict('Barolo 2016'), 2016);
      expect(strict('Novello 2027'), 2027);
      expect(strict('Barolo 2028'), isNull);
    });

    test('founding years on their line are skipped', () {
      expect(strict('Depuis 1902\nBordeaux 2019'), 2019);
      expect(strict('Seit 1921 Riesling'), isNull);
      expect(strict('Fundada em 1930\nsafra 2023'), 2023);
    });

    test('a vintage word strictly closest decides, else empty', () {
      expect(strict('Millésime 2015 · 2018'), 2015);
      expect(strict('2015 Jahrgang 2018'), isNull);
      expect(strict('2015 2018'), isNull);
      expect(strict(''), isNull);
    });
  });

  group('LabelLinePicker (BR1.12)', () {
    const picker = LabelLinePicker();

    test('the first line with a recognised denomination wins', () {
      expect(
        picker.pick('Tenuta Bellavista Superiore\nBarolo DOCG\n2016'),
        'Barolo DOCG',
      );
    });

    test('without a denomination, the longest line with 3 letters', () {
      expect(
        const LabelLinePicker(isDenomination: _never)
            .pick('Rosso\nCantina dei Colli Alti\nIGT'),
        'Cantina dei Colli Alti',
      );
    });

    test('numbers, volume, alcohol and sulphites lines are skipped', () {
      const text =
          '0123456789 1234567890 1234\n'
          'Bottiglia da 750 ml prodotta in Italia\n'
          'Alcool 13,5% vol imbottigliato all origine\n'
          'Contiene solfiti e altri allergeni presenti\n'
          'Contains sulphites\n'
          'Contém sulfitos\n'
          'Vino Rosso';
      expect(
        const LabelLinePicker(isDenomination: _never).pick(text),
        'Vino Rosso',
      );
    });

    test('cut to 120 characters, spaces collapsed, empty when nothing', () {
      final long = '${'A' * 80} ${'B' * 80}';
      expect(
        const LabelLinePicker(isDenomination: _never).pick(long).length,
        lessThanOrEqualTo(LabelLinePicker.maxLength),
      );
      expect(
        const LabelLinePicker(isDenomination: _never).pick('  Lago    Blu  '),
        'Lago Blu',
      );
      expect(picker.pick('750 ml\n13% vol\n2016'), '');
    });

    test('longest() ignores denominations and returns null when none', () {
      expect(
        picker.longest(['Rosso', 'Cantina dei Colli']),
        'Cantina dei Colli',
      );
      expect(picker.longest(['750 ml', '2016']), isNull);
    });

    test('hasLetters needs 3 letters by default', () {
      expect(hasLetters('ab 12'), isFalse);
      expect(hasLetters('2016 Rosso'), isTrue);
      expect(hasLetters('àèì'), isTrue);
      expect(hasLetters('a', minLetters: 1), isTrue);
    });
  });

  group('agingQualifierIn, the level suggested by a typed name (FR4.3)', () {
    test('an aging qualifier suggests it, whatever the case', () {
      expect(agingQualifierIn('Chianti Classico Riserva'), Qualifier.riserva);
      expect(agingQualifierIn('RIOJA GRAN RESERVA'), Qualifier.granReserva);
      expect(agingQualifierIn('Chablis 1er Cru'), Qualifier.premierCru);
      expect(agingQualifierIn('Riesling Spätlese'), Qualifier.spatlese);
    });

    test('the most specific qualifier wins (BR1.8)', () {
      expect(
        agingQualifierIn('Chianti Classico Gran Selezione Riserva'),
        Qualifier.granSelezione,
      );
      // "Crianza" comes before "Superiore" and does not suggest "aging".
      expect(agingQualifierIn('Rioja Crianza Superiore'), isNull);
    });

    test('a qualifier that does not suggest aging gives nothing', () {
      expect(agingQualifierIn('Rioja Crianza'), isNull);
      expect(agingQualifierIn('Valpolicella Superiore'), isNull);
      expect(agingQualifierIn('Mosel Kabinett'), isNull);
    });

    test('"Vintage" counts only for an appellation that has it', () {
      expect(agingQualifierIn('Vinho do Porto Vintage'), Qualifier.vintage);
      expect(agingQualifierIn('Vintage Barolo'), isNull);
      expect(agingQualifierIn('Vintage Collection'), isNull);
    });

    test('no qualifier, empty text or whole words only', () {
      expect(agingQualifierIn(''), isNull);
      expect(agingQualifierIn('   '), isNull);
      expect(agingQualifierIn('Barolo'), isNull);
      expect(agingQualifierIn('Riservato'), isNull);
    });
  });
}
