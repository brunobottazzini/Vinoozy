import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../account/account_gate.dart';
import '../account/auth_service.dart';
import '../account/data/user_repository.dart';
import '../account/google_auth_service.dart';
import '../account/reset_coordinator.dart';
import '../cellar/data/cellar_repository.dart';
import '../cellar/data/wine_repository.dart';
import '../e2e/emulator_google_auth_service.dart';
import '../firebase/firebase_env.dart';
import '../firebase/firestore_bootstrap.dart';
import '../l10n/app_localizations.dart';
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
  AppServices({required this.container, required this.gate});

  final ProviderContainer container;
  final AccountGate gate;

  void dispose() {
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
    final watcher = SyncWatcher(
      ledger: ledger,
      gateway: FirestoreSyncGateway(db),
      reporter: reporter,
    );
    final cellars = CellarRepository(db: db());
    final wines = WineRepository(
      db: db(),
      ledger: ledger,
      bus: bus,
      reporter: reporter,
      onWriteStarted: watcher.trigger,
    );
    final AuthService auth = kIsE2EBuild
        ? EmulatorGoogleAuthService(FirebaseAuth.instance)
        : GoogleAuthService(
            auth: FirebaseAuth.instance,
            google: GoogleSignIn.instance,
            serverClientId: _serverClientId,
          );
    late final ProviderContainer container;
    final gate = AccountGate(
      auth: auth,
      ledger: ledger,
      resetCoordinator: ResetCoordinator(
        ledger: ledger,
        bootstrap: firestore,
        watcher: watcher,
        reporter: reporter,
        invalidateListeners: () => invalidateFirestoreListeners(container),
      ),
      cellars: cellars,
      users: UserRepository(db: db()),
      watcher: watcher,
      bus: bus,
      reporter: reporter,
      defaultCellarName: () => lookupAppLocalizations(
        resolveAppLocale(PlatformDispatcher.instance.locales),
      ).defaultCellarName,
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
      ],
    );
    return AppServices(container: container, gate: gate);
  }

  /// OAuth web client id of the production project (public value), passed by
  /// release.yml with `--dart-define=GOOGLE_SERVER_CLIENT_ID=...`.
  static String? get _serverClientId {
    const value = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');
    return value.isEmpty ? null : value;
  }
}
