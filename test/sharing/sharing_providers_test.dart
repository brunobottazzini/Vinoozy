// Sharing providers (u7-sharing BR1.4, BR1.5, BR1.8-BR1.10, BR1.14; NFR2.4,
// NFR5.1, NFR6.1, NFR6.3, NFR6.4): activation, accessible cellars, the
// remembered active cellar, lost access with and without notice, the count
// of open listeners and the reset.
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinoozy/app/providers.dart';
import 'package:vinoozy/cellar/data/cellar_repository.dart';
import 'package:vinoozy/cellar/data/wine_repository.dart';
import 'package:vinoozy/cellar/domain/cellar.dart';
import 'package:vinoozy/sharing/domain/membership.dart';
import 'package:vinoozy/sharing/domain/membership_tracker.dart';
import 'package:vinoozy/sharing/domain/sharing_error.dart';
import 'package:vinoozy/sharing/sharing_providers.dart';
import 'package:vinoozy/sync/snapshot_meta.dart';
import 'package:vinoozy/sync/sync_error_bus.dart';

import '../helpers/firestore_mocks.dart';
import '../helpers/service_mocks.dart';
import '../u1/ui/sign_in_screen_test.dart' show FakeNetwork;
import 'sharing_harness.dart';

const _synced = SnapshotMeta(hasPendingWrites: false, isFromCache: false);

/// U1 listeners per cellar id, counting the open ones (NFR5.1).
class CellarStreams {
  CellarStreams() {
    when(() => cellars.watchCellar(any())).thenAnswer(
      (invocation) => _open(
        cellarControllers,
        invocation.positionalArguments.single as String,
        cellarOpen,
      ),
    );
    when(() => wines.watchCellarWines(any())).thenAnswer(
      (invocation) => _open(
        winesControllers,
        invocation.positionalArguments.single as String,
        winesOpen,
      ),
    );
  }

  final cellars = MockCellarRepository();
  final wines = MockWineRepository();
  final Map<String, StreamController<CellarSnapshot>> cellarControllers = {};
  final Map<String, StreamController<WinesSnapshot>> winesControllers = {};
  final Map<String, int> cellarOpen = {};
  final Map<String, int> winesOpen = {};

  Stream<T> _open<T>(
    Map<String, StreamController<T>> controllers,
    String id,
    Map<String, int> open,
  ) {
    final controller = controllers.putIfAbsent(
      id,
      () => StreamController<T>.broadcast(),
    );
    late StreamController<T> out;
    StreamSubscription<T>? subscription;
    out = StreamController<T>(
      onListen: () {
        open[id] = (open[id] ?? 0) + 1;
        subscription = controller.stream.listen(out.add, onError: out.addError);
      },
      onCancel: () async {
        open[id] = (open[id] ?? 1) - 1;
        await subscription?.cancel();
      },
    );
    return out.stream;
  }

  int get openTotal =>
      [...cellarOpen.values, ...winesOpen.values].fold(0, (a, b) => a + b);

  void denyWines(String id) =>
      winesControllers[id]?.addError(firestoreError('permission-denied'));

  void emit(String id) {
    cellarControllers[id]?.add(
      CellarSnapshot(
        cellar: Cellar(id: id, ownerId: id, name: 'Cantina'),
        meta: _synced,
      ),
    );
    winesControllers[id]?.add(const WinesSnapshot(wines: [], meta: _synced));
  }
}

void main() {
  setUpAll(registerSharingFallbacks);

  late SharingStreams sharing;
  late CellarStreams cellars;
  late SyncErrorBus bus;
  late List<SyncEvent> events;
  late ProviderContainer container;

  ProviderContainer newContainer() => ProviderContainer(
    retry: (_, _) => null,
    overrides: [
      sharingRepositoryProvider.overrideWithValue(sharing.repository),
      cellarRepositoryProvider.overrideWithValue(cellars.cellars),
      wineRepositoryProvider.overrideWithValue(cellars.wines),
      syncErrorBusProvider.overrideWithValue(bus),
      sharingPreferencesProvider.overrideWithValue(
        SharedPreferences.getInstance,
      ),
      networkStatusProvider.overrideWithValue(FakeNetwork()),
    ],
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    sharing = SharingStreams();
    cellars = CellarStreams();
    bus = SyncErrorBus();
    events = [];
    bus.events.listen(events.add);
    container = newContainer();
  });

  tearDown(() => container.dispose());

  /// Keeps the active cellar of [user] alive and returns its notifier.
  ActiveCellarNotifier listenActive([dynamic user = invitee]) {
    container.listen(activeCellarProvider(user), (_, _) {});
    return container.read(activeCellarProvider(user).notifier);
  }

  AccessibleCellar active([dynamic user = invitee]) =>
      container.read(activeCellarProvider(user));

  Future<void> settle() async {
    for (var i = 0; i < 5; i++) {
      await pumpEventQueue();
    }
  }

  final sharedByMario = membership();
  final sharedByAnna = membership(
    cellarId: 'user-z',
    ownerId: 'user-z',
    ownerName: 'Anna',
    permission: MemberPermission.read,
  );

  group('BR1.4 activation', () {
    test('BR1.4 an invited invitation confirmed by the server is activated '
        'once, with the notice', () async {
      final notices = <CellarShared>[];
      container.read(sharingNoticesProvider).events.listen(notices.add);
      listenActive();
      await settle();

      sharing.emitMine([membership(status: MemberStatus.invited)]);
      await settle();
      sharing.emitMine([membership(status: MemberStatus.invited)]);
      await settle();

      expect(sharing.activated, ['user-a']);
      expect(notices.single.ownerName, 'Mario');
    });

    test('BR1.4 a list from the cache only activates nothing', () async {
      listenActive();
      await settle();

      sharing.emitMine([
        membership(status: MemberStatus.invited),
      ], fromCache: true);
      await settle();

      expect(sharing.activated, isEmpty);
    });

    test('BR1.4 a failed activation is tried again on the next confirmed '
        'list, with no notice', () async {
      var calls = 0;
      when(
        () => sharing.repository.activate(
          cellarId: any(named: 'cellarId'),
          user: any(named: 'user'),
        ),
      ).thenAnswer((_) async {
        calls++;
        if (calls == 1) {
          throw const SharingException(SharingError.timeout);
        }
      });
      final notices = <CellarShared>[];
      container.read(sharingNoticesProvider).events.listen(notices.add);
      listenActive();
      await settle();

      sharing.emitMine([membership(status: MemberStatus.invited)]);
      await settle();
      expect(notices, isEmpty);
      sharing.emitMine([membership(status: MemberStatus.invited)]);
      await settle();

      expect(calls, 2);
      expect(notices, hasLength(1));
    });

    test('BR1.4 an activation that timed out but reached the server shows '
        'the notice once, when the server confirms it active', () async {
      // actions-release-fix: with a busy server the commit answered after
      // the timeout, the confirmed list was already `active` and the notice
      // was never shown (account deletion E2E, local runs 3 and 5).
      when(
        () => sharing.repository.activate(
          cellarId: any(named: 'cellarId'),
          user: any(named: 'user'),
        ),
      ).thenAnswer((_) async {
        throw const SharingException(SharingError.timeout);
      });
      final notices = <CellarShared>[];
      container.read(sharingNoticesProvider).events.listen(notices.add);
      listenActive();
      await settle();

      sharing.emitMine([membership(status: MemberStatus.invited)]);
      await settle();
      expect(notices, isEmpty);
      // The late commit reaches the server: the list is confirmed active.
      sharing.emitMine([membership(status: MemberStatus.active)]);
      await settle();
      sharing.emitMine([membership(status: MemberStatus.active)]);
      await settle();

      expect(notices.map((notice) => notice.ownerName), ['Mario']);
    });

    test('BR1.4 a timed-out activation whose invitation is then revoked '
        'shows no notice', () async {
      when(
        () => sharing.repository.activate(
          cellarId: any(named: 'cellarId'),
          user: any(named: 'user'),
        ),
      ).thenAnswer((_) async {
        throw const SharingException(SharingError.timeout);
      });
      final notices = <CellarShared>[];
      container.read(sharingNoticesProvider).events.listen(notices.add);
      listenActive();
      await settle();

      sharing.emitMine([membership(status: MemberStatus.invited)]);
      await settle();
      sharing.emitMine([
        membership(status: MemberStatus.revoked, closedBy: ClosedBy.owner),
      ]);
      await settle();
      sharing.emitMine([membership(status: MemberStatus.active)]);
      await settle();

      expect(notices, isEmpty);
    });

    test('BR1.4 BR1.2 a re-invitation after a revoke is activated again '
        'while the app stays open', () async {
      listenActive();
      await settle();

      sharing.emitMine([membership(status: MemberStatus.invited)]);
      await settle();
      sharing.emitMine([membership(status: MemberStatus.active)]);
      await settle();
      sharing.emitMine([
        membership(status: MemberStatus.revoked, closedBy: ClosedBy.owner),
      ]);
      await settle();
      sharing.emitMine([membership(status: MemberStatus.invited)]);
      await settle();

      expect(sharing.activated, ['user-a', 'user-a']);
    });
  });

  group('BR1.5 accessible cellars', () {
    test('BR1.5 personal first, then the active invitations by owner name', () {
      final list = accessibleCellarsOf(invitee, [
        sharedByMario,
        sharedByAnna,
        membership(cellarId: 'user-x', status: MemberStatus.invited),
        membership(cellarId: 'user-y', status: MemberStatus.revoked),
      ]);

      expect(list.map((c) => c.cellarId), ['user-b', 'user-z', 'user-a']);
      expect(list.first.isPersonal, isTrue);
      expect(list.first.ownerName, 'Giulia');
      expect(canReadCellar(list, 'user-z'), isTrue);
      expect(canEditCellar(list, 'user-z'), isFalse);
      expect(canEditCellar(list, 'user-a'), isTrue);
      expect(canReadCellar(list, 'user-x'), isFalse);
    });

    test('an invitation of the own cellar is never a second entry', () {
      final list = accessibleCellarsOf(owner, [membership(cellarId: 'user-a')]);
      expect(list, hasLength(1));
    });

    test('a failed invitation query keeps the personal cellar only', () async {
      listenActive();
      await settle();
      sharing.mine.addError(firestoreError('failed-precondition'));
      await settle();

      expect(container.read(accessibleCellarsProvider(invitee)), hasLength(1));
      expect(active().isPersonal, isTrue);
    });
  });

  group('BR1.5 BR1.6 the active cellar', () {
    test('BR1.5 starts from the personal cellar, the owner can edit', () async {
      listenActive();
      await settle();

      expect(active().cellarId, 'user-b');
      expect(active().canEdit, isTrue);
    });

    test('BR1.5 a choice is shown and remembered per user', () async {
      final notifier = listenActive();
      sharing.emitMine([sharedByMario, sharedByAnna]);
      await settle();

      await notifier.select('user-z');
      await settle();

      expect(active().cellarId, 'user-z');
      expect(active().canEdit, isFalse, reason: 'BR1.6 read only');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('sharing.activeCellar.user-b'), 'user-z');

      await notifier.select('user-b');
      expect(prefs.getString('sharing.activeCellar.user-b'), isNull);
    });

    test('BR1.5 the remembered choice comes back after a restart', () async {
      SharedPreferences.setMockInitialValues({
        'sharing.activeCellar.user-b': 'user-a',
      });
      listenActive();
      await settle();
      expect(active().isPersonal, isTrue, reason: 'invitations not known yet');

      sharing.emitMine([sharedByMario]);
      await settle();

      expect(active().cellarId, 'user-a');
      expect(active().role, CellarRole.edit);
    });

    test('BR1.5 a remembered cellar no longer accessible goes back to the '
        'personal one and is forgotten', () async {
      SharedPreferences.setMockInitialValues({
        'sharing.activeCellar.user-b': 'user-a',
      });
      listenActive();
      await settle();

      sharing.emitMine(const []);
      await settle();

      expect(active().isPersonal, isTrue);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('sharing.activeCellar.user-b'), isNull);
      expect(
        events.whereType<CellarAccessLost>().single.cellarId,
        'user-a',
        reason: 'revoked while the app was closed: one notice',
      );
    });

    test('BR1.9 a permission change updates canEdit at once', () async {
      final notifier = listenActive();
      sharing.emitMine([sharedByMario]);
      await settle();
      await notifier.select('user-a');
      await settle();
      expect(active().canEdit, isTrue);

      sharing.emitMine([membership(permission: MemberPermission.read)]);
      await settle();

      expect(active().cellarId, 'user-a');
      expect(active().canEdit, isFalse);
    });
  });

  group('BR1.8 BR1.10 BR1.14 lost access', () {
    Future<ActiveCellarNotifier> onMariosCellar() async {
      final notifier = listenActive();
      sharing.emitMine([sharedByMario]);
      await settle();
      await notifier.select('user-a');
      await settle();
      return notifier;
    }

    test('BR1.8 a revocation by the owner: one notice and back to the '
        'personal cellar', () async {
      await onMariosCellar();

      sharing.emitMine([
        membership(status: MemberStatus.revoked, closedBy: ClosedBy.owner),
      ]);
      await settle();

      final lost = events.whereType<CellarAccessLost>().single;
      expect(lost.cellarId, 'user-a');
      expect(lost.ownerName, 'Mario');
      expect(active().isPersonal, isTrue);
      expect(container.read(accessibleCellarsProvider(invitee)), hasLength(1));
    });

    test('BR1.14 a deleted invitation counts as a revocation', () async {
      await onMariosCellar();

      sharing.emitMine(const []);
      await settle();

      expect(events.whereType<CellarAccessLost>(), hasLength(1));
      expect(active().isPersonal, isTrue);
    });

    test('BR1.10 leaving: no notice, back to the personal cellar', () async {
      final notifier = await onMariosCellar();
      when(
        () => sharing.repository.leave(
          cellarId: any(named: 'cellarId'),
          user: any(named: 'user'),
        ),
      ).thenAnswer((_) async {});

      await notifier.leaveActive();
      cellars.denyWines('user-a');
      sharing.emitMine([
        membership(status: MemberStatus.revoked, closedBy: ClosedBy.invitee),
      ]);
      await settle();

      verify(() => sharing.repository.leave(cellarId: 'user-a', user: invitee))
          .called(1);
      expect(events.whereType<CellarAccessLost>(), isEmpty);
      expect(active().isPersonal, isTrue);
    });

    test('BR1.10 a failed exit keeps the cellar and rethrows', () async {
      final notifier = await onMariosCellar();
      when(
        () => sharing.repository.leave(
          cellarId: any(named: 'cellarId'),
          user: any(named: 'user'),
        ),
      ).thenThrow(const SharingException(SharingError.offline));

      await expectLater(
        notifier.leaveActive(),
        throwsA(isA<SharingException>()),
      );

      expect(active().cellarId, 'user-a');
      expect(container.read(leavingCellarIdsProvider), isEmpty);
    });

    test('BR1.14 permission-denied on the shared wines listener: notice and '
        'back to the personal cellar', () async {
      await onMariosCellar();
      cellars.emit('user-a');
      await settle();

      cellars.denyWines('user-a');
      await settle();

      final lost = events.whereType<CellarAccessLost>().single;
      expect(lost.cellarId, 'user-a');
      expect(active().isPersonal, isTrue);
    });

    test('BR1.14 permission-denied while leaving shows no notice', () async {
      await onMariosCellar();
      container.read(leavingCellarIdsProvider).add('user-a');

      cellars.denyWines('user-a');
      await settle();

      expect(events.whereType<CellarAccessLost>(), isEmpty);
      expect(active().isPersonal, isTrue);
    });

    test('BR1.14 a refused queued write on the active cellar goes back to '
        'the personal one', () async {
      await onMariosCellar();

      bus.publish(
        const CellarAccessLost(cellarId: 'user-a', fromQueuedWrite: true),
      );
      await settle();

      expect(active().isPersonal, isTrue);
    });

    test(
      'the owner names seen are kept for the notices of refused writes',
      () async {
        await onMariosCellar();
        expect(container.read(knownCellarOwnersProvider)['user-a'], 'Mario');
      },
    );
  });

  group('NFR5.1 open listeners', () {
    test('one invitations listener, and only the active cellar listeners: '
        'switching keeps the count', () async {
      final notifier = listenActive();
      container.listen(winesStreamProvider(active().cellarId), (_, _) {});
      sharing.emitMine([sharedByMario, sharedByAnna]);
      await settle();
      expect(sharing.myOpen, 1);

      await notifier.select('user-a');
      await settle();
      final countOnMario = cellars.openTotal;
      await notifier.select('user-z');
      await settle();

      expect(sharing.myOpen, 1);
      expect(cellars.openTotal, countOnMario);
      expect(cellars.winesOpen['user-a'] ?? 0, 0);
      expect(cellars.cellarOpen['user-a'] ?? 0, 0);
    });

    test(
      '"People" opens one members listener, closed when it is left',
      () async {
        final subscription = container.listen(
          cellarMembersProvider('user-a'),
          (_, _) {},
        );
        await settle();
        expect(sharing.membersOpen, 1);

        subscription.close();
        await settle();

        expect(sharing.membersOpen, 0);
      },
    );
  });

  group('NFR6.4 reset', () {
    test('NFR6.4 the reset closes the invitations listener and forgets the '
        'chosen cellar', () async {
      final notifier = listenActive();
      sharing.emitMine([sharedByMario]);
      await settle();
      await notifier.select('user-a');
      expect(sharing.myOpen, 1);

      // AccountGate order: forget the choice, then the reset invalidates.
      await clearActiveCellarChoices(SharedPreferences.getInstance);
      invalidateFirestoreListeners(container);
      await settle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getKeys().where((k) => k.startsWith('sharing.')), isEmpty);
      expect(active().isPersonal, isTrue);
      await settle();
      expect(
        sharing.myListens,
        greaterThanOrEqualTo(2),
        reason: 'the listener was closed and reopened fresh',
      );
      expect(active().isPersonal, isTrue);
    });

    test('clearing never throws when the preferences fail', () async {
      await clearActiveCellarChoices(() async => throw StateError('down'));
    });

    test(
      'reopenCellarListeners reopens the invitations listener too',
      () async {
        listenActive();
        await settle();
        final before = sharing.myListens;

        reopenCellarListeners(container);
        await settle();

        expect(sharing.myListens, greaterThan(before));
      },
    );
  });

  group('NFR6.1 network for the commands', () {
    test('the current state, then every change', () async {
      final network = FakeNetwork(online: false);
      final local = ProviderContainer(
        overrides: [networkStatusProvider.overrideWithValue(network)],
      );
      addTearDown(local.dispose);
      final values = <bool>[];
      local.listen(sharingOnlineProvider, (_, next) {
        if (next.hasValue) values.add(next.value!);
      });
      await settle();
      network.online = true;
      await settle();

      expect(values, [false, true]);
    });
  });

  group('MembershipTracker', () {
    test('the first list is the baseline', () {
      expect(MembershipTracker().update([membership()]), isEmpty);
    });

    test(
      'BR1.8 active -> revoked by the owner is lost; by the invitee not',
      () {
        final tracker = MembershipTracker()
          ..update([membership(), sharedByAnna]);
        final lost = tracker.update([
          membership(status: MemberStatus.revoked, closedBy: ClosedBy.owner),
          membership(
            cellarId: 'user-z',
            status: MemberStatus.revoked,
            closedBy: ClosedBy.invitee,
          ),
        ]);
        expect(lost.map((m) => m.cellarId), ['user-a']);
      },
    );

    test('an invitation that never gave access is never lost', () {
      final tracker = MembershipTracker()
        ..update([membership(status: MemberStatus.invited)]);
      expect(tracker.update(const []), isEmpty);
    });
  });
}
