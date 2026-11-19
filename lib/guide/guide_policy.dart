import 'guide_providers.dart';
import 'guide_state_store.dart';

/// The rules of the guided tour and of the first-visit hints
/// (tester-feedback FR2.2, FR2.3, FR2.6; review R-02, R-03). Pure functions,
/// so the screens only ask and the tests cover every case.

/// The steps of the tour, in order (FR2.2). The label photo lives behind
/// "Add" (the choice screen), so [labelPhoto] points at the same button
/// with its own text. A step whose control is not on screen is skipped.
enum GuideTourStep { addWine, labelPhoto, tabs, menu }

/// Whether the tour starts on the Cellar.
///
/// [firstRunHadWines] is true only on the first evaluation on this phone,
/// when the cellar already had wines: an existing user, for whom the tour
/// counts as seen (R-02). End-to-end builds never start it (FR2.6).
bool shouldStartTour({
  required bool tourSeen,
  required bool firstRunHadWines,
  required bool e2e,
}) => !e2e && !tourSeen && !firstRunHadWines;

/// Whether the hint of [screen] shows: once, only after the tour was
/// finished or skipped and never while it is on screen (R-03), never in
/// end-to-end builds (FR2.6).
bool shouldShowHint({
  required GuideScreen screen,
  required GuideProgress progress,
  required bool e2e,
}) =>
    !e2e &&
    progress.tourSeen &&
    !progress.tourRunning &&
    !progress.hintSeen(screen);

/// The steps of [steps] whose control is on screen, in order (R-03).
List<GuideTourStep> presentSteps(
  Iterable<GuideTourStep> steps,
  bool Function(GuideTourStep step) hasTarget,
) => [
  for (final step in steps)
    if (hasTarget(step)) step,
];
