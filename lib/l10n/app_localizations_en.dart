// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Vinoozy';

  @override
  String get signInTagline => 'Your cellar, at the right time';

  @override
  String get signInWithGoogle => 'Continue with Google';

  @override
  String get signInInProgress => 'Signing in';

  @override
  String get signInFailed => 'Sign-in failed';

  @override
  String get signInNeedsNetwork =>
      'You need a connection for the first sign-in';

  @override
  String get signInSessionExpired => 'Your session has expired: sign in again';

  @override
  String get retry => 'Try again';

  @override
  String get cancel => 'Cancel';

  @override
  String blockedMessage(String email) {
    return 'There are changes by $email not yet saved to the cloud: sign in with that account and connect to the network';
  }

  @override
  String blockedSignInWith(String email) {
    return 'Sign in with $email';
  }

  @override
  String blockedDiscard(String email) {
    return 'Delete unsaved changes by $email';
  }

  @override
  String get discardDialogTitle => 'Delete the changes?';

  @override
  String discardDialogBody(int count, String email) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count wines by $email are not in the cloud yet and will be deleted from this phone.',
      one:
          '1 wine by $email is not in the cloud yet and will be deleted from this phone.',
    );
    return '$_temp0';
  }

  @override
  String get discardConfirm => 'Delete';

  @override
  String get resetFailed => 'Could not clear the data on this phone';

  @override
  String get restartRequired => 'Restart the app to finish';

  @override
  String get restartCloseApp => 'Close the app';

  @override
  String get startupFailed => 'The app could not start';

  @override
  String get cellarTitle => 'Cellar';

  @override
  String get defaultCellarName => 'My cellar';

  @override
  String get cellarLoading => 'Preparing the cellar';

  @override
  String get cellarSetupFailed => 'Could not prepare the cellar';

  @override
  String get cellarEmpty => 'Your cellar is empty';

  @override
  String get addWine => 'Add';

  @override
  String get estimatePending => 'Estimate coming';

  @override
  String get noVintage => 'No vintage';

  @override
  String bottleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bottles',
      one: '1 bottle',
    );
    return '$_temp0';
  }

  @override
  String get syncInProgress => 'Syncing';

  @override
  String get syncOffline => 'Offline - sync pending';

  @override
  String writeRejected(String name) {
    return 'Change not allowed: $name';
  }

  @override
  String get saveFailed => 'Could not save, try again';

  @override
  String wineNotSaved(String name) {
    return 'The wine $name was not saved to the cloud';
  }

  @override
  String get addAgain => 'Add again';

  @override
  String get ignore => 'Ignore';

  @override
  String get addWineTitle => 'Write';

  @override
  String get wineNameLabel => 'Wine';

  @override
  String get vintageLabel => 'Vintage';

  @override
  String get quantityLabel => 'Quantity';

  @override
  String get decreaseQuantity => 'Decrease quantity';

  @override
  String get increaseQuantity => 'Increase quantity';

  @override
  String get save => 'Save';

  @override
  String get nameRequired => 'Write the name of the wine';

  @override
  String get nameTooLong => 'Maximum 120 characters';

  @override
  String vintageRange(String year) {
    return 'Vintage between 1900 and $year';
  }
}
