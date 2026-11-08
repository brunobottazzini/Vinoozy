// BackPhotoPrompt, "Ora il retro" (label-recognition FR1.1, BR1.1, L1, L2):
// the three buttons in the three languages, each calling its action, and
// the accessibility matrix.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/l10n/app_localizations.dart';
import 'package:vinoozy/label/ui/back_photo_prompt.dart';

import '../../helpers/ui_harness.dart';

void main() {
  for (final locale in testLocales) {
    testWidgets('BR1.1 "Scatta il retro", "Scegli dalla galleria" and '
        '"Salta" are always shown (${locale.toLanguageTag()})', (tester) async {
      final l10n = lookupAppLocalizations(locale);
      final taps = <String>[];
      await pumpScreen(
        tester,
        Scaffold(
          body: BackPhotoPrompt(
            onTake: () => taps.add('take'),
            onPick: () => taps.add('pick'),
            onSkip: () => taps.add('skip'),
          ),
        ),
        locale: locale,
      );
      expect(find.text(l10n.labelBackTitle), findsOneWidget);
      expect(find.text(l10n.labelBackHint), findsOneWidget);
      expect(find.text(l10n.labelBackTake), findsOneWidget);
      expect(find.text(l10n.labelBackGallery), findsOneWidget);
      expect(find.text(l10n.labelBackSkip), findsOneWidget);
      for (final key in ['take', 'gallery', 'skip']) {
        await tester.tap(find.byKey(Key('label-back-$key')));
      }
      expect(taps, ['take', 'pick', 'skip']);
    });
  }

  testWidgets('L2 every button is at least 48 dp high', (tester) async {
    await pumpScreen(
      tester,
      Scaffold(
        body: BackPhotoPrompt(onTake: () {}, onPick: () {}, onSkip: () {}),
      ),
    );
    for (final key in ['take', 'gallery', 'skip']) {
      expect(
        tester.getSize(find.byKey(Key('label-back-$key'))).height,
        greaterThanOrEqualTo(48),
      );
    }
  });

  accessibilityMatrix(
    'BackPhotoPrompt',
    () => Scaffold(
      body: BackPhotoPrompt(onTake: () {}, onPick: () {}, onSkip: () {}),
    ),
  );
}
