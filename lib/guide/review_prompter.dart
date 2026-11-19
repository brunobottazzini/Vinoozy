import '../settings/app_review.dart';
import 'guide_state_store.dart';
import 'review_prompt_policy.dart';

/// The automatic review prompt after a drink (tester-feedback FR5.2, FR5.3,
/// NFR4): reads the phone dates, applies [shouldAutoPrompt], records the
/// prompt date and asks Google Play for the window. Returns whether it
/// asked. Never throws: the store and the launcher report their own
/// failures, and a missing or unreadable store means no prompt.
Future<bool> maybeAskForReview({
  required GuideStateStore? store,
  required AppReviewLauncher launcher,
  required int? rating,
  required int activeWineCount,
  required DateTime now,
  required bool enabled,
}) async {
  // Cheap checks first: most drinks stop here without touching the store.
  if (store == null || !enabled) return false;
  if (rating == null || rating < reviewMinRating) return false;
  if (activeWineCount < reviewMinActiveWines) return false;
  final dates = await store.reviewDates();
  if (dates == null) return false;
  final ask = shouldAutoPrompt(
    rating: rating,
    activeWineCount: activeWineCount,
    firstUse: dates.firstUse,
    lastPrompt: dates.lastPrompt,
    now: now,
    enabled: enabled,
  );
  if (!ask) return false;
  // Recorded before asking: Google Play does not say whether the window
  // showed, and asking twice in a row must never happen (NFR4). A refused
  // write means no prompt: without the date the next drink could ask
  // again. The store has already reported the failure.
  if (!await store.markPrompted(now)) return false;
  await launcher.requestReview();
  return true;
}
