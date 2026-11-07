import 'package:estimation/estimation.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../domain/cellar_filter.dart';
import '../domain/window_adjuster.dart';
import '../domain/wine_estimate.dart';
import 'wine_labels.dart';

/// The estimate of a wine (BR1.9, FR4.1-FR4.5): start, peak and end, the
/// status as icon and text, the confidence and the source as text, and the
/// fixed notice "Indicative estimate…", always shown.
class WindowCard extends StatelessWidget {
  const WindowCard({super.key, required this.estimate, required this.today});

  final WineEstimate estimate;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final window = estimate.window;
    final status = _statusOf(window);
    return Card(
      key: const Key('window-card'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatusLabel(status: status),
            const SizedBox(height: 8),
            if (window == null)
              Text(l10n.estimateUnavailable, key: const Key('window-none'))
            else ...[
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
              Text(confidenceText(l10n, window.confidence)),
              Text(
                estimateSourceText(
                  l10n,
                  WindowAdjuster.labelOf(
                    window: window,
                    base: estimate.baseWindow,
                    adjustment: estimate.adjustment,
                  ),
                ),
                key: const Key('window-source'),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              l10n.estimateDisclaimer,
              key: const Key('window-disclaimer'),
              style: theme.textTheme.bodySmall,
            ),
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
