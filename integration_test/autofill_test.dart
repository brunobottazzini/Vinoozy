// End-to-end test of the form filled from a label text (label-autofill-
// windows NFR5.4; FR2.2, FR2.4, FR2.6, FR2.7, FR4.3, BR2.2, BR2.6, BR4.3)
// on the Android emulator with the Firebase Emulator Suite (demo-vinoozy),
// never the real project:
//
//   npx firebase emulators:exec --only auth,firestore --project demo-vinoozy \
//     "flutter test integration_test/autofill_test.dart -d <emulator-id> \
//      --dart-define=FIREBASE_ENV=demo --dart-define=E2E=true"
//
// The clipboard and Google Lens are fakes (no real Google app, no real
// clipboard, NFR3.1); the catalog is the app one without network, so Open
// Food Facts is never called, and with the e2e offline database of
// support/e2e_wine_db.dart, never the shipped asset. Everything else is the real app: the form,
// the extractor, the estimate with the world tables, the save through the
// ledger and the real security rules on the emulator.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:vinoozy/app/home_shell.dart';
import 'package:vinoozy/catalog/core/catalog_cache_store.dart';
import 'package:vinoozy/catalog/core/catalog_config.dart';
import 'package:vinoozy/catalog/core/catalog_coordinator.dart';
import 'package:vinoozy/catalog/core/catalog_event_logger.dart';
import 'package:vinoozy/catalog/core/internal_catalog.dart';
import 'package:vinoozy/catalog/core/off/open_food_facts_source.dart';
import 'package:vinoozy/catalog/core/off_circuit_breaker.dart';
import 'package:vinoozy/catalog/core/request_budget.dart';
import 'package:vinoozy/catalog/platform/wine_db_loader.dart';
import 'package:vinoozy/core/clock.dart';
import 'package:vinoozy/catalog/platform/catalog_providers.dart';
import 'package:vinoozy/cellar/ui/add_wine_screen.dart';
import 'package:vinoozy/label/autofill_providers.dart';
import 'package:vinoozy/label/core/lens_session.dart';
import 'package:vinoozy/label/core/text_autofill.dart';
import 'package:vinoozy/label/platform/lens_channel.dart';
import 'package:vinoozy/sharing/sharing_providers.dart';

import 'e2e_helpers.dart';
import 'support/fake_label_services.dart';

/// The clipboard of the test.
class _FakeClipboard implements ClipboardReader {
  String? text;
  int reads = 0;

  @override
  Future<String?> readText() async {
    reads++;
    return text;
  }
}

/// Google Lens and the clipboard description of the test.
class _FakeLensCamera implements LensCamera {
  LensCameraOpening opening = LensCameraOpening.unavailable;
  ClipInfo? clip;
  final StreamController<void> focus = StreamController<void>.broadcast();

  @override
  Future<LensCameraOpening> openLensCamera() async => opening;

  @override
  Future<ClipInfo?> clipTimestamp() async => clip;

  @override
  Stream<void> get windowFocused => focus.stream;
}

class _AutofillE2E {
  _AutofillE2E._(this.tester, this.shell);

  final WidgetTester tester;
  final Finder shell;
  final _FakeClipboard clipboard = _FakeClipboard();
  final _FakeLensCamera camera = _FakeLensCamera();
  final SwitchableNetwork network = SwitchableNetwork()..online = false;

  static Future<_AutofillE2E> start(WidgetTester tester) async {
    await clearPhone();
    await clearEmulators();
    await launchApp(tester);
    await signIn(tester, userA, then: find.byKey(const Key('cellar-empty')));
    return _AutofillE2E._(tester, find.byType(HomeShell, skipOffstage: false));
  }

  /// The add form pushed above the shell, with the fakes; with
  /// [realClipboard] the system clipboard is read; [overrides] are added.
  Future<void> openForm({
    bool openLens = false,
    bool realClipboard = false,
    TextAutofillFlow? textFlow,
    List<Override> overrides = const [],
  }) async {
    final user = tester.widget<HomeShell>(shell).user;
    final container = ProviderScope.containerOf(tester.element(shell));
    final cellar = container.read(activeCellarProvider(user));
    final catalog = e2eCatalog(network);
    unawaited(
      Navigator.of(tester.element(shell)).push(
        MaterialPageRoute<void>(
          builder: (_) => ProviderScope(
            overrides: [
              clipboardReaderProvider.overrideWithValue(
                realClipboard ? const FlutterClipboardReader() : clipboard,
              ),
              lensCameraProvider.overrideWithValue(camera),
              catalogProvider.overrideWithValue(catalog),
              wineDbLoaderProvider.overrideWithValue(e2eWineDb),
              // The text flow of the root scope keeps the root catalog: it
              // is overridden here too, so the paste really looks up the
              // e2e database (label-autofill-windows Step 21).
              textAutofillFlowProvider.overrideWithValue(
                textFlow ??
                    TextAutofillFlow(
                      catalog: catalog,
                      currentYear: () => DateTime.now().year,
                    ),
              ),
              ...overrides,
            ],
            child: AddWineScreen(
              user: user,
              cellarId: cellar.cellarId,
              cellar: cellar,
              openLensOnStart: openLens,
            ),
          ),
        ),
      ),
    );
    await waitFor(
      tester,
      find.byKey(const Key('add-wine-screen')),
      viaCellarTab: false,
    );
  }

  String fieldText(String key) =>
      tester.widget<TextField>(find.byKey(Key(key))).controller!.text;

  /// The cloud document of the wine named [name], once it is there.
  Future<Map<String, Object?>> cloudWine(String name) async {
    Map<String, Object?>? found;
    await eventually(tester, () async {
      for (final doc in await cloudWineDocuments(currentUid)) {
        if (restValue(doc['name']) == name) found = doc;
      }
      return found != null;
    }, reason: '$name reached the Firestore emulator');
    return found!;
  }
}

/// The catalog of the phone build: the shipped offline database (opened
/// cold at the first paste), Open Food Facts on, a network, and an Open
/// Food Facts that never answers before its own deadline, as on a slow
/// mobile network. Never the real service.
CatalogCoordinator _phoneCatalog(WineDbLoader wineDb, List<Uri> offRequests) {
  const logger = ConsoleCatalogEventLogger(debugLogging: false);
  const clock = SystemClock();
  final health = CatalogHealth();
  return CatalogCoordinator(
    internal: InternalCatalog.build(),
    cache: CatalogCacheStore(
      file: MemoryCacheFile(),
      clock: clock,
      health: health,
      logger: logger,
    ),
    budget: RequestBudget(clock),
    breaker: OffCircuitBreaker(clock: clock, logger: logger, health: health),
    logger: logger,
    offSource: Future.value(
      OpenFoodFactsSource(
        client: MockClient((request) async {
          offRequests.add(request.url);
          await Future<void>.delayed(const Duration(seconds: 30));
          return http.Response('{"count": 0, "products": []}', 200);
        }),
        config: const CatalogConfig(
          appVersion: 'e2e',
          offContact: 'e2e.invalid',
        ),
      ),
    ),
    wineDb: wineDb.openDb,
    network: SwitchableNetwork(),
  );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('"Incolla da Lens" with the real clipboard, the shipped '
      'database opened cold and an Open Food Facts that never answers: '
      'a visible result within 2 s, every time', (tester) async {
    final e2e = await _AutofillE2E.start(tester);
    final offRequests = <Uri>[];
    final wineDb = WineDbLoader(
      logger: const ConsoleCatalogEventLogger(debugLogging: false),
    );
    await e2e.openForm(
      realClipboard: true,
      textFlow: TextAutofillFlow(
        catalog: _phoneCatalog(wineDb, offRequests),
        currentYear: () => DateTime.now().year,
      ),
    );
    final snackbar = find.byKey(const Key('autofill-snackbar'));
    final sureMatch = find.byKey(const Key('autofill-sure-match'));
    // FR2.8: the first question of the guide is a result too (FR7.1).
    final guide = find.byKey(const Key('guide-sheet'));

    /// Pastes [text] through the system clipboard and returns how long the
    /// result took to show; fails past 2 s.
    Future<Duration> pasteAndTime(String text) async {
      await Clipboard.setData(ClipboardData(text: text));
      await tapVisible(tester, find.byKey(const Key('autofill-paste')));
      final watch = Stopwatch()..start();
      while (watch.elapsed < const Duration(seconds: 2)) {
        await tester.pump(const Duration(milliseconds: 50));
        if (snackbar.evaluate().isNotEmpty ||
            sureMatch.evaluate().isNotEmpty ||
            guide.evaluate().isNotEmpty) {
          return watch.elapsed;
        }
      }
      throw TestFailure('no visible result 2 s after "Incolla da Lens"');
    }

    // Cold: the database opens while the person waits; a long text with
    // no wine of the database also asks Open Food Facts, which hangs.
    final unknown = [
      'Fattoria Inventata',
      'Morellino di Scansano',
      'Denominazione di Origine Controllata e Garantita',
      '2021',
      for (var i = 0; i < 20; i++)
        'Vino ottenuto da uve selezionate, affinato in botti di rovere.',
    ].join('\n');
    await pasteAndTime(unknown);
    // FR7.1, BR7.8: the uncertain name is not filled; the first question
    // of the guide is the result shown.
    expect(guide, findsOneWidget);
    expect(find.byKey(const Key('guide-proposal')), findsOneWidget);
    expect(e2e.fieldText('add-wine-vintage-field'), '2021');
    // The lookup goes on in the background: the opening ends, then Open
    // Food Facts is asked and hangs, with the form already filled.
    expect(await wineDb.open(), isA<WineDbReady>());
    await eventually(
      tester,
      () async => offRequests.isNotEmpty,
      reason: 'Open Food Facts asked after the paste answered',
    );

    // Warm: the label copied in Lens is a wine of the shipped database.
    // FR7.7: the guide closes first, "Pulisci" is under it.
    await tapVisible(tester, find.byKey(const Key('guide-close')));
    await tapVisible(tester, find.byKey(const Key('autofill-clear')));
    await waitFor(
      tester,
      find.byKey(const Key('autofill-paste')),
      viaCellarTab: false,
    );
    await tester.pump(const Duration(seconds: 1));
    await pasteAndTime(
      "CASCINA CASTLET\nBarbera d'Asti\nDenominazione di Origine "
      'Controllata e Garantita\n2019\n14% vol\n75 cl',
    );
    expect(sureMatch, findsOneWidget);
    expect(find.text("Barbera D'Asti"), findsWidgets);
  });

  testWidgets('FR2.2 "Incolla da Lens": the text fills the empty fields, '
      'the wine is saved with the appellation estimate', (tester) async {
    final e2e = await _AutofillE2E.start(tester);
    await e2e.openForm();
    e2e.clipboard.text = 'Barolo Vietti\n2019';
    await tapVisible(tester, find.byKey(const Key('autofill-paste')));
    await waitFor(
      tester,
      find.byKey(const Key('autofill-toolbar')),
      viaCellarTab: false,
    );
    expect(e2e.clipboard.reads, 1);
    expect(e2e.fieldText('add-wine-name-field'), 'Barolo Vietti');
    expect(e2e.fieldText('add-wine-denomination'), 'Barolo DOCG');
    expect(e2e.fieldText('add-wine-vintage-field'), '2019');
    await tapVisible(tester, find.byKey(const Key('add-wine-save-button')));
    await waitFor(tester, wineRow('Barolo Vietti'));
    final doc = await e2e.cloudWine('Barolo Vietti');
    expect(restValue(doc['denomination']), 'Barolo DOCG');
    expect(restValue(doc['vintage']), 2019);
    expect(restValue(doc['country']), 'IT');
    expect(doc.containsKey('level'), isFalse, reason: 'BR4.3 not chosen');
    final window = restValue(doc['window'])! as Map;
    expect(window['basis'], 'denomination');
    expect(window['denominationKey'], 'barolo');
    expect(window['tablesVersion'], 2);
  });

  testWidgets('FR7 the guided check on the Cascina Castlet text: No, '
      'words, Edit, the wheel; then Yes, Skip, Back and a new text with the '
      'guide open (NFR5.8)', (tester) async {
    final e2e = await _AutofillE2E.start(tester);
    await e2e.openForm();
    Finder key(String value) => find.byKey(Key(value));
    Finder word(String text) =>
        find.descendant(of: key('guide-words'), matching: find.text(text));

    // "Question N of T" in any language of the device.
    Future<void> waitQuestion(int n, int total) => waitFor(
      tester,
      find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            widget.key == const Key('guide-progress') &&
            RegExp('\\b$n\\D+$total\\b').hasMatch(widget.data ?? ''),
      ),
      viaCellarTab: false,
    );
    Future<void> settle() => tester.pump(const Duration(milliseconds: 600));

    e2e.clipboard.text = "CASCINA CASTLET\nBarbera d'Asti Superiore";
    await tapVisible(tester, key('autofill-paste'));
    await waitQuestion(1, 3);
    expect(e2e.fieldText('add-wine-denomination'), "Barbera d'Asti DOCG");
    expect(e2e.fieldText('add-wine-producer'), isEmpty);

    // Producer: "No" on the only candidate, then composed with two words.
    await tapVisible(tester, key('guide-no'));
    await waitFor(tester, key('guide-notice'), viaCellarTab: false);
    await tapVisible(tester, word('CASTLET'));
    await tapVisible(tester, word('CASCINA'));
    await tapVisible(tester, key('guide-compose-confirm'));
    await waitQuestion(2, 3);
    expect(e2e.fieldText('add-wine-producer'), 'Cascina Castlet');

    // Name: "Modifica" with a value typed on the keyboard.
    await tapVisible(tester, key('guide-edit'));
    await tester.enterText(key('guide-edit-field'), 'Superiore Vigna Alta');
    await tapVisible(tester, key('guide-edit-confirm'));
    await waitFor(tester, key('guide-wheel'), viaCellarTab: false);
    expect(e2e.fieldText('add-wine-name-field'), 'Superiore Vigna Alta');

    // Vintage: the number pad of the wheel, then "Conferma".
    await tapVisible(tester, key('guide-wheel-type'));
    await tester.enterText(key('guide-year-field'), '2019');
    await tapVisible(tester, key('guide-year-ok'));
    await tapVisible(tester, key('guide-wheel-confirm'));
    await settle();
    expect(key('guide-sheet'), findsNothing);
    expect(e2e.fieldText('add-wine-vintage-field'), '2019');

    // A second text after "Pulisci" (it asks first: Edit wrote by hand):
    // Yes, Skip, then Back closes the sheet before the form (A19).
    await tapVisible(tester, key('autofill-clear'));
    await tapVisible(tester, key('clear-form-confirm'));
    await settle();
    e2e.clipboard.text =
        'Señorío de Valcuerna\nGarnacha Viñas Viejas 2019\nNavarra\n'
        'Edición 2021';
    await tapVisible(tester, key('autofill-paste'));
    await waitQuestion(1, 4);
    await tapVisible(tester, key('guide-yes'));
    await waitQuestion(2, 4);
    expect(e2e.fieldText('add-wine-denomination'), 'Navarra');
    await tapVisible(tester, key('guide-skip'));
    await waitQuestion(3, 4);
    await tester.binding.handlePopRoute();
    await settle();
    expect(key('guide-sheet'), findsNothing);
    expect(key('add-wine-screen'), findsOneWidget);

    // "Conferma guidata" reopens what is left; a new text with the guide
    // open closes it, keeps the answers and asks its own questions.
    await tapVisible(tester, key('autofill-guide'));
    await waitQuestion(1, 3);
    final form = tester.state(find.byType(AddWineScreen));
    await (form as dynamic).applySharedText('Barolo Vietti');
    await settle();
    expect(e2e.fieldText('add-wine-denomination'), 'Navarra');
    expect(e2e.fieldText('add-wine-name-field'), 'Barolo Vietti');
    // Only its vintage is asked: the denomination has its answer.
    await waitQuestion(1, 1);
    expect(key('guide-wheel'), findsOneWidget);
    await tapVisible(tester, key('guide-close'));
    await settle();

    // "Salva": nothing was saved before it (FR7.6).
    await tapVisible(tester, key('add-wine-no-vintage-switch'));
    await tapVisible(tester, key('add-wine-save-button'));
    await waitFor(tester, wineRow('Barolo Vietti'));
    final doc = await e2e.cloudWine('Barolo Vietti');
    expect(restValue(doc['denomination']), 'Navarra');
  });

  testWidgets('FR2.6 FR2.7 "Da Google Lens" and the paste on the way back: '
      'the "Riserva" suggestion is accepted on Save (BR4.3)', (tester) async {
    final e2e = await _AutofillE2E.start(tester);
    final openedAt = DateTime.now().millisecondsSinceEpoch - 1000;
    e2e.camera.opening = LensCameraOpening(
      LensCameraRoute.lensApp,
      openedAt: openedAt,
    );
    await e2e.openForm(openLens: true);
    await tester.pump(const Duration(milliseconds: 300));
    // Copied in Lens after it opened; then the window gets the focus back.
    e2e.camera.clip = ClipInfo(timestamp: openedAt + 500, mime: 'text/plain');
    e2e.clipboard.text = 'Chianti Classico Riserva\n2018';
    e2e.camera.focus.add(null);
    await waitFor(
      tester,
      find.byKey(const Key('wine-level-reason')),
      viaCellarTab: false,
    );
    expect(e2e.clipboard.reads, 1);
    expect(e2e.fieldText('add-wine-name-field'), 'Chianti Classico Riserva');
    // The same clip is never pasted twice.
    e2e.camera.focus.add(null);
    await tester.pump(const Duration(milliseconds: 500));
    expect(e2e.clipboard.reads, 1);
    await tapVisible(tester, find.byKey(const Key('add-wine-save-button')));
    await waitFor(tester, wineRow('Chianti Classico Riserva'));
    final doc = await e2e.cloudWine('Chianti Classico Riserva');
    expect(restValue(doc['level']), 'aging');
    expect(restValue(doc['denomination']), 'Chianti Classico DOCG');
    final window = restValue(doc['window'])! as Map;
    expect(window['qualifier'], 'riserva');
  });
}
