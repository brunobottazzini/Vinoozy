import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/account/account_gate.dart';
import 'package:vinoozy/account/app_user.dart';
import 'package:vinoozy/account/ui/account_gate_view.dart';
import 'package:vinoozy/app/providers.dart';
import 'package:vinoozy/cellar/data/cellar_repository.dart';
import 'package:vinoozy/cellar/data/wine_repository.dart';
import 'package:vinoozy/cellar/domain/cellar.dart';
import 'package:vinoozy/cellar/ui/cellar_screen.dart';
import 'package:vinoozy/sync/ledger/local_ledger.dart';
import 'package:vinoozy/sync/snapshot_meta.dart';
import 'package:vinoozy/sync/sync_error_bus.dart';

import '../../helpers/fakes.dart';
import '../../helpers/service_mocks.dart';
import '../../helpers/ui_harness.dart';
import '../../cellar/cellar_harness.dart' show cellarServiceOverrides;
import '../../sharing/sharing_harness.dart' show noSharingOverrides;
import 'cellar_screen_test.dart' show CellarFixture, cellarSnapshot, userA;
import 'sign_in_screen_test.dart' show FakeNetwork;

/// The error Firestore gives a listener rejected by the rules.
FirebaseException permissionDenied() =>
    FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied');

const _synced = SnapshotMeta(hasPendingWrites: false, isFromCache: false);

/// Firestore listeners behind security rules that can deny and then allow
/// access. Like the real SDK, a rejected listener gets one error and is
/// closed: it never recovers by itself, only a new subscription can.
class RulesFake {
  bool denied = false;
  int cellarListens = 0;
  int wineListens = 0;

  /// Whether `cellars/{uid}` exists. Like firestore.rules, the owner may read
  /// a missing cellar (empty snapshot), while the wines rule reads the
  /// cellar with get() and denies until it exists.
  bool cellarExists = true;
  final List<StreamController<Object>> _live = [];
  final List<StreamController<CellarSnapshot>> _cellarListeners = [];

  Stream<CellarSnapshot> watchCellar(String uid) {
    cellarListens++;
    if (!cellarExists && !denied) {
      final controller = StreamController<CellarSnapshot>()
        ..add(const CellarSnapshot(cellar: null, meta: _synced));
      _cellarListeners.add(controller);
      return controller.stream;
    }
    return _open(_cellar(uid));
  }

  Stream<WinesSnapshot> watchCellarWines(String cellarId) {
    wineListens++;
    if (!cellarExists) {
      final controller = StreamController<WinesSnapshot>()
        ..addError(permissionDenied())
        ..close();
      return controller.stream;
    }
    return _open(const WinesSnapshot(wines: [], meta: _synced));
  }

  /// `ensurePersonalCellar` created the cellar: open cellar listeners see it.
  void createCellar(String uid) {
    cellarExists = true;
    for (final controller in _cellarListeners) {
      controller.add(_cellar(uid));
    }
  }

  CellarSnapshot _cellar(String uid) => CellarSnapshot(
    cellar: Cellar(id: uid, ownerId: uid, name: 'La mia cantina'),
    meta: _synced,
  );

  /// The rules start denying while listeners are open: each open listener
  /// gets permission-denied and is closed.
  void rejectOpenListeners() {
    denied = true;
    for (final controller in _live) {
      controller
        ..addError(permissionDenied())
        ..close();
    }
    _live.clear();
  }

  Stream<T> _open<T extends Object>(T value) {
    final controller = StreamController<T>();
    if (denied) {
      controller
        ..addError(permissionDenied())
        ..close();
    } else {
      controller.add(value);
      _live.add(controller as StreamController<Object>);
    }
    return controller.stream;
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(userA);
    registerFallbackValue(
      const JournalEntry(wineId: '', cellarId: '', name: '', ownerUid: ''),
    );
  });

  // ux-redesign: "Aggiungi" is a floating button.
  FloatingActionButton addButton(WidgetTester tester) => tester
      .widget<FloatingActionButton>(find.byKey(const Key('cellar-add-button')));

  group('CellarScreen: a listener error is the cellar error (BR1.3, §8)', () {
    late CellarFixture fixture;
    late int retries;

    setUp(() {
      fixture = CellarFixture();
      retries = 0;
    });

    Future<void> pump(WidgetTester tester) => pumpScreen(
      tester,
      CellarScreen(
        user: userA,
        setup: CellarSetup.ready,
        onRetrySetup: () async => retries++,
      ),
      overrides: fixture.overrides,
    );

    testWidgets('a rejected cellar listener shows "Impossibile preparare la '
        'cantina", "Aggiungi" disabled', (tester) async {
      await pump(tester);
      fixture.cellar.addError(StateError('permission-denied'));
      fixture.winesStream.add(const WinesSnapshot(wines: [], meta: _synced));
      await tester.pumpAndSettle();

      expect(find.text('Impossibile preparare la cantina'), findsOneWidget);
      expect(find.byKey(const Key('cellar-retry-button')), findsOneWidget);
      expect(addButton(tester).onPressed, isNull);
    });

    testWidgets('a listener error after the cellar was shown disables '
        '"Aggiungi" and "Riprova" goes through the cellar check', (
      tester,
    ) async {
      await pump(tester);
      await fixture.emit(tester);
      expect(addButton(tester).onPressed, isNotNull);

      fixture.cellar.addError(StateError('permission-denied'));
      await tester.pumpAndSettle();
      expect(addButton(tester).onPressed, isNull);

      await tester.tap(find.byKey(const Key('cellar-retry-button')));
      await tester.pump();
      expect(retries, 1);
    });

    testWidgets('"Riprova" after a wines listener error also goes through '
        'the cellar check, not only the wines listener', (tester) async {
      await pump(tester);
      fixture.cellar.add(cellarSnapshot());
      fixture.winesStream.addError(StateError('permission-denied'));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('cellar-error')), findsOneWidget);
      expect(addButton(tester).onPressed, isNull);
      await tester.tap(find.byKey(const Key('cellar-retry-button')));
      await tester.pump();
      expect(retries, 1);
    });
  });

  group('AccountGate + CellarScreen: "Riprova" reopens the listeners', () {
    late RulesFake rules;
    late MockAuthService auth;
    late MockCellarRepository cellars;
    late MockWineRepository wines;
    late MockUserRepository users;
    late MockSyncWatcher watcher;
    late LocalLedger ledger;
    late StreamController<AppUser?> userChanges;
    late AccountGate gate;
    late ProviderContainer container;

    setUp(() {
      rules = RulesFake();
      auth = MockAuthService();
      cellars = MockCellarRepository();
      wines = MockWineRepository();
      users = MockUserRepository();
      watcher = MockSyncWatcher();
      userChanges = StreamController<AppUser?>.broadcast();
      final sink = RecordingErrorSink();
      ledger = LocalLedger(
        store: InMemoryKeyValueStore(),
        reporter: recordingReporter(sink),
      );
      when(() => auth.currentUser).thenReturn(userA);
      when(() => auth.userChanges()).thenAnswer((_) => userChanges.stream);
      when(() => cellars.isCached(any())).thenAnswer((_) async => false);
      when(
        () => cellars.ensurePersonalCellar(
          uid: any(named: 'uid'),
          defaultName: any(named: 'defaultName'),
        ),
      ).thenAnswer((_) async {
        if (rules.denied) throw CellarSetupException(permissionDenied());
      });
      when(() => cellars.watchCellar(any())).thenAnswer(
        (invocation) =>
            rules.watchCellar(invocation.positionalArguments.single as String),
      );
      when(() => wines.watchCellarWines(any())).thenAnswer(
        (invocation) => rules.watchCellarWines(
          invocation.positionalArguments.single as String,
        ),
      );
      when(() => users.ensureProfile(any())).thenAnswer((_) async {});
      when(() => watcher.start(any())).thenAnswer((_) async {});
      when(() => watcher.trigger()).thenAnswer((_) async {});
      when(() => watcher.reconcileRejected(any()))
          .thenAnswer((_) async => false);
      gate = AccountGate(
        auth: auth,
        ledger: ledger,
        resetCoordinator: MockResetCoordinator(),
        cellars: cellars,
        users: users,
        watcher: watcher,
        bus: SyncErrorBus(),
        reporter: recordingReporter(sink),
        defaultCellarName: () => 'La mia cantina',
        reopenCellarListeners: () => reopenCellarListeners(container),
      );
    });

    tearDown(() => userChanges.close());

    Future<void> pump(WidgetTester tester) async {
      await pumpScreen(
        tester,
        const AccountGateView(),
        overrides: [
          cellarRepositoryProvider.overrideWithValue(cellars),
          wineRepositoryProvider.overrideWithValue(wines),
          syncWatcherProvider.overrideWithValue(watcher),
          localLedgerProvider.overrideWithValue(ledger),
          accountGateProvider.overrideWithValue(gate),
          networkStatusProvider.overrideWithValue(FakeNetwork()),
          idGeneratorProvider.overrideWithValue(SequenceIdGenerator()),
          clockProvider.overrideWithValue(FakeClock(DateTime(2026, 11, 5))),
          ...noSharingOverrides(),
          // u4-cellar: the HomeShell of the gate starts the maintenance.
          ...cellarServiceOverrides(),
        ],
      );
      container = ProviderScope.containerOf(
        tester.element(find.byType(AccountGateView)),
      );
      // Since u5-dashboard the shell opens on the Dashboard: these checks
      // are on the "Cantina" tab.
      await tester.tap(find.byKey(const Key('home-nav-cellar')));
      await tester.pump();
    }

    /// Lets Riverpod's own automatic retries of a failed provider run out
    /// (10 attempts, about 38 s), as on the phone where the error stuck.
    Future<void> outlastAutomaticRetries(WidgetTester tester) async {
      for (var second = 0; second < 60; second++) {
        await tester.pump(const Duration(seconds: 1));
      }
    }

    testWidgets('"Caso con rifiuto iniziale": rules deny, access restored, '
        '"Riprova" opens the cellar with "Aggiungi" enabled, no restart', (
      tester,
    ) async {
      rules.denied = true;
      await tester.runAsync(gate.start);
      await pump(tester);
      await outlastAutomaticRetries(tester);

      expect(find.text('Impossibile preparare la cantina'), findsOneWidget);
      expect(addButton(tester).onPressed, isNull);
      final listensBeforeRetry = rules.cellarListens;
      await tester.pump(const Duration(seconds: 30));
      expect(
        rules.cellarListens,
        listensBeforeRetry,
        reason: 'the rejected listener stays closed on its own',
      );

      rules.denied = false;
      await tester.tap(find.byKey(const Key('cellar-retry-button')));
      await tester.pumpAndSettle();

      expect(rules.cellarListens, greaterThan(listensBeforeRetry));
      expect(find.text('Impossibile preparare la cantina'), findsNothing);
      expect(find.byKey(const Key('cellar-empty')), findsOneWidget);
      expect(addButton(tester).onPressed, isNotNull);
    });

    testWidgets('first sign-in with no cached cellar: no listener is opened '
        'while the cellar is created, no error once it is ready, "Aggiungi" '
        'enabled', (tester) async {
      rules.cellarExists = false;
      final created = Completer<void>();
      when(
        () => cellars.ensurePersonalCellar(
          uid: any(named: 'uid'),
          defaultName: any(named: 'defaultName'),
        ),
      ).thenAnswer((invocation) async {
        await created.future;
        rules.createCellar(invocation.namedArguments[#uid] as String);
      });

      late Future<void> start;
      // The ledger check runs on real async: wait until the gate is creating
      // the cellar.
      await tester.runAsync(() async {
        start = gate.start();
        for (var i = 0; i < 200 && gate.current is! GateEnsureCellar; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 5));
        }
      });
      await pump(tester);
      // A slow creation: longer than Riverpod's automatic retries, so a
      // listener rejected now would keep its error.
      await outlastAutomaticRetries(tester);
      expect(gate.current, isA<GateEnsureCellar>());
      expect(find.byKey(const Key('cellar-loading')), findsOneWidget);
      final listensWhilePreparing = (rules.cellarListens, rules.wineListens);

      await tester.runAsync(() async {
        created.complete();
        await start;
      });
      await tester.pumpAndSettle();

      expect(gate.current, isA<GateCellar>());
      expect((gate.current as GateCellar).setupFailed, isFalse);
      expect(find.text('Impossibile preparare la cantina'), findsNothing);
      expect(find.byKey(const Key('cellar-empty')), findsOneWidget);
      expect(addButton(tester).onPressed, isNotNull);
      expect(listensWhilePreparing.$1, 0);
      expect(
        listensWhilePreparing.$2,
        0,
        reason: 'the wines rule denies until the cellar exists',
      );
      expect(rules.wineListens, 1);
    });

    testWidgets('first sign-in whose cellar creation fails, then fails again '
        'on "Riprova": the error stays; a later "Riprova" that succeeds '
        'opens the cellar with "Aggiungi" enabled', (tester) async {
      rules.cellarExists = false;
      var failures = 2;
      when(
        () => cellars.ensurePersonalCellar(
          uid: any(named: 'uid'),
          defaultName: any(named: 'defaultName'),
        ),
      ).thenAnswer((invocation) async {
        if (failures > 0) {
          failures--;
          throw CellarSetupException(StateError('unavailable'));
        }
        rules.createCellar(invocation.namedArguments[#uid] as String);
      });

      await tester.runAsync(gate.start);
      await pump(tester);
      await outlastAutomaticRetries(tester);
      expect(find.byKey(const Key('cellar-error')), findsOneWidget);
      expect(addButton(tester).onPressed, isNull);

      await tester.tap(find.byKey(const Key('cellar-retry-button')));
      await outlastAutomaticRetries(tester);
      expect((gate.current as GateCellar).setupFailed, isTrue);
      expect(find.byKey(const Key('cellar-error')), findsOneWidget);
      expect(addButton(tester).onPressed, isNull);

      await tester.tap(find.byKey(const Key('cellar-retry-button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('cellar-error')), findsNothing);
      expect(find.byKey(const Key('cellar-empty')), findsOneWidget);
      expect(addButton(tester).onPressed, isNotNull);
    });

    testWidgets('a cellar already open whose listeners are rejected: error, '
        'then "Riprova" re-subscribes both listeners', (tester) async {
      await tester.runAsync(gate.start);
      await pump(tester);
      await tester.pumpAndSettle();
      expect(addButton(tester).onPressed, isNotNull);
      final cellarListens = rules.cellarListens;
      final wineListens = rules.wineListens;

      rules.rejectOpenListeners();
      await outlastAutomaticRetries(tester);
      expect(find.byKey(const Key('cellar-error')), findsOneWidget);
      expect(addButton(tester).onPressed, isNull);

      rules.denied = false;
      final listensBeforeRetry = (rules.cellarListens, rules.wineListens);
      await tester.tap(find.byKey(const Key('cellar-retry-button')));
      await tester.pumpAndSettle();

      expect(rules.cellarListens, greaterThan(listensBeforeRetry.$1));
      expect(rules.wineListens, greaterThan(listensBeforeRetry.$2));
      expect(rules.cellarListens, greaterThan(cellarListens));
      expect(rules.wineListens, greaterThan(wineListens));
      expect(find.byKey(const Key('cellar-error')), findsNothing);
      expect(addButton(tester).onPressed, isNotNull);
    });
  });
}
