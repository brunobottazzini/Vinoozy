// u4-cellar extensions for the label photo (u6-label-recognition BR1.15):
// AddWineScreen with AddWineInitialValues, and the public DuplicateDialog.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/catalog/core/wine_catalog.dart';
import 'package:vinoozy/cellar/cellar_actions.dart';
import 'package:vinoozy/cellar/domain/wine_draft.dart';
import 'package:vinoozy/cellar/ui/add_wine_screen.dart';
import 'package:vinoozy/cellar/ui/cellar_dialogs.dart';

import '../../helpers/ui_harness.dart';
import '../cellar_harness.dart';
import 'cellar_ui_harness.dart';

void main() {
  late CellarUi ui;
  late List<WineDraft> saved;

  setUp(() {
    ui = CellarUi();
    saved = [];
    when(
      () => ui.actions.saveNewWine(
        cellar: any(named: 'cellar'),
        user: any(named: 'user'),
        draft: any(named: 'draft'),
      ),
    ).thenAnswer((invocation) async {
      saved.add(invocation.namedArguments[#draft] as WineDraft);
      return AddSaved(cellarWine('wine-1'));
    });
  });

  Future<void> pumpForm(WidgetTester tester, AddWineInitialValues values) =>
      pumpScreen(
        tester,
        AddWineScreen(
          user: cellarOwner,
          cellarId: 'user-a',
          cellar: ownerCellar,
          initialValues: values,
        ),
        overrides: ui.overrides,
      );

  group('BR1.15 AddWineInitialValues', () {
    test('BR1.15 a candidate converts its type like a picked suggestion', () {
      const candidate = WineCandidate(
        name: 'Barolo',
        producer: 'Cantina A',
        wineType: CatalogWineType.red,
        region: 'Piemonte',
        denomination: 'Barolo DOCG',
        source: CandidateSource.openFoodFacts,
      );
      final values = AddWineInitialValues.fromCandidate(candidate, quantity: 4);
      expect(values.wineType, wineFamilyOf(CatalogWineType.red));
      expect(values.wineType, 'redStructured');
      expect(values.noVintage, isTrue);
      expect(values.quantity, 4);
      expect(values.region, 'Piemonte');
      expect(wineFamilyOf(null), isNull);
    });

    testWidgets('BR1.15 the form opens filled, with the notice on top, and '
        'saves those values', (tester) async {
      await pumpForm(
        tester,
        const AddWineInitialValues(
          name: 'Barolo',
          producer: 'Cantina A',
          vintage: 2016,
          quantity: 3,
          wineType: 'redStructured',
          region: 'Piemonte',
          denomination: 'Barolo DOCG',
          notice: 'Non ho trovato il vino: controlla i dati',
        ),
      );
      expect(find.byKey(const Key('add-wine-notice')), findsOneWidget);
      expect(find.text('Barolo'), findsOneWidget);
      expect(find.text('Cantina A'), findsOneWidget);
      expect(find.text('2016'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      await tester.tap(find.byKey(const Key('add-wine-save-button')));
      await tester.pumpAndSettle();
      final draft = saved.single;
      expect(draft.vintage, 2016);
      expect(draft.quantity, 3);
      expect(draft.wineType, 'redStructured');
      expect(draft.denomination, 'Barolo DOCG');
    });

    testWidgets('BR1.15 "no vintage" and a quantity out of range are kept '
        'within the form rules', (tester) async {
      await pumpForm(
        tester,
        const AddWineInitialValues(
          name: 'Rosso',
          noVintage: true,
          quantity: 150,
        ),
      );
      expect(find.byKey(const Key('add-wine-notice')), findsNothing);
      expect(find.text('99'), findsOneWidget);
      await tester.tap(find.byKey(const Key('add-wine-save-button')));
      await tester.pumpAndSettle();
      expect(saved.single.vintage, isNull);
      expect(saved.single.quantity, 99);
    });
  });

  group('BR1.15 DuplicateDialog is public', () {
    testWidgets('BR1.15 shown from outside U4 it adds at most up to 99', (
      tester,
    ) async {
      final existing = cellarWine('old', name: 'Barolo', quantity: 98);
      late bool confirmed;
      await pumpScreen(
        tester,
        Builder(
          builder: (context) => TextButton(
            onPressed: () async => confirmed = await DuplicateDialog.show(
              context,
              existing: existing,
              bottles: 5,
            ),
            child: const Text('open'),
          ),
        ),
        overrides: ui.overrides,
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('duplicate-dialog')), findsOneWidget);
      expect(DuplicateDialog.addableFor(existing, 5), 1);
      await tester.tap(find.byKey(const Key('duplicate-confirm')));
      await tester.pumpAndSettle();
      expect(confirmed, isTrue);
    });
  });
}
