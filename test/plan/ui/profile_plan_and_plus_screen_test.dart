// freemium-plus Step 17: the plan row of the Profile (FR1.3, FR4.3, FR5.4)
// and the Plus screen (FR3.1, FR3.2, FR3.3, FR3.5) in it, en and pt-BR.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinoozy/account/ui/profile_screen.dart';
import 'package:vinoozy/app/external_links.dart';
import 'package:vinoozy/app/providers.dart';
import 'package:vinoozy/dev/dev_cheats.dart';
import 'package:vinoozy/plan/billing/billing_client.dart';
import 'package:vinoozy/plan/billing/billing_service.dart';
import 'package:vinoozy/plan/billing/purchase_verifier.dart';
import 'package:vinoozy/plan/capability_resolver.dart';
import 'package:vinoozy/plan/domain/capabilities.dart';
import 'package:vinoozy/plan/domain/entitlement.dart';
import 'package:vinoozy/plan/domain/plan_policy.dart';
import 'package:vinoozy/plan/plan_providers.dart';
import 'package:vinoozy/plan/ui/plan_labels.dart';
import 'package:vinoozy/plan/ui/plus_screen.dart';

import '../../account/account_harness.dart';
import '../../helpers/fakes.dart';
import '../../helpers/ui_harness.dart';
import 'plan_ui_fakes.dart';

const ResolvedPlan _plusBought = ResolvedPlan(
  PlanTier(PlanKind.plus, PlanOrigin.playPurchase),
);
const ResolvedPlan _plusGift = ResolvedPlan(
  PlanTier(PlanKind.plus, PlanOrigin.manualGrant),
);

void main() {
  late FakeAuthService auth;
  late FakeBillingClient billing;
  late FakePurchaseVerifier verifier;
  late RecordingErrorSink sink;
  late List<String> opened;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    auth = FakeAuthService(currentUser: mario);
    billing = FakeBillingClient();
    verifier = FakePurchaseVerifier();
    sink = RecordingErrorSink();
    opened = [];
  });

  List<Override> base({PlanPolicy policy = PlanPolicy.safeDefaults}) => [
    authServiceProvider.overrideWithValue(auth),
    errorReporterProvider.overrideWithValue(recordingReporter(sink)),
    planPolicyProvider.overrideWithValue(policy),
    billingClientProvider.overrideWithValue(billing),
    purchaseVerifierProvider.overrideWithValue(verifier),
    externalLinkOpenerProvider.overrideWithValue((url) async {
      opened.add(url);
      return true;
    }),
  ];

  group('Profile plan row (FR1.3, FR5.4)', () {
    const labels = {
      'it': ['Gratuito', 'Plus', 'Plus in regalo', 'DEV · Plus di test'],
      'en': ['Free', 'Plus', 'Plus (gift)', 'DEV · Test Plus'],
      'pt-BR': ['Gratuito', 'Plus', 'Plus de presente', 'DEV · Plus de teste'],
    };
    for (final locale in testLocales) {
      final expected = labels[locale.toLanguageTag()]!;
      final plans = [
        ResolvedPlan.free,
        _plusBought,
        _plusGift,
        const ResolvedPlan(
          PlanTier(PlanKind.plus, PlanOrigin.developerOverride),
          scenario: DevScenario.unlockAll,
        ),
      ];
      for (final (index, plan) in plans.indexed) {
        testWidgets('${locale.toLanguageTag()}: ${expected[index]}', (
          tester,
        ) async {
          await pumpScreen(
            tester,
            const ProfileScreen(user: mario),
            locale: locale,
            overrides: [
              ...base(),
              resolvedPlanProvider(mario.uid).overrideWithValue(plan),
            ],
          );
          expect(
            tester.widget<Text>(find.byKey(const Key('profile-plan'))).data,
            expected[index],
          );
        });
      }
    }

    testWidgets('FR4.3 a gift written by the script shows as "Plus in regalo" '
        'without any action', (tester) async {
      await pumpScreen(
        tester,
        const ProfileScreen(user: mario),
        overrides: [
          ...base(),
          entitlementProvider(mario.uid).overrideWith(
            (ref) => Stream.value(
              Entitlement(
                uid: mario.uid,
                plan: plusPlanId,
                source: EntitlementSource.manualGrant,
                status: EntitlementStatus.active,
                reason: EntitlementReason.gift,
              ),
            ),
          ),
        ],
      );
      await tester.pumpAndSettle();
      expect(find.text('Plus in regalo'), findsOneWidget);
    });

    testWidgets('FR5.4 a saved developer override shows its indicator', (
      tester,
    ) async {
      final store = InMemoryKeyValueStore();
      final overrides = DevOverrideStore(
        store: store,
        reporter: recordingReporter(sink),
      );
      await overrides.write(
        DevOverride(scenario: DevScenario.simulateExpired, uid: mario.uid),
      );
      await pumpScreen(
        tester,
        const ProfileScreen(user: mario),
        overrides: [
          ...base(),
          devOverrideStoreProvider.overrideWithValue(overrides),
        ],
      );
      await tester.pumpAndSettle();
      expect(find.text('DEV · Plus scaduto simulato'), findsOneWidget);
    });

    testWidgets('"Scopri Plus" opens the Plus screen', (tester) async {
      await pumpScreen(
        tester,
        const ProfileScreen(user: mario),
        overrides: base(),
      );
      await tester.ensureVisible(
        find.byKey(const Key('profile-discover-plus')),
      );
      await tester.tap(find.byKey(const Key('profile-discover-plus')));
      await tester.pumpAndSettle();
      expect(find.byType(PlusScreen), findsOneWidget);
    });
  });

  group('Plus screen (FR3.1, FR3.2, FR3.5)', () {
    const comingSoon = {
      'it': 'Plus arriverà presto',
      'en': 'Plus is coming soon',
      'pt-BR': 'O Plus chegará em breve',
    };
    const prices = {
      'it': ['1,99 € al mese', '14,99 € all\'anno', 'Ripristina acquisti'],
      'en': ['1,99 € per month', '14,99 € per year', 'Restore purchases'],
      'pt-BR': ['1,99 € por mês', '14,99 € por ano', 'Restaurar compras'],
    };

    for (final locale in testLocales) {
      final tag = locale.toLanguageTag();
      testWidgets('$tag: purchases off says "coming soon", no buy button, '
          'the store is never asked', (tester) async {
        await pumpScreen(
          tester,
          const PlusScreen(user: mario),
          locale: locale,
          overrides: base(),
        );
        await tester.pumpAndSettle();
        expect(find.text(comingSoon[tag]!), findsOneWidget);
        expect(find.byKey(const Key('plus-buy-monthly')), findsNothing);
        expect(find.byKey(const Key('plus-restore')), findsNothing);
        expect(billing.availabilityCalls + billing.queryCalls, 0);
      });

      testWidgets('$tag: purchases on shows the store prices, renewal, terms, '
          'restore and the Play link', (tester) async {
        await pumpScreen(
          tester,
          const PlusScreen(user: mario),
          locale: locale,
          overrides: base(policy: const PlanPolicy(purchasesEnabled: true)),
        );
        await tester.pumpAndSettle();
        expect(find.text(prices[tag]![0]), findsOneWidget);
        expect(find.text(prices[tag]![1]), findsOneWidget);
        expect(find.text(prices[tag]![2]), findsOneWidget);
        expect(find.byKey(const Key('plus-renewal')), findsOneWidget);
        expect(find.byKey(const Key('plus-terms')), findsOneWidget);
        expect(find.byKey(const Key('plus-manage')), findsOneWidget);
      });
    }

    testWidgets('FR3.1 the store does not answer: an error, never prices', (
      tester,
    ) async {
      billing.failQuery = true;
      await pumpScreen(
        tester,
        const PlusScreen(user: mario),
        overrides: base(policy: const PlanPolicy(purchasesEnabled: true)),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('plus-store-unavailable')), findsOneWidget);
      expect(find.textContaining('€'), findsNothing);
      expect(sink.reasons, contains('BillingQueryFailed'));
    });

    testWidgets('FR3.3 a bought Plus is verified by the backend, then the '
        'store is told it was handled', (tester) async {
      await pumpScreen(
        tester,
        const PlusScreen(user: mario),
        overrides: base(policy: const PlanPolicy(purchasesEnabled: true)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('plus-buy-monthly')));
      await tester.pumpAndSettle();
      expect(billing.bought, [monthlyOffer]);

      billing.emit(BillingPurchaseStatus.purchased, token: 'tok-abc');
      await tester.pumpAndSettle();

      expect(verifier.tokens, ['tok-abc']);
      expect(billing.completed, hasLength(1));
      expect(
        find.text('Acquisto verificato: Plus si attiverà tra pochi secondi.'),
        findsOneWidget,
      );
    });

    testWidgets('FR3.3 a pending purchase unlocks nothing and is not '
        'acknowledged', (tester) async {
      await pumpScreen(
        tester,
        const PlusScreen(user: mario),
        overrides: base(policy: const PlanPolicy(purchasesEnabled: true)),
      );
      await tester.pumpAndSettle();
      billing.emit(BillingPurchaseStatus.pending);
      await tester.pumpAndSettle();

      expect(verifier.tokens, isEmpty);
      expect(billing.completed, isEmpty);
      expect(find.textContaining('Pagamento in attesa'), findsOneWidget);
    });

    testWidgets('FR3.3 a token of another account is refused and never '
        'acknowledged by the phone', (tester) async {
      verifier.result = PurchaseVerificationResult.ownedByAnotherAccount;
      await pumpScreen(
        tester,
        const PlusScreen(user: mario),
        overrides: base(policy: const PlanPolicy(purchasesEnabled: true)),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('plus-restore')));
      billing.emit(BillingPurchaseStatus.restored);
      await tester.pumpAndSettle();

      expect(billing.restoreCalls, 1);
      expect(billing.completed, isEmpty);
      expect(
        find.text(
          'Questo abbonamento appartiene già a un altro account Vinoozy.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('FR3.2 the Play link opens the subscriptions page', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        const PlusScreen(user: mario),
        overrides: base(policy: const PlanPolicy(purchasesEnabled: true)),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('plus-manage')));
      await tester.tap(find.byKey(const Key('plus-manage')));
      await tester.pumpAndSettle();
      expect(opened, [plusManageUrl]);
      expect(plusManageUrl, contains('sku=vinoozy_plus'));
      expect(plusManageUrl, contains('package=com.vinoozy.app'));
    });

    testWidgets('FR1.3 a gift shows no renewal, no price and no Play link', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        const PlusScreen(user: mario),
        overrides: [
          ...base(policy: const PlanPolicy(purchasesEnabled: true)),
          resolvedPlanProvider(mario.uid).overrideWithValue(_plusGift),
        ],
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Hai Plus in regalo: nessun addebito e nessun rinnovo.'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('plus-manage')), findsNothing);
      expect(find.byKey(const Key('plus-renewal')), findsNothing);
      expect(billing.queryCalls, 0);
    });

    testWidgets('a bought Plus links to manage it on Google Play', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        const PlusScreen(user: mario),
        overrides: [
          ...base(policy: const PlanPolicy(purchasesEnabled: true)),
          resolvedPlanProvider(mario.uid).overrideWithValue(_plusBought),
        ],
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('plus-active')), findsOneWidget);
      expect(find.byKey(const Key('plus-manage')), findsOneWidget);
    });
  });
}
