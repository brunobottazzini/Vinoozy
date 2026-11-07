/// One step of the account deletion (u8-account BR1.7, with the
/// clarifications of the second review).
///
/// The order is fixed; [index] is the number of functional-spec.md and the
/// value kept by the local signal (`account.deletion.<uid>`).
enum DeletionStep {
  /// Phone only: stop SyncWatcher and the listeners, wait for the queued
  /// Firestore writes (30 s at most), then clear the ledger (BR1.13).
  preparePhone,

  /// `users/{uid}.deletionStartedAt` = now, creating the profile when it is
  /// missing (BR1.7 step 1, BR1.10).
  markStarted,

  /// Other people's cellars: activate and leave every open invitation, then
  /// delete every own `members` document (BR1.9).
  leaveOtherCellars,

  /// Own cellar: revoke every open invitation, then delete every `members`
  /// document.
  closeOwnInvitations,

  /// Drinks and wines of the own cellar, read from the server in pages of
  /// 400 and deleted in confirmed batches of 400.
  deleteWinesAndRecords,

  /// The own cellar document.
  deleteCellar,

  /// `users/{uid}`, then the Firebase Authentication user.
  deleteProfileAndUser,

  /// Phone only: local reset, label files, then the local signal is removed.
  cleanUpPhone;

  /// Steps that only touch the phone: the web page skips them (BR1.11).
  bool get isPhoneOnly =>
      this == DeletionStep.preparePhone || this == DeletionStep.cleanUpPhone;

  /// The step stored as [value], or null for a value that is not a step.
  static DeletionStep? fromIndex(int value) =>
      value >= 0 && value < values.length ? values[value] : null;
}

/// The deletion steps as data (logical-components.md: DeletionPlan), shared
/// by the runner and by the sequence tests.
abstract final class DeletionPlan {
  /// Every step, in execution order.
  static const List<DeletionStep> steps = DeletionStep.values;

  /// Largest page read and largest batch written by step 4 (Firestore allows
  /// 500 writes per batch; 400 leaves room, performance-design.md §2).
  static const int pageSize = 400;

  /// Longest wait for the queued writes in step 0 (NFR1.3).
  static const Duration pendingWritesTimeout = Duration(seconds: 30);

  /// Where a deletion resumes (BR1.8).
  ///
  /// The local signal says which step comes next; with only
  /// `deletionStartedAt` (another phone, or a reinstalled app) the deletion
  /// resumes at step 1, since step 0 is for the phone that started it.
  /// Without either signal there is nothing to resume: a missing profile is
  /// never a signal (NFR6.2).
  static DeletionStep? resumeFrom({
    required int? localStep,
    required bool startedInCloud,
  }) {
    if (localStep != null) {
      return DeletionStep.fromIndex(localStep) ?? DeletionStep.markStarted;
    }
    return startedInCloud ? DeletionStep.markStarted : null;
  }

  /// The steps still to run from [from], included.
  static List<DeletionStep> remaining(DeletionStep from) =>
      steps.sublist(from.index);
}
