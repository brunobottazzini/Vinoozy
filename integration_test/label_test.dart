// End-to-end test of the label photo (u6-label-recognition cicd-pipeline.md
// §1, job `e2e`; BR1.6-BR1.11, NFR1.2, NFR4.4, NFR7.4; label-recognition
// NFR4.3: front and back, a barcode only on the back, "Salta", candidates
// and the filled form, "Cerca online" without network, Google Lens
// cancelled) on the Android emulator with the Firebase Emulator Suite
// (demo-vinoozy), never the real project:
//
//   npx firebase emulators:exec --only auth,firestore --project demo-vinoozy \
//     "flutter test integration_test/label_test.dart -d <emulator-id> \
//      --dart-define=FIREBASE_ENV=demo --dart-define=E2E=true"
//
// One `testWidgets` per scenario (code-generation review R-01), each from a
// clean phone and clean emulators, so a failure names its scenario. The
// shared setup is [_LabelE2E].
//
// The images are drawn on the emulator at run time (no file in the
// repository or in the assets): label texts in black on white, a known
// EAN-13, and random bytes named .jpg. A fake image source hands them to
// the app in place of the system camera; they still go through the real
// channel to LabelImagePreparer and the real ML Kit. The offline wine
// database is the e2e one of support/e2e_wine_db.dart, built from rows of
// tool/fixtures/off_wines_sample.csv (8001234567897 is "Barolo Ravera
// 2016"), never the shipped asset, whose content changes at every release.
// Open Food Facts is a MockClient and Google Lens a recording fake: neither
// real service is ever called (NFR4.4).
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vinoozy/app/home_shell.dart';
import 'package:vinoozy/catalog/platform/catalog_providers.dart';
import 'package:vinoozy/label/label_providers.dart';
import 'package:vinoozy/label/ui/add_choice_screen.dart';
import 'package:vinoozy/label/ui/label_capture_flow.dart';
import 'package:vinoozy/sharing/sharing_providers.dart';

import 'e2e_helpers.dart';
import 'support/e2e_wine_db.dart';
import 'support/ean13_painter.dart';
import 'support/fake_image_source.dart';
import 'support/fake_label_services.dart';

/// NFR1.2 on the emulator: a wide limit, the emulator is slow.
const readingLimit = Duration(seconds: 15);

/// The app started and signed in, with the fake camera, the fake Open Food
/// Facts and the fake Lens above the real app services: what every
/// scenario shares.
class _LabelE2E {
  _LabelE2E._(this.tester, this.temp, this.shell, this.target);

  final WidgetTester tester;
  final Directory temp;
  final Finder shell;
  final LabelTarget target;
  final FakeImageSource source = FakeImageSource();
  final SwitchableNetwork network = SwitchableNetwork();
  final RecordingLensLauncher lens = RecordingLensLauncher();
  late final catalog = e2eCatalog(network);

  /// Open Food Facts requests of earlier scenarios are not this one's.
  final int requestsAtStart = offRequests.length;

  /// Clean phone and emulators, the real app, user A signed in.
  static Future<_LabelE2E> start(WidgetTester tester) async {
    await clearPhone();
    await clearEmulators();
    await launchApp(tester);
    await signIn(tester, userA, then: find.byKey(const Key('cellar-empty')));
    final temp = await getTemporaryDirectory();
    // skipOffstage: false, the shell stays under the pushed photo routes.
    final shell = find.byType(HomeShell, skipOffstage: false);
    final user = tester.widget<HomeShell>(shell).user;
    final container = ProviderScope.containerOf(tester.element(shell));
    final target = LabelTarget(
      user: user,
      cellar: container.read(activeCellarProvider(user)),
    );
    return _LabelE2E._(tester, temp, shell, target);
  }

  Future<String> drawPng(
    String name,
    ui.Size size,
    void Function(ui.Canvas canvas) draw,
  ) async {
    final path = '${temp.path}/$name';
    await tester.runAsync(() async {
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder)
        ..drawRect(
          ui.Offset.zero & size,
          ui.Paint()..color = const ui.Color(0xFFFFFFFF),
        );
      draw(canvas);
      final image = await recorder.endRecording().toImage(
        size.width.round(),
        size.height.round(),
      );
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      await File(path).writeAsBytes(bytes!.buffer.asUint8List());
    });
    return path;
  }

  /// A label with [text] in black on white. Each pick consumes its file
  /// (the preparer deletes the input): one file per photo.
  Future<String> drawText(String name, String text) =>
      drawPng(name, const ui.Size(1600, 1000), (canvas) {
        final painter = TextPainter(
          text: TextSpan(
            text: text,
            style: const TextStyle(color: Color(0xFF000000), fontSize: 140),
          ),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: 1500);
        painter.paint(canvas, const Offset(50, 300));
      });

  /// A front with "Barolo DOCG 2016" and no barcode.
  Future<String> front(String name) =>
      drawText('$name.png', 'Barolo DOCG 2016');

  /// A back with only the EAN-13 of [e2eBackWineName].
  Future<String> back(String name) => drawPng(
    '$name.png',
    const ui.Size(1000, 600),
    (canvas) =>
        paintEan13(canvas, e2eBackBarcode, origin: const Offset(120, 100)),
  );

  /// "Aggiungi" pushed above the shell, then "Scatta foto" with [path].
  Future<void> takePhoto(String path) async {
    unawaited(
      Navigator.of(tester.element(shell)).push(
        MaterialPageRoute<void>(
          builder: (_) => ProviderScope(
            overrides: [
              imageSourceProvider.overrideWithValue(source),
              lensLauncherProvider.overrideWithValue(lens),
              catalogProvider.overrideWithValue(catalog),
              wineDbLoaderProvider.overrideWithValue(e2eWineDb),
            ],
            child: AddChoiceScreen(target: target),
          ),
        ),
      ),
    );
    await waitFor(
      tester,
      find.byKey(const Key('add-choice-photo')),
      viaCellarTab: false,
    );
    source.nextPath = path;
    await tester.tap(find.byKey(const Key('add-choice-photo')));
  }

  /// Waits for [finder] within [readingLimit]; returns how long it took.
  Future<Duration> outcome(Finder finder) async {
    final stopwatch = Stopwatch()..start();
    await waitFor(tester, finder, viaCellarTab: false, timeout: readingLimit);
    return stopwatch.elapsed;
  }

  /// Taps [key] once scrolled into view: on the emulator's small screen
  /// the last buttons of an outcome are below the fold.
  Future<void> tapKey(String key) async {
    await tapVisible(tester, find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  /// A label nothing recognises, read without its back: "Non trovato".
  /// Since label-autofill-windows (BR2.1) the producer read in the text
  /// opens the form filled above "Non trovato"; back returns to it.
  Future<void> notFound(String name) async {
    await takePhoto(await drawText('$name.png', 'Cantina Inesistente'));
    await outcome(find.byKey(const Key('label-back-prompt')));
    await tapKey('label-back-skip');
    await outcome(find.byKey(const Key('autofill-toolbar')));
    // FR7.1, A19: the guide opens on the form of the photo; close it first.
    final closeGuide = find.byKey(const Key('guide-close'));
    if (closeGuide.evaluate().isNotEmpty) {
      await tapWhenHittable(tester, closeGuide);
      await tester.pumpAndSettle();
    }
    await tapWhenHittable(
      tester,
      find.descendant(
        of: find.byKey(const Key('add-wine-screen')),
        matching: find.byType(BackButton),
      ),
    );
    await tester.pumpAndSettle();
    await outcome(find.byKey(const Key('label-not-found-noMatch')));
  }

  /// Closes every outcome, then BR1.4, NFR3.4: no copy left in the label
  /// folder; [photos] photos taken; NFR4.4 only the MockClient saw the
  /// Open Food Facts requests.
  Future<void> finish({required int photos}) async {
    Navigator.of(tester.element(shell)).popUntil((route) => route.isFirst);
    await tester.pumpAndSettle();
    final folder = Directory('${temp.path}/label');
    await eventually(
      tester,
      () async => !folder.existsSync() || folder.listSync().isEmpty,
      reason: 'the label folder is empty',
    );
    expect(source.origins, hasLength(photos));
    expect(
      offRequests
          .skip(requestsAtStart)
          .every((uri) => uri.host == 'world.openfoodfacts.org'),
      isTrue,
      reason: 'only the MockClient saw them',
    );
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('NFR4.4 a damaged file is refused before the back is asked, '
      'no copy left', (tester) async {
    final e2e = await _LabelE2E.start(tester);
    final random = Random(42);
    final damaged = '${e2e.temp.path}/e2e-label-damaged.jpg';
    await File(damaged)
        .writeAsBytes([for (var i = 0; i < 8192; i++) random.nextInt(256)]);
    // Damaged bytes named .jpg: refused by the native preparer.
    await e2e.takePhoto(damaged);
    await e2e.outcome(find.byKey(const Key('label-not-found-unreadable')));
    await e2e.finish(photos: 1);
  });

  testWidgets('FR1.1 front and back, the barcode only on the back: a sure '
      'proposal from the offline database, saved through U4', (tester) async {
    final e2e = await _LabelE2E.start(tester);
    await e2e.takePhoto(await e2e.front('e2e-front-1'));
    await e2e.outcome(find.byKey(const Key('label-back-prompt')));
    e2e.source.nextPath = await e2e.back('e2e-back-1');
    await tester.tap(find.byKey(const Key('label-back-take')));
    final sureTime = await e2e.outcome(find.byKey(const Key('label-proposal')));
    expect(sureTime, lessThan(readingLimit));
    expect(find.text(e2eBackWineName), findsOneWidget);
    await e2e.tapKey('label-confirm');
    await waitFor(tester, wineRow(e2eBackWineName));
    await eventually(
      tester,
      () async => (await cloudWineNames(currentUid)).contains(e2eBackWineName),
      reason: 'the wine reached the Firestore emulator',
    );
    await e2e.finish(photos: 2);
  });

  testWidgets('FR1.1 "Salta": the front alone, the denomination is a '
      'candidate that opens the form filled, which saves', (tester) async {
    final e2e = await _LabelE2E.start(tester);
    await e2e.takePhoto(await e2e.front('e2e-front-2'));
    await e2e.outcome(find.byKey(const Key('label-back-prompt')));
    await e2e.tapKey('label-back-skip');
    await e2e.outcome(find.byKey(const Key('label-candidates')));
    await e2e.tapKey('label-candidate-0');
    await e2e.outcome(find.byKey(const Key('add-wine-screen')));
    expect(find.text('Barolo DOCG'), findsWidgets);
    expect(find.text('2016'), findsWidgets);
    await e2e.tapKey('add-wine-save-button');
    await waitFor(tester, wineRow('Barolo DOCG'));
    await e2e.finish(photos: 1);
  });

  testWidgets('FR3.4 no wine recognised: "Cerca online" without network '
      'searches only the database on the phone and says so, no request '
      'leaves', (tester) async {
    final e2e = await _LabelE2E.start(tester);
    // Offline from the reading on: a lookup made online would cache the
    // same words, and "Cerca online" would answer from that cache.
    e2e.network.online = false;
    final requestsBefore = offRequests.length;
    await e2e.notFound('e2e-front-3');
    await e2e.tapKey('label-search-online');
    await e2e.tapKey('online-search-submit');
    await e2e.outcome(find.byKey(const Key('online-search-offline')));
    expect(offRequests, hasLength(requestsBefore));
    // The app bar's back arrow ("pageBack" looks for the English
    // tooltip, the app runs in Italian here).
    await tapWhenHittable(
      tester,
      find.descendant(
        of: find.byKey(const Key('online-search-screen')),
        matching: find.byType(BackButton),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('label-not-found-noMatch')), findsOneWidget);
    await e2e.finish(photos: 1);
  });

  testWidgets('BR5.1 Google Lens: the confirmation is cancelled, nothing '
      'leaves', (tester) async {
    final e2e = await _LabelE2E.start(tester);
    await e2e.notFound('e2e-front-4');
    await e2e.tapKey('label-lens');
    await e2e.outcome(find.byKey(const Key('lens-confirm-sheet')));
    await e2e.tapKey('lens-cancel');
    expect(e2e.lens.paths, isEmpty);
    expect(find.byKey(const Key('label-not-found-noMatch')), findsOneWidget);
    await e2e.finish(photos: 1);
  });
}
