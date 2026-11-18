import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/app/locale_resolution.dart';
import 'package:vinoozy/app/theme.dart';
import 'package:vinoozy/app/vinoozy_app.dart';
import 'package:vinoozy/l10n/app_localizations.dart';

/// The three languages of the tests whose expected texts are written per
/// language (BR5.1): Italian, English and Brazilian Portuguese.
const List<Locale> testLocales = [
  Locale('it'),
  Locale('en'),
  Locale('pt', 'BR'),
];

/// The interface language with the longest texts among those that are not
/// already in [matrixLocales] for another reason (wine-culture-languages
/// NFR3), measured as the total length in characters of the texts in the
/// ARB files: Dutch. `test/l10n/languages_test.dart` measures the ARB files
/// and fails when another language becomes longer: change this constant
/// then.
const Locale longestTextLocale = Locale('nl');

/// The ten languages of the complete check of the main screens (NFR3): the
/// three of [testLocales], French, Spanish and German, one language for each
/// other script (Greek, Cyrillic with Ukrainian, Georgian) and
/// [longestTextLocale].
const List<Locale> matrixLocales = [
  ...testLocales,
  Locale('fr'),
  Locale('es'),
  Locale('de'),
  Locale('el'),
  Locale('uk'),
  Locale('ka'),
  longestTextLocale,
];

/// Pumps [screen] like the app does (theme, translations, root sync
/// listener), with a fixed [locale], text scale and phone-sized surface.
Future<void> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  Locale locale = const Locale('it'),
  double textScale = 1.0,
  Brightness brightness = Brightness.light,
  List<Override> overrides = const [],
}) async {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        locale: locale,
        // The test backend has no shader for InkSparkle (the Android M3
        // default); InkRipple keeps taps working. Colors are unchanged.
        theme: buildAppTheme(brightness)
            .copyWith(splashFactory: InkRipple.splashFactory),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: appLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: SyncEventListener(child: screen),
      ),
    ),
  );
  await tester.pump();
}

/// For every language of [matrixLocales] and text scale 1.0 / 2.0, in light
/// and dark theme: no overflow (a RenderFlex overflow fails the test,
/// NFR3.4) and the contrast, tap-target and label guidelines (NFR3.1-NFR3.3).
void accessibilityMatrix(
  String screenName,
  Widget Function() build, {
  List<Override> Function()? overrides,
  Future<void> Function(WidgetTester tester)? afterPump,
}) {
  for (final locale in matrixLocales) {
    for (final scale in [1.0, 2.0]) {
      for (final brightness in Brightness.values) {
        testWidgets('$screenName meets the a11y guidelines '
            '(${locale.toLanguageTag()}, text x$scale, ${brightness.name})', (
          tester,
        ) async {
          final handle = tester.ensureSemantics();
          await pumpScreen(
            tester,
            build(),
            locale: locale,
            textScale: scale,
            brightness: brightness,
            overrides: overrides?.call() ?? const [],
          );
          await afterPump?.call(tester);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await expectLater(tester, meetsGuideline(textContrastGuideline));
          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          handle.dispose();
        });
      }
    }
  }
}
