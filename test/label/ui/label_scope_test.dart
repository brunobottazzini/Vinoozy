// A reading started from a screen inside a nested ProviderScope (as the
// end-to-end test does) uses that scope's image source, Google Lens
// launcher and catalog for the whole reading: the back photo, the lookup,
// "Apri in Google Lens" and "Cerca online". The reading screen is pushed on
// the app Navigator, above the nested scope, so it must not fall back to
// the root services (label_test.dart once opened the real system camera
// for the back photo).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/catalog/core/wine_catalog.dart';
import 'package:vinoozy/catalog/platform/catalog_providers.dart';
import 'package:vinoozy/cellar/ui/add_wine_screen.dart';
import 'package:vinoozy/label/core/label_reading.dart';
import 'package:vinoozy/label/core/label_session.dart';
import 'package:vinoozy/label/label_providers.dart';
import 'package:vinoozy/label/platform/picker_image_source.dart';
import 'package:vinoozy/label/ui/add_choice_screen.dart';

import '../../helpers/ui_harness.dart';
import '../label_harness.dart';
import 'label_ui_harness.dart';

void main() {
  late LabelUi ui;
  late FakeImageSource scopedSource;
  late FakeLensLauncher scopedLens;
  late LabelCatalog scopedCatalog;

  setUp(() {
    ui = LabelUi();
    scopedSource = FakeImageSource(const PickedImage('/cache/1/front.jpg'));
    scopedLens = FakeLensLauncher();
    scopedCatalog = LabelCatalog();
    // The root services would fail the test if they were used.
    ui.env.source.outcome = const PickedImage('/cache/1/root.jpg');
    ui.env.reader.reading = const LabelReading(text: 'Cantina Inesistente');
  });

  /// "Aggiungi" pushed inside a nested scope that overrides the image
  /// source, the Lens launcher and the catalog, then "Scatta foto".
  Future<void> takeFrontInScope(WidgetTester tester) async {
    await pumpScreen(
      tester,
      Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              key: const Key('open-add'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ProviderScope(
                    overrides: [
                      imageSourceProvider.overrideWithValue(scopedSource),
                      lensLauncherProvider.overrideWithValue(scopedLens),
                      catalogProvider.overrideWithValue(scopedCatalog),
                    ],
                    child: const AddChoiceScreen(target: labelTarget),
                  ),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
      overrides: ui.overrides,
    );
    await tester.tap(find.byKey(const Key('open-add')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add-choice-photo')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('label-back-prompt')), findsOneWidget);
  }

  /// label-autofill-windows BR2.1: the text gives a producer, so the form
  /// opens filled above "not found"; back returns to it.
  Future<void> backFromFilledForm(WidgetTester tester) async {
    expect(find.byKey(const Key('add-wine-screen')), findsOneWidget);
    // FR7.1, A19: the guide opens on the form of the photo; close it first.
    await closeGuideSheet(tester);
    await Navigator.of(tester.element(find.byType(AddWineScreen))).maybePop();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('label-not-found-noMatch')), findsOneWidget);
  }

  /// "Salta": the scoped catalog finds nothing, "not found".
  Future<void> skipToNotFound(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('label-back-skip')));
    await tester.pumpAndSettle();
    await backFromFilledForm(tester);
  }

  void expectRootUnused() {
    expect(ui.env.source.origins, isEmpty);
    expect(ui.env.catalog.calls, 0);
    expect(ui.env.catalog.searchCalls, isEmpty);
    expect(ui.env.lens.paths, isEmpty);
  }

  testWidgets('the back photo and the lookup use the scoped image source '
      'and catalog', (tester) async {
    scopedCatalog.byLabel = sureMatch(
      candidateOf('Barolo Ravera', source: CandidateSource.offline),
    );
    await takeFrontInScope(tester);
    scopedSource.outcome = const PickedImage('/cache/1/back.jpg');
    await tester.tap(find.byKey(const Key('label-back-take')));
    await tester.pumpAndSettle();
    expect(scopedSource.origins, [PhotoOrigin.camera, PhotoOrigin.camera]);
    expect(scopedCatalog.textCalls, isNotEmpty);
    expect(find.byKey(const Key('label-proposal')), findsOneWidget);
    expect(find.text('Barolo Ravera'), findsOneWidget);
    expectRootUnused();
  });

  testWidgets('a cancelled back photo from the scoped source is "Salta"', (
    tester,
  ) async {
    await takeFrontInScope(tester);
    scopedSource.outcome = const PickCancelled();
    await tester.tap(find.byKey(const Key('label-back-gallery')));
    await tester.pumpAndSettle();
    expect(scopedSource.origins, [PhotoOrigin.camera, PhotoOrigin.gallery]);
    await backFromFilledForm(tester);
    expect(scopedCatalog.textCalls, ['Cantina Inesistente']);
    expectRootUnused();
  });

  testWidgets('"Apri in Google Lens" uses the scoped launcher', (tester) async {
    await takeFrontInScope(tester);
    await skipToNotFound(tester);
    await tester.tap(find.byKey(const Key('label-lens')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('lens-confirm')));
    await tester.pumpAndSettle();
    expect(scopedLens.paths, hasLength(1));
    expectRootUnused();
  });

  testWidgets('"Cerca online" searches the scoped catalog', (tester) async {
    await takeFrontInScope(tester);
    await skipToNotFound(tester);
    await tester.tap(find.byKey(const Key('label-search-online')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('online-search-submit')));
    await tester.pumpAndSettle();
    expect(scopedCatalog.searchCalls, isNotEmpty);
    expectRootUnused();
  });
}
