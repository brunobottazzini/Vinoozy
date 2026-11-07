// `catalog_cache.json` in the private app support directory (BR2.1, NFR8.1).
// On Android that directory is in the `file` domain, which U1's
// data_extraction_rules.xml already excludes from cloud backup and device
// transfer (security-design.md §5, test/catalog/backup_rules_test.dart).

import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../core/catalog_cache_store.dart';

/// [CacheFile] on disk: written to `catalog_cache.json.tmp`, then renamed,
/// so an interruption never leaves half a file (reliability-design.md).
class FileCacheFile implements CacheFile {
  FileCacheFile({Future<Directory> Function()? directory})
    : _directory = directory ?? getApplicationSupportDirectory;

  static const String fileName = 'catalog_cache.json';
  static const String tempFileName = '$fileName.tmp';

  final Future<Directory> Function() _directory;
  Future<Directory>? _resolved;

  Future<File> _fileNamed(String name) async {
    final directory = await (_resolved ??= _directory());
    return File('${directory.path}${Platform.pathSeparator}$name');
  }

  @override
  Future<String?> read() async {
    final file = await _fileNamed(fileName);
    if (!await file.exists()) return null;
    // A file that is not UTF-8 throws: the store then empties the cache.
    return file.readAsString();
  }

  @override
  Future<void> writeTemp(String contents) async {
    final temp = await _fileNamed(tempFileName);
    await temp.parent.create(recursive: true);
    await temp.writeAsString(contents, flush: true);
  }

  @override
  Future<void> commitTemp() async {
    final temp = await _fileNamed(tempFileName);
    final file = await _fileNamed(fileName);
    await temp.rename(file.path);
  }

  @override
  Future<void> deleteTemp() async => _deleteIfExists(tempFileName);

  @override
  Future<void> deleteAll() async {
    await _deleteIfExists(fileName);
    await _deleteIfExists(tempFileName);
  }

  Future<void> _deleteIfExists(String name) async {
    final file = await _fileNamed(name);
    if (await file.exists()) await file.delete();
  }
}
