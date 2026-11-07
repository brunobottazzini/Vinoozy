/// Fixed reasons of the account errors sent to the crash reports
/// (u8-account NFR8.2). Nothing else about an account operation is reported.
abstract final class AccountErrorReason {
  static const String deleteFailed = 'account_delete_failed';
  static const String signOutFailed = 'account_signout_failed';
  static const String reauthFailed = 'account_reauth_failed';

  static const List<String> all = [deleteFailed, signOutFailed, reauthFailed];
}

/// The typed error U8 reports instead of the original exception (NFR8.2,
/// security-design.md §4).
///
/// It carries only a fixed [reason], the deletion [step] (when there is one)
/// and the runtime type name of the original exception. Its [toString] never
/// includes the original message, so emails, names, uids and document paths
/// cannot reach the reports even before `ErrorReporter` sanitizes them.
class AccountOperationError implements Exception {
  AccountOperationError(this.reason, {this.step, Object? cause})
    : causeType = cause == null ? 'none' : _typeName(cause) {
    if (!AccountErrorReason.all.contains(reason)) {
      throw ArgumentError.value(reason, 'reason', 'not a fixed account reason');
    }
  }

  final String reason;

  /// Index of the deletion step that failed (BR1.7), or null.
  final int? step;

  /// Runtime type name of the original exception, e.g. `FirebaseException`.
  final String causeType;

  /// Generic type arguments may carry nothing personal, but they add noise:
  /// only the bare type name is kept.
  static String _typeName(Object cause) {
    final name = cause.runtimeType.toString();
    final generic = name.indexOf('<');
    return generic < 0 ? name : name.substring(0, generic);
  }

  @override
  String toString() => step == null
      ? 'AccountOperationError($reason, $causeType)'
      : 'AccountOperationError($reason, step $step, $causeType)';
}
