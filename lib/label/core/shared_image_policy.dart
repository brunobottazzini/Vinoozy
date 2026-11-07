/// Where the person is with the account when a shared image waits (BR1.4).
enum ShareAccount {
  /// Starting up, or on the sign-in screen with no attempt yet: wait.
  unknown,

  /// A sign-in is running (a slow Google sign-in must not expire the photo).
  signingIn,

  /// A sign-in ended without an account: the image is dropped at once.
  signInCancelled,

  /// Signed in: the cellar screens are shown.
  signedIn,

  /// Blocked account, reset, failed check: no reading.
  unavailable,
}

/// What to do with a waiting shared image.
enum ShareDecision { wait, read, notAllowed, expired, discard }

/// The rules of a shared image before it is read (BR1.4 and "Chiarimenti
/// dopo la revisione"; NFR4.5). Pure: the caller owns the timers.
///
/// - Until the sign-in is done the image waits as a reference only; a
///   cancelled sign-in or an unavailable account drops it.
/// - Signed in, with the cellar ready: "can edit" reads it, "read only"
///   gives "Non puoi aggiungere vini a questa cantina". While the permission
///   is still loading it waits at most [canEditWait], then counts as absent.
/// - Signed in but the cellar never gets ready: after [readWindow] from the
///   end of the sign-in the image is dropped with "Non è stato possibile
///   leggere la foto condivisa".
class SharedImagePolicy {
  const SharedImagePolicy();

  static const Duration readWindow = Duration(seconds: 60);
  static const Duration canEditWait = Duration(seconds: 5);

  /// [canEdit] is `null` while the permission is loading.
  /// [canEditWaitOver] is true [canEditWait] after the cellar got ready;
  /// [readWindowOver] is true [readWindow] after the sign-in completed.
  ShareDecision decide({
    required ShareAccount account,
    required bool cellarReady,
    required bool? canEdit,
    required bool canEditWaitOver,
    required bool readWindowOver,
  }) {
    switch (account) {
      case ShareAccount.signInCancelled:
      case ShareAccount.unavailable:
        return ShareDecision.discard;
      case ShareAccount.unknown:
      case ShareAccount.signingIn:
        return ShareDecision.wait;
      case ShareAccount.signedIn:
        break;
    }
    if (!cellarReady) {
      return readWindowOver ? ShareDecision.expired : ShareDecision.wait;
    }
    if (canEdit == true) return ShareDecision.read;
    if (canEdit == false || canEditWaitOver) return ShareDecision.notAllowed;
    return readWindowOver ? ShareDecision.expired : ShareDecision.wait;
  }
}
