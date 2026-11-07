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
