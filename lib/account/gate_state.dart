import 'app_user.dart';

/// Notice shown on the sign-in screen.
enum SignInNotice { failed, sessionExpired }

/// States of [AccountGate] (security-design.md §1): Accesso, Bloccato, Reset,
/// AssicuraCantina, Cantina, plus start-up and plan-B restart.
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
