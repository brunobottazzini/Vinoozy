import 'package:estimation/estimation.dart';
import 'package:flutter/material.dart';

import '../wine_estimator.dart';
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
class LevelChoice {
  LevelChoice({this.saved}) : value = saved;

  /// The level saved in the wine (edit form): never replaced by a
  /// suggestion.
  final WineLevel? saved;

  /// The level chosen now; `null` is "not chosen".
  WineLevel? value;

  /// True once an option or "None" was tapped.
  bool touched = false;

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
      value ?? (suggestion != null ? WineLevel.aging : null);

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
  });

  final LevelChoice choice;

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
          suggested: suggestion == null ? null : WineLevel.aging,
          suggestedReason: suggestion == null
              ? null
              : qualifierDisplayName(suggestion!),
          onChanged: onChanged,
        ),
        if (window != null)
          LevelPreview(window: window, level: level, before: before),
      ],
    );
  }
}
