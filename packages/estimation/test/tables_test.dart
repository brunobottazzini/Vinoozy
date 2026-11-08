// Generated per-row checks of the wine tables (NFR7.2; label-autofill-windows
// NFR5.2, NFR4.6, NFR4.13, BR3.6, BR3.9): every dedicated row and every
// model gets its own tests, and one test walks the whole generated table, so
// a new or corrected row is covered without editing this file.
import 'package:estimation/src/appellations.dart';
import 'package:estimation/src/generated/appellations.g.dart';
import 'package:estimation/src/grapes.dart';
import 'package:estimation/src/models.dart';
import 'package:estimation/src/recognizer.dart';
import 'package:estimation/src/tables.dart';
import 'package:estimation/src/world_tables.dart';
import 'package:test/test.dart';

final _normalisedAlias = RegExp(r'^[a-z0-9]+( [a-z0-9]+)*$');
final _isoCode = RegExp(r'^[A-Z]{2}$');

void expectOrderedOffsets(YearOffsets offsets, String label) {
  expect(offsets.start, greaterThanOrEqualTo(0), reason: '$label start');
  expect(offsets.start, lessThanOrEqualTo(offsets.peak), reason: label);
  expect(offsets.peak, lessThanOrEqualTo(offsets.end), reason: label);
}

/// BR3.9: 0 <= start <= peak <= end and end >= start + 1.
void expectValidWindow(YearOffsets offsets, String label) {
  expectOrderedOffsets(offsets, label);
  expect(offsets.end, greaterThanOrEqualTo(offsets.start + 1), reason: label);
  expect(offsets.isValid, isTrue, reason: label);
}

void expectValidCategories(List<PairingCategory> categories, String label) {
  expect(categories.length, inInclusiveRange(3, 5), reason: label);
  expect(categories.toSet(), hasLength(categories.length), reason: label);
}

/// Every window a row can give: each type, each qualifier, each level.
void expectEveryWindowValid(String key, DenominationProfile row) {
  for (final type in row.types) {
    final offsets = row.offsetsFor(type);
    expectValidWindow(offsets, '$key ${type.name}');
    for (final level in WineLevel.values) {
      expectValidWindow(level.apply(offsets), '$key ${type.name} $level');
    }
  }
  row.qualifierOffsets.forEach((qualifier, offsets) {
    expectValidWindow(offsets, '$key ${qualifier.name}');
    for (final level in WineLevel.values) {
      expectValidWindow(
        level.apply(offsets, qualifierUsed: true),
        '$key ${qualifier.name} $level',
      );
    }
  });
}

void main() {
  final dedicated = {
    for (final entry in denominationTable.entries)
      if (entry.value.dedicated) entry.key: entry.value,
  };
  final generated = {
    for (final entry in denominationTable.entries)
      if (!entry.value.dedicated) entry.key: entry.value,
  };

  group('size of the tables (FR3.1, owner decision 94dc0883)', () {
    test('at least 500 dedicated rows, the 47 Italian ones included', () {
      expect(dedicated.length, greaterThanOrEqualTo(500));
      expect(italianDenominationTable, hasLength(47));
      for (final key in italianDenominationTable.keys) {
        expect(dedicated, contains(key));
      }
    });

    test('every hand-written world row is in the table under its key', () {
      for (final row in worldDenominations) {
        final key = row.key ?? keyOfWords(tokenizeAll(row.name!));
        expect(dedicated, contains(key), reason: row.name);
      }
      expect(dedicated.length, 47 + worldDenominations.length);
    });

    test('every generated row of the file is in the table', () {
      expect(generated.length, generatedAppellationRows.length);
    });
  });

  group('dedicated rows', () {
    for (final MapEntry(:key, value: row) in dedicated.entries) {
      group(key, () {
        test('a valid window for every type, qualifier and level (BR3.9)', () {
          expectEveryWindowValid(key, row);
        });

        test('forms normalised, recognised as this row, country ISO', () {
          expect(row.aliases.every(_normalisedAlias.hasMatch), isTrue);
          final forms = formsOf(row);
          expect(forms, isNotEmpty);
          for (final (form, _) in forms) {
            expect(form, matches(_normalisedAlias), reason: '$key: $form');
            expect(findAlias(form.split(' '))?.denominationKey, key);
          }
          for (final weak in row.weakAliases) {
            expect(forms.map((f) => f.$1), contains(weak), reason: key);
          }
          expect(row.country, matches(_isoCode));
          if (row.pairingCategories.isNotEmpty) {
            expectValidCategories(row.pairingCategories, key);
          }
        });
      });
    }
  });

  group('models of the generated rows (BR3.7, NFR4.6)', () {
    for (final MapEntry(key: model, value: types)
        in appellationTemplates.entries) {
      test('$model: a valid window per type, used by a generated row', () {
        expect(types, isNotEmpty);
        types.forEach((type, offsets) {
          expectValidWindow(offsets, '$model ${type.name}');
        });
        expect(
          generated.values.any((row) => row.templateKey == model),
          isTrue,
          reason: '$model has no row',
        );
      });
    }

    test('the default types of a row without types are in every model', () {
      for (final types in appellationTemplates.values) {
        expect(defaultGeneratedTypes.where(types.containsKey), isNotEmpty);
      }
    });
  });

  test('the whole generated table: every row and type gives a valid window, '
      'its model exists, its key and forms are unique (BR3.6, BR3.9, '
      'NFR4.13)', () {
    expect(generated, isNotEmpty);
    for (final MapEntry(:key, value: row) in generated.entries) {
      expect(appellationTemplates, contains(row.templateKey), reason: key);
      expect(row.country, matches(_isoCode), reason: key);
      expect(row.name, isNotNull, reason: key);
      expectEveryWindowValid(key, row);
      for (final type in row.types) {
        expect(
          row.offsetsFor(type),
          appellationTemplates[row.templateKey]![type],
          reason: '$key ${type.name}',
        );
      }
      expect(row.qualifierOffsets, isEmpty, reason: key);
    }
  });

  test('every form belongs to exactly one row, never to a grape (BR3.2)', () {
    final owners = <String, String>{};
    final grapes = {for (final g in grapeTable.values) ...grapeFormsOf(g)};
    for (final MapEntry(:key, value: row) in denominationTable.entries) {
      for (final (form, _) in formsOf(row)) {
        expect(
          owners.containsKey(form),
          isFalse,
          reason: '"$form" in ${owners[form]} and $key',
        );
        expect(grapes.contains(form), isFalse, reason: '$form of $key');
        owners[form] = key;
      }
    }
  });

  test('keys are unique ignoring case and at most 60 characters', () {
    final lowered = denominationTable.keys.map((k) => k.toLowerCase());
    expect(lowered.toSet(), hasLength(denominationTable.length));
    for (final key in denominationTable.keys) {
      expect(key.length, inInclusiveRange(1, 60), reason: key);
    }
  });

  group('type rows', () {
    test('every wine type has a row whose type matches its key', () {
      expect(typeTable.keys.toSet(), WineType.values.toSet());
      typeTable.forEach((type, row) => expect(row.wineType, type));
    });

    for (final entry in typeTable.entries) {
      test('${entry.key.name}: offsets ordered and 3 to 5 categories', () {
        expectValidWindow(entry.value.offsets, entry.key.name);
        expectValidCategories(entry.value.pairingCategories, entry.key.name);
      });
    }

    test('generic row: no type, ordered offsets, 3 to 5 categories', () {
      expect(genericTypeProfile.wineType, isNull);
      expectValidWindow(genericTypeProfile.offsets, 'generic');
      expectValidCategories(genericTypeProfile.pairingCategories, 'generic');
    });
  });

  test('rules.md sample rows keep their published offsets', () {
    final barolo = denominationTable['barolo']!;
    expect(barolo.offsets, const YearOffsets(8, 15, 30));
    expect(
      barolo.qualifierOffsets[Qualifier.riserva],
      const YearOffsets(10, 18, 35),
    );
    expect(genericTypeProfile.offsets, const YearOffsets(1, 3, 6));
  });

  group('world-tables.md values', () {
    YearOffsets offsets(String key, [WineType? type]) {
      final row = denominationTable[key]!;
      return row.offsetsFor(type ?? row.wineType);
    }

    YearOffsets qualifier(String key, Qualifier q) =>
        denominationTable[key]!.qualifierOffsets[q]!;

    test('France', () {
      expect(offsets('bordeauxRouge'), const YearOffsets(2, 5, 10));
      expect(
        offsets('bordeauxRouge', WineType.white),
        const YearOffsets(1, 2, 5),
      );
      expect(offsets('pauillac'), const YearOffsets(8, 15, 30));
      expect(
        qualifier('pauillac', Qualifier.grandCru),
        const YearOffsets(10, 20, 40),
      );
      expect(offsets('coteDeNuits'), const YearOffsets(5, 10, 20));
      expect(
        qualifier('gevreyChambertin', Qualifier.premierCru),
        const YearOffsets(6, 12, 22),
      );
      expect(
        qualifier('chablis', Qualifier.grandCru),
        const YearOffsets(4, 10, 20),
      );
      expect(
        qualifier('champagne', Qualifier.vintage),
        const YearOffsets(5, 10, 20),
      );
      expect(offsets('cremantDAlsace'), const YearOffsets(1, 2, 5));
      expect(
        denominationTable['cremantDAlsace']!.wineType,
        WineType.sparklingClassic,
      );
    });

    test('Spain, Portugal, Germany', () {
      expect(
        qualifier('rioja', Qualifier.granReserva),
        const YearOffsets(6, 12, 25),
      );
      expect(
        qualifier('riberaDelDuero', Qualifier.crianza),
        const YearOffsets(3, 6, 12),
      );
      expect(
        qualifier('porto', Qualifier.vintage),
        const YearOffsets(15, 30, 60),
      );
      expect(qualifier('porto', Qualifier.lbv), const YearOffsets(4, 8, 15));
      expect(
        qualifier('mosel', Qualifier.auslese),
        const YearOffsets(5, 12, 30),
      );
      expect(offsets('nahe'), const YearOffsets(2, 5, 12));
    });

    test('New World', () {
      expect(offsets('napaValley'), const YearOffsets(4, 8, 18));
      expect(offsets('napaValley', WineType.white), const YearOffsets(1, 3, 7));
      expect(offsets('mendoza', WineType.white), const YearOffsets(0, 2, 4));
      expect(
        qualifier('valleDelMaipo', Qualifier.granReserva),
        const YearOffsets(4, 8, 15),
      );
      expect(offsets('marlborough'), const YearOffsets(0, 2, 4));
      expect(offsets('stellenbosch'), const YearOffsets(3, 6, 12));
    });
  });

  test('the weak aliases of world-tables.md are weak (BR1.2)', () {
    for (final (key, form) in const [
      ('toro', 'toro'),
      ('cava', 'cava'),
      ('porto', 'port'),
      ('baden', 'baden'),
      ('napaValley', 'napa'),
      ('salta', 'salta'),
      ('rioja', 'rioja'),
    ]) {
      expect(denominationTable[key]!.weakAliases, contains(form), reason: key);
    }
  });

  test('the generated file comes from the sample until Build and Test', () {
    expect(generatedAppellationsSource, isNotEmpty);
    expect(appellationsSource, generatedAppellationsSource);
  });
}
