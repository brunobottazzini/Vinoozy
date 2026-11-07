// Imports every file of lib/ so that a file without tests counts as 0% in
// the package coverage instead of disappearing from it (NFR7.1, as
// tool/gen_coverage_helper.dart does for the app). The test below fails when
// a file is added to or removed from lib/ without updating this list.
// ignore_for_file: unused_import, unnecessary_import
import 'dart:io';

import 'package:estimation/estimation.dart';
import 'package:estimation/src/catalog.dart';
import 'package:estimation/src/errors.dart';
import 'package:estimation/src/models.dart';
import 'package:estimation/src/pairings.dart';
import 'package:estimation/src/recognizer.dart';
import 'package:estimation/src/status.dart';
import 'package:estimation/src/tables.dart';
import 'package:estimation/src/validation.dart';
import 'package:estimation/src/window.dart';
import 'package:test/test.dart';

const importedLibFiles = [
  'estimation.dart',
  'src/catalog.dart',
  'src/errors.dart',
  'src/models.dart',
  'src/pairings.dart',
  'src/recognizer.dart',
  'src/status.dart',
  'src/tables.dart',
  'src/validation.dart',
  'src/window.dart',
];

void main() {
  test('the imports above cover exactly the files of lib/', () {
    final onDisk =
        Directory('lib')
            .listSync(recursive: true)
            .whereType<File>()
            .map((file) => file.path.replaceAll(r'\', '/'))
            .where((path) => path.endsWith('.dart'))
            .map((path) => path.substring('lib/'.length))
            .toList()
          ..sort();
    expect(onDisk, importedLibFiles);

    final source = File('test/coverage_helper_test.dart').readAsStringSync();
    for (final path in importedLibFiles) {
      final uri = path == 'estimation.dart'
          ? 'package:estimation/estimation.dart'
          : 'package:estimation/$path';
      expect(source, contains("import '$uri';"), reason: path);
    }
  });
}
