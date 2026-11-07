// WineValidator (u4-cellar BR1.3; FR2.4, FR2.6, FR2.7; AC2.1.3).
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/cellar/domain/wine_draft.dart';
import 'package:vinoozy/cellar/domain/wine_validator.dart';

void main() {
  const currentYear = 2026;

  WineValidation validate({
    String name = 'Barolo',
    String producer = 'Cantina Esempio',
    String vintage = '2016',
    bool noVintage = false,
    int quantity = 1,
    int minQuantity = 1,
    String? wineType,
  }) => WineValidator.validate(
    WineInput(
      id: 'w1',
      name: name,
      producer: producer,
      vintage: vintage,
      noVintage: noVintage,
      quantity: quantity,
      wineType: wineType,
      region: '  Piemonte ',
      denomination: '',
    ),
    currentYear: currentYear,
    minQuantity: minQuantity,
  );

  test('BR1.3 a valid wine gives a trimmed draft with the details', () {
    final result = validate(name: '  Barolo  ', wineType: 'redStructured');

    expect(result.isValid, isTrue);
    final draft = result.draft!;
    expect(draft.name, 'Barolo');
    expect(draft.producer, 'Cantina Esempio');
    expect(draft.vintage, 2016);
    expect(draft.wineType, 'redStructured');
    expect(draft.region, 'Piemonte');
    expect(draft.denomination, isNull, reason: 'blank text is null');
  });

  test('BR1.3 the name has 1 to 120 characters after trimming', () {
    expect(validate(name: 'a' * 120).isValid, isTrue);
    expect(validate(name: 'a' * 121).nameError, NameError.tooLong);
    expect(validate(name: '   ').nameError, NameError.empty);
  });

  test('BR1.3 the producer is optional and at most 120 characters', () {
    expect(validate(producer: '').draft!.producer, isNull);
    expect(validate(producer: 'p' * 120).isValid, isTrue);
    expect(validate(producer: 'p' * 121).producerError, ProducerError.tooLong);
  });

  test('BR1.3 the vintage is 1900 to the current year or none', () {
    expect(validate(vintage: '1900').isValid, isTrue);
    expect(validate(vintage: '$currentYear').isValid, isTrue);
    expect(validate(vintage: '1899').vintageError, VintageError.outOfRange);
    expect(
      validate(vintage: '${currentYear + 1}').vintageError,
      VintageError.outOfRange,
    );
    expect(validate(vintage: '', noVintage: true).draft!.vintage, isNull);
  });

  test('BR1.3 the quantity is 1-99 when adding, 0-99 when editing', () {
    expect(validate(quantity: 1).isValid, isTrue);
    expect(validate(quantity: 99).isValid, isTrue);
    expect(validate(quantity: 0).quantityError, QuantityError.outOfRange);
    expect(validate(quantity: 100).quantityError, QuantityError.outOfRange);
    expect(validate(quantity: 0, minQuantity: 0).isValid, isTrue);
  });

  test('BR1.3 every invalid field gets its own error at once', () {
    final result = validate(
      name: '',
      producer: 'p' * 121,
      vintage: '1800',
      quantity: 0,
    );

    expect(result.isValid, isFalse);
    expect(result.draft, isNull);
    expect(result.nameError, NameError.empty);
    expect(result.producerError, ProducerError.tooLong);
    expect(result.vintageError, VintageError.outOfRange);
    expect(result.quantityError, QuantityError.outOfRange);
  });

  test('WineDraft.withDetails keeps the U1 creation fields unchanged', () {
    final draft = validate().draft!;

    expect(draft.toCreateFields(uid: 'user-a').keys, {
      'name',
      'vintage',
      'quantity',
      'updatedBy',
    });
  });
}
