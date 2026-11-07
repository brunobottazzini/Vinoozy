import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../account/ui/account_gate_view.dart';
import '../e2e/e2e_locale.dart';
import '../l10n/app_localizations.dart';
import '../sharing/sharing_providers.dart';
import '../sharing/ui/shared_cellar_notice.dart';
import '../sync/sync_error_bus.dart';
import 'locale_resolution.dart';
import 'providers.dart';
import 'theme.dart';

/// Root widget: theme and language follow the phone (BR5.1, BR5.2), and the
/// sync error listener sits at the root so its messages appear on any screen,
/// also after the form has closed (NFR6.2).
class VinoozyApp extends StatelessWidget {
  const VinoozyApp({super.key, this.home = const AccountGateView()});

  final Widget home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      // Null except in E2E builds, which are always in Italian (review R-01
      // of u8-account); otherwise the phone's languages decide (BR5.1).
      locale: appLocaleOverride,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: appLocales,
      localeListResolutionCallback: (preferred, _) =>
          resolveAppLocale(preferred),
      home: SyncEventListener(child: home),
    );
  }
}

/// Shows a message for every [SyncEvent] of the bus: "Change not allowed:
/// name" for a rejection, "Could not save, try again" for other failures.
///
/// Since u7-sharing it also shows the sharing notices (security-design.md
/// §4): "You no longer have access to the cellar of Mario" once per cellar
/// and session for a [CellarAccessLost] (the queued-writes variant once
/// more), and "Mario shared their cellar with you" after an activation.
class SyncEventListener extends ConsumerStatefulWidget {
  const SyncEventListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SyncEventListener> createState() => _SyncEventListenerState();
}

class _SyncEventListenerState extends ConsumerState<SyncEventListener> {
  StreamSubscription<SyncEvent>? _subscription;
  StreamSubscription<CellarShared>? _sharedSubscription;

  @override
  void initState() {
    super.initState();
    _subscription = ref.read(syncErrorBusProvider).events.listen(_show);
    _sharedSubscription = ref
        .read(sharingNoticesProvider)
        .events
        .listen(_showShared);
  }

  void _showShared(CellarShared event) {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    SharedCellarNotice.show(context, l10n.sharingSharedNotice(event.ownerName));
  }

  void _showAccessLost(CellarAccessLost event) {
    final shown = ref.read(shownAccessNoticesProvider);
    if (!shown.add('${event.cellarId}/${event.fromQueuedWrite}')) return;
    final l10n = AppLocalizations.of(context);
    final owner =
        event.ownerName ??
        ref.read(knownCellarOwnersProvider)[event.cellarId] ??
        l10n.sharingSomeone;
    SharedCellarNotice.show(
      context,
      event.fromQueuedWrite
          ? l10n.sharingWritesLost(owner)
          : l10n.sharingAccessLost(owner),
    );
  }

  void _show(SyncEvent event) {
    if (!mounted) return;
    if (event is CellarAccessLost) return _showAccessLost(event);
    final l10n = AppLocalizations.of(context);
    final message = switch (event) {
      WriteRejected(:final wineName) => l10n.writeRejected(wineName),
      WriteFailed() => l10n.saveFailed,
      // Handled by AccountGate (back to sign-in).
      SessionExpired() => null,
      // Shown above by _showAccessLost.
      CellarAccessLost() => null,
      CellarNotice(kind: CellarNoticeKind.undoRejected) =>
        l10n.cellarUndoRejected,
      CellarNotice(kind: CellarNoticeKind.deleteFailed) =>
        l10n.cellarDeleteFailed,
    };
    if (message == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(key: const Key('sync-event-snackbar'), content: Text(message)),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _sharedSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
