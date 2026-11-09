// What the one-off migration writes on a wine (wine-style-profiles BR7.4,
// BR7.2, BR7.5, BR4.1): sources, preselection of the empty fields, style,
// the estimate with the profiles, the corrections kept.
import 'package:estimation/estimation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinoozy/cellar/cellar_actions.dart';
import 'package:vinoozy/cellar/data/record_reconciler.dart';
import 'package:vinoozy/cellar/data/wine_repository.dart';
import 'package:vinoozy/cellar/estimate_refresher.dart';
import 'package:vinoozy/sync/sync_error_bus.dart';
import 'package:vinoozy/cellar/domain/drinking_record.dart';
import 'package:vinoozy/cellar/domain/window_adjuster.dart';
import 'package:vinoozy/cellar/domain/wine.dart';
import 'package:vinoozy/cellar/domain/wine_classification.dart';
import 'package:vinoozy/cellar/estimates_migration.dart';

import '../helpers/fakes.dart';
import 'cellar_harness.dart';

final _now = DateTime(2026, 11, 9);

class _Repo extends Mock implements WineRepository {}

/// The repository is never called by fieldsOf.
EstimatesMigration _migration() => EstimatesMigration(
  wines: _Repo(),
  reporter: recordingReporter(RecordingErrorSink()),
  clock: FakeClock(_now),
);

Map<String, Object?> _window(Map<String, Object?> fields, String key) =>
    (fields[key]! as Map).cast<String, Object?>();

void main() {
  group('BR7.4 provenance and preselection', () {
    test('(a) Barolo with "good": levelSource user, 8/15/30 before and '
        'after', () {
      final old = windowOf(2024, 2031, 2046);
      final wine = cellarWine(
        'w1',
        name: 'Barolo',
        vintage: 2016,
        level: WineLevel.good,
        window: old,
        baseWindow: old,
      );
      final fields = _migration().fieldsOf(wine, _now);
      expect(fields[WineFields.typeSource], 'user');
      expect(fields[WineFields.levelSource], 'user');
      expect(fields[WineFields.level], 'good');
      expect(fields[WineFields.style], 'redLong');
      expect(fields[WineFields.styleSource], 'auto');
      final window = _window(fields, WineFields.window);
      expect(
        [window['startYear'], window['peakYear'], window['endYear']],
        [2024, 2031, 2046],
      );
      expect(window['tablesVersion'], estimationTablesVersion);
      expect(window['profile'], 'R_LONG');
    });

    test('empty type and level are preselected as auto', () {
      final wine = cellarWine(
        'w1',
        name: 'Prosecco Superiore',
        wineType: null,
        vintage: null,
        createdAt: DateTime(2026, 5, 3),
      );
      final classification = EstimatesMigration.classificationOf(wine);
      expect(classification.wineType, WineType.sparklingTank);
      expect(classification.typeSource, FieldSource.auto);
      expect(classification.level, WineLevel.everyday);
      expect(classification.levelSource, FieldSource.auto);
      expect(classification.style, WineStyle.tankFresh);
      final fields = _migration().fieldsOf(wine, _now);
      final window = _window(fields, WineFields.window);
      // SP_TANK from the month added, start 0 (BR6.2, BR8.3).
      expect(window['unit'], 'months');
      expect([window['startYear'], window['startMonth']], [2026, 5]);
      expect(window['anchorFallback'], true);
    });

    test('BR7.2 a style chosen by the user is kept and decides the window', () {
      final wine = cellarWine(
        'w1',
        name: 'Barolo',
        vintage: 2016,
        style: WineStyle.redAge,
        styleSource: FieldSource.user,
      );
      final fields = _migration().fieldsOf(wine, _now);
      expect(fields[WineFields.style], 'redAge');
      expect(fields[WineFields.styleSource], 'user');
      final window = _window(fields, WineFields.baseWindow);
      expect([window['startYear'], window['endYear']], [2020, 2031]);
    });

    test('a catalog window stays: only the classification is written', () {
      final catalog = windowOf(2020, 2025, 2035, source: WindowSource.catalog);
      final wine = cellarWine('w1', window: catalog, baseWindow: catalog);
      final fields = _migration().fieldsOf(wine, _now);
      expect(fields.containsKey(WineFields.window), isFalse);
      expect(fields[WineFields.migrationVersion], 3);
    });

    test(
      'BR7.5 a correction in years on a months profile ends in December',
      () {
        final wine = cellarWine(
          'w1',
          name: 'Prosecco',
          wineType: 'sparklingTank',
          vintage: null,
          createdAt: DateTime(2025, 3, 1),
          windowOverride: const WindowOverride(endYear: 2026),
        );
        final fields = _migration().fieldsOf(wine, _now);
        final window = _window(fields, WineFields.window);
        expect([window['endYear'], window['endMonth']], [2026, 12]);
        expect(fields.containsKey(WineFields.windowOverride), isFalse);
      },
    );

    test('a catalog window with a feedback and no base window stays', () {
      final catalog = windowOf(2020, 2025, 2035, source: WindowSource.catalog);
      final wine = cellarWine(
        'w1',
        window: catalog,
        adjustment: const WindowAdjustment(
          kind: DrinkCondition.tooYoung,
          year: 2021,
          recordId: 'r1',
        ),
      );
      final fields = _migration().fieldsOf(wine, _now);
      expect(fields.containsKey(WineFields.window), isFalse);
      expect(fields.containsKey(WineFields.baseWindow), isFalse);
      expect(fields[WineFields.migrationVersion], 3);
    });

    test('a non-wine name gets no type; a fortified one "To estimate"', () {
      final fortified = cellarWine(
        'w1',
        name: 'Liquore misterioso',
        wineType: 'fortified',
      );
      final fields = _migration().fieldsOf(fortified, _now);
      expect(fields[WineFields.window], isNull);
      expect(fields[WineFields.style], 'fortifiedOther');
    });
  });

  group('WineClassification', () {
    test('BR7.2 user fields never change, empty and auto ones do', () {
      const stored = WineClassification(
        wineType: WineType.white,
        typeSource: FieldSource.user,
        level: WineLevel.good,
        levelSource: FieldSource.auto,
      );
      final next = stored.withPreselection(classifyWine('Barolo'));
      expect(next.wineType, WineType.white);
      expect(next.typeSource, FieldSource.user);
      expect(next.level, WineLevel.good);
      expect(next.levelSource, FieldSource.auto);
      // The red style does not fit a white kept by the user.
      expect(next.style, isNull);
      expect(next.styleSource, isNull);
    });

    test('a level source only with a level (ENT-108)', () {
      final none = const WineClassification().withPreselection(
        classifyWine('Cuvée Mario'),
      );
      expect(none.level, WineLevel.good);
      expect(none.levelSource, FieldSource.auto);
      final empty = const WineClassification().toFields();
      expect(empty[WineFields.level], isNot(isA<String>()));
      expect(empty[WineFields.levelSource], isNot(isA<String>()));
    });

    test('of, equality, text and fields', () {
      final wine = cellarWine(
        'w1',
        wineType: 'rose',
        typeSource: FieldSource.auto,
        style: WineStyle.roseFresh,
        styleSource: FieldSource.user,
      );
      final c = WineClassification.of(wine);
      expect(c, WineClassification.of(wine));
      expect(c.hashCode, WineClassification.of(wine).hashCode);
      expect(c.toString(), contains('rose/auto'));
      final fields = c.toFields();
      expect(fields[WineFields.wineType], 'rose');
      expect(fields[WineFields.styleSource], 'user');
      expect(fields[WineFields.level], isNot(isA<String>()));
    });
  });

  group('F5 CellarActions.chooseStyle', () {
    late _Repo repo;
    late CellarActions actions;
    late List<(WineClassification, Map<String, Object?>)> writes;

    setUpAll(() {
      registerCellarFallbacks();
      registerFallbackValue(const WineClassification());
    });

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      repo = _Repo();
      writes = [];
      final sink = RecordingErrorSink();
      final clock = FakeClock(_now);
      when(
        () => repo.updateClassification(
          cellarId: any(named: 'cellarId'),
          user: any(named: 'user'),
          wine: any(named: 'wine'),
          classification: any(named: 'classification'),
          estimate: any(named: 'estimate'),
        ),
      ).thenAnswer((invocation) async {
        final estimate = invocation.namedArguments[#estimate];
        writes.add((
          invocation.namedArguments[#classification]! as WineClassification,
          (estimate as dynamic).toFields() as Map<String, Object?>,
        ));
        return const SaveAccepted();
      });
      actions = CellarActions(
        wines: repo,
        records: MockDrinkingRecordRepository(),
        reconciler: RecordReconciler(
          preferences: SharedPreferences.getInstance,
          clock: clock,
          reporter: recordingReporter(sink),
        ),
        refresher: EstimateRefresher(
          wines: repo,
          catalog: FakeWineCatalog(),
          network: FakeCellarNetwork(online: false),
          reporter: recordingReporter(sink),
          clock: clock,
        ),
        bus: SyncErrorBus(),
        reporter: recordingReporter(sink),
        clock: clock,
      );
    });

    test(
      'a style chosen: user source, automatic level again, new window',
      () async {
        final wine = cellarWine(
          'w1',
          name: 'Rosso della casa',
          wineType: 'redLight',
          vintage: 2024,
          style: WineStyle.redFresh,
          styleSource: FieldSource.auto,
          level: WineLevel.everyday,
          levelSource: FieldSource.auto,
        );
        expect(
          await actions.chooseStyle(
            cellar: ownerCellar,
            user: cellarOwner,
            wine: wine,
            style: WineStyle.redMedium,
          ),
          isTrue,
        );
        final (classification, fields) = writes.single;
        expect(classification.style, WineStyle.redMedium);
        expect(classification.styleSource, FieldSource.user);
        // A type saved without a source is the user's (BR7.4).
        expect(classification.typeSource, FieldSource.user);
        expect(classification.levelSource, FieldSource.auto);
        expect(classification.level, WineLevel.good);
        final window = fields[WineFields.baseWindow]! as Map;
        expect(window['startYear'], 2026);
        expect(window['profile'], 'R_MEDIUM');
      },
    );

    test(
      'a type chosen for a wine without one; a level of the user stays',
      () async {
        final wine = cellarWine(
          'w1',
          name: 'Cuvée Mario',
          wineType: null,
          level: WineLevel.aging,
          levelSource: FieldSource.user,
        );
        await actions.chooseStyle(
          cellar: ownerCellar,
          user: cellarOwner,
          wine: wine,
          wineType: WineType.white,
        );
        final (classification, _) = writes.single;
        expect(classification.wineType, WineType.white);
        expect(classification.typeSource, FieldSource.user);
        expect(classification.level, WineLevel.aging);
        expect(classification.levelSource, FieldSource.user);
        expect(classification.style, isNull);
      },
    );

    test('a reader writes nothing', () async {
      expect(
        await actions.chooseStyle(
          cellar: readCellar,
          user: cellarEditor,
          wine: cellarWine('w1'),
          style: WineStyle.redAge,
        ),
        isFalse,
      );
      expect(writes, isEmpty);
    });
  });
}
