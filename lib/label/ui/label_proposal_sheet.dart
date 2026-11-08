import 'package:flutter/material.dart';

import '../../app/ui/country_flag.dart';
import '../../catalog/core/wine_catalog.dart';
import '../../cellar/domain/quantity.dart';
import '../../cellar/domain/wine_origins.dart';
import '../../cellar/ui/add_wine_screen.dart' show guessOrigin, wineFamilyOf;
import '../../cellar/ui/quantity_stepper.dart';
import '../../cellar/ui/wine_badges.dart';
import '../../l10n/app_localizations.dart';
import 'candidate_list.dart';
import 'label_message_layout.dart';
import 'not_found_view.dart' show BackUnreadableNotice;

/// "Ho riconosciuto:" (u6-label-recognition BR1.9, BR1.10, mockup M4a):
/// name, producer and vintage ("—" or "Senza annata" when missing), the U4
/// quantity stepper from 1 to 99 starting at 1, "Correggi" and "Conferma".
/// It scrolls, so 200% text wraps and is never cut (NFR3.3).
///
/// label-recognition (BR3.5, BR6.2; mockup "Trovato"): a note on where the
/// wine comes from ("dalla base sul telefono", "dal catalogo", "da Open Food
/// Facts"), "Non è questo", and the Open Food Facts attribution for data of
/// the offline database or Open Food Facts.
///
/// Nothing is saved here: "Conferma" and "Correggi" call back with the
/// quantity chosen (FR2.3).
class LabelProposalSheet extends StatefulWidget {
  const LabelProposalSheet({
    super.key,
    required this.candidate,
    required this.onConfirm,
    required this.onCorrect,
    required this.onNotThis,
    this.saving = false,
    this.saveFailed = false,
    this.backUnreadable = false,
    this.offlineIsSample = false,
  });

  final WineCandidate candidate;

  /// The offline database is the hand-written sample: an offline proposal
  /// carries no Open Food Facts attribution (review R-02).
  final bool offlineIsSample;
  final ValueChanged<int> onConfirm;
  final ValueChanged<int> onCorrect;
  final VoidCallback onNotThis;
  final bool saving;

  /// "Retro non leggibile" on top (BR1.5).
  final bool backUnreadable;

  /// The U4 save failed: its message, the proposal and quantity stay.
  final bool saveFailed;

  @override
  State<LabelProposalSheet> createState() => _LabelProposalSheetState();
}

class _LabelProposalSheetState extends State<LabelProposalSheet> {
  int _quantity = QuantityLimits.initial;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final candidate = widget.candidate;
    final error = TextStyle(color: theme.colorScheme.error);
    final source = switch (candidate.source) {
      CandidateSource.offline => l10n.labelSourceOffline,
      CandidateSource.openFoodFacts => l10n.labelSourceOnline,
      CandidateSource.internal ||
      CandidateSource.cellar => l10n.labelSourceCatalog,
    };
    return SingleChildScrollView(
      key: const Key('label-proposal'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.backUnreadable) ...[
            const BackUnreadableNotice(),
            const SizedBox(height: 12),
          ],
          Semantics(
            liveRegion: true,
            child: Text(
              l10n.labelRecognized,
              style: theme.textTheme.titleMedium,
            ),
          ),
          Text(
            source,
            key: const Key('label-proposal-source'),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            candidate.name,
            key: const Key('label-proposal-name'),
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          _Field(label: l10n.producerLabel, value: candidate.producer ?? '—'),
          _Field(
            label: l10n.vintageLabel,
            value: candidate.vintage?.toString() ?? l10n.noVintage,
          ),
          _Origin(candidate: candidate),
          const SizedBox(height: 16),
          Text(l10n.quantityLabel, style: theme.textTheme.titleSmall),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: QuantityStepper(
              value: _quantity,
              onChanged: (value) => setState(() => _quantity = value),
            ),
          ),
          if (widget.saveFailed) ...[
            const SizedBox(height: 8),
            Semantics(
              liveRegion: true,
              child: Text(
                l10n.saveFailed,
                key: const Key('label-save-failed'),
                style: theme.textTheme.bodyLarge?.merge(error),
              ),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            key: const Key('label-confirm'),
            style: labelActionStyle(),
            onPressed: widget.saving ? null : () => widget.onConfirm(_quantity),
            child: Text(l10n.labelConfirm),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            key: const Key('label-correct'),
            style: labelActionStyle(),
            onPressed: widget.saving ? null : () => widget.onCorrect(_quantity),
            child: Text(l10n.labelCorrect),
          ),
          const SizedBox(height: 12),
          TextButton(
            key: const Key('label-not-this'),
            style: labelActionStyle(),
            onPressed: widget.saving ? null : widget.onNotThis,
            child: Text(l10n.labelNotThis),
          ),
          if (needsOffAttribution([
            candidate,
          ], offlineIsSample: widget.offlineIsSample)) ...[
            const SizedBox(height: 12),
            const OffAttributionText(),
          ],
        ],
      ),
    );
  }
}

/// Country with its flag, region and type family of the proposal
/// (ux-redesign FR1.3, FR3.4): the same components as the cards; nothing
/// when none was recognised.
class _Origin extends StatelessWidget {
  const _Origin({required this.candidate});

  final WineCandidate candidate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final language = Localizations.localeOf(context).languageCode;
    final origin = guessOrigin(candidate);
    final country = WineOrigins.country(origin.country);
    final region = origin.region;
    final wineType = wineFamilyOf(candidate.wineType);
    return Column(
      key: const Key('label-proposal-origin'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (country != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                CountryFlag(code: country.code, size: 22),
                const SizedBox(width: 8),
                Flexible(child: Text(country.nameIn(language))),
              ],
            ),
          ),
        if (region != null)
          _Field(
            label: l10n.uxRegionLabel,
            value: WineOrigins.regionDisplayName(
              country?.code,
              region,
              language,
            ),
          ),
        if (wineType != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: WineTypeBadge(wineType: wineType),
          ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '$label: ', style: theme.textTheme.bodyMedium),
            TextSpan(text: value, style: theme.textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
