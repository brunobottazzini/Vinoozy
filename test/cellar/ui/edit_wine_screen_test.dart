// EditWineScreen (BR1.13, BR1.3; FR3.3, AC3.3.1; NFR3.4): the form filled
// with the wine, the quantity down to 0, the duplicate refused, in three
// languages.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/cellar/cellar_actions.dart';
import 'package:vinoozy/cellar/domain/wine_draft.dart';
import 'package:vinoozy/cellar/ui/edit_wine_screen.dart';

import '../../helpers/ui_harness.dart';
import '../cellar_harness.dart';
import 'cellar_ui_harness.dart';

void main() {
  late CellarUi ui;
  late EditResult result;

  setUp(() {
    ui = CellarUi();
    result = EditResult.saved;
    when(
      () => ui.actions.saveEdit(
        cellar: any(named: 'cellar'),
        user: any(named: 'user'),
        before: any(named: 'before'),
        draft: any(named: 'draft'),
        targetQuantity: any(named: 'targetQuantity'),
      ),
    ).thenAnswer((_) async => result);
  });

  final wine = cellarWine(
    'w1',
    name: 'Barolo',
    producer: 'Cantina Esempio',
    quantity: 1,
    region: 'Piemonte',
  );

  Future<void> pump(
    WidgetTester tester, {
    Locale locale = const Locale('it'),
  }) => pumpScreen(
    tester,
    Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: TextButton(
            key: const Key('open-edit'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => EditWineScreen(
                  user: cellarOwner,
                  cellar: ownerCellar,
                  wine: wine,
                ),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ),
    overrides: ui.overrides,
    locale: locale,
  );

  Future<void> open(
    WidgetTester tester, {
    Locale locale = const Locale('it'),
  }) async {
    await pump(tester, locale: locale);
    await tester.tap(find.byKey(const Key('open-edit')));
    await tester.pumpAndSettle();
  }

  Finder key(String value) => find.byKey(Key(value));

  testWidgets('BR1.13 the form is filled; the quantity goes down to 0', (
    tester,
  ) async {
    await open(tester);

    expect(
      tester.widget<TextField>(key('edit-wine-name')).controller!.text,
      'Barolo',
    );
    expect(
      tester.widget<TextField>(key('edit-wine-producer')).controller!.text,
      'Cantina Esempio',
    );
    await tester.tap(key('quantity-decrease-button'));
    await tester.pump();
    expect(tester.widget<Text>(key('quantity-value')).data, '0');
    expect(
      tester.widget<IconButton>(key('quantity-decrease-button')).onPressed,
      isNull,
    );

    await tester.ensureVisible(key('edit-wine-save'));
    await tester.tap(key('edit-wine-save'));
    await tester.pumpAndSettle();

    final captured = verify(
      () => ui.actions.saveEdit(
        cellar: ownerCellar,
        user: cellarOwner,
        before: wine,
        draft: captureAny(named: 'draft'),
        targetQuantity: 0,
      ),
    ).captured;
    final draft = captured.single as WineDraft;
    expect(draft.region, 'Piemonte', reason: 'kept from the wine');
    expect(find.byType(EditWineScreen), findsNothing);
  });

  testWidgets(
    'BR1.13 the same wine as another one is refused, the form stays',
    (tester) async {
      result = EditResult.duplicate;
      await open(tester);

      await tester.ensureVisible(key('edit-wine-save'));
      await tester.tap(key('edit-wine-save'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Esiste già un altro vino con lo stesso nome, produttore e annata',
        ),
        findsOneWidget,
      );
      expect(find.byType(EditWineScreen), findsOneWidget);
    },
  );

  testWidgets('BR1.3 an empty name is not saved', (tester) async {
    await open(tester);
    await tester.enterText(key('edit-wine-name'), '  ');
    await tester.ensureVisible(key('edit-wine-save'));
    await tester.tap(key('edit-wine-save'));
    await tester.pumpAndSettle();

    expect(find.text('Scrivi il nome del vino'), findsOneWidget);
    verifyNever(
      () => ui.actions.saveEdit(
        cellar: any(named: 'cellar'),
        user: any(named: 'user'),
        before: any(named: 'before'),
        draft: any(named: 'draft'),
        targetQuantity: any(named: 'targetQuantity'),
      ),
    );
  });

  testWidgets('a failed save shows "Impossibile salvare, riprova"', (
    tester,
  ) async {
    result = EditResult.failed;
    await open(tester);
    await tester.tap(key('edit-wine-no-vintage'));
    await tester.ensureVisible(key('edit-wine-save'));
    await tester.tap(key('edit-wine-save'));
    await tester.pumpAndSettle();

    expect(find.text('Impossibile salvare, riprova'), findsOneWidget);
  });

  for (final (locale, title) in [
    (const Locale('en'), 'Edit wine'),
    (const Locale('pt', 'BR'), 'Editar vinho'),
  ]) {
    testWidgets('the title in ${locale.toLanguageTag()}', (tester) async {
      await open(tester, locale: locale);
      expect(find.text(title), findsOneWidget);
    });
  }

  accessibilityMatrix(
    'EditWineScreen',
    () => EditWineScreen(user: cellarOwner, cellar: ownerCellar, wine: wine),
    overrides: () {
      ui = CellarUi();
      return ui.overrides;
    },
  );
}
