// Tests of analyzeLabelText (label-autofill-windows FR7.3, BR7.1-BR7.9,
// NFR5.8): the criteria of BR7.9 on the reference set of
// test/fixtures/label_reference_set.json, the filled view on the texts of
// label_texts.json, the certainty rule, the cases of the owner and the
// invariants of ENT-009.
import 'dart:convert';
import 'dart:io';

import 'package:estimation/estimation.dart';
import 'package:test/test.dart';

const int _year = 2026;

Map<String, Object?> _load(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, Object?>;

/// One key field of a text of the reference set.
class _Expected {
  _Expected(this.field, Map<String, Object?> raw)
    : value = raw['value'],
      state = raw['state']! as String,
      inText = raw['inText'] as bool?,
      noValue = raw['noValue'] == true;

  final KeyField field;
  final Object? value;
  final String state;
  final bool? inText;
  final bool noValue;

  bool isRight(FieldCandidate candidate) => switch (field) {
    KeyField.denomination => candidate.denominationKey == value,
    KeyField.vintage => value != null && candidate.year == value,
    _ =>
      value != null &&
          normalizeWineText(candidate.value) ==
              normalizeWineText(value! as String),
  };
}

class _Case {
  _Case(Map<String, Object?> raw)
    : id = raw['id']! as String,
      lang = raw['lang']! as String,
      text = raw['text']! as String,
      expected = {
        for (final field in KeyField.values)
          field: _Expected(
            field,
            (raw['expected']! as Map<String, Object?>)[field.name]!
                as Map<String, Object?>,
          ),
      };

  final String id;
  final String lang;
  final String text;
  final Map<KeyField, _Expected> expected;
  late final LabelAnalysis analysis = analyzeLabelText(
    text,
    currentYear: _year,
  );
}

void main() {
  final fixture = _load('test/fixtures/label_reference_set.json');
  final cases = [
    for (final raw in fixture['texts']! as List<Object?>)
      _Case(raw! as Map<String, Object?>),
  ];
  _Case caseOf(String id) => cases.singleWhere((c) => c.id == id);

  group('reference set (BR7.9, FR7.3)', () {
    test('at least 60 texts in it, fr, es, en, de, pt with currentYear', () {
      expect(fixture['currentYear'], _year);
      expect(cases.length, greaterThanOrEqualTo(60));
      expect(
        {for (final c in cases) c.lang},
        {'it', 'fr', 'es', 'en', 'de', 'pt'},
      );
    });

    test('at least 15 uncertain texts per field, 10 with the value outside '
        'the candidates', () {
      for (final field in KeyField.values) {
        final uncertain = cases
            .where((c) => c.expected[field]!.state == 'I')
            .length;
        expect(uncertain, greaterThanOrEqualTo(15), reason: field.name);
      }
      final outside = cases
          .where(
            (c) => c.expected.values.any(
              (e) => e.state == 'I' && e.inText == true,
            ),
          )
          .length;
      expect(outside, greaterThanOrEqualTo(10));
    });

    test('(1) no certain field is wrong', () {
      final wrong = <String>[];
      for (final c in cases) {
        for (final field in KeyField.values) {
          final analysis = c.analysis[field];
          if (analysis.certainty != FieldCertainty.certain) continue;
          if (!c.expected[field]!.isRight(analysis.top!)) {
            wrong.add('${c.id} ${field.name}');
          }
        }
      }
      expect(wrong, isEmpty);
    });

    test('(1) expected-uncertain fields found certain are at most 10%', () {
      var expectedUncertain = 0;
      var certain = 0;
      for (final c in cases) {
        for (final field in KeyField.values) {
          if (c.expected[field]!.state != 'I') continue;
          expectedUncertain++;
          if (c.analysis[field].certainty == FieldCertainty.certain) certain++;
        }
      }
      expect(certain * 10, lessThanOrEqualTo(expectedUncertain));
    });

    test('(2) FR1.1 thresholds on the expected-certain fields', () {
      const minimum = {
        KeyField.name: 90,
        KeyField.vintage: 90,
        KeyField.denomination: 80,
      };
      for (final MapEntry(key: field, value: percent) in minimum.entries) {
        final expectedCertain = cases
            .where((c) => c.expected[field]!.state == 'C')
            .toList();
        final filled = expectedCertain.where((c) {
          final analysis = c.analysis[field];
          return analysis.certainty == FieldCertainty.certain &&
              c.expected[field]!.isRight(analysis.top!);
        }).length;
        expect(
          filled * 100,
          greaterThanOrEqualTo(percent * expectedCertain.length),
          reason: '${field.name}: $filled of ${expectedCertain.length}',
        );
      }
    });

    test('(3) the right value is first in 70% and in the top 3 in 90%', () {
      var ranked = 0;
      var first = 0;
      var topThree = 0;
      for (final c in cases) {
        for (final field in KeyField.values) {
          final analysis = c.analysis[field];
          if (analysis.certainty != FieldCertainty.uncertain) continue;
          final rank = analysis.candidates.indexWhere(
            c.expected[field]!.isRight,
          );
          if (rank < 0) continue;
          ranked++;
          if (rank == 0) first++;
          if (rank < 3) topThree++;
        }
      }
      expect(ranked, greaterThan(0));
      expect(first * 100, greaterThanOrEqualTo(70 * ranked));
      expect(topThree * 100, greaterThanOrEqualTo(90 * ranked));
    });

    test('(4) at most 2 uncertain fields per text on average, never more '
        'than 4', () {
      final counts = [for (final c in cases) c.analysis.uncertainFields.length];
      final total = counts.fold<int>(0, (a, b) => a + b);
      expect(total, lessThanOrEqualTo(2 * cases.length));
      expect(counts.every((count) => count <= 4), isTrue);
    });

    test('an expected-absent field with no value never gets a certain one; '
        'a field without a value in the text is never certain', () {
      for (final c in cases) {
        for (final field in KeyField.values) {
          final expected = c.expected[field]!;
          if (expected.value != null) continue;
          expect(
            c.analysis[field].certainty,
            isNot(FieldCertainty.certain),
            reason: '${c.id} ${field.name}',
          );
        }
      }
    });

    test('invariants of ENT-009 on every text', () {
      for (final c in cases) {
        final analysis = c.analysis;
        expect(analysis.fields.keys.toSet(), KeyField.values.toSet());
        for (final field in KeyField.values) {
          final f = analysis[field];
          expect(f.candidates.length, lessThanOrEqualTo(5));
          for (var i = 1; i < f.candidates.length; i++) {
            expect(
              f.candidates[i - 1].score,
              greaterThanOrEqualTo(f.candidates[i].score),
            );
          }
          for (final candidate in f.candidates) {
            expect(candidate.score, inInclusiveRange(0, 100));
            expect(candidate.field, field);
            expect(
              candidate.wordIds.every((id) => id < analysis.words.length),
              isTrue,
            );
          }
          final folded = {for (final c in f.candidates) c.folded};
          expect(folded.length, f.candidates.length, reason: 'merged');
          switch (f.certainty) {
            case FieldCertainty.certain:
              final second = f.candidates.length > 1
                  ? f.candidates[1].score
                  : 0;
              expect(f.top!.score, greaterThanOrEqualTo(80));
              expect(f.top!.score - second, greaterThanOrEqualTo(25));
              expect(f.value, f.top);
            case FieldCertainty.absent:
              expect(f.candidates, isEmpty);
              expect(field, isNot(KeyField.vintage));
              expect(f.value, isNull);
            case FieldCertainty.uncertain:
              expect(f.value, isNull);
          }
        }
        expect(analysis.words.length, lessThanOrEqualTo(maxLabelWords));
      }
    });

    test('the filled view holds exactly the certain key fields', () {
      for (final c in cases) {
        final view = c.analysis.certainFields;
        expect(view.name, c.analysis[KeyField.name].value?.value);
        expect(view.producer, c.analysis[KeyField.producer].value?.value);
        expect(
          view.denominationKey,
          c.analysis[KeyField.denomination].value?.denominationKey,
        );
        expect(view.vintage, c.analysis[KeyField.vintage].value?.year);
      }
    });
  });

  group('the filled view on label_texts.json (BR7.9, BR1.10)', () {
    final reference = _load('test/fixtures/label_texts.json');
    const fields = [
      'name',
      'producer',
      'denomination',
      'vintage',
      'wineType',
      'country',
      'region',
      'suggestedLevel',
    ];
    Object? valueOf(LabelFields f, String field) => switch (field) {
      'name' => f.name,
      'producer' => f.producer,
      'denomination' => f.denomination,
      'vintage' => f.vintage,
      'wineType' => f.wineType?.name,
      'country' => f.country,
      'region' => f.region,
      _ => f.suggestedLevel?.name,
    };
    for (final raw in reference['texts']! as List<Object?>) {
      final entry = raw! as Map<String, Object?>;
      test('${entry['id']}: no filled field differs from the expected', () {
        final view = analyzeLabelText(
          entry['text']! as String,
          currentYear: reference['currentYear']! as int,
        ).certainFields;
        final expected = entry['expected']! as Map<String, Object?>;
        for (final field in fields) {
          final value = valueOf(view, field);
          if (value == null) continue;
          expect(value, expected[field], reason: '${entry['id']} $field');
        }
      });
    }
  });

  group('certainty rule (BR7.7)', () {
    test('threshold 80 and margin 25, in integer hundredths', () {
      expect(labelCertaintyThreshold, 80);
      expect(labelCertaintyMargin, 25);
      expect(isCertainScore(80, null), isTrue);
      expect(isCertainScore(80, 55), isTrue);
      expect(isCertainScore(80, 56), isFalse);
      expect(isCertainScore(79, null), isFalse);
      expect(isCertainScore(100, 75), isTrue);
      expect(isCertainScore(100, 76), isFalse);
      // 55 + 25 is exactly 80 (BR7.1).
      expect(isCertainScore(55 + 25, 0), isTrue);
    });
  });

  group('cases of the owner and of the design', () {
    test('IT01: two questions, producer then name; the name reuses the '
        'words of the denomination', () {
      final analysis = caseOf('IT01').analysis;
      expect(analysis.uncertainFields, [KeyField.producer, KeyField.name]);
      expect(analysis[KeyField.producer].top!.value, 'Cascina Castlet');
      expect(analysis[KeyField.name].top!.value, "Barbera d'Asti Superiore");
      expect(analysis.certainFields.denominationKey, 'barberaDAsti');
      expect(analysis.certainFields.vintage, 2019);
      final denominationWords = analysis[KeyField.denomination].top!.wordIds
          .toSet();
      expect(
        analysis[KeyField.name].top!.wordIds.toSet().containsAll(
          denominationWords,
        ),
        isTrue,
      );
    });

    test('IT02: "Rosso Toscana" is proposed first and not filled alone', () {
      final analysis = caseOf('IT02').analysis;
      expect(analysis.certainFields.name, isNull);
      expect(analysis.certainFields.denominationKey, 'toscanaIT');
      expect(analysis.certainFields.producer, 'Tenuta Sconosciuta');
      expect(analysis[KeyField.name].top!.value, 'Rosso Toscana');
      expect(analysis.uncertainFields, [KeyField.name]);
    });

    test('FR04: Champagne uncertain without indicator; the name proposal '
        'shares the word CHAMPAGNE', () {
      final analysis = caseOf('FR04').analysis;
      expect(
        analysis[KeyField.denomination].certainty,
        FieldCertainty.uncertain,
      );
      expect(analysis[KeyField.denomination].top!.denominationKey, 'champagne');
      final name = analysis[KeyField.name].top!;
      expect(name.value, 'Champagne Brut Réserve');
      expect(
        name.wordIds,
        containsAll(analysis[KeyField.denomination].top!.wordIds),
      );
      expect(analysis[KeyField.vintage].candidates, isEmpty);
      expect(analysis[KeyField.vintage].certainty, FieldCertainty.uncertain);
    });

    test('ES10: a producer without producer words is absent, not asked', () {
      final analysis = caseOf('ES10').analysis;
      expect(analysis[KeyField.producer].certainty, FieldCertainty.absent);
      expect(analysis.certainFields.name, 'Txomin Etxeberria');
      expect(analysis.uncertainFields, isEmpty);
    });

    test('IT12: an indicator without alias leaves the denomination '
        'uncertain with no candidate', () {
      final analysis = caseOf('IT12').analysis;
      expect(
        analysis[KeyField.denomination].certainty,
        FieldCertainty.uncertain,
      );
      expect(analysis[KeyField.denomination].candidates, isEmpty);
      expect(analysis[KeyField.vintage].candidates, isEmpty);
    });

    test('IT05: a founding year is never the vintage', () {
      final vintage = caseOf('IT05').analysis[KeyField.vintage];
      expect(vintage.value!.year, 2019);
      final founding = vintage.candidates.singleWhere((c) => c.year == 1921);
      expect(founding.signals, contains(CandidateSignal.foundingYear));
    });

    test('FR13: a year after "cuvée" stays in the name and is no vintage', () {
      final analysis = caseOf('FR13').analysis;
      expect(analysis.certainFields.name, 'Cuvée 2000');
      expect(analysis[KeyField.vintage].certainty, FieldCertainty.uncertain);
      expect(
        analysis[KeyField.vintage].top!.signals,
        contains(CandidateSignal.cuveeYear),
      );
    });

    test('FR14 and ES11: no type without the denomination, the row type '
        'once it is confirmed (BR7.8 b, BR7.20)', () {
      final fr14 = caseOf('FR14').analysis;
      expect(fr14.certainFields.wineType, isNull);
      final cotes = fr14.fieldsForDenomination('cotesDeBourg');
      expect(cotes.wineType, WineType.redStructured);
      expect(cotes.country, 'FR');
      expect(cotes.region, isNotNull);
      final es11 = caseOf('ES11').analysis;
      expect(es11.certainFields.wineType, isNull);
      expect(
        es11.fieldsForDenomination('riberaDelGuadiana').wineType,
        WineType.redLight,
      );
      expect(es11.fieldsForDenomination('unknownKey'), LabelFields.empty);
    });

    test('FR08: a long Lens line loses only its service pieces', () {
      final analysis = caseOf('FR08').analysis;
      expect(analysis.certainFields.denominationKey, 'morgon');
      expect(
        analysis[KeyField.producer].top!.value,
        'Domaine du Vieux Pressoir',
      );
      expect(analysis.words.map((w) => w.text), isNot(contains('75cl')));
      expect(analysis.words.map((w) => w.text), contains('Pressoir'));
    });

    test('PT04: "Vinho do Porto Vintage" with the vintage qualifier', () {
      final analysis = caseOf('PT04').analysis;
      expect(analysis[KeyField.name].top!.value, 'Vinho do Porto Vintage');
      expect(analysis.certainFields.vintage, 2017);
      final porto = analysis.fieldsForDenomination('porto');
      expect(porto.qualifier, Qualifier.vintage);
      expect(porto.suggestedLevel, WineLevel.aging);
    });
  });

  group('texts of the app tests (functional-spec.md, D7 table)', () {
    test('"Barolo Vietti / 2019" fills 6 fields with no question', () {
      final analysis = analyzeLabelText(
        'Barolo Vietti\n2019',
        currentYear: _year,
      );
      final view = analysis.certainFields;
      expect(view.name, 'Barolo Vietti');
      expect(view.denomination, 'Barolo DOCG');
      expect(view.vintage, 2019);
      expect(view.wineType, WineType.redStructured);
      expect(view.country, 'IT');
      expect(view.region, 'Piemonte');
      expect(view.producer, isNull);
      expect(view.sourceKeys.length, 6);
      expect(analysis.uncertainFields, isEmpty);
      expect(analysis[KeyField.producer].certainty, FieldCertainty.absent);
    });

    test('"Chianti Classico Riserva / 2018": certain name, the qualifier '
        'goes to the level', () {
      final analysis = analyzeLabelText(
        'Chianti Classico Riserva\n2018',
        currentYear: _year,
      );
      expect(analysis.certainFields.name, 'Chianti Classico Riserva');
      expect(analysis.qualifier, Qualifier.riserva);
      expect(analysis.certainFields.suggestedLevel, WineLevel.aging);
      expect(analysis.uncertainFields, isEmpty);
    });

    test('a vintage after the current year is no candidate: a certain '
        'vintage always passes the form on Save (BR7.6 note)', () {
      final next = analyzeLabelText('Barolo Vietti\n2027', currentYear: _year);
      expect(next[KeyField.vintage].candidates, isEmpty);
      expect(next[KeyField.vintage].certainty, FieldCertainty.uncertain);
      expect(next.words.map((w) => w.text), isNot(contains('2027')));
      final current = analyzeLabelText(
        'Barolo Vietti\n2026',
        currentYear: _year,
      );
      expect(current.certainFields.vintage, 2026);
    });

    test('"Cantina del Lago": certain producer', () {
      final analysis = analyzeLabelText('Cantina del Lago', currentYear: _year);
      expect(analysis.certainFields.producer, 'Cantina del Lago');
      expect(analysis.hasClues, isTrue);
    });

    test('noise and an empty text give nothing to ask (BR7.10)', () {
      final noise = analyzeLabelText('750 ml\n13% vol', currentYear: _year);
      expect(noise.hasClues, isFalse);
      expect(noise.isEmpty, isTrue);
      expect(noise.certainFields.isEmpty, isTrue);
      expect(noise.uncertainFields, [KeyField.vintage]);
      final empty = analyzeLabelText('   ', currentYear: _year);
      expect(identical(empty, LabelAnalysis.empty), isTrue);
      expect(empty.hasClues, isFalse);
      expect(empty.words, isEmpty);
    });
  });

  group('untrusted text (NFR3.4, BR7.22)', () {
    test('string forms never hold the text', () {
      final analysis = analyzeLabelText(
        'Cascina Segreta\nBarolo\n2019',
        currentYear: _year,
      );
      final strings = [
        analysis.toString(),
        for (final field in analysis.fields.values) ...[
          field.toString(),
          for (final c in field.candidates) c.toString(),
        ],
        for (final word in analysis.words) word.toString(),
      ];
      for (final s in strings) {
        expect(s.toLowerCase(), isNot(contains('segreta')));
        expect(s, isNot(contains('2019')));
      }
    });

    test('control characters, markup and 10000 characters are read safely', () {
      final long = '${'Barolo\u0000 <b>Vietti</b>\n' * 600}2019';
      final analysis = analyzeLabelText(long, currentYear: _year);
      expect(analysis.words.length, lessThanOrEqualTo(maxLabelWords));
      for (final word in analysis.words) {
        expect(word.text.contains('<'), isFalse);
        expect(word.text.codeUnits.any((u) => u < 0x20), isFalse);
      }
    });

    test('a candidate equal after folding keeps the higher score', () {
      final name = analyzeLabelText(
        'Barolo Vietti\n2019',
        currentYear: _year,
      )[KeyField.name];
      expect(
        name.candidates.where((c) => c.folded == 'barolo vietti').length,
        1,
      );
      expect(name.candidates.first, isA<FieldCandidate>());
      expect(
        name.candidates.first ==
            FieldCandidate(
              field: KeyField.name,
              value: 'BAROLO VIETTI',
              score: 0,
            ),
        isTrue,
      );
      expect(name.candidates.first.hashCode, isA<int>());
    });
  });

  group('KeyField', () {
    test('order of the questions and keys of the mark (ENT-007)', () {
      expect(KeyField.values, [
        KeyField.denomination,
        KeyField.producer,
        KeyField.name,
        KeyField.vintage,
      ]);
      expect(
        [for (final f in KeyField.values) f.labelFieldKey],
        [
          LabelFieldKeys.denomination,
          LabelFieldKeys.producer,
          LabelFieldKeys.name,
          LabelFieldKeys.vintage,
        ],
      );
    });
  });
}
