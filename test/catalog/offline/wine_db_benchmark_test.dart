// Speed of the offline database on CI (label-recognition NFR2.1, NFR2.2,
// NFR2.7): a synthetic database of 20,000 and 50,000 wines generated with a
// fixed seed (no real data), 1,000 barcode lookups within 50 ms in all, and
// a 4,000-character label compared with the whole database within 600 ms
// (the phone limit is 300 ms; x2 margin for CI machines). The thresholds are
// inputs: never raise them to make the job pass.
@Tags(['benchmark'])
library;

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/catalog/core/offline/wine_db_index.dart';
import 'package:vinoozy/catalog/core/offline/wine_db_record.dart';

const _syllables = [
  'ba',
  'ro',
  'lo',
  'ne',
  'bi',
  'ol',
  'ca',
  'nu',
  'mo',
  'ri',
  'va',
  'te',
  'sa',
  'gi',
  'ov',
  'es',
  'tu',
  'ra',
  'li',
  'pe',
  'ma',
  'do',
  'chi',
  'an',
];

String _word(Random random) {
  final length = 2 + random.nextInt(3);
  return [
    for (var i = 0; i < length; i++)
      _syllables[random.nextInt(_syllables.length)],
  ].join();
}

List<WineDbRecord> _synthetic(int count, Random random) => [
  for (var i = 0; i < count; i++)
    WineDbRecord(
      code: (8000000000000 + i).toString(),
      name: '${_word(random)} ${_word(random)} ${_word(random)}',
      producer: 'Cantina ${_word(random)}',
      denomination: random.nextBool() ? '${_word(random)} DOC' : null,
      vintage: random.nextInt(4) == 0 ? null : 1990 + random.nextInt(35),
    ),
];

String _label(Random random) {
  final buffer = StringBuffer();
  while (buffer.length < 4000) {
    buffer.write('${_word(random)} ');
  }
  return buffer.toString().substring(0, 4000);
}

void main() {
  for (final size in [20000, 50000]) {
    group('NFR2.7 $size wines', () {
      final random = Random(20261107);
      final index = WineDbIndex.build(_synthetic(size, random));
      final label = _label(random);

      test('NFR2.1 1,000 barcode lookups take at most 50 ms in all', () {
        final codes = [
          for (var i = 0; i < 1000; i++)
            (8000000000000 + random.nextInt(size * 2)).toString(),
        ];
        for (final code in codes.take(100)) {
          index.byBarcode(code);
        }
        final stopwatch = Stopwatch()..start();
        var found = 0;
        for (final code in codes) {
          if (index.byBarcode(code) != null) found++;
        }
        stopwatch.stop();
        expect(found, greaterThan(0));
        expect(stopwatch.elapsedMilliseconds, lessThanOrEqualTo(50));
      });

      test('NFR2.2 a 4,000-character label against every wine takes at most '
          '600 ms', () {
        expect(label, hasLength(4000));
        index.matchText(label);
        final stopwatch = Stopwatch()..start();
        final found = index.matchText(label);
        stopwatch.stop();
        expect(found.length, lessThanOrEqualTo(10));
        expect(stopwatch.elapsedMilliseconds, lessThanOrEqualTo(600));
      });
    });
  }
}
