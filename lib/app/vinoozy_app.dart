import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../account/ui/account_gate_view.dart';
import '../l10n/app_localizations.dart';
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
class SyncEventListener extends ConsumerStatefulWidget {
  const SyncEventListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SyncEventListener> createState() => _SyncEventListenerState();
}

class _SyncEventListenerState extends ConsumerState<SyncEventListener> {
  StreamSubscription<SyncEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = ref.read(syncErrorBusProvider).events.listen(_show);
  }

  void _show(SyncEvent event) {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    final message = switch (event) {
      WriteRejected(:final wineName) => l10n.writeRejected(wineName),
      WriteFailed() => l10n.saveFailed,
      // Handled by AccountGate (back to sign-in).
      SessionExpired() => null,
    };
    if (message == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(key: const Key('sync-event-snackbar'), content: Text(message)),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
