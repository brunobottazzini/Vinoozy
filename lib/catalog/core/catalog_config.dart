// Configuration of the catalog (security-design.md §2, NFR4.3).
//
// The Open Food Facts contact comes only from the production build
// configuration (`--dart-define-from-file=config/firebase_prod.json`, never
// committed). Development builds, tests, end-to-end tests and CI do not have
// it, so Open Food Facts is off there and the real service is never called.

import 'dart:async';

/// Creates the timers of the catalog (request deadline, cache saves);
/// [Timer.new] in production, a manually fired fake in tests, so no test
/// waits on real time.
typedef CatalogTimerFactory = Timer Function(
  Duration duration,
  void Function() callback,
);

/// What the catalog needs to call Open Food Facts.
class CatalogConfig {
  const CatalogConfig({
    required this.appVersion,
    this.offContact = contactFromEnvironment,
  });

  /// Fixed Open Food Facts host: the only external address of the module.
  static const String offHost = 'world.openfoodfacts.org';

  /// Licence of the Open Food Facts data, linked next to the attribution
  /// text `offAttribution` (BR5.2, NFR4.6).
  static const String offLicenseUrl =
      'https://opendatacommons.org/licenses/odbl/1-0/';

  /// Contact of this build, empty unless the production defines set it.
  static const String contactFromEnvironment = String.fromEnvironment(
    'OFF_CONTACT',
  );

  /// App version name, read by the platform layer at start-up.
  final String appVersion;
  final String offContact;

  /// Open Food Facts is used only with a configured contact (BR5.1).
  bool get offEnabled => offContact.trim().isNotEmpty;

  /// Identification required by Open Food Facts:
  /// `Vinoozy/<version> (<contact>)`.
  String get userAgent => 'Vinoozy/$appVersion (${offContact.trim()})';
}
