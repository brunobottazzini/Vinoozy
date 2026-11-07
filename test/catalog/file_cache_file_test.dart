// FileCacheFile on a temporary directory: atomic write through .tmp, damaged
// file, deletion of the file and its .tmp (NFR6.4, NFR8.1).
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/catalog/core/catalog_cache_store.dart';
import 'package:vinoozy/catalog/core/off_circuit_breaker.dart';
import 'package:vinoozy/catalog/core/wine_catalog.dart';
import 'package:vinoozy/catalog/platform/file_cache_file.dart';

import 'catalog_test_helpers.dart';

void main() {
  late Directory directory;
  late FileCacheFile cacheFile;
  late int directoryCalls;

  File named(String name) =>
      File('${directory.path}${Platform.pathSeparator}$name');

  setUp(() {
    directory = Directory.systemTemp.createTempSync('catalog_cache_test');
    directoryCalls = 0;
    cacheFile = FileCacheFile(
      directory: () async {
        directoryCalls++;
        return directory;
      },
    );
  });

  tearDown(() {
    if (directory.existsSync()) directory.deleteSync(recursive: true);
  });

  test('no file reads as null', () async {
    expect(await cacheFile.read(), isNull);
  });

  test('writes the .tmp first, then renames it over the file', () async {
    await cacheFile.writeTemp('{"a": 1}');
    expect(named(FileCacheFile.tempFileName).readAsStringSync(), '{"a": 1}');
    expect(named(FileCacheFile.fileName).existsSync(), isFalse);
    await cacheFile.commitTemp();
    expect(named(FileCacheFile.fileName).readAsStringSync(), '{"a": 1}');
    expect(named(FileCacheFile.tempFileName).existsSync(), isFalse);
    expect(await cacheFile.read(), '{"a": 1}');
    expect(directoryCalls, 1, reason: 'directory resolved once');
  });

  test('an interrupted write leaves the previous file intact', () async {
    await cacheFile.writeTemp('old');
    await cacheFile.commitTemp();
    await cacheFile.writeTemp('half writt');
    // Crash before the rename: the cache file still holds the old version.
    expect(await cacheFile.read(), 'old');
    await cacheFile.deleteTemp();
    expect(named(FileCacheFile.tempFileName).existsSync(), isFalse);
    await cacheFile.deleteTemp();
  });

  test('deleteAll removes the file and the .tmp, also when absent', () async {
    await cacheFile.writeTemp('x');
    await cacheFile.commitTemp();
    await cacheFile.writeTemp('y');
    await cacheFile.deleteAll();
    expect(named(FileCacheFile.fileName).existsSync(), isFalse);
    expect(named(FileCacheFile.tempFileName).existsSync(), isFalse);
    await cacheFile.deleteAll();
  });

  test('NFR6.4 a damaged file empties the cache through the store', () async {
    named(FileCacheFile.fileName).writeAsBytesSync([0xff, 0xfe, 0x00, 0x7b]);
    final health = CatalogHealth();
    final store = CatalogCacheStore(
      file: cacheFile,
      clock: FakeClock(),
      health: health,
      logger: RecordingLogger(),
    );
    await store.open('owner');
    expect(store.entryCount, 0);
    expect(health.snapshot().cacheResets, 1);
    expect(named(FileCacheFile.fileName).existsSync(), isFalse);
  });

  test('a store saves to disk and reads its own file back', () async {
    final timers = FakeTimers();
    CatalogCacheStore newStore() => CatalogCacheStore(
      file: cacheFile,
      clock: FakeClock(),
      health: CatalogHealth(),
      logger: RecordingLogger(),
      timerFactory: timers.call,
    );
    final store = newStore();
    await store.open('owner');
    store.put('search:barolo', const [
      WineCandidate(name: 'Barolo', source: CandidateSource.openFoodFacts),
    ], hintKeyOf: (name) => name);
    await store.flush();
    expect(named(FileCacheFile.fileName).existsSync(), isTrue);

    final reopened = newStore();
    await reopened.open('owner');
    expect(reopened.lookup('search:barolo'), hasLength(1));
    await reopened.clear();
    expect(named(FileCacheFile.fileName).existsSync(), isFalse);
  });
}
