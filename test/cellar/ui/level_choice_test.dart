// LevelChoice, the level state of the add and edit forms
// (label-autofill-windows BR4.3, interaction-spec "Livello").
import 'package:estimation/estimation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/cellar/ui/level_section.dart';

void main() {
  group('LevelChoice', () {
    test('not chosen: no level saved, no suggestion without a qualifier', () {
      final choice = LevelChoice();
      final suggestion = choice.suggestionFor('Barolo', null);
      expect(suggestion, isNull);
      expect(choice.effective(suggestion), isNull);
    });

    test('a qualifier in the name or the appellation suggests "aging", '
        'accepted on Save', () {
      final choice = LevelChoice();
      expect(choice.suggestionFor('Chianti Riserva', ''), Qualifier.riserva);
      expect(
        choice.suggestionFor('Vino', 'Rioja Gran Reserva'),
        Qualifier.granReserva,
      );
      expect(
        choice.effective(choice.suggestionFor('Chianti Riserva', null)),
        WineLevel.aging,
      );
    });

    test('a tap replaces the suggestion; the choice is saved', () {
      final choice = LevelChoice()..choose(WineLevel.everyday);
      expect(choice.touched, isTrue);
      final suggestion = choice.suggestionFor('Chianti Riserva', null);
      expect(suggestion, isNull);
      expect(choice.effective(suggestion), WineLevel.everyday);
    });

    test('"None" turns the suggestion off until reset', () {
      final choice = LevelChoice()..choose(null);
      expect(choice.suggestionOff, isTrue);
      expect(choice.suggestionFor('Chianti Riserva', null), isNull);
      expect(choice.effective(null), isNull);
      choice.reset();
      expect(choice.touched, isFalse);
      expect(choice.suggestionFor('Chianti Riserva', null), Qualifier.riserva);
    });

    test('a saved level is never replaced by a suggestion (edit form)', () {
      final choice = LevelChoice(saved: WineLevel.good);
      expect(choice.value, WineLevel.good);
      final suggestion = choice.suggestionFor('Barolo Riserva', null);
      expect(suggestion, isNull);
      expect(choice.effective(suggestion), WineLevel.good);
    });

    test('the qualifier of a label text counts only while the name is the '
        'one read, and only when it suggests "aging"', () {
      final choice = LevelChoice()..textQualifier = Qualifier.granReserva;
      expect(
        choice.suggestionFor('Muga', null, nameFromText: true),
        Qualifier.granReserva,
      );
      expect(choice.suggestionFor('Muga', null), isNull);
      choice.textQualifier = Qualifier.crianza;
      expect(choice.suggestionFor('Muga', null, nameFromText: true), isNull);
    });
  });
}
