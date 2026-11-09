// The generated profile map (wine-style-profiles BR2.1-BR2.17, NFR4.2): the
// table generated from the study (generated/profile_map.g.dart) equals the
// functional-design fixture profile-map.json, combination by combination,
// and the estimate gives the same profile, type and window when it is
// called with the inputs of the fixture's "inputConvention".
import 'dart:convert';
import 'dart:io';

import 'package:estimation/estimation.dart';
import 'package:estimation/src/generated/profile_map.g.dart';
import 'package:estimation/src/profile_map.dart';
import 'package:test/test.dart';

/// The qualifier words appended to the name (inputConvention.qualifier).
const Map<String, String> _qualifierWords = {
  'grandCru': 'grand cru',
  'premierCru': 'premier cru',
  'granReserva': 'gran reserva',
  'granSelezione': 'gran selezione',
};

void main() {
  final fixture = jsonDecode(
    File('test/fixtures/profile-map.json').readAsStringSync(),
  ) as Map<String, Object?>;
  final combinations = (fixture['combinations']! as List)
      .cast<Map<String, Object?>>();

  test('BR2.17: version 3 of the tables and of the fixture', () {
    expect(estimationTablesVersion, 3);
    expect(fixture['estimationTablesVersion'], 3);
    expect(profileMapStudyVersion, '2026-11-08-draft');
  });

  test('every generated row parses and there are 5946 of them', () {
    expect(profileMapRows, hasLength(5946));
    expect(profileMap, hasLength(5946));
    expect(combinations, hasLength(5946));
  });

  test('a malformed row is rejected', () {
    expect(parseProfileMapRow('a|b'), isNull);
    expect(parseProfileMapRow('x|white|NOPE|3|profiled|||||||good'), isNull);
    expect(parseProfileMapRow('x|white|W_FRESH|z|profiled|||||||good'), isNull);
    expect(parseProfileMapRow('|white|W_FRESH|3|profiled|||||||good'), isNull);
    expect(parseProfileMapRow('x|white|W_FRESH|3|later|||||||good'), isNull);
  });

  test('NFR4.2: the generated table equals profile-map.json', () {
    final mismatches = <String>[];
    for (final e in combinations) {
      final entry = profileMap[e['id']];
      if (entry == null) {
        mismatches.add('${e['id']}: missing');
        continue;
      }
      final actual = {
        'type': entry.wineType?.name,
        'profile': entry.profile.id,
        'step': entry.step,
        'estimate': entry.estimate.name,
        'anchor': entry.anchor?.name,
        'unit': entry.unit?.name,
        'start': entry.start,
        'peak': entry.peak,
        'end': entry.end,
        'styleToConfirm': entry.styleToConfirm,
        'rowMakesType': entry.rowMakesType,
        'typeCorrected': entry.typeCorrected,
        'presetLevel': entry.presetLevel.name,
      };
      for (final MapEntry(:key, :value) in actual.entries) {
        if (e[key] != value) {
          mismatches.add('${e['id']}.$key: ${e[key]} != $value');
        }
      }
    }
    expect(mismatches, isEmpty);
  });

  test('BR2.17: the estimate gives each combination of the fixture', () {
    final mismatches = <String>[];
    final otherRow = <String>[];
    for (final e in combinations) {
      final qualifier = e['qualifier'] as String?;
      final name = e['name']! as String;
      final months = e['unit'] == 'months';
      final classic =
          e['studyType'] == 'sparklingClassic' ||
          e['type'] == 'sparklingClassic';
      final resolution = resolveStyle(
        WineFacts(
          name: qualifier == null
              ? name
              : '$name ${_qualifierWords[qualifier] ?? qualifier}',
          denomination: name,
          wineType: e['variant'] == 'otherType'
              ? WineType.tryParse(e['studyType'] as String?)
              : null,
          vintage: classic ? null : 2020,
          referenceYear: 2025,
          agingStartYear: months ? 2024 : null,
          agingStartMonth: months ? 3 : null,
        ),
      );
      if (resolution.denominationKey != e['key']) {
        // The name of the row is recognised as another, longer row: the
        // table test above covers its combination.
        otherRow.add('${e['id']} -> ${resolution.denominationKey}');
        continue;
      }
      final same =
          resolution.profile.id == e['profile'] &&
          resolution.wineType?.name == e['type'] &&
          resolution.styleToConfirm == e['styleToConfirm'] &&
          (e['estimate'] == 'none'
              ? resolution.hasNoWindow
              : resolution.start == e['start'] &&
                    resolution.peak == e['peak'] &&
                    resolution.end == e['end'] &&
                    resolution.unit?.name == e['unit'] &&
                    resolution.anchor?.name == e['anchor']);
      if (!same) mismatches.add('${e['id']}: $resolution');
    }
    expect(mismatches, isEmpty);
    // Exactly these names are recognised as another, longer row (Lagrein
    // in Alto Adige, Derthona in Colli Tortonesi); any other is an error.
    expect(otherRow, [
      'lagrein:base:redLight -> altoAdige',
      'lagrein:qualifier:riserva -> altoAdige',
      'derthona:base:white -> colliTortonesiIT',
    ]);
  });

  test('the window of a combination is the profile window or kept', () {
    for (final entry in profileMap.values) {
      if (entry.estimate == MapEstimate.none) {
        expect(entry.start, isNull, reason: entry.id);
        continue;
      }
      expect(entry.start, isNotNull, reason: entry.id);
      if (!entry.keepsLegacyWindow) {
        expect(entry.unit, entry.profile.unit, reason: entry.id);
      }
    }
  });

  test('profileMapIdOf builds the three kinds of id', () {
    expect(
      profileMapIdOf(
        'barolo',
        WineType.redStructured,
        WineType.redStructured,
        null,
      ),
      'barolo:base:redStructured',
    );
    expect(
      profileMapIdOf(
        'barolo',
        WineType.redStructured,
        WineType.redStructured,
        Qualifier.riserva,
      ),
      'barolo:qualifier:riserva',
    );
    expect(
      profileMapIdOf(
        'langhe',
        WineType.redLight,
        WineType.white,
        Qualifier.riserva,
      ),
      'langhe:otherType:white',
    );
  });
}
