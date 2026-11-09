// The raw-line filter of tool/build_wine_db.dart (wine-style-profiles
// NFR3.3, loop-back 1): lines without `en:wines` are counted as non-wine
// rows without being decoded; the result is the one of reading every line
// with LineSplitter, whatever the chunks, the line breaks and the case.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/build_wine_db.dart';

const _sample = 'tool/fixtures/off_wines_sample.csv';

/// The reading of every line, as before the filter.
ExportReader _readAll(String text) {
  final reader = ExportReader();
  const LineSplitter().convert(text).forEach(reader.addLine);
  return reader;
}

/// The filtered reading, the bytes given in chunks of [chunk] bytes.
ExportReader _readFiltered(String text, int chunk) {
  final reader = ExportReader();
  final bytes = utf8.encode(text);
  final filter = RawLineFilter(reader);
  for (var i = 0; i < bytes.length; i += chunk) {
    filter.add(
      bytes.sublist(i, i + chunk > bytes.length ? bytes.length : i + chunk),
    );
  }
  filter.close();
  return reader;
}

void _expectSame(ExportReader filtered, ExportReader all) {
  expect(filtered.rows, all.rows);
  expect(filtered.dropped, all.dropped);
  expect(
    filtered.records.map((r) => r.toJsonLine()).toList(),
    all.records.map((r) => r.toJsonLine()).toList(),
  );
}

void main() {
  final sample = File(_sample).readAsStringSync();
  final header = sample.substring(0, sample.indexOf('\n'));

  String row(String code, String name, String tags) =>
      '$code\t$name\tCantina\t$tags\t\ten:italy\t750 ml\tsomeone\t1700000000';

  final extra = [
    row('8001234567897', 'Barolo maiuscolo', 'EN:Beverages,EN:WINES'),
    row('3000000000014', 'Succo di mela', 'en:beverages,en:juices'),
    row('3000000000021', 'Cioccolato al vino', 'en:snacks'),
    row('3000000000038', 'Hard Seltzer', 'en:wines,en:white-wines'),
    '   ',
    '',
  ].join('\r\n');

  test('the sample export: same rows, drops and wines as before', () {
    for (final chunk in [1, 7, 64, 4096]) {
      _expectSame(_readFiltered(sample, chunk), _readAll(sample));
    }
    expect(_readAll(sample).records, isNotEmpty);
  });

  test('wine lines kept, others dropped as notWine, with CR LF and '
      'upper case tags, in any chunk size', () {
    final text = '$header\n$extra\rlast line without break en:wines';
    for (final chunk in [1, 3, 50, 1 << 16]) {
      final filtered = _readFiltered(text, chunk);
      final all = _readAll(text);
      _expectSame(filtered, all);
    }
    final all = _readAll(text);
    expect(all.dropped[DropReason.notWine], 3);
    expect(all.records.single.name, 'Barolo maiuscolo');
    expect(all.dropped[DropReason.excludedCategory], 1);
  });

  test('mayBeWineLine is conservative: any case of en:wines', () {
    expect(mayBeWineLine('x\ten:wines,en:red'), isTrue);
    expect(mayBeWineLine('x\tEN:WINES'), isTrue);
    expect(mayBeWineLine('x\ten:beverages'), isFalse);
  });
}
