import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/label/core/label_line_picker.dart';
import 'package:vinoozy/label/core/label_reading.dart';

void main() {
  const picker = LabelLinePicker();

  group('BR1.12 most significant line', () {
    test('BR1.12 the first line with a recognised denomination wins', () {
      const text = 'Tenuta Bellavista Superiore\nBarolo DOCG\n2016';
      expect(picker.pick(text), 'Barolo DOCG');
    });

    test('BR1.12 without a denomination, the longest line with 3 letters', () {
      final picked = const LabelLinePicker(isDenomination: _never)
          .pick('Rosso\nCantina dei Colli Alti\nIGT');
      expect(picked, 'Cantina dei Colli Alti');
    });

    test('BR1.12 numbers-only, volume, alcohol and sulphites lines are '
        'skipped', () {
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

    test("BR1.12 an Italian apostrophe is not a volume ('l')", () {
      const text = "Vino dell'amicizia\nRosso";
      expect(
        const LabelLinePicker(isDenomination: _never).pick(text),
        "Vino dell'amicizia",
      );
    });

    test('BR1.12 the line is cut to 120 characters', () {
      final long = '${'A' * 80} ${'B' * 80}';
      final picked = const LabelLinePicker(isDenomination: _never).pick(long);
      expect(picked.length, lessThanOrEqualTo(LabelLinePicker.maxLength));
      expect(picked, startsWith('A' * 80));
    });

    test('BR1.12 no valid line gives an empty name (BR1.11)', () {
      expect(picker.pick('750 ml\n13% vol\n2016'), '');
      expect(picker.pick(''), '');
    });

    test('BR1.12 spaces inside a line are collapsed', () {
      expect(
        const LabelLinePicker(isDenomination: _never)
            .pick('  Cantina    del   Lago  '),
        'Cantina del Lago',
      );
    });
  });

  group('BR1.11 readable text', () {
    test('BR1.11 fewer than 3 letters is nothing readable', () {
      expect(hasLetters('ab 12'), isFalse);
      expect(hasLetters('2016 75cl'), isFalse);
      expect(hasLetters('2016 Rosso'), isTrue);
      expect(hasLetters('àèì'), isTrue);
    });

    test('BR1.7 the text is cut to 2000 characters for matchLabelText', () {
      expect(LabelReading.clampText('x' * 2500).length, 2000);
      expect(LabelReading.clampText('short'), 'short');
    });

    test('BR1.14 a reading never prints its text nor codes', () {
      const reading = LabelReading(
        barcodes: [ReadBarcode(LabelBarcodeFormat.ean13, 'MARKER-888')],
        text: 'MARKER-TEXT',
      );
      expect(reading.toString(), isNot(contains('MARKER')));
      expect(reading.barcodes.single.toString(), isNot(contains('MARKER')));
      expect(
        reading.barcodes.single,
        const ReadBarcode(LabelBarcodeFormat.ean13, 'MARKER-888'),
      );
      expect(
        reading.barcodes.single.hashCode,
        const ReadBarcode(LabelBarcodeFormat.ean13, 'MARKER-888').hashCode,
      );
    });
  });
}

bool _never(String line) => false;
