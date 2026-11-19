// tester-feedback FR2.5, FR5.3: the phone state of the guide and of the
// review prompt (GuideStateStore) and its provider (GuideProgressNotifier).
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinoozy/guide/guide_providers.dart';
import 'package:vinoozy/guide/guide_state_store.dart';

import '../helpers/fakes.dart';

void main() {
  late RecordingErrorSink sink;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    sink = RecordingErrorSink();
  });

  GuideStateStore store() => GuideStateStore(
    SharedPreferences.getInstance,
    reporter: recordingReporter(sink),
  );

  GuideStateStore broken() => GuideStateStore(
    () async => throw StateError('preferences unavailable'),
    reporter: recordingReporter(sink),
  );

  group('GuideStateStore', () {
    test('a new phone has seen nothing and has no review dates', () async {
      final guide = store();
      expect(await guide.tourSeen(), isFalse);
      for (final screen in GuideScreen.values) {
        expect(await guide.hintSeen(screen), isFalse, reason: screen.name);
      }
      expect(await guide.firstRunRecorded(), isFalse);
      final dates = await guide.reviewDates();
      expect(dates, isNotNull);
      expect(dates!.firstUse, isNull);
      expect(dates.lastPrompt, isNull);
    });

    test('marks are written and read back with the documented keys', () async {
      final guide = store();
      expect(await guide.markTourSeen(), isTrue);
      expect(await guide.markHintSeen(GuideScreen.history), isTrue);
      expect(await guide.tourSeen(), isTrue);
      expect(await guide.hintSeen(GuideScreen.history), isTrue);
      expect(await guide.hintSeen(GuideScreen.dashboard), isFalse);
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getBool('guide.tour.seen'), isTrue);
      expect(preferences.getBool('guide.hint.history'), isTrue);
    });

    test('reset clears tour and hints but keeps the review dates', () async {
      final guide = store();
      final firstUse = DateTime(2026, 11, 1, 9);
      final prompted = DateTime(2026, 11, 10, 21);
      await guide.ensureFirstUse(firstUse);
      await guide.markPrompted(prompted);
      await guide.recordFirstRun(hadWines: true);
      expect(await guide.tourSeen(), isTrue);

      expect(await guide.reset(), isTrue);

      expect(await guide.tourSeen(), isFalse);
      for (final screen in GuideScreen.values) {
        expect(await guide.hintSeen(screen), isFalse, reason: screen.name);
      }
      expect(await guide.firstRunRecorded(), isTrue);
      final dates = (await guide.reviewDates())!;
      expect(dates.firstUse, firstUse);
      expect(dates.lastPrompt, prompted);
    });

    test(
      'a first run with wines counts as tour and hints seen (R-02)',
      () async {
        final guide = store();
        expect(await guide.recordFirstRun(hadWines: true), isTrue);
        expect(await guide.firstRunRecorded(), isTrue);
        expect(await guide.tourSeen(), isTrue);
        for (final screen in GuideScreen.values) {
          expect(await guide.hintSeen(screen), isTrue, reason: screen.name);
        }
      },
    );

    test('a first run without wines leaves the tour to show', () async {
      final guide = store();
      expect(await guide.recordFirstRun(hadWines: false), isTrue);
      expect(await guide.firstRunRecorded(), isTrue);
      expect(await guide.tourSeen(), isFalse);
    });

    test('ensureFirstUse is idempotent', () async {
      final guide = store();
      final first = DateTime(2026, 11, 1, 9);
      expect(await guide.ensureFirstUse(first), first);
      expect(await guide.ensureFirstUse(DateTime(2026, 12, 24)), first);
      expect((await guide.reviewDates())!.firstUse, first);
    });

    test('a malformed stored date counts as missing', () async {
      SharedPreferences.setMockInitialValues({
        'review.firstUse': 'not a date',
        'review.lastPrompt': '',
      });
      final dates = (await store().reviewDates())!;
      expect(dates.firstUse, isNull);
      expect(dates.lastPrompt, isNull);
    });

    test('an unreadable store counts as seen and as no prompt', () async {
      final guide = broken();
      expect(await guide.tourSeen(), isTrue);
      expect(await guide.hintSeen(GuideScreen.addWine), isTrue);
      expect(await guide.firstRunRecorded(), isTrue);
      expect(await guide.reviewDates(), isNull);
      expect(sink.reasons, everyElement('GuideStateUnreadable'));
      expect(sink.reasons, hasLength(4));
    });

    test('a refused write returns false and is reported', () async {
      final guide = broken();
      expect(await guide.markTourSeen(), isFalse);
      expect(await guide.markHintSeen(GuideScreen.dashboard), isFalse);
      expect(await guide.recordFirstRun(hadWines: true), isFalse);
      expect(await guide.reset(), isFalse);
      expect(await guide.markPrompted(DateTime(2026, 11, 19)), isFalse);
      expect(await guide.ensureFirstUse(DateTime(2026, 11, 19)), isNull);
      expect(sink.reasons, everyElement('GuideStateNotSaved'));
      expect(sink.reasons, hasLength(6));
    });
  });

  group('GuideProgressNotifier', () {
    ProviderContainer containerWith(GuideStateStore? guide) {
      final container = ProviderContainer(
        overrides: [guideStateStoreProvider.overrideWithValue(guide)],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('without a store everything counts as seen', () async {
      final container = containerWith(null);
      final progress = await container.read(guideProgressProvider.future);
      expect(progress.tourSeen, isTrue);
      expect(progress.hintSeen(GuideScreen.history), isTrue);
    });

    test('loads, finishes the tour and closes a hint', () async {
      final guide = store();
      final container = containerWith(guide);
      final notifier = container.read(guideProgressProvider.notifier);
      var progress = await container.read(guideProgressProvider.future);
      expect(progress.tourSeen, isFalse);
      expect(progress.firstRunRecorded, isFalse);

      await notifier.recordFirstRun(hadWines: false);
      notifier.startTour();
      expect(container.read(guideProgressProvider).value!.tourRunning, isTrue);
      await notifier.finishTour();
      await notifier.markHintSeen(GuideScreen.dashboard);

      progress = container.read(guideProgressProvider).value!;
      expect(progress.tourRunning, isFalse);
      expect(progress.tourSeen, isTrue);
      expect(progress.hintSeen(GuideScreen.dashboard), isTrue);
      expect(await guide.tourSeen(), isTrue);
      expect(await guide.hintSeen(GuideScreen.dashboard), isTrue);
    });

    test('the first run is recorded once; with wines all is seen', () async {
      final guide = store();
      final container = containerWith(guide);
      final notifier = container.read(guideProgressProvider.notifier);
      await container.read(guideProgressProvider.future);
      await notifier.recordFirstRun(hadWines: true);
      expect(container.read(guideProgressProvider).value!.tourSeen, isTrue);
      await notifier.reset();
      // Already recorded: a later evaluation changes nothing.
      await notifier.recordFirstRun(hadWines: true);
      final progress = container.read(guideProgressProvider).value!;
      expect(progress.tourSeen, isFalse);
      expect(progress.hintsSeen, isEmpty);
      expect(await guide.tourSeen(), isFalse);
    });
  });
}
