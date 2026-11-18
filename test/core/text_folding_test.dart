import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/core/text_folding.dart';

// Comparison that ignores case and accents in every script of the interface
// languages (wine-culture-languages FR3.3, FR1.2).
void main() {
  group('foldText', () {
    test('Latin letters lose case and diacritics', () {
      expect(foldText('ȘTERGE'), 'sterge');
      expect(foldText('ŞTERGE'), 'sterge'); // cedilla, as many keyboards type
      expect(foldText('TÖRLÉS'), 'torles');
      expect(foldText('LÖSCHEN'), 'loschen');
      expect(foldText('USUŃ'), 'usun');
      expect(foldText('ODSTRÁNIŤ'), 'odstranit');
      expect(foldText('IZBRIŠI'), 'izbrisi');
    });

    test('Greek: accents and final sigma', () {
      expect(foldText('ΔΙΑΓΡΑΦΗ'), foldText('διαγραφή'));
      expect(foldText('Κύπρος'), foldText('ΚΥΠΡΟΣ'));
    });

    test('Cyrillic keeps its letters, without case', () {
      expect(foldText('ОБРИШИ'), 'обриши');
      expect(foldText('ВИДАЛИТИ'), foldText('видалити'));
    });

    test('Georgian capitals are the ordinary letters', () {
      expect(foldText('წაშლა'), 'წაშლა');
      // The same word in Mtavruli capitals (U+1C90 block) folds the same.
      final mtavruli = String.fromCharCodes([
        for (final rune in 'წაშლა'.runes) rune - 0x10D0 + 0x1C90,
      ]);
      expect(foldText(mtavruli), 'წაშლა');
    });

    test('separate combining accents are dropped', () {
      expect(foldText('Géorgie'), 'georgie');
    });

    test('punctuation and spaces become one space, ends trimmed', () {
      expect(foldText('  Valle  d\'Aosta! '), 'valle d aosta');
      expect(foldText('...'), '');
      expect(foldText(''), '');
    });
  });
}
