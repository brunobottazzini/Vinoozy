import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/account/app_user.dart';
import 'package:vinoozy/app/providers.dart';
import 'package:vinoozy/cellar/data/wine_repository.dart';
import 'package:vinoozy/cellar/domain/wine_draft.dart';
import 'package:vinoozy/cellar/ui/add_wine_screen.dart';

import '../../helpers/fakes.dart';
import '../../helpers/service_mocks.dart';
import '../../helpers/ui_harness.dart';

const userA = AppUser(
  uid: 'user-a',
  email: 'user-a@example.com',
  displayName: 'A',
);

void main() {
  late MockWineRepository wines;
  late List<WineDraft> created;
  late Completer<SaveOutcome> outcome;

  setUpAll(() {
    registerFallbackValue(userA);
    registerFallbackValue(
      WineDraft.validate(
        id: 'x',
        rawName: 'x',
        rawVintage: '',
        noVintage: true,
        quantity: 1,
        currentYear: 2026,
      ).draft!,
    );
  });

  setUp(() {
    wines = MockWineRepository();
    created = [];
    outcome = Completer<SaveOutcome>();
    when(
      () => wines.create(
        cellarId: any(named: 'cellarId'),
        user: any(named: 'user'),
        draft: any(named: 'draft'),
      ),
    ).thenAnswer((invocation) {
      created.add(invocation.namedArguments[#draft] as WineDraft);
      return outcome.future;
    });
  });

  /// Opens the form from a host page, so a successful save can pop it.
  Future<void> open(WidgetTester tester, {String? initialName}) async {
    // Created inside the test's fake-async zone, so completing it is seen by
    // tester.pump().
    outcome = Completer<SaveOutcome>();
    await pumpScreen(
      tester,
      Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              key: const Key('open-form'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => AddWineScreen(
                    user: userA,
                    cellarId: 'user-a',
                    initialName: initialName,
                  ),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
      overrides: [
        wineRepositoryProvider.overrideWithValue(wines),
        idGeneratorProvider.overrideWithValue(SequenceIdGenerator()),
        clockProvider.overrideWithValue(FakeClock(DateTime(2026, 11, 5))),
      ],
    );
    await tester.tap(find.byKey(const Key('open-form')));
    await tester.pumpAndSettle();
  }

  Finder field(String key) => find.byKey(Key(key));

  Future<void> fill(
    WidgetTester tester, {
    String name = 'Barolo',
    String vintage = '2016',
  }) async {
    await tester.enterText(field('add-wine-name-field'), name);
    await tester.enterText(field('add-wine-vintage-field'), vintage);
  }

  testWidgets('opens empty with quantity 1 (W3)', (tester) async {
    await open(tester);

    expect(find.text('Scrivi'), findsOneWidget);
    expect(tester.widget<Text>(field('quantity-value')).data, '1');
    expect(
      tester.widget<TextField>(field('add-wine-name-field')).controller!.text,
      isEmpty,
    );
  });

  testWidgets('leaving an empty name field shows its error (BR2.1)', (
    tester,
  ) async {
    await open(tester);

    await tester.tap(field('add-wine-name-field'));
    await tester.pump();
    await tester.tap(field('add-wine-vintage-field'));
    await tester.pump();

    expect(find.text('Scrivi il nome del vino'), findsOneWidget);
  });

  testWidgets('Save with invalid data shows the errors and keeps the input', (
    tester,
  ) async {
    await open(tester);
    await fill(tester, name: 'a' * 121, vintage: '2027');

    await tester.tap(field('add-wine-save-button'));
    await tester.pumpAndSettle();

    expect(find.text('Massimo 120 caratteri'), findsOneWidget);
    expect(find.text('Annata tra 1900 e 2026'), findsOneWidget);
    expect(created, isEmpty);
    expect(
      tester.widget<TextField>(field('add-wine-name-field')).controller!.text,
      'a' * 121,
    );
  });

  testWidgets('a double tap on Save creates one wine and closes the form', (
    tester,
  ) async {
    await open(tester);
    await fill(tester);

    await tester.tap(field('add-wine-save-button'));
    await tester.pump();
    await tester.tap(field('add-wine-save-button'), warnIfMissed: false);
    await tester.pump();
    expect(created, hasLength(1));
    expect(created.single.name, 'Barolo');
    expect(created.single.vintage, 2016);
    expect(created.single.id, 'wine-1');

    outcome.complete(const SaveAccepted());
    await tester.pumpAndSettle();
    expect(find.byType(AddWineScreen), findsNothing);
  });

  testWidgets('a local failure keeps the form, the data and the same id', (
    tester,
  ) async {
    await open(tester);
    await fill(tester);
    await tester.tap(field('add-wine-save-button'));
    outcome.complete(SaveFailure(StateError('cache')));
    await tester.pumpAndSettle();

    expect(find.text('Impossibile salvare, riprova'), findsOneWidget);
    final save = tester.widget<ButtonStyleButton>(
      field('add-wine-save-button'),
    );
    expect(save.onPressed, isNotNull, reason: 'Save is enabled again');

    outcome = Completer<SaveOutcome>()..complete(const SaveAccepted());
    await tester.tap(field('add-wine-save-button'));
    await tester.pumpAndSettle();
    expect(created.map((d) => d.id), ['wine-1', 'wine-1']);
  });

  testWidgets('"Senza annata" disables the vintage and saves null', (
    tester,
  ) async {
    await open(tester);
    await tester.enterText(field('add-wine-name-field'), 'Barbera');
    await tester.tap(field('add-wine-no-vintage-switch'));
    await tester.pump();

    expect(
      tester.widget<TextField>(field('add-wine-vintage-field')).enabled,
      isFalse,
    );
    await tester.tap(field('add-wine-save-button'));
    await tester.pump();
    expect(created.single.vintage, isNull);
  });

  testWidgets('the stepper stays within 1..99 (BR2.3)', (tester) async {
    await open(tester);
    final minus = field('quantity-decrease-button');
    final plus = field('quantity-increase-button');

    expect(tester.widget<IconButton>(minus).onPressed, isNull);
    await tester.tap(plus);
    await tester.pump();
    expect(tester.widget<Text>(field('quantity-value')).data, '2');
    await tester.tap(minus);
    await tester.pump();
    expect(tester.widget<Text>(field('quantity-value')).data, '1');
  });

  testWidgets('"Aggiungi di nuovo" reopens with only the name', (tester) async {
    await open(tester, initialName: 'Barolo');

    expect(
      tester.widget<TextField>(field('add-wine-name-field')).controller!.text,
      'Barolo',
    );
    expect(
      tester
          .widget<TextField>(field('add-wine-vintage-field'))
          .controller!
          .text,
      isEmpty,
    );
  });

  accessibilityMatrix(
    'AddWineScreen',
    () => const AddWineScreen(user: userA, cellarId: 'user-a'),
    overrides: () => [
      wineRepositoryProvider.overrideWithValue(MockWineRepository()),
      idGeneratorProvider.overrideWithValue(SequenceIdGenerator()),
      clockProvider.overrideWithValue(FakeClock(DateTime(2026, 11, 5))),
    ],
    afterPump: (tester) async {
      // Errors visible too: they must also fit at 200%.
      await tester.tap(find.byKey(const Key('add-wine-save-button')));
      await tester.pump();
    },
  );
}
