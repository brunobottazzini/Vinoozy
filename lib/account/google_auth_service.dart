import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'app_user.dart';
import 'auth_service.dart';
import 'firebase_user_mapping.dart';

/// Real Google sign-in: Google account picker, then Firebase Authentication
/// with the Google id token (BR1.1). Google is the only provider (NFR4.1).
class GoogleAuthService implements AuthService {
  GoogleAuthService({
    required this._auth,
    required this._google,
    this._serverClientId,
  });

  final FirebaseAuth _auth;
  final GoogleSignIn _google;

  /// OAuth web client id of the Firebase project (public, not a secret),
  /// passed with `--dart-define=GOOGLE_SERVER_CLIENT_ID`.
  final String? _serverClientId;
  Future<void>? _initialized;

  /// `GoogleSignIn.initialize` must run exactly once.
  Future<void> _ensureInitialized() =>
      _initialized ??= _google.initialize(serverClientId: _serverClientId);

  @override
  AppUser? get currentUser {
    final user = _auth.currentUser;
    return user == null ? null : appUserFromFirebase(user);
  }

  @override
  String? get photoUrl => _auth.currentUser?.photoURL;

  @override
  Stream<AppUser?> userChanges() => _auth.idTokenChanges().map(
    (user) => user == null ? null : appUserFromFirebase(user),
  );

  @override
  Future<AppUser> signIn() async {
    try {
      final result = await _auth.signInWithCredential(
        GoogleAuthProvider.credential(idToken: await _googleIdToken()),
      );
      final user = result.user;
      if (user == null) throw const SignInException(SignInFailureKind.failed);
      return appUserFromFirebase(user);
    } on SignInException {
      rethrow;
    } on FirebaseAuthException catch (error) {
      throw SignInException(
        error.code == 'network-request-failed'
            ? SignInFailureKind.network
            : SignInFailureKind.failed,
        error,
      );
    } catch (error) {
      throw SignInException(SignInFailureKind.failed, error);
    }
  }

  /// The Google account picker, then its id token. Throws [SignInException].
  Future<String> _googleIdToken() async {
    try {
      await _ensureInitialized();
      if (!_google.supportsAuthenticate()) {
        throw const SignInException(SignInFailureKind.failed);
      }
      final account = await _google.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw const SignInException(SignInFailureKind.failed);
      }
      return idToken;
    } on GoogleSignInException catch (error) {
      throw SignInException(
        error.code == GoogleSignInExceptionCode.canceled
            ? SignInFailureKind.cancelled
            : SignInFailureKind.failed,
        error,
      );
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    await _signOutGoogle();
  }

  /// The Google account cache only preselects the account next time, so a
  /// failure here is not worth failing for.
  Future<void> _signOutGoogle() async {
    try {
      await _ensureInitialized();
      await _google.signOut();
    } on GoogleSignInException {
      // See above: nothing to undo.
    }
  }

  @override
  Future<ReauthResult> reauthenticate() async {
    final current = _auth.currentUser;
    if (current == null) return ReauthResult.failed;
    try {
      final credential = GoogleAuthProvider.credential(
        idToken: await _googleIdToken(),
      );
      final result = await current.reauthenticateWithCredential(credential);
      if (result.user?.uid != current.uid) {
        await _signOutGoogle();
        return ReauthResult.differentAccount;
      }
      return ReauthResult.confirmed;
    } on SignInException catch (error) {
      return error.kind == SignInFailureKind.cancelled
          ? ReauthResult.cancelled
          : ReauthResult.failed;
    } on FirebaseAuthException catch (error) {
      // Firebase refuses a credential of another account with `user-mismatch`
      // and keeps the current session.
      if (error.code == 'user-mismatch') {
        await _signOutGoogle();
        return ReauthResult.differentAccount;
      }
      return ReauthResult.failed;
    } catch (_) {
      return ReauthResult.failed;
    }
  }

  @override
  Future<void> deleteUser() async {
    final current = _auth.currentUser;
    if (current == null) {
      throw const DeleteUserException(DeleteUserFailure.failed);
    }
    try {
      await current.delete();
    } on FirebaseAuthException catch (error) {
      throw DeleteUserException(
        error.code == 'requires-recent-login'
            ? DeleteUserFailure.requiresRecentLogin
            : DeleteUserFailure.failed,
        error,
      );
    } catch (error) {
      throw DeleteUserException(DeleteUserFailure.failed, error);
    }
    await _signOutGoogle();
  }
}
