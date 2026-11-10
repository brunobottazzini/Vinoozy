// freemium-plus Step 17 (FR7.1-FR7.4, FR7.6; study §7.7): the Dashboard
// banner with a fake ad SDK and a fake slot backend. With ads off the SDK is
// never initialised; Plus removes the banner, also during the load; leaving
// the Dashboard destroys it and the same day it is not loaded again.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/ads/ad_slot_client.dart';
import 'package:vinoozy/ads/ads_providers.dart';
import 'package:vinoozy/ads/ui/dashboard_ad_slot.dart';
import 'package:vinoozy/app/providers.dart';
import 'package:vinoozy/plan/domain/capabilities.dart';
import 'package:vinoozy/plan/domain/plan_policy.dart';
import 'package:vinoozy/plan/plan_notices.dart';
import 'package:vinoozy/plan/plan_providers.dart';
import 'package:vinoozy/usage/usage_providers.dart';

import '../../account/account_harness.dart' show FakeNetworkStatus;
import '../../dashboard/fixtures.dart' show dashboardUser;
import '../../helpers/fakes.dart';
import '../../helpers/ui_harness.dart';
import '../../plan/ui/plan_ui_fakes.dart';

class _Flag extends Notifier<bool> {
  _Flag(this.initial);

  final bool initial;

  @override
  bool build() => initial;

  void set(bool value) => state = value;
}

final _adsOn = NotifierProvider<_Flag, bool>(() => _Flag(true));
final _plusOn = NotifierProvider<_Flag, bool>(() => _Flag(false));

void main() {
  late FakeAdsGateway gateway;
  late FakeAdSlotClient slots;
  late InMemoryKeyValueStore store;
  late FakeClock clock;
  late ProviderContainer container;

  setUp(() {
    gateway = FakeAdsGateway();
    slots = FakeAdSlotClient();
    store = InMemoryKeyValueStore();
    clock = FakeClock(DateTime.utc(2026, 11, 10, 12));
  });

  Future<void> pump(WidgetTester tester, {bool adsOn = true}) async {
    await pumpScreen(
      tester,
      Scaffold(
        body: Column(
          children: [
            const Expanded(child: SizedBox()),
            DashboardAdSlot(user: dashboardUser),
          ],
        ),
      ),
      overrides: [
        adsGatewayProvider.overrideWithValue(gateway),
        adSlotClientProvider.overrideWithValue(slots),
        planNoticeStoreProvider.overrideWithValue(store),
        clockProvider.overrideWithValue(clock),
        networkStatusProvider.overrideWithValue(FakeNetworkStatus()),
        errorReporterProvider.overrideWithValue(
          recordingReporter(RecordingErrorSink()),
        ),
        _adsOn.overrideWith(() => _Flag(adsOn)),
        planPolicyProvider.overrideWith(
          (ref) => ref.watch(_adsOn)
              ? const PlanPolicy(adsEnabled: true)
              : PlanPolicy.safeDefaults,
        ),
        capabilitiesProvider(dashboardUser.uid).overrideWith(
          (ref) => ref.watch(_plusOn) ? Capabilities.plus : Capabilities.free,
        ),
        entitlementKnownProvider(dashboardUser.uid).overrideWithValue(true),
        usageStatusProvider.overrideWith(
          (ref) => Stream.value(
            UsageStatus(
              periodId: '2026-11',
              nextResetUtc: DateTime.utc(2026, 12),
              verified: true,
              aboveBudget: true,
            ),
          ),
        ),
      ],
    );
    container = ProviderScope.containerOf(
      tester.element(find.byType(DashboardAdSlot)),
    );
    await tester.pumpAndSettle();
  }

  Finder banner() => find.byKey(const Key('fake-banner'));

  testWidgets('FR7.1 with adsEnabled=false the SDK is never initialised and '
      'nothing is requested', (tester) async {
    await pump(tester, adsOn: false);
    expect(gateway.calls, isEmpty);
    expect(slots.reserveCalls, 0);
    expect(banner(), findsNothing);
  });

  testWidgets('consent, slot, initialisation, one load; loaded is not an '
      'impression (FR7.2, FR7.6)', (tester) async {
    await pump(tester);
    expect(gateway.calls, ['consent', 'initialize', 'load']);
    expect(slots.reserveCalls, 1);
    expect(banner(), findsNothing, reason: 'not before onAdLoaded');

    gateway.banners.single.callbacks.onLoaded();
    await tester.pumpAndSettle();
    expect(banner(), findsOneWidget);
    expect(slots.outcomes, [AdOutcome.request, AdOutcome.loaded]);

    gateway.banners.single.callbacks
      ..onImpression()
      ..onImpression();
    await tester.pump();
    expect(
      slots.outcomes.where((o) => o == AdOutcome.impression),
      hasLength(1),
    );
  });

  testWidgets('no consent, no request', (tester) async {
    gateway.consent = false;
    await pump(tester);
    expect(gateway.calls, ['consent']);
    expect(slots.reserveCalls, 0);
  });

  testWidgets('a slot refused or not answered loads nothing', (tester) async {
    slots.answer = const AdSlotReservation(
      granted: false,
      reason: 'ALREADY_RESERVED',
    );
    await pump(tester);
    expect(gateway.calls, ['consent']);

    await tester.pumpWidget(const SizedBox());
    gateway.calls.clear();
    store.values.clear();
    slots.failWith = StateError('offline');
    await pump(tester);
    expect(gateway.calls, ['consent'], reason: 'no answer, no ad');
  });

  testWidgets('FR7.4 Plus arriving while the banner loads: never shown', (
    tester,
  ) async {
    await pump(tester);
    container.read(_plusOn.notifier).set(true);
    await tester.pump();
    gateway.banners.single.callbacks.onLoaded();
    await tester.pumpAndSettle();

    expect(banner(), findsNothing);
    expect(gateway.banners.single.disposed, isTrue);
  });

  testWidgets('FR7.4 Plus or ads turned off remove a visible banner', (
    tester,
  ) async {
    await pump(tester);
    gateway.banners.single.callbacks.onLoaded();
    await tester.pumpAndSettle();
    expect(banner(), findsOneWidget);

    container.read(_adsOn.notifier).set(false);
    await tester.pumpAndSettle();
    expect(banner(), findsNothing);
    expect(gateway.banners.single.disposed, isTrue);
  });

  testWidgets('FR7.3 leaving the Dashboard destroys the banner; back the same '
      'day nothing is loaded again', (tester) async {
    await pump(tester);
    gateway.banners.single.callbacks.onLoaded();
    await tester.pumpAndSettle();

    container.read(dashboardTabVisibleProvider.notifier).set(false);
    await tester.pumpAndSettle();
    expect(gateway.banners.single.disposed, isTrue);

    container.read(dashboardTabVisibleProvider.notifier).set(true);
    await tester.pumpAndSettle();
    expect(gateway.banners, hasLength(1));
    expect(slots.reserveCalls, 1);

    // A new start the same day: the attempt of the day is used.
    await tester.pumpWidget(const SizedBox());
    await pump(tester);
    expect(slots.reserveCalls, 1);
    expect(gateway.banners, hasLength(1));
  });

  testWidgets('a failed load uses the day: no retry', (tester) async {
    await pump(tester);
    gateway.banners.single.callbacks.onFailed();
    await tester.pumpAndSettle();
    expect(slots.outcomes, [AdOutcome.request, AdOutcome.failed]);

    container.read(dashboardTabVisibleProvider.notifier).set(false);
    await tester.pumpAndSettle();
    container.read(dashboardTabVisibleProvider.notifier).set(true);
    await tester.pumpAndSettle();
    expect(gateway.banners, hasLength(1));
  });
}
