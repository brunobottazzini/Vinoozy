// The offline wine database of the end-to-end tests (label-recognition
// NFR4.3): a few rows copied verbatim from tool/fixtures/off_wines_sample.csv,
// turned into `wines.jsonl.gz` and `manifest.json` by the same code as
// tool/build_wine_db.dart, and handed to WineDbLoader in place of the
// assets.
//
// The e2e never reads the database shipped in assets/wine_db/: that is the
// real Open Food Facts export, rebuilt at every release, so a barcode or a
// name taken from it would make the tests depend on its content. The
// fixture file itself is not on the phone, hence the copied rows;
// test/tool/e2e_wine_db_test.dart checks that each of them is still a line
// of the fixture.
import 'dart:convert';
import 'dart:typed_data';

import 'package:vinoozy/catalog/core/catalog_event_logger.dart';
import 'package:vinoozy/catalog/core/offline/wine_db_record.dart';
import 'package:vinoozy/catalog/platform/wine_db_loader.dart';

import '../../tool/build_wine_db.dart' show ExportReader, encodeWineDb;

/// The barcode painted on the back label, and the wine it names.
const String e2eBackBarcode = '8001234567897';
const String e2eBackWineName = 'Barolo Ravera 2016';

/// The header and the wine rows of the fixture used by the e2e tests
/// (tab-separated, as in the Open Food Facts export).
const List<String> e2eWineDbRows = [
  'code\tproduct_name\tbrands\tcategories_tags\tlabels_tags\tcountries_tags'
      '\tquantity\tcreator\tcreated_t',
  '8001234567897\tBarolo Ravera 2016\tElvio Cogno\ten:beverages,'
      'en:alcoholic-beverages,en:wines,en:red-wines,en:italian-wines\ten:pdo'
      '\ten:italy\t750 ml\tcontributor-sample\t1700000000',
  '8001234500016\tBarbaresco Asili 2019\tProduttori del Barbaresco'
      '\ten:beverages,en:alcoholic-beverages,en:wines,en:red-wines\ten:pdo'
      '\ten:italy\t750 ml\tcontributor-sample\t1700000000',
  '8001234500023\tChianti Classico Riserva\tCastello di Ama\ten:beverages,'
      'en:wines,en:red-wines\ten:pdo\ten:italy,en:france\t0.75 l'
      '\tcontributor-sample\t1700000000',
  '8001234500030\tBrunello di Montalcino 2017\tBiondi-Santi\ten:beverages,'
      'en:wines,en:red-wines\t\ten:italy\t750 ml\tcontributor-sample'
      '\t1700000000',
];

/// The two asset files of [e2eWineDbRows], built once.
final Map<String, Uint8List> _assets = () {
  final reader = ExportReader();
  e2eWineDbRows.forEach(reader.addLine);
  final encoded = encodeWineDb(
    reader.records,
    DateTime.utc(2026, 11, 7),
    // Invented rows: never attributed to Open Food Facts (review R-02).
    source: WineDbSource.sample,
  );
  return {
    wineDbAsset: Uint8List.fromList(encoded.compressed),
    wineDbManifestAsset: Uint8List.fromList(
      utf8.encode(jsonEncode(encoded.manifest.toJson())),
    ),
  };
}();

/// Reads the e2e database in place of `rootBundle`; any other key fails as
/// a missing asset would.
Future<Uint8List> readE2eWineDbAsset(String key) async {
  final bytes = _assets[key];
  if (bytes == null) throw StateError('No e2e asset $key');
  return bytes;
}

/// A loader of the e2e database, opened in a background isolate like the
/// app's one.
WineDbLoader e2eWineDbLoader(CatalogEventLogger logger) =>
    WineDbLoader(logger: logger, readAsset: readE2eWineDbAsset);
