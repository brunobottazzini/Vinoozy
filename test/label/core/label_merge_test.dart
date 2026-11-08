// Front and back merged (label-recognition FR1.2, BR1.2, BR1.3, BR1.5):
// repeated lines, the 2000/4000 limits, the barcode side and the unreadable
// cases.
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/label/core/label_merge.dart';
import 'package:vinoozy/label/core/label_reading.dart';

import '../label_harness.dart';

LabelReading _reading(String text, [List<String> codes = const []]) =>
    LabelReading(
      text: text,
      barcodes: [
        for (final code in codes) ReadBarcode(LabelBarcodeFormat.ean13, code),
      ],
    );

/// Another valid EAN-13 (check digit 3).
const _otherEan13 = '8001234500016';

void main() {
  group('BR1.2 text', () {
    test('BR1.2 front lines, then the back lines not already there '
        '(no capitals, accents or double spaces)', () {
      final merged = mergeLabelReadings(
        front: _reading('CHÂTEAU MUSAR\n2015'),
        back: _reading('Chateau  Musar\nBekaa Valley\n2015\nLebanon'),
        backTaken: true,
      );
      expect(merged.text, 'CHÂTEAU MUSAR\n2015\nBekaa Valley\nLebanon');
      expect(merged.backStatus, BackStatus.taken);
    });

    test('BR1.2 at most 2000 characters per photo and 4000 in all', () {
      final merged = mergeLabelReadings(
        front: _reading('a' * 2500),
        back: _reading('b' * 2500),
        backTaken: true,
      );
      expect(merged.text.length, 2000 + 1 + 1999);
      expect(merged.text.length, lessThanOrEqualTo(MergedReading.maxText));
      expect(merged.text.split('\n').first, 'a' * 2000);
    });

    test('BR1.6 no back photo: the front alone, back skipped', () {
      final merged = mergeLabelReadings(front: _reading('Barolo'));
      expect(merged.text, 'Barolo');
      expect(merged.backStatus, BackStatus.skipped);
      expect(merged.isUnreadable, isFalse);
    });
  });

  group('BR1.3 barcode', () {
    test('BR1.3 a code only on the back is used', () {
      final merged = mergeLabelReadings(
        front: _reading('Barolo Ravera'),
        back: _reading('Elvio Cogno', [testEan13]),
        backTaken: true,
      );
      expect(merged.barcode, testEan13);
      expect(merged.barcodeSide, BarcodeSide.back);
    });

    test('BR1.3 two different valid codes: the front wins', () {
      final merged = mergeLabelReadings(
        front: _reading('Barolo', [_otherEan13]),
        back: _reading('Retro', [testEan13]),
        backTaken: true,
      );
      expect(merged.barcode, _otherEan13);
      expect(merged.barcodeSide, BarcodeSide.front);
    });

    test('BR1.3 an invalid code on the front gives way to the back', () {
      final merged = mergeLabelReadings(
        front: _reading('Barolo', ['8001234567890']),
        back: _reading('', [testEan13]),
        backTaken: true,
      );
      expect(merged.barcode, testEan13);
    });
  });

  group('BR1.5 unreadable photos', () {
    test('BR1.5 a back without text or code, or a failed reading, is '
        '"Retro non leggibile" and the front goes on', () {
      for (final back in [_reading('· ·'), null]) {
        final merged = mergeLabelReadings(
          front: _reading('Barolo Ravera', [testEan13]),
          back: back,
          backTaken: true,
        );
        expect(merged.backStatus, BackStatus.unreadable);
        expect(merged.text, 'Barolo Ravera');
        expect(merged.barcode, testEan13);
      }
    });

    test('BR1.5 an unreadable front with a readable back uses the back', () {
      final merged = mergeLabelReadings(
        front: null,
        back: _reading('Elvio Cogno', [testEan13]),
        backTaken: true,
      );
      expect(merged.text, 'Elvio Cogno');
      expect(merged.barcodeSide, BarcodeSide.back);
      expect(merged.isUnreadable, isFalse);
    });

    test('BR1.5 both unreadable: unreadable', () {
      final merged = mergeLabelReadings(
        front: _reading('12'),
        back: _reading(''),
        backTaken: true,
      );
      expect(merged.isUnreadable, isTrue);
      expect(merged.toString(), isNot(contains('12')));
    });
  });
}
