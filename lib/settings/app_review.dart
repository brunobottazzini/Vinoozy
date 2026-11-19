import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';

import '../app/external_links.dart';
import '../app/providers.dart' show errorReporterProvider;
import '../app/store_links.dart';

/// "Rate the app" and the automatic prompt (tester-feedback FR5.1, FR5.2,
/// FR5.4). Behind an interface so the tests replace it.
abstract interface class AppReviewLauncher {
  /// The automatic prompt after a positive drink (FR5.2): the Google Play
  /// window when available, otherwise nothing. Never throws.
  Future<void> requestReview();

  /// "Rate the app" (FR5.1): the Google Play window when available,
  /// otherwise the app page on the Play Store in the browser. False when
  /// neither could be opened.
  Future<bool> openRatingPage();
}

/// [AppReviewLauncher] on Google Play In-App Review. The window can always
/// be closed without rating, and the app asks nothing of its own (FR5.4).
class InAppReviewLauncher implements AppReviewLauncher {
  InAppReviewLauncher({
    required this._review,
    required this._openLink,
    this._onError,
  });

  final InAppReview _review;
  final Future<bool> Function(String url) _openLink;
  final PlatformErrorHandler? _onError;

  /// Whether the window is offered; a failing check counts as "not offered".
  Future<bool> _available() async {
    try {
      return await _review.isAvailable();
    } on Object catch (error, stack) {
      _onError?.call(error, stack);
      return false;
    }
  }

  @override
  Future<void> requestReview() async {
    if (!await _available()) return;
    try {
      await _review.requestReview();
    } on Object catch (error, stack) {
      _onError?.call(error, stack);
    }
  }

  @override
  Future<bool> openRatingPage() async {
    if (await _available()) {
      try {
        await _review.requestReview();
        return true;
      } on Object catch (error, stack) {
        // Falls back to the store page below.
        _onError?.call(error, stack);
      }
    }
    // https only, through the restricted links channel (NFR7).
    return _openLink(playStoreLink);
  }
}

final appReviewLauncherProvider = Provider<AppReviewLauncher>(
  (ref) => InAppReviewLauncher(
    review: InAppReview.instance,
    openLink: ref.watch(externalLinkOpenerProvider),
    onError: (error, stack) => reportPlatformError(
      () => ref.read(errorReporterProvider),
      error,
      stack,
      'AppReviewFailed',
    ),
  ),
);
