import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import '../app_user.dart';
import '../auth_service.dart';
import '../deletion/deletion_plan.dart';
import '../gate_state.dart';

/// "Delete account" (u8-account BR1.5, BR1.6, BR1.13): what is deleted, the
/// changes still queued, the confirmation word of the app language and
/// "Delete forever", enabled only with that word. Then the Google sign-in
/// again (NFR4.6) and, on success, the gate shows only the progress.
class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key, required this.user});

  final AppUser user;

  static Future<void> open(BuildContext context, AppUser user) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => DeleteAccountScreen(user: user),
        ),
      );

  @override
  ConsumerState<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  final TextEditingController _word = TextEditingController();
  int _pending = 0;
  bool _offline = false;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _word.addListener(() => setState(() {}));
    _load();
  }

  Future<void> _load() async {
    final pending = await ref.read(accountGateProvider).pendingChanges();
    final online = await ref.read(networkStatusProvider).hasNetwork();
    if (!mounted) return;
    setState(() {
      _pending = pending;
      _offline = !online;
    });
  }

  @override
  void dispose() {
    _word.dispose();
    super.dispose();
  }

  bool _matches(String word) => _word.text.trim().toUpperCase() == word;

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    // BR1.5: checked again right before the deletion.
    if (!await ref.read(networkStatusProvider).hasNetwork()) {
      if (mounted) {
        setState(() {
          _busy = false;
          _offline = true;
        });
      }
      return;
    }
    final result = await ref.read(accountGateProvider).deleteAccount();
    if (!mounted) return;
    if (result == ReauthResult.confirmed) {
      // The gate now shows only the progress (BR1.5).
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }
    setState(() {
      _busy = false;
      _offline = false;
      _error = result == ReauthResult.failed
          ? l10n.deletionFailed
          : l10n.deleteAccountSameAccount;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final word = l10n.deleteAccountConfirmWord;
    final message = _offline ? l10n.deleteAccountNeedsNetwork : _error;
    return Scaffold(
      key: const Key('delete-account-screen'),
      appBar: AppBar(title: Text(l10n.profileDeleteAccount)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.deleteAccountIntro, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              for (final item in [
                l10n.deleteAccountItemCellar,
                l10n.deleteAccountItemShares,
                l10n.deleteAccountItemMemberships,
                l10n.deleteAccountItemProfile,
              ])
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.remove_circle_outline),
                  title: Text(item),
                ),
              if (_pending > 0) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.deleteAccountPending(_pending),
                  key: const Key('delete-pending'),
                  style: theme.textTheme.bodyLarge,
                ),
              ],
              const SizedBox(height: 16),
              TextField(
                key: const Key('delete-confirm-word'),
                controller: _word,
                enabled: !_busy,
                textCapitalization: TextCapitalization.characters,
                autocorrect: false,
                enableSuggestions: false,
                decoration: InputDecoration(
                  labelText: l10n.deleteAccountTypeWord(word),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Text(l10n.deleteAccountReauthHint),
              if (message != null) ...[
                const SizedBox(height: 16),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    message,
                    key: const Key('delete-message'),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton(
                key: const Key('delete-forever'),
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                ),
                onPressed: !_busy && _matches(word) ? _delete : null,
                child: _busy
                    ? SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          semanticsLabel: l10n.deletionTitle,
                        ),
                      )
                    : Text(l10n.deleteAccountForever),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The name of [step] in the app language.
String deletionStepLabel(
  AppLocalizations l10n,
  DeletionStep step,
) => switch (step) {
  DeletionStep.preparePhone => l10n.deletionStepPreparePhone,
  DeletionStep.markStarted => l10n.deletionStepMarkStarted,
  DeletionStep.leaveOtherCellars => l10n.deletionStepLeaveOtherCellars,
  DeletionStep.closeOwnInvitations => l10n.deletionStepCloseOwnInvitations,
  DeletionStep.deleteWinesAndRecords => l10n.deletionStepDeleteWinesAndRecords,
  DeletionStep.deleteCellar => l10n.deletionStepDeleteCellar,
  DeletionStep.deleteProfileAndUser => l10n.deletionStepDeleteProfileAndUser,
  DeletionStep.cleanUpPhone => l10n.deletionStepCleanUpPhone,
};

/// The only screen while an account is deleted (BR1.5, BR1.7, BR1.8): the
/// steps with their state, the current one announced to TalkBack (NFR3.2),
/// "Try again" on every error (NFR6.4), "Continue" after a resume, and
/// "Cancel" only while nothing was deleted yet. Back does nothing.
class DeletionProgressView extends StatelessWidget {
  const DeletionProgressView({
    super.key,
    required this.state,
    required this.onContinue,
    required this.onCancel,
  });

  final GateDeleting state;
  final VoidCallback onContinue;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final current = deletionStepLabel(l10n, state.step);
    final notice = switch (state.notice) {
      DeletionNotice.offline => l10n.deletionOffline,
      DeletionNotice.pendingWrites => l10n.deletionPendingWrites,
      DeletionNotice.sameAccountRequired => l10n.deleteAccountSameAccount,
      DeletionNotice.failed => l10n.deletionFailed,
      null =>
        state.needsReauth && !state.running ? l10n.deletionResumeHint : null,
    };
    return PopScope(
      canPop: false,
      child: Scaffold(
        key: const Key('deletion-progress'),
        appBar: AppBar(
          title: Text(l10n.deletionTitle),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  key: const Key('deletion-current-step'),
                  liveRegion: true,
                  label: l10n.deletionStepAnnounce(
                    state.step.index + 1,
                    current,
                  ),
                  excludeSemantics: true,
                  child: Text(current, style: theme.textTheme.titleMedium),
                ),
                if (state.running) ...[
                  const SizedBox(height: 12),
                  LinearProgressIndicator(semanticsLabel: l10n.deletionTitle),
                ],
                if (state.deletedDocuments > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n.deletionDeletedCount(state.deletedDocuments),
                    key: const Key('deletion-count'),
                  ),
                ],
                const SizedBox(height: 16),
                for (final step in DeletionPlan.steps)
                  _StepRow(
                    label: deletionStepLabel(l10n, step),
                    done: step.index < state.step.index,
                    current: step == state.step,
                  ),
                if (notice != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    notice,
                    key: const Key('deletion-notice'),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: state.notice == null
                          ? null
                          : theme.colorScheme.error,
                    ),
                  ),
                ],
                if (!state.running &&
                    (state.notice != null || state.needsReauth)) ...[
                  const SizedBox(height: 16),
                  FilledButton(
                    key: const Key('deletion-retry'),
                    onPressed: onContinue,
                    child: Text(
                      state.needsReauth && state.notice == null
                          ? l10n.deletionContinue
                          : l10n.retry,
                    ),
                  ),
                ],
                if (state.canCancel) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    key: const Key('deletion-cancel'),
                    onPressed: onCancel,
                    child: Text(l10n.cancel),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.label,
    required this.done,
    required this.current,
  });

  final String label;
  final bool done;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        done
            ? Icons.check_circle
            : current
            ? Icons.radio_button_checked
            : Icons.radio_button_unchecked,
        color: done || current ? colors.primary : colors.onSurfaceVariant,
      ),
      title: Text(label),
    );
  }
}
