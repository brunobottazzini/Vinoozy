import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../account/app_user.dart';
import '../../ads/ad_eligibility.dart';
import '../../l10n/app_localizations.dart';
import '../../usage/usage_providers.dart';
import '../plan_notices.dart';
import '../plan_providers.dart';
import 'plus_screen.dart';

/// The plan notices at the top of the Dashboard content: the free-plan
/// presentation (freemium-plus FR8.2) and the threshold explanation
/// (FR7.5). Cards in the list, never a popup, so neither ever appears over a
/// save.
class DashboardPlanNotices extends ConsumerWidget {
  const DashboardPlanNotices({super.key, required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final policy = ref.watch(planPolicyProvider);
    final capabilities = ref.watch(capabilitiesProvider(user.uid));
    final usage =
        ref.watch(usageStatusProvider).value ??
        UsageStatus.unverified(DateTime.now().toUtc());
    final showThreshold = AdEligibility.eligible(
      AdEligibilityInput(
        adsEnabled: policy.adsEnabled,
        stateVerified:
            usage.verified && ref.watch(entitlementKnownProvider(user.uid)),
        plusActive: capabilities.adFree,
        aboveThreshold: usage.aboveBudget,
      ),
    );
    final showIntro =
        policy.capacityLimitEnabled && !capabilities.unlimitedActiveWines;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showIntro)
          _OnceNotice(
            notice: freePlanIntroNotice(user.uid),
            builder: (onClose) =>
                FreePlanIntroCard(user: user, onClose: onClose),
          ),
        if (showThreshold)
          _OnceNotice(
            notice: thresholdNotice(user.uid, usage.periodId),
            builder: (onClose) => ThresholdNoticeCard(
              user: user,
              nextResetUtc: usage.nextResetUtc,
              onClose: onClose,
            ),
          ),
      ],
    );
  }
}

/// Shows [builder] while [notice] was never seen; remembers it as seen when
/// it appears, and hides it when closed.
class _OnceNotice extends ConsumerStatefulWidget {
  const _OnceNotice({required this.notice, required this.builder});

  final PlanNoticeKey notice;
  final Widget Function(VoidCallback onClose) builder;

  @override
  ConsumerState<_OnceNotice> createState() => _OnceNoticeState();
}

class _OnceNoticeState extends ConsumerState<_OnceNotice> {
  PlanNoticeKey? _marked;

  @override
  Widget build(BuildContext context) {
    final provider = planNoticeSeenProvider(widget.notice);
    final seen = ref.watch(provider).value ?? true;
    if (seen) return const SizedBox.shrink();
    if (_marked != widget.notice) {
      _marked = widget.notice;
      // After the frame: a provider cannot change while the tree builds.
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => ref.read(provider.notifier).markSeen(),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: widget.builder(() => ref.read(provider.notifier).dismiss()),
    );
  }
}

/// The free-plan presentation (FR8.1, FR8.2; study §7.8): shown once when the
/// capacity limit is turned on. With ads off it says "No ads in the launch
/// version"; with purchases off it never promises a Plus to buy.
class FreePlanIntroCard extends ConsumerWidget {
  const FreePlanIntroCard({
    super.key,
    required this.user,
    required this.onClose,
  });

  final AppUser user;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final policy = ref.watch(planPolicyProvider);
    return _NoticeCard(
      key: const Key('free-plan-intro'),
      title: l10n.freeIntroTitle,
      paragraphs: [
        [
          l10n.freeIntroLimit(policy.freeActiveWineLimit),
          policy.adsEnabled ? l10n.freeIntroAds : l10n.freeIntroNoAds,
          policy.purchasesEnabled ? l10n.freeIntroPlus : l10n.plusComingSoon,
        ].join(' '),
      ],
      actions: [
        TextButton(
          key: const Key('free-plan-intro-discover-plus'),
          onPressed: () => PlusScreen.open(context, user),
          child: Text(l10n.planDiscoverPlus),
        ),
        FilledButton.tonal(
          key: const Key('free-plan-intro-close'),
          onPressed: onClose,
          child: Text(l10n.noticeGotIt),
        ),
      ],
    );
  }
}

/// The threshold explanation (FR7.5; study §7.7, §7.8): once per month and
/// account, with the next reset in the phone's local time, "How it works"
/// and "Discover Plus".
class ThresholdNoticeCard extends StatelessWidget {
  const ThresholdNoticeCard({
    super.key,
    required this.user,
    required this.nextResetUtc,
    required this.onClose,
  });

  final AppUser user;
  final DateTime nextResetUtc;
  final VoidCallback onClose;

  /// [instant] in the phone's time zone, with date and time.
  static String formatReset(DateTime instant, Locale locale) =>
      DateFormat.yMMMMd(locale.toLanguageTag())
          .add_Hm()
          .format(instant.toLocal());

  Future<void> _howItWorks(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        key: const Key('threshold-how-dialog'),
        title: Text(l10n.thresholdHowItWorks),
        content: SingleChildScrollView(
          child: Text(l10n.thresholdHowItWorksBody),
        ),
        actions: [
          TextButton(
            key: const Key('threshold-how-close'),
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
    final reset = formatReset(nextResetUtc, Localizations.localeOf(context));
    return _NoticeCard(
      key: const Key('threshold-notice'),
      title: l10n.thresholdTitle,
      paragraphs: [
        l10n.thresholdBody,
        l10n.thresholdReset,
        l10n.thresholdNextReset(reset),
      ],
      paragraphKeys: const {2: Key('threshold-next-reset')},
      actions: [
        TextButton(
          key: const Key('threshold-how-it-works'),
          onPressed: () => _howItWorks(context),
          child: Text(l10n.thresholdHowItWorks),
        ),
        TextButton(
          key: const Key('threshold-discover-plus'),
          onPressed: () => PlusScreen.open(context, user),
          child: Text(l10n.planDiscoverPlus),
        ),
        FilledButton.tonal(
          key: const Key('threshold-close'),
          onPressed: onClose,
          child: Text(l10n.noticeGotIt),
        ),
      ],
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({
    super.key,
    required this.title,
    required this.paragraphs,
    required this.actions,
    this.paragraphKeys = const {},
  });

  final String title;
  final List<String> paragraphs;
  final Map<int, Key> paragraphKeys;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(title, style: theme.textTheme.titleMedium),
            ),
            for (final (index, text) in paragraphs.indexed)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(text, key: paragraphKeys[index]),
              ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 4,
              children: actions,
            ),
          ],
        ),
      ),
    );
  }
}
