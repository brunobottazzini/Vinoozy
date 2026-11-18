// Text comparison that ignores case and accents in every script of the
// interface languages (wine-culture-languages FR3.3, FR1.2). Pure Dart: no
// Flutter import.

/// Lower case, accents removed, every other character a single space.
///
/// Latin, Greek, Cyrillic and Georgian letters and the digits are kept; a
/// Greek final sigma is a sigma; an accent, precomposed or written as a
/// separate combining mark, is dropped; Georgian capitals (Mtavruli) are the
/// ordinary letters (Mkhedruli). Two texts that fold to the same string are
/// the same words for a person typing them, with or without diacritics.
String foldText(String text) {
  final buffer = StringBuffer();
  var pendingSpace = false;
  for (final rune in text.toLowerCase().runes) {
    if (_isCombiningMark(rune)) continue;
    final folded = _folding[rune] ?? _plain(_mkhedruli(rune));
    if (folded == null) {
      pendingSpace = buffer.isNotEmpty;
      continue;
    }
    if (pendingSpace) buffer.write(' ');
    pendingSpace = false;
    buffer.write(folded);
  }
  return buffer.toString();
}

/// Combining diacritical marks (U+0300-U+036F): an accent typed or stored as
/// a separate character after its letter.
bool _isCombiningMark(int rune) => rune >= 0x300 && rune <= 0x36F;

/// A Georgian capital (Mtavruli, U+1C90-U+1CBA) as its ordinary letter.
int _mkhedruli(int rune) =>
    rune >= 0x1C90 && rune <= 0x1CBA ? rune - 0x1C90 + 0x10D0 : rune;

/// The letters and digits kept as they are: ASCII, then the lower-case Greek,
/// Cyrillic and Georgian (Mkhedruli) alphabets.
String? _plain(int rune) {
  final isLetter = rune >= 0x61 && rune <= 0x7A;
  final isDigit = rune >= 0x30 && rune <= 0x39;
  final isGreek = rune >= 0x3B1 && rune <= 0x3C9;
  final isCyrillic = rune >= 0x430 && rune <= 0x45F;
  final isGeorgian = rune >= 0x10D0 && rune <= 0x10FA;
  return isLetter || isDigit || isGreek || isCyrillic || isGeorgian
      ? String.fromCharCode(rune)
      : null;
}

/// Latin-1 and Latin Extended-A letters, the Romanian comma-below letters,
/// the Catalan middle dot (`l·l`, dropped), then the accented Greek vowels
/// and the final sigma, and the Cyrillic letters written with a diacritic.
const Map<int, String> _folding = {
  0xB7: '', 0x10F: 'd', 0x13A: 'l', 0x13E: 'l', 0x155: 'r', 0x15D: 's', //
  0x3AC: 'α', 0x3AD: 'ε', 0x3AE: 'η', 0x3AF: 'ι', 0x3CC: 'ο', 0x3CD: 'υ', //
  0x3CE: 'ω', 0x3CA: 'ι', 0x3CB: 'υ', 0x390: 'ι', 0x3B0: 'υ', 0x3C2: 'σ', //
  0x439: 'и', 0x450: 'е', 0x451: 'е', 0x453: 'г', 0x457: 'і', 0x45C: 'к', //
  0x45D: 'и', 0x45E: 'у', 0x491: 'г',
  0xE0: 'a', 0xE1: 'a', 0xE2: 'a', 0xE3: 'a', 0xE4: 'a', 0xE5: 'a', //
  0xE6: 'ae', 0xE7: 'c', 0xE8: 'e', 0xE9: 'e', 0xEA: 'e', 0xEB: 'e', //
  0xEC: 'i', 0xED: 'i', 0xEE: 'i', 0xEF: 'i', 0xF1: 'n', 0xF2: 'o', //
  0xF3: 'o', 0xF4: 'o', 0xF5: 'o', 0xF6: 'o', 0xF8: 'o', 0xF9: 'u', //
  0xFA: 'u', 0xFB: 'u', 0xFC: 'u', 0xFD: 'y', 0xFF: 'y', 0xDF: 'ss', //
  0x101: 'a', 0x103: 'a', 0x105: 'a', 0x107: 'c', 0x10D: 'c', 0x111: 'd', //
  0x113: 'e', 0x117: 'e', 0x119: 'e', 0x11B: 'e', 0x11F: 'g', 0x12B: 'i', //
  0x131: 'i', 0x142: 'l', 0x144: 'n', 0x148: 'n', 0x14D: 'o', 0x151: 'o', //
  0x153: 'oe', 0x159: 'r', 0x15B: 's', 0x15F: 's', 0x161: 's', 0x163: 't', //
  0x165: 't', 0x16B: 'u', 0x16F: 'u', 0x171: 'u', 0x17A: 'z', 0x17C: 'z', //
  0x17E: 'z', 0x219: 's', 0x21B: 't',
};
