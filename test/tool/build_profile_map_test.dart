// tool/build_profile_map.dart (wine-style-profiles Step 1, D1, D9, BR2):
// the study database converted from the Excel workbook holds 24 profiles
// and 5946 combinations; the map built from it equals the functional-design
// fixture profile-map.json; the generated Dart table in the package is the
// one the generator writes now (no hand edits, no stale table).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/build_profile_map.dart';

const _studyPath = 'tool/data/study/study_db.json';
const _fixture = 'packages/estimation/test/fixtures/profile-map.json';

Map<String, Object?> _json(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, Object?>;

void main() {
  late Study study;
  late Map<String, List<String>> generatedTypes;
  late List<ProfileMapEntry> entries;

  setUpAll(() {
    study = Study.fromJson(_json(_studyPath));
    generatedTypes = generatedTypesOf(
      File(defaultAppellations).readAsStringSync(),
    );
    entries = buildProfileMap(study, generatedTypes);
  });

  test('the study database: 24 profiles, 5946 combinations, version', () {
    final db = _json(_studyPath);
    final meta = db['study']! as Map<String, Object?>;
    expect(meta['date'], '2026-11-08');
    expect(meta['version'], '2026-11-08-draft');
    expect(meta['sourceSha256'], isA<String>());
    expect(study.profiles.keys, profileOrder);
    expect(study.rows, hasLength(5946));
    expect(study.reviewedKeys, hasLength(60));
    expect(((db['sources']! as Map)['rows']! as List), isNotEmpty);
    expect(study.typeWindows['generic'], [1, 3, 6]);
  });

  test('the generated types of the 1700 generated rows', () {
    expect(generatedTypes, hasLength(1700));
    expect(generatedTypes['25DeMayoAR'], ['redLight', 'white', 'rose']);
  });

  test('NFR4.2: the map built from the study equals profile-map.json', () {
    final fixture = (_json(_fixture)['combinations']! as List)
        .cast<Map<String, Object?>>();
    expect(entries, hasLength(fixture.length));
    final mismatches = <String>[];
    for (var i = 0; i < fixture.length; i++) {
      final expected = fixture[i];
      final actual = entries[i].toJson();
      for (final field in const [
        'id',
        'type',
        'typeCorrected',
        'rowMakesType',
        'profile',
        'step',
        'estimate',
        'anchor',
        'unit',
        'start',
        'peak',
        'end',
        'levelApplies',
        'presetLevel',
        'styleToConfirm',
      ]) {
        if (expected[field] != actual[field]) {
          mismatches.add('${expected['id']}.$field');
        }
      }
      final code = (expected['deviation'] as Map?)?['code'];
      if (code != actual['deviationCode']) {
        mismatches.add('${expected['id']}.deviation');
      }
    }
    expect(mismatches, isEmpty);
  });

  test('the generated table in the package is the one of the study', () {
    expect(
      File(defaultOutput).readAsStringSync(),
      renderProfileMap(entries, study),
    );
  });

  test('a broken study writes nothing (StateError)', () {
    final db = _json(_studyPath);
    final profiles = db['profiles']! as Map<String, Object?>;
    final rows = (profiles['rows']! as List).toList()..removeLast();
    expect(
      () => Study.fromJson({
        ...db,
        'profiles': {...profiles, 'rows': rows},
      }),
      throwsStateError,
    );
  });

  test(
    'the command writes the table and the JSON; bad arguments exit 2',
    () async {
      final temp = Directory.systemTemp.createTempSync('profile_map');
      addTearDown(() => temp.deleteSync(recursive: true));
      expect(
        await runBuildProfileMap([
          '--output',
          '${temp.path}/map.g.dart',
          '--json',
          '${temp.path}/map.json',
        ]),
        0,
      );
      expect(
        File('${temp.path}/map.g.dart').readAsStringSync(),
        File(defaultOutput).readAsStringSync(),
      );
      expect(
        (jsonDecode(
          File('${temp.path}/map.json').readAsStringSync(),
        ) as List).length,
        5946,
      );
      expect(await runBuildProfileMap(['--output']), 2);
      expect(
        await runBuildProfileMap(['--study', '${temp.path}/missing.json']),
        1,
      );
    },
  );
}
