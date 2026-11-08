import 'package:estimation/estimation.dart';
import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../l10n/app_localizations.dart';
import '../domain/cellar_filter.dart';
import 'wine_labels.dart';

/// The five graphic families of the wine types (ux-redesign plan, review
/// Major 1): the form keeps the 8 [WineType] values, which change the
/// estimate; cards, chips and charts group them with one color, icon and
/// name each.
enum WineTypeFamily {
  red,
  white,
  rose,
  sparkling,
  sweet;

  /// The family of a stored `wineType` string, `null` when absent or not
  /// recognised by `WineType.tryParse` (shown as neutral).
  static WineTypeFamily? of(String? wineType) {
    final type = WineType.tryParse(wineType);
    return type == null ? null : ofType(type);
  }

  /// The family of [type].
  static WineTypeFamily ofType(WineType type) => switch (type) {
    WineType.redLight || WineType.redStructured => WineTypeFamily.red,
    WineType.white => WineTypeFamily.white,
    WineType.rose => WineTypeFamily.rose,
    WineType.sparklingClassic ||
    WineType.sparklingTank => WineTypeFamily.sparkling,
    WineType.sweet || WineType.fortified => WineTypeFamily.sweet,
  };
}

/// The translated name of [family] ("Rosso", "Bollicine"...).
String wineFamilyLabel(AppLocalizations l10n, WineTypeFamily family) =>
    switch (family) {
      WineTypeFamily.red => l10n.uxFamilyRed,
      WineTypeFamily.white => l10n.uxFamilyWhite,
      WineTypeFamily.rose => l10n.uxFamilyRose,
      WineTypeFamily.sparkling => l10n.uxFamilySparkling,
      WineTypeFamily.sweet => l10n.uxFamilySweet,
    };

/// The theme color of [family]; the neutral one without a family.
Color wineFamilyColor(WineTypeColors colors, WineTypeFamily? family) =>
    switch (family) {
      WineTypeFamily.red => colors.red,
      WineTypeFamily.white => colors.white,
      WineTypeFamily.rose => colors.rose,
      WineTypeFamily.sparkling => colors.sparkling,
      WineTypeFamily.sweet => colors.sweet,
      null => colors.unknown,
    };

/// The icon of [family]: a drop for red, a sun for white, a flower for
/// rosé, bubbles for sparkling, a honeycomb for sweet (the emoji of the
/// mockup as Material icons).
IconData wineFamilyIcon(WineTypeFamily family) => switch (family) {
  WineTypeFamily.red => Icons.water_drop,
  WineTypeFamily.white => Icons.wb_sunny,
  WineTypeFamily.rose => Icons.local_florist,
  WineTypeFamily.sparkling => Icons.bubble_chart,
  WineTypeFamily.sweet => Icons.hive,
};

/// The type of a wine as colored icon and family name (FR3.2): the color is
/// never alone (NFR1, A2). Nothing for a wine without type.
class WineTypeBadge extends StatelessWidget {
  const WineTypeBadge({super.key, required this.wineType, this.detailed});

  /// The stored `wineType` string.
  final String? wineType;

  /// When true the 8-value type name follows the family ("Rosso ·
  /// Rosso strutturato"), as in the form.
  final bool? detailed;

  @override
  Widget build(BuildContext context) {
    final type = WineType.tryParse(wineType);
    if (type == null) return const SizedBox.shrink();
    final family = WineTypeFamily.ofType(type);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final familyName = wineFamilyLabel(l10n, family);
    final label = detailed ?? false
        ? '$familyName · ${wineTypeLabel(l10n, type)}'
        : familyName;
    return Row(
      key: Key('wine-type-badge-${family.name}'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          wineFamilyIcon(family),
          size: 16,
          color: wineFamilyColor(WineTypeColors.of(context), family),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

/// The status of a wine as a colored chip with icon and text (FR3.2): "to
/// drink now", "wait", "past the window"... The color is never the only
/// signal (NFR1).
class StateChip extends StatelessWidget {
  const StateChip({super.key, required this.status});

  final StatusFilter status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final colors = StatusColors.of(context);
    final (background, foreground) = switch (status) {
      StatusFilter.waiting => (colors.waitingChip, colors.onWaitingChip),
      StatusFilter.ready => (colors.readyChip, colors.onReadyChip),
      StatusFilter.drinkSoon => (colors.drinkSoonChip, colors.onDrinkSoonChip),
      StatusFilter.pastWindow => (
        colors.pastWindowChip,
        colors.onPastWindowChip,
      ),
      StatusFilter.toEstimate => (
        scheme.surfaceContainerHigh,
        scheme.onSurfaceVariant,
      ),
    };
    final label = _capitalized(statusFilterLabel(l10n, status));
    return Container(
      key: Key('state-chip-${status.name}'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusFilterIcon(status), size: 14, color: foreground),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(color: foreground, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  static String _capitalized(String text) =>
      text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
}
