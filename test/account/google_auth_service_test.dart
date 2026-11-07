// GoogleAuthService on doubles of Firebase Auth and Google Sign-In:
// u8-account reauthentication with the uid check (NFR4.6), deleteUser
// (BR1.7 step 6) and the U1 sign-in that now shares the Google picker.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/account/auth_service.dart';
import 'package:vinoozy/account/google_auth_service.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockCredential extends Mock implements UserCredential {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleAccount extends Mock implements GoogleSignInAccount {}

class _FakeAuthCredential extends Fake implements AuthCredential {}

MockUser firebaseUser(String uid) {
  final user = MockUser();
  when(() => user.uid).thenReturn(uid);
  when(() => user.email).thenReturn('$uid@example.com');
  when(() => user.displayName).thenReturn(null);
  when(() => user.photoURL).thenReturn('https://example.com/$uid.png');
  return user;
}

void main() {
  late MockFirebaseAuth auth;
  late MockGoogleSignIn google;
  late MockUser current;
  late GoogleAuthService service;

  setUpAll(() => registerFallbackValue(_FakeAuthCredential()));

  void pickerReturns(String? idToken) {
    final account = MockGoogleAccount();
    when(() => account.authentication)
        .thenReturn(GoogleSignInAuthentication(idToken: idToken));
    when(() => google.authenticate()).thenAnswer((_) async => account);
  }

  setUp(() {
    auth = MockFirebaseAuth();
    google = MockGoogleSignIn();
    current = firebaseUser('uid-mario');
    when(() => auth.currentUser).thenReturn(current);
    when(() => google.initialize(serverClientId: any(named: 'serverClientId')))
        .thenAnswer((_) async {});
    when(() => google.supportsAuthenticate()).thenReturn(true);
    when(() => google.signOut()).thenAnswer((_) async {});
    when(() => auth.signOut()).thenAnswer((_) async {});
    pickerReturns('id-token');
    service = GoogleAuthService(auth: auth, google: google);
  });

  group('reauthenticate (NFR4.6)', () {
    test('BR1.6 the same account confirms', () async {
      final credential = MockCredential();
      when(() => credential.user).thenReturn(current);
      when(() => current.reauthenticateWithCredential(any()))
          .thenAnswer((_) async => credential);

      expect(await service.reauthenticate(), ReauthResult.confirmed);
      verifyNever(() => google.signOut());
    });

    test('BR1.6 another account is refused and signed out of Google', () async {
      when(() => current.reauthenticateWithCredential(any()))
          .thenThrow(FirebaseAuthException(code: 'user-mismatch'));
      expect(await service.reauthenticate(), ReauthResult.differentAccount);
      verify(() => google.signOut()).called(1);
    });

    test('a credential answered with another uid is refused too', () async {
      final credential = MockCredential();
      final other = firebaseUser('uid-giulia');
      when(() => credential.user).thenReturn(other);
      when(() => current.reauthenticateWithCredential(any()))
          .thenAnswer((_) async => credential);
      expect(await service.reauthenticate(), ReauthResult.differentAccount);
    });

    test('a closed picker is cancelled, other errors fail', () async {
      when(() => google.authenticate()).thenThrow(
        const GoogleSignInException(code: GoogleSignInExceptionCode.canceled),
      );
      expect(await service.reauthenticate(), ReauthResult.cancelled);

      when(() => google.authenticate()).thenThrow(
        const GoogleSignInException(
          code: GoogleSignInExceptionCode.clientConfigurationError,
        ),
      );
      expect(await service.reauthenticate(), ReauthResult.failed);

      pickerReturns('id-token');
      when(() => current.reauthenticateWithCredential(any()))
          .thenThrow(FirebaseAuthException(code: 'network-request-failed'));
      expect(await service.reauthenticate(), ReauthResult.failed);

      when(() => current.reauthenticateWithCredential(any()))
          .thenThrow(StateError('x'));
      expect(await service.reauthenticate(), ReauthResult.failed);
    });

    test('without a session it fails', () async {
      when(() => auth.currentUser).thenReturn(null);
      expect(await service.reauthenticate(), ReauthResult.failed);
      expect(service.currentUser, isNull);
      expect(service.photoUrl, isNull);
    });
  });

  group('deleteUser (BR1.7 step 6)', () {
    test('deletes the Firebase user and the Google cache', () async {
      when(() => current.delete()).thenAnswer((_) async {});
      await service.deleteUser();
      verify(() => current.delete()).called(1);
      verify(() => google.signOut()).called(1);
    });

    test('NFR4.6 requires-recent-login asks for a new sign-in', () async {
      when(() => current.delete())
          .thenThrow(FirebaseAuthException(code: 'requires-recent-login'));
      await expectLater(
        service.deleteUser(),
        throwsA(
          isA<DeleteUserException>().having(
            (e) => e.failure,
            'failure',
            DeleteUserFailure.requiresRecentLogin,
          ),
        ),
      );
    });

    test('other errors and a missing session fail', () async {
      when(() => current.delete())
          .thenThrow(FirebaseAuthException(code: 'network-request-failed'));
      await expectLater(
        service.deleteUser(),
        throwsA(isA<DeleteUserException>()),
      );
      when(() => current.delete()).thenThrow(StateError('x'));
      await expectLater(
        service.deleteUser(),
        throwsA(isA<DeleteUserException>()),
      );
      when(() => auth.currentUser).thenReturn(null);
      await expectLater(
        service.deleteUser(),
        throwsA(isA<DeleteUserException>()),
      );
    });
  });

  group('U1 sign-in and session', () {
    test('signs in with the Google id token', () async {
      final credential = MockCredential();
      when(() => credential.user).thenReturn(current);
      when(() => auth.signInWithCredential(any()))
          .thenAnswer((_) async => credential);
      final user = await service.signIn();
      expect(user.uid, 'uid-mario');
      expect(service.currentUser?.uid, 'uid-mario');
      expect(service.photoUrl, 'https://example.com/uid-mario.png');
    });

    test('no id token, no user or a network error fail the sign-in', () async {
      pickerReturns(null);
      await expectLater(service.signIn(), throwsA(isA<SignInException>()));

      pickerReturns('id-token');
      final empty = MockCredential();
      when(() => empty.user).thenReturn(null);
      when(() => auth.signInWithCredential(any()))
          .thenAnswer((_) async => empty);
      await expectLater(service.signIn(), throwsA(isA<SignInException>()));

      when(() => auth.signInWithCredential(any()))
          .thenThrow(FirebaseAuthException(code: 'network-request-failed'));
      await expectLater(
        service.signIn(),
        throwsA(
          isA<SignInException>().having(
            (e) => e.kind,
            'kind',
            SignInFailureKind.network,
          ),
        ),
      );

      when(() => auth.signInWithCredential(any())).thenThrow(StateError('x'));
      await expectLater(service.signIn(), throwsA(isA<SignInException>()));

      when(() => google.supportsAuthenticate()).thenReturn(false);
      await expectLater(service.signIn(), throwsA(isA<SignInException>()));
    });

    test(
      'signOut closes Firebase and Google; a Google error is ignored',
      () async {
        when(() => google.signOut()).thenThrow(
          const GoogleSignInException(
            code: GoogleSignInExceptionCode.unknownError,
          ),
        );
        await service.signOut();
        verify(() => auth.signOut()).called(1);
      },
    );

    test('userChanges maps the Firebase users', () async {
      when(() => auth.idTokenChanges())
          .thenAnswer((_) => Stream.fromIterable([current, null]));
      expect(await service.userChanges().map((u) => u?.uid).toList(), [
        'uid-mario',
        null,
      ]);
    });
  });
}
