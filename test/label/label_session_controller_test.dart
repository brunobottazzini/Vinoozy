import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vinoozy/account/network_status.dart';
import 'package:vinoozy/catalog/core/wine_catalog.dart';
import 'package:vinoozy/label/core/label_reading.dart';
import 'package:vinoozy/label/core/label_session.dart';
import 'package:vinoozy/label/label_providers.dart';
import 'package:vinoozy/label/platform/shared_image_channel.dart';

import 'label_harness.dart';

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

  Future<void> start(LabelInput input) =>
      controller().start(input, locale: CatalogLocale.it);

  group('BR1.7 BR1.8 a reading from start to proposal', () {
    test('BR1.8 a picked photo is prepared, read, looked up; the copy is '
        'deleted (BR1.6)', () async {
      env.reader.reading = const LabelReading(
        text: 'Barolo DOCG 2016',
        barcodes: [ReadBarcode(LabelBarcodeFormat.ean13, testEan13)],
      );
      env.catalog.byBarcode = candidateOf('Barolo', producer: 'Cantina A');
      await start(const PickedLabelInput('/cache/1/pick.jpg'));
      final proposal = state() as LabelProposalState;
      expect(proposal.candidate.vintage, 2016);
      expect(proposal.offline, isFalse);
      expect(env.channel.prepared, ['/cache/1/pick.jpg']);
      expect(env.reader.paths.single, startsWith('/cache/label/'));
      expect(env.files.files, isEmpty, reason: 'copy released');
      expect(env.files.deleted, env.reader.paths);
    });

    test('BR1.4 a shared photo is read through the channel', () async {
      env.channel.pending = const SharedImageNotice(multiple: false);
      env.reader.reading = const LabelReading(text: 'Cantina del Lago');
      await start(const SharedLabelInput());
      expect(env.channel.readShareCalls, 1);
      expect(state(), isA<LabelIncompleteState>());
      expect(env.files.files, isEmpty);
    });

    test('BR1.9 without network the proposal says it is offline', () async {
      env.network.online = false;
      env.reader.reading = const LabelReading(text: 'Barolo DOCG');
      env.catalog.byText = LabelMatch.matched(candidateOf('Barolo DOCG'));
      await start(const PickedLabelInput('/p.jpg'));
      expect((state() as LabelProposalState).offline, isTrue);
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
  });

  group('BR1.11 BR1.14 failures become unreadable with a fixed reason', () {
    test('BR1.14 a refused image: pick failed with its code only', () async {
      env.channel.result = const RejectedImage('size');
      await start(const PickedLabelInput('/p.jpg'));
      expect(state(), isA<LabelUnreadableState>());
      expect(env.reasons, [pickFailed]);
      expect(
        env.sink.recorded.single.error.toString(),
        contains('LabelImageRejected'),
      );
      expect(env.reader.paths, isEmpty);
    });

    test('BR1.14 a missing share is a pick failure', () async {
      await start(const SharedLabelInput());
      expect(state(), isA<LabelUnreadableState>());
      expect(env.reasons, [pickFailed]);
    });

    test('BR1.14 a failing channel is a pick failure', () async {
      env.channel.prepareError = PlatformException(
        code: 'x',
        message: labelMarkers.last,
      );
      await start(const PickedLabelInput('/p.jpg'));
      expect(state(), isA<LabelUnreadableState>());
      expect(env.reasons, [pickFailed]);
      expect(env.reportsAreClean, isTrue);
    });

    test('BR1.11 a failing reader: read failed, no marker reaches a report '
        'nor the global handlers (NFR8.2)', () async {
      env.reader.error = StateError(labelMarkers.join(' '));
      await start(const PickedLabelInput('/p.jpg'));
      expect(state(), isA<LabelUnreadableState>());
      expect(env.reasons, [readFailed]);
      expect(env.reportsAreClean, isTrue);
      expect(globalErrors, isEmpty);
      expect(env.files.files, isEmpty, reason: 'copy released after error');
    });

    test('BR1.14 a failing catalog is reported as lookup failed', () async {
      env.reader.reading = const LabelReading(
        text: 'Cantina',
        barcodes: [ReadBarcode(LabelBarcodeFormat.ean13, testEan13)],
      );
      env.catalog.barcodeError = StateError(labelMarkers[1]);
      await start(const PickedLabelInput('/p.jpg'));
      await Future<void>.delayed(Duration.zero);
      expect(state(), isA<LabelIncompleteState>());
      expect(env.reasons, [lookupFailed]);
      expect(env.reportsAreClean, isTrue);
    });

    test('BR1.11 a failing network check counts as offline', () async {
      container.dispose();
      env = LabelEnv()..networkOverride = _ThrowingNetwork();
      env.reader.reading = const LabelReading(
        barcodes: [ReadBarcode(LabelBarcodeFormat.ean13, testEan13)],
      );
      container = ProviderContainer(overrides: env.overrides);
      subscription = container.listen(labelSessionProvider(1), (_, _) {});
      await start(const PickedLabelInput('/p.jpg'));
      expect((state() as LabelBarcodeOnlyState).needsNetwork, isTrue);
      expect(env.catalog.calls, 0);
      expect(env.reasons, isEmpty);
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
      expect(state(), isA<LabelUnreadableState>());
      expect(env.reasons, [pickFailed]);
    });
  });

  group('BR1.13 Annulla', () {
    test('BR1.13 cancelling ignores the late result, still deletes the copy, '
        'and a late error never reaches the global handlers', () async {
      env.reader
        ..gate = Completer<void>()
        ..error = StateError(labelMarkers.first);
      final reading = start(const PickedLabelInput('/p.jpg'));
      await Future<void>.delayed(Duration.zero);
      controller().cancel();
      expect(state(), isA<LabelCancelledState>());
      env.reader.gate!.complete();
      await reading;
      expect(state(), isA<LabelCancelledState>());
      expect(env.files.files, isEmpty);
      expect(env.reasons, [readFailed]);
      expect(env.reportsAreClean, isTrue);
      expect(globalErrors, isEmpty);
    });

    test('BR1.13 closing the screen mid-reading: the work ends quietly and '
        'the reader is closed', () async {
      env.reader.gate = Completer<void>();
      final reading = start(const PickedLabelInput('/p.jpg'));
      await Future<void>.delayed(Duration.zero);
      subscription.close();
      await Future<void>.delayed(Duration.zero);
      env.reader.gate!.complete();
      await reading;
      await Future<void>.delayed(Duration.zero);
      expect(env.reader.closeCount, 1);
      expect(env.files.files, isEmpty);
      expect(globalErrors, isEmpty);
    });

    test('BR1.4 a second reading makes the first stale', () async {
      final slow = Completer<void>();
      env.reader
        ..gate = slow
        ..reading = const LabelReading(text: 'Primo vino');
      final first = start(const PickedLabelInput('/a.jpg'));
      await Future<void>.delayed(Duration.zero);
      expect(env.reader.paths, hasLength(1), reason: 'first one reading');
      env.reader.gate = null;
      env.reader.reading = const LabelReading(text: 'Secondo vino');
      await start(const PickedLabelInput('/b.jpg'));
      expect((state() as LabelIncompleteState).name, 'Secondo vino');
      env.reader.reading = const LabelReading(text: 'Primo vino');
      slow.complete();
      await first;
      expect((state() as LabelIncompleteState).name, 'Secondo vino');
      expect(env.files.files, isEmpty, reason: 'both copies released');
    });
  });

  group('BR1.8 Riprova quando torna la rete', () {
    test('BR1.8 the code kept in memory is looked up again', () async {
      env.network.online = false;
      env.reader.reading = const LabelReading(
        barcodes: [ReadBarcode(LabelBarcodeFormat.ean13, testEan13)],
      );
      await start(const PickedLabelInput('/p.jpg'));
      expect((state() as LabelBarcodeOnlyState).needsNetwork, isTrue);
      env.network.online = true;
      env.catalog.byBarcode = candidateOf('Barolo');
      await controller().retryBarcode();
      expect((state() as LabelProposalState).candidate.name, 'Barolo');
      expect(env.channel.prepared, hasLength(1), reason: 'no new photo');
      await controller().retryBarcode();
      expect(
        env.catalog.barcodeCalls,
        hasLength(1),
        reason: 'not barcode only',
      );
    });
  });
}

class _ThrowingNetwork implements NetworkStatus {
  @override
  Future<bool> hasNetwork() async => throw StateError('connectivity');

  @override
  Stream<bool> get onChanged => const Stream.empty();
}
