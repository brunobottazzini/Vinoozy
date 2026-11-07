import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/app_user.dart';
import '../../app/providers.dart';
import '../../cellar/domain/cellar.dart';
import '../../l10n/app_localizations.dart';
import '../domain/invite_validator.dart';
import '../domain/membership.dart';
import '../domain/sharing_error.dart';
import '../sharing_providers.dart';
import 'invite_form.dart';
import 'member_tile.dart';
import 'share_launcher.dart';
import 'sharing_dialogs.dart';
import 'sharing_labels.dart';

/// "People" of the active cellar (BR1.1, BR1.12; frontend-components.md).
///
/// The owner sees the invitation form, the people invited or active and the
/// closed section "Closed access". An invited person sees only the owner,
/// the own permission and "Leave this cellar". Every management command
/// needs the network (BR1.11) and shows a progress indicator while it runs.
class SharingScreen extends ConsumerStatefulWidget {
  const SharingScreen({super.key, required this.user});

  final AppUser user;

  @override
  ConsumerState<SharingScreen> createState() => _SharingScreenState();
}

class _SharingScreenState extends ConsumerState<SharingScreen> {
  final Set<String> _busy = {};

  AppUser get _user => widget.user;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final active = ref.watch(activeCellarProvider(_user));
    final online = ref.watch(sharingOnlineProvider).value ?? false;
    return Scaffold(
      key: const Key('sharing-screen'),
      appBar: AppBar(title: Text(l10n.sharingPeopleTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (!online)
              Semantics(
                liveRegion: true,
                child: Text(
                  l10n.sharingOfflineHint,
                  key: const Key('sharing-offline'),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            if (active.isOwner)
              ..._ownerView(l10n, active, online)
            else
              ..._inviteeView(l10n, active, online),
          ],
        ),
      ),
    );
  }

  // ---- Owner --------------------------------------------------------------

  List<Widget> _ownerView(
    AppLocalizations l10n,
    AccessibleCellar active,
    bool online,
  ) {
    final members = ref.watch(cellarMembersProvider(active.cellarId));
    final cellar = ref
        .watch(cellarStreamProvider(active.cellarId))
        .value
        ?.cellar;
    final list = members.value;
    if (list == null) {
      return [
        if (members.hasError)
          Text(l10n.sharingFailed, key: const Key('sharing-members-error'))
        else
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(key: Key('sharing-loading')),
            ),
          ),
      ];
    }
    final sorted = [...list]
      ..sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));
    final open = sorted.where((member) => member.isOpen).toList();
    final closed = sorted.where((member) => !member.isOpen).toList();
    final slots = cellar?.memberSlots ?? 0;
    return [
      InviteForm(
        usedPlaces: InviteValidator.usedPlaces(list, slots),
        online: online,
        onInvite: (email, permission) =>
            _invite(cellar ?? _fallbackCellar(active), list, email, permission),
      ),
      const Divider(height: 32),
      if (open.isEmpty)
        Text(l10n.sharingNobody, key: const Key('sharing-nobody'))
      else
        for (final member in open) _tile(member, online, active, list, cellar),
      if (closed.isNotEmpty)
        ExpansionTile(
          key: const Key('sharing-closed-section'),
          tilePadding: EdgeInsets.zero,
          title: Text(l10n.sharingClosedSection),
          children: [
            for (final member in closed)
              _tile(member, online, active, list, cellar),
          ],
        ),
    ];
  }

  Cellar _fallbackCellar(AccessibleCellar active) =>
      Cellar(id: active.cellarId, ownerId: active.ownerId, name: '');

  Widget _tile(
    Membership member,
    bool online,
    AccessibleCellar active,
    List<Membership> members,
    Cellar? cellar,
  ) {
    final key = member.memberKey;
    final repository = ref.read(sharingRepositoryProvider);
    return MemberTile(
      member: member,
      enabled: online && _busy.isEmpty,
      busy: _busy.contains(key),
      onPermission: (permission) => _run(
        key,
        () => repository.changePermission(
          cellarId: active.cellarId,
          memberKey: key,
          permission: permission,
          owner: _user,
        ),
      ),
      onRevoke: () async {
        if (!await RevokeDialog.confirm(context, member.label)) return;
        await _run(
          key,
          () => repository.revoke(
            cellarId: active.cellarId,
            memberKey: key,
            owner: _user,
          ),
        );
      },
      onReinvite: () => _run(key, () async {
        final error = await _invite(
          cellar ?? _fallbackCellar(active),
          members,
          member.inviteeEmail,
          member.permission,
        );
        if (error != null) throw SharingException(error);
      }),
      onDelete: () => _run(
        key,
        () => repository.deleteClosed(
          cellarId: active.cellarId,
          memberKey: key,
          owner: _user,
        ),
      ),
    );
  }

  /// Invites, then opens the share sheet with the ready-made message
  /// (BR1.3). Closing the sheet keeps the invitation.
  Future<SharingError?> _invite(
    Cellar cellar,
    List<Membership> members,
    String email,
    MemberPermission permission,
  ) async {
    final l10n = AppLocalizations.of(context);
    final String key;
    try {
      key = await ref
          .read(sharingRepositoryProvider)
          .invite(
            cellar: cellar,
            owner: _user,
            rawEmail: email,
            permission: permission,
            members: members,
          );
    } on SharingException catch (error) {
      return error.error;
    }
    final message = l10n.sharingShareMessage(
      displayNameOrFallback(_user.displayName, _user.email),
      cellar.name.isEmpty ? l10n.defaultCellarName : cellar.name,
      playStoreLink,
      key,
    );
    try {
      await ref
          .read(shareLauncherProvider)
          .share(text: message, subject: l10n.sharingShareSubject);
    } catch (error) {
      // The invitation is already valid; the sheet is only a convenience.
      debugPrint('Sharing: share sheet not opened (${error.runtimeType})');
    }
    return null;
  }

  Future<void> _run(String id, Future<void> Function() operation) async {
    if (_busy.isNotEmpty) return;
    setState(() => _busy.add(id));
    try {
      await operation();
    } on SharingException catch (error) {
      if (mounted) _showError(error.error);
    } finally {
      if (mounted) setState(() => _busy.remove(id));
    }
  }

  void _showError(SharingError error) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        key: const Key('sharing-error'),
        content: Text(l10n.sharingErrorMessage(error)),
      ),
    );
  }

  // ---- Invited person -----------------------------------------------------

  List<Widget> _inviteeView(
    AppLocalizations l10n,
    AccessibleCellar active,
    bool online,
  ) {
    final theme = Theme.of(context);
    final leaving = _busy.contains(active.cellarId);
    return [
      Text(
        l10n.sharingOwnedBy(active.ownerName),
        key: const Key('sharing-owner'),
        style: theme.textTheme.titleMedium,
      ),
      const SizedBox(height: 8),
      Text(
        l10n.sharingYourPermission(l10n.roleLabel(active.role)),
        key: const Key('sharing-own-permission'),
      ),
      const SizedBox(height: 24),
      OutlinedButton.icon(
        key: const Key('leave-cellar'),
        onPressed: online && !leaving ? () => _leave(active) : null,
        icon: leaving
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.logout),
        label: Text(l10n.sharingLeave),
      ),
    ];
  }

  Future<void> _leave(AccessibleCellar active) async {
    if (!await LeaveCellarDialog.confirm(context, active.ownerName)) return;
    if (!mounted) return;
    final notifier = ref.read(activeCellarProvider(_user).notifier);
    var left = false;
    await _run(active.cellarId, () async {
      await notifier.leaveActive();
      left = true;
    });
    if (left && mounted) Navigator.of(context).maybePop();
  }
}
