// Catalog providers (catalog_providers.dart): composition, clear() on every
// change of uid, no user means no cache, Open Food Facts only with a contact
// (BR5.1, BR5.2, NFR4.3, NFR8.1).
import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vinoozy/account/app_user.dart';
import 'package:vinoozy/account/auth_service.dart';
import 'package:vinoozy/app/providers.dart';
import 'package:vinoozy/catalog/core/catalog_config.dart';
import 'package:vinoozy/catalog/core/catalog_coordinator.dart';
import 'package:vinoozy/catalog/core/catalog_event_logger.dart';
import 'package:vinoozy/catalog/core/wine_catalog.dart';
import 'package:vinoozy/catalog/platform/catalog_providers.dart';
import 'package:vinoozy/catalog/platform/file_cache_file.dart';
import 'package:vinoozy/l10n/app_localizations.dart';

import 'catalog_test_helpers.dart';

const _alice = AppUser(uid: 'uid-alice', email: 'a@x.test', displayName: 'A');
const _bob = AppUser(uid: 'uid-bob', email: 'b@x.test', displayName: 'B');

class _FakeAuth implements AuthService {
  _FakeAuth(this.currentUser);

  @override
  AppUser? currentUser;
  final changes = StreamController<AppUser?>.broadcast();

  @override
  Stream<AppUser?> userChanges() => changes.stream;

  void emit(AppUser? user) {
    currentUser = user;
    changes.add(user);
  }

  @override
  Future<AppUser> signIn() => throw UnimplementedError();

  @override
  Future<void> signOut() async {}

  // u8-account additions to AuthService, unused here.
  @override
  String? get photoUrl => null;

  @override
  Future<ReauthResult> reauthenticate() => throw UnimplementedError();

  @override
  Future<void> deleteUser() => throw UnimplementedError();
}

class _Harness {
  _Harness({AppUser? user, String contact = ''}) : auth = _FakeAuth(user) {
    container = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(auth),
        clockProvider.overrideWithValue(clock),
        catalogCacheFileProvider.overrideWithValue(file),
        catalogEventLoggerProvider.overrideWithValue(logger),
        catalogOffContactProvider.overrideWithValue(contact),
        catalogAppVersionProvider.overrideWith((ref) async => '9.9.9'),
        catalogHttpClientProvider.overrideWithValue(
          MockClient((request) async {
            requests.add(request);
            return http.Response.bytes(
              utf8.encode(fixture('search_wines.json')),
              200,
            );
          }),
        ),
      ],
    );
  }

  final _FakeAuth auth;
  final clock = FakeClock();
  final file = InMemoryCacheFile();
  final logger = RecordingLogger();
  final requests = <http.Request>[];
  late final ProviderContainer container;

  /// Kept listened, as U4 does with `ref.watch`: Riverpod pauses providers
  /// nobody listens to.
  CatalogCoordinator get session =>
      container.listen(catalogSessionProvider, (_, _) {}).read();

  /// Lets the uid stream and the session start run.
  Future<void> pump() async {
    for (var i = 0; i < 5; i++) {
      await settle();
    }
  }
}

void main() {
  test('catalogProvider is the session coordinator', () async {
    final h = _Harness(user: _alice);
    addTearDown(h.container.dispose);
    final catalog = h.container.read(catalogProvider);
    expect(catalog, isA<WineCatalog>());
    expect(identical(catalog, h.session), isTrue);
    expect(catalog.suggestWines('barolo').suggestions, isNotEmpty);
  });

  test('BR5.1 without a contact Open Food Facts is never created', () async {
    final h = _Harness(user: _alice);
    addTearDown(h.container.dispose);
    await h.pump();
    final result = await h.session.suggestExternal('barolo');
    expect(result, SuggestResult.empty);
    expect(h.requests, isEmpty);
    expect(h.logger.debugEvents, contains(CatalogDebugEvent.offDisabled));
  });

  test('with a contact the User-Agent carries version and contact', () async {
    final h = _Harness(user: _alice, contact: 'team.example');
    addTearDown(h.container.dispose);
    await h.pump();
    final result = await h.session.suggestExternal('barolo');
    expect(result.externalIncluded, isTrue);
    expect(
      h.requests.single.headers['User-Agent'],
      'Vinoozy/9.9.9 (team.example)',
    );
  });

  test(
    'NFR8.1 a change of uid clears the previous user cache and file',
    () async {
      final h = _Harness(user: _alice, contact: 'team.example');
      addTearDown(h.container.dispose);
      final session = h.session;
      await h.pump();
      await session.suggestExternal('barolo');
      await session.clear().then((_) async {});
      // Saved again by a new answer, then the user changes.
      await h.pump();
      await session.suggestExternal('barolo');
      h.auth.emit(_bob);
      await h.pump();
      expect(h.file.contents, isNull);
      expect(h.file.deletes, greaterThanOrEqualTo(1));
      // Bob's first search is asked again: Alice's answer is gone.
      final before = h.requests.length;
      await session.suggestExternal('barolo');
      expect(h.requests.length, before + 1);
    },
  );

  test('NFR8.1 nobody signed in: nothing is loaded or saved', () async {
    final h = _Harness(contact: 'team.example');
    h.file.contents = '{"version":1,"owner":null,"entries":[],"hints":[]}';
    addTearDown(h.container.dispose);
    final session = h.session;
    await h.pump();
    await session.suggestExternal('barolo');
    h.clock.advance(const Duration(seconds: 3));
    await session.suggestExternal('soave');
    expect(h.file.commits, 0);
  });

  test('the owner of the cache is the SHA-256 of the uid, never the uid', () {
    final hash = catalogOwnerHash('uid-alice');
    expect(hash, sha256.convert(utf8.encode('uid-alice')).toString());
    expect(hash, hasLength(64));
    expect(hash, isNot(contains('alice')));
  });

  group('default providers', () {
    test('version from package_info_plus, logger and cache file', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      PackageInfo.setMockInitialValues(
        appName: 'Vinoozy',
        packageName: 'com.vinoozy.vinoozy',
        version: '0.1.0',
        buildNumber: '1',
        buildSignature: '',
      );
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(await container.read(catalogAppVersionProvider.future), '0.1.0');
      expect(container.read(catalogOffContactProvider), isEmpty);
      expect(container.read(catalogCacheFileProvider), isA<FileCacheFile>());
      expect(
        container.read(catalogEventLoggerProvider),
        isA<ConsoleCatalogEventLogger>(),
      );
      expect(container.read(catalogHttpClientProvider), isA<http.Client>());
    });
  });

  group('BR5.2 attribution', () {
    test('BR5.2 offAttribution in the three app languages, ODbL link', () {
      expect(
        lookupAppLocalizations(const Locale('it')).offAttribution,
        'Dati da Open Food Facts (ODbL)',
      );
      expect(
        lookupAppLocalizations(const Locale('en')).offAttribution,
        'Data from Open Food Facts (ODbL)',
      );
      expect(
        lookupAppLocalizations(
          const Locale.fromSubtags(languageCode: 'pt', countryCode: 'BR'),
        ).offAttribution,
        'Dados do Open Food Facts (ODbL)',
      );
      expect(Uri.parse(CatalogConfig.offLicenseUrl).scheme, 'https');
      expect(CatalogConfig.offLicenseUrl, contains('odbl'));
    });
  });
}
