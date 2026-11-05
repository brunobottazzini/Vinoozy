// The SDK marks these types @sealed to discourage implementations in app
// code. Test doubles of the adapters' dependencies are the documented
// exception; nothing in lib/ implements them.
// ignore_for_file: subtype_of_sealed_class
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mocktail/mocktail.dart';

/// mocktail doubles of the Firestore SDK, used only by the tests of the
/// adapters (repositories, bootstrap, gateway). Everything above the adapters
/// is tested against the app's own interfaces.
class MockFirestore extends Mock implements FirebaseFirestore {}

class MockDocRef extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockCollectionRef extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

class MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

class MockQueryDocSnapshot extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {}

class MockMetadata extends Mock implements SnapshotMetadata {}

class MockTransaction extends Mock implements Transaction {}

/// Registers the fallback values mocktail needs for `any()` matchers.
void registerFirestoreFallbacks() {
  registerFallbackValue(<String, dynamic>{});
  registerFallbackValue(<Object, Object?>{});
  registerFallbackValue(MockDocRef());
  registerFallbackValue(const GetOptions());
  registerFallbackValue(const Settings());
  Future<void> noopHandler(Transaction _) async {}
  registerFallbackValue(noopHandler);
}

MockMetadata metadata({bool pending = false, bool fromCache = false}) {
  final meta = MockMetadata();
  when(() => meta.hasPendingWrites).thenReturn(pending);
  when(() => meta.isFromCache).thenReturn(fromCache);
  return meta;
}

MockDocSnapshot docSnapshot({
  required bool exists,
  Map<String, dynamic>? data,
  bool pending = false,
  bool fromCache = false,
}) {
  final snapshot = MockDocSnapshot();
  when(() => snapshot.exists).thenReturn(exists);
  when(() => snapshot.data()).thenReturn(data);
  final meta = metadata(pending: pending, fromCache: fromCache);
  when(() => snapshot.metadata).thenReturn(meta);
  return snapshot;
}

/// Makes `db.runTransaction` run its handler against [transaction].
void runTransactionsWith(MockFirestore db, MockTransaction transaction) {
  when(() => db.runTransaction<void>(any())).thenAnswer((invocation) async {
    final handler =
        invocation.positionalArguments.first as TransactionHandler<void>;
    await handler(transaction);
  });
}

FirebaseException firestoreError(String code) =>
    FirebaseException(plugin: 'cloud_firestore', code: code, message: code);
