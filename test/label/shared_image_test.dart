import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/account/gate_state.dart';
import 'package:vinoozy/label/core/shared_image_policy.dart';
import 'package:vinoozy/label/label_providers.dart';

import 'label_harness.dart';

void main() {
  group('BR1.4 shared image policy', () {
    const policy = SharedImagePolicy();
    ShareDecision decide({
      ShareAccount account = ShareAccount.signedIn,
      bool cellarReady = true,
      bool? canEdit = true,
      bool canEditWaitOver = false,
      bool readWindowOver = false,
    }) => policy.decide(
      account: account,
      cellarReady: cellarReady,
      canEdit: canEdit,
      canEditWaitOver: canEditWaitOver,
      readWindowOver: readWindowOver,
    );

    test('BR1.4 signed in with "can edit": read', () {
      expect(decide(), ShareDecision.read);
    });

    test('BR1.4 waiting for the sign-in, even a slow one', () {
      expect(decide(account: ShareAccount.unknown), ShareDecision.wait);
      expect(
        decide(account: ShareAccount.signingIn, readWindowOver: true),
        ShareDecision.wait,
      );
    });

    test('BR1.4 a cancelled sign-in or an unavailable account drops it', () {
      expect(
        decide(account: ShareAccount.signInCancelled),
        ShareDecision.discard,
      );
      expect(decide(account: ShareAccount.unavailable), ShareDecision.discard);
    });

    test('BR1.4 read only: not allowed', () {
      expect(decide(canEdit: false), ShareDecision.notAllowed);
    });

    test('BR1.4 permission loading: wait, then not allowed after 5 s', () {
      expect(decide(canEdit: null), ShareDecision.wait);
      expect(
        decide(canEdit: null, canEditWaitOver: true),
        ShareDecision.notAllowed,
      );
    });

    test('BR1.4 cellar never ready: wait, then expired after 60 s', () {
      expect(decide(cellarReady: false), ShareDecision.wait);
      expect(
        decide(cellarReady: false, readWindowOver: true),
        ShareDecision.expired,
      );
      expect(
        decide(canEdit: null, readWindowOver: true),
        ShareDecision.expired,
      );
    });
  });

  group('BR1.4 shared image notifier', () {
    late LabelEnv env;
    late ProviderContainer container;
    late List<SharedImageEvent?> events;
    var disposed = true;

    /// Disposing cancels the 5 s and 60 s timers of a share still waiting.
    void disposeContainer() {
      if (disposed) return;
      disposed = true;
      container.dispose();
    }

    tearDown(disposeContainer);

    void setUpEnv({
      GateState? gate,
      bool pending = false,
      bool multiple = false,
    }) {
      env = LabelEnv();
      if (gate != null) env.gate.value = gate;
      if (pending) env.channel.arrive(multiple: multiple);
      container = ProviderContainer(overrides: env.overrides);
      disposed = false;
      events = [];
      container.listen<SharedImageEvent?>(
        sharedImageProvider,
        (_, next) => events.add(next),
      );
      // What AppBootstrap does at start-up.
      final notifier = container.read(sharedImageProvider.notifier)
        ..attachGate(env.gate);
      unawaited(notifier.checkColdStart());
    }

    SharedImageNotifier notifier() =>
        container.read(sharedImageProvider.notifier);

    testWidgets('BR1.4 a cold-start share is read once the shell is ready '
        'with "can edit"', (tester) async {
      setUpEnv(pending: true, multiple: true);
      await tester.pump();
      expect(events, isEmpty, reason: 'no shell yet');
      notifier().updateShell(cellarReady: true, canEdit: true);
      final event = events.single as SharedImageReadNow;
      expect(event.multiple, isTrue);
      expect(env.channel.discardCalls, 0);
    });

    testWidgets('BR1.4 a slow sign-in does not expire the photo', (
      tester,
    ) async {
      setUpEnv(gate: const GateSignIn(), pending: true);
      await tester.pump();
      env.gate.value = const GateSignIn(busy: true);
      await tester.pump(const Duration(minutes: 3));
      expect(events, isEmpty);
      env.gate.value = const GateCellar(labelUser);
      notifier().updateShell(cellarReady: true, canEdit: true);
      expect(events.single, isA<SharedImageReadNow>());
    });

    testWidgets('BR1.4 a cancelled sign-in drops the photo at once', (
      tester,
    ) async {
      setUpEnv(gate: const GateSignIn(), pending: true);
      await tester.pump();
      env.gate.value = const GateSignIn(busy: true);
      env.gate.value = const GateSignIn();
      await tester.pump();
      expect(env.channel.discardCalls, 1);
      expect(events, isEmpty, reason: 'ignored without a message');
    });

    testWidgets('BR1.4 a blocked account drops the photo', (tester) async {
      setUpEnv(gate: const GateStarting(), pending: true);
      await tester.pump();
      env.gate.value = const GateResetting();
      expect(env.channel.discardCalls, 1);
    });

    testWidgets(
      'BR1.4 read only: "Non puoi aggiungere vini a questa cantina"',
      (tester) async {
        setUpEnv(pending: true);
        await tester.pump();
        notifier().updateShell(cellarReady: true, canEdit: false);
        expect(events.single, isA<SharedImageNotAllowed>());
        await tester.pump();
        expect(env.channel.discardCalls, 1);
      },
    );

    testWidgets('BR1.4 permission still loading after 5 s counts as absent', (
      tester,
    ) async {
      setUpEnv(pending: true);
      await tester.pump();
      notifier().updateShell(cellarReady: true, canEdit: null);
      await tester.pump(const Duration(seconds: 4));
      expect(events, isEmpty);
      await tester.pump(const Duration(seconds: 1));
      expect(events.single, isA<SharedImageNotAllowed>());
    });

    testWidgets('BR1.4 a cellar not ready 60 s after the sign-in: expired', (
      tester,
    ) async {
      setUpEnv(pending: true);
      await tester.pump();
      notifier().updateShell(cellarReady: false, canEdit: null);
      await tester.pump(const Duration(seconds: 59));
      expect(events, isEmpty);
      await tester.pump(const Duration(seconds: 1));
      expect(events.single, isA<SharedImageExpired>());
      expect(env.channel.discardCalls, 1);
    });

    testWidgets('BR1.4 a share while the app runs is read; "Continua con '
        'quello aperto" drops it', (tester) async {
      setUpEnv();
      await tester.pump();
      notifier().updateShell(cellarReady: true, canEdit: true);
      expect(events, isEmpty);
      env.channel.arrive();
      await tester.pump();
      expect(events.single, isA<SharedImageReadNow>());
      await notifier().decline();
      expect(env.channel.discardCalls, 1);
      notifier().shellGone();
      env.channel.arrive();
      await tester.pump();
      expect(events, hasLength(1), reason: 'waits for the shell again');
      disposeContainer();
    });
  });

  group('BR1.4 shared image without the bootstrap wiring', () {
    testWidgets('BR1.4 the shell alone means signed in', (tester) async {
      final env = LabelEnv();
      final container = ProviderContainer(overrides: env.overrides);
      final events = <SharedImageEvent?>[];
      container.listen<SharedImageEvent?>(
        sharedImageProvider,
        (_, next) => events.add(next),
      );
      env.channel.arrive();
      await tester.pump();
      container
          .read(sharedImageProvider.notifier)
          .updateShell(cellarReady: true, canEdit: true);
      expect(events.single, isA<SharedImageReadNow>());
      container.dispose();
    });

    test('BR1.14 a failing cold-start check is a pick failure', () async {
      final env = LabelEnv();
      env.channel.pendingError = StateError(labelMarkers.first);
      final container = ProviderContainer(overrides: env.overrides);
      addTearDown(container.dispose);
      await container.read(sharedImageProvider.notifier).checkColdStart();
      expect(env.reasons, [pickFailed]);
      expect(env.reportsAreClean, isTrue);
    });
  });

  group('BR1.4 label flow status', () {
    test('BR1.4 only the owner clears the status of an open label screen', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final flow = container.read(labelFlowProvider.notifier);
      final oldScreen = Object();
      final newScreen = Object();
      flow.set(oldScreen, LabelFlowStatus.reading);
      flow.set(newScreen, LabelFlowStatus.unsaved);
      flow.release(oldScreen);
      expect(container.read(labelFlowProvider), LabelFlowStatus.unsaved);
      flow.release(newScreen);
      expect(container.read(labelFlowProvider), LabelFlowStatus.none);
    });
  });
}
