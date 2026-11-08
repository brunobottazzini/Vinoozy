// The offline database of the end-to-end tests
// (integration_test/support/e2e_wine_db.dart): its rows are still lines of
// tool/fixtures/off_wines_sample.csv, and the loader opens it with the wine
// the label e2e paints on the back.
import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/catalog/core/catalog_event_logger.dart';
import 'package:vinoozy/catalog/platform/wine_db_loader.dart';

import '../../integration_test/support/e2e_wine_db.dart';

void main() {
  test('every e2e row is a line of the fixture, the header first', () {
    final fixture = File('tool/fixtures/off_wines_sample.csv')
        .readAsLinesSync();
    expect(e2eWineDbRows.first, fixture.first);
    for (final row in e2eWineDbRows) {
      expect(fixture, contains(row));
    }
  });

  test('the loader opens the e2e database as the sample, with the back '
      'label wine', () async {
    final loader = WineDbLoader(
      logger: const ConsoleCatalogEventLogger(debugLogging: false),
      readAsset: readE2eWineDbAsset,
      runInBackground: <R>(FutureOr<R> Function() work) async => work(),
    );
    final db = (await loader.open()) as WineDbReady;
    expect(db.db.wineCount, e2eWineDbRows.length - 1);
    expect(db.db.skippedRows, 0);
    expect(loader.isSample, isTrue);
    expect(db.db.index.byBarcode(e2eBackBarcode)?.name, e2eBackWineName);
  });

  test('any other asset key fails like a missing asset', () async {
    await expectLater(readE2eWineDbAsset('assets/other'), throwsStateError);
  });
}
