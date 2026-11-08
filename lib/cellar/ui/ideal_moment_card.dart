import 'dart:math' as math;

import 'package:estimation/estimation.dart';
import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../l10n/app_localizations.dart';
import '../domain/cellar_filter.dart';
import '../domain/window_adjuster.dart';
import '../domain/window_override.dart';
import '../domain/wine_estimate.dart';
import 'window_override_widgets.dart';
import 'wine_badges.dart';
import 'wine_labels.dart';

/// "Ideal moment" in the detail (owner request e22b8032; u4-cellar BR1.9,
/// FR4.1-FR4.5): "Recommended until `end`" in plain words, "At its best from
/// `start` to `end`", the colored bar of the window with today's mark, the
/// status chip, start, peak and end, the confidence and the source, and the
/// notice "⚠︎ Indicative…", always shown and read as a note.
///
/// Cases: a window already over ("…: it has passed", past the window) and
/// no estimate ("Estimate not available" with how to get one).
///
/// label-autofill-windows (FR4.4, FR5, BR4.7): the level of the wine, the
/// origin of the estimate ([EstimateSourceLine]), and with an owner's
/// correction "corrected by you" instead of the notice, with the app
/// estimate under it; "Correct" and "Restore estimate" for who can edit.
class IdealMomentCard extends StatelessWidget {
  const IdealMomentCard({
    super.key,
    required this.estimate,
    required this.today,
    this.windowOverride,
    this.level,
    this.onCorrect,
    this.onRestore,
  });

  final WineEstimate estimate;
  final DateTime today;

  /// The owner's end year (FR5); `null` without a correction.
  final WindowOverride? windowOverride;

  /// The level saved (FR4.4).
  final WineLevel? level;

  /// "Correct" and "Restore estimate"; `null` for a reader.
  final VoidCallback? onCorrect;
  final VoidCallback? onRestore;

  /// The window without the correction: the estimate with the feedback.
  DrinkingWindow? get _withoutOverride {
    final base = estimate.baseWindow;
    if (base == null) return estimate.window;
    return WindowAdjuster.effective(base, estimate.adjustment);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final window = estimate.window;
    final status = _statusOf(window);
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final override = windowOverride;
    return Card(
      key: const Key('window-card'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.uxIdealTitle,
              style: theme.textTheme.labelLarge?.copyWith(
                color: scheme.onSurfaceVariant,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            if (window == null) ...[
              Text(
                l10n.estimateUnavailable,
                key: const Key('window-none'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.uxIdealUnavailableHint,
                key: const Key('ideal-hint'),
                style: muted,
              ),
              const SizedBox(height: 8),
              StateChip(status: status),
            ] else ...[
              Wrap(
                spacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    status == StatusFilter.pastWindow
                        ? l10n.uxIdealUntilPast('${window.endYear}')
                        : l10n.uxIdealUntil('${window.endYear}'),
                    key: const Key('ideal-until'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (override != null) const CorrectedBadge(),
                ],
              ),
              Text(
                l10n.uxIdealBest('${window.startYear}', '${window.endYear}'),
                key: const Key('ideal-best'),
                style: muted,
              ),
              const SizedBox(height: 10),
              WindowBar(window: window, today: today),
              const SizedBox(height: 10),
              StateChip(status: status),
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                runSpacing: 4,
                children: [
                  Text('${l10n.windowStartLabel}: ${window.startYear}'),
                  Text('${l10n.windowPeakLabel}: ${window.peakYear}'),
                  Text('${l10n.windowEndLabel}: ${window.endYear}'),
                ],
              ),
              const SizedBox(height: 4),
              Text(confidenceText(l10n, window.confidence), style: muted),
              Text(
                estimateSourceText(
                  l10n,
                  WindowAdjuster.labelOf(
                    window: window,
                    base: estimate.baseWindow,
                    adjustment: estimate.adjustment,
                    override: override,
                  ),
                ),
                key: const Key('window-source'),
                style: muted,
              ),
              if (override != null && _withoutOverride != null)
                Text(
                  l10n.overrideAppEstimate('${_withoutOverride!.endYear}'),
                  key: const Key('override-app-estimate'),
                  style: muted,
                ),
              EstimateSourceLine(window: estimate.baseWindow ?? window),
              if (level case final level?)
                Text(
                  l10n.levelDetail(levelLabel(l10n, level)),
                  key: const Key('ideal-level'),
                  style: muted,
                ),
              if (onCorrect != null || (onRestore != null && override != null))
                Wrap(
                  spacing: 8,
                  children: [
                    if (onCorrect != null)
                      TextButton.icon(
                        key: const Key('override-correct'),
                        style: TextButton.styleFrom(
                          minimumSize: const Size(48, 48),
                        ),
                        onPressed: onCorrect,
                        icon: const Icon(Icons.edit_calendar_outlined),
                        label: Text(l10n.overrideCorrect),
                      ),
                    if (onRestore != null && override != null)
                      TextButton.icon(
                        key: const Key('override-restore'),
                        style: TextButton.styleFrom(
                          minimumSize: const Size(48, 48),
                        ),
                        onPressed: onRestore,
                        icon: const Icon(Icons.restore),
                        label: Text(l10n.overrideRestore),
                      ),
                  ],
                ),
            ],
            // FR5.2: with a correction "corrected by you" replaces the
            // "Indicative" notice.
            if (override == null || window == null) ...[
              const SizedBox(height: 12),
              _Notice(text: l10n.uxIdealDisclaimer),
            ],
          ],
        ),
      ),
    );
  }

  StatusFilter _statusOf(DrinkingWindow? window) {
    if (window == null) return StatusFilter.toEstimate;
    try {
      return StatusFilter.of(statusOf(window, today));
    } on Object {
      return StatusFilter.toEstimate;
    }
  }
}

/// The notice in the warning colors, announced as a note (A1).
class _Notice extends StatelessWidget {
  const _Notice({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = StatusColors.of(context);
    return Semantics(
      container: true,
      child: Container(
        key: const Key('window-disclaimer'),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colors.waitingChip,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: colors.onWaitingChip),
        ),
      ),
    );
  }
}

/// The window as a bar: "wait" before the start, "ready" from start to end,
/// "past" after the end, with today's mark; one year of margin on each side
/// and today always inside. Read as "Drinking window from … to …".
class WindowBar extends StatelessWidget {
  const WindowBar({super.key, required this.window, required this.today});

  final DrinkingWindow window;
  final DateTime today;

  /// First and last year shown.
  ({int from, int to}) get range => (
    from: math.min(window.startYear, today.year) - 1,
    to: math.max(window.endYear, today.year) + 1,
  );

  /// Position of today on the bar, from 0 (left) to 1 (right).
  double get todayFraction {
    final (:from, :to) = range;
    final years = to - from + 1;
    final dayOfYear = today.difference(DateTime(today.year)).inDays;
    return ((today.year - from) + dayOfYear / 365) / years;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final colors = StatusColors.of(context);
    final (:from, :to) = range;
    final before = window.startYear - from;
    final inside = window.endYear - window.startYear + 1;
    final after = to - window.endYear;
    final legend = Theme.of(context).textTheme.labelSmall
        ?.copyWith(color: scheme.onSurfaceVariant);
    return Semantics(
      key: const Key('ideal-bar'),
      label: l10n.uxIdealBar('${window.startYear}', '${window.endYear}'),
      excludeSemantics: true,
      child: Column(
        children: [
          SizedBox(
            height: 20,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final markLeft = (constraints.maxWidth * todayFraction).clamp(
                  0.0,
                  constraints.maxWidth - 3,
                );
                return Stack(
                  children: [
                    Positioned.fill(
                      top: 3,
                      bottom: 3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: Row(
                          children: [
                            if (before > 0)
                              Expanded(
                                flex: before,
                                child: ColoredBox(color: colors.waitingChip),
                              ),
                            Expanded(
                              flex: inside,
                              child: ColoredBox(color: colors.readyChip),
                            ),
                            if (after > 0)
                              Expanded(
                                flex: after,
                                child: ColoredBox(color: colors.pastWindowChip),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      key: const Key('ideal-today'),
                      left: markLeft,
                      top: 0,
                      bottom: 0,
                      width: 3,
                      child: ColoredBox(color: scheme.onSurface),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$from', style: legend),
              Flexible(
                child: Text(
                  '${window.startYear} – ${window.endYear}',
                  textAlign: TextAlign.center,
                  style: legend,
                ),
              ),
              Text('$to', style: legend),
            ],
          ),
        ],
      ),
    );
  }
}
