import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dev/dev_cheats.dart';
import 'capability_resolver.dart';
import 'data/entitlement_repository.dart';
import 'data/policy_repository.dart';
import 'domain/capabilities.dart';
import 'domain/entitlement.dart';
import 'domain/plan_policy.dart';

// Providers of the plan (freemium-plus FR1.1-FR1.5, FR5.3-FR5.5). Every
// service has a safe default when start-up did not inject it (the tests of
// the other units): no repository means the free plan, the safe policy (no
// ads, no limit, no purchases) and no developer override (NFR4).

/// The entitlement repository (FR1.1), created at start-up.
final entitlementRepositoryProvider = Provider<EntitlementRepository?>(
  (ref) => null,
);

/// The `config/policy` repository (FR2.4, FR3.5, FR7.1), created at
/// start-up.
final policyRepositoryProvider = Provider<PolicyRepository?>((ref) => null);

/// The developer override store (FR5.5). Created at start-up only when
/// `kDevCheatsAvailable`, so a release build never has one.
final devOverrideStoreProvider = Provider<DevOverrideStore?>((ref) => null);

/// The server time as the phone estimates it (study §7.6): the offset is
/// learnt from the backend answers.
final serverTimeProvider = Provider<ServerTimeEstimate>(
  (ref) => ServerTimeEstimate(),
);

/// The uid of the open session, set by the plan session from the account
/// gate; null while nobody is signed in. The plan listeners exist only while
/// it is set, so a local reset never finds them open (NFR4.10 of U1).
final signedInUidProvider = NotifierProvider<SignedInUid, String?>(
  SignedInUid.new,
);

class SignedInUid extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? uid) {
    if (state != uid) state = uid;
  }
}

/// The product switches: the copy on the phone (or the safe defaults) first,
/// then `config/policy` while a session is open (NFR4).
final planPolicyStreamProvider = StreamProvider<PlanPolicy>((ref) {
  final repository = ref.watch(policyRepositoryProvider);
  final uid = ref.watch(signedInUidProvider);
  if (repository == null) return Stream.value(PlanPolicy.safeDefaults);
  if (uid == null) return Stream.value(repository.current);
  return repository.watch();
});

/// The policy in force, synchronously; the safe defaults until it is known.
final planPolicyProvider = Provider<PlanPolicy>(
  (ref) => ref.watch(planPolicyStreamProvider).value ?? PlanPolicy.safeDefaults,
);

/// The entitlement of [uid] (FR1.1, FR1.4, FR4.3): null means "no Plus
/// known". A listener only for the account of the open session.
final entitlementProvider = StreamProvider.family<Entitlement?, String>((
  ref,
  uid,
) {
  final repository = ref.watch(entitlementRepositoryProvider);
  if (repository == null || ref.watch(signedInUidProvider) != uid) {
    return Stream.value(null);
  }
  return repository.watch(uid);
});

/// The developer scenario of [uid] (FR5.3-FR5.5); always null without a
/// store, that is in every build where the tools do not exist.
final devOverrideProvider =
    AsyncNotifierProvider.family<DevOverrideNotifier, DevOverride?, String>(
      DevOverrideNotifier.new,
    );

class DevOverrideNotifier extends AsyncNotifier<DevOverride?> {
  DevOverrideNotifier(this.uid);

  final String uid;

  @override
  Future<DevOverride?> build() async {
    final store = ref.watch(devOverrideStoreProvider);
    if (store == null) return null;
    return store.read(uid: uid, projectId: devCheatsProjectId);
  }

  /// One of the scenarios of the panel; saved for this account and the demo
  /// project only.
  Future<void> apply(DevScenario scenario) async {
    final store = ref.read(devOverrideStoreProvider);
    if (store == null) return;
    final override = DevOverride(scenario: scenario, uid: uid);
    await store.write(override);
    state = AsyncData(override);
  }

  /// "Restore normal state": the ordinary entitlement again.
  Future<void> restore() async {
    await ref.read(devOverrideStoreProvider)?.clear();
    state = const AsyncData(null);
  }
}

/// The plan of [uid], the single resolution every screen and action uses
/// (FR1.2).
final resolvedPlanProvider = Provider.family<ResolvedPlan, String>((ref, uid) {
  final entitlement = ref.watch(entitlementProvider(uid)).value;
  final override = ref.watch(devOverrideProvider(uid)).value;
  return CapabilityResolver.resolve(
    entitlement: entitlement,
    serverNow: ref.watch(serverTimeProvider).now(),
    override: override,
  );
});

/// What the plan of [uid] allows (FR1.2).
final capabilitiesProvider = Provider.family<Capabilities, String>(
  (ref, uid) => ref.watch(resolvedPlanProvider(uid)).capabilities,
);

/// Whether the entitlement of [uid] is known (from the server or from a
/// copy still valid): with it unknown the state is not verified and no ad is
/// ever tried (NFR4, study §7.7).
final entitlementKnownProvider = Provider.family<bool, String>(
  (ref, uid) => ref.watch(entitlementProvider(uid)).hasValue,
);
