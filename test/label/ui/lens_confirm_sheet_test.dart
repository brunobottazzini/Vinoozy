// LensConfirmSheet (label-recognition FR4.2, BR5.1, NFR3.1, NFR3.2, L5): the
// text in the three languages says the photo goes to the Google app, which
// may keep a copy; only "Apri Google Lens" answers true; "Annulla" and the
// back gesture answer false; the accessibility matrix.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/l10n/app_localizations.dart';
import 'package:vinoozy/label/ui/lens_confirm_sheet.dart';

import '../../helpers/ui_harness.dart';

void main() {
  bool? answer;

  Widget opener() => Builder(
    builder: (context) => Scaffold(
      body: Center(
        child: TextButton(
          key: const Key('open-lens-sheet'),
          onPressed: () async => answer = await LensConfirmSheet.show(context),
          child: const Text('open'),
        ),
      ),
    ),
  );

  setUp(() => answer = null);

  Future<void> open(
    WidgetTester tester, {
    Locale locale = const Locale('it'),
  }) async {
    await pumpScreen(tester, opener(), locale: locale);
    await tester.tap(find.byKey(const Key('open-lens-sheet')));
    await tester.pumpAndSettle();
  }

  for (final locale in testLocales) {
    testWidgets('NFR3.2 the confirmation says where the photo goes '
        '(${locale.toLanguageTag()})', (tester) async {
      final l10n = lookupAppLocalizations(locale);
      await open(tester, locale: locale);
      expect(find.text(l10n.labelLensTitle), findsOneWidget);
      expect(find.text(l10n.labelLensBody), findsOneWidget);
      expect(l10n.labelLensBody, contains('Google'));
      expect(find.text(l10n.labelLensConfirm), findsOneWidget);
      expect(find.text(l10n.cancel), findsOneWidget);
    });
  }

  testWidgets('BR5.1 only "Apri Google Lens" confirms', (tester) async {
    await open(tester);
    await tester.tap(find.byKey(const Key('lens-confirm')));
    await tester.pumpAndSettle();
    expect(answer, isTrue);
  });

  testWidgets('NFR3.1 "Annulla" does not confirm', (tester) async {
    await open(tester);
    await tester.tap(find.byKey(const Key('lens-cancel')));
    await tester.pumpAndSettle();
    expect(answer, isFalse);
  });

  testWidgets('L5 the back gesture closes the sheet without confirming', (
    tester,
  ) async {
    await open(tester);
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    await navigator.maybePop();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('lens-confirm-sheet')), findsNothing);
    expect(answer, isFalse);
  });

  accessibilityMatrix(
    'LensConfirmSheet',
    opener,
    afterPump: (tester) async {
      await tester.tap(find.byKey(const Key('open-lens-sheet')));
    },
  );
}
