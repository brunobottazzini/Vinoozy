// Dialogs and the drink sheet (BR1.4, BR1.11, BR1.12, BR1.14, BR1.20; NFR3.2,
// NFR3.4): texts in it, en and pt-BR, the stars as labelled selectable
// buttons, the validation of rating, notes and date.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/app/providers.dart';
import 'package:vinoozy/sync/sync_error_bus.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/cellar/data/wine_repository.dart';
import 'package:vinoozy/cellar/domain/drinking_record.dart';
import 'package:vinoozy/cellar/ui/cellar_dialogs.dart';
import 'package:vinoozy/cellar/ui/drinking_record_sheet.dart';

import '../../helpers/ui_harness.dart';
import '../cellar_harness.dart';
import 'cellar_ui_harness.dart';

void main() {
  late CellarUi ui;
  Object? dialogResult;

  setUp(() {
    ui = CellarUi();
    dialogResult = null;
  });

  /// A host page with one button that opens [open] and keeps its result.
  Widget host(Future<Object?> Function(BuildContext context) open) => Builder(
    builder: (context) => Scaffold(
      body: Center(
        child: TextButton(
          key: const Key('open'),
          onPressed: () async => dialogResult = await open(context),
          child: const Text('open'),
        ),
      ),
    ),
  );

  Future<void> openWith(
    WidgetTester tester,
    Future<Object?> Function(BuildContext context) open, {
    Locale locale = const Locale('it'),
  }) async {
    await pumpScreen(
      tester,
      host(open),
      overrides: ui.overrides,
      locale: locale,
    );
    await tester.tap(find.byKey(const Key('open')));
    await tester.pumpAndSettle();
  }

  Finder key(String value) => find.byKey(Key(value));

  group('BR1.4 DuplicateDialog', () {
    for (final (locale, title, add) in [
      (const Locale('it'), 'Già in cantina', 'Aggiungi 3 bottiglie'),
      (const Locale('en'), 'Already in the cellar', 'Add 3 bottles'),
      (const Locale('pt', 'BR'), 'Já está na adega', 'Adicionar 3 garrafas'),
    ]) {
      testWidgets('BR1.4 texts in ${locale.toLanguageTag()}', (tester) async {
        await openWith(
          tester,
          (context) => DuplicateDialog.show(
            context,
            existing: cellarWine('w1', quantity: 2),
            bottles: 3,
          ),
          locale: locale,
        );

        expect(find.text(title), findsOneWidget);
        expect(find.text(add), findsOneWidget);
        await tester.tap(key('duplicate-confirm'));
        await tester.pumpAndSettle();
        expect(dialogResult, isTrue);
      });
    }

    testWidgets('BR1.4 the body shows the current quantity', (tester) async {
      await openWith(
        tester,
        (context) => DuplicateDialog.show(
          context,
          existing: cellarWine('w1', quantity: 1),
          bottles: 1,
        ),
      );

      expect(find.textContaining('1 bottiglia'), findsWidgets);
      await tester.tap(key('duplicate-cancel'));
      await tester.pumpAndSettle();
      expect(dialogResult, isFalse);
    });
  });

  testWidgets('BR1.3 R-05 the dialog adds at most up to 99 bottles', (
    tester,
  ) async {
    await openWith(
      tester,
      (context) => DuplicateDialog.show(
        context,
        existing: cellarWine('w1', quantity: 97),
        bottles: 5,
      ),
    );

    expect(find.text('Aggiungi 2 bottiglie'), findsOneWidget);
    expect(key('duplicate-full'), findsNothing);
    expect(DuplicateDialog.addableFor(cellarWine('w1', quantity: 97), 5), 2);
    expect(DuplicateDialog.addableFor(cellarWine('w1', quantity: -3), 5), 5);
  });

  testWidgets('BR1.3 R-05 a wine already at 99: "Aggiungi" off, the reason '
      'shown', (tester) async {
    await openWith(
      tester,
      (context) => DuplicateDialog.show(
        context,
        existing: cellarWine('w1', quantity: 99),
        bottles: 1,
      ),
    );

    expect(
      find.text(
        'Questo vino ha già 99 bottiglie: non se ne possono aggiungere altre.',
      ),
      findsOneWidget,
    );
    expect(
      tester.widget<ButtonStyleButton>(key('duplicate-confirm')).onPressed,
      isNull,
    );
  });

  for (final (locale, text) in [
    (
      const Locale('it'),
      "L'eliminazione non è ancora completa: continuerà appena possibile",
    ),
    (
      const Locale('en'),
      'The deletion is not complete yet: it will finish as soon as possible',
    ),
    (
      const Locale('pt', 'BR'),
      'A exclusão ainda não foi concluída: continuará assim que possível',
    ),
  ]) {
    testWidgets('BR1.14 R-06 a delete refused twice says it will complete, '
        'never "try again" (${locale.toLanguageTag()})', (tester) async {
      await pumpScreen(
        tester,
        host((_) async => null),
        overrides: ui.overrides,
        locale: locale,
      );
      ProviderScope.containerOf(tester.element(find.byType(Scaffold)))
          .read(syncErrorBusProvider)
          .publish(const CellarNotice(CellarNoticeKind.deleteFailed));
      await tester.pumpAndSettle();

      expect(find.text(text), findsOneWidget);
      expect(find.textContaining('riprova'), findsNothing);
    });
  }

  testWidgets('BR1.14 DeleteWineDialog names the wine', (tester) async {
    await openWith(
      tester,
      (context) => DeleteWineDialog.show(context, 'Barolo'),
      locale: const Locale('en'),
    );

    expect(find.text('Delete Barolo?'), findsOneWidget);
    expect(
      find.text(
        'The wine and all its drinks are deleted. This cannot be undone.',
      ),
      findsOneWidget,
    );
    await tester.tap(key('delete-cancel'));
    await tester.pumpAndSettle();
    expect(dialogResult, isFalse);
  });

  testWidgets('BR1.20 MergeDialog confirms in pt-BR', (tester) async {
    await openWith(tester, MergeDialog.show, locale: const Locale('pt', 'BR'));

    expect(find.text('Mesclar as duas entradas?'), findsOneWidget);
    await tester.tap(key('merge-confirm'));
    await tester.pumpAndSettle();
    expect(dialogResult, isTrue);
  });

  group('BR1.11 DrinkingRecordSheet', () {
    final record = drinkRecord('r1', vintage: 2016, rating: 2);

    Future<void> openSheet(WidgetTester tester, {Locale? locale}) => openWith(
      tester,
      (context) => DrinkingRecordSheet.show(
        context,
        user: cellarOwner,
        cellar: ownerCellar,
        record: record,
        wine: cellarWine('w1'),
      ),
      locale: locale ?? const Locale('it'),
    );

    testWidgets('NFR3.2 every star is a button "Voto N su 5", selected up to '
        'the rating', (tester) async {
      final handle = tester.ensureSemantics();
      await openSheet(tester);

      expect(
        tester.getSemantics(key('record-rating-2')),
        matchesSemantics(
          label: 'Voto 2 su 5',
          isButton: true,
          isSelected: true,
          hasSelectedState: true,
        ),
      );
      expect(
        tester.getSemantics(key('record-rating-4')),
        matchesSemantics(
          label: 'Voto 4 su 5',
          isButton: true,
          isSelected: false,
          hasSelectedState: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('BR1.11 BR1.12 rating, notes and "Com\'era?" are saved', (
      tester,
    ) async {
      await openSheet(tester);

      await tester.tap(key('record-rating-4'));
      await tester.enterText(key('record-notes'), 'Ancora chiuso');
      await tester.tap(key('record-condition-tooYoung'));
      await tester.ensureVisible(key('record-save'));
      await tester.tap(key('record-save'));
      await tester.pumpAndSettle();

      verify(
        () => ui.actions.updateRecord(
          cellar: ownerCellar,
          user: cellarOwner,
          record: record,
          wine: any(named: 'wine'),
          rating: 4,
          notes: 'Ancora chiuso',
          drankOn: record.drankOn,
          condition: DrinkCondition.tooYoung,
        ),
      ).called(1);
      expect(dialogResult, isTrue);
    });

    testWidgets('BR1.11 notes over 1000 characters are refused', (
      tester,
    ) async {
      await openSheet(tester);

      await tester.enterText(key('record-notes'), 'n' * 1001);
      await tester.ensureVisible(key('record-save'));
      await tester.tap(key('record-save'));
      await tester.pumpAndSettle();

      expect(find.text('Al massimo 1000 caratteri'), findsOneWidget);
      verifyNever(
        () => ui.actions.updateRecord(
          cellar: any(named: 'cellar'),
          user: any(named: 'user'),
          record: any(named: 'record'),
          wine: any(named: 'wine'),
          rating: any(named: 'rating'),
          notes: any(named: 'notes'),
          drankOn: any(named: 'drankOn'),
          condition: any(named: 'condition'),
        ),
      );
    });

    testWidgets('a failed save keeps the sheet open with the message', (
      tester,
    ) async {
      when(
        () => ui.actions.updateRecord(
          cellar: any(named: 'cellar'),
          user: any(named: 'user'),
          record: any(named: 'record'),
          wine: any(named: 'wine'),
          rating: any(named: 'rating'),
          notes: any(named: 'notes'),
          drankOn: any(named: 'drankOn'),
          condition: any(named: 'condition'),
        ),
      ).thenAnswer((_) async => SaveFailure(StateError('ledger')));
      await openSheet(tester);

      await tester.tap(key('record-condition-none'));
      await tester.ensureVisible(key('record-save'));
      await tester.tap(key('record-save'));
      await tester.pumpAndSettle();

      expect(key('record-save-failed'), findsOneWidget);
    });

    testWidgets('the date picker offers no future day', (tester) async {
      await openSheet(tester);

      await tester.tap(key('record-date'));
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);
      final picker = tester.widget<DatePickerDialog>(
        find.byType(DatePickerDialog),
      );
      expect(picker.lastDate, DateTime(2026, 11, 6));
      expect(picker.firstDate, DateTime(2016));
    });

    testWidgets('BR1.11 only the author or the owner may change a drink', (
      tester,
    ) async {
      final byOther = drinkRecord('r2', recordedBy: 'user-z');

      expect(
        DrinkingRecordSheet.canChange(ownerCellar, cellarOwner, byOther),
        isTrue,
      );
      expect(
        DrinkingRecordSheet.canChange(editCellar, cellarEditor, byOther),
        isFalse,
      );
      expect(
        DrinkingRecordSheet.canChange(
          editCellar,
          cellarEditor,
          drinkRecord('r3', recordedBy: 'user-c'),
        ),
        isTrue,
      );
      expect(
        DrinkingRecordSheet.canChange(
          readCellar,
          cellarEditor,
          drinkRecord('r3', recordedBy: 'user-c'),
        ),
        isFalse,
      );
    });

    for (final (locale, title, howWas) in [
      (const Locale('en'), 'Rating and notes', 'How was it?'),
      (const Locale('pt', 'BR'), 'Nota e comentários', 'Como estava?'),
    ]) {
      testWidgets('BR1.11 the sheet in ${locale.toLanguageTag()}', (
        tester,
      ) async {
        await openSheet(tester, locale: locale);

        expect(find.text(title), findsOneWidget);
        expect(find.text(howWas), findsOneWidget);
      });
    }
  });

  accessibilityMatrix(
    'DrinkingRecordSheet',
    // In the app the sheet sits on the Material of the bottom sheet.
    () => Scaffold(
      body: DrinkingRecordSheet(
        user: cellarOwner,
        cellar: ownerCellar,
        record: drinkRecord('r1', rating: 3),
      ),
    ),
    overrides: () {
      ui = CellarUi();
      return ui.overrides;
    },
  );
}
