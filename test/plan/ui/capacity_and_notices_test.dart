// freemium-plus Step 17: the capacity explanation at 15 of 15 (FR2.4,
// FR2.5), the reason of a refused draft (FR2.5), the free-plan presentation
// once (FR8.1, FR8.2) and the threshold explanation once per month with the
// local reset time (FR7.5), in it, en and pt-BR.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinoozy/app/home_shell.dart';
import 'package:vinoozy/app/providers.dart';
import 'package:vinoozy/cellar/ui/cellar_screen.dart';
import 'package:vinoozy/label/ui/add_choice_screen.dart';
import 'package:vinoozy/plan/domain/capabilities.dart';
import 'package:vinoozy/plan/domain/plan_policy.dart';
import 'package:vinoozy/plan/plan_notices.dart';
import 'package:vinoozy/plan/plan_providers.dart';
import 'package:vinoozy/plan/ui/dashboard_plan_notices.dart';
import 'package:vinoozy/plan/ui/plus_screen.dart';
import 'package:vinoozy/sync/capacity_rejection.dart';
import 'package:vinoozy/sync/ledger/ledger_state.dart';
import 'package:vinoozy/sync/ui/rejected_wine_notice.dart';
import 'package:vinoozy/usage/usage_providers.dart';

import '../../dashboard/dashboard_harness.dart';
import '../../dashboard/fixtures.dart';
import '../../helpers/fakes.dart';
import '../../helpers/ui_harness.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('Capacity limit at the add entry point (FR2.4, FR2.5)', () {
    late DashboardStreams streams;

    setUp(() => streams = DashboardStreams());

    Future<void> openAdd(
      WidgetTester tester, {
      required int wines,
      PlanPolicy policy = const PlanPolicy(capacityLimitEnabled: true),
      Capabilities capabilities = Capabilities.free,
      Locale locale = const Locale('it'),
    }) async {
      await pumpScreen(
        tester,
        HomeShell(
          user: dashboardUser,
          setup: CellarSetup.ready,
          onRetrySetup: () async {},
        ),
        locale: locale,
        overrides: [
          ...streams.overrides,
          planPolicyProvider.overrideWithValue(policy),
          capabilitiesProvider(dashboardUser.uid)
              .overrideWithValue(capabilities),
        ],
      );
      streams
        ..emitCellar()
        ..emitWines([for (var i = 0; i < wines; i++) wineOf('w$i')]);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('home-nav-cellar')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('cellar-add-button')));
      await tester.pumpAndSettle();
    }

    const bodies = {
      'it': 'Il piano gratuito comprende fino a 15 vini diversi in cantina.',
      'en': 'The free plan includes up to 15 different wines in your cellar.',
      'pt-BR': 'O plano gratuito inclui até 15 vinhos diferentes na adega.',
    };
    for (final locale in testLocales) {
      testWidgets('${locale.toLanguageTag()}: with 15 of 15 "Add" explains '
          'the limit and opens nothing', (tester) async {
        await openAdd(tester, wines: 15, locale: locale);
        expect(find.byKey(const Key('capacity-limit-sheet')), findsOneWidget);
        expect(
          find.textContaining(bodies[locale.toLanguageTag()]!),
          findsOneWidget,
        );
        expect(find.byType(AddChoiceScreen), findsNothing);
      });
    }

    testWidgets('with 14 of 15 the add choice opens', (tester) async {
      await openAdd(tester, wines: 14);
      expect(find.byType(AddChoiceScreen), findsOneWidget);
    });

    testWidgets('with Plus there is no limit', (tester) async {
      await openAdd(tester, wines: 15, capabilities: Capabilities.plus);
      expect(find.byType(AddChoiceScreen), findsOneWidget);
    });

    testWidgets('with the limit off (launch) there is no limit', (
      tester,
    ) async {
      await openAdd(tester, wines: 30, policy: PlanPolicy.safeDefaults);
      expect(find.byType(AddChoiceScreen), findsOneWidget);
    });

    testWidgets('"Scopri Plus" in the explanation opens the Plus screen, '
        'which says "coming soon" with purchases off', (tester) async {
      await openAdd(tester, wines: 15);
      expect(find.textContaining('Plus arriverà presto'), findsOneWidget);
      await tester.tap(find.byKey(const Key('capacity-limit-discover-plus')));
      await tester.pumpAndSettle();
      expect(find.byType(PlusScreen), findsOneWidget);
      expect(find.byKey(const Key('plus-coming-soon')), findsOneWidget);
    });
  });

  group('Refused draft reason (FR2.5)', () {
    const texts = {
      'it': 'Non sincronizzato: supera il limite di vini del piano gratuito.',
      'en': 'Not synced: it goes over the wine limit of the free plan.',
      'pt-BR':
          'Não sincronizado: ultrapassa o limite de vinhos do plano gratuito.',
    };
    for (final locale in testLocales) {
      testWidgets('${locale.toLanguageTag()}: the capacity reason is shown', (
        tester,
      ) async {
        await pumpScreen(
          tester,
          RejectedWineNotice(
            entry: const JournalEntry(
              wineId: 'w16',
              cellarId: 'user-a',
              name: 'Barolo',
              ownerUid: 'user-a',
              state: JournalState.rejected,
              reason: CapacityRejection.capacityLimit,
            ),
            onAddAgain: () {},
            onIgnore: () {},
          ),
          locale: locale,
        );
        expect(
          find.textContaining(texts[locale.toLanguageTag()]!),
          findsOneWidget,
        );
      });
    }

    testWidgets('a refusal without a reason shows no reason line', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        RejectedWineNotice(
          entry: const JournalEntry(
            wineId: 'w1',
            cellarId: 'user-a',
            name: 'Barolo',
            ownerUid: 'user-a',
            state: JournalState.rejected,
          ),
          onAddAgain: () {},
          onIgnore: () {},
        ),
      );
      expect(find.byKey(const Key('rejected-wine-reason')), findsNothing);
    });
  });

  group('Dashboard notices (FR7.5, FR8.2)', () {
    late InMemoryKeyValueStore store;
    final reset = DateTime.utc(2026, 12);
    final verifiedAbove = UsageStatus(
      periodId: '2026-11',
      nextResetUtc: reset,
      verified: true,
      aboveBudget: true,
    );

    setUp(() => store = InMemoryKeyValueStore());

    /// A new app start: the provider scope goes away, the store stays.
    Future<void> restart(WidgetTester tester) =>
        tester.pumpWidget(const SizedBox());

    List<Override> overrides({
      PlanPolicy policy = const PlanPolicy(adsEnabled: true),
      UsageStatus? usage,
      Capabilities capabilities = Capabilities.free,
    }) => [
      errorReporterProvider.overrideWithValue(
        recordingReporter(RecordingErrorSink()),
      ),
      planNoticeStoreProvider.overrideWithValue(store),
      planPolicyProvider.overrideWithValue(policy),
      usageStatusProvider.overrideWith(
        (ref) => Stream.value(usage ?? verifiedAbove),
      ),
      entitlementKnownProvider(dashboardUser.uid).overrideWithValue(true),
      capabilitiesProvider(dashboardUser.uid).overrideWithValue(capabilities),
    ];

    Future<void> pump(
      WidgetTester tester, {
      List<Override>? with_,
      Locale locale = const Locale('it'),
    }) async {
      await pumpScreen(
        tester,
        const SingleChildScrollView(
          child: DashboardPlanNotices(user: dashboardUser),
        ),
        locale: locale,
        overrides: with_ ?? overrides(),
      );
      await tester.pumpAndSettle();
    }

    const titles = {
      'it': 'Gli annunci aiutano a mantenere Vinoozy gratuito',
      'en': 'Ads help keep Vinoozy free',
      'pt-BR': 'Os anúncios ajudam a manter o Vinoozy gratuito',
    };
    for (final locale in testLocales) {
      testWidgets('${locale.toLanguageTag()}: the threshold explanation shows '
          'the next reset in local time', (tester) async {
        await pump(tester, locale: locale);
        expect(find.text(titles[locale.toLanguageTag()]!), findsOneWidget);
        final expected = DateFormat.yMMMMd(locale.toLanguageTag())
            .add_Hm()
            .format(reset.toLocal());
        expect(
          tester
              .widget<Text>(find.byKey(const Key('threshold-next-reset')))
              .data,
          contains(expected),
        );
      });
    }

    testWidgets('FR7.5 the explanation appears once per month and account', (
      tester,
    ) async {
      await pump(tester);
      expect(find.byKey(const Key('threshold-notice')), findsOneWidget);
      await tester.tap(find.byKey(const Key('threshold-close')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('threshold-notice')), findsNothing);
      expect(store.values['plan.notice.threshold.v1/user-a'], '2026-11');

      // A new start in the same month: not again.
      await restart(tester);
      await pump(tester);
      expect(find.byKey(const Key('threshold-notice')), findsNothing);

      // The next month: again.
      await restart(tester);
      await pump(
        tester,
        with_: overrides(
          usage: UsageStatus(
            periodId: '2026-12',
            nextResetUtc: DateTime.utc(2027),
            verified: true,
            aboveBudget: true,
          ),
        ),
      );
      expect(find.byKey(const Key('threshold-notice')), findsOneWidget);
    });

    testWidgets('FR7.5 shown on the screen is remembered even if not closed', (
      tester,
    ) async {
      await pump(tester);
      expect(store.values['plan.notice.threshold.v1/user-a'], '2026-11');
    });

    testWidgets(
      'no explanation with ads off, with Plus, or unverified (NFR4)',
      (tester) async {
        for (final variant in [
          overrides(policy: PlanPolicy.safeDefaults),
          overrides(capabilities: Capabilities.plus),
          overrides(
            usage: UsageStatus(
              periodId: '2026-11',
              nextResetUtc: reset,
              verified: false,
              aboveBudget: true,
            ),
          ),
        ]) {
          await restart(tester);
          await pump(tester, with_: variant);
          expect(find.byKey(const Key('threshold-notice')), findsNothing);
        }
      },
    );

    testWidgets('"Come funziona" explains the estimate; "Scopri Plus" opens '
        'Plus', (tester) async {
      await pump(tester);
      await tester.tap(find.byKey(const Key('threshold-how-it-works')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('threshold-how-dialog')), findsOneWidget);
      expect(
        find.textContaining("L'uso offline non genera da solo"),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('threshold-how-close')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('threshold-discover-plus')));
      await tester.pumpAndSettle();
      expect(find.byType(PlusScreen), findsOneWidget);
    });

    const intros = {
      'it': [
        'Puoi gestire gratuitamente fino a 15 vini diversi.',
        'Nessuna pubblicità nella versione di lancio.',
        'Plus arriverà presto',
      ],
      'en': [
        'You can manage up to 15 different wines for free.',
        'No ads in the launch version.',
        'Plus is coming soon',
      ],
      'pt-BR': [
        'Você pode gerenciar gratuitamente até 15 vinhos diferentes.',
        'Sem anúncios na versão de lançamento.',
        'O Plus chegará em breve',
      ],
    };
    for (final locale in testLocales) {
      testWidgets('${locale.toLanguageTag()}: FR8.2 the free-plan '
          'presentation with ads and purchases off', (tester) async {
        await pump(
          tester,
          locale: locale,
          with_: overrides(
            policy: const PlanPolicy(capacityLimitEnabled: true),
          ),
        );
        final card = find.byKey(const Key('free-plan-intro'));
        expect(card, findsOneWidget);
        for (final text in intros[locale.toLanguageTag()]!) {
          expect(
            find.descendant(of: card, matching: find.textContaining(text)),
            findsOneWidget,
          );
        }
      });
    }

    testWidgets('FR8.2 with ads and purchases on it uses the study text', (
      tester,
    ) async {
      await pump(
        tester,
        with_: overrides(
          policy: const PlanPolicy(
            capacityLimitEnabled: true,
            adsEnabled: true,
            purchasesEnabled: true,
          ),
          usage: UsageStatus(
            periodId: '2026-11',
            nextResetUtc: reset,
            verified: true,
            aboveBudget: false,
          ),
        ),
      );
      expect(
        find.textContaining('potresti vedere annunci occasionali'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Con Plus elimini gli annunci e il limite'),
        findsOneWidget,
      );
    });

    testWidgets('FR8.2 the presentation appears once; never with the limit '
        'off', (tester) async {
      await pump(tester, with_: overrides(policy: PlanPolicy.safeDefaults));
      expect(find.byKey(const Key('free-plan-intro')), findsNothing);

      await restart(tester);
      await pump(
        tester,
        with_: overrides(policy: const PlanPolicy(capacityLimitEnabled: true)),
      );
      await tester.tap(find.byKey(const Key('free-plan-intro-close')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('free-plan-intro')), findsNothing);

      await restart(tester);
      await pump(
        tester,
        with_: overrides(policy: const PlanPolicy(capacityLimitEnabled: true)),
      );
      expect(find.byKey(const Key('free-plan-intro')), findsNothing);
      expect(store.values[freePlanIntroNotice(dashboardUser.uid).key], 'seen');
    });
  });
}
