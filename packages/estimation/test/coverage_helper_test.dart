// Imports every file of lib/ so that a file without tests counts as 0% in
// the package coverage instead of disappearing from it (NFR7.1, as
// tool/gen_coverage_helper.dart does for the app). The test below fails when
// a file is added to or removed from lib/ without updating this list.
// ignore_for_file: unused_import, unnecessary_import
import 'dart:io';

import 'package:estimation/estimation.dart';
import 'package:estimation/src/appellations.dart';
import 'package:estimation/src/catalog.dart';
import 'package:estimation/src/country_names.dart';
import 'package:estimation/src/effective_window.dart';
import 'package:estimation/src/errors.dart';
import 'package:estimation/src/europe_tables.dart';
import 'package:estimation/src/france_tables.dart';
import 'package:estimation/src/generated/appellations.g.dart';
import 'package:estimation/src/grapes.dart';
import 'package:estimation/src/italy_tables.dart';
import 'package:estimation/src/label_fields.dart';
import 'package:estimation/src/label_line_picker.dart';
import 'package:estimation/src/models.dart';
import 'package:estimation/src/new_world_tables.dart';
import 'package:estimation/src/pairings.dart';
import 'package:estimation/src/qualifiers.dart';
import 'package:estimation/src/recognizer.dart';
import 'package:estimation/src/status.dart';
import 'package:estimation/src/tables.dart';
import 'package:estimation/src/validation.dart';
import 'package:estimation/src/vintage_parser.dart';
import 'package:estimation/src/window.dart';
import 'package:estimation/src/wine_level.dart';
import 'package:estimation/src/world_tables.dart';
import 'package:test/test.dart';

const importedLibFiles = [
  'estimation.dart',
  'src/appellations.dart',
  'src/catalog.dart',
  'src/country_names.dart',
  'src/effective_window.dart',
  'src/errors.dart',
  'src/europe_tables.dart',
  'src/france_tables.dart',
  'src/generated/appellations.g.dart',
  'src/grapes.dart',
  'src/italy_tables.dart',
  'src/label_fields.dart',
  'src/label_line_picker.dart',
  'src/models.dart',
  'src/new_world_tables.dart',
  'src/pairings.dart',
  'src/qualifiers.dart',
  'src/recognizer.dart',
  'src/status.dart',
  'src/tables.dart',
  'src/validation.dart',
  'src/vintage_parser.dart',
  'src/window.dart',
  'src/wine_level.dart',
  'src/world_tables.dart',
];

/// Parts of src/label_fields.dart (label-autofill-windows D7): they cannot be
/// imported and are covered through their library, imported above.
const partFiles = [
  'src/label_candidates.dart',
  'src/label_lines.dart',
  'src/label_scoring.dart',
  'src/label_words.dart',
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
    expect(onDisk, [...importedLibFiles, ...partFiles]..sort());
    for (final path in partFiles) {
      expect(
        File('lib/$path').readAsStringSync(),
        contains("part of 'label_fields.dart';"),
        reason: path,
      );
    }

    final source = File('test/coverage_helper_test.dart').readAsStringSync();
    for (final path in importedLibFiles) {
      final uri = path == 'estimation.dart'
          ? 'package:estimation/estimation.dart'
          : 'package:estimation/$path';
      expect(source, contains("import '$uri';"), reason: path);
    }
  });
}
