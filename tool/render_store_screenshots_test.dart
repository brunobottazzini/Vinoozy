// Render the current Flutter Android screens with fictional cellar data.
// Explicit authoring tool, outside test/ and integration_test/ so CI does
// not generate store assets during ordinary tests. Never uses Firebase.
// flutter test tool/render_store_screenshots_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:estimation/estimation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vinoozy/app/home_shell.dart';
import 'package:vinoozy/app/theme.dart';
import 'package:vinoozy/app/vinoozy_app.dart';
import 'package:vinoozy/cellar/data/drinking_record_repository.dart';
import 'package:vinoozy/cellar/domain/wine.dart';
import 'package:vinoozy/cellar/ui/cellar_screen.dart';
import 'package:vinoozy/l10n/app_localizations.dart';

import '../test/cellar/cellar_harness.dart';
import '../test/cellar/ui/cellar_ui_harness.dart';

extension on ThemeData {
  ThemeData applyScreenshotFontFallback() => copyWith(
    textTheme: textTheme.apply(fontFamilyFallback: const ['Symbols', 'Emoji']),
    primaryTextTheme: primaryTextTheme.apply(
      fontFamilyFallback: const ['Symbols', 'Emoji'],
    ),
  );
}

Wine sample(
  String id,
  String name,
  int vintage,
  int quantity,
  String country,
  String region,
) {
  final pre = classifyWine(name);
  final facts = WineFacts(
    name: name,
    vintage: vintage,
    wineType: pre.wineType,
    style: pre.style,
    level: pre.level,
    referenceYear: 2026,
    region: region,
  );
  return Wine(
    id: id,
    name: name,
    vintage: vintage,
    storedQuantity: quantity,
    producer: 'Cantina Esempio',
    wineType: pre.wineType?.name,
    country: country,
    region: region,
    style: pre.style,
    level: pre.level,
    typeSource: FieldSource.auto,
    styleSource: FieldSource.auto,
    levelSource: FieldSource.auto,
    migrationVersion: estimationTablesVersion,
    window: estimateWindow(facts),
    baseWindow: estimateWindow(facts),
    pairings: pairingsFor(facts),
    createdAt: DateTime(2026, 11, 1),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final flutterRoot =
        Platform.environment['FLUTTER_ROOT'] ?? '/opt/homebrew/share/flutter';
    final fonts = '$flutterRoot/bin/cache/artifacts/material_fonts';
    for (final face in ['Regular', 'Medium', 'Bold', 'Italic']) {
      await ui.loadFontFromList(
        await File('$fonts/Roboto-$face.ttf').readAsBytes(),
        fontFamily: 'Roboto',
      );
    }
    await ui.loadFontFromList(
      await File('$fonts/MaterialIcons-Regular.otf').readAsBytes(),
      fontFamily: 'MaterialIcons',
    );
    for (final face in ['Regular', 'Bold']) {
      await ui.loadFontFromList(
        await File('/tmp/vinoozy-NotoSerif-$face.ttf').readAsBytes(),
        fontFamily: 'serif',
      );
    }
    await ui.loadFontFromList(
      await File('/System/Library/Fonts/Apple Color Emoji.ttc').readAsBytes(),
      fontFamily: 'Emoji',
    );
    await ui.loadFontFromList(
      await File('/System/Library/Fonts/Apple Symbols.ttf').readAsBytes(),
      fontFamily: 'Symbols',
    );
  });
  for (final locale in [
    const Locale('it'),
    const Locale('en'),
    const Locale('pt', 'BR'),
  ]) {
    testWidgets('render store screens ${locale.toLanguageTag()}', (
      tester,
    ) async {
      debugDisableShadows = false;
      tester.view
        ..physicalSize = const Size(1080, 1920)
        ..devicePixelRatio = 2.625;
      addTearDown(tester.view.reset);
      // This explicit authoring command runs with `flutter test`.
      // ignore: invalid_use_of_visible_for_testing_member
      PackageInfo.setMockInitialValues(
        appName: 'Vinoozy',
        packageName: 'com.vinoozy.app',
        version: '0.1.0',
        buildNumber: '1',
        buildSignature: '',
      );
      final state = CellarUi();
      final notes = switch (locale.languageCode) {
        'en' => [
          'Red fruit and spices, a balanced finish.',
          'Fresh, with a pleasant mineral note.',
          'Complex aromas and elegant tannins.',
        ],
        'pt' => [
          'Frutas vermelhas e especiarias, final equilibrado.',
          'Fresco, com uma agradável nota mineral.',
          'Aromas complexos e taninos elegantes.',
        ],
        _ => [
          'Frutti rossi e spezie, finale equilibrato.',
          'Fresco, con una piacevole nota minerale.',
          'Profumi complessi, tannini eleganti.',
        ],
      };
      final wines = [
        sample('w1', 'Barolo DOCG', 2016, 3, 'IT', 'Piemonte'),
        sample('w2', 'Brunello di Montalcino', 2018, 2, 'IT', 'Toscana'),
        sample(
          'w3',
          "Verdicchio dei Castelli di Jesi",
          2024,
          4,
          'IT',
          'Marche',
        ),
        sample('w4', 'Chianti Classico', 2021, 2, 'IT', 'Toscana'),
        sample('w5', 'Champagne Brut', 2020, 2, 'FR', 'Champagne'),
        sample('w6', 'Porto Vintage', 2017, 1, 'PT', 'Douro'),
      ];
      final records = [
        drinkRecord(
          'r1',
          wineId: 'w4',
          wineName: 'Chianti Classico',
          vintage: 2021,
          drankOn: DateTime(2026, 11, 5),
          rating: 4,
          notes: notes[0],
        ),
        drinkRecord(
          'r2',
          wineId: 'w3',
          wineName: 'Verdicchio dei Castelli di Jesi',
          vintage: 2024,
          drankOn: DateTime(2026, 10, 24),
          rating: 4,
          notes: notes[1],
        ),
        drinkRecord(
          'r3',
          wineId: 'w1',
          wineName: 'Barolo DOCG',
          vintage: 2016,
          drankOn: DateTime(2026, 10, 12),
          rating: 5,
          notes: notes[2],
        ),
      ];
      state.drinks = records;
      when(
        () => state.records.pageHistory(
          any(),
          after: any(named: 'after'),
          limit: 30,
        ),
      ).thenAnswer(
        (_) async =>
            HistoryPage(records: records, cursor: null, hasMore: false),
      );
      for (final wine in wines) {
        when(() => state.wines.watchWine('user-a', wine.id))
            .thenAnswer((_) => Stream.value(wine));
      }
      final boundaryKey = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundaryKey,
          child: ProviderScope(
            overrides: state.overrides,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              locale: locale,
              theme: buildAppTheme(Brightness.light)
                  .copyWith(
                    platform: TargetPlatform.android,
                    splashFactory: InkRipple.splashFactory,
                  )
                  .applyScreenshotFontFallback(),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: const [
                Locale('it'),
                Locale('en'),
                Locale('pt', 'BR'),
              ],
              home: SyncEventListener(
                child: HomeShell(
                  user: cellarOwner,
                  setup: CellarSetup.ready,
                  onRetrySetup: () async {},
                ),
              ),
            ),
          ),
        ),
      );
      state
        ..emitCellar()
        ..emitWines(wines);
      await tester.pumpAndSettle();
      Future<void> capture(String name) async {
        await tester.pumpAndSettle();
        await tester.runAsync(() async {
          final boundary =
              boundaryKey.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: 2.625);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final folder = Directory(
            'distribution/google-play/assets/screenshots/${locale.toLanguageTag()}',
          );
          await folder.create(recursive: true);
          await File('${folder.path}/$name.png')
              .writeAsBytes(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }

      await capture('02-cruscotto');
      await tester.tap(find.byKey(const Key('home-nav-cellar')));
      await tester.pumpAndSettle();
      await capture('01-cantina');
      await tester.tap(find.byKey(const ValueKey('w1')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('wine-detail')), findsOneWidget);
      await capture('03-dettaglio');
      Navigator.of(tester.element(find.byKey(const Key('wine-detail')))).pop();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('home-nav-history')));
      await tester.pumpAndSettle();
      await capture('04-storico');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await state.cellar.close();
      await state.winesStream.close();
      debugDisableShadows = true;
    });
  }
}
