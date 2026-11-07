// Fakes of u8-account (unit-test-instructions.md, "Mock e stub"): AuthService,
// UserRepository, the Firestore of the deletion, LocalLedger, ResetCoordinator,
// ErrorSink, network and shared_preferences, all injected. Time is never
// waited for real: the 30 s deadline goes through an injected fake.
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:vinoozy/account/app_user.dart';
import 'package:vinoozy/account/auth_service.dart';
import 'package:vinoozy/account/deletion/account_deletion_runner.dart';
import 'package:vinoozy/account/deletion/deletion_backend.dart';
import 'package:vinoozy/account/deletion/deletion_device.dart';
import 'package:vinoozy/account/deletion/deletion_signal.dart';
import 'package:vinoozy/account/network_status.dart';
import 'package:vinoozy/account/reset_coordinator.dart';
import 'package:vinoozy/sharing/domain/membership.dart';

import '../helpers/fakes.dart';

const AppUser mario = AppUser(
  uid: 'uid-mario-0001',
  email: 'mario@example.com',
  displayName: 'Mario Rossi',
);
const AppUser giulia = AppUser(
  uid: 'uid-giulia-0002',
  email: 'giulia@example.com',
  displayName: 'Giulia',
);

/// [AuthService] whose answers the test sets.
class FakeAuthService implements AuthService {
  FakeAuthService({this.currentUser});

  @override
  AppUser? currentUser;

  @override
  String? photoUrl;

  final StreamController<AppUser?> changes =
      StreamController<AppUser?>.broadcast();

  ReauthResult reauthResult = ReauthResult.confirmed;
  int reauthCount = 0;

  /// Errors thrown by the next [deleteUser] calls, in order.
  final List<Object> deleteUserErrors = [];
  int deleteUserCount = 0;
  bool userDeleted = false;

  Object? signOutError;
  int signOutCount = 0;

  @override
  Stream<AppUser?> userChanges() => changes.stream;

  @override
  Future<AppUser> signIn() async {
    final user = currentUser;
    if (user == null) throw const SignInException(SignInFailureKind.cancelled);
    return user;
  }

  @override
  Future<void> signOut() async {
    signOutCount++;
    final error = signOutError;
    if (error != null) throw error;
    currentUser = null;
  }

  @override
  Future<ReauthResult> reauthenticate() async {
    reauthCount++;
    return reauthResult;
  }

  @override
  Future<void> deleteUser() async {
    deleteUserCount++;
    if (deleteUserErrors.isNotEmpty) throw deleteUserErrors.removeAt(0);
    userDeleted = true;
    currentUser = null;
    changes.add(null);
  }
}

/// [NetworkStatus] switched by the test.
class FakeNetworkStatus implements NetworkStatus {
  bool online = true;
  final StreamController<bool> _changes = StreamController<bool>.broadcast();

  @override
  Future<bool> hasNetwork() async => online;

  @override
  Stream<bool> get onChanged => _changes.stream;
}

/// One invitation document of the fake cloud.
class FakeInvitation {
  FakeInvitation(this.cellarId, this.memberKey, this.status);

  final String cellarId;
  final String memberKey;
  MemberStatus status;
}

/// The Firestore of the deletion in memory (unit-test-instructions.md): it
/// records every read and batch, keeps the documents the steps change and
/// can fail any operation, once, to interrupt the run after any step.
class FakeDeletionBackend implements DeletionBackend {
  FakeDeletionBackend({
    this.profileExists = true,
    this.cellarExistsValue = true,
    int drinks = 0,
    int wines = 0,
  }) : drinkCount = drinks,
       wineCount = wines;

  bool profileExists;
  bool startedAt = false;
  bool cellarExistsValue;
  int drinkCount;
  int wineCount;

  /// Invitations [mario] received in other people's cellars.
  final List<FakeInvitation> received = [];

  /// Invitations of [mario]'s own cellar.
  final List<FakeInvitation> given = [];

  /// Every operation in order, e.g. `leave:cellar-anna`.
  final List<String> log = [];

  /// Batches committed (writes), for the cost check (NFR5.1).
  int batches = 0;

  /// Operation names (the part before `:`) that throw the given error once.
  final Map<String, Object> failOnce = {};

  /// Operation names that never complete (lost network).
  final Set<String> hang = {};

  Future<void> _op(String name, [String? detail]) async {
    log.add(detail == null ? name : '$name:$detail');
    if (hang.contains(name)) await Completer<void>().future;
    final failure = failOnce.remove(name);
    if (failure != null) throw failure;
  }

  @override
  Future<void> markStarted(AppUser user) async {
    await _op('markStarted');
    if (!startedAt) batches++;
    profileExists = true;
    startedAt = true;
  }

  @override
  Future<List<DeletionInvitation>> invitationsReceived(AppUser user) async {
    await _op('invitationsReceived');
    return [
      for (final invitation in received)
        DeletionInvitation(
          cellarId: invitation.cellarId,
          memberKey: invitation.memberKey,
          status: invitation.status,
        ),
    ];
  }

  FakeInvitation? _find(List<FakeInvitation> list, String cellarId) {
    for (final invitation in list) {
      if (invitation.cellarId == cellarId) return invitation;
    }
    return null;
  }

  @override
  Future<void> activate(String cellarId, AppUser user) async {
    await _op('activate', cellarId);
    final invitation = _find(received, cellarId)!;
    if (invitation.status != MemberStatus.invited) {
      throw StateError('rules: activate refused');
    }
    batches++;
    invitation.status = MemberStatus.active;
  }

  @override
  Future<void> leave(String cellarId, AppUser user) async {
    await _op('leave', cellarId);
    final invitation = _find(received, cellarId)!;
    if (invitation.status != MemberStatus.active) {
      throw StateError('rules: leave refused');
    }
    batches++;
    invitation.status = MemberStatus.revoked;
  }

  @override
  Future<bool> cellarExists(String uid) async {
    await _op('cellarExists');
    return cellarExistsValue;
  }

  @override
  Future<List<DeletionInvitation>> invitationsGiven(String uid) async {
    await _op('invitationsGiven');
    return [
      for (final invitation in given)
        DeletionInvitation(
          cellarId: invitation.cellarId,
          memberKey: invitation.memberKey,
          status: invitation.status,
        ),
    ];
  }

  @override
  Future<void> revoke(String cellarId, String memberKey) async {
    await _op('revoke', memberKey);
    final invitation = given.firstWhere((i) => i.memberKey == memberKey);
    if (invitation.status == MemberStatus.revoked) {
      throw StateError('rules: revoke refused');
    }
    batches++;
    invitation.status = MemberStatus.revoked;
  }

  @override
  Future<void> deleteInvitation(String cellarId, String memberKey) async {
    await _op('deleteInvitation', '$cellarId/$memberKey');
    for (final list in [received, given]) {
      final index = list.indexWhere(
        (i) => i.cellarId == cellarId && i.memberKey == memberKey,
      );
      if (index < 0) continue;
      if (list[index].status != MemberStatus.revoked) {
        throw StateError('rules: delete of an open invitation refused');
      }
      batches++;
      list.removeAt(index);
    }
  }

  @override
  Future<int> deletePage(String uid, String collection) async {
    await _op('deletePage', collection);
    final drinks = collection == 'drinkingRecords';
    final available = drinks ? drinkCount : wineCount;
    final page = available < 400 ? available : 400;
    if (page == 0) return 0;
    batches++;
    if (drinks) {
      drinkCount -= page;
    } else {
      wineCount -= page;
    }
    return page;
  }

  @override
  Future<void> deleteCellar(String uid) async {
    await _op('deleteCellar');
    if (!cellarExistsValue) return;
    if (!startedAt) throw StateError('rules: cellar delete refused');
    batches++;
    cellarExistsValue = false;
  }

  @override
  Future<void> deleteProfile(String uid) async {
    await _op('deleteProfile');
    if (!profileExists) return;
    if (!startedAt) throw StateError('rules: profile delete refused');
    batches++;
    profileExists = false;
    startedAt = false;
  }

  /// Nothing of the account is left in the cloud.
  bool get isEmpty =>
      !profileExists &&
      !cellarExistsValue &&
      drinkCount == 0 &&
      wineCount == 0 &&
      received.isEmpty &&
      given.isEmpty;
}

/// [DeletionDevice] recording what the runner did on the phone.
class FakeDeletionDevice implements DeletionDevice {
  final List<String> log = [];

  /// The queued writes; completes at once unless the test replaces it.
  Future<void> Function() pendingWrites = () async {};

  ResetOutcome resetOutcome = ResetOutcome.completed;

  @override
  void stopSyncAndListeners() => log.add('stopSync');

  @override
  Future<void> waitForPendingWrites() {
    log.add('waitForPendingWrites');
    return pendingWrites();
  }

  @override
  Future<void> clearLedger(String uid) async => log.add('clearLedger');

  @override
  Future<ResetOutcome> resetPhone(String uid) async {
    log.add('resetPhone');
    return resetOutcome;
  }

  @override
  Future<void> clearLabelFiles() async => log.add('clearLabelFiles');
}

/// A deadline that never waits: it records the limit and fails at once when
/// the work does not complete in the current microtask queue.
class FakeDeadline {
  final List<Duration> limits = [];

  Future<void> call(Future<void> work, Duration limit) async {
    limits.add(limit);
    var done = false;
    Object? error;
    unawaited(work.then((_) => done = true, onError: (Object e) => error = e));
    await Future<void>.delayed(Duration.zero);
    if (error != null) throw error!;
    if (!done) throw TimeoutException('fake deadline', limit);
  }
}

/// Everything a runner test needs.
class DeletionHarness {
  DeletionHarness({FakeDeletionBackend? backend, AppUser user = mario})
    : backend = backend ?? FakeDeletionBackend(),
      auth = FakeAuthService(currentUser: user);

  final FakeDeletionBackend backend;
  final FakeDeletionDevice device = FakeDeletionDevice();
  final FakeAuthService auth;
  final RecordingErrorSink sink = RecordingErrorSink();
  final FakeDeadline deadline = FakeDeadline();

  /// Backed by `SharedPreferences.setMockInitialValues`, set in `setUp`.
  final DeletionSignal signal = DeletionSignal(SharedPreferences.getInstance);

  late final AccountDeletionRunner runner = AccountDeletionRunner(
    backend: backend,
    device: device,
    signal: signal,
    auth: auth,
    reporter: recordingReporter(sink),
    deadline: deadline.call,
  );
}
