// Shared fakes and factories of the u4-cellar tests (unit-test-instructions.md
// of u4-cellar): fictitious users with @example.com addresses, synthetic wines
// and drinks, a network whose changes the test drives, a recording ErrorSink
// (test/helpers/fakes.dart), a recording WriteBatch and document references.
// No test uses the real Firebase project or Open Food Facts.
//
// The SDK marks these types @sealed to discourage implementations in app
// code. Test doubles of the adapters' dependencies are the documented
// exception; nothing in lib/ implements them.
// ignore_for_file: subtype_of_sealed_class
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:estimation/estimation.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinoozy/account/app_user.dart';
import 'package:vinoozy/account/network_status.dart';
import 'package:vinoozy/app/error_reporter.dart';
import 'package:vinoozy/catalog/core/wine_catalog.dart';
import 'package:vinoozy/catalog/platform/catalog_providers.dart';
import 'package:vinoozy/cellar/cellar_actions.dart';
import 'package:vinoozy/cellar/cellar_maintenance.dart';
import 'package:vinoozy/cellar/cellar_providers.dart';
import 'package:vinoozy/cellar/data/drinking_record_repository.dart';
import 'package:vinoozy/cellar/data/match_key_backfill.dart';
import 'package:vinoozy/cellar/data/record_reconciler.dart';
import 'package:vinoozy/cellar/domain/drinking_record.dart';
import 'package:vinoozy/cellar/domain/window_adjuster.dart';
import 'package:vinoozy/cellar/domain/wine.dart';
import 'package:vinoozy/cellar/domain/wine_estimate.dart';
import 'package:vinoozy/cellar/domain/wine_validator.dart';
import 'package:vinoozy/core/clock.dart';
import 'package:vinoozy/sharing/domain/membership.dart';

const cellarOwner = AppUser(
  uid: 'user-a',
  email: 'mario@example.com',
  displayName: 'Mario',
);

const cellarEditor = AppUser(
  uid: 'user-c',
  email: 'luca@example.com',
  displayName: 'Luca',
);

/// The personal cellar of [cellarOwner].
const ownerCellar = AccessibleCellar(
  cellarId: 'user-a',
  ownerId: 'user-a',
  ownerName: 'Mario',
  role: CellarRole.owner,
);

/// Mario's cellar seen by a person with "can edit".
const editCellar = AccessibleCellar(
  cellarId: 'user-a',
  ownerId: 'user-a',
  ownerName: 'Mario',
  role: CellarRole.edit,
);

/// Mario's cellar seen by a person with "read only".
const readCellar = AccessibleCellar(
  cellarId: 'user-a',
  ownerId: 'user-a',
  ownerName: 'Mario',
  role: CellarRole.read,
);

/// A window as U4 stores it.
DrinkingWindow windowOf(
  int start,
  int peak,
  int end, {
  Confidence confidence = Confidence.medium,
  WindowSource source = WindowSource.internalRules,
  EstimationBasis basis = EstimationBasis.denomination,
}) => DrinkingWindow(
  startYear: start,
  peakYear: peak,
  endYear: end,
  confidence: confidence,
  source: source,
  basis: basis,
);

/// A wine built with the real [Wine] constructor, so a change of its shape
/// breaks the factory too.
Wine cellarWine(
  String id, {
  String name = 'Barolo',
  int? vintage = 2016,
  int quantity = 2,
  String? producer = 'Cantina Esempio',
  String? wineType = 'redStructured',
  String? region,
  String? denomination,
  DrinkingWindow? window,
  DrinkingWindow? baseWindow,
  WindowAdjustment? adjustment,
  Pairings? pairings,
  String? matchKey,
  DateTime? createdAt,
  String? country,
  WineLevel? level,
  WindowOverride? windowOverride,
  DateTime? updatedAt,
  WineStyle? style,
  FieldSource? typeSource,
  FieldSource? levelSource,
  FieldSource? styleSource,
  AgingStart? agingStart,
  int? migrationVersion,
}) => Wine(
  id: id,
  name: name,
  vintage: vintage,
  storedQuantity: quantity,
  producer: producer,
  wineType: wineType,
  region: region,
  denomination: denomination,
  country: country,
  window: window,
  baseWindow: baseWindow,
  windowAdjustment: adjustment,
  pairings: pairings,
  matchKey: matchKey,
  createdAt: createdAt,
  level: level,
  windowOverride: windowOverride,
  updatedAt: updatedAt,
  style: style,
  typeSource: typeSource,
  levelSource: levelSource,
  styleSource: styleSource,
  agingStart: agingStart,
  migrationVersion: migrationVersion,
);

/// A drink built with the real [DrinkingRecord] constructor.
DrinkingRecord drinkRecord(
  String id, {
  String wineId = 'w1',
  String wineName = 'Barolo',
  int? vintage = 2016,
  DateTime? drankOn,
  String recordedBy = 'user-a',
  int? rating,
  String? notes,
  DrinkCondition? condition,
  DateTime? createdAt,
}) => DrinkingRecord(
  id: id,
  wineId: wineId,
  wineName: wineName,
  vintage: vintage,
  drankOn: drankOn ?? DateTime(2026, 11, 6),
  recordedBy: recordedBy,
  rating: rating,
  notes: notes,
  condition: condition,
  createdAt: createdAt,
);

/// A network whose state and changes the test drives (`onChanged`).
class FakeCellarNetwork implements NetworkStatus {
  FakeCellarNetwork({this._online = true});

  bool _online;
  final StreamController<bool> _changes = StreamController<bool>.broadcast();

  bool get online => _online;

  set online(bool value) {
    _online = value;
    _changes.add(value);
  }

  @override
  Future<bool> hasNetwork() async => _online;

  @override
  Stream<bool> get onChanged => _changes.stream;
}

/// A document reference that only knows its path, so batch operations can be
/// checked by path.
class FakeDocRef extends Fake
    implements DocumentReference<Map<String, dynamic>> {
  FakeDocRef(this.path);

  @override
  final String path;

  @override
  String get id => path.split('/').last;

  @override
  String toString() => 'FakeDocRef($path)';
}

/// One operation written into a [RecordingBatch].
class BatchOp {
  const BatchOp(this.kind, this.path, [this.data]);

  /// `set`, `update` or `delete`.
  final String kind;
  final String path;
  final Map<String, Object?>? data;

  @override
  String toString() => 'BatchOp($kind $path)';
}

/// A [WriteBatch] that records its operations; [commit] returns [result],
/// which the test completes (or fails) when it wants.
class RecordingBatch extends Fake implements WriteBatch {
  final List<BatchOp> ops = [];
  Completer<void> result = Completer<void>();
  bool committed = false;

  @override
  void set<T>(DocumentReference<T> document, T data, [SetOptions? options]) =>
      ops.add(
        BatchOp('set', document.path, Map<String, Object?>.from(data as Map)),
      );

  @override
  void update<T>(DocumentReference<T> document, T data) => ops.add(
    BatchOp('update', document.path, {
      for (final entry in (data as Map).entries)
        entry.key as String: entry.value,
    }),
  );

  @override
  void delete(DocumentReference document) =>
      ops.add(BatchOp('delete', document.path));

  @override
  Future<void> commit() {
    committed = true;
    return result.future;
  }

  BatchOp opAt(String path) => ops.singleWhere((op) => op.path == path);
}

/// Wires `db.doc()` to [FakeDocRef]s and `db.batch()` to [RecordingBatch]es.
/// [commitWith] decides how each new batch's commit ends; by default it
/// succeeds at once.
class BatchRecorder {
  BatchRecorder(this.db, {this.commitWith}) {
    when(() => db.doc(any())).thenAnswer(
      (invocation) =>
          FakeDocRef(invocation.positionalArguments.single as String),
    );
    when(() => db.batch()).thenAnswer((_) {
      final batch = RecordingBatch();
      final decide = commitWith;
      if (decide == null) {
        batch.result.complete();
      } else {
        decide(batches.length, batch.result);
      }
      batches.add(batch);
      return batch;
    });
  }

  final FirebaseFirestore db;

  /// Called with the index of each new batch and its commit completer.
  void Function(int index, Completer<void> result)? commitWith;
  final List<RecordingBatch> batches = [];

  RecordingBatch get single => batches.single;
}

/// A query snapshot of [docs] (`id` → data) with optional metadata.
QuerySnapshot<Map<String, dynamic>> querySnapshotOf(
  Map<String, Map<String, dynamic>> docs, {
  bool fromCache = false,
  bool pending = false,
}) {
  final snapshot = _MockQuerySnapshot();
  final list = [
    for (final entry in docs.entries) queryDocOf(entry.key, entry.value),
  ];
  when(() => snapshot.docs).thenReturn(list);
  final meta = _MockMetadata();
  when(() => meta.isFromCache).thenReturn(fromCache);
  when(() => meta.hasPendingWrites).thenReturn(pending);
  when(() => snapshot.metadata).thenReturn(meta);
  return snapshot;
}

QueryDocumentSnapshot<Map<String, dynamic>> queryDocOf(
  String id,
  Map<String, dynamic> data,
) {
  final doc = _MockQueryDoc();
  when(() => doc.id).thenReturn(id);
  when(() => doc.data()).thenReturn(data);
  return doc;
}

class MockQuery extends Mock implements Query<Map<String, dynamic>> {}

class _MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

class _MockQueryDoc extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {}

class _MockMetadata extends Mock implements SnapshotMetadata {}

class MockDrinkingRecordRepository extends Mock
    implements DrinkingRecordRepository {}

class MockMatchKeyBackfill extends Mock implements MatchKeyBackfill {}

class MockCellarActions extends Mock implements CellarActions {}

class MockCellarMaintenance extends Mock implements CellarMaintenance {}

/// The wine catalog of U3 without Open Food Facts: answers set by the test,
/// calls counted.
class FakeWineCatalog implements WineCatalog {
  List<WineCandidate> internal = const [];
  List<WineCandidate> external = const [];
  WineProfileResult profile = const WineProfileResult(found: false);

  /// Profile answers by wine name; [profile] otherwise.
  final Map<String, WineProfileResult> profiles = {};

  /// Wine names whose profile request throws.
  final Set<String> failingNames = {};
  final List<String> suggestQueries = [];
  final List<String> externalQueries = [];
  final List<String> profileNames = [];
  List<CellarWineRef>? lastCellarWines;

  @override
  SuggestResult suggestWines(
    String query, {
    CatalogLocale locale = CatalogLocale.en,
    List<CellarWineRef>? cellarWines,
  }) {
    suggestQueries.add(query);
    lastCellarWines = cellarWines;
    return SuggestResult(suggestions: internal, externalIncluded: false);
  }

  @override
  Future<SuggestResult> suggestExternal(
    String query, {
    CatalogLocale locale = CatalogLocale.en,
  }) async {
    externalQueries.add(query);
    return SuggestResult(suggestions: external, externalIncluded: true);
  }

  @override
  Future<WineProfileResult> getWineProfile(
    String name, {
    String? producer,
    int? vintage,
  }) async {
    profileNames.add(name);
    if (failingNames.contains(name)) throw StateError('catalog down');
    return profiles[name] ?? profile;
  }

  /// The answer to a label text (label-autofill-windows BR2.2); nothing by
  /// default.
  LabelMatchResult labelMatch = const LabelMatchResult.none();
  final List<String> labelTexts = [];

  /// Holds [matchLabel] until completed: a catalog that never answers in
  /// time (offline database opening, slow Open Food Facts).
  Completer<void>? labelGate;

  @override
  Future<LabelMatchResult> matchLabel(
    String text, {
    String? barcode,
    CatalogLocale locale = CatalogLocale.en,
  }) async {
    labelTexts.add(text);
    final gate = labelGate;
    if (gate != null) await gate.future;
    return labelMatch;
  }

  @override
  Future<OnlineSearchResult> searchOnline(
    String query, {
    CatalogLocale locale = CatalogLocale.en,
  }) async =>
      const OnlineSearchResult(candidates: [], status: OnlineSearchStatus.ok);

  @override
  Future<WineCandidate?> lookupBarcode(String code) async => null;
}

/// Fallback values for `any()` of the cellar mocks.
void registerCellarFallbacks() {
  registerFallbackValue(cellarOwner);
  registerFallbackValue(ownerCellar);
  registerFallbackValue(cellarWine('fallback'));
  registerFallbackValue(drinkRecord('fallback'));
  registerFallbackValue(WineEstimate.none);
  registerFallbackValue(windowOf(2020, 2024, 2030));
  registerFallbackValue(DrinkCondition.justRight);
  registerFallbackValue(DateTime(2026));
  registerFallbackValue(RecordsSource.serverOrCache);
  registerFallbackValue(<Wine>[]);
  registerFallbackValue(
    WineValidator.validate(
      const WineInput(
        id: 'fallback',
        name: 'x',
        vintage: '',
        noVintage: true,
        quantity: 1,
      ),
      currentYear: 2026,
    ).draft!,
  );
}

/// Safe defaults for every u4-cellar service a screen may read: a fake
/// catalog, mocked drinks, backfill and maintenance (doing nothing) and a
/// real reconciler on mock preferences. Tests of other units add them to
/// their overrides so the HomeShell and the screens build.
List<Override> cellarServiceOverrides({
  FakeWineCatalog? catalog,
  MockDrinkingRecordRepository? records,
  MockCellarMaintenance? maintenance,
}) {
  registerCellarFallbacks();
  final drinks = records ?? MockDrinkingRecordRepository();
  if (records == null) {
    when(
      () => drinks.recordsOfWine(any(), any(), source: any(named: 'source')),
    ).thenAnswer((_) async => const WineRecords(records: [], fromServer: true));
  }
  final background = maintenance ?? MockCellarMaintenance();
  if (maintenance == null) {
    when(() => background.run(any(), any(), any()))
        .thenAnswer((_) async => false);
  }
  return [
    catalogProvider.overrideWithValue(catalog ?? FakeWineCatalog()),
    drinkingRecordRepositoryProvider.overrideWithValue(drinks),
    matchKeyBackfillProvider.overrideWithValue(MockMatchKeyBackfill()),
    recordReconcilerProvider.overrideWithValue(
      RecordReconciler(
        preferences: SharedPreferences.getInstance,
        clock: const SystemClock(),
        reporter: ErrorReporter(const DebugLogSink(), log: (_) {}),
      ),
    ),
    cellarMaintenanceProvider.overrideWithValue(background),
  ];
}

/// Markers of sensitive values: none of them may reach the ErrorSink
/// (NFR8.2).
const sensitiveMarkers = [
  'MARKER-NAME-1234',
  'MARKER-PRODUCER-5678',
  'MARKER-DENOMINATION-9',
  'MARKER-NOTES-4321',
];
