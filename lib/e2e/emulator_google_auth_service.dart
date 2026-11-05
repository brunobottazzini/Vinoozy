import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';

import '../account/app_user.dart';
import '../account/auth_service.dart';
import '../account/firebase_user_mapping.dart';

/// A Google identity used by the end-to-end tests.
class E2EIdentity {
  const E2EIdentity({required this.sub, required this.email});

  final String sub;
  final String email;
}

/// [AuthService] for builds made with `--dart-define=E2E=true` only
/// (cicd-pipeline.md §1). It signs in to the Auth Emulator with an unsigned
/// Google id token, which only the emulator accepts; the user gets
/// `sign_in_provider = google.com`, so the real rules apply. Release builds
/// do not reference this class and tree-shake it away (checked by
/// tool/check_release_build.sh).
class EmulatorGoogleAuthService implements AuthService {
  EmulatorGoogleAuthService(this._auth);

  final FirebaseAuth _auth;

  /// Identity used by the next [signIn]; set by the test before tapping
  /// "Continue with Google".
  static E2EIdentity? nextIdentity;

  @override
  AppUser? get currentUser {
    final user = _auth.currentUser;
    return user == null ? null : appUserFromFirebase(user);
  }

  @override
  Stream<AppUser?> userChanges() => _auth.idTokenChanges().map(
    (user) => user == null ? null : appUserFromFirebase(user),
  );

  @override
  Future<AppUser> signIn() async {
    final identity = nextIdentity;
    if (identity == null) {
      throw const SignInException(SignInFailureKind.cancelled);
    }
    try {
      final result = await _auth.signInWithCredential(
        GoogleAuthProvider.credential(
          idToken: jsonEncode({
            'sub': identity.sub,
            'email': identity.email,
            'email_verified': true,
            'name': identity.email.split('@').first,
          }),
        ),
      );
      final user = result.user;
      if (user == null) throw const SignInException(SignInFailureKind.failed);
      return appUserFromFirebase(user);
    } on FirebaseAuthException catch (error) {
      throw SignInException(SignInFailureKind.failed, error);
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();
}
