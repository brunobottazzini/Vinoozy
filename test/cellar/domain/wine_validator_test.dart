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

  group('ux-redesign FR1.2 FR1.5 country and region', () {
    WineValidation withOrigin({String? country, String? region}) =>
        WineValidator.validate(
          WineInput(
            id: 'w1',
            name: 'Malbec',
            vintage: '2019',
            noVintage: false,
            quantity: 1,
            country: country,
            region: region,
          ),
          currentYear: currentYear,
        );

    test('a chosen country and listed region are saved as they are', () {
      final draft = withOrigin(country: 'AR', region: 'Mendoza').draft!;
      expect(draft.country, 'AR');
      expect(draft.region, 'Mendoza');
    });

    test('a translated region is saved with its canonical name', () {
      final draft = withOrigin(country: 'FR', region: ' Borgogna ').draft!;
      expect(draft.region, 'Bourgogne');
      expect(draft.country, 'FR');
    });

    test('R-06 an Italian region without country saves Italy', () {
      final draft = withOrigin(region: 'piemonte').draft!;
      expect(draft.country, 'IT');
      expect(draft.region, 'Piemonte');
    });

    test('a free region of 100 characters is valid, trimmed', () {
      final free = 'a' * 100;
      final draft = withOrigin(country: 'MP', region: '  $free  ').draft!;
      expect(draft.region, free);
      expect(draft.country, 'MP');
    });

    test('a region over 120 characters is refused', () {
      final result = withOrigin(region: 'b' * 121);
      expect(result.isValid, isFalse);
      expect(result.regionError, RegionError.tooLong);
      expect(withOrigin(region: 'b' * 120).isValid, isTrue);
    });

    test('an unknown or lower-case country code is refused', () {
      for (final code in ['XX', 'it', 'ITA', '']) {
        final result = withOrigin(country: code);
        expect(result.countryError, CountryError.unknown, reason: code);
        expect(result.draft, isNull);
      }
    });

    test('no country and no region stay absent', () {
      final draft = withOrigin(region: '   ').draft!;
      expect(draft.country, isNull);
      expect(draft.region, isNull);
    });
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
