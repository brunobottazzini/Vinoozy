// WineDbRecord and WineDbManifest (label-recognition entities.md, D1,
// NFR4.6): the compact line format both ways, optional fields, and damaged
// or out-of-range lines dropped instead of thrown.
import 'package:estimation/estimation.dart' show WineType;
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/catalog/core/offline/wine_db_record.dart';
import 'package:vinoozy/catalog/core/wine_catalog.dart';

void main() {
  const full = WineDbRecord(
    code: '8001234567897',
    name: 'Barolo Ravera',
    producer: 'Elvio Cogno',
    wineType: WineType.redStructured,
    denomination: 'Barolo DOCG',
    country: 'IT',
    vintage: 2016,
  );

  group('D1 line format', () {
    test('a full record goes to a line and back unchanged', () {
      final line = full.toJsonLine();
      expect(line, contains('"b":"8001234567897"'));
      expect(WineDbRecord.fromJsonLine(line), full);
    });

    test('optional fields are left out and read back as absent', () {
      const minimal = WineDbRecord(code: '96385074', name: 'Vino X');
      expect(minimal.toJson().keys, ['b', 'n']);
      expect(WineDbRecord.fromJsonLine(minimal.toJsonLine()), minimal);
    });

    test('NFR3.7 only public product fields are written', () {
      expect(full.toJson().keys.toSet(), {'b', 'n', 'p', 't', 'd', 'c', 'v'});
      expect(full.toString(), isNot(contains('Barolo')));
    });

    test('the offline candidate keeps code, country and the C1 type', () {
      final candidate = full.toCandidate();
      expect(candidate.source, CandidateSource.offline);
      expect(candidate.barcode, '8001234567897');
      expect(candidate.country, 'IT');
      expect(candidate.wineType, CatalogWineType.red);
      expect(candidate.vintage, 2016);
    });
  });

  group('NFR4.6 damaged lines', () {
    test('broken JSON, missing name or code, bad code are dropped', () {
      for (final line in [
        '{"b":"8001234567897","n":',
        '{"n":"Barolo"}',
        '{"b":"8001234567897"}',
        '{"b":"12345","n":"Barolo"}',
        '[1,2,3]',
        '',
      ]) {
        expect(WineDbRecord.fromJsonLine(line), isNull, reason: line);
      }
    });

    test('names out of 2-120 characters are dropped', () {
      expect(WineDbRecord.fromJson({'b': '96385074', 'n': 'X'}), isNull);
      expect(WineDbRecord.fromJson({'b': '96385074', 'n': 'X' * 121}), isNull);
      expect(
        WineDbRecord.fromJson({'b': '96385074', 'n': 'X' * 120})?.name,
        hasLength(120),
      );
    });

    test('optional fields of the wrong kind count as absent', () {
      final record = WineDbRecord.fromJson({
        'b': '96385074',
        'n': 'Vino X',
        'p': 12,
        't': 'purple',
        'c': 'italy',
        'v': 1850,
        'd': 'D' * 121,
      })!;
      expect(record.producer, isNull);
      expect(record.wineType, isNull);
      expect(record.country, isNull);
      expect(record.vintage, isNull);
      expect(record.denomination, isNull);
    });

    test('parseWineDbLines keeps good lines and counts the bad ones', () {
      final parsed = parseWineDbLines([
        full.toJsonLine(),
        'not json',
        '',
        const WineDbRecord(code: '96385074', name: 'Vino X').toJsonLine(),
      ]);
      expect(parsed.records, hasLength(2));
      expect(parsed.skipped, 1);
    });
  });

  group('manifest', () {
    test('manifest round trip with date only', () {
      final manifest = WineDbManifest(
        exportDate: DateTime.utc(2026, 11, 7),
        wineCount: 42,
      );
      final json = manifest.toJson();
      expect(json['exportDate'], '2026-11-07');
      expect(json['license'], 'ODbL-1.0');
      final back = WineDbManifest.fromJson(json)!;
      expect(back.exportDate, DateTime.utc(2026, 11, 7));
      expect(back.wineCount, 42);
      expect(back.formatVersion, wineDbFormatVersion);
      expect(json['source'], 'Open Food Facts');
      expect(back.source, WineDbSource.openFoodFacts);
      expect(back.isSample, isFalse);
    });

    test('review R-02 the sample says "sample", has no licence and reads '
        'back as the sample', () {
      final manifest = WineDbManifest(
        exportDate: DateTime.utc(2026, 11, 7),
        wineCount: 45,
        source: WineDbSource.sample,
      );
      final json = manifest.toJson();
      expect(json['source'], 'sample');
      expect(json.containsKey('license'), isFalse);
      final back = WineDbManifest.fromJson(json)!;
      expect(back.source, WineDbSource.sample);
      expect(back.isSample, isTrue);
    });

    test('review R-02 an unknown source is never taken for Open Food Facts; '
        'a manifest without source is the real export', () {
      Map<String, Object?> json(Object? source) => {
        'formatVersion': 1,
        'exportDate': '2026-11-07',
        'wineCount': 3,
        'source': ?source,
      };
      expect(WineDbManifest.fromJson(json('somewhere'))!.isSample, isTrue);
      expect(WineDbManifest.fromJson(json(42))!.isSample, isTrue);
      expect(WineDbManifest.fromJson(json(null))!.isSample, isFalse);
      expect(
        WineDbManifest.fromJson(json('Open Food Facts'))!.source,
        WineDbSource.openFoodFacts,
      );
    });

    test('an invalid manifest is null', () {
      expect(WineDbManifest.fromJson('x'), isNull);
      expect(WineDbManifest.fromJson({'formatVersion': 1}), isNull);
      expect(
        WineDbManifest.fromJson({
          'formatVersion': 1,
          'wineCount': 3,
          'exportDate': 'yesterday',
        }),
        isNull,
      );
    });
  });
}
