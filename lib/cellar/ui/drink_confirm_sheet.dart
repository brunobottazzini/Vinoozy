import 'package:flutter/material.dart';

import '../../app/ui/country_flag.dart';
import '../../l10n/app_localizations.dart';
import '../domain/drinking_record.dart';
import '../domain/wine.dart';
import '../domain/wine_origins.dart';
import 'wine_badges.dart';
import 'wine_labels.dart';

/// What the person confirmed in [DrinkConfirmSheet]: the optional rating.
class DrinkConfirmation {
  const DrinkConfirmation({this.rating});

  /// 1-5, or `null` when no star was chosen.
  final int? rating;
}

/// The "I drank one" confirmation (ux-redesign FR2.2, A6, A7, A9): flag,
/// name and vintage of the wine, the bottles before and after ("2 → 1"),
/// five optional stars, "Yes, I drank it" and "Cancel". Nothing is written
/// here: [show] returns the confirmation, or `null` for "Cancel", the back
/// gesture or a tap outside.
class DrinkConfirmSheet extends StatefulWidget {
  const DrinkConfirmSheet({super.key, required this.wine});

  final Wine wine;

  /// Opens the sheet from the bottom; the standard animation follows the
  /// system's reduced motion (A9).
  static Future<DrinkConfirmation?> show(BuildContext context, Wine wine) =>
      showModalBottomSheet<DrinkConfirmation>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => DrinkConfirmSheet(wine: wine),
      );

  @override
  State<DrinkConfirmSheet> createState() => _DrinkConfirmSheetState();
}

class _DrinkConfirmSheetState extends State<DrinkConfirmSheet> {
  int? _rating;

  void _toggleStar(int value) =>
      setState(() => _rating = _rating == value ? null : value);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final wine = widget.wine;
    final language = Localizations.localeOf(context).languageCode;
    final country = wine.displayCountry;
    final region = wine.region;
    final family = WineTypeFamily.of(wine.wineType);
    final meta = [
      ?wine.producer,
      if (region != null)
        WineOrigins.regionDisplayName(country, region, language),
      if (family != null) wineFamilyLabel(l10n, family),
    ].join(' · ');
    final before = wine.quantity;
    final after = before - 1;
    final big = theme.textTheme.displaySmall;
    return Semantics(
      key: const Key('drink-confirm-sheet'),
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      label: l10n.uxDrinkSheetLabel,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (country != null) ...[
                  CountryFlag(code: country, size: 28),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${wine.name} ${vintageText(l10n, wine.vintage)}',
                        key: const Key('drink-confirm-title'),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (meta.isNotEmpty)
                        Text(
                          meta,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Semantics(
              key: const Key('drink-confirm-bottles'),
              label: l10n.uxDrinkSheetBottlesChange(before, after),
              excludeSemantics: true,
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                children: [
                  Text(
                    l10n.uxDrinkSheetBottles,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  Text('$before', style: big),
                  Icon(Icons.arrow_forward, color: scheme.onSurface),
                  Text('$after', style: big?.copyWith(color: scheme.primary)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.uxDrinkSheetRating,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            Wrap(
              children: [
                for (
                  var value = RecordRules.minRating;
                  value <= RecordRules.maxRating;
                  value++
                )
                  // A7: read as "3 stars of 5", selected when chosen.
                  MergeSemantics(
                    child: Semantics(
                      label: l10n.uxDrinkSheetStars(value),
                      child: IconButton(
                        key: Key('drink-confirm-star-$value'),
                        isSelected: (_rating ?? 0) >= value,
                        onPressed: () => _toggleStar(value),
                        color: scheme.secondary,
                        icon: Icon(Icons.star_border, color: scheme.secondary),
                        selectedIcon: Icon(Icons.star, color: scheme.secondary),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('drink-confirm'),
              onPressed: () =>
                  Navigator.of(context).pop(DrinkConfirmation(rating: _rating)),
              child: Text(l10n.uxDrinkSheetConfirm),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              key: const Key('drink-cancel'),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
          ],
        ),
      ),
    );
  }
}
