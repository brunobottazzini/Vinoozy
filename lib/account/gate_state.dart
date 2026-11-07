import 'app_user.dart';
import 'deletion/deletion_plan.dart';

/// Notice shown on the sign-in screen. [accountDeleted] since u8-account
/// (BR1.7 step 7, BR1.13).
enum SignInNotice { failed, sessionExpired, accountDeleted }

/// States of [AccountGate] (security-design.md §1): Accesso, Bloccato, Reset,
/// AssicuraCantina, Cantina, plus start-up and plan-B restart; since
/// u8-account the deletion states [GateDeleting] and [GateDeleted].
sealed class GateState {
  const GateState();
}

/// Reading the session and the ledger.
class GateStarting extends GateState {
  const GateStarting();
}

/// "Accesso": no session.
class GateSignIn extends GateState {
  const GateSignIn({this.notice, this.busy = false});

  final SignInNotice? notice;

  /// A sign-in is in progress: the button shows a spinner.
  final bool busy;
}

/// "Bloccato": another account owns queued writes on this phone (BR1.4).
class GateBlocked extends GateState {
  const GateBlocked({
    required this.user,
    required this.ownerEmail,
    required this.unsavedCount,
    this.resetFailed = false,
  });

  /// The account that just signed in.
  final AppUser user;

  /// Email of the account whose changes are still queued.
  final String ownerEmail;

  /// Number of that account's unsaved wines (shown, never their names).
  final int unsavedCount;

  /// Clearing the local data failed: "Try again" (NFR4.10).
  final bool resetFailed;
}

/// The ledger could not be read: nothing is opened until it can.
class GateCheckFailed extends GateState {
  const GateCheckFailed(this.user);

  final AppUser user;
}

/// "Reset": local data being cleared.
class GateResetting extends GateState {
  const GateResetting();
}

/// Plan B of the reset: "Restart the app to finish".
class GateRestartRequired extends GateState {
  const GateRestartRequired();
}

/// "AssicuraCantina": the personal cellar is being read or created.
class GateEnsureCellar extends GateState {
  const GateEnsureCellar(this.user);

  final AppUser user;
}

/// "Cantina": the cellar can be shown. [setupFailed] means the cellar could
/// not be prepared: error with "Try again", adding disabled (BR1.3).
class GateCellar extends GateState {
  const GateCellar(this.user, {this.setupFailed = false});

  final AppUser user;
  final bool setupFailed;
}

/// Why a deletion waits for the person (u8-account, functional-spec.md
/// "Errori e casi limite"); every one has "Try again" (NFR6.4).
enum DeletionNotice {
  /// No network: "Connect to the internet to complete the deletion".
  offline,

  /// Step 0: the queued changes could not be saved; the deletion did not
  /// start and can also be cancelled.
  pendingWrites,

  /// The Google sign-in was cancelled or used another account.
  sameAccountRequired,

  /// Any other error: "Could not complete the deletion. Try again".
  failed,
}

/// u8-account BR1.5, BR1.7, BR1.8: the account is being deleted. The app
/// shows only the progress (DeletionProgressView), no other screen.
class GateDeleting extends GateState {
  const GateDeleting({
    required this.user,
    required this.step,
    this.running = false,
    this.needsReauth = false,
    this.notice,
    this.deletedDocuments = 0,
  });

  final AppUser user;

  /// The step running or to repeat.
  final DeletionStep step;

  /// A step is running: no button is enabled.
  final bool running;

  /// A resumed deletion (or step 6 after `requires-recent-login`) asks for
  /// the Google sign-in again before going on (NFR4.6).
  final bool needsReauth;

  final DeletionNotice? notice;

  /// Drinks and wines deleted so far (step 4).
  final int deletedDocuments;

  /// Still at step 0, so nothing was deleted in the cloud: it can be
  /// cancelled (review R-03), whether the wait for the queued changes failed
  /// or a deletion interrupted during step 0 is resumed.
  bool get canCancel => step == DeletionStep.preparePhone && !running;

  GateDeleting copyWith({
    DeletionStep? step,
    bool? running,
    bool? needsReauth,
    DeletionNotice? notice,
    bool clearNotice = false,
    int? deletedDocuments,
  }) => GateDeleting(
    user: user,
    step: step ?? this.step,
    running: running ?? this.running,
    needsReauth: needsReauth ?? this.needsReauth,
    notice: clearNotice ? null : notice ?? this.notice,
    deletedDocuments: deletedDocuments ?? this.deletedDocuments,
  );
}

/// u8-account BR1.7 step 7: the account is deleted; sign-in with
/// "Account deleted".
class GateDeleted extends GateState {
  const GateDeleted();
}
