// Real composition of the catalog with Riverpod (logical-components.md).
//
// - Open Food Facts exists only when the build has a contact (BR5.1): without
//   it no OpenFoodFactsSource is created and every operation stays internal.
// - catalogSessionProvider follows the signed-in user of U1 and, on every
//   change of uid (sign-out or another account), clears the previous user's
//   cache before serving the new one; with nobody signed in no cache is
//   loaded or saved (NFR8.1).
// - U4 and U6 use catalogProvider with `ref.watch` (Riverpod pauses a
//   provider nobody listens to, and with it the uid listener); U8 calls
//   `clear()` on catalogSessionProvider when the account is deleted.

import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

import '../../app/providers.dart';
import '../core/catalog_cache_store.dart';
import '../core/catalog_config.dart';
import '../core/catalog_coordinator.dart';
import '../core/catalog_event_logger.dart';
import '../core/internal_catalog.dart';
import '../core/off/open_food_facts_source.dart';
import '../core/off_circuit_breaker.dart';
import '../core/request_budget.dart';
import '../core/wine_catalog.dart';
import 'crashlytics_catalog_event_logger.dart';
import 'file_cache_file.dart';

/// Open Food Facts contact of this build; empty outside production.
final catalogOffContactProvider = Provider<String>(
  (ref) => CatalogConfig.contactFromEnvironment,
);

/// App version for the User-Agent, read once at start-up.
final catalogAppVersionProvider = FutureProvider<String>((ref) async {
  try {
    return (await PackageInfo.fromPlatform()).version;
  } on Object {
    // The version only identifies the app to Open Food Facts.
    return 'unknown';
  }
});

/// One HTTP client for the whole session, closed with the provider.
final catalogHttpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

/// `catalog_cache.json` in the app support directory.
final catalogCacheFileProvider = Provider<CacheFile>((ref) => FileCacheFile());

/// Crashlytics in release builds (where U1 enables it), the console in
/// debug builds; `kDebugMode` stays here so the core never imports Flutter.
final catalogEventLoggerProvider = Provider<CatalogEventLogger>(
  (ref) => kReleaseMode
      ? CrashlyticsCatalogEventLogger(
          FirebaseCrashlytics.instance,
          debugLogging: false,
        )
      : ConsoleCatalogEventLogger(debugLogging: kDebugMode, sink: debugPrint),
);

/// The coordinator and its parts, built once per session (NFR1.5).
final catalogCoordinatorProvider = Provider<CatalogCoordinator>((ref) {
  final clock = ref.watch(clockProvider);
  final logger = ref.watch(catalogEventLoggerProvider);
  final health = CatalogHealth();
  final contact = ref.watch(catalogOffContactProvider);
  Future<OpenFoodFactsSource?> offSource = Future.value();
  if (contact.trim().isNotEmpty) {
    final client = ref.watch(catalogHttpClientProvider);
    offSource = ref
        .watch(catalogAppVersionProvider.future)
        .then(
          (version) => OpenFoodFactsSource(
            client: client,
            config: CatalogConfig(appVersion: version, offContact: contact),
          ),
        );
  }
  final coordinator = CatalogCoordinator(
    internal: InternalCatalog.build(),
    cache: CatalogCacheStore(
      file: ref.watch(catalogCacheFileProvider),
      clock: clock,
      health: health,
      logger: logger,
    ),
    budget: RequestBudget(clock),
    breaker: OffCircuitBreaker(clock: clock, logger: logger, health: health),
    logger: logger,
    offSource: offSource,
  );
  ref.onDispose(coordinator.dispose);
  return coordinator;
});

/// The signed-in uid of U1, starting from the saved session.
final catalogUidProvider = StreamProvider<String?>((ref) async* {
  final auth = ref.watch(authServiceProvider);
  yield auth.currentUser?.uid;
  yield* auth.userChanges().map((user) => user?.uid);
});

/// Owner stored in the cache file: SHA-256 of the uid, never the uid.
String catalogOwnerHash(String uid) =>
    sha256.convert(utf8.encode(uid)).toString();

/// The coordinator bound to the signed-in user: every change of uid starts
/// a new session, which clears the previous user's cache first.
final catalogSessionProvider = Provider<CatalogCoordinator>((ref) {
  final coordinator = ref.watch(catalogCoordinatorProvider);
  ref.listen<AsyncValue<String?>>(catalogUidProvider, (_, next) {
    if (!next.hasValue) return;
    final uid = next.value;
    unawaited(
      coordinator.startSession(uid == null ? null : catalogOwnerHash(uid)),
    );
  }, fireImmediately: true);
  return coordinator;
});

/// The wine catalog (C1) used by U4 and U6.
final catalogProvider = Provider<WineCatalog>(
  (ref) => ref.watch(catalogSessionProvider),
);
