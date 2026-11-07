// End-to-end test of the label photo (u6-label-recognition cicd-pipeline.md
// §1, job `e2e`; BR1.6-BR1.11, NFR1.2, NFR4.4, NFR7.4) on the Android
// emulator with the Firebase Emulator Suite (demo-vinoozy), never the real
// project:
//
//   npx firebase emulators:exec --only auth,firestore --project demo-vinoozy \
//     "flutter test integration_test/label_test.dart \
//      --dart-define=FIREBASE_ENV=demo --dart-define=E2E=true"
//
// The images are drawn on the emulator at run time (no file in the
// repository or in the assets): "Barolo DOCG 2016" in black on white, a
// known EAN-13, and random bytes named .jpg. A fake image source hands them
// to the app in place of the system camera; they still go through the real
// channel to LabelImagePreparer and the real ML Kit. The demo build has no
// Open Food Facts contact, so the catalog is internal only: Open Food
// Facts is never called.
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
import 'package:vinoozy/label/label_providers.dart';
import 'package:vinoozy/label/ui/add_choice_screen.dart';
import 'package:vinoozy/label/ui/label_capture_flow.dart';
import 'package:vinoozy/sharing/sharing_providers.dart';

import 'e2e_helpers.dart';
import 'support/ean13_painter.dart';
import 'support/fake_image_source.dart';

/// NFR1.2 on the emulator: a wide limit, the emulator is slow.
const readingLimit = Duration(seconds: 10);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<String> drawPng(
    WidgetTester tester,
    Directory dir,
    String name,
    ui.Size size,
    void Function(ui.Canvas canvas) draw,
  ) async {
    final path = '${dir.path}/$name';
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

  testWidgets('label photo: text read and saved through U4, barcode read, '
      'damaged file refused, no copy left', (tester) async {
    await clearPhone();
    await clearEmulators();
    await launchApp(tester);
    await signIn(tester, userA, then: find.byKey(const Key('cellar-empty')));

    final temp = await getTemporaryDirectory();
    final label = await drawPng(
      tester,
      temp,
      'e2e-label-text.png',
      const ui.Size(1600, 1000),
      (canvas) {
        final painter = TextPainter(
          text: const TextSpan(
            text: 'Barolo DOCG 2016',
            style: TextStyle(color: Color(0xFF000000), fontSize: 140),
          ),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: 1500);
        painter.paint(canvas, const Offset(50, 400));
      },
    );
    final barcode = await drawPng(
      tester,
      temp,
      'e2e-label-barcode.png',
      const ui.Size(1000, 600),
      (canvas) =>
          paintEan13(canvas, '8001234567897', origin: const Offset(120, 100)),
    );
    final random = Random(42);
    final damaged = '${temp.path}/e2e-label-damaged.jpg';
    await File(damaged)
        .writeAsBytes([for (var i = 0; i < 8192; i++) random.nextInt(256)]);

    // "Aggiungi" with the fake camera, above the real app services.
    final source = FakeImageSource();
    // skipOffstage: false, the shell stays under the pushed photo routes.
    final shell = find.byType(HomeShell, skipOffstage: false);
    final user = tester.widget<HomeShell>(shell).user;
    final container = ProviderScope.containerOf(tester.element(shell));
    final target = LabelTarget(
      user: user,
      cellar: container.read(activeCellarProvider(user)),
    );
    Future<void> takePhoto(String path) async {
      unawaited(
        Navigator.of(tester.element(shell)).push(
          MaterialPageRoute<void>(
            builder: (_) => ProviderScope(
              overrides: [imageSourceProvider.overrideWithValue(source)],
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

    Future<Duration> outcome(Finder finder) async {
      final stopwatch = Stopwatch()..start();
      await waitFor(tester, finder, viaCellarTab: false, timeout: readingLimit);
      return stopwatch.elapsed;
    }

    void backToShell() =>
        Navigator.of(tester.element(shell)).popUntil((route) => route.isFirst);

    // Damaged bytes named .jpg: refused by the native preparer (NFR4.4).
    await takePhoto(damaged);
    await outcome(find.byKey(const Key('label-unreadable')));
    backToShell();
    await tester.pumpAndSettle();

    // A barcode only: read by ML Kit; no Open Food Facts in the demo build,
    // so "Ho letto il codice a barre ma non trovo il vino".
    await takePhoto(barcode);
    final barcodeTime = await outcome(
      find.byKey(const Key('label-barcode-only')),
    );
    expect(barcodeTime, lessThan(readingLimit));
    backToShell();
    await tester.pumpAndSettle();

    // Text: the internal catalog recognises the denomination; "Conferma"
    // saves through U4 and the wine reaches the Firestore emulator.
    await takePhoto(label);
    final textTime = await outcome(find.byKey(const Key('label-proposal')));
    expect(textTime, lessThan(readingLimit));
    expect(find.textContaining('Barolo'), findsWidgets);
    await tester.tap(find.byKey(const Key('label-confirm')));
    await waitFor(tester, wineRow('Barolo DOCG'));
    await eventually(
      tester,
      () async => (await cloudWineNames(currentUid)).contains('Barolo DOCG'),
      reason: 'the wine reached the Firestore emulator',
    );

    // BR1.6: no copy left in the label folder.
    final folder = Directory('${temp.path}/label');
    await eventually(
      tester,
      () async => !folder.existsSync() || folder.listSync().isEmpty,
      reason: 'the label folder is empty',
    );
    expect(source.origins, hasLength(3));
  });
}
