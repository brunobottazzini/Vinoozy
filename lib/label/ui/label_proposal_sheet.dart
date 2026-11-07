import 'package:flutter/material.dart';

import '../../catalog/core/wine_catalog.dart';
import '../../cellar/domain/quantity.dart';
import '../../cellar/ui/quantity_stepper.dart';
import '../../l10n/app_localizations.dart';
import 'label_message_layout.dart';

/// "Ho riconosciuto:" (u6-label-recognition BR1.9, BR1.10, mockup M4a):
/// name, producer and vintage ("—" or "Senza annata" when missing), the U4
/// quantity stepper from 1 to 99 starting at 1, "Correggi" and "Conferma".
/// Without network it also says that only the denomination was recognised.
/// It scrolls, so 200% text wraps and is never cut (NFR3.3).
///
/// Nothing is saved here: "Conferma" and "Correggi" call back with the
/// quantity chosen (FR2.3).
class LabelProposalSheet extends StatefulWidget {
  const LabelProposalSheet({
    super.key,
    required this.candidate,
    required this.offline,
    required this.onConfirm,
    required this.onCorrect,
    this.saving = false,
    this.saveFailed = false,
  });

  final WineCandidate candidate;
  final bool offline;
  final ValueChanged<int> onConfirm;
  final ValueChanged<int> onCorrect;
  final bool saving;

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
    return SingleChildScrollView(
      key: const Key('label-proposal'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            liveRegion: true,
            child: Text(
              l10n.labelRecognized,
              style: theme.textTheme.titleMedium,
            ),
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
          if (widget.offline) ...[
            const SizedBox(height: 12),
            Text(
              l10n.labelOfflineNotice,
              key: const Key('label-offline-notice'),
              style: theme.textTheme.bodyLarge,
            ),
          ],
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
        ],
      ),
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
