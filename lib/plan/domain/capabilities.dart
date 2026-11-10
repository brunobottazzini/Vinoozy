/// The two plans of the app (freemium-plus FR1.2).
enum PlanKind { free, plus }

/// Where the resolved plan comes from (FR1.3, FR5.4): what the Profile shows
/// next to the plan name.
enum PlanOrigin {
  /// No entitlement, or one that does not give Plus: the free plan.
  standard,

  /// A Plus bought on Google Play and verified by the backend.
  playPurchase,

  /// A Plus given by the owner with the admin script ("Plus in regalo").
  manualGrant,

  /// A scenario of the developer tools, development builds only (FR5.4).
  developerOverride,
}

/// The plan in force and its origin, the single answer every screen and
/// action asks for (FR1.2).
class PlanTier {
  const PlanTier(this.kind, this.origin);

  /// The free plan with no entitlement.
  static const PlanTier free = PlanTier(PlanKind.free, PlanOrigin.standard);

  final PlanKind kind;
  final PlanOrigin origin;

  bool get isPlus => kind == PlanKind.plus;

  @override
  bool operator ==(Object other) =>
      other is PlanTier && other.kind == kind && other.origin == origin;

  @override
  int get hashCode => Object.hash(kind, origin);

  @override
  String toString() => 'PlanTier(${kind.name}, ${origin.name})';
}

/// What the plan allows (FR1.2). Derived only from the [PlanTier], so the
/// screens, the actions and the capacity guard never disagree.
class Capabilities {
  const Capabilities({
    required this.unlimitedActiveWines,
    required this.adFree,
  });

  factory Capabilities.of(PlanTier tier) => tier.isPlus ? plus : free;

  static const Capabilities free = Capabilities(
    unlimitedActiveWines: false,
    adFree: false,
  );

  static const Capabilities plus = Capabilities(
    unlimitedActiveWines: true,
    adFree: true,
  );

  /// No active-wine limit (FR2.4).
  final bool unlimitedActiveWines;

  /// Never eligible for ads (FR7.2).
  final bool adFree;

  @override
  bool operator ==(Object other) =>
      other is Capabilities &&
      other.unlimitedActiveWines == unlimitedActiveWines &&
      other.adFree == adFree;

  @override
  int get hashCode => Object.hash(unlimitedActiveWines, adFree);
}
