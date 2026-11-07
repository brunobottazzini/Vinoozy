// matchKeyOf (u4-cellar BR1.4; NFR4.1: at most 400 characters).
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/cellar/domain/match_key.dart';

void main() {
  test('BR1.4 case, accents and spaces do not change the key', () {
    final a = matchKeyOf('Barolo  Riserva', 'Cantina Città', 2016);
    final b = matchKeyOf('barolo riserva ', 'CANTINA CITTA', 2016);

    expect(a, b);
    expect(a, 'barolo riserva|cantina citta|2016');
  });

  test('BR1.4 producer and vintage are part of the key', () {
    expect(
      matchKeyOf('Barolo', 'A', 2016),
      isNot(matchKeyOf('Barolo', 'B', 2016)),
    );
    expect(
      matchKeyOf('Barolo', 'A', 2016),
      isNot(matchKeyOf('Barolo', 'A', 2017)),
    );
  });

  test('BR1.4 a missing producer or vintage is an empty part', () {
    expect(matchKeyOf('Barolo', null, null), 'barolo||');
    expect(matchKeyOf('Barolo', '', null), matchKeyOf('Barolo', null, null));
  });

  test('BR1.4 the key never exceeds 400 characters', () {
    final key = matchKeyOf('n' * 120, 'p' * 300, 2016);

    expect(key.length, maxMatchKeyLength);
    expect(key.length, 400);
  });

  test('BR1.4 a key of 399 characters is kept whole', () {
    final key = matchKeyOf('n' * 120, 'p' * 272, 2016);

    expect(key.length, 120 + 1 + 272 + 1 + 4);
    expect(key.endsWith('|2016'), isTrue);
  });
}
