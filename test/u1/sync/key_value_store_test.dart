import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinoozy/sync/ledger/key_value_store.dart';

class _MockPreferences extends Mock implements SharedPreferences {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('SharedPreferencesStore writes and reads back a value', () async {
    SharedPreferences.setMockInitialValues({});
    final store = SharedPreferencesStore();

    await store.write('ledger.v1', '{"journal":[]}');

    expect(await store.read('ledger.v1'), '{"journal":[]}');
    expect(await SharedPreferencesStore().read('ledger.v1'), '{"journal":[]}');
  });

  test('a missing key reads as null', () async {
    SharedPreferences.setMockInitialValues({'other': 'x'});

    expect(await SharedPreferencesStore().read('ledger.v1'), isNull);
  });

  test('a refused platform write raises KeyValueStoreException', () async {
    final prefs = _MockPreferences();
    when(() => prefs.setString(any(), any())).thenAnswer((_) async => false);
    final store = SharedPreferencesStore(open: () async => prefs);

    await expectLater(
      store.write('ledger.v1', 'x'),
      throwsA(
        isA<KeyValueStoreException>().having(
          (e) => e.toString(),
          'message',
          contains('ledger.v1'),
        ),
      ),
    );
  });

  test('a platform exception propagates to the caller', () async {
    final prefs = _MockPreferences();
    when(() => prefs.getString(any())).thenThrow(Exception('io'));
    final store = SharedPreferencesStore(open: () async => prefs);

    await expectLater(store.read('ledger.v1'), throwsException);
  });
}
