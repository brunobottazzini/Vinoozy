// SharingScreen, InviteForm and MemberTile (u7-sharing BR1.1-BR1.3,
// BR1.8-BR1.12; NFR3.1-NFR3.3, NFR6.1, NFR8.1) in it, en and pt-BR: owner
// and invitee views, offline, operation in progress, errors, the limit.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinoozy/sharing/domain/membership.dart';
import 'package:vinoozy/sharing/domain/sharing_error.dart';
import 'package:vinoozy/sharing/ui/sharing_screen.dart';
import 'package:vinoozy/sharing/ui/share_launcher.dart';

import '../helpers/ui_harness.dart';
import 'sharing_harness.dart';

void main() {
  setUpAll(registerSharingFallbacks);

  late SharingUi ui;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ui = SharingUi();
    when(
      () => ui.repository.invite(
        cellar: any(named: 'cellar'),
        owner: any(named: 'owner'),
        rawEmail: any(named: 'rawEmail'),
        permission: any(named: 'permission'),
        members: any(named: 'members'),
      ),
    ).thenAnswer(
      (invocation) async =>
          (invocation.namedArguments[#rawEmail] as String).trim().toLowerCase(),
    );
  });

  final giulia = membership();
  final luca = membership(
    email: 'luca@example.com',
    inviteeName: null,
    status: MemberStatus.invited,
    permission: MemberPermission.read,
  );
  final paolo = membership(
    email: 'paolo@example.com',
    inviteeName: 'Paolo',
    status: MemberStatus.revoked,
    closedBy: ClosedBy.invitee,
  );

  Future<void> pumpOwner(
    WidgetTester tester, {
    List<Membership> members = const [],
    int slots = 0,
    Locale locale = const Locale('it'),
  }) async {
    await pumpScreen(
      tester,
      const SharingScreen(user: owner),
      overrides: ui.overrides,
      locale: locale,
    );
    ui.emitCellar('user-a', memberSlots: slots, name: 'Cantina di casa');
    ui.sharing.members.add(members);
    await tester.pumpAndSettle();
  }

  /// Giulia's view of Mario's cellar, chosen before.
  Future<void> pumpInvitee(
    WidgetTester tester, {
    MemberPermission permission = MemberPermission.edit,
  }) async {
    SharedPreferences.setMockInitialValues({
      'sharing.activeCellar.user-b': 'user-a',
    });
    await pumpScreen(
      tester,
      const SharingScreen(user: invitee),
      overrides: ui.overrides,
    );
    ui.sharing.emitMine([membership(permission: permission)]);
    await tester.pumpAndSettle();
  }

  ButtonStyleButton button(WidgetTester tester, String key) =>
      tester.widget<ButtonStyleButton>(find.byKey(Key(key)));

  group('owner view (BR1.1, BR1.12)', () {
    testWidgets('BR1.12 invited and active people in the main list, closed '
        'ones under "Accessi chiusi"', (tester) async {
      await pumpOwner(tester, members: [giulia, luca, paolo], slots: 2);

      expect(
        find.byKey(const Key('member-giulia@example.com')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('member-luca@example.com')), findsOneWidget);
      expect(find.text('Giulia'), findsOneWidget);
      expect(find.text('luca@example.com'), findsOneWidget, reason: 'no name');
      expect(find.byKey(const Key('member-paolo@example.com')), findsNothing);

      await tester.tap(find.byKey(const Key('sharing-closed-section')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('member-paolo@example.com')), findsOneWidget);
      expect(find.text('Può modificare · uscita'), findsOneWidget);
    });

    testWidgets('nobody invited yet: the empty message and 0/2', (
      tester,
    ) async {
      await pumpOwner(tester);

      expect(find.byKey(const Key('sharing-nobody')), findsOneWidget);
      expect(find.text('0/2 persone'), findsOneWidget);
    });

    testWidgets('BR1.2 AC8.1.2 with 2 places used: the limit and "Invita" '
        'disabled', (tester) async {
      await pumpOwner(tester, members: [giulia, luca], slots: 2);

      expect(find.text('2/2 persone'), findsOneWidget);
      expect(find.text('Hai raggiunto il limite di 2 persone'), findsOneWidget);
      expect(button(tester, 'invite-submit').onPressed, isNull);
    });

    testWidgets('NFR3.1 a member is read as "name, permission, status"', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpOwner(tester, members: [giulia]);

      expect(
        find.bySemanticsLabel('Giulia, Può modificare, attiva'),
        findsOneWidget,
      );
      handle.dispose();
    });
  });

  group('invite (BR1.2, BR1.3)', () {
    testWidgets('BR1.3 a successful invitation opens the share sheet with '
        'the ready-made message and clears the field', (tester) async {
      await pumpOwner(tester, members: [giulia], slots: 1);

      await tester.enterText(
        find.byKey(const Key('invite-email')),
        ' Anna@Example.com ',
      );
      await tester.tap(find.byKey(const Key('invite-permission-edit')));
      await tester.tap(find.byKey(const Key('invite-submit')));
      await tester.pumpAndSettle();

      final call = verify(
        () => ui.repository.invite(
          cellar: captureAny(named: 'cellar'),
          owner: owner,
          rawEmail: ' Anna@Example.com ',
          permission: MemberPermission.edit,
          members: any(named: 'members'),
        ),
      );
      call.called(1);
      final message = ui.share.texts.single;
      expect(message, contains('Mario'));
      expect(message, contains('Cantina di casa'));
      expect(message, contains(playStoreLink));
      expect(message, contains('anna@example.com'));
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('invite-email')))
            .controller!
            .text,
        isEmpty,
      );
    });

    testWidgets('BR1.3 a share sheet that fails keeps the invitation', (
      tester,
    ) async {
      ui.share.failWith = StateError('no sheet');
      await pumpOwner(tester);

      await tester.enterText(
        find.byKey(const Key('invite-email')),
        'anna@example.com',
      );
      await tester.tap(find.byKey(const Key('invite-submit')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('invite-error')), findsNothing);
    });

    for (final (error, text) in [
      (SharingError.invalidEmail, "Inserisci un'email valida"),
      (SharingError.selfInvite, 'Non puoi invitare te stesso'),
      (SharingError.alreadyInvited, 'Questa persona è già invitata'),
    ]) {
      testWidgets('BR1.2 ${error.name} is shown under the field', (
        tester,
      ) async {
        when(
          () => ui.repository.invite(
            cellar: any(named: 'cellar'),
            owner: any(named: 'owner'),
            rawEmail: any(named: 'rawEmail'),
            permission: any(named: 'permission'),
            members: any(named: 'members'),
          ),
        ).thenThrow(SharingException(error));
        await pumpOwner(tester);

        await tester.enterText(find.byKey(const Key('invite-email')), 'x');
        await tester.tap(find.byKey(const Key('invite-submit')));
        await tester.pumpAndSettle();

        expect(find.text(text), findsOneWidget);
        expect(ui.share.texts, isEmpty);
      });
    }

    testWidgets('a server error says "Invito non riuscito. Riprova" and the '
        'list does not change', (tester) async {
      when(
        () => ui.repository.invite(
          cellar: any(named: 'cellar'),
          owner: any(named: 'owner'),
          rawEmail: any(named: 'rawEmail'),
          permission: any(named: 'permission'),
          members: any(named: 'members'),
        ),
      ).thenThrow(const SharingException(SharingError.timeout));
      await pumpOwner(tester, members: [giulia], slots: 1);

      await tester.enterText(
        find.byKey(const Key('invite-email')),
        'anna@example.com',
      );
      await tester.tap(find.byKey(const Key('invite-submit')));
      await tester.pumpAndSettle();

      expect(find.text('Invito non riuscito. Riprova'), findsOneWidget);
      expect(find.byKey(const Key('member-anna@example.com')), findsNothing);
    });

    testWidgets('while the invitation runs: indicator, a second tap is '
        'ignored', (tester) async {
      final pending = Completer<String>();
      when(
        () => ui.repository.invite(
          cellar: any(named: 'cellar'),
          owner: any(named: 'owner'),
          rawEmail: any(named: 'rawEmail'),
          permission: any(named: 'permission'),
          members: any(named: 'members'),
        ),
      ).thenAnswer((_) => pending.future);
      await pumpOwner(tester);

      await tester.enterText(
        find.byKey(const Key('invite-email')),
        'anna@example.com',
      );
      await tester.tap(find.byKey(const Key('invite-submit')));
      await tester.pump();
      expect(button(tester, 'invite-submit').onPressed, isNull);
      expect(
        find.descendant(
          of: find.byKey(const Key('invite-submit')),
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('invite-submit')));

      pending.complete('anna@example.com');
      await tester.pumpAndSettle();
      verify(
        () => ui.repository.invite(
          cellar: any(named: 'cellar'),
          owner: any(named: 'owner'),
          rawEmail: any(named: 'rawEmail'),
          permission: any(named: 'permission'),
          members: any(named: 'members'),
        ),
      ).called(1);
    });
  });

  group('BR1.11 NFR6.1 network', () {
    testWidgets('BR1.11 offline: the explanation and every command disabled; '
        'they come back with the network', (tester) async {
      ui.network.online = false;
      await pumpOwner(tester, members: [giulia], slots: 1);

      expect(
        find.text('Serve la connessione per gestire la condivisione'),
        findsOneWidget,
      );
      expect(button(tester, 'invite-submit').onPressed, isNull);
      expect(
        tester
            .widget<IconButton>(
              find.byKey(const Key('member-revoke-giulia@example.com')),
            )
            .onPressed,
        isNull,
      );

      ui.network.online = true;
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('sharing-offline')), findsNothing);
      expect(button(tester, 'invite-submit').onPressed, isNotNull);
    });
  });

  group('members (BR1.8, BR1.9, BR1.12)', () {
    setUp(() {
      when(
        () => ui.repository.revoke(
          cellarId: any(named: 'cellarId'),
          memberKey: any(named: 'memberKey'),
          owner: any(named: 'owner'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => ui.repository.changePermission(
          cellarId: any(named: 'cellarId'),
          memberKey: any(named: 'memberKey'),
          permission: any(named: 'permission'),
          owner: any(named: 'owner'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => ui.repository.deleteClosed(
          cellarId: any(named: 'cellarId'),
          memberKey: any(named: 'memberKey'),
          owner: any(named: 'owner'),
        ),
      ).thenAnswer((_) async {});
    });

    testWidgets('BR1.8 "Revoca" asks for the name, then revokes', (
      tester,
    ) async {
      await pumpOwner(tester, members: [giulia], slots: 1);

      await tester.tap(
        find.byKey(const Key('member-revoke-giulia@example.com')),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<TextButton>(find.byKey(const Key('revoke-confirm')))
            .onPressed,
        isNull,
      );
      await tester.enterText(
        find.byKey(const Key('revoke-confirm-field')),
        'Giu',
      );
      await tester.pump();
      expect(
        tester
            .widget<TextButton>(find.byKey(const Key('revoke-confirm')))
            .onPressed,
        isNull,
      );
      await tester.enterText(
        find.byKey(const Key('revoke-confirm-field')),
        ' giulia ',
      );
      await tester.pump();
      await tester.tap(find.byKey(const Key('revoke-confirm')));
      await tester.pumpAndSettle();

      verify(
        () => ui.repository.revoke(
          cellarId: 'user-a',
          memberKey: 'giulia@example.com',
          owner: owner,
        ),
      ).called(1);
    });

    testWidgets('BR1.8 the confirmation uses the email when there is no name', (
      tester,
    ) async {
      await pumpOwner(tester, members: [luca], slots: 1);

      await tester.tap(find.byKey(const Key('member-revoke-luca@example.com')));
      await tester.pumpAndSettle();

      expect(
        find.text('Revocare l\'accesso di luca@example.com?'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('revoke-cancel')));
      await tester.pumpAndSettle();
      verifyNever(
        () => ui.repository.revoke(
          cellarId: any(named: 'cellarId'),
          memberKey: any(named: 'memberKey'),
          owner: any(named: 'owner'),
        ),
      );
    });

    testWidgets('BR1.9 the permission menu changes read to edit', (
      tester,
    ) async {
      await pumpOwner(tester, members: [luca], slots: 1);

      await tester.tap(
        find.byKey(const Key('member-permission-luca@example.com')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('permission-option-edit')).last);
      await tester.pumpAndSettle();

      verify(
        () => ui.repository.changePermission(
          cellarId: 'user-a',
          memberKey: 'luca@example.com',
          permission: MemberPermission.edit,
          owner: owner,
        ),
      ).called(1);
    });

    testWidgets('an error of an operation is shown with its fixed message', (
      tester,
    ) async {
      when(
        () => ui.repository.changePermission(
          cellarId: any(named: 'cellarId'),
          memberKey: any(named: 'memberKey'),
          permission: any(named: 'permission'),
          owner: any(named: 'owner'),
        ),
      ).thenThrow(const SharingException(SharingError.notFound));
      await pumpOwner(tester, members: [luca], slots: 1);

      await tester.tap(
        find.byKey(const Key('member-permission-luca@example.com')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('permission-option-edit')).last);
      await tester.pumpAndSettle();

      expect(
        find.text('Questa persona non è più nell\'elenco'),
        findsOneWidget,
      );
    });

    testWidgets('BR1.12 a closed access can be invited again or deleted', (
      tester,
    ) async {
      await pumpOwner(tester, members: [paolo]);
      await tester.tap(find.byKey(const Key('sharing-closed-section')));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const Key('member-reinvite-paolo@example.com')),
      );
      await tester.pumpAndSettle();
      verify(
        () => ui.repository.invite(
          cellar: any(named: 'cellar'),
          owner: owner,
          rawEmail: 'paolo@example.com',
          permission: MemberPermission.edit,
          members: any(named: 'members'),
        ),
      ).called(1);
      expect(ui.share.texts, hasLength(1));

      await tester.tap(
        find.byKey(const Key('member-delete-paolo@example.com')),
      );
      await tester.pumpAndSettle();
      verify(
        () => ui.repository.deleteClosed(
          cellarId: 'user-a',
          memberKey: 'paolo@example.com',
          owner: owner,
        ),
      ).called(1);
    });

    testWidgets('while an operation runs the member shows an indicator', (
      tester,
    ) async {
      final pending = Completer<void>();
      when(
        () => ui.repository.deleteClosed(
          cellarId: any(named: 'cellarId'),
          memberKey: any(named: 'memberKey'),
          owner: any(named: 'owner'),
        ),
      ).thenAnswer((_) => pending.future);
      await pumpOwner(tester, members: [paolo]);
      await tester.tap(find.byKey(const Key('sharing-closed-section')));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const Key('member-delete-paolo@example.com')),
      );
      await tester.pump();

      expect(
        find.descendant(
          of: find.byKey(const Key('member-paolo@example.com')),
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );
      pending.complete();
      await tester.pumpAndSettle();
    });
  });

  group('invitee view (BR1.1, BR1.10, AC8.4.2)', () {
    testWidgets('AC8.4.2 BR1.1 only the owner and the own permission, no '
        'invitation or revocation commands', (tester) async {
      await pumpInvitee(tester, permission: MemberPermission.read);

      expect(find.text('Cantina di Mario'), findsOneWidget);
      expect(find.text('Il tuo permesso: Solo lettura'), findsOneWidget);
      expect(find.byKey(const Key('invite-submit')), findsNothing);
      expect(find.byKey(const Key('invite-email')), findsNothing);
      // Never the members of Mario's cellar (NFR4.5): only the own personal
      // cellar was shown before the invitations arrived.
      verifyNever(() => ui.repository.watchCellarMembers('user-a'));
    });

    testWidgets('BR1.10 "Esci da questa cantina" confirmed leaves and closes '
        'the screen', (tester) async {
      when(
        () => ui.repository.leave(
          cellarId: any(named: 'cellarId'),
          user: any(named: 'user'),
        ),
      ).thenAnswer((_) async {});
      await pumpInvitee(tester);

      await tester.tap(find.byKey(const Key('leave-cellar')));
      await tester.pumpAndSettle();
      expect(find.text('Uscire dalla cantina di Mario?'), findsOneWidget);
      await tester.tap(find.byKey(const Key('leave-confirm')));
      await tester.pump();
      await tester.pump();
      // Back on the personal cellar: its (empty) People list.
      ui.sharing.members.add(const []);
      ui.emitCellar('user-b');
      await tester.pumpAndSettle();

      verify(() => ui.repository.leave(cellarId: 'user-a', user: invitee))
          .called(1);
      expect(find.text('Cantina di Mario'), findsNothing);
      expect(find.byKey(const Key('sharing-nobody')), findsOneWidget);
    });

    testWidgets('BR1.10 a cancelled exit does nothing; a failed one says so', (
      tester,
    ) async {
      when(
        () => ui.repository.leave(
          cellarId: any(named: 'cellarId'),
          user: any(named: 'user'),
        ),
      ).thenThrow(const SharingException(SharingError.timeout));
      await pumpInvitee(tester);

      await tester.tap(find.byKey(const Key('leave-cellar')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('leave-cancel')));
      await tester.pumpAndSettle();
      verifyNever(
        () => ui.repository.leave(
          cellarId: any(named: 'cellarId'),
          user: any(named: 'user'),
        ),
      );

      await tester.tap(find.byKey(const Key('leave-cellar')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('leave-confirm')));
      await tester.pumpAndSettle();

      expect(find.text('Non riuscito, riprova'), findsOneWidget);
      expect(find.text('Cantina di Mario'), findsOneWidget);
    });

    testWidgets('BR1.11 offline the exit is disabled', (tester) async {
      ui.network.online = false;
      await pumpInvitee(tester);

      expect(button(tester, 'leave-cellar').onPressed, isNull);
    });
  });

  group('languages (NFR7.3)', () {
    for (final (locale, people, places) in [
      (const Locale('en'), 'People', '1/2 people'),
      (const Locale('pt', 'BR'), 'Pessoas', '1/2 pessoas'),
    ]) {
      testWidgets('the owner view in ${locale.toLanguageTag()}', (
        tester,
      ) async {
        await pumpOwner(tester, members: [giulia], slots: 1, locale: locale);

        expect(find.text(people), findsOneWidget);
        expect(find.text(places), findsOneWidget);
      });
    }
  });

  // NFR3.2 NFR3.3: contrast, tap targets, labels, 200% text, 3 languages.
  accessibilityMatrix(
    'SharingScreen (owner)',
    () => const SharingScreen(user: owner),
    overrides: () {
      ui = SharingUi();
      return ui.overrides;
    },
    afterPump: (tester) async {
      ui.emitCellar('user-a', memberSlots: 2);
      ui.sharing.members.add([giulia, luca, paolo]);
      await tester.pumpAndSettle();
    },
  );

  accessibilityMatrix(
    'SharingScreen (invitee)',
    () => const SharingScreen(user: invitee),
    overrides: () {
      SharedPreferences.setMockInitialValues({
        'sharing.activeCellar.user-b': 'user-a',
      });
      ui = SharingUi();
      return ui.overrides;
    },
    afterPump: (tester) async {
      ui.sharing.emitMine([membership()]);
      await tester.pumpAndSettle();
    },
  );
}
