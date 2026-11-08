import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'label_message_layout.dart';

/// "Apri in Google Lens?" (label-recognition FR4.2, BR5.1, NFR3.1, NFR3.2,
/// L5; mockup "Conferma prima di Google Lens"): asked at every tap, it says
/// that the front photo goes to the Google app (or the app chosen), which
/// may keep a copy, and that Vinoozy gets nothing back. A bottom sheet like
/// `DrinkConfirmSheet`, announced as a dialog; "Annulla" and the back
/// gesture close it without sending anything.
class LensConfirmSheet extends StatelessWidget {
  const LensConfirmSheet({
    super.key,
    required this.onConfirm,
    required this.onCancel,
  });

  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  /// Shows the sheet; true only after "Apri Google Lens".
  static Future<bool> show(BuildContext context) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => LensConfirmSheet(
        onConfirm: () => Navigator.of(sheetContext).pop(true),
        onCancel: () => Navigator.of(sheetContext).pop(false),
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      label: l10n.labelLensTitle,
      child: SafeArea(
        child: SingleChildScrollView(
          key: const Key('lens-confirm-sheet'),
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.labelLensTitle, style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              Text(
                l10n.labelLensBody,
                key: const Key('lens-confirm-body'),
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              FilledButton(
                key: const Key('lens-confirm'),
                style: labelActionStyle(),
                onPressed: onConfirm,
                child: Text(l10n.labelLensConfirm),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                key: const Key('lens-cancel'),
                style: labelActionStyle(),
                onPressed: onCancel,
                child: Text(l10n.cancel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
