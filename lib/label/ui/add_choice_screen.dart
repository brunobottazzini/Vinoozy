import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../core/label_session.dart';
import 'label_capture_flow.dart';

/// "Aggiungi" (u6-label-recognition BR1.1, mockup M4): large buttons, one
/// under the other, with icon, text and a line of explanation. Shown only
/// to who can edit the active cellar (U7): the shell hides "Aggiungi"
/// otherwise.
///
/// label-autofill-windows FR2.6, BR2.5: four choices in this order, "Scatta
/// foto", "Da Google Lens", "Importa una foto", "Scrivi". "Da Google Lens"
/// opens the empty form first and then Lens, so the way back from Lens is
/// the form.
class AddChoiceScreen extends ConsumerWidget {
  const AddChoiceScreen({super.key, required this.target});

  final LabelTarget target;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      key: const Key('add-choice-screen'),
      appBar: AppBar(title: Text(l10n.addChoiceTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ChoiceButton(
                key: const Key('add-choice-photo'),
                icon: Icons.photo_camera_outlined,
                label: l10n.addChoicePhoto,
                hint: l10n.addChoicePhotoHint,
                onPressed: () => LabelCaptureFlow.run(
                  context,
                  ref,
                  target,
                  PhotoOrigin.camera,
                ),
              ),
              const SizedBox(height: 16),
              _ChoiceButton(
                key: const Key('add-choice-lens'),
                icon: Icons.center_focus_strong,
                label: l10n.addChoiceLens,
                hint: l10n.addChoiceLensHint,
                onPressed: () =>
                    LabelCaptureFlow.openForm(context, target, openLens: true),
              ),
              const SizedBox(height: 16),
              _ChoiceButton(
                key: const Key('add-choice-import'),
                icon: Icons.photo_library_outlined,
                label: l10n.addChoiceImport,
                hint: l10n.addChoiceImportHint,
                onPressed: () => LabelCaptureFlow.run(
                  context,
                  ref,
                  target,
                  PhotoOrigin.gallery,
                ),
              ),
              const SizedBox(height: 16),
              _ChoiceButton(
                key: const Key('add-choice-write'),
                icon: Icons.edit_outlined,
                label: l10n.addChoiceWrite,
                hint: l10n.addChoiceWriteHint,
                onPressed: () => LabelCaptureFlow.openForm(context, target),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A large button (at least 72 dp high) with its explanation under the
/// text; TalkBack reads the text and then the explanation (NFR3.1).
class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    super.key,
    required this.icon,
    required this.label,
    required this.hint,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final String hint;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FilledButton.tonalIcon(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(72),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        alignment: AlignmentDirectional.centerStart,
        textStyle: theme.textTheme.titleMedium,
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 32),
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(height: 2),
          Text(
            hint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
