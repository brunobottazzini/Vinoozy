import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:http/http.dart' as http;

import '../account/account_gate.dart';
import '../ads/ad_slot_client.dart';
import '../ads/ads_gateway.dart';
import '../ads/ads_providers.dart';
import '../app/error_reporter.dart';
import '../cellar/data/active_wine_counter.dart';
import '../dev/dev_cheats.dart';
import '../dev/dev_entitlement_fixture.dart';
import '../dev/dev_providers.dart';
import '../firebase/firebase_env.dart';
import '../firebase/functions_config.dart';
import '../sync/ledger/key_value_store.dart';
import '../usage/cloud_usage_meter.dart';
import '../usage/functions_usage_report_client.dart';
import '../usage/usage_providers.dart';
import '../usage/usage_uploader.dart';
import 'billing/billing_client.dart';
import 'billing/billing_service.dart';
import 'billing/purchase_verifier.dart';
import 'capability_resolver.dart';
import 'data/entitlement_repository.dart';
import 'data/policy_repository.dart';
import 'plan_notices.dart';
import 'plan_providers.dart';
import 'plan_session.dart';

/// The freemium-plus services created at start-up (plan Step 15): the usage
/// meter and its uploader, the plan repositories, the active-wine counter,
/// the backend callables and, in development builds only, the developer
/// tools.
class PlanServices {
  PlanServices._({
    required this.store,
    required this.meter,
    required this.uploader,
    required this.policies,
    required this.entitlements,
    required this.counter,
    required this.serverTime,
    required this._functions,
    required this.devOverrides,
    required this.fixture,
  });

  factory PlanServices.create({
    required FirebaseEnvConfig env,
    required FirebaseFirestore db,
    required ErrorReporter reporter,
  }) {
    final store = SharedPreferencesStore();
    final meter = CloudUsageMeter(store: store, reporter: reporter);
    final policies = PolicyRepository(
      db: db,
      store: store,
      reporter: reporter,
      meter: meter,
    );
    FirebaseFunctions functions() => configuredFunctions(env);
    return PlanServices._(
      store: store,
      meter: meter,
      uploader: UsageUploader(
        meter: meter,
        client: FunctionsUsageReportClient(functions),
        store: store,
        reporter: reporter,
        budgetEuro: () => policies.current.usageBudgetEuro,
        policyVersion: () => policies.current.policyVersion,
      ),
      policies: policies,
      entitlements: EntitlementRepository(
        db: db,
        store: store,
        reporter: reporter,
        meter: meter,
      ),
      counter: ActiveWineCounter(
        db: db,
        capacityLimitEnabled: () => policies.current.capacityLimitEnabled,
        meter: meter,
      ),
      serverTime: ServerTimeEstimate(),
      functions: functions,
      // FR5.1: the developer tools exist only in development builds against
      // the demo project; `kDevCheatsAvailable` is a constant, so release
      // builds drop both.
      devOverrides: kDevCheatsAvailable
          ? DevOverrideStore(store: store, reporter: reporter)
          : null,
      fixture: kDevCheatsAvailable
          ? DevEntitlementFixture(
              client: http.Client(),
              host: env.emulatorHost,
              port: FirebaseEnvConfig.firestoreEmulatorPort,
              reporter: reporter,
            )
          : null,
    );
  }

  final KeyValueStore store;
  final CloudUsageMeter meter;
  final UsageUploader uploader;
  final PolicyRepository policies;
  final EntitlementRepository entitlements;
  final ActiveWineCounter counter;
  final ServerTimeEstimate serverTime;
  final FirebaseFunctions Function() _functions;
  final DevOverrideStore? devOverrides;
  final DevEntitlementFixture? fixture;

  /// The provider overrides of these services.
  List<Override> overrides() => [
    usageMeterProvider.overrideWithValue(meter),
    usageUploaderProvider.overrideWithValue(uploader),
    policyRepositoryProvider.overrideWithValue(policies),
    entitlementRepositoryProvider.overrideWithValue(entitlements),
    serverTimeProvider.overrideWithValue(serverTime),
    devOverrideStoreProvider.overrideWithValue(devOverrides),
    devEntitlementFixtureProvider.overrideWithValue(fixture),
    planNoticeStoreProvider.overrideWithValue(store),
    billingClientProvider.overrideWithValue(InAppPurchaseBillingClient()),
    purchaseVerifierProvider.overrideWithValue(
      FunctionsPurchaseVerifier(_functions),
    ),
    adsGatewayProvider.overrideWithValue(GoogleMobileAdsGateway()),
    adSlotClientProvider.overrideWithValue(FunctionsAdSlotClient(_functions)),
  ];

  /// Ties [session] to the account gate and to the app lifecycle, keeps the
  /// policy listened for the write paths, and moves the server time learnt
  /// by the uploader to the plan resolution. Returns what to dispose.
  List<void Function()> attach({
    required ProviderContainer container,
    required AccountGate gate,
    required PlanSession session,
  }) {
    GateState? previous;
    void onGate() {
      final next = gate.current;
      session.onGateState(previous, next);
      previous = next;
    }

    gate.state.addListener(onGate);
    onGate();
    final lifecycle = AppLifecycleListener(
      onResume: session.onAppResumed,
      onPause: () => unawaited(session.onAppPaused()),
    );
    // The policy stays current for ActiveWineCounter (FR2.5) even when no
    // screen shows it.
    final policy = container.listen(planPolicyStreamProvider, (_, _) {});
    final serverTimeSync = uploader.updates.listen(
      (_) => serverTime.offset = meter.serverOffset,
    );
    return [
      () => gate.state.removeListener(onGate),
      lifecycle.dispose,
      policy.close,
      () => unawaited(serverTimeSync.cancel()),
    ];
  }
}
