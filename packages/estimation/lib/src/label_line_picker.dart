// The most significant line of a label text, moved here from lib/label/core
// by label-autofill-windows (D1) so the extractor of this package can use
// it; lib/label/core/label_line_picker.dart re-exports it.

import 'catalog.dart' show recognizeDenomination;

/// Recognises a denomination in one line of text; `null` when there is none.
typedef DenominationTest = bool Function(String line);

bool _hasDenomination(String line) => recognizeDenomination(line) != null;

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

/// The most significant line of the label text (BR1.12), used to fill the
/// name of the U4 form when no wine is found (BR1.11).
///
/// - The first line that contains a recognised denomination;
/// - otherwise the longest line with at least 3 letters that is not only
///   numbers and is not a volume, alcohol or sulphites line ("750 ml",
///   "13,5% vol", "contiene solfiti");
/// - cut to [maxLength] characters; empty when no line qualifies.
///
/// A product choice, not an oenological one: it only spares the user an
/// empty field.
class LabelLinePicker {
  const LabelLinePicker({this._isDenomination = _hasDenomination});

  /// The longest name of the U4 form (C3).
  static const int maxLength = 120;

  final DenominationTest _isDenomination;

  static final RegExp _onlyNumbers = RegExp(r'^[\d\s.,:;/%\-+()°]*$');

  /// Volume, alcohol and allergen lines in the three app languages.
  static final List<RegExp> _noise = [
    // "750 ml", "0,75 l", "75cl", or "ml" alone; never the "l'" of Italian.
    RegExp(r'\d\s*(ml|cl|lt?)\b', caseSensitive: false),
    RegExp(r'\b(ml|cl)\b', caseSensitive: false),
    RegExp(r'%\s*vol', caseSensitive: false),
    RegExp(r'\bvol\.?\s*\d', caseSensitive: false),
    RegExp(r'contiene\s+solfiti', caseSensitive: false),
    RegExp(r'contains\s+sul(ph|f)ites', caseSensitive: false),
    RegExp(r'cont[ée]m\s+sulfitos', caseSensitive: false),
  ];

  String pick(String text) {
    final lines = [
      for (final line in text.split('\n'))
        if (line.trim().isNotEmpty) _collapse(line),
    ];
    for (final line in lines) {
      if (_isDenomination(line)) return _cut(line);
    }
    String? best;
    for (final line in lines) {
      if (!_qualifies(line)) continue;
      if (best == null || line.length > best.length) best = line;
    }
    return best == null ? '' : _cut(best);
  }

  /// The longest line of [lines] that qualifies (no denomination check),
  /// or `null`; used by `extractLabelFields` on the lines left after the
  /// other fields (label-autofill-windows BR1.5).
  String? longest(Iterable<String> lines) {
    String? best;
    for (final raw in lines) {
      final line = _collapse(raw);
      if (!_qualifies(line)) continue;
      if (best == null || line.length > best.length) best = line;
    }
    return best;
  }

  bool _qualifies(String line) =>
      hasLetters(line) &&
      !_onlyNumbers.hasMatch(line) &&
      !_noise.any((pattern) => pattern.hasMatch(line));

  static String _collapse(String line) =>
      line.trim().replaceAll(RegExp(r'\s+'), ' ');

  static String _cut(String line) => line.length <= maxLength
      ? line
      : line.substring(0, maxLength).trimRight();
}
