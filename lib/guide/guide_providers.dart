import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../firebase/firebase_env.dart' show kIsE2EBuild;
import 'guide_state_store.dart';

/// tester-feedback FR2.5, FR5.3: the phone state of the guide and of the
/// review prompt, injected at start-up (lib/app/bootstrap.dart) like
/// `onboardingFlagProvider`. Without it, as in the tests of the other units,
/// tour and hints count as seen and no automatic review prompt is made.
final guideStateStoreProvider = Provider<GuideStateStore?>((ref) => null);

/// Whether this is an end-to-end build (FR2.6): tour and hints stay off.
/// A provider so the widget tests can turn it on.
final isE2EBuildProvider = Provider<bool>((ref) => kIsE2EBuild);

/// Whether the automatic review prompt may run at all (FR5.2, review R-06):
/// never in debug builds nor in end-to-end builds. The "Rate the app" button
/// is not affected.
final autoReviewEnabledProvider = Provider<bool>(
  (ref) => !kDebugMode && !ref.watch(isE2EBuildProvider),
);

/// What the guide knows on this phone, plus whether the tour is on screen.
@immutable
class GuideProgress {
  const GuideProgress({
    required this.tourSeen,
    required this.hintsSeen,
    required this.firstRunRecorded,
    this.tourRunning = false,
  });

  /// Nothing to show: no store, or an unreadable one.
  static const GuideProgress allSeen = GuideProgress(
    tourSeen: true,
    hintsSeen: {...GuideScreen.values},
    firstRunRecorded: true,
  );

  final bool tourSeen;
  final Set<GuideScreen> hintsSeen;
  final bool firstRunRecorded;

  /// The tour is on screen: no hint shows meanwhile (review R-03).
  final bool tourRunning;

  bool hintSeen(GuideScreen screen) => hintsSeen.contains(screen);

  GuideProgress copyWith({
    bool? tourSeen,
    Set<GuideScreen>? hintsSeen,
    bool? firstRunRecorded,
    bool? tourRunning,
  }) => GuideProgress(
    tourSeen: tourSeen ?? this.tourSeen,
    hintsSeen: hintsSeen ?? this.hintsSeen,
    firstRunRecorded: firstRunRecorded ?? this.firstRunRecorded,
    tourRunning: tourRunning ?? this.tourRunning,
  );
}

final guideProgressProvider =
    AsyncNotifierProvider<GuideProgressNotifier, GuideProgress>(
      GuideProgressNotifier.new,
    );

/// The guide state for the screens (FR2.2-FR2.5). Each change is applied in
/// memory first, so a refused write never shows the same step twice in one
/// session; the store keeps it across starts when it can.
class GuideProgressNotifier extends AsyncNotifier<GuideProgress> {
  GuideStateStore? get _store => ref.read(guideStateStoreProvider);

  @override
  FutureOr<GuideProgress> build() {
    final store = ref.watch(guideStateStoreProvider);
    if (store == null) return GuideProgress.allSeen;
    return _load(store);
  }

  static Future<GuideProgress> _load(GuideStateStore store) async {
    final tourSeen = await store.tourSeen();
    final hints = <GuideScreen>{
      for (final screen in GuideScreen.values)
        if (await store.hintSeen(screen)) screen,
    };
    return GuideProgress(
      tourSeen: tourSeen,
      hintsSeen: hints,
      firstRunRecorded: await store.firstRunRecorded(),
    );
  }

  GuideProgress? get _current => state.value;

  void _set(GuideProgress next) => state = AsyncData(next);

  /// R-02: the first evaluation on this phone, with whether the cellar
  /// already had wines.
  Future<void> recordFirstRun({required bool hadWines}) async {
    final current = _current;
    if (current == null || current.firstRunRecorded) return;
    _set(
      hadWines
          ? GuideProgress.allSeen
          : current.copyWith(firstRunRecorded: true),
    );
    await _store?.recordFirstRun(hadWines: hadWines);
  }

  /// The tour is shown (R-03: hints wait for its end).
  void startTour() {
    final current = _current;
    if (current == null) return;
    _set(current.copyWith(tourRunning: true));
  }

  /// "Done", "Skip" or back: the tour is not started again (FR2.2).
  Future<void> finishTour() async {
    final current = _current;
    if (current == null) return;
    _set(current.copyWith(tourSeen: true, tourRunning: false));
    await _store?.markTourSeen();
  }

  /// A hint was closed (FR2.3).
  Future<void> markHintSeen(GuideScreen screen) async {
    final current = _current;
    if (current == null) return;
    _set(current.copyWith(hintsSeen: {...current.hintsSeen, screen}));
    await _store?.markHintSeen(screen);
  }

  /// "Show the guide again" (FR2.4): tour and hints show again.
  Future<void> reset() async {
    final current = _current ?? GuideProgress.allSeen;
    _set(
      current.copyWith(
        tourSeen: false,
        hintsSeen: const {},
        firstRunRecorded: true,
        tourRunning: false,
      ),
    );
    await _store?.reset();
  }
}
