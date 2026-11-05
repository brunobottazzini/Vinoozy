import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/cellar/domain/quantity.dart';
import 'package:vinoozy/cellar/domain/wine.dart';

void main() {
  final created = DateTime.utc(2026, 11, 4, 10);

  Map<String, Object?> validData() => {
    WineFields.name: 'Barolo',
    WineFields.vintage: 2016,
    WineFields.quantity: 2,
    WineFields.createdAt: created,
    WineFields.updatedAt: created,
    WineFields.updatedBy: 'user-a',
  };

  group('Wine.fromMap', () {
    test('reads every U1 field', () {
      final wine = Wine.fromMap('w1', validData());

      expect(wine.id, 'w1');
      expect(wine.name, 'Barolo');
      expect(wine.vintage, 2016);
      expect(wine.quantity, 2);
      expect(wine.createdAt, created);
      expect(wine.updatedBy, 'user-a');
    });

    test('ignores unknown and later-unit fields', () {
      final data = validData()
        ..['window'] = {'startYear': 2024}
        ..['futureField'] = 42;

      final wine = Wine.fromMap('w1', data);

      expect(wine.name, 'Barolo');
      expect(wine.quantity, 2);
    });

    test('null vintage means "no vintage"', () {
      final wine = Wine.fromMap('w1', validData()..[WineFields.vintage] = null);

      expect(wine.vintage, isNull);
    });

    test('malformed fields fall back instead of throwing', () {
      final wine = Wine.fromMap('w1', {
        WineFields.name: 7,
        WineFields.vintage: 'twenty',
        WineFields.quantity: 'two',
        WineFields.createdAt: 'yesterday',
      });

      expect(wine.name, '');
      expect(wine.vintage, isNull);
      expect(wine.quantity, 0);
      expect(wine.createdAt, isNull);
    });

    test('integral doubles are accepted, fractional ones are not', () {
      final integral = Wine.fromMap('w1', {WineFields.quantity: 3.0});
      final fractional = Wine.fromMap('w2', {WineFields.quantity: 2.5});

      expect(integral.quantity, 3);
      expect(fractional.quantity, 0);
    });
  });

  group('displayed quantity (ADR-004)', () {
    test('a negative stored quantity is shown as 0', () {
      final wine = Wine.fromMap('w1', validData()..[WineFields.quantity] = -1);

      expect(wine.storedQuantity, -1);
      expect(wine.quantity, 0);
      expect(displayQuantity(-5), 0);
    });

    test('positive quantities are shown unchanged', () {
      expect(displayQuantity(0), 0);
      expect(displayQuantity(12), 12);
    });

    test('stepper limits clamp to 1..99', () {
      expect(QuantityLimits.clamp(0), 1);
      expect(QuantityLimits.clamp(100), 99);
      expect(QuantityLimits.clamp(5), 5);
    });
  });

  test('compareByName sorts case-insensitively, then by vintage and id', () {
    final wines = [
      Wine.fromMap('3', {WineFields.name: 'barolo', WineFields.vintage: 2018}),
      Wine.fromMap('1', {WineFields.name: 'Arneis'}),
      Wine.fromMap('2', {WineFields.name: 'Barolo', WineFields.vintage: 2016}),
    ]..sort(Wine.compareByName);

    expect(wines.map((w) => w.id), ['1', '2', '3']);
  });
}
