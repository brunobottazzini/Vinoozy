import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'label_message_layout.dart';

/// "Ora il retro" (label-recognition FR1.1, BR1.1, BR1.6; mockup "Etichetta
/// · Fronte letto"): after the front, from the camera, the gallery or a
/// share, the back is asked with "Scatta il retro", "Scegli dalla galleria"
/// and "Salta", always visible. Buttons are full width and at least 48 dp
/// (L2); the view scrolls, so 200% text is never cut.
class BackPhotoPrompt extends StatelessWidget {
  const BackPhotoPrompt({
    super.key,
    required this.onTake,
    required this.onPick,
    required this.onSkip,
  });

  final VoidCallback onTake;
  final VoidCallback onPick;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LabelMessageLayout(
      key: const Key('label-back-prompt'),
      icon: Icons.flip_outlined,
      message: l10n.labelBackTitle,
      hint: l10n.labelBackHint,
      actions: [
        FilledButton.icon(
          key: const Key('label-back-take'),
          style: labelActionStyle(),
          onPressed: onTake,
          icon: const Icon(Icons.photo_camera_outlined),
          label: Text(l10n.labelBackTake),
        ),
        OutlinedButton.icon(
          key: const Key('label-back-gallery'),
          style: labelActionStyle(),
          onPressed: onPick,
          icon: const Icon(Icons.photo_library_outlined),
          label: Text(l10n.labelBackGallery),
        ),
        TextButton(
          key: const Key('label-back-skip'),
          style: labelActionStyle(),
          onPressed: onSkip,
          child: Text(l10n.labelBackSkip),
        ),
      ],
    );
  }
}
