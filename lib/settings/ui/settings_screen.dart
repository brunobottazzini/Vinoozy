import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/app_user.dart';
import '../../account/ui/profile_screen.dart';
import '../../app/external_links.dart' show reportPlatformError;
import '../../app/providers.dart' show errorReporterProvider;
import '../../app/store_links.dart';
import '../../app/ui/about_screen.dart';
import '../../guide/guide_providers.dart';
import '../../l10n/app_localizations.dart';
import '../../sharing/ui/share_launcher.dart' show shareLauncherProvider;
import '../app_review.dart';
import 'faq_screen.dart';
import 'feedback_flow.dart';

/// The Settings screen, opened from the Cellar menu (tester-feedback FR1).
///
/// Seven entries in the order of FR1.2: Profile, Show the guide again,
/// Share the app, Rate the app, Send feedback, FAQ, About. Profile and About
/// open the existing screens; nothing here needs the network or Firestore
/// (NFR6). Every entry is a [ListTile] (56 dp, above the 48 dp tap target)
/// with an icon and its text as the TalkBack label (NFR5).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key, required this.user});

  final AppUser user;

  static Future<void> open(BuildContext context, AppUser user) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => SettingsScreen(user: user)));

  /// FR2.4: tour and hints show again; back to the Cellar, where the tour
  /// starts from its first step.
  Future<void> _showGuideAgain(BuildContext context, WidgetRef ref) async {
    final navigator = Navigator.of(context);
    await ref.read(guideProgressProvider.notifier).reset();
    navigator.popUntil((route) => route.isFirst);
  }

  /// FR4.1: the share sheet with the translated message and the Play Store
  /// link (FR4.2). A cancel is not an error; a platform failure is reported
  /// and explained.
  Future<void> _share(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(shareLauncherProvider)
          .share(
            text: l10n.shareAppMessage(playStoreLink),
            subject: l10n.shareAppSubject,
          );
    } on Object catch (error, stack) {
      reportPlatformError(
        () => ref.read(errorReporterProvider),
        error,
        stack,
        'ShareAppFailed',
      );
      messenger.showSnackBar(
        SnackBar(
          key: const Key('settings-share-failed'),
          content: Text(l10n.settingsShareFailed),
        ),
      );
    }
  }

  /// FR5.1: the Google Play window, or the store page in the browser.
  Future<void> _rate(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final opened = await ref.read(appReviewLauncherProvider).openRatingPage();
    if (opened) return;
    messenger.showSnackBar(
      SnackBar(
        key: const Key('settings-rate-failed'),
        content: Text(l10n.settingsRateFailed),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      key: const Key('settings-screen'),
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: SafeArea(
        child: ListView(
          children: [
            _Entry(
              key: const Key('settings-profile'),
              icon: Icons.person_outline,
              title: l10n.profileTitle,
              onTap: () => ProfileScreen.open(context, user),
            ),
            _Entry(
              key: const Key('settings-guide'),
              icon: Icons.tour_outlined,
              title: l10n.settingsGuide,
              onTap: () => _showGuideAgain(context, ref),
            ),
            _Entry(
              key: const Key('settings-share'),
              icon: Icons.share_outlined,
              title: l10n.settingsShare,
              onTap: () => _share(context, ref),
            ),
            _Entry(
              key: const Key('settings-rate'),
              icon: Icons.star_outline,
              title: l10n.settingsRate,
              onTap: () => _rate(context, ref),
            ),
            _Entry(
              key: const Key('settings-feedback'),
              icon: Icons.mail_outline,
              title: l10n.settingsFeedback,
              onTap: () => sendFeedback(context, ref),
            ),
            _Entry(
              key: const Key('settings-faq'),
              icon: Icons.help_outline,
              title: l10n.settingsFaq,
              onTap: () => FaqScreen.open(context),
            ),
            _Entry(
              key: const Key('settings-about'),
              icon: Icons.info_outline,
              title: l10n.aboutTitle,
              onTap: () => AboutScreen.open(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _Entry extends StatelessWidget {
  const _Entry({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    minTileHeight: 56,
    leading: Icon(icon),
    title: Text(title),
    trailing: const Icon(Icons.chevron_right),
    onTap: onTap,
  );
}
