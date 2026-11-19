// tester-feedback FR2.3, review R-03, FR2.6: the first-visit hints show
// once per screen, only after the guided tour, never during it, in it, en
// and pt-BR.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinoozy/guide/guide_providers.dart';
import 'package:vinoozy/guide/guide_state_store.dart';
import 'package:vinoozy/guide/ui/first_visit_hint.dart';
import 'package:vinoozy/l10n/app_localizations.dart';

import '../helpers/ui_harness.dart';

Widget _screenWith(GuideScreen screen) => Scaffold(
  body: Column(
    children: [
      FirstVisitHint(screen: screen),
      const Expanded(child: Placeholder()),
    ],
  ),
);

void main() {
  List<Override> overrides({bool e2e = false}) => [
    guideStateStoreProvider.overrideWithValue(
      GuideStateStore(SharedPreferences.getInstance),
    ),
    isE2EBuildProvider.overrideWithValue(e2e),
  ];

  for (final locale in testLocales) {
    testWidgets('the History hint shows the first time and not the second '
        '(${locale.toLanguageTag()})', (tester) async {
      SharedPreferences.setMockInitialValues({'guide.tour.seen': true});
      final l10n = lookupAppLocalizations(locale);
      await pumpScreen(
        tester,
        _screenWith(GuideScreen.history),
        locale: locale,
        overrides: overrides(),
      );
      await tester.pumpAndSettle();
      expect(find.text(l10n.hintHistory), findsOneWidget);

      await tester.tap(find.byKey(const Key('hint-history-close')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('hint-history')), findsNothing);

      // A new start of the app: the phone remembers it.
      await tester.pumpWidget(const SizedBox());
      await pumpScreen(
        tester,
        _screenWith(GuideScreen.history),
        locale: locale,
        overrides: overrides(),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('hint-history')), findsNothing);
    });
  }

  testWidgets('each screen has its own hint', (tester) async {
    SharedPreferences.setMockInitialValues({
      'guide.tour.seen': true,
      'guide.hint.history': true,
    });
    final l10n = lookupAppLocalizations(const Locale('it'));
    await pumpScreen(
      tester,
      _screenWith(GuideScreen.dashboard),
      overrides: overrides(),
    );
    await tester.pumpAndSettle();
    expect(find.text(l10n.hintDashboard), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await pumpScreen(
      tester,
      _screenWith(GuideScreen.addWine),
      overrides: overrides(),
    );
    await tester.pumpAndSettle();
    expect(find.text(l10n.hintAddWine), findsOneWidget);
  });

  testWidgets('R-03 no hint before the tour, nor while it runs', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await pumpScreen(
      tester,
      _screenWith(GuideScreen.dashboard),
      overrides: overrides(),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('hint-dashboard')), findsNothing);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(FirstVisitHint)),
    );
    final notifier = container.read(guideProgressProvider.notifier)
      ..startTour();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('hint-dashboard')), findsNothing);

    await notifier.finishTour();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('hint-dashboard')), findsOneWidget);
  });

  testWidgets('FR2.6 never in an end-to-end build', (tester) async {
    SharedPreferences.setMockInitialValues({'guide.tour.seen': true});
    await pumpScreen(
      tester,
      _screenWith(GuideScreen.history),
      overrides: overrides(e2e: true),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('hint-history')), findsNothing);
  });

  testWidgets('without the phone store nothing shows (other units)', (
    tester,
  ) async {
    await pumpScreen(tester, _screenWith(GuideScreen.history));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('hint-history')), findsNothing);
  });
}
