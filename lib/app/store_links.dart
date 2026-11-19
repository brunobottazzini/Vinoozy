/// Fixed public addresses of the app (tester-feedback FR4.2, FR6.1).
///
/// One place for the Google Play page, shared by the cellar invitations
/// (u7-sharing BR1.3), "Share the app" and the "Rate the app" fallback, so no
/// copy of it can drift. The support address is not here: it lives only on
/// the Android side (LinksChannelHandler.kt, `SUPPORT_EMAIL`) and Dart reads
/// it through the links channel (`supportEmailReaderProvider`), so no email
/// address sits in the Dart code (NFR7, tool/check_off_config.sh).
library;

/// The app on Google Play (https only, NFR7).
const String playStoreLink =
    'https://play.google.com/store/apps/details?id=com.vinoozy.app';
