// WineDbLoader (label-recognition BR2.5, NFR2.3, NFR2.4, NFR2.6, NFR4.5,
// NFR4.6, NFR4.15): assets read in memory, the background runner recorded,
// one opening for concurrent requests, and every broken database turned
// into "unavailable" with its reason.
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/catalog/core/catalog_event_logger.dart';
import 'package:vinoozy/catalog/core/offline/wine_db_record.dart';
import 'package:vinoozy/catalog/platform/wine_db_loader.dart';

import 'catalog_test_helpers.dart';

const _ravera = WineDbRecord(
  code: '8001234567897',
  name: 'Barolo Ravera',
  producer: 'Elvio Cogno',
);

Uint8List _gzip(String text) =>
    Uint8List.fromList(gzip.encode(utf8.encode(text)));

Uint8List _manifest({int version = wineDbFormatVersion, String? source}) =>
    Uint8List.fromList(
      utf8.encode(
        jsonEncode({
          'formatVersion': version,
          'exportDate': '2026-11-07',
          'wineCount': 1,
          'source': ?source,
        }),
      ),
    );

class _Assets {
  _Assets(this.files);

  final Map<String, Uint8List> files;
  final List<String> reads = [];
  Completer<void>? gate;

  Future<Uint8List> read(String key) async {
    reads.add(key);
    final wait = gate;
    if (wait != null) await wait.future;
    final bytes = files[key];
    if (bytes == null) throw StateError('Unable to load asset');
    return bytes;
  }
}

void main() {
  late RecordingLogger logger;
  late int backgroundCalls;

  setUp(() {
    logger = RecordingLogger();
    backgroundCalls = 0;
  });

  WineDbLoader loader(_Assets assets) => WineDbLoader(
    logger: logger,
    readAsset: assets.read,
    runInBackground: <R>(FutureOr<R> Function() work) async {
      backgroundCalls++;
      return work();
    },
  );

  _Assets valid() => _Assets({
    wineDbAsset: _gzip('${_ravera.toJsonLine()}\n{broken\n'),
    wineDbManifestAsset: _manifest(),
  });

  test('BR2.5 the database opens with its wines and manifest; NFR4.6 a '
      'broken line is dropped', () async {
    final result = await loader(valid()).open();
    final db = (result as WineDbReady).db;
    expect(db.wineCount, 1);
    expect(db.skippedRows, 1);
    expect(db.manifest.exportDate, DateTime.utc(2026, 11, 7));
    expect(db.index.byBarcode('8001234567897'), _ravera);
    expect(logger.wineDbOpenings.single.$1, 1);
    expect(logger.wineDbFailures, isEmpty);
  });

  group('review R-02 isSample', () {
    test('false before the opening, which it never starts', () {
      final assets = valid();
      final subject = loader(assets);
      expect(subject.isSample, isFalse);
      expect(assets.reads, isEmpty);
    });

    test('true once the sample is open, false for Open Food Facts', () async {
      final sample = loader(
        _Assets({
          wineDbAsset: _gzip('${_ravera.toJsonLine()}\n'),
          wineDbManifestAsset: _manifest(source: 'sample'),
        }),
      );
      await sample.open();
      expect(sample.isSample, isTrue);
      final real = loader(
        _Assets({
          wineDbAsset: _gzip('${_ravera.toJsonLine()}\n'),
          wineDbManifestAsset: _manifest(source: 'Open Food Facts'),
        }),
      );
      await real.open();
      expect(real.isSample, isFalse);
    });

    test('false when the database is unavailable', () async {
      final subject = loader(_Assets({}));
      await subject.open();
      expect(subject.isSample, isFalse);
    });
  });

  test('NFR2.4 decompression and indexing go through runInBackground, '
      'once', () async {
    final subject = loader(valid());
    await subject.open();
    await subject.open();
    expect(backgroundCalls, 1);
  });

  test('NFR2.6 two requests at the same time read the asset once', () async {
    final assets = valid()..gate = Completer<void>();
    final subject = loader(assets);
    final first = subject.openDb();
    final second = subject.openDb();
    assets.gate!.complete();
    final dbs = await Future.wait([first, second]);
    expect(identical(dbs[0], dbs[1]), isTrue);
    expect(assets.reads.where((k) => k == wineDbAsset), hasLength(1));
  });

  group('NFR4.5 unavailable database', () {
    Future<WineDbUnavailable> unavailable(_Assets assets) async =>
        await loader(assets).open() as WineDbUnavailable;

    test('NFR4.5 a missing file is "missing"', () async {
      final result = await unavailable(_Assets({}));
      expect(result.reason, WineDbFailure.missing);
      expect(logger.wineDbFailures.single, (WineDbFailure.missing, 0));
    });

    test('NFR4.5 broken gzip is "corruptGzip"', () async {
      final result = await unavailable(
        _Assets({
          wineDbAsset: Uint8List.fromList([1, 2, 3, 4]),
          wineDbManifestAsset: _manifest(),
        }),
      );
      expect(result.reason, WineDbFailure.corruptGzip);
    });

    test('NFR4.5 no valid line is "noValidRows" with the count', () async {
      final result = await unavailable(
        _Assets({
          wineDbAsset: _gzip('{broken\nnot json\n'),
          wineDbManifestAsset: _manifest(),
        }),
      );
      expect(result.reason, WineDbFailure.noValidRows);
      expect(result.skippedRows, 2);
      expect(logger.wineDbFailures.single, (WineDbFailure.noValidRows, 2));
      expect(await loader(_Assets({})).openDb(), isNull);
    });

    test('a broken or unknown manifest, or a failing isolate, is '
        '"unexpected"', () async {
      for (final manifest in [
        Uint8List.fromList(utf8.encode('{nope')),
        _manifest(version: 99),
      ]) {
        final result = await unavailable(
          _Assets({
            wineDbAsset: _gzip(_ravera.toJsonLine()),
            wineDbManifestAsset: manifest,
          }),
        );
        expect(result.reason, WineDbFailure.unexpected);
      }
      final failing = WineDbLoader(
        logger: logger,
        readAsset: valid().read,
        runInBackground: <R>(FutureOr<R> Function() work) async =>
            throw StateError('isolate'),
      );
      expect(
        (await failing.open() as WineDbUnavailable).reason,
        WineDbFailure.unexpected,
      );
    });
  });

  test('the real Isolate.run path opens the database of the assets in the '
      'repository', () async {
    final subject = WineDbLoader(
      logger: logger,
      readAsset: (key) async => File(key).readAsBytesSync(),
    );
    final db = await subject.openDb();
    expect(db, isNotNull);
    expect(db!.wineCount, db.manifest.wineCount);
    // Whatever database the repository carries (the real export or the
    // sample), its first and last records are found by their barcode.
    final lines = const LineSplitter().convert(
      utf8.decode(gzip.decode(File(wineDbAsset).readAsBytesSync())),
    )..removeWhere((line) => line.trim().isEmpty);
    expect(lines, hasLength(db.wineCount));
    for (final line in [lines.first, lines.last]) {
      final json = jsonDecode(line) as Map<String, Object?>;
      expect(db.index.byBarcode(json['b']! as String)?.name, json['n']);
    }
  });
}
