import 'firestore_values.dart';
import 'quantity.dart';

/// Field names of `cellars/{cellarId}/wines/{wineId}` (C3).
abstract final class WineFields {
  static const String name = 'name';
  static const String producer = 'producer';
  static const String vintage = 'vintage';
  static const String wineType = 'wineType';
  static const String region = 'region';
  static const String denomination = 'denomination';
  static const String quantity = 'quantity';
  static const String window = 'window';
  static const String pairings = 'pairings';
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';
  static const String updatedBy = 'updatedBy';
}

/// A wine of a cellar as read from Firestore.
///
/// U1 writes only name, vintage, quantity and the audit fields; the other C3
/// fields (producer, type, region, window, pairings) arrive with later units
/// and are ignored here, as are unknown fields (C3: consumers ignore unknown
/// fields).
class Wine {
  const Wine({
    required this.id,
    required this.name,
    required this.vintage,
    required this.storedQuantity,
    this.createdAt,
    this.updatedAt,
    this.updatedBy,
  });

  /// Builds a wine from document data. Never throws: a malformed field falls
  /// back to an empty name, no vintage or quantity 0.
  factory Wine.fromMap(String id, Map<String, Object?> data) => Wine(
    id: id,
    name: FirestoreValues.string(data[WineFields.name]) ?? '',
    vintage: FirestoreValues.integer(data[WineFields.vintage]),
    storedQuantity: FirestoreValues.integer(data[WineFields.quantity]) ?? 0,
    createdAt: FirestoreValues.dateTime(data[WineFields.createdAt]),
    updatedAt: FirestoreValues.dateTime(data[WineFields.updatedAt]),
    updatedBy: FirestoreValues.string(data[WineFields.updatedBy]),
  );

  final String id;
  final String name;

  /// Null means "no vintage".
  final int? vintage;

  /// Raw stored value; may be negative after concurrent decrements (ADR-004).
  final int storedQuantity;

  /// Null while the server timestamp of a pending write is not resolved.
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? updatedBy;

  /// Quantity for display, never below 0 (ADR-004).
  int get quantity => displayQuantity(storedQuantity);

  /// Orders wines by name (case-insensitive), then by vintage, then by id, so
  /// the list is stable (performance-design.md: client-side sort).
  static int compareByName(Wine a, Wine b) {
    final byName = a.name.toLowerCase().compareTo(b.name.toLowerCase());
    if (byName != 0) return byName;
    final byVintage = (a.vintage ?? 0).compareTo(b.vintage ?? 0);
    if (byVintage != 0) return byVintage;
    return a.id.compareTo(b.id);
  }
}
