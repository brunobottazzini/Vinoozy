// AboutScreen, "Informazioni" (label-recognition BR6.3, FR2.2, FR2.5,
// NFR6.7, TS5): version, number of wines and export date of the offline
// database, the ODbL/DbCL licences and the photo note in the three
// languages; unavailable and loading database; the accessibility matrix.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/app/ui/about_screen.dart';
import 'package:vinoozy/catalog/core/catalog_event_logger.dart';
import 'package:vinoozy/catalog/core/offline/wine_db_index.dart';
import 'package:vinoozy/catalog/core/offline/wine_db_record.dart';
import 'package:vinoozy/catalog/platform/catalog_providers.dart';
import 'package:vinoozy/catalog/platform/wine_db_loader.dart';
import 'package:vinoozy/l10n/app_localizations.dart';

import '../helpers/ui_harness.dart';

final _db = OfflineWineDb(
  manifest: WineDbManifest(exportDate: DateTime.utc(2026, 11, 7), wineCount: 2),
  index: WineDbIndex.build(const [
    WineDbRecord(code: '8001234567897', name: 'Barolo Ravera'),
    WineDbRecord(code: '96385074', name: 'Lagrein Alto Adige'),
  ]),
);

void main() {
  Future<void> pump(
    WidgetTester tester, {
    Locale locale = const Locale('it'),
    Future<WineDbLoadResult>? result,
  }) => pumpScreen(
    tester,
    const AboutScreen(),
    locale: locale,
    overrides: [
      catalogAppVersionProvider.overrideWith((ref) async => '0.2.0'),
      wineDbStatusProvider.overrideWith(
        (ref) => result ?? Future.value(WineDbReady(_db)),
      ),
    ],
  );

  for (final locale in testLocales) {
    testWidgets('NFR6.7 FR2.2 number of wines, export date, licences and the '
        'photo note (${locale.toLanguageTag()})', (tester) async {
      final l10n = lookupAppLocalizations(locale);
      await pump(tester, locale: locale);
      await tester.pumpAndSettle();
      expect(find.text(l10n.aboutTitle), findsOneWidget);
      expect(find.text(l10n.aboutVersion('0.2.0')), findsOneWidget);
      expect(find.text(l10n.aboutDbCount(2)), findsOneWidget);
      expect(find.textContaining('2026'), findsOneWidget);
      expect(find.textContaining('7'), findsWidgets);
      expect(find.text(l10n.aboutLicense), findsOneWidget);
      expect(l10n.aboutLicense, contains('ODbL'));
      expect(l10n.aboutLicense, contains('DbCL'));
      expect(
        find.text(l10n.aboutDbSource(AboutScreen.repositoryUrl)),
        findsOneWidget,
      );
      await tester.scrollUntilVisible(
        find.text(l10n.aboutPrivacy),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text(l10n.aboutPrivacy), findsOneWidget);
    });
  }

  for (final locale in testLocales) {
    testWidgets('review R-02 the sample database says it is a sample, '
        'without an Open Food Facts export date '
        '(${locale.toLanguageTag()})', (tester) async {
      final l10n = lookupAppLocalizations(locale);
      final sample = OfflineWineDb(
        manifest: WineDbManifest(
          exportDate: DateTime.utc(2026, 11, 7),
          wineCount: 2,
          source: WineDbSource.sample,
        ),
        index: _db.index,
      );
      await pump(
        tester,
        locale: locale,
        result: Future.value(WineDbReady(sample)),
      );
      await tester.pumpAndSettle();
      expect(find.text(l10n.aboutDbCount(2)), findsOneWidget);
      expect(find.text(l10n.aboutDbSample), findsOneWidget);
      expect(find.textContaining('2026'), findsNothing);
    });
  }

  test('review R-02 the sample note is translated in each language', () {
    final notes = {
      for (final locale in testLocales)
        lookupAppLocalizations(locale).aboutDbSample,
    };
    expect(notes, hasLength(testLocales.length));
  });

  accessibilityMatrix(
    'AboutScreen sample',
    () => const AboutScreen(),
    overrides: () => [
      catalogAppVersionProvider.overrideWith((ref) async => '0.2.0'),
      wineDbStatusProvider.overrideWith(
        (ref) async => WineDbReady(
          OfflineWineDb(
            manifest: WineDbManifest(
              exportDate: DateTime.utc(2026, 11, 7),
              wineCount: 2,
              source: WineDbSource.sample,
            ),
            index: _db.index,
          ),
        ),
      ),
    ],
  );

  testWidgets('NFR4.5 an unavailable database says so', (tester) async {
    final l10n = lookupAppLocalizations(const Locale('it'));
    await pump(
      tester,
      result: Future.value(const WineDbUnavailable(WineDbFailure.missing)),
    );
    await tester.pumpAndSettle();
    expect(find.text(l10n.aboutDbUnavailable), findsOneWidget);
  });

  testWidgets('the database still opening shows a waiting line', (
    tester,
  ) async {
    final l10n = lookupAppLocalizations(const Locale('it'));
    final opening = Completer<WineDbLoadResult>();
    await pump(tester, result: opening.future);
    expect(find.text(l10n.aboutDbLoading), findsOneWidget);
    opening.complete(WineDbReady(_db));
    await tester.pumpAndSettle();
    expect(find.text(l10n.aboutDbCount(2)), findsOneWidget);
  });

  testWidgets('open() pushes the screen', (tester) async {
    await pumpScreen(
      tester,
      Builder(
        builder: (context) => TextButton(
          key: const Key('open-about'),
          onPressed: () => AboutScreen.open(context),
          child: const Text('open'),
        ),
      ),
      overrides: [
        catalogAppVersionProvider.overrideWith((ref) async => '0.2.0'),
        wineDbStatusProvider.overrideWith((ref) async => WineDbReady(_db)),
      ],
    );
    await tester.tap(find.byKey(const Key('open-about')));
    await tester.pumpAndSettle();
    expect(find.byType(AboutScreen), findsOneWidget);
  });

  accessibilityMatrix(
    'AboutScreen',
    () => const AboutScreen(),
    overrides: () => [
      catalogAppVersionProvider.overrideWith((ref) async => '0.2.0'),
      wineDbStatusProvider.overrideWith((ref) async => WineDbReady(_db)),
    ],
  );
}
