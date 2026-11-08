import 'package:estimation/estimation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../../label/core/guided_session.dart';
import 'guided_confirm_controller.dart';

// The guided check of the uncertain fields (label-autofill-windows FR7,
// D10, frontend-components.md, mockups G1-G5, A15-A22): a layer at the
// bottom of the add form, one question at a time. Every text comes from
// the translation files; values are shown, never logged (BR7.22).

/// The minimum height of every answer, word and wheel row (A18).
const double _tapHeight = 48;

/// The sheet of the guide (D10): above the dimmed form, in its `Stack`.
/// The form handles Back ([GuidedConfirmController.dispatch] with
/// [BackAction]) and the tap outside ([TapOutsideAction]).
class GuidedConfirmSheet extends StatelessWidget {
  const GuidedConfirmSheet({super.key, required this.controller, this.message});

  final GuidedConfirmController controller;

  /// "Filled from the text" of the text that opened the guide, read by the
  /// screen reader; `null` when nothing was filled.
  final String? message;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final session = controller.session;
        if (session == null) return const SizedBox.shrink();
        return _SheetBody(
          controller: controller,
          session: session,
          message: message,
        );
      },
    );
  }
}

class _SheetBody extends StatelessWidget {
  const _SheetBody({
    required this.controller,
    required this.session,
    required this.message,
  });

  final GuidedConfirmController controller;
  final GuidedSession session;
  final String? message;

  void _send(GuidedAction action) => controller.dispatch(action);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);
    final reduced = media.disableAnimations;
    final content = Material(
      key: const Key('guide-sheet'),
      elevation: 8,
      color: theme.colorScheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: media.size.height * 0.85),
        child: SingleChildScrollView(
          key: const Key('guide-scroll'),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message case final text?)
                Semantics(
                  liveRegion: true,
                  child: Text(
                    text,
                    key: const Key('guide-filled-message'),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              _Header(
                session: session,
                onClose: () => _send(const CloseAction()),
              ),
              if (session.notice case final notice?)
                _NoticeLine(notice: notice),
              _modeBody(context, l10n),
            ],
          ),
        ),
      ),
    );
    // Sized to its content: the form puts it in the bottom-sheet slot of its
    // Scaffold, so a SnackBar shows above it, never over its buttons.
    return reduced
        ? content
        : TweenAnimationBuilder<Offset>(
            tween: Tween(begin: const Offset(0, 1), end: Offset.zero),
            duration: const Duration(milliseconds: 200),
            builder: (context, offset, child) =>
                FractionalTranslation(translation: offset, child: child),
            child: content,
          );
  }

  Widget _modeBody(BuildContext context, AppLocalizations l10n) {
    final words = session.analysis.words;
    final usedBy = <int, KeyField>{
      for (final entry in controller.memory.usedWords.entries)
        if (entry.key != session.field)
          for (final id in entry.value) id: entry.key,
    };
    final picker = WordPicker(
      key: const Key('guide-words'),
      words: words,
      selected: session.selected,
      usedBy: usedBy,
      onToggle: (id) => _send(ToggleWordAction(id)),
    );
    switch (session.mode) {
      case GuidedMode.yearWheel:
        final candidates = session.analysis[KeyField.vintage].candidates;
        return Column(
          key: ValueKey('guide-question-${session.index}'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _QuestionTitle(
              semantics: l10n.guideQuestionSemantics(
                session.number,
                session.total,
                l10n.guideAskVintage,
              ),
              child: Text(
                l10n.guideAskVintage,
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            if (candidates.length > 1)
              Text(
                l10n.guideOtherYears(
                  [for (final c in candidates.skip(1)) '${c.year}'].join(', '),
                ),
                key: const Key('guide-other-years'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 8),
            VintageWheel(
              key: const Key('guide-wheel'),
              year: session.wheelYear,
              minYear: controller.contextOf().minYear,
              maxYear: controller.contextOf().maxYear,
              markedYears: {for (final c in candidates) ?c.year},
              keyboardOpen: session.keyboardOpen,
              error: session.error != null,
              onChanged: (year) => _send(WheelChangedAction(year)),
              onOpenKeyboard: () => _send(const OpenKeyboardAction()),
              onSubmitYear: (text) => _send(KeyboardSubmitAction(text)),
              onConfirm: () => _send(const WheelConfirmAction()),
              onNoVintage: () => _send(const NoVintageAction()),
              onSkip: () => _send(const SkipAction()),
            ),
          ],
        );
      case GuidedMode.edit:
        return GuidedEditField(
          key: ValueKey('guide-edit-${session.index}'),
          field: session.field,
          initial: session.editText,
          error: session.error,
          onChanged: (text) => _send(EditChangedAction(text)),
          onConfirm: () => _send(const ConfirmAction()),
          onCancel: () => _send(const CancelAction()),
        );
      case GuidedMode.compose:
        final composed = composeValue(words, session.selected.toSet());
        final match = session.field == KeyField.denomination
            ? composedDenomination(composed, controller.contextOf())
            : null;
        final atLimit = words.any(
          (word) => !canSelect(words, session.selected.toSet(), word.id),
        );
        return Column(
          key: ValueKey('guide-compose-${session.index}'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ComposePreview(
              value: composed,
              tableMatch: match?.displayName,
              error: session.error == null
                  ? null
                  : guidedErrorText(
                      l10n,
                      session.field,
                      session.error!,
                      controller.contextOf().maxYear,
                    ),
              limit: atLimit,
              onConfirm: session.selected.isEmpty
                  ? null
                  : () => _send(const ConfirmAction()),
              onCancel: () => _send(const CancelAction()),
            ),
            const SizedBox(height: 8),
            picker,
          ],
        );
      case GuidedMode.question:
        return Column(
          key: ValueKey('guide-question-${session.index}'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GuidedQuestionView(
              field: session.field,
              number: session.number,
              total: session.total,
              proposal: session.proposal?.value,
              onYes: session.proposal == null
                  ? null
                  : () => _send(const YesAction()),
              onNo: session.proposal == null
                  ? null
                  : () => _send(const NoAction()),
              onEdit: () => _send(const EditAction()),
              onSkip: () => _send(const SkipAction()),
            ),
            if (words.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                l10n.guideComposeLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 4),
              picker,
            ],
          ],
        );
    }
  }
}

/// The localized message of a validation error in the guide (FR1.5,
/// NFR3.9): the same texts as the form.
String guidedErrorText(
  AppLocalizations l10n,
  KeyField field,
  GuidedFieldError error,
  int maxYear,
) => switch (error) {
  GuidedFieldError.invalid => l10n.guideInvalidValue,
  GuidedFieldError.outOfRange => l10n.vintageRange('$maxYear'),
  GuidedFieldError.tooLong => switch (field) {
    KeyField.name => l10n.nameTooLong,
    KeyField.producer => l10n.producerTooLong,
    KeyField.denomination => l10n.denominationTooLong,
    KeyField.vintage => l10n.vintageRange('$maxYear'),
  },
};

/// "Question N of T", the progress bar and "Close ✕" (FR7.6).
class _Header extends StatelessWidget {
  const _Header({required this.session, required this.onClose});

  final GuidedSession session;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Flexible(
          child: Text(
            l10n.guideProgress(session.number, session.total),
            key: const Key('guide-progress'),
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ExcludeSemantics(
            child: Row(
              children: [
                for (var i = 0; i < session.total; i++)
                  Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: i < session.number
                            ? scheme.primary
                            : scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        IconButton(
          key: const Key('guide-close'),
          tooltip: l10n.guideClose,
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          icon: const Icon(Icons.close),
          onPressed: onClose,
        ),
      ],
    );
  }
}

/// The 2-second notice (BR7.12), read by the screen reader.
class _NoticeLine extends StatelessWidget {
  const _NoticeLine({required this.notice});

  final GuidedNotice notice;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      child: Container(
        key: const Key('guide-notice'),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: scheme.secondaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(switch (notice) {
          RejectedNotice(:final value) => l10n.guideRejected(value),
          NoMoreNotice() => l10n.guideNoMore,
        }, style: TextStyle(color: scheme.onSecondaryContainer)),
      ),
    );
  }
}

/// The title of a question: focused when it opens, read whole (A16).
class _QuestionTitle extends StatelessWidget {
  const _QuestionTitle({required this.semantics, required this.child});

  final String semantics;
  final Widget child;

  @override
  Widget build(BuildContext context) => Focus(
    autofocus: true,
    child: Semantics(
      key: const Key('guide-question-semantics'),
      label: semantics,
      excludeSemantics: true,
      focused: true,
      header: true,
      child: child,
    ),
  );
}

/// A question with its proposal and the four answers (BR7.12): "Yes",
/// "No, another", "Edit", "Skip"; without a proposal "Yes" and "No" are
/// off and "I couldn't find it in the text" shows.
class GuidedQuestionView extends StatelessWidget {
  const GuidedQuestionView({
    super.key,
    required this.field,
    required this.number,
    required this.total,
    required this.proposal,
    required this.onYes,
    required this.onNo,
    required this.onEdit,
    required this.onSkip,
  });

  final KeyField field;
  final int number;
  final int total;
  final String? proposal;
  final VoidCallback? onYes;
  final VoidCallback? onNo;
  final VoidCallback onEdit;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final value = proposal;
    final phrase = switch (field) {
      KeyField.denomination => l10n.guideIsDenomination,
      KeyField.producer => l10n.guideIsProducer,
      KeyField.name => l10n.guideIsName,
      KeyField.vintage => l10n.guideIsVintage,
    };
    final question = value == null
        ? '$phrase ${l10n.guideNoProposal}'
        : switch (field) {
            KeyField.denomination => l10n.guideAskDenomination(value),
            KeyField.producer => l10n.guideAskProducer(value),
            KeyField.name => l10n.guideAskName(value),
            KeyField.vintage => l10n.guideAskVintage,
          };
    final answers = [
      FilledButton(
        key: const Key('guide-yes'),
        style: FilledButton.styleFrom(minimumSize: const Size(48, _tapHeight)),
        onPressed: onYes,
        child: Text(l10n.guideYes),
      ),
      OutlinedButton(
        key: const Key('guide-no'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, _tapHeight),
        ),
        onPressed: onNo,
        child: Text(l10n.guideNo),
      ),
      OutlinedButton(
        key: const Key('guide-edit'),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, _tapHeight),
        ),
        onPressed: onEdit,
        child: Text(l10n.guideEdit),
      ),
      TextButton(
        key: const Key('guide-skip'),
        style: TextButton.styleFrom(minimumSize: const Size(48, _tapHeight)),
        onPressed: onSkip,
        child: Text(l10n.guideSkip),
      ),
    ];
    final large = MediaQuery.textScalerOf(context).scale(10) > 15;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _QuestionTitle(
          semantics: l10n.guideQuestionSemantics(number, total, question),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value ?? l10n.guideNoProposal,
                key: const Key('guide-proposal'),
                style:
                    (value == null
                            ? theme.textTheme.titleMedium
                            : theme.textTheme.headlineSmall)
                        ?.copyWith(color: theme.colorScheme.primary),
              ),
              Text(phrase, style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (large)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final answer in answers)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: answer,
                ),
            ],
          )
        else
          Column(
            children: [
              Row(
                children: [
                  Expanded(child: answers[0]),
                  const SizedBox(width: 8),
                  Expanded(child: answers[1]),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: answers[2]),
                  const SizedBox(width: 8),
                  Expanded(child: answers[3]),
                ],
              ),
            ],
          ),
      ],
    );
  }
}

/// "Edit" (BR7.12): the value, the keyboard open, "Confirm" and "Cancel".
class GuidedEditField extends StatefulWidget {
  const GuidedEditField({
    super.key,
    required this.field,
    required this.initial,
    required this.error,
    required this.onChanged,
    required this.onConfirm,
    required this.onCancel,
  });

  final KeyField field;
  final String initial;
  final GuidedFieldError? error;
  final ValueChanged<String> onChanged;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  State<GuidedEditField> createState() => _GuidedEditFieldState();
}

class _GuidedEditFieldState extends State<GuidedEditField> {
  late final TextEditingController _text = TextEditingController(
    text: widget.initial,
  );

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = switch (widget.field) {
      KeyField.denomination => l10n.denominationLabel,
      KeyField.producer => l10n.producerLabel,
      KeyField.name => l10n.wineNameLabel,
      KeyField.vintage => l10n.vintageLabel,
    };
    final error = widget.error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const Key('guide-edit-field'),
          controller: _text,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          onChanged: widget.onChanged,
          onSubmitted: (_) => widget.onConfirm(),
          decoration: InputDecoration(
            labelText: label,
            errorText: error == null
                ? null
                : guidedErrorText(l10n, widget.field, error, 0),
            errorMaxLines: 3,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton(
              key: const Key('guide-edit-confirm'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(48, _tapHeight),
              ),
              onPressed: widget.onConfirm,
              child: Text(l10n.guideConfirm),
            ),
            TextButton(
              key: const Key('guide-edit-cancel'),
              style: TextButton.styleFrom(
                minimumSize: const Size(48, _tapHeight),
              ),
              onPressed: widget.onCancel,
              child: Text(l10n.guideCancel),
            ),
          ],
        ),
      ],
    );
  }
}

/// The words of the text as buttons (FR7.5, BR7.14, BR7.15, A17, A21):
/// grouped by line, a chosen word filled with its order in the text, a
/// word used by another field marked but still selectable, a word beyond
/// the limits off and read "unavailable".
class WordPicker extends StatelessWidget {
  const WordPicker({
    super.key,
    required this.words,
    required this.selected,
    required this.usedBy,
    required this.onToggle,
  });

  final List<LabelWord> words;

  /// Ids chosen now.
  final List<int> selected;

  /// Ids used by another confirmed field: only a mark (BR7.15).
  final Map<int, KeyField> usedBy;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lines = <int, List<LabelWord>>{};
    for (final word in words) {
      lines.putIfAbsent(word.line, () => []).add(word);
    }
    final chosen = selected.toSet();
    final order = [
      for (final word in words)
        if (chosen.contains(word.id)) word.id,
    ];
    final groups = lines.values.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, group) in groups.indexed)
          Semantics(
            key: Key('guide-line-$index'),
            container: true,
            label: l10n.guideLine(index + 1, groups.length),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final word in group)
                    _WordButton(
                      word: word,
                      order: chosen.contains(word.id)
                          ? order.indexOf(word.id) + 1
                          : null,
                      usedFor: usedBy[word.id],
                      enabled: canSelect(words, chosen, word.id),
                      onTap: () => onToggle(word.id),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _WordButton extends StatelessWidget {
  const _WordButton({
    required this.word,
    required this.order,
    required this.usedFor,
    required this.enabled,
    required this.onTap,
  });

  final LabelWord word;
  final int? order;
  final KeyField? usedFor;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final chosen = order != null;
    final used = usedFor;
    final label = chosen
        ? l10n.guideWordSelected(word.text, order!)
        : !enabled
        ? l10n.guideWordUnavailable(word.text)
        : used != null
        ? l10n.guideWordUsedFor(word.text, used.name)
        : word.text;
    final text = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: Text(word.text)),
        if (chosen) ...[
          const SizedBox(width: 6),
          CircleAvatar(
            radius: 10,
            backgroundColor: scheme.onPrimary,
            child: Text(
              '$order',
              style: TextStyle(fontSize: 11, color: scheme.primary),
            ),
          ),
        ],
      ],
    );
    final button = chosen
        ? FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size(48, _tapHeight),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            onPressed: onTap,
            child: text,
          )
        : OutlinedButton(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(48, _tapHeight),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              side: used == null
                  ? null
                  : BorderSide(color: scheme.tertiary, width: 2),
            ),
            onPressed: enabled ? onTap : null,
            child: text,
          );
    return Semantics(
      key: Key('guide-word-${word.id}'),
      button: true,
      selected: chosen,
      enabled: enabled,
      label: label,
      onTap: enabled ? onTap : null,
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          button,
          if (used != null)
            Text(
              l10n.guideUsedMark(used.name),
              key: Key('guide-word-used-${word.id}'),
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(color: scheme.tertiary),
            ),
        ],
      ),
    );
  }
}

/// The composed value (FR7.5, BR7.15, BR7.16, A17): a live region, the
/// table match with its mark, the limits and the validation error.
class ComposePreview extends StatelessWidget {
  const ComposePreview({
    super.key,
    required this.value,
    required this.tableMatch,
    required this.error,
    required this.limit,
    required this.onConfirm,
    required this.onCancel,
  });

  final String value;

  /// The name of the table row the value matches, or `null`.
  final String? tableMatch;
  final String? error;

  /// True when some free word is off for the limits.
  final bool limit;

  /// `null` with no word chosen.
  final VoidCallback? onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final match = tableMatch;
    final shown = match ?? value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.guideComposePreview, style: theme.textTheme.labelLarge),
        Semantics(
          liveRegion: true,
          container: true,
          child: Container(
            key: const Key('guide-preview'),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              children: [
                Text(
                  shown.isEmpty ? l10n.guideComposeEmpty : shown,
                  style: theme.textTheme.titleMedium,
                ),
                if (match != null)
                  Semantics(
                    label: l10n.guideTableMatchSemantics(match),
                    excludeSemantics: true,
                    child: Text(
                      '✓ ${_markOf(match)}',
                      key: const Key('guide-table-match'),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (limit)
          Text(
            l10n.guideComposeLimit,
            key: const Key('guide-compose-limit'),
            style: theme.textTheme.bodySmall,
          ),
        if (error case final message?)
          Text(
            message,
            key: const Key('guide-compose-error'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton(
              key: const Key('guide-compose-confirm'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(48, _tapHeight),
              ),
              onPressed: onConfirm,
              child: Text(l10n.guideConfirm),
            ),
            TextButton(
              key: const Key('guide-compose-cancel'),
              style: TextButton.styleFrom(
                minimumSize: const Size(48, _tapHeight),
              ),
              onPressed: onCancel,
              child: Text(l10n.guideCancel),
            ),
          ],
        ),
      ],
    );
  }

  /// The mark of a table name: its last word when it is a sigla (DOCG,
  /// AOC, DO…), else nothing.
  static String _markOf(String name) {
    final last = name.split(' ').last;
    final sigla =
        last.length >= 2 &&
        last.length <= 5 &&
        last == last.toUpperCase() &&
        last.toLowerCase() != last;
    return sigla ? last : '';
  }
}

/// The wheel of the vintage (FR7.4, BR7.13, A22): the years from the
/// newest, the years of the text marked with a dot, a tap on the middle
/// year for the number pad; "Confirm" with the year, "No vintage" and
/// "Skip".
class VintageWheel extends StatefulWidget {
  const VintageWheel({
    super.key,
    required this.year,
    required this.minYear,
    required this.maxYear,
    required this.markedYears,
    required this.keyboardOpen,
    required this.error,
    required this.onChanged,
    required this.onOpenKeyboard,
    required this.onSubmitYear,
    required this.onConfirm,
    required this.onNoVintage,
    required this.onSkip,
  });

  final int year;
  final int minYear;
  final int maxYear;
  final Set<int> markedYears;
  final bool keyboardOpen;

  /// The typed year is out of range.
  final bool error;
  final ValueChanged<int> onChanged;
  final VoidCallback onOpenKeyboard;

  /// "OK" on the number pad; Back closes the pad through the form
  /// (BR7.13).
  final ValueChanged<String> onSubmitYear;
  final VoidCallback onConfirm;
  final VoidCallback onNoVintage;
  final VoidCallback onSkip;

  @override
  State<VintageWheel> createState() => _VintageWheelState();
}

class _VintageWheelState extends State<VintageWheel> {
  late final FixedExtentScrollController _wheel = FixedExtentScrollController(
    initialItem: _itemOf(widget.year),
  );
  final TextEditingController _typed = TextEditingController();

  int _itemOf(int year) => widget.maxYear - year;

  @override
  void didUpdateWidget(VintageWheel old) {
    super.didUpdateWidget(old);
    if (old.year != widget.year &&
        _wheel.hasClients &&
        _wheel.selectedItem != _itemOf(widget.year)) {
      _wheel.jumpToItem(_itemOf(widget.year));
    }
    if (!old.keyboardOpen && widget.keyboardOpen) {
      _typed.text = '${widget.year}';
    }
  }

  @override
  void dispose() {
    _wheel.dispose();
    _typed.dispose();
    super.dispose();
  }

  void _step(int delta) {
    final year = (widget.year + delta).clamp(widget.minYear, widget.maxYear);
    widget.onChanged(year);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scale = MediaQuery.textScalerOf(context).scale(1);
    final extent = _tapHeight * (scale < 1 ? 1 : scale);
    final count = widget.maxYear - widget.minYear + 1;
    final year = widget.year;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.keyboardOpen)
          _YearPad(
            controller: _typed,
            error: widget.error ? l10n.vintageRange('${widget.maxYear}') : null,
            onSubmit: () => widget.onSubmitYear(_typed.text),
          )
        else
          Semantics(
            key: const Key('guide-wheel-semantics'),
            slider: true,
            label: l10n.guideIsVintage,
            value: '$year',
            increasedValue:
                '${(year + 1).clamp(widget.minYear, widget.maxYear)}',
            decreasedValue:
                '${(year - 1).clamp(widget.minYear, widget.maxYear)}',
            onIncrease: () => _step(1),
            onDecrease: () => _step(-1),
            child: SizedBox(
              height: extent * 3,
              child: Stack(
                children: [
                  Center(
                    child: IgnorePointer(
                      child: Container(
                        height: extent,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  ExcludeSemantics(
                    child: ListWheelScrollView.useDelegate(
                      key: const Key('guide-wheel-list'),
                      controller: _wheel,
                      itemExtent: extent,
                      physics: const FixedExtentScrollPhysics(),
                      // A jump to the year of the state (keyboard, slider)
                      // is no change: it never dispatches during a build.
                      onSelectedItemChanged: (item) {
                        final shown = widget.maxYear - item;
                        if (shown != widget.year) widget.onChanged(shown);
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: count,
                        builder: (context, item) {
                          final shown = widget.maxYear - item;
                          final marked = widget.markedYears.contains(shown);
                          final text = Text(
                            marked ? '• $shown' : '$shown',
                            key: Key('guide-year-$shown'),
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: marked ? theme.colorScheme.primary : null,
                              fontWeight: marked ? FontWeight.w700 : null,
                            ),
                          );
                          return shown == year
                              ? GestureDetector(
                                  key: const Key('guide-wheel-center'),
                                  behavior: HitTestBehavior.opaque,
                                  onTap: widget.onOpenKeyboard,
                                  child: Center(child: text),
                                )
                              : Center(child: text);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (widget.markedYears.contains(year) && !widget.keyboardOpen)
          Text(
            l10n.guideWheelFromText,
            key: const Key('guide-wheel-from-text'),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        if (!widget.keyboardOpen)
          TextButton(
            key: const Key('guide-wheel-type'),
            style: TextButton.styleFrom(
              minimumSize: const Size(48, _tapHeight),
            ),
            onPressed: widget.onOpenKeyboard,
            child: Text(l10n.guideWheelTypeYear),
          ),
        const SizedBox(height: 8),
        FilledButton(
          key: const Key('guide-wheel-confirm'),
          style: FilledButton.styleFrom(
            minimumSize: const Size(48, _tapHeight),
          ),
          onPressed: widget.keyboardOpen ? null : widget.onConfirm,
          child: Text(l10n.guideWheelConfirm('$year')),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          key: const Key('guide-no-vintage'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(48, _tapHeight),
          ),
          onPressed: widget.onNoVintage,
          child: Text(l10n.guideNoVintage),
        ),
        TextButton(
          key: const Key('guide-wheel-skip'),
          style: TextButton.styleFrom(minimumSize: const Size(48, _tapHeight)),
          onPressed: widget.onSkip,
          child: Text(l10n.guideSkip),
        ),
      ],
    );
  }
}

/// The number pad of the wheel (BR7.13): 4 digits and "OK".
class _YearPad extends StatelessWidget {
  const _YearPad({
    required this.controller,
    required this.error,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final String? error;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            key: const Key('guide-year-field'),
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            onSubmitted: (_) => onSubmit(),
            decoration: InputDecoration(
              labelText: l10n.guideWheelTypeYear,
              errorText: error,
              errorMaxLines: 3,
            ),
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(
          key: const Key('guide-year-ok'),
          style: FilledButton.styleFrom(
            minimumSize: const Size(48, _tapHeight),
          ),
          onPressed: onSubmit,
          child: Text(l10n.ok),
        ),
      ],
    );
  }
}
