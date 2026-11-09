// The classified offline database (wine-style-profiles F3, BR9.1-BR9.5,
// FR2.1, FR2.5): the tool classifies every wine with classifyWine, drops the
// products that are not wine, writes format 2 with Level and Style and the
// share with a Type; the database shipped in assets/wine_db/ matches its
// manifest and keeps the 84% the owner accepted (90% is the target, printed).
import 'dart:convert';
import 'dart:io';

import 'package:estimation/estimation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/catalog/core/offline/wine_db_record.dart';

import '../../tool/build_wine_db.dart';

/// The share of wines with a Type below which the build is refused at the
/// gate: the owner accepted 84-86% against the 90% target (BR9.5, R1).
const double minClassifiedShare = 0.84;

Map<String, String> _row(
  String name, {
  String tags = 'en:wines',
  String brand = '',
  String countries = 'en:france',
}) => {
  'code': '3000000000014',
  'product_name': name,
  'categories_tags': tags,
  'brands': brand,
  'countries_tags': countries,
  'quantity': '75 cl',
};

void main() {
  group('BR9.1 recordOfRow classifies the wine', () {
    test('a Barolo: Type, Level and Style of classifyWine', () {
      final record = recordOfRow(
        _row('Barolo 2016', tags: 'en:wines,en:red-wines'),
      ).record!;
      expect(record.wineType, WineType.redStructured);
      expect(record.level, WineLevel.good);
      expect(record.style, WineStyle.redLong);
      expect(record.vintage, 2016);
    });

    test('BR3.5 a Prosecco stays Charmat, a Porto stays fortified', () {
      final prosecco = recordOfRow(
        _row('Prosecco Extra Dry', tags: 'en:wines,en:sparkling-wines'),
      ).record!;
      expect(prosecco.wineType, WineType.sparklingTank);
      expect(prosecco.toCandidate().exactType, WineType.sparklingTank);
      final porto = recordOfRow(
        _row('Porto Tawny', tags: 'en:wines,en:sweet-wines'),
      ).record!;
      expect(porto.wineType, WineType.fortified);
      expect(porto.style, WineStyle.portTawny);
    });

    test('BR9.4 a product that is not wine is dropped', () {
      final result = recordOfRow(
        _row('Hard Seltzer Lime', tags: 'en:wines,en:white-wines'),
      );
      expect(result.record, isNull);
      expect(result.reason, DropReason.excludedCategory);
    });

    test('no clue: no Type, no Level, no Style', () {
      final record = recordOfRow(_row('Cuvée Mario', countries: 'en:italy'))
          .record!;
      expect(record.wineType, isNull);
      expect(record.level, isNull);
      expect(record.style, isNull);
      expect(record.toJson().containsKey('l'), isFalse);
    });

    test('BR9.2 short keys round-trip; format 1 is still read', () {
      final record = recordOfRow(_row('Champagne Brut 2015')).record!;
      final read = WineDbRecord.fromJson(record.toJson())!;
      expect(read, record);
      expect(read.hashCode, record.hashCode);
      final old = WineDbRecord.fromJson({'b': '3000000000014', 'n': 'Vin'})!;
      expect(old.level, isNull);
      expect(old.style, isNull);
    });
  });

  test('BR9.5 the share is computed and written in the manifest', () {
    final records = [
      recordOfRow(_row('Barolo')).record!,
      recordOfRow(_row('Cuvée Mario')).record!,
    ];
    expect(classifiedTypeShareOf(records), 0.5);
    expect(classifiedTypeShareOf(const []), 0);
    final encoded = encodeWineDb(records, DateTime.utc(2026, 11, 7));
    expect(encoded.manifest.formatVersion, 2);
    expect(encoded.manifest.toJson()['classifiedTypeShare'], 0.5);
    final read = WineDbManifest.fromJson(encoded.manifest.toJson())!;
    expect(read.classifiedTypeShare, 0.5);
    expect(
      WineDbManifest.fromJson({
        ...encoded.manifest.toJson(),
        'classifiedTypeShare': 2,
      })!.classifiedTypeShare,
      isNull,
    );
  });

  group('FR2.1, BR9.5 the database shipped', () {
    late WineDbManifest manifest;
    late List<WineDbRecord> records;

    setUpAll(() {
      manifest = WineDbManifest.fromJson(
        jsonDecode(File('assets/wine_db/manifest.json').readAsStringSync()),
      )!;
      final lines = const LineSplitter().convert(
        utf8.decode(
          gzip.decode(File('assets/wine_db/wines.jsonl.gz').readAsBytesSync()),
        ),
      );
      records = parseWineDbLines(lines).records;
    });

    test('format 2, as many wines as the manifest says', () {
      expect(manifest.formatVersion, 2);
      expect(records, hasLength(manifest.wineCount));
    });

    test('the share recomputed equals the manifest and is at least 84%', () {
      final share = classifiedTypeShareOf(records);
      // ignore: avoid_print
      print(
        'classified type share: ${(share * 100).toStringAsFixed(2)}% '
        '(target 90%, accepted from ${minClassifiedShare * 100}%)',
      );
      expect(share, manifest.classifiedTypeShare);
      expect(share, greaterThanOrEqualTo(minClassifiedShare));
    });

    test('BR9.2 a style only with a Type; a Level with every Type', () {
      for (final record in records) {
        if (record.wineType == null) {
          expect(record.style, isNull);
          expect(record.level, isNull);
        } else {
          expect(record.level, isNotNull);
          if (record.style case final style?) {
            expect(style.wineTypes, contains(record.wineType));
          }
        }
      }
    });
  });
}
