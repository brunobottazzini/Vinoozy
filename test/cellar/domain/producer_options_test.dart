// producerOptions (u4-cellar BR1.2: new producer as the last entry).
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/cellar/domain/producer_options.dart';

void main() {
  test('BR1.2 known producers containing the text, then "add new"', () {
    final options = producerOptions(
      'cant',
      catalogProducers: ['Cantina Terlano', null, ''],
      cellarProducers: ['Cantina Esempio', 'Giacomo'],
    );

    expect(options, const [
      ProducerOption(name: 'Cantina Esempio', isNew: false),
      ProducerOption(name: 'Cantina Terlano', isNew: false),
      ProducerOption(name: 'cant', isNew: true),
    ]);
  });

  test('BR1.2 the new entry keeps the text as typed, trimmed', () {
    final options = producerOptions('  Az. Agr. Rossi ');

    expect(
      options.single,
      const ProducerOption(name: 'Az. Agr. Rossi', isNew: true),
    );
  });

  test('BR1.2 duplicates differing by case or accents appear once', () {
    final options = producerOptions(
      'citta',
      cellarProducers: ['Cantina Città', 'CANTINA CITTA'],
    );

    expect(options.where((o) => !o.isNew).length, 1);
    expect(options.first.name, 'Cantina Città');
  });

  test('BR1.2 nothing typed: no entries; at most maxKnown known ones', () {
    expect(producerOptions('  '), isEmpty);
    final many = producerOptions(
      'c',
      cellarProducers: [for (var i = 0; i < 20; i++) 'Cantina $i'],
      maxKnown: 3,
    );
    expect(many.length, 4);
    expect(many.last.isNew, isTrue);
  });
}
