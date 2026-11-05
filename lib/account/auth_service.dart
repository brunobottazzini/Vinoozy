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

/// Google sign-in behind an interface (logical-components.md, "Isolamento"):
/// the gate and the UI never touch Firebase Auth directly, so tests replace
/// it, and the E2E build swaps in the emulator implementation.
abstract interface class AuthService {
  /// The saved session, available synchronously after Firebase starts, also
  /// offline (BR1.2).
  AppUser? get currentUser;

  /// Emits the user on every token change and null when the session ends or
  /// is revoked by the cloud (W2).
  Stream<AppUser?> userChanges();

  /// Google sign-in. Throws [SignInException].
  Future<AppUser> signIn();

  /// Signs out of Firebase and Google. Queued Firestore writes stay on the
  /// phone (security-design.md §1).
  Future<void> signOut();
}
