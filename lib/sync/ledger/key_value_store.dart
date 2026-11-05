import 'package:shared_preferences/shared_preferences.dart';

/// Minimal persistent string store behind [LocalLedger].
///
/// Keeping the ledger behind this interface lets unit tests run without
/// touching the disk (logical-components.md, "Isolamento").
abstract interface class KeyValueStore {
  Future<String?> read(String key);

  /// Persists [value]; throws [KeyValueStoreException] when the platform store
  /// reports a failed write.
  Future<void> write(String key, String value);
}

/// Raised when the platform preferences store cannot persist a value.
class KeyValueStoreException implements Exception {
  KeyValueStoreException(this.message);

  final String message;

  @override
  String toString() => 'KeyValueStoreException: $message';
}

/// [KeyValueStore] backed by `shared_preferences` (tech-stack-decisions.md).
class SharedPreferencesStore implements KeyValueStore {
  SharedPreferencesStore({Future<SharedPreferences> Function()? open})
    : _open = open ?? SharedPreferences.getInstance;

  final Future<SharedPreferences> Function() _open;
  SharedPreferences? _prefs;

  Future<SharedPreferences> _instance() async => _prefs ??= await _open();

  @override
  Future<String?> read(String key) async => (await _instance()).getString(key);

  @override
  Future<void> write(String key, String value) async {
    final saved = await (await _instance()).setString(key, value);
    if (!saved) {
      throw KeyValueStoreException('the platform store refused key "$key"');
    }
  }
}
