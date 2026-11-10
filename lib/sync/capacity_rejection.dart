import 'package:firebase_core/firebase_core.dart' show FirebaseException;

/// Why the cloud refused a wine write that changes the number of active
/// wines (freemium-plus FR2.5). The app keeps the change as a recoverable
/// draft and tells the person this reason; it is never shown as synced.
enum CapacityRejection {
  /// The write would take the owner's cellar over its active-wine limit
  /// while the limit is on and the owner has no valid Plus (FR2.4).
  capacityLimit('capacityLimit'),

  /// The active-wine counter sent with the write no longer matched the wine
  /// on the server (another device changed it meanwhile, D1), and the single
  /// retry with the wine read again was refused too.
  capacityConflict('capacityConflict');

  const CapacityRejection(this.wireValue);

  /// Value stored in the local ledger.
  final String wireValue;

  /// Null for a missing or unknown value, so a ledger written by a newer
  /// app version never breaks this one.
  static CapacityRejection? fromWire(Object? value) {
    for (final reason in values) {
      if (reason.wireValue == value) return reason;
    }
    return null;
  }
}

/// A rules refusal of a counted wine write, with its [reason].
///
/// It keeps the code of the original [FirebaseException], so the existing
/// classification (`classifyWriteError`) still sees a rejection; the access
/// check of `reportWriteRejected` knows it is not a lost access.
class CapacityRejectedException extends FirebaseException {
  CapacityRejectedException(this.reason, FirebaseException cause)
    : super(plugin: cause.plugin, code: cause.code, message: cause.message);

  final CapacityRejection reason;

  @override
  String toString() => 'CapacityRejectedException(${reason.wireValue}, $code)';
}
