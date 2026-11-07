import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../domain/membership.dart';
import 'sharing_labels.dart';

/// One person of the owner's list (BR1.8, BR1.9, BR1.12): name or email,
/// permission and status, read by TalkBack as "name, permission, status".
///
/// In the main list (invited or active) it offers the permission menu and
/// "Revoke"; in "Closed access" (revoked or left) "Invite again" and
/// "Delete for good". [enabled] is false offline or while an operation runs.
class MemberTile extends StatelessWidget {
  const MemberTile({
    super.key,
    required this.member,
    required this.enabled,
    required this.busy,
    this.onPermission,
    this.onRevoke,
    this.onReinvite,
    this.onDelete,
  });

  final Membership member;
  final bool enabled;
  final bool busy;
  final ValueChanged<MemberPermission>? onPermission;
  final VoidCallback? onRevoke;
  final VoidCallback? onReinvite;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final permission = l10n.permissionLabel(member.permission);
    final status = l10n.statusLabel(member);
    final key = member.memberKey;
    return ListTile(
      key: Key('member-$key'),
      title: MergeSemantics(
        child: Semantics(
          label: l10n.sharingMemberSemantics(member.label, permission, status),
          excludeSemantics: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(member.label),
              Text(
                '$permission · $status',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
      trailing: busy
          ? const SizedBox.square(
              dimension: 48,
              child: Center(child: CircularProgressIndicator()),
            )
          : Wrap(children: _actions(l10n, key)),
    );
  }

  List<Widget> _actions(AppLocalizations l10n, String key) {
    final active = enabled;
    if (member.isOpen) {
      return [
        PermissionMenu(
          key: Key('member-permission-$key'),
          current: member.permission,
          name: member.label,
          onSelected: active ? onPermission : null,
        ),
        IconButton(
          key: Key('member-revoke-$key'),
          tooltip: l10n.sharingRevoke,
          icon: const Icon(Icons.person_remove_outlined),
          onPressed: active ? onRevoke : null,
        ),
      ];
    }
    return [
      IconButton(
        key: Key('member-reinvite-$key'),
        tooltip: l10n.sharingReinvite,
        icon: const Icon(Icons.person_add_alt),
        onPressed: active ? onReinvite : null,
      ),
      IconButton(
        key: Key('member-delete-$key'),
        tooltip: l10n.sharingDeleteForGood,
        icon: const Icon(Icons.delete_forever_outlined),
        onPressed: active ? onDelete : null,
      ),
    ];
  }
}

/// "Read only" / "Can edit" for one person (BR1.9).
class PermissionMenu extends StatelessWidget {
  const PermissionMenu({
    super.key,
    required this.current,
    required this.name,
    required this.onSelected,
  });

  final MemberPermission current;
  final String name;
  final ValueChanged<MemberPermission>? onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final onSelected = this.onSelected;
    return PopupMenuButton<MemberPermission>(
      tooltip: l10n.sharingChangePermission(name),
      enabled: onSelected != null,
      icon: const Icon(Icons.tune),
      initialValue: current,
      onSelected: (permission) {
        if (permission != current) onSelected?.call(permission);
      },
      itemBuilder: (_) => [
        for (final permission in MemberPermission.values)
          PopupMenuItem(
            key: Key('permission-option-${permission.name}'),
            value: permission,
            child: Text(l10n.permissionLabel(permission)),
          ),
      ],
    );
  }
}
