// Shared fixtures and fakes of the u7-sharing tests
// (unit-test-instructions.md): users with @example.com addresses, membership
// builders, the mocktail doubles of the repository and of the Firestore
// batch, and a fake network.
// ignore_for_file: subtype_of_sealed_class
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinoozy/account/app_user.dart';
import 'package:vinoozy/app/providers.dart';
import 'package:vinoozy/cellar/data/cellar_repository.dart';
import 'package:vinoozy/cellar/data/wine_repository.dart';
import 'package:vinoozy/cellar/domain/cellar.dart';
import 'package:vinoozy/sharing/data/sharing_repository.dart';
import 'package:vinoozy/sharing/domain/membership.dart';
import 'package:vinoozy/sharing/sharing_providers.dart';
import 'package:vinoozy/sharing/ui/share_launcher.dart';
import 'package:vinoozy/sync/snapshot_meta.dart';

import '../cellar/cellar_harness.dart' show cellarServiceOverrides;
import '../helpers/firestore_mocks.dart';
import '../helpers/service_mocks.dart';
import '../u1/ui/sign_in_screen_test.dart' show FakeNetwork;

/// The owner of the cellar `user-a`.
const owner = AppUser(
  uid: 'user-a',
  email: 'mario@example.com',
  displayName: 'Mario',
);

/// An invited person.
const invitee = AppUser(
  uid: 'user-b',
  email: 'giulia@example.com',
  displayName: 'Giulia',
);

/// A second invited person.
const secondInvitee = AppUser(
  uid: 'user-c',
  email: 'luca@example.com',
  displayName: 'Luca',
);

/// A membership of [cellarId] for [email], as read from Firestore.
Membership membership({
  String cellarId = 'user-a',
  String email = 'giulia@example.com',
  MemberStatus status = MemberStatus.active,
  MemberPermission permission = MemberPermission.edit,
  String ownerId = 'user-a',
  String ownerName = 'Mario',
  String? inviteeName = 'Giulia',
  ClosedBy? closedBy,
}) => Membership(
  cellarId: cellarId,
  memberKey: email,
  inviteeEmail: email,
  permission: permission,
  status: status,
  ownerId: ownerId,
  ownerName: ownerName,
  inviteeName: inviteeName,
  closedBy: closedBy,
);

/// Firestore map of a membership, for the mapper tests.
Map<String, dynamic> memberData(Membership member) => {
  MemberFields.inviteeEmail: member.inviteeEmail,
  MemberFields.permission: member.permission.name,
  MemberFields.status: member.status.name,
  MemberFields.ownerId: member.ownerId,
  MemberFields.ownerName: member.ownerName,
  if (member.inviteeName != null) MemberFields.inviteeName: member.inviteeName,
  if (member.closedBy != null) MemberFields.closedBy: member.closedBy!.name,
};

/// mocktail double of the sharing service, for providers and screens.
class MockSharingRepository extends Mock implements SharingRepository {}

class MockWriteBatch extends Mock implements WriteBatch {}

class MockQuery extends Mock implements Query<Map<String, dynamic>> {}

/// A query snapshot of [members] under their `cellars/{id}/members/{key}`
/// paths.
MockQuerySnapshot memberQuerySnapshot(
  List<Membership> members, {
  bool fromCache = false,
}) {
  final snapshot = MockQuerySnapshot();
  final docs = [
    for (final member in members)
      _memberDoc(
        'cellars/${member.cellarId}/members/${member.memberKey}',
        memberData(member),
      ),
  ];
  when(() => snapshot.docs).thenReturn(docs);
  final meta = metadata(fromCache: fromCache);
  when(() => snapshot.metadata).thenReturn(meta);
  return snapshot;
}

MockQueryDocSnapshot _memberDoc(String path, Map<String, dynamic> data) {
  final doc = MockQueryDocSnapshot();
  final ref = MockDocRef();
  when(() => ref.path).thenReturn(path);
  when(() => doc.reference).thenReturn(ref);
  when(() => doc.data()).thenReturn(data);
  return doc;
}

/// Controllable streams behind a [MockSharingRepository]: the person's own
/// invitations and the members of a cellar, counting the open listeners
/// (NFR5.1).
class SharingStreams {
  SharingStreams() {
    // The `any(named: 'user')` below needs it, also outside the sharing tests.
    registerFallbackValue(owner);
    when(() => repository.watchMyMemberships(any())).thenAnswer((_) {
      myListens++;
      return _tracked(mine, () => myOpen++, () => myOpen--);
    });
    when(() => repository.watchCellarMembers(any())).thenAnswer((_) {
      memberListens++;
      return _tracked(members, () => membersOpen++, () => membersOpen--);
    });
    when(
      () => repository.activate(
        cellarId: any(named: 'cellarId'),
        user: any(named: 'user'),
      ),
    ).thenAnswer((invocation) async {
      activated.add(invocation.namedArguments[#cellarId] as String);
    });
  }

  final repository = MockSharingRepository();
  final mine = StreamController<MembershipsSnapshot>.broadcast();
  final members = StreamController<List<Membership>>.broadcast();
  final List<String> activated = [];
  int myListens = 0;
  int myOpen = 0;
  int memberListens = 0;
  int membersOpen = 0;

  Stream<T> _tracked<T>(
    StreamController<T> source,
    void Function() onListen,
    void Function() onCancel,
  ) {
    late StreamController<T> controller;
    StreamSubscription<T>? subscription;
    controller = StreamController<T>(
      onListen: () {
        onListen();
        subscription = source.stream.listen(
          controller.add,
          onError: controller.addError,
        );
      },
      onCancel: () async {
        onCancel();
        await subscription?.cancel();
      },
    );
    return controller.stream;
  }

  /// Emits the person's invitations; from the server by default.
  void emitMine(List<Membership> list, {bool fromCache = false}) =>
      mine.add(MembershipsSnapshot(memberships: list, isFromCache: fromCache));

  Future<void> close() async {
    await mine.close();
    await members.close();
  }
}

/// The Android share sheet, recorded (BR1.3).
class FakeShareLauncher implements ShareLauncher {
  final List<String> texts = [];
  Object? failWith;

  @override
  Future<void> share({required String text, required String subject}) async {
    final error = failWith;
    if (error != null) throw error;
    texts.add(text);
  }
}

/// Everything a sharing screen needs: the sharing streams, the U1 cellar and
/// wines listeners of every cellar id, a network and the share sheet.
class SharingUi {
  SharingUi() {
    when(() => cellars.watchCellar(any())).thenAnswer(
      (invocation) =>
          cellarStream(invocation.positionalArguments.single as String).stream,
    );
    when(() => wines.watchCellarWines(any())).thenAnswer(
      (invocation) =>
          winesStream(invocation.positionalArguments.single as String).stream,
    );
  }

  final sharing = SharingStreams();
  final cellars = MockCellarRepository();
  final wines = MockWineRepository();
  final network = FakeNetwork();
  final share = FakeShareLauncher();
  final Map<String, StreamController<CellarSnapshot>> _cellars = {};
  final Map<String, StreamController<WinesSnapshot>> _wines = {};

  MockSharingRepository get repository => sharing.repository;

  StreamController<CellarSnapshot> cellarStream(String id) =>
      _cellars.putIfAbsent(id, StreamController<CellarSnapshot>.broadcast);

  StreamController<WinesSnapshot> winesStream(String id) =>
      _wines.putIfAbsent(id, StreamController<WinesSnapshot>.broadcast);

  List<Override> get overrides => [
    sharingRepositoryProvider.overrideWithValue(sharing.repository),
    sharingPreferencesProvider.overrideWithValue(SharedPreferences.getInstance),
    cellarRepositoryProvider.overrideWithValue(cellars),
    wineRepositoryProvider.overrideWithValue(wines),
    networkStatusProvider.overrideWithValue(network),
    shareLauncherProvider.overrideWithValue(share),
    // u4-cellar: the HomeShell starts the maintenance; the forms use the
    // catalog.
    ...cellarServiceOverrides(),
  ];

  /// The cellar document of [id] with [memberSlots], from the server.
  void emitCellar(String id, {int memberSlots = 0, String name = 'Cantina'}) =>
      cellarStream(id).add(
        CellarSnapshot(
          cellar: Cellar(
            id: id,
            ownerId: id,
            name: name,
            memberSlots: memberSlots,
          ),
          meta: const SnapshotMeta(hasPendingWrites: false, isFromCache: false),
        ),
      );
}

/// Overrides for screens of U1 and U5 tested without sharing: a sharing
/// service whose invitations never arrive, so the active cellar is the
/// personal one (NFR7.5).
List<Override> noSharingOverrides() => [
  sharingRepositoryProvider.overrideWithValue(SharingStreams().repository),
  sharingPreferencesProvider.overrideWithValue(SharedPreferences.getInstance),
];

/// Registers the fallback values the sharing mocks need.
void registerSharingFallbacks() {
  registerFirestoreFallbacks();
  registerFallbackValue(owner);
  registerFallbackValue(MemberPermission.read);
  registerFallbackValue(const Cellar(id: 'c', ownerId: 'c', name: 'c'));
  registerFallbackValue(<Membership>[]);
}
