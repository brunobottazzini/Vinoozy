import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// The three steps shown when neither the Lens app nor the Lens of the
/// Google app opens (label-autofill-windows BR2.5, FR2.6, NFR4.9, A8, A14):
/// a sheet that takes the focus, reads the steps in order as a numbered
/// list and closes with "Got it"; the form stays open behind it.
abstract final class LensInstructionsSheet {
  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => const _Sheet(),
  );
}

class _Sheet extends StatelessWidget {
  const _Sheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final steps = [
      l10n.lensInstructionsStep1,
      l10n.lensInstructionsStep2,
      l10n.lensInstructionsStep3,
    ];
    return SafeArea(
      child: SingleChildScrollView(
        key: const Key('lens-instructions'),
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                l10n.lensInstructionsTitle,
                style: theme.textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 12),
            for (final (index, step) in steps.indexed)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Semantics(
                  label: '${index + 1}. $step',
                  excludeSemantics: true,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(radius: 14, child: Text('${index + 1}')),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          step,
                          key: Key('lens-step-${index + 1}'),
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),
            FilledButton(
              key: const Key('lens-instructions-ok'),
              autofocus: true,
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.lensInstructionsOk),
            ),
          ],
        ),
      ),
    );
  }
}
