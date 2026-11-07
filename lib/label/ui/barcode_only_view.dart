import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'label_message_layout.dart';

/// A barcode read with no wine for it, and too little text to search by
/// ("Chiarimenti dopo la revisione"):
/// - with the network: "Ho letto il codice a barre ma non trovo il vino",
///   "Riprova" (photograph the front of the label) and "Scrivi a mano";
/// - without: "...serve la rete per cercarlo", plus "Riprova quando torna la
///   rete", which looks the code up again without a new photo.
class BarcodeOnlyView extends StatelessWidget {
  const BarcodeOnlyView({
    super.key,
    required this.needsNetwork,
    required this.onRetry,
    required this.onWriteByHand,
    required this.onRetryOnline,
  });

  final bool needsNetwork;
  final VoidCallback onRetry;
  final VoidCallback onWriteByHand;
  final VoidCallback onRetryOnline;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LabelMessageLayout(
      key: const Key('label-barcode-only'),
      icon: Icons.qr_code_2_outlined,
      message: needsNetwork
          ? l10n.labelBarcodeNeedsNetwork
          : l10n.labelBarcodeNotFound,
      hint: needsNetwork ? null : l10n.labelBarcodeFrontHint,
      actions: [
        if (needsNetwork)
          FilledButton(
            key: const Key('label-retry-online'),
            style: labelActionStyle(),
            onPressed: onRetryOnline,
            child: Text(l10n.labelRetryOnline),
          ),
        OutlinedButton(
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
