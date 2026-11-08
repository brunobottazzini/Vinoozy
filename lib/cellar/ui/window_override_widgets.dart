import 'dart:math' as math;

import 'package:estimation/estimation.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'wine_labels.dart';

// The owner's correction of "Recommended until" (label-autofill-windows
// FR5.1-FR5.4, BR4.6, interaction-spec "Correzione"; A2, A4, A7, A8) and the
// origin of the estimate.

/// "corrected by you" (FR5.2): a chip in the colours of the existing chips,
/// `onSecondaryContainer` on `secondaryContainer` (A6).
class CorrectedBadge extends StatelessWidget {
  const CorrectedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Chip(
      key: const Key('corrected-badge'),
      visualDensity: VisualDensity.compact,
      backgroundColor: scheme.secondaryContainer,
      side: BorderSide.none,
      label: Text(
        AppLocalizations.of(context).overrideCorrectedByYou,
        style: TextStyle(
          color: scheme.onSecondaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// "Recommended until": a sheet with a grid of years from "Ready from" to
/// 60 years later (BR4.6) and "more…" for the whole list; the year before
/// the start is shown struck through and is not selectable, for the
/// screen reader too (A4). The estimated end is preselected without a
/// correction (interaction-spec). Returns the year saved, or `null`.
abstract final class CorrectEndYearSheet {
  static Future<int?> show(
    BuildContext context, {
    required int startYear,
    required int peakYear,
    required int currentEnd,
  }) => showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _YearSheet(
      startYear: startYear,
      peakYear: peakYear,
      currentEnd: currentEnd,
    ),
  );

  /// The years of the grid: the start, the peak, the end and four years
  /// around it, every one within start..start+60.
  static List<int> gridYears(int startYear, int peakYear, int currentEnd) {
    final last = startYear + maxOverrideSpan;
    return {
      startYear,
      peakYear,
      for (final step in const [-8, -4, 0, 4, 8, 12]) currentEnd + step,
    }.where((year) => year >= startYear && year <= last).toList()..sort();
  }
}

class _YearSheet extends StatefulWidget {
  const _YearSheet({
    required this.startYear,
    required this.peakYear,
    required this.currentEnd,
  });

  final int startYear;
  final int peakYear;
  final int currentEnd;

  @override
  State<_YearSheet> createState() => _YearSheetState();
}

class _YearSheetState extends State<_YearSheet> {
  late int _year = math.min(
    math.max(widget.currentEnd, widget.startYear),
    widget.startYear + maxOverrideSpan,
  );

  Future<void> _more() async {
    final years = [
      for (
        var y = widget.startYear;
        y <= widget.startYear + maxOverrideSpan;
        y++
      )
        y,
    ];
    final picked = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        key: const Key('override-year-list'),
        children: [
          for (final year in years)
            SimpleDialogOption(
              key: Key('override-list-$year'),
              onPressed: () => Navigator.of(context).pop(year),
              child: Text('$year'),
            ),
        ],
      ),
    );
    if (picked != null && mounted) setState(() => _year = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final years = CorrectEndYearSheet.gridYears(
      widget.startYear,
      widget.peakYear,
      widget.currentEnd,
    );
    final grid = {...years, _year}.toList()..sort();
    return SafeArea(
      child: SingleChildScrollView(
        key: const Key('override-sheet'),
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                l10n.overrideSheetTitle,
                style: theme.textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 4),
            Text(l10n.overrideSheetHint('${widget.startYear}')),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // The year before the start: struck, never selectable (A4).
                ExcludeSemantics(
                  child: ChoiceChip(
                    key: Key('override-year-${widget.startYear - 1}'),
                    label: Text(
                      '${widget.startYear - 1}',
                      style: const TextStyle(
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    selected: false,
                    onSelected: null,
                  ),
                ),
                for (final year in grid)
                  ChoiceChip(
                    key: Key('override-year-$year'),
                    label: Text('$year'),
                    selected: year == _year,
                    onSelected: (_) => setState(() => _year = year),
                  ),
                ActionChip(
                  key: const Key('override-more'),
                  label: Text(l10n.overrideMore),
                  onPressed: _more,
                ),
              ],
            ),
            if (_year < widget.peakYear) ...[
              const SizedBox(height: 8),
              Semantics(
                liveRegion: true,
                child: Text(
                  l10n.overridePeakNotice('${widget.peakYear}'),
                  key: const Key('override-peak-notice'),
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('override-save'),
              onPressed: () => Navigator.of(context).pop(_year),
              child: Text(l10n.overrideSave),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Go back to the app estimate (until …)?" (FR5.4): true with "Restore".
/// No timed "Undo", so one write only.
abstract final class RestoreEstimateDialog {
  static Future<bool> show(BuildContext context, int estimatedEnd) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        key: const Key('restore-estimate-dialog'),
        title: Text(l10n.overrideRestoreTitle('$estimatedEnd')),
        actions: [
          TextButton(
            key: const Key('restore-estimate-cancel'),
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            key: const Key('restore-estimate-confirm'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.overrideRestoreConfirm),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }
}

/// "Estimate from the appellation …", "… from the grape …" or "… from the
/// type of wine" (interaction-spec "Origine della stima"), small, under the
/// ideal moment; nothing for a catalog window.
class EstimateSourceLine extends StatelessWidget {
  const EstimateSourceLine({super.key, required this.window});

  final DrinkingWindow window;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final text = estimateOriginText(l10n, window);
    if (text == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Text(
      text,
      key: const Key('estimate-origin'),
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
