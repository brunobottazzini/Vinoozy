import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

// Components of the add form filled from a label text (label-autofill-windows
// frontend-components.md; FR1.3, FR1.4, FR2.2, BR2.7; A1, A2, A8, A11-A13).
// Every text comes from the translation files.

/// "Clear", "Search online" and "Lens" above a form filled from a text
/// (interaction-spec "La barra"): chips at least 48 dp high (A2), that wrap
/// at 200% text (A5). "Lens" only with the front photo ([onLens] not null).
class AutofillToolbar extends StatelessWidget {
  const AutofillToolbar({
    super.key,
    required this.onClear,
    this.onSearchOnline,
    this.onLens,
    this.onGuide,
    this.guideFocus,
  });

  final VoidCallback onClear;

  /// `null` hides "Search online" (a form opened with no search).
  final VoidCallback? onSearchOnline;
  final VoidCallback? onLens;

  /// "🧭 Guided check" (BR7.17, G4): shown only while an uncertain field
  /// waits for an answer; `null` hides it.
  final VoidCallback? onGuide;

  /// The focus of "Guided check", where the focus goes back when the guide
  /// it reopened closes (A16).
  final FocusNode? guideFocus;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Outlined buttons rather than chips: a chip at 200% text is shorter
    // than 48 dp (A2), a button keeps its minimum size.
    final style = OutlinedButton.styleFrom(
      minimumSize: const Size(48, 48),
      padding: const EdgeInsets.symmetric(horizontal: 12),
    );
    return Wrap(
      key: const Key('autofill-toolbar'),
      spacing: 8,
      runSpacing: 4,
      children: [
        OutlinedButton.icon(
          key: const Key('autofill-clear'),
          style: style,
          icon: const Icon(Icons.cleaning_services_outlined, size: 18),
          label: Text(l10n.autofillClear),
          onPressed: onClear,
        ),
        if (onGuide case final guide?)
          OutlinedButton.icon(
            key: const Key('autofill-guide'),
            focusNode: guideFocus,
            style: style,
            icon: const Icon(Icons.explore_outlined, size: 18),
            label: Text(l10n.guideChip),
            onPressed: guide,
          ),
        if (onSearchOnline case final search?)
          OutlinedButton.icon(
            key: const Key('autofill-search-online'),
            style: style,
            icon: const Icon(Icons.travel_explore, size: 18),
            label: Text(l10n.labelSearchOnline),
            onPressed: search,
          ),
        if (onLens case final lens?)
          OutlinedButton.icon(
            key: const Key('autofill-lens'),
            style: style,
            icon: const Icon(Icons.image_search, size: 18),
            label: Text(l10n.autofillLens),
            onPressed: lens,
          ),
      ],
    );
  }
}

/// "✦ from the text" under a field filled from the text (FR1.3): below the
/// field, never over its value (A13), in the colours of the chips
/// (`onSecondaryContainer` on `secondaryContainer`, A6), and read as
/// "filled from the label" (A1).
class FilledFromTextBadge extends StatelessWidget {
  const FilledFromTextBadge({super.key, required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Semantics(
          label: l10n.autofillFromTextSemantics,
          excludeSemantics: true,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: scheme.secondaryContainer,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              l10n.autofillFromText,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: scheme.onSecondaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Do you have the text from Google Lens?" at the top of the add form
/// (FR2.2, FR2.6, interaction-spec): one button reads the clipboard once,
/// the other opens Lens. Shown whatever the clipboard holds: it is never
/// read to decide (NFR3.1).
class PasteFromLensCard extends StatelessWidget {
  const PasteFromLensCard({
    super.key,
    required this.onPaste,
    required this.onOpenLens,
    this.busy = false,
    this.pasteFocus,
  });

  final VoidCallback onPaste;
  final VoidCallback onOpenLens;

  /// From the tap to the result (FR2.8, BR7.24, A15, G0): "Reading the
  /// text…" with a progress indicator, marked busy, a second tap ignored.
  final bool busy;

  /// The focus of "Paste from Lens", where the focus goes back when the
  /// guide it opened closes (A16).
  final FocusNode? pasteFocus;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      key: const Key('paste-from-lens-card'),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.autofillPasteTitle, style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(l10n.autofillPasteHint, style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            Semantics(
              liveRegion: busy,
              child: FilledButton.tonalIcon(
                key: const Key('autofill-paste'),
                focusNode: pasteFocus,
                style: FilledButton.styleFrom(minimumSize: const Size(48, 48)),
                onPressed: busy ? null : onPaste,
                icon: busy
                    ? const SizedBox.square(
                        key: Key('autofill-reading'),
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.content_paste),
                label: Text(busy ? l10n.autofillReading : l10n.autofillPaste),
              ),
            ),
            Semantics(
              hint: l10n.autofillOpenLensSemantics,
              child: TextButton.icon(
                key: const Key('autofill-open-lens'),
                style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                onPressed: onOpenLens,
                icon: const Icon(Icons.center_focus_strong),
                label: Text(l10n.autofillOpenLens),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Clear the form?" (FR1.4, BR2.7, A8): true with "Clear".
abstract final class ClearFormDialog {
  static Future<bool> show(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        key: const Key('clear-form-dialog'),
        title: Text(l10n.autofillClearTitle),
        content: Text(l10n.autofillClearBody),
        actions: [
          TextButton(
            key: const Key('clear-form-cancel'),
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            key: const Key('clear-form-confirm'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.autofillClearConfirm),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }
}

/// "Use the text for the empty fields?" for a text shared while the form
/// holds changes (BR2.4): true with "Use".
abstract final class UseSharedTextDialog {
  static Future<bool> show(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final use = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        key: const Key('use-shared-text-dialog'),
        title: Text(l10n.autofillShareUseTitle),
        actions: [
          TextButton(
            key: const Key('use-shared-text-ignore'),
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.autofillShareIgnore),
          ),
          TextButton(
            key: const Key('use-shared-text-use'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.autofillShareUse),
          ),
        ],
      ),
    );
    return use ?? false;
  }
}
