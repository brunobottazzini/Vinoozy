import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../core/label_session.dart';
import 'label_message_layout.dart';

/// Access refused by the system (u6-label-recognition BR1.5): "Per leggere
/// l'etichetta serve l'accesso alla fotocamera" (or "alle foto"), "Apri
/// impostazioni", "Scrivi a mano". With no camera app ([cameraUnavailable]):
/// "Fotocamera non disponibile", "Importa una foto", "Scrivi a mano".
class PermissionDeniedView extends StatelessWidget {
  const PermissionDeniedView({
    super.key,
    required this.origin,
    required this.onOpenSettings,
    required this.onWriteByHand,
    required this.onImport,
    this.cameraUnavailable = false,
  });

  final PhotoOrigin origin;
  final bool cameraUnavailable;
  final VoidCallback onOpenSettings;
  final VoidCallback onWriteByHand;
  final VoidCallback onImport;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final writeByHand = OutlinedButton(
      key: const Key('label-write-by-hand'),
      style: labelActionStyle(),
      onPressed: onWriteByHand,
      child: Text(l10n.labelWriteByHand),
    );
    if (cameraUnavailable) {
      return LabelMessageLayout(
        key: const Key('label-camera-unavailable'),
        icon: Icons.no_photography_outlined,
        message: l10n.labelCameraUnavailable,
        actions: [
          FilledButton(
            key: const Key('label-import'),
            style: labelActionStyle(),
            onPressed: onImport,
            child: Text(l10n.addChoiceImport),
          ),
          writeByHand,
        ],
      );
    }
    return LabelMessageLayout(
      key: const Key('label-permission-denied'),
      icon: Icons.lock_outline,
      message: origin == PhotoOrigin.camera
          ? l10n.labelCameraDenied
          : l10n.labelPhotosDenied,
      actions: [
        FilledButton(
          key: const Key('label-open-settings'),
          style: labelActionStyle(),
          onPressed: onOpenSettings,
          child: Text(l10n.labelOpenSettings),
        ),
        writeByHand,
      ],
    );
  }
}
