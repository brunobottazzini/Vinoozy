import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../domain/invite_validator.dart';
import '../domain/membership.dart';
import '../domain/sharing_error.dart';
import 'sharing_labels.dart';

/// The invitation form (BR1.2, BR1.11; frontend-components.md): email, the
/// two permissions with their explanation, "Invite" and the places used
/// ("x/2"). Disabled offline; with the places used up it says so and
/// "Invite" stays disabled (AC8.1.2). A double tap is ignored while the
/// invitation runs.
class InviteForm extends StatefulWidget {
  const InviteForm({
    super.key,
    required this.usedPlaces,
    required this.online,
    required this.onInvite,
  });

  final int usedPlaces;
  final bool online;

  /// Runs the invitation; returns the error, or null when it succeeded.
  final Future<SharingError?> Function(
    String email,
    MemberPermission permission,
  )
  onInvite;

  @override
  State<InviteForm> createState() => _InviteFormState();
}

class _InviteFormState extends State<InviteForm> {
  final TextEditingController _email = TextEditingController();
  MemberPermission _permission = MemberPermission.read;
  SharingError? _error;
  bool _busy = false;

  bool get _full => widget.usedPlaces >= InviteValidator.maxInvitees;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final error = await widget.onInvite(_email.text, _permission);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = error;
      if (error == null) _email.clear();
    });
  }

  static const _fieldErrors = {
    SharingError.invalidEmail,
    SharingError.selfInvite,
    SharingError.alreadyInvited,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final error = _error;
    final fieldError = error != null && _fieldErrors.contains(error)
        ? l10n.sharingErrorMessage(error)
        : null;
    final formError = error != null && fieldError == null
        ? l10n.sharingErrorMessage(error, invite: true)
        : null;
    final enabled = widget.online && !_full && !_busy;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.sharingInviteTitle, style: theme.textTheme.titleMedium),
        Text(
          l10n.sharingPlacesUsed(
            widget.usedPlaces,
            InviteValidator.maxInvitees,
          ),
          key: const Key('invite-places'),
        ),
        const SizedBox(height: 8),
        TextField(
          key: const Key('invite-email'),
          controller: _email,
          enabled: widget.online && !_full,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          decoration: InputDecoration(
            labelText: l10n.sharingEmailLabel,
            errorText: fieldError,
            errorMaxLines: 3,
          ),
        ),
        for (final permission in MemberPermission.values)
          _PermissionOption(
            key: Key('invite-permission-${permission.name}'),
            permission: permission,
            selected: permission == _permission,
            onTap: () => setState(() => _permission = permission),
          ),
        if (_full)
          Semantics(
            liveRegion: true,
            child: Text(
              l10n.sharingLimitReached(InviteValidator.maxInvitees),
              key: const Key('invite-limit'),
              style: theme.textTheme.bodyLarge,
            ),
          ),
        if (formError != null)
          Semantics(
            liveRegion: true,
            child: Text(
              formError,
              key: const Key('invite-error'),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        const SizedBox(height: 8),
        FilledButton.icon(
          key: const Key('invite-submit'),
          onPressed: enabled ? _submit : null,
          icon: _busy
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.person_add),
          label: Text(l10n.sharingInviteButton),
        ),
      ],
    );
  }
}

class _PermissionOption extends StatelessWidget {
  const _PermissionOption({
    super.key,
    required this.permission,
    required this.selected,
    required this.onTap,
  });

  final MemberPermission permission;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hint = switch (permission) {
      MemberPermission.read => l10n.sharingPermissionReadHint,
      MemberPermission.edit => l10n.sharingPermissionEditHint,
    };
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        ),
        selected: selected,
        title: Text(l10n.permissionLabel(permission)),
        subtitle: Text(hint),
        onTap: onTap,
      ),
    );
  }
}
