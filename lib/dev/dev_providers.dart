import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import 'dev_cheats.dart';
import 'dev_entitlement_fixture.dart';

/// The emulator fixture of the developer scenarios (FR5.6), created at
/// start-up only when `kDevCheatsAvailable`.
final devEntitlementFixtureProvider = Provider<DevEntitlementFixture?>(
  (ref) => null,
);

/// The recogniser of the hidden sequence (FR5.2). The screens report steps
/// to it only inside `if (kDevCheatsAvailable)`.
final secretSequenceProvider = Provider<SecretSequenceDetector>(
  (ref) => SecretSequenceDetector(clock: ref.watch(clockProvider)),
);
