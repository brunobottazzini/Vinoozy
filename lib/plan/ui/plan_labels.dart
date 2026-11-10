import '../../dev/dev_cheats.dart';
import '../../l10n/app_localizations.dart';
import '../capability_resolver.dart';
import '../domain/capabilities.dart';

/// The name of the plan in force (freemium-plus FR1.3, FR5.4): "Free",
/// "Plus", "Plus (gift)" or the developer indicator, so a test plan is never
/// taken for a purchase.
String planLabelOf(AppLocalizations l10n, ResolvedPlan plan) =>
    switch (plan.tier.origin) {
      PlanOrigin.developerOverride => switch (plan.scenario) {
        DevScenario.unlockAll => l10n.planDevUnlockAll,
        DevScenario.simulateExpired => l10n.planDevSimulateExpired,
        DevScenario.simulateFree || null => l10n.planDevSimulateFree,
      },
      PlanOrigin.manualGrant => l10n.planPlusGift,
      PlanOrigin.playPurchase => l10n.planPlus,
      PlanOrigin.standard => l10n.planFree,
    };

/// The Google Play page to manage or cancel the Plus subscription (FR3.2).
const String plusManageUrl =
    'https://play.google.com/store/account/subscriptions'
    '?sku=vinoozy_plus&package=com.vinoozy.app';
