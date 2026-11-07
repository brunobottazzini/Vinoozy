import 'package:estimation/estimation.dart' show recognizeDenomination;

import 'label_reading.dart';

/// Recognises a denomination in one line of text; `null` when there is none.
typedef DenominationTest = bool Function(String line);

bool _hasDenomination(String line) => recognizeDenomination(line) != null;

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
