import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Revocation confirmed by typing the person's name, or the email when the
/// name is missing (BR1.8; security-design.md §3). Returns true on "Revoke".
class RevokeDialog extends StatefulWidget {
  const RevokeDialog({super.key, required this.expectedName});

  final String expectedName;

  static Future<bool> confirm(
    BuildContext context,
    String expectedName,
  ) async =>
      await showDialog<bool>(
        context: context,
        builder: (_) => RevokeDialog(expectedName: expectedName),
      ) ??
      false;

  @override
  State<RevokeDialog> createState() => _RevokeDialogState();
}

class _RevokeDialogState extends State<RevokeDialog> {
  final TextEditingController _confirmation = TextEditingController();

  /// Spaces around and letter case do not matter; the name itself does.
  bool get _matches =>
      _confirmation.text.trim().toLowerCase() ==
      widget.expectedName.trim().toLowerCase();

  @override
  void dispose() {
    _confirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      key: const Key('revoke-dialog'),
      title: Text(l10n.sharingRevokeTitle(widget.expectedName)),
      content: TextField(
        key: const Key('revoke-confirm-field'),
        controller: _confirmation,
        autofocus: true,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          labelText: l10n.sharingRevokeConfirmLabel(widget.expectedName),
        ),
      ),
      actions: [
        TextButton(
          key: const Key('revoke-cancel'),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          key: const Key('revoke-confirm'),
          onPressed: _matches ? () => Navigator.of(context).pop(true) : null,
          // Merged into the button's node: while disabled TalkBack says why.
          child: Semantics(
            hint: _matches ? null : l10n.sharingRevokeDisabledHint,
            child: Text(l10n.sharingRevoke),
          ),
        ),
      ],
    );
  }
}

/// "Leave this cellar" confirmation (BR1.10). Returns true on "Leave".
class LeaveCellarDialog extends StatelessWidget {
  const LeaveCellarDialog({super.key, required this.ownerName});

  final String ownerName;

  static Future<bool> confirm(BuildContext context, String ownerName) async =>
      await showDialog<bool>(
        context: context,
        builder: (_) => LeaveCellarDialog(ownerName: ownerName),
      ) ??
      false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      key: const Key('leave-dialog'),
      title: Text(l10n.sharingLeaveTitle(ownerName)),
      content: Text(l10n.sharingLeaveBody(ownerName)),
      actions: [
        TextButton(
          key: const Key('leave-cancel'),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          key: const Key('leave-confirm'),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.sharingLeaveConfirm),
        ),
      ],
    );
  }
}
