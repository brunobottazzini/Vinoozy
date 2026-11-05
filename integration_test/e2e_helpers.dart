import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinoozy/cellar/ui/wine_list_tile.dart';
import 'package:vinoozy/e2e/emulator_google_auth_service.dart';
import 'package:vinoozy/firebase/firebase_env.dart';
import 'package:vinoozy/firebase/firestore_bootstrap.dart';
import 'package:vinoozy/main.dart' as app;
import 'package:vinoozy/sync/ledger/local_ledger.dart';

/// Provisional non-regression limit for save-to-list in the e2e tests (debug
/// build on an emulator). It is not the NFR1.1 target of 300 ms, which is
/// measured on the reference phone with a release build
/// (docs/release-checklist.md); until then NFR1.1 is open.
const provisionalSaveToListLimit = Duration(seconds: 2);

final FirebaseEnvConfig e2eConfig = FirebaseEnvConfig.fromEnvironment();

const userA = E2EIdentity(sub: 'user-a', email: 'user-a@example.com');
const userB = E2EIdentity(sub: 'user-b', email: 'user-b@example.com');

String get _host => e2eConfig.emulatorHost;
const _project = 'demo-vinoozy';

/// Calls an emulator REST endpoint as the emulator admin ("Bearer owner"
/// bypasses the rules), so checks read the cloud, never the app's cache.
Future<(int, Object?)> emulatorRequest(
  String method,
  int port,
  String path,
) async {
  final client = HttpClient();
  try {
    final request = await client.openUrl(
      method,
      Uri.parse('http://$_host:$port$path'),
    );
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer owner');
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    return (response.statusCode, body.isEmpty ? null : jsonDecode(body));
  } finally {
    client.close();
  }
}

/// Empties both emulators, so every test starts from nothing.
/// The Firestore reset can answer 500 while writes of the previous test are
/// still in flight, so it is retried a few times.
Future<void> clearEmulators() async {
  var fs = 0;
  for (var attempt = 0; attempt < 5 && fs != 200; attempt++) {
    if (attempt > 0) await Future<void>.delayed(const Duration(seconds: 1));
    (fs, _) = await emulatorRequest(
      'DELETE',
      FirebaseEnvConfig.firestoreEmulatorPort,
      '/emulator/v1/projects/$_project/databases/(default)/documents',
    );
  }
  final (auth, _) = await emulatorRequest(
    'DELETE',
    FirebaseEnvConfig.authEmulatorPort,
    '/emulator/v1/projects/$_project/accounts',
  );
  if (fs != 200 || auth != 200) {
    throw StateError('could not clear the emulators ($fs, $auth)');
  }
}

/// Reads a document from the Firestore emulator; null if it does not exist.
Future<Map<String, Object?>?> cloudDocument(String path) async {
  final (status, body) = await emulatorRequest(
    'GET',
    FirebaseEnvConfig.firestoreEmulatorPort,
    '/v1/projects/$_project/databases/(default)/documents/$path',
  );
  if (status == 404) return null;
  if (status != 200) throw StateError('GET $path -> $status');
  return ((body! as Map)['fields'] as Map).cast<String, Object?>();
}

/// Names of the wines of a cellar, as stored in the cloud.
Future<List<String>> cloudWineNames(String cellarId) async {
  final (status, body) = await emulatorRequest(
    'GET',
    FirebaseEnvConfig.firestoreEmulatorPort,
    '/v1/projects/$_project/databases/(default)/documents/cellars/$cellarId/wines',
  );
  if (status != 200) throw StateError('list wines -> $status');
  final documents = (body as Map?)?['documents'] as List? ?? const [];
  return [
    for (final doc in documents)
      ((doc as Map)['fields'] as Map)['name']['stringValue'] as String,
  ];
}

/// Clears the local state of the phone: session, ledger, Firestore cache.
///
/// Also on the very first test: a session or cache left on the emulator by an
/// earlier run must not leak into this one.
Future<void> clearPhone() async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: e2eConfig.options);
  }
  await FirebaseAuth.instance.signOut();
  // Same settings as the app, so the instance re-created later is correct.
  FirestoreBootstrap(
    firestore: () => FirebaseFirestore.instance,
    config: e2eConfig,
  ).configure();
  await FirebaseFirestore.instance.terminate();
  await FirebaseFirestore.instance.clearPersistence();
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}

/// Starts the real app (`main()`), keeping the test framework's error hooks.
Future<void> launchApp(WidgetTester tester) async {
  final flutterOnError = FlutterError.onError;
  final platformOnError = PlatformDispatcher.instance.onError;
  await app.runVinoozy();
  FlutterError.onError = flutterOnError;
  PlatformDispatcher.instance.onError = platformOnError;
  await tester.pump();
}

/// Pumps until [finder] matches, or fails after [timeout].
Future<void> waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 20),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('Timed out after $timeout waiting for $finder');
}

/// Waits until [condition] holds (polling real async work such as REST).
Future<void> eventually(
  WidgetTester tester,
  Future<bool> Function() condition, {
  Duration timeout = const Duration(seconds: 20),
  String? reason,
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    if (await condition()) return;
    await tester.pump(const Duration(milliseconds: 250));
  }
  throw TestFailure('Condition not met after $timeout: ${reason ?? ''}');
}

/// Taps "Continue with Google" as [identity] and waits for [then].
Future<void> signIn(
  WidgetTester tester,
  E2EIdentity identity, {
  required Finder then,
}) async {
  EmulatorGoogleAuthService.nextIdentity = identity;
  await waitFor(tester, find.byKey(const Key('sign-in-google-button')));
  await tester.tap(find.byKey(const Key('sign-in-google-button')));
  await waitFor(tester, then);
}

/// Adds a wine through the form; returns the time from the Save tap to the
/// wine's row in the list (NFR1.1).
Future<Duration> addWine(
  WidgetTester tester, {
  required String name,
  String? vintage,
  int quantity = 1,
}) async {
  await waitFor(tester, find.byKey(const Key('cellar-add-button')));
  await eventually(
    tester,
    () async =>
        tester
            .widget<ButtonStyleButton>(
              find.byKey(const Key('cellar-add-button')),
            )
            .onPressed !=
        null,
    reason: 'Add enabled',
  );
  await tester.tap(find.byKey(const Key('cellar-add-button')));
  await waitFor(tester, find.byKey(const Key('add-wine-name-field')));
  await tester.enterText(find.byKey(const Key('add-wine-name-field')), name);
  if (vintage == null) {
    await tester.tap(find.byKey(const Key('add-wine-no-vintage-switch')));
  } else {
    await tester.enterText(
      find.byKey(const Key('add-wine-vintage-field')),
      vintage,
    );
  }
  for (var i = 1; i < quantity; i++) {
    await tester.tap(find.byKey(const Key('quantity-increase-button')));
    await tester.pump();
  }
  final stopwatch = Stopwatch()..start();
  await tester.tap(find.byKey(const Key('add-wine-save-button')));
  // The row in the list, not the text still visible in the closing form.
  await waitFor(tester, wineRow(name));
  stopwatch.stop();
  await eventually(
    tester,
    () async => find.byKey(const Key('add-wine-screen')).evaluate().isEmpty,
    reason: 'the form closed',
  );
  return stopwatch.elapsed;
}

/// The cellar row showing [name].
Finder wineRow(String name) =>
    find.descendant(of: find.byType(WineListTile), matching: find.text(name));

/// Uid of the signed-in user.
String get currentUid => FirebaseAuth.instance.currentUser!.uid;

/// The app's ledger as stored on the phone (`ledger.v1`).
Future<LedgerState> readLedger() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  final raw = prefs.getString(LocalLedger.storageKey);
  if (raw == null) return LedgerState.empty;
  return LedgerState.fromJson(jsonDecode(raw) as Map<String, Object?>);
}
