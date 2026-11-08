import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../app/ui/country_flag.dart';
import '../../catalog/core/wine_catalog.dart';
import '../../cellar/domain/wine_origins.dart';
import '../../cellar/ui/add_wine_screen.dart' show guessOrigin, wineFamilyOf;
import '../../cellar/ui/wine_badges.dart';
import '../../l10n/app_localizations.dart';

/// Whether [candidates] show data of the offline database or of Open Food
/// Facts, which need the attribution (label-recognition BR6.2). With
/// [offlineIsSample] the offline database is the hand-written sample, not
/// Open Food Facts data: its results carry no attribution (review R-02).
bool needsOffAttribution(
  Iterable<WineCandidate> candidates, {
  bool offlineIsSample = false,
}) => candidates.any(
  (c) =>
      (c.source == CandidateSource.offline && !offlineIsSample) ||
      c.source == CandidateSource.openFoodFacts,
);

/// "Dati da Open Food Facts, licenza ODbL" (label-recognition BR6.2, L6):
/// small text in the readable secondary color.
class OffAttributionText extends StatelessWidget {
  const OffAttributionText({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      AppLocalizations.of(context).labelOffAttribution,
      key: const Key('label-off-attribution'),
      textAlign: TextAlign.center,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

/// The candidates to choose from (label-recognition FR3.2, FR3.3, BR3.2,
/// BR3.3, L2, L4, L8; mockup "Quale di questi?"): at most 10, each with
/// flag, name, producer and what else it has, an "offline" / "online" chip
/// in words, and the attribution under the list. Tapping one calls
/// [onPick]; "Nessuno di questi" calls [onNone] when given.
///
/// A list of widgets for a parent that scrolls, so the reading screen and
/// "Cerca online" share it.
class CandidateList extends StatelessWidget {
  const CandidateList({
    super.key,
    required this.candidates,
    required this.onPick,
    this.onNone,
    this.offlineIsSample = false,
  });

  final List<WineCandidate> candidates;
  final ValueChanged<WineCandidate> onPick;
  final VoidCallback? onNone;

  /// The offline database is the hand-written sample (see
  /// [needsOffAttribution]).
  final bool offlineIsSample;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      key: const Key('label-candidate-list'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, candidate) in candidates.take(10).indexed) ...[
          if (index > 0) const SizedBox(height: 8),
          CandidateCard(
            key: Key('label-candidate-$index'),
            candidate: candidate,
            onTap: () => onPick(candidate),
          ),
        ],
        if (onNone != null) ...[
          const SizedBox(height: 16),
          OutlinedButton(
            key: const Key('label-candidates-none'),
            style: const ButtonStyle(
              minimumSize: WidgetStatePropertyAll(Size.fromHeight(48)),
            ),
            onPressed: onNone,
            child: Text(l10n.labelCandidatesNone),
          ),
        ],
        if (needsOffAttribution(
          candidates,
          offlineIsSample: offlineIsSample,
        )) ...[
          const SizedBox(height: 12),
          const OffAttributionText(),
        ],
      ],
    );
  }
}

/// One candidate as a card with the band of its type family (design-system
/// mapping: `WineCard` with the "offline"/"online" chip).
class CandidateCard extends StatelessWidget {
  const CandidateCard({
    super.key,
    required this.candidate,
    required this.onTap,
  });

  final WineCandidate candidate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final language = Localizations.localeOf(context).languageCode;
    final origin = guessOrigin(candidate);
    final country = WineOrigins.country(origin.country);
    final family = WineTypeFamily.of(wineFamilyOf(candidate.wineType));
    final details = [
      candidate.producer ?? l10n.labelNoProducer,
      if (origin.region != null)
        WineOrigins.regionDisplayName(country?.code, origin.region!, language),
      if (candidate.denomination != null &&
          candidate.denomination != candidate.name)
        candidate.denomination!,
    ].join(' · ');
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 6,
                  color: wineFamilyColor(WineTypeColors.of(context), family),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (country != null) ...[
                              CountryFlag(code: country.code, size: 20),
                              const SizedBox(width: 8),
                            ],
                            Expanded(
                              child: Text(
                                candidate.name,
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(details, style: theme.textTheme.bodyMedium),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            _SourceChip(source: candidate.source),
                            Text(
                              candidate.vintage?.toString() ?? l10n.noVintage,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// "offline", "online" or "catalogo" in words, never color alone (L4).
class _SourceChip extends StatelessWidget {
  const _SourceChip({required this.source});

  final CandidateSource source;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final text = switch (source) {
      CandidateSource.offline => l10n.labelChipOffline,
      CandidateSource.openFoodFacts => l10n.labelChipOnline,
      CandidateSource.internal ||
      CandidateSource.cellar => l10n.labelChipCatalog,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: scheme.onSecondaryContainer),
      ),
    );
  }
}
