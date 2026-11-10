// Cellar capacity fields (freemium-plus FR2.2, FR2.3): the active-wine
// counter and the migrated legacy limit, read leniently.
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/cellar/domain/cellar.dart';

void main() {
  Map<String, Object?> cellar(Map<String, Object?> extra) => {
    CellarFields.ownerId: 'u1',
    CellarFields.name: 'Cantina',
    ...extra,
  };

  test('reads the counter and the legacy limit', () {
    final read = Cellar.fromMap(
      'u1',
      cellar({
        CellarFields.activeWineCount: 14,
        CellarFields.activeOpWineId: 'w3',
        CellarFields.legacyActiveWineLimit: 22,
      }),
    );

    expect(read.activeWineCount, 14);
    expect(read.legacyActiveWineLimit, 22);
  });

  test('a cellar written before the counter has neither', () {
    final read = Cellar.fromMap('u1', cellar(const {}));

    expect(read.activeWineCount, isNull);
    expect(read.legacyActiveWineLimit, isNull);
  });

  test('a negative counter before the migration is kept as is', () {
    expect(
      Cellar.fromMap(
        'u1',
        cellar({CellarFields.activeWineCount: -1}),
      ).activeWineCount,
      -1,
    );
  });

  test('a legacy limit below 1 or mistyped is ignored', () {
    for (final value in [0, -4, 'twenty']) {
      expect(
        Cellar.fromMap(
          'u1',
          cellar({CellarFields.legacyActiveWineLimit: value}),
        ).legacyActiveWineLimit,
        isNull,
        reason: '$value',
      );
    }
  });
}
