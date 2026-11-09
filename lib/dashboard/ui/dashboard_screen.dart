import '../../app/ui/brand_footer.dart';

import 'dart:developer' show Timeline;

import 'package:estimation/estimation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/app_user.dart';
import '../../cellar/ui/cellar_screen.dart' show CellarSetup;
import '../../firebase/firebase_env.dart';
import '../../l10n/app_localizations.dart';
import '../../sharing/domain/membership.dart';
import '../../sharing/sharing_providers.dart';
import '../../sharing/ui/cellar_switcher.dart';
import '../../sync/ui/offline_banner.dart';
import '../dashboard_providers.dart';
import '../domain/dashboard_summary.dart';
import 'chart_cards.dart';
import 'drink_soon_section.dart';
import 'to_confirm_card.dart';

/// The Dashboard, first screen after sign-in (u5-dashboard FR5.1, US5.1,
/// US5.2). Read only: it shows what [dashboardSummaryProvider] computed
/// from the local wines of U1 and never writes (NFR4.1).
///
/// States: preparing (skeleton, no Firestore listener, as CellarScreen),
/// failed (the U1 error with "Try again"), loading, syncing, empty, content.
/// Navigation is injected, so U4 can rewire it without touching U5.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({
    super.key,
    required this.user,
    required this.setup,
    required this.onRetrySetup,
    required this.onOpenWine,
    required this.onOpenStatus,
    required this.onAddFirstWine,
  });

  final AppUser user;
  final CellarSetup setup;
  final Future<void> Function() onRetrySetup;
  final void Function(String wineId) onOpenWine;
  final void Function(WineStatus status) onOpenStatus;
  final VoidCallback onAddFirstWine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final preparing = setup == CellarSetup.preparing;
    // The active cellar (u7-sharing BR1.5, BR1.6): "read" hides the
    // invitation to add the first wine.
    final active = ref.watch(activeCellarProvider(user));
    return Scaffold(
      key: const Key('dashboard-screen'),
      appBar: AppBar(title: Text(l10n.dashboardTitle)),
      body: Column(
        children: [
          CellarSwitcher(user: user),
          // The banner explains a wait for the first sync (BR1.9).
          if (!preparing) OfflineBanner(cellarId: active.cellarId),
          Expanded(child: _body(context, ref, l10n, active)),
        ],
      ),
    );
  }

  Widget _body(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    AccessibleCellar active,
  ) {
    // No listener while the cellar is prepared (security-design.md §4).
    if (setup == CellarSetup.preparing) return const DashboardSkeleton();
    if (setup == CellarSetup.failed) {
      return _DashboardError(onRetry: onRetrySetup);
    }
    final onAdd = active.canEdit ? onAddFirstWine : null;
    return switch (ref.watch(dashboardSummaryProvider(active.cellarId))) {
      DashboardLoading() => const DashboardSkeleton(),
      DashboardFailed() => _DashboardError(onRetry: onRetrySetup),
      DashboardSyncing() => _Invitation(
        key: const Key('dashboard-syncing'),
        message: l10n.dashboardSyncing,
        buttonKey: const Key('dashboard-syncing-add'),
        onAdd: onAdd,
      ),
      DashboardEmpty() => _Invitation(
        key: const Key('dashboard-empty'),
        message: l10n.cellarEmpty,
        buttonKey: const Key('dashboard-empty-add'),
        onAdd: onAdd,
      ),
      DashboardReady(:final summary) => DashboardContent(
        summary: summary,
        onOpenWine: onOpenWine,
        onOpenStatus: onOpenStatus,
      ),
    };
  }
}

/// The list and the three charts in one scrolling view (NFR2.4).
///
/// Each card receives only its part of the summary; the selector is watched
/// only by the third card, so changing it does not rebuild this widget.
class DashboardContent extends StatefulWidget {
  const DashboardContent({
    super.key = const Key('dashboard-content'),
    required this.summary,
    required this.onOpenWine,
    required this.onOpenStatus,
  });

  final DashboardSummary summary;
  final void Function(String wineId) onOpenWine;
  final void Function(WineStatus status) onOpenStatus;

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  /// The "ready" signal is emitted once per process (performance-design.md).
  static bool _readySignalled = false;

  @override
  void initState() {
    super.initState();
    // Only in measurement builds (--dart-define=PERF=true): kIsPerfBuild is
    // a compile-time constant, so normal builds drop this branch and its
    // marker text (tool/check_release_build.sh).
    if (kIsPerfBuild && !_readySignalled) {
      _readySignalled = true;
      final bottles = widget.summary.totalBottles;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Timeline.instantSync('vinoozy_dashboard_ready');
        debugPrint('VINOOZY_DASHBOARD_READY bottles=$bottles');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final summary = widget.summary;
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          sliver: SliverList.list(
            children: [
              _TotalHero(summary: summary, l10n: l10n),
              const SizedBox(height: 8),
              DrinkSoonSection(
                rows: summary.drinkSoon,
                total: summary.drinkSoonTotal,
                onOpenWine: widget.onOpenWine,
                onOpenStatus: widget.onOpenStatus,
              ),
              // wine-style-profiles BR6.7.
              ToConfirmCard(
                rows: summary.toConfirm,
                onOpenWine: widget.onOpenWine,
              ),
              StatusChartCard(
                summary: summary,
                onOpenStatus: widget.onOpenStatus,
              ),
              PeakYearChartCard(
                peakYears: summary.peakYears,
                toEstimateBottles: summary.toEstimateBottles,
              ),
              BreakdownChartCard(
                byType: summary.byType,
                byRegion: summary.byRegion,
              ),
              // Studio logo and app version at the bottom of the Dashboard.
              const BrandFooter(),
            ],
          ),
        ),
      ],
    );
  }
}

/// The bordeaux box on top (ux-redesign FR3.3, mockup 6): the total in
/// large serif digits and how many bottles are to drink now (ready or to
/// drink soon). `dashboard-total` keeps the full sentence (u1 e2e).
class _TotalHero extends StatelessWidget {
  const _TotalHero({required this.summary, required this.l10n});

  final DashboardSummary summary;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final onHero = TextStyle(color: scheme.onPrimary);
    return Container(
      key: const Key('dashboard-hero'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExcludeSemantics(
            child: Text(
              '${summary.totalBottles}',
              style: theme.textTheme.displaySmall?.merge(onHero),
            ),
          ),
          Text(
            l10n.dashboardTotalBottles(summary.totalBottles),
            key: const Key('dashboard-total'),
            style: theme.textTheme.titleMedium?.merge(onHero),
          ),
          Text(
            l10n.uxDashboardDrinkNow(
              summary.readyBottles + summary.drinkSoonBottles,
            ),
            key: const Key('dashboard-drink-now'),
            style: theme.textTheme.bodyMedium?.merge(onHero),
          ),
        ],
      ),
    );
  }
}

/// Grey outline of the three cards while the data arrives: no endless
/// spinner, the local data usually arrives in under a second.
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key = const Key('dashboard-loading')});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface
        .withValues(alpha: 0.08);
    return Semantics(
      label: AppLocalizations.of(context).cellarLoading,
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (final height in const [120.0, 180.0, 180.0])
            Container(
              height: height,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
        ],
      ),
    );
  }
}

/// The U1 cellar error: "Could not prepare the cellar" with "Try again",
/// which checks the cellar again and reopens both listeners.
class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.onRetry});

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              liveRegion: true,
              child: Text(
                l10n.cellarSetupFailed,
                key: const Key('dashboard-error'),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('dashboard-retry-button'),
              onPressed: onRetry,
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty cellar or first sync: a message and "Add your first wine" (BR1.8);
/// without [onAdd] (a "read only" shared cellar, u7 BR1.6) the message only.
class _Invitation extends StatelessWidget {
  const _Invitation({
    super.key,
    required this.message,
    required this.buttonKey,
    required this.onAdd,
  });

  final String message;
  final Key buttonKey;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            if (onAdd case final add?) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                key: buttonKey,
                onPressed: add,
                icon: const Icon(Icons.add),
                label: Text(AppLocalizations.of(context).dashboardAddFirstWine),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
