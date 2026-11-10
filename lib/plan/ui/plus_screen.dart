import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/app_user.dart';
import '../../app/external_links.dart';
import '../../l10n/app_localizations.dart';
import '../billing/billing_client.dart';
import '../billing/billing_service.dart';
import '../capability_resolver.dart';
import '../domain/capabilities.dart';
import '../plan_providers.dart';
import 'plan_labels.dart';

/// "Vinoozy Plus" (freemium-plus FR3.1, FR3.2, FR3.5).
///
/// The real benefits only (no ads, no cellar limit; never features not yet
/// built), the prices read from Google Play with the renewal and the terms,
/// "Restore purchases" and the link to manage or cancel the subscription on
/// Google Play. With `purchasesEnabled=false` it says "Plus is coming soon"
/// and shows no purchase button: the store is not even asked.
class PlusScreen extends ConsumerStatefulWidget {
  const PlusScreen({super.key, required this.user});

  final AppUser user;

  static Future<void> open(BuildContext context, AppUser user) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => PlusScreen(user: user)));

  @override
  ConsumerState<PlusScreen> createState() => _PlusScreenState();
}

class _PlusScreenState extends ConsumerState<PlusScreen> {
  bool _loadRequested = false;

  void _loadIfNeeded(bool purchasesEnabled, ResolvedPlan plan) {
    if (!purchasesEnabled || plan.tier.isPlus || _loadRequested) return;
    _loadRequested = true;
    // After the frame: a provider cannot change while the tree builds.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(ref.read(billingServiceProvider.notifier).load());
    });
  }

  Future<void> _manage() async {
    final opened = await ref.read(externalLinkOpenerProvider)(plusManageUrl);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          key: const Key('plus-link-failed'),
          content: Text(AppLocalizations.of(context).profileOpenLinkFailed),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final policy = ref.watch(planPolicyProvider);
    final plan = ref.watch(resolvedPlanProvider(widget.user.uid));
    _loadIfNeeded(policy.purchasesEnabled, plan);
    return Scaffold(
      key: const Key('plus-screen'),
      appBar: AppBar(title: Text(l10n.plusTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(l10n.plusBenefitsTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            _Benefit(icon: Icons.block, text: l10n.plusBenefitNoAds),
            _Benefit(icon: Icons.all_inclusive, text: l10n.plusBenefitNoLimit),
            const SizedBox(height: 24),
            ..._body(context, l10n, theme, plan, policy.purchasesEnabled),
          ],
        ),
      ),
    );
  }

  List<Widget> _body(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
    ResolvedPlan plan,
    bool purchasesEnabled,
  ) {
    if (plan.tier.isPlus) {
      return [
        Text(
          plan.tier.origin == PlanOrigin.manualGrant
              ? l10n.plusActiveGift
              : plan.tier.origin == PlanOrigin.developerOverride
              ? planLabelOf(l10n, plan)
              : l10n.plusActive,
          key: const Key('plus-active'),
          style: theme.textTheme.titleMedium,
        ),
        // A gift has nothing to manage on Google Play (FR1.3).
        if (plan.tier.origin == PlanOrigin.playPurchase) ...[
          const SizedBox(height: 16),
          _ManageLink(onPressed: _manage),
        ],
      ];
    }
    if (!purchasesEnabled) {
      return [
        Text(
          l10n.plusComingSoon,
          key: const Key('plus-coming-soon'),
          style: theme.textTheme.titleMedium,
        ),
      ];
    }
    final billing = ref.watch(billingServiceProvider);
    return [
      ..._offers(l10n, theme, billing),
      if (_statusOf(l10n, billing) case final status?) ...[
        const SizedBox(height: 12),
        Semantics(
          liveRegion: true,
          child: Text(
            status,
            key: const Key('plus-status'),
            style: theme.textTheme.bodyLarge,
          ),
        ),
      ],
      const SizedBox(height: 16),
      Text(l10n.plusRenewal, key: const Key('plus-renewal')),
      const SizedBox(height: 8),
      Text(l10n.plusTerms, key: const Key('plus-terms')),
      const SizedBox(height: 16),
      OutlinedButton(
        key: const Key('plus-restore'),
        onPressed: billing.phase == BillingPhase.verifying
            ? null
            : () => ref.read(billingServiceProvider.notifier).restore(),
        child: Text(l10n.plusRestore),
      ),
      const SizedBox(height: 8),
      _ManageLink(onPressed: _manage),
    ];
  }

  List<Widget> _offers(
    AppLocalizations l10n,
    ThemeData theme,
    BillingState billing,
  ) {
    switch (billing.phase) {
      case BillingPhase.idle || BillingPhase.loading:
        return [
          const LinearProgressIndicator(),
          const SizedBox(height: 8),
          Text(l10n.plusLoading),
        ];
      case BillingPhase.unavailable:
        return [
          Text(
            l10n.plusStoreUnavailable,
            key: const Key('plus-store-unavailable'),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            key: const Key('plus-retry'),
            onPressed: () => ref.read(billingServiceProvider.notifier).load(),
            child: Text(l10n.retry),
          ),
        ];
      default:
        final busy =
            billing.phase == BillingPhase.purchasing ||
            billing.phase == BillingPhase.verifying;
        return [
          for (final offer in billing.offers)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: FilledButton(
                key: Key('plus-buy-${offer.basePlanId ?? offer.key}'),
                onPressed: busy
                    ? null
                    : () =>
                          ref.read(billingServiceProvider.notifier).buy(offer),
                child: Text(_priceOf(l10n, offer)),
              ),
            ),
        ];
    }
  }

  static String _priceOf(AppLocalizations l10n, PlusOffer offer) =>
      switch (offer.period) {
        PlusPeriod.monthly => l10n.plusPriceMonthly(offer.price),
        PlusPeriod.annual => l10n.plusPriceAnnual(offer.price),
        PlusPeriod.unknown => offer.price,
      };

  static String? _statusOf(AppLocalizations l10n, BillingState billing) =>
      switch (billing.phase) {
        BillingPhase.pending => l10n.plusPending,
        BillingPhase.verifying => l10n.plusVerifying,
        BillingPhase.verified => l10n.plusVerified,
        BillingPhase.failed => switch (billing.problem) {
          BillingProblem.invalidPurchase => l10n.plusInvalidPurchase,
          BillingProblem.ownedByAnotherAccount => l10n.plusOwnedByOther,
          BillingProblem.verificationUnavailable =>
            l10n.plusVerificationUnavailable,
          BillingProblem.purchaseFailed || null => l10n.plusPurchaseFailed,
        },
        _ => null,
      };
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(child: Text(text)),
      ],
    ),
  );
}

class _ManageLink extends StatelessWidget {
  const _ManageLink({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => TextButton(
    key: const Key('plus-manage'),
    onPressed: onPressed,
    child: Text(AppLocalizations.of(context).plusManage),
  );
}
