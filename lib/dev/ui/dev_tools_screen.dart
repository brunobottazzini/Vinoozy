import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../account/app_user.dart';
import '../../l10n/app_localizations.dart';
import '../../plan/plan_providers.dart';
import '../../plan/ui/plan_labels.dart';
import '../dev_cheats.dart';
import '../dev_providers.dart';

/// Marker of the developer panel, looked for by
/// tool/check_release_build.sh: present in a development build with
/// `ENABLE_DEV_CHEATS=true`, absent from the release artifact (FR5.7). The
/// panel is reachable only inside `if (kDevCheatsAvailable)`, so release
/// builds drop it with this string.
const String devCheatsPanelMarker = 'VINOOZY_DEV_CHEATS_PANEL';

/// "Developer tools" (freemium-plus FR5.3, FR5.4, FR5.6; study §9.2):
/// "Unlock everything — test Plus", "Simulate free plan", "Simulate expired
/// Plus" and "Restore normal state", with the indicator of the scenario in
/// force. No command opens a payment, creates a token or a receipt.
///
/// Every scenario is also written in the Firestore emulator, so the rules
/// see it (FR5.6); when the emulator does not confirm, the panel says the
/// simulation is incomplete and never shows it as done.
class DevToolsScreen extends ConsumerStatefulWidget {
  const DevToolsScreen({super.key, required this.user});

  final AppUser user;

  static Future<void> open(BuildContext context, AppUser user) => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => DevToolsScreen(user: user)));

  @override
  ConsumerState<DevToolsScreen> createState() => _DevToolsScreenState();
}

/// The emulator outcome of the last command.
enum _FixtureOutcome { applied, incomplete }

class _DevToolsScreenState extends ConsumerState<DevToolsScreen> {
  bool _busy = false;
  _FixtureOutcome? _outcome;

  Future<void> _run(DevScenario? scenario) async {
    setState(() => _busy = true);
    final notifier = ref.read(devOverrideProvider(widget.user.uid).notifier);
    if (scenario == null) {
      await notifier.restore();
    } else {
      await notifier.apply(scenario);
    }
    final fixture = ref.read(devEntitlementFixtureProvider);
    final applied =
        fixture != null && await fixture.apply(widget.user.uid, scenario);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _outcome = applied ? _FixtureOutcome.applied : _FixtureOutcome.incomplete;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final override = ref.watch(devOverrideProvider(widget.user.uid)).value;
    final plan = ref.watch(resolvedPlanProvider(widget.user.uid));
    return Scaffold(
      key: const Key(devCheatsPanelMarker),
      appBar: AppBar(title: Text(l10n.devToolsTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              override == null ? l10n.devNoOverride : planLabelOf(l10n, plan),
              key: const Key('dev-indicator'),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(l10n.devNotice),
            const SizedBox(height: 16),
            if (_busy) const LinearProgressIndicator(),
            for (final (key, label, scenario) in [
              ('dev-unlock-all', l10n.devUnlockAll, DevScenario.unlockAll),
              (
                'dev-simulate-free',
                l10n.devSimulateFree,
                DevScenario.simulateFree,
              ),
              (
                'dev-simulate-expired',
                l10n.devSimulateExpired,
                DevScenario.simulateExpired,
              ),
            ])
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: FilledButton.tonal(
                  key: Key(key),
                  onPressed: _busy ? null : () => _run(scenario),
                  child: Text(label),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: OutlinedButton(
                key: const Key('dev-restore'),
                onPressed: _busy ? null : () => _run(null),
                child: Text(l10n.devRestore),
              ),
            ),
            if (_outcome case final outcome?) ...[
              const SizedBox(height: 16),
              Semantics(
                liveRegion: true,
                child: Text(
                  outcome == _FixtureOutcome.applied
                      ? l10n.devApplied
                      : l10n.devIncomplete,
                  key: Key(
                    outcome == _FixtureOutcome.applied
                        ? 'dev-fixture-applied'
                        : 'dev-fixture-incomplete',
                  ),
                  style: outcome == _FixtureOutcome.applied
                      ? null
                      : theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
