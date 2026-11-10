// freemium-plus Step 17 (FR5.2-FR5.6; study §9.2, §9.3): the developer
// panel, its four commands, the indicator, the emulator fixture (applied or
// "incomplete simulation", never a fake success), and the hidden sequence.
//
// The sequence exists only where `kDevCheatsAvailable` is true, a constant
// that keeps it out of release builds (FR5.7): its tests run with
// `flutter test --dart-define=ENABLE_DEV_CHEATS=true test/dev/ui` and are
// skipped otherwise. The single tap on the logo is checked in both modes.
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show ProviderScope;
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinoozy/app/home_shell.dart';
import 'package:vinoozy/app/providers.dart';
import 'package:vinoozy/app/ui/about_screen.dart';
import 'package:vinoozy/app/ui/brand_footer.dart';
import 'package:vinoozy/catalog/platform/catalog_providers.dart';
import 'package:vinoozy/catalog/platform/wine_db_loader.dart';
import 'package:vinoozy/cellar/ui/cellar_screen.dart';
import 'package:vinoozy/dev/dev_cheats.dart';
import 'package:vinoozy/dev/dev_entitlement_fixture.dart';
import 'package:vinoozy/dev/dev_providers.dart';
import 'package:vinoozy/dev/ui/dev_tools_screen.dart';
import 'package:vinoozy/plan/plan_providers.dart';

import '../../dashboard/dashboard_harness.dart';
import '../../dashboard/fixtures.dart';
import '../../helpers/fakes.dart';
import '../../helpers/ui_harness.dart';

void main() {
  late InMemoryKeyValueStore store;
  late RecordingErrorSink sink;
  late List<http.Request> requests;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    store = InMemoryKeyValueStore();
    sink = RecordingErrorSink();
    requests = [];
  });

  DevEntitlementFixture fixture({
    String host = 'localhost',
    bool reachable = true,
  }) => DevEntitlementFixture(
    client: MockClient((request) async {
      requests.add(request);
      if (!reachable) throw http.ClientException('connection refused');
      return http.Response('{}', 200);
    }),
    host: host,
    reporter: recordingReporter(sink),
    clock: FakeClock(DateTime.utc(2026, 11, 10, 12)),
  );

  List<Override> overrides(DevEntitlementFixture? emulator) => [
    errorReporterProvider.overrideWithValue(recordingReporter(sink)),
    devOverrideStoreProvider.overrideWithValue(
      DevOverrideStore(store: store, reporter: recordingReporter(sink)),
    ),
    devEntitlementFixtureProvider.overrideWithValue(emulator),
  ];

  Future<void> pumpPanel(
    WidgetTester tester, {
    DevEntitlementFixture? emulator,
    Locale locale = const Locale('it'),
  }) async {
    await pumpScreen(
      tester,
      const DevToolsScreen(user: dashboardUser),
      locale: locale,
      overrides: overrides(emulator),
    );
    await tester.pumpAndSettle();
  }

  String indicator(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const Key('dev-indicator'))).data!;

  group('Developer panel (FR5.3-FR5.6)', () {
    const texts = {
      'it': ['Nessuna simulazione attiva', 'DEV · Plus di test'],
      'en': ['No simulation active', 'DEV · Test Plus'],
      'pt-BR': ['Nenhuma simulação ativa', 'DEV · Plus de teste'],
    };
    for (final locale in testLocales) {
      testWidgets('${locale.toLanguageTag()}: the marker, four commands and '
          'the indicator', (tester) async {
        await pumpPanel(tester, emulator: fixture(), locale: locale);
        final tag = locale.toLanguageTag();
        expect(find.byKey(const Key(devCheatsPanelMarker)), findsOneWidget);
        for (final key in [
          'dev-unlock-all',
          'dev-simulate-free',
          'dev-simulate-expired',
          'dev-restore',
        ]) {
          expect(find.byKey(Key(key)), findsOneWidget);
        }
        expect(indicator(tester), texts[tag]![0]);

        await tester.tap(find.byKey(const Key('dev-unlock-all')));
        await tester.pumpAndSettle();
        expect(indicator(tester), texts[tag]![1]);
      });
    }

    testWidgets('FR5.6 "Unlock everything" writes the test Plus in the '
        'emulator only, as the owner', (tester) async {
      await pumpPanel(tester, emulator: fixture());
      await tester.tap(find.byKey(const Key('dev-unlock-all')));
      await tester.pumpAndSettle();

      final request = requests.single;
      expect(request.method, 'PATCH');
      expect(request.url.host, 'localhost');
      expect(request.url.port, 8080);
      expect(
        request.url.path,
        '/v1/projects/demo-vinoozy/databases/(default)/documents/'
        'entitlements/${dashboardUser.uid}',
      );
      expect(request.headers['Authorization'], 'Bearer owner');
      final fields =
          (jsonDecode(request.body) as Map<String, Object?>)['fields']! as Map;
      expect(fields['status'], {'stringValue': 'active'});
      expect(fields['source'], {'stringValue': 'manual_grant'});
      expect(fields.containsKey('purchaseToken'), isFalse);
      expect(find.byKey(const Key('dev-fixture-applied')), findsOneWidget);
    });

    testWidgets('FR5.6 an unreachable emulator says "incomplete simulation"', (
      tester,
    ) async {
      await pumpPanel(tester, emulator: fixture(reachable: false));
      await tester.tap(find.byKey(const Key('dev-unlock-all')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('dev-fixture-incomplete')), findsOneWidget);
      expect(find.byKey(const Key('dev-fixture-applied')), findsNothing);
      expect(sink.reasons, contains('DevFixtureFailed'));
    });

    testWidgets('FR5.6 a public host is never written', (tester) async {
      await pumpPanel(tester, emulator: fixture(host: 'firestore.example.com'));
      await tester.tap(find.byKey(const Key('dev-simulate-expired')));
      await tester.pumpAndSettle();

      expect(requests, isEmpty);
      expect(find.byKey(const Key('dev-fixture-incomplete')), findsOneWidget);
    });

    testWidgets(
      'FR5.3 test Plus → free → expired → normal: the indicator '
      'follows, "Restore" removes the override and the emulator entitlement',
      (tester) async {
        await pumpPanel(tester, emulator: fixture());
        for (final (key, expected) in [
          ('dev-unlock-all', 'DEV · Plus di test'),
          ('dev-simulate-free', 'DEV · Piano gratuito simulato'),
          ('dev-simulate-expired', 'DEV · Plus scaduto simulato'),
          ('dev-restore', 'Nessuna simulazione attiva'),
        ]) {
          await tester.tap(find.byKey(Key(key)));
          await tester.pumpAndSettle();
          expect(indicator(tester), expected);
        }
        expect(requests.map((r) => r.method), [
          'PATCH',
          'DELETE',
          'PATCH',
          'DELETE',
        ]);
        expect(store.values[DevOverrideStore.storageKey], '');
      },
    );

    testWidgets('FR5.4 the override in force resolves the plan', (
      tester,
    ) async {
      await pumpPanel(tester, emulator: fixture());
      await tester.tap(find.byKey(const Key('dev-unlock-all')));
      await tester.pumpAndSettle();
      final container = ProviderScope.containerOf(
        tester.element(find.byType(DevToolsScreen)),
      );
      expect(
        container.read(capabilitiesProvider(dashboardUser.uid)).adFree,
        isTrue,
      );
    });
  });

  group('Brand footer', () {
    testWidgets('FR5.2 a single tap on the logo still opens "Informazioni"', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        const Scaffold(body: BrandFooter()),
        overrides: [
          appVersionLabelProvider.overrideWith((ref) async => '0.1.0 (1)'),
          catalogAppVersionProvider.overrideWith((ref) async => '0.1.0'),
          wineDbStatusProvider.overrideWith(
            (ref) => Completer<WineDbLoadResult>().future,
          ),
        ],
      );
      await tester.tap(find.byKey(const Key('brand-footer')));
      // Past the double-tap timeout, when the tools exist.
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(find.byType(AboutScreen), findsOneWidget);
    });
  });

  group('Hidden sequence in the home shell (FR5.2)', () {
    late DashboardStreams streams;
    // Needs --dart-define=ENABLE_DEV_CHEATS=true (see the file header).
    const skip = !kDevCheatsAvailable;

    setUp(() => streams = DashboardStreams());

    Future<void> pumpShell(WidgetTester tester) async {
      await pumpScreen(
        tester,
        HomeShell(
          user: dashboardUser,
          setup: CellarSetup.ready,
          onRetrySetup: () async {},
        ),
        overrides: [
          ...streams.overrides,
          ...overrides(fixture()).skip(1),
          appVersionLabelProvider.overrideWith((ref) async => '0.1.0 (1)'),
        ],
      );
      streams
        ..emitCellar()
        ..emitWines([wineOf('w1')]);
      await tester.pumpAndSettle();
    }

    Future<void> doubleTapLogo(WidgetTester tester) async {
      final footer = find.byKey(const Key('brand-footer'));
      await tester.scrollUntilVisible(
        footer,
        200,
        scrollable: find
            .descendant(
              of: find.byKey(const Key('dashboard-content')),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.tap(footer);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(footer);
      await tester.pumpAndSettle();
    }

    Future<void> nav(WidgetTester tester, List<String> tabs) async {
      for (final tab in tabs) {
        await tester.tap(find.byKey(Key('home-nav-$tab')));
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.pumpAndSettle();
    }

    const sequence = [
      'cellar',
      'cellar',
      'cellar',
      'history',
      'history',
      'history',
      'cellar',
      'history',
      'dashboard',
    ];

    testWidgets('the full sequence within 20 s opens the panel', skip: skip, (
      tester,
    ) async {
      await pumpShell(tester);
      await doubleTapLogo(tester);
      expect(find.byType(AboutScreen), findsNothing);
      await nav(tester, sequence);
      expect(find.byType(DevToolsScreen), findsOneWidget);
    });

    testWidgets('a wrong step opens nothing', skip: skip, (tester) async {
      await pumpShell(tester);
      await doubleTapLogo(tester);
      await nav(tester, [...sequence.take(4), 'cellar', ...sequence.skip(5)]);
      expect(find.byType(DevToolsScreen), findsNothing);
    });

    testWidgets('without the two taps on the logo nothing opens', skip: skip, (
      tester,
    ) async {
      await pumpShell(tester);
      await nav(tester, sequence);
      expect(find.byType(DevToolsScreen), findsNothing);
    });
  });
}
