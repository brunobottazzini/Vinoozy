import 'dart:async';

import 'package:estimation/estimation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../account/app_user.dart';
import '../cellar/cellar_providers.dart';
import '../cellar/domain/cellar_filter.dart';
import '../cellar/domain/wine.dart';
import '../cellar/ui/cellar_screen.dart';
import '../cellar/ui/history_screen.dart';
import '../cellar/ui/wine_detail_screen.dart';
import '../dashboard/ui/dashboard_screen.dart';
import '../l10n/app_localizations.dart';
import '../label/core/label_session.dart';
import '../label/label_providers.dart';
import '../label/ui/add_choice_screen.dart';
import '../label/ui/label_capture_flow.dart';
import '../label/ui/label_reading_screen.dart';
import '../label/ui/replace_label_dialog.dart';
import '../sharing/domain/membership.dart';
import '../sharing/sharing_providers.dart';
import 'providers.dart';

/// The three tabs of the app after sign-in: Dashboard, Cellar and, since
/// u4-cellar, History (u5-dashboard FR5.1; u4-cellar BR1.16).
///
/// The tabs stay mounted in an [IndexedStack] and receive the same [user],
/// [setup] and [onRetrySetup], so they share the cellar and wines listeners
/// (one Firestore listener each) and going back to a tab rebuilds nothing.
/// The History reads its pages only once its tab has been opened.
///
/// u4-cellar wires the Dashboard (BR1.17): a wine opens its detail, a status
/// opens the Cellar filtered by that status, "Add your first wine" opens the
/// full form. While the cellar is ready the shell keeps the background work
/// of the cellar running (backfill, recovery, estimates; NFR6.6).
///
/// Since u7-sharing every tab shows the active cellar (activeCellarProvider).
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({
    super.key,
    required this.user,
    required this.setup,
    required this.onRetrySetup,
  });

  final AppUser user;
  final CellarSetup setup;
  final Future<void> Function() onRetrySetup;

  static const int dashboardTab = 0;
  static const int cellarTab = 1;
  static const int historyTab = 2;

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _tab = HomeShell.dashboardTab;
  bool _historyOpened = false;

  void _select(int tab) {
    if (tab == _tab) return;
    // The History stays mounted once opened: coming back to it reads the
    // first page again, so drinks written meanwhile, also by other people
    // of a shared cellar, are there (review R-01, BR1.16).
    if (tab == HomeShell.historyTab && _historyOpened) {
      ref.invalidate(
        historyPagerProvider(
          ref.read(activeCellarProvider(widget.user)).cellarId,
        ),
      );
    }
    setState(() {
      _tab = tab;
      if (tab == HomeShell.historyTab) _historyOpened = true;
    });
  }

  void _openWine(String wineId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WineDetailScreen(
          user: widget.user,
          cellar: ref.read(activeCellarProvider(widget.user)),
          wineId: wineId,
        ),
      ),
    );
  }

  void _openStatus(WineStatus status) {
    ref.read(cellarFilterProvider.notifier).showOnly(StatusFilter.of(status));
    _select(HomeShell.cellarTab);
  }

  LabelTarget _target([AccessibleCellar? cellar, List<Wine>? wines]) {
    final AccessibleCellar active =
        cellar ?? ref.read(activeCellarProvider(widget.user));
    return LabelTarget(
      user: widget.user,
      cellar: active,
      cellarWines:
          wines ??
          ref.read(winesStreamProvider(active.cellarId)).value?.wines ??
          const [],
    );
  }

  /// "Aggiungi" from the Cellar and "Add your first wine" from the
  /// Dashboard: the three ways to add (u6-label-recognition BR1.1).
  void _openAdd([AccessibleCellar? cellar, List<Wine>? wines]) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AddChoiceScreen(target: _target(cellar, wines)),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _shares = ref.read(sharedImageProvider.notifier);
    _scheduleShellReport();
  }

  @override
  void didUpdateWidget(HomeShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.setup != widget.setup) _scheduleShellReport();
  }

  @override
  void dispose() {
    _shares.shellGone();
    super.dispose();
  }

  late final SharedImageNotifier _shares;
  bool _reportScheduled = false;

  /// Tells the shared image whether the cellar is ready and the permission
  /// on the active cellar, `null` while the invitations load (u6 BR1.4).
  /// After the frame: providers cannot change while the tree builds.
  void _scheduleShellReport() {
    if (_reportScheduled) return;
    _reportScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reportScheduled = false;
      if (!mounted) return;
      final memberships = ref.read(myMembershipsProvider(widget.user));
      final known = memberships.hasValue || memberships.hasError;
      _shares.updateShell(
        cellarReady: widget.setup == CellarSetup.ready,
        canEdit: known
            ? ref.read(activeCellarProvider(widget.user)).canEdit
            : null,
      );
    });
  }

  void _onShare(SharedImageEvent? event) {
    if (event == null || !mounted) return;
    final l10n = AppLocalizations.of(context);
    switch (event) {
      case SharedImageReadNow(:final multiple):
        unawaited(_readShared(multiple));
      case SharedImageNotAllowed():
        _snack(l10n.labelSharedNotAllowed);
      case SharedImageExpired():
        _snack(l10n.labelSharedExpired);
    }
  }

  void _snack(String message) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(key: const Key('label-share-snackbar'), content: Text(message)),
  );

  /// Opens the reading of a shared photo; a label screen with unsaved data
  /// asks first (BR1.4, "Chiarimenti dopo la revisione").
  Future<void> _readShared(bool multiple) async {
    if (ref.read(labelFlowProvider) == LabelFlowStatus.unsaved) {
      final read = await ReplaceLabelDialog.show(context);
      if (!mounted) return;
      if (!read) return _shares.decline();
    }
    final navigator = Navigator.of(context)..popUntil((route) => route.isFirst);
    unawaited(
      navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => LabelReadingScreen(
            target: _target(),
            input: const SharedLabelInput(),
            origin: PhotoOrigin.shared,
          ),
        ),
      ),
    );
    if (multiple) _snack(AppLocalizations.of(context).labelSharedFirstOnly);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (widget.setup == CellarSetup.ready) {
      ref.watch(cellarMaintenanceTriggerProvider(widget.user));
    }
    ref
      ..listen(sharedImageProvider, (_, next) => _onShare(next))
      ..listen(activeCellarProvider(widget.user), (_, _) {
        _scheduleShellReport();
      })
      ..listen(myMembershipsProvider(widget.user), (_, _) {
        _scheduleShellReport();
      });
    return Scaffold(
      key: const Key('home-shell'),
      body: IndexedStack(
        index: _tab,
        children: [
          DashboardScreen(
            user: widget.user,
            setup: widget.setup,
            onRetrySetup: widget.onRetrySetup,
            onOpenWine: _openWine,
            onOpenStatus: _openStatus,
            onAddFirstWine: _openAdd,
          ),
          CellarScreen(
            user: widget.user,
            setup: widget.setup,
            onRetrySetup: widget.onRetrySetup,
            onAdd: _openAdd,
          ),
          if (_historyOpened && widget.setup == CellarSetup.ready)
            HistoryScreen(user: widget.user)
          else
            const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _select,
        destinations: [
          NavigationDestination(
            key: const Key('home-nav-dashboard'),
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: l10n.dashboardTitle,
          ),
          NavigationDestination(
            key: const Key('home-nav-cellar'),
            icon: const Icon(Icons.wine_bar_outlined),
            selectedIcon: const Icon(Icons.wine_bar),
            label: l10n.cellarTitle,
          ),
          NavigationDestination(
            key: const Key('home-nav-history'),
            icon: const Icon(Icons.history_outlined),
            selectedIcon: const Icon(Icons.history),
            label: l10n.historyTitle,
          ),
        ],
      ),
    );
  }
}
