// tester-feedback FR2.1, FR2.2, FR2.6, NFR5, review R-02/R-03: the guided
// tour on the Cellar tab of the real HomeShell, in it, en and pt-BR.
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinoozy/app/home_shell.dart';
import 'package:vinoozy/cellar/ui/cellar_screen.dart' show CellarSetup;
import 'package:vinoozy/cellar/data/wine_repository.dart';
import 'package:vinoozy/cellar/domain/wine.dart';
import 'package:vinoozy/guide/guide_policy.dart';
import 'package:vinoozy/guide/guide_providers.dart';
import 'package:vinoozy/guide/guide_state_store.dart';
import 'package:vinoozy/guide/ui/guide_tour.dart';
import 'package:vinoozy/l10n/app_localizations.dart';
import 'package:vinoozy/sync/snapshot_meta.dart';

import '../dashboard/dashboard_harness.dart';
import '../dashboard/fixtures.dart';
import '../helpers/ui_harness.dart';

/// Targets without the "Add" button: its two steps have no control on
/// screen and are skipped (R-03).
class _NoAddButton extends GuideTargets {
  @override
  Rect? rectOf(GuideTourStep step) =>
      step == GuideTourStep.addWine || step == GuideTourStep.labelPhoto
      ? null
      : super.rectOf(step);
}

void main() {
  late DashboardStreams streams;
  late GuideStateStore store;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    streams = DashboardStreams();
    store = GuideStateStore(SharedPreferences.getInstance);
  });

  Future<void> openCellar(
    WidgetTester tester, {
    Locale locale = const Locale('it'),
    List<Override> extra = const [],
    List<Wine> wines = const [],
    bool e2e = false,
  }) async {
    await pumpScreen(
      tester,
      HomeShell(
        user: dashboardUser,
        setup: CellarSetup.ready,
        onRetrySetup: () async {},
      ),
      locale: locale,
      overrides: [
        ...streams.overrides,
        guideStateStoreProvider.overrideWithValue(store),
        isE2EBuildProvider.overrideWithValue(e2e),
        ...extra,
      ],
    );
    streams
      ..emitCellar()
      ..emitWines(wines);
    await tester.pumpAndSettle();
    // The Dashboard comes first; the tour belongs to the Cellar.
    expect(find.byKey(const Key('tour-scrim')), findsNothing);
    await tester.tap(find.byKey(const Key('home-nav-cellar')));
    await tester.pumpAndSettle();
  }

  for (final locale in testLocales) {
    testWidgets('a new user: the tour starts on the Cellar and "Done" ends '
        'it (${locale.toLanguageTag()})', (tester) async {
      final l10n = lookupAppLocalizations(locale);
      final handle = tester.ensureSemantics();
      await openCellar(tester, locale: locale);

      expect(find.byKey(const Key('tour-step-addWine')), findsOneWidget);
      expect(find.text(l10n.guideAddTitle), findsOneWidget);
      expect(find.text(l10n.guideStepOf(1, 4)), findsOneWidget);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

      for (final step in ['labelPhoto', 'tabs', 'menu']) {
        await tester.tap(find.byKey(const Key('tour-next')));
        await tester.pumpAndSettle();
        expect(find.byKey(Key('tour-step-$step')), findsOneWidget);
      }
      expect(find.text(l10n.guideMenuTitle), findsOneWidget);
      // The last step has "Done" and no "Skip".
      expect(find.byKey(const Key('tour-skip')), findsNothing);
      await tester.tap(find.byKey(const Key('tour-done')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('tour-scrim')), findsNothing);
      expect(await store.tourSeen(), isTrue);
      handle.dispose();
    });
  }

  testWidgets('"Skip" closes the tour and records it', (tester) async {
    await openCellar(tester);
    await tester.tap(find.byKey(const Key('tour-skip')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tour-scrim')), findsNothing);
    expect(await store.tourSeen(), isTrue);
    expect(await store.firstRunRecorded(), isTrue);

    // Leaving the Cellar and coming back does not start it again.
    await tester.tap(find.byKey(const Key('home-nav-dashboard')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home-nav-cellar')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tour-scrim')), findsNothing);
  });

  testWidgets('NFR5 the system Back closes the tour like "Skip"', (
    tester,
  ) async {
    await openCellar(tester);
    expect(find.byKey(const Key('tour-scrim')), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tour-scrim')), findsNothing);
    expect(find.byKey(const Key('home-shell')), findsOneWidget);
    expect(await store.tourSeen(), isTrue);
  });

  testWidgets('R-03 a step without its control on screen is skipped', (
    tester,
  ) async {
    await openCellar(
      tester,
      extra: [guideTargetsProvider.overrideWithValue(_NoAddButton())],
    );
    expect(find.byKey(const Key('tour-step-tabs')), findsOneWidget);
    expect(
      find.text(lookupAppLocalizations(const Locale('it')).guideStepOf(1, 2)),
      findsOneWidget,
    );
  });

  testWidgets('R-02 a phone whose cellar already had wines: no tour, '
      'tour and hints count as seen', (tester) async {
    await openCellar(
      tester,
      wines: [wineOf('w1', name: 'Barolo', window: window(2024, 2030, 2040))],
    );
    expect(find.byKey(const Key('tour-scrim')), findsNothing);
    expect(await store.tourSeen(), isTrue);
    expect(await store.hintSeen(GuideScreen.history), isTrue);
  });

  testWidgets('an empty list from the cache waits for the server', (
    tester,
  ) async {
    await openCellar(tester);
    // Already decided above for a server snapshot; start over with a
    // cache-only one on a fresh phone.
    await tester.pumpWidget(const SizedBox());
    SharedPreferences.setMockInitialValues({});
    streams = DashboardStreams();
    await pumpScreen(
      tester,
      HomeShell(
        user: dashboardUser,
        setup: CellarSetup.ready,
        onRetrySetup: () async {},
      ),
      overrides: [
        ...streams.overrides,
        guideStateStoreProvider.overrideWithValue(store),
      ],
    );
    streams
      ..emitCellar()
      ..winesStream.add(
        const WinesSnapshot(
          wines: [],
          meta: SnapshotMeta(hasPendingWrites: false, isFromCache: true),
        ),
      );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('home-nav-cellar')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tour-scrim')), findsNothing);
    expect(await store.firstRunRecorded(), isFalse);

    streams.emitWines(const []);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tour-scrim')), findsOneWidget);
  });

  testWidgets('FR2.6 never in an end-to-end build', (tester) async {
    await openCellar(tester, e2e: true);
    expect(find.byKey(const Key('tour-scrim')), findsNothing);
    expect(await store.tourSeen(), isFalse);
  });

  group('FR2.1 the hole follows its control', () {
    // The control: 120 x 56, like the extended "Add" button.
    const size = Size(120, 56);
    const start = Offset(16, 100);
    const end = Offset(240, 700);
    Offset centerAt(Offset topLeft) => (topLeft & size).center;

    late GuideTargets targets;
    late ValueNotifier<Offset> place;
    late ValueNotifier<bool> visible;

    setUp(() {
      targets = GuideTargets();
      place = ValueNotifier(start);
      visible = ValueNotifier(true);
    });

    tearDown(() {
      place.dispose();
      visible.dispose();
    });

    Future<void> openTour(WidgetTester tester) async {
      tester.view
        ..physicalSize = const Size(1080, 2400)
        ..devicePixelRatio = 2.625;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('it'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: _MovingControl(
            targets: targets,
            place: place,
            visible: visible,
          ),
        ),
      );
      unawaited(
        GuideTour.show(
          tester.element(find.byType(_MovingControl)),
          steps: const [GuideTourStep.addWine],
          targets: targets,
        ),
      );
    }

    /// Two frames: the route is offstage in its first one (hero measuring).
    Future<void> showRoute(WidgetTester tester) async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
    }

    RenderObject scrim(WidgetTester tester) =>
        tester.renderObject(find.byKey(const Key('tour-scrim')));

    testWidgets('a control still moving into place when the tour opens: '
        'the hole ends where the control ends', (tester) async {
      await openTour(tester);
      // The control starts moving in the frame the tour opens, like the
      // extended FloatingActionButton after the tab change.
      place.value = end;
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('tour-step-addWine')), findsOneWidget);
      expect(
        scrim(tester),
        paints..path(includes: [centerAt(start)], excludes: [centerAt(end)]),
      );
      // Once the control is still, the tour stops following it.
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('a control that disappears: the step stays, without a hole '
        'and without errors', (tester) async {
      await openTour(tester);
      await showRoute(tester);
      expect(scrim(tester), paints..path(excludes: [centerAt(start)]));

      visible.value = false;
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('tour-step-addWine')), findsOneWidget);
      expect(scrim(tester), paints..path(includes: [centerAt(start)]));
    });

    testWidgets('a control laid out only after the tour opened gets its hole', (
      tester,
    ) async {
      visible.value = false;
      await openTour(tester);
      await showRoute(tester);
      expect(scrim(tester), paints..path(includes: [centerAt(start)]));

      visible.value = true;
      await tester.pumpAndSettle();

      expect(scrim(tester), paints..path(excludes: [centerAt(start)]));
    });
  });

  testWidgets('FR2.4 after "Show the guide again" the tour starts again', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'guide.firstRun.version': 1,
      'guide.tour.seen': true,
    });
    await openCellar(tester);
    expect(find.byKey(const Key('tour-scrim')), findsNothing);

    final element = tester.element(find.byKey(const Key('home-shell')));
    await ProviderScopeReader.notifierOf(element).reset();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('tour-step-addWine')), findsOneWidget);
  });
}

/// A control registered as the "Add" target that animates to [place] and
/// is laid out only while [visible] is true.
class _MovingControl extends StatelessWidget {
  const _MovingControl({
    required this.targets,
    required this.place,
    required this.visible,
  });

  final GuideTargets targets;
  final ValueListenable<Offset> place;
  final ValueListenable<bool> visible;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SizedBox.expand(
      child: ValueListenableBuilder<bool>(
        valueListenable: visible,
        builder: (_, shown, _) => ValueListenableBuilder<Offset>(
          valueListenable: place,
          builder: (_, offset, _) => Stack(
            children: [
              if (shown)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  left: offset.dx,
                  top: offset.dy,
                  child: KeyedSubtree(
                    key: targets.addButton,
                    child: const SizedBox(
                      width: 120,
                      height: 56,
                      child: ColoredBox(color: Colors.indigo),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Reads the guide notifier of the widget tree under test.
abstract final class ProviderScopeReader {
  static GuideProgressNotifier notifierOf(BuildContext context) =>
      ProviderScope.containerOf(
        context,
        listen: false,
      ).read(guideProgressProvider.notifier);
}
