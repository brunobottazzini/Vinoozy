// tester-feedback FR1.1-FR1.3, FR2.4, FR4.1, FR4.2, FR5.1, FR6.1, FR6.3,
// NFR5: the Settings entry of the Cellar menu and the Settings screen with
// its seven entries, in it, en and pt-BR.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinoozy/account/account_gate.dart';
import 'package:vinoozy/account/ui/profile_screen.dart';
import 'package:vinoozy/app/device_info.dart';
import 'package:vinoozy/app/external_links.dart';
import 'package:vinoozy/app/providers.dart';
import 'package:vinoozy/app/store_links.dart';
import 'package:vinoozy/app/ui/about_screen.dart';
import 'package:vinoozy/catalog/core/catalog_event_logger.dart'
    show WineDbFailure;
import 'package:vinoozy/catalog/platform/catalog_providers.dart';
import 'package:vinoozy/catalog/platform/wine_db_loader.dart';
import 'package:vinoozy/cellar/ui/cellar_screen.dart';
import 'package:vinoozy/guide/guide_providers.dart';
import 'package:vinoozy/guide/guide_state_store.dart';
import 'package:vinoozy/l10n/app_localizations.dart';
import 'package:vinoozy/settings/app_review.dart';
import 'package:vinoozy/settings/ui/faq_screen.dart';
import 'package:vinoozy/settings/ui/settings_screen.dart';
import 'package:vinoozy/sharing/ui/share_launcher.dart';

import '../account/account_harness.dart';
import '../cellar/cellar_harness.dart' show cellarOwner;
import '../cellar/ui/cellar_ui_harness.dart';
import '../helpers/fakes.dart';
import '../helpers/ui_harness.dart';

class _MockGate extends Mock implements AccountGate {}

class _FakeShare implements ShareLauncher {
  final List<(String, String)> shared = [];
  Object? error;

  @override
  Future<void> share({required String text, required String subject}) async {
    if (error != null) throw error!;
    shared.add((text, subject));
  }
}

class _FakeReview implements AppReviewLauncher {
  int ratingPages = 0;
  int requests = 0;
  bool opens = true;

  @override
  Future<bool> openRatingPage() async {
    ratingPages++;
    return opens;
  }

  @override
  Future<void> requestReview() async => requests++;
}

class _Launcher extends StatelessWidget {
  const _Launcher();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: ElevatedButton(
        key: const Key('open-settings'),
        onPressed: () => SettingsScreen.open(context, mario),
        child: const Text('open'),
      ),
    ),
  );
}

const List<String> _entryKeys = [
  'settings-profile',
  'settings-guide',
  'settings-share',
  'settings-rate',
  'settings-feedback',
  'settings-faq',
  'settings-about',
];

void main() {
  late _FakeShare share;
  late _FakeReview review;
  late RecordingErrorSink sink;
  late List<(String, String)> emails;
  late bool emailOpens;
  late _MockGate gate;

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'guide.tour.seen': true,
      'guide.firstRun.version': 1,
      'guide.hint.history': true,
    });
    share = _FakeShare();
    review = _FakeReview();
    sink = RecordingErrorSink();
    emails = [];
    emailOpens = true;
    gate = _MockGate();
    when(() => gate.state).thenReturn(ValueNotifier(const GateCellar(mario)));
    when(() => gate.current).thenAnswer((_) => const GateCellar(mario));
    when(() => gate.pendingChanges()).thenAnswer((_) async => 0);
  });

  List<Override> overrides() => [
    shareLauncherProvider.overrideWithValue(share),
    appReviewLauncherProvider.overrideWithValue(review),
    errorReporterProvider.overrideWithValue(recordingReporter(sink)),
    supportEmailOpenerProvider.overrideWithValue(({
      required subject,
      required body,
    }) async {
      emails.add((subject, body));
      return emailOpens;
    }),
    deviceInfoReaderProvider.overrideWithValue(
      () async => const DeviceInfo(
        manufacturer: 'Google',
        model: 'Pixel 8',
        release: '15',
      ),
    ),
    catalogAppVersionProvider.overrideWith((ref) async => '0.4.0'),
    wineDbStatusProvider.overrideWith(
      (ref) => Future.value(const WineDbUnavailable(WineDbFailure.missing)),
    ),
    guideStateStoreProvider.overrideWithValue(
      GuideStateStore(SharedPreferences.getInstance),
    ),
    accountGateProvider.overrideWithValue(gate),
    authServiceProvider.overrideWithValue(FakeAuthService(currentUser: mario)),
    networkStatusProvider.overrideWithValue(FakeNetworkStatus()),
  ];

  Future<void> pumpSettings(
    WidgetTester tester, {
    Locale locale = const Locale('it'),
  }) async {
    await pumpScreen(
      tester,
      const SettingsScreen(user: mario),
      locale: locale,
      overrides: overrides(),
    );
    await tester.pumpAndSettle();
  }

  group('FR1.1 FR1.3 the Cellar menu', () {
    for (final locale in testLocales) {
      testWidgets('"Settings" comes before "About" and opens the screen '
          '(${locale.toLanguageTag()})', (tester) async {
        final ui = CellarUi();
        await pumpScreen(
          tester,
          const CellarScreen(
            user: cellarOwner,
            setup: CellarSetup.ready,
            onRetrySetup: _noRetry,
          ),
          locale: locale,
          overrides: ui.overrides,
        );
        ui
          ..emitCellar()
          ..emitWines(const []);
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('cellar-menu')));
        await tester.pumpAndSettle();

        final l10n = lookupAppLocalizations(locale);
        // The entries that were there stay (FR1.3).
        for (final key in [
          'cellar-menu-profile',
          'cellar-menu-people',
          'cellar-archive',
          'cellar-menu-about',
        ]) {
          expect(find.byKey(Key(key)), findsOneWidget, reason: key);
        }
        final settings = find.byKey(const Key('cellar-menu-settings'));
        expect(
          find.descendant(
            of: settings,
            matching: find.text(l10n.settingsTitle),
          ),
          findsOneWidget,
        );
        expect(
          tester.getTopLeft(settings).dy,
          lessThan(
            tester.getTopLeft(find.byKey(const Key('cellar-menu-about'))).dy,
          ),
        );
        await tester.tap(settings);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('settings-screen')), findsOneWidget);
      });
    }
  });

  group('FR1.2 the seven entries', () {
    for (final locale in testLocales) {
      testWidgets('in the order of FR1.2 (${locale.toLanguageTag()})', (
        tester,
      ) async {
        await pumpSettings(tester, locale: locale);
        final l10n = lookupAppLocalizations(locale);
        expect(find.text(l10n.settingsTitle), findsOneWidget);
        final tops = [
          for (final key in _entryKeys)
            tester.getTopLeft(find.byKey(Key(key))).dy,
        ];
        expect(tops, orderedEquals([...tops]..sort()));
        for (final (key, text) in [
          ('settings-profile', l10n.profileTitle),
          ('settings-guide', l10n.settingsGuide),
          ('settings-share', l10n.settingsShare),
          ('settings-rate', l10n.settingsRate),
          ('settings-feedback', l10n.settingsFeedback),
          ('settings-faq', l10n.settingsFaq),
          ('settings-about', l10n.aboutTitle),
        ]) {
          expect(
            find.descendant(
              of: find.byKey(Key(key)),
              matching: find.text(text),
            ),
            findsOneWidget,
            reason: key,
          );
        }
      });

      testWidgets('NFR5 tap targets, labels and contrast '
          '(${locale.toLanguageTag()})', (tester) async {
        final handle = tester.ensureSemantics();
        await pumpSettings(tester, locale: locale);
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
      });
    }
  });

  testWidgets('FR1.2 Profile and About open the existing screens; Back '
      'returns to the Settings', (tester) async {
    await pumpSettings(tester);
    await tester.tap(find.byKey(const Key('settings-profile')));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);
    // The system Back.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsNothing);
    expect(find.byKey(const Key('settings-screen')), findsOneWidget);

    await tester.tap(find.byKey(const Key('settings-about')));
    await tester.pumpAndSettle();
    expect(find.byType(AboutScreen), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(AboutScreen), findsNothing);

    await tester.tap(find.byKey(const Key('settings-faq')));
    await tester.pumpAndSettle();
    expect(find.byType(FaqScreen), findsOneWidget);
  });

  group('FR4 share the app', () {
    for (final locale in testLocales) {
      testWidgets('the translated message carries the Play Store link '
          '(${locale.toLanguageTag()})', (tester) async {
        await pumpSettings(tester, locale: locale);
        await tester.tap(find.byKey(const Key('settings-share')));
        await tester.pumpAndSettle();
        final l10n = lookupAppLocalizations(locale);
        expect(share.shared, [
          (l10n.shareAppMessage(playStoreLink), l10n.shareAppSubject),
        ]);
        expect(share.shared.single.$1, contains(playStoreLink));
      });
    }

    testWidgets('a platform failure shows a translated message and is '
        'reported', (tester) async {
      share.error = PlatformException(code: 'share_failed');
      await pumpSettings(tester);
      await tester.tap(find.byKey(const Key('settings-share')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('settings-share-failed')), findsOneWidget);
      expect(
        find.text(
          lookupAppLocalizations(const Locale('it')).settingsShareFailed,
        ),
        findsOneWidget,
      );
      expect(sink.reasons, ['ShareAppFailed']);
    });

    test('FR4.2 one link for invitations and "Share the app"', () {
      expect(
        playStoreLink,
        'https://play.google.com/store/apps/details?id=com.vinoozy.app',
      );
    });
  });

  group('FR5.1 rate the app', () {
    testWidgets('asks the review launcher, no message on success', (
      tester,
    ) async {
      await pumpSettings(tester);
      await tester.tap(find.byKey(const Key('settings-rate')));
      await tester.pumpAndSettle();
      expect(review.ratingPages, 1);
      // The button never counts as an automatic prompt (FR5.3).
      expect(review.requests, 0);
      expect(find.byKey(const Key('settings-rate-failed')), findsNothing);
    });

    testWidgets('nothing could be opened: a translated message', (
      tester,
    ) async {
      review.opens = false;
      await pumpSettings(tester, locale: const Locale('en'));
      await tester.tap(find.byKey(const Key('settings-rate')));
      await tester.pumpAndSettle();
      expect(
        find.text('Could not open Google Play. Try again'),
        findsOneWidget,
      );
    });
  });

  group('FR6 feedback', () {
    for (final locale in testLocales) {
      testWidgets('subject and technical data are filled '
          '(${locale.toLanguageTag()})', (tester) async {
        await pumpSettings(tester, locale: locale);
        await tester.tap(find.byKey(const Key('settings-feedback')));
        await tester.pumpAndSettle();
        final l10n = lookupAppLocalizations(locale);
        final (subject, body) = emails.single;
        expect(subject, l10n.feedbackSubject);
        expect(body, contains(l10n.feedbackTechHeader));
        expect(body, contains('Vinoozy 0.4.0'));
        expect(body, contains('Google Pixel 8'));
        expect(body, contains('Android 15'));
        expect(body, endsWith(locale.toLanguageTag()));
        expect(find.byKey(const Key('feedback-no-email-dialog')), findsNothing);
      });
    }

    testWidgets('FR6.3 no email app: the address can be copied', (
      tester,
    ) async {
      emailOpens = false;
      final copied = <Object?>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') copied.add(call.arguments);
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await pumpSettings(tester);
      await tester.tap(find.byKey(const Key('settings-feedback')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('feedback-no-email-dialog')), findsOneWidget);
      expect(find.textContaining(supportEmail), findsOneWidget);
      await tester.tap(find.byKey(const Key('feedback-copy-address')));
      await tester.pumpAndSettle();
      expect(copied, [
        {'text': supportEmail},
      ]);
      expect(find.byKey(const Key('feedback-address-copied')), findsOneWidget);
      expect(find.byKey(const Key('feedback-no-email-dialog')), findsNothing);
    });

    testWidgets('FR6.3 the dialog closes without copying', (tester) async {
      emailOpens = false;
      await pumpSettings(tester);
      await tester.tap(find.byKey(const Key('settings-feedback')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('feedback-dialog-close')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('feedback-no-email-dialog')), findsNothing);
    });
  });

  testWidgets('FR2.4 "Show the guide again" clears the guide and goes back', (
    tester,
  ) async {
    await pumpScreen(tester, const _Launcher(), overrides: overrides());
    await tester.tap(find.byKey(const Key('open-settings')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('settings-screen')), findsOneWidget);

    await tester.tap(find.byKey(const Key('settings-guide')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('settings-screen')), findsNothing);
    expect(find.byKey(const Key('open-settings')), findsOneWidget);
    final guide = GuideStateStore(SharedPreferences.getInstance);
    expect(await guide.tourSeen(), isFalse);
    expect(await guide.hintSeen(GuideScreen.history), isFalse);
    expect(await guide.firstRunRecorded(), isTrue);
  });
}

Future<void> _noRetry() async {}
