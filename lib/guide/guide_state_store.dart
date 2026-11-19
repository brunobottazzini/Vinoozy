import '../account/deletion/deletion_signal.dart' show PreferencesOpener;
import '../app/error_reporter.dart';

/// The screens with a first-visit hint (tester-feedback FR2.3).
enum GuideScreen { dashboard, history, addWine }

/// The dates of the automatic review prompt (FR5.2.2, FR5.2.3, FR5.3).
class ReviewDates {
  const ReviewDates({required this.firstUse, this.lastPrompt});

  /// When this phone first recorded the guide state after the update
  /// (requirements, assumption on "first use").
  final DateTime? firstUse;

  /// The last automatic prompt; null when there was none. The "Rate the app"
  /// button never counts (FR5.3).
  final DateTime? lastPrompt;
}

/// The phone state of the guided tour, the first-visit hints and the review
/// prompt (tester-feedback FR2.5, FR5.3), in `shared_preferences` like
/// `onboarding.seen` (OnboardingFlag): never synced, readable offline.
///
/// Keys:
/// - `guide.tour.seen` (bool): the tour was finished or skipped;
/// - `guide.hint.<screen>` (bool) for `dashboard`, `history`, `addWine`;
/// - `guide.firstRun.version` (int): set the first time the guide is
///   evaluated on this phone, so a phone that already had wines is treated
///   as "tour seen" exactly once (review R-02);
/// - `review.firstUse`, `review.lastPrompt` (ISO-8601 dates).
///
/// An unreadable store counts as "seen" (nothing is shown) and as "no
/// automatic prompt"; a refused write returns false. Every failure is
/// reported, never thrown: the guide is never worth blocking the cellar.
class GuideStateStore {
  GuideStateStore(this._open, {this._reporter});

  static const String tourKey = 'guide.tour.seen';
  static const String hintKeyPrefix = 'guide.hint.';
  static const String firstRunKey = 'guide.firstRun.version';
  static const String firstUseKey = 'review.firstUse';
  static const String lastPromptKey = 'review.lastPrompt';

  /// Version of the guide written under [firstRunKey]. A future guide that
  /// must be shown again to everyone raises it.
  static const int guideVersion = 1;

  final PreferencesOpener _open;
  final ErrorReporter? _reporter;

  static String hintKeyOf(GuideScreen screen) => '$hintKeyPrefix${screen.name}';

  /// Whether the tour was finished or skipped on this phone.
  Future<bool> tourSeen() => _readFlag(tourKey);

  /// Whether the hint of [screen] was closed on this phone.
  Future<bool> hintSeen(GuideScreen screen) => _readFlag(hintKeyOf(screen));

  /// Whether the guide was already evaluated once on this phone (R-02). An
  /// unreadable store answers true: nothing is recorded over it.
  Future<bool> firstRunRecorded() async {
    try {
      return (await _open()).getInt(firstRunKey) != null;
    } catch (error, stack) {
      await _report(error, stack, 'GuideStateUnreadable');
      return true;
    }
  }

  Future<bool> markTourSeen() => _writeFlag(tourKey);

  Future<bool> markHintSeen(GuideScreen screen) =>
      _writeFlag(hintKeyOf(screen));

  /// Records the first evaluation of the guide (R-02). A phone whose cellar
  /// already had wines is an existing user: tour and hints count as seen,
  /// and "Show the guide again" can still start them.
  Future<bool> recordFirstRun({required bool hadWines}) async {
    try {
      final preferences = await _open();
      var saved = await preferences.setInt(firstRunKey, guideVersion);
      if (hadWines) {
        saved = await preferences.setBool(tourKey, true) && saved;
        for (final screen in GuideScreen.values) {
          saved = await preferences.setBool(hintKeyOf(screen), true) && saved;
        }
      }
      return saved;
    } catch (error, stack) {
      await _report(error, stack, 'GuideStateNotSaved');
      return false;
    }
  }

  /// "Show the guide again" (FR2.4): clears the tour and the hints only; the
  /// review dates and the first-run marker stay.
  Future<bool> reset() async {
    try {
      final preferences = await _open();
      var removed = await preferences.remove(tourKey);
      for (final screen in GuideScreen.values) {
        removed = await preferences.remove(hintKeyOf(screen)) && removed;
      }
      return removed;
    } catch (error, stack) {
      await _report(error, stack, 'GuideStateNotSaved');
      return false;
    }
  }

  /// The review dates, or null when the store cannot be read (then no
  /// automatic prompt is made).
  Future<ReviewDates?> reviewDates() async {
    try {
      final preferences = await _open();
      return ReviewDates(
        firstUse: _parseDate(preferences.getString(firstUseKey)),
        lastPrompt: _parseDate(preferences.getString(lastPromptKey)),
      );
    } catch (error, stack) {
      await _report(error, stack, 'GuideStateUnreadable');
      return null;
    }
  }

  /// Records [now] as the first use unless one is already stored, and
  /// returns the stored date; idempotent. Null when the store failed.
  Future<DateTime?> ensureFirstUse(DateTime now) async {
    try {
      final preferences = await _open();
      final stored = _parseDate(preferences.getString(firstUseKey));
      if (stored != null) return stored;
      final saved = await preferences.setString(
        firstUseKey,
        now.toIso8601String(),
      );
      return saved ? now : null;
    } catch (error, stack) {
      await _report(error, stack, 'GuideStateNotSaved');
      return null;
    }
  }

  /// Records an automatic review prompt at [now] (FR5.3).
  Future<bool> markPrompted(DateTime now) async {
    try {
      return await (await _open()).setString(
        lastPromptKey,
        now.toIso8601String(),
      );
    } catch (error, stack) {
      await _report(error, stack, 'GuideStateNotSaved');
      return false;
    }
  }

  Future<bool> _readFlag(String key) async {
    try {
      return (await _open()).getBool(key) ?? false;
    } catch (error, stack) {
      await _report(error, stack, 'GuideStateUnreadable');
      return true;
    }
  }

  Future<bool> _writeFlag(String key) async {
    try {
      return await (await _open()).setBool(key, true);
    } catch (error, stack) {
      await _report(error, stack, 'GuideStateNotSaved');
      return false;
    }
  }

  /// A malformed date is treated as missing.
  static DateTime? _parseDate(String? text) =>
      text == null ? null : DateTime.tryParse(text);

  Future<void> _report(Object error, StackTrace stack, String reason) async =>
      _reporter?.report(error, stack, reason: reason);
}
