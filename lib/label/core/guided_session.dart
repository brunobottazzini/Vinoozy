// The guided check of the uncertain fields (label-autofill-windows FR7,
// D11, BR7.10-BR7.21, ENT-012-ENT-014): the questions, the answers and the
// memory of the add form, as pure transitions: state + action -> new state
// and the effects the form applies. No timer, no clock, no I/O here: the
// controller of the form sends `noticeExpired` after 2 seconds.
//
// Everything lives in memory only (FR7.9, BR7.22): nothing is saved, logged
// or restored by Android, and no string form holds a text.

import 'package:estimation/estimation.dart';

import '../../cellar/domain/wine_draft.dart';
import '../../cellar/domain/wine_validator.dart';

/// The modes of a question (ENT-012).
enum GuidedMode { question, compose, edit, yearWheel }

/// Why a question has no proposal (BR7.12).
enum NoProposalReason {
  /// The field has no candidate: "I couldn't find it in the text".
  notFound,

  /// Every candidate was rejected: "No other suggestion".
  exhausted,
}

/// The validation error of a value typed or composed (NFR3.9, FR1.5).
enum GuidedFieldError {
  /// Longer than the field allows.
  tooLong,

  /// A vintage outside 1900 .. current year + 1, or not 4 digits.
  outOfRange,

  /// Control characters, which the form never takes.
  invalid,
}

/// The 2-second notice above a question (BR7.12).
sealed class GuidedNotice {
  const GuidedNotice();
}

/// "«value» no: here's the next one".
class RejectedNotice extends GuidedNotice {
  const RejectedNotice(this.value);

  final String value;

  // No text in the string form (BR7.22).
  @override
  String toString() => 'RejectedNotice';
}

/// "No other suggestion: compose it or skip".
class NoMoreNotice extends GuidedNotice {
  const NoMoreNotice();
}

/// How a confirmed answer was given (ENT-013).
enum AnswerVia { yes, compose, edit, wheel }

/// The answer to a field, kept in the memory of the form (ENT-013). "Skip"
/// and closing are no answer (BR7.17).
sealed class GuidedAnswer {
  const GuidedAnswer();
}

/// A value confirmed with Yes, the words, Edit or the wheel.
class ConfirmedAnswer extends GuidedAnswer {
  const ConfirmedAnswer(this.value, this.via);

  final String value;
  final AnswerVia via;

  @override
  String toString() => 'ConfirmedAnswer(${via.name})';
}

/// "Edit" confirmed empty: the field stays empty by choice.
class EmptiedByEditAnswer extends GuidedAnswer {
  const EmptiedByEditAnswer();
}

/// "No vintage".
class NoVintageAnswer extends GuidedAnswer {
  const NoVintageAnswer();
}

/// One open guide (ENT-012).
class GuidedSession {
  const GuidedSession({
    required this.analysis,
    required this.questions,
    required this.index,
    required this.mode,
    this.proposal,
    this.noProposalReason,
    this.keyboardOpen = false,
    this.selected = const [],
    this.editText = '',
    this.wheelYear = 0,
    this.error,
    this.notice,
    this.skipped = const {},
  });

  final LabelAnalysis analysis;

  /// Fixed when the guide opens (BR7.11): 1 to 4.
  final List<KeyField> questions;

  /// The question asked now, 0 .. [total] - 1.
  final int index;
  final GuidedMode mode;

  /// The candidate proposed now; `null` without one (BR7.12).
  final FieldCandidate? proposal;
  final NoProposalReason? noProposalReason;

  /// The number pad of the wheel is open (BR7.13).
  final bool keyboardOpen;

  /// Ids of the words chosen in [GuidedMode.compose], in tap order.
  final List<int> selected;

  /// The text of [GuidedMode.edit].
  final String editText;

  /// The year in the middle of the wheel.
  final int wheelYear;
  final GuidedFieldError? error;
  final GuidedNotice? notice;

  /// The fields skipped in this guide, for the final message.
  final Set<KeyField> skipped;

  /// The field asked now.
  KeyField get field => questions[index];

  /// "Question N of T" (FR7.6): N grows only with the next question.
  int get number => index + 1;
  int get total => questions.length;

  GuidedSession copyWith({
    int? index,
    GuidedMode? mode,
    FieldCandidate? Function()? proposal,
    NoProposalReason? Function()? noProposalReason,
    bool? keyboardOpen,
    List<int>? selected,
    String? editText,
    int? wheelYear,
    GuidedFieldError? Function()? error,
    GuidedNotice? Function()? notice,
    Set<KeyField>? skipped,
  }) => GuidedSession(
    analysis: analysis,
    questions: questions,
    index: index ?? this.index,
    mode: mode ?? this.mode,
    proposal: proposal == null ? this.proposal : proposal(),
    noProposalReason: noProposalReason == null
        ? this.noProposalReason
        : noProposalReason(),
    keyboardOpen: keyboardOpen ?? this.keyboardOpen,
    selected: selected ?? this.selected,
    editText: editText ?? this.editText,
    wheelYear: wheelYear ?? this.wheelYear,
    error: error == null ? this.error : error(),
    notice: notice == null ? this.notice : notice(),
    skipped: skipped ?? this.skipped,
  );

  // No text in the string form (BR7.22).
  @override
  String toString() =>
      'GuidedSession(${field.name}, $number of $total, ${mode.name})';
}

/// The memory of one add form (ENT-014). Emptied by "Clear" (BR7.21), lost
/// when the form or the process closes (BR7.19).
class GuidedMemory {
  const GuidedMemory({
    this.answers = const {},
    this.rejected = const {},
    this.usedWords = const {},
    this.manual = const {},
    this.analysis,
    this.session,
  });

  static const GuidedMemory empty = GuidedMemory();

  /// Fields with an answer are never asked again, not even with a new
  /// text (BR7.13, BR7.18).
  final Map<KeyField, GuidedAnswer> answers;

  /// Values rejected with "No", folded: they never come back (BR7.12).
  final Map<KeyField, Set<String>> rejected;

  /// The words used by each confirmed field, for the mark "used for …"
  /// (BR7.15); they never disable a word.
  final Map<KeyField, Set<int>> usedWords;

  /// Fields written by hand while the guide was closed (BR7.19).
  final Set<KeyField> manual;

  /// The last analysis, to reopen the guide.
  final LabelAnalysis? analysis;

  /// The open guide, if any.
  final GuidedSession? session;

  GuidedMemory copyWith({
    Map<KeyField, GuidedAnswer>? answers,
    Map<KeyField, Set<String>>? rejected,
    Map<KeyField, Set<int>>? usedWords,
    Set<KeyField>? manual,
    LabelAnalysis? Function()? analysis,
    GuidedSession? Function()? session,
  }) => GuidedMemory(
    answers: answers ?? this.answers,
    rejected: rejected ?? this.rejected,
    usedWords: usedWords ?? this.usedWords,
    manual: manual ?? this.manual,
    analysis: analysis == null ? this.analysis : analysis(),
    session: session == null ? this.session : session(),
  );

  /// The questions of the last analysis (BR7.10, BR7.17): uncertain fields
  /// (never absent ones) that are [empty] in the form, not written by hand
  /// and without an answer, in the order of [KeyField]. None for a text with
  /// no clue at all (BR7.10: the vintage alone is never asked).
  List<KeyField> pendingQuestions(Set<KeyField> empty) {
    final last = analysis;
    if (last == null || !last.hasClues) return const [];
    return [
      for (final field in last.uncertainFields)
        if (empty.contains(field) &&
            !manual.contains(field) &&
            !answers.containsKey(field))
          field,
    ];
  }

  /// The person wrote [field] by hand with the guide closed (BR7.19).
  GuidedMemory markManual(KeyField field) =>
      session != null || manual.contains(field)
      ? this
      : copyWith(manual: {...manual, field});

  /// A new text (BR7.18): the guide open closes, the old analysis and the
  /// used words go (their ids change); answers and rejections stay.
  GuidedMemory withText(LabelAnalysis analysis) => copyWith(
    analysis: () => analysis,
    session: () => null,
    usedWords: const {},
  );

  @override
  String toString() =>
      'GuidedMemory(${answers.length} answers, ${session ?? 'closed'})';
}

/// What the form does after a transition.
sealed class GuidedEffect {
  const GuidedEffect();
}

/// Fill [field] with [value]: marked "✦ from the text" when [fromText];
/// [denominationKey] names the table row of a denomination (BR7.20). An
/// empty [value] empties the field ("Edit" confirmed empty).
class FillEffect extends GuidedEffect {
  const FillEffect(
    this.field,
    this.value, {
    required this.fromText,
    this.denominationKey,
  });

  final KeyField field;
  final String value;
  final bool fromText;
  final String? denominationKey;

  @override
  String toString() => 'FillEffect(${field.name}, fromText: $fromText)';
}

/// Tick "No vintage" in the form (BR7.13).
class NoVintageEffect extends GuidedEffect {
  const NoVintageEffect();
}

/// The screen reader announces the new proposal (A20).
class AnnounceProposalEffect extends GuidedEffect {
  const AnnounceProposalEffect(this.value);

  final String value;

  @override
  String toString() => 'AnnounceProposalEffect';
}

/// The sheet closed. [completed] after the last question, when the fields
/// in [skipped] get their message (BR7.12); a close by hand shows none.
class ClosedEffect extends GuidedEffect {
  const ClosedEffect({required this.completed, this.skipped = const {}});

  final bool completed;
  final Set<KeyField> skipped;
}

/// The actions of the sheet (ENT-012).
sealed class GuidedAction {
  const GuidedAction();
}

class YesAction extends GuidedAction {
  const YesAction();
}

class NoAction extends GuidedAction {
  const NoAction();
}

class EditAction extends GuidedAction {
  const EditAction();
}

class EditChangedAction extends GuidedAction {
  const EditChangedAction(this.text);

  final String text;
}

class SkipAction extends GuidedAction {
  const SkipAction();
}

/// A tap on the word [id] (BR7.15): the first one opens "Compose".
class ToggleWordAction extends GuidedAction {
  const ToggleWordAction(this.id);

  final int id;
}

/// "Confirm" in "Compose" or "Edit".
class ConfirmAction extends GuidedAction {
  const ConfirmAction();
}

/// "Cancel" in "Compose" or "Edit".
class CancelAction extends GuidedAction {
  const CancelAction();
}

class WheelChangedAction extends GuidedAction {
  const WheelChangedAction(this.year);

  final int year;
}

/// A tap on the year in the middle of the wheel (BR7.13).
class OpenKeyboardAction extends GuidedAction {
  const OpenKeyboardAction();
}

/// "OK" on the number pad.
class KeyboardSubmitAction extends GuidedAction {
  const KeyboardSubmitAction(this.text);

  final String text;
}

/// "Confirm" and the year on the wheel.
class WheelConfirmAction extends GuidedAction {
  const WheelConfirmAction();
}

class NoVintageAction extends GuidedAction {
  const NoVintageAction();
}

/// The Back key (BR7.17).
class BackAction extends GuidedAction {
  const BackAction();
}

/// A tap on the dimmed form (BR7.17).
class TapOutsideAction extends GuidedAction {
  const TapOutsideAction();
}

/// "Close ✕".
class CloseAction extends GuidedAction {
  const CloseAction();
}

/// The 2 seconds of the notice are over (BR7.12).
class NoticeExpiredAction extends GuidedAction {
  const NoticeExpiredAction();
}

/// What the form holds that the transitions need: the year, and the type
/// and country for the choice of a composed denomination (BR7.16).
class GuidedContext {
  const GuidedContext({required this.currentYear, this.wineType, this.country});

  final int currentYear;
  final WineType? wineType;
  final String? country;

  int get minYear => WineRules.minVintage;

  /// The newest vintage the form saves: the upper bound of
  /// [WineRules.validateVintage], so the guide never gives a vintage that
  /// fails on "Save". Deviation from the "+1" of FR7.4 (code-summary.md).
  int get maxYear => currentYear;

  /// The wheel starts here without a candidate (BR7.13).
  int get defaultYear => currentYear - 2;
}

/// A new state and the effects to apply.
class GuidedStep {
  const GuidedStep(this.memory, [this.effects = const []]);

  final GuidedMemory memory;
  final List<GuidedEffect> effects;
}

/// Opens the guide on the [questions] of the last analysis (BR7.10,
/// BR7.11); unchanged when there is none.
GuidedMemory openGuide(
  GuidedMemory memory,
  List<KeyField> questions,
  GuidedContext context,
) {
  final analysis = memory.analysis;
  if (analysis == null || questions.isEmpty) return memory;
  final fixed = List<KeyField>.unmodifiable(questions.take(4));
  final session = _questionAt(
    GuidedSession(
      analysis: analysis,
      questions: fixed,
      index: 0,
      mode: GuidedMode.question,
    ),
    0,
    memory,
    context,
  );
  return memory.copyWith(session: () => session);
}

/// The session at question [index]: the first candidate not rejected, or
/// the wheel for the vintage (BR7.12, BR7.13).
GuidedSession _questionAt(
  GuidedSession session,
  int index,
  GuidedMemory memory,
  GuidedContext context,
) {
  final field = session.questions[index];
  final candidates = session.analysis[field].candidates;
  if (field == KeyField.vintage) {
    final year = candidates.firstOrNull?.year ?? context.defaultYear;
    return GuidedSession(
      analysis: session.analysis,
      questions: session.questions,
      index: index,
      mode: GuidedMode.yearWheel,
      wheelYear: year.clamp(context.minYear, context.maxYear),
      skipped: session.skipped,
    );
  }
  final proposal = _nextCandidate(candidates, memory.rejected[field]);
  return GuidedSession(
    analysis: session.analysis,
    questions: session.questions,
    index: index,
    mode: GuidedMode.question,
    proposal: proposal,
    noProposalReason: proposal == null
        ? (candidates.isEmpty
              ? NoProposalReason.notFound
              : NoProposalReason.exhausted)
        : null,
    skipped: session.skipped,
  );
}

FieldCandidate? _nextCandidate(
  List<FieldCandidate> candidates,
  Set<String>? rejected,
) {
  for (final candidate in candidates) {
    if (!(rejected?.contains(candidate.folded) ?? false)) return candidate;
  }
  return null;
}

/// Applies [action] to the guide of [memory] (ENT-012 transitions). Without
/// an open guide nothing changes.
GuidedStep reduceGuide(
  GuidedMemory memory,
  GuidedAction action,
  GuidedContext context,
) {
  final session = memory.session;
  if (session == null) return GuidedStep(memory);
  GuidedStep same([GuidedSession? next]) =>
      GuidedStep(memory.copyWith(session: () => next ?? session));
  switch (action) {
    case CloseAction():
      return _close(memory, completed: false);
    case NoticeExpiredAction():
      return same(session.copyWith(notice: () => null));
    case BackAction():
      if (session.mode == GuidedMode.compose ||
          session.mode == GuidedMode.edit) {
        return same(_backToQuestion(session));
      }
      if (session.keyboardOpen) {
        return same(session.copyWith(keyboardOpen: false, error: () => null));
      }
      return _close(memory, completed: false);
    case TapOutsideAction():
      if (session.mode == GuidedMode.compose ||
          session.mode == GuidedMode.edit) {
        return GuidedStep(memory);
      }
      return _close(memory, completed: false);
    case SkipAction():
      return _advance(
        memory,
        session.copyWith(skipped: {...session.skipped, session.field}),
        context,
      );
    case YesAction():
      return _yes(memory, session, context);
    case NoAction():
      return _no(memory, session);
    case EditAction():
      if (session.mode != GuidedMode.question) return GuidedStep(memory);
      return same(
        session.copyWith(
          mode: GuidedMode.edit,
          editText: session.proposal?.value ?? '',
          error: () => null,
          notice: () => null,
        ),
      );
    case EditChangedAction(:final text):
      if (session.mode != GuidedMode.edit) return GuidedStep(memory);
      return same(session.copyWith(editText: text, error: () => null));
    case ToggleWordAction(:final id):
      return _toggle(memory, session, id);
    case ConfirmAction():
      return switch (session.mode) {
        GuidedMode.edit => _confirmEdit(memory, session, context),
        GuidedMode.compose => _confirmCompose(memory, session, context),
        _ => GuidedStep(memory),
      };
    case CancelAction():
      // Only "Compose" and "Edit" have a "Cancel"; the wheel and a
      // question stay as they are.
      if (session.mode != GuidedMode.compose &&
          session.mode != GuidedMode.edit) {
        return GuidedStep(memory);
      }
      return same(_backToQuestion(session));
    case WheelChangedAction(:final year):
      if (session.mode != GuidedMode.yearWheel) return GuidedStep(memory);
      return same(
        session.copyWith(
          wheelYear: year.clamp(context.minYear, context.maxYear),
        ),
      );
    case OpenKeyboardAction():
      if (session.mode != GuidedMode.yearWheel) return GuidedStep(memory);
      return same(session.copyWith(keyboardOpen: true, error: () => null));
    case KeyboardSubmitAction(:final text):
      if (!session.keyboardOpen) return GuidedStep(memory);
      final year = _yearOf(text, context);
      if (year == null) {
        return same(session.copyWith(error: () => GuidedFieldError.outOfRange));
      }
      return same(
        session.copyWith(
          wheelYear: year,
          keyboardOpen: false,
          error: () => null,
        ),
      );
    case WheelConfirmAction():
      if (session.mode != GuidedMode.yearWheel) return GuidedStep(memory);
      final year = session.wheelYear;
      final fromText = session.analysis[KeyField.vintage].candidates.any(
        (candidate) => candidate.year == year,
      );
      return _answer(
        memory,
        session,
        context,
        ConfirmedAnswer('$year', AnswerVia.wheel),
        FillEffect(KeyField.vintage, '$year', fromText: fromText),
      );
    case NoVintageAction():
      if (session.mode != GuidedMode.yearWheel) return GuidedStep(memory);
      return _answer(
        memory,
        session,
        context,
        const NoVintageAnswer(),
        const NoVintageEffect(),
      );
  }
}

GuidedSession _backToQuestion(GuidedSession session) => session.copyWith(
  mode: GuidedMode.question,
  selected: const [],
  editText: '',
  error: () => null,
);

GuidedStep _yes(
  GuidedMemory memory,
  GuidedSession session,
  GuidedContext context,
) {
  final proposal = session.proposal;
  if (session.mode != GuidedMode.question || proposal == null) {
    return GuidedStep(memory);
  }
  return _answer(
    memory,
    session,
    context,
    ConfirmedAnswer(proposal.value, AnswerVia.yes),
    FillEffect(
      session.field,
      proposal.value,
      fromText: true,
      denominationKey: proposal.denominationKey,
    ),
    words: proposal.wordIds.toSet(),
  );
}

GuidedStep _no(GuidedMemory memory, GuidedSession session) {
  final proposal = session.proposal;
  if (session.mode != GuidedMode.question || proposal == null) {
    return GuidedStep(memory);
  }
  final field = session.field;
  final rejected = {
    ...memory.rejected,
    field: {...?memory.rejected[field], proposal.folded},
  };
  final next = _nextCandidate(
    session.analysis[field].candidates,
    rejected[field],
  );
  final updated = memory.copyWith(rejected: rejected);
  if (next == null) {
    return GuidedStep(
      updated.copyWith(
        session: () => session.copyWith(
          proposal: () => null,
          noProposalReason: () => NoProposalReason.exhausted,
          notice: () => const NoMoreNotice(),
        ),
      ),
    );
  }
  return GuidedStep(
    updated.copyWith(
      session: () => session.copyWith(
        proposal: () => next,
        notice: () => RejectedNotice(proposal.value),
      ),
    ),
    [AnnounceProposalEffect(next.value)],
  );
}

GuidedStep _toggle(GuidedMemory memory, GuidedSession session, int id) {
  if (session.mode != GuidedMode.question &&
      session.mode != GuidedMode.compose) {
    return GuidedStep(memory);
  }
  final words = session.analysis.words;
  if (id < 0 || id >= words.length) return GuidedStep(memory);
  final selected = session.selected.toSet();
  if (!canSelect(words, selected, id)) return GuidedStep(memory);
  final next = selected.contains(id)
      ? [
          for (final chosen in session.selected)
            if (chosen != id) chosen,
        ]
      : [...session.selected, id];
  return GuidedStep(
    memory.copyWith(
      session: () => session.copyWith(
        mode: GuidedMode.compose,
        selected: next,
        error: () => null,
        notice: () => null,
      ),
    ),
  );
}

GuidedStep _confirmEdit(
  GuidedMemory memory,
  GuidedSession session,
  GuidedContext context,
) {
  final value = session.editText.trim();
  final field = session.field;
  if (value.isEmpty) {
    return _answer(
      memory,
      session,
      context,
      const EmptiedByEditAnswer(),
      FillEffect(field, '', fromText: false),
    );
  }
  final error = validateGuidedValue(field, value, context);
  if (error != null) {
    return GuidedStep(
      memory.copyWith(session: () => session.copyWith(error: () => error)),
    );
  }
  final proposal = session.proposal;
  final fromText = proposal != null && proposal.value == value;
  return _answer(
    memory,
    session,
    context,
    ConfirmedAnswer(value, AnswerVia.edit),
    FillEffect(
      field,
      value,
      fromText: fromText,
      denominationKey: fromText ? proposal.denominationKey : null,
    ),
    words: fromText ? proposal.wordIds.toSet() : const {},
  );
}

GuidedStep _confirmCompose(
  GuidedMemory memory,
  GuidedSession session,
  GuidedContext context,
) {
  if (session.selected.isEmpty) return GuidedStep(memory);
  final field = session.field;
  final selected = session.selected.toSet();
  var value = composeValue(session.analysis.words, selected);
  String? key;
  if (field == KeyField.denomination) {
    final match = composedDenomination(value, context);
    if (match != null) {
      value = match.displayName;
      key = match.key;
    }
  }
  final error = validateGuidedValue(field, value, context);
  if (error != null) {
    return GuidedStep(
      memory.copyWith(session: () => session.copyWith(error: () => error)),
    );
  }
  return _answer(
    memory,
    session,
    context,
    ConfirmedAnswer(value, AnswerVia.compose),
    FillEffect(field, value, fromText: true, denominationKey: key),
    words: selected,
  );
}

/// The table row of a composed denomination (BR7.16), with the choice of
/// the estimate on the type and country of the form.
AppellationInfo? composedDenomination(String value, GuidedContext context) =>
    matchDenomination(value, type: context.wineType, country: context.country);

/// The validation of the form for a value of [field] (FR1.5, NFR3.9):
/// lengths of the form, the vintage in 1900 .. current year + 1, no control
/// characters. `null` when valid.
GuidedFieldError? validateGuidedValue(
  KeyField field,
  String value,
  GuidedContext context,
) {
  final trimmed = value.trim();
  if (trimmed.codeUnits.any((u) => u < 0x20 || (u >= 0x7F && u <= 0x9F))) {
    return GuidedFieldError.invalid;
  }
  final length = trimmed.runes.length;
  return switch (field) {
    KeyField.name =>
      length > WineRules.maxNameLength ? GuidedFieldError.tooLong : null,
    KeyField.producer =>
      length > WineValidator.maxProducerLength
          ? GuidedFieldError.tooLong
          : null,
    KeyField.denomination =>
      length > WineValidator.maxDenominationLength
          ? GuidedFieldError.tooLong
          : null,
    KeyField.vintage =>
      _yearOf(trimmed, context) == null ? GuidedFieldError.outOfRange : null,
  };
}

int? _yearOf(String text, GuidedContext context) {
  final trimmed = text.trim();
  if (!RegExp(r'^\d{4}$').hasMatch(trimmed)) return null;
  // The validation of the form itself (FR1.5): one source of truth.
  final error = WineRules.validateVintage(
    trimmed,
    noVintage: false,
    currentYear: context.currentYear,
  );
  return error == null ? int.parse(trimmed) : null;
}

/// Records [answer], applies [fill] and goes to the next question.
GuidedStep _answer(
  GuidedMemory memory,
  GuidedSession session,
  GuidedContext context,
  GuidedAnswer answer,
  GuidedEffect fill, {
  Set<int> words = const {},
}) {
  final field = session.field;
  final updated = memory.copyWith(
    answers: {...memory.answers, field: answer},
    usedWords: {
      for (final entry in memory.usedWords.entries)
        if (entry.key != field) entry.key: entry.value,
      if (words.isNotEmpty) field: words,
    },
  );
  final step = _advance(updated, session, context);
  return GuidedStep(step.memory, [fill, ...step.effects]);
}

/// The next question, or the end of the guide after the last one.
GuidedStep _advance(
  GuidedMemory memory,
  GuidedSession session,
  GuidedContext context,
) {
  final next = session.index + 1;
  if (next >= session.total) {
    return GuidedStep(memory.copyWith(session: () => null), [
      ClosedEffect(completed: true, skipped: session.skipped),
    ]);
  }
  return GuidedStep(
    memory.copyWith(session: () => _questionAt(session, next, memory, context)),
  );
}

GuidedStep _close(GuidedMemory memory, {required bool completed}) => GuidedStep(
  memory.copyWith(session: () => null),
  [ClosedEffect(completed: completed)],
);
