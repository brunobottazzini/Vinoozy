// tester-feedback FR7.1-FR7.3, review R-07: the FAQ screen, in it, en and
// pt-BR, without network.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/app/external_links.dart';
import 'package:vinoozy/catalog/platform/catalog_providers.dart';
import 'package:vinoozy/l10n/app_localizations.dart';
import 'package:vinoozy/plan/domain/plan_policy.dart';
import 'package:vinoozy/settings/ui/faq_screen.dart';

import '../helpers/ui_harness.dart';

void main() {
  late List<String> subjects;
  late bool emailOpens;

  setUp(() {
    subjects = [];
    emailOpens = true;
  });

  Future<void> pump(
    WidgetTester tester, {
    Locale locale = const Locale('it'),
    Widget screen = const FaqScreen(),
  }) async {
    await pumpScreen(
      tester,
      screen,
      locale: locale,
      overrides: [
        supportEmailOpenerProvider.overrideWithValue(({
          required subject,
          required body,
        }) async {
          subjects.add(subject);
          return emailOpens;
        }),
        deviceInfoReaderProvider.overrideWithValue(() async => null),
        supportEmailReaderProvider.overrideWithValue(
          () async => 'support@example.com',
        ),
        catalogAppVersionProvider.overrideWith((ref) async => '0.4.0'),
      ],
    );
    await tester.pumpAndSettle();
  }

  for (final locale in testLocales) {
    testWidgets('FR7.1 eight questions; a tap opens and closes the answer '
        '(${locale.toLanguageTag()})', (tester) async {
      final l10n = lookupAppLocalizations(locale);
      await pump(tester, locale: locale);
      expect(find.text(l10n.settingsFaq), findsOneWidget);
      for (var index = 0; index < 8; index++) {
        expect(find.byKey(Key('faq-item-$index')), findsOneWidget);
      }
      expect(find.text(l10n.faqAddAnswer), findsNothing);

      await tester.tap(find.text(l10n.faqAddQuestion));
      await tester.pumpAndSettle();
      expect(find.text(l10n.faqAddAnswer), findsOneWidget);

      await tester.tap(find.text(l10n.faqAddQuestion));
      await tester.pumpAndSettle();
      expect(find.text(l10n.faqAddAnswer), findsNothing);
    });
  }

  testWidgets('R-07 the Plus answer shows the limit of the app constant', (
    tester,
  ) async {
    final l10n = lookupAppLocalizations(const Locale('it'));
    await pump(tester);
    await tester.tap(find.byKey(const Key('faq-item-5')));
    await tester.pumpAndSettle();
    final answer = l10n.faqPlusAnswer(PlanPolicy.defaultFreeActiveWineLimit);
    expect(find.text(answer), findsOneWidget);
    expect(answer, contains('${PlanPolicy.defaultFreeActiveWineLimit}'));
  });

  testWidgets('R-07 another limit changes the text, not the translation', (
    tester,
  ) async {
    await pump(tester, screen: const FaqScreen(freeWineLimit: 30));
    await tester.tap(find.byKey(const Key('faq-item-5')));
    await tester.pumpAndSettle();
    expect(find.textContaining('30'), findsOneWidget);
  });

  testWidgets('FR7.3 "Didn\'t find the answer?" opens the feedback email', (
    tester,
  ) async {
    await pump(tester, locale: const Locale('en'));
    await tester.scrollUntilVisible(find.byKey(const Key('faq-feedback')), 200);
    await tester.tap(find.byKey(const Key('faq-feedback')));
    await tester.pumpAndSettle();
    expect(subjects, ['Feedback on Vinoozy']);
  });

  testWidgets('FR7.3 without an email app the address dialog shows', (
    tester,
  ) async {
    emailOpens = false;
    await pump(tester);
    await tester.scrollUntilVisible(find.byKey(const Key('faq-feedback')), 200);
    await tester.tap(find.byKey(const Key('faq-feedback')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('feedback-no-email-dialog')), findsOneWidget);
    expect(find.textContaining('support@example.com'), findsOneWidget);
    expect(find.byKey(const Key('feedback-copy-address')), findsOneWidget);
  });

  test('FR7.1 every answer is there in every language', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final entries = FaqScreen.entriesOf(lookupAppLocalizations(locale), 15);
      expect(entries, hasLength(8));
      for (final (question, answer) in entries) {
        expect(question.trim(), isNotEmpty);
        expect(answer.trim(), isNotEmpty);
      }
    }
  });
}
