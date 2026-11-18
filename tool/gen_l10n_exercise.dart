// Generates test/l10n/l10n_exercise_test.dart from the template
// lib/l10n/app_en.arb: for each interface language the test calls every
// message with sample arguments and checks that the text is not empty; a
// message with a count is called with 0, 1, 2, 5 and 21, so every plural
// form of every language is exercised (wine-culture-languages FR1.5, NFR4).
//
// The generated localization classes are about 2,450 lines per language:
// without this test they would count as untested lines (NFR1: 80% of lines
// on all of lib/, generated code included). The generated test is ignored
// by git, like test/coverage_helper_test.dart.
//
// Usage: dart run tool/gen_l10n_exercise.dart
import 'dart:convert';
import 'dart:io';

const String templatePath = 'lib/l10n/app_en.arb';
const String outputPath = 'test/l10n/l10n_exercise_test.dart';

/// The counts tried for a plural: zero, one, a "few" (2), a "many" (5) and a
/// number that is "one" again in the languages that count by the last digit.
const List<int> pluralCounts = [0, 1, 2, 5, 21];

/// Sample values of the placeholders that are not a count or a `select`.
const String sampleText = 'Sample';
const int sampleNumber = 7;

final RegExp _pluralArgument = RegExp(r'\{\s*(\w+)\s*,\s*plural\s*,');
final RegExp _selectArgument = RegExp(r'\{\s*(\w+)\s*,\s*select\s*,');
final RegExp _optionName = RegExp(r'(\w+)\s*\{');

void main() {
  final template = File(templatePath);
  if (!template.existsSync()) {
    stderr.writeln(
      'gen_l10n_exercise: run from the project root ($templatePath missing)',
    );
    exitCode = 2;
    return;
  }
  final Object? decoded = jsonDecode(template.readAsStringSync());
  if (decoded is! Map<String, dynamic>) {
    stderr.writeln('gen_l10n_exercise: $templatePath is not a JSON object');
    exitCode = 2;
    return;
  }

  final calls = <String>[];
  var messages = 0;
  try {
    for (final key in decoded.keys.where((key) => !key.startsWith('@'))) {
      calls.addAll(messageCalls(key, decoded[key], decoded['@$key']));
      messages++;
    }
  } on FormatException catch (error) {
    stderr.writeln('gen_l10n_exercise: ${error.message}');
    exitCode = 2;
    return;
  }

  File(outputPath)
    ..createSync(recursive: true)
    ..writeAsStringSync(testSource(calls));
  // The project check `dart format --set-exit-if-changed .` also sees the
  // generated file when it is run after this tool.
  final format = Process.runSync('dart', ['format', outputPath]);
  if (format.exitCode != 0) {
    stderr.writeln('gen_l10n_exercise: dart format failed: ${format.stderr}');
    exitCode = 1;
    return;
  }
  stdout.writeln(
    'gen_l10n_exercise: $messages messages, ${calls.length} calls per '
    'language',
  );
}

/// The `check(...)` lines of one message: one call, or one for each
/// combination of plural count and `select` option.
List<String> messageCalls(String key, Object? text, Object? metadata) {
  if (text is! String) {
    throw FormatException('the message "$key" is not a text');
  }
  final placeholders = metadata is Map ? metadata['placeholders'] : null;
  if (placeholders is! Map || placeholders.isEmpty) {
    return ["  check('$key', l10n.$key);"];
  }
  final plurals = {
    for (final match in _pluralArgument.allMatches(text)) match.group(1)!,
  };
  final selects = {
    for (final match in _selectArgument.allMatches(text))
      match.group(1)!: selectOptions(text, match.end),
  };

  // One list of Dart literals per parameter, in the declared order: the
  // order of the parameters of the generated method.
  var combinations = <List<String>>[[]];
  for (final MapEntry(key: name, value: details) in placeholders.entries) {
    final type = details is Map ? details['type'] : null;
    final List<String> values;
    if (plurals.contains(name)) {
      values = [for (final count in pluralCounts) '$count'];
    } else if (selects[name] case final options?) {
      values = [for (final option in options) "'$option'"];
    } else if (type == 'int' || type == 'num') {
      values = ['$sampleNumber'];
    } else if (type == 'String' || type == null) {
      values = ["'$sampleText'"];
    } else {
      throw FormatException(
        'the placeholder "$name" of "$key" has the type "$type", which '
        'tool/gen_l10n_exercise.dart does not know: add a sample value',
      );
    }
    combinations = [
      for (final combination in combinations)
        for (final value in values) [...combination, value],
    ];
  }
  return [
    for (final arguments in combinations)
      "  check('$key', l10n.$key(${arguments.join(', ')}));",
  ];
}

/// The option names of the `select` whose options start at [start] in
/// [text]: the words followed by `{` at the first nesting level.
List<String> selectOptions(String text, int start) {
  final options = <String>[];
  var depth = 0;
  var index = start;
  while (index < text.length && depth >= 0) {
    final char = text[index];
    if (char == '{') {
      depth++;
    } else if (char == '}') {
      depth--;
    } else if (depth == 0) {
      final match = _optionName.matchAsPrefix(text, index);
      if (match != null) {
        options.add(match.group(1)!);
        index = match.end - 1;
        continue;
      }
    }
    index++;
  }
  return options;
}

String testSource(List<String> calls) =>
    '''
// GENERATED by tool/gen_l10n_exercise.dart from $templatePath - do not edit.
// Calls every message of every interface language (FR1.5, NFR1, NFR4).
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/app/locale_resolution.dart';
import 'package:vinoozy/l10n/app_localizations.dart';

/// Calls every message of [l10n]; [check] receives the key and the text.
void exerciseMessages(
  AppLocalizations l10n,
  void Function(String key, String text) check,
) {
${calls.join('\n')}
}

void main() {
  test('every interface language has its translations', () {
    expect(
      AppLocalizations.supportedLocales.toSet(),
      appLocales.toSet(),
    );
  });

  for (final Locale locale in appLocales) {
    final tag = locale.toLanguageTag();
    test('every message has a text in \$tag', () {
      final l10n = lookupAppLocalizations(locale);
      expect(l10n.localeName, locale.toString());
      var checked = 0;
      exerciseMessages(l10n, (key, text) {
        checked++;
        expect(text.trim(), isNotEmpty, reason: '\$key in \$tag');
        // A brace left in the text is a placeholder that was not replaced.
        expect(text, isNot(contains('{')), reason: '\$key in \$tag');
        expect(text, isNot(contains('}')), reason: '\$key in \$tag');
      });
      expect(checked, ${calls.length});
    });
  }
}
''';
