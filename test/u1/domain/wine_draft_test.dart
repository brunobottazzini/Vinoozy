import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/cellar/domain/wine.dart';
import 'package:vinoozy/cellar/domain/wine_draft.dart';

void main() {
  const currentYear = 2026;

  DraftValidation validate({
    String name = 'Barolo',
    String vintage = '2016',
    bool noVintage = false,
    int quantity = 2,
  }) => WineDraft.validate(
    id: 'wine-1',
    rawName: name,
    rawVintage: vintage,
    noVintage: noVintage,
    quantity: quantity,
    currentYear: currentYear,
  );

  group('name (BR2.1)', () {
    test('a valid name is trimmed and kept', () {
      final result = validate(name: '  Barolo DOCG  ');

      expect(result.isValid, isTrue);
      expect(result.draft!.name, 'Barolo DOCG');
    });

    test('an empty name is rejected', () {
      expect(WineRules.validateName(''), NameError.empty);
      expect(validate(name: '').nameError, NameError.empty);
    });

    test('a name of only spaces is rejected as empty', () {
      expect(validate(name: '    ').nameError, NameError.empty);
    });

    test('120 characters are accepted, 121 are rejected', () {
      final name120 = 'a' * 120;
      final name121 = 'a' * 121;

      expect(WineRules.validateName(name120), isNull);
      expect(WineRules.validateName(name121), NameError.tooLong);
      expect(WineRules.validateName('  $name120  '), isNull);
    });

    test('length counts code points, not UTF-16 units', () {
      // 120 emoji are 240 UTF-16 units but 120 characters.
      expect(WineRules.validateName('\u{1F377}' * 120), isNull);
      expect(WineRules.validateName('\u{1F377}' * 121), NameError.tooLong);
    });
  });

  group('vintage (BR2.2)', () {
    test('1900 and the current year are the inclusive limits', () {
      expect(validate(vintage: '1900').isValid, isTrue);
      expect(validate(vintage: '$currentYear').isValid, isTrue);
    });

    test('1899 and the current year + 1 are rejected', () {
      expect(validate(vintage: '1899').vintageError, VintageError.outOfRange);
      expect(
        validate(vintage: '${currentYear + 1}').vintageError,
        VintageError.outOfRange,
      );
    });

    test('"no vintage" stores null and ignores the text field', () {
      final result = validate(vintage: 'abc', noVintage: true);

      expect(result.isValid, isTrue);
      expect(result.draft!.vintage, isNull);
    });

    test('empty or non-numeric vintage without the switch is an error', () {
      expect(validate(vintage: '').vintageError, VintageError.outOfRange);
      expect(validate(vintage: '20x6').vintageError, VintageError.outOfRange);
    });

    test('name and vintage errors are reported together', () {
      final result = validate(name: '', vintage: '1800');

      expect(result.isValid, isFalse);
      expect(result.draft, isNull);
      expect(result.nameError, NameError.empty);
      expect(result.vintageError, VintageError.outOfRange);
    });
  });

  group('quantity (BR2.3)', () {
    test('1 and 99 are accepted', () {
      expect(validate(quantity: 1).draft!.quantity, 1);
      expect(validate(quantity: 99).draft!.quantity, 99);
    });

    test('0 and 100 are programming errors of the stepper', () {
      expect(() => validate(quantity: 0), throwsRangeError);
      expect(() => validate(quantity: 100), throwsRangeError);
    });
  });

  group('creation fields (BR2.4, BR2.5)', () {
    test('only the U1 fields of C3 are written, with updatedBy = uid', () {
      final fields = validate(
        name: ' Barolo ',
        vintage: '2016',
      ).draft!.toCreateFields(uid: 'user-a');

      expect(fields, {
        WineFields.name: 'Barolo',
        WineFields.vintage: 2016,
        WineFields.quantity: 2,
        WineFields.updatedBy: 'user-a',
      });
      expect(fields.containsKey('format'), isFalse);
    });

    test('an empty id is rejected', () {
      expect(
        () => WineDraft.validate(
          id: '',
          rawName: 'Barolo',
          rawVintage: '2016',
          noVintage: false,
          quantity: 1,
          currentYear: currentYear,
        ),
        throwsArgumentError,
      );
    });
  });
}
