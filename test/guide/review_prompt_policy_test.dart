// tester-feedback FR5.2, FR5.2.1-FR5.2.3, NFR4, review R-05/R-06: when the
// app asks for the review window by itself.
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/guide/review_prompt_policy.dart';

void main() {
  final now = DateTime(2026, 11, 19, 21);
  final eightDaysAgo = now.subtract(const Duration(days: 8));

  bool ask({
    int? rating = 5,
    int wines = 5,
    DateTime? firstUse,
    DateTime? lastPrompt,
    bool enabled = true,
    bool noFirstUse = false,
  }) => shouldAutoPrompt(
    rating: rating,
    activeWineCount: wines,
    firstUse: noFirstUse ? null : (firstUse ?? eightDaysAgo),
    lastPrompt: lastPrompt,
    now: now,
    enabled: enabled,
  );

  test('5 wines, first use 8 days ago, never asked, 5 stars: ask', () {
    expect(ask(), isTrue);
    expect(ask(rating: 4), isTrue);
  });

  test('3 stars or no rating: no prompt', () {
    expect(ask(rating: 3), isFalse);
    expect(ask(rating: null), isFalse);
  });

  test('4 wines in the cellar: no prompt (FR5.2.1)', () {
    expect(ask(wines: 4), isFalse);
    expect(ask(wines: 0), isFalse);
  });

  test('first use 6 days ago: no prompt; exactly 7 days: ask (FR5.2.2)', () {
    expect(ask(firstUse: now.subtract(const Duration(days: 6))), isFalse);
    expect(ask(firstUse: now.subtract(const Duration(days: 7))), isTrue);
    expect(ask(noFirstUse: true), isFalse);
  });

  test('last prompt 30 days ago: no prompt; 120 days: ask (FR5.2.3)', () {
    expect(ask(lastPrompt: now.subtract(const Duration(days: 30))), isFalse);
    expect(ask(lastPrompt: now.subtract(const Duration(days: 119))), isFalse);
    expect(ask(lastPrompt: now.subtract(const Duration(days: 120))), isTrue);
  });

  test('turned off in end-to-end and debug builds (R-06)', () {
    expect(ask(enabled: false), isFalse);
  });

  test('the thresholds are the ones of the requirements', () {
    expect(reviewMinRating, 4);
    expect(reviewMinActiveWines, 5);
    expect(reviewMinDaysSinceFirstUse, 7);
    expect(reviewMinDaysBetweenPrompts, 120);
  });
}
