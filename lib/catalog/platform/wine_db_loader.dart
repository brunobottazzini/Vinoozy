// Opens the offline wine database of the app assets (label-recognition
// BR2.5, NFR2.3-NFR2.6, NFR4.5, NFR4.6, NFR4.15).
//
// - The asset is read once per process; two requests at the same time wait
//   for the same opening (NFR2.6).
// - Decompression, line parsing and indexing go through the injected
//   [BackgroundRunner], `Isolate.run` in the app, so the interface never
//   blocks (NFR2.4).
// - A missing or broken database never stops the app: the result is
//   "unavailable" with a closed reason, logged as `wine_db_unavailable`, and
//   recognition goes on with the internal catalog and Open Food Facts
//   (NFR4.5). Damaged lines are dropped and counted (NFR4.6).

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;

import '../core/catalog_event_logger.dart';
import '../core/offline/wine_db_index.dart';
import '../core/offline/wine_db_record.dart';

/// Runs [computation] away from the interface thread; `Isolate.run` in the
/// app, a recording fake in tests.
typedef BackgroundRunner = Future<R> Function<R>(
  FutureOr<R> Function() computation,
);

/// Reads one asset as bytes; `rootBundle` in the app.
typedef AssetBytesReader = Future<Uint8List> Function(String key);

/// Asset paths of the database (pubspec.yaml, `assets/wine_db/`).
const String wineDbAsset = 'assets/wine_db/wines.jsonl.gz';
const String wineDbManifestAsset = 'assets/wine_db/manifest.json';

/// The outcome of opening the database.
sealed class WineDbLoadResult {
  const WineDbLoadResult();
}

/// The database is open and in memory.
final class WineDbReady extends WineDbLoadResult {
  const WineDbReady(this.db);

  final OfflineWineDb db;
}

/// The database could not be used; [skippedRows] damaged lines were seen.
final class WineDbUnavailable extends WineDbLoadResult {
  const WineDbUnavailable(this.reason, {this.skippedRows = 0});

  final WineDbFailure reason;
  final int skippedRows;
}

Future<Uint8List> _readBundle(String key) async =>
    (await rootBundle.load(key)).buffer.asUint8List();

Future<R> _isolateRun<R>(FutureOr<R> Function() computation) =>
    Isolate.run(computation);

/// Opens the database once, in the background.
class WineDbLoader {
  WineDbLoader({
    required this._logger,
    AssetBytesReader? readAsset,
    BackgroundRunner? runInBackground,
  }) : _readAsset = readAsset ?? _readBundle,
       _runInBackground = runInBackground ?? _isolateRun;

  final CatalogEventLogger _logger;
  final AssetBytesReader _readAsset;
  final BackgroundRunner _runInBackground;
  Future<WineDbLoadResult>? _opening;
  WineDbLoadResult? _loaded;

  /// The database, opened at the first call; later calls get the same
  /// answer. Never throws.
  Future<WineDbLoadResult> open() => _opening ??= _open();

  /// Whether the open database is the hand-written sample (review R-02):
  /// its offline results must not carry the Open Food Facts attribution.
  /// Read without starting the opening: offline results exist only once
  /// the database is open, so `false` before that is never wrong.
  bool get isSample => switch (_loaded) {
    WineDbReady(:final db) => db.manifest.isSample,
    _ => false,
  };

  /// The open database, or `null` when it is unavailable: what the
  /// coordinator uses.
  Future<OfflineWineDb?> openDb() async => switch (await open()) {
    WineDbReady(:final db) => db,
    WineDbUnavailable() => null,
  };

  Future<WineDbLoadResult> _open() async {
    final stopwatch = Stopwatch()..start();
    final result = await _load();
    stopwatch.stop();
    _loaded = result;
    switch (result) {
      case WineDbReady(:final db):
        _logger.wineDbOpened(db.wineCount, stopwatch.elapsedMilliseconds);
      case WineDbUnavailable(:final reason, :final skippedRows):
        _logger.wineDbUnavailable(reason, skippedRows);
    }
    return result;
  }

  Future<WineDbLoadResult> _load() async {
    final Uint8List compressed;
    final Uint8List manifest;
    try {
      compressed = await _readAsset(wineDbAsset);
      manifest = await _readAsset(wineDbManifestAsset);
    } catch (_) {
      // rootBundle throws when the asset is not in the build.
      return const WineDbUnavailable(WineDbFailure.missing);
    }
    try {
      return await _runInBackground(() => decodeWineDb(compressed, manifest));
    } catch (_) {
      return const WineDbUnavailable(WineDbFailure.unexpected);
    }
  }
}

/// Decompresses, parses and indexes the database: the work done in the
/// background isolate. Returns, never throws.
WineDbLoadResult decodeWineDb(Uint8List compressed, Uint8List manifestBytes) {
  final WineDbManifest? manifest;
  try {
    manifest = WineDbManifest.fromJson(
      jsonDecode(utf8.decode(manifestBytes, allowMalformed: true)),
    );
  } on FormatException {
    return const WineDbUnavailable(WineDbFailure.unexpected);
  }
  // wine-style-profiles (ENT-109): format 1 (without Level and Style) is
  // still read; the form classifies its wines when they are proposed.
  if (manifest == null ||
      manifest.formatVersion < 1 ||
      manifest.formatVersion > wineDbFormatVersion) {
    return const WineDbUnavailable(WineDbFailure.unexpected);
  }
  final List<int> plain;
  try {
    plain = gzip.decode(compressed);
  } on FormatException {
    return const WineDbUnavailable(WineDbFailure.corruptGzip);
  }
  final lines = const LineSplitter().convert(
    utf8.decode(plain, allowMalformed: true),
  );
  final db = OfflineWineDb.fromLines(manifest, lines);
  if (db.wineCount == 0) {
    return WineDbUnavailable(
      WineDbFailure.noValidRows,
      skippedRows: db.skippedRows,
    );
  }
  return WineDbReady(db);
}
