import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../account/account_gate.dart';
import '../account/account_providers.dart';
import '../account/auth_service.dart';
import '../account/data/user_repository.dart';
import '../account/deletion/account_deletion_runner.dart';
import '../account/deletion/deletion_device.dart';
import '../account/deletion/deletion_signal.dart';
import '../account/deletion/firestore_deletion_backend.dart';
import '../account/google_auth_service.dart';
import '../account/onboarding_flag.dart';
import '../account/network_status.dart';
import '../account/reset_coordinator.dart';
import '../cellar/cellar_providers.dart';
import '../cellar/data/cellar_repository.dart';
import '../cellar/data/drinking_record_repository.dart';
import '../cellar/data/match_key_backfill.dart';
import '../cellar/data/pending_writes_probe.dart';
import '../cellar/data/record_reconciler.dart';
import '../cellar/data/wine_repository.dart';
import '../core/clock.dart';
import '../core/id_generator.dart';
import '../e2e/e2e_locale.dart';
import '../e2e/emulator_google_auth_service.dart';
import '../firebase/firebase_env.dart';
import '../firebase/firestore_bootstrap.dart';
import '../l10n/app_localizations.dart';
import '../label/label_providers.dart';
import '../plan/plan_providers.dart';
import '../plan/plan_session.dart';
import '../plan/plan_wiring.dart';
import '../sharing/data/sharing_repository.dart';
import '../sharing/sharing_providers.dart';
import '../sync/ledger/key_value_store.dart';
import '../sync/ledger/local_ledger.dart';
import '../sync/sync_error_bus.dart';
import '../sync/sync_gateway.dart';
import '../sync/sync_watcher.dart';
import 'crashlytics_sink.dart';
import 'error_reporter.dart';
import 'locale_resolution.dart';
import 'providers.dart';

/// Everything started by [AppBootstrap.start].
class AppServices {
  AppServices({
    required this.container,
    required this.gate,
    this.onDispose = const [],
  });

  final ProviderContainer container;
  final AccountGate gate;

  /// freemium-plus: the plan session's gate listener and app lifecycle.
  final List<void Function()> onDispose;

  void dispose() {
    for (final dispose in onDispose) {
      dispose();
    }
    gate.dispose();
    container.dispose();
  }
}

/// Start-up order (security-design.md §7, performance-design.md):
/// `Firebase.initializeApp`, then App Check, then — in parallel — Crashlytics
/// and the ledger read. No Auth or Firestore call happens before App Check.
/// The ledger is checked by [AccountGate] before any Firestore listener.
abstract final class AppBootstrap {
  static bool _authEmulatorConfigured = false;
  static AppServices? _current;

  /// Starts (or, in the end-to-end restart test, restarts) the app services.
  static Future<AppServices> start({FirebaseEnvConfig? config}) async {
    _current?.dispose();
    _current = null;
    final env = config ?? FirebaseEnvConfig.fromEnvironment();
    announceE2ELocale();

    if (Firebase.apps.isEmpty) {
      // Throws MissingProductionOptionsError for a prod build without the
      // production dart-defines: fail fast instead of reaching the wrong project.
      await Firebase.initializeApp(options: env.options);
    }
    if (!env.usesEmulators) {
      // Play Integrity in release; the debug provider only in debug builds
      // on a real phone. The emulators do not enforce App Check (NFR4.6).
      await FirebaseAppCheck.instance.activate(
        providerAndroid: kReleaseMode
            ? const AndroidPlayIntegrityProvider()
            : const AndroidDebugProvider(),
      );
    } else if (!kReleaseMode) {
      // freemium-plus: the callables keep `enforceAppCheck` in the Functions
      // emulator too (the token is decoded, not verified), so demo builds
      // send a debug App Check token. Never in a release build.
      try {
        await FirebaseAppCheck.instance.activate(
          providerAndroid: const AndroidDebugProvider(),
        );
      } on Object catch (error) {
        // A demo build still starts; its callables then fail and are
        // reported where they are used.
        debugPrint('App Check debug provider not active: $error');
      }
    }

    final reporter = ErrorReporter(_errorSink(env));
    final ledger = LocalLedger(
      store: SharedPreferencesStore(),
      reporter: reporter,
    );
    await Future.wait([_configureCrashlytics(env, reporter), ledger.read()]);

    if (env.usesEmulators && !_authEmulatorConfigured) {
      await FirebaseAuth.instance.useAuthEmulator(
        env.emulatorHost,
        FirebaseEnvConfig.authEmulatorPort,
        automaticHostMapping: false,
      );
      _authEmulatorConfigured = true;
    }

    final firestore = FirestoreBootstrap(
      firestore: () => FirebaseFirestore.instance,
      config: env,
    )..configure();
    // Plan B of a previous reset: clear before any other Firestore use.
    await firestore.completePendingReset(ledger);

    final services = _wire(
      env: env,
      reporter: reporter,
      ledger: ledger,
      firestore: firestore,
    );
    _current = services;
    unawaited(services.gate.start());
    // u6-label-recognition (NFR8.1): label copies left by a killed process
    // and image_picker's lost data go after the first frame, before any
    // reading (every reading waits for this cleanup).
    scheduleLabelCleanup(services.container);
    // u6 BR1.4: a share follows the account from start-up; the one that
    // started the app is held as a reference until sign-in and cellar.
    final shares = services.container.read(sharedImageProvider.notifier)
      ..attachGate(services.gate.state);
    unawaited(shares.checkColdStart());
    return services;
  }

  static ErrorSink _errorSink(FirebaseEnvConfig env) =>
      kReleaseMode && !env.usesEmulators
      ? CrashlyticsErrorSink(FirebaseCrashlytics.instance)
      : const DebugLogSink();

  /// Crashlytics only in release builds of the real project (NFR8.2).
  static Future<void> _configureCrashlytics(
    FirebaseEnvConfig env,
    ErrorReporter reporter,
  ) async {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      unawaited(
        reporter.report(
          details.exception,
          details.stack,
          reason: 'FlutterError',
          fatal: true,
        ),
      );
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      unawaited(
        reporter.report(error, stack, reason: 'UncaughtError', fatal: true),
      );
      return true;
    };
    if (env.usesEmulators) return;
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
      kReleaseMode,
    );
  }

  static AppServices _wire({
    required FirebaseEnvConfig env,
    required ErrorReporter reporter,
    required LocalLedger ledger,
    required FirestoreBootstrap firestore,
  }) {
    FirebaseFirestore db() => FirebaseFirestore.instance;
    final bus = SyncErrorBus();
    // freemium-plus FR6.1: one meter for every repository; FR2.2: one
    // active-wine counter for the wine and drink writes, which explains a
    // refused +1 as the capacity limit only while the policy turns it on.
    final plan = PlanServices.create(env: env, db: db(), reporter: reporter);
    final meter = plan.meter;
    final watcher = SyncWatcher(
      ledger: ledger,
      gateway: FirestoreSyncGateway(db, meter: meter),
      reporter: reporter,
    );
    final cellars = CellarRepository(db: db(), meter: meter);
    final wines = WineRepository(
      db: db(),
      ledger: ledger,
      bus: bus,
      reporter: reporter,
      onWriteStarted: watcher.trigger,
      counter: plan.counter,
      meter: meter,
    );
    final AuthService auth = kIsE2EBuild
        ? EmulatorGoogleAuthService(FirebaseAuth.instance)
        : GoogleAuthService(
            auth: FirebaseAuth.instance,
            google: GoogleSignIn.instance,
            serverClientId: _serverClientId,
          );
    late final ProviderContainer container;
    final users = UserRepository(db: db(), meter: meter);
    final session = PlanSession(
      meter: meter,
      uploader: plan.uploader,
      store: plan.store,
      reporter: reporter,
      entitlements: plan.entitlements,
      devOverrides: plan.devOverrides,
      onSessionChanged: (uid) =>
          container.read(signedInUidProvider.notifier).set(uid),
    );
    final resets = ResetCoordinator(
      ledger: ledger,
      bootstrap: firestore,
      watcher: watcher,
      reporter: reporter,
      invalidateListeners: () => invalidateFirestoreListeners(container),
      clearAccountState: session.clearAccountData,
    );
    final network = ConnectivityNetworkStatus();
    // u8-account (logical-components.md): the account deletion run by the
    // app, without cloud functions (BR1.7).
    final deletion = AccountDeletionRunner(
      backend: FirestoreDeletionBackend(db: db(), users: users),
      device: AppDeletionDevice(
        watcher: watcher,
        invalidateListeners: () => invalidateFirestoreListeners(container),
        waitForPendingWrites: () => db().waitForPendingWrites(),
        ledger: ledger,
        resets: resets,
        labels: () => container.read(tempLabelStoreProvider),
      ),
      signal: DeletionSignal(SharedPreferences.getInstance),
      auth: auth,
      reporter: reporter,
    );
    final gate = AccountGate(
      auth: auth,
      ledger: ledger,
      resetCoordinator: resets,
      cellars: cellars,
      users: users,
      watcher: watcher,
      bus: bus,
      reporter: reporter,
      defaultCellarName: () => lookupAppLocalizations(
        appLocaleOverride ??
            resolveAppLocale(PlatformDispatcher.instance.locales),
      ).defaultCellarName,
      reopenCellarListeners: () => reopenCellarListeners(container),
      clearSharingChoice: () =>
          clearActiveCellarChoices(SharedPreferences.getInstance),
      deletion: deletion,
      network: network,
      markOnboardingSeen: () =>
          container.read(onboardingSeenProvider.notifier).markSeen(),
    );
    final sharing = SharingRepository(
      db: db(),
      network: network,
      reporter: reporter,
      meter: meter,
    );
    // u4-cellar: the drinks keep the sync banner "pending" until the server
    // confirms them (security-design.md §4, NFR6.6).
    final probe = PendingWritesProbe(
      waitForPendingWrites: () => db().waitForPendingWrites(),
      onPendingChanged: (pending) =>
          container.read(drinkingRecordsPendingProvider.notifier).set(pending),
      reporter: reporter,
    );
    final records = DrinkingRecordRepository(
      db: db(),
      ledger: ledger,
      bus: bus,
      reporter: reporter,
      probe: probe,
      ids: RandomIdGenerator(),
      onWriteStarted: watcher.trigger,
      counter: plan.counter,
      meter: meter,
    );
    final reconciler = RecordReconciler(
      preferences: SharedPreferences.getInstance,
      clock: const SystemClock(),
      reporter: reporter,
    );
    container = ProviderContainer(
      overrides: [
        errorReporterProvider.overrideWithValue(reporter),
        authServiceProvider.overrideWithValue(auth),
        localLedgerProvider.overrideWithValue(ledger),
        cellarRepositoryProvider.overrideWithValue(cellars),
        wineRepositoryProvider.overrideWithValue(wines),
        syncErrorBusProvider.overrideWithValue(bus),
        syncWatcherProvider.overrideWithValue(watcher),
        accountGateProvider.overrideWithValue(gate),
        accessNoticesAllowedProvider.overrideWithValue(
          () => gate.current is GateCellar,
        ),
        sharingRepositoryProvider.overrideWithValue(sharing),
        drinkingRecordRepositoryProvider.overrideWithValue(records),
        matchKeyBackfillProvider.overrideWithValue(
          MatchKeyBackfill(db: db(), reporter: reporter),
        ),
        recordReconcilerProvider.overrideWithValue(reconciler),
        onboardingFlagProvider.overrideWithValue(
          OnboardingFlag(SharedPreferences.getInstance),
        ),
        ...plan.overrides(),
      ],
    );
    // Drinks queued by an earlier session count too (NFR6.6).
    unawaited(probe.checkAtStartup());
    return AppServices(
      container: container,
      gate: gate,
      onDispose: plan.attach(
        container: container,
        gate: gate,
        session: session,
      ),
    );
  }

  /// OAuth web client id of the production project (public value), passed by
  /// release.yml with `--dart-define=GOOGLE_SERVER_CLIENT_ID=...`.
  static String? get _serverClientId {
    const value = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');
    return value.isEmpty ? null : value;
  }
}
