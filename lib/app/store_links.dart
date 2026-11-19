/// Fixed public addresses of the app (tester-feedback FR4.2, FR6.1).
///
/// One place for the Google Play page and the support address, shared by the
/// cellar invitations (u7-sharing BR1.3), "Share the app", the "Rate the app"
/// fallback and the feedback email, so no copy of them can drift.
library;

/// The app on Google Play (https only, NFR7).
const String playStoreLink =
    'https://play.google.com/store/apps/details?id=com.vinoozy.app';

/// The support address declared in the store listing
/// (distribution/google-play/README.md). The Android side of the feedback
/// email (MainActivity.kt, `SUPPORT_EMAIL`) holds the same value: the
/// recipient never travels from Dart to Android (NFR7).
const String supportEmail = 'bottazzinibruno@gmail.com';
