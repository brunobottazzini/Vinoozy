import 'package:estimation/estimation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

import '../../app/theme.dart';
import '../../l10n/app_localizations.dart';
import '../domain/wine_validator.dart';
import 'wine_labels.dart';

// The parts of the Style of a wine (wine-style-profiles, frontend-
// components.md): the "✦ suggested" mark and "Restore suggestion", the style
// chips, the disgorgement or bottling date, the "Style to confirm" notice.
// Every text comes from the translation files; every tappable area is at
// least 48 dp (NFR5).

/// "✦ suggested" next to a field filled by the preselection (BR7.7), in
/// the colours of "✦ from the text". One mark per field.
class SuggestedMark extends StatelessWidget {
  const SuggestedMark({super.key, required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: scheme.secondaryContainer,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            l10n.suggestedMark,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: scheme.onSecondaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

/// "Restore suggestion" (BR7.3): shown only when the caller says so; the
/// tap restores and announces "Suggestion restored".
class RestoreSuggestionLink extends StatelessWidget {
  const RestoreSuggestionLink({
    super.key,
    required this.visible,
    required this.onRestore,
  });

  final bool visible;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: TextButton.icon(
        style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
        onPressed: () {
          onRestore();
          SemanticsService.sendAnnouncement(
            View.of(context),
            l10n.restoreSuggestionDone,
            Directionality.of(context),
          );
        },
        icon: const Icon(Icons.auto_awesome_outlined),
        label: Text(l10n.restoreSuggestion),
      ),
    );
  }
}

/// The Style of a wine (BR5.1-BR5.3): single-choice chips for [wineType];
/// the selected one is highlighted, the suggestion marked once.
class StyleField extends StatelessWidget {
  const StyleField({
    super.key,
    required this.wineType,
    required this.selected,
    required this.suggested,
    required this.onChanged,
  });

  final WineType wineType;
  final WineStyle? selected;

  /// True when [selected] was filled by the preselection.
  final bool suggested;
  final ValueChanged<WineStyle> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final options = WineStyle.optionsFor(wineType);
    return Column(
      key: const Key('style-field'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        Text(l10n.styleLabel, style: theme.textTheme.titleSmall),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final (index, style) in options.indexed)
              Semantics(
                label: l10n.styleGroupSemantics(
                  styleLabel(l10n, style) +
                      (suggested && style == selected
                          ? ', ${l10n.suggestedMark}'
                          : ''),
                  index + 1,
                  options.length,
                ),
                selected: style == selected,
                inMutuallyExclusiveGroup: true,
                excludeSemantics: true,
                child: ChoiceChip(
                  key: Key('style-${style.name}'),
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  label: Text(styleLabel(l10n, style)),
                  selected: style == selected,
                  onSelected: (_) => onChanged(style),
                ),
              ),
          ],
        ),
        SuggestedMark(
          key: const Key('style-suggested'),
          visible: suggested && selected != null,
        ),
      ],
    );
  }
}

/// The disgorgement or bottling date (BR8.1, BR8.2): month menu and year,
/// with the error under the field and "It is usually on the back label."
class AgingStartField extends StatelessWidget {
  const AgingStartField({
    super.key,
    required this.anchor,
    required this.month,
    required this.yearController,
    required this.onMonthChanged,
    required this.onYearChanged,
    this.error,
  });

  final AgingAnchor anchor;
  final int? month;
  final TextEditingController yearController;
  final ValueChanged<int?> onMonthChanged;
  final ValueChanged<String> onYearChanged;
  final AgingStartError? error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final label = anchor == AgingAnchor.disgorgement
        ? l10n.agingStartDisgorgement
        : l10n.agingStartBottling;
    final errorText = switch (error) {
      AgingStartError.incomplete => l10n.agingStartIncomplete,
      AgingStartError.future => l10n.agingStartFuture,
      AgingStartError.beforeVintage => l10n.agingStartBeforeVintage,
      AgingStartError.outOfRange => l10n.agingStartIncomplete,
      null => null,
    };
    return Column(
      key: const Key('aging-start-field'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        Text(label, style: theme.textTheme.titleSmall),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: DropdownButtonFormField<int?>(
                key: const Key('aging-start-month'),
                initialValue: month,
                isExpanded: true,
                decoration: InputDecoration(labelText: l10n.agingStartMonth),
                items: [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text(l10n.filterTypeUnspecified),
                  ),
                  for (var m = 1; m <= 12; m++)
                    DropdownMenuItem<int?>(
                      value: m,
                      child: Text(_monthName(context, m)),
                    ),
                ],
                onChanged: onMonthChanged,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: TextField(
                key: const Key('aging-start-year'),
                controller: yearController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                decoration: InputDecoration(labelText: l10n.agingStartYear),
                onChanged: onYearChanged,
              ),
            ),
          ],
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Semantics(
              liveRegion: true,
              child: Text(
                errorText,
                key: const Key('aging-start-error'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            l10n.agingStartHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  /// The month name in the app language ("marzo"), without the year.
  static String _monthName(BuildContext context, int month) {
    final full = formatMonthLong(context, 2001, month);
    return full.replaceAll(RegExp(r'\s*(de\s+)?2001\s*'), '').trim();
  }
}

/// "⚠︎ Style to confirm: the estimate is indicative" (BR5.4), in the
/// colours of the existing notices.
class StyleToConfirmBanner extends StatelessWidget {
  const StyleToConfirmBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = StatusColors.of(context);
    return Semantics(
      container: true,
      child: Container(
        key: const Key('style-to-confirm'),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: colors.waitingChip,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          AppLocalizations.of(context).styleToConfirmBanner,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colors.onWaitingChip,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
