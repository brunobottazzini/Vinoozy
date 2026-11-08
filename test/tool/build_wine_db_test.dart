// tool/build_wine_db.dart (label-recognition FR2.1, BR2.1-BR2.4, NFR1.2,
// NFR2.8, NFR3.7, NFR4.7, NFR5.6) on the hand-written sample of
// tool/fixtures/: never the real Open Food Facts export, never the network.
import 'dart:convert';
import 'dart:io';

import 'package:estimation/estimation.dart' show WineType;
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/catalog/core/offline/wine_db_record.dart';

import '../../tool/build_wine_db.dart';

const _sample = 'tool/fixtures/off_wines_sample.csv';
final _today = DateTime.utc(2026, 11, 7);

/// The sample limits: everything as decided except the 5000-wine floor.
const _sampleLimits = BuildLimits(minWines: 10);

void main() {
  late Directory temp;

  setUp(() => temp = Directory.systemTemp.createTempSync('vinoozy_wine_db'));
  tearDown(() => temp.deleteSync(recursive: true));

  Future<(int, String, String)> run(
    List<String> extra, {
    String input = _sample,
    BuildLimits limits = _sampleLimits,
  }) async {
    final out = StringBuffer();
    final err = StringBuffer();
    final code = await runBuildWineDb(
      [
        '--input',
        input,
        '--output',
        temp.path,
        '--export-date',
        '2026-11-01',
        ...extra,
      ],
      now: _today,
      limits: limits,
      out: out,
      err: err,
    );
    return (code, out.toString(), err.toString());
  }

  List<WineDbRecord> written() {
    final bytes = File('${temp.path}/$winesFileName').readAsBytesSync();
    final lines = const LineSplitter().convert(utf8.decode(gzip.decode(bytes)));
    return [for (final line in lines) WineDbRecord.fromJsonLine(line)!];
  }

  Future<ExportReader> sample() => readExport(File(_sample));

  group('BR2.1 filters', () {
    test('BR2.1 only wines with a valid barcode and name are kept', () async {
      final export = await sample();
      expect(export.rows, 60);
      expect(export.records, hasLength(45));
      expect(export.dropped, {
        DropReason.excludedCategory: 5,
        DropReason.notWine: 2,
        DropReason.invalidBarcode: 3,
        DropReason.invalidName: 3,
        DropReason.duplicate: 2,
      });
      final names = export.records.map((r) => r.name).toList();
      for (final excluded in [
        'Marmellata di uva al vino',
        "Succo d'uva rosso",
        'Aceto di vino rosso',
        'Salsa al vino rosso',
        'Birra Bionda',
        'Brodo al vino bianco',
        'Barolo con codice sbagliato',
      ]) {
        expect(names, isNot(contains(excluded)));
      }
    });

    test('BR2.1 a UPC-A code is stored with 13 digits, EAN-8 as is', () async {
      final codes = (await sample()).records.map((r) => r.code);
      expect(codes, containsAll(['0036000291452', '96385074']));
    });
  });

  group('BR2.2 BR2.3 derived fields', () {
    test('BR2.2 the type follows the category tags', () {
      WineType? type(String tags) => wineTypeOfTags(tags.split(',').toSet());
      expect(type('en:wines,en:red-wines'), WineType.redStructured);
      expect(type('en:wines,en:red-wines,en:young-wines'), WineType.redLight);
      expect(type('en:wines,en:white-wines'), WineType.white);
      expect(type('en:wines,en:rose-wines'), WineType.rose);
      expect(
        type('en:wines,en:sparkling-wines,en:champagnes'),
        WineType.sparklingClassic,
      );
      expect(
        type('en:wines,en:sparkling-wines,en:proseccos'),
        WineType.sparklingTank,
      );
      expect(type('en:wines,en:dessert-wines'), WineType.sweet);
      expect(type('en:wines,en:fortified-wines,en:ports'), WineType.fortified);
      expect(
        type('en:wines,en:portuguese-wines,en:red-wines'),
        WineType.redStructured,
      );
      expect(type('en:wines'), isNull);
    });

    test('BR2.3 denomination, country and vintage', () async {
      final byCode = {for (final r in (await sample()).records) r.code: r};
      final barolo = byCode['8001234567897']!;
      expect(barolo.denomination, 'Barolo DOCG');
      expect(barolo.country, 'IT');
      expect(barolo.vintage, 2016);
      expect(barolo.producer, 'Elvio Cogno');
      expect(byCode['8001234500405']!.denomination, 'Pomerol AOC');
      expect(byCode['8001234500399']!.vintage, 2021, reason: 'from quantity');
      expect(byCode['8001234500092']!.country, 'LB');
      expect(byCode['0036000291452']!.country, 'US');
      expect(byCode['8001234500023']!.country, 'IT', reason: 'first country');
      expect(byCode['8001234500344']!.producer, isNull);
      expect(vintageOf('Vino 12345', '750 ml'), isNull);
      expect(vintageOf('Vino 1850', null), isNull);
      expect(countryOfTags('en:atlantis'), isNull);
      expect(countryOfTags(''), isNull);
    });
  });

  group('BR2.4 plausibility', () {
    test('BR2.4 duplicated barcodes keep the first row only', () async {
      final export = await sample();
      final barolo = export.records.where((r) => r.code == '8001234567897');
      expect(barolo.single.name, 'Barolo Ravera 2016');
      expect(export.records.map((r) => r.code).toSet(), hasLength(45));
    });

    test('NFR4.7 below 5000 wines: no file written and exit 1', () async {
      final (code, _, err) = await run(const [], limits: const BuildLimits());
      expect(code, 1);
      expect(err, contains('only 45 wines, at least 5000'));
      expect(File('${temp.path}/$winesFileName').existsSync(), isFalse);
      expect(File('${temp.path}/$manifestFileName').existsSync(), isFalse);
    });

    test('NFR4.7 a failed build leaves the previous database whole', () async {
      final (first, _, _) = await run(const []);
      expect(first, 0);
      final before = File('${temp.path}/$winesFileName').readAsBytesSync();
      final (second, _, _) = await run(const [], limits: const BuildLimits());
      expect(second, 1);
      expect(File('${temp.path}/$winesFileName').readAsBytesSync(), before);
    });

    test('BR2.4 an export older than 180 days is refused without the '
        'option', () async {
      final (code, _, err) = await run(const ['--export-date', '2026-01-01']);
      expect(code, 1);
      expect(err, contains('--skip-freshness-check'));
      final (skipped, _, _) = await run(const [
        '--export-date',
        '2026-01-01',
        '--skip-freshness-check',
      ]);
      expect(skipped, 0);
    });
  });

  group('NFR1.2 sizes', () {
    test('NFR1.2 over 3 MB compressed is refused (limit injected)', () async {
      final (code, _, err) = await run(
        const [],
        limits: const BuildLimits(minWines: 10, maxCompressedBytes: 100),
      );
      expect(code, 1);
      expect(err, contains('NFR1.2'));
    });

    test(
      'owner limit: over 30 MB uncompressed is refused (limit injected)',
      () async {
        const limits = BuildLimits();
        expect(limits.maxUncompressedBytes, 30 * 1024 * 1024);
        expect(limits.maxCompressedBytes, 3 * 1024 * 1024);
        final (code, _, err) = await run(
          const [],
          limits: const BuildLimits(minWines: 10, maxUncompressedBytes: 1000),
        );
        expect(code, 1);
        expect(err, contains('30 MB limit set by the owner'));
        expect(File('${temp.path}/$winesFileName').existsSync(), isFalse);
      },
    );
  });

  group('output', () {
    test('FR2.1 writes wines.jsonl.gz and the manifest', () async {
      final (code, out, _) = await run(const []);
      expect(code, 0);
      expect(out, contains('45 wines kept'));
      expect(written(), hasLength(45));
      final manifest = WineDbManifest.fromJson(
        jsonDecode(File('${temp.path}/$manifestFileName').readAsStringSync()),
      )!;
      expect(manifest.wineCount, 45);
      expect(manifest.exportDate, DateTime.utc(2026, 11, 1));
      // Without --allow-small-sample the build is a real one.
      expect(manifest.source, WineDbSource.openFoodFacts);
    });

    test('review R-02 --allow-small-sample marks the manifest "sample", '
        'without licence', () async {
      final (code, out, _) = await run(const ['--allow-small-sample']);
      expect(code, 0);
      expect(out, contains('source sample'));
      final json = jsonDecode(
        File('${temp.path}/$manifestFileName').readAsStringSync(),
      ) as Map<String, Object?>;
      expect(json['source'], 'sample');
      expect(json.containsKey('license'), isFalse);
      expect(WineDbManifest.fromJson(json)!.isSample, isTrue);
    });

    test('review R-02 the database of the app today is the sample and says '
        'so', () {
      final manifest = WineDbManifest.fromJson(
        jsonDecode(File('assets/wine_db/$manifestFileName').readAsStringSync()),
      )!;
      // Once the real export is built this test stops applying: the
      // manifest then must be Open Food Facts with at least 5000 wines.
      if (manifest.wineCount < 5000) {
        expect(manifest.isSample, isTrue);
      } else {
        expect(manifest.source, WineDbSource.openFoodFacts);
      }
    });

    test('NFR3.7 no personal field reaches the output', () async {
      await run(const []);
      final raw = utf8.decode(
        gzip.decode(File('${temp.path}/$winesFileName').readAsBytesSync()),
      );
      expect(raw, isNot(contains('contributor-sample')));
      expect(raw, isNot(contains('1700000000')));
      for (final record in written()) {
        expect(
          record.toJson().keys.toSet().difference({
            'b',
            'n',
            'p',
            't',
            'd',
            'c',
            'v',
          }),
          isEmpty,
        );
      }
    });

    test('NFR2.8 a gzip export is read as a stream of lines', () async {
      final gz = File('${temp.path}/export.csv.gz')
        ..writeAsBytesSync(gzip.encode(File(_sample).readAsBytesSync()));
      final export = await readExport(gz);
      expect(export.records, hasLength(45));
    });

    test('wrong arguments or a missing input exit 2', () async {
      final err = StringBuffer();
      expect(await runBuildWineDb(const ['--input'], err: err), 2);
      expect(
        await runBuildWineDb([
          '--input',
          '${temp.path}/none.csv.gz',
          '--output',
          temp.path,
        ], err: err),
        2,
      );
      expect(await runBuildWineDb(const ['--bogus'], err: err), 2);
    });
  });

  test('NFR5.6 assets/wine_db/ has LICENSE (ODbL) and README', () {
    final license = File('assets/wine_db/LICENSE').readAsStringSync();
    expect(license, contains('Open Database License'));
    expect(license, contains('Database Contents License'));
    final readme = File('assets/wine_db/README.md').readAsStringSync();
    expect(readme, contains('dart run tool/build_wine_db.dart'));
    expect(readme, contains('exportDate'));
    expect(File('assets/wine_db/$winesFileName').existsSync(), isTrue);
    expect(File('assets/wine_db/$manifestFileName').existsSync(), isTrue);
  });
}
