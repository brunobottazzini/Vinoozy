import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/app_user.dart';
import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../sharing/domain/membership.dart';
import '../capacity_guard.dart';
import '../plan_providers.dart';
import 'plus_screen.dart';

/// The check made at the entry points that add an active wine (freemium-plus
/// FR2.4, FR2.5): "Add", the "+" of a finished wine and "Add bottles" to a
/// finished duplicate. When the write would take the person's own cellar
/// over its limit, nothing is written and the explanation with "Discover
/// Plus" opens; the answer is false.
///
/// The count is the one the phone sees: the wines with `quantity > 0` of the
/// single wines listener, and the cellar's migrated limit. The rules decide
/// in the end; a refusal comes back as a recoverable draft (FR2.5).
Future<bool> ensureCapacity(
  BuildContext context,
  WidgetRef ref, {
  required AppUser user,
  required AccessibleCellar cellar,
  int activeDelta = 1,
}) async {
  final decision = CapacityGuard.check(
    policy: ref.read(planPolicyProvider),
    capabilities: ref.read(capabilitiesProvider(user.uid)),
    ownCellar: cellar.isOwner,
    activeWines:
        ref.read(winesStreamProvider(cellar.cellarId)).value?.wines.length ?? 0,
    activeDelta: activeDelta,
    legacyActiveWineLimit: ref
        .read(cellarStreamProvider(cellar.cellarId))
        .value
        ?.cellar
        ?.legacyActiveWineLimit,
  );
  if (decision is! CapacityBlocked) return true;
  await CapacityLimitSheet.show(context, user: user, limit: decision.limit);
  return false;
}

/// "You reached the limit of the free plan" (FR2.5) with "Discover Plus".
class CapacityLimitSheet extends ConsumerWidget {
  const CapacityLimitSheet({
    super.key,
    required this.user,
    required this.limit,
  });

  final AppUser user;
  final int limit;

  static Future<void> show(
    BuildContext context, {
    required AppUser user,
    required int limit,
  }) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => CapacityLimitSheet(user: user, limit: limit),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final purchases = ref.watch(planPolicyProvider).purchasesEnabled;
    return SafeArea(
      child: SingleChildScrollView(
        key: const Key('capacity-limit-sheet'),
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.capacityLimitTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(
              purchases
                  ? l10n.capacityLimitBody(limit)
                  : l10n.capacityLimitBodyComingSoon(limit),
              key: const Key('capacity-limit-body'),
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('capacity-limit-discover-plus'),
              onPressed: () {
                final navigator = Navigator.of(context)..pop();
                navigator.push(
                  MaterialPageRoute<void>(
                    builder: (_) => PlusScreen(user: user),
                  ),
                );
              },
              child: Text(l10n.planDiscoverPlus),
            ),
            const SizedBox(height: 8),
            TextButton(
              key: const Key('capacity-limit-close'),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.close),
            ),
          ],
        ),
      ),
    );
  }
}
