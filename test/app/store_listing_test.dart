// tester-feedback FR3.1-FR3.4, review R-04: the 25 Google Play listings
// keep Play's length limits, open with a paragraph followed by a bulleted
// list of at least 6 features, avoid the words Play's metadata policy
// forbids, and the Italian and English ones carry at least 5 of their fixed
// search keywords.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const String _root = 'distribution/google-play';

/// R-04: the fixed keyword lists of the plan (Step 15).
const Map<String, List<String>> _keywords = {
  'it-IT': [
    'cantina',
    'vino',
    'vini',
    'gestione cantina',
    'etichetta',
    'quando bere',
    'finestra di consumo',
    'abbinamenti',
  ],
  'en-US': [
    'wine cellar',
    'wine',
    'cellar manager',
    'wine inventory',
    'wine label',
    'drinking window',
    'when to drink',
    'food pairing',
  ],
};

/// Words Play's metadata policy rejects (rankings, "best"), anywhere. Word
/// edges are letter-aware: "Bestätigung" is not "best".
final RegExp _forbidden = RegExp(
  r'((?<!\p{L})(migliore|best)(?!\p{L})|#1|(?<!\p{L})n\. ?1(?!\d))',
  caseSensitive: false,
  unicode: true,
);

/// Price words never allowed in a title.
final RegExp _forbiddenInTitle = RegExp(
  r'(?<!\p{L})(gratis|free)(?!\p{L})',
  caseSensitive: false,
  unicode: true,
);

String _read(String folder, String name) =>
    File('$_root/$folder/$name.txt').readAsStringSync().trim();

List<String> _folders() {
  final json =
      jsonDecode(File('$_root/languages.json').readAsStringSync()) as Map;
  return (json['languages'] as Map).values.cast<String>().toList();
}

void main() {
  final folders = _folders();

  test('there are 25 listings', () => expect(folders, hasLength(25)));

  for (final folder in folders) {
    group(folder, () {
      test('FR3.4 Google Play length limits', () {
        for (final (name, limit) in [
          ('title', 30),
          ('short-description', 80),
          ('full-description', 4000),
        ]) {
          final length = _read(folder, name).runes.length;
          expect(length, inInclusiveRange(1, limit), reason: name);
        }
      });

      test('FR3.2 opening paragraph and at least 6 bullet points', () {
        final full = _read(folder, 'full-description');
        final lines = full.split('\n');
        expect(lines.first.trim(), isNotEmpty);
        expect(lines.first.startsWith('•'), isFalse);
        final bullets = lines.where((line) => line.startsWith('• '));
        expect(bullets.length, greaterThanOrEqualTo(6));
        expect(full, contains('Vinoozy Plus'));
      });

      test('FR3.4 no forbidden words', () {
        for (final name in ['title', 'short-description', 'full-description']) {
          expect(
            _forbidden.hasMatch(_read(folder, name)),
            isFalse,
            reason: name,
          );
        }
        expect(_forbiddenInTitle.hasMatch(_read(folder, 'title')), isFalse);
      });
    });
  }

  for (final MapEntry(key: folder, value: words) in _keywords.entries) {
    test('FR3.1 $folder has at least 5 of its keywords', () {
      final text = [
        _read(folder, 'title'),
        _read(folder, 'short-description'),
        _read(folder, 'full-description'),
      ].join('\n').toLowerCase();
      final present = [
        for (final word in words)
          if (text.contains(word)) word,
      ];
      expect(present.length, greaterThanOrEqualTo(5), reason: '$present');
    });
  }

  test('the forbidden-word check catches what it must', () {
    expect(_forbidden.hasMatch('Il migliore vino'), isTrue);
    expect(_forbidden.hasMatch('The best cellar app'), isTrue);
    expect(_forbidden.hasMatch('App #1'), isTrue);
    expect(_forbiddenInTitle.hasMatch('Vinoozy free'), isTrue);
    expect(_forbidden.hasMatch('Vinoozy: gestione cantina'), isFalse);
    expect(_forbidden.hasMatch('erfordert deine Bestätigung'), isFalse);
  });
}
