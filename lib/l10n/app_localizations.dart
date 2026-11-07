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

  /// No description provided for @labelOfflineNotice.
  ///
  /// In en, this message translates to:
  /// **'Without network I only recognise the denomination: check the details'**
  String get labelOfflineNotice;

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

  /// No description provided for @labelBarcodeNeedsNetwork.
  ///
  /// In en, this message translates to:
  /// **'I read the barcode: I need the network to look it up'**
  String get labelBarcodeNeedsNetwork;

  /// No description provided for @labelRetryOnline.
  ///
  /// In en, this message translates to:
  /// **'Try again when the network is back'**
  String get labelRetryOnline;

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
