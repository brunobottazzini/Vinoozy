// The 100-wine sample of the functional design (wine-style-profiles NFR4.3,
// BR9.5): blocking thresholds of the preselection.
import 'dart:convert';
import 'dart:io';

import 'package:estimation/estimation.dart';
import 'package:test/test.dart';

void main() {
  final sample = jsonDecode(
    File('test/fixtures/classification-sample.json').readAsStringSync(),
  ) as Map<String, Object?>;
  final wines = (sample['wines']! as List).cast<Map<String, Object?>>();

  Preselection classify(Map<String, Object?> w) => classifyWine(
    w['name']! as String,
    producer: w['producer'] as String?,
    denomination: w['denomination'] as String?,
    dbType: WineType.tryParse(w['dbType'] as String?),
    country: w['country'] as String?,
    vintage: w['vintage'] as int?,
  );

  test('NFR4.3 thresholds on the preselected wines', () {
    var preselected = 0;
    var typeRight = 0;
    var levelRight = 0;
    var styleRight = 0;
    var alwaysGood = 0;
    var tuningPreselected = 0;
    var tuningType = 0;
    for (final w in wines) {
      final expected = w['expected']! as Map<String, Object?>;
      final p = classify(w);
      if (p.wineType == null) continue;
      preselected++;
      final typeOk = p.wineType!.name == expected['wineType'];
      if (typeOk) typeRight++;
      if (p.level.name == expected['level']) levelRight++;
      if (p.style?.name == expected['style']) styleRight++;
      if (expected['level'] == 'good') alwaysGood++;
      if (w['usedForTuning'] != true) {
        tuningPreselected++;
        if (typeOk) tuningType++;
      }
    }
    final typeShare = typeRight / preselected;
    final levelShare = levelRight / preselected;
    final alwaysGoodShare = alwaysGood / preselected;
    // ignore: avoid_print
    print(
      'sample: $preselected preselected; type $typeRight '
      '(${(typeShare * 100).toStringAsFixed(1)}%), level $levelRight '
      '(${(levelShare * 100).toStringAsFixed(1)}%), always-good '
      '${(alwaysGoodShare * 100).toStringAsFixed(1)}%, style $styleRight '
      '(informative); rows not used for tuning: type '
      '$tuningType/$tuningPreselected',
    );
    expect(typeShare, greaterThanOrEqualTo(0.95));
    expect(levelShare, greaterThanOrEqualTo(0.85));
    expect(levelShare, greaterThan(alwaysGoodShare));
  });

  test('wines with no clue stay without a type', () {
    for (final w in wines.where((w) => w['clue'] == 'none')) {
      expect(classify(w).wineType, isNull, reason: '${w['name']}');
    }
  });
}
