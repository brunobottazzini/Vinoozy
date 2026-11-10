import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/external_links.dart';
import '../../l10n/app_localizations.dart';
import '../../plan/ui/profile_plan_row.dart';
import '../account_providers.dart';
import '../app_user.dart';
import 'delete_account_screen.dart';

/// Profile (u8-account BR1.2): photo, name and email of the Google account,
/// "Sign out", "Delete account" and the privacy policy. Nothing is read from
/// the cloud: name and email come from the session, N from the ledger
/// (NFR1.1).
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key, required this.user});

  final AppUser user;

  /// Opens the profile from the app menu.
  static Future<void> open(BuildContext context, AppUser user) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => ProfileScreen(user: user)));

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _busy = false;

  void _snack(String message) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(key: const Key('profile-snackbar'), content: Text(message)),
  );

  /// BR1.3 and BR1.4: a confirmation without queued writes, a warning with N
  /// and "Stay and sync" / "Sign out anyway" otherwise.
  Future<void> _signOut() async {
    final gate = ref.read(accountGateProvider);
    setState(() => _busy = true);
    final pending = await gate.pendingChanges();
    if (!mounted) return;
    setState(() => _busy = false);
    final choice = pending == 0
        ? await SignOutConfirmDialog.show(context)
        : await SignOutWarningDialog.show(context, pending);
    if (!mounted) return;
    switch (choice) {
      case SignOutChoice.signOut:
        Navigator.of(context).popUntil((route) => route.isFirst);
        await gate.signOut();
      case SignOutChoice.stayAndSync:
        await _sync();
      case SignOutChoice.cancel || null:
        break;
    }
  }

  Future<void> _sync() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    final left = await ref.read(accountGateProvider).syncNow();
    if (!mounted) return;
    setState(() => _busy = false);
    _snack(left == 0 ? l10n.syncAllSaved : l10n.syncStillPending(left));
  }

  Future<void> _privacy() async {
    final l10n = AppLocalizations.of(context);
    final url = ref.read(privacyPolicyUrlProvider);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        key: const Key('privacy-dialog'),
        title: Text(l10n.profilePrivacy),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.profilePrivacyBody),
              const SizedBox(height: 8),
              SelectableText(url, key: const Key('privacy-url')),
            ],
          ),
        ),
        actions: [
          TextButton(
            key: const Key('privacy-open'),
            onPressed: () async {
              final opened = await ref.read(externalLinkOpenerProvider)(url);
              if (!mounted) return;
              if (opened) {
                if (context.mounted) Navigator.of(context).pop();
              } else {
                _snack(l10n.profileOpenLinkFailed);
              }
            },
            child: Text(l10n.profileOpenLink),
          ),
          TextButton(
            key: const Key('privacy-copy'),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: url));
              if (context.mounted) Navigator.of(context).pop();
              if (mounted) _snack(l10n.profileLinkCopied);
            },
            child: Text(l10n.profileCopyLink),
          ),
          TextButton(
            key: const Key('privacy-close'),
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final user = widget.user;
    final photo = ref.watch(authServiceProvider).photoUrl;
    final initial =
        (user.displayName.isNotEmpty ? user.displayName : user.email)
            .characters
            .first
            .toUpperCase();
    return Scaffold(
      key: const Key('profile-screen'),
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Semantics(
                  label: l10n.profilePhoto,
                  image: true,
                  child: CircleAvatar(
                    key: const Key('profile-avatar'),
                    radius: 40,
                    foregroundImage: photo == null ? null : NetworkImage(photo),
                    // No photo, or one that does not load: the initial.
                    onForegroundImageError: photo == null ? null : (_, _) {},
                    child: Text(initial, style: theme.textTheme.headlineMedium),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user.displayName,
                key: const Key('profile-name'),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge,
              ),
              Text(
                user.email,
                key: const Key('profile-email'),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              // freemium-plus FR1.3, FR5.4: the plan and "Discover Plus".
              ProfilePlanRow(user: user),
              const SizedBox(height: 24),
              if (_busy) const LinearProgressIndicator(),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                key: const Key('profile-sign-out'),
                onPressed: _busy ? null : _signOut,
                icon: const Icon(Icons.logout),
                label: Text(l10n.profileSignOut),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                key: const Key('profile-delete'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
                onPressed: _busy
                    ? null
                    : () => DeleteAccountScreen.open(context, user),
                icon: const Icon(Icons.delete_forever),
                label: Text(l10n.profileDeleteAccount),
              ),
              const SizedBox(height: 12),
              TextButton(
                key: const Key('profile-privacy'),
                onPressed: _privacy,
                child: Text(l10n.profilePrivacy),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// What the person chose in a sign-out dialog.
enum SignOutChoice { cancel, signOut, stayAndSync }

/// "Do you want to sign out?" with "Cancel" and "Sign out" (BR1.3).
abstract final class SignOutConfirmDialog {
  static Future<SignOutChoice?> show(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return showDialog<SignOutChoice>(
      context: context,
      builder: (context) => AlertDialog(
        key: const Key('sign-out-confirm-dialog'),
        title: Text(l10n.signOutConfirmTitle),
        actions: [
          TextButton(
            key: const Key('sign-out-cancel'),
            onPressed: () => Navigator.of(context).pop(SignOutChoice.cancel),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            key: const Key('sign-out-confirm'),
            onPressed: () => Navigator.of(context).pop(SignOutChoice.signOut),
            child: Text(l10n.profileSignOut),
          ),
        ],
      ),
    );
  }
}

/// "You have N changes not saved yet..." with "Stay and sync" and "Sign out
/// anyway" (BR1.4).
abstract final class SignOutWarningDialog {
  static Future<SignOutChoice?> show(BuildContext context, int pending) {
    final l10n = AppLocalizations.of(context);
    return showDialog<SignOutChoice>(
      context: context,
      builder: (context) => AlertDialog(
        key: const Key('sign-out-warning-dialog'),
        content: SingleChildScrollView(
          child: Text(l10n.signOutPendingWarning(pending)),
        ),
        actions: [
          TextButton(
            key: const Key('sign-out-anyway'),
            onPressed: () => Navigator.of(context).pop(SignOutChoice.signOut),
            child: Text(l10n.signOutAnyway),
          ),
          FilledButton(
            key: const Key('sign-out-stay'),
            onPressed: () =>
                Navigator.of(context).pop(SignOutChoice.stayAndSync),
            child: Text(l10n.signOutStayAndSync),
          ),
        ],
      ),
    );
  }
}
