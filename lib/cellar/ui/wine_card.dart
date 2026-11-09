import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../app/ui/country_flag.dart';
import '../../l10n/app_localizations.dart';
import '../domain/cellar_filter.dart';
import '../domain/quantity_delta.dart';
import '../domain/wine.dart';
import '../domain/wine_origins.dart';
import 'wine_badges.dart';
import 'wine_labels.dart';

/// The icon of "I drank one": two glasses, never the bottle of the Cellar
/// tab (ux-redesign FR2.1, review R-11).
const IconData drinkActionIcon = Icons.wine_bar;

/// A wine of the cellar as a card (ux-redesign FR1.4, FR2.1, FR3.2;
/// u4-cellar BR1.7, BR1.10, FR4.5): a 6 dp band in the color of its type,
/// the flag, name and vintage, producer and region, the status chip, the
/// bottles, the type with icon and name and, with `canEdit`, "I drank one".
/// Long names wrap instead of being cut (NFR3.4). The status of the day is
/// computed once per list by the caller (performance-design.md §2).
class WineCard extends StatelessWidget {
  const WineCard({
    super.key,
    required this.wine,
    this.status,
    this.onTap,
    this.onDrink,
  });

  final Wine wine;

  /// The status of the day; without it "estimate pending" shows.
  final StatusFilter? status;
  final VoidCallback? onTap;

  /// Present only with `canEdit` (read-only people see no button, FR2.1).
  final VoidCallback? onDrink;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final language = Localizations.localeOf(context).languageCode;
    final country = wine.displayCountry;
    final region = wine.region;
    final family = WineTypeFamily.of(wine.wineType);
    final status = this.status;
    final window = wine.window;
    final drink = onDrink;
    final meta = [
      ?wine.producer,
      if (region != null)
        WineOrigins.regionDisplayName(country, region, language),
    ].join(' · ');
    return Card(
      key: Key('wine-tile-${wine.id}'),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: InkWell(
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                key: Key('wine-card-band-${family?.name ?? 'none'}'),
                width: 6,
                color: wineFamilyColor(WineTypeColors.of(context), family),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (country != null) ...[
                            CountryFlag(code: country, size: 22),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${wine.name} ${vintageText(l10n, wine.vintage)}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (meta.isNotEmpty)
                                  Text(
                                    meta,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          if (status == null)
                            Text(
                              l10n.estimatePending,
                              style: theme.textTheme.bodySmall,
                            )
                          else
                            StateChip(status: status),
                          Semantics(
                            label: l10n.bottleCount(wine.quantity),
                            excludeSemantics: true,
                            child: Text(
                              '× ${wine.quantity}',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (status != null && window != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            confidenceText(l10n, window.confidence),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      // wine-style-profiles BR6.5, BR6.6: "by Mar 2027" for a
                      // window in months, "no end estimated" without an end.
                      if (window != null &&
                          (window.inMonths || window.endYear == null))
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            window.endYear == null
                                ? l10n.windowNoEndShort
                                : l10n.windowDrinkWithin(
                                    windowDates(
                                      context,
                                      window,
                                      short: true,
                                    ).end!,
                                  ),
                            key: const Key('wine-card-month'),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      if (family != null || drink != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              WineTypeBadge(wineType: wine.wineType),
                              if (drink != null)
                                DrinkActionButton(
                                  key: Key('wine-tile-drink-${wine.id}'),
                                  wineName: wine.name,
                                  onPressed:
                                      QuantityDelta.canDecrease(
                                        wine.storedQuantity,
                                      )
                                      ? drink
                                      : null,
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "I drank one" with the verb (FR2.1): gold, at least 48 × 48 dp, the
/// glasses icon; disabled when [onPressed] is `null` (0 bottles).
class DrinkActionButton extends StatelessWidget {
  const DrinkActionButton({
    super.key,
    required this.wineName,
    required this.onPressed,
    this.label,
  });

  final String wineName;
  final VoidCallback? onPressed;

  /// The visible text; "I drank one" by default.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: l10n.uxDrinkActionTooltip(wineName),
      excludeFromSemantics: true,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          backgroundColor: scheme.secondaryContainer,
          foregroundColor: scheme.onSecondaryContainer,
          side: BorderSide(color: scheme.secondary),
          shape: const StadiumBorder(),
        ),
        onPressed: onPressed,
        icon: const Icon(drinkActionIcon),
        label: Text(label ?? l10n.uxDrinkAction),
      ),
    );
  }
}
