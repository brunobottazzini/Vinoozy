// RevokeDialog, LeaveCellarDialog and the sharing notices at the app root
// (u7-sharing BR1.4, BR1.8, BR1.10, BR1.14; NFR3.1-NFR3.3, NFR6.3) in it,
// en and pt-BR.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/app/providers.dart';
import 'package:vinoozy/sharing/sharing_providers.dart';
import 'package:vinoozy/sharing/ui/sharing_dialogs.dart';
import 'package:vinoozy/sync/sync_error_bus.dart';

import '../helpers/ui_harness.dart';

/// A page with a button that opens [open] and records its result.
class _Opener extends StatelessWidget {
  const _Opener({required this.open, required this.results});

  final Future<bool> Function(BuildContext context) open;
  final List<bool> results;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: TextButton(
        key: const Key('open'),
        onPressed: () async => results.add(await open(context)),
        child: const Text('open'),
      ),
    ),
  );
}

void main() {
  late List<bool> results;

  setUp(() => results = []);

  Future<void> open(
    WidgetTester tester,
    Future<bool> Function(BuildContext context) dialog, {
    Locale locale = const Locale('it'),
  }) async {
    await pumpScreen(
      tester,
      _Opener(open: dialog, results: results),
      locale: locale,
    );
    await tester.tap(find.byKey(const Key('open')));
    await tester.pumpAndSettle();
  }

  TextButton confirmButton(WidgetTester tester) =>
      tester.widget<TextButton>(find.byKey(const Key('revoke-confirm')));

  group('RevokeDialog (BR1.8)', () {
    testWidgets('BR1.8 "Revoca" is enabled only with the right name, case '
        'and spaces aside', (tester) async {
      await open(tester, (context) => RevokeDialog.confirm(context, 'Giulia'));

      expect(find.text("Revocare l'accesso di Giulia?"), findsOneWidget);
      expect(find.text('Scrivi Giulia per confermare'), findsOneWidget);
      expect(confirmButton(tester).onPressed, isNull);

      await tester.enterText(
        find.byKey(const Key('revoke-confirm-field')),
        'Luca',
      );
      await tester.pump();
      expect(confirmButton(tester).onPressed, isNull);

      await tester.enterText(
        find.byKey(const Key('revoke-confirm-field')),
        '  GIULIA ',
      );
      await tester.pump();
      await tester.tap(find.byKey(const Key('revoke-confirm')));
      await tester.pumpAndSettle();

      expect(results, [true]);
    });

    testWidgets('"Annulla" and closing return false', (tester) async {
      await open(tester, (context) => RevokeDialog.confirm(context, 'Giulia'));
      await tester.tap(find.byKey(const Key('revoke-cancel')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('open')));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();

      expect(results, [false, false]);
    });

    testWidgets('NFR3.1 the disabled button explains why', (tester) async {
      final handle = tester.ensureSemantics();
      await open(tester, (context) => RevokeDialog.confirm(context, 'Giulia'));

      final semantics = tester.getSemantics(
        find.byKey(const Key('revoke-confirm')),
      );
      expect(semantics.hint, 'Si attiva quando il nome coincide');
      handle.dispose();
    });
  });

  group('LeaveCellarDialog (BR1.10)', () {
    testWidgets('BR1.10 "Esci" confirms, "Annulla" does not', (tester) async {
      await open(
        tester,
        (context) => LeaveCellarDialog.confirm(context, 'Mario'),
      );
      expect(find.text('Uscire dalla cantina di Mario?'), findsOneWidget);
      expect(
        find.text('Non la vedrai più. Mario potrà invitarti di nuovo.'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('leave-confirm')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('open')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('leave-cancel')));
      await tester.pumpAndSettle();

      expect(results, [true, false]);
    });

    for (final (locale, title) in [
      (const Locale('en'), 'Leave the cellar of Mario?'),
      (const Locale('pt', 'BR'), 'Sair da adega de Mario?'),
    ]) {
      testWidgets('the dialog in ${locale.toLanguageTag()}', (tester) async {
        await open(
          tester,
          (context) => LeaveCellarDialog.confirm(context, 'Mario'),
          locale: locale,
        );
        expect(find.text(title), findsOneWidget);
      });
    }
  });

  group('notices at the app root (BR1.4, BR1.8, BR1.14, NFR6.3)', () {
    late SyncErrorBus bus;
    late SharingNotices notices;

    setUp(() {
      bus = SyncErrorBus();
      notices = SharingNotices();
    });

    Future<void> pumpRoot(WidgetTester tester) => pumpScreen(
      tester,
      const Scaffold(body: SizedBox.expand()),
      overrides: [
        syncErrorBusProvider.overrideWithValue(bus),
        sharingNoticesProvider.overrideWithValue(notices),
      ],
    );

    Future<void> dismiss(WidgetTester tester) async {
      await tester.tap(find.byKey(const Key('shared-cellar-notice-ok')));
      await tester.pumpAndSettle();
    }

    testWidgets('BR1.8 NFR6.3 "Non hai più accesso" once per cellar and '
        'session', (tester) async {
      await pumpRoot(tester);

      bus.publish(
        const CellarAccessLost(cellarId: 'user-a', ownerName: 'Mario'),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Non hai più accesso alla cantina di Mario'),
        findsOneWidget,
      );
      await dismiss(tester);

      bus.publish(
        const CellarAccessLost(cellarId: 'user-a', ownerName: 'Mario'),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('shared-cellar-notice')), findsNothing);
    });

    testWidgets('BR1.14 refused queued writes: one notice with the last '
        'known owner name', (tester) async {
      await pumpRoot(tester);
      ProviderScope.containerOf(tester.element(find.byType(Scaffold)))
              .read(knownCellarOwnersProvider)['user-z'] =
          'Anna';

      bus.publish(
        const CellarAccessLost(cellarId: 'user-z', fromQueuedWrite: true),
      );
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Alcune modifiche alla cantina di Anna non sono state salvate '
          'perché non hai più accesso',
        ),
        findsOneWidget,
      );
      await dismiss(tester);

      bus.publish(
        const CellarAccessLost(cellarId: 'user-z', fromQueuedWrite: true),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('shared-cellar-notice')), findsNothing);
    });

    testWidgets('an unknown owner is "qualcuno"', (tester) async {
      await pumpRoot(tester);

      bus.publish(const CellarAccessLost(cellarId: 'user-q'));
      await tester.pumpAndSettle();

      expect(
        find.text('Non hai più accesso alla cantina di qualcuno'),
        findsOneWidget,
      );
    });

    testWidgets('BR1.4 "Mario ti ha condiviso la sua cantina"', (tester) async {
      await pumpRoot(tester);

      notices.publish(
        const CellarShared(cellarId: 'user-a', ownerName: 'Mario'),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mario ti ha condiviso la sua cantina'), findsOneWidget);
      await dismiss(tester);
      expect(find.byKey(const Key('shared-cellar-notice')), findsNothing);
    });
  });

  accessibilityMatrix(
    'RevokeDialog',
    () => _Opener(
      open: (context) => RevokeDialog.confirm(context, 'Giulia'),
      results: [],
    ),
    afterPump: (tester) async {
      await tester.tap(find.byKey(const Key('open')));
      await tester.pumpAndSettle();
    },
  );

  accessibilityMatrix(
    'LeaveCellarDialog',
    () => _Opener(
      open: (context) => LeaveCellarDialog.confirm(context, 'Mario'),
      results: [],
    ),
    afterPump: (tester) async {
      await tester.tap(find.byKey(const Key('open')));
      await tester.pumpAndSettle();
    },
  );
}
