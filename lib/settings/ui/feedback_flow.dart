import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/external_links.dart';
import '../../catalog/platform/catalog_providers.dart'
    show catalogAppVersionProvider;
import '../../l10n/app_localizations.dart';
import '../feedback_email.dart';

/// "Send feedback" from the Settings and "Didn't find the answer?" from the
/// FAQ (tester-feedback FR6, FR7.3): the email app opens with the support
/// address, a translated subject and the technical data at the end of the
/// body; the person edits and sends it (FR6.2). Without an email app, a
/// dialog shows the address, read from the Android side, with "Copy"
/// (FR6.3). Nothing is sent by the app.
Future<void> sendFeedback(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final languageTag = Localizations.localeOf(context).toLanguageTag();
  final openEmail = ref.read(supportEmailOpenerProvider);
  final readDevice = ref.read(deviceInfoReaderProvider);
  final readAddress = ref.read(supportEmailReaderProvider);
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
  final address = await readAddress();
  if (!context.mounted) return;
  await NoEmailAppDialog.show(context, address: address);
}

/// FR6.3: no email app on the phone; the support [address] can be copied.
/// When the address could not be read (null) the dialog says only that there
/// is no email app, with no address and no "Copy".
abstract final class NoEmailAppDialog {
  static Future<void> show(BuildContext context, {required String? address}) =>
      showDialog<void>(
        context: context,
        builder: (dialogContext) {
          final l10n = AppLocalizations.of(dialogContext);
          return AlertDialog(
            key: const Key('feedback-no-email-dialog'),
            title: Text(l10n.feedbackNoEmailTitle),
            content: address == null
                ? null
                : SelectableText(l10n.feedbackNoEmailBody(address)),
            actions: [
              if (address != null) _copyButton(dialogContext, l10n, address),
              TextButton(
                key: const Key('feedback-dialog-close'),
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(l10n.close),
              ),
            ],
          );
        },
      );

  static Widget _copyButton(
    BuildContext dialogContext,
    AppLocalizations l10n,
    String address,
  ) => TextButton(
    key: const Key('feedback-copy-address'),
    onPressed: () async {
      await Clipboard.setData(ClipboardData(text: address));
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
  );
}
