import 'app_user.dart';

/// Why a sign-in did not complete (BR1.1).
enum SignInFailureKind { cancelled, network, failed }

/// Sign-in did not complete; no data was created.
class SignInException implements Exception {
  const SignInException(this.kind, [this.cause]);

  final SignInFailureKind kind;
  final Object? cause;

  @override
  String toString() => 'SignInException(${kind.name}): $cause';
}

/// Outcome of [AuthService.reauthenticate] (u8-account BR1.6, NFR4.6).
enum ReauthResult {
  /// The same Google account signed in again: the deletion may run.
  confirmed,

  /// The person closed the Google picker.
  cancelled,

  /// Another Google account was chosen: nothing is deleted, and that account
  /// is signed out of Google again.
  differentAccount,

  /// No network, or Google or Firebase failed.
  failed,
}

/// Why [AuthService.deleteUser] failed.
enum DeleteUserFailure {
  /// Firebase wants a recent sign-in: reauthenticate and repeat step 6.
  requiresRecentLogin,

  /// Any other error (network, server).
  failed,
}

/// [AuthService.deleteUser] did not delete the Firebase user.
class DeleteUserException implements Exception {
  const DeleteUserException(this.failure, [this.cause]);

  final DeleteUserFailure failure;
  final Object? cause;

  @override
  String toString() => 'DeleteUserException(${failure.name})';
}

/// Google sign-in behind an interface (logical-components.md, "Isolamento"):
/// the gate and the UI never touch Firebase Auth directly, so tests replace
/// it, and the E2E build swaps in the emulator implementation.
abstract interface class AuthService {
  /// The saved session, available synchronously after Firebase starts, also
  /// offline (BR1.2).
  AppUser? get currentUser;

  /// The profile photo of the Google account, when it has one (u8-account
  /// BR1.2); read from the session in memory, never from the cloud.
  String? get photoUrl;

  /// Emits the user on every token change and null when the session ends or
  /// is revoked by the cloud (W2).
  Stream<AppUser?> userChanges();

  /// Google sign-in. Throws [SignInException].
  Future<AppUser> signIn();

  /// Signs out of Firebase and Google. Queued Firestore writes stay on the
  /// phone (security-design.md §1).
  Future<void> signOut();

  /// u8-account NFR4.6: signs in again with Google and checks that the uid is
  /// the current one. Never throws.
  Future<ReauthResult> reauthenticate();

  /// u8-account BR1.7 step 6: deletes the Firebase Authentication user.
  /// Throws [DeleteUserException].
  Future<void> deleteUser();
}
