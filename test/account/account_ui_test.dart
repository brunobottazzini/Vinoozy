// Screens of u8-account in it, en and pt-BR (NFR3, NFR7.3): presentation,
// profile with the sign-out dialogs, account deletion and its progress.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinoozy/account/account_gate.dart';
import 'package:vinoozy/account/account_providers.dart';
import 'package:vinoozy/account/auth_service.dart';
import 'package:vinoozy/account/deletion/deletion_plan.dart';
import 'package:vinoozy/account/onboarding_flag.dart';
import 'package:vinoozy/account/ui/account_gate_view.dart';
import 'package:vinoozy/account/ui/delete_account_screen.dart';
import 'package:vinoozy/account/ui/onboarding_screen.dart';
import 'package:vinoozy/account/ui/profile_screen.dart';
import 'package:vinoozy/account/ui/sign_in_screen.dart';
import 'package:vinoozy/account/ui/status_screens.dart';
import 'package:vinoozy/app/providers.dart';

import '../helpers/ui_harness.dart';
import 'account_harness.dart';

class _MockGate extends Mock implements AccountGate {}

void main() {
  late _MockGate gate;
  late ValueNotifier<GateState> state;
  late FakeAuthService auth;
  late FakeNetworkStatus network;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    gate = _MockGate();
    state = ValueNotifier(const GateCellar(mario));
    auth = FakeAuthService(currentUser: mario);
    network = FakeNetworkStatus();
    when(() => gate.state).thenReturn(state);
    when(() => gate.current).thenAnswer((_) => state.value);
    when(() => gate.pendingChanges()).thenAnswer((_) async => 0);
    when(() => gate.syncNow()).thenAnswer((_) async => 0);
    when(() => gate.signOut()).thenAnswer((_) async {});
    when(() => gate.signIn()).thenAnswer((_) async {});
    when(() => gate.deleteAccount())
        .thenAnswer((_) async => ReauthResult.confirmed);
    when(() => gate.resumeDeletion()).thenAnswer((_) async {});
    when(() => gate.cancelDeletion()).thenAnswer((_) async {});
  });

  List<Override> overrides() => [
    accountGateProvider.overrideWithValue(gate),
    authServiceProvider.overrideWithValue(auth),
    networkStatusProvider.overrideWithValue(network),
  ];

  group('OnboardingScreen (BR1.1)', () {
    testWidgets('BR1.1 three pages, "Pagina N di 3", Start on the last', (
      tester,
    ) async {
      var done = 0;
      final handle = tester.ensureSemantics();
      await pumpScreen(tester, OnboardingScreen(onDone: () async => done++));

      expect(find.bySemanticsLabel('Pagina 1 di 3'), findsOneWidget);
      expect(find.byKey(const Key('onboarding-start')), findsNothing);
      await tester.tap(find.byKey(const Key('onboarding-next')));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Pagina 2 di 3'), findsOneWidget);
      await tester.tap(find.byKey(const Key('onboarding-next')));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Pagina 3 di 3'), findsOneWidget);

      await tester.tap(find.byKey(const Key('onboarding-start')));
      await tester.pump();
      expect(done, 1);
      handle.dispose();
    });

    testWidgets('BR1.1 "Salta" leads to sign-in at once', (tester) async {
      var done = 0;
      await pumpScreen(tester, OnboardingScreen(onDone: () async => done++));
      await tester.tap(find.byKey(const Key('onboarding-skip')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('onboarding-skip')));
      expect(done, 1, reason: 'a second tap does nothing');
    });

    accessibilityMatrix(
      'OnboardingScreen',
      () => OnboardingScreen(onDone: () async {}),
    );
  });

  group('AccountGateView (BR1.1, BR1.5, BR1.8)', () {
    testWidgets('BR1.1 the presentation comes before sign-in on a new phone '
        'and not again once seen', (tester) async {
      state.value = const GateSignIn();
      await pumpScreen(
        tester,
        const AccountGateView(),
        overrides: [
          ...overrides(),
          onboardingFlagProvider.overrideWithValue(
            OnboardingFlag(SharedPreferences.getInstance),
          ),
        ],
      );
      await tester.pumpAndSettle();
      expect(find.byType(OnboardingScreen), findsOneWidget);

      await tester.tap(find.byKey(const Key('onboarding-skip')));
      await tester.pumpAndSettle();
      expect(find.byType(SignInScreen), findsOneWidget);
      expect(
        (await SharedPreferences.getInstance()).getBool('onboarding.seen'),
        isTrue,
      );
    });

    testWidgets('BR1.1 a phone that saw it goes straight to sign-in', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({'onboarding.seen': true});
      state.value = const GateSignIn();
      await pumpScreen(
        tester,
        const AccountGateView(),
        overrides: [
          ...overrides(),
          onboardingFlagProvider.overrideWithValue(
            OnboardingFlag(SharedPreferences.getInstance),
          ),
        ],
      );
      await tester.pumpAndSettle();
      expect(find.byType(OnboardingScreen), findsNothing);
      expect(find.byType(SignInScreen), findsOneWidget);
    });

    testWidgets('BR1.7 plan B of the final reset asks to restart the app', (
      tester,
    ) async {
      state.value = const GateRestartRequired();
      await pumpScreen(tester, const AccountGateView(), overrides: overrides());
      expect(find.byKey(const Key('restart-required-screen')), findsOneWidget);
    });

    testWidgets('BR1.7 "Chiudi l\'app" closes the app after plan B', (
      tester,
    ) async {
      var closed = 0;
      await pumpScreen(
        tester,
        RestartRequiredScreen(closeApp: () async => closed++),
      );
      await tester.tap(find.byKey(const Key('restart-close-app-button')));
      expect(closed, 1);
    });

    testWidgets('BR1.8 while the gate reads the session: loading', (
      tester,
    ) async {
      state.value = const GateStarting();
      await pumpScreen(tester, const AccountGateView(), overrides: overrides());
      expect(find.byKey(const Key('gate-loading-screen')), findsOneWidget);
    });

    testWidgets('BR1.7 GateDeleted shows sign-in with "Account cancellato"', (
      tester,
    ) async {
      state.value = const GateDeleted();
      await pumpScreen(tester, const AccountGateView(), overrides: overrides());
      expect(find.text('Account cancellato'), findsOneWidget);
    });

    testWidgets('BR1.5 GateDeleting shows only the progress; back does '
        'nothing', (tester) async {
      state.value = const GateDeleting(
        user: mario,
        step: DeletionStep.leaveOtherCellars,
        running: true,
      );
      await pumpScreen(tester, const AccountGateView(), overrides: overrides());
      expect(find.byKey(const Key('deletion-progress')), findsOneWidget);
      expect(find.byKey(const Key('deletion-retry')), findsNothing);
      final pop = await tester.binding.handlePopRoute();
      await tester.pump();
      expect(pop, isTrue);
      expect(find.byKey(const Key('deletion-progress')), findsOneWidget);
    });
  });

  group('DeletionProgressView (BR1.7, BR1.8, NFR3.2, NFR6.4)', () {
    Widget view(GateDeleting deleting) => DeletionProgressView(
      state: deleting,
      onContinue: () => gate.resumeDeletion(),
      onCancel: () => gate.cancelDeletion(),
    );

    testWidgets('NFR3.2 the current step is announced with its number', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpScreen(
        tester,
        view(
          const GateDeleting(
            user: mario,
            step: DeletionStep.deleteWinesAndRecords,
            running: true,
            deletedDocuments: 400,
          ),
        ),
      );
      expect(
        find.bySemanticsLabel('Passo 5 di 8: Cancellazione di vini e Storico'),
        findsOneWidget,
      );
      expect(find.text('400 vini e bevute cancellati'), findsOneWidget);
      final announced = tester.getSemantics(
        find.byKey(const Key('deletion-current-step')),
      );
      expect(announced.flagsCollection.isLiveRegion, isTrue);
      handle.dispose();
    });

    testWidgets('BR1.8 a resumed deletion asks to continue with Google', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        view(
          const GateDeleting(
            user: mario,
            step: DeletionStep.markStarted,
            needsReauth: true,
          ),
        ),
      );
      expect(find.text('Continua'), findsOneWidget);
      await tester.tap(find.byKey(const Key('deletion-retry')));
      verify(() => gate.resumeDeletion()).called(1);
    });

    for (final (notice, text) in [
      (
        DeletionNotice.offline,
        'Collegati a Internet per completare la cancellazione',
      ),
      (
        DeletionNotice.failed,
        'Non è stato possibile completare la '
            'cancellazione. Riprova',
      ),
      (
        DeletionNotice.sameAccountRequired,
        'La cancellazione richiede l\'accesso con lo stesso account',
      ),
    ]) {
      testWidgets('NFR6.4 ${notice.name} has its message and "Riprova"', (
        tester,
      ) async {
        await pumpScreen(
          tester,
          view(
            GateDeleting(
              user: mario,
              step: DeletionStep.deleteCellar,
              notice: notice,
            ),
          ),
        );
        expect(find.text(text), findsOneWidget);
        expect(find.text('Riprova'), findsOneWidget);
        expect(find.byKey(const Key('deletion-cancel')), findsNothing);
      });
    }

    testWidgets('BR1.13 unsaved writes at step 0 can be retried or cancelled', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        view(
          const GateDeleting(
            user: mario,
            step: DeletionStep.preparePhone,
            notice: DeletionNotice.pendingWrites,
          ),
        ),
      );
      expect(
        find.text('Non riesco a salvare le modifiche in sospeso. Riprova'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('deletion-cancel')));
      verify(() => gate.cancelDeletion()).called(1);
    });

    accessibilityMatrix(
      'DeletionProgressView',
      () => view(
        const GateDeleting(
          user: mario,
          step: DeletionStep.deleteCellar,
          notice: DeletionNotice.failed,
          deletedDocuments: 12,
        ),
      ),
    );
  });

  group('ProfileScreen (BR1.2-BR1.4)', () {
    testWidgets('BR1.2 name, email, initial without a photo, and the actions', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        const ProfileScreen(user: mario),
        overrides: overrides(),
      );
      expect(find.text('Mario Rossi'), findsOneWidget);
      expect(find.text('mario@example.com'), findsOneWidget);
      expect(find.text('M'), findsOneWidget);
      for (final key in ['profile-sign-out', 'profile-delete']) {
        expect(find.byKey(Key(key)), findsOneWidget);
      }
    });

    testWidgets('BR1.2 the privacy policy link can be copied', (tester) async {
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await pumpScreen(
        tester,
        const ProfileScreen(user: mario),
        overrides: overrides(),
      );
      await tester.tap(find.byKey(const Key('profile-privacy')));
      await tester.pumpAndSettle();
      expect(find.text(defaultPrivacyPolicyUrl), findsOneWidget);
      await tester.tap(find.byKey(const Key('privacy-copy')));
      await tester.pumpAndSettle();
      expect(copied, defaultPrivacyPolicyUrl);
      expect(find.text('Link copiato'), findsOneWidget);

      await tester.tap(find.byKey(const Key('profile-privacy')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('privacy-close')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('privacy-dialog')), findsNothing);
    });

    testWidgets('BR1.3 without queued writes: "Vuoi uscire?", Annulla stays', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        const ProfileScreen(user: mario),
        overrides: overrides(),
      );
      await tester.tap(find.byKey(const Key('profile-sign-out')));
      await tester.pumpAndSettle();
      expect(find.text('Vuoi uscire?'), findsOneWidget);
      await tester.tap(find.byKey(const Key('sign-out-cancel')));
      await tester.pumpAndSettle();
      verifyNever(() => gate.signOut());

      await tester.tap(find.byKey(const Key('profile-sign-out')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('sign-out-confirm')));
      await tester.pumpAndSettle();
      verify(() => gate.signOut()).called(1);
    });

    testWidgets('BR1.4 with 2 queued writes the warning offers to sync first', (
      tester,
    ) async {
      when(() => gate.pendingChanges()).thenAnswer((_) async => 2);
      await pumpScreen(
        tester,
        const ProfileScreen(user: mario),
        overrides: overrides(),
      );
      await tester.tap(find.byKey(const Key('profile-sign-out')));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Hai 2 modifiche non ancora salvate'),
        findsOne,
      );

      await tester.tap(find.byKey(const Key('sign-out-stay')));
      await tester.pumpAndSettle();
      verify(() => gate.syncNow()).called(1);
      expect(find.text('Tutto salvato'), findsOneWidget);
      verifyNever(() => gate.signOut());
    });

    testWidgets('BR1.4 still pending after sync, then "Esci comunque"', (
      tester,
    ) async {
      when(() => gate.pendingChanges()).thenAnswer((_) async => 1);
      when(() => gate.syncNow()).thenAnswer((_) async => 1);
      await pumpScreen(
        tester,
        const ProfileScreen(user: mario),
        overrides: overrides(),
      );
      await tester.tap(find.byKey(const Key('profile-sign-out')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('sign-out-stay')));
      await tester.pumpAndSettle();
      expect(
        find.text('Ancora 1 modifica da salvare: controlla la rete'),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('profile-sign-out')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('sign-out-anyway')));
      await tester.pumpAndSettle();
      verify(() => gate.signOut()).called(1);
    });

    testWidgets('BR1.2 the profile opens within 300 ms (NFR1.1)', (
      tester,
    ) async {
      final watch = Stopwatch()..start();
      await pumpScreen(
        tester,
        const ProfileScreen(user: mario),
        overrides: overrides(),
      );
      expect(watch.elapsedMilliseconds, lessThan(300));
    });

    accessibilityMatrix(
      'ProfileScreen',
      () => const ProfileScreen(user: mario),
      overrides: overrides,
    );
  });

  group('DeleteAccountScreen (BR1.5, BR1.6, BR1.13)', () {
    Future<void> pumpDelete(
      WidgetTester tester, {
      Locale locale = const Locale('it'),
    }) async {
      await pumpScreen(
        tester,
        const DeleteAccountScreen(user: mario),
        locale: locale,
        overrides: overrides(),
      );
      await tester.pumpAndSettle();
    }

    for (final (locale, word) in [
      (const Locale('it'), 'CANCELLA'),
      (const Locale('en'), 'DELETE'),
      (const Locale('pt', 'BR'), 'EXCLUIR'),
    ]) {
      testWidgets('BR1.6 "Delete forever" only with $word '
          '(${locale.toLanguageTag()})', (tester) async {
        await pumpDelete(tester, locale: locale);
        final button = find.byKey(const Key('delete-forever'));
        expect(tester.widget<FilledButton>(button).onPressed, isNull);
        await tester.enterText(
          find.byKey(const Key('delete-confirm-word')),
          'WRONG',
        );
        await tester.pump();
        expect(tester.widget<FilledButton>(button).onPressed, isNull);
        await tester.enterText(
          find.byKey(const Key('delete-confirm-word')),
          word.toLowerCase(),
        );
        await tester.pump();
        expect(tester.widget<FilledButton>(button).onPressed, isNotNull);
      });
    }

    testWidgets('BR1.6 the list says what is deleted', (tester) async {
      await pumpDelete(tester);
      expect(find.text('La tua cantina, con i vini e lo Storico'), findsOne);
      expect(
        find.text(
          'La tua partecipazione alle cantine di altri: le tue bevute '
          'restano lì senza nome',
        ),
        findsOne,
      );
    });

    testWidgets('BR1.13 the queued writes are announced', (tester) async {
      when(() => gate.pendingChanges()).thenAnswer((_) async => 3);
      await pumpDelete(tester);
      expect(
        find.text(
          'Hai 3 modifiche non ancora salvate: verranno salvate e poi '
          'cancellate con il resto',
        ),
        findsOneWidget,
      );
    });

    testWidgets('BR1.5 without network: message and no deletion', (
      tester,
    ) async {
      network.online = false;
      await pumpDelete(tester);
      expect(
        find.text('Collegati a Internet per cancellare l\'account'),
        findsOneWidget,
      );
      await tester.enterText(
        find.byKey(const Key('delete-confirm-word')),
        'CANCELLA',
      );
      await tester.pump();
      await tester.tap(find.byKey(const Key('delete-forever')));
      await tester.pumpAndSettle();
      verifyNever(() => gate.deleteAccount());
    });

    testWidgets('BR1.6 a different account keeps the screen with its message', (
      tester,
    ) async {
      when(() => gate.deleteAccount())
          .thenAnswer((_) async => ReauthResult.differentAccount);
      await pumpDelete(tester);
      await tester.enterText(
        find.byKey(const Key('delete-confirm-word')),
        'CANCELLA',
      );
      await tester.pump();
      await tester.tap(find.byKey(const Key('delete-forever')));
      await tester.pumpAndSettle();
      expect(
        find.text('La cancellazione richiede l\'accesso con lo stesso account'),
        findsOneWidget,
      );

      when(() => gate.deleteAccount())
          .thenAnswer((_) async => ReauthResult.failed);
      await tester.tap(find.byKey(const Key('delete-forever')));
      await tester.pumpAndSettle();
      expect(
        find.text('Non è stato possibile completare la cancellazione. Riprova'),
        findsOneWidget,
      );
    });

    testWidgets('BR1.7 confirmed: back to the root, where the gate shows the '
        'progress', (tester) async {
      await pumpScreen(
        tester,
        Builder(
          builder: (context) => TextButton(
            onPressed: () => ProfileScreen.open(context, mario),
            child: const Text('open'),
          ),
        ),
        overrides: overrides(),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('profile-delete')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('delete-confirm-word')),
        'CANCELLA',
      );
      await tester.pump();
      await tester.tap(find.byKey(const Key('delete-forever')));
      await tester.pumpAndSettle();

      verify(() => gate.deleteAccount()).called(1);
      expect(find.byType(DeleteAccountScreen), findsNothing);
      expect(find.byType(ProfileScreen), findsNothing);
    });

    accessibilityMatrix(
      'DeleteAccountScreen',
      () => const DeleteAccountScreen(user: mario),
      overrides: overrides,
    );
  });
}
