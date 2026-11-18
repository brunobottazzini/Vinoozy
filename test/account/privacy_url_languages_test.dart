import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/account/account_gate.dart';
import 'package:vinoozy/account/account_providers.dart';
import 'package:vinoozy/account/ui/profile_screen.dart';
import 'package:vinoozy/app/external_links.dart';
import 'package:vinoozy/app/locale_resolution.dart';
import 'package:vinoozy/app/providers.dart';

import '../helpers/ui_harness.dart';
import 'account_harness.dart';

class _MockGate extends Mock implements AccountGate {}

// The privacy notice opened from the profile, by interface language
// (wine-culture-languages FR5.1).
void main() {
  const base = defaultPrivacyPolicyUrl;

  group('address by language (FR5.1)', () {
    test('Italian opens the base page', () {
      expect(privacyPolicyUrlFor('it'), base);
      expect(privacyPolicyUrlFor('it-IT'), base);
    });

    test('English opens the English page', () {
      expect(privacyPolicyUrlFor('en'), '${base}en/');
    });

    test('Brazilian Portuguese opens its own page', () {
      expect(privacyPolicyUrlFor('pt-BR'), '${base}pt-BR/');
      expect(privacyPolicyUrlFor('pt_BR'), '${base}pt-BR/');
    });

    test('a new language opens the English page', () {
      expect(privacyPolicyUrlFor('fr'), '${base}en/');
      expect(privacyPolicyUrlFor('el'), '${base}en/');
      // European Portuguese has no page of its own.
      expect(privacyPolicyUrlFor('pt'), '${base}en/');
      expect(privacyPolicyUrlFor('pt-PT'), '${base}en/');
    });

    test('an unknown or empty tag opens the English page', () {
      expect(privacyPolicyUrlFor(''), '${base}en/');
      expect(privacyPolicyUrlFor('zz-ZZ'), '${base}en/');
    });

    test('every interface language has an address under the base page', () {
      for (final locale in appLocales) {
        final url = privacyPolicyUrlFor(locale.toLanguageTag());
        expect(url, startsWith(base), reason: locale.toLanguageTag());
        expect(Uri.parse(url).scheme, 'https');
      }
    });

    test('an address configured at build time is used as it is', () {
      const configured = 'https://example.org/privacy.html';
      for (final tag in ['it', 'en', 'pt-BR', 'fr', 'ka']) {
        expect(privacyPolicyUrlFor(tag, configured: configured), configured);
      }
    });

    test('the provider gives the address of the language', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(privacyPolicyUrlProvider('it')), base);
      expect(container.read(privacyPolicyUrlProvider('de')), '${base}en/');
    });
  });

  group('profile link (FR5.1)', () {
    Future<String?> openedIn(WidgetTester tester, Locale locale) async {
      final gate = _MockGate();
      final state = ValueNotifier<GateState>(const GateCellar(mario));
      addTearDown(state.dispose);
      when(() => gate.state).thenReturn(state);
      when(() => gate.current).thenAnswer((_) => state.value);
      when(() => gate.pendingChanges()).thenAnswer((_) async => 0);
      String? opened;
      await pumpScreen(
        tester,
        const ProfileScreen(user: mario),
        locale: locale,
        overrides: [
          accountGateProvider.overrideWithValue(gate),
          authServiceProvider.overrideWithValue(
            FakeAuthService(currentUser: mario),
          ),
          networkStatusProvider.overrideWithValue(FakeNetworkStatus()),
          externalLinkOpenerProvider.overrideWithValue((url) async {
            opened = url;
            return true;
          }),
        ],
      );
      await tester.tap(find.byKey(const Key('profile-privacy')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('privacy-open')));
      await tester.pumpAndSettle();
      return opened;
    }

    testWidgets('Italian opens the Italian notice', (tester) async {
      expect(await openedIn(tester, const Locale('it')), base);
    });

    testWidgets('Brazilian Portuguese opens its notice', (tester) async {
      expect(await openedIn(tester, const Locale('pt', 'BR')), '${base}pt-BR/');
    });

    testWidgets('English opens the English notice', (tester) async {
      expect(await openedIn(tester, const Locale('en')), '${base}en/');
    });
  });
}
