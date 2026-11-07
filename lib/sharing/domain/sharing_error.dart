/// Errors of the sharing service (C4; security-design.md §4).
///
/// Every value maps to one fixed, translated message: no email or name ever
/// reaches a message or a crash report (NFR8.2).
enum SharingError {
  /// The email is not a valid address (BR1.2, AC8.1.3).
  invalidEmail,

  /// The owner tried to invite their own address (BR1.2).
  selfInvite,

  /// The address already has an `invited` or `active` invitation (BR1.2).
  alreadyInvited,

  /// The cellar already has 2 open invitations (BR1.2, AC8.1.2).
  limitReached,

  /// The cloud refused the change: the caller is not the owner, or the
  /// transition is not allowed (BR1.1, BR1.13).
  notOwner,

  /// The invitation no longer exists (C4).
  notFound,

  /// No network: management needs the server's confirmation (BR1.11).
  offline,

  /// No confirmation within 10 seconds, or the server was unavailable
  /// (BR1.11, NFR6.2): "Could not complete, try again".
  timeout,

  /// Any other failure: "Could not complete, try again".
  failed,
}

/// A sharing operation that failed with [error].
class SharingException implements Exception {
  const SharingException(this.error);

  final SharingError error;

  @override
  String toString() => 'SharingException(${error.name})';
}
