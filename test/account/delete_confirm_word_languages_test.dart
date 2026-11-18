import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/account/account_gate.dart';
import 'package:vinoozy/account/ui/delete_account_screen.dart';
import 'package:vinoozy/app/providers.dart';
import 'package:vinoozy/l10n/app_localizations.dart';

import '../helpers/ui_harness.dart';
import 'account_harness.dart';

class _MockGate extends Mock implements AccountGate {}

// The confirmation word of the account deletion in the new interface
// languages (u8-account BR1.6, wine-culture-languages FR1.2): typed with or
// without diacritics and in any case, it enables "Delete forever"; another
// word does not.
void main() {
  Future<void> pumpDelete(WidgetTester tester, Locale locale) async {
    final gate = _MockGate();
    final state = ValueNotifier<GateState>(const GateCellar(mario));
    addTearDown(state.dispose);
    when(() => gate.state).thenReturn(state);
    when(() => gate.current).thenAnswer((_) => state.value);
    when(() => gate.pendingChanges()).thenAnswer((_) async => 0);
    await pumpScreen(
      tester,
      const DeleteAccountScreen(user: mario),
      locale: locale,
      overrides: [
        accountGateProvider.overrideWithValue(gate),
        authServiceProvider.overrideWithValue(
          FakeAuthService(currentUser: mario),
        ),
        networkStatusProvider.overrideWithValue(FakeNetworkStatus()),
      ],
    );
    await tester.pumpAndSettle();
  }

  Future<bool> enabledWith(WidgetTester tester, String typed) async {
    await tester.enterText(find.byKey(const Key('delete-confirm-word')), typed);
    await tester.pump();
    final button = find.byKey(const Key('delete-forever'));
    return tester.widget<FilledButton>(button).onPressed != null;
  }

  // Language, the word of the ARB file, the same word as typed by a person
  // without diacritics (or in another case).
  for (final (locale, word, typed) in [
    (const Locale('ro'), 'ȘTERGE', 'sterge'),
    (const Locale('de'), 'LÖSCHEN', 'loschen'),
    (const Locale('hu'), 'TÖRLÉS', 'Torles'),
    (const Locale('pl'), 'USUŃ', 'usun'),
    (const Locale('sk'), 'ODSTRÁNIŤ', 'odstranit'),
    (const Locale('el'), 'ΔΙΑΓΡΑΦΗ', 'διαγραφή'),
    (const Locale('ka'), 'წაშლა', ' წაშლა '),
  ]) {
    final tag = locale.toLanguageTag();
    testWidgets('$tag: the word of the language is $word', (tester) async {
      await pumpDelete(tester, locale);
      expect(lookupAppLocalizations(locale).deleteAccountConfirmWord, word);
    });

    testWidgets('$tag: "$word" as written enables the deletion', (
      tester,
    ) async {
      await pumpDelete(tester, locale);
      expect(await enabledWith(tester, word), isTrue);
    });

    testWidgets('$tag: "$typed" without accents or case enables it', (
      tester,
    ) async {
      await pumpDelete(tester, locale);
      expect(await enabledWith(tester, typed), isTrue);
    });

    testWidgets('$tag: another word keeps it disabled', (tester) async {
      await pumpDelete(tester, locale);
      final button = find.byKey(const Key('delete-forever'));
      expect(tester.widget<FilledButton>(button).onPressed, isNull);
      expect(await enabledWith(tester, 'DELETE'), isFalse);
      expect(await enabledWith(tester, '${typed}x'), isFalse);
      expect(await enabledWith(tester, '   '), isFalse);
    });
  }

  test('every language has a confirmation word that is not blank', () {
    for (final locale in AppLocalizations.supportedLocales) {
      final word = lookupAppLocalizations(locale).deleteAccountConfirmWord;
      expect(word.trim(), isNotEmpty, reason: locale.toLanguageTag());
    }
  });
}
