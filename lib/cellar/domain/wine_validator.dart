import 'package:estimation/estimation.dart' show WineLevel;

import 'quantity.dart';
import 'wine_draft.dart';
import 'wine_origins.dart';

/// Validation error of the producer (BR1.3).
enum ProducerError { tooLong }

/// Validation error of the quantity (BR1.3).
enum QuantityError { outOfRange }

/// Validation error of the region (ux-redesign FR1.2, review R-03).
enum RegionError { tooLong }

/// Validation error of the country (ux-redesign FR1.5).
enum CountryError { unknown }

/// Validation error of the denomination (label-autofill-windows: the field
/// of the form; the rules accept at most 120 characters).
enum DenominationError { tooLong }

/// Raw input of the add and edit forms.
class WineInput {
  const WineInput({
    required this.id,
    required this.name,
    required this.vintage,
    required this.noVintage,
    required this.quantity,
    this.producer = '',
    this.wineType,
    this.region,
    this.denomination,
    this.country,
    this.level,
  });

  final String id;
  final String name;
  final String vintage;
  final bool noVintage;
  final int quantity;
  final String producer;

  /// A C2 `WineType` name, or `null` for "not specified".
  final String? wineType;
  final String? region;
  final String? denomination;

  /// An ISO 3166-1 alpha-2 code, or `null` for "no country".
  final String? country;

  /// The level chosen or accepted (BR4.3), `null` when not chosen.
  final WineLevel? level;
}

/// Result of [WineValidator.validate]: a draft, or one error per field.
class WineValidation {
  const WineValidation({
    this.draft,
    this.nameError,
    this.producerError,
    this.vintageError,
    this.quantityError,
    this.regionError,
    this.countryError,
    this.denominationError,
  });

  final WineDraft? draft;
  final NameError? nameError;
  final ProducerError? producerError;
  final VintageError? vintageError;
  final QuantityError? quantityError;
  final RegionError? regionError;
  final CountryError? countryError;
  final DenominationError? denominationError;

  bool get isValid => draft != null;
}

/// Validation of a wine in the add and edit forms (BR1.3, FR2.4, FR2.6,
/// FR2.7; ux-redesign FR1.2, FR1.5). Pure.
///
/// - name: 1-120 characters after trimming (U1 [WineRules]);
/// - producer: optional, at most 120 characters after trimming;
/// - vintage: 1900 to the current year, or "no vintage";
/// - quantity: an integer from [minQuantity] to 99 (1 when adding, 0 is
///   allowed when editing, BR1.13);
/// - region: optional, 1-120 characters after trimming (blank is "no
///   region"); a listed region written in any language is saved with its
///   canonical name (review R-02, R-07);
/// - country: optional, an ISO 3166-1 alpha-2 code; without one, an Italian
///   region saves Italy (review R-06).
///
/// Only 0.75 L bottles exist, so there is no size field. Each invalid field
/// gets its own error and nothing else changes (AC2.1.3).
abstract final class WineValidator {
  static const int maxProducerLength = 120;

  /// Same limit as the security rules (`validOptionalText`, review R-03).
  static const int maxRegionLength = 120;

  static WineValidation validate(
    WineInput input, {
    required int currentYear,
    int minQuantity = QuantityLimits.min,
  }) {
    final nameError = WineRules.validateName(input.name);
    final vintageError = WineRules.validateVintage(
      input.vintage,
      noVintage: input.noVintage,
      currentYear: currentYear,
    );
    final producerError = input.producer.trim().runes.length > maxProducerLength
        ? ProducerError.tooLong
        : null;
    final quantityError =
        input.quantity < minQuantity || input.quantity > QuantityLimits.max
        ? QuantityError.outOfRange
        : null;
    final regionError = validateRegion(input.region);
    final countryError = validateCountry(input.country);
    final denominationError =
        (input.denomination?.trim().runes.length ?? 0) > maxDenominationLength
        ? DenominationError.tooLong
        : null;
    if (nameError != null ||
        vintageError != null ||
        producerError != null ||
        quantityError != null ||
        regionError != null ||
        countryError != null ||
        denominationError != null) {
      return WineValidation(
        nameError: nameError,
        producerError: producerError,
        vintageError: vintageError,
        quantityError: quantityError,
        regionError: regionError,
        countryError: countryError,
        denominationError: denominationError,
      );
    }
    // WineDraft keeps the U1 range 1-99; an edit to 0 bottles is a valid
    // change of quantity, carried by the edit form, not by the draft.
    final draft = WineDraft.validate(
      id: input.id,
      rawName: input.name,
      rawVintage: input.vintage,
      noVintage: input.noVintage,
      quantity: QuantityLimits.clamp(input.quantity),
      currentYear: currentYear,
    ).draft!;
    final region = WineOrigins.canonicalRegion(input.country, input.region);
    return WineValidation(
      draft: draft.withDetails(
        producer: input.producer,
        wineType: input.wineType,
        region: region,
        denomination: input.denomination,
        country: WineOrigins.effectiveCountry(input.country, region),
        level: input.level,
      ),
    );
  }

  /// Same limit as the security rules (`validOptionalText`).
  static const int maxDenominationLength = 120;

  /// At most [maxRegionLength] characters after trimming, counted as
  /// Unicode code points like the rules; blank is no region.
  static RegionError? validateRegion(String? raw) {
    final trimmed = raw?.trim() ?? '';
    return trimmed.runes.length > maxRegionLength ? RegionError.tooLong : null;
  }

  /// `null` or an ISO 3166-1 alpha-2 code.
  static CountryError? validateCountry(String? code) =>
      code == null || WineOrigins.isCountryCode(code)
      ? null
      : CountryError.unknown;
}
