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

  @override
  String get offAttribution => 'Data from Open Food Facts (ODbL)';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String dashboardTotalBottles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bottles in the cellar',
      one: '1 bottle in the cellar',
    );
    return '$_temp0';
  }

  @override
  String get dashboardSyncing => 'Syncing the cellar…';

  @override
  String get dashboardAddFirstWine => 'Add your first wine';

  @override
  String get drinkSoonTitle => 'Drink soon';

  @override
  String get drinkSoonEmpty => 'No bottles due soon';

  @override
  String drinkSoonUntil(String year) {
    return 'by $year';
  }

  @override
  String drinkSoonSeeAll(int count) {
    return 'See all ($count)';
  }

  @override
  String get statusChartTitle => 'Bottle status';

  @override
  String get statusWaiting => 'to wait';

  @override
  String get statusReady => 'ready';

  @override
  String get statusDrinkSoon => 'drink soon';

  @override
  String get statusPastWindow => 'past the window';

  @override
  String toEstimateNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bottles to estimate',
      one: '1 bottle to estimate',
    );
    return '$_temp0';
  }

  @override
  String chartBarValue(String label, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bottles',
      one: '1 bottle',
    );
    return '$label: $_temp0';
  }

  @override
  String chartDescription(String title, String values) {
    return '$title: $values';
  }

  @override
  String get openListHint => 'Open the list';

  @override
  String get peakChartTitle => 'Peak year';

  @override
  String get peakPast => 'past peak';

  @override
  String get peakBeyond => 'later';

  @override
  String get breakdownTypeTitle => 'Bottles by type';

  @override
  String get breakdownRegionTitle => 'Bottles by region';

  @override
  String get breakdownType => 'Type';

  @override
  String get breakdownRegion => 'Region';

  @override
  String get familyRed => 'red';

  @override
  String get familyWhite => 'white';

  @override
  String get familyRose => 'rosé';

  @override
  String get familySparkling => 'sparkling';

  @override
  String get familySweet => 'sweet';

  @override
  String get breakdownUnspecified => 'not specified';

  @override
  String get breakdownOtherRegions => 'others';

  @override
  String get ok => 'OK';

  @override
  String get cellarMenu => 'Cellar menu';

  @override
  String get sharingPeopleTitle => 'People';

  @override
  String get sharingInviteTitle => 'Invite a person';

  @override
  String get sharingEmailLabel => 'Google email address';

  @override
  String get sharingPermissionRead => 'Read only';

  @override
  String get sharingPermissionReadHint =>
      'Sees wines, estimates, dashboard and drinks';

  @override
  String get sharingPermissionEdit => 'Can edit';

  @override
  String get sharingPermissionEditHint =>
      'Also adds and changes wines and records drinks';

  @override
  String get sharingRoleOwner => 'owner';

  @override
  String get sharingInviteButton => 'Invite';

  @override
  String sharingPlacesUsed(int used, int max) {
    return '$used/$max people';
  }

  @override
  String get sharingInvalidEmail => 'Enter a valid email';

  @override
  String get sharingSelfInvite => 'You cannot invite yourself';

  @override
  String get sharingAlreadyInvited => 'This person is already invited';

  @override
  String sharingLimitReached(int max) {
    return 'You have reached the limit of $max people';
  }

  @override
  String get sharingNotOwner => 'You cannot change the sharing of this cellar';

  @override
  String get sharingNotFound => 'This person is no longer in the list';

  @override
  String get sharingFailed => 'Could not complete, try again';

  @override
  String get sharingInviteFailed => 'Invitation failed. Try again';

  @override
  String get sharingOfflineHint => 'You need a connection to manage sharing';

  @override
  String get sharingStatusInvited => 'invited';

  @override
  String get sharingStatusActive => 'active';

  @override
  String get sharingStatusRevoked => 'revoked';

  @override
  String get sharingStatusLeft => 'left';

  @override
  String sharingMemberSemantics(String name, String permission, String status) {
    return '$name, $permission, $status';
  }

  @override
  String get sharingClosedSection => 'Closed access';

  @override
  String get sharingNobody => 'Nobody else sees this cellar yet';

  @override
  String sharingChangePermission(String name) {
    return 'Change permission of $name';
  }

  @override
  String get sharingRevoke => 'Revoke';

  @override
  String sharingRevokeTitle(String name) {
    return 'Revoke the access of $name?';
  }

  @override
  String sharingRevokeConfirmLabel(String name) {
    return 'Type $name to confirm';
  }

  @override
  String get sharingRevokeDisabledHint => 'Enabled when the name matches';

  @override
  String get sharingReinvite => 'Invite again';

  @override
  String get sharingDeleteForGood => 'Delete for good';

  @override
  String sharingOwnedBy(String owner) {
    return 'Cellar of $owner';
  }

  @override
  String get sharingYourCellar => 'Your cellar';

  @override
  String sharingYourPermission(String permission) {
    return 'Your permission: $permission';
  }

  @override
  String sharingSwitcherSemantics(String cellar, String permission) {
    return '$cellar, $permission. Tap to change cellar';
  }

  @override
  String get sharingLeave => 'Leave this cellar';

  @override
  String sharingLeaveTitle(String owner) {
    return 'Leave the cellar of $owner?';
  }

  @override
  String sharingLeaveBody(String owner) {
    return 'You will no longer see it. $owner can invite you again.';
  }

  @override
  String get sharingLeaveConfirm => 'Leave';

  @override
  String sharingSharedNotice(String owner) {
    return '$owner shared their cellar with you';
  }

  @override
  String sharingAccessLost(String owner) {
    return 'You no longer have access to the cellar of $owner';
  }

  @override
  String sharingWritesLost(String owner) {
    return 'Some changes to the cellar of $owner were not saved because you no longer have access';
  }

  @override
  String get sharingSomeone => 'someone';

  @override
  String get sharingShareSubject => 'Invitation to Vinoozy';

  @override
  String sharingShareMessage(
    String owner,
    String cellar,
    String link,
    String email,
  ) {
    return '$owner invited you to the cellar \"$cellar\" on Vinoozy. Install the app from $link and sign in with the Google account $email: use exactly this address.';
  }

  @override
  String get cellarSearchHint => 'Search by name or producer';

  @override
  String get cellarFilterStatus => 'Status';

  @override
  String get cellarFilterType => 'Type';

  @override
  String get statusToEstimate => 'To estimate';

  @override
  String get filterTypeUnspecified => 'Not specified';

  @override
  String get cellarNoMatches => 'No wine with these filters';

  @override
  String get cellarClearFilters => 'Clear filters';

  @override
  String get cellarArchiveTitle => 'Drunk';

  @override
  String get cellarArchiveEmpty => 'No finished wines yet';

  @override
  String get cellarArchiveFailed => 'Could not load the finished wines';

  @override
  String get wineDrink => 'Drunk';

  @override
  String wineDrinkTooltip(String name) {
    return 'Mark a bottle of $name as drunk';
  }

  @override
  String confidenceLabel(String level) {
    return 'Confidence: $level';
  }

  @override
  String get confidenceHigh => 'high';

  @override
  String get confidenceMedium => 'medium';

  @override
  String get confidenceLow => 'low';

  @override
  String get windowStartLabel => 'Start';

  @override
  String get windowPeakLabel => 'Peak';

  @override
  String get windowEndLabel => 'End';

  @override
  String estimateSourceLabel(String source) {
    return 'Source: $source';
  }

  @override
  String get estimateSourceCatalog => 'wine database';

  @override
  String get estimateSourceType => 'estimate for the type';

  @override
  String get estimateSourceCorrected => 'estimate corrected by your drinks';

  @override
  String get estimateDisclaimer =>
      'Indicative estimate: it also depends on how the bottle was stored';

  @override
  String get estimateUnavailable => 'Estimate not available';

  @override
  String get pairingsTitle => 'Pairings';

  @override
  String get pairingsGeneric => 'generic pairings for the type';

  @override
  String get pairingBraisedRedMeat => 'Braised red meat';

  @override
  String get pairingGrilledRedMeat => 'Grilled red meat';

  @override
  String get pairingGame => 'Game';

  @override
  String get pairingRoastPoultry => 'Roast poultry';

  @override
  String get pairingPoultry => 'Poultry';

  @override
  String get pairingPork => 'Pork';

  @override
  String get pairingCuredMeats => 'Cured meats';

  @override
  String get pairingPastaMeatSauce => 'Pasta with meat sauce';

  @override
  String get pairingMushroomsTruffle => 'Mushrooms and truffle';

  @override
  String get pairingAgedCheese => 'Aged cheese';

  @override
  String get pairingFreshCheese => 'Fresh cheese';

  @override
  String get pairingBlueCheese => 'Blue cheese';

  @override
  String get pairingFish => 'Fish';

  @override
  String get pairingSeafood => 'Seafood';

  @override
  String get pairingRawSeafood => 'Raw seafood';

  @override
  String get pairingFriedFood => 'Fried food';

  @override
  String get pairingVegetables => 'Vegetables';

  @override
  String get pairingRisotto => 'Risotto';

  @override
  String get pairingPizza => 'Pizza';

  @override
  String get pairingAperitif => 'Aperitif';

  @override
  String get pairingPastries => 'Pastries';

  @override
  String get pairingDryBiscuits => 'Dry biscuits';

  @override
  String get pairingChocolate => 'Chocolate';

  @override
  String get pairingDriedFruit => 'Dried fruit';

  @override
  String get pairingSpicyDishes => 'Spicy dishes';

  @override
  String get recentDrinksTitle => 'Last drinks';

  @override
  String get noDrinksYet => 'No drinks yet';

  @override
  String get wineEdit => 'Edit';

  @override
  String get wineDelete => 'Delete';

  @override
  String get wineFinished => 'Finished: no bottles left';

  @override
  String get wineLoadFailed => 'Could not open the wine';

  @override
  String get wineNotFound => 'This wine no longer exists';

  @override
  String drinkDone(String name) {
    return 'Marked as drunk: $name';
  }

  @override
  String get drinkUndo => 'Undo';

  @override
  String get drinkAddNotes => 'Add rating and notes';

  @override
  String get nothingToUndo => 'Nothing left to undo';

  @override
  String get cellarUndoRejected =>
      'Undo failed: the bottle stays marked as drunk';

  @override
  String get cellarDeleteFailed =>
      'The deletion is not complete yet: it will finish as soon as possible';

  @override
  String get duplicateFull =>
      'This wine already has 99 bottles: no more can be added.';

  @override
  String get recordSheetTitle => 'Rating and notes';

  @override
  String get recordRatingLabel => 'Rating';

  @override
  String ratingStar(int n) {
    return 'Rating $n of 5';
  }

  @override
  String get recordNotesLabel => 'Notes';

  @override
  String get recordNotesTooLong => 'At most 1000 characters';

  @override
  String recordDateLabel(String date) {
    return 'Date: $date';
  }

  @override
  String get recordDateInvalid =>
      'The date cannot be in the future or before the vintage';

  @override
  String get recordConditionTitle => 'How was it?';

  @override
  String get conditionTooYoung => 'Still too young';

  @override
  String get conditionJustRight => 'Just right';

  @override
  String get conditionPastPeak => 'Past its best';

  @override
  String get recordNoCondition => 'No answer';

  @override
  String get producerLabel => 'Producer (optional)';

  @override
  String get producerTooLong => 'At most 120 characters';

  @override
  String producerAddNew(String name) {
    return 'Add «$name» as a new producer';
  }

  @override
  String get wineTypeLabel => 'Type';

  @override
  String get typeRedLight => 'Light red';

  @override
  String get typeRedStructured => 'Full-bodied red';

  @override
  String get typeWhite => 'White';

  @override
  String get typeRose => 'Rosé';

  @override
  String get typeSparklingClassic => 'Classic-method sparkling';

  @override
  String get typeSparklingTank => 'Tank-method sparkling';

  @override
  String get typeSweet => 'Sweet';

  @override
  String get typeFortified => 'Fortified';

  @override
  String get suggestionFromCellar => 'In your cellar';

  @override
  String get suggestionsLabel => 'Suggestions';

  @override
  String get duplicateTitle => 'Already in the cellar';

  @override
  String duplicateBody(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bottles',
      one: '1 bottle',
      zero: 'no bottles',
    );
    return '$name is already there with $_temp0. Add the new bottles to it?';
  }

  @override
  String duplicateAdd(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Add $count bottles',
      one: 'Add 1 bottle',
    );
    return '$_temp0';
  }

  @override
  String get duplicateBanner => 'Possible duplicate';

  @override
  String get duplicateMerge => 'Merge';

  @override
  String get duplicateDeleteHint => 'Delete this entry if it is a duplicate';

  @override
  String get mergeTitle => 'Merge the two entries?';

  @override
  String get mergeBody =>
      'The bottles of this entry move to the older one, then this entry is deleted.';

  @override
  String get editWineTitle => 'Edit wine';

  @override
  String get editDuplicate =>
      'Another wine with the same name, producer and vintage exists';

  @override
  String deleteWineTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get deleteWineBody =>
      'The wine and all its drinks are deleted. This cannot be undone.';

  @override
  String get historyTitle => 'History';

  @override
  String get historyEmpty => 'Here you will find the bottles you drank';

  @override
  String get historyLoadFailed => 'Could not load the history';

  @override
  String drankOnLabel(String date) {
    return 'Drunk on $date';
  }

  @override
  String get addChoiceTitle => 'Add a wine';

  @override
  String get addChoicePhoto => 'Take a photo';

  @override
  String get addChoiceImport => 'Import a photo';

  @override
  String get addChoiceWrite => 'Write';

  @override
  String get labelReading => 'Reading the label…';

  @override
  String get labelRecognized => 'I recognised:';

  @override
  String get labelCorrect => 'Correct';

  @override
  String get labelConfirm => 'Confirm';

  @override
  String get labelUnreadable => 'I can\'t read the label';

  @override
  String get labelWriteByHand => 'Write by hand';

  @override
  String get labelNotFound => 'I didn\'t find the wine: check the details';

  @override
  String get labelCameraDenied =>
      'To read the label I need access to the camera';

  @override
  String get labelPhotosDenied =>
      'To read the label I need access to the photos';

  @override
  String get labelOpenSettings => 'Open settings';

  @override
  String get labelCameraUnavailable => 'Camera not available';

  @override
  String get labelBarcodeNotFound =>
      'I read the barcode but I can\'t find the wine';

  @override
  String get labelBarcodeFrontHint => 'Take a photo of the front of the label';

  @override
  String get labelSharedNotAllowed => 'You can\'t add wines to this cellar';

  @override
  String get labelSharedFirstOnly => 'I used only the first photo';

  @override
  String get labelSharedExpired =>
      'The shared photo could not be read: share it again';

  @override
  String get labelReplaceTitle =>
      'You have an unsaved wine. Read the new photo?';

  @override
  String get labelReplaceRead => 'Read the new photo';

  @override
  String get labelReplaceKeep => 'Continue with the open one';

  @override
  String get labelWineAdded => 'Wine added to the cellar';

  @override
  String get onboardingPage1Title => 'Your cellar in your pocket';

  @override
  String get onboardingPage1Body =>
      'Add your bottles by writing them or with a photo of the label, also without network.';

  @override
  String get onboardingPage2Title => 'At the right time';

  @override
  String get onboardingPage2Body =>
      'Vinoozy estimates when each wine is at its best and tells you which ones to open first.';

  @override
  String get onboardingPage3Title => 'Together';

  @override
  String get onboardingPage3Body =>
      'Share your cellar with up to two people and keep the history of every bottle you drink.';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Start';

  @override
  String onboardingPageOf(int page) {
    return 'Page $page of 3';
  }

  @override
  String get profileTitle => 'Profile';

  @override
  String get profilePhoto => 'Profile photo';

  @override
  String get profileSignOut => 'Sign out';

  @override
  String get profileDeleteAccount => 'Delete account';

  @override
  String get profilePrivacy => 'Privacy policy';

  @override
  String get profilePrivacyBody =>
      'You can read the privacy policy at this address:';

  @override
  String get profileCopyLink => 'Copy link';

  @override
  String get profileLinkCopied => 'Link copied';

  @override
  String get close => 'Close';

  @override
  String get signOutConfirmTitle => 'Do you want to sign out?';

  @override
  String signOutPendingWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'You have $count changes not saved yet. If you sign out and another account signs in, they will be lost.',
      one: 'You have 1 change not saved yet. If you sign out and another account signs in, it will be lost.',
    );
    return '$_temp0';
  }

  @override
  String get signOutStayAndSync => 'Stay and sync';

  @override
  String get signOutAnyway => 'Sign out anyway';

  @override
  String get syncAllSaved => 'Everything saved';

  @override
  String syncStillPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes still to save: check the network',
      one: '1 change still to save: check the network',
    );
    return '$_temp0';
  }

  @override
  String get signOutFailed => 'Could not sign out. Try again';

  @override
  String get signInAccountDeleted => 'Account deleted';

  @override
  String get deleteAccountIntro => 'This deletes for good:';

  @override
  String get deleteAccountItemCellar =>
      'Your cellar, with its wines and History';

  @override
  String get deleteAccountItemShares =>
      'The shares you gave: the invited people lose access';

  @override
  String get deleteAccountItemMemberships =>
      'Your participation in other people\'s cellars: your drinks stay there without your name';

  @override
  String get deleteAccountItemProfile => 'Your profile';

  @override
  String deleteAccountPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'You have $count changes not saved yet: they will be saved and then deleted with the rest',
      one: 'You have 1 change not saved yet: it will be saved and then deleted with the rest',
    );
    return '$_temp0';
  }

  @override
  String get deleteAccountConfirmWord => 'DELETE';

  @override
  String deleteAccountTypeWord(String word) {
    return 'Type $word to confirm';
  }

  @override
  String get deleteAccountReauthHint =>
      'Then you will sign in again with Google to confirm it is you.';

  @override
  String get deleteAccountForever => 'Delete forever';

  @override
  String get deleteAccountNeedsNetwork =>
      'Connect to the internet to delete the account';

  @override
  String get deleteAccountSameAccount =>
      'The deletion requires signing in with the same account';

  @override
  String get deletionTitle => 'Deleting the account';

  @override
  String get deletionStepPreparePhone => 'Saving the pending changes';

  @override
  String get deletionStepMarkStarted => 'Starting the deletion';

  @override
  String get deletionStepLeaveOtherCellars => 'Leaving other people\'s cellars';

  @override
  String get deletionStepCloseOwnInvitations => 'Closing your shares';

  @override
  String get deletionStepDeleteWinesAndRecords => 'Deleting wines and History';

  @override
  String get deletionStepDeleteCellar => 'Deleting the cellar';

  @override
  String get deletionStepDeleteProfileAndUser =>
      'Deleting the profile and the account';

  @override
  String get deletionStepCleanUpPhone => 'Cleaning this phone';

  @override
  String deletionStepAnnounce(int step, String label) {
    return 'Step $step of 8: $label';
  }

  @override
  String deletionDeletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wines and drinks deleted',
      one: '1 wine or drink deleted',
    );
    return '$_temp0';
  }

  @override
  String get deletionResumeHint =>
      'A deletion of this account is not finished. Sign in again with Google to complete it.';

  @override
  String get deletionContinue => 'Continue';

  @override
  String get deletionOffline =>
      'Connect to the internet to complete the deletion';

  @override
  String get deletionPendingWrites =>
      'I can\'t save the pending changes. Try again';

  @override
  String get deletionFailed => 'Could not complete the deletion. Try again';

  @override
  String get uxCountryLabel => 'Country';

  @override
  String get uxCountryOther => 'Other country…';

  @override
  String get uxCountryNone => 'No country';

  @override
  String get uxAllCountriesTitle => 'All countries and territories';

  @override
  String get uxAllCountriesSearch => 'Search a country';

  @override
  String get uxAllCountriesRare => 'Rare for wine';

  @override
  String get uxAllCountriesAll => 'All, from A to Z';

  @override
  String get uxAllCountriesNone => 'No country found';

  @override
  String get uxRegionLabel => 'Region';

  @override
  String uxRegionOf(String country) {
    return 'Region · $country';
  }

  @override
  String get uxRegionOther => 'Other region';

  @override
  String get uxRegionFieldLabel => 'Write the region';

  @override
  String get uxRegionTooLong => 'At most 120 characters';

  @override
  String get uxDrinkAction => 'I drank one';

  @override
  String uxDrinkActionTooltip(String name) {
    return 'I drank a bottle of $name';
  }

  @override
  String get uxDrinkActionDetail => 'I drank a bottle';

  @override
  String get uxDrinkSheetLabel => 'Confirm the drink';

  @override
  String get uxDrinkSheetBottles => 'Bottles';

  @override
  String uxDrinkSheetBottlesChange(int before, int after) {
    return 'Bottles: from $before to $after';
  }

  @override
  String get uxDrinkSheetRating => 'How was it? (optional)';

  @override
  String uxDrinkSheetStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stars of 5',
      one: '1 star of 5',
    );
    return '$_temp0';
  }

  @override
  String get uxDrinkSheetConfirm => 'Yes, I drank it';

  @override
  String get uxRemoveBottle => 'Remove a bottle without a drink';

  @override
  String get uxRemoveBottleTitle => 'Remove a bottle?';

  @override
  String uxRemoveBottleBody(String name) {
    return 'One bottle of $name is removed without recording a drink.';
  }

  @override
  String get uxRemoveBottleConfirm => 'Remove';

  @override
  String get uxIdealTitle => 'Ideal moment';

  @override
  String uxIdealUntil(String year) {
    return 'Recommended until $year';
  }

  @override
  String uxIdealUntilPast(String year) {
    return 'Recommended until $year: it has passed';
  }

  @override
  String uxIdealBest(String start, String end) {
    return 'At its best from $start to $end';
  }

  @override
  String uxIdealBar(String start, String end) {
    return 'Drinking window from $start to $end';
  }

  @override
  String get uxIdealDisclaimer =>
      '⚠︎ Indicative: an estimate based on type, denomination and vintage. Storage and the single bottle can change it.';

  @override
  String get uxIdealUnavailableHint =>
      'Add the vintage and the type to get an estimate.';

  @override
  String uxDashboardDrinkNow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count to drink now',
      one: '1 to drink now',
    );
    return '$_temp0';
  }

  @override
  String get uxFamilyRed => 'Red';

  @override
  String get uxFamilyWhite => 'White';

  @override
  String get uxFamilyRose => 'Rosé';

  @override
  String get uxFamilySparkling => 'Sparkling';

  @override
  String get uxFamilySweet => 'Sweet';

  @override
  String get labelBackTitle => 'Now the back';

  @override
  String get labelBackHint =>
      'The back usually has the barcode, the producer and the vintage: they help find the wine.';

  @override
  String get labelBackTake => 'Take the back';

  @override
  String get labelBackGallery => 'Choose from the gallery';

  @override
  String get labelBackSkip => 'Skip';

  @override
  String get labelStepFront => 'Front';

  @override
  String get labelStepBack => 'Back';

  @override
  String get labelStepBarcode => 'Barcode';

  @override
  String get labelStepDatabase => 'Wine database on the phone';

  @override
  String get labelStepPending => 'Waiting';

  @override
  String get labelStepRunning => 'Working…';

  @override
  String get labelStepDone => 'Done';

  @override
  String get labelStepSkipped => 'Skipped';

  @override
  String get labelStepFailed => 'Not readable';

  @override
  String labelStepStatus(String step, String status) {
    return '$step: $status';
  }

  @override
  String get labelOnPhoneNote =>
      'Everything happens on the phone: the photos are not sent to anyone.';

  @override
  String get labelBackUnreadable => 'Back not readable';

  @override
  String get labelSourceOffline => 'From the database on the phone · offline';

  @override
  String get labelSourceCatalog => 'From the catalog';

  @override
  String get labelSourceOnline => 'From Open Food Facts · online';

  @override
  String get labelNotThis => 'Not this one';

  @override
  String get labelOffAttribution => 'Data from Open Food Facts, ODbL licence';

  @override
  String get labelCandidatesTitle => 'Which of these?';

  @override
  String labelCandidatesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count similar wines',
      one: '1 similar wine',
    );
    return '$_temp0';
  }

  @override
  String get labelCandidatesNone => 'None of these';

  @override
  String get labelChipOffline => 'offline';

  @override
  String get labelChipOnline => 'online';

  @override
  String get labelChipCatalog => 'catalog';

  @override
  String get labelNoProducer => 'producer not given';

  @override
  String get labelNoMatch => 'I read the label but I don\'t recognise the wine';

  @override
  String get labelReadText => 'Text read';

  @override
  String get labelSearchOnline => 'Search online';

  @override
  String get labelOpenLens => 'Open in Google Lens';

  @override
  String get labelLensLastResort =>
      'Google Lens is the last resort: the photo goes to the Google app only if you confirm.';

  @override
  String get labelLensTitle => 'Open in Google Lens?';

  @override
  String get labelLensBody =>
      'The photo of the front will go to the Google app on your phone, or to the app you choose, which may keep a copy under its own rules. Vinoozy does not receive the results: come back here to choose or write the wine.';

  @override
  String get labelLensConfirm => 'Open Google Lens';

  @override
  String get labelLensFailed => 'I can\'t open Google Lens or the share menu';

  @override
  String get onlineSearchTitle => 'Search online';

  @override
  String get onlineSearchSubtitle => 'Open Food Facts · wines only';

  @override
  String get onlineSearchField => 'Words to search';

  @override
  String get onlineSearchHint => 'You can change the words before searching.';

  @override
  String get onlineSearchEmptyField => 'Write at least one word';

  @override
  String get onlineSearchButton => 'Search';

  @override
  String get onlineSearchLoading => 'Searching…';

  @override
  String onlineSearchResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results',
      one: '1 result',
    );
    return '$_temp0';
  }

  @override
  String get onlineSearchEmpty =>
      'No wine found: try other words or \"Write by hand\".';

  @override
  String get onlineSearchOffline =>
      'No network: I only search the database on the phone.';

  @override
  String get onlineSearchRateLimited =>
      'Online search is not available now, try again in a few minutes.';

  @override
  String get onlineSearchUnavailable =>
      'Online search is not active in this version of the app: I only search the database on the phone.';

  @override
  String get aboutTitle => 'About';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aboutDbTitle => 'Wine database';

  @override
  String aboutDbCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wines',
      one: '1 wine',
    );
    return '$_temp0';
  }

  @override
  String aboutDbDate(String date) {
    return 'Open Food Facts export of $date';
  }

  @override
  String get aboutDbSample =>
      'Sample database: a few hand-written test wines, not Open Food Facts data.';

  @override
  String get aboutDbLoading => 'Opening the wine database…';

  @override
  String get aboutDbUnavailable =>
      'The wine database is not available in this version';

  @override
  String aboutDbSource(String url) {
    return 'The derived database and the tool that builds it are in the public repository: $url';
  }

  @override
  String get aboutLicenseTitle => 'Licences';

  @override
  String get aboutLicense =>
      'Contains information from Open Food Facts, made available under the Open Database License (ODbL). Individual contents are under the Database Contents License (DbCL).';

  @override
  String get aboutPrivacyTitle => 'Label photos';

  @override
  String get aboutPrivacy =>
      'Label photos are read on the phone and deleted when you leave the outcome. They leave the phone only if you tap \"Open in Google Lens\" and confirm.';

  @override
  String get aboutAppellationsTitle => 'Appellations';

  @override
  String get aboutAppellationsSource =>
      'Appellations: eAmbrosia register (EU) and official national registers.';

  @override
  String get aboutAppellationsSample =>
      'Sample table: a hand-written extract of the registers, until the real registers are downloaded.';

  @override
  String get denominationLabel => 'Appellation';

  @override
  String get denominationTooLong => 'At most 120 characters';

  @override
  String get autofillFilledNotice => 'Filled from the label: check and save';

  @override
  String get autofillPastedNotice => 'Filled from the text: check and save';

  @override
  String get autofillFromText => '✦ from the text';

  @override
  String get autofillFromTextSemantics => 'filled from the label';

  @override
  String get autofillClear => 'Clear';

  @override
  String get autofillLens => 'Lens';

  @override
  String get autofillClearTitle => 'Clear the form?';

  @override
  String get autofillClearBody =>
      'You also wrote in some fields. \"Clear\" empties name, producer, appellation, vintage, type, country, region and level. The quantity stays.';

  @override
  String get autofillClearConfirm => 'Clear';

  @override
  String get autofillCleared => 'Form cleared';

  @override
  String get autofillPasteTitle => 'Do you have the text from Google Lens?';

  @override
  String get autofillPasteHint =>
      'In Lens select the text of the label and tap \"Copy\", then come back here.';

  @override
  String get autofillPaste => 'Paste from Lens';

  @override
  String get autofillOpenLens => 'From Google Lens';

  @override
  String get autofillOpenLensSemantics => 'opens Google Lens';

  @override
  String get autofillClipboardEmpty => 'There is no text on the clipboard';

  @override
  String get autofillNoNewFields => 'I found no data to add in the text';

  @override
  String get autofillFromLens => 'Form filled from the Lens text';

  @override
  String get autofillShareEmpty => 'No text received';

  @override
  String get autofillShareUseTitle => 'Use the text for the empty fields?';

  @override
  String get autofillShareUse => 'Use';

  @override
  String get autofillShareIgnore => 'Ignore';

  @override
  String get addChoiceLens => 'From Google Lens';

  @override
  String get addChoicePhotoHint => 'Front and back: Vinoozy reads the label.';

  @override
  String get addChoiceLensHint =>
      'Opens Lens: frame, select the text and tap Share → Vinoozy.';

  @override
  String get addChoiceImportHint => 'A photo of the label you already took.';

  @override
  String get addChoiceWriteHint => 'Empty form, with \"Paste from Lens\".';

  @override
  String get lensInstructionsTitle => 'Google Lens can\'t be opened from here';

  @override
  String get lensInstructionsStep1 => 'Open Google Lens and frame the label';

  @override
  String get lensInstructionsStep2 => 'Select the text of the label';

  @override
  String get lensInstructionsStep3 => 'Tap Share → Vinoozy';

  @override
  String get lensInstructionsOk => 'Got it';

  @override
  String get levelLabel => 'Level';

  @override
  String get levelEveryday => 'Everyday (inexpensive)';

  @override
  String get levelGood => 'Good';

  @override
  String get levelAging => 'For ageing';

  @override
  String get levelNone => 'None';

  @override
  String get levelEverydayShort => 'drink early';

  @override
  String get levelGoodShort => 'normal estimate';

  @override
  String get levelAgingShort => 'lasts longer';

  @override
  String get levelSuggested => 'suggested';

  @override
  String levelSuggestedReason(String qualifier) {
    return 'Suggested because the name says \"$qualifier\": it is saved like this unless you change it. Choose another one or tap \"None\".';
  }

  @override
  String levelSuggestedSemantics(String qualifier) {
    return 'suggested, because the name says $qualifier';
  }

  @override
  String levelOptionSemantics(String option, int index, int count) {
    return 'Level, $option, $index of $count';
  }

  @override
  String get levelWhatChanges => 'What changes';

  @override
  String get levelEverydayExamples =>
      'The window gets shorter. E.g. house wine, Lambrusco, basic Prosecco, Bardolino, Vinho Verde.';

  @override
  String get levelGoodExamples =>
      'The normal estimate, and the value when you choose nothing. E.g. Chianti Classico, Barbera d\'Asti Superiore, Rioja Crianza, Côtes du Rhône.';

  @override
  String get levelAgingExamples =>
      'The window gets longer. E.g. Barolo, Brunello, Amarone, Bordeaux Grand Cru, Rioja Gran Reserva, Vintage Port.';

  @override
  String levelPreviewBefore(String start, String end) {
    return 'Before $start – $end';
  }

  @override
  String levelPreviewWith(String level, String start, String end) {
    return 'With \"$level\" $start – $end';
  }

  @override
  String levelPreviewNow(String start, String end) {
    return 'Ready $start – until $end';
  }

  @override
  String levelDetail(String level) {
    return 'Level: $level';
  }

  @override
  String get overrideCorrect => 'Correct';

  @override
  String get overrideRestore => 'Restore estimate';

  @override
  String get overrideCorrectedByYou => 'corrected by you';

  @override
  String overrideAppEstimate(String year) {
    return 'App estimate: until $year';
  }

  @override
  String get overrideSheetTitle => 'Recommended until';

  @override
  String overrideSheetHint(String start) {
    return 'Choose the year. It cannot be before \"Ready from $start\".';
  }

  @override
  String overridePeakNotice(String peak) {
    return 'If you choose a year before $peak (at its best), \"at its best\" moves to the same year too.';
  }

  @override
  String get overrideMore => 'more…';

  @override
  String get overrideSave => 'Save correction';

  @override
  String overrideRestoreTitle(String year) {
    return 'Go back to the app estimate (until $year)?';
  }

  @override
  String get overrideRestoreConfirm => 'Restore';

  @override
  String get overrideSaved => 'Correction saved';

  @override
  String get overrideRestored => 'Estimate restored';

  @override
  String get estimateSourceCorrectedByYou => 'corrected by you';

  @override
  String estimateFromDenomination(String name) {
    return 'Estimate from the appellation $name';
  }

  @override
  String estimateFromDenominationQualifier(String name, String qualifier) {
    return 'Estimate from the appellation $name, $qualifier';
  }

  @override
  String estimateFromGrape(String name) {
    return 'Estimate from the grape $name';
  }

  @override
  String get estimateFromType => 'Estimate from the type of wine';

  @override
  String get autofillReading => 'Reading the text…';

  @override
  String get guideChip => 'Guided check';

  @override
  String guideProgress(int n, int total) {
    return 'Question $n of $total';
  }

  @override
  String get guideClose => 'Close';

  @override
  String get guideIsDenomination => 'is it the appellation?';

  @override
  String get guideIsProducer => 'is it the producer?';

  @override
  String get guideIsName => 'is it the wine name?';

  @override
  String get guideIsVintage => 'Vintage';

  @override
  String guideAskDenomination(String value) {
    return 'Is $value the appellation?';
  }

  @override
  String guideAskProducer(String value) {
    return 'Is $value the producer?';
  }

  @override
  String guideAskName(String value) {
    return 'Is $value the wine name?';
  }

  @override
  String get guideAskVintage => 'What is the vintage?';

  @override
  String guideQuestionSemantics(int n, int total, String question) {
    return 'Question $n of $total: $question';
  }

  @override
  String get guideNoProposal => 'I couldn\'t find it in the text';

  @override
  String get guideYes => 'Yes';

  @override
  String get guideNo => 'No, another';

  @override
  String get guideEdit => 'Edit';

  @override
  String get guideSkip => 'Skip';

  @override
  String get guideConfirm => 'Confirm';

  @override
  String get guideCancel => 'Cancel';

  @override
  String guideRejected(String value) {
    return 'Not \"$value\": here\'s the next one';
  }

  @override
  String get guideNoMore => 'No other suggestion: compose it or skip';

  @override
  String guideProposalAnnounce(String value) {
    return 'Suggestion: $value';
  }

  @override
  String get guideComposeLabel => 'Or build it by tapping words of the text';

  @override
  String get guideComposePreview => 'Preview';

  @override
  String get guideComposeEmpty => 'Tap one or more words';

  @override
  String get guideComposeLimit => 'Up to 8 words and 80 characters';

  @override
  String guideTableMatchSemantics(String name) {
    return 'matches $name';
  }

  @override
  String guideLine(int n, int total) {
    return 'Line $n of $total';
  }

  @override
  String guideWordSelected(String word, int order) {
    return '$word, selected, $order';
  }

  @override
  String guideWordUnavailable(String word) {
    return '$word, unavailable';
  }

  @override
  String guideWordUsedFor(String word, String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'appellation',
      'producer': 'producer',
      'other': 'name',
    });
    return '$word, used for the $_temp0';
  }

  @override
  String guideUsedMark(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'appellation',
      'producer': 'producer',
      'other': 'name',
    });
    return '$_temp0';
  }

  @override
  String guideOtherYears(String years) {
    return 'Also in the text: $years';
  }

  @override
  String get guideWheelFromText => 'year found in the text';

  @override
  String get guideWheelTypeYear => 'Type the year';

  @override
  String guideWheelConfirm(String year) {
    return 'Confirm $year';
  }

  @override
  String get guideNoVintage => 'No vintage';

  @override
  String guideSkippedNotice(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'Appellation skipped',
      'producer': 'Producer skipped',
      'vintage': 'Vintage skipped',
      'other': 'Name skipped',
    });
    return '$_temp0: type it or resume the guide';
  }

  @override
  String guideSkippedMany(int count) {
    return '$count fields skipped: type them or resume the guide';
  }

  @override
  String get guideInvalidValue =>
      'This text contains characters that cannot be saved';

  @override
  String get brandStudio => 'Bottazzini Softworks';

  @override
  String get suggestedMark => '✦ suggested';

  @override
  String suggestedSemantics(String field, String value) {
    return '$field, $value, suggested';
  }

  @override
  String get restoreSuggestion => 'Restore suggestion';

  @override
  String get restoreSuggestionDone => 'Suggestion restored';

  @override
  String get styleLabel => 'Style';

  @override
  String styleGroupSemantics(String value, int index, int count) {
    return 'Style, $value, $index of $count';
  }

  @override
  String get styleRedFresh => 'Fresh';

  @override
  String get styleRedMedium => 'Medium';

  @override
  String get styleRedAge => 'For ageing';

  @override
  String get styleRedLong => 'Long ageing';

  @override
  String get styleWhiteFresh => 'Fresh';

  @override
  String get styleWhiteMedium => 'Medium';

  @override
  String get styleWhiteAge => 'For ageing';

  @override
  String get styleRoseFresh => 'Fresh';

  @override
  String get styleClassicFresh => 'Fresh';

  @override
  String get styleClassicAge => 'For ageing';

  @override
  String get styleTankFresh => 'Fresh';

  @override
  String get styleLambrusco => 'Lambrusco';

  @override
  String get styleSweetAromatic => 'Aromatic';

  @override
  String get styleSweetPassito => 'Dried-grape';

  @override
  String get styleSweetBotrytis => 'Botrytised';

  @override
  String get stylePortVintage => 'Vintage Port';

  @override
  String get stylePortLbv => 'LBV/Ruby Port';

  @override
  String get stylePortTawny => 'Tawny/Colheita Port';

  @override
  String get styleSherryFino => 'Fino/Manzanilla';

  @override
  String get styleSherryAmontillado => 'Amontillado';

  @override
  String get styleSherryOloroso => 'Oloroso/Cream';

  @override
  String get styleSherryPx => 'Pedro Ximénez';

  @override
  String get styleMadeira => 'Madeira';

  @override
  String get styleFortifiedOther => 'Other';

  @override
  String get profileNameRFresh => 'Fruit-forward red';

  @override
  String get profileNameRMedium => 'Medium-bodied red';

  @override
  String get profileNameRAge => 'Red for ageing';

  @override
  String get profileNameRLong => 'Long-ageing red';

  @override
  String get profileNameWFresh => 'Fresh aromatic white';

  @override
  String get profileNameWMedium => 'Medium-bodied white';

  @override
  String get profileNameWAge => 'White for ageing';

  @override
  String get profileNameRoseFresh => 'Fresh rosé';

  @override
  String get profileNameSpTank => 'Fresh tank-method sparkling';

  @override
  String get profileNameLamFresh => 'Fresh Lambrusco';

  @override
  String get profileNameSpClassic => 'Fresh traditional-method sparkling';

  @override
  String get profileNameSpClassicAge =>
      'Traditional-method sparkling for ageing';

  @override
  String get profileNameSwAromatic => 'Young aromatic sweet wine';

  @override
  String get profileNameSwPassito => 'Dried-grape sweet wine';

  @override
  String get profileNameSwBotrytis => 'Botrytised sweet wine';

  @override
  String get profileNamePortVintage => 'Vintage Port';

  @override
  String get profileNamePortLbv => 'LBV/Ruby Port';

  @override
  String get profileNamePortOx => 'Tawny/Colheita Port';

  @override
  String get profileNameShFino => 'Fino/Manzanilla';

  @override
  String get profileNameShAmont => 'Amontillado/Medium';

  @override
  String get profileNameShOloroso => 'Oloroso/Cream';

  @override
  String get profileNameShPx => 'Pedro Ximénez Sherry';

  @override
  String get profileNameFortUnknown => 'Fortified, style unknown';

  @override
  String get profileNameUnknown => 'Style not identified';

  @override
  String estimateFromProfile(String profile, String denomination) {
    return 'Estimate from the $profile profile ($denomination)';
  }

  @override
  String estimateFromProfileType(String profile) {
    return 'Estimate from the $profile profile, by type';
  }

  @override
  String estimateFromProfileGrape(String profile, String grape) {
    return 'Estimate from the $profile profile, by the grape $grape';
  }

  @override
  String get estimateFromEntryDateDisgorgement =>
      'From the date added: add the disgorgement date for a better estimate';

  @override
  String get estimateFromEntryDateBottling =>
      'From the date added: add the bottling date for a better estimate';

  @override
  String get styleToConfirmBanner =>
      '⚠︎ Style to confirm: the estimate is indicative';

  @override
  String get chooseTypePrompt => 'Choose the type';

  @override
  String estimateUpdatedAnnouncement(String summary) {
    return 'Estimate updated: $summary';
  }

  @override
  String get agingStartDisgorgement => 'Disgorgement';

  @override
  String get agingStartBottling => 'Bottling';

  @override
  String get agingStartMonth => 'Month';

  @override
  String get agingStartYear => 'Year';

  @override
  String get agingStartHint => 'It is usually on the back label.';

  @override
  String get agingStartIncomplete => 'Enter month and year';

  @override
  String get agingStartFuture => 'The date cannot be in the future';

  @override
  String get agingStartBeforeVintage => 'It cannot be before the vintage';

  @override
  String get windowNoEnd => 'Ready, no end estimated';

  @override
  String get windowNoEndShort => 'no end estimated';

  @override
  String windowDrinkWithin(String date) {
    return 'by $date';
  }

  @override
  String get levelNoEffect => 'The level does not change this estimate';

  @override
  String get dashboardToConfirmTitle => 'To confirm';

  @override
  String dashboardToConfirmCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wines',
      one: '1 wine',
    );
    return '$_temp0';
  }

  @override
  String aboutDbClassified(String percent) {
    return '$percent% of the wines with a recognised type';
  }
}
