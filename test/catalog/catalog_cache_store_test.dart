// CatalogCacheStore: expiry, limits, owner, epoch and serialised saves
// (BR2.1, NFR2.3, NFR6.4, NFR8.1).
import 'dart:async';
import 'dart:convert';

import 'package:estimation/estimation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/catalog/core/catalog_cache_store.dart';
import 'package:vinoozy/catalog/core/catalog_event_logger.dart';
import 'package:vinoozy/catalog/core/off_circuit_breaker.dart';
import 'package:vinoozy/catalog/core/wine_catalog.dart';

import 'catalog_test_helpers.dart';

const _ownerA = 'owner-hash-a';
const _ownerB = 'owner-hash-b';

WineCandidate _off(String name, {String? region, CatalogWineType? type}) =>
    WineCandidate(
      name: name,
      source: CandidateSource.openFoodFacts,
      region: region,
      wineType: type,
    );

class _Harness {
  _Harness({InMemoryCacheFile? file}) : file = file ?? InMemoryCacheFile() {
    store = CatalogCacheStore(
      file: this.file,
      clock: clock,
      health: health,
      logger: logger,
      timerFactory: timers.call,
    );
  }

  final InMemoryCacheFile file;
  final clock = FakeClock();
  final health = CatalogHealth();
  final logger = RecordingLogger();
  final timers = FakeTimers();
  late final CatalogCacheStore store;

  void put(String key, List<WineCandidate> candidates) =>
      store.put(key, candidates, hintKeyOf: normalizeWineText);

  /// Fires the pending save timer and lets the save finish.
  Future<void> save() async {
    timers.fireAll(CatalogCacheStore.saveDelay);
    await store.flush();
  }
}

void main() {
  group('lookup and put (BR2.1)', () {
    test(
      'stores answers, empty lists included, and counts the hit ratio',
      () async {
        final h = _Harness();
        await h.store.open(_ownerA);
        expect(h.store.lookup('search:barolo'), isNull);
        h.put('search:barolo', [_off('Barolo Cannubi')]);
        h.put('product:8000000000000', const []);
        expect(h.store.lookup('search:barolo'), [_off('Barolo Cannubi')]);
        expect(h.store.lookup('product:8000000000000'), isEmpty);
        final health = h.health.snapshot();
        expect(health.cacheHitRatio, closeTo(2 / 3, 1e-9));
        expect(h.logger.debugEvents, contains(CatalogDebugEvent.cacheHit));
      },
    );

    test('BR2.1 an answer expires after 30 days, a hint too', () async {
      final h = _Harness();
      await h.store.open(_ownerA);
      h.put('search:barolo', [
        _off('Barolo Cannubi', region: 'Piemonte', type: CatalogWineType.red),
      ]);
      h.clock.advance(const Duration(days: 30) - const Duration(seconds: 1));
      expect(h.store.lookup('search:barolo'), isNotNull);
      expect(h.store.hint('barolo cannubi')?.region, 'Piemonte');
      h.clock.advance(const Duration(seconds: 1));
      expect(h.store.lookup('search:barolo'), isNull);
      expect(h.store.hint('barolo cannubi'), isNull);
      expect(h.store.entryCount, 0);
      expect(h.store.hintCount, 0);
    });

    test(
      'updates the profile hint of every proposal with a profile field',
      () async {
        final h = _Harness();
        await h.store.open(_ownerA);
        h.put('search:x', [
          _off("Barbera d'Asti", type: CatalogWineType.red),
          _off('Senza profilo'),
          _off('🍷🍷', region: 'Nowhere'),
        ]);
        expect(
          h.store.hint('barbera d asti'),
          const ProfileHint(wineType: CatalogWineType.red),
        );
        expect(h.store.hint('senza profilo'), isNull);
        expect(h.store.hintCount, 1);
        expect(const ProfileHint().isEmpty, isTrue);
        expect(
          const ProfileHint(region: 'x').hashCode,
          const ProfileHint(region: 'x').hashCode,
        );
      },
    );
  });

  group('limits (NFR2.3)', () {
    test('keeps 200 answers of at most 10 proposals, the newest', () async {
      final h = _Harness();
      await h.store.open(_ownerA);
      for (var i = 0; i < 250; i++) {
        h.put('search:q$i', [for (var j = 0; j < 12; j++) _off('Vino $i $j')]);
        h.clock.advance(const Duration(seconds: 1));
      }
      expect(h.store.entryCount, CatalogCacheStore.maxEntries);
      expect(h.store.lookup('search:q49'), isNull);
      expect(h.store.lookup('search:q50'), hasLength(10));
      expect(h.store.lookup('search:q249'), hasLength(10));
    });

    test('keeps at most 500 hints, the newest', () async {
      final h = _Harness();
      await h.store.open(_ownerA);
      for (var i = 0; i < 60; i++) {
        h.put('search:q$i', [
          for (var j = 0; j < 10; j++) _off('Vino $i $j', region: 'Piemonte'),
        ]);
        h.clock.advance(const Duration(seconds: 1));
      }
      expect(h.store.hintCount, CatalogCacheStore.maxHints);
      expect(h.store.hint('vino 0 0'), isNull);
      expect(h.store.hint('vino 59 9'), isNotNull);
    });

    test(
      'worst case with 4-byte characters stays under 3 MB of UTF-8',
      () async {
        final h = _Harness();
        await h.store.open(_ownerA);
        String wide(int length) => '𝔅' * length; // 4 bytes in UTF-8
        for (var i = 0; i < 250; i++) {
          h.put('search:${'q' * 100}$i', [
            for (var j = 0; j < 10; j++)
              WineCandidate(
                // Two latin names per answer fill the 500 hints too.
                name: j < 8
                    ? wide(120)
                    : '${'v' * 100} $i $j'.padRight(120, 'x'),
                source: CandidateSource.openFoodFacts,
                producer: wide(80),
                vintage: 2016,
                wineType: CatalogWineType.sparkling,
                region: wide(60),
                denomination: wide(60),
                barcode: '8001234567890',
              ),
          ]);
          h.clock.advance(const Duration(seconds: 1));
        }
        expect(h.store.entryCount, 200);
        expect(h.store.hintCount, 500);
        final bytes = utf8.encode(h.store.serialize()).length;
        expect(bytes, lessThan(3 * 1024 * 1024));
      },
    );
  });

  group('file, owner and resets (NFR6.4, NFR8.1)', () {
    test('a saved cache is read back by the same owner', () async {
      final h = _Harness();
      await h.store.open(_ownerA);
      h.put('search:barolo', [_off('Barolo', region: 'Piemonte')]);
      await h.save();
      expect(h.file.commits, 1);

      final again = _Harness(file: h.file);
      await again.store.open(_ownerA);
      expect(again.store.lookup('search:barolo'), [
        _off('Barolo', region: 'Piemonte'),
      ]);
      expect(again.store.hint('barolo')?.region, 'Piemonte');
    });

    test('a cache of another owner, or without owner, is deleted', () async {
      final h = _Harness();
      await h.store.open(_ownerA);
      h.put('search:barolo', [_off('Barolo')]);
      await h.save();
      final saved = h.file.contents!;

      final other = _Harness(file: InMemoryCacheFile(saved));
      await other.store.open(_ownerB);
      expect(other.store.lookup('search:barolo'), isNull);
      expect(other.file.contents, isNull);
      expect(
        other.logger.debugEvents,
        contains(CatalogDebugEvent.cacheOwnerMismatch),
      );
      expect(other.health.snapshot().cacheResets, 0);

      final ownerless = jsonDecode(saved) as Map<String, Object?>
        ..remove('owner');
      final noOwner = _Harness(file: InMemoryCacheFile(jsonEncode(ownerless)));
      await noOwner.store.open(_ownerA);
      expect(noOwner.store.entryCount, 0);
      expect(noOwner.file.contents, isNull);
    });

    test('NFR6.4 an unreadable or damaged file empties the cache', () async {
      for (final contents in [
        'not json',
        '[]',
        '{"version": 2, "owner": "$_ownerA", "entries": [], "hints": []}',
        '{"version": 1, "owner": "$_ownerA", "entries": {}, "hints": []}',
      ]) {
        final h = _Harness(file: InMemoryCacheFile(contents));
        await h.store.open(_ownerA);
        expect(h.store.entryCount, 0, reason: contents);
        expect(h.file.contents, isNull, reason: contents);
        expect(h.health.snapshot().cacheResets, 1, reason: contents);
      }
      final failing = _Harness(file: InMemoryCacheFile('{}')..failReads = true);
      await failing.store.open(_ownerA);
      expect(failing.health.snapshot().cacheResets, 1);
      final undeletable = _Harness(
        file: InMemoryCacheFile('garbage')..failDeletes = true,
      );
      await undeletable.store.open(_ownerA);
      expect(
        undeletable.logger.debugEvents,
        contains(CatalogDebugEvent.cacheWriteFailed),
      );
    });

    test('damaged and expired items inside a valid file are skipped', () async {
      final h = _Harness();
      final old = h.clock.now().subtract(const Duration(days: 31));
      final now = h.clock.now().millisecondsSinceEpoch;
      h.file.contents = jsonEncode({
        'version': 1,
        'owner': _ownerA,
        'entries': [
          'junk',
          {'k': 'search:old', 'at': old.millisecondsSinceEpoch, 'c': []},
          {'k': 'search:bad', 'at': 'yesterday', 'c': []},
          {
            'k': 'search:ok',
            'at': now,
            'c': [
              {'n': 'Barolo', 's': 'openFoodFacts'},
              {'n': '', 's': 'internal'},
            ],
          },
        ],
        'hints': [
          7,
          {'k': 'barolo', 'at': now, 't': 'red', 'r': 'Piemonte', 'd': 3},
          {'k': 'empty', 'at': now},
          {'k': 'old', 'at': old.millisecondsSinceEpoch, 'r': 'x'},
        ],
      });
      await h.store.open(_ownerA);
      expect(h.store.entryCount, 1);
      expect(h.store.lookup('search:ok'), [_off('Barolo')]);
      expect(
        h.store.hint('barolo'),
        const ProfileHint(wineType: CatalogWineType.red, region: 'Piemonte'),
      );
      expect(h.store.hintCount, 1);
    });

    test('without a signed-in user nothing is read or saved', () async {
      final h = _Harness(file: InMemoryCacheFile('{"owner": "x"}'));
      await h.store.open(null);
      h.put('search:barolo', [_off('Barolo')]);
      expect(h.timers.created, isEmpty);
      await h.store.flush();
      expect(h.file.commits, 0);
      expect(h.store.lookup('search:barolo'), isNotNull);
    });
  });

  group('saves (NFR2.3)', () {
    test('changes are grouped: one save every 2 seconds at most', () async {
      final h = _Harness();
      await h.store.open(_ownerA);
      h
        ..put('search:a', [_off('A')])
        ..put('search:b', [_off('B')])
        ..put('search:c', [_off('C')]);
      expect(h.timers.created, hasLength(1));
      expect(h.timers.created.single.duration, const Duration(seconds: 2));
      expect(h.file.commits, 0);
      await h.save();
      expect(h.file.commits, 1);
      expect(h.file.contents, contains('search:c'));
      // Nothing changed: no further save.
      await h.store.flush();
      expect(h.file.commits, 1);
    });

    test('two saves in a row are serialised and nothing is lost', () async {
      final h = _Harness();
      await h.store.open(_ownerA);
      h.put('search:a', [_off('A')]);
      h.file.writeGate = Completer<void>();
      h.timers.fireAll();
      await settle();
      // The first save is writing A; B arrives meanwhile.
      expect(h.file.temp, isNot(contains('search:b')));
      h.put('search:b', [_off('B')]);
      h.timers.fireAll();
      await settle();
      expect(h.file.commits, 0);
      h.file.writeGate!.complete();
      h.file.writeGate = null;
      await h.store.flush();
      expect(h.file.commits, 2);
      expect(
        h.file.contents,
        allOf(contains('search:a'), contains('search:b')),
      );
    });

    test('a failing write keeps the cache and saves again later', () async {
      final h = _Harness();
      await h.store.open(_ownerA);
      h.file.failWrites = true;
      h.put('search:a', [_off('A')]);
      await h.save();
      expect(
        h.logger.debugEvents,
        contains(CatalogDebugEvent.cacheWriteFailed),
      );
      expect(h.store.lookup('search:a'), isNotNull);
      h.file.failWrites = false;
      await h.store.flush();
      expect(h.file.contents, contains('search:a'));
    });

    test('dispose cancels the pending save', () async {
      final h = _Harness();
      await h.store.open(_ownerA);
      h.put('search:a', [_off('A')]);
      h.store.dispose();
      expect(h.timers.active, isEmpty);
    });
  });

  group('clear (NFR8.1)', () {
    test(
      'empties memory, cancels the pending save, deletes file and tmp',
      () async {
        final h = _Harness();
        await h.store.open(_ownerA);
        h.put('search:a', [_off('A', region: 'Piemonte')]);
        await h.save();
        h.put('search:b', [_off('B')]);
        h.file.temp = 'leftover';
        final epoch = h.store.epoch;

        await h.store.clear();

        expect(h.store.epoch, epoch + 1);
        expect(h.store.entryCount, 0);
        expect(h.store.hintCount, 0);
        expect(h.timers.active, isEmpty);
        expect(h.file.contents, isNull);
        expect(h.file.temp, isNull);
        expect(h.logger.debugEvents, contains(CatalogDebugEvent.cacheCleared));
      },
    );

    test('a save in progress during clear is never committed', () async {
      final h = _Harness();
      await h.store.open(_ownerA);
      h.put('search:secret', [_off('Secret wine')]);
      h.file.writeGate = Completer<void>();
      h.timers.fireAll();
      await settle();
      expect(h.file.temp, contains('search:secret'));

      final cleared = h.store.clear();
      h.file.writeGate!.complete();
      await cleared;

      expect(h.file.commits, 0);
      expect(h.file.contents, isNull);
      expect(h.file.temp, isNull);
    });

    test('a clear right after open wins over the load', () async {
      final h = _Harness();
      await h.store.open(_ownerA);
      h.put('search:a', [_off('A')]);
      await h.save();

      final again = _Harness(file: h.file);
      final opening = again.store.open(_ownerA);
      final clearing = again.store.clear();
      await Future.wait([opening, clearing]);
      expect(again.store.entryCount, 0);
      expect(again.file.contents, isNull);
    });

    test('a failing delete is reported and never throws', () async {
      final h = _Harness(file: InMemoryCacheFile()..failDeletes = true);
      await h.store.open(_ownerA);
      await h.store.clear();
      expect(
        h.logger.debugEvents,
        contains(CatalogDebugEvent.cacheWriteFailed),
      );
    });
  });
}
