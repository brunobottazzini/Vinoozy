import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it'),
    Locale('pt'),
    Locale('pt', 'BR'),
  ];

  /// Application name.
  ///
  /// In en, this message translates to:
  /// **'Vinoozy'**
  String get appTitle;

  /// Tagline under the logo on the sign-in screen (M1).
  ///
  /// In en, this message translates to:
  /// **'Your cellar, at the right time'**
  String get signInTagline;

  /// Only sign-in button (BR1.1).
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get signInWithGoogle;

  /// Accessibility label of the progress indicator inside the sign-in button.
  ///
  /// In en, this message translates to:
  /// **'Signing in'**
  String get signInInProgress;

  /// Shown when Google sign-in is cancelled or fails (BR1.1).
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed'**
  String get signInFailed;

  /// Shown when the phone has no network on first sign-in (BR1.1, NFR2.5).
  ///
  /// In en, this message translates to:
  /// **'You need a connection for the first sign-in'**
  String get signInNeedsNetwork;

  /// Shown on the sign-in screen after the cloud revoked the session (W2).
  ///
  /// In en, this message translates to:
  /// **'Your session has expired: sign in again'**
  String get signInSessionExpired;

  /// Generic retry button.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// Generic cancel button.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Blocked account screen message (BR1.4).
  ///
  /// In en, this message translates to:
  /// **'There are changes by {email} not yet saved to the cloud: sign in with that account and connect to the network'**
  String blockedMessage(String email);

  /// Blocked screen: sign out and go back to sign-in.
  ///
  /// In en, this message translates to:
  /// **'Sign in with {email}'**
  String blockedSignInWith(String email);

  /// Blocked screen: discard the other account's pending changes.
  ///
  /// In en, this message translates to:
  /// **'Delete unsaved changes by {email}'**
  String blockedDiscard(String email);

  /// Title of the discard confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Delete the changes?'**
  String get discardDialogTitle;

  /// Discard confirmation: shows the email and the number of unsaved wines, never their names.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 wine by {email} is not in the cloud yet and will be deleted from this phone.} other{{count} wines by {email} are not in the cloud yet and will be deleted from this phone.}}'**
  String discardDialogBody(int count, String email);

  /// Confirm button of the discard dialog.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get discardConfirm;

  /// Shown when clearing the offline data fails (NFR4.10).
  ///
  /// In en, this message translates to:
  /// **'Could not clear the data on this phone'**
  String get resetFailed;

  /// Plan B of the local reset: the app must be restarted.
  ///
  /// In en, this message translates to:
  /// **'Restart the app to finish'**
  String get restartRequired;

  /// Button that closes the app so it can be reopened.
  ///
  /// In en, this message translates to:
  /// **'Close the app'**
  String get restartCloseApp;

  /// Start-up error screen.
  ///
  /// In en, this message translates to:
  /// **'The app could not start'**
  String get startupFailed;

  /// Cellar screen title.
  ///
  /// In en, this message translates to:
  /// **'Cellar'**
  String get cellarTitle;

  /// Name of the personal cellar created on first sign-in (BR1.3).
  ///
  /// In en, this message translates to:
  /// **'My cellar'**
  String get defaultCellarName;

  /// Accessibility label of the cellar loading indicator.
  ///
  /// In en, this message translates to:
  /// **'Preparing the cellar'**
  String get cellarLoading;

  /// Cellar creation or read failed (BR1.3).
  ///
  /// In en, this message translates to:
  /// **'Could not prepare the cellar'**
  String get cellarSetupFailed;

  /// Empty cellar state.
  ///
  /// In en, this message translates to:
  /// **'Your cellar is empty'**
  String get cellarEmpty;

  /// Button that opens the add-wine form.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addWine;

  /// Placeholder until the drinking-window estimate exists (u2/u4).
  ///
  /// In en, this message translates to:
  /// **'Estimate coming'**
  String get estimatePending;

  /// Wine without vintage; also the switch label in the form.
  ///
  /// In en, this message translates to:
  /// **'No vintage'**
  String get noVintage;

  /// Accessibility label for the quantity of a wine.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 bottle} other{{count} bottles}}'**
  String bottleCount(int count);

  /// Banner: pending changes with network (BR3.2).
  ///
  /// In en, this message translates to:
  /// **'Syncing'**
  String get syncInProgress;

  /// Banner: pending changes without network (BR3.2).
  ///
  /// In en, this message translates to:
  /// **'Offline - sync pending'**
  String get syncOffline;

  /// A write was rejected by the cloud (BR3.1, NFR6.2).
  ///
  /// In en, this message translates to:
  /// **'Change not allowed: {name}'**
  String writeRejected(String name);

  /// Local save failed (BR2.4, NFR6.4).
  ///
  /// In en, this message translates to:
  /// **'Could not save, try again'**
  String get saveFailed;

  /// Notice for a rejected creation found after a restart (NFR6.3).
  ///
  /// In en, this message translates to:
  /// **'The wine {name} was not saved to the cloud'**
  String wineNotSaved(String name);

  /// Reopens the form with the name filled in.
  ///
  /// In en, this message translates to:
  /// **'Add again'**
  String get addAgain;

  /// Dismisses the rejected-wine notice.
  ///
  /// In en, this message translates to:
  /// **'Ignore'**
  String get ignore;

  /// Title of the written add-wine form (M4b).
  ///
  /// In en, this message translates to:
  /// **'Write'**
  String get addWineTitle;

  /// Wine name field label.
  ///
  /// In en, this message translates to:
  /// **'Wine'**
  String get wineNameLabel;

  /// Vintage field label.
  ///
  /// In en, this message translates to:
  /// **'Vintage'**
  String get vintageLabel;

  /// Quantity stepper label.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantityLabel;

  /// Accessibility label of the minus button.
  ///
  /// In en, this message translates to:
  /// **'Decrease quantity'**
  String get decreaseQuantity;

  /// Accessibility label of the plus button.
  ///
  /// In en, this message translates to:
  /// **'Increase quantity'**
  String get increaseQuantity;

  /// Save button of the form.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Name empty or blank (BR2.1).
  ///
  /// In en, this message translates to:
  /// **'Write the name of the wine'**
  String get nameRequired;

  /// Name longer than 120 characters (BR2.1).
  ///
  /// In en, this message translates to:
  /// **'Maximum 120 characters'**
  String get nameTooLong;

  /// Vintage outside 1900..current year (BR2.2).
  ///
  /// In en, this message translates to:
  /// **'Vintage between 1900 and {year}'**
  String vintageRange(String year);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
