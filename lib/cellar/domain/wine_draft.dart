import 'quantity.dart';
import 'wine.dart';

/// Validation errors of the wine name (BR2.1).
enum NameError { empty, tooLong }

/// Validation error of the vintage (BR2.2).
enum VintageError { outOfRange }

/// Rules of the add-wine form, shared by field validation (on focus loss)
/// and by the final check on Save.
abstract final class WineRules {
  static const int maxNameLength = 120;
  static const int minVintage = 1900;

  /// BR2.1: 1-120 characters after trimming outer spaces. Length counts
  /// Unicode code points, like the length check of the security rules.
  static NameError? validateName(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return NameError.empty;
    if (trimmed.runes.length > maxNameLength) return NameError.tooLong;
    return null;
  }

  /// BR2.2: a year between 1900 and [currentYear], or "no vintage". An empty
  /// field without the "no vintage" switch is an error: the user must choose.
  static VintageError? validateVintage(
    String raw, {
    required bool noVintage,
    required int currentYear,
  }) {
    if (noVintage) return null;
    final year = int.tryParse(raw.trim());
    if (year == null || year < minVintage || year > currentYear) {
      return VintageError.outOfRange;
    }
    return null;
  }
}

/// Result of [WineDraft.validate]: either a draft or the field errors.
class DraftValidation {
  const DraftValidation._({this.draft, this.nameError, this.vintageError});

  final WineDraft? draft;
  final NameError? nameError;
  final VintageError? vintageError;

  bool get isValid => draft != null;
}

/// A validated wine ready to be written (US2.1, BR2.1-BR2.5).
///
/// The id is generated once when the form opens (BR2.4). There is no bottle
/// size field: every bottle is 0.75 L in U1 (BR2.5).
class WineDraft {
  const WineDraft._({
    required this.id,
    required this.name,
    required this.vintage,
    required this.quantity,
  });

  /// Validates raw form input. [currentYear] comes from the injected clock.
  static DraftValidation validate({
    required String id,
    required String rawName,
    required String rawVintage,
    required bool noVintage,
    required int quantity,
    required int currentYear,
  }) {
    if (id.isEmpty) throw ArgumentError.value(id, 'id', 'must not be empty');
    final nameError = WineRules.validateName(rawName);
    final vintageError = WineRules.validateVintage(
      rawVintage,
      noVintage: noVintage,
      currentYear: currentYear,
    );
    if (nameError != null || vintageError != null) {
      return DraftValidation._(
        nameError: nameError,
        vintageError: vintageError,
      );
    }
    if (!QuantityLimits.isValid(quantity)) {
      throw RangeError.range(
        quantity,
        QuantityLimits.min,
        QuantityLimits.max,
        'quantity',
      );
    }
    return DraftValidation._(
      draft: WineDraft._(
        id: id,
        name: rawName.trim(),
        vintage: noVintage ? null : int.parse(rawVintage.trim()),
        quantity: quantity,
      ),
    );
  }

  final String id;

  /// Name with outer spaces removed.
  final String name;

  /// Null for "no vintage".
  final int? vintage;
  final int quantity;

  /// Fields written on creation, without `createdAt`/`updatedAt`: the
  /// repository sets both to the server timestamp, as the rules require
  /// (`== request.time`).
  Map<String, Object?> toCreateFields({required String uid}) => {
    WineFields.name: name,
    WineFields.vintage: vintage,
    WineFields.quantity: quantity,
    WineFields.updatedBy: uid,
  };
}
