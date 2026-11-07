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
  String get labelOfflineNotice =>
      'Without network I only recognise the denomination: check the details';

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
  String get labelBarcodeNeedsNetwork =>
      'I read the barcode: I need the network to look it up';

  @override
  String get labelRetryOnline => 'Try again when the network is back';

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
  String get labelOfflineNotice =>
      'Sem rede reconheço só a denominação: confira os dados';

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
  String get labelBarcodeNeedsNetwork =>
      'Li o código de barras: preciso da rede para procurá-lo';

  @override
  String get labelRetryOnline => 'Tentar de novo quando a rede voltar';

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
}
