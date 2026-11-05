import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../l10n/app_localizations.dart';
import '../sync_status.dart';

/// Banner under the app bar while changes are not yet in the cloud (BR3.2):
/// "Syncing" with network, "Offline - sync pending" without. Announced by
/// TalkBack when it appears (live region).
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key, required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(syncStatusProvider(uid));
    return SyncStateBanner(state: state);
  }
}

/// Presentation of a [SyncState]; nothing is shown when synced.
class SyncStateBanner extends StatelessWidget {
  const SyncStateBanner({super.key, required this.state});

  final SyncState state;

  @override
  Widget build(BuildContext context) {
    if (state == SyncState.synced) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final offline = state == SyncState.offline;
    final text = offline ? l10n.syncOffline : l10n.syncInProgress;
    return Semantics(
      key: const Key('offline-banner'),
      liveRegion: true,
      container: true,
      label: text,
      excludeSemantics: true,
      child: Material(
        color: scheme.inverseSurface,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                offline ? Icons.cloud_off : Icons.cloud_sync,
                color: scheme.onInverseSurface,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  key: Key(
                    offline
                        ? 'offline-banner-offline'
                        : 'offline-banner-syncing',
                  ),
                  style: TextStyle(color: scheme.onInverseSurface),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
