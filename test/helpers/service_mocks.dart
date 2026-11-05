import 'package:mocktail/mocktail.dart';
import 'package:vinoozy/account/auth_service.dart';
import 'package:vinoozy/account/data/user_repository.dart';
import 'package:vinoozy/account/reset_coordinator.dart';
import 'package:vinoozy/cellar/data/cellar_repository.dart';
import 'package:vinoozy/cellar/data/wine_repository.dart';
import 'package:vinoozy/firebase/firestore_bootstrap.dart';
import 'package:vinoozy/sync/sync_watcher.dart';

/// mocktail doubles of the app's own services.
class MockAuthService extends Mock implements AuthService {}

class MockCellarRepository extends Mock implements CellarRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class MockWineRepository extends Mock implements WineRepository {}

class MockResetCoordinator extends Mock implements ResetCoordinator {}

class MockSyncWatcher extends Mock implements SyncWatcher {}

class MockFirestoreBootstrap extends Mock implements FirestoreBootstrap {}
