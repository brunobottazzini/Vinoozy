import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/external_links.dart';
import '../../app/store_links.dart';
import '../../catalog/platform/catalog_providers.dart'
    show catalogAppVersionProvider;
import '../../l10n/app_localizations.dart';
import '../feedback_email.dart';

/// "Send feedback" from the Settings and "Didn't find the answer?" from the
/// FAQ (tester-feedback FR6, FR7.3): the email app opens with the support
/// address, a translated subject and the technical data at the end of the
/// body; the person edits and sends it (FR6.2). Without an email app, a
/// dialog shows the address with "Copy" (FR6.3). Nothing is sent by the app.
Future<void> sendFeedback(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final languageTag = Localizations.localeOf(context).toLanguageTag();
  final openEmail = ref.read(supportEmailOpenerProvider);
  final readDevice = ref.read(deviceInfoReaderProvider);
  final version = await ref.read(catalogAppVersionProvider.future);
  final device = await readDevice();
  final opened = await openEmail(
    subject: l10n.feedbackSubject,
    body: buildFeedbackBody(
      techHeader: l10n.feedbackTechHeader,
      appVersion: version,
      device: device,
      languageTag: languageTag,
    ),
  );
  if (opened || !context.mounted) return;
  await NoEmailAppDialog.show(context);
}

/// FR6.3: no email app on the phone; the support address can be copied.
abstract final class NoEmailAppDialog {
  static Future<void> show(BuildContext context) => showDialog<void>(
    context: context,
    builder: (dialogContext) {
      final l10n = AppLocalizations.of(dialogContext);
      return AlertDialog(
        key: const Key('feedback-no-email-dialog'),
        title: Text(l10n.feedbackNoEmailTitle),
        content: SelectableText(l10n.feedbackNoEmailBody(supportEmail)),
        actions: [
          TextButton(
            key: const Key('feedback-copy-address'),
            onPressed: () async {
              await Clipboard.setData(const ClipboardData(text: supportEmail));
              if (!dialogContext.mounted) return;
              ScaffoldMessenger.of(dialogContext).showSnackBar(
                SnackBar(
                  key: const Key('feedback-address-copied'),
                  content: Text(l10n.feedbackCopied),
                ),
              );
              Navigator.of(dialogContext).pop();
            },
            child: Text(l10n.feedbackCopy),
          ),
          TextButton(
            key: const Key('feedback-dialog-close'),
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.close),
          ),
        ],
      );
    },
  );
}
