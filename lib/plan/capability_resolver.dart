import '../core/clock.dart';
import '../dev/dev_cheats.dart';
import 'domain/capabilities.dart';
import 'domain/entitlement.dart';

/// The time of the server as the phone estimates it: the phone clock moved
/// by the offset learnt from the last backend answer (study §7.6). Plus
/// expiries are compared with this, never with the raw phone clock.
class ServerTimeEstimate {
  ServerTimeEstimate({this._clock = const SystemClock()});

  final Clock _clock;

  /// Server time minus phone time, from the last answer that carried the
  /// server time.
  Duration offset = Duration.zero;

  DateTime now() => _clock.now().toUtc().add(offset);

  /// Learns the offset from a server time read at the phone time [at]
  /// (by default now).
  void learn(DateTime serverTime, {DateTime? at}) {
    offset = serverTime.toUtc().difference((at ?? _clock.now()).toUtc());
  }
}

/// The resolved plan with what it allows (freemium-plus FR1.2).
class ResolvedPlan {
  const ResolvedPlan(this.tier, {this.scenario});

  static const ResolvedPlan free = ResolvedPlan(PlanTier.free);

  final PlanTier tier;

  /// The developer scenario in force, when the tier comes from one (FR5.4:
  /// the indicator in the Profile and in the panel).
  final DevScenario? scenario;

  Capabilities get capabilities => Capabilities.of(tier);

  @override
  bool operator ==(Object other) =>
      other is ResolvedPlan && other.tier == tier && other.scenario == scenario;

  @override
  int get hashCode => Object.hash(tier, scenario);

  @override
  String toString() => 'ResolvedPlan($tier, ${scenario?.name})';
}

/// The single resolution of the plan used by screens, actions and guards
/// (freemium-plus FR1.2, FR1.5, FR5.3).
///
/// - A developer override (development builds only, FR5.1) wins: "Unlock
///   everything" is a test Plus, "Simulate free plan" and "Simulate expired
///   Plus" are the free plan. It never comes from a purchase.
/// - Otherwise an entitlement gives Plus only while
///   [Entitlement.isPlusValidAt] holds at the estimated server time:
///   `active` or `grace` before `expiresAt`, or a `manual_grant` without
///   expiry. Every other state, and no entitlement, is the free plan, which
///   never hides or deletes data (FR1.5, NFR4).
abstract final class CapabilityResolver {
  static ResolvedPlan resolve({
    required Entitlement? entitlement,
    required DateTime serverNow,
    DevOverride? override,
  }) {
    if (override != null) {
      final kind = override.scenario == DevScenario.unlockAll
          ? PlanKind.plus
          : PlanKind.free;
      return ResolvedPlan(
        PlanTier(kind, PlanOrigin.developerOverride),
        scenario: override.scenario,
      );
    }
    if (entitlement == null || !entitlement.isPlusValidAt(serverNow)) {
      return ResolvedPlan.free;
    }
    return ResolvedPlan(
      PlanTier(
        PlanKind.plus,
        entitlement.isManualGrant
            ? PlanOrigin.manualGrant
            : PlanOrigin.playPurchase,
      ),
    );
  }
}
