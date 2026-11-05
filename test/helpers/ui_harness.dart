import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/app/theme.dart';
import 'package:vinoozy/app/vinoozy_app.dart';
import 'package:vinoozy/l10n/app_localizations.dart';

/// The three interface languages (BR5.1).
const List<Locale> testLocales = [
  Locale('it'),
  Locale('en'),
  Locale('pt', 'BR'),
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
        supportedLocales: const [
          Locale('en'),
          Locale('it'),
          Locale('pt', 'BR'),
        ],
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

/// For every language and text scale 1.0 / 2.0, in light and dark theme:
/// no overflow (a RenderFlex overflow fails the test, NFR3.4) and the
/// contrast, tap-target and label guidelines (NFR3.1-NFR3.3).
void accessibilityMatrix(
  String screenName,
  Widget Function() build, {
  List<Override> Function()? overrides,
  Future<void> Function(WidgetTester tester)? afterPump,
}) {
  for (final locale in testLocales) {
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
