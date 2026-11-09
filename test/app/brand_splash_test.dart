// Bottazzini Softworks intro at start and the studio footer of the
// Dashboard with the app version.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vinoozy/app/ui/about_screen.dart';
import 'package:vinoozy/app/ui/brand_footer.dart';
import 'package:vinoozy/app/ui/brand_splash.dart';
import 'package:vinoozy/app/vinoozy_app.dart';
import 'package:vinoozy/l10n/app_localizations.dart';

Widget _app(Widget home, {List overrides = const []}) => ProviderScope(
  overrides: [...overrides],
  child: MaterialApp(
    locale: const Locale('it'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  ),
);

const _home = Scaffold(body: Text('home', key: Key('home')));

void main() {
  group('BrandSplash', () {
    testWidgets('shows only the studio logo, then the app', (tester) async {
      await tester.pumpWidget(_app(const BrandSplash(child: _home)));
      // The app is built under the intro from the start.
      expect(find.byKey(const Key('home')), findsOneWidget);
      expect(find.byKey(const Key('brand-splash-studio')), findsOneWidget);
      // The studio logo is announced by name to the screen reader.
      final logo = tester.widget<Image>(
        find.descendant(
          of: find.byKey(const Key('brand-splash-studio')),
          matching: find.byType(Image),
        ),
      );
      expect(logo.semanticLabel, 'Bottazzini Softworks');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // No second Vinoozy logo: Android shows it in its own launch splash.
      expect(find.text('Vinoozy'), findsNothing);

      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('brand-splash')), findsNothing);
      expect(find.byKey(const Key('home')), findsOneWidget);
    });

    testWidgets('a tap before the skip delay is ignored, after it ends the '
        'intro', (tester) async {
      await tester.pumpWidget(_app(const BrandSplash(child: _home)));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.byKey(const Key('brand-splash')));
      await tester.pump();
      expect(find.byKey(const Key('brand-splash')), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.byKey(const Key('brand-splash')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('brand-splash')), findsNothing);
      expect(find.byKey(const Key('home')), findsOneWidget);
    });

    testWidgets('the app under the intro receives taps once it is gone', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        _app(
          BrandSplash(
            duration: const Duration(milliseconds: 600),
            child: Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => taps++,
                  child: const Text('go'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('go'), warnIfMissed: false);
      expect(taps, 0);
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();
      await tester.tap(find.text('go'));
      expect(taps, 1);
    });

    testWidgets('disposing during the intro cancels its timers', (
      tester,
    ) async {
      await tester.pumpWidget(_app(const BrandSplash(child: _home)));
      await tester.pumpWidget(_app(_home));
      await tester.pump(const Duration(seconds: 3));
      expect(find.byKey(const Key('home')), findsOneWidget);
    });
  });

  group('VinoozyApp', () {
    testWidgets('shows the intro only when asked', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: VinoozyApp(home: _home)),
      );
      expect(find.byType(BrandSplash), findsNothing);

      await tester.pumpWidget(
        const ProviderScope(
          child: VinoozyApp(home: _home, showBrandSplash: true),
        ),
      );
      expect(find.byType(BrandSplash), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });
  });

  group('BrandFooter', () {
    testWidgets('shows the studio and the version with the build number', (
      tester,
    ) async {
      PackageInfo.setMockInitialValues(
        appName: 'Vinoozy',
        packageName: 'com.vinoozy.vinoozy',
        version: '0.1.0',
        buildNumber: '12',
        buildSignature: '',
      );
      await tester.pumpWidget(
        _app(const Scaffold(body: SingleChildScrollView(child: BrandFooter()))),
      );
      await tester.pumpAndSettle();
      expect(find.text('Bottazzini Softworks'), findsOneWidget);
      expect(find.text('Versione 0.1.0 (12)'), findsOneWidget);
    });

    testWidgets('without a build number only the version name', (tester) async {
      PackageInfo.setMockInitialValues(
        appName: 'Vinoozy',
        packageName: 'com.vinoozy.vinoozy',
        version: '0.2.0',
        buildNumber: '',
        buildSignature: '',
      );
      await tester.pumpWidget(
        _app(const Scaffold(body: SingleChildScrollView(child: BrandFooter()))),
      );
      await tester.pumpAndSettle();
      expect(find.text('Versione 0.2.0'), findsOneWidget);
    });

    testWidgets('without the version it shows only the studio', (tester) async {
      await tester.pumpWidget(
        _app(
          const Scaffold(body: SingleChildScrollView(child: BrandFooter())),
          overrides: [appVersionLabelProvider.overrideWith((ref) => null)],
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Bottazzini Softworks'), findsOneWidget);
      expect(find.byKey(const Key('brand-footer-version')), findsNothing);
    });

    testWidgets('a tap opens "Informazioni"', (tester) async {
      await tester.pumpWidget(
        _app(
          const Scaffold(body: SingleChildScrollView(child: BrandFooter())),
          overrides: [appVersionLabelProvider.overrideWith((ref) => '0.1.0')],
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('brand-footer')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(AboutScreen), findsOneWidget);
    });
  });
}
