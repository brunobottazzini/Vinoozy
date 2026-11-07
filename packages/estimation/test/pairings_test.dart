import 'package:estimation/estimation.dart';
import 'package:estimation/src/tables.dart';
import 'package:test/test.dart';

void main() {
  const barolo = WineFacts(name: 'Barolo', vintage: 2016);

  group('catalog pairings (BR4.2, NFR4.3)', () {
    test('more than 5 pairings: the first 5, as they are', () {
      final source = [
        'Brasato',
        'Tartufo',
        'Selvaggina',
        'Toma',
        'Funghi',
        'Pizza',
      ];
      final pairings = pairingsFor(barolo, ExternalProfile(pairings: source));
      expect(pairings.items, source.take(5).toList());
      expect(pairings.categoryKeys, isEmpty);
      expect(pairings.source, WindowSource.catalog);
      expect(source, hasLength(6), reason: 'the input list is not changed');
    });

    test('the returned list cannot be modified', () {
      final pairings = pairingsFor(
        barolo,
        const ExternalProfile(pairings: ['Brasato']),
      );
      expect(() => pairings.items.add('x'), throwsA(isA<UnsupportedError>()));
    });

    test('a single pairing is enough', () {
      final pairings = pairingsFor(
        barolo,
        const ExternalProfile(pairings: ['<b>Brasato</b>']),
      );
      expect(pairings.items, ['<b>Brasato</b>']);
    });

    test('an empty catalog list falls back to the internal rules', () {
      final pairings = pairingsFor(barolo, const ExternalProfile());
      expect(pairings.source, WindowSource.internalRules);
      expect(pairings.items, isEmpty);
    });
  });

  group('internal pairings (BR4.1)', () {
    test('denomination categories, returned without copying', () {
      final pairings = pairingsFor(barolo);
      expect(pairings.categoryKeys, [
        PairingCategory.braisedRedMeat,
        PairingCategory.game,
        PairingCategory.mushroomsTruffle,
        PairingCategory.agedCheese,
      ]);
      expect(
        pairings.categoryKeys,
        same(denominationTable['barolo']!.pairingCategories),
      );
      expect(pairings.items, isEmpty);
      expect(pairings.source, WindowSource.internalRules);
    });

    test('type categories when only the type is known', () {
      final pairings = pairingsFor(
        const WineFacts(
          name: 'Bianco della casa',
          vintage: 2024,
          wineType: WineType.white,
        ),
      );
      expect(
        pairings.categoryKeys,
        same(typeTable[WineType.white]!.pairingCategories),
      );
    });

    test('a hand-picked type different from the name wins', () {
      final pairings = pairingsFor(
        const WineFacts(
          name: 'Barolo bianco della casa',
          vintage: 2024,
          wineType: WineType.white,
        ),
      );
      expect(pairings.categoryKeys, contains(PairingCategory.fish));
    });

    test('generic categories when nothing is known', () {
      final pairings = pairingsFor(
        const WineFacts(name: 'Vino di Mario', referenceYear: 2026),
      );
      expect(pairings.categoryKeys, same(genericTypeProfile.pairingCategories));
    });

    test('the catalog type helps when the catalog has no pairings', () {
      final pairings = pairingsFor(
        const WineFacts(name: 'Cuvée', vintage: 2024),
        const ExternalProfile(wineType: 'sparkling'),
      );
      expect(
        pairings.categoryKeys,
        same(typeTable[WineType.sparklingClassic]!.pairingCategories),
      );
    });
  });

  group('invalid inputs (BR4.5)', () {
    Matcher fails(EstimationErrorCode code) => throwsA(
      isA<EstimationArgumentError>().having((e) => e.code, 'code', code),
    );

    test('empty name, even with catalog pairings', () {
      expect(
        () => pairingsFor(
          const WineFacts(name: ' ', vintage: 2020),
          const ExternalProfile(pairings: ['Brasato']),
        ),
        fails(EstimationErrorCode.emptyName),
      );
    });

    test('vintage out of range', () {
      expect(
        () => pairingsFor(const WineFacts(name: 'Barolo', vintage: 3000)),
        fails(EstimationErrorCode.vintageOutOfRange),
      );
    });

    test('neither vintage nor reference year', () {
      expect(
        () => pairingsFor(const WineFacts(name: 'Barolo')),
        fails(EstimationErrorCode.missingReferenceYear),
      );
    });
  });
}
