// The label screens in a widget test: every label fake (LabelEnv), the U4
// operations as a mocktail double, predictable ids, no sharing.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinoozy/app/providers.dart';
import 'package:vinoozy/cellar/cellar_actions.dart';
import 'package:vinoozy/cellar/cellar_providers.dart';
import 'package:vinoozy/cellar/data/wine_repository.dart';
import 'package:vinoozy/label/ui/add_choice_screen.dart';
import 'package:vinoozy/label/ui/label_capture_flow.dart';

import '../../cellar/cellar_harness.dart';
import '../../helpers/fakes.dart';
import '../../helpers/ui_harness.dart';
import '../../sharing/sharing_harness.dart' show noSharingOverrides;
import '../label_harness.dart';

/// label-autofill-windows FR7.1, A19: the form filled from a photo opens
/// the guided check of its uncertain fields; "Close" shuts it, keeping the
/// form, so that Back then leaves the form. The sheet must be there: a
/// test adapted for FR7.1 fails if the guide never opens.
Future<void> closeGuideSheet(WidgetTester tester) async {
  expect(find.byKey(const Key('guide-sheet')), findsOneWidget);
  await tester.tap(find.byKey(const Key('guide-close')));
  await tester.pumpAndSettle();
  expect(find.byKey(const Key('guide-sheet')), findsNothing);
}

/// The cellar the photo adds to: the owner's own.
const labelTarget = LabelTarget(user: cellarOwner, cellar: ownerCellar);

class LabelUi {
  LabelUi() {
    SharedPreferences.setMockInitialValues({});
    registerCellarFallbacks();
    when(
      () => actions.saveNewWine(
        cellar: any(named: 'cellar'),
        user: any(named: 'user'),
        draft: any(named: 'draft'),
      ),
    ).thenAnswer((_) async => saveResult);
    when(
      () => actions.addBottles(
        cellar: any(named: 'cellar'),
        user: any(named: 'user'),
        wine: any(named: 'wine'),
        n: any(named: 'n'),
      ),
    ).thenAnswer((_) async => const SaveAccepted());
  }

  final env = LabelEnv();
  final actions = MockCellarActions();

  /// What "Conferma" gets from the U4 save.
  AddResult saveResult = AddSaved(cellarWine('new'));

  /// More overrides of one test, after the usual ones.
  List<Override> extraOverrides = [];

  List<Override> get overrides => [
    ...env.overrides,
    cellarActionsProvider.overrideWithValue(actions),
    idGeneratorProvider.overrideWithValue(SequenceIdGenerator()),
    ...noSharingOverrides(),
    ...extraOverrides,
  ];

  /// "Aggiungi" pushed above a root page, like the shell does.
  Future<void> pumpAddChoice(
    WidgetTester tester, {
    Locale locale = const Locale('it'),
    double textScale = 1.0,
  }) async {
    await pumpScreen(
      tester,
      Builder(
        builder: (context) => Scaffold(
          key: const Key('root-page'),
          body: Center(
            child: TextButton(
              key: const Key('open-add'),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const AddChoiceScreen(target: labelTarget),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
      locale: locale,
      textScale: textScale,
      overrides: overrides,
    );
    await tester.tap(find.byKey(const Key('open-add')));
    await tester.pumpAndSettle();
  }
}
