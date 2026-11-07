import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'label_message_layout.dart';

/// "Non riesco a leggere l'etichetta" with "Riprova" and "Scrivi a mano"
/// (u6-label-recognition BR1.11): nothing readable, an image that could not
/// be read or prepared.
class LabelUnreadableView extends StatelessWidget {
  const LabelUnreadableView({
    super.key,
    required this.onRetry,
    required this.onWriteByHand,
  });

  final VoidCallback onRetry;
  final VoidCallback onWriteByHand;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LabelMessageLayout(
      key: const Key('label-unreadable'),
      icon: Icons.image_not_supported_outlined,
      message: l10n.labelUnreadable,
      actions: [
        FilledButton(
          key: const Key('label-retry'),
          style: labelActionStyle(),
          onPressed: onRetry,
          child: Text(l10n.retry),
        ),
        OutlinedButton(
          key: const Key('label-write-by-hand'),
          style: labelActionStyle(),
          onPressed: onWriteByHand,
          child: Text(l10n.labelWriteByHand),
        ),
      ],
    );
  }
}
