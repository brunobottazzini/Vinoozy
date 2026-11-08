import 'package:estimation/estimation.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'wine_labels.dart';

// The drinking window of the detail is IdealMomentCard
// (ideal_moment_card.dart) since ux-redesign; this file keeps the pairings.

/// The pairings (BR1.9, FR7.1, FR7.2): catalog texts, or the categories of
/// the type with "generic pairings for the type".
class PairingsCard extends StatelessWidget {
  const PairingsCard({super.key, required this.pairings});

  final Pairings pairings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final items = [
      ...pairings.items,
      for (final key in pairings.categoryKeys) pairingLabel(l10n, key),
    ];
    if (items.isEmpty) return const SizedBox.shrink();
    return Card(
      key: const Key('pairings-card'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.pairingsTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            for (final item in items) Text('• $item'),
            if (pairings.source == WindowSource.internalRules)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  l10n.pairingsGeneric,
                  key: const Key('pairings-generic'),
                  style: theme.textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
