import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinoozy/cellar/domain/wine.dart';
import 'package:vinoozy/cellar/ui/wine_card.dart';
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

/// Own identity of the 500-wine Dashboard test (u5-dashboard
/// cicd-pipeline.md §1): a cellar no other test reads or counts.
const userDashboard = E2EIdentity(
  sub: 'user-dashboard',
  email: 'dashboard@example.com',
);

String get _host => e2eConfig.emulatorHost;
const _project = 'demo-vinoozy';

/// Calls an emulator REST endpoint as the emulator admin ("Bearer owner"
/// bypasses the rules), so checks read the cloud, never the app's cache.
/// With [bearer] it calls as that user's id token instead, through the rules.
Future<(int, Object?)> emulatorRequest(
  String method,
  int port,
  String path, {
  Map<String, Object?>? body,
  String bearer = 'owner',
}) async {
  final client = HttpClient();
  try {
    final request = await client.openUrl(
      method,
      Uri.parse('http://$_host:$port$path'),
    );
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $bearer');
    if (body != null) {
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(body));
    }
    final response = await request.close();
    final text = await response.transform(utf8.decoder).join();
    return (response.statusCode, text.isEmpty ? null : jsonDecode(text));
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

/// Changes `ownerId` of a cellar in the cloud as the emulator admin. With
/// another owner the real rules reject the wines listener of the signed-in
/// user (permission-denied); setting it back restores the access.
Future<void> setCloudCellarOwner(String cellarId, String ownerId) async {
  final (status, _) = await emulatorRequest(
    'PATCH',
    FirebaseEnvConfig.firestoreEmulatorPort,
    '/v1/projects/$_project/databases/(default)/documents/cellars/$cellarId'
        '?updateMask.fieldPaths=ownerId',
    body: {
      'fields': {
        'ownerId': {'stringValue': ownerId},
      },
    },
  );
  if (status != 200) throw StateError('PATCH cellars/$cellarId -> $status');
}

String _documentName(String path) =>
    'projects/$_project/databases/(default)/documents/$path';

/// Applies [writes] in one `:commit` of the Firestore emulator as its admin
/// (at most 500 writes, the Firestore limit).
Future<void> commitWrites(List<Map<String, Object?>> writes) async {
  final (status, body) = await emulatorRequest(
    'POST',
    FirebaseEnvConfig.firestoreEmulatorPort,
    '/v1/projects/$_project/databases/(default)/documents:commit',
    body: {'writes': writes},
  );
  if (status != 200) throw StateError(':commit -> $status $body');
}

/// REST fields of [wine] as U4 will store it (C3), window included.
Map<String, Object?> restWineFields(Wine wine) {
  Map<String, Object?> integer(int value) => {'integerValue': '$value'};
  Map<String, Object?> text(String value) => {'stringValue': value};
  final window = wine.window;
  return {
    WineFields.name: text(wine.name),
    WineFields.vintage: wine.vintage == null
        ? {'nullValue': 'NULL_VALUE'}
        : integer(wine.vintage!),
    WineFields.quantity: integer(wine.storedQuantity),
    if (wine.wineType != null) WineFields.wineType: text(wine.wineType!),
    if (wine.region != null) WineFields.region: text(wine.region!),
    if (window != null)
      WineFields.window: {
        'mapValue': {
          'fields': {
            WindowFields.startYear: integer(window.startYear),
            WindowFields.peakYear: integer(window.peakYear!),
            WindowFields.endYear: integer(window.endYear!),
            WindowFields.confidence: text(window.confidence.name),
            WindowFields.source: text(window.source.name),
            WindowFields.basis: text(window.basis.name),
          },
        },
      },
    WineFields.createdAt: {'timestampValue': '2026-11-06T10:00:00Z'},
    WineFields.updatedAt: {'timestampValue': '2026-11-06T10:00:00Z'},
    WineFields.updatedBy: text('seed'),
  };
}

/// Creates [wines] in `cellars/{cellarId}/wines` with a single `:commit`.
Future<void> seedCloudWines(String cellarId, List<Wine> wines) => commitWrites([
  for (final wine in wines)
    {
      'update': {
        'name': _documentName('cellars/$cellarId/wines/${wine.id}'),
        'fields': restWineFields(wine),
      },
    },
]);

/// Deletes [wineIds] of the cellar and the cellar itself, as the emulator
/// admin (the clean-up of the 500-wine test).
Future<void> deleteCloudCellar(String cellarId, List<String> wineIds) =>
    commitWrites([
      for (final id in wineIds)
        {'delete': _documentName('cellars/$cellarId/wines/$id')},
      {'delete': _documentName('cellars/$cellarId')},
    ]);

/// The wines of a cellar as the emulator stores them: the REST `fields` of
/// each document (label-autofill-windows e2e).
Future<List<Map<String, Object?>>> cloudWineDocuments(String cellarId) async {
  final (status, body) = await emulatorRequest(
    'GET',
    FirebaseEnvConfig.firestoreEmulatorPort,
    '/v1/projects/$_project/databases/(default)/documents/cellars/$cellarId/wines',
  );
  if (status != 200) throw StateError('list wines -> $status');
  final documents = (body as Map?)?['documents'] as List? ?? const [];
  return [
    for (final doc in documents)
      ((doc as Map)['fields'] as Map).cast<String, Object?>(),
  ];
}

/// The plain value of a REST field: strings, integers, maps; `null` when
/// the field is absent.
Object? restValue(Object? field) {
  if (field is! Map) return null;
  if (field.containsKey('stringValue')) return field['stringValue'];
  if (field.containsKey('integerValue')) {
    return int.parse('${field['integerValue']}');
  }
  if (field.containsKey('mapValue')) {
    final fields = (field['mapValue'] as Map)['fields'] as Map? ?? const {};
    return {
      for (final entry in fields.entries)
        '${entry.key}': restValue(entry.value),
    };
  }
  if (field.containsKey('nullValue')) return null;
  return field.values.first;
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

/// The owner of a cellar acting from the test through the emulators' REST
/// API with their own id token (u7-sharing security-design.md §5): every
/// write passes the real rules, unlike the admin "Bearer owner". Each
/// operation is one `:commit` with the cellar counter and the invitation, as
/// the app's SharingRepository writes them.
class OwnerRestClient {
  OwnerRestClient._(this.idToken, this.uid);

  final String idToken;

  /// The uid the Auth Emulator assigned: owner id and personal cellar id.
  final String uid;

  static Map<String, Object?> _text(String value) => {'stringValue': value};

  static Map<String, Object?> _now(String field) => {
    'fieldPath': field,
    'setToServerValue': 'REQUEST_TIME',
  };

  Map<String, Object?> _counter(String memberKey, int delta) => {
    'update': {
      'name': _documentName('cellars/$uid'),
      'fields': {'memberOpKey': _text(memberKey)},
    },
    'updateMask': {
      'fieldPaths': ['memberOpKey'],
    },
    'updateTransforms': [
      {
        'fieldPath': 'memberSlots',
        'increment': {'integerValue': '$delta'},
      },
    ],
  };

  Map<String, Object?> _memberUpdate(
    String memberKey,
    Map<String, Object?> fields,
  ) => {
    'update': {
      'name': _documentName('cellars/$uid/members/$memberKey'),
      'fields': fields,
    },
    'updateMask': {'fieldPaths': fields.keys.toList()},
    'updateTransforms': [_now('updatedAt')],
  };

  Future<void> _commit(List<Map<String, Object?>> writes) async {
    final (status, body) = await emulatorRequest(
      'POST',
      FirebaseEnvConfig.firestoreEmulatorPort,
      '/v1/projects/$_project/databases/(default)/documents:commit',
      body: {'writes': writes},
      bearer: idToken,
    );
    if (status != 200) throw StateError('owner :commit -> $status $body');
  }

  /// The personal cellar `cellars/{uid}`, as `ensurePersonalCellar` writes it.
  Future<void> createCellar(String name) => _commit([
    {
      'update': {
        'name': _documentName('cellars/$uid'),
        'fields': {
          'ownerId': _text(uid),
          'name': _text(name),
          'schemaVersion': {'integerValue': '1'},
        },
      },
      'updateTransforms': [_now('createdAt')],
      'currentDocument': {'exists': false},
    },
  ]);

  /// A new invitation of [email] with [permission], counter +1.
  Future<void> invite(String email, String permission, String ownerName) =>
      _commit([
        {
          'update': {
            'name': _documentName('cellars/$uid/members/$email'),
            'fields': {
              'inviteeEmail': _text(email),
              'permission': _text(permission),
              'status': _text('invited'),
              'ownerId': _text(uid),
              'ownerName': _text(ownerName),
            },
          },
          'updateTransforms': [_now('invitedAt'), _now('updatedAt')],
          'currentDocument': {'exists': false},
        },
        _counter(email, 1),
      ]);

  Future<void> changePermission(String email, String permission) => _commit([
    _memberUpdate(email, {'permission': _text(permission)}),
  ]);

  /// `revoked`, closed by the owner, counter -1.
  Future<void> revoke(String email) => _commit([
    _memberUpdate(email, {
      'status': _text('revoked'),
      'closedBy': _text('owner'),
    }),
    _counter(email, -1),
  ]);

  /// A wine of the owner's cellar as u4-cellar writes it, `matchKey`
  /// included (u4-cellar NFR6.3).
  Future<void> createWine(
    String wineId, {
    required String name,
    required int quantity,
  }) => _commit([
    {
      'update': {
        'name': _documentName('cellars/$uid/wines/$wineId'),
        'fields': {
          'name': _text(name),
          'vintage': {'nullValue': 'NULL_VALUE'},
          'quantity': {'integerValue': '$quantity'},
          'matchKey': _text('${name.toLowerCase()}||'),
          'updatedBy': _text(uid),
        },
      },
      'updateTransforms': [_now('createdAt'), _now('updatedAt')],
      'currentDocument': {'exists': false},
    },
  ]);

  /// "Drunk" by the owner (u4-cellar BR1.10): the quantity as an increment
  /// of −1 and the drink, in one commit, as DrinkingRecordRepository writes
  /// them.
  Future<void> recordDrink(
    String wineId,
    String recordId, {
    required String wineName,
    required String drankOn,
  }) => _commit([
    {
      'update': {
        'name': _documentName('cellars/$uid/wines/$wineId'),
        'fields': {'updatedBy': _text(uid)},
      },
      'updateMask': {
        'fieldPaths': ['updatedBy'],
      },
      'updateTransforms': [
        {
          'fieldPath': 'quantity',
          'increment': {'integerValue': '-1'},
        },
        _now('updatedAt'),
      ],
    },
    {
      'update': {
        'name': _documentName('cellars/$uid/drinkingRecords/$recordId'),
        'fields': {
          'wineId': _text(wineId),
          'wineName': _text(wineName),
          'drankOn': _text(drankOn),
          'recordedBy': _text(uid),
        },
      },
      'updateTransforms': [_now('createdAt')],
      'currentDocument': {'exists': false},
    },
  ]);
}

/// The `quantity` stored in the cloud for a wine, or null without it.
Future<int?> cloudQuantity(String cellarId, String wineId) async {
  final fields = await cloudDocument('cellars/$cellarId/wines/$wineId');
  final quantity = (fields?['quantity'] as Map?)?['integerValue'];
  return quantity == null ? null : int.parse(quantity as String);
}

/// How many drinks of [cellarId] the cloud has.
Future<int> cloudDrinkCount(String cellarId) async {
  final (status, body) = await emulatorRequest(
    'GET',
    FirebaseEnvConfig.firestoreEmulatorPort,
    '/v1/projects/$_project/databases/(default)/documents/cellars/$cellarId/drinkingRecords',
  );
  if (status != 200) throw StateError('list drinks -> $status');
  return ((body as Map?)?['documents'] as List?)?.length ?? 0;
}

String _base64UrlJson(Map<String, Object?> value) =>
    base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');

/// Signs [identity] in to the Auth Emulator with an unsigned Google id token
/// (`signInWithIdp`), which only the emulator accepts, and returns the
/// client acting as that owner through the rules (u7 NFR2.3, NFR7.4).
Future<OwnerRestClient> ownerRestClient(E2EIdentity identity) async {
  final jwt = [
    _base64UrlJson({'alg': 'none', 'typ': 'JWT'}),
    _base64UrlJson({
      'sub': identity.sub,
      'email': identity.email,
      'email_verified': true,
      'name': identity.email.split('@').first,
    }),
    '',
  ].join('.');
  final (status, body) = await emulatorRequest(
    'POST',
    FirebaseEnvConfig.authEmulatorPort,
    '/identitytoolkit.googleapis.com/v1/accounts:signInWithIdp'
        '?key=fake-api-key',
    body: {
      'postBody':
          'id_token=${Uri.encodeQueryComponent(jwt)}'
          '&providerId=google.com',
      'requestUri': 'http://localhost',
      'returnSecureToken': true,
    },
  );
  if (status != 200) throw StateError('signInWithIdp -> $status $body');
  final response = body! as Map;
  return OwnerRestClient._(
    response['idToken'] as String,
    response['localId'] as String,
  );
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
  // u8-account BR1.1: the first-start presentation is a test of its own
  // (account_test.dart); every other test starts on the sign-in screen.
  if (!showOnboarding) await prefs.setBool('onboarding.seen', true);
}

/// Set by account_test.dart to see the first-start presentation after
/// [clearPhone].
bool showOnboarding = false;

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
///
/// Since u5-dashboard the app opens on the Dashboard and the cellar list is
/// the "Cantina" tab. With [viaCellarTab] (the default, for the U1 checks)
/// the Cantina tab is opened whenever the Dashboard is on screen; the
/// Dashboard tests pass `false`.
Future<void> waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 20),
  bool viaCellarTab = true,
}) async {
  final cellarTab = find.byKey(const Key('home-nav-cellar'));
  final dashboardOnScreen = find.byKey(const Key('dashboard-screen'));
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
    if (viaCellarTab &&
        dashboardOnScreen.evaluate().isNotEmpty &&
        cellarTab.evaluate().isNotEmpty) {
      await tester.tap(cellarTab);
    }
  }
  throw TestFailure(
    'Timed out after $timeout waiting for $finder\n'
    'On screen: ${visibleKeys().join(', ')}',
  );
}

/// The string keys of the widgets on screen (offstage ones excluded), in
/// tree order: a timed-out wait names what the app was showing instead,
/// such as a dialog covering the tab bar (actions-release-fix, account
/// deletion E2E that timed out in CI without saying why).
List<String> visibleKeys() {
  final keys = <String>[];
  for (final element
      in find
          .byWidgetPredicate((widget) => widget.key is ValueKey<String>)
          .evaluate()) {
    final value = (element.widget.key! as ValueKey<String>).value;
    if (!keys.contains(value)) keys.add(value);
    if (keys.length >= 60) break;
  }
  return keys;
}

/// Taps [finder] once it can really receive the tap.
///
/// A SnackBar sliding in, or one shown by the shell over the Cellar's "Add"
/// bar, covers the target for a few seconds: like a person, the test waits
/// until the target is hittable instead of tapping whatever is on top.
Future<void> tapWhenHittable(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 20),
}) async {
  await waitFor(
    tester,
    finder.hitTestable(),
    timeout: timeout,
    viaCellarTab: false,
  );
  await tester.tap(finder);
  await tester.pump();
}

/// Waits for "… shared their cellar with you" (u7 BR1.4) and closes it with
/// "OK": the dialog covers the screen until the person answers it.
Future<void> acknowledgeSharedNotice(
  WidgetTester tester, {
  Duration timeout = const Duration(seconds: 20),
}) async {
  await waitFor(
    tester,
    find.byKey(const Key('shared-cellar-notice')),
    timeout: timeout,
    viaCellarTab: false,
  );
  await tapWhenHittable(
    tester,
    find.byKey(const Key('shared-cellar-notice-ok')),
  );
  await tester.pumpAndSettle();
}

/// Waits until the cellar of [uid] exists in the Firestore emulator: the app
/// creates it after sign-in, and the rules refuse invitations and wines of a
/// cellar that is not there yet.
Future<void> waitForCloudCellar(WidgetTester tester, String uid) => eventually(
  tester,
  () async => await cloudDocument('cellars/$uid') != null,
  reason: 'the cellar of $uid reached the server',
);

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
  bool viaCellarTab = true,
  Duration timeout = const Duration(seconds: 20),
}) async {
  EmulatorGoogleAuthService.nextIdentity = identity;
  await waitFor(tester, find.byKey(const Key('sign-in-google-button')));
  await tester.tap(find.byKey(const Key('sign-in-google-button')));
  await waitFor(tester, then, viaCellarTab: viaCellarTab, timeout: timeout);
}

/// Adds a wine through the form; returns the time from the Save tap to the
/// wine's row in the list (NFR1.1). With [country] the flag of the grid is
/// tapped, then [region] among its chips (ux-redesign FR1.1, FR1.2).
Future<Duration> addWine(
  WidgetTester tester, {
  required String name,
  String? vintage,
  int quantity = 1,
  String? country,
  String? region,
}) async {
  await waitFor(tester, find.byKey(const Key('cellar-add-button')));
  await eventually(
    tester,
    () async =>
        tester
            .widget<FloatingActionButton>(
              find.byKey(const Key('cellar-add-button')),
            )
            .onPressed !=
        null,
    reason: 'Add enabled',
  );
  await tester.tap(find.byKey(const Key('cellar-add-button')));
  // Since u6-label-recognition "Aggiungi" offers three ways (BR1.1):
  // "Scrivi" opens the form.
  await waitFor(tester, find.byKey(const Key('add-choice-write')));
  await tester.tap(find.byKey(const Key('add-choice-write')));
  await waitFor(tester, find.byKey(const Key('add-wine-name-field')));
  await tester.enterText(find.byKey(const Key('add-wine-name-field')), name);
  if (country != null) {
    await tapVisible(tester, find.byKey(Key('country-cell-$country')));
    if (region != null) {
      await tapVisible(tester, find.byKey(Key('region-chip-$region')));
    }
  }
  if (vintage == null) {
    // ux-redesign: country and region come first, the switch is lower.
    await tapVisible(
      tester,
      find.byKey(const Key('add-wine-no-vintage-switch')),
    );
  } else {
    await tester.enterText(
      find.byKey(const Key('add-wine-vintage-field')),
      vintage,
    );
  }
  for (var i = 1; i < quantity; i++) {
    await tapVisible(tester, find.byKey(const Key('quantity-increase-button')));
  }
  // Since u4-cellar the suggestions may push "Save" below the fold.
  final save = find.byKey(const Key('add-wine-save-button'));
  await tester.ensureVisible(save);
  await tester.pump();
  final stopwatch = Stopwatch()..start();
  await tester.tap(save);
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

/// The cellar card showing [name] (ux-redesign WineCard: "name vintage" on
/// one line).
Finder wineRow(String name) => find.descendant(
  of: find.byType(WineCard),
  matching: find.textContaining(RegExp('^${RegExp.escape(name)}( |\$)')),
);

/// The card of [name].
Finder wineCardOf(String name) =>
    find.ancestor(of: wineRow(name), matching: find.byType(WineCard));

/// "Ho bevuto" of the card of [name] (ux-redesign FR2.1).
Finder drinkButtonOf(String name) => find.descendant(
  of: wineCardOf(name),
  matching: find.byIcon(drinkActionIcon),
);

/// Scrolls [finder] into the middle of the view, then taps it.
///
/// The real keyboard of the emulator and the fixed "Save" bar of the forms
/// cover the screen edges: `ensureVisible` alone stops at an edge, so the
/// keyboard is closed first and the target is centred, then tapped only once
/// it really receives the tap.
Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pump(const Duration(milliseconds: 300));
  await waitFor(tester, finder, viaCellarTab: false);
  unawaited(
    Scrollable.ensureVisible(
      tester.element(finder),
      alignment: 0.5,
      duration: const Duration(milliseconds: 1),
    ),
  );
  await tester.pump(const Duration(milliseconds: 50));
  await tapWhenHittable(tester, finder);
}

/// "Ho bevuto" on [button], then the confirmation sheet (ux-redesign
/// FR2.2): optionally [stars], then "Sì, l'ho bevuta". Nothing is written
/// before the confirmation.
Future<void> drinkAndConfirm(
  WidgetTester tester,
  Finder button, {
  int? stars,
}) async {
  await tapWhenHittable(tester, button);
  await waitFor(tester, find.byKey(const Key('drink-confirm')));
  if (stars != null) {
    await tester.tap(find.byKey(Key('drink-confirm-star-$stars')));
    await tester.pump();
  }
  await tapWhenHittable(tester, find.byKey(const Key('drink-confirm')));
}

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
