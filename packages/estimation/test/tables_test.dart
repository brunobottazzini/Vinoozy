// Generated per-row checks of the wine tables (NFR7.2): every row defined in
// tables.dart gets its own tests, so a new or corrected row is covered
// without editing this file.
import 'package:estimation/src/models.dart';
import 'package:estimation/src/recognizer.dart';
import 'package:estimation/src/tables.dart';
import 'package:test/test.dart';

final _normalisedAlias = RegExp(r'^[a-z0-9]+( [a-z0-9]+)*$');

void expectOrderedOffsets(YearOffsets offsets, String label) {
  expect(offsets.start, greaterThanOrEqualTo(0), reason: '$label start');
  expect(offsets.start, lessThanOrEqualTo(offsets.peak), reason: label);
  expect(offsets.peak, lessThanOrEqualTo(offsets.end), reason: label);
}

void expectValidCategories(List<PairingCategory> categories, String label) {
  expect(categories.length, inInclusiveRange(3, 5), reason: label);
  expect(categories.toSet(), hasLength(categories.length), reason: label);
}

void main() {
  test('the denomination table is not empty', () {
    expect(denominationTable, isNotEmpty);
  });

  group('denomination rows', () {
    for (final entry in denominationTable.entries) {
      final key = entry.key;
      final row = entry.value;

      group(key, () {
        test('start <= peak <= end, qualifiers included', () {
          expectOrderedOffsets(row.offsets, key);
          row.qualifierOffsets.forEach((qualifier, offsets) {
            expectOrderedOffsets(offsets, '$key ${qualifier.name}');
          });
        });

        test('3 to 5 distinct pairing categories', () {
          expectValidCategories(row.pairingCategories, key);
        });

        test('aliases are non-empty and already normalised', () {
          expect(row.aliases, isNotEmpty);
          for (final alias in row.aliases) {
            expect(alias, matches(_normalisedAlias), reason: '$key: $alias');
          }
        });

        test('every alias is recognised as this denomination', () {
          for (final alias in row.aliases) {
            final recognised = recognize(alias);
            expect(recognised?.denominationKey, key, reason: alias);
            expect(recognised?.wineType, row.wineType, reason: alias);
          }
        });
      });
    }
  });

  test('every alias belongs to exactly one denomination', () {
    final owners = <String, String>{};
    for (final entry in denominationTable.entries) {
      for (final alias in entry.value.aliases) {
        expect(
          owners.containsKey(alias),
          isFalse,
          reason: '"$alias" in ${owners[alias]} and ${entry.key}',
        );
        owners[alias] = entry.key;
      }
    }
  });

  test('keys are unique ignoring case', () {
    final lowered = denominationTable.keys.map((k) => k.toLowerCase());
    expect(lowered.toSet(), hasLength(denominationTable.length));
  });

  group('type rows', () {
    test('every wine type has a row whose type matches its key', () {
      expect(typeTable.keys.toSet(), WineType.values.toSet());
      typeTable.forEach((type, row) => expect(row.wineType, type));
    });

    for (final entry in typeTable.entries) {
      test('${entry.key.name}: offsets ordered and 3 to 5 categories', () {
        expectOrderedOffsets(entry.value.offsets, entry.key.name);
        expectValidCategories(entry.value.pairingCategories, entry.key.name);
      });
    }

    test('generic row: no type, ordered offsets, 3 to 5 categories', () {
      expect(genericTypeProfile.wineType, isNull);
      expectOrderedOffsets(genericTypeProfile.offsets, 'generic');
      expectValidCategories(genericTypeProfile.pairingCategories, 'generic');
    });
  });

  test('rules.md sample rows keep their published offsets', () {
    final barolo = denominationTable['barolo']!;
    expect(
      [barolo.offsets.start, barolo.offsets.peak, barolo.offsets.end],
      [8, 15, 30],
    );
    final riserva = barolo.qualifierOffsets[Qualifier.riserva]!;
    expect([riserva.start, riserva.peak, riserva.end], [10, 18, 35]);
    final generic = genericTypeProfile.offsets;
    expect([generic.start, generic.peak, generic.end], [1, 3, 6]);
  });
}
