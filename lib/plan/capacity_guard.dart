import 'domain/capabilities.dart';
import 'domain/plan_policy.dart';

/// The answer of [CapacityGuard.check].
sealed class CapacityDecision {
  const CapacityDecision();
}

/// The write may be sent.
class CapacityAllowed extends CapacityDecision {
  const CapacityAllowed();
}

/// The write would take the cellar over its limit: it is not sent, and the
/// app explains why with "Discover Plus" (freemium-plus FR2.5).
class CapacityBlocked extends CapacityDecision {
  const CapacityBlocked({required this.limit, required this.activeWines});

  /// The effective limit of the cellar (`legacyActiveWineLimit` or 15).
  final int limit;

  /// The active wines the phone counts now.
  final int activeWines;
}

/// The check made before a write that adds an active wine (freemium-plus
/// FR2.4, FR2.5): the same rule the Firestore rules enforce, so the person
/// learns about the limit before saving and nothing is written.
///
/// Only an increase is ever blocked: a new wine or the reactivation of a
/// finished one. Reading, editing, more bottles of an active wine, drinking,
/// archiving, deleting and exporting never are. The limit applies only while
/// `config/policy.capacityLimitEnabled` is on and the cellar owner has no
/// valid Plus.
///
/// In a cellar shared with the person, the owner's plan decides and the
/// phone does not know it: the guard lets the write go and the rules decide;
/// a refusal comes back as a recoverable draft with its reason (FR2.5).
abstract final class CapacityGuard {
  static const CapacityDecision _allowed = CapacityAllowed();

  /// [activeDelta] is the change of active wines of the write (+1 for a new
  /// or reactivated wine). [activeWines] is the number of active wines the
  /// phone sees in the person's own cellar; [legacyActiveWineLimit] is the
  /// cellar's migrated limit, when present.
  static CapacityDecision check({
    required PlanPolicy policy,
    required Capabilities capabilities,
    required bool ownCellar,
    required int activeWines,
    required int activeDelta,
    int? legacyActiveWineLimit,
  }) {
    if (activeDelta <= 0) return _allowed;
    if (!policy.capacityLimitEnabled) return _allowed;
    if (!ownCellar || capabilities.unlimitedActiveWines) return _allowed;
    final limit = policy.effectiveActiveWineLimit(
      legacyActiveWineLimit: legacyActiveWineLimit,
    );
    if (activeWines + activeDelta <= limit) return _allowed;
    return CapacityBlocked(limit: limit, activeWines: activeWines);
  }
}
