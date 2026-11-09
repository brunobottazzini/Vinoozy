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

  /// Attribution shown next to wine suggestions that come from Open Food Facts, and in the about screen, with a link to the ODbL licence (u3-wine-catalog BR5.2).
  ///
  /// In en, this message translates to:
  /// **'Data from Open Food Facts (ODbL)'**
  String get offAttribution;

  /// Title of the Dashboard screen and label of its navigation tab (u5-dashboard FR5.1).
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// Total bottles at the top of the Dashboard (BR1.1).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 bottle in the cellar} other{{count} bottles in the cellar}}'**
  String dashboardTotalBottles(int count);

  /// 0 bottles read only from the phone cache: the first sync is still running (BR1.8, BR1.9).
  ///
  /// In en, this message translates to:
  /// **'Syncing the cellar…'**
  String get dashboardSyncing;

  /// Button of the empty Dashboard that opens the add-wine form (BR1.8).
  ///
  /// In en, this message translates to:
  /// **'Add your first wine'**
  String get dashboardAddFirstWine;

  /// Title of the list of wines in the drink-soon status (BR1.3).
  ///
  /// In en, this message translates to:
  /// **'Drink soon'**
  String get drinkSoonTitle;

  /// Shown when no wine is in the drink-soon status (BR1.3).
  ///
  /// In en, this message translates to:
  /// **'No bottles due soon'**
  String get drinkSoonEmpty;

  /// End year of the drinking window in a drink-soon row (BR1.3).
  ///
  /// In en, this message translates to:
  /// **'by {year}'**
  String drinkSoonUntil(String year);

  /// Opens the cellar filtered on drink soon when there are more than 10 wines (BR1.3).
  ///
  /// In en, this message translates to:
  /// **'See all ({count})'**
  String drinkSoonSeeAll(int count);

  /// Title of the four-bar status chart (BR1.4).
  ///
  /// In en, this message translates to:
  /// **'Bottle status'**
  String get statusChartTitle;

  /// Status waiting: before the drinking window (BR1.4).
  ///
  /// In en, this message translates to:
  /// **'to wait'**
  String get statusWaiting;

  /// Status ready: inside the drinking window (BR1.4).
  ///
  /// In en, this message translates to:
  /// **'ready'**
  String get statusReady;

  /// Status drink soon: near the end of the window (BR1.4).
  ///
  /// In en, this message translates to:
  /// **'drink soon'**
  String get statusDrinkSoon;

  /// Status past window: after the end of the window (BR1.4).
  ///
  /// In en, this message translates to:
  /// **'past the window'**
  String get statusPastWindow;

  /// Bottles without a drinking window, under the status and peak charts (BR1.4, BR1.5).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 bottle to estimate} other{{count} bottles to estimate}}'**
  String toEstimateNote(int count);

  /// Label and value of one bar for the screen reader (BR1.7).
  ///
  /// In en, this message translates to:
  /// **'{label}: {count, plural, =1{1 bottle} other{{count} bottles}}'**
  String chartBarValue(String label, int count);

  /// Text description of a chart for the screen reader: title, then every label-value pair in the order shown (BR1.7).
  ///
  /// In en, this message translates to:
  /// **'{title}: {values}'**
  String chartDescription(String title, String values);

  /// Screen reader hint of a status bar and of See all: they open the Cellar list filtered by that status (u5 BR1.7, u4 BR1.17).
  ///
  /// In en, this message translates to:
  /// **'Open the list'**
  String get openListHint;

  /// Title of the chart of bottles by peak year (BR1.5).
  ///
  /// In en, this message translates to:
  /// **'Peak year'**
  String get peakChartTitle;

  /// Column of the bottles whose peak is before the current year (BR1.5).
  ///
  /// In en, this message translates to:
  /// **'past peak'**
  String get peakPast;

  /// Column of the bottles whose peak is more than 10 years ahead (BR1.5).
  ///
  /// In en, this message translates to:
  /// **'later'**
  String get peakBeyond;

  /// Title of the third chart in type mode (BR1.6).
  ///
  /// In en, this message translates to:
  /// **'Bottles by type'**
  String get breakdownTypeTitle;

  /// Title of the third chart in region mode (BR1.6).
  ///
  /// In en, this message translates to:
  /// **'Bottles by region'**
  String get breakdownRegionTitle;

  /// Selector option: chart by wine type (BR1.6).
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get breakdownType;

  /// Selector option: chart by region (BR1.6).
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get breakdownRegion;

  /// Wine family red (BR1.6).
  ///
  /// In en, this message translates to:
  /// **'red'**
  String get familyRed;

  /// Wine family white (BR1.6).
  ///
  /// In en, this message translates to:
  /// **'white'**
  String get familyWhite;

  /// Wine family rosé (BR1.6).
  ///
  /// In en, this message translates to:
  /// **'rosé'**
  String get familyRose;

  /// Wine family sparkling (BR1.6).
  ///
  /// In en, this message translates to:
  /// **'sparkling'**
  String get familySparkling;

  /// Wine family sweet, fortified included (BR1.6).
  ///
  /// In en, this message translates to:
  /// **'sweet'**
  String get familySweet;

  /// Bar of the wines without type or region (BR1.6).
  ///
  /// In en, this message translates to:
  /// **'not specified'**
  String get breakdownUnspecified;

  /// Bar of the regions after the first eight (BR1.6).
  ///
  /// In en, this message translates to:
  /// **'others'**
  String get breakdownOtherRegions;

  /// Generic button that closes a notice.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// u7-sharing: tooltip of the cellar menu (frontend-components.md).
  ///
  /// In en, this message translates to:
  /// **'Cellar menu'**
  String get cellarMenu;

  /// u7-sharing: the People screen and its menu entry (BR1.12).
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get sharingPeopleTitle;

  /// u7-sharing: title of the invitation form (BR1.2).
  ///
  /// In en, this message translates to:
  /// **'Invite a person'**
  String get sharingInviteTitle;

  /// u7-sharing: email field of the invitation (BR1.2).
  ///
  /// In en, this message translates to:
  /// **'Google email address'**
  String get sharingEmailLabel;

  /// u7-sharing: the read permission (BR1.6).
  ///
  /// In en, this message translates to:
  /// **'Read only'**
  String get sharingPermissionRead;

  /// u7-sharing: explanation of the read permission (BR1.6).
  ///
  /// In en, this message translates to:
  /// **'Sees wines, estimates, dashboard and drinks'**
  String get sharingPermissionReadHint;

  /// u7-sharing: the edit permission (BR1.6).
  ///
  /// In en, this message translates to:
  /// **'Can edit'**
  String get sharingPermissionEdit;

  /// u7-sharing: explanation of the edit permission (BR1.6).
  ///
  /// In en, this message translates to:
  /// **'Also adds and changes wines and records drinks'**
  String get sharingPermissionEditHint;

  /// u7-sharing: role of the owner in the cellar switcher (BR1.5).
  ///
  /// In en, this message translates to:
  /// **'owner'**
  String get sharingRoleOwner;

  /// u7-sharing: invitation button (BR1.2).
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get sharingInviteButton;

  /// u7-sharing: places used of the limit (BR1.2).
  ///
  /// In en, this message translates to:
  /// **'{used}/{max} people'**
  String sharingPlacesUsed(int used, int max);

  /// u7-sharing: invalidEmail (AC8.1.3).
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get sharingInvalidEmail;

  /// u7-sharing: selfInvite (BR1.2).
  ///
  /// In en, this message translates to:
  /// **'You cannot invite yourself'**
  String get sharingSelfInvite;

  /// u7-sharing: alreadyInvited (BR1.2).
  ///
  /// In en, this message translates to:
  /// **'This person is already invited'**
  String get sharingAlreadyInvited;

  /// u7-sharing: limitReached (AC8.1.2).
  ///
  /// In en, this message translates to:
  /// **'You have reached the limit of {max} people'**
  String sharingLimitReached(int max);

  /// u7-sharing: notOwner (BR1.1).
  ///
  /// In en, this message translates to:
  /// **'You cannot change the sharing of this cellar'**
  String get sharingNotOwner;

  /// u7-sharing: notFound (C4).
  ///
  /// In en, this message translates to:
  /// **'This person is no longer in the list'**
  String get sharingNotFound;

  /// u7-sharing: timeout or failure of a management operation (BR1.11).
  ///
  /// In en, this message translates to:
  /// **'Could not complete, try again'**
  String get sharingFailed;

  /// u7-sharing: server error during the invitation.
  ///
  /// In en, this message translates to:
  /// **'Invitation failed. Try again'**
  String get sharingInviteFailed;

  /// u7-sharing: management commands disabled offline (BR1.11).
  ///
  /// In en, this message translates to:
  /// **'You need a connection to manage sharing'**
  String get sharingOfflineHint;

  /// u7-sharing: a person who has not opened the app yet (BR1.12).
  ///
  /// In en, this message translates to:
  /// **'invited'**
  String get sharingStatusInvited;

  /// u7-sharing: a person with access (BR1.12).
  ///
  /// In en, this message translates to:
  /// **'active'**
  String get sharingStatusActive;

  /// u7-sharing: access closed by the owner (BR1.12).
  ///
  /// In en, this message translates to:
  /// **'revoked'**
  String get sharingStatusRevoked;

  /// u7-sharing: access closed by the person (BR1.10).
  ///
  /// In en, this message translates to:
  /// **'left'**
  String get sharingStatusLeft;

  /// u7-sharing: TalkBack label of a member (security-design.md §3).
  ///
  /// In en, this message translates to:
  /// **'{name}, {permission}, {status}'**
  String sharingMemberSemantics(String name, String permission, String status);

  /// u7-sharing: section of revoked and left people (BR1.12).
  ///
  /// In en, this message translates to:
  /// **'Closed access'**
  String get sharingClosedSection;

  /// u7-sharing: empty list of people (BR1.12).
  ///
  /// In en, this message translates to:
  /// **'Nobody else sees this cellar yet'**
  String get sharingNobody;

  /// u7-sharing: permission menu of a member (BR1.9).
  ///
  /// In en, this message translates to:
  /// **'Change permission of {name}'**
  String sharingChangePermission(String name);

  /// u7-sharing: revoke command (BR1.8).
  ///
  /// In en, this message translates to:
  /// **'Revoke'**
  String get sharingRevoke;

  /// u7-sharing: revoke dialog (BR1.8).
  ///
  /// In en, this message translates to:
  /// **'Revoke the access of {name}?'**
  String sharingRevokeTitle(String name);

  /// u7-sharing: confirmation field of the revoke dialog (BR1.8).
  ///
  /// In en, this message translates to:
  /// **'Type {name} to confirm'**
  String sharingRevokeConfirmLabel(String name);

  /// u7-sharing: why Revoke is disabled (security-design.md §3).
  ///
  /// In en, this message translates to:
  /// **'Enabled when the name matches'**
  String get sharingRevokeDisabledHint;

  /// u7-sharing: renew a closed access (BR1.12).
  ///
  /// In en, this message translates to:
  /// **'Invite again'**
  String get sharingReinvite;

  /// u7-sharing: delete a closed access (BR1.12, NFR8.3).
  ///
  /// In en, this message translates to:
  /// **'Delete for good'**
  String get sharingDeleteForGood;

  /// u7-sharing: a shared cellar (BR1.5).
  ///
  /// In en, this message translates to:
  /// **'Cellar of {owner}'**
  String sharingOwnedBy(String owner);

  /// u7-sharing: the personal cellar in the switcher (BR1.5).
  ///
  /// In en, this message translates to:
  /// **'Your cellar'**
  String get sharingYourCellar;

  /// u7-sharing: invitee view of the People screen (BR1.12).
  ///
  /// In en, this message translates to:
  /// **'Your permission: {permission}'**
  String sharingYourPermission(String permission);

  /// u7-sharing: TalkBack label of the cellar switcher (security-design.md §3).
  ///
  /// In en, this message translates to:
  /// **'{cellar}, {permission}. Tap to change cellar'**
  String sharingSwitcherSemantics(String cellar, String permission);

  /// u7-sharing: leave command (BR1.10).
  ///
  /// In en, this message translates to:
  /// **'Leave this cellar'**
  String get sharingLeave;

  /// u7-sharing: leave dialog (BR1.10).
  ///
  /// In en, this message translates to:
  /// **'Leave the cellar of {owner}?'**
  String sharingLeaveTitle(String owner);

  /// u7-sharing: leave dialog (BR1.10).
  ///
  /// In en, this message translates to:
  /// **'You will no longer see it. {owner} can invite you again.'**
  String sharingLeaveBody(String owner);

  /// u7-sharing: confirm the exit (BR1.10).
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get sharingLeaveConfirm;

  /// u7-sharing: first access to a shared cellar (BR1.4).
  ///
  /// In en, this message translates to:
  /// **'{owner} shared their cellar with you'**
  String sharingSharedNotice(String owner);

  /// u7-sharing: access revoked (BR1.8).
  ///
  /// In en, this message translates to:
  /// **'You no longer have access to the cellar of {owner}'**
  String sharingAccessLost(String owner);

  /// u7-sharing: queued writes refused after a revocation (BR1.14).
  ///
  /// In en, this message translates to:
  /// **'Some changes to the cellar of {owner} were not saved because you no longer have access'**
  String sharingWritesLost(String owner);

  /// u7-sharing: owner name when it is not known.
  ///
  /// In en, this message translates to:
  /// **'someone'**
  String get sharingSomeone;

  /// u7-sharing: subject of the invitation message (BR1.3).
  ///
  /// In en, this message translates to:
  /// **'Invitation to Vinoozy'**
  String get sharingShareSubject;

  /// u7-sharing: ready-made invitation message for the Android share sheet (BR1.3).
  ///
  /// In en, this message translates to:
  /// **'{owner} invited you to the cellar \"{cellar}\" on Vinoozy. Install the app from {link} and sign in with the Google account {email}: use exactly this address.'**
  String sharingShareMessage(
    String owner,
    String cellar,
    String link,
    String email,
  );

  /// u4-cellar: search field of the cellar list (BR1.8).
  ///
  /// In en, this message translates to:
  /// **'Search by name or producer'**
  String get cellarSearchHint;

  /// u4-cellar: title of the status filters (BR1.8).
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get cellarFilterStatus;

  /// u4-cellar: title of the type filters (BR1.8).
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get cellarFilterType;

  /// u4-cellar: status of a wine without an estimate (BR1.8, BR1.9).
  ///
  /// In en, this message translates to:
  /// **'To estimate'**
  String get statusToEstimate;

  /// u4-cellar: type filter for wines without a type (BR1.8).
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get filterTypeUnspecified;

  /// u4-cellar: the filters match nothing (BR1.8).
  ///
  /// In en, this message translates to:
  /// **'No wine with these filters'**
  String get cellarNoMatches;

  /// u4-cellar: removes search and filters (BR1.8).
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get cellarClearFilters;

  /// u4-cellar: the finished wines (BR1.7 archive).
  ///
  /// In en, this message translates to:
  /// **'Drunk'**
  String get cellarArchiveTitle;

  /// u4-cellar: empty archive.
  ///
  /// In en, this message translates to:
  /// **'No finished wines yet'**
  String get cellarArchiveEmpty;

  /// u4-cellar: archive read failed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the finished wines'**
  String get cellarArchiveFailed;

  /// u4-cellar: marks one bottle as drunk (BR1.10).
  ///
  /// In en, this message translates to:
  /// **'Drunk'**
  String get wineDrink;

  /// u4-cellar: screen reader label of the quick Drunk action of a row (BR1.10).
  ///
  /// In en, this message translates to:
  /// **'Mark a bottle of {name} as drunk'**
  String wineDrinkTooltip(String name);

  /// u4-cellar: confidence of the estimate, as text (FR4.5, NFR3.1).
  ///
  /// In en, this message translates to:
  /// **'Confidence: {level}'**
  String confidenceLabel(String level);

  /// No description provided for @confidenceHigh.
  ///
  /// In en, this message translates to:
  /// **'high'**
  String get confidenceHigh;

  /// No description provided for @confidenceMedium.
  ///
  /// In en, this message translates to:
  /// **'medium'**
  String get confidenceMedium;

  /// No description provided for @confidenceLow.
  ///
  /// In en, this message translates to:
  /// **'low'**
  String get confidenceLow;

  /// No description provided for @windowStartLabel.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get windowStartLabel;

  /// No description provided for @windowPeakLabel.
  ///
  /// In en, this message translates to:
  /// **'Peak'**
  String get windowPeakLabel;

  /// No description provided for @windowEndLabel.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get windowEndLabel;

  /// u4-cellar: where the estimate comes from (BR1.9).
  ///
  /// In en, this message translates to:
  /// **'Source: {source}'**
  String estimateSourceLabel(String source);

  /// No description provided for @estimateSourceCatalog.
  ///
  /// In en, this message translates to:
  /// **'wine database'**
  String get estimateSourceCatalog;

  /// No description provided for @estimateSourceType.
  ///
  /// In en, this message translates to:
  /// **'estimate for the type'**
  String get estimateSourceType;

  /// No description provided for @estimateSourceCorrected.
  ///
  /// In en, this message translates to:
  /// **'estimate corrected by your drinks'**
  String get estimateSourceCorrected;

  /// u4-cellar: fixed notice under every estimate (BR1.9, FR4).
  ///
  /// In en, this message translates to:
  /// **'Indicative estimate: it also depends on how the bottle was stored'**
  String get estimateDisclaimer;

  /// No description provided for @estimateUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Estimate not available'**
  String get estimateUnavailable;

  /// No description provided for @pairingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Pairings'**
  String get pairingsTitle;

  /// No description provided for @pairingsGeneric.
  ///
  /// In en, this message translates to:
  /// **'generic pairings for the type'**
  String get pairingsGeneric;

  /// No description provided for @pairingBraisedRedMeat.
  ///
  /// In en, this message translates to:
  /// **'Braised red meat'**
  String get pairingBraisedRedMeat;

  /// No description provided for @pairingGrilledRedMeat.
  ///
  /// In en, this message translates to:
  /// **'Grilled red meat'**
  String get pairingGrilledRedMeat;

  /// No description provided for @pairingGame.
  ///
  /// In en, this message translates to:
  /// **'Game'**
  String get pairingGame;

  /// No description provided for @pairingRoastPoultry.
  ///
  /// In en, this message translates to:
  /// **'Roast poultry'**
  String get pairingRoastPoultry;

  /// No description provided for @pairingPoultry.
  ///
  /// In en, this message translates to:
  /// **'Poultry'**
  String get pairingPoultry;

  /// No description provided for @pairingPork.
  ///
  /// In en, this message translates to:
  /// **'Pork'**
  String get pairingPork;

  /// No description provided for @pairingCuredMeats.
  ///
  /// In en, this message translates to:
  /// **'Cured meats'**
  String get pairingCuredMeats;

  /// No description provided for @pairingPastaMeatSauce.
  ///
  /// In en, this message translates to:
  /// **'Pasta with meat sauce'**
  String get pairingPastaMeatSauce;

  /// No description provided for @pairingMushroomsTruffle.
  ///
  /// In en, this message translates to:
  /// **'Mushrooms and truffle'**
  String get pairingMushroomsTruffle;

  /// No description provided for @pairingAgedCheese.
  ///
  /// In en, this message translates to:
  /// **'Aged cheese'**
  String get pairingAgedCheese;

  /// No description provided for @pairingFreshCheese.
  ///
  /// In en, this message translates to:
  /// **'Fresh cheese'**
  String get pairingFreshCheese;

  /// No description provided for @pairingBlueCheese.
  ///
  /// In en, this message translates to:
  /// **'Blue cheese'**
  String get pairingBlueCheese;

  /// No description provided for @pairingFish.
  ///
  /// In en, this message translates to:
  /// **'Fish'**
  String get pairingFish;

  /// No description provided for @pairingSeafood.
  ///
  /// In en, this message translates to:
  /// **'Seafood'**
  String get pairingSeafood;

  /// No description provided for @pairingRawSeafood.
  ///
  /// In en, this message translates to:
  /// **'Raw seafood'**
  String get pairingRawSeafood;

  /// No description provided for @pairingFriedFood.
  ///
  /// In en, this message translates to:
  /// **'Fried food'**
  String get pairingFriedFood;

  /// No description provided for @pairingVegetables.
  ///
  /// In en, this message translates to:
  /// **'Vegetables'**
  String get pairingVegetables;

  /// No description provided for @pairingRisotto.
  ///
  /// In en, this message translates to:
  /// **'Risotto'**
  String get pairingRisotto;

  /// No description provided for @pairingPizza.
  ///
  /// In en, this message translates to:
  /// **'Pizza'**
  String get pairingPizza;

  /// No description provided for @pairingAperitif.
  ///
  /// In en, this message translates to:
  /// **'Aperitif'**
  String get pairingAperitif;

  /// No description provided for @pairingPastries.
  ///
  /// In en, this message translates to:
  /// **'Pastries'**
  String get pairingPastries;

  /// No description provided for @pairingDryBiscuits.
  ///
  /// In en, this message translates to:
  /// **'Dry biscuits'**
  String get pairingDryBiscuits;

  /// No description provided for @pairingChocolate.
  ///
  /// In en, this message translates to:
  /// **'Chocolate'**
  String get pairingChocolate;

  /// No description provided for @pairingDriedFruit.
  ///
  /// In en, this message translates to:
  /// **'Dried fruit'**
  String get pairingDriedFruit;

  /// No description provided for @pairingSpicyDishes.
  ///
  /// In en, this message translates to:
  /// **'Spicy dishes'**
  String get pairingSpicyDishes;

  /// No description provided for @recentDrinksTitle.
  ///
  /// In en, this message translates to:
  /// **'Last drinks'**
  String get recentDrinksTitle;

  /// No description provided for @noDrinksYet.
  ///
  /// In en, this message translates to:
  /// **'No drinks yet'**
  String get noDrinksYet;

  /// No description provided for @wineEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get wineEdit;

  /// No description provided for @wineDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get wineDelete;

  /// No description provided for @wineFinished.
  ///
  /// In en, this message translates to:
  /// **'Finished: no bottles left'**
  String get wineFinished;

  /// No description provided for @wineLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the wine'**
  String get wineLoadFailed;

  /// No description provided for @wineNotFound.
  ///
  /// In en, this message translates to:
  /// **'This wine no longer exists'**
  String get wineNotFound;

  /// u4-cellar: message after Drunk, with Undo and Add rating and notes (BR1.10).
  ///
  /// In en, this message translates to:
  /// **'Marked as drunk: {name}'**
  String drinkDone(String name);

  /// No description provided for @drinkUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get drinkUndo;

  /// No description provided for @drinkAddNotes.
  ///
  /// In en, this message translates to:
  /// **'Add rating and notes'**
  String get drinkAddNotes;

  /// No description provided for @nothingToUndo.
  ///
  /// In en, this message translates to:
  /// **'Nothing left to undo'**
  String get nothingToUndo;

  /// u4-cellar: a queued Undo was refused by the cloud (security-design.md §4).
  ///
  /// In en, this message translates to:
  /// **'Undo failed: the bottle stays marked as drunk'**
  String get cellarUndoRejected;

  /// u4-cellar: a part of a delete was refused twice; the queued purge completes it when the network is back (security-design.md §4, review R-06).
  ///
  /// In en, this message translates to:
  /// **'The deletion is not complete yet: it will finish as soon as possible'**
  String get cellarDeleteFailed;

  /// u4-cellar: the duplicate is already at the 99-bottle cap (BR1.3, review R-05).
  ///
  /// In en, this message translates to:
  /// **'This wine already has 99 bottles: no more can be added.'**
  String get duplicateFull;

  /// No description provided for @recordSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Rating and notes'**
  String get recordSheetTitle;

  /// No description provided for @recordRatingLabel.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get recordRatingLabel;

  /// u4-cellar: screen reader label of a rating star (NFR3.2).
  ///
  /// In en, this message translates to:
  /// **'Rating {n} of 5'**
  String ratingStar(int n);

  /// No description provided for @recordNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get recordNotesLabel;

  /// No description provided for @recordNotesTooLong.
  ///
  /// In en, this message translates to:
  /// **'At most 1000 characters'**
  String get recordNotesTooLong;

  /// u4-cellar: date of the drink, tap to change (BR1.11).
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String recordDateLabel(String date);

  /// No description provided for @recordDateInvalid.
  ///
  /// In en, this message translates to:
  /// **'The date cannot be in the future or before the vintage'**
  String get recordDateInvalid;

  /// No description provided for @recordConditionTitle.
  ///
  /// In en, this message translates to:
  /// **'How was it?'**
  String get recordConditionTitle;

  /// No description provided for @conditionTooYoung.
  ///
  /// In en, this message translates to:
  /// **'Still too young'**
  String get conditionTooYoung;

  /// No description provided for @conditionJustRight.
  ///
  /// In en, this message translates to:
  /// **'Just right'**
  String get conditionJustRight;

  /// No description provided for @conditionPastPeak.
  ///
  /// In en, this message translates to:
  /// **'Past its best'**
  String get conditionPastPeak;

  /// No description provided for @recordNoCondition.
  ///
  /// In en, this message translates to:
  /// **'No answer'**
  String get recordNoCondition;

  /// No description provided for @producerLabel.
  ///
  /// In en, this message translates to:
  /// **'Producer (optional)'**
  String get producerLabel;

  /// No description provided for @producerTooLong.
  ///
  /// In en, this message translates to:
  /// **'At most 120 characters'**
  String get producerTooLong;

  /// u4-cellar: last entry of the producer field (BR1.2).
  ///
  /// In en, this message translates to:
  /// **'Add «{name}» as a new producer'**
  String producerAddNew(String name);

  /// No description provided for @wineTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get wineTypeLabel;

  /// No description provided for @typeRedLight.
  ///
  /// In en, this message translates to:
  /// **'Light red'**
  String get typeRedLight;

  /// No description provided for @typeRedStructured.
  ///
  /// In en, this message translates to:
  /// **'Full-bodied red'**
  String get typeRedStructured;

  /// No description provided for @typeWhite.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get typeWhite;

  /// No description provided for @typeRose.
  ///
  /// In en, this message translates to:
  /// **'Rosé'**
  String get typeRose;

  /// No description provided for @typeSparklingClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic-method sparkling'**
  String get typeSparklingClassic;

  /// No description provided for @typeSparklingTank.
  ///
  /// In en, this message translates to:
  /// **'Tank-method sparkling'**
  String get typeSparklingTank;

  /// No description provided for @typeSweet.
  ///
  /// In en, this message translates to:
  /// **'Sweet'**
  String get typeSweet;

  /// No description provided for @typeFortified.
  ///
  /// In en, this message translates to:
  /// **'Fortified'**
  String get typeFortified;

  /// No description provided for @suggestionFromCellar.
  ///
  /// In en, this message translates to:
  /// **'In your cellar'**
  String get suggestionFromCellar;

  /// No description provided for @suggestionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get suggestionsLabel;

  /// No description provided for @duplicateTitle.
  ///
  /// In en, this message translates to:
  /// **'Already in the cellar'**
  String get duplicateTitle;

  /// u4-cellar: the wine exists, finished wines included (BR1.4).
  ///
  /// In en, this message translates to:
  /// **'{name} is already there with {count, plural, =0{no bottles} =1{1 bottle} other{{count} bottles}}. Add the new bottles to it?'**
  String duplicateBody(String name, int count);

  /// u4-cellar: confirms the bottles of a duplicate (BR1.4, BR1.15).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Add 1 bottle} other{Add {count} bottles}}'**
  String duplicateAdd(int count);

  /// No description provided for @duplicateBanner.
  ///
  /// In en, this message translates to:
  /// **'Possible duplicate'**
  String get duplicateBanner;

  /// No description provided for @duplicateMerge.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get duplicateMerge;

  /// No description provided for @duplicateDeleteHint.
  ///
  /// In en, this message translates to:
  /// **'Delete this entry if it is a duplicate'**
  String get duplicateDeleteHint;

  /// No description provided for @mergeTitle.
  ///
  /// In en, this message translates to:
  /// **'Merge the two entries?'**
  String get mergeTitle;

  /// No description provided for @mergeBody.
  ///
  /// In en, this message translates to:
  /// **'The bottles of this entry move to the older one, then this entry is deleted.'**
  String get mergeBody;

  /// No description provided for @editWineTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit wine'**
  String get editWineTitle;

  /// No description provided for @editDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Another wine with the same name, producer and vintage exists'**
  String get editDuplicate;

  /// u4-cellar: confirmation with the wine name (BR1.14).
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String deleteWineTitle(String name);

  /// No description provided for @deleteWineBody.
  ///
  /// In en, this message translates to:
  /// **'The wine and all its drinks are deleted. This cannot be undone.'**
  String get deleteWineBody;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'Here you will find the bottles you drank'**
  String get historyEmpty;

  /// No description provided for @historyLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the history'**
  String get historyLoadFailed;

  /// u4-cellar: date of a drink in the History (BR1.16).
  ///
  /// In en, this message translates to:
  /// **'Drunk on {date}'**
  String drankOnLabel(String date);

  /// u6-label-recognition: the three ways to add a wine (BR1.1).
  ///
  /// In en, this message translates to:
  /// **'Add a wine'**
  String get addChoiceTitle;

  /// No description provided for @addChoicePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get addChoicePhoto;

  /// No description provided for @addChoiceImport.
  ///
  /// In en, this message translates to:
  /// **'Import a photo'**
  String get addChoiceImport;

  /// No description provided for @addChoiceWrite.
  ///
  /// In en, this message translates to:
  /// **'Write'**
  String get addChoiceWrite;

  /// u6: progress while the label is read and looked up (BR1.13).
  ///
  /// In en, this message translates to:
  /// **'Reading the label…'**
  String get labelReading;

  /// No description provided for @labelRecognized.
  ///
  /// In en, this message translates to:
  /// **'I recognised:'**
  String get labelRecognized;

  /// No description provided for @labelCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get labelCorrect;

  /// No description provided for @labelConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get labelConfirm;

  /// No description provided for @labelUnreadable.
  ///
  /// In en, this message translates to:
  /// **'I can\'t read the label'**
  String get labelUnreadable;

  /// No description provided for @labelWriteByHand.
  ///
  /// In en, this message translates to:
  /// **'Write by hand'**
  String get labelWriteByHand;

  /// u6: notice on top of the form filled from the label (BR1.11).
  ///
  /// In en, this message translates to:
  /// **'I didn\'t find the wine: check the details'**
  String get labelNotFound;

  /// No description provided for @labelCameraDenied.
  ///
  /// In en, this message translates to:
  /// **'To read the label I need access to the camera'**
  String get labelCameraDenied;

  /// No description provided for @labelPhotosDenied.
  ///
  /// In en, this message translates to:
  /// **'To read the label I need access to the photos'**
  String get labelPhotosDenied;

  /// No description provided for @labelOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get labelOpenSettings;

  /// No description provided for @labelCameraUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Camera not available'**
  String get labelCameraUnavailable;

  /// No description provided for @labelBarcodeNotFound.
  ///
  /// In en, this message translates to:
  /// **'I read the barcode but I can\'t find the wine'**
  String get labelBarcodeNotFound;

  /// No description provided for @labelBarcodeFrontHint.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of the front of the label'**
  String get labelBarcodeFrontHint;

  /// No description provided for @labelSharedNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'You can\'t add wines to this cellar'**
  String get labelSharedNotAllowed;

  /// No description provided for @labelSharedFirstOnly.
  ///
  /// In en, this message translates to:
  /// **'I used only the first photo'**
  String get labelSharedFirstOnly;

  /// No description provided for @labelSharedExpired.
  ///
  /// In en, this message translates to:
  /// **'The shared photo could not be read: share it again'**
  String get labelSharedExpired;

  /// No description provided for @labelReplaceTitle.
  ///
  /// In en, this message translates to:
  /// **'You have an unsaved wine. Read the new photo?'**
  String get labelReplaceTitle;

  /// No description provided for @labelReplaceRead.
  ///
  /// In en, this message translates to:
  /// **'Read the new photo'**
  String get labelReplaceRead;

  /// No description provided for @labelReplaceKeep.
  ///
  /// In en, this message translates to:
  /// **'Continue with the open one'**
  String get labelReplaceKeep;

  /// No description provided for @labelWineAdded.
  ///
  /// In en, this message translates to:
  /// **'Wine added to the cellar'**
  String get labelWineAdded;

  /// u8-account: first page of the first-start presentation (BR1.1, mockup S0).
  ///
  /// In en, this message translates to:
  /// **'Your cellar in your pocket'**
  String get onboardingPage1Title;

  /// No description provided for @onboardingPage1Body.
  ///
  /// In en, this message translates to:
  /// **'Add your bottles by writing them or with a photo of the label, also without network.'**
  String get onboardingPage1Body;

  /// No description provided for @onboardingPage2Title.
  ///
  /// In en, this message translates to:
  /// **'At the right time'**
  String get onboardingPage2Title;

  /// No description provided for @onboardingPage2Body.
  ///
  /// In en, this message translates to:
  /// **'Vinoozy estimates when each wine is at its best and tells you which ones to open first.'**
  String get onboardingPage2Body;

  /// No description provided for @onboardingPage3Title.
  ///
  /// In en, this message translates to:
  /// **'Together'**
  String get onboardingPage3Title;

  /// No description provided for @onboardingPage3Body.
  ///
  /// In en, this message translates to:
  /// **'Share your cellar with up to two people and keep the history of every bottle you drink.'**
  String get onboardingPage3Body;

  /// u8-account: skips the presentation and goes to sign-in (BR1.1).
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// u8-account: last page of the presentation, goes to sign-in (BR1.1).
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get onboardingStart;

  /// u8-account: TalkBack label of the page indicator (NFR3.2).
  ///
  /// In en, this message translates to:
  /// **'Page {page} of 3'**
  String onboardingPageOf(int page);

  /// u8-account: profile screen and its menu entry (BR1.2).
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get profilePhoto;

  /// No description provided for @profileSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileSignOut;

  /// No description provided for @profileDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get profileDeleteAccount;

  /// No description provided for @profilePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get profilePrivacy;

  /// No description provided for @profilePrivacyBody.
  ///
  /// In en, this message translates to:
  /// **'You can read the privacy policy at this address:'**
  String get profilePrivacyBody;

  /// No description provided for @profileCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get profileCopyLink;

  /// No description provided for @profileLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get profileLinkCopied;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// u8-account: sign-out confirmation without queued changes (BR1.3).
  ///
  /// In en, this message translates to:
  /// **'Do you want to sign out?'**
  String get signOutConfirmTitle;

  /// u8-account: sign-out warning with N queued writes (BR1.4).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{You have 1 change not saved yet. If you sign out and another account signs in, it will be lost.} other{You have {count} changes not saved yet. If you sign out and another account signs in, they will be lost.}}'**
  String signOutPendingWarning(int count);

  /// No description provided for @signOutStayAndSync.
  ///
  /// In en, this message translates to:
  /// **'Stay and sync'**
  String get signOutStayAndSync;

  /// No description provided for @signOutAnyway.
  ///
  /// In en, this message translates to:
  /// **'Sign out anyway'**
  String get signOutAnyway;

  /// No description provided for @syncAllSaved.
  ///
  /// In en, this message translates to:
  /// **'Everything saved'**
  String get syncAllSaved;

  /// u8-account: after "Stay and sync" some writes are still pending (BR1.4).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 change still to save: check the network} other{{count} changes still to save: check the network}}'**
  String syncStillPending(int count);

  /// No description provided for @signOutFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not sign out. Try again'**
  String get signOutFailed;

  /// u8-account: sign-in notice after the account deletion (BR1.7 step 7).
  ///
  /// In en, this message translates to:
  /// **'Account deleted'**
  String get signInAccountDeleted;

  /// No description provided for @deleteAccountIntro.
  ///
  /// In en, this message translates to:
  /// **'This deletes for good:'**
  String get deleteAccountIntro;

  /// No description provided for @deleteAccountItemCellar.
  ///
  /// In en, this message translates to:
  /// **'Your cellar, with its wines and History'**
  String get deleteAccountItemCellar;

  /// No description provided for @deleteAccountItemShares.
  ///
  /// In en, this message translates to:
  /// **'The shares you gave: the invited people lose access'**
  String get deleteAccountItemShares;

  /// No description provided for @deleteAccountItemMemberships.
  ///
  /// In en, this message translates to:
  /// **'Your participation in other people\'s cellars: your drinks stay there without your name'**
  String get deleteAccountItemMemberships;

  /// No description provided for @deleteAccountItemProfile.
  ///
  /// In en, this message translates to:
  /// **'Your profile'**
  String get deleteAccountItemProfile;

  /// u8-account: queued writes before the deletion (BR1.13, clarifications).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{You have 1 change not saved yet: it will be saved and then deleted with the rest} other{You have {count} changes not saved yet: they will be saved and then deleted with the rest}}'**
  String deleteAccountPending(int count);

  /// u8-account: the word to type to enable the deletion, in the app language (BR1.6).
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get deleteAccountConfirmWord;

  /// u8-account: label of the confirmation field (BR1.6).
  ///
  /// In en, this message translates to:
  /// **'Type {word} to confirm'**
  String deleteAccountTypeWord(String word);

  /// No description provided for @deleteAccountReauthHint.
  ///
  /// In en, this message translates to:
  /// **'Then you will sign in again with Google to confirm it is you.'**
  String get deleteAccountReauthHint;

  /// No description provided for @deleteAccountForever.
  ///
  /// In en, this message translates to:
  /// **'Delete forever'**
  String get deleteAccountForever;

  /// No description provided for @deleteAccountNeedsNetwork.
  ///
  /// In en, this message translates to:
  /// **'Connect to the internet to delete the account'**
  String get deleteAccountNeedsNetwork;

  /// No description provided for @deleteAccountSameAccount.
  ///
  /// In en, this message translates to:
  /// **'The deletion requires signing in with the same account'**
  String get deleteAccountSameAccount;

  /// No description provided for @deletionTitle.
  ///
  /// In en, this message translates to:
  /// **'Deleting the account'**
  String get deletionTitle;

  /// No description provided for @deletionStepPreparePhone.
  ///
  /// In en, this message translates to:
  /// **'Saving the pending changes'**
  String get deletionStepPreparePhone;

  /// No description provided for @deletionStepMarkStarted.
  ///
  /// In en, this message translates to:
  /// **'Starting the deletion'**
  String get deletionStepMarkStarted;

  /// No description provided for @deletionStepLeaveOtherCellars.
  ///
  /// In en, this message translates to:
  /// **'Leaving other people\'s cellars'**
  String get deletionStepLeaveOtherCellars;

  /// No description provided for @deletionStepCloseOwnInvitations.
  ///
  /// In en, this message translates to:
  /// **'Closing your shares'**
  String get deletionStepCloseOwnInvitations;

  /// No description provided for @deletionStepDeleteWinesAndRecords.
  ///
  /// In en, this message translates to:
  /// **'Deleting wines and History'**
  String get deletionStepDeleteWinesAndRecords;

  /// No description provided for @deletionStepDeleteCellar.
  ///
  /// In en, this message translates to:
  /// **'Deleting the cellar'**
  String get deletionStepDeleteCellar;

  /// No description provided for @deletionStepDeleteProfileAndUser.
  ///
  /// In en, this message translates to:
  /// **'Deleting the profile and the account'**
  String get deletionStepDeleteProfileAndUser;

  /// No description provided for @deletionStepCleanUpPhone.
  ///
  /// In en, this message translates to:
  /// **'Cleaning this phone'**
  String get deletionStepCleanUpPhone;

  /// u8-account: TalkBack announcement of the current step (NFR3.2).
  ///
  /// In en, this message translates to:
  /// **'Step {step} of 8: {label}'**
  String deletionStepAnnounce(int step, String label);

  /// u8-account: progress of step 4 (performance-design.md §2).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 wine or drink deleted} other{{count} wines and drinks deleted}}'**
  String deletionDeletedCount(int count);

  /// No description provided for @deletionResumeHint.
  ///
  /// In en, this message translates to:
  /// **'A deletion of this account is not finished. Sign in again with Google to complete it.'**
  String get deletionResumeHint;

  /// No description provided for @deletionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get deletionContinue;

  /// No description provided for @deletionOffline.
  ///
  /// In en, this message translates to:
  /// **'Connect to the internet to complete the deletion'**
  String get deletionOffline;

  /// No description provided for @deletionPendingWrites.
  ///
  /// In en, this message translates to:
  /// **'I can\'t save the pending changes. Try again'**
  String get deletionPendingWrites;

  /// No description provided for @deletionFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not complete the deletion. Try again'**
  String get deletionFailed;

  /// ux-redesign: label of the country grid of the wine form (FR1.1).
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get uxCountryLabel;

  /// ux-redesign: last cell of the country grid, opens every ISO country (FR1.1).
  ///
  /// In en, this message translates to:
  /// **'Other country…'**
  String get uxCountryOther;

  /// ux-redesign: chip that clears the chosen country (country is optional, FR1.2).
  ///
  /// In en, this message translates to:
  /// **'No country'**
  String get uxCountryNone;

  /// ux-redesign: title of the sheet with the 249 ISO countries (FR1.1).
  ///
  /// In en, this message translates to:
  /// **'All countries and territories'**
  String get uxAllCountriesTitle;

  /// ux-redesign: search field of the country sheet, works in it, en and pt-BR.
  ///
  /// In en, this message translates to:
  /// **'Search a country'**
  String get uxAllCountriesSearch;

  /// ux-redesign: section of wine countries outside the grid.
  ///
  /// In en, this message translates to:
  /// **'Rare for wine'**
  String get uxAllCountriesRare;

  /// ux-redesign: section with every country in alphabetical order.
  ///
  /// In en, this message translates to:
  /// **'All, from A to Z'**
  String get uxAllCountriesAll;

  /// ux-redesign: the search found no country.
  ///
  /// In en, this message translates to:
  /// **'No country found'**
  String get uxAllCountriesNone;

  /// ux-redesign: label of the region chips without a country (FR1.2).
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get uxRegionLabel;

  /// ux-redesign: label of the region chips of the chosen country (FR1.2).
  ///
  /// In en, this message translates to:
  /// **'Region · {country}'**
  String uxRegionOf(String country);

  /// ux-redesign: chip that opens the free region field (FR1.2).
  ///
  /// In en, this message translates to:
  /// **'Other region'**
  String get uxRegionOther;

  /// ux-redesign: free region field, 1-120 characters.
  ///
  /// In en, this message translates to:
  /// **'Write the region'**
  String get uxRegionFieldLabel;

  /// ux-redesign: error of the free region field (review R-03).
  ///
  /// In en, this message translates to:
  /// **'At most 120 characters'**
  String get uxRegionTooLong;

  /// ux-redesign: the verb button of a wine card, opens the confirmation (FR2.1).
  ///
  /// In en, this message translates to:
  /// **'I drank one'**
  String get uxDrinkAction;

  /// ux-redesign: screen reader label of the card button (FR2.1).
  ///
  /// In en, this message translates to:
  /// **'I drank a bottle of {name}'**
  String uxDrinkActionTooltip(String name);

  /// ux-redesign: main button of the wine detail (FR2.1).
  ///
  /// In en, this message translates to:
  /// **'I drank a bottle'**
  String get uxDrinkActionDetail;

  /// ux-redesign: screen reader name of the confirmation sheet (FR2.2, A6).
  ///
  /// In en, this message translates to:
  /// **'Confirm the drink'**
  String get uxDrinkSheetLabel;

  /// ux-redesign: label of the bottles before and after (FR2.2).
  ///
  /// In en, this message translates to:
  /// **'Bottles'**
  String get uxDrinkSheetBottles;

  /// ux-redesign: screen reader text of the bottles before and after (FR2.2).
  ///
  /// In en, this message translates to:
  /// **'Bottles: from {before} to {after}'**
  String uxDrinkSheetBottlesChange(int before, int after);

  /// ux-redesign: the optional rating of the confirmation (FR2.2).
  ///
  /// In en, this message translates to:
  /// **'How was it? (optional)'**
  String get uxDrinkSheetRating;

  /// ux-redesign: screen reader label of a rating star (A7).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 star of 5} other{{count} stars of 5}}'**
  String uxDrinkSheetStars(int count);

  /// ux-redesign: the only button that records the drink (FR2.2, FR2.3).
  ///
  /// In en, this message translates to:
  /// **'Yes, I drank it'**
  String get uxDrinkSheetConfirm;

  /// ux-redesign: secondary button of the detail, asks for confirmation (FR2.4).
  ///
  /// In en, this message translates to:
  /// **'Remove a bottle without a drink'**
  String get uxRemoveBottle;

  /// ux-redesign: title of the confirmation of FR2.4.
  ///
  /// In en, this message translates to:
  /// **'Remove a bottle?'**
  String get uxRemoveBottleTitle;

  /// ux-redesign: text of the confirmation of FR2.4.
  ///
  /// In en, this message translates to:
  /// **'One bottle of {name} is removed without recording a drink.'**
  String uxRemoveBottleBody(String name);

  /// ux-redesign: confirm button of FR2.4.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get uxRemoveBottleConfirm;

  /// ux-redesign: title of the drinking window card of the detail.
  ///
  /// In en, this message translates to:
  /// **'Ideal moment'**
  String get uxIdealTitle;

  /// ux-redesign: plain sentence with the end of the effective window.
  ///
  /// In en, this message translates to:
  /// **'Recommended until {year}'**
  String uxIdealUntil(String year);

  /// ux-redesign: the window is over.
  ///
  /// In en, this message translates to:
  /// **'Recommended until {year}: it has passed'**
  String uxIdealUntilPast(String year);

  /// ux-redesign: start and end of the window.
  ///
  /// In en, this message translates to:
  /// **'At its best from {start} to {end}'**
  String uxIdealBest(String start, String end);

  /// ux-redesign: screen reader label of the window bar.
  ///
  /// In en, this message translates to:
  /// **'Drinking window from {start} to {end}'**
  String uxIdealBar(String start, String end);

  /// ux-redesign: notice always shown under the window, read as a note.
  ///
  /// In en, this message translates to:
  /// **'⚠︎ Indicative: an estimate based on type, denomination and vintage. Storage and the single bottle can change it.'**
  String get uxIdealDisclaimer;

  /// ux-redesign: how to get an estimate when there is none.
  ///
  /// In en, this message translates to:
  /// **'Add the vintage and the type to get an estimate.'**
  String get uxIdealUnavailableHint;

  /// ux-redesign: bottles ready or to drink soon, under the total (FR3.3).
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 to drink now} other{{count} to drink now}}'**
  String uxDashboardDrinkNow(int count);

  /// ux-redesign: graphic family of redLight and redStructured (FR3.2).
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get uxFamilyRed;

  /// ux-redesign: graphic family of white.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get uxFamilyWhite;

  /// ux-redesign: graphic family of rose.
  ///
  /// In en, this message translates to:
  /// **'Rosé'**
  String get uxFamilyRose;

  /// ux-redesign: graphic family of sparklingClassic and sparklingTank.
  ///
  /// In en, this message translates to:
  /// **'Sparkling'**
  String get uxFamilySparkling;

  /// ux-redesign: graphic family of sweet and fortified.
  ///
  /// In en, this message translates to:
  /// **'Sweet'**
  String get uxFamilySweet;

  /// label-recognition FR1.1: title of the back photo prompt.
  ///
  /// In en, this message translates to:
  /// **'Now the back'**
  String get labelBackTitle;

  /// label-recognition FR1.1: why the back helps.
  ///
  /// In en, this message translates to:
  /// **'The back usually has the barcode, the producer and the vintage: they help find the wine.'**
  String get labelBackHint;

  /// label-recognition FR1.1: camera for the back.
  ///
  /// In en, this message translates to:
  /// **'Take the back'**
  String get labelBackTake;

  /// label-recognition FR1.1: gallery for the back.
  ///
  /// In en, this message translates to:
  /// **'Choose from the gallery'**
  String get labelBackGallery;

  /// label-recognition FR1.1: go on with the front only.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get labelBackSkip;

  /// label-recognition F1: reading step.
  ///
  /// In en, this message translates to:
  /// **'Front'**
  String get labelStepFront;

  /// label-recognition F1: reading step.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get labelStepBack;

  /// label-recognition F1: reading step.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get labelStepBarcode;

  /// label-recognition F1: reading step, the offline database.
  ///
  /// In en, this message translates to:
  /// **'Wine database on the phone'**
  String get labelStepDatabase;

  /// label-recognition F1: status of a step.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get labelStepPending;

  /// label-recognition F1: status of a step.
  ///
  /// In en, this message translates to:
  /// **'Working…'**
  String get labelStepRunning;

  /// label-recognition F1: status of a step.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get labelStepDone;

  /// label-recognition F1: status of a step.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get labelStepSkipped;

  /// label-recognition F1: status of a step.
  ///
  /// In en, this message translates to:
  /// **'Not readable'**
  String get labelStepFailed;

  /// label-recognition L3: one step as read by the screen reader.
  ///
  /// In en, this message translates to:
  /// **'{step}: {status}'**
  String labelStepStatus(String step, String status);

  /// label-recognition NFR3.1: under the reading steps.
  ///
  /// In en, this message translates to:
  /// **'Everything happens on the phone: the photos are not sent to anyone.'**
  String get labelOnPhoneNote;

  /// label-recognition BR1.5: the back could not be read, the front was used.
  ///
  /// In en, this message translates to:
  /// **'Back not readable'**
  String get labelBackUnreadable;

  /// label-recognition: origin of a sure proposal.
  ///
  /// In en, this message translates to:
  /// **'From the database on the phone · offline'**
  String get labelSourceOffline;

  /// label-recognition: origin of a sure proposal.
  ///
  /// In en, this message translates to:
  /// **'From the catalog'**
  String get labelSourceCatalog;

  /// label-recognition: origin of a sure proposal.
  ///
  /// In en, this message translates to:
  /// **'From Open Food Facts · online'**
  String get labelSourceOnline;

  /// label-recognition BR3.5: the proposal is wrong.
  ///
  /// In en, this message translates to:
  /// **'Not this one'**
  String get labelNotThis;

  /// label-recognition BR6.2: attribution wherever offline or Open Food Facts data appear.
  ///
  /// In en, this message translates to:
  /// **'Data from Open Food Facts, ODbL licence'**
  String get labelOffAttribution;

  /// label-recognition FR3.2: title of the candidate list.
  ///
  /// In en, this message translates to:
  /// **'Which of these?'**
  String get labelCandidatesTitle;

  /// label-recognition FR3.2: under the candidate list title.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 similar wine} other{{count} similar wines}}'**
  String labelCandidatesCount(int count);

  /// label-recognition F2: no candidate is the wine.
  ///
  /// In en, this message translates to:
  /// **'None of these'**
  String get labelCandidatesNone;

  /// label-recognition L4: chip of a candidate from the phone database.
  ///
  /// In en, this message translates to:
  /// **'offline'**
  String get labelChipOffline;

  /// label-recognition L4: chip of a candidate from Open Food Facts.
  ///
  /// In en, this message translates to:
  /// **'online'**
  String get labelChipOnline;

  /// label-recognition L4: chip of a denomination of the internal catalog.
  ///
  /// In en, this message translates to:
  /// **'catalog'**
  String get labelChipCatalog;

  /// label-recognition FR3.2: a candidate without producer.
  ///
  /// In en, this message translates to:
  /// **'producer not given'**
  String get labelNoProducer;

  /// label-recognition BR3.4: text read, no candidate.
  ///
  /// In en, this message translates to:
  /// **'I read the label but I don\'t recognise the wine'**
  String get labelNoMatch;

  /// label-recognition: the text read, on the not-found outcome.
  ///
  /// In en, this message translates to:
  /// **'Text read'**
  String get labelReadText;

  /// label-recognition FR3.1: button of the not-found outcomes.
  ///
  /// In en, this message translates to:
  /// **'Search online'**
  String get labelSearchOnline;

  /// label-recognition FR4.1: last button of the not-found outcomes.
  ///
  /// In en, this message translates to:
  /// **'Open in Google Lens'**
  String get labelOpenLens;

  /// label-recognition FR4.1: under the Lens button.
  ///
  /// In en, this message translates to:
  /// **'Google Lens is the last resort: the photo goes to the Google app only if you confirm.'**
  String get labelLensLastResort;

  /// label-recognition FR4.2: title of the confirmation.
  ///
  /// In en, this message translates to:
  /// **'Open in Google Lens?'**
  String get labelLensTitle;

  /// label-recognition FR4.2, NFR3.2: what leaves the phone.
  ///
  /// In en, this message translates to:
  /// **'The photo of the front will go to the Google app on your phone, or to the app you choose, which may keep a copy under its own rules. Vinoozy does not receive the results: come back here to choose or write the wine.'**
  String get labelLensBody;

  /// label-recognition FR4.2: confirmation button.
  ///
  /// In en, this message translates to:
  /// **'Open Google Lens'**
  String get labelLensConfirm;

  /// label-recognition NFR4.10: neither the Google app nor the share menu opened.
  ///
  /// In en, this message translates to:
  /// **'I can\'t open Google Lens or the share menu'**
  String get labelLensFailed;

  /// label-recognition FR3.2: title of the search screen.
  ///
  /// In en, this message translates to:
  /// **'Search online'**
  String get onlineSearchTitle;

  /// label-recognition FR3.2: under the title.
  ///
  /// In en, this message translates to:
  /// **'Open Food Facts · wines only'**
  String get onlineSearchSubtitle;

  /// label-recognition L7: label of the search field.
  ///
  /// In en, this message translates to:
  /// **'Words to search'**
  String get onlineSearchField;

  /// label-recognition L7: helper of the search field.
  ///
  /// In en, this message translates to:
  /// **'You can change the words before searching.'**
  String get onlineSearchHint;

  /// label-recognition BR4.2: the field is empty.
  ///
  /// In en, this message translates to:
  /// **'Write at least one word'**
  String get onlineSearchEmptyField;

  /// label-recognition BR4.2: start the search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get onlineSearchButton;

  /// label-recognition: loading state.
  ///
  /// In en, this message translates to:
  /// **'Searching…'**
  String get onlineSearchLoading;

  /// label-recognition FR3.2: number of results.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 result} other{{count} results}}'**
  String onlineSearchResults(int count);

  /// label-recognition: no result.
  ///
  /// In en, this message translates to:
  /// **'No wine found: try other words or \"Write by hand\".'**
  String get onlineSearchEmpty;

  /// label-recognition FR3.4: no network.
  ///
  /// In en, this message translates to:
  /// **'No network: I only search the database on the phone.'**
  String get onlineSearchOffline;

  /// label-recognition FR3.4, BR4.3: Open Food Facts over its limits, suspended or failing.
  ///
  /// In en, this message translates to:
  /// **'Online search is not available now, try again in a few minutes.'**
  String get onlineSearchRateLimited;

  /// label-recognition BR4.3 (review R-03): Open Food Facts is off in this build; trying again does not help.
  ///
  /// In en, this message translates to:
  /// **'Online search is not active in this version of the app: I only search the database on the phone.'**
  String get onlineSearchUnavailable;

  /// label-recognition BR6.3: title of the About screen and its cellar menu item.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// label-recognition BR6.3: app version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String aboutVersion(String version);

  /// label-recognition BR6.3: section of the offline database.
  ///
  /// In en, this message translates to:
  /// **'Wine database'**
  String get aboutDbTitle;

  /// label-recognition NFR6.7: wines loaded.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 wine} other{{count} wines}}'**
  String aboutDbCount(int count);

  /// label-recognition FR2.2: date of the export used.
  ///
  /// In en, this message translates to:
  /// **'Open Food Facts export of {date}'**
  String aboutDbDate(String date);

  /// label-recognition BR6.3 (review R-02): the database is the hand-written sample, shown in place of the export date.
  ///
  /// In en, this message translates to:
  /// **'Sample database: a few hand-written test wines, not Open Food Facts data.'**
  String get aboutDbSample;

  /// label-recognition: the database is being opened.
  ///
  /// In en, this message translates to:
  /// **'Opening the wine database…'**
  String get aboutDbLoading;

  /// label-recognition NFR4.5: the database could not be opened.
  ///
  /// In en, this message translates to:
  /// **'The wine database is not available in this version'**
  String get aboutDbUnavailable;

  /// label-recognition TS5: where the ODbL database can be found.
  ///
  /// In en, this message translates to:
  /// **'The derived database and the tool that builds it are in the public repository: {url}'**
  String aboutDbSource(String url);

  /// label-recognition BR6.3: section title.
  ///
  /// In en, this message translates to:
  /// **'Licences'**
  String get aboutLicenseTitle;

  /// label-recognition TS5: attribution of the About screen.
  ///
  /// In en, this message translates to:
  /// **'Contains information from Open Food Facts, made available under the Open Database License (ODbL). Individual contents are under the Database Contents License (DbCL).'**
  String get aboutLicense;

  /// label-recognition BR6.3: section title.
  ///
  /// In en, this message translates to:
  /// **'Label photos'**
  String get aboutPrivacyTitle;

  /// label-recognition BR6.3, NFR3.1: photo privacy note.
  ///
  /// In en, this message translates to:
  /// **'Label photos are read on the phone and deleted when you leave the outcome. They leave the phone only if you tap \"Open in Google Lens\" and confirm.'**
  String get aboutPrivacy;

  /// label-autofill-windows NFR5.7: section title.
  ///
  /// In en, this message translates to:
  /// **'Appellations'**
  String get aboutAppellationsTitle;

  /// label-autofill-windows NFR5.7, TS3: source of the appellation table.
  ///
  /// In en, this message translates to:
  /// **'Appellations: eAmbrosia register (EU) and official national registers.'**
  String get aboutAppellationsSource;

  /// label-autofill-windows BR6.3: the generated table is still the sample.
  ///
  /// In en, this message translates to:
  /// **'Sample table: a hand-written extract of the registers, until the real registers are downloaded.'**
  String get aboutAppellationsSample;

  /// label-autofill-windows: the appellation field of the add and edit forms.
  ///
  /// In en, this message translates to:
  /// **'Appellation'**
  String get denominationLabel;

  /// label-autofill-windows: appellation over 120 characters.
  ///
  /// In en, this message translates to:
  /// **'At most 120 characters'**
  String get denominationTooLong;

  /// label-autofill-windows FR1.2: notice above a form filled from the label photo.
  ///
  /// In en, this message translates to:
  /// **'Filled from the label: check and save'**
  String get autofillFilledNotice;

  /// label-autofill-windows FR2.1, FR2.2: notice above a form filled from a pasted or shared text.
  ///
  /// In en, this message translates to:
  /// **'Filled from the text: check and save'**
  String get autofillPastedNotice;

  /// label-autofill-windows FR1.3: mark under a field filled from the text.
  ///
  /// In en, this message translates to:
  /// **'✦ from the text'**
  String get autofillFromText;

  /// label-autofill-windows A1: what the screen reader says of a field filled from the text.
  ///
  /// In en, this message translates to:
  /// **'filled from the label'**
  String get autofillFromTextSemantics;

  /// label-autofill-windows FR1.4: empties the descriptive fields.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get autofillClear;

  /// label-autofill-windows: opens the Lens confirmation with the front photo.
  ///
  /// In en, this message translates to:
  /// **'Lens'**
  String get autofillLens;

  /// label-autofill-windows FR1.4, BR2.7: confirmation title.
  ///
  /// In en, this message translates to:
  /// **'Clear the form?'**
  String get autofillClearTitle;

  /// label-autofill-windows FR1.4: confirmation text.
  ///
  /// In en, this message translates to:
  /// **'You also wrote in some fields. \"Clear\" empties name, producer, appellation, vintage, type, country, region and level. The quantity stays.'**
  String get autofillClearBody;

  /// label-autofill-windows FR1.4: confirms the clearing.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get autofillClearConfirm;

  /// label-autofill-windows A11: announced after clearing.
  ///
  /// In en, this message translates to:
  /// **'Form cleared'**
  String get autofillCleared;

  /// label-autofill-windows FR2.2: title of the paste card.
  ///
  /// In en, this message translates to:
  /// **'Do you have the text from Google Lens?'**
  String get autofillPasteTitle;

  /// label-autofill-windows FR2.2: hint of the paste card.
  ///
  /// In en, this message translates to:
  /// **'In Lens select the text of the label and tap \"Copy\", then come back here.'**
  String get autofillPasteHint;

  /// label-autofill-windows FR2.2: reads the clipboard once.
  ///
  /// In en, this message translates to:
  /// **'Paste from Lens'**
  String get autofillPaste;

  /// label-autofill-windows FR2.6: opens Google Lens.
  ///
  /// In en, this message translates to:
  /// **'From Google Lens'**
  String get autofillOpenLens;

  /// label-autofill-windows A14: the button opens another app.
  ///
  /// In en, this message translates to:
  /// **'opens Google Lens'**
  String get autofillOpenLensSemantics;

  /// label-autofill-windows FR2.2: the clipboard has no text.
  ///
  /// In en, this message translates to:
  /// **'There is no text on the clipboard'**
  String get autofillClipboardEmpty;

  /// label-autofill-windows BR2.2: the text fills no empty field.
  ///
  /// In en, this message translates to:
  /// **'I found no data to add in the text'**
  String get autofillNoNewFields;

  /// label-autofill-windows FR2.7: announced after the automatic paste.
  ///
  /// In en, this message translates to:
  /// **'Form filled from the Lens text'**
  String get autofillFromLens;

  /// label-autofill-windows BR2.4: an empty shared text.
  ///
  /// In en, this message translates to:
  /// **'No text received'**
  String get autofillShareEmpty;

  /// label-autofill-windows BR2.4: a text shared while the form holds changes.
  ///
  /// In en, this message translates to:
  /// **'Use the text for the empty fields?'**
  String get autofillShareUseTitle;

  /// label-autofill-windows BR2.4: fills the empty fields.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get autofillShareUse;

  /// label-autofill-windows BR2.4: drops the shared text.
  ///
  /// In en, this message translates to:
  /// **'Ignore'**
  String get autofillShareIgnore;

  /// label-autofill-windows FR2.6: choice of the Add screen.
  ///
  /// In en, this message translates to:
  /// **'From Google Lens'**
  String get addChoiceLens;

  /// label-autofill-windows: explanation of "Take a photo".
  ///
  /// In en, this message translates to:
  /// **'Front and back: Vinoozy reads the label.'**
  String get addChoicePhotoHint;

  /// label-autofill-windows FR2.6: explanation of "From Google Lens".
  ///
  /// In en, this message translates to:
  /// **'Opens Lens: frame, select the text and tap Share → Vinoozy.'**
  String get addChoiceLensHint;

  /// label-autofill-windows: explanation of "Import a photo".
  ///
  /// In en, this message translates to:
  /// **'A photo of the label you already took.'**
  String get addChoiceImportHint;

  /// label-autofill-windows: explanation of "Write".
  ///
  /// In en, this message translates to:
  /// **'Empty form, with \"Paste from Lens\".'**
  String get addChoiceWriteHint;

  /// label-autofill-windows BR2.5: neither Lens nor the Google app opened.
  ///
  /// In en, this message translates to:
  /// **'Google Lens can\'t be opened from here'**
  String get lensInstructionsTitle;

  /// label-autofill-windows A14: step 1.
  ///
  /// In en, this message translates to:
  /// **'Open Google Lens and frame the label'**
  String get lensInstructionsStep1;

  /// label-autofill-windows A14: step 2.
  ///
  /// In en, this message translates to:
  /// **'Select the text of the label'**
  String get lensInstructionsStep2;

  /// label-autofill-windows A14: step 3.
  ///
  /// In en, this message translates to:
  /// **'Tap Share → Vinoozy'**
  String get lensInstructionsStep3;

  /// label-autofill-windows: closes the instructions.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get lensInstructionsOk;

  /// label-autofill-windows FR4.1: title of the level selector.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get levelLabel;

  /// label-autofill-windows FR4.1.
  ///
  /// In en, this message translates to:
  /// **'Everyday (inexpensive)'**
  String get levelEveryday;

  /// label-autofill-windows FR4.1.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get levelGood;

  /// label-autofill-windows FR4.1.
  ///
  /// In en, this message translates to:
  /// **'For ageing'**
  String get levelAging;

  /// label-autofill-windows: back to "not chosen".
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get levelNone;

  /// label-autofill-windows: line under "Everyday".
  ///
  /// In en, this message translates to:
  /// **'drink early'**
  String get levelEverydayShort;

  /// label-autofill-windows: line under "Good".
  ///
  /// In en, this message translates to:
  /// **'normal estimate'**
  String get levelGoodShort;

  /// label-autofill-windows: line under "For ageing".
  ///
  /// In en, this message translates to:
  /// **'lasts longer'**
  String get levelAgingShort;

  /// label-autofill-windows A3: the suggested level.
  ///
  /// In en, this message translates to:
  /// **'suggested'**
  String get levelSuggested;

  /// label-autofill-windows FR4.3: why a level is suggested.
  ///
  /// In en, this message translates to:
  /// **'Suggested because the name says \"{qualifier}\": it is saved like this unless you change it. Choose another one or tap \"None\".'**
  String levelSuggestedReason(String qualifier);

  /// label-autofill-windows A3, A10: read with the suggested option.
  ///
  /// In en, this message translates to:
  /// **'suggested, because the name says {qualifier}'**
  String levelSuggestedSemantics(String qualifier);

  /// label-autofill-windows A10: an option of the single-choice group.
  ///
  /// In en, this message translates to:
  /// **'Level, {option}, {index} of {count}'**
  String levelOptionSemantics(String option, int index, int count);

  /// label-autofill-windows FR4.1: title of the examples.
  ///
  /// In en, this message translates to:
  /// **'What changes'**
  String get levelWhatChanges;

  /// label-autofill-windows FR4.1.
  ///
  /// In en, this message translates to:
  /// **'The window gets shorter. E.g. house wine, Lambrusco, basic Prosecco, Bardolino, Vinho Verde.'**
  String get levelEverydayExamples;

  /// label-autofill-windows FR4.1.
  ///
  /// In en, this message translates to:
  /// **'The normal estimate, and the value when you choose nothing. E.g. Chianti Classico, Barbera d\'Asti Superiore, Rioja Crianza, Côtes du Rhône.'**
  String get levelGoodExamples;

  /// label-autofill-windows FR4.1.
  ///
  /// In en, this message translates to:
  /// **'The window gets longer. E.g. Barolo, Brunello, Amarone, Bordeaux Grand Cru, Rioja Gran Reserva, Vintage Port.'**
  String get levelAgingExamples;

  /// label-autofill-windows FR4.2: window with the level saved.
  ///
  /// In en, this message translates to:
  /// **'Before {start} – {end}'**
  String levelPreviewBefore(String start, String end);

  /// label-autofill-windows FR4.2: window with the level chosen.
  ///
  /// In en, this message translates to:
  /// **'With \"{level}\" {start} – {end}'**
  String levelPreviewWith(String level, String start, String end);

  /// label-autofill-windows FR4.2: window of the form with the level shown.
  ///
  /// In en, this message translates to:
  /// **'Ready {start} – until {end}'**
  String levelPreviewNow(String start, String end);

  /// label-autofill-windows FR4.4: the level in the detail.
  ///
  /// In en, this message translates to:
  /// **'Level: {level}'**
  String levelDetail(String level);

  /// label-autofill-windows FR5.1: opens the year sheet.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get overrideCorrect;

  /// label-autofill-windows FR5.4.
  ///
  /// In en, this message translates to:
  /// **'Restore estimate'**
  String get overrideRestore;

  /// label-autofill-windows FR5.2: replaces the "Indicative" notice.
  ///
  /// In en, this message translates to:
  /// **'corrected by you'**
  String get overrideCorrectedByYou;

  /// label-autofill-windows FR5.2: the estimate under a correction.
  ///
  /// In en, this message translates to:
  /// **'App estimate: until {year}'**
  String overrideAppEstimate(String year);

  /// label-autofill-windows FR5.1: title of the year sheet.
  ///
  /// In en, this message translates to:
  /// **'Recommended until'**
  String get overrideSheetTitle;

  /// label-autofill-windows FR5.1, BR4.6.
  ///
  /// In en, this message translates to:
  /// **'Choose the year. It cannot be before \"Ready from {start}\".'**
  String overrideSheetHint(String start);

  /// label-autofill-windows FR5.1: a year before the peak.
  ///
  /// In en, this message translates to:
  /// **'If you choose a year before {peak} (at its best), \"at its best\" moves to the same year too.'**
  String overridePeakNotice(String peak);

  /// label-autofill-windows: every year of the range in a list.
  ///
  /// In en, this message translates to:
  /// **'more…'**
  String get overrideMore;

  /// label-autofill-windows FR5.1.
  ///
  /// In en, this message translates to:
  /// **'Save correction'**
  String get overrideSave;

  /// label-autofill-windows FR5.4.
  ///
  /// In en, this message translates to:
  /// **'Go back to the app estimate (until {year})?'**
  String overrideRestoreTitle(String year);

  /// label-autofill-windows FR5.4.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get overrideRestoreConfirm;

  /// label-autofill-windows A7: announced after saving.
  ///
  /// In en, this message translates to:
  /// **'Correction saved'**
  String get overrideSaved;

  /// label-autofill-windows A7: announced after restoring.
  ///
  /// In en, this message translates to:
  /// **'Estimate restored'**
  String get overrideRestored;

  /// label-autofill-windows BR4.7: source label with a correction.
  ///
  /// In en, this message translates to:
  /// **'corrected by you'**
  String get estimateSourceCorrectedByYou;

  /// label-autofill-windows: origin of the estimate.
  ///
  /// In en, this message translates to:
  /// **'Estimate from the appellation {name}'**
  String estimateFromDenomination(String name);

  /// label-autofill-windows: origin of the estimate with its qualifier.
  ///
  /// In en, this message translates to:
  /// **'Estimate from the appellation {name}, {qualifier}'**
  String estimateFromDenominationQualifier(String name, String qualifier);

  /// label-autofill-windows FR3.2: origin of the estimate.
  ///
  /// In en, this message translates to:
  /// **'Estimate from the grape {name}'**
  String estimateFromGrape(String name);

  /// label-autofill-windows: origin of the estimate.
  ///
  /// In en, this message translates to:
  /// **'Estimate from the type of wine'**
  String get estimateFromType;

  /// label-autofill-windows FR2.8, BR7.24, A15: the paste button while the text is read.
  ///
  /// In en, this message translates to:
  /// **'Reading the text…'**
  String get autofillReading;

  /// label-autofill-windows FR7.7, BR7.17: reopens the guided check of the uncertain fields.
  ///
  /// In en, this message translates to:
  /// **'Guided check'**
  String get guideChip;

  /// label-autofill-windows FR7.6: progress of the guided check.
  ///
  /// In en, this message translates to:
  /// **'Question {n} of {total}'**
  String guideProgress(int n, int total);

  /// label-autofill-windows FR7.7: closes the guided check, keeping the confirmed fields.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get guideClose;

  /// label-autofill-windows FR7.4: phrase under the proposed appellation.
  ///
  /// In en, this message translates to:
  /// **'is it the appellation?'**
  String get guideIsDenomination;

  /// label-autofill-windows FR7.4: phrase under the proposed producer.
  ///
  /// In en, this message translates to:
  /// **'is it the producer?'**
  String get guideIsProducer;

  /// label-autofill-windows FR7.4: phrase under the proposed name.
  ///
  /// In en, this message translates to:
  /// **'is it the wine name?'**
  String get guideIsName;

  /// label-autofill-windows FR7.4: title of the vintage question.
  ///
  /// In en, this message translates to:
  /// **'Vintage'**
  String get guideIsVintage;

  /// label-autofill-windows A16: the whole question read by the screen reader.
  ///
  /// In en, this message translates to:
  /// **'Is {value} the appellation?'**
  String guideAskDenomination(String value);

  /// label-autofill-windows A16: the whole question read by the screen reader.
  ///
  /// In en, this message translates to:
  /// **'Is {value} the producer?'**
  String guideAskProducer(String value);

  /// label-autofill-windows A16: the whole question read by the screen reader.
  ///
  /// In en, this message translates to:
  /// **'Is {value} the wine name?'**
  String guideAskName(String value);

  /// label-autofill-windows A16: the vintage question read by the screen reader.
  ///
  /// In en, this message translates to:
  /// **'What is the vintage?'**
  String get guideAskVintage;

  /// label-autofill-windows A16: what the screen reader says when a question opens.
  ///
  /// In en, this message translates to:
  /// **'Question {n} of {total}: {question}'**
  String guideQuestionSemantics(int n, int total, String question);

  /// label-autofill-windows BR7.12: a question with no candidate.
  ///
  /// In en, this message translates to:
  /// **'I couldn\'t find it in the text'**
  String get guideNoProposal;

  /// label-autofill-windows FR7.4: confirms the proposed value.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get guideYes;

  /// label-autofill-windows FR7.4: proposes the next candidate.
  ///
  /// In en, this message translates to:
  /// **'No, another'**
  String get guideNo;

  /// label-autofill-windows FR7.4: writes the value by hand.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get guideEdit;

  /// label-autofill-windows FR7.4: leaves the field empty and goes on.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get guideSkip;

  /// label-autofill-windows FR7.4, FR7.5: confirms an edited or composed value.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get guideConfirm;

  /// label-autofill-windows FR7.4, FR7.5: back to the question.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get guideCancel;

  /// label-autofill-windows BR7.12: notice after "No".
  ///
  /// In en, this message translates to:
  /// **'Not \"{value}\": here\'s the next one'**
  String guideRejected(String value);

  /// label-autofill-windows BR7.12: notice after the last "No".
  ///
  /// In en, this message translates to:
  /// **'No other suggestion: compose it or skip'**
  String get guideNoMore;

  /// label-autofill-windows A20: announced after "No".
  ///
  /// In en, this message translates to:
  /// **'Suggestion: {value}'**
  String guideProposalAnnounce(String value);

  /// label-autofill-windows FR7.5: title of the words of the text.
  ///
  /// In en, this message translates to:
  /// **'Or build it by tapping words of the text'**
  String get guideComposeLabel;

  /// label-autofill-windows FR7.5: title of the composed value.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get guideComposePreview;

  /// label-autofill-windows FR7.5: empty preview.
  ///
  /// In en, this message translates to:
  /// **'Tap one or more words'**
  String get guideComposeEmpty;

  /// label-autofill-windows BR7.15: limits of a composed value.
  ///
  /// In en, this message translates to:
  /// **'Up to 8 words and 80 characters'**
  String get guideComposeLimit;

  /// label-autofill-windows BR7.16: the composed appellation matches a table row.
  ///
  /// In en, this message translates to:
  /// **'matches {name}'**
  String guideTableMatchSemantics(String name);

  /// label-autofill-windows A21: group of the words of one line.
  ///
  /// In en, this message translates to:
  /// **'Line {n} of {total}'**
  String guideLine(int n, int total);

  /// label-autofill-windows A17: a chosen word and its place in the value.
  ///
  /// In en, this message translates to:
  /// **'{word}, selected, {order}'**
  String guideWordSelected(String word, int order);

  /// label-autofill-windows A21: a word beyond the limits.
  ///
  /// In en, this message translates to:
  /// **'{word}, unavailable'**
  String guideWordUnavailable(String word);

  /// label-autofill-windows BR7.15: a word already used by another field, still selectable.
  ///
  /// In en, this message translates to:
  /// **'{word}, used for the {field, select, denomination{appellation} producer{producer} other{name}}'**
  String guideWordUsedFor(String word, String field);

  /// label-autofill-windows BR7.15: small mark under a word used by another field.
  ///
  /// In en, this message translates to:
  /// **'{field, select, denomination{appellation} producer{producer} other{name}}'**
  String guideUsedMark(String field);

  /// label-autofill-windows FR7.4: the other years of the text, without thousands separator (A9).
  ///
  /// In en, this message translates to:
  /// **'Also in the text: {years}'**
  String guideOtherYears(String years);

  /// label-autofill-windows BR7.13: a year of the text on the wheel.
  ///
  /// In en, this message translates to:
  /// **'year found in the text'**
  String get guideWheelFromText;

  /// label-autofill-windows BR7.13: the number pad of the wheel.
  ///
  /// In en, this message translates to:
  /// **'Type the year'**
  String get guideWheelTypeYear;

  /// label-autofill-windows BR7.13: confirms the year of the wheel, without thousands separator.
  ///
  /// In en, this message translates to:
  /// **'Confirm {year}'**
  String guideWheelConfirm(String year);

  /// label-autofill-windows BR7.13: the wine has no vintage; it counts as an answer.
  ///
  /// In en, this message translates to:
  /// **'No vintage'**
  String get guideNoVintage;

  /// label-autofill-windows BR7.12: one field skipped at the end of the guide.
  ///
  /// In en, this message translates to:
  /// **'{field, select, denomination{Appellation skipped} producer{Producer skipped} vintage{Vintage skipped} other{Name skipped}}: type it or resume the guide'**
  String guideSkippedNotice(String field);

  /// label-autofill-windows BR7.12: several fields skipped at the end of the guide.
  ///
  /// In en, this message translates to:
  /// **'{count} fields skipped: type them or resume the guide'**
  String guideSkippedMany(int count);

  /// label-autofill-windows NFR3.9: a typed or composed value with control characters.
  ///
  /// In en, this message translates to:
  /// **'This text contains characters that cannot be saved'**
  String get guideInvalidValue;

  /// Name of the studio that makes the app, shown in the splash and at the bottom of the Dashboard. Not translated.
  ///
  /// In en, this message translates to:
  /// **'Bottazzini Softworks'**
  String get brandStudio;

  /// wine-style-profiles BR7.7: mark of a field filled by the preselection.
  ///
  /// In en, this message translates to:
  /// **'✦ suggested'**
  String get suggestedMark;

  /// wine-style-profiles: screen reader label of a suggested field.
  ///
  /// In en, this message translates to:
  /// **'{field}, {value}, suggested'**
  String suggestedSemantics(String field, String value);

  /// wine-style-profiles BR7.3.
  ///
  /// In en, this message translates to:
  /// **'Restore suggestion'**
  String get restoreSuggestion;

  /// wine-style-profiles BR7.3: announcement.
  ///
  /// In en, this message translates to:
  /// **'Suggestion restored'**
  String get restoreSuggestionDone;

  /// wine-style-profiles BR5.1: style field.
  ///
  /// In en, this message translates to:
  /// **'Style'**
  String get styleLabel;

  /// wine-style-profiles: screen reader label of a style chip.
  ///
  /// In en, this message translates to:
  /// **'Style, {value}, {index} of {count}'**
  String styleGroupSemantics(String value, int index, int count);

  /// BR5.2 style chip.
  ///
  /// In en, this message translates to:
  /// **'Fresh'**
  String get styleRedFresh;

  /// BR5.2 style chip.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get styleRedMedium;

  /// BR5.2 style chip.
  ///
  /// In en, this message translates to:
  /// **'For ageing'**
  String get styleRedAge;

  /// BR5.2 style chip.
  ///
  /// In en, this message translates to:
  /// **'Long ageing'**
  String get styleRedLong;

  /// BR5.2 style chip.
  ///
  /// In en, this message translates to:
  /// **'Fresh'**
  String get styleWhiteFresh;

  /// BR5.2 style chip.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get styleWhiteMedium;

  /// BR5.2 style chip.
  ///
  /// In en, this message translates to:
  /// **'For ageing'**
  String get styleWhiteAge;

  /// BR5.2 style chip.
  ///
  /// In en, this message translates to:
  /// **'Fresh'**
  String get styleRoseFresh;

  /// BR5.2 style chip.
  ///
  /// In en, this message translates to:
  /// **'Fresh'**
  String get styleClassicFresh;

  /// BR5.2 style chip.
  ///
  /// In en, this message translates to:
  /// **'For ageing'**
  String get styleClassicAge;

  /// BR5.2 style chip.
  ///
  /// In en, this message translates to:
  /// **'Fresh'**
  String get styleTankFresh;

  /// BR5.2 style chip.
  ///
  /// In en, this message translates to:
  /// **'Lambrusco'**
  String get styleLambrusco;

  /// BR5.2 style chip.
  ///
  /// In en, this message translates to:
  /// **'Aromatic'**
  String get styleSweetAromatic;

  /// BR5.2 style chip.
  ///
  /// In en, this message translates to:
  /// **'Dried-grape'**
  String get styleSweetPassito;

  /// BR5.2 style chip.
  ///
  /// In en, this message translates to:
  /// **'Botrytised'**
  String get styleSweetBotrytis;

  /// BR5.2 style chip.
  ///
  /// In en, this message translates to:
  /// **'Vintage Port'**
  String get stylePortVintage;

  /// BR5.2 style chip.
  ///
  /// In en, this message translates to:
  /// **'LBV/Ruby Port'**
  String get stylePortLbv;

  /// BR5.2 style chip.
  ///
  /// In en, this message translates to:
  /// **'Tawny/Colheita Port'**
  String get stylePortTawny;

  /// BR5.2 style chip.
  ///
  /// In en, this message translates to:
  /// **'Fino/Manzanilla'**
  String get styleSherryFino;

  /// BR5.2 style chip.
  ///
  /// In en, this message translates to:
  /// **'Amontillado'**
  String get styleSherryAmontillado;

  /// BR5.2 style chip.
  ///
  /// In en, this message translates to:
  /// **'Oloroso/Cream'**
  String get styleSherryOloroso;

  /// BR5.2 style chip.
  ///
  /// In en, this message translates to:
  /// **'Pedro Ximénez'**
  String get styleSherryPx;

  /// BR5.2 style chip.
  ///
  /// In en, this message translates to:
  /// **'Madeira'**
  String get styleMadeira;

  /// BR5.2 style chip.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get styleFortifiedOther;

  /// Profile name (R_FRESH).
  ///
  /// In en, this message translates to:
  /// **'Fruit-forward red'**
  String get profileNameRFresh;

  /// Profile name (R_MEDIUM).
  ///
  /// In en, this message translates to:
  /// **'Medium-bodied red'**
  String get profileNameRMedium;

  /// Profile name (R_AGE).
  ///
  /// In en, this message translates to:
  /// **'Red for ageing'**
  String get profileNameRAge;

  /// Profile name (R_LONG).
  ///
  /// In en, this message translates to:
  /// **'Long-ageing red'**
  String get profileNameRLong;

  /// Profile name (W_FRESH).
  ///
  /// In en, this message translates to:
  /// **'Fresh aromatic white'**
  String get profileNameWFresh;

  /// Profile name (W_MEDIUM).
  ///
  /// In en, this message translates to:
  /// **'Medium-bodied white'**
  String get profileNameWMedium;

  /// Profile name (W_AGE).
  ///
  /// In en, this message translates to:
  /// **'White for ageing'**
  String get profileNameWAge;

  /// Profile name (ROSE_FRESH).
  ///
  /// In en, this message translates to:
  /// **'Fresh rosé'**
  String get profileNameRoseFresh;

  /// Profile name (SP_TANK).
  ///
  /// In en, this message translates to:
  /// **'Fresh tank-method sparkling'**
  String get profileNameSpTank;

  /// Profile name (LAM_FRESH).
  ///
  /// In en, this message translates to:
  /// **'Fresh Lambrusco'**
  String get profileNameLamFresh;

  /// Profile name (SP_CLASSIC).
  ///
  /// In en, this message translates to:
  /// **'Fresh traditional-method sparkling'**
  String get profileNameSpClassic;

  /// Profile name (SP_CLASSIC_AGE).
  ///
  /// In en, this message translates to:
  /// **'Traditional-method sparkling for ageing'**
  String get profileNameSpClassicAge;

  /// Profile name (SW_AROMATIC).
  ///
  /// In en, this message translates to:
  /// **'Young aromatic sweet wine'**
  String get profileNameSwAromatic;

  /// Profile name (SW_PASSITO).
  ///
  /// In en, this message translates to:
  /// **'Dried-grape sweet wine'**
  String get profileNameSwPassito;

  /// Profile name (SW_BOTRYTIS).
  ///
  /// In en, this message translates to:
  /// **'Botrytised sweet wine'**
  String get profileNameSwBotrytis;

  /// Profile name (PORT_VINTAGE).
  ///
  /// In en, this message translates to:
  /// **'Vintage Port'**
  String get profileNamePortVintage;

  /// Profile name (PORT_LBV).
  ///
  /// In en, this message translates to:
  /// **'LBV/Ruby Port'**
  String get profileNamePortLbv;

  /// Profile name (PORT_OX).
  ///
  /// In en, this message translates to:
  /// **'Tawny/Colheita Port'**
  String get profileNamePortOx;

  /// Profile name (SH_FINO).
  ///
  /// In en, this message translates to:
  /// **'Fino/Manzanilla'**
  String get profileNameShFino;

  /// Profile name (SH_AMONT).
  ///
  /// In en, this message translates to:
  /// **'Amontillado/Medium'**
  String get profileNameShAmont;

  /// Profile name (SH_OLOROSO).
  ///
  /// In en, this message translates to:
  /// **'Oloroso/Cream'**
  String get profileNameShOloroso;

  /// Profile name (SH_PX).
  ///
  /// In en, this message translates to:
  /// **'Pedro Ximénez Sherry'**
  String get profileNameShPx;

  /// Profile name (FORT_UNKNOWN).
  ///
  /// In en, this message translates to:
  /// **'Fortified, style unknown'**
  String get profileNameFortUnknown;

  /// Profile name (UNKNOWN).
  ///
  /// In en, this message translates to:
  /// **'Style not identified'**
  String get profileNameUnknown;

  /// wine-style-profiles BR5.5.
  ///
  /// In en, this message translates to:
  /// **'Estimate from the {profile} profile ({denomination})'**
  String estimateFromProfile(String profile, String denomination);

  /// wine-style-profiles BR5.5.
  ///
  /// In en, this message translates to:
  /// **'Estimate from the {profile} profile, by type'**
  String estimateFromProfileType(String profile);

  /// wine-style-profiles BR5.5.
  ///
  /// In en, this message translates to:
  /// **'Estimate from the {profile} profile, by the grape {grape}'**
  String estimateFromProfileGrape(String profile, String grape);

  /// wine-style-profiles BR5.5, BR8.3.
  ///
  /// In en, this message translates to:
  /// **'From the date added: add the disgorgement date for a better estimate'**
  String get estimateFromEntryDateDisgorgement;

  /// wine-style-profiles BR5.5, BR8.3.
  ///
  /// In en, this message translates to:
  /// **'From the date added: add the bottling date for a better estimate'**
  String get estimateFromEntryDateBottling;

  /// wine-style-profiles BR5.4.
  ///
  /// In en, this message translates to:
  /// **'⚠︎ Style to confirm: the estimate is indicative'**
  String get styleToConfirmBanner;

  /// wine-style-profiles S4.
  ///
  /// In en, this message translates to:
  /// **'Choose the type'**
  String get chooseTypePrompt;

  /// wine-style-profiles R-08: screen reader announcement.
  ///
  /// In en, this message translates to:
  /// **'Estimate updated: {summary}'**
  String estimateUpdatedAnnouncement(String summary);

  /// wine-style-profiles BR8.1.
  ///
  /// In en, this message translates to:
  /// **'Disgorgement'**
  String get agingStartDisgorgement;

  /// wine-style-profiles BR8.1.
  ///
  /// In en, this message translates to:
  /// **'Bottling'**
  String get agingStartBottling;

  /// wine-style-profiles BR8.1.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get agingStartMonth;

  /// wine-style-profiles BR8.1.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get agingStartYear;

  /// wine-style-profiles BR8.1.
  ///
  /// In en, this message translates to:
  /// **'It is usually on the back label.'**
  String get agingStartHint;

  /// wine-style-profiles BR8.2.
  ///
  /// In en, this message translates to:
  /// **'Enter month and year'**
  String get agingStartIncomplete;

  /// wine-style-profiles BR8.2.
  ///
  /// In en, this message translates to:
  /// **'The date cannot be in the future'**
  String get agingStartFuture;

  /// wine-style-profiles BR8.2.
  ///
  /// In en, this message translates to:
  /// **'It cannot be before the vintage'**
  String get agingStartBeforeVintage;

  /// wine-style-profiles BR6.5.
  ///
  /// In en, this message translates to:
  /// **'Ready, no end estimated'**
  String get windowNoEnd;

  /// wine-style-profiles BR6.5.
  ///
  /// In en, this message translates to:
  /// **'no end estimated'**
  String get windowNoEndShort;

  /// wine-style-profiles BR6.7.
  ///
  /// In en, this message translates to:
  /// **'by {date}'**
  String windowDrinkWithin(String date);

  /// wine-style-profiles BR4.1.
  ///
  /// In en, this message translates to:
  /// **'The level does not change this estimate'**
  String get levelNoEffect;

  /// wine-style-profiles BR6.7.
  ///
  /// In en, this message translates to:
  /// **'To confirm'**
  String get dashboardToConfirmTitle;

  /// wine-style-profiles BR6.7.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 wine} other{{count} wines}}'**
  String dashboardToConfirmCount(int count);

  /// wine-style-profiles NFR6.1: share of the offline wines with a Type.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of the wines with a recognised type'**
  String aboutDbClassified(String percent);
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
