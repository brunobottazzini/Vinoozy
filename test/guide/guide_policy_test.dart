// tester-feedback FR2.2, FR2.3, FR2.6, review R-02/R-03: when the tour
// starts and when a first-visit hint shows.
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/guide/guide_policy.dart';
import 'package:vinoozy/guide/guide_providers.dart';
import 'package:vinoozy/guide/guide_state_store.dart';

void main() {
  group('shouldStartTour', () {
    test('a new user who has not seen it: the tour starts', () {
      expect(
        shouldStartTour(tourSeen: false, firstRunHadWines: false, e2e: false),
        isTrue,
      );
    });

    test('an existing user with wines at the first run: no tour (R-02)', () {
      expect(
        shouldStartTour(tourSeen: false, firstRunHadWines: true, e2e: false),
        isFalse,
      );
    });

    test('already seen, or an end-to-end build: no tour (FR2.6)', () {
      expect(
        shouldStartTour(tourSeen: true, firstRunHadWines: false, e2e: false),
        isFalse,
      );
      expect(
        shouldStartTour(tourSeen: false, firstRunHadWines: false, e2e: true),
        isFalse,
      );
    });
  });

  group('shouldShowHint', () {
    const fresh = GuideProgress(
      tourSeen: false,
      hintsSeen: {},
      firstRunRecorded: true,
    );

    test('no hint before the tour is finished or skipped (R-03)', () {
      expect(
        shouldShowHint(
          screen: GuideScreen.history,
          progress: fresh,
          e2e: false,
        ),
        isFalse,
      );
    });

    test('no hint while the tour is on screen (R-03)', () {
      expect(
        shouldShowHint(
          screen: GuideScreen.history,
          progress: fresh.copyWith(tourSeen: true, tourRunning: true),
          e2e: false,
        ),
        isFalse,
      );
    });

    test('after the tour the hint shows once per screen (FR2.3)', () {
      final after = fresh.copyWith(tourSeen: true);
      expect(
        shouldShowHint(
          screen: GuideScreen.history,
          progress: after,
          e2e: false,
        ),
        isTrue,
      );
      final closed = after.copyWith(hintsSeen: {GuideScreen.history});
      expect(
        shouldShowHint(
          screen: GuideScreen.history,
          progress: closed,
          e2e: false,
        ),
        isFalse,
      );
      expect(
        shouldShowHint(
          screen: GuideScreen.dashboard,
          progress: closed,
          e2e: false,
        ),
        isTrue,
      );
    });

    test('never in an end-to-end build (FR2.6)', () {
      expect(
        shouldShowHint(
          screen: GuideScreen.addWine,
          progress: fresh.copyWith(tourSeen: true),
          e2e: true,
        ),
        isFalse,
      );
    });
  });

  test('a step without its control on screen is skipped (R-03)', () {
    expect(
      presentSteps(GuideTourStep.values, (step) => step != GuideTourStep.menu),
      [GuideTourStep.addWine, GuideTourStep.labelPhoto, GuideTourStep.tabs],
    );
    expect(presentSteps(GuideTourStep.values, (_) => false), isEmpty);
  });
}
