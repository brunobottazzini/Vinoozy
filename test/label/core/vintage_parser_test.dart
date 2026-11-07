import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/label/core/vintage_parser.dart';

void main() {
  const parser = VintageParser();
  int? parse(String text) => parser.parse(text, currentYear: 2026);

  group('BR1.8 vintage read on the label', () {
    test('BR1.8 one year between 1900 and this year', () {
      expect(parse('Barolo DOCG 2016'), 2016);
      expect(parse('Vendemmia 1900'), 1900);
      expect(parse('Annata 2026'), 2026);
    });

    test('BR1.8 a future year or one before 1900 is not a vintage', () {
      expect(parse('Barolo 2031'), isNull);
      expect(parse('Barolo 1899'), isNull);
    });

    test('BR1.8 a year inside a longer number is not a vintage', () {
      expect(parse('Lotto 120162 L.2016.3'), isNull);
      expect(parse('Codice 20161'), isNull);
      expect(parse('13,5% vol 750 ml'), isNull);
    });

    test('BR1.8 no year gives null', () {
      expect(parse('Dolcetto d Alba'), isNull);
      expect(parse(''), isNull);
    });

    test('BR1.8 a founding year is skipped', () {
      expect(parse('Cantina dal 1952\nBarolo 2016'), 2016);
      expect(parse('Since 1890'), isNull);
      expect(parse('Fondata nel 1975 Rosso 2020'), 2020);
      expect(parse('Desde 1901 Reserva 2019'), 2019);
    });

    test('BR1.8 with several years, the one closest to a vintage word', () {
      expect(parse('Premio 2022\nVendemmia 2018'), 2018);
      expect(parse('2019 harvest, awarded 2023'), 2019);
      expect(parse('Gold medal 2024 — Barolo DOCG 2015'), 2015);
    });

    test('BR1.8 with several years and no vintage word, the most recent', () {
      expect(parse('2015 2019 2017'), 2019);
    });

    test('BR1.8 a tie on distance keeps the most recent', () {
      // Both years are one space from "DOC".
      expect(parse('2015 DOC 2017'), 2017);
      expect(parse('2017 DOC 2015'), 2017);
    });

    test('BR1.8 a year on the line of the vintage word beats a closer one '
        'on another line', () {
      expect(parse('Premio 2022\nVendemmia 2018'), 2018);
    });
  });
}
