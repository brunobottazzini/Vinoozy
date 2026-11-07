// DrinkSnackBar (BR1.10; NFR3.3): "Undo" and "Add rating and notes" for 6
// seconds, 10 seconds with a screen reader or reduced animations, in three
// languages.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/cellar/ui/drink_snack_bar.dart';

import '../../helpers/ui_harness.dart';
import 'cellar_ui_harness.dart';

void main() {
  late List<String> calls;
  late CellarUi ui;

  setUp(() {
    calls = [];
    ui = CellarUi();
  });

  Widget host({bool accessible = false, bool reducedMotion = false}) => Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        accessibleNavigation: accessible,
        disableAnimations: reducedMotion,
      ),
      child: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              key: const Key('drink'),
              onPressed: () => DrinkSnackBar.show(
                context,
                wineName: 'Barolo',
                onUndo: () => calls.add('undo'),
                onAddNotes: () => calls.add('notes'),
              ),
              child: const Text('drink'),
            ),
          ),
        ),
      ),
    ),
  );

  Future<void> show(
    WidgetTester tester, {
    bool accessible = false,
    bool reducedMotion = false,
    Locale locale = const Locale('it'),
  }) async {
    await pumpScreen(
      tester,
      host(accessible: accessible, reducedMotion: reducedMotion),
      overrides: ui.overrides,
      locale: locale,
    );
    await tester.tap(find.byKey(const Key('drink')));
    await tester.pumpAndSettle();
  }

  Duration shownFor(WidgetTester tester) =>
      tester.widget<SnackBar>(find.byKey(const Key('drink-snackbar'))).duration;

  testWidgets('BR1.10 NFR3.3 6 seconds by default, with both actions', (
    tester,
  ) async {
    await show(tester);

    expect(shownFor(tester), const Duration(seconds: 6));
    expect(find.text('Bevuta segnata: Barolo'), findsOneWidget);
    expect(find.text('Annulla'), findsOneWidget);
    expect(find.text('Aggiungi voto e note'), findsOneWidget);
  });

  testWidgets('NFR3.3 10 seconds with a screen reader', (tester) async {
    await show(tester, accessible: true);
    expect(shownFor(tester), const Duration(seconds: 10));
  });

  testWidgets('NFR3.3 10 seconds with reduced animations', (tester) async {
    await show(tester, reducedMotion: true);
    expect(shownFor(tester), const Duration(seconds: 10));
  });

  testWidgets('BR1.10 "Annulla" and "Aggiungi voto e note" close it and act', (
    tester,
  ) async {
    await show(tester);
    await tester.tap(find.byKey(const Key('drink-undo')));
    await tester.pumpAndSettle();
    expect(calls, ['undo']);
    expect(find.byKey(const Key('drink-snackbar')), findsNothing);

    await tester.tap(find.byKey(const Key('drink')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('drink-add-notes')));
    await tester.pumpAndSettle();
    expect(calls, ['undo', 'notes']);
  });

  testWidgets('BR1.10 the message closes by itself after 6 seconds', (
    tester,
  ) async {
    await show(tester);
    await tester.pump(const Duration(seconds: 7));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('drink-snackbar')), findsNothing);
  });

  for (final (locale, done, undo) in [
    (const Locale('en'), 'Marked as drunk: Barolo', 'Undo'),
    (const Locale('pt', 'BR'), 'Degustação registrada: Barolo', 'Desfazer'),
  ]) {
    testWidgets('BR1.10 texts in ${locale.toLanguageTag()}', (tester) async {
      await show(tester, locale: locale);
      expect(find.text(done), findsOneWidget);
      expect(find.text(undo), findsOneWidget);
    });
  }

  testWidgets('NFR3.4 the actions meet the tap-target guideline', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await show(tester, locale: const Locale('pt', 'BR'));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });
}
