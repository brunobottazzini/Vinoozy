import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../core/label_session.dart';
import 'label_message_layout.dart';

/// "Leggo l'etichetta…" step by step (label-recognition F1, mockup "Lettura
/// in corso", L3): front, back, barcode and the database on the phone, each
/// with its status in words, in a live region so the screen reader
/// announces every change; "Annulla" stays (u6 BR1.13).
class ReadingProgressView extends StatelessWidget {
  const ReadingProgressView({
    super.key,
    required this.progress,
    required this.onCancel,
  });

  final ReadingProgress progress;
  final VoidCallback onCancel;

  static String stepLabel(AppLocalizations l10n, ReadingStep step) =>
      switch (step) {
        ReadingStep.front => l10n.labelStepFront,
        ReadingStep.back => l10n.labelStepBack,
        ReadingStep.barcode => l10n.labelStepBarcode,
        ReadingStep.database => l10n.labelStepDatabase,
      };

  static String statusLabel(AppLocalizations l10n, StepStatus status) =>
      switch (status) {
        StepStatus.pending => l10n.labelStepPending,
        StepStatus.running => l10n.labelStepRunning,
        StepStatus.done => l10n.labelStepDone,
        StepStatus.skipped => l10n.labelStepSkipped,
        StepStatus.failed => l10n.labelStepFailed,
      };

  static IconData _icon(StepStatus status) => switch (status) {
    StepStatus.pending => Icons.radio_button_unchecked,
    StepStatus.running => Icons.autorenew,
    StepStatus.done => Icons.check_circle_outline,
    StepStatus.skipped => Icons.remove_circle_outline,
    StepStatus.failed => Icons.error_outline,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return SingleChildScrollView(
      key: const Key('label-reading-progress'),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          const Center(child: CircularProgressIndicator()),
          const SizedBox(height: 24),
          Semantics(
            liveRegion: true,
            child: Text(
              l10n.labelReading,
              key: const Key('label-reading'),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 16),
          for (final step in ReadingStep.values)
            Semantics(
              liveRegion: true,
              label: l10n.labelStepStatus(
                stepLabel(l10n, step),
                statusLabel(l10n, progress.of(step)),
              ),
              excludeSemantics: true,
              child: Padding(
                key: Key('label-step-${step.name}'),
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(
                      _icon(progress.of(step)),
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        stepLabel(l10n, step),
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        statusLabel(l10n, progress.of(step)),
                        textAlign: TextAlign.end,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 16),
          Text(
            l10n.labelOnPhoneNote,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            key: const Key('label-cancel'),
            style: labelActionStyle(),
            onPressed: onCancel,
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }
}
