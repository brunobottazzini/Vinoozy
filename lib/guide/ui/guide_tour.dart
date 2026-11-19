import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show Ticker;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../cellar/data/wine_repository.dart' show WinesSnapshot;
import '../../l10n/app_localizations.dart';
import '../guide_policy.dart';
import '../guide_providers.dart';

/// The controls the tour points at (tester-feedback FR2.2): the screens
/// wrap them in a [KeyedSubtree] with these keys. One set per app.
class GuideTargets {
  final GlobalKey addButton = GlobalKey(debugLabel: 'guide-target-add');
  final GlobalKey tabs = GlobalKey(debugLabel: 'guide-target-tabs');
  final GlobalKey menu = GlobalKey(debugLabel: 'guide-target-menu');

  /// The key of [step]; the label photo lives behind "Add".
  GlobalKey keyOf(GuideTourStep step) => switch (step) {
    GuideTourStep.addWine || GuideTourStep.labelPhoto => addButton,
    GuideTourStep.tabs => tabs,
    GuideTourStep.menu => menu,
  };

  /// Where the control of [step] is on screen, or null when it is not laid
  /// out (then the step is skipped, review R-03).
  Rect? rectOf(GuideTourStep step) {
    final object = keyOf(step).currentContext?.findRenderObject();
    if (object is! RenderBox || !object.attached || !object.hasSize) {
      return null;
    }
    if (object.size.isEmpty) return null;
    return object.localToGlobal(Offset.zero) & object.size;
  }
}

final guideTargetsProvider = Provider<GuideTargets>((ref) => GuideTargets());

/// Starts the tour on the Cellar (FR2.2, R-02, R-03, FR2.6), placed in the
/// Cellar screen. [active] is true when the Cellar tab is the one shown and
/// the cellar is ready; [snapshot] is the wines list already loaded (no new
/// Firestore read, NFR6).
///
/// The first time on this phone it records whether the cellar already had
/// wines (an existing user: tour and hints count as seen). An empty list
/// read only from the cache waits for the server before deciding.
class GuideTourStarter extends ConsumerStatefulWidget {
  const GuideTourStarter({
    super.key,
    required this.active,
    required this.snapshot,
  });

  final bool active;
  final WinesSnapshot? snapshot;

  @override
  ConsumerState<GuideTourStarter> createState() => _GuideTourStarterState();
}

class _GuideTourStarterState extends ConsumerState<GuideTourStarter> {
  bool _scheduled = false;
  bool _showing = false;

  void _schedule() {
    if (_scheduled || _showing) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      unawaited(_maybeStart());
    });
  }

  Future<void> _maybeStart() async {
    if (!mounted || _showing || !widget.active) return;
    final snapshot = widget.snapshot;
    final progress = ref.read(guideProgressProvider).value;
    if (snapshot == null || progress == null || progress.tourRunning) return;
    final notifier = ref.read(guideProgressProvider.notifier);
    var firstRunHadWines = false;
    if (!progress.firstRunRecorded) {
      if (snapshot.wines.isEmpty && snapshot.meta.isFromCache) return;
      firstRunHadWines = snapshot.wines.isNotEmpty;
      await notifier.recordFirstRun(hadWines: firstRunHadWines);
    }
    final start = shouldStartTour(
      tourSeen: progress.tourSeen,
      firstRunHadWines: firstRunHadWines,
      e2e: ref.read(isE2EBuildProvider),
    );
    if (!start || !mounted) return;
    final targets = ref.read(guideTargetsProvider);
    final steps = presentSteps(
      GuideTourStep.values,
      (step) => targets.rectOf(step) != null,
    );
    if (steps.isEmpty) return;
    _showing = true;
    notifier.startTour();
    try {
      await GuideTour.show(context, steps: steps, targets: targets);
    } finally {
      _showing = false;
      await notifier.finishTour();
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(guideProgressProvider).value;
    final waiting =
        progress != null &&
        !progress.tourRunning &&
        (!progress.tourSeen || !progress.firstRunRecorded);
    if (widget.active && widget.snapshot != null && waiting) _schedule();
    return const SizedBox.shrink();
  }
}

/// The guided tour (FR2.2, NFR5): a transparent route that dims the screen,
/// cuts out the control of the step and shows a card with title, text,
/// "Skip" and "Next" ("Done" on the last step). Being a route, the system
/// Back closes it like "Skip". The caller records the end.
abstract final class GuideTour {
  static Future<void> show(
    BuildContext context, {
    required List<GuideTourStep> steps,
    required GuideTargets targets,
  }) => Navigator.of(context).push(
    PageRouteBuilder<void>(
      opaque: false,
      barrierDismissible: false,
      pageBuilder: (_, _, _) => _GuideTourView(steps: steps, targets: targets),
      transitionsBuilder: (_, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  );
}

class _GuideTourView extends StatefulWidget {
  const _GuideTourView({required this.steps, required this.targets});

  final List<GuideTourStep> steps;
  final GuideTargets targets;

  @override
  State<_GuideTourView> createState() => _GuideTourViewState();
}

class _GuideTourViewState extends State<_GuideTourView>
    with SingleTickerProviderStateMixin {
  /// How long the control must stay still before the tour stops following
  /// it. Following stops so that a settled tour schedules no frames (no
  /// battery drain, and widget tests can settle).
  static const Duration _stillFor = Duration(seconds: 1);

  int _index = 0;

  /// Where the control of the current step was on the last frame.
  Rect? _target;

  /// The ticker elapsed time at the last change of [_target].
  Duration _lastMove = Duration.zero;

  late final Ticker _ticker;

  bool get _last => _index == widget.steps.length - 1;

  Rect? _currentRect() => widget.targets.rectOf(widget.steps[_index]);

  @override
  void initState() {
    super.initState();
    _target = _currentRect();
    _ticker = createTicker(_onTick);
    _follow();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // A new screen size (rotation, split screen) can move the control.
    _follow();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  /// Starts (or restarts) re-reading the control's place every frame, so
  /// the hole follows a control that is still animating into place, like
  /// the extended "Add" button right after a tab change (FR2.1).
  void _follow() {
    _lastMove = Duration.zero;
    _ticker
      ..stop()
      ..start();
  }

  void _onTick(Duration elapsed) {
    final rect = _currentRect();
    if (rect != _target) {
      _lastMove = elapsed;
      setState(() => _target = rect);
    } else if (elapsed - _lastMove >= _stillFor) {
      _ticker.stop();
    }
  }

  void _next() {
    if (_last) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _index++;
        _target = _currentRect();
      });
      _follow();
    }
  }

  (String, String) _texts(AppLocalizations l10n, GuideTourStep step) =>
      switch (step) {
        GuideTourStep.addWine => (l10n.guideAddTitle, l10n.guideAddBody),
        GuideTourStep.labelPhoto => (l10n.guideLabelTitle, l10n.guideLabelBody),
        GuideTourStep.tabs => (l10n.guideTabsTitle, l10n.guideTabsBody),
        GuideTourStep.menu => (l10n.guideMenuTitle, l10n.guideMenuBody),
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final step = widget.steps[_index];
    final hole = _target?.inflate(8);
    final (title, body) = _texts(l10n, step);
    final size = MediaQuery.sizeOf(context);
    // The card goes on the side of the screen with more room: below a
    // control in the top half, above one in the bottom half.
    final double? cardTop;
    final double? cardBottom;
    if (hole != null && hole.center.dy >= size.height / 2) {
      cardTop = null;
      cardBottom = size.height - hole.top + 16;
    } else {
      cardTop = (hole?.bottom ?? size.height / 3) + 16;
      cardBottom = null;
    }
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: ExcludeSemantics(
              child: CustomPaint(
                key: const Key('tour-scrim'),
                painter: _ScrimPainter(
                  hole: hole,
                  color: Theme.of(context).colorScheme.scrim
                      .withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            top: cardTop,
            bottom: cardBottom,
            child: SafeArea(
              child: _StepCard(
                key: Key('tour-step-${step.name}'),
                title: title,
                body: body,
                counter: l10n.guideStepOf(_index + 1, widget.steps.length),
                skip: _last ? null : l10n.onboardingSkip,
                next: _last ? l10n.guideDone : l10n.onboardingNext,
                last: _last,
                onSkip: () => Navigator.of(context).pop(),
                onNext: _next,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    super.key,
    required this.title,
    required this.body,
    required this.counter,
    required this.skip,
    required this.next,
    required this.last,
    required this.onSkip,
    required this.onNext,
  });

  final String title;
  final String body;
  final String counter;
  final String? skip;
  final String next;
  final bool last;
  final VoidCallback onSkip;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(counter, style: theme.textTheme.labelMedium),
            const SizedBox(height: 4),
            Semantics(
              header: true,
              child: Text(title, style: theme.textTheme.titleMedium),
            ),
            const SizedBox(height: 8),
            Text(body, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              children: [
                if (skip != null)
                  TextButton(
                    key: const Key('tour-skip'),
                    onPressed: onSkip,
                    child: Text(skip!),
                  ),
                FilledButton(
                  key: Key(last ? 'tour-done' : 'tour-next'),
                  onPressed: onNext,
                  child: Text(next),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The dimmed screen with a rounded hole around the control of the step.
class _ScrimPainter extends CustomPainter {
  const _ScrimPainter({required this.hole, required this.color});

  final Rect? hole;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final screen = Path()..addRect(Offset.zero & size);
    final cut = hole;
    final path = cut == null
        ? screen
        : Path.combine(
            PathOperation.difference,
            screen,
            Path()..addRRect(
              RRect.fromRectAndRadius(cut, const Radius.circular(16)),
            ),
          );
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_ScrimPainter oldDelegate) =>
      oldDelegate.hole != hole || oldDelegate.color != color;
}
