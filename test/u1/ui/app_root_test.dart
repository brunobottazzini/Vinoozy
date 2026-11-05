import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/app/locale_resolution.dart';
import 'package:vinoozy/app/providers.dart';
import 'package:vinoozy/app/theme.dart';
import 'package:vinoozy/app/vinoozy_app.dart';
import 'package:vinoozy/main.dart';
import 'package:vinoozy/sync/sync_error_bus.dart';

import '../../helpers/ui_harness.dart';

void main() {
  group('language (BR5.1)', () {
    test('it, en and pt-BR are used as set on the phone', () {
      expect(resolveAppLocale([const Locale('it', 'IT')]), const Locale('it'));
      expect(resolveAppLocale([const Locale('en', 'US')]), const Locale('en'));
      expect(
        resolveAppLocale([const Locale('pt', 'BR')]),
        const Locale('pt', 'BR'),
      );
    });

    test('other languages and Portuguese of Portugal fall back to English', () {
      expect(resolveAppLocale([const Locale('de')]), const Locale('en'));
      expect(resolveAppLocale([const Locale('pt', 'PT')]), const Locale('en'));
      expect(resolveAppLocale(null), const Locale('en'));
    });

    test('the first supported language in the phone order wins', () {
      expect(
        resolveAppLocale([const Locale('fr'), const Locale('it')]),
        const Locale('it'),
      );
    });
  });

  group('theme (BR5.2, NFR3.1)', () {
    test('light and dark use the bordeaux tokens', () {
      final light = buildAppTheme(Brightness.light).colorScheme;
      final dark = buildAppTheme(Brightness.dark).colorScheme;

      expect(light.primary, AppColors.lightPrimary);
      expect(light.surface, AppColors.lightSurface);
      expect(dark.primary, AppColors.darkPrimary);
      expect(dark.onSurface, AppColors.darkOnSurface);
    });

    testWidgets('VinoozyApp follows the system theme and language', (
      tester,
    ) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      tester.platformDispatcher.localesTestValue = const [Locale('it')];
      addTearDown(tester.platformDispatcher.clearAllTestValues);

      await tester.pumpWidget(
        ProviderScope(
          child: VinoozyApp(
            home: Builder(
              builder: (context) => Text(
                Theme.of(context).brightness.name,
                key: const Key('probe'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('dark'), findsOneWidget);
      final context = tester.element(find.byKey(const Key('probe')));
      expect(Localizations.localeOf(context), const Locale('it'));
    });
  });

  group('root sync listener (NFR6.2)', () {
    late SyncErrorBus bus;

    setUp(() => bus = SyncErrorBus());

    Future<void> pump(WidgetTester tester) => pumpScreen(
      tester,
      const Scaffold(body: SizedBox.expand()),
      overrides: [syncErrorBusProvider.overrideWithValue(bus)],
    );

    testWidgets('a rejection shows "Modifica non consentita: <name>"', (
      tester,
    ) async {
      await pump(tester);

      bus.publish(const WriteRejected(wineId: 'w1', wineName: 'Barolo'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Modifica non consentita: Barolo'), findsOneWidget);
    });

    testWidgets('a transient failure shows "Impossibile salvare, riprova"', (
      tester,
    ) async {
      await pump(tester);

      bus.publish(const WriteFailed(wineId: 'w1'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Impossibile salvare, riprova'), findsOneWidget);
    });

    testWidgets('an expired session shows no message here', (tester) async {
      await pump(tester);

      bus.publish(const SessionExpired());
      await tester.pump();
      await tester.pump();

      expect(find.byKey(const Key('sync-event-snackbar')), findsNothing);
    });
  });

  testWidgets('the start-up error screen offers "Riprova"', (tester) async {
    tester.platformDispatcher.localesTestValue = const [Locale('it')];
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    var retries = 0;

    await tester.pumpWidget(StartupErrorApp(onRetry: () => retries++));
    await tester.pump();

    expect(find.text("Impossibile avviare l'app"), findsOneWidget);
    // The real app theme uses InkSparkle, whose shader the test backend
    // lacks: press the button through its callback instead of a tap.
    tester
        .widget<ButtonStyleButton>(
          find.byKey(const Key('gate-error-retry-button')),
        )
        .onPressed!();
    expect(retries, 1);
  });
}
