import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseException;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../account/app_user.dart';
import '../app/providers.dart';
import '../cellar/domain/cellar.dart';
import '../sync/sync_error_bus.dart';
import 'data/sharing_repository.dart';
import 'domain/membership.dart';
import 'domain/membership_tracker.dart';

/// The sharing service; created at start-up (lib/app/bootstrap.dart) and
/// injected, replaced by a mocktail double in the tests.
final sharingRepositoryProvider = Provider<SharingRepository>(
  (ref) => throw UnimplementedError(
    'sharingRepositoryProvider must be overridden at start-up',
  ),
);

/// Opens `shared_preferences`; tests override it.
final sharingPreferencesProvider =
    Provider<Future<SharedPreferences> Function()>(
      (ref) => SharedPreferences.getInstance,
    );

/// Prefix of the remembered cellar choice, one key per user (BR1.5).
const String activeCellarKeyPrefix = 'sharing.activeCellar.';

/// Key of the cellar chosen by [uid], on this phone only.
String activeCellarKey(String uid) => '$activeCellarKeyPrefix$uid';

/// Removes every remembered cellar choice (u7 NFR6.4): part of the reset
/// and of the sign-out. Never throws; a failure is only logged locally.
Future<void> clearActiveCellarChoices(
  Future<SharedPreferences> Function() open,
) async {
  try {
    final prefs = await open();
    for (final key in prefs.getKeys().toList()) {
      if (key.startsWith(activeCellarKeyPrefix)) await prefs.remove(key);
    }
  } catch (error) {
    // Optional data: the next sign-in starts from the personal cellar
    // anyway when the choice is not accessible (BR1.5).
    debugPrint('Sharing: cellar choice not cleared (${error.runtimeType})');
  }
}

/// Session-wide notices of the sharing (BR1.4): "Mario shared their cellar
/// with you", once per invitation activated on this phone.
class SharingNotices {
  final StreamController<CellarShared> _controller =
      StreamController<CellarShared>.broadcast();

  Stream<CellarShared> get events => _controller.stream;

  void publish(CellarShared event) {
    if (!_controller.isClosed) _controller.add(event);
  }

  Future<void> close() => _controller.close();
}

/// A cellar was shared with the person and is now active (BR1.4).
class CellarShared {
  const CellarShared({required this.cellarId, required this.ownerName});

  final String cellarId;
  final String ownerName;
}

final sharingNoticesProvider = Provider<SharingNotices>((ref) {
  final notices = SharingNotices();
  ref.onDispose(notices.close);
  return notices;
});

/// Cellars the person is leaving right now (security-design.md §4): a
/// listener refused for one of them is the expected end of the exit, never
/// "You no longer have access".
final leavingCellarIdsProvider = Provider<Set<String>>((ref) => <String>{});

/// Last owner name seen per cellar in this session, for the notice of a
/// refused queued write, whose event carries only the cellar id.
final knownCellarOwnersProvider = Provider<Map<String, String>>(
  (ref) => <String, String>{},
);

/// Cellars and kinds of notice already shown in this session (one notice
/// per cellar, BR1.8, NFR6.3).
final shownAccessNoticesProvider = Provider<Set<String>>((ref) => <String>{});

/// Whether there is a network, for the management commands (BR1.11,
/// NFR6.1): the current state, then every change.
final sharingOnlineProvider = StreamProvider.autoDispose<bool>((ref) async* {
  final network = ref.watch(networkStatusProvider);
  yield await network.hasNetwork();
  yield* network.onChanged;
});

/// The person's own invitations, in every state (BR1.4, BR1.14; NFR2.2,
/// NFR5.1: one listener per user).
///
/// - Every `invited` one, once the server confirmed the list, is activated
///   in the background; a successful activation shows "Mario shared their
///   cellar with you" once.
/// - An `active` invitation revoked by the owner, or gone, publishes
///   [CellarAccessLost]; leaving does not.
final myMembershipsProvider = StreamProvider.autoDispose
    .family<List<Membership>, AppUser>((ref, user) {
      final repository = ref.watch(sharingRepositoryProvider);
      final bus = ref.read(syncErrorBusProvider);
      final notices = ref.read(sharingNoticesProvider);
      final leaving = ref.read(leavingCellarIdsProvider);
      final owners = ref.read(knownCellarOwnersProvider);
      final tracker = MembershipTracker();
      final activating = <String>{};

      Future<void> activate(Membership membership) async {
        try {
          await repository.activate(cellarId: membership.cellarId, user: user);
          notices.publish(
            CellarShared(
              cellarId: membership.cellarId,
              ownerName: membership.ownerLabel,
            ),
          );
        } catch (_) {
          // Reported by the repository with a fixed reason; the next
          // confirmed list tries again.
          activating.remove(membership.cellarId);
        }
      }

      return repository.watchMyMemberships(user.email).map((snapshot) {
        final memberships = [
          for (final membership in snapshot.memberships)
            if (membership.ownerId != user.uid) membership,
        ];
        for (final membership in memberships) {
          owners[membership.cellarId] = membership.ownerLabel;
          // A new invitation re-arms the notice of a cellar left before.
          if (membership.status == MemberStatus.invited) {
            leaving.remove(membership.cellarId);
          }
        }
        for (final lost in tracker.update(memberships)) {
          bus.publish(
            CellarAccessLost(
              cellarId: lost.cellarId,
              ownerName: lost.ownerLabel,
            ),
          );
        }
        // An invitation that is no longer `invited` (activated, revoked,
        // left) leaves the in-flight set, so a later re-invitation of the
        // same cellar is activated again (BR1.2, BR1.4).
        activating.removeWhere(
          (cellarId) => !memberships.any(
            (m) => m.cellarId == cellarId && m.status == MemberStatus.invited,
          ),
        );
        if (!snapshot.isFromCache) {
          for (final membership in memberships) {
            if (membership.status == MemberStatus.invited &&
                activating.add(membership.cellarId)) {
              unawaited(activate(membership));
            }
          }
        }
        return memberships;
      });
    });

/// C4 `listAccessibleCellars`: the personal cellar first, then the cellars
/// of `active` invitations by owner name (BR1.5). While the invitations are
/// loading, or when their query fails, only the personal cellar: the
/// sharing never blocks it.
///
/// The list compares by content (actions-release-fix FR7.2): Riverpod
/// notifies the listeners only when the value is `!=` the previous one, and a
/// new List instance always was. When `CellarScreen.build` watched the active
/// cellar, Riverpod flushed this pending dependency first, and its
/// notification marked the Dashboard's CellarSwitcher during the build of
/// another widget ("setState() or markNeedsBuild() called during build",
/// E2E test 8 of CI run 15), even though the cellars had not changed.
final accessibleCellarsProvider = Provider.autoDispose
    .family<List<AccessibleCellar>, AppUser>((ref, user) {
      final memberships = ref.watch(myMembershipsProvider(user)).value;
      return accessibleCellarsOf(user, memberships ?? const []);
    });

/// The pure part of [accessibleCellarsProvider].
List<AccessibleCellar> accessibleCellarsOf(
  AppUser user,
  Iterable<Membership> memberships,
) {
  final personal = AccessibleCellar.personal(
    uid: Cellar.personalCellarId(user.uid),
    ownerName: displayNameOrFallback(user.displayName, user.email),
  );
  final shared = <String, AccessibleCellar>{};
  for (final membership in memberships) {
    if (!membership.grantsAccess) continue;
    if (membership.cellarId == personal.cellarId) continue;
    shared[membership.cellarId] = AccessibleCellar.shared(membership);
  }
  final sorted = shared.values.toList()
    ..sort((a, b) {
      final byName = a.ownerName.toLowerCase().compareTo(
        b.ownerName.toLowerCase(),
      );
      return byName != 0 ? byName : a.cellarId.compareTo(b.cellarId);
    });
  return AccessibleCellarList([personal, ...sorted]);
}

/// The read-only list of [accessibleCellarsProvider], equal to another list
/// with the same cellars in the same order (see there why).
class AccessibleCellarList extends UnmodifiableListView<AccessibleCellar> {
  AccessibleCellarList(super.cellars);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccessibleCellarList &&
          listEquals<AccessibleCellar>(this, other);

  @override
  int get hashCode => Object.hashAll(this);
}

/// C4 `canRead`: whether [cellarId] is among [cellars].
bool canReadCellar(List<AccessibleCellar> cellars, String cellarId) =>
    cellars.any((cellar) => cellar.cellarId == cellarId);

/// C4 `canEdit`: whether [cellarId] is among [cellars] with "can edit".
bool canEditCellar(List<AccessibleCellar> cellars, String cellarId) =>
    cellars.any((cellar) => cellar.cellarId == cellarId && cellar.canEdit);

/// The cellar the screens show (BR1.5, BR1.6; NFR2.4, NFR6.3).
///
/// Starts from the personal cellar, restores the last choice of this user
/// from the phone and goes back to the personal cellar when the choice is
/// no longer accessible. While a shared cellar is active it watches its
/// cellar and wines listeners: a `permission-denied` there is a lost access
/// (one notice, unless the person is leaving it).
final activeCellarProvider = NotifierProvider.autoDispose
    .family<ActiveCellarNotifier, AccessibleCellar, AppUser>(
      ActiveCellarNotifier.new,
    );

/// Since Riverpod 3 a notifier is recreated whenever it rebuilds, so this one
/// never `watch`es: it `listen`s and keeps the choice in its fields until it
/// is disposed or invalidated (reset, "Try again").
class ActiveCellarNotifier extends Notifier<AccessibleCellar> {
  ActiveCellarNotifier(this.user);

  final AppUser user;
  String? _selectedId;
  bool _chosen = false;
  final List<ProviderSubscription<Object?>> _accessListeners = [];
  String? _watchedId;

  String get _personalId => Cellar.personalCellarId(user.uid);

  @override
  AccessibleCellar build() {
    // A build runs only at creation and after an invalidation (reset, "Try
    // again"): start again from the choice saved on the phone.
    _selectedId = null;
    _chosen = false;
    _closeAccessListeners();
    ref.listen(accessibleCellarsProvider(user), (_, _) => _refresh());
    ref.listen(myMembershipsProvider(user), (_, _) => _refresh());
    final subscription = ref
        .read(syncErrorBusProvider)
        .events
        .listen(_onSyncEvent);
    ref.onDispose(() {
      subscription.cancel();
      _closeAccessListeners();
    });
    unawaited(_restore());
    return _resolve();
  }

  /// Shows [cellarId] and remembers it on the phone (BR1.5).
  Future<void> select(String cellarId) async {
    _chosen = true;
    _selectedId = cellarId == _personalId ? null : cellarId;
    _refresh();
    await _remember(_selectedId);
  }

  /// "Leave this cellar" confirmed (BR1.10): no "no longer have access"
  /// notice for it, then back to the personal cellar. A failure leaves the
  /// cellar active and is rethrown for the dialog.
  Future<void> leaveActive() async {
    final cellarId = state.cellarId;
    if (state.isPersonal) return;
    final leaving = ref.read(leavingCellarIdsProvider)..add(cellarId);
    try {
      await ref
          .read(sharingRepositoryProvider)
          .leave(cellarId: cellarId, user: user);
    } catch (_) {
      leaving.remove(cellarId);
      rethrow;
    }
    if (ref.mounted) await select(_personalId);
  }

  AccessibleCellar _resolve() {
    final cellars = ref.read(accessibleCellarsProvider(user));
    final personal = cellars.first;
    final selected = _selectedId;
    AccessibleCellar result = personal;
    if (selected != null) {
      final match = cellars.where((cellar) => cellar.cellarId == selected);
      if (match.isNotEmpty) {
        result = match.first;
      } else {
        _forgetIfGone(selected);
      }
    }
    _watchAccess(result);
    return result;
  }

  void _refresh() {
    final next = _resolve();
    if (next != state) state = next;
  }

  /// The remembered cellar is not in the list once the invitations are
  /// known: it is no longer accessible, so the choice is forgotten (BR1.5).
  /// A revocation found at start-up still gets its notice.
  void _forgetIfGone(String cellarId) {
    final memberships = ref.read(myMembershipsProvider(user));
    if (!memberships.hasValue) return;
    _selectedId = null;
    unawaited(_remember(null));
    final membership = memberships.value!
        .where((membership) => membership.cellarId == cellarId)
        .firstOrNull;
    final left = membership?.closedBy == ClosedBy.invitee;
    final pending = membership?.status == MemberStatus.invited;
    if (left || pending) return;
    if (ref.read(leavingCellarIdsProvider).contains(cellarId)) return;
    ref
        .read(syncErrorBusProvider)
        .publish(
          CellarAccessLost(
            cellarId: cellarId,
            ownerName: membership?.ownerLabel,
          ),
        );
  }

  /// Watches the cellar and wines listeners of a shared active cellar for a
  /// `permission-denied` (security-design.md §4, source 2). The listeners
  /// are the same ones the screens use (one per cellar, NFR5.1).
  void _watchAccess(AccessibleCellar cellar) {
    final id = cellar.isPersonal ? null : cellar.cellarId;
    if (id == _watchedId) return;
    _closeAccessListeners();
    _watchedId = id;
    if (id == null) return;
    void onState(AsyncValue<Object?>? _, AsyncValue<Object?> next) {
      final error = next.error;
      if (error is FirebaseException && error.code == 'permission-denied') {
        _lose(cellar);
      }
    }

    final cellarListener = ref.listen<AsyncValue<Object?>>(
      cellarStreamProvider(id),
      onState,
    );
    final winesListener = ref.listen<AsyncValue<Object?>>(
      winesStreamProvider(id),
      onState,
    );
    _accessListeners
      ..add(cellarListener)
      ..add(winesListener);
  }

  void _closeAccessListeners() {
    for (final listener in _accessListeners) {
      listener.close();
    }
    _accessListeners.clear();
    _watchedId = null;
  }

  void _lose(AccessibleCellar cellar) {
    if (_selectedId != cellar.cellarId) return;
    if (!ref.read(leavingCellarIdsProvider).contains(cellar.cellarId)) {
      ref
          .read(syncErrorBusProvider)
          .publish(
            CellarAccessLost(
              cellarId: cellar.cellarId,
              ownerName: cellar.ownerName,
            ),
          );
    }
    _backToPersonal();
  }

  void _onSyncEvent(SyncEvent event) {
    if (event is CellarAccessLost && event.cellarId == _selectedId) {
      _backToPersonal();
    }
  }

  void _backToPersonal() {
    if (!ref.mounted) return;
    _selectedId = null;
    unawaited(_remember(null));
    // Not during a build of another provider: schedule the change.
    scheduleMicrotask(() {
      if (ref.mounted) _refresh();
    });
  }

  Future<void> _restore() async {
    final open = ref.read(sharingPreferencesProvider);
    try {
      final prefs = await open();
      final stored = prefs.getString(activeCellarKey(user.uid));
      if (stored == null || _chosen || !ref.mounted) return;
      _selectedId = stored == _personalId ? null : stored;
      _refresh();
    } catch (error) {
      // An optional preference: the personal cellar stays (BR1.5). Logged
      // locally only, never sent out (NFR8.2).
      debugPrint('Sharing: cellar choice not read (${error.runtimeType})');
    }
  }

  Future<void> _remember(String? cellarId) async {
    final open = ref.read(sharingPreferencesProvider);
    try {
      final prefs = await open();
      final key = activeCellarKey(user.uid);
      if (cellarId == null) {
        await prefs.remove(key);
      } else {
        await prefs.setString(key, cellarId);
      }
    } catch (error) {
      debugPrint('Sharing: cellar choice not saved (${error.runtimeType})');
    }
  }
}

/// The invitations of [cellarId] for the owner's "People" screen, opened
/// only while the screen is shown (BR1.12, NFR5.1).
final cellarMembersProvider = StreamProvider.autoDispose
    .family<List<Membership>, String>(
      (ref, cellarId) =>
          ref.watch(sharingRepositoryProvider).watchCellarMembers(cellarId),
    );

/// Invalidates every sharing provider that holds a Firestore listener
/// (functional-spec.md, "Integrazione con U1"): used by
/// `reopenCellarListeners` and `invalidateFirestoreListeners`.
void invalidateSharingListeners(ProviderContainer container) {
  container
    ..invalidate(myMembershipsProvider)
    ..invalidate(accessibleCellarsProvider)
    ..invalidate(activeCellarProvider)
    ..invalidate(cellarMembersProvider);
}
