// freemium-plus FR5.1, FR5.2, FR5.5: when the developer tools exist, the
// override per account and demo project, and the owner's hidden sequence.
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/dev/dev_cheats.dart';

import '../helpers/fakes.dart';

void main() {
  group('FR5.1 availability', () {
    test('only with all four conditions', () {
      bool available({
        bool releaseMode = false,
        bool flag = true,
        bool usesEmulators = true,
        String projectId = 'demo-vinoozy',
      }) => devCheatsAvailableFor(
        releaseMode: releaseMode,
        flag: flag,
        usesEmulators: usesEmulators,
        projectId: projectId,
      );

      expect(available(), isTrue);
      expect(available(releaseMode: true), isFalse);
      expect(available(flag: false), isFalse);
      expect(available(usesEmulators: false), isFalse);
      expect(available(projectId: 'vinoozy-d6f45'), isFalse);
    });

    test('the constant of this build follows the same rule', () {
      // Tests run without ENABLE_DEV_CHEATS: no tools.
      expect(kEnableDevCheatsFlag, isFalse);
      expect(
        kDevCheatsAvailable,
        devCheatsAvailableFor(
          releaseMode: kReleaseMode,
          flag: kEnableDevCheatsFlag,
          usesEmulators: true,
          projectId: devCheatsProjectId,
        ),
      );
      expect(kDevCheatsAvailable, isFalse);
    });
  });

  group('FR5.5 the override per account and demo project', () {
    late InMemoryKeyValueStore store;
    late RecordingErrorSink sink;
    late DevOverrideStore overrides;

    setUp(() {
      store = InMemoryKeyValueStore();
      sink = RecordingErrorSink();
      overrides = DevOverrideStore(
        store: store,
        reporter: recordingReporter(sink),
      );
    });

    const unlock = DevOverride(scenario: DevScenario.unlockAll, uid: 'user-a');

    test('survives a restart with the same account', () async {
      await overrides.write(unlock);

      final restarted = DevOverrideStore(
        store: store,
        reporter: recordingReporter(sink),
      );
      expect(
        await restarted.read(uid: 'user-a', projectId: 'demo-vinoozy'),
        unlock,
      );
    });

    test('another account does not get it, and it is removed', () async {
      await overrides.write(unlock);

      expect(
        await overrides.read(uid: 'user-b', projectId: 'demo-vinoozy'),
        isNull,
      );
      expect(
        await overrides.read(uid: 'user-a', projectId: 'demo-vinoozy'),
        isNull,
      );
    });

    test('never for the real project', () async {
      await overrides.write(unlock);

      expect(
        await overrides.read(uid: 'user-a', projectId: 'vinoozy-d6f45'),
        isNull,
      );
      expect(
        () => overrides.write(
          const DevOverride(
            scenario: DevScenario.unlockAll,
            uid: 'user-a',
            projectId: 'vinoozy-d6f45',
          ),
        ),
        throwsArgumentError,
      );
    });

    test('"Restore normal state" clears it', () async {
      await overrides.write(unlock);
      await overrides.clear();

      expect(
        await overrides.read(uid: 'user-a', projectId: 'demo-vinoozy'),
        isNull,
      );
    });

    test('a damaged value reads as no override', () async {
      store.values[DevOverrideStore.storageKey] = '{"scenario": "x"}';
      expect(
        await overrides.read(uid: 'user-a', projectId: 'demo-vinoozy'),
        isNull,
      );
      store.values[DevOverrideStore.storageKey] = 'not json';
      expect(
        await overrides.read(uid: 'user-a', projectId: 'demo-vinoozy'),
        isNull,
      );
    });
  });

  group('FR5.2 the hidden sequence', () {
    late FakeClock clock;
    late SecretSequenceDetector detector;

    setUp(() {
      clock = FakeClock(DateTime.utc(2026, 11, 10, 12));
      detector = SecretSequenceDetector(clock: clock);
    });

    /// Registers [steps] one second apart; true when one of them opened.
    bool play(
      List<DevGestureStep> steps, {
      Duration gap = const Duration(seconds: 1),
    }) {
      var opened = false;
      for (final step in steps) {
        opened = detector.register(step) || opened;
        clock.current = clock.current.add(gap);
      }
      return opened;
    }

    test('the complete sequence within 20 s opens the panel', () {
      expect(play(SecretSequenceDetector.sequence), isTrue);
      expect(detector.progress, 0, reason: 'ready for the next time');
    });

    test('a wrong step opens nothing and starts again', () {
      final wrong = [...SecretSequenceDetector.sequence]
        ..[6] = DevGestureStep.dashboard;
      expect(play(wrong), isFalse);
      expect(detector.progress, 0);
    });

    test('an incomplete sequence opens nothing', () {
      expect(play(SecretSequenceDetector.sequence.sublist(0, 10)), isFalse);
    });

    test('over 20 s from the first tap opens nothing', () {
      expect(
        play(
          SecretSequenceDetector.sequence,
          gap: const Duration(milliseconds: 2100),
        ),
        isFalse,
      );
    });

    test('a logo tap after a wrong step starts a new attempt', () {
      play([DevGestureStep.logo, DevGestureStep.history]);
      expect(play(SecretSequenceDetector.sequence), isTrue);
      // A third logo tap restarts from that tap.
      play([DevGestureStep.logo, DevGestureStep.logo, DevGestureStep.logo]);
      expect(detector.progress, 1);
    });

    test('leaving the app resets it', () {
      play(SecretSequenceDetector.sequence.sublist(0, 6));
      detector.reset();
      expect(play(SecretSequenceDetector.sequence.sublist(6)), isFalse);
    });
  });
}
