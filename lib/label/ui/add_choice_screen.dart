import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../core/label_session.dart';
import 'label_capture_flow.dart';

/// "Aggiungi" (u6-label-recognition BR1.1, mockup M4): three large buttons,
/// one under the other, with icon and text: "Scatta foto", "Importa una
/// foto", "Scrivi". Shown only to who can edit the active cellar (U7): the
/// shell hides "Aggiungi" otherwise.
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
                onPressed: () => LabelCaptureFlow.run(
                  context,
                  ref,
                  target,
                  PhotoOrigin.camera,
                ),
              ),
              const SizedBox(height: 16),
              _ChoiceButton(
                key: const Key('add-choice-import'),
                icon: Icons.photo_library_outlined,
                label: l10n.addChoiceImport,
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
                onPressed: () => LabelCaptureFlow.openForm(context, target),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A large button (at least 72 dp high) whose TalkBack label is its text
/// (NFR3.1).
class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(72),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        alignment: AlignmentDirectional.centerStart,
        textStyle: Theme.of(context).textTheme.titleMedium,
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 32),
      label: Text(label),
    );
  }
}
