import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/app_user.dart';
import '../../l10n/app_localizations.dart';
import '../domain/membership.dart';
import '../sharing_providers.dart';
import 'sharing_labels.dart';

/// The active cellar at the top of the Dashboard and the Cellar, with the
/// choice among the accessible cellars (BR1.5; frontend-components.md).
///
/// With the personal cellar only it shows nothing, so a phone without
/// sharing looks exactly as before u7-sharing (NFR7.5).
class CellarSwitcher extends ConsumerWidget {
  const CellarSwitcher({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cellars = ref.watch(accessibleCellarsProvider(user));
    if (cellars.length < 2) return const SizedBox.shrink();
    final active = ref.watch(activeCellarProvider(user));
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final name = l10n.cellarLabel(active);
    final role = l10n.roleLabel(active.role);
    return Semantics(
      button: true,
      label: l10n.sharingSwitcherSemantics(name, role),
      excludeSemantics: true,
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest,
        child: InkWell(
          key: const Key('cellar-switcher'),
          onTap: () => _choose(context, ref, cellars, active),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    active.isPersonal ? Icons.home_outlined : Icons.people_alt,
                    color: theme.colorScheme.onSurface,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '$name · $role',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Icon(Icons.expand_more, color: theme.colorScheme.onSurface),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _choose(
    BuildContext context,
    WidgetRef ref,
    List<AccessibleCellar> cellars,
    AccessibleCellar active,
  ) async {
    final chosen = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) {
        final l10n = AppLocalizations.of(sheetContext);
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final cellar in cellars)
                ListTile(
                  key: Key('cellar-option-${cellar.cellarId}'),
                  leading: Icon(
                    cellar.cellarId == active.cellarId
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                  ),
                  selected: cellar.cellarId == active.cellarId,
                  title: Text(l10n.cellarLabel(cellar)),
                  subtitle: Text(l10n.roleLabel(cellar.role)),
                  onTap: () => Navigator.of(sheetContext).pop(cellar.cellarId),
                ),
            ],
          ),
        );
      },
    );
    if (chosen == null) return;
    await ref.read(activeCellarProvider(user).notifier).select(chosen);
  }
}
