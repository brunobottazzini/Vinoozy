// The interface texts in the 25 languages (wine-culture-languages FR1.2,
// FR1.3, FR1.5, FR1.6, FR3.5, NFR3, NFR4): the ARB files against the English
// template, the language with the longest texts, the plural forms of each
// language, a main screen in the languages outside the full check, the
// words that are never translated, dates and numbers.
import 'dart:convert';
import 'dart:io';

import 'package:estimation/estimation.dart' show Qualifier;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinoozy/app/home_shell.dart';
import 'package:vinoozy/app/locale_resolution.dart';
import 'package:vinoozy/cellar/ui/cellar_screen.dart' show CellarSetup;
import 'package:vinoozy/cellar/ui/wine_labels.dart';
import 'package:vinoozy/dashboard/ui/dashboard_screen.dart';
import 'package:vinoozy/l10n/app_localizations.dart';

import '../dashboard/dashboard_harness.dart';
import '../dashboard/fixtures.dart';
import '../helpers/ui_harness.dart';

const String _l10nDir = 'lib/l10n';
const String _templateName = 'app_en.arb';

/// The ARB file of [locale]: `app_pt_BR.arb` for `pt-BR`.
File _arbFileOf(Locale locale) => File(
  '$_l10nDir/app_${[locale.languageCode, ?locale.countryCode].join('_')}.arb',
);

Map<String, Object?> _readArb(File file) =>
    (jsonDecode(file.readAsStringSync()) as Map).cast<String, Object?>();

/// The message texts of an ARB file, by key (metadata left out).
Map<String, String> _messagesOf(Map<String, Object?> arb) => {
  for (final MapEntry(:key, :value) in arb.entries)
    if (!key.startsWith('@') && value is String) key: value,
};

/// What an ICU message uses: its arguments, the option keys of each select
/// and plural, and the text of each plural branch.
class _MessageShape {
  final Set<String> arguments = {};
  final Map<String, Set<String>> selectKeys = {};
  final Map<String, Map<String, String>> pluralBranches = {};
}

/// Parses the ICU syntax of the ARB messages (no apostrophe escaping:
/// `use-escaping` is off in l10n.yaml).
_MessageShape _shapeOf(String key, String text) {
  final shape = _MessageShape();
  final end = _parseMessage(key, text, 0, shape);
  if (end != text.length) {
    throw FormatException('unbalanced "}" in "$key"', text, end);
  }
  return shape;
}

int _parseMessage(String key, String text, int start, _MessageShape shape) {
  var index = start;
  while (index < text.length) {
    final char = text[index];
    if (char == '}') return index;
    index = char == '{'
        ? _parseArgument(key, text, index + 1, shape)
        : index + 1;
  }
  return index;
}

final RegExp _argumentName = RegExp(r'\s*(\w+)\s*');
final RegExp _argumentType = RegExp(r',\s*(plural|select)\s*,');
final RegExp _optionKey = RegExp(r'\s*(=?\w+)\s*\{');

int _parseArgument(String key, String text, int start, _MessageShape shape) {
  final name = _argumentName.matchAsPrefix(text, start);
  if (name == null) throw FormatException('bad argument in "$key"', text);
  final argument = name.group(1)!;
  shape.arguments.add(argument);
  var index = name.end;
  if (index < text.length && text[index] == '}') return index + 1;
  final type = _argumentType.matchAsPrefix(text, index);
  if (type == null) throw FormatException('bad argument in "$key"', text);
  index = type.end;
  final isPlural = type.group(1) == 'plural';
  final branches = <String, String>{};
  while (true) {
    while (index < text.length && text[index].trim().isEmpty) {
      index++;
    }
    if (index >= text.length) throw FormatException('open "{" in "$key"');
    if (text[index] == '}') break;
    final option = _optionKey.matchAsPrefix(text, index);
    if (option == null) throw FormatException('bad option in "$key"', text);
    final branchEnd = _parseMessage(key, text, option.end, shape);
    branches[option.group(1)!] = text.substring(option.end, branchEnd);
    index = branchEnd + 1;
  }
  if (isPlural) {
    shape.pluralBranches[argument] = branches;
  } else {
    shape.selectKeys[argument] = branches.keys.toSet();
  }
  return index + 1;
}

/// The plural categories that [localeName] uses for whole numbers, from the
/// CLDR rules of package:intl, the same rules the generated code applies.
Set<String> _integerCategories(String localeName) => {
  for (var count = 0; count <= 1000; count++)
    Intl.pluralLogic(
      count,
      locale: localeName,
      useExplicitNumberCases: false,
      one: 'one',
      two: 'two',
      few: 'few',
      many: 'many',
      other: 'other',
    ),
};

/// The whole numbers other than 1 that fall in the category `one`.
List<int> _otherOnes(String localeName) => [
  for (var count = 0; count <= 1000; count++)
    if (count != 1 &&
        Intl.pluralLogic(
              count,
              locale: localeName,
              useExplicitNumberCases: false,
              one: 'one',
              other: 'other',
            ) ==
            'one')
      count,
];

/// Total length in characters of the texts of [arb].
int _textLength(Map<String, Object?> arb) =>
    _messagesOf(arb).values.fold(0, (total, text) => total + text.runes.length);

void main() {
  final template = _readArb(File('$_l10nDir/$_templateName'));
  final templateMessages = _messagesOf(template);
  final templateShapes = {
    for (final MapEntry(:key, :value) in templateMessages.entries)
      key: _shapeOf(key, value),
  };

  group('every message in every language (FR1.2)', () {
    test('there is one ARB file per interface language', () {
      final files = {
        for (final entity in Directory(_l10nDir).listSync())
          if (entity is File && entity.path.endsWith('.arb'))
            entity.uri.pathSegments.last,
      };
      expect(files, {
        for (final l in appLocales) _arbFileOf(l).uri.pathSegments.last,
      });
    });

    for (final locale in appLocales) {
      final tag = locale.toLanguageTag();
      test('$tag has the keys and placeholders of the template', () {
        final arb = _readArb(_arbFileOf(locale));
        expect(
          arb['@@locale'],
          [locale.languageCode, ?locale.countryCode].join('_'),
        );
        final messages = _messagesOf(arb);
        expect(messages.keys.toSet(), templateMessages.keys.toSet());
        for (final MapEntry(:key, value: text) in messages.entries) {
          expect(text.trim(), isNotEmpty, reason: '$key in $tag');
          final shape = _shapeOf(key, text);
          final expected = templateShapes[key]!;
          expect(shape.arguments, expected.arguments, reason: '$key in $tag');
          expect(shape.selectKeys, expected.selectKeys, reason: '$key in $tag');
          expect(
            shape.pluralBranches.keys.toSet(),
            expected.pluralBranches.keys.toSet(),
            reason: '$key in $tag',
          );
        }
      });
    }
  });

  group('plural forms of each language (FR1.5)', () {
    for (final locale in appLocales) {
      final tag = locale.toLanguageTag();
      final localeName = lookupAppLocalizations(locale).localeName;

      test('$tag has every plural form its language uses', () {
        // `other` is always there; `one`, `two`, `few` and `many` are needed
        // when CLDR gives them to whole numbers. gen-l10n turns `=1` into
        // the form `one` and `=2` into `two`; the next test checks that such
        // a branch shows the count when the form covers other numbers too.
        final needed = _integerCategories(localeName)..remove('other');
        final messages = _messagesOf(_readArb(_arbFileOf(locale)));
        for (final MapEntry(:key, value: text) in messages.entries) {
          for (final MapEntry(key: argument, value: branches) in _shapeOf(
            key,
            text,
          ).pluralBranches.entries) {
            expect(branches.keys, contains('other'), reason: '$key in $tag');
            final present = branches.keys.map(
              (option) => switch (option) {
                '=1' => 'one',
                '=2' => 'two',
                _ => option,
              },
            );
            expect(
              present,
              containsAll(needed),
              reason: '$key in $tag: plural of {$argument}',
            );
          }
        }
      });

      test('$tag never writes a fixed number where one form covers many', () {
        // In uk, hr, sr, fr or pt the form `one` is used for 21 or 0 too: a
        // text "1 ..." there would be wrong, it must show the count (or the
        // message needs its own `=0`).
        final ones = _otherOnes(localeName);
        if (ones.isEmpty) return;
        final messages = _messagesOf(_readArb(_arbFileOf(locale)));
        for (final MapEntry(:key, value: text) in messages.entries) {
          for (final MapEntry(key: argument, value: branches) in _shapeOf(
            key,
            text,
          ).pluralBranches.entries) {
            // gen-l10n turns `=1` into the form `one`, so both count.
            for (final option in ['one', '=1']) {
              final branch = branches[option];
              if (branch == null) continue;
              final zeroHandled = branches.containsKey('=0');
              final otherNumbers = ones.where((n) => n != 0 || !zeroHandled);
              if (otherNumbers.isEmpty) continue;
              expect(
                branch,
                contains('{$argument}'),
                reason:
                    '$key in $tag: "$option" is also used for '
                    '${otherNumbers.take(3).join(', ')}',
              );
            }
          }
        }
      });
    }
  });

  group('longest texts (NFR3)', () {
    test('the full check includes the language with the longest texts', () {
      final others = [
        for (final locale in appLocales)
          if (!matrixLocales.contains(locale) || locale == longestTextLocale)
            locale,
      ];
      final lengths = {
        for (final locale in others)
          locale: _textLength(_readArb(_arbFileOf(locale))),
      };
      final longest = lengths.entries.reduce(
        (a, b) => b.value > a.value ? b : a,
      );
      expect(longestTextLocale, longest.key, reason: 'lengths: $lengths');
      expect(matrixLocales, contains(longestTextLocale));
      expect(matrixLocales.toSet(), hasLength(10));
      expect(appLocales, containsAll(matrixLocales));
    });
  });

  group('a main screen outside the full check (NFR4)', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    final outside = [
      for (final locale in appLocales)
        if (!matrixLocales.contains(locale)) locale,
    ];

    test('15 languages are outside the full check', () {
      expect(outside, hasLength(15));
    });

    for (final locale in outside) {
      testWidgets('the Dashboard shows in ${locale.toLanguageTag()}', (
        tester,
      ) async {
        final streams = DashboardStreams();
        await pumpScreen(
          tester,
          HomeShell(
            user: dashboardUser,
            setup: CellarSetup.ready,
            onRetrySetup: () async {},
          ),
          locale: locale,
          textScale: 2.0,
          overrides: streams.overrides,
        );
        streams
          ..emitCellar()
          ..emitWines([
            wineOf('w1', name: 'Barolo', window: window(2024, 2030, 2040)),
            wineOf('w2', name: 'Chablis', vintage: null),
          ]);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byType(DashboardScreen), findsOneWidget);
        final l10n = lookupAppLocalizations(locale);
        expect(find.text(l10n.dashboardTitle), findsWidgets);
      });
    }
  });

  group('words that are never translated (FR1.6)', () {
    test('qualifiers keep their name in every language', () {
      for (final locale in appLocales) {
        final l10n = lookupAppLocalizations(locale);
        for (final qualifier in Qualifier.values) {
          final name = qualifierDisplayName(qualifier);
          expect(
            l10n.estimateFromDenominationQualifier('Barolo', name),
            contains(name),
            reason: '${qualifier.name} in ${locale.toLanguageTag()}',
          );
        }
      }
      expect(qualifierDisplayName(Qualifier.spatlese), 'Spätlese');
      expect(qualifierDisplayName(Qualifier.grandCru), 'Grand Cru');
      expect(qualifierDisplayName(Qualifier.riserva), 'Riserva');
    });

    test('Vinoozy is written the same everywhere', () {
      final withName = [
        for (final MapEntry(:key, :value) in templateMessages.entries)
          if (value.contains('Vinoozy')) key,
      ];
      expect(withName, isNotEmpty);
      for (final locale in appLocales) {
        final messages = _messagesOf(_readArb(_arbFileOf(locale)));
        expect(lookupAppLocalizations(locale).appTitle, 'Vinoozy');
        for (final key in withName) {
          expect(
            messages[key],
            contains('Vinoozy'),
            reason: '$key in ${locale.toLanguageTag()}',
          );
        }
      }
    });
  });

  group('European and Brazilian Portuguese (FR1.3)', () {
    test('the two variants have texts of their own', () {
      final european = lookupAppLocalizations(const Locale('pt'));
      final brazilian = lookupAppLocalizations(const Locale('pt', 'BR'));
      expect(european.cellarTitle, 'Garrafeira');
      expect(brazilian.cellarTitle, 'Adega');
      expect(european.vintageLabel, isNot(brazilian.vintageLabel));
      final pt = _messagesOf(_readArb(_arbFileOf(const Locale('pt'))));
      final ptBr = _messagesOf(_readArb(_arbFileOf(const Locale('pt', 'BR'))));
      // Many short texts are the same in both variants ("Vinoozy", "Plus",
      // "Rosé"); the European file is still a translation of its own.
      final different = pt.keys.where((key) => pt[key] != ptBr[key]).length;
      expect(different, greaterThan(pt.length ~/ 3));
    });
  });

  group('dates and numbers follow the language (FR3.5)', () {
    Future<({String month, String number})> formatted(
      WidgetTester tester,
      Locale locale,
    ) async {
      late String month;
      late String number;
      await pumpScreen(
        tester,
        Builder(
          builder: (context) {
            month = formatMonthLong(context, 2027, 3);
            number = NumberFormat.decimalPatternDigits(
              locale: intlLocaleOf(context),
              decimalDigits: 1,
            ).format(1234.5);
            return const SizedBox();
          },
        ),
        locale: locale,
      );
      return (month: month, number: number);
    }

    testWidgets('German (Latin)', (tester) async {
      final result = await formatted(tester, const Locale('de'));
      expect(result.month, 'März 2027');
      expect(result.number, '1.234,5');
    });

    testWidgets('Greek', (tester) async {
      final result = await formatted(tester, const Locale('el'));
      expect(result.month, contains('Μάρτιος'));
      expect(result.month, contains('2027'));
      expect(result.number, '1.234,5');
    });

    testWidgets('Ukrainian (Cyrillic)', (tester) async {
      final result = await formatted(tester, const Locale('uk'));
      expect(result.month, contains('березень'));
      expect(result.month, contains('2027'));
      expect(result.number, matches(RegExp(r'^1\s234,5$')));
    });

    testWidgets('Georgian', (tester) async {
      final result = await formatted(tester, const Locale('ka'));
      expect(result.month, contains('მარტი'));
      expect(result.month, contains('2027'));
      expect(result.number, matches(RegExp(r'^1\s234,5$')));
    });

    testWidgets('European Portuguese is not formatted as Brazilian', (
      tester,
    ) async {
      final european = await formatted(tester, const Locale('pt'));
      expect(european.number, matches(RegExp(r'^1\s234,5$')));
      final brazilian = await formatted(tester, const Locale('pt', 'BR'));
      expect(brazilian.number, '1.234,5');
    });
  });
}
