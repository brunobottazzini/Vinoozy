// LabelSessionController (u6 BR1.4-BR1.14; label-recognition F1, BR1.1,
// BR1.4-BR1.6, BR3.5, BR5.2, NFR3.4, NFR4.11, NFR4.13): every fake of
// LabelEnv, no ML Kit, no Open Food Facts, no Google app.
import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/catalog/core/catalog_event_logger.dart';
import 'package:vinoozy/catalog/core/wine_catalog.dart';
import 'package:vinoozy/label/core/label_lookup_flow.dart';
import 'package:vinoozy/label/core/label_merge.dart';
import 'package:vinoozy/label/core/label_reading.dart';
import 'package:vinoozy/label/core/label_session.dart';
import 'package:vinoozy/label/label_providers.dart';
import 'package:vinoozy/label/platform/picker_image_source.dart';
import 'package:vinoozy/label/platform/shared_image_channel.dart';

import 'label_harness.dart';

/// A reader answering by path: the front and the back read differently.
class _ByPathReader extends FakeLabelReader {
  final Map<String, LabelReading> byPath = {};
  final Set<String> failing = {};

  @override
  Future<LabelReading> read(String imagePath) async {
    paths.add(imagePath);
    if (failing.contains(imagePath)) throw StateError(labelMarkers.first);
    return byPath[imagePath] ?? reading;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late LabelEnv env;
  late ProviderContainer container;
  late ProviderSubscription<LabelState> subscription;
  late List<Object> globalErrors;
  late FlutterExceptionHandler? previousFlutterHandler;
  late ErrorCallback? previousPlatformHandler;

  setUp(() {
    env = LabelEnv();
    container = ProviderContainer(overrides: env.overrides);
    subscription = container.listen(labelSessionProvider(1), (_, _) {});
    globalErrors = [];
    previousFlutterHandler = FlutterError.onError;
    previousPlatformHandler = PlatformDispatcher.instance.onError;
    FlutterError.onError = (details) => globalErrors.add(details.exception);
    PlatformDispatcher.instance.onError = (error, _) {
      globalErrors.add(error);
      return true;
    };
  });

  tearDown(() {
    FlutterError.onError = previousFlutterHandler;
    PlatformDispatcher.instance.onError = previousPlatformHandler;
    container.dispose();
  });

  LabelSessionController controller() =>
      container.read(labelSessionProvider(1).notifier);
  LabelState state() => container.read(labelSessionProvider(1));

  Future<void> start(LabelInput input) => controller().start(
    input,
    locale: CatalogLocale.it,
    services: LabelServices(
      source: env.source,
      lens: env.lens,
      catalog: env.catalog,
    ),
  );

  /// The front, then "Salta".
  Future<void> frontOnly(LabelInput input) async {
    await start(input);
    await controller().skipBack();
  }

  /// Closes the screen and lets the background work end.
  Future<void> closeScreen() async {
    subscription.close();
    for (var i = 0; i < 5; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  group('BR1.1 "Ora il retro"', () {
    test('BR1.1 the prepared front leads to the back prompt', () async {
      await start(const PickedLabelInput('/cache/1/pick.jpg'));
      expect(state(), isA<LabelBackPromptState>());
      expect(env.channel.prepared, ['/cache/1/pick.jpg']);
      expect(env.reader.paths, isEmpty, reason: 'nothing read yet');
      expect(controller().frontPath, startsWith('/cache/label/'));
    });

    test('BR1.1 FR1.2 a back from the camera: both read, barcode only on '
        'the back used (BR1.3)', () async {
      final reader = _ByPathReader();
      env.reader = reader;
      reader.byPath['/cache/label/prepared-1.jpg'] = const LabelReading(
        text: 'Barolo Ravera',
      );
      reader.byPath['/cache/label/prepared-2.jpg'] = const LabelReading(
        text: 'Elvio Cogno',
        barcodes: [ReadBarcode(LabelBarcodeFormat.ean13, testEan13)],
      );
      env.catalog.byLabel = sureMatch(candidateOf('Barolo Ravera'));
      await start(const PickedLabelInput('/p.jpg'));
      env.source.outcome = const PickedImage('/cache/2/back.jpg');
      await controller().takeBack(PhotoOrigin.camera);
      expect(env.source.origins, [PhotoOrigin.camera]);
      expect(env.channel.prepared, ['/p.jpg', '/cache/2/back.jpg']);
      expect(env.catalog.textCalls.single, 'Barolo Ravera\nElvio Cogno');
      expect(env.catalog.labelBarcodes.single, testEan13);
      final proposal = state() as LabelProposalState;
      expect(proposal.backStatus, BackStatus.taken);
    });

    test('BR1.6 NFR4.11 a cancelled or denied back is "Salta"', () async {
      for (final outcome in [const PickCancelled(), const PickDenied()]) {
        env.reader.reading = const LabelReading(text: 'Cantina del Lago');
        await start(const PickedLabelInput('/p.jpg'));
        env.source.outcome = outcome;
        await controller().takeBack(PhotoOrigin.gallery);
        final notFound = state() as LabelNotFoundState;
        expect(notFound.kind, NotFoundKind.noMatch);
        expect(notFound.backStatus, BackStatus.skipped);
      }
      expect(env.reasons, isEmpty);
    });

    test('BR1.5 a back that cannot be read: the front goes on, "Retro non '
        'leggibile"', () async {
      env.reader.reading = const LabelReading(text: 'Barolo');
      await start(const PickedLabelInput('/p.jpg'));
      env.source.outcome = const PickedImage('/back.jpg');
      env.channel.result = const RejectedImage('decode');
      await controller().takeBack(PhotoOrigin.camera);
      final notFound = state() as LabelNotFoundState;
      expect(notFound.backStatus, BackStatus.unreadable);
      expect(env.reasons, [pickFailed]);
      expect(env.catalog.textCalls.single, 'Barolo');
    });

    test(
      'BR1.14 a failing picker for the back is reported and skipped',
      () async {
        env.reader.reading = const LabelReading(text: 'Barolo');
        await start(const PickedLabelInput('/p.jpg'));
        env.source.outcome = PickFailed(StateError('x'), StackTrace.current);
        await controller().takeBack(PhotoOrigin.camera);
        expect(state(), isA<LabelNotFoundState>());
        expect(env.reasons, [pickFailed]);
      },
    );

    test('takeBack and skipBack outside the back prompt do nothing', () async {
      await controller().skipBack();
      await controller().takeBack(PhotoOrigin.camera);
      expect(state(), isA<LabelIdle>());
      expect(env.source.origins, isEmpty);
    });
  });

  group('BR1.7 BR1.8 a reading from start to outcome', () {
    test('BR1.8 a picked photo is prepared, read, looked up; NFR4.13 the '
        'outcome is logged with its step', () async {
      env.reader.reading = const LabelReading(
        text: 'Barolo DOCG 2016',
        barcodes: [ReadBarcode(LabelBarcodeFormat.ean13, testEan13)],
      );
      env.catalog.byLabel = sureMatch(
        candidateOf('Barolo', producer: 'Cantina A'),
        step: LabelMatchStep.offlineBarcode,
      );
      await frontOnly(const PickedLabelInput('/cache/1/pick.jpg'));
      final proposal = state() as LabelProposalState;
      expect(proposal.candidate.vintage, 2016);
      expect(env.reader.paths.single, startsWith('/cache/label/'));
      expect(env.logger.labelOutcomes.single, (
        LabelOutcomeKind.sure,
        LabelMatchStep.offlineBarcode,
      ));
    });

    test('BR1.4 a shared photo is read through the channel', () async {
      env.channel.pending = const SharedImageNotice(multiple: false);
      env.reader.reading = const LabelReading(text: 'Cantina del Lago');
      await frontOnly(const SharedLabelInput());
      expect(env.channel.readShareCalls, 1);
      expect(state(), isA<LabelNotFoundState>());
    });

    test('BR1.6 the reading waits for the start-up cleanup', () async {
      env.files
        ..add('/cache/label/left.jpg', env.clock.current)
        ..listGate = Completer<void>();
      startLabelCleanup(container);
      final reading = start(const PickedLabelInput('/p.jpg'));
      await Future<void>.delayed(Duration.zero);
      expect(env.channel.prepared, isEmpty, reason: 'still cleaning');
      env.files.listGate!.complete();
      await reading;
      expect(env.channel.prepared, ['/p.jpg']);
      expect(env.source.lostDataCalls, 1);
      expect(env.files.deleted, contains('/cache/label/left.jpg'));
    });

    test('BR3.5 "Non è questo" and "Nessuno di questi"', () async {
      env.reader.reading = const LabelReading(text: 'Barolo');
      env.catalog.byLabel = sureMatch(
        candidateOf('Barolo Ravera'),
        others: [candidateOf('Barolo Bussia')],
      );
      await frontOnly(const PickedLabelInput('/p.jpg'));
      controller().notThis();
      expect(
        (state() as LabelCandidatesState).candidates.single.name,
        'Barolo Bussia',
      );
      controller().noneOfThese();
      expect((state() as LabelNotFoundState).kind, NotFoundKind.noMatch);
    });
  });

  group('BR1.4 FR1.3 photos kept while the outcome is open', () {
    test('NFR3.4 the copies stay during the outcome and go when the screen '
        'closes', () async {
      env.reader = _ByPathReader();
      await start(const PickedLabelInput('/p.jpg'));
      env.source.outcome = const PickedImage('/back.jpg');
      await controller().takeBack(PhotoOrigin.gallery);
      expect(env.files.files, hasLength(2), reason: 'front and back held');
      await closeScreen();
      expect(env.files.files, isEmpty);
    });

    test('BR1.6 Annulla while waiting for the back deletes the front once '
        'the screen closes', () async {
      await start(const PickedLabelInput('/p.jpg'));
      controller().cancel();
      expect(state(), isA<LabelCancelledState>());
      await closeScreen();
      expect(env.files.files, isEmpty);
    });

    test('BR1.4 a second reading makes the first stale and deletes its '
        'copy', () async {
      env.reader.reading = const LabelReading(text: 'Primo vino');
      await frontOnly(const PickedLabelInput('/a.jpg'));
      env.reader.reading = const LabelReading(text: 'Secondo vino');
      await frontOnly(const PickedLabelInput('/b.jpg'));
      await Future<void>.delayed(Duration.zero);
      expect((state() as LabelNotFoundState).outcome.name, 'Secondo vino');
      expect(env.files.files, hasLength(1), reason: 'only the current front');
    });
  });

  group('BR5.2 Google Lens', () {
    test(
      'BR5.2 only the prepared front is handed over; NFR4.13 logged',
      () async {
        env.reader.reading = const LabelReading(text: 'Château Musar');
        await frontOnly(const PickedLabelInput('/p.jpg'));
        env.lens.route = LensRoute.chooser;
        expect(await controller().openLens(), LensRoute.chooser);
        expect(env.lens.paths.single, controller().frontPath);
        expect(env.lens.paths.single, startsWith('/cache/label/'));
        expect(env.logger.lensRoutes, [LensRoute.chooser]);
      },
    );

    test('NFR4.10 without a photo Lens fails, nothing is sent', () async {
      expect(await controller().openLens(), LensRoute.failed);
      expect(env.lens.paths, isEmpty);
    });
  });

  group('BR1.11 BR1.14 failures become unreadable with a fixed reason', () {
    test('BR1.14 a refused image: pick failed with its code only', () async {
      env.channel.result = const RejectedImage('size');
      await start(const PickedLabelInput('/p.jpg'));
      expect((state() as LabelNotFoundState).kind, NotFoundKind.unreadable);
      expect(env.reasons, [pickFailed]);
      expect(
        env.sink.recorded.single.error.toString(),
        contains('LabelImageRejected'),
      );
      expect(env.reader.paths, isEmpty);
    });

    test('BR1.14 a missing share is a pick failure', () async {
      await start(const SharedLabelInput());
      expect(state(), isA<LabelNotFoundState>());
      expect(env.reasons, [pickFailed]);
    });

    test('BR1.14 a failing channel is a pick failure', () async {
      env.channel.prepareError = PlatformException(
        code: 'x',
        message: labelMarkers.last,
      );
      await start(const PickedLabelInput('/p.jpg'));
      expect(state(), isA<LabelNotFoundState>());
      expect(env.reasons, [pickFailed]);
      expect(env.reportsAreClean, isTrue);
    });

    test('BR1.11 a failing reader: read failed, no marker reaches a report '
        'nor the global handlers (NFR8.2)', () async {
      env.reader.error = StateError(labelMarkers.join(' '));
      await frontOnly(const PickedLabelInput('/p.jpg'));
      expect((state() as LabelNotFoundState).kind, NotFoundKind.unreadable);
      expect(env.reasons, [readFailed]);
      expect(env.reportsAreClean, isTrue);
      expect(globalErrors, isEmpty);
      expect(env.catalog.calls, 0);
    });

    test('BR1.14 a failing catalog is reported as lookup failed', () async {
      env.reader.reading = const LabelReading(
        text: 'Cantina',
        barcodes: [ReadBarcode(LabelBarcodeFormat.ean13, testEan13)],
      );
      env.catalog.textError = StateError(labelMarkers[1]);
      await frontOnly(const PickedLabelInput('/p.jpg'));
      await Future<void>.delayed(Duration.zero);
      expect(state(), isA<LabelNotFoundState>());
      expect(env.reasons, [lookupFailed]);
      expect(env.reportsAreClean, isTrue);
    });

    test('BR1.5 denied access, no camera and a failed picker', () async {
      await start(const DeniedLabelInput(PhotoOrigin.camera));
      expect(
        (state() as LabelPermissionDeniedState).origin,
        PhotoOrigin.camera,
      );
      await start(const CameraUnavailableLabelInput());
      expect(state(), isA<LabelCameraUnavailableState>());
      await start(FailedPickLabelInput(StateError('x'), StackTrace.current));
      expect(state(), isA<LabelNotFoundState>());
      expect(env.reasons, [pickFailed]);
    });
  });

  group('BR1.13 Annulla', () {
    test('BR1.13 cancelling ignores the late result, still deletes the '
        'copies, and a late error never reaches the global handlers', () async {
      env.reader
        ..gate = Completer<void>()
        ..error = StateError(labelMarkers.first);
      await start(const PickedLabelInput('/p.jpg'));
      final reading = controller().skipBack();
      await Future<void>.delayed(Duration.zero);
      controller().cancel();
      expect(state(), isA<LabelCancelledState>());
      env.reader.gate!.complete();
      await reading;
      expect(state(), isA<LabelCancelledState>());
      expect(env.reasons, [readFailed]);
      expect(env.reportsAreClean, isTrue);
      await closeScreen();
      expect(env.files.files, isEmpty);
      expect(globalErrors, isEmpty);
    });

    test('BR1.13 closing the screen mid-reading: the work ends quietly and '
        'the reader is closed', () async {
      env.reader.gate = Completer<void>();
      await start(const PickedLabelInput('/p.jpg'));
      final reading = controller().skipBack();
      await Future<void>.delayed(Duration.zero);
      subscription.close();
      await Future<void>.delayed(Duration.zero);
      env.reader.gate!.complete();
      await reading;
      for (var i = 0; i < 5; i++) {
        await Future<void>.delayed(Duration.zero);
      }
      expect(env.reader.closeCount, 1);
      expect(env.files.files, isEmpty);
      expect(globalErrors, isEmpty);
    });
  });
}
