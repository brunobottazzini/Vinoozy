// Fakes of the label photo (u6-label-recognition unit-test-instructions.md):
// the reader, the catalog, the image source, the temporary folder, the
// shared-image channel, the network and the error sink. No test uses ML Kit,
// Open Food Facts or a Firebase project.
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:vinoozy/account/app_user.dart';
import 'package:vinoozy/account/gate_state.dart';
import 'package:vinoozy/account/network_status.dart';
import 'package:vinoozy/app/providers.dart';
import 'package:vinoozy/catalog/core/wine_catalog.dart';
import 'package:vinoozy/catalog/platform/catalog_providers.dart';
import 'package:vinoozy/label/label_providers.dart';
import 'package:vinoozy/label/platform/label_error_reporter.dart';

import '../catalog/catalog_test_helpers.dart' show RecordingLogger;
import '../cellar/cellar_harness.dart' show FakeCellarNetwork;
import '../helpers/fakes.dart';

import 'package:vinoozy/label/core/label_reading.dart';
import 'package:vinoozy/label/core/label_session.dart';
import 'package:vinoozy/label/core/lens_launcher.dart';
import 'package:vinoozy/label/platform/picker_image_source.dart';
import 'package:vinoozy/label/platform/shared_image_channel.dart';
import 'package:vinoozy/label/platform/temp_label_store.dart';

/// A valid EAN-13 test code (check digit 7) and a valid EAN-8 (check 4).
const testEan13 = '8001234567897';
const testEan8 = '96385074';

/// A UPC-A code (12 digits); its EAN-13 form has a leading zero.
const testUpcA = '036000291452';

/// Markers that must never reach a report (NFR8.2).
const labelMarkers = [
  'MARKER-LABEL-TEXT-777',
  'MARKER-BARCODE-888',
  '/MARKER/PATH/999.jpg',
];

/// A candidate from the catalog.
WineCandidate candidateOf(
  String name, {
  String? producer,
  int? vintage,
  CatalogWineType? wineType,
  String? region,
  String? denomination,
  CandidateSource source = CandidateSource.openFoodFacts,
}) => WineCandidate(
  name: name,
  source: source,
  producer: producer,
  vintage: vintage,
  wineType: wineType,
  region: region,
  denomination: denomination,
);

/// A [LabelReader] whose answers the test chooses. [gate] holds the answer
/// until the test completes it (a slow reading, for "Annulla").
class FakeLabelReader implements LabelReader {
  FakeLabelReader({this.reading = const LabelReading(), this.error});

  LabelReading reading;
  Object? error;
  Completer<void>? gate;
  final List<String> paths = [];
  int closeCount = 0;

  @override
  Future<LabelReading> read(String imagePath) async {
    paths.add(imagePath);
    final wait = gate;
    if (wait != null) await wait.future;
    final failure = error;
    if (failure != null) throw failure;
    return reading;
  }

  @override
  Future<void> close() async => closeCount++;
}

/// A sure answer of [WineCatalog.matchLabel] for [candidate].
LabelMatchResult sureMatch(
  WineCandidate candidate, {
  List<WineCandidate> others = const [],
  LabelMatchStep step = LabelMatchStep.offlineText,
}) => LabelMatchResult.sure(candidate, step: step, candidates: others);

/// A candidates answer of [WineCatalog.matchLabel].
LabelMatchResult candidatesMatch(
  List<WineCandidate> candidates, {
  LabelMatchStep step = LabelMatchStep.offlineText,
}) => LabelMatchResult.candidates(candidates, step: step);

/// A [WineCatalog] for the label flow: chosen answers, counted calls, and
/// failures on demand. [matchLabel] and [searchOnline] are what the label
/// module uses (label-recognition); the other operations answer empty.
class LabelCatalog implements WineCatalog {
  WineCandidate? byBarcode;

  /// The answer of [matchLabel].
  LabelMatchResult byLabel = const LabelMatchResult.none();
  Object? textError;

  /// Holds [matchLabel] until completed: a catalog that is slow to answer
  /// (offline database opening, slow network).
  Completer<void>? labelGate;
  final List<String> barcodeCalls = [];
  final List<String> textCalls = [];
  final List<String?> labelBarcodes = [];
  final List<CatalogLocale> textLocales = [];

  /// The answer of [searchOnline], and the queries received.
  OnlineSearchResult searchResult = const OnlineSearchResult(
    candidates: [],
    status: OnlineSearchStatus.ok,
  );
  Completer<void>? searchGate;
  final List<String> searchCalls = [];

  int get calls => barcodeCalls.length + textCalls.length;

  @override
  Future<WineCandidate?> lookupBarcode(String code) async {
    barcodeCalls.add(code);
    return byBarcode;
  }

  @override
  Future<LabelMatchResult> matchLabel(
    String text, {
    String? barcode,
    CatalogLocale locale = CatalogLocale.en,
  }) async {
    textCalls.add(text);
    labelBarcodes.add(barcode);
    textLocales.add(locale);
    final gate = labelGate;
    if (gate != null) await gate.future;
    final failure = textError;
    if (failure != null) throw failure;
    return byLabel;
  }

  @override
  Future<OnlineSearchResult> searchOnline(
    String query, {
    CatalogLocale locale = CatalogLocale.en,
  }) async {
    searchCalls.add(query);
    final wait = searchGate;
    if (wait != null) await wait.future;
    return searchResult;
  }

  @override
  SuggestResult suggestWines(
    String query, {
    CatalogLocale locale = CatalogLocale.en,
    List<CellarWineRef>? cellarWines,
  }) => SuggestResult.empty;

  @override
  Future<SuggestResult> suggestExternal(
    String query, {
    CatalogLocale locale = CatalogLocale.en,
  }) async => SuggestResult.empty;

  @override
  Future<WineProfileResult> getWineProfile(
    String name, {
    String? producer,
    int? vintage,
  }) async => const WineProfileResult(found: false);
}

/// The label folder in memory: paths with their modification time, and
/// deletions that can fail on demand.
class InMemoryLabelFileSystem implements LabelFileSystem {
  final Map<String, DateTime> files = {};
  final List<String> deleted = [];

  /// Paths whose deletion throws.
  final Set<String> undeletable = {};

  /// When set, [list] waits for it (a slow start-up cleanup).
  Completer<void>? listGate;

  void add(String path, DateTime modified) => files[path] = modified;

  @override
  Future<List<LabelFileEntry>> list() async {
    final gate = listGate;
    if (gate != null) await gate.future;
    return [
      for (final entry in files.entries) LabelFileEntry(entry.key, entry.value),
    ];
  }

  @override
  Future<void> delete(String path) async {
    if (undeletable.contains(path)) {
      throw StateError('cannot delete ${labelMarkers.last}');
    }
    files.remove(path);
    deleted.add(path);
  }
}

/// An [ImageSource] with the outcome chosen by the test.
class FakeImageSource implements ImageSource {
  FakeImageSource([this.outcome = const PickCancelled()]);

  PickOutcome outcome;
  final List<PhotoOrigin> origins = [];
  int lostDataCalls = 0;
  Object? lostDataError;

  @override
  Future<PickOutcome> pick(PhotoOrigin origin) async {
    origins.add(origin);
    return outcome;
  }

  @override
  Future<void> discardLostData() async {
    lostDataCalls++;
    final failure = lostDataError;
    if (failure != null) throw failure;
  }
}

/// The native label channel, answered by the test. Prepared images are
/// "written" into [files] (when given) so the cleanup can be checked.
class FakeSharedImageChannel implements SharedImageChannel {
  FakeSharedImageChannel({this.files, this.folder = '/cache/label'});

  final InMemoryLabelFileSystem? files;
  final String folder;
  final StreamController<SharedImageNotice> _arrivals =
      StreamController<SharedImageNotice>.broadcast();

  /// The answer to [prepare] and [readShare]; `null` prepares a new file.
  PrepareResult? result;
  SharedImageNotice? pending;
  Object? prepareError;

  /// When set, [prepare] and [readShare] wait for it.
  Completer<void>? gate;
  final List<String> prepared = [];
  int readShareCalls = 0;
  int discardCalls = 0;
  int settingsCalls = 0;
  int _next = 0;

  void arrive({bool multiple = false}) {
    pending = SharedImageNotice(multiple: multiple);
    _arrivals.add(SharedImageNotice(multiple: multiple));
  }

  /// The text of a "Share -> Vinoozy" from Lens (label-autofill-windows).
  String? sharedText;
  int readTextCalls = 0;

  void arriveText(String text) {
    sharedText = text;
    pending = const SharedImageNotice(multiple: false, isText: true);
    _arrivals.add(const SharedImageNotice(multiple: false, isText: true));
  }

  @override
  Future<String?> readSharedText() async {
    readTextCalls++;
    final text = sharedText;
    sharedText = null;
    pending = null;
    return text;
  }

  Future<PrepareResult> _answer() async {
    final wait = gate;
    if (wait != null) await wait.future;
    final failure = prepareError;
    if (failure != null) throw failure;
    final chosen = result;
    if (chosen != null) return chosen;
    final path = '$folder/prepared-${++_next}.jpg';
    files?.add(path, DateTime(2026, 11, 6, 20));
    return PreparedImage(path);
  }

  @override
  Stream<SharedImageNotice> get arrivals => _arrivals.stream;

  @override
  Future<PrepareResult> prepare(String path) {
    prepared.add(path);
    return _answer();
  }

  /// When set, [pendingShare] throws it.
  Object? pendingError;

  @override
  Future<SharedImageNotice?> pendingShare() async {
    final failure = pendingError;
    if (failure != null) throw failure;
    return pending;
  }

  @override
  Future<PrepareResult?> readShare() async {
    readShareCalls++;
    if (pending == null) return null;
    pending = null;
    return _answer();
  }

  @override
  Future<void> discardShare() async {
    discardCalls++;
    pending = null;
  }

  @override
  Future<bool> openSettings() async {
    settingsCalls++;
    return true;
  }

  @override
  void dispose() => unawaited(_arrivals.close());
}

/// The `vinoozy/lens` launcher, answered by the test; never the real Google
/// app (label-recognition NFR4.4).
class FakeLensLauncher implements LensLauncher {
  LensRoute route = LensRoute.direct;
  final List<String> paths = [];

  @override
  Future<LensRoute> open(String path) async {
    paths.add(path);
    return route;
  }
}

/// The signed-in user of the label tests.
const labelUser = AppUser(
  uid: 'user-a',
  email: 'a@example.com',
  displayName: 'Anna',
);

/// Every fake of the label photo, wired as provider overrides.
class LabelEnv {
  LabelEnv() {
    channel = FakeSharedImageChannel(files: files);
  }

  final files = InMemoryLabelFileSystem();
  late final FakeSharedImageChannel channel;

  /// Replaceable before the first reading (a reader answering by path).
  FakeLabelReader reader = FakeLabelReader();
  final catalog = LabelCatalog();
  final source = FakeImageSource();
  final network = FakeCellarNetwork();
  final lens = FakeLensLauncher();
  final logger = RecordingLogger();
  final sink = RecordingErrorSink();
  final clock = FakeClock(DateTime(2026, 11, 6, 20));
  final gate = ValueNotifier<GateState>(const GateCellar(labelUser));
  int readersCreated = 0;

  /// Replaces [network] when set (a failing connectivity check).
  NetworkStatus? networkOverride;

  List<Override> get overrides => [
    errorReporterProvider.overrideWithValue(recordingReporter(sink)),
    clockProvider.overrideWithValue(clock),
    networkStatusProvider.overrideWithValue(networkOverride ?? network),
    catalogProvider.overrideWithValue(catalog),
    ...labelOnlyOverrides,
  ];

  /// Only the label providers, to add to another harness (the shell).
  List<Override> get labelOnlyOverrides => [
    labelFileSystemProvider.overrideWithValue(files),
    lensLauncherProvider.overrideWithValue(lens),
    catalogEventLoggerProvider.overrideWithValue(logger),
    sharedImageChannelProvider.overrideWithValue(channel),
    imageSourceProvider.overrideWithValue(source),
    labelReaderFactoryProvider.overrideWithValue(() {
      readersCreated++;
      return reader;
    }),
  ];

  /// The label reasons recorded by the error sink.
  List<String> get reasons => sink.reasons;

  /// True when no recorded error carries one of [labelMarkers].
  bool get reportsAreClean => sink.recorded.every(
    (recorded) => labelMarkers.every(
      (marker) =>
          !recorded.error.toString().contains(marker) &&
          !recorded.reason.contains(marker),
    ),
  );
}

/// The fixed reasons, for readable expectations.
final String readFailed = LabelFailure.readFailed.reason;
final String pickFailed = LabelFailure.pickFailed.reason;
final String lookupFailed = LabelFailure.lookupFailed.reason;
final String cleanupFailed = LabelFailure.cleanupFailed.reason;
