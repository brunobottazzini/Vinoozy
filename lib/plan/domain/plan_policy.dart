import '../../cellar/domain/firestore_values.dart';

/// Field names of `config/policy` (freemium-plus FR2.4, FR3.5, FR6.2, FR7.1).
/// Every signed-in client reads it; only the owner's admin script writes it.
abstract final class PlanPolicyFields {
  static const String adsEnabled = 'adsEnabled';
  static const String capacityLimitEnabled = 'capacityLimitEnabled';
  static const String purchasesEnabled = 'purchasesEnabled';
  static const String policyVersion = 'policyVersion';
  static const String usageBudgetEuro = 'usageBudgetEuro';
  static const String freeActiveWineLimit = 'freeActiveWineLimit';
}

/// Product switches and thresholds of the free plan, from `config/policy`.
///
/// Every default is the safe one (study §7.1, NFR4): no ads, no capacity
/// limit, no purchases. A missing or unreadable policy therefore never shows
/// ads, never blocks a write and never opens a payment flow.
class PlanPolicy {
  const PlanPolicy({
    this.adsEnabled = false,
    this.capacityLimitEnabled = false,
    this.purchasesEnabled = false,
    this.policyVersion = defaultPolicyVersion,
    this.usageBudgetEuro = defaultUsageBudgetEuro,
    this.freeActiveWineLimit = defaultFreeActiveWineLimit,
  });

  /// Reads [data] leniently: a missing or mistyped field keeps its safe
  /// default; a budget that is not a plain non-negative decimal string and a
  /// limit below 1 are refused the same way.
  factory PlanPolicy.fromMap(Map<String, Object?> data) => PlanPolicy(
    adsEnabled:
        FirestoreValues.boolean(data[PlanPolicyFields.adsEnabled]) ?? false,
    capacityLimitEnabled:
        FirestoreValues.boolean(data[PlanPolicyFields.capacityLimitEnabled]) ??
        false,
    purchasesEnabled:
        FirestoreValues.boolean(data[PlanPolicyFields.purchasesEnabled]) ??
        false,
    policyVersion:
        FirestoreValues.string(data[PlanPolicyFields.policyVersion]) ??
        defaultPolicyVersion,
    usageBudgetEuro: _budget(data[PlanPolicyFields.usageBudgetEuro]),
    freeActiveWineLimit: _limit(data[PlanPolicyFields.freeActiveWineLimit]),
  );

  /// The policy used before `config/policy` is read, or when it cannot be.
  static const PlanPolicy safeDefaults = PlanPolicy();

  static const String defaultPolicyVersion = 'freemium-v1';

  /// Kept as a decimal string so the cost comparison stays exact (D3).
  static const String defaultUsageBudgetEuro = '0.005';

  /// Active wines of the free plan when the cellar has no legacy limit
  /// (FR2.4).
  static const int defaultFreeActiveWineLimit = 15;

  static final RegExp _decimal = RegExp(r'^[0-9]+(\.[0-9]+)?$');

  static String _budget(Object? value) {
    final text = FirestoreValues.string(value);
    return text != null && _decimal.hasMatch(text)
        ? text
        : defaultUsageBudgetEuro;
  }

  static int _limit(Object? value) {
    final limit = FirestoreValues.integer(value);
    return limit != null && limit >= 1 ? limit : defaultFreeActiveWineLimit;
  }

  final bool adsEnabled;
  final bool capacityLimitEnabled;
  final bool purchasesEnabled;
  final String policyVersion;
  final String usageBudgetEuro;
  final int freeActiveWineLimit;

  /// The active-wine limit of a cellar (FR2.4): its migrated
  /// `legacyActiveWineLimit` when present, otherwise [freeActiveWineLimit].
  int effectiveActiveWineLimit({int? legacyActiveWineLimit}) =>
      legacyActiveWineLimit ?? freeActiveWineLimit;

  @override
  bool operator ==(Object other) =>
      other is PlanPolicy &&
      other.adsEnabled == adsEnabled &&
      other.capacityLimitEnabled == capacityLimitEnabled &&
      other.purchasesEnabled == purchasesEnabled &&
      other.policyVersion == policyVersion &&
      other.usageBudgetEuro == usageBudgetEuro &&
      other.freeActiveWineLimit == freeActiveWineLimit;

  @override
  int get hashCode => Object.hash(
    adsEnabled,
    capacityLimitEnabled,
    purchasesEnabled,
    policyVersion,
    usageBudgetEuro,
    freeActiveWineLimit,
  );
}
