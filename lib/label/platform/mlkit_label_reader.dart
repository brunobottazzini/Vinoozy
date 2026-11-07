import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../core/label_reading.dart';

/// [LabelReader] with ML Kit on the phone, models bundled in the app
/// (u6-label-recognition BR1.7, tech-stack-decisions.md): no network, no
/// image leaves the phone.
///
/// Barcode and text run in parallel on the same prepared image (2,048 px on
/// the long side, NFR1.2). One reader lives for one reading session; [close]
/// releases both recognizers (performance-design.md §1).
class MlKitLabelReader implements LabelReader {
  MlKitLabelReader({TextRecognizer? text, BarcodeScanner? barcodes})
    : _text = text ?? TextRecognizer(script: TextRecognitionScript.latin),
      _barcodes =
          barcodes ??
          BarcodeScanner(
            formats: const [
              BarcodeFormat.ean13,
              BarcodeFormat.ean8,
              BarcodeFormat.upca,
            ],
          );

  final TextRecognizer _text;
  final BarcodeScanner _barcodes;

  @override
  Future<LabelReading> read(String imagePath) async {
    final image = InputImage.fromFilePath(imagePath);
    final (codes, recognized) = await (
      _barcodes.processImage(image),
      _text.processImage(image),
    ).wait;
    return LabelReading(
      barcodes: [
        for (final code in codes)
          if (code.rawValue != null)
            ReadBarcode(formatOf(code.format), code.rawValue!),
      ],
      text: LabelReading.clampText(orderedText(recognized.blocks)),
    );
  }

  @override
  Future<void> close() async {
    await Future.wait([_text.close(), _barcodes.close()]);
  }

  static LabelBarcodeFormat formatOf(BarcodeFormat format) => switch (format) {
    BarcodeFormat.ean13 => LabelBarcodeFormat.ean13,
    BarcodeFormat.ean8 => LabelBarcodeFormat.ean8,
    BarcodeFormat.upca => LabelBarcodeFormat.upcA,
    _ => LabelBarcodeFormat.other,
  };

  /// The blocks in reading order (top to bottom, then left to right), each
  /// block's lines on their own line (BR1.7).
  static String orderedText(List<TextBlock> blocks) {
    final sorted = [...blocks]
      ..sort((a, b) {
        final byTop = a.boundingBox.top.compareTo(b.boundingBox.top);
        return byTop != 0
            ? byTop
            : a.boundingBox.left.compareTo(b.boundingBox.left);
      });
    return [
      for (final block in sorted)
        if (block.lines.isEmpty)
          block.text
        else
          for (final line in block.lines) line.text,
    ].where((line) => line.trim().isNotEmpty).join('\n');
  }
}
