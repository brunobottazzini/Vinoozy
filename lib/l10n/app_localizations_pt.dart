// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

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
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

  @override
  String get appTitle => 'Vinoozy';

  @override
  String get signInTagline => 'Sua adega, no momento certo';

  @override
  String get signInWithGoogle => 'Continuar com o Google';

  @override
  String get signInInProgress => 'Entrando';

  @override
  String get signInFailed => 'Não foi possível entrar';

  @override
  String get signInNeedsNetwork => 'É preciso conexão para o primeiro acesso';

  @override
  String get signInSessionExpired => 'Sua sessão expirou: entre novamente';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get cancel => 'Cancelar';

  @override
  String blockedMessage(String email) {
    return 'Há alterações de $email ainda não salvas na nuvem: entre com essa conta e conecte-se à rede';
  }

  @override
  String blockedSignInWith(String email) {
    return 'Entrar com $email';
  }

  @override
  String blockedDiscard(String email) {
    return 'Excluir as alterações não salvas de $email';
  }

  @override
  String get discardDialogTitle => 'Excluir as alterações?';

  @override
  String discardDialogBody(int count, String email) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count vinhos de $email ainda não estão na nuvem e serão excluídos deste telefone.',
      one:
          '1 vinho de $email ainda não está na nuvem e será excluído deste telefone.',
    );
    return '$_temp0';
  }

  @override
  String get discardConfirm => 'Excluir';

  @override
  String get resetFailed => 'Não foi possível apagar os dados deste telefone';

  @override
  String get restartRequired => 'Reinicie o app para concluir';

  @override
  String get restartCloseApp => 'Fechar o app';

  @override
  String get startupFailed => 'Não foi possível iniciar o app';

  @override
  String get cellarTitle => 'Adega';

  @override
  String get defaultCellarName => 'Minha adega';

  @override
  String get cellarLoading => 'Preparando a adega';

  @override
  String get cellarSetupFailed => 'Não foi possível preparar a adega';

  @override
  String get cellarEmpty => 'Sua adega está vazia';

  @override
  String get addWine => 'Adicionar';

  @override
  String get estimatePending => 'Estimativa em breve';

  @override
  String get noVintage => 'Sem safra';

  @override
  String bottleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count garrafas',
      one: '1 garrafa',
    );
    return '$_temp0';
  }

  @override
  String get syncInProgress => 'Sincronizando';

  @override
  String get syncOffline => 'Offline - sincronização pendente';

  @override
  String writeRejected(String name) {
    return 'Alteração não permitida: $name';
  }

  @override
  String get saveFailed => 'Não foi possível salvar, tente novamente';

  @override
  String wineNotSaved(String name) {
    return 'O vinho $name não foi salvo na nuvem';
  }

  @override
  String get addAgain => 'Adicionar novamente';

  @override
  String get ignore => 'Ignorar';

  @override
  String get addWineTitle => 'Escrever';

  @override
  String get wineNameLabel => 'Vinho';

  @override
  String get vintageLabel => 'Safra';

  @override
  String get quantityLabel => 'Quantidade';

  @override
  String get decreaseQuantity => 'Diminuir quantidade';

  @override
  String get increaseQuantity => 'Aumentar quantidade';

  @override
  String get save => 'Salvar';

  @override
  String get nameRequired => 'Escreva o nome do vinho';

  @override
  String get nameTooLong => 'Máximo de 120 caracteres';

  @override
  String vintageRange(String year) {
    return 'Safra entre 1900 e $year';
  }

  @override
  String get offAttribution => 'Dados do Open Food Facts (ODbL)';

  @override
  String get dashboardTitle => 'Painel';

  @override
  String dashboardTotalBottles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count garrafas na adega',
      one: '1 garrafa na adega',
    );
    return '$_temp0';
  }

  @override
  String get dashboardSyncing => 'Sincronizando a adega…';

  @override
  String get dashboardAddFirstWine => 'Adicionar o primeiro vinho';

  @override
  String get drinkSoonTitle => 'Beber em breve';

  @override
  String get drinkSoonEmpty => 'Nenhuma garrafa perto do fim';

  @override
  String drinkSoonUntil(String year) {
    return 'até $year';
  }

  @override
  String drinkSoonSeeAll(int count) {
    return 'Ver todos ($count)';
  }

  @override
  String get statusChartTitle => 'Situação das garrafas';

  @override
  String get statusWaiting => 'aguardar';

  @override
  String get statusReady => 'prontas';

  @override
  String get statusDrinkSoon => 'beber em breve';

  @override
  String get statusPastWindow => 'fora da janela';

  @override
  String toEstimateNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count garrafas a estimar',
      one: '1 garrafa a estimar',
    );
    return '$_temp0';
  }

  @override
  String chartBarValue(String label, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count garrafas',
      one: '1 garrafa',
    );
    return '$label: $_temp0';
  }

  @override
  String chartDescription(String title, String values) {
    return '$title: $values';
  }

  @override
  String get openListHint => 'Abrir a lista';

  @override
  String get peakChartTitle => 'Ano do auge';

  @override
  String get peakPast => 'auge passado';

  @override
  String get peakBeyond => 'depois';

  @override
  String get breakdownTypeTitle => 'Garrafas por tipo';

  @override
  String get breakdownRegionTitle => 'Garrafas por região';

  @override
  String get breakdownType => 'Tipo';

  @override
  String get breakdownRegion => 'Região';

  @override
  String get familyRed => 'tinto';

  @override
  String get familyWhite => 'branco';

  @override
  String get familyRose => 'rosé';

  @override
  String get familySparkling => 'espumante';

  @override
  String get familySweet => 'doce';

  @override
  String get breakdownUnspecified => 'não informado';

  @override
  String get breakdownOtherRegions => 'outras';

  @override
  String get ok => 'OK';

  @override
  String get cellarMenu => 'Menu da adega';

  @override
  String get sharingPeopleTitle => 'Pessoas';

  @override
  String get sharingInviteTitle => 'Convidar uma pessoa';

  @override
  String get sharingEmailLabel => 'Endereço de e-mail do Google';

  @override
  String get sharingPermissionRead => 'Somente leitura';

  @override
  String get sharingPermissionReadHint =>
      'Vê vinhos, estimativas, painel e consumos';

  @override
  String get sharingPermissionEdit => 'Pode editar';

  @override
  String get sharingPermissionEditHint =>
      'Também adiciona e altera vinhos e registra consumos';

  @override
  String get sharingRoleOwner => 'proprietário';

  @override
  String get sharingInviteButton => 'Convidar';

  @override
  String sharingPlacesUsed(int used, int max) {
    return '$used/$max pessoas';
  }

  @override
  String get sharingInvalidEmail => 'Digite um e-mail válido';

  @override
  String get sharingSelfInvite => 'Você não pode convidar a si mesmo';

  @override
  String get sharingAlreadyInvited => 'Esta pessoa já foi convidada';

  @override
  String sharingLimitReached(int max) {
    return 'Você atingiu o limite de $max pessoas';
  }

  @override
  String get sharingNotOwner =>
      'Você não pode alterar o compartilhamento desta adega';

  @override
  String get sharingNotFound => 'Esta pessoa não está mais na lista';

  @override
  String get sharingFailed => 'Não foi possível concluir, tente novamente';

  @override
  String get sharingInviteFailed => 'Convite não enviado. Tente novamente';

  @override
  String get sharingOfflineHint =>
      'É preciso conexão para gerenciar o compartilhamento';

  @override
  String get sharingStatusInvited => 'convidada';

  @override
  String get sharingStatusActive => 'ativa';

  @override
  String get sharingStatusRevoked => 'revogada';

  @override
  String get sharingStatusLeft => 'saiu';

  @override
  String sharingMemberSemantics(String name, String permission, String status) {
    return '$name, $permission, $status';
  }

  @override
  String get sharingClosedSection => 'Acessos encerrados';

  @override
  String get sharingNobody => 'Ninguém mais vê esta adega ainda';

  @override
  String sharingChangePermission(String name) {
    return 'Alterar a permissão de $name';
  }

  @override
  String get sharingRevoke => 'Revogar';

  @override
  String sharingRevokeTitle(String name) {
    return 'Revogar o acesso de $name?';
  }

  @override
  String sharingRevokeConfirmLabel(String name) {
    return 'Digite $name para confirmar';
  }

  @override
  String get sharingRevokeDisabledHint => 'Ativado quando o nome coincidir';

  @override
  String get sharingReinvite => 'Convidar novamente';

  @override
  String get sharingDeleteForGood => 'Excluir definitivamente';

  @override
  String sharingOwnedBy(String owner) {
    return 'Adega de $owner';
  }

  @override
  String get sharingYourCellar => 'Sua adega';

  @override
  String sharingYourPermission(String permission) {
    return 'Sua permissão: $permission';
  }

  @override
  String sharingSwitcherSemantics(String cellar, String permission) {
    return '$cellar, $permission. Toque para trocar de adega';
  }

  @override
  String get sharingLeave => 'Sair desta adega';

  @override
  String sharingLeaveTitle(String owner) {
    return 'Sair da adega de $owner?';
  }

  @override
  String sharingLeaveBody(String owner) {
    return 'Você não a verá mais. $owner poderá convidar você novamente.';
  }

  @override
  String get sharingLeaveConfirm => 'Sair';

  @override
  String sharingSharedNotice(String owner) {
    return '$owner compartilhou a adega com você';
  }

  @override
  String sharingAccessLost(String owner) {
    return 'Você não tem mais acesso à adega de $owner';
  }

  @override
  String sharingWritesLost(String owner) {
    return 'Algumas alterações na adega de $owner não foram salvas porque você não tem mais acesso';
  }

  @override
  String get sharingSomeone => 'alguém';

  @override
  String get sharingShareSubject => 'Convite para o Vinoozy';

  @override
  String sharingShareMessage(
    String owner,
    String cellar,
    String link,
    String email,
  ) {
    return '$owner convidou você para a adega \"$cellar\" no Vinoozy. Instale o app em $link e entre com a conta Google $email: use exatamente este endereço.';
  }

  @override
  String get cellarSearchHint => 'Buscar por nome ou produtor';

  @override
  String get cellarFilterStatus => 'Estado';

  @override
  String get cellarFilterType => 'Tipo';

  @override
  String get statusToEstimate => 'A estimar';

  @override
  String get filterTypeUnspecified => 'Não informado';

  @override
  String get cellarNoMatches => 'Nenhum vinho com estes filtros';

  @override
  String get cellarClearFilters => 'Limpar filtros';

  @override
  String get cellarArchiveTitle => 'Bebidos';

  @override
  String get cellarArchiveEmpty => 'Nenhum vinho terminado ainda';

  @override
  String get cellarArchiveFailed =>
      'Não foi possível carregar os vinhos terminados';

  @override
  String get wineDrink => 'Bebida';

  @override
  String wineDrinkTooltip(String name) {
    return 'Marcar uma garrafa de $name como bebida';
  }

  @override
  String confidenceLabel(String level) {
    return 'Confiança: $level';
  }

  @override
  String get confidenceHigh => 'alta';

  @override
  String get confidenceMedium => 'média';

  @override
  String get confidenceLow => 'baixa';

  @override
  String get windowStartLabel => 'Início';

  @override
  String get windowPeakLabel => 'Pico';

  @override
  String get windowEndLabel => 'Fim';

  @override
  String estimateSourceLabel(String source) {
    return 'Fonte: $source';
  }

  @override
  String get estimateSourceCatalog => 'base de dados de vinhos';

  @override
  String get estimateSourceType => 'estimativa por tipo';

  @override
  String get estimateSourceCorrected =>
      'estimativa corrigida pelas suas degustações';

  @override
  String get estimateDisclaimer =>
      'Estimativa indicativa: depende também de como a garrafa foi guardada';

  @override
  String get estimateUnavailable => 'Estimativa indisponível';

  @override
  String get pairingsTitle => 'Harmonizações';

  @override
  String get pairingsGeneric => 'harmonizações genéricas para o tipo';

  @override
  String get pairingBraisedRedMeat => 'Carne vermelha ensopada';

  @override
  String get pairingGrilledRedMeat => 'Carne vermelha grelhada';

  @override
  String get pairingGame => 'Caça';

  @override
  String get pairingRoastPoultry => 'Aves assadas';

  @override
  String get pairingPoultry => 'Aves';

  @override
  String get pairingPork => 'Carne de porco';

  @override
  String get pairingCuredMeats => 'Frios e embutidos';

  @override
  String get pairingPastaMeatSauce => 'Massa ao ragu';

  @override
  String get pairingMushroomsTruffle => 'Cogumelos e trufas';

  @override
  String get pairingAgedCheese => 'Queijos curados';

  @override
  String get pairingFreshCheese => 'Queijos frescos';

  @override
  String get pairingBlueCheese => 'Queijos azuis';

  @override
  String get pairingFish => 'Peixe';

  @override
  String get pairingSeafood => 'Frutos do mar';

  @override
  String get pairingRawSeafood => 'Frutos do mar crus';

  @override
  String get pairingFriedFood => 'Frituras';

  @override
  String get pairingVegetables => 'Legumes';

  @override
  String get pairingRisotto => 'Risoto';

  @override
  String get pairingPizza => 'Pizza';

  @override
  String get pairingAperitif => 'Aperitivo';

  @override
  String get pairingPastries => 'Confeitaria';

  @override
  String get pairingDryBiscuits => 'Biscoitos secos';

  @override
  String get pairingChocolate => 'Chocolate';

  @override
  String get pairingDriedFruit => 'Frutas secas';

  @override
  String get pairingSpicyDishes => 'Pratos condimentados';

  @override
  String get recentDrinksTitle => 'Últimas degustações';

  @override
  String get noDrinksYet => 'Nenhuma degustação ainda';

  @override
  String get wineEdit => 'Editar';

  @override
  String get wineDelete => 'Excluir';

  @override
  String get wineFinished => 'Terminado: nenhuma garrafa';

  @override
  String get wineLoadFailed => 'Não foi possível abrir o vinho';

  @override
  String get wineNotFound => 'Este vinho não existe mais';

  @override
  String drinkDone(String name) {
    return 'Degustação registrada: $name';
  }

  @override
  String get drinkUndo => 'Desfazer';

  @override
  String get drinkAddNotes => 'Adicionar nota e comentários';

  @override
  String get nothingToUndo => 'Não há mais nada para desfazer';

  @override
  String get cellarUndoRejected =>
      'Desfazer falhou: a garrafa continua marcada como bebida';

  @override
  String get cellarDeleteFailed =>
      'A exclusão ainda não foi concluída: continuará assim que possível';

  @override
  String get duplicateFull =>
      'Este vinho já tem 99 garrafas: não é possível adicionar mais.';

  @override
  String get recordSheetTitle => 'Nota e comentários';

  @override
  String get recordRatingLabel => 'Nota';

  @override
  String ratingStar(int n) {
    return 'Nota $n de 5';
  }

  @override
  String get recordNotesLabel => 'Comentários';

  @override
  String get recordNotesTooLong => 'No máximo 1000 caracteres';

  @override
  String recordDateLabel(String date) {
    return 'Data: $date';
  }

  @override
  String get recordDateInvalid =>
      'A data não pode ser futura nem anterior à safra';

  @override
  String get recordConditionTitle => 'Como estava?';

  @override
  String get conditionTooYoung => 'Ainda muito jovem';

  @override
  String get conditionJustRight => 'No ponto certo';

  @override
  String get conditionPastPeak => 'Já em declínio';

  @override
  String get recordNoCondition => 'Sem resposta';

  @override
  String get producerLabel => 'Produtor (opcional)';

  @override
  String get producerTooLong => 'No máximo 120 caracteres';

  @override
  String producerAddNew(String name) {
    return 'Adicionar «$name» como novo produtor';
  }

  @override
  String get wineTypeLabel => 'Tipo';

  @override
  String get typeRedLight => 'Tinto leve';

  @override
  String get typeRedStructured => 'Tinto encorpado';

  @override
  String get typeWhite => 'Branco';

  @override
  String get typeRose => 'Rosé';

  @override
  String get typeSparklingClassic => 'Espumante método clássico';

  @override
  String get typeSparklingTank => 'Espumante método Charmat';

  @override
  String get typeSweet => 'Doce';

  @override
  String get typeFortified => 'Fortificado';

  @override
  String get suggestionFromCellar => 'Na sua adega';

  @override
  String get suggestionsLabel => 'Sugestões';

  @override
  String get duplicateTitle => 'Já está na adega';

  @override
  String duplicateBody(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count garrafas',
      one: '1 garrafa',
      zero: 'nenhuma garrafa',
    );
    return '$name já está lá, com $_temp0. Adicionar as novas garrafas a ele?';
  }

  @override
  String duplicateAdd(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Adicionar $count garrafas',
      one: 'Adicionar 1 garrafa',
    );
    return '$_temp0';
  }

  @override
  String get duplicateBanner => 'Possível duplicado';

  @override
  String get duplicateMerge => 'Mesclar';

  @override
  String get duplicateDeleteHint => 'Exclua esta entrada se for um duplicado';

  @override
  String get mergeTitle => 'Mesclar as duas entradas?';

  @override
  String get mergeBody =>
      'As garrafas desta entrada passam para a mais antiga, depois esta entrada é excluída.';

  @override
  String get editWineTitle => 'Editar vinho';

  @override
  String get editDuplicate =>
      'Já existe outro vinho com o mesmo nome, produtor e safra';

  @override
  String deleteWineTitle(String name) {
    return 'Excluir $name?';
  }

  @override
  String get deleteWineBody =>
      'O vinho e todas as suas degustações são excluídos. Não é possível desfazer.';

  @override
  String get historyTitle => 'Histórico';

  @override
  String get historyEmpty => 'Aqui você encontrará as garrafas que bebeu';

  @override
  String get historyLoadFailed => 'Não foi possível carregar o histórico';

  @override
  String drankOnLabel(String date) {
    return 'Bebida em $date';
  }

  @override
  String get addChoiceTitle => 'Adicionar um vinho';

  @override
  String get addChoicePhoto => 'Tirar foto';

  @override
  String get addChoiceImport => 'Importar uma foto';

  @override
  String get addChoiceWrite => 'Escrever';

  @override
  String get labelReading => 'Lendo o rótulo…';

  @override
  String get labelRecognized => 'Reconheci:';

  @override
  String get labelCorrect => 'Corrigir';

  @override
  String get labelConfirm => 'Confirmar';

  @override
  String get labelUnreadable => 'Não consigo ler o rótulo';

  @override
  String get labelWriteByHand => 'Escrever à mão';

  @override
  String get labelNotFound => 'Não encontrei o vinho: confira os dados';

  @override
  String get labelCameraDenied =>
      'Para ler o rótulo preciso de acesso à câmera';

  @override
  String get labelPhotosDenied =>
      'Para ler o rótulo preciso de acesso às fotos';

  @override
  String get labelOpenSettings => 'Abrir configurações';

  @override
  String get labelCameraUnavailable => 'Câmera indisponível';

  @override
  String get labelBarcodeNotFound =>
      'Li o código de barras, mas não encontro o vinho';

  @override
  String get labelBarcodeFrontHint => 'Fotografe a frente do rótulo';

  @override
  String get labelSharedNotAllowed =>
      'Você não pode adicionar vinhos a esta adega';

  @override
  String get labelSharedFirstOnly => 'Usei só a primeira foto';

  @override
  String get labelSharedExpired =>
      'Não foi possível ler a foto compartilhada: compartilhe de novo';

  @override
  String get labelReplaceTitle =>
      'Você tem um vinho não salvo. Quer ler a nova foto?';

  @override
  String get labelReplaceRead => 'Ler a nova foto';

  @override
  String get labelReplaceKeep => 'Continuar com o aberto';

  @override
  String get labelWineAdded => 'Vinho adicionado à adega';

  @override
  String get onboardingPage1Title => 'Sua adega no bolso';

  @override
  String get onboardingPage1Body =>
      'Adicione as garrafas digitando ou com uma foto do rótulo, mesmo sem internet.';

  @override
  String get onboardingPage2Title => 'No momento certo';

  @override
  String get onboardingPage2Body =>
      'O Vinoozy estima quando cada vinho está no auge e diz quais abrir primeiro.';

  @override
  String get onboardingPage3Title => 'Juntos';

  @override
  String get onboardingPage3Body =>
      'Compartilhe a adega com até duas pessoas e guarde o histórico de cada garrafa bebida.';

  @override
  String get onboardingSkip => 'Pular';

  @override
  String get onboardingNext => 'Avançar';

  @override
  String get onboardingStart => 'Começar';

  @override
  String onboardingPageOf(int page) {
    return 'Página $page de 3';
  }

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profilePhoto => 'Foto do perfil';

  @override
  String get profileSignOut => 'Sair';

  @override
  String get profileDeleteAccount => 'Excluir conta';

  @override
  String get profilePrivacy => 'Política de privacidade';

  @override
  String get profilePrivacyBody =>
      'Você pode ler a política de privacidade neste endereço:';

  @override
  String get profileCopyLink => 'Copiar link';

  @override
  String get profileLinkCopied => 'Link copiado';

  @override
  String get close => 'Fechar';

  @override
  String get signOutConfirmTitle => 'Quer sair?';

  @override
  String signOutPendingWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Você tem $count alterações ainda não salvas. Se sair e outra conta entrar, elas serão perdidas.',
      one: 'Você tem 1 alteração ainda não salva. Se sair e outra conta entrar, ela será perdida.',
    );
    return '$_temp0';
  }

  @override
  String get signOutStayAndSync => 'Ficar e sincronizar';

  @override
  String get signOutAnyway => 'Sair mesmo assim';

  @override
  String get syncAllSaved => 'Tudo salvo';

  @override
  String syncStillPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ainda $count alterações para salvar: verifique a internet',
      one: 'Ainda 1 alteração para salvar: verifique a internet',
    );
    return '$_temp0';
  }

  @override
  String get signOutFailed => 'Não foi possível sair. Tente novamente';

  @override
  String get signInAccountDeleted => 'Conta excluída';

  @override
  String get deleteAccountIntro => 'Serão excluídos para sempre:';

  @override
  String get deleteAccountItemCellar =>
      'Sua adega, com os vinhos e o Histórico';

  @override
  String get deleteAccountItemShares =>
      'Os compartilhamentos que você deu: as pessoas convidadas perdem o acesso';

  @override
  String get deleteAccountItemMemberships =>
      'Sua participação nas adegas de outras pessoas: suas degustações ficam lá sem o seu nome';

  @override
  String get deleteAccountItemProfile => 'Seu perfil';

  @override
  String deleteAccountPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Você tem $count alterações ainda não salvas: elas serão salvas e depois excluídas com o resto',
      one: 'Você tem 1 alteração ainda não salva: ela será salva e depois excluída com o resto',
    );
    return '$_temp0';
  }

  @override
  String get deleteAccountConfirmWord => 'EXCLUIR';

  @override
  String deleteAccountTypeWord(String word) {
    return 'Digite $word para confirmar';
  }

  @override
  String get deleteAccountReauthHint =>
      'Depois você vai entrar de novo com o Google para confirmar que é você.';

  @override
  String get deleteAccountForever => 'Excluir para sempre';

  @override
  String get deleteAccountNeedsNetwork =>
      'Conecte-se à internet para excluir a conta';

  @override
  String get deleteAccountSameAccount =>
      'A exclusão exige entrar com a mesma conta';

  @override
  String get deletionTitle => 'Excluindo a conta';

  @override
  String get deletionStepPreparePhone => 'Salvando as alterações pendentes';

  @override
  String get deletionStepMarkStarted => 'Iniciando a exclusão';

  @override
  String get deletionStepLeaveOtherCellars =>
      'Saindo das adegas de outras pessoas';

  @override
  String get deletionStepCloseOwnInvitations =>
      'Encerrando seus compartilhamentos';

  @override
  String get deletionStepDeleteWinesAndRecords =>
      'Excluindo vinhos e Histórico';

  @override
  String get deletionStepDeleteCellar => 'Excluindo a adega';

  @override
  String get deletionStepDeleteProfileAndUser => 'Excluindo o perfil e a conta';

  @override
  String get deletionStepCleanUpPhone => 'Limpando este celular';

  @override
  String deletionStepAnnounce(int step, String label) {
    return 'Passo $step de 8: $label';
  }

  @override
  String deletionDeletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vinhos e degustações excluídos',
      one: '1 vinho ou degustação excluído',
    );
    return '$_temp0';
  }

  @override
  String get deletionResumeHint =>
      'A exclusão desta conta não terminou. Entre de novo com o Google para concluí-la.';

  @override
  String get deletionContinue => 'Continuar';

  @override
  String get deletionOffline =>
      'Conecte-se à internet para concluir a exclusão';

  @override
  String get deletionPendingWrites =>
      'Não consigo salvar as alterações pendentes. Tente novamente';

  @override
  String get deletionFailed =>
      'Não foi possível concluir a exclusão. Tente novamente';

  @override
  String get uxCountryLabel => 'País';

  @override
  String get uxCountryOther => 'Outro país…';

  @override
  String get uxCountryNone => 'Nenhum país';

  @override
  String get uxAllCountriesTitle => 'Todos os países e territórios';

  @override
  String get uxAllCountriesSearch => 'Buscar um país';

  @override
  String get uxAllCountriesRare => 'Raros para o vinho';

  @override
  String get uxAllCountriesAll => 'Todos, de A a Z';

  @override
  String get uxAllCountriesNone => 'Nenhum país encontrado';

  @override
  String get uxRegionLabel => 'Região';

  @override
  String uxRegionOf(String country) {
    return 'Região · $country';
  }

  @override
  String get uxRegionOther => 'Outra região';

  @override
  String get uxRegionFieldLabel => 'Escreva a região';

  @override
  String get uxRegionTooLong => 'No máximo 120 caracteres';

  @override
  String get uxDrinkAction => 'Bebi uma';

  @override
  String uxDrinkActionTooltip(String name) {
    return 'Bebi uma garrafa de $name';
  }

  @override
  String get uxDrinkActionDetail => 'Bebi uma garrafa';

  @override
  String get uxDrinkSheetLabel => 'Confirmar o consumo';

  @override
  String get uxDrinkSheetBottles => 'Garrafas';

  @override
  String uxDrinkSheetBottlesChange(int before, int after) {
    return 'Garrafas: de $before para $after';
  }

  @override
  String get uxDrinkSheetRating => 'Como estava? (opcional)';

  @override
  String uxDrinkSheetStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count estrelas de 5',
      one: '1 estrela de 5',
    );
    return '$_temp0';
  }

  @override
  String get uxDrinkSheetConfirm => 'Sim, eu bebi';

  @override
  String get uxRemoveBottle => 'Tirar uma garrafa sem registrar consumo';

  @override
  String get uxRemoveBottleTitle => 'Tirar uma garrafa?';

  @override
  String uxRemoveBottleBody(String name) {
    return 'Uma garrafa de $name é retirada sem registrar um consumo.';
  }

  @override
  String get uxRemoveBottleConfirm => 'Tirar';

  @override
  String get uxIdealTitle => 'Momento ideal';

  @override
  String uxIdealUntil(String year) {
    return 'Recomendado até $year';
  }

  @override
  String uxIdealUntilPast(String year) {
    return 'Recomendado até $year: já passou';
  }

  @override
  String uxIdealBest(String start, String end) {
    return 'No seu melhor de $start a $end';
  }

  @override
  String uxIdealBar(String start, String end) {
    return 'Janela de consumo de $start a $end';
  }

  @override
  String get uxIdealDisclaimer =>
      '⚠︎ Indicativo: é uma estimativa baseada em tipo, denominação e safra. A conservação e cada garrafa podem mudá-la.';

  @override
  String get uxIdealUnavailableHint =>
      'Informe a safra e o tipo para ter uma estimativa.';

  @override
  String uxDashboardDrinkNow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count para beber agora',
      one: '1 para beber agora',
    );
    return '$_temp0';
  }

  @override
  String get uxFamilyRed => 'Tinto';

  @override
  String get uxFamilyWhite => 'Branco';

  @override
  String get uxFamilyRose => 'Rosé';

  @override
  String get uxFamilySparkling => 'Espumante';

  @override
  String get uxFamilySweet => 'Doce';

  @override
  String get labelBackTitle => 'Agora o verso';

  @override
  String get labelBackHint =>
      'No verso geralmente estão o código de barras, o produtor e a safra: ajudam a encontrar o vinho.';

  @override
  String get labelBackTake => 'Fotografar o verso';

  @override
  String get labelBackGallery => 'Escolher da galeria';

  @override
  String get labelBackSkip => 'Pular';

  @override
  String get labelStepFront => 'Frente';

  @override
  String get labelStepBack => 'Verso';

  @override
  String get labelStepBarcode => 'Código de barras';

  @override
  String get labelStepDatabase => 'Base de vinhos no celular';

  @override
  String get labelStepPending => 'Aguardando';

  @override
  String get labelStepRunning => 'Em andamento…';

  @override
  String get labelStepDone => 'Pronto';

  @override
  String get labelStepSkipped => 'Pulado';

  @override
  String get labelStepFailed => 'Ilegível';

  @override
  String labelStepStatus(String step, String status) {
    return '$step: $status';
  }

  @override
  String get labelOnPhoneNote =>
      'Tudo acontece no celular: as fotos não são enviadas a ninguém.';

  @override
  String get labelBackUnreadable => 'Verso ilegível';

  @override
  String get labelSourceOffline => 'Da base no celular · offline';

  @override
  String get labelSourceCatalog => 'Do catálogo';

  @override
  String get labelSourceOnline => 'Do Open Food Facts · online';

  @override
  String get labelNotThis => 'Não é este';

  @override
  String get labelOffAttribution => 'Dados do Open Food Facts, licença ODbL';

  @override
  String get labelCandidatesTitle => 'Qual destes?';

  @override
  String labelCandidatesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vinhos parecidos',
      one: '1 vinho parecido',
    );
    return '$_temp0';
  }

  @override
  String get labelCandidatesNone => 'Nenhum destes';

  @override
  String get labelChipOffline => 'offline';

  @override
  String get labelChipOnline => 'online';

  @override
  String get labelChipCatalog => 'catálogo';

  @override
  String get labelNoProducer => 'produtor não informado';

  @override
  String get labelNoMatch => 'Li o rótulo, mas não reconheço o vinho';

  @override
  String get labelReadText => 'Texto lido';

  @override
  String get labelSearchOnline => 'Buscar online';

  @override
  String get labelOpenLens => 'Abrir no Google Lens';

  @override
  String get labelLensLastResort =>
      'O Google Lens é a última opção: a foto vai para o app Google só se você confirmar.';

  @override
  String get labelLensTitle => 'Abrir no Google Lens?';

  @override
  String get labelLensBody =>
      'A foto da frente vai para o app Google no seu celular, ou para o app que você escolher, que pode guardar uma cópia segundo as regras dele. O Vinoozy não recebe os resultados: volte aqui para escolher ou escrever o vinho.';

  @override
  String get labelLensConfirm => 'Abrir o Google Lens';

  @override
  String get labelLensFailed =>
      'Não foi possível abrir o Google Lens nem o menu Compartilhar';

  @override
  String get onlineSearchTitle => 'Buscar online';

  @override
  String get onlineSearchSubtitle => 'Open Food Facts · só vinhos';

  @override
  String get onlineSearchField => 'Palavras para buscar';

  @override
  String get onlineSearchHint => 'Você pode mudar as palavras antes de buscar.';

  @override
  String get onlineSearchEmptyField => 'Escreva pelo menos uma palavra';

  @override
  String get onlineSearchButton => 'Buscar';

  @override
  String get onlineSearchLoading => 'Buscando…';

  @override
  String onlineSearchResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count resultados',
      one: '1 resultado',
    );
    return '$_temp0';
  }

  @override
  String get onlineSearchEmpty =>
      'Nenhum vinho encontrado: tente outras palavras ou \"Escrever à mão\".';

  @override
  String get onlineSearchOffline => 'Sem rede: busco só na base do celular.';

  @override
  String get onlineSearchRateLimited =>
      'A busca online não está disponível agora, tente de novo em alguns minutos.';

  @override
  String get onlineSearchUnavailable =>
      'A busca online não está ativa nesta versão do app: busco só na base do celular.';

  @override
  String get aboutTitle => 'Sobre';

  @override
  String aboutVersion(String version) {
    return 'Versão $version';
  }

  @override
  String get aboutDbTitle => 'Base de vinhos';

  @override
  String aboutDbCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vinhos',
      one: '1 vinho',
    );
    return '$_temp0';
  }

  @override
  String aboutDbDate(String date) {
    return 'Exportação do Open Food Facts de $date';
  }

  @override
  String get aboutDbSample =>
      'Base de teste: poucos vinhos de teste escritos à mão, não dados do Open Food Facts.';

  @override
  String get aboutDbLoading => 'Abrindo a base de vinhos…';

  @override
  String get aboutDbUnavailable =>
      'A base de vinhos não está disponível nesta versão';

  @override
  String aboutDbSource(String url) {
    return 'A base derivada e a ferramenta que a gera estão no repositório público: $url';
  }

  @override
  String get aboutLicenseTitle => 'Licenças';

  @override
  String get aboutLicense =>
      'Contém informações do Open Food Facts, disponibilizadas sob a Open Database License (ODbL). Os conteúdos individuais estão sob a Database Contents License (DbCL).';

  @override
  String get aboutPrivacyTitle => 'Fotos dos rótulos';

  @override
  String get aboutPrivacy =>
      'As fotos dos rótulos são lidas no celular e apagadas quando você sai do resultado. Só saem do celular se você tocar em \"Abrir no Google Lens\" e confirmar.';

  @override
  String get aboutAppellationsTitle => 'Denominações';

  @override
  String get aboutAppellationsSource =>
      'Denominações: registro eAmbrosia (UE) e registros oficiais nacionais.';

  @override
  String get aboutAppellationsSample =>
      'Tabela de teste: um extrato dos registros escrito à mão, até baixar os registros reais.';

  @override
  String get denominationLabel => 'Denominação';

  @override
  String get denominationTooLong => 'No máximo 120 caracteres';

  @override
  String get autofillFilledNotice => 'Preenchido pelo rótulo: confira e salve';

  @override
  String get autofillPastedNotice => 'Preenchido pelo texto: confira e salve';

  @override
  String get autofillFromText => '✦ do texto';

  @override
  String get autofillFromTextSemantics => 'preenchido pelo rótulo';

  @override
  String get autofillClear => 'Limpar';

  @override
  String get autofillLens => 'Lens';

  @override
  String get autofillClearTitle => 'Limpar o formulário?';

  @override
  String get autofillClearBody =>
      'Você também escreveu em alguns campos. \"Limpar\" esvazia nome, produtor, denominação, safra, tipo, país, região e nível. A quantidade fica.';

  @override
  String get autofillClearConfirm => 'Limpar';

  @override
  String get autofillCleared => 'Formulário limpo';

  @override
  String get autofillPasteTitle => 'Você tem o texto do Google Lens?';

  @override
  String get autofillPasteHint =>
      'No Lens selecione o texto do rótulo e toque em \"Copiar\", depois volte aqui.';

  @override
  String get autofillPaste => 'Colar do Lens';

  @override
  String get autofillOpenLens => 'Do Google Lens';

  @override
  String get autofillOpenLensSemantics => 'abre o Google Lens';

  @override
  String get autofillClipboardEmpty => 'Não há texto na área de transferência';

  @override
  String get autofillNoNewFields =>
      'Não encontrei dados para adicionar no texto';

  @override
  String get autofillFromLens => 'Formulário preenchido com o texto do Lens';

  @override
  String get autofillShareEmpty => 'Nenhum texto recebido';

  @override
  String get autofillShareUseTitle => 'Usar o texto nos campos vazios?';

  @override
  String get autofillShareUse => 'Usar';

  @override
  String get autofillShareIgnore => 'Ignorar';

  @override
  String get addChoiceLens => 'Do Google Lens';

  @override
  String get addChoicePhotoHint => 'Frente e verso: o Vinoozy lê o rótulo.';

  @override
  String get addChoiceLensHint =>
      'Abre o Lens: enquadre, selecione o texto e toque em Compartilhar → Vinoozy.';

  @override
  String get addChoiceImportHint => 'Uma foto do rótulo já tirada.';

  @override
  String get addChoiceWriteHint => 'Formulário vazio, com \"Colar do Lens\".';

  @override
  String get lensInstructionsTitle => 'Daqui o Google Lens não abre';

  @override
  String get lensInstructionsStep1 => 'Abra o Google Lens e enquadre o rótulo';

  @override
  String get lensInstructionsStep2 => 'Selecione o texto do rótulo';

  @override
  String get lensInstructionsStep3 => 'Toque em Compartilhar → Vinoozy';

  @override
  String get lensInstructionsOk => 'Entendi';

  @override
  String get levelLabel => 'Nível';

  @override
  String get levelEveryday => 'Cotidiano (econômico)';

  @override
  String get levelGood => 'Bom';

  @override
  String get levelAging => 'Para envelhecer';

  @override
  String get levelNone => 'Nenhum';

  @override
  String get levelEverydayShort => 'beber cedo';

  @override
  String get levelGoodShort => 'estimativa normal';

  @override
  String get levelAgingShort => 'dura mais';

  @override
  String get levelSuggested => 'sugerido';

  @override
  String levelSuggestedReason(String qualifier) {
    return 'Sugerido porque o nome contém \"$qualifier\": é salvo assim se você não mudar. Escolha outro ou toque em \"Nenhum\".';
  }

  @override
  String levelSuggestedSemantics(String qualifier) {
    return 'sugerido, porque o nome contém $qualifier';
  }

  @override
  String levelOptionSemantics(String option, int index, int count) {
    return 'Nível, $option, $index de $count';
  }

  @override
  String get levelWhatChanges => 'O que muda';

  @override
  String get levelEverydayExamples =>
      'A janela fica mais curta. Ex. vinho da casa, Lambrusco, Prosecco básico, Bardolino, Vinho Verde.';

  @override
  String get levelGoodExamples =>
      'A estimativa normal, e o valor se você não escolher nada. Ex. Chianti Classico, Barbera d\'Asti Superiore, Rioja Crianza, Côtes du Rhône.';

  @override
  String get levelAgingExamples =>
      'A janela fica mais longa. Ex. Barolo, Brunello, Amarone, Bordeaux Grand Cru, Rioja Gran Reserva, Porto Vintage.';

  @override
  String levelPreviewBefore(String start, String end) {
    return 'Antes $start – $end';
  }

  @override
  String levelPreviewWith(String level, String start, String end) {
    return 'Com \"$level\" $start – $end';
  }

  @override
  String levelPreviewNow(String start, String end) {
    return 'Pronto $start – até $end';
  }

  @override
  String levelDetail(String level) {
    return 'Nível: $level';
  }

  @override
  String get overrideCorrect => 'Corrigir';

  @override
  String get overrideRestore => 'Restaurar estimativa';

  @override
  String get overrideCorrectedByYou => 'corrigido por você';

  @override
  String overrideAppEstimate(String year) {
    return 'Estimativa do app: até $year';
  }

  @override
  String get overrideSheetTitle => 'Recomendado até';

  @override
  String overrideSheetHint(String start) {
    return 'Escolha o ano. Não pode ser antes de \"Pronto a partir de $start\".';
  }

  @override
  String overridePeakNotice(String peak) {
    return 'Se você escolher um ano antes de $peak (no auge), \"no auge\" também passa para o mesmo ano.';
  }

  @override
  String get overrideMore => 'mais…';

  @override
  String get overrideSave => 'Salvar correção';

  @override
  String overrideRestoreTitle(String year) {
    return 'Voltar para a estimativa do app (até $year)?';
  }

  @override
  String get overrideRestoreConfirm => 'Restaurar';

  @override
  String get overrideSaved => 'Correção salva';

  @override
  String get overrideRestored => 'Estimativa restaurada';

  @override
  String get estimateSourceCorrectedByYou => 'corrigida por você';

  @override
  String estimateFromDenomination(String name) {
    return 'Estimativa pela denominação $name';
  }

  @override
  String estimateFromDenominationQualifier(String name, String qualifier) {
    return 'Estimativa pela denominação $name, $qualifier';
  }

  @override
  String estimateFromGrape(String name) {
    return 'Estimativa pela uva $name';
  }

  @override
  String get estimateFromType => 'Estimativa pelo tipo de vinho';

  @override
  String get autofillReading => 'Lendo o texto…';

  @override
  String get guideChip => 'Confirmação guiada';

  @override
  String guideProgress(int n, int total) {
    return 'Pergunta $n de $total';
  }

  @override
  String get guideClose => 'Fechar';

  @override
  String get guideIsDenomination => 'é a denominação?';

  @override
  String get guideIsProducer => 'é o produtor?';

  @override
  String get guideIsName => 'é o nome do vinho?';

  @override
  String get guideIsVintage => 'Safra';

  @override
  String guideAskDenomination(String value) {
    return '$value é a denominação?';
  }

  @override
  String guideAskProducer(String value) {
    return '$value é o produtor?';
  }

  @override
  String guideAskName(String value) {
    return '$value é o nome do vinho?';
  }

  @override
  String get guideAskVintage => 'Qual é a safra?';

  @override
  String guideQuestionSemantics(int n, int total, String question) {
    return 'Pergunta $n de $total: $question';
  }

  @override
  String get guideNoProposal => 'Não encontrei no texto';

  @override
  String get guideYes => 'Sim';

  @override
  String get guideNo => 'Não, outra';

  @override
  String get guideEdit => 'Editar';

  @override
  String get guideSkip => 'Pular';

  @override
  String get guideConfirm => 'Confirmar';

  @override
  String get guideCancel => 'Cancelar';

  @override
  String guideRejected(String value) {
    return '\"$value\" não: aqui está o próximo';
  }

  @override
  String get guideNoMore => 'Nenhuma outra sugestão: componha ou pule';

  @override
  String guideProposalAnnounce(String value) {
    return 'Sugestão: $value';
  }

  @override
  String get guideComposeLabel => 'Ou monte tocando as palavras do texto';

  @override
  String get guideComposePreview => 'Prévia';

  @override
  String get guideComposeEmpty => 'Toque em uma ou mais palavras';

  @override
  String get guideComposeLimit => 'No máximo 8 palavras e 80 caracteres';

  @override
  String guideTableMatchSemantics(String name) {
    return 'corresponde a $name';
  }

  @override
  String guideLine(int n, int total) {
    return 'Linha $n de $total';
  }

  @override
  String guideWordSelected(String word, int order) {
    return '$word, selecionada, $order';
  }

  @override
  String guideWordUnavailable(String word) {
    return '$word, indisponível';
  }

  @override
  String guideWordUsedFor(String word, String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'na denominação',
      'producer': 'no produtor',
      'other': 'no nome',
    });
    return '$word, usada $_temp0';
  }

  @override
  String guideUsedMark(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'denominação',
      'producer': 'produtor',
      'other': 'nome',
    });
    return '$_temp0';
  }

  @override
  String guideOtherYears(String years) {
    return 'Também no texto: $years';
  }

  @override
  String get guideWheelFromText => 'ano encontrado no texto';

  @override
  String get guideWheelTypeYear => 'Digite o ano';

  @override
  String guideWheelConfirm(String year) {
    return 'Confirmar $year';
  }

  @override
  String get guideNoVintage => 'Sem safra';

  @override
  String guideSkippedNotice(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'Denominação pulada',
      'producer': 'Produtor pulado',
      'vintage': 'Safra pulada',
      'other': 'Nome pulado',
    });
    return '$_temp0: digite ou retome o guia';
  }

  @override
  String guideSkippedMany(int count) {
    return '$count campos pulados: digite-os ou retome o guia';
  }

  @override
  String get guideInvalidValue =>
      'O texto contém caracteres que não podem ser salvos';
}
