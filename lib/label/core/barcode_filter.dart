import '../../catalog/core/off/open_food_facts_source.dart'
    show normalizeBarcode;
import 'label_reading.dart';

/// The barcode used for the lookup (BR1.7): the first EAN-13, EAN-8 or UPC-A
/// code, normalised with `normalizeBarcode` of U3, whose GS1 check digit is
/// right. Other formats (QR codes, Code 128...) and damaged codes are
/// ignored, so the catalog never receives a code it would reject.
class BarcodeFilter {
  const BarcodeFilter();

  static const Set<LabelBarcodeFormat> accepted = {
    LabelBarcodeFormat.ean13,
    LabelBarcodeFormat.ean8,
    LabelBarcodeFormat.upcA,
  };

  /// The first valid code of [barcodes], normalised (8 or 13 digits), or
  /// `null`.
  String? firstValid(Iterable<ReadBarcode> barcodes) {
    for (final barcode in barcodes) {
      if (!accepted.contains(barcode.format)) continue;
      final normalized = normalizeBarcode(barcode.value.trim());
      if (normalized == null || !_lengthFits(barcode.format, normalized)) {
        continue;
      }
      if (hasValidCheckDigit(normalized)) return normalized;
    }
    return null;
  }

  /// EAN-8 has 8 digits; UPC-A (12, padded to 13) and EAN-13 have 13.
  static bool _lengthFits(LabelBarcodeFormat format, String code) =>
      format == LabelBarcodeFormat.ean8 ? code.length == 8 : code.length == 13;

  /// GS1 mod-10 check digit of an 8- or 13-digit code.
  static bool hasValidCheckDigit(String code) {
    final digits = [for (final unit in code.codeUnits) unit - 0x30];
    final body = digits.sublist(0, digits.length - 1);
    var sum = 0;
    for (var i = 0; i < body.length; i++) {
      // Weights 3, 1, 3... counted from the digit next to the check digit.
      final fromRight = body.length - 1 - i;
      sum += body[i] * (fromRight.isEven ? 3 : 1);
    }
    return (10 - sum % 10) % 10 == digits.last;
  }
}
