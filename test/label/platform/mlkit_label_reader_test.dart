import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/label/core/label_reading.dart';
import 'package:vinoozy/label/platform/mlkit_label_reader.dart';

import '../label_harness.dart';

class _MockText extends Mock implements TextRecognizer {}

class _MockBarcodes extends Mock implements BarcodeScanner {}

class _FakeInputImage extends Fake implements InputImage {}

TextBlock block(String text, double top, double left, {List<String>? lines}) =>
    TextBlock(
      text: text,
      lines: [
        for (final line in lines ?? [text])
          TextLine(
            text: line,
            elements: const [],
            boundingBox: Rect.fromLTWH(left, top, 10, 10),
            recognizedLanguages: const [],
            cornerPoints: const [],
            confidence: null,
            angle: null,
          ),
      ],
      boundingBox: Rect.fromLTWH(left, top, 100, 20),
      recognizedLanguages: const [],
      cornerPoints: const [],
    );

Barcode barcode(BarcodeFormat format, String? raw) => Barcode(
  type: BarcodeType.product,
  format: format,
  displayValue: raw,
  rawValue: raw,
  rawBytes: null,
  boundingBox: Rect.zero,
  cornerPoints: const [],
  value: null,
);

void main() {
  late _MockText text;
  late _MockBarcodes barcodes;
  late MlKitLabelReader reader;

  setUpAll(() => registerFallbackValue(_FakeInputImage()));

  setUp(() {
    text = _MockText();
    barcodes = _MockBarcodes();
    reader = MlKitLabelReader(text: text, barcodes: barcodes);
    when(() => text.close()).thenAnswer((_) async {});
    when(() => barcodes.close()).thenAnswer((_) async {});
  });

  group('BR1.7 reading on the phone', () {
    test('BR1.7 barcodes and text of the same image, blocks in reading '
        'order', () async {
      when(() => barcodes.processImage(any())).thenAnswer(
        (_) async => [
          barcode(BarcodeFormat.ean13, testEan13),
          barcode(BarcodeFormat.ean8, testEan8),
          barcode(BarcodeFormat.upca, testUpcA),
          barcode(BarcodeFormat.qrCode, 'https://x'),
          barcode(BarcodeFormat.ean13, null),
        ],
      );
      when(() => text.processImage(any())).thenAnswer(
        (_) async => RecognizedText(
          text: '',
          blocks: [
            block('2016', 300, 0),
            block('Barolo DOCG', 100, 50, lines: ['Barolo', 'DOCG']),
            block('Tenuta', 100, 0),
            block('  ', 200, 0),
          ],
        ),
      );
      final reading = await reader.read('/cache/label/a.jpg');
      expect(reading.barcodes, const [
        ReadBarcode(LabelBarcodeFormat.ean13, testEan13),
        ReadBarcode(LabelBarcodeFormat.ean8, testEan8),
        ReadBarcode(LabelBarcodeFormat.upcA, testUpcA),
        ReadBarcode(LabelBarcodeFormat.other, 'https://x'),
      ]);
      expect(reading.text, 'Tenuta\nBarolo\nDOCG\n2016');
    });

    test('BR1.7 the text is at most 2000 characters', () async {
      when(() => barcodes.processImage(any())).thenAnswer((_) async => []);
      when(() => text.processImage(any())).thenAnswer(
        (_) async =>
            RecognizedText(text: '', blocks: [block('x' * 3000, 0, 0)]),
      );
      final reading = await reader.read('/p.jpg');
      expect(reading.text.length, LabelReading.maxTextLength);
    });

    test('BR1.11 a failing recognizer makes the reading throw', () async {
      when(() => barcodes.processImage(any())).thenAnswer((_) async => []);
      when(() => text.processImage(any())).thenThrow(StateError('broken'));
      await expectLater(reader.read('/p.jpg'), throwsA(anything));
    });

    test('BR1.7 close releases both recognizers', () async {
      await reader.close();
      verify(() => text.close()).called(1);
      verify(() => barcodes.close()).called(1);
    });

    test('BR1.7 a block without lines keeps its text', () {
      final empty = TextBlock(
        text: 'Solo',
        lines: const [],
        boundingBox: Rect.zero,
        recognizedLanguages: const [],
        cornerPoints: const [],
      );
      expect(MlKitLabelReader.orderedText([empty]), 'Solo');
    });

    test('BR1.7 the default reader builds its own recognizers', () {
      expect(MlKitLabelReader(), isA<LabelReader>());
    });
  });
}
