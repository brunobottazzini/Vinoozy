import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../l10n/app_localizations.dart';
import '../core/label_lookup_flow.dart';
import 'label_message_layout.dart';

/// "Non trovato" (label-recognition FR3.1, FR4.1, BR3.4, BR5.3; mockup
/// "Non trovato"), one view for the three kinds, which change only the
/// title and the text shown:
/// - `unreadable`: "Non riesco a leggere l'etichetta", with "Riprova";
/// - `barcodeNotFound`: "Ho letto il codice a barre ma non trovo il vino";
/// - `noMatch`: "Ho letto l'etichetta ma non riconosco il vino" and the
///   text read.
///
/// Then, in order: "Cerca online", "Scrivi a mano" and, last, "Apri in
/// Google Lens" with its note, only while the front photo is still there
/// ([photosAvailable], BR5.3). Replaces the u6 unreadable and barcode-only
/// views.
class NotFoundView extends StatelessWidget {
  const NotFoundView({
    super.key,
    required this.kind,
    required this.onSearchOnline,
    required this.onWriteByHand,
    required this.onLens,
    this.readText = '',
    this.photosAvailable = true,
    this.backUnreadable = false,
    this.onRetry,
  });

  final NotFoundKind kind;
  final VoidCallback onSearchOnline;
  final VoidCallback onWriteByHand;
  final VoidCallback onLens;

  /// The most significant line read, shown for `noMatch`.
  final String readText;
  final bool photosAvailable;

  /// "Retro non leggibile" above the message (BR1.5).
  final bool backUnreadable;

  /// "Riprova" for `unreadable` only; `null` hides it.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final (icon, message) = switch (kind) {
      NotFoundKind.unreadable => (
        Icons.image_not_supported_outlined,
        l10n.labelUnreadable,
      ),
      NotFoundKind.barcodeNotFound => (
        Icons.qr_code_2_outlined,
        l10n.labelBarcodeNotFound,
      ),
      NotFoundKind.noMatch => (Icons.search_off_outlined, l10n.labelNoMatch),
    };
    final hint = switch (kind) {
      NotFoundKind.noMatch when readText.isNotEmpty =>
        '${l10n.labelReadText}: $readText',
      NotFoundKind.barcodeNotFound => l10n.labelBarcodeFrontHint,
      _ => null,
    };
    return Column(
      key: Key('label-not-found-${kind.name}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (backUnreadable) const BackUnreadableNotice(),
        Expanded(
          child: LabelMessageLayout(
            key: const Key('label-not-found'),
            icon: icon,
            message: message,
            hint: hint,
            actions: [
              if (onRetry != null && kind == NotFoundKind.unreadable)
                OutlinedButton(
                  key: const Key('label-retry'),
                  style: labelActionStyle(),
                  onPressed: onRetry,
                  child: Text(l10n.retry),
                ),
              FilledButton.icon(
                key: const Key('label-search-online'),
                style: labelActionStyle(),
                onPressed: onSearchOnline,
                icon: const Icon(Icons.travel_explore),
                label: Text(l10n.labelSearchOnline),
              ),
              OutlinedButton.icon(
                key: const Key('label-write-by-hand'),
                style: labelActionStyle(),
                onPressed: onWriteByHand,
                icon: const Icon(Icons.edit_outlined),
                label: Text(l10n.labelWriteByHand),
              ),
              if (photosAvailable) ...[
                TextButton.icon(
                  key: const Key('label-lens'),
                  style: labelActionStyle(),
                  onPressed: onLens,
                  icon: const Icon(Icons.image_search),
                  label: Text(l10n.labelOpenLens),
                ),
                Text(
                  l10n.labelLensLastResort,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// "Retro non leggibile" in the `wait` colors, text and background with a
/// verified contrast (label-recognition BR1.5, L6).
class BackUnreadableNotice extends StatelessWidget {
  const BackUnreadableNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = StatusColors.of(context);
    return Semantics(
      liveRegion: true,
      child: Container(
        key: const Key('label-back-unreadable'),
        width: double.infinity,
        color: colors.waitingChip,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Text(
          AppLocalizations.of(context).labelBackUnreadable,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: colors.onWaitingChip),
        ),
      ),
    );
  }
}
