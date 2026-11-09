// The 24 profiles and the style keys (wine-style-profiles BR1.1-BR1.4,
// BR5.2, ENT-101, ENT-102), compared with the study as copied into the
// functional-design fixture profile-map.json.
import 'dart:convert';
import 'dart:io';

import 'package:estimation/estimation.dart';
import 'package:test/test.dart';

void main() {
  final fixture = jsonDecode(
    File('test/fixtures/profile-map.json').readAsStringSync(),
  ) as Map<String, Object?>;
  final studyProfiles = (fixture['profiles']! as List).cast<Map>();

  group('BR1.1 profiles of the study', () {
    test('24 profiles, in the order of the study', () {
      expect(StyleProfile.values.map((p) => p.id).toList(), [
        for (final p in studyProfiles) p['id'],
      ]);
    });

    for (final study in studyProfiles) {
      test('${study['id']} has the study numbers, anchor and unit', () {
        final profile = StyleProfile.tryParse(study['id'])!;
        expect(profile.anchor?.name, study['anchor']);
        expect(profile.unit?.name, study['unit']);
        expect(
          [profile.start, profile.peak, profile.end],
          [study['start'], study['peak'], study['end']],
        );
        expect(profile.evidence.studyName, study['evidence']);
        expect(profile.sources, study['sources']);
      });
    }

    test('BR1.2: no invented end, the unclear profiles have no numbers', () {
      expect(StyleProfile.portLbv.end, isNull);
      expect(StyleProfile.portOx.peak, isNull);
      expect(StyleProfile.shFino.peak, isNull);
      expect(StyleProfile.shFino.end, 12);
      for (final p in [StyleProfile.unknown, StyleProfile.fortUnknown]) {
        expect(p.isUnclear, isTrue);
        expect([p.anchor, p.unit, p.start, p.peak, p.end], everyElement(null));
      }
      expect(StyleProfile.rLong.isUnclear, isFalse);
    });

    test('tryParse reads only the study identifiers', () {
      expect(StyleProfile.tryParse('SP_TANK'), StyleProfile.spTank);
      expect(StyleProfile.tryParse('sp_tank'), isNull);
      expect(StyleProfile.tryParse(3), isNull);
      expect(StyleProfile.tryParse(null), isNull);
    });

    test('fresh profiles for the level (BR4.3)', () {
      expect(
        StyleProfile.values.where((p) => p.freshForLevel).map((p) => p.id),
        unorderedEquals([
          'R_FRESH',
          'W_FRESH',
          'ROSE_FRESH',
          'SP_TANK',
          'LAM_FRESH',
          'SW_AROMATIC',
        ]),
      );
    });
  });

  group('BR1.4 style keys', () {
    test('24 keys; madeira and fortifiedOther share FORT_UNKNOWN', () {
      expect(WineStyle.values, hasLength(24));
      expect(WineStyle.madeira.profile, StyleProfile.fortUnknown);
      expect(WineStyle.fortifiedOther.profile, StyleProfile.fortUnknown);
      expect(WineStyle.portTawny.profile, StyleProfile.portOx);
      expect(
        WineStyle.values.map((s) => s.profile),
        isNot(contains(StyleProfile.unknown)),
      );
    });

    test('tryParse: an unknown key is no style (NFR2.1)', () {
      expect(WineStyle.tryParse('classicAge'), WineStyle.classicAge);
      expect(WineStyle.tryParse('UNKNOWN'), isNull);
      expect(WineStyle.tryParse(''), isNull);
      expect(WineStyle.tryParse(null), isNull);
    });

    test('BR5.2 options per type', () {
      expect(WineStyle.optionsFor(WineType.sparklingClassic), [
        WineStyle.classicFresh,
        WineStyle.classicAge,
      ]);
      expect(WineStyle.optionsFor(WineType.sparklingTank), [
        WineStyle.tankFresh,
        WineStyle.lambrusco,
      ]);
      expect(WineStyle.optionsFor(WineType.sweet), hasLength(3));
      expect(WineStyle.optionsFor(WineType.fortified), hasLength(9));
      expect(WineStyle.optionsFor(WineType.redLight), [
        WineStyle.redFresh,
        WineStyle.redMedium,
        WineStyle.redAge,
        WineStyle.redLong,
      ]);
      expect(
        WineStyle.optionsFor(WineType.redStructured),
        WineStyle.optionsFor(WineType.redLight),
      );
      expect(WineStyle.optionsFor(WineType.white), hasLength(3));
      expect(WineStyle.optionsFor(WineType.rose), [WineStyle.roseFresh]);
    });

    test('BR8.1 date label of the months profiles', () {
      expect(WineStyle.classicAge.agingStartLabel, AgingAnchor.disgorgement);
      expect(WineStyle.tankFresh.agingStartLabel, AgingAnchor.bottling);
      expect(WineStyle.sherryPx.agingStartLabel, AgingAnchor.bottling);
      expect(WineStyle.portVintage.agingStartLabel, isNull);
      expect(WineStyle.redLong.agingStartLabel, isNull);
      expect(WineStyle.madeira.agingStartLabel, isNull);
    });

    test('ofProfile (BR5.3)', () {
      expect(WineStyle.ofProfile(StyleProfile.unknown), isNull);
      expect(
        WineStyle.ofProfile(StyleProfile.fortUnknown),
        WineStyle.fortifiedOther,
      );
      expect(
        WineStyle.ofProfile(
          StyleProfile.fortUnknown,
          madeiraDenomination: true,
        ),
        WineStyle.madeira,
      );
      for (final style in WineStyle.values) {
        if (style.profile.isUnclear) continue;
        expect(WineStyle.ofProfile(style.profile), style);
      }
    });
  });
}
