// Active cellar and the build phase (actions-release-fix FR7.1-FR7.3).
//
// CI run 15 failed the E2E "after a restart the queued changes are still
// there" with "setState() or markNeedsBuild() called during build". The CI
// stack shows the path: `CellarScreen.build` watches `activeCellarProvider`;
// Riverpod first flushes its pending dependency `accessibleCellarsProvider`,
// whose rebuild notifies its listeners, among them the CellarSwitcher of the
// Dashboard, a widget outside the CellarScreen subtree.
//
// In that test nobody shares a cellar: the list is the personal cellar both
// before and after. The notification came only from a new List instance,
// which is never `==` to the previous one. A list equal by content does not
// notify, so the rebuild during another widget's build marks nothing.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinoozy/sharing/domain/membership.dart';
import 'package:vinoozy/sharing/sharing_providers.dart';
import 'package:vinoozy/sharing/ui/cellar_switcher.dart';

import '../helpers/ui_harness.dart';
import 'sharing_harness.dart';

/// Stands for CellarScreen: from [watching] on, its build watches the active
/// cellar, as `CellarScreen.build` does at line 103.
class _ActiveCellarReader extends ConsumerWidget {
  const _ActiveCellarReader({required this.watching});

  final ValueNotifier<bool> watching;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ValueListenableBuilder<bool>(
      valueListenable: watching,
      builder: (context, on, _) => on
          ? Consumer(
              builder: (context, ref, _) => Text(
                ref.watch(activeCellarProvider(invitee)).ownerName,
                key: const Key('active-owner'),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

void main() {
  setUpAll(registerSharingFallbacks);

  final annas = membership(
    cellarId: 'user-z',
    ownerId: 'user-z',
    ownerName: 'Anna',
    permission: MemberPermission.read,
  );

  group('FR7.3 accessible cellars notify only real changes', () {
    late SharingUi ui;
    late ProviderContainer container;
    late List<List<AccessibleCellar>> notified;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      ui = SharingUi();
      container = ProviderContainer(overrides: ui.overrides);
      notified = [];
      container.listen(
        accessibleCellarsProvider(invitee),
        (_, next) => notified.add(next),
      );
    });

    tearDown(() => container.dispose());

    Future<void> settle() async {
      for (var i = 0; i < 5; i++) {
        await pumpEventQueue();
      }
      // The refresh the scheduler would run in the next frame.
      container.read(accessibleCellarsProvider(invitee));
    }

    test('FR7.3 the same invitations again (cache, then server) notify '
        'nobody', () async {
      ui.sharing.emitMine([], fromCache: true);
      await settle();
      ui.sharing.emitMine([]);
      await settle();
      ui.sharing.emitMine([]);
      await settle();

      expect(notified, isEmpty);
    });

    test(
      'FR7.3 a shared cellar that arrives or leaves still notifies',
      () async {
        ui.sharing.emitMine([annas]);
        await settle();
        ui.sharing.emitMine([annas]);
        await settle();
        ui.sharing.emitMine([]);
        await settle();

        expect(notified.map((list) => list.length), [2, 1]);
        expect(notified.first.last.ownerName, 'Anna');
      },
    );

    test('FR7.2 the list compares by content and stays a read-only list', () {
      final first = container.read(accessibleCellarsProvider(invitee));
      final again = accessibleCellarsOf(invitee, const []);

      expect(again, first);
      expect(again.hashCode, first.hashCode);
      expect(() => again.add(again.first), throwsUnsupportedError);
    });
  });

  group('FR7.2 screens', () {
    late SharingUi ui;
    late ValueNotifier<bool> watching;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      ui = SharingUi();
      watching = ValueNotifier(false);
    });

    tearDown(() => watching.dispose());

    // The "Cellar" tab first, the Dashboard switcher in a sibling subtree.
    Widget host() => Scaffold(
      body: Column(
        children: [
          _ActiveCellarReader(watching: watching),
          const Padding(
            padding: EdgeInsets.zero,
            child: CellarSwitcher(user: invitee),
          ),
        ],
      ),
    );

    testWidgets('FR7.2 the screen starts watching the active cellar while '
        'the invitations arrive again', (tester) async {
      await pumpScreen(tester, host(), overrides: ui.overrides);
      ui.sharing.emitMine([annas]);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('cellar-switcher')), findsOneWidget);

      ui.sharing.emitMine([annas]);
      watching.value = true;
      await tester.pump();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('active-owner')), findsOneWidget);
    });

    testWidgets('FR7.2 a remembered shared cellar is still restored', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        activeCellarKey(invitee.uid): 'user-z',
      });
      watching.value = true;
      await pumpScreen(tester, host(), overrides: ui.overrides);
      ui.sharing.emitMine([annas]);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        tester.widget<Text>(find.byKey(const Key('active-owner'))).data,
        'Anna',
      );
    });
  });
}
