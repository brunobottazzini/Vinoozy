import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../guide_policy.dart';
import '../guide_providers.dart';
import '../guide_state_store.dart';

/// A short hint at the top of the Dashboard, the History and the add form,
/// shown once per phone (tester-feedback FR2.3): only after the tour was
/// finished or skipped and never while it is on screen (review R-03), never
/// in end-to-end builds (FR2.6). One tap on "Got it" closes it for good;
/// "Show the guide again" brings it back (FR2.4).
class FirstVisitHint extends ConsumerWidget {
  const FirstVisitHint({super.key, required this.screen});

  final GuideScreen screen;

  static String textOf(AppLocalizations l10n, GuideScreen screen) =>
      switch (screen) {
        GuideScreen.dashboard => l10n.hintDashboard,
        GuideScreen.history => l10n.hintHistory,
        GuideScreen.addWine => l10n.hintAddWine,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(guideProgressProvider).value;
    final show =
        progress != null &&
        shouldShowHint(
          screen: screen,
          progress: progress,
          e2e: ref.watch(isE2EBuildProvider),
        );
    if (!show) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    return MaterialBanner(
      key: Key('hint-${screen.name}'),
      leading: const Icon(Icons.lightbulb_outline),
      content: Text(textOf(l10n, screen)),
      actions: [
        TextButton(
          key: Key('hint-${screen.name}-close'),
          onPressed: () => unawaited(
            ref.read(guideProgressProvider.notifier).markHintSeen(screen),
          ),
          child: Text(l10n.noticeGotIt),
        ),
      ],
    );
  }
}
