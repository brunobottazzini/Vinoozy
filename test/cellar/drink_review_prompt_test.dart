// tester-feedback FR5.2, FR5.3, NFR4, NFR6, review R-05/R-06: after a drink
// rated 4-5 stars, with the conditions met, the app asks Google Play for the
// review window once and records the date; otherwise nothing happens.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinoozy/cellar/domain/wine.dart';
import 'package:vinoozy/cellar/ui/cellar_screen.dart';
import 'package:vinoozy/guide/guide_providers.dart';
import 'package:vinoozy/guide/guide_state_store.dart';
import 'package:vinoozy/guide/review_prompter.dart';
import 'package:vinoozy/settings/app_review.dart';

import '../helpers/fakes.dart';
import '../helpers/ui_harness.dart';
import 'cellar_harness.dart';
import 'ui/cellar_ui_harness.dart';

class _MockPreferences extends Mock implements SharedPreferences {}

class _FakeReview implements AppReviewLauncher {
  int requests = 0;
  int ratingPages = 0;

  @override
  Future<void> requestReview() async => requests++;

  @override
  Future<bool> openRatingPage() async {
    ratingPages++;
    return true;
  }
}

void main() {
  late CellarUi ui;
  late _FakeReview review;
  late GuideStateStore store;

  List<Wine> winesOf(int count) => [
    for (var i = 1; i <= count; i++) cellarWine('w$i', name: 'Wine $i'),
  ];

  setUp(() {
    ui = CellarUi();
    review = _FakeReview();
    // The tour is over on this phone (it would cover the Cellar), first use
    // 8 days before the harness clock (2026-11-06 20:00), never asked.
    SharedPreferences.setMockInitialValues({
      'guide.tour.seen': true,
      'guide.firstRun.version': 1,
      'review.firstUse': DateTime(2026, 10, 29, 20).toIso8601String(),
    });
    store = GuideStateStore(SharedPreferences.getInstance);
  });

  List<Override> overrides({bool enabled = true}) => [
    ...ui.overrides,
    guideStateStoreProvider.overrideWithValue(store),
    appReviewLauncherProvider.overrideWithValue(review),
    autoReviewEnabledProvider.overrideWithValue(enabled),
  ];

  Future<void> drink(
    WidgetTester tester, {
    required int wines,
    required int? stars,
    bool enabled = true,
  }) async {
    await pumpScreen(
      tester,
      const CellarScreen(
        user: cellarOwner,
        setup: CellarSetup.ready,
        onRetrySetup: _noRetry,
      ),
      overrides: overrides(enabled: enabled),
    );
    ui
      ..emitCellar()
      ..emitWines(winesOf(wines));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('wine-tile-drink-w1')));
    await tester.pumpAndSettle();
    if (stars != null) {
      await tester.tap(find.byKey(Key('drink-confirm-star-$stars')));
      await tester.pump();
    }
    await tester.tap(find.byKey(const Key('drink-confirm')));
    await tester.pumpAndSettle();
  }

  testWidgets('5 stars with 5 wines, 8 days of use, never asked: the window '
      'is asked and the date recorded', (tester) async {
    await drink(tester, wines: 5, stars: 5);
    expect(review.requests, 1);
    expect(review.ratingPages, 0);
    expect(find.text('Bevuta segnata: Wine 1'), findsOneWidget);
    final dates = (await store.reviewDates())!;
    expect(dates.lastPrompt, ui.clock.now());
  });

  testWidgets('3 stars: no prompt', (tester) async {
    await drink(tester, wines: 5, stars: 3);
    expect(review.requests, 0);
    expect((await store.reviewDates())!.lastPrompt, isNull);
  });

  testWidgets('no rating: no prompt', (tester) async {
    await drink(tester, wines: 5, stars: null);
    expect(review.requests, 0);
  });

  testWidgets('R-05 4 wines before the drink: no prompt', (tester) async {
    await drink(tester, wines: 4, stars: 5);
    expect(review.requests, 0);
  });

  testWidgets('R-06 turned off (debug, end-to-end): no prompt', (tester) async {
    await drink(tester, wines: 5, stars: 5, enabled: false);
    expect(review.requests, 0);
  });

  testWidgets('NFR4 asked 30 days ago: no prompt', (tester) async {
    await store.markPrompted(DateTime(2026, 10, 7, 20));
    await drink(tester, wines: 5, stars: 4);
    expect(review.requests, 0);
  });

  group('maybeAskForReview', () {
    final now = DateTime(2026, 11, 6, 20);

    test('without the phone store nothing is asked', () async {
      expect(
        await maybeAskForReview(
          store: null,
          launcher: review,
          rating: 5,
          activeWineCount: 9,
          now: now,
          enabled: true,
        ),
        isFalse,
      );
      expect(review.requests, 0);
    });

    test('an unreadable store means no prompt', () async {
      final broken = GuideStateStore(
        () async => throw StateError('preferences unavailable'),
      );
      expect(
        await maybeAskForReview(
          store: broken,
          launcher: review,
          rating: 5,
          activeWineCount: 9,
          now: now,
          enabled: true,
        ),
        isFalse,
      );
      expect(review.requests, 0);
    });

    group('R-02 the date is saved before asking', () {
      late _MockPreferences preferences;
      late RecordingErrorSink sink;

      setUp(() {
        preferences = _MockPreferences();
        sink = RecordingErrorSink();
        // Readable: first use 8 days ago, never asked.
        when(() => preferences.getString(GuideStateStore.firstUseKey))
            .thenReturn(DateTime(2026, 10, 29, 20).toIso8601String());
        when(() => preferences.getString(GuideStateStore.lastPromptKey))
            .thenReturn(null);
      });

      Future<bool> askWith(SharedPreferences prefs) => maybeAskForReview(
        store: GuideStateStore(
          () async => prefs,
          reporter: recordingReporter(sink),
        ),
        launcher: review,
        rating: 5,
        activeWineCount: 9,
        now: now,
        enabled: true,
      );

      test('a refused write of the date: no request', () async {
        when(() => preferences.setString(any(), any()))
            .thenAnswer((_) async => false);
        expect(await askWith(preferences), isFalse);
        expect(review.requests, 0);
        verify(
          () => preferences.setString(
            GuideStateStore.lastPromptKey,
            now.toIso8601String(),
          ),
        ).called(1);
      });

      test('a failing write of the date: no request, and the store has '
          'reported it', () async {
        when(() => preferences.setString(any(), any()))
            .thenThrow(StateError('disk full'));
        expect(await askWith(preferences), isFalse);
        expect(review.requests, 0);
        expect(sink.reasons, ['GuideStateNotSaved']);
      });

      test('a saved date: the window is asked once', () async {
        when(() => preferences.setString(any(), any()))
            .thenAnswer((_) async => true);
        expect(await askWith(preferences), isTrue);
        expect(review.requests, 1);
        expect(sink.reasons, isEmpty);
      });
    });

    test('a second positive drink right after does not ask again', () async {
      Future<bool> ask() => maybeAskForReview(
        store: store,
        launcher: review,
        rating: 5,
        activeWineCount: 9,
        now: now,
        enabled: true,
      );
      expect(await ask(), isTrue);
      expect(await ask(), isFalse);
      expect(review.requests, 1);
    });
  });
}

Future<void> _noRetry() async {}
