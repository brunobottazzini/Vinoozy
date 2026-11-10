import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/app_user.dart';
import '../../l10n/app_localizations.dart';
import '../plan_providers.dart';
import 'plan_labels.dart';
import 'plus_screen.dart';

/// The plan row of the Profile (freemium-plus FR1.3, FR5.4): the plan in
/// force and "Discover Plus". A gift never shows renewals or charges; a
/// developer scenario shows its "DEV · …" indicator.
class ProfilePlanRow extends ConsumerWidget {
  const ProfilePlanRow({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final plan = ref.watch(resolvedPlanProvider(user.uid));
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.planTitle, style: theme.textTheme.labelLarge),
                Text(
                  planLabelOf(l10n, plan),
                  key: const Key('profile-plan'),
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            TextButton(
              key: const Key('profile-discover-plus'),
              onPressed: () => PlusScreen.open(context, user),
              child: Text(l10n.planDiscoverPlus),
            ),
          ],
        ),
      ),
    );
  }
}
