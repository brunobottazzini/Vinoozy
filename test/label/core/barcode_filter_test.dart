import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/label/core/barcode_filter.dart';
import 'package:vinoozy/label/core/label_reading.dart';

import '../label_harness.dart';

void main() {
  const filter = BarcodeFilter();
  ReadBarcode code(LabelBarcodeFormat format, String value) =>
      ReadBarcode(format, value);

  group('BR1.7 accepted barcodes', () {
    test('BR1.7 an EAN-13 with a right check digit is used as it is', () {
      expect(
        filter.firstValid([code(LabelBarcodeFormat.ean13, testEan13)]),
        testEan13,
      );
    });

    test('BR1.7 an EAN-8 keeps its 8 digits', () {
      expect(
        filter.firstValid([code(LabelBarcodeFormat.ean8, testEan8)]),
        testEan8,
      );
    });

    test('BR1.7 a UPC-A becomes 13 digits with normalizeBarcode of U3', () {
      expect(
        filter.firstValid([code(LabelBarcodeFormat.upcA, testUpcA)]),
        '0$testUpcA',
      );
    });

    test('BR1.7 a wrong check digit, letters or a bad length are skipped', () {
      expect(
        filter.firstValid([
          code(LabelBarcodeFormat.ean13, '8001234567890'),
          code(LabelBarcodeFormat.ean13, '80012345678AB'),
          code(LabelBarcodeFormat.ean13, '12345'),
          code(LabelBarcodeFormat.ean8, testEan13),
        ]),
        isNull,
      );
    });

    test('BR1.7 other formats (QR, Code 128) are ignored', () {
      expect(
        filter.firstValid([code(LabelBarcodeFormat.other, testEan13)]),
        isNull,
      );
    });

    test('BR1.7 the first valid code wins', () {
      expect(
        filter.firstValid([
          code(LabelBarcodeFormat.other, 'https://example.org'),
          code(LabelBarcodeFormat.ean13, '8001234567890'),
          code(LabelBarcodeFormat.ean8, testEan8),
          code(LabelBarcodeFormat.ean13, testEan13),
        ]),
        testEan8,
      );
    });

    test('BR1.7 no code gives null', () {
      expect(filter.firstValid(const []), isNull);
    });

    test('BR1.7 GS1 check digit', () {
      expect(BarcodeFilter.hasValidCheckDigit(testEan13), isTrue);
      expect(BarcodeFilter.hasValidCheckDigit(testEan8), isTrue);
      expect(BarcodeFilter.hasValidCheckDigit('0$testUpcA'), isTrue);
      expect(BarcodeFilter.hasValidCheckDigit('96385075'), isFalse);
    });
  });
}
