import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/label/platform/label_error_reporter.dart';
import 'package:vinoozy/label/platform/temp_label_store.dart';

import '../../helpers/fakes.dart';
import '../label_harness.dart';

void main() {
  late InMemoryLabelFileSystem files;
  late RecordingErrorSink sink;
  late FakeClock clock;
  late TempLabelStore store;

  setUp(() {
    files = InMemoryLabelFileSystem();
    sink = RecordingErrorSink();
    clock = FakeClock(DateTime(2026, 11, 6, 20));
    store = TempLabelStore(
      files: files,
      clock: clock,
      reporter: LabelErrorReporter(recordingReporter(sink)),
    );
  });

  group('BR1.6 temporary copies', () {
    test('BR1.6 the start-up cleanup empties the folder and discards the '
        'lost picker data', () async {
      files
        ..add('/cache/label/a.jpg', clock.current)
        ..add('/cache/label/b.share', clock.current);
      var discarded = false;
      store.startCleanup(alsoDiscard: () async => discarded = true);
      await store.cleanup;
      expect(files.files, isEmpty);
      expect(discarded, isTrue);
      expect(sink.recorded, isEmpty);
    });

    test('BR1.6 a reading waits for the start-up cleanup before creating a '
        'file', () async {
      files
        ..add('/cache/label/left.jpg', clock.current)
        ..listGate = Completer<void>();
      store.startCleanup();
      var ready = false;
      final before = store.beforeRead().then((_) => ready = true);
      await Future<void>.delayed(Duration.zero);
      expect(ready, isFalse, reason: 'still cleaning');
      files.listGate!.complete();
      await before;
      expect(ready, isTrue);
      expect(files.files, isEmpty);
    });

    test('BR1.6 files older than 10 minutes go before a new reading', () async {
      files
        ..add(
          '/cache/label/old.jpg',
          clock.current.subtract(const Duration(minutes: 11)),
        )
        ..add(
          '/cache/label/new.jpg',
          clock.current.subtract(const Duration(minutes: 2)),
        );
      await store.beforeRead();
      expect(files.files.keys, ['/cache/label/new.jpg']);
    });

    test(
      'BR1.6 release deletes the file of a reading; null does nothing',
      () async {
        files.add('/cache/label/r.jpg', clock.current);
        await store.release('/cache/label/r.jpg');
        await store.release(null);
        expect(files.deleted, ['/cache/label/r.jpg']);
      },
    );

    test('BR1.14 a file that cannot be deleted is reported as '
        'label_cleanup_failed, without its path', () async {
      files
        ..add(labelMarkers.last, clock.current)
        ..add('/cache/label/ok.jpg', clock.current)
        ..undeletable.add(labelMarkers.last);
      await store.release(labelMarkers.last);
      store.startCleanup(alsoDiscard: () async => throw StateError('picker'));
      await store.cleanup;
      expect(files.files.keys, [labelMarkers.last], reason: 'others deleted');
      expect(sink.reasons, ['label_cleanup_failed', 'label_cleanup_failed']);
      for (final recorded in sink.recorded) {
        expect(recorded.error.toString(), isNot(contains('MARKER')));
      }
    });
  });

  group('BR1.4 photos of an open outcome (label-recognition)', () {
    const front = '/cache/label/front.jpg';
    const back = '/cache/label/back.jpg';

    test('NFR3.4 held files survive the 10-minute cleanup and the end of '
        'the reading', () async {
      final old = clock.current.subtract(const Duration(minutes: 30));
      files
        ..add(front, old)
        ..add(back, old)
        ..add('/cache/label/stray.jpg', old);
      store
        ..hold(front)
        ..hold(back);
      await store.beforeRead();
      await store.release(front);
      expect(files.files.keys, unorderedEquals([front, back]));
      expect(store.inUse, {front, back});
    });

    test(
      'FR1.3 leaving the outcome releases and deletes front and back',
      () async {
        files
          ..add(front, clock.current)
          ..add(back, clock.current);
        store
          ..hold(front)
          ..hold(back);
        await store.releaseCapture([front, back]);
        expect(files.files, isEmpty);
        expect(store.inUse, isEmpty);
      },
    );

    test('NFR4.12 at start-up every leftover photo is deleted (process '
        'killed while in Google Lens)', () async {
      files
        ..add(front, clock.current)
        ..add(back, clock.current);
      await store.wipeAll();
      expect(files.files, isEmpty);
      store.startCleanup();
      await store.cleanup;
      expect(sink.recorded, isEmpty);
    });

    test('a held file is not wiped while its outcome is open', () async {
      files
        ..add(front, clock.current)
        ..add('/cache/label/other.jpg', clock.current);
      store.hold(front);
      await store.wipeAll();
      expect(files.files.keys, [front]);
    });
  });

  group('BR1.6 IoLabelFileSystem', () {
    late Directory root;

    setUp(() async {
      root = await Directory.systemTemp.createTemp('vinoozy_label_test');
    });
    tearDown(() async {
      if (root.existsSync()) await root.delete(recursive: true);
    });

    test('BR1.6 lists and deletes only inside <temp>/label', () async {
      final system = IoLabelFileSystem(temporaryDirectory: () async => root);
      expect(await system.list(), isEmpty, reason: 'no folder yet');
      final folder = Directory('${root.path}/${TempLabelStore.folderName}')
        ..createSync();
      final inside = File('${folder.path}/x.jpg')..writeAsStringSync('x');
      final outside = File('${root.path}/gallery.jpg')..writeAsStringSync('g');
      Directory('${folder.path}/sub').createSync();
      final listed = await system.list();
      expect(listed.map((entry) => entry.path), [inside.path]);
      await system.delete(inside.path);
      await system.delete(inside.path);
      expect(inside.existsSync(), isFalse);
      await expectLater(system.delete(outside.path), throwsArgumentError);
      expect(
        outside.existsSync(),
        isTrue,
        reason: 'the original is never touched',
      );
    });

    test('BR1.6 a temporary folder behind a symlink: the canonical path '
        'from Kotlin is deleted, outside paths still refused (R-01)', () async {
      // Like Android: getTemporaryDirectory() is /data/user/0/<pkg>/cache,
      // /data/user/0 links to /data/data, and the native side may report
      // either form of the path.
      final real = Directory('${root.path}/data/cache')
        ..createSync(recursive: true);
      final link = Link('${root.path}/user0-cache')..createSync(real.path);
      final system = IoLabelFileSystem(
        temporaryDirectory: () async => Directory(link.path),
      );
      final realLabel = Directory('${real.path}/${TempLabelStore.folderName}')
        ..createSync();
      final canonical = File('${realLabel.path}/a.jpg')..writeAsStringSync('a');
      final throughLink = File(
        '${link.path}/${TempLabelStore.folderName}/b.jpg',
      )..writeAsStringSync('b');

      await system.delete(canonical.path);
      await system.delete(throughLink.path);
      expect(canonical.existsSync(), isFalse);
      expect(File('${realLabel.path}/b.jpg').existsSync(), isFalse);
      expect(await system.list(), isEmpty);

      final outside = File('${real.path}/gallery.jpg')..writeAsStringSync('g');
      final sibling = Directory('${real.path}/labels')..createSync();
      final lookalike = File('${sibling.path}/c.jpg')..writeAsStringSync('c');
      await expectLater(system.delete(outside.path), throwsArgumentError);
      await expectLater(system.delete(lookalike.path), throwsArgumentError);
      await expectLater(
        system.delete('${link.path}/${TempLabelStore.folderName}/../x.jpg'),
        throwsArgumentError,
      );
      expect(outside.existsSync() && lookalike.existsSync(), isTrue);
    });

    test('BR1.6 a missing folder refuses a path elsewhere and accepts a '
        'gone file inside', () async {
      final system = IoLabelFileSystem(temporaryDirectory: () async => root);
      await system.delete('${root.path}/${TempLabelStore.folderName}/gone.jpg');
      await expectLater(
        system.delete('${root.path}/elsewhere/gone.jpg'),
        throwsArgumentError,
      );
    });
  });
}
