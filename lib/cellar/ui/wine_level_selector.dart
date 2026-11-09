import 'package:estimation/estimation.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'wine_labels.dart';

/// The "Level" of a wine (label-autofill-windows FR4.1-FR4.3, BR4.3,
/// interaction-spec "Livello"; A2, A3, A10): a single-choice group of the
/// three levels plus "None", each at least 48 dp high.
///
/// - [value] is the level chosen; `null` is "not chosen" (it estimates as
///   "Good"), and no option is highlighted then.
/// - [suggested] is shown with a dashed gold border and the word
///   "suggested" (never colour alone, A3) and read as "suggested, because
///   the name says ..." ([suggestedReason]); it is never shown when a
///   level is chosen.
/// - [onChanged] receives the level tapped, or `null` for "None".
class WineLevelSelector extends StatelessWidget {
  const WineLevelSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.suggested,
    this.suggestedReason,
  });

  final WineLevel? value;
  final WineLevel? suggested;

  /// The qualifier read in the name, as written on labels ("Gran Reserva").
  final String? suggestedReason;
  final ValueChanged<WineLevel?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final showSuggestion = value == null ? suggested : null;
    final options = <(WineLevel?, String, String?)>[
      (WineLevel.everyday, l10n.levelEveryday, l10n.levelEverydayShort),
      (WineLevel.good, l10n.levelGood, l10n.levelGoodShort),
      (WineLevel.aging, l10n.levelAging, l10n.levelAgingShort),
      (null, l10n.levelNone, null),
    ];
    return Column(
      key: const Key('wine-level-selector'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.levelLabel, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (index, (level, label, hint)) in options.indexed)
              _LevelOption(
                key: Key('wine-level-${level?.name ?? 'none'}'),
                label: label,
                hint: hint,
                selected: level != null && level == value,
                suggested: level != null && level == showSuggestion,
                semanticsLabel: [
                  l10n.levelOptionSemantics(label, index + 1, options.length),
                  if (level != null && level == showSuggestion)
                    suggestedReason == null
                        ? l10n.levelSuggested
                        : l10n.levelSuggestedSemantics(suggestedReason!),
                ].join(', '),
                onTap: () => onChanged(level),
              ),
          ],
        ),
        if (showSuggestion != null && suggestedReason != null) ...[
          const SizedBox(height: 6),
          Text(
            l10n.levelSuggestedReason(suggestedReason!),
            key: const Key('wine-level-reason'),
            style: theme.textTheme.bodySmall,
          ),
        ],
        Theme(
          data: theme.copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            key: const Key('wine-level-what-changes'),
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(bottom: 8),
            title: Text(
              l10n.levelWhatChanges,
              style: theme.textTheme.bodyMedium,
            ),
            children: [
              for (final (label, text) in [
                (l10n.levelEveryday, l10n.levelEverydayExamples),
                (l10n.levelGood, l10n.levelGoodExamples),
                (l10n.levelAging, l10n.levelAgingExamples),
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '$label: ',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(text: text),
                      ],
                    ),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LevelOption extends StatelessWidget {
  const _LevelOption({
    super.key,
    required this.label,
    required this.hint,
    required this.selected,
    required this.suggested,
    required this.semanticsLabel,
    required this.onTap,
  });

  final String label;
  final String? hint;
  final bool selected;
  final bool suggested;
  final String semanticsLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final borderColor = selected
        ? scheme.primary
        : suggested
        ? scheme.tertiary
        : scheme.outline;
    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: selected ? scheme.onSecondaryContainer : null,
            ),
          ),
          if (suggested)
            Text(
              l10n.levelSuggested,
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            )
          else if (hint != null)
            Text(
              hint!,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: selected
                    ? scheme.onSecondaryContainer
                    : scheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
    return Semantics(
      inMutuallyExclusiveGroup: true,
      selected: selected,
      button: true,
      label: semanticsLabel,
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
        child: Material(
          color: selected ? scheme.secondaryContainer : scheme.surface,
          shape: suggested
              ? const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                )
              : RoundedRectangleBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                  side: BorderSide(color: borderColor, width: selected ? 2 : 1),
                ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: suggested
                ? CustomPaint(
                    painter: _DashedBorderPainter(color: borderColor),
                    child: content,
                  )
                : content,
          ),
        ),
      ),
    );
  }
}

/// The dashed border of the suggested level (design-system-mapping.md).
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(12)),
      );
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 6), paint);
        distance += 10;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) => old.color != color;
}

/// The window with the level shown (FR4.2): with a level other than the
/// [before] one, "Before" and "With «level»" side by side; otherwise the
/// window alone.
class LevelPreview extends StatelessWidget {
  const LevelPreview({
    super.key,
    required this.window,
    required this.level,
    this.before,
  });

  /// The window with [level].
  final DrinkingWindow window;
  final WineLevel? level;

  /// The window with the level saved or "Good"; `null` hides "Before".
  final DrinkingWindow? before;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final style = Theme.of(context).textTheme.bodyMedium;
    final previous = before;
    final chosen = level;
    final changed =
        previous != null &&
        chosen != null &&
        (previous.startIndex != window.startIndex ||
            previous.endIndex != window.endIndex);
    // wine-style-profiles BR6.6: months for a window in months, and no end
    // estimated for an open window.
    String end(DrinkingWindow w) =>
        windowDates(context, w).end ?? l10n.windowNoEndShort;
    String start(DrinkingWindow w) => windowDates(context, w).start;
    return Semantics(
      container: true,
      liveRegion: true,
      child: Column(
        key: const Key('level-preview'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: changed
            ? [
                Text(
                  l10n.levelPreviewBefore(start(previous), end(previous)),
                  style: style,
                ),
                Text(
                  l10n.levelPreviewWith(
                    levelLabel(l10n, chosen),
                    start(window),
                    end(window),
                  ),
                  style: style?.copyWith(fontWeight: FontWeight.w700),
                ),
              ]
            : [
                Text(
                  l10n.levelPreviewNow(start(window), end(window)),
                  style: style,
                ),
              ],
      ),
    );
  }
}
