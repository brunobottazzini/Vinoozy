// BR3.6 text score and BR3.2 sure-proposal rule (label-recognition), one case
// per rule of the formula.
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/catalog/core/offline/text_score.dart';

void main() {
  WineWords wine(
    String name, {
    String? producer,
    String? denomination,
    int? vintage,
  }) => WineWords.of(
    name: name,
    producer: producer,
    denomination: denomination,
    vintage: vintage,
  );

  group('BR3.6 distinctive words', () {
    test('BR3.6 short, common and digit-only words are dropped, each word '
        'counts once', () {
      final words = wine(
        'Château Musar Rouge 2015',
        producer: 'Château Musar',
        denomination: 'Bekaa Valley',
      );
      expect(words.words, ['musar', 'bekaa', 'valley']);
      expect(words.totalWeight, 5 + 5 + 6);
    });

    test('BR3.6 accents and capitals are normalised', () {
      final label = LabelWords.of('CRÉMANT D’ALSACE\nDomaine Zind');
      final words = wine('Crémant d’Alsace', producer: 'Zind');
      expect(scoreWine(words, label).score, 1.0);
      expect(scoreWine(words, label).matchedWords, 3);
    });
  });

  group('BR3.6 score', () {
    test('BR3.6 name + producer fully read: 1.0, two words found', () {
      final match = scoreWine(
        wine('Barolo Ravera', producer: 'Elvio Cogno'),
        LabelWords.of('ELVIO COGNO\nBAROLO\nRAVERA\n2016'),
      );
      expect(match.score, 1.0);
      expect(match.matchedWords, 4);
    });

    test('BR3.6 weights are the letters of each word', () {
      // barbaresco (10) found, asili (5) missing.
      final match = scoreWine(
        wine('Barbaresco Asili'),
        LabelWords.of('Barbaresco 2019'),
      );
      expect(match.score, closeTo(10 / 15, 1e-9));
      expect(match.matchedWords, 1);
    });

    test('BR3.6 a wine of one distinctive word is capped at 0.60', () {
      final match = scoreWine(wine('Barolo'), LabelWords.of('Barolo DOCG'));
      expect(match.score, LabelMatchThresholds.fewWordsCap);
    });

    test('BR3.6 the vintage adds 0.05, never above 1.0', () {
      final partial = scoreWine(
        wine('Barbaresco Asili', vintage: 2019),
        LabelWords.of('Barbaresco 2019'),
      );
      expect(partial.score, closeTo(10 / 15 + 0.05, 1e-9));
      final full = scoreWine(
        wine('Barbaresco Asili', vintage: 2019),
        LabelWords.of('Barbaresco Asili 2019'),
      );
      expect(full.score, 1.0);
    });

    test('BR3.6 a vintage alone gives nothing', () {
      final match = scoreWine(
        wine('Barbaresco Asili', vintage: 2019),
        LabelWords.of('2019 contiene solfiti'),
      );
      expect(match.score, 0);
    });

    test('BR3.6 noise around the words does not lower the score', () {
      final match = scoreWine(
        wine('Barolo Ravera', producer: 'Elvio Cogno'),
        LabelWords.of(
          'imbottigliato all origine da elvio cogno novello italia 750 ml '
          '14% vol contiene solfiti barolo ravera',
        ),
      );
      expect(match.score, 1.0);
    });

    test('BR3.6 empty text and wines without distinctive words score 0', () {
      expect(scoreWine(wine('Barolo'), LabelWords.of('')).score, 0);
      expect(
        scoreWine(wine('Vino Rosso'), LabelWords.of('vino rosso')).score,
        0,
      );
      expect(LabelWords.of('  ').isEmpty, isTrue);
    });
  });

  group('BR3.2 sure proposal', () {
    test('BR3.2 at least 0.85, two words and a margin of 0.15', () {
      const best = TextMatch(0.9, 2);
      expect(isSureTextMatch(best, null), isTrue);
      expect(isSureTextMatch(best, 0.75), isTrue);
      expect(isSureTextMatch(best, 0.76), isFalse);
      expect(isSureTextMatch(const TextMatch(0.84, 3), null), isFalse);
      expect(isSureTextMatch(const TextMatch(1.0, 1), null), isFalse);
    });
  });
}
