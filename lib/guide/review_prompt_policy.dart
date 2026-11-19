/// When Vinoozy asks Google Play for the review window by itself
/// (tester-feedback FR5.2, NFR4): right after a drink rated 4 or 5 stars,
/// only with an established cellar, after a first week of use and at most
/// once every 120 days.
///
/// Wine-domain reasoning behind the thresholds (project rule: decided here,
/// open to correction by the owner):
/// - 4-5 stars: the person has just enjoyed a bottle, the happiest moment
///   the app sees; a 3-star bottle is a neutral evening, not a moment to ask.
/// - 5 active wines: below that the cellar is a trial, the person has not
///   yet seen the drinking windows at work, which is the app's real value.
/// - 7 days: a week covers at least one weekend, when most bottles are
///   opened, so the person has used the app in a real evening.
/// - 120 days: about a season of drinking; Google Play itself throttles the
///   window, so asking more often would only waste the moment.
library;

/// The lowest rating that counts as a positive moment (FR5.2).
const int reviewMinRating = 4;

/// The active wines needed in the cellar before the drink (FR5.2.1, R-05).
const int reviewMinActiveWines = 5;

/// Days since the first use on this phone (FR5.2.2).
const int reviewMinDaysSinceFirstUse = 7;

/// Days since the last automatic prompt (FR5.2.3, NFR4).
const int reviewMinDaysBetweenPrompts = 120;

/// Whether to ask for the review window after a drink.
///
/// [rating] is the stars given in the drink confirmation (null: none);
/// [activeWineCount] the wines of the active cellar before the drink,
/// archived ones excluded (R-05); [firstUse] null means the phone state is
/// unknown, so nothing is asked; [lastPrompt] null means never asked.
/// [enabled] is false in debug and end-to-end builds (R-06).
bool shouldAutoPrompt({
  required int? rating,
  required int activeWineCount,
  required DateTime? firstUse,
  required DateTime? lastPrompt,
  required DateTime now,
  required bool enabled,
}) {
  if (!enabled) return false;
  if (rating == null || rating < reviewMinRating) return false;
  if (activeWineCount < reviewMinActiveWines) return false;
  if (firstUse == null) return false;
  if (now.difference(firstUse) <
      const Duration(days: reviewMinDaysSinceFirstUse)) {
    return false;
  }
  if (lastPrompt == null) return true;
  return now.difference(lastPrompt) >=
      const Duration(days: reviewMinDaysBetweenPrompts);
}
