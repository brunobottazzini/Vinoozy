// Synthetic wines for the Dashboard tests (unit-test-instructions.md of
// u5-dashboard): realistic wine names, fictitious users, no personal data.
import 'package:estimation/estimation.dart';
import 'package:vinoozy/account/app_user.dart';
import 'package:vinoozy/cellar/data/wine_repository.dart';
import 'package:vinoozy/cellar/domain/wine.dart';
import 'package:vinoozy/sync/snapshot_meta.dart';

const dashboardUser = AppUser(
  uid: 'user-a',
  email: 'user-a@example.com',
  displayName: 'A',
);

const fromServer = SnapshotMeta(hasPendingWrites: false, isFromCache: false);
const fromCache = SnapshotMeta(hasPendingWrites: false, isFromCache: true);

/// A window as U4 stores it, already converted by the `Wine` mapper.
DrinkingWindow window(int start, int peak, int end) => DrinkingWindow(
  startYear: start,
  peakYear: peak,
  endYear: end,
  confidence: Confidence.medium,
  source: WindowSource.internalRules,
  basis: EstimationBasis.denomination,
);

/// A wine built with the real [Wine] constructor, so a change of its shape
/// breaks the fixtures too.
Wine wineOf(
  String id, {
  String name = 'Barolo',
  int? vintage = 2016,
  int quantity = 1,
  String? producer,
  String? wineType,
  String? region,
  String? denomination,
  DrinkingWindow? window,
  String? country,
}) => Wine(
  id: id,
  name: name,
  vintage: vintage,
  storedQuantity: quantity,
  producer: producer,
  wineType: wineType,
  region: region,
  denomination: denomination,
  window: window,
  country: country,
);

/// The same wine as the cloud document [Wine.fromMap] reads.
Map<String, Object?> wineDocument({
  String name = 'Barolo',
  int? vintage = 2016,
  int quantity = 1,
  Object? window,
}) => {
  WineFields.name: name,
  WineFields.vintage: vintage,
  WineFields.quantity: quantity,
  WineFields.window: ?window,
};

const _names = [
  'Barolo Riserva',
  "Barbera d'Asti Superiore",
  'Chianti Classico',
  'Amarone della Valpolicella',
  'Prosecco Superiore',
  'Franciacorta Brut',
  'Etna Bianco',
  'Soave Classico',
  'Moscato di Pantelleria',
  'Lambrusco di Sorbara',
];

const _types = ['redStructured', 'white', 'sparkling', 'rose', 'sweet', null];

const _regions = [
  'Piemonte',
  'Toscana',
  'Veneto',
  'Sicilia',
  'piemonte',
  'Lombardia',
  'Campania',
  'Puglia',
  'Sardegna',
  'Marche',
  'Abruzzo',
  null,
];

/// [count] wines (500 in the size tests): two thirds with a valid window
/// spread around [baseYear], one third not estimated yet, mixed types and
/// regions, quantities 1-3.
List<Wine> syntheticCellar(int count, {int baseYear = 2026}) =>
    List.generate(count, (i) {
      final start = baseYear - 6 + i % 9;
      final peak = start + i % 5;
      return wineOf(
        'w$i',
        name: '${_names[i % _names.length]} $i',
        vintage: i % 7 == 0 ? null : 2000 + i % 25,
        quantity: 1 + i % 3,
        producer: i % 4 == 0 ? null : 'Cantina ${i % 37}',
        wineType: _types[i % _types.length],
        region: _regions[i % _regions.length],
        denomination: i % 5 == 0 ? 'Barolo DOCG' : null,
        window: i % 3 == 0 ? null : window(start, peak, peak + i % 7),
      );
    });

WinesSnapshot snapshotOf(List<Wine> wines, {SnapshotMeta meta = fromServer}) =>
    WinesSnapshot(wines: wines, meta: meta);
