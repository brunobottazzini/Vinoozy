import 'quantity.dart';
import 'wine_draft.dart';

/// Validation error of the producer (BR1.3).
enum ProducerError { tooLong }

/// Validation error of the quantity (BR1.3).
enum QuantityError { outOfRange }

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
}

/// Result of [WineValidator.validate]: a draft, or one error per field.
class WineValidation {
  const WineValidation({
    this.draft,
    this.nameError,
    this.producerError,
    this.vintageError,
    this.quantityError,
  });

  final WineDraft? draft;
  final NameError? nameError;
  final ProducerError? producerError;
  final VintageError? vintageError;
  final QuantityError? quantityError;

  bool get isValid => draft != null;
}

/// Validation of a wine in the add and edit forms (BR1.3, FR2.4, FR2.6,
/// FR2.7). Pure.
///
/// - name: 1-120 characters after trimming (U1 [WineRules]);
/// - producer: optional, at most 120 characters after trimming;
/// - vintage: 1900 to the current year, or "no vintage";
/// - quantity: an integer from [minQuantity] to 99 (1 when adding, 0 is
///   allowed when editing, BR1.13).
///
/// Only 0.75 L bottles exist, so there is no size field. Each invalid field
/// gets its own error and nothing else changes (AC2.1.3).
abstract final class WineValidator {
  static const int maxProducerLength = 120;

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
    if (nameError != null ||
        vintageError != null ||
        producerError != null ||
        quantityError != null) {
      return WineValidation(
        nameError: nameError,
        producerError: producerError,
        vintageError: vintageError,
        quantityError: quantityError,
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
    return WineValidation(
      draft: draft.withDetails(
        producer: input.producer,
        wineType: input.wineType,
        region: input.region,
        denomination: input.denomination,
      ),
    );
  }
}
