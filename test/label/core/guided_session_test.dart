// The state machine of the guided check (label-autofill-windows ENT-012-
// ENT-014, BR7.10-BR7.21, NFR4.21, NFR4.22, NFR3.9): every transition, the
// edge cases of FR7.7, "Question N of T", "No vintage" as an answer and
// the words shared between fields.
import 'package:estimation/estimation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/cellar/domain/wine_draft.dart';
import 'package:vinoozy/label/core/guided_session.dart';

const _context = GuidedContext(currentYear: 2026);

/// IT01 of the reference set: producer and name uncertain.
const _it01 =
    "CASCINA CASTLET\nBarbera d'Asti Superiore\n14,5% vol  75 cl\n2019";

/// ES08: the four fields uncertain.
const _es08 =
    'Señorío de Valcuerna\nGarnacha Viñas Viejas 2019\nNavarra\nEdición 2021';

/// IT12: the denomination uncertain with no candidate, no vintage.
const _it12 =
    "TENUTA CA' BIANCA\nBARBARESOO\nDENOMINAZIONE DI ORIGINE\n"
    'CONTROLLATA E GARANTITA\nRio Sordo\n2O19';

LabelAnalysis _analyze(String text) =>
    analyzeLabelText(text, currentYear: 2026);

const _allEmpty = {
  KeyField.denomination,
  KeyField.producer,
  KeyField.name,
  KeyField.vintage,
};

GuidedMemory _opened(String text, {Set<KeyField> empty = _allEmpty}) {
  final memory = GuidedMemory.empty.withText(_analyze(text));
  return openGuide(memory, memory.pendingQuestions(empty), _context);
}

GuidedStep _send(GuidedMemory memory, GuidedAction action) =>
    reduceGuide(memory, action, _context);

void main() {
  group('opening (BR7.10, BR7.11)', () {
    test('IT01: two questions, producer then name, the first candidate '
        'proposed', () {
      final memory = _opened(_it01);
      final session = memory.session!;
      expect(session.questions, [KeyField.producer, KeyField.name]);
      expect(session.number, 1);
      expect(session.total, 2);
      expect(session.mode, GuidedMode.question);
      expect(session.proposal!.value, 'Cascina Castlet');
      expect(session.toString(), isNot(contains('Castlet')));
    });

    test('ES08: four questions, the vintage on the wheel at its best year', () {
      var memory = _opened(_es08);
      expect(memory.session!.total, 4);
      for (var i = 0; i < 3; i++) {
        memory = _send(memory, const SkipAction()).memory;
      }
      final session = memory.session!;
      expect(session.field, KeyField.vintage);
      expect(session.mode, GuidedMode.yearWheel);
      expect(session.wheelYear, 2019);
      expect(session.number, 4);
    });

    test('no question: a short text all certain, a text with no clue', () {
      final barolo = GuidedMemory.empty.withText(
        _analyze('Barolo Vietti\n2019'),
      );
      expect(barolo.pendingQuestions(_allEmpty), isEmpty);
      final noise = GuidedMemory.empty.withText(_analyze('750 ml\n13% vol'));
      expect(noise.pendingQuestions(_allEmpty), isEmpty);
      expect(
        openGuide(noise, const [], _context).session,
        isNull,
        reason: 'nothing to open',
      );
      expect(GuidedMemory.empty.pendingQuestions(_allEmpty), isEmpty);
    });

    test('a field filled, written by hand or answered is never asked', () {
      final memory = GuidedMemory.empty.withText(_analyze(_es08));
      expect(memory.pendingQuestions({KeyField.name, KeyField.vintage}), [
        KeyField.name,
        KeyField.vintage,
      ]);
      final manual = memory.markManual(KeyField.name);
      expect(
        manual.pendingQuestions(_allEmpty),
        isNot(contains(KeyField.name)),
      );
      final answered = memory.copyWith(
        answers: {KeyField.vintage: const NoVintageAnswer()},
      );
      expect(
        answered.pendingQuestions(_allEmpty),
        isNot(contains(KeyField.vintage)),
      );
    });

    test('a question without candidate has no proposal (IT12)', () {
      final session = _opened(_it12).session!;
      expect(session.field, KeyField.denomination);
      expect(session.proposal, isNull);
      expect(session.noProposalReason, NoProposalReason.notFound);
      expect(session.notice, isNull);
    });

    test('the wheel starts at the current year - 2 without a year', () {
      var memory = _opened(_it12);
      while (memory.session!.field != KeyField.vintage) {
        memory = _send(memory, const SkipAction()).memory;
      }
      expect(memory.session!.wheelYear, 2024);
    });
  });

  group('answers (BR7.12)', () {
    test('Yes fills the field from the text, keeps its words and goes on; '
        'N grows', () {
      final memory = _opened(_it01);
      final proposal = memory.session!.proposal!;
      final step = _send(memory, const YesAction());
      final fill = step.effects.first as FillEffect;
      expect(fill.field, KeyField.producer);
      expect(fill.value, 'Cascina Castlet');
      expect(fill.fromText, isTrue);
      expect(step.memory.answers[KeyField.producer], isA<ConfirmedAnswer>());
      expect(
        (step.memory.answers[KeyField.producer]! as ConfirmedAnswer).via,
        AnswerVia.yes,
      );
      expect(
        step.memory.usedWords[KeyField.producer],
        proposal.wordIds.toSet(),
      );
      expect(step.memory.session!.number, 2);
      expect(step.memory.session!.field, KeyField.name);
    });

    test('Yes on a name that shares the words of the denomination is '
        'allowed (BR7.15)', () {
      var memory = _opened(
        'CHAMPAGNE\nMAISON VERMONT-LAURENT\nBRUT RÉSERVE\n'
        'Élaboré par Vermont-Laurent, Épernay - France\n12% vol',
      );
      expect(memory.session!.field, KeyField.denomination);
      memory = _send(memory, const YesAction()).memory;
      expect(memory.session!.field, KeyField.name);
      final step = _send(memory, const YesAction());
      expect(
        (step.effects.first as FillEffect).value,
        'Champagne Brut Réserve',
      );
    });

    test('a denomination confirmed carries its table key (BR7.20)', () {
      final memory = _opened(
        'Domaine de la Combe Haute\nVin Rouge\nCôtes de Bourg\n2020',
      );
      final step = _send(memory, const YesAction());
      final fill = step.effects.first as FillEffect;
      expect(fill.denominationKey, 'cotesDeBourg');
      expect(
        memory.analysis!.fieldsForDenomination(fill.denominationKey!).wineType,
        WineType.redStructured,
      );
    });

    test('No proposes the next one, never again the rejected, announces '
        'it; N does not change', () {
      final memory = _opened(_es08);
      var step = _send(memory, const SkipAction());
      step = _send(step.memory, const SkipAction());
      final name = step.memory.session!;
      expect(name.field, KeyField.name);
      final first = name.proposal!;
      step = _send(step.memory, const NoAction());
      final after = step.memory.session!;
      expect(after.proposal, isNot(first));
      expect(after.number, name.number);
      expect(after.notice, isA<RejectedNotice>());
      expect((after.notice! as RejectedNotice).value, first.value);
      expect(after.notice.toString(), isNot(contains(first.value)));
      expect(step.effects.single, isA<AnnounceProposalEffect>());
      expect(step.memory.rejected[KeyField.name], contains(first.folded));
      expect(
        _send(step.memory, const NoticeExpiredAction()).memory.session!.notice,
        isNull,
      );
    });

    test('after the last candidate: no proposal, "no other", Yes and No '
        'do nothing, the field waits for Skip', () {
      var memory = _opened(_it01);
      memory = _send(memory, const SkipAction()).memory;
      final count = memory.session!.analysis[KeyField.name].candidates.length;
      for (var i = 0; i < count; i++) {
        memory = _send(memory, const NoAction()).memory;
      }
      final session = memory.session!;
      expect(session.proposal, isNull);
      expect(session.noProposalReason, NoProposalReason.exhausted);
      expect(session.notice, isA<NoMoreNotice>());
      expect(
        identical(_send(memory, const YesAction()).memory, memory),
        isTrue,
      );
      expect(identical(_send(memory, const NoAction()).memory, memory), isTrue);
      final skip = _send(memory, const SkipAction());
      expect(skip.memory.session, isNull);
      final closed = skip.effects.single as ClosedEffect;
      expect(closed.completed, isTrue);
      expect(closed.skipped, {KeyField.producer, KeyField.name});
    });

    test('a rejected value never comes back with a new text', () {
      var memory = _opened(_it01);
      final first = memory.session!.proposal!;
      memory = _send(memory, const NoAction()).memory;
      memory = memory.withText(_analyze(_it01));
      memory = openGuide(memory, memory.pendingQuestions(_allEmpty), _context);
      expect(memory.session!.proposal, isNot(first));
    });

    test('Edit: the proposal to change; Confirm valid fills (mark only when '
        'unchanged), empty empties and counts, invalid stays', () {
      final memory = _opened(_it01);
      var step = _send(memory, const EditAction());
      expect(step.memory.session!.mode, GuidedMode.edit);
      expect(step.memory.session!.editText, 'Cascina Castlet');
      final same = _send(step.memory, const ConfirmAction());
      expect((same.effects.first as FillEffect).fromText, isTrue);
      expect(
        (same.memory.answers[KeyField.producer]! as ConfirmedAnswer).via,
        AnswerVia.edit,
      );

      step = _send(step.memory, const EditChangedAction('Castlet'));
      final changed = _send(step.memory, const ConfirmAction());
      final fill = changed.effects.first as FillEffect;
      expect(fill.value, 'Castlet');
      expect(fill.fromText, isFalse);

      step = _send(step.memory, const EditChangedAction('  '));
      final emptied = _send(step.memory, const ConfirmAction());
      expect((emptied.effects.first as FillEffect).value, isEmpty);
      expect(
        emptied.memory.answers[KeyField.producer],
        isA<EmptiedByEditAnswer>(),
      );

      step = _send(step.memory, EditChangedAction('x' * 121));
      final tooLong = _send(step.memory, const ConfirmAction());
      expect(tooLong.memory.session!.mode, GuidedMode.edit);
      expect(tooLong.memory.session!.error, GuidedFieldError.tooLong);
      expect(tooLong.effects, isEmpty);

      step = _send(step.memory, const EditChangedAction('Cascina\u0007'));
      final invalid = _send(step.memory, const ConfirmAction());
      expect(invalid.memory.session!.error, GuidedFieldError.invalid);
    });

    test('Cancel and Back in Edit go back to the question', () {
      final edit = _send(_opened(_it01), const EditAction()).memory;
      for (final action in [const CancelAction(), const BackAction()]) {
        final back = _send(edit, action).memory.session!;
        expect(back.mode, GuidedMode.question);
        expect(back.editText, isEmpty);
      }
      expect(_send(edit, const TapOutsideAction()).memory, same(edit));
    });

    test('Edit is only a question action; EditChanged only in Edit', () {
      final memory = _opened(_it01);
      expect(_send(memory, const EditChangedAction('x')).memory, same(memory));
      final compose = _send(memory, const ToggleWordAction(0)).memory;
      expect(_send(compose, const EditAction()).memory, same(compose));
    });
  });

  group('compose (BR7.15, BR7.16)', () {
    test('the first tap opens Compose; the value follows the text; Confirm '
        'fills from the text with the words used', () {
      var memory = _opened(_it01);
      final words = memory.session!.analysis.words;
      final castlet = words.indexWhere((w) => w.text == 'CASTLET');
      final cascina = words.indexWhere((w) => w.text == 'CASCINA');
      memory = _send(memory, ToggleWordAction(castlet)).memory;
      expect(memory.session!.mode, GuidedMode.compose);
      memory = _send(memory, ToggleWordAction(cascina)).memory;
      final step = _send(memory, const ConfirmAction());
      final fill = step.effects.first as FillEffect;
      expect(fill.value, 'Cascina Castlet');
      expect(fill.fromText, isTrue);
      expect(step.memory.usedWords[KeyField.producer], {cascina, castlet});
      expect(
        (step.memory.answers[KeyField.producer]! as ConfirmedAnswer).via,
        AnswerVia.compose,
      );
    });

    test('a second tap removes the word; Confirm with none does nothing; '
        'Cancel empties the choice', () {
      var memory = _send(_opened(_it01), const ToggleWordAction(0)).memory;
      memory = _send(memory, const ToggleWordAction(0)).memory;
      expect(memory.session!.selected, isEmpty);
      expect(memory.session!.mode, GuidedMode.compose);
      expect(_send(memory, const ConfirmAction()).memory, same(memory));
      memory = _send(memory, const ToggleWordAction(1)).memory;
      final cancelled = _send(memory, const CancelAction()).memory.session!;
      expect(cancelled.mode, GuidedMode.question);
      expect(cancelled.selected, isEmpty);
      expect(_send(memory, const TapOutsideAction()).memory, same(memory));
      expect(
        _send(memory, const BackAction()).memory.session!.mode,
        GuidedMode.question,
      );
    });

    test('a word of the denomination can be reused for the name', () {
      var memory = _opened(
        "Domaine des Roches Fines\nBOURGOGNE\nPinot Noir\n2022",
      );
      expect(memory.session!.field, KeyField.denomination);
      memory = _send(memory, const YesAction()).memory;
      final used = memory.usedWords[KeyField.denomination]!;
      expect(memory.session!.field, KeyField.name);
      memory = _send(memory, ToggleWordAction(used.first)).memory;
      expect(memory.session!.selected, [used.first]);
    });

    test('a composed denomination takes the name of its table row', () {
      var memory = _opened(_it12);
      final words = memory.session!.analysis.words;
      final rio = words.indexWhere((w) => w.text == 'Rio');
      memory = _send(memory, ToggleWordAction(rio)).memory;
      final plain = _send(memory, const ConfirmAction());
      expect((plain.effects.first as FillEffect).value, 'Rio');
      expect((plain.effects.first as FillEffect).denominationKey, isNull);
      expect(
        composedDenomination("barbera d'asti docg", _context)?.displayName,
        "Barbera d'Asti DOCG",
      );
    });

    test('the limits of 8 words disable the ninth (BR7.15)', () {
      var memory = _opened(
        'Uno Due Tre Quattro Cinque Sei Sette Otto Nove\nCantina Prova',
      );
      while (memory.session!.field != KeyField.name) {
        memory = _send(memory, const SkipAction()).memory;
      }
      for (var id = 0; id < 8; id++) {
        memory = _send(memory, ToggleWordAction(id)).memory;
      }
      expect(memory.session!.selected, hasLength(8));
      expect(_send(memory, const ToggleWordAction(8)).memory, same(memory));
      expect(_send(memory, const ToggleWordAction(999)).memory, same(memory));
    });
  });

  group('vintage wheel (BR7.13)', () {
    GuidedMemory wheel() {
      var memory = _opened(_es08);
      while (memory.session!.field != KeyField.vintage) {
        memory = _send(memory, const SkipAction()).memory;
      }
      return memory;
    }

    test('Confirm fills the year, marked when it is a year of the text', () {
      final memory = wheel();
      final step = _send(memory, const WheelConfirmAction());
      final fill = step.effects.first as FillEffect;
      expect(fill.value, '2019');
      expect(fill.fromText, isTrue);
      final moved = _send(memory, const WheelChangedAction(2000)).memory;
      final other = _send(moved, const WheelConfirmAction());
      expect((other.effects.first as FillEffect).fromText, isFalse);
      expect(
        (other.memory.answers[KeyField.vintage]! as ConfirmedAnswer).via,
        AnswerVia.wheel,
      );
    });

    test('the wheel stays within the years the form saves', () {
      final memory = wheel();
      expect(
        _send(memory, const WheelChangedAction(1500)).memory.session!.wheelYear,
        1900,
      );
      expect(
        _send(memory, const WheelChangedAction(3000)).memory.session!.wheelYear,
        2026,
      );
    });

    test('the number pad: OK valid moves and closes, invalid keeps it open '
        'with the error, Back closes only the pad', () {
      var memory = _send(wheel(), const OpenKeyboardAction()).memory;
      expect(memory.session!.keyboardOpen, isTrue);
      final wrong = _send(memory, const KeyboardSubmitAction('1850')).memory;
      expect(wrong.session!.keyboardOpen, isTrue);
      expect(wrong.session!.error, GuidedFieldError.outOfRange);
      expect(wrong.session!.wheelYear, 2019);
      final ok = _send(memory, const KeyboardSubmitAction('1985')).memory;
      expect(ok.session!.keyboardOpen, isFalse);
      expect(ok.session!.wheelYear, 1985);
      final back = _send(memory, const BackAction()).memory;
      expect(back.session, isNotNull);
      expect(back.session!.keyboardOpen, isFalse);
      expect(_send(ok, const KeyboardSubmitAction('2000')).memory, same(ok));
      memory = _send(memory, const CloseAction()).memory;
      expect(memory.session, isNull);
    });

    test('"No vintage" counts as an answer and is never asked again', () {
      final step = _send(wheel(), const NoVintageAction());
      expect(step.effects.first, isA<NoVintageEffect>());
      expect(step.memory.answers[KeyField.vintage], isA<NoVintageAnswer>());
      final again = step.memory.withText(_analyze(_es08));
      expect(
        again.pendingQuestions(_allEmpty),
        isNot(contains(KeyField.vintage)),
      );
    });

    test('Skip leaves it without an answer; no word action on the wheel', () {
      final memory = wheel();
      final step = _send(memory, const SkipAction());
      expect(step.memory.answers, isNot(contains(KeyField.vintage)));
      expect(step.memory.session, isNull);
      expect(_send(memory, const ToggleWordAction(0)).memory, same(memory));
      expect(_send(memory, const YesAction()).memory, same(memory));
      expect(_send(memory, const ConfirmAction()).memory, same(memory));
    });

    test('Cancel does nothing on the wheel, with or without the pad, and '
        'on a question', () {
      final memory = wheel();
      expect(_send(memory, const CancelAction()).memory, same(memory));
      final pad = _send(memory, const OpenKeyboardAction()).memory;
      final cancelled = _send(pad, const CancelAction()).memory;
      expect(cancelled, same(pad));
      expect(cancelled.session!.mode, GuidedMode.yearWheel);
      final question = _opened(_it01);
      expect(_send(question, const CancelAction()).memory, same(question));
    });

    test('wheel actions do nothing outside the wheel', () {
      final memory = _opened(_it01);
      for (final action in const <GuidedAction>[
        WheelChangedAction(2000),
        OpenKeyboardAction(),
        WheelConfirmAction(),
        NoVintageAction(),
      ]) {
        expect(_send(memory, action).memory, same(memory));
      }
    });
  });

  group('closing and new texts (BR7.17-BR7.21, FR7.7)', () {
    test('Close, Back and tap outside close a question, keeping answers', () {
      var memory = _opened(_it01);
      memory = _send(memory, const YesAction()).memory;
      for (final action in const <GuidedAction>[
        CloseAction(),
        BackAction(),
        TapOutsideAction(),
      ]) {
        final step = _send(memory, action);
        expect(step.memory.session, isNull);
        expect(step.memory.answers, contains(KeyField.producer));
        expect((step.effects.single as ClosedEffect).completed, isFalse);
      }
    });

    test('reopening asks only what is left, with T recomputed', () {
      var memory = _opened(_es08);
      memory = _send(memory, const YesAction()).memory;
      memory = _send(memory, const CloseAction()).memory;
      final left = memory.pendingQuestions(
        _allEmpty.difference({KeyField.denomination}),
      );
      memory = openGuide(memory, left, _context);
      expect(memory.session!.total, 3);
      expect(memory.session!.field, KeyField.producer);
      expect(memory.session!.number, 1);
    });

    test('a new text closes the guide, keeps answers and rejections, drops '
        'the words used', () {
      var memory = _opened(_it01);
      memory = _send(memory, const YesAction()).memory;
      memory = _send(memory, const NoAction()).memory;
      final next = memory.withText(_analyze(_es08));
      expect(next.session, isNull);
      expect(next.answers, contains(KeyField.producer));
      expect(next.rejected, contains(KeyField.name));
      expect(next.usedWords, isEmpty);
      expect(
        next.pendingQuestions(_allEmpty),
        isNot(contains(KeyField.producer)),
      );
    });

    test('a field written by hand while the guide is open is not marked', () {
      final memory = _opened(_it01);
      expect(memory.markManual(KeyField.name), same(memory));
      final closed = _send(memory, const CloseAction()).memory;
      final manual = closed.markManual(KeyField.name);
      expect(manual.manual, {KeyField.name});
      expect(manual.markManual(KeyField.name), same(manual));
    });

    test('no guide open: every action leaves the memory as it is', () {
      expect(
        reduceGuide(GuidedMemory.empty, const YesAction(), _context).memory,
        same(GuidedMemory.empty),
      );
      expect(GuidedMemory.empty.toString(), contains('closed'));
    });
  });

  group('validation (NFR3.9, FR1.5)', () {
    test('lengths of the form, the vintage range, control characters', () {
      expect(validateGuidedValue(KeyField.name, 'x' * 120, _context), isNull);
      expect(
        validateGuidedValue(KeyField.name, 'x' * 121, _context),
        GuidedFieldError.tooLong,
      );
      expect(
        validateGuidedValue(KeyField.producer, 'y' * 121, _context),
        GuidedFieldError.tooLong,
      );
      expect(
        validateGuidedValue(KeyField.denomination, 'z' * 121, _context),
        GuidedFieldError.tooLong,
      );
      expect(validateGuidedValue(KeyField.vintage, '2026', _context), isNull);
      expect(
        validateGuidedValue(KeyField.vintage, '2027', _context),
        GuidedFieldError.outOfRange,
      );
      expect(
        validateGuidedValue(KeyField.vintage, '19', _context),
        GuidedFieldError.outOfRange,
      );
      expect(
        validateGuidedValue(KeyField.name, 'Barolo\u0000', _context),
        GuidedFieldError.invalid,
      );
      expect(_context.minYear, 1900);
      expect(_context.maxYear, 2026);
      expect(_context.defaultYear, 2024);
    });

    test('one source of truth: every wheel year passes the validation of '
        'the form on Save, and none beyond', () {
      for (final year in [_context.minYear, _context.maxYear]) {
        expect(
          WineRules.validateVintage(
            '$year',
            noVintage: false,
            currentYear: _context.currentYear,
          ),
          isNull,
        );
      }
      expect(
        WineRules.validateVintage(
          '${_context.maxYear + 1}',
          noVintage: false,
          currentYear: _context.currentYear,
        ),
        isNotNull,
      );
      expect(
        WineRules.validateVintage(
          '${_context.minYear - 1}',
          noVintage: false,
          currentYear: _context.currentYear,
        ),
        isNotNull,
      );
    });
  });
}
