import 'package:estimation/estimation.dart';
import 'package:flutter/material.dart';

import '../domain/wine.dart';
import '../wine_estimator.dart';
import '../../l10n/app_localizations.dart';
import 'style_widgets.dart';
import 'wine_labels.dart';
import 'wine_level_selector.dart';

/// The "Level" of an add or edit form (label-autofill-windows FR4.1-FR4.3,
/// BR4.3, interaction-spec "Livello"): what is chosen, whether it was
/// touched, and the suggestion from a qualifier of the name.
///
/// - Not chosen: no option highlighted, it estimates as "Good".
/// - A suggestion ("aging" from "Riserva", "Gran Reserva"…) is shown only
///   while nothing was touched and no level is saved (edit form); it goes
///   away when the qualifier leaves the name.
/// - Tapping an option chooses it; "None" goes back to "not chosen" and
///   turns the suggestion off while the form is open.
/// - "Save" with the suggestion visible saves it (accepted); "not chosen"
///   and "None" save no level.
///
/// wine-style-profiles (BR4.3, BR4.6, BR7.1-BR7.3): the level is always
/// preselected ([preselected], "✦ suggested", automatic) until an option is
/// tapped; "Restore suggestion" goes back to it. A level saved as automatic
/// is preselected again.
class LevelChoice {
  LevelChoice({WineLevel? saved, FieldSource? savedSource})
    : saved = savedSource == FieldSource.auto ? null : saved,
      value = savedSource == FieldSource.auto ? null : saved;

  /// The level saved in the wine (edit form): never replaced by a
  /// suggestion.
  final WineLevel? saved;

  /// The level chosen now; `null` is "not chosen".
  WineLevel? value;

  /// True once an option or "None" was tapped.
  bool touched = false;

  /// The level the classification proposes now (BR4.3); `null` without a
  /// name.
  WineLevel? preselected;

  /// True after "None": no suggestion until the form closes.
  bool suggestionOff = false;

  /// The qualifier read in a label text (BR1.8), used while the name is
  /// still the one filled from the text.
  Qualifier? textQualifier;

  /// The qualifier that suggests "aging" for [name] and [denomination], or
  /// `null` when no suggestion is shown.
  Qualifier? suggestionFor(
    String name,
    String? denomination, {
    bool nameFromText = false,
  }) {
    if (touched || suggestionOff || value != null || saved != null) {
      return null;
    }
    final typed = agingQualifierIn('$name ${denomination ?? ''}');
    if (typed != null) return typed;
    final fromText = textQualifier;
    if (nameFromText &&
        fromText != null &&
        agingQualifiers.contains(fromText)) {
      return fromText;
    }
    return null;
  }

  /// The level the form shows and estimates with: the chosen one, else the
  /// suggested one.
  WineLevel? effective(Qualifier? suggestion) =>
      value ??
      (suggestion != null
          ? WineLevel.aging
          : (suggestionOff ? null : preselected));

  /// The level suggested and shown with "✦ suggested", or `null`.
  WineLevel? suggestedLevel(Qualifier? suggestion) => value != null
      ? null
      : (suggestion != null
            ? WineLevel.aging
            : (suggestionOff ? null : preselected));

  /// Where the level saved comes from (BR7.1): the user's when chosen or
  /// saved by the user, automatic when suggested.
  FieldSource? sourceFor(Qualifier? suggestion) {
    if (value != null) return FieldSource.user;
    return effective(suggestion) == null ? null : FieldSource.auto;
  }

  /// "Restore suggestion" (BR7.3): visible for a level chosen that differs
  /// from the preselection.
  bool get canRestore =>
      value != null && preselected != null && preselected != value;

  /// "Restore suggestion" (BR7.3).
  void restore() {
    value = null;
    touched = false;
    suggestionOff = false;
  }

  /// A tap on an option, or `null` for "None".
  void choose(WineLevel? level) {
    touched = true;
    value = level;
    if (level == null) suggestionOff = true;
  }

  /// "Clear" (BR2.7): back to "not chosen", the suggestion on again.
  void reset() {
    value = null;
    touched = false;
    suggestionOff = false;
    textQualifier = null;
  }
}

/// The level options and, when there is an estimate, the window with the
/// level shown next to the one without it (FR4.2).
class LevelSection extends StatelessWidget {
  const LevelSection({
    super.key,
    required this.choice,
    required this.suggestion,
    required this.facts,
    required this.onChanged,
    this.onRestore,
  });

  final LevelChoice choice;

  /// "Restore suggestion" (BR7.3); `null` hides it.
  final VoidCallback? onRestore;

  /// The qualifier of the suggestion, or `null`.
  final Qualifier? suggestion;

  /// The facts of the form, without the level; `null` without a name.
  final WineFactsInput? facts;
  final ValueChanged<WineLevel?> onChanged;

  DrinkingWindow? _windowWith(WineLevel? level) {
    final input = facts;
    if (input == null) return null;
    return const WineEstimator()
        .estimate(
          WineFactsInput(
            name: input.name,
            producer: input.producer,
            vintage: input.vintage,
            wineType: input.wineType,
            region: input.region,
            denomination: input.denomination,
            referenceYear: input.referenceYear,
            level: level,
            referenceMonth: input.referenceMonth,
            style: input.style,
            styleChosen: input.styleChosen,
            agingStart: input.agingStart,
          ),
        )
        .window;
  }

  @override
  Widget build(BuildContext context) {
    final level = choice.effective(suggestion);
    final window = _windowWith(level);
    final before = _windowWith(choice.saved);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WineLevelSelector(
          value: choice.value,
          suggested: choice.suggestedLevel(suggestion),
          suggestedReason: suggestion == null
              ? null
              : qualifierDisplayName(suggestion!),
          onChanged: onChanged,
        ),
        SuggestedMark(
          key: const Key('level-suggested'),
          visible: choice.suggestedLevel(suggestion) != null,
        ),
        RestoreSuggestionLink(
          key: const Key('level-restore'),
          visible: choice.canRestore && onRestore != null,
          onRestore: onRestore ?? () {},
        ),
        if (window != null)
          LevelPreview(window: window, level: level, before: before),
        // wine-style-profiles BR4.1: months, no peak or no end.
        if (window != null && !levelChangesWindow(window))
          Text(
            AppLocalizations.of(context).levelNoEffect,
            key: const Key('level-no-effect'),
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }
}
