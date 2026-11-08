import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../core/clock.dart';
import 'label_error_reporter.dart';

/// One file of the label folder.
class LabelFileEntry {
  const LabelFileEntry(this.path, this.modified);

  final String path;
  final DateTime modified;
}

/// The label folder as [TempLabelStore] sees it: the real one in the app,
/// an in-memory one in tests.
abstract interface class LabelFileSystem {
  /// The files of the folder; empty when it does not exist yet.
  Future<List<LabelFileEntry>> list();

  /// Deletes [path], which must be inside the folder. A missing file is not
  /// an error.
  Future<void> delete(String path);
}

/// `<temporary folder>/label/`, the folder `MainActivity` writes to
/// (`context.cacheDir/label`, the same as `getTemporaryDirectory()`).
class IoLabelFileSystem implements LabelFileSystem {
  IoLabelFileSystem({Future<Directory> Function()? temporaryDirectory})
    : _temporaryDirectory = temporaryDirectory ?? getTemporaryDirectory;

  final Future<Directory> Function() _temporaryDirectory;

  Future<Directory> get _folder async => Directory(
    '${(await _temporaryDirectory()).path}/${TempLabelStore.folderName}',
  );

  @override
  Future<List<LabelFileEntry>> list() async {
    final folder = await _folder;
    if (!folder.existsSync()) return const [];
    return [
      for (final entity in folder.listSync())
        if (entity is File)
          LabelFileEntry(entity.path, entity.statSync().modified),
    ];
  }

  @override
  Future<void> delete(String path) async {
    final file = File(path).absolute;
    // Never delete anything outside the label folder (the gallery original
    // is never touched, BR1.6). Both folders are compared with their
    // symlinks resolved: on Android `getTemporaryDirectory()` is usually
    // under /data/user/0, a symlink to /data/data (review R-01).
    final folder = await _resolved((await _folder).absolute);
    if (await _resolved(file.parent) != folder) {
      throw ArgumentError('not a label file');
    }
    if (file.existsSync()) await file.delete();
  }

  /// [directory] with its symlinks resolved, or as given when it does not
  /// exist (nothing to delete there then).
  static Future<String> _resolved(Directory directory) async {
    try {
      return await directory.resolveSymbolicLinks();
    } on FileSystemException {
      return directory.path;
    }
  }
}

/// The temporary copies of the label photo (BR1.6, NFR8.1).
///
/// - [startCleanup] empties the folder after the first frame, in the
///   background; every reading waits for it in [beforeRead], so the folder
///   is always emptied before any reading creates a file;
/// - [beforeRead] also deletes files older than [maxAge];
/// - [release] deletes the file of a reading as soon as it ends (success,
///   error, cancel, replacement, closed screen).
///
/// A file that cannot be deleted is reported as `label_cleanup_failed` and
/// retried at the next start or reading; nothing here throws.
///
/// label-recognition BR1.4: the front and back of the reading whose outcome
/// is open are [hold]: neither [beforeRead] (even after 10 minutes) nor
/// [release] delete them; [releaseCapture] deletes them when the outcome is
/// left, and [wipeAll] at start-up deletes whatever a killed process left.
class TempLabelStore {
  TempLabelStore({
    required this._files,
    required this._clock,
    required this._reporter,
  });

  /// Same name as `LabelImagePreparer.LABEL_DIR_NAME` in Kotlin.
  static const String folderName = 'label';

  /// No label file lives longer than this (NFR8.1).
  static const Duration maxAge = Duration(minutes: 10);

  final LabelFileSystem _files;
  final Clock _clock;
  final LabelErrorReporter _reporter;
  Future<void> _cleanup = Future<void>.value();
  final Set<String> _inUse = {};

  /// The start-up cleanup in progress (tests, start-up order).
  Future<void> get cleanup => _cleanup;

  /// The files of open outcomes (tests).
  Set<String> get inUse => Set.unmodifiable(_inUse);

  /// Starts the start-up cleanup: [wipeAll], then [alsoDiscard]
  /// (image_picker's lost data). Returns at once.
  void startCleanup({Future<void> Function()? alsoDiscard}) {
    _cleanup = _guard(() async {
      await _deleteWhere((_) => true);
      if (alsoDiscard != null) await alsoDiscard();
    });
  }

  /// Deletes every file of the folder not held by an open outcome: at
  /// start-up nothing is held, so the photos of a process killed while in
  /// Google Lens are gone (BR1.4, BR5.3, NFR4.12).
  Future<void> wipeAll() => _guard(() => _deleteWhere((_) => true));

  /// Before a reading creates a file: the start-up cleanup is over and no
  /// file older than [maxAge] is left, except the held ones.
  Future<void> beforeRead() async {
    await _cleanup;
    final limit = _clock.now().subtract(maxAge);
    await _guard(() => _deleteWhere((entry) => entry.modified.isBefore(limit)));
  }

  /// Keeps [path] while its outcome is open (BR1.4).
  void hold(String path) => _inUse.add(path);

  /// Deletes the file of a finished reading; `null` and held files do
  /// nothing.
  Future<void> release(String? path) async {
    if (path == null || _inUse.contains(path)) return;
    await _guard(() => _files.delete(path));
  }

  /// The outcome is left (confirm, write by hand, back, closed, cancelled):
  /// [paths] are no longer held and are deleted (BR1.4, FR1.3).
  Future<void> releaseCapture(Iterable<String> paths) async {
    final owned = [...paths];
    _inUse.removeAll(owned);
    for (final path in owned) {
      await release(path);
    }
  }

  Future<void> _deleteWhere(bool Function(LabelFileEntry entry) test) async {
    Object? firstError;
    StackTrace? firstStack;
    for (final entry in await _files.list()) {
      if (_inUse.contains(entry.path) || !test(entry)) continue;
      try {
        await _files.delete(entry.path);
      } catch (error, stack) {
        firstError ??= error;
        firstStack ??= stack;
      }
    }
    if (firstError != null) {
      Error.throwWithStackTrace(firstError, firstStack!);
    }
  }

  Future<void> _guard(Future<void> Function() work) async {
    try {
      await work();
    } catch (error, stack) {
      await _reporter.report(LabelFailure.cleanupFailed, error, stack);
    }
  }
}
