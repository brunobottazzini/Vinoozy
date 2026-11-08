// ReadingProgressView (label-recognition F1, L3; u6 BR1.13): the four steps
// with their status in words, each a live region for the screen reader,
// "Annulla", and the accessibility matrix.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/l10n/app_localizations.dart';
import 'package:vinoozy/label/core/label_session.dart';
import 'package:vinoozy/label/ui/reading_progress.dart';

import '../../helpers/ui_harness.dart';

const _progress = ReadingProgress({
  ReadingStep.front: StepStatus.done,
  ReadingStep.back: StepStatus.failed,
  ReadingStep.barcode: StepStatus.skipped,
  ReadingStep.database: StepStatus.running,
});

void main() {
  Widget view({VoidCallback? onCancel}) => Scaffold(
    body: ReadingProgressView(progress: _progress, onCancel: onCancel ?? () {}),
  );

  for (final locale in testLocales) {
    testWidgets('F1 each step shows its status in words '
        '(${locale.toLanguageTag()})', (tester) async {
      final l10n = lookupAppLocalizations(locale);
      await pumpScreen(tester, view(), locale: locale);
      expect(find.text(l10n.labelReading), findsOneWidget);
      expect(find.text(l10n.labelStepFront), findsOneWidget);
      expect(find.text(l10n.labelStepDone), findsOneWidget);
      expect(find.text(l10n.labelStepFailed), findsOneWidget);
      expect(find.text(l10n.labelStepSkipped), findsOneWidget);
      expect(find.text(l10n.labelStepRunning), findsOneWidget);
      expect(find.text(l10n.labelOnPhoneNote), findsOneWidget);
    });
  }

  testWidgets('L3 every step is a live region read as "step: status"', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final l10n = lookupAppLocalizations(const Locale('it'));
    await pumpScreen(tester, view());
    final label = l10n.labelStepStatus(
      l10n.labelStepBack,
      l10n.labelStepFailed,
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel(label)),
      isSemantics(label: label, isLiveRegion: true),
    );
    handle.dispose();
  });

  testWidgets('BR1.13 "Annulla" calls back; a step not started is pending', (
    tester,
  ) async {
    var cancelled = 0;
    final l10n = lookupAppLocalizations(const Locale('it'));
    await pumpScreen(
      tester,
      Scaffold(
        body: ReadingProgressView(
          progress: const ReadingProgress(),
          onCancel: () => cancelled++,
        ),
      ),
    );
    expect(find.text(l10n.labelStepPending), findsNWidgets(4));
    await tester.tap(find.byKey(const Key('label-cancel')));
    expect(cancelled, 1);
  });

  // The spinner never settles: tickers are off for the matrix only.
  accessibilityMatrix(
    'ReadingProgressView',
    () => TickerMode(enabled: false, child: view()),
  );
}
