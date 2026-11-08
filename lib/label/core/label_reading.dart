// Value types and the reader seam of the label photo (u6-label-recognition
// logical-components.md). Pure Dart: no Flutter, no plugin, no Firebase.

/// Barcode formats the label reader can report. Only [ean13], [ean8] and
/// [upcA] are used for the lookup (BR1.7); anything else is [other].
enum LabelBarcodeFormat { ean13, ean8, upcA, other }

/// One barcode found on the photo, as read on the phone.
class ReadBarcode {
  const ReadBarcode(this.format, this.value);

  final LabelBarcodeFormat format;

  /// The raw digits; never logged nor reported (BR1.14).
  final String value;

  @override
  bool operator ==(Object other) =>
      other is ReadBarcode && other.format == format && other.value == value;

  @override
  int get hashCode => Object.hash(format, value);

  // No value in the string form: it may end up in a log (NFR8.2).
  @override
  String toString() => 'ReadBarcode(${format.name})';
}

/// What the reader found on one photo: the barcodes and the text, with the
/// blocks in reading order joined by new lines (BR1.7).
class LabelReading {
  const LabelReading({this.barcodes = const [], this.text = ''});

  /// The most text kept per photo (BR1.7; label-recognition BR1.2: front
  /// and back together up to 4000, the limit of `matchLabel`).
  static const int maxTextLength = 2000;

  final List<ReadBarcode> barcodes;
  final String text;

  /// [text] cut to [maxTextLength] characters.
  static String clampText(String text) =>
      text.length <= maxTextLength ? text : text.substring(0, maxTextLength);

  @override
  String toString() =>
      'LabelReading(${barcodes.length} barcodes, ${text.length} chars)';
}

/// Reads barcodes and text on the phone (tech-stack-decisions.md). ML Kit in
/// the app (`MlKitLabelReader`), a fake in tests.
abstract interface class LabelReader {
  /// Reads the prepared image at [imagePath]. Throws when the image cannot be
  /// read; the session turns that into "unreadable" (BR1.11).
  Future<LabelReading> read(String imagePath);

  /// Releases the recognizers; the reader is not used afterwards.
  Future<void> close();
}

/// Whether [text] has at least [minLetters] letters (BR1.11: fewer than 3 is
/// "nothing readable").
bool hasLetters(String text, {int minLetters = 3}) {
  var count = 0;
  for (final rune in text.runes) {
    if (_isLetter(rune) && ++count >= minLetters) return true;
  }
  return false;
}

bool _isLetter(int rune) {
  final char = String.fromCharCode(rune);
  return char.toLowerCase() != char.toUpperCase();
}
