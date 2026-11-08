// Tests of the words of a label text and of the composition (FR7.5,
// label-autofill-windows BR7.14-BR7.16, NFR5.8, NFR3.9).
import 'package:estimation/estimation.dart';
import 'package:test/test.dart';

const int _year = 2026;

List<LabelWord> _words(String text) =>
    analyzeLabelText(text, currentYear: _year).words;

Set<int> _ids(List<LabelWord> words, List<String> texts) => {
  for (final text in texts) words.firstWhere((w) => w.text == text).id,
};

void main() {
  group('words of the text (BR7.14)', () {
    test('apostrophes and inner dashes stay, punctuation is stripped', () {
      final words = _words(
        "Barbera d'Asti, Saint-Émilion; (Cuvée) «Réserve» “Brut”",
      );
      expect(words.map((w) => w.text), [
        'Barbera',
        "d'Asti",
        'Saint-Émilion',
        'Cuvée',
        'Réserve',
        'Brut',
      ]);
    });

    test('one-letter words, lone dashes, numbers and volumes are dropped; '
        'plausible years and words with letters stay', () {
      final words = _words(
        'R. Lemaire - Bisol1542 904 2019 1850 2028 ’24 B\nGran Reserva 904',
      );
      final texts = words.map((w) => w.text).toList();
      expect(texts, containsAll(['Lemaire', 'Bisol1542', '2019', 'Gran']));
      expect(texts, isNot(contains('R')));
      expect(texts, isNot(contains('-')));
      expect(texts, isNot(contains('904')));
      expect(texts, isNot(contains('1850')));
      expect(texts, isNot(contains('2028')));
      expect(texts, isNot(contains('’24')));
      expect(texts, isNot(contains('B')));
    });

    test('service lines give no word, a long line keeps its other words', () {
      final words = _words(
        'Morgon Côte du Py Appellation Morgon Contrôlée Domaine du Vieux '
        'Pressoir 2020 13% vol 75cl\n750 ml\nwww.example.com',
      );
      final texts = words.map((w) => w.text).toList();
      expect(texts, contains('Pressoir'));
      expect(texts, isNot(contains('75cl')));
      expect(texts, isNot(contains('vol')));
      expect(texts.any((t) => t.contains('www')), isFalse);
    });

    test('ids follow the text, lines are indexed, folded is normalised', () {
      final words = _words('CASCINA CASTLET\nBarbera d’Asti Superiore\n2019');
      expect([for (final w in words) w.id], [0, 1, 2, 3, 4, 5]);
      expect([for (final w in words) w.line], [0, 0, 1, 1, 1, 2]);
      expect(words[3].folded, 'd asti');
      expect(words[0].folded, 'cascina');
    });

    test('at most 120 words', () {
      final text = List.generate(60, (i) => 'Word$i Other$i').join('\n');
      final words = _words(text);
      expect(words.length, maxLabelWords);
      expect(words.last.id, maxLabelWords - 1);
    });
  });

  group('composition (BR7.15)', () {
    final words = _words(
      "CASCINA CASTLET\nBarbera d'Asti Superiore\nGran Selezione 2019",
    );

    test('the order of the text, whatever the order of the taps', () {
      final selected = _ids(words, ["d'Asti", 'Barbera']);
      expect(composeValue(words, selected), "Barbera d'Asti");
      expect(composeValue(words, {...selected}.toSet()), "Barbera d'Asti");
    });

    test('words of different lines, one space between them; a mixed value '
        'stays as written', () {
      expect(
        composeValue(words, _ids(words, ['Superiore', 'CASTLET'])),
        'CASTLET Superiore',
      );
    });

    test('all capitals become title case, as the read values', () {
      expect(
        composeValue(words, _ids(words, ['CASCINA', 'CASTLET'])),
        'Cascina Castlet',
      );
    });

    test('nothing chosen gives an empty value', () {
      expect(composeValue(words, {}), isEmpty);
    });

    test('at most 8 words and 80 characters; a chosen word can always be '
        'removed', () {
      final many = _words(
        'Uno Due Tre Quattro Cinque Sei Sette Otto Nove Dieci',
      );
      final eight = {for (var i = 0; i < 8; i++) i};
      expect(canSelect(many, eight, 8), isFalse);
      expect(canSelect(many, eight, 3), isTrue);
      expect(canSelect(many, {0, 1}, 2), isTrue);
      final long = _words(
        '${'Abcdefghijklmnopqrstuvwxyz' * 2} '
        '${'Zyxwvutsrqponmlkjihgfedcba' * 2} Abc',
      );
      expect(canSelect(long, {0}, 1), isFalse);
      expect(canSelect(long, {0}, 2), isTrue);
      expect(maxComposedWords, 8);
      expect(maxComposedLength, 80);
    });
  });

  group('composed appellation (BR7.16)', () {
    test('matches a name or alias without case, accents and trailing '
        'indicators or qualifiers', () {
      expect(matchDenomination("Barbera d'Asti")?.key, 'barberaDAsti');
      expect(matchDenomination("BARBERA D'ASTI DOCG")?.key, 'barberaDAsti');
      expect(
        matchDenomination("barbera d'asti superiore")?.key,
        'barberaDAsti',
      );
      expect(matchDenomination('Saint Emilion')?.key, 'saintEmilion');
      expect(
        matchDenomination('Chianti Classico D.O.C.G.')?.key,
        'chiantiClassico',
      );
    });

    test('the whole value first: the longest match wins, "Classico" is '
        'never stripped', () {
      expect(matchDenomination('Chianti Classico')?.key, 'chiantiClassico');
      expect(matchDenomination('Chianti')?.key, 'chianti');
      expect(
        matchDenomination("Barbera d'Asti Superiore")?.key,
        'barberaDAsti',
      );
      expect(
        matchDenomination('Chianti Classico Riserva DOCG')?.key,
        'chiantiClassico',
      );
    });

    test('aging qualifiers in tail: Grand Cru, Premier Cru, Gran '
        'Selezione, Gran Reserva, Vintage', () {
      expect(matchDenomination('Saint-Émilion Grand Cru')?.key, 'saintEmilion');
      expect(matchDenomination('Chablis Premier Cru')?.key, 'chablis');
      expect(
        matchDenomination('Chianti Classico Gran Selezione')?.key,
        'chiantiClassico',
      );
      expect(matchDenomination('Rioja Gran Reserva')?.key, 'rioja');
      expect(matchDenomination('Porto Vintage')?.key, 'porto');
      // "Gran" alone or "Cru" alone are no qualifier phrase: no match.
      expect(matchDenomination('Chianti Gran'), isNull);
    });

    test('weak aliases count too', () {
      expect(matchDenomination('Rioja')?.key, 'rioja');
      expect(matchDenomination('Cava')?.key, 'cava');
    });

    test('no match gives null, the value is kept as composed', () {
      expect(matchDenomination('Barbaresoo'), isNull);
      expect(matchDenomination('Cascina Castlet'), isNull);
      expect(matchDenomination(''), isNull);
      expect(matchDenomination('DOCG Riserva'), isNull);
    });

    test('the type and the country of the form only break ties', () {
      final plain = matchDenomination('Barolo');
      expect(
        matchDenomination('Barolo', type: WineType.white, country: 'FR')?.key,
        plain?.key,
      );
    });
  });
}
