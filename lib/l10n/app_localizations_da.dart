// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Danish (`da`).
class AppLocalizationsDa extends AppLocalizations {
  AppLocalizationsDa([String locale = 'da']) : super(locale);

  @override
  String get appTitle => 'Vinoozy';

  @override
  String get signInTagline => 'Din vinkælder, på det rette tidspunkt';

  @override
  String get signInWithGoogle => 'Fortsæt med Google';

  @override
  String get signInInProgress => 'Logger ind';

  @override
  String get signInFailed => 'Login mislykkedes';

  @override
  String get signInNeedsNetwork =>
      'Du skal have forbindelse første gang du logger ind';

  @override
  String get signInSessionExpired => 'Din session er udløbet: log ind igen';

  @override
  String get retry => 'Prøv igen';

  @override
  String get cancel => 'Annuller';

  @override
  String blockedMessage(String email) {
    return 'Der er ændringer fra $email, som endnu ikke er gemt i skyen: log ind med den konto, og opret forbindelse til nettet';
  }

  @override
  String blockedSignInWith(String email) {
    return 'Log ind med $email';
  }

  @override
  String blockedDiscard(String email) {
    return 'Slet ikke-gemte ændringer fra $email';
  }

  @override
  String get discardDialogTitle => 'Slet ændringerne?';

  @override
  String discardDialogBody(int count, String email) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count vine fra $email er endnu ikke i skyen og bliver slettet fra denne telefon.',
      one:
          '1 vin fra $email er endnu ikke i skyen og bliver slettet fra denne telefon.',
    );
    return '$_temp0';
  }

  @override
  String get discardConfirm => 'Slet';

  @override
  String get resetFailed => 'Dataene på denne telefon kunne ikke ryddes';

  @override
  String get restartRequired => 'Genstart appen for at afslutte';

  @override
  String get restartCloseApp => 'Luk appen';

  @override
  String get startupFailed => 'Appen kunne ikke starte';

  @override
  String get cellarTitle => 'Kælder';

  @override
  String get defaultCellarName => 'Min kælder';

  @override
  String get cellarLoading => 'Klargør kælderen';

  @override
  String get cellarSetupFailed => 'Kælderen kunne ikke klargøres';

  @override
  String get cellarEmpty => 'Din kælder er tom';

  @override
  String get addWine => 'Tilføj';

  @override
  String get estimatePending => 'Estimat på vej';

  @override
  String get noVintage => 'Uden årgang';

  @override
  String bottleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count flasker',
      one: '1 flaske',
    );
    return '$_temp0';
  }

  @override
  String get syncInProgress => 'Synkroniserer';

  @override
  String get syncOffline => 'Offline - synkronisering venter';

  @override
  String writeRejected(String name) {
    return 'Ændring ikke tilladt: $name';
  }

  @override
  String get saveFailed => 'Kunne ikke gemme, prøv igen';

  @override
  String wineNotSaved(String name) {
    return 'Vinen $name blev ikke gemt i skyen';
  }

  @override
  String get addAgain => 'Tilføj igen';

  @override
  String get ignore => 'Ignorer';

  @override
  String get addWineTitle => 'Skriv';

  @override
  String get wineNameLabel => 'Vin';

  @override
  String get vintageLabel => 'Årgang';

  @override
  String get quantityLabel => 'Antal';

  @override
  String get decreaseQuantity => 'Reducer antal';

  @override
  String get increaseQuantity => 'Forøg antal';

  @override
  String get save => 'Gem';

  @override
  String get nameRequired => 'Skriv vinens navn';

  @override
  String get nameTooLong => 'Højst 120 tegn';

  @override
  String vintageRange(String year) {
    return 'Årgang mellem 1900 og $year';
  }

  @override
  String get offAttribution => 'Data fra Open Food Facts (ODbL)';

  @override
  String get dashboardTitle => 'Oversigt';

  @override
  String dashboardTotalBottles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count flasker i kælderen',
      one: '1 flaske i kælderen',
    );
    return '$_temp0';
  }

  @override
  String get dashboardSyncing => 'Synkroniserer kælderen…';

  @override
  String get dashboardAddFirstWine => 'Tilføj din første vin';

  @override
  String get drinkSoonTitle => 'Drik snart';

  @override
  String get drinkSoonEmpty => 'Ingen flasker skal drikkes snart';

  @override
  String drinkSoonUntil(String year) {
    return 'senest $year';
  }

  @override
  String drinkSoonSeeAll(int count) {
    return 'Se alle ($count)';
  }

  @override
  String get statusChartTitle => 'Flaskernes status';

  @override
  String get statusWaiting => 'skal vente';

  @override
  String get statusReady => 'drikkeklar';

  @override
  String get statusDrinkSoon => 'drik snart';

  @override
  String get statusPastWindow => 'vindue forbi';

  @override
  String toEstimateNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count flasker uden estimat',
      one: '1 flaske uden estimat',
    );
    return '$_temp0';
  }

  @override
  String chartBarValue(String label, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count flasker',
      one: '1 flaske',
    );
    return '$label: $_temp0';
  }

  @override
  String chartDescription(String title, String values) {
    return '$title: $values';
  }

  @override
  String get openListHint => 'Åbn listen';

  @override
  String get peakChartTitle => 'År for toppunkt';

  @override
  String get peakPast => 'toppunkt forbi';

  @override
  String get peakBeyond => 'senere';

  @override
  String get breakdownTypeTitle => 'Flasker efter type';

  @override
  String get breakdownRegionTitle => 'Flasker efter region';

  @override
  String get breakdownType => 'Type';

  @override
  String get breakdownRegion => 'Region';

  @override
  String get familyRed => 'rød';

  @override
  String get familyWhite => 'hvid';

  @override
  String get familyRose => 'rosé';

  @override
  String get familySparkling => 'mousserende';

  @override
  String get familySweet => 'sød';

  @override
  String get breakdownUnspecified => 'ikke angivet';

  @override
  String get breakdownOtherRegions => 'andre';

  @override
  String get ok => 'OK';

  @override
  String get cellarMenu => 'Kældermenu';

  @override
  String get sharingPeopleTitle => 'Personer';

  @override
  String get sharingInviteTitle => 'Inviter en person';

  @override
  String get sharingEmailLabel => 'Google-mailadresse';

  @override
  String get sharingPermissionRead => 'Kun læse';

  @override
  String get sharingPermissionReadHint =>
      'Ser vine, estimater, oversigt og drukne flasker';

  @override
  String get sharingPermissionEdit => 'Kan redigere';

  @override
  String get sharingPermissionEditHint =>
      'Tilføjer og ændrer også vine og noterer drukne flasker';

  @override
  String get sharingRoleOwner => 'ejer';

  @override
  String get sharingInviteButton => 'Inviter';

  @override
  String sharingPlacesUsed(int used, int max) {
    return '$used/$max personer';
  }

  @override
  String get sharingInvalidEmail => 'Skriv en gyldig mailadresse';

  @override
  String get sharingSelfInvite => 'Du kan ikke invitere dig selv';

  @override
  String get sharingAlreadyInvited => 'Denne person er allerede inviteret';

  @override
  String sharingLimitReached(int max) {
    return 'Du har nået grænsen på $max personer';
  }

  @override
  String get sharingNotOwner => 'Du kan ikke ændre delingen af denne kælder';

  @override
  String get sharingNotFound => 'Denne person er ikke længere på listen';

  @override
  String get sharingFailed => 'Det lykkedes ikke, prøv igen';

  @override
  String get sharingInviteFailed => 'Invitationen mislykkedes. Prøv igen';

  @override
  String get sharingOfflineHint =>
      'Du skal have forbindelse for at administrere deling';

  @override
  String get sharingStatusInvited => 'inviteret';

  @override
  String get sharingStatusActive => 'aktiv';

  @override
  String get sharingStatusRevoked => 'tilbagekaldt';

  @override
  String get sharingStatusLeft => 'har forladt';

  @override
  String sharingMemberSemantics(String name, String permission, String status) {
    return '$name, $permission, $status';
  }

  @override
  String get sharingClosedSection => 'Lukket adgang';

  @override
  String get sharingNobody => 'Ingen andre kan se denne kælder endnu';

  @override
  String sharingChangePermission(String name) {
    return 'Skift rettighed for $name';
  }

  @override
  String get sharingRevoke => 'Tilbagekald';

  @override
  String sharingRevokeTitle(String name) {
    return 'Tilbagekald adgangen for $name?';
  }

  @override
  String sharingRevokeConfirmLabel(String name) {
    return 'Skriv $name for at bekræfte';
  }

  @override
  String get sharingRevokeDisabledHint => 'Aktiveres, når navnet stemmer';

  @override
  String get sharingReinvite => 'Inviter igen';

  @override
  String get sharingDeleteForGood => 'Slet permanent';

  @override
  String sharingOwnedBy(String owner) {
    return 'Kælder tilhørende $owner';
  }

  @override
  String get sharingYourCellar => 'Din kælder';

  @override
  String sharingYourPermission(String permission) {
    return 'Din rettighed: $permission';
  }

  @override
  String sharingSwitcherSemantics(String cellar, String permission) {
    return '$cellar, $permission. Tryk for at skifte kælder';
  }

  @override
  String get sharingLeave => 'Forlad denne kælder';

  @override
  String sharingLeaveTitle(String owner) {
    return 'Forlad kælderen tilhørende $owner?';
  }

  @override
  String sharingLeaveBody(String owner) {
    return 'Du kan ikke længere se den. $owner kan invitere dig igen.';
  }

  @override
  String get sharingLeaveConfirm => 'Forlad';

  @override
  String sharingSharedNotice(String owner) {
    return '$owner har delt sin kælder med dig';
  }

  @override
  String sharingAccessLost(String owner) {
    return 'Du har ikke længere adgang til kælderen tilhørende $owner';
  }

  @override
  String sharingWritesLost(String owner) {
    return 'Nogle ændringer i kælderen tilhørende $owner blev ikke gemt, fordi du ikke længere har adgang';
  }

  @override
  String get sharingSomeone => 'nogen';

  @override
  String get sharingShareSubject => 'Invitation til Vinoozy';

  @override
  String sharingShareMessage(
    String owner,
    String cellar,
    String link,
    String email,
  ) {
    return '$owner har inviteret dig til kælderen \"$cellar\" i Vinoozy. Installer appen fra $link, og log ind med Google-kontoen $email: brug præcis denne adresse.';
  }

  @override
  String get cellarSearchHint => 'Søg efter navn eller producent';

  @override
  String get cellarFilterStatus => 'Status';

  @override
  String get cellarFilterType => 'Type';

  @override
  String get statusToEstimate => 'Uden estimat';

  @override
  String get filterTypeUnspecified => 'Ikke angivet';

  @override
  String get cellarNoMatches => 'Ingen vin med disse filtre';

  @override
  String get cellarClearFilters => 'Ryd filtre';

  @override
  String get cellarArchiveTitle => 'Drukket';

  @override
  String get cellarArchiveEmpty => 'Ingen vine er drukket op endnu';

  @override
  String get cellarArchiveFailed =>
      'De vine, der er drukket op, kunne ikke hentes';

  @override
  String get wineDrink => 'Drukket';

  @override
  String wineDrinkTooltip(String name) {
    return 'Markér en flaske $name som drukket';
  }

  @override
  String confidenceLabel(String level) {
    return 'Sikkerhed: $level';
  }

  @override
  String get confidenceHigh => 'høj';

  @override
  String get confidenceMedium => 'middel';

  @override
  String get confidenceLow => 'lav';

  @override
  String get windowStartLabel => 'Start';

  @override
  String get windowPeakLabel => 'Toppunkt';

  @override
  String get windowEndLabel => 'Slut';

  @override
  String estimateSourceLabel(String source) {
    return 'Kilde: $source';
  }

  @override
  String get estimateSourceCatalog => 'vindatabase';

  @override
  String get estimateSourceType => 'estimat for typen';

  @override
  String get estimateSourceCorrected =>
      'estimat justeret efter dine drukne flasker';

  @override
  String get estimateDisclaimer =>
      'Vejledende estimat: det afhænger også af, hvordan flasken er opbevaret';

  @override
  String get estimateUnavailable => 'Intet estimat tilgængeligt';

  @override
  String get pairingsTitle => 'Passer til';

  @override
  String get pairingsGeneric => 'generelle madforslag til typen';

  @override
  String get pairingBraisedRedMeat => 'Braiseret rødt kød';

  @override
  String get pairingGrilledRedMeat => 'Grillet rødt kød';

  @override
  String get pairingGame => 'Vildt';

  @override
  String get pairingRoastPoultry => 'Stegt fjerkræ';

  @override
  String get pairingPoultry => 'Fjerkræ';

  @override
  String get pairingPork => 'Svinekød';

  @override
  String get pairingCuredMeats => 'Charcuteri';

  @override
  String get pairingPastaMeatSauce => 'Pasta med kødsovs';

  @override
  String get pairingMushroomsTruffle => 'Svampe og trøffel';

  @override
  String get pairingAgedCheese => 'Lagret ost';

  @override
  String get pairingFreshCheese => 'Friskost';

  @override
  String get pairingBlueCheese => 'Blåskimmelost';

  @override
  String get pairingFish => 'Fisk';

  @override
  String get pairingSeafood => 'Skaldyr';

  @override
  String get pairingRawSeafood => 'Rå fisk og skaldyr';

  @override
  String get pairingFriedFood => 'Friturestegt';

  @override
  String get pairingVegetables => 'Grøntsager';

  @override
  String get pairingRisotto => 'Risotto';

  @override
  String get pairingPizza => 'Pizza';

  @override
  String get pairingAperitif => 'Aperitif';

  @override
  String get pairingPastries => 'Kager';

  @override
  String get pairingDryBiscuits => 'Tørre småkager';

  @override
  String get pairingChocolate => 'Chokolade';

  @override
  String get pairingDriedFruit => 'Nødder og tørret frugt';

  @override
  String get pairingSpicyDishes => 'Krydrede retter';

  @override
  String get recentDrinksTitle => 'Senest drukket';

  @override
  String get noDrinksYet => 'Intet drukket endnu';

  @override
  String get wineEdit => 'Rediger';

  @override
  String get wineDelete => 'Slet';

  @override
  String get wineFinished => 'Drukket op: ingen flasker tilbage';

  @override
  String get wineLoadFailed => 'Vinen kunne ikke åbnes';

  @override
  String get wineNotFound => 'Denne vin findes ikke længere';

  @override
  String drinkDone(String name) {
    return 'Markeret som drukket: $name';
  }

  @override
  String get drinkUndo => 'Fortryd';

  @override
  String get drinkAddNotes => 'Tilføj bedømmelse og noter';

  @override
  String get nothingToUndo => 'Der er ikke mere at fortryde';

  @override
  String get cellarUndoRejected =>
      'Fortryd mislykkedes: flasken er stadig markeret som drukket';

  @override
  String get cellarDeleteFailed =>
      'Sletningen er ikke færdig endnu: den afsluttes hurtigst muligt';

  @override
  String get duplicateFull =>
      'Denne vin har allerede 99 flasker: der kan ikke tilføjes flere.';

  @override
  String get recordSheetTitle => 'Bedømmelse og noter';

  @override
  String get recordRatingLabel => 'Bedømmelse';

  @override
  String ratingStar(int n) {
    return 'Bedømmelse $n af 5';
  }

  @override
  String get recordNotesLabel => 'Noter';

  @override
  String get recordNotesTooLong => 'Højst 1000 tegn';

  @override
  String recordDateLabel(String date) {
    return 'Dato: $date';
  }

  @override
  String get recordDateInvalid =>
      'Datoen må ikke ligge i fremtiden eller før årgangen';

  @override
  String get recordConditionTitle => 'Hvordan var den?';

  @override
  String get conditionTooYoung => 'Stadig for ung';

  @override
  String get conditionJustRight => 'Lige tilpas';

  @override
  String get conditionPastPeak => 'Over toppunktet';

  @override
  String get recordNoCondition => 'Intet svar';

  @override
  String get producerLabel => 'Producent (valgfrit)';

  @override
  String get producerTooLong => 'Højst 120 tegn';

  @override
  String producerAddNew(String name) {
    return 'Tilføj \"$name\" som ny producent';
  }

  @override
  String get wineTypeLabel => 'Type';

  @override
  String get typeRedLight => 'Let rødvin';

  @override
  String get typeRedStructured => 'Fyldig rødvin';

  @override
  String get typeWhite => 'Hvidvin';

  @override
  String get typeRose => 'Rosé';

  @override
  String get typeSparklingClassic => 'Mousserende, traditionel metode';

  @override
  String get typeSparklingTank => 'Mousserende, tankmetode';

  @override
  String get typeSweet => 'Sød vin';

  @override
  String get typeFortified => 'Hedvin';

  @override
  String get suggestionFromCellar => 'I din kælder';

  @override
  String get suggestionsLabel => 'Forslag';

  @override
  String get duplicateTitle => 'Allerede i kælderen';

  @override
  String duplicateBody(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count flasker',
      one: '1 flaske',
      zero: 'ingen flasker',
    );
    return '$name findes allerede med $_temp0. Vil du lægge de nye flasker til den?';
  }

  @override
  String duplicateAdd(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tilføj $count flasker',
      one: 'Tilføj 1 flaske',
    );
    return '$_temp0';
  }

  @override
  String get duplicateBanner => 'Mulig dublet';

  @override
  String get duplicateMerge => 'Flet';

  @override
  String get duplicateDeleteHint => 'Slet denne post, hvis den er en dublet';

  @override
  String get mergeTitle => 'Flet de to poster?';

  @override
  String get mergeBody =>
      'Flaskerne i denne post flyttes til den ældste, og derefter slettes denne post.';

  @override
  String get editWineTitle => 'Rediger vin';

  @override
  String get editDuplicate =>
      'Der findes allerede en vin med samme navn, producent og årgang';

  @override
  String deleteWineTitle(String name) {
    return 'Slet $name?';
  }

  @override
  String get deleteWineBody =>
      'Vinen og alle noteringer om drukne flasker slettes. Det kan ikke fortrydes.';

  @override
  String get historyTitle => 'Historik';

  @override
  String get historyEmpty => 'Her finder du de flasker, du har drukket';

  @override
  String get historyLoadFailed => 'Historikken kunne ikke hentes';

  @override
  String drankOnLabel(String date) {
    return 'Drukket den $date';
  }

  @override
  String get addChoiceTitle => 'Tilføj en vin';

  @override
  String get addChoicePhoto => 'Tag et billede';

  @override
  String get addChoiceImport => 'Importér et billede';

  @override
  String get addChoiceWrite => 'Skriv';

  @override
  String get labelReading => 'Jeg læser etiketten…';

  @override
  String get labelRecognized => 'Jeg genkendte:';

  @override
  String get labelCorrect => 'Ret';

  @override
  String get labelConfirm => 'Bekræft';

  @override
  String get labelUnreadable => 'Jeg kan ikke læse etiketten';

  @override
  String get labelWriteByHand => 'Skriv selv';

  @override
  String get labelNotFound => 'Jeg fandt ikke vinen: tjek oplysningerne';

  @override
  String get labelCameraDenied =>
      'For at læse etiketten skal jeg have adgang til kameraet';

  @override
  String get labelPhotosDenied =>
      'For at læse etiketten skal jeg have adgang til billederne';

  @override
  String get labelOpenSettings => 'Åbn indstillinger';

  @override
  String get labelCameraUnavailable => 'Kameraet er ikke tilgængeligt';

  @override
  String get labelBarcodeNotFound =>
      'Jeg læste stregkoden, men kan ikke finde vinen';

  @override
  String get labelBarcodeFrontHint => 'Tag et billede af etikettens forside';

  @override
  String get labelSharedNotAllowed =>
      'Du kan ikke tilføje vine til denne kælder';

  @override
  String get labelSharedFirstOnly => 'Jeg brugte kun det første billede';

  @override
  String get labelSharedExpired =>
      'Det delte billede kunne ikke læses: del det igen';

  @override
  String get labelReplaceTitle =>
      'Du har en vin, der ikke er gemt. Vil du læse det nye billede?';

  @override
  String get labelReplaceRead => 'Læs det nye billede';

  @override
  String get labelReplaceKeep => 'Fortsæt med den åbne';

  @override
  String get labelWineAdded => 'Vinen er tilføjet til kælderen';

  @override
  String get onboardingPage1Title => 'Din vinkælder i lommen';

  @override
  String get onboardingPage1Body =>
      'Tilføj dine flasker ved at skrive dem ind eller med et billede af etiketten, også uden net.';

  @override
  String get onboardingPage2Title => 'På det rette tidspunkt';

  @override
  String get onboardingPage2Body =>
      'Vinoozy vurderer, hvornår hver vin er bedst, og fortæller dig, hvilke du skal åbne først.';

  @override
  String get onboardingPage3Title => 'Sammen';

  @override
  String get onboardingPage3Body =>
      'Del din kælder med op til to personer, og gem historikken for hver flaske, du drikker.';

  @override
  String get onboardingSkip => 'Spring over';

  @override
  String get onboardingNext => 'Næste';

  @override
  String get onboardingStart => 'Start';

  @override
  String onboardingPageOf(int page) {
    return 'Side $page af 3';
  }

  @override
  String get profileTitle => 'Profil';

  @override
  String get profilePhoto => 'Profilbillede';

  @override
  String get profileSignOut => 'Log ud';

  @override
  String get profileDeleteAccount => 'Slet konto';

  @override
  String get profilePrivacy => 'Privatlivspolitik';

  @override
  String get profilePrivacyBody =>
      'Du kan læse privatlivspolitikken på denne adresse:';

  @override
  String get profileOpenLink => 'Åbn i browser';

  @override
  String get profileOpenLinkFailed =>
      'Siden kunne ikke åbnes. Du kan kopiere linket og åbne det i din browser.';

  @override
  String get profileCopyLink => 'Kopiér link';

  @override
  String get profileLinkCopied => 'Link kopieret';

  @override
  String get close => 'Luk';

  @override
  String get signOutConfirmTitle => 'Vil du logge ud?';

  @override
  String signOutPendingWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Du har $count ændringer, der endnu ikke er gemt. Hvis du logger ud, og en anden konto logger ind, går de tabt.',
      one: 'Du har 1 ændring, der endnu ikke er gemt. Hvis du logger ud, og en anden konto logger ind, går den tabt.',
    );
    return '$_temp0';
  }

  @override
  String get signOutStayAndSync => 'Bliv og synkroniser';

  @override
  String get signOutAnyway => 'Log ud alligevel';

  @override
  String get syncAllSaved => 'Alt er gemt';

  @override
  String syncStillPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ændringer mangler stadig at blive gemt: tjek nettet',
      one: '1 ændring mangler stadig at blive gemt: tjek nettet',
    );
    return '$_temp0';
  }

  @override
  String get signOutFailed => 'Kunne ikke logge ud. Prøv igen';

  @override
  String get signInAccountDeleted => 'Kontoen er slettet';

  @override
  String get deleteAccountIntro => 'Dette slettes permanent:';

  @override
  String get deleteAccountItemCellar => 'Din kælder med dens vine og historik';

  @override
  String get deleteAccountItemShares =>
      'Det, du har delt: de inviterede personer mister adgangen';

  @override
  String get deleteAccountItemMemberships =>
      'Din deltagelse i andres kældre: dine drukne flasker bliver stående der uden dit navn';

  @override
  String get deleteAccountItemProfile => 'Din profil';

  @override
  String deleteAccountPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Du har $count ændringer, der endnu ikke er gemt: de gemmes og slettes derefter sammen med resten',
      one: 'Du har 1 ændring, der endnu ikke er gemt: den gemmes og slettes derefter sammen med resten',
    );
    return '$_temp0';
  }

  @override
  String get deleteAccountConfirmWord => 'SLET';

  @override
  String deleteAccountTypeWord(String word) {
    return 'Skriv $word for at bekræfte';
  }

  @override
  String get deleteAccountReauthHint =>
      'Derefter logger du ind igen med Google for at bekræfte, at det er dig.';

  @override
  String get deleteAccountForever => 'Slet for altid';

  @override
  String get deleteAccountNeedsNetwork =>
      'Opret forbindelse til internettet for at slette kontoen';

  @override
  String get deleteAccountSameAccount =>
      'Sletningen kræver, at du logger ind med den samme konto';

  @override
  String get deletionTitle => 'Sletter kontoen';

  @override
  String get deletionStepPreparePhone => 'Gemmer ventende ændringer';

  @override
  String get deletionStepMarkStarted => 'Starter sletningen';

  @override
  String get deletionStepLeaveOtherCellars => 'Forlader andres kældre';

  @override
  String get deletionStepCloseOwnInvitations => 'Lukker dine delinger';

  @override
  String get deletionStepDeleteWinesAndRecords => 'Sletter vine og historik';

  @override
  String get deletionStepDeleteCellar => 'Sletter kælderen';

  @override
  String get deletionStepDeleteProfileAndUser => 'Sletter profilen og kontoen';

  @override
  String get deletionStepCleanUpPhone => 'Rydder op på denne telefon';

  @override
  String deletionStepAnnounce(int step, String label) {
    return 'Trin $step af 8: $label';
  }

  @override
  String deletionDeletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vine og drukne flasker slettet',
      one: '1 vin eller drukket flaske slettet',
    );
    return '$_temp0';
  }

  @override
  String get deletionResumeHint =>
      'En sletning af denne konto er ikke afsluttet. Log ind igen med Google for at fuldføre den.';

  @override
  String get deletionContinue => 'Fortsæt';

  @override
  String get deletionOffline =>
      'Opret forbindelse til internettet for at fuldføre sletningen';

  @override
  String get deletionPendingWrites =>
      'Jeg kan ikke gemme de ventende ændringer. Prøv igen';

  @override
  String get deletionFailed => 'Sletningen kunne ikke fuldføres. Prøv igen';

  @override
  String get uxCountryLabel => 'Land';

  @override
  String get uxCountryOther => 'Andet land…';

  @override
  String get uxCountryNone => 'Intet land';

  @override
  String get uxAllCountriesTitle => 'Alle lande og territorier';

  @override
  String get uxAllCountriesSearch => 'Søg efter et land';

  @override
  String get uxAllCountriesRare => 'Sjældne for vin';

  @override
  String get uxAllCountriesAll => 'Alle, fra A til Å';

  @override
  String get uxAllCountriesNone => 'Intet land fundet';

  @override
  String get uxRegionLabel => 'Region';

  @override
  String uxRegionOf(String country) {
    return 'Region · $country';
  }

  @override
  String get uxRegionOther => 'Anden region';

  @override
  String get uxRegionFieldLabel => 'Skriv regionen';

  @override
  String get uxRegionTooLong => 'Højst 120 tegn';

  @override
  String get uxDrinkAction => 'Drak en';

  @override
  String uxDrinkActionTooltip(String name) {
    return 'Jeg har drukket en flaske $name';
  }

  @override
  String get uxDrinkActionDetail => 'Jeg har drukket en flaske';

  @override
  String get uxDrinkSheetLabel => 'Bekræft drukket flaske';

  @override
  String get uxDrinkSheetBottles => 'Flasker';

  @override
  String uxDrinkSheetBottlesChange(int before, int after) {
    return 'Flasker: fra $before til $after';
  }

  @override
  String get uxDrinkSheetRating => 'Hvordan var den? (valgfrit)';

  @override
  String uxDrinkSheetStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stjerner af 5',
      one: '1 stjerne af 5',
    );
    return '$_temp0';
  }

  @override
  String get uxDrinkSheetConfirm => 'Ja, den er drukket';

  @override
  String get uxRemoveBottle => 'Fjern en flaske uden notering';

  @override
  String get uxRemoveBottleTitle => 'Fjern en flaske?';

  @override
  String uxRemoveBottleBody(String name) {
    return 'En flaske $name fjernes uden at blive noteret som drukket.';
  }

  @override
  String get uxRemoveBottleConfirm => 'Fjern';

  @override
  String get uxIdealTitle => 'Ideelt tidspunkt';

  @override
  String uxIdealUntil(String year) {
    return 'Anbefales til og med $year';
  }

  @override
  String uxIdealUntilPast(String year) {
    return 'Anbefales til og med $year: det er passeret';
  }

  @override
  String uxIdealBest(String start, String end) {
    return 'Bedst fra $start til $end';
  }

  @override
  String uxIdealBar(String start, String end) {
    return 'Drikkevindue fra $start til $end';
  }

  @override
  String get uxIdealDisclaimer =>
      '⚠︎ Vejledende: et estimat ud fra type, appellation og årgang. Opbevaring og den enkelte flaske kan ændre det.';

  @override
  String get uxIdealUnavailableHint =>
      'Angiv årgang og type for at få et estimat.';

  @override
  String uxDashboardDrinkNow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count at drikke nu',
      one: '1 at drikke nu',
    );
    return '$_temp0';
  }

  @override
  String get uxFamilyRed => 'Rød';

  @override
  String get uxFamilyWhite => 'Hvid';

  @override
  String get uxFamilyRose => 'Rosé';

  @override
  String get uxFamilySparkling => 'Mousserende';

  @override
  String get uxFamilySweet => 'Sød';

  @override
  String get labelBackTitle => 'Nu bagsiden';

  @override
  String get labelBackHint =>
      'På bagsiden står som regel stregkoden, producenten og årgangen: de hjælper med at finde vinen.';

  @override
  String get labelBackTake => 'Tag bagsiden';

  @override
  String get labelBackGallery => 'Vælg fra galleriet';

  @override
  String get labelBackSkip => 'Spring over';

  @override
  String get labelStepFront => 'Forside';

  @override
  String get labelStepBack => 'Bagside';

  @override
  String get labelStepBarcode => 'Stregkode';

  @override
  String get labelStepDatabase => 'Vindatabase på telefonen';

  @override
  String get labelStepPending => 'Venter';

  @override
  String get labelStepRunning => 'Arbejder…';

  @override
  String get labelStepDone => 'Færdig';

  @override
  String get labelStepSkipped => 'Sprunget over';

  @override
  String get labelStepFailed => 'Kan ikke læses';

  @override
  String labelStepStatus(String step, String status) {
    return '$step: $status';
  }

  @override
  String get labelOnPhoneNote =>
      'Alt sker på telefonen: billederne sendes ikke til nogen.';

  @override
  String get labelBackUnreadable => 'Bagsiden kan ikke læses';

  @override
  String get labelSourceOffline => 'Fra databasen på telefonen · offline';

  @override
  String get labelSourceCatalog => 'Fra kataloget';

  @override
  String get labelSourceOnline => 'Fra Open Food Facts · online';

  @override
  String get labelNotThis => 'Ikke denne';

  @override
  String get labelOffAttribution => 'Data fra Open Food Facts, ODbL-licens';

  @override
  String get labelCandidatesTitle => 'Hvilken af disse?';

  @override
  String labelCandidatesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lignende vine',
      one: '1 lignende vin',
    );
    return '$_temp0';
  }

  @override
  String get labelCandidatesNone => 'Ingen af disse';

  @override
  String get labelChipOffline => 'offline';

  @override
  String get labelChipOnline => 'online';

  @override
  String get labelChipCatalog => 'katalog';

  @override
  String get labelNoProducer => 'producent ikke angivet';

  @override
  String get labelNoMatch => 'Jeg læste etiketten, men genkender ikke vinen';

  @override
  String get labelReadText => 'Læst tekst';

  @override
  String get labelSearchOnline => 'Søg online';

  @override
  String get labelOpenLens => 'Åbn i Google Lens';

  @override
  String get labelLensLastResort =>
      'Google Lens er sidste udvej: billedet sendes kun til Google-appen, hvis du bekræfter.';

  @override
  String get labelLensTitle => 'Åbn i Google Lens?';

  @override
  String get labelLensBody =>
      'Billedet af forsiden sendes til Google-appen på din telefon eller til den app, du vælger, som kan gemme en kopi efter sine egne regler. Vinoozy modtager ikke resultaterne: kom tilbage hertil for at vælge eller skrive vinen.';

  @override
  String get labelLensConfirm => 'Åbn Google Lens';

  @override
  String get labelLensFailed =>
      'Jeg kan hverken åbne Google Lens eller delemenuen';

  @override
  String get onlineSearchTitle => 'Søg online';

  @override
  String get onlineSearchSubtitle => 'Open Food Facts · kun vine';

  @override
  String get onlineSearchField => 'Søgeord';

  @override
  String get onlineSearchHint => 'Du kan ændre ordene, før du søger.';

  @override
  String get onlineSearchEmptyField => 'Skriv mindst ét ord';

  @override
  String get onlineSearchButton => 'Søg';

  @override
  String get onlineSearchLoading => 'Søger…';

  @override
  String onlineSearchResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count resultater',
      one: '1 resultat',
    );
    return '$_temp0';
  }

  @override
  String get onlineSearchEmpty =>
      'Ingen vin fundet: prøv andre ord eller \"Skriv selv\".';

  @override
  String get onlineSearchOffline =>
      'Intet net: jeg søger kun i databasen på telefonen.';

  @override
  String get onlineSearchRateLimited =>
      'Onlinesøgning er ikke tilgængelig lige nu, prøv igen om et par minutter.';

  @override
  String get onlineSearchUnavailable =>
      'Onlinesøgning er ikke aktiv i denne version af appen: jeg søger kun i databasen på telefonen.';

  @override
  String get aboutTitle => 'Om';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aboutDbTitle => 'Vindatabase';

  @override
  String aboutDbCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vine',
      one: '1 vin',
    );
    return '$_temp0';
  }

  @override
  String aboutDbDate(String date) {
    return 'Eksport fra Open Food Facts fra $date';
  }

  @override
  String get aboutDbSample =>
      'Eksempeldatabase: nogle få håndskrevne testvine, ikke data fra Open Food Facts.';

  @override
  String get aboutDbLoading => 'Åbner vindatabasen…';

  @override
  String get aboutDbUnavailable =>
      'Vindatabasen er ikke tilgængelig i denne version';

  @override
  String aboutDbSource(String url) {
    return 'Den afledte database og værktøjet, der bygger den, ligger i det offentlige repository: $url';
  }

  @override
  String get aboutLicenseTitle => 'Licenser';

  @override
  String get aboutLicense =>
      'Indeholder oplysninger fra Open Food Facts, stillet til rådighed under Open Database License (ODbL). De enkelte indhold er under Database Contents License (DbCL).';

  @override
  String get aboutPrivacyTitle => 'Billeder af etiketter';

  @override
  String get aboutPrivacy =>
      'Billeder af etiketter læses på telefonen og slettes, når du forlader resultatet. De forlader kun telefonen, hvis du trykker på \"Åbn i Google Lens\" og bekræfter.';

  @override
  String get aboutAppellationsTitle => 'Appellationer';

  @override
  String get aboutAppellationsSource =>
      'Appellationer: eAmbrosia-registret (EU) og officielle nationale registre.';

  @override
  String get aboutAppellationsSample =>
      'Eksempeltabel: et håndskrevet uddrag af registrene, indtil de rigtige registre er hentet.';

  @override
  String get denominationLabel => 'Appellation';

  @override
  String get denominationTooLong => 'Højst 120 tegn';

  @override
  String get autofillFilledNotice => 'Udfyldt fra etiketten: tjek og gem';

  @override
  String get autofillPastedNotice => 'Udfyldt fra teksten: tjek og gem';

  @override
  String get autofillFromText => '✦ fra teksten';

  @override
  String get autofillFromTextSemantics => 'udfyldt fra etiketten';

  @override
  String get autofillClear => 'Ryd';

  @override
  String get autofillLens => 'Lens';

  @override
  String get autofillClearTitle => 'Ryd formularen?';

  @override
  String get autofillClearBody =>
      'Du har også selv skrivet i nogle felter. \"Ryd\" tømmer navn, producent, appellation, årgang, type, land, region og niveau. Antallet bliver stående.';

  @override
  String get autofillClearConfirm => 'Ryd';

  @override
  String get autofillCleared => 'Formularen er ryddet';

  @override
  String get autofillPasteTitle => 'Har du teksten fra Google Lens?';

  @override
  String get autofillPasteHint =>
      'Markér etikettens tekst i Lens, og tryk på \"Kopiér\". Kom derefter tilbage hertil.';

  @override
  String get autofillPaste => 'Indsæt fra Lens';

  @override
  String get autofillOpenLens => 'Fra Google Lens';

  @override
  String get autofillOpenLensSemantics => 'åbner Google Lens';

  @override
  String get autofillClipboardEmpty => 'Der er ingen tekst på udklipsholderen';

  @override
  String get autofillNoNewFields =>
      'Jeg fandt ingen oplysninger at tilføje i teksten';

  @override
  String get autofillFromLens => 'Formularen er udfyldt fra Lens-teksten';

  @override
  String get autofillShareEmpty => 'Ingen tekst modtaget';

  @override
  String get autofillShareUseTitle => 'Brug teksten til de tomme felter?';

  @override
  String get autofillShareUse => 'Brug';

  @override
  String get autofillShareIgnore => 'Ignorer';

  @override
  String get addChoiceLens => 'Fra Google Lens';

  @override
  String get addChoicePhotoHint =>
      'Forside og bagside: Vinoozy læser etiketten.';

  @override
  String get addChoiceLensHint =>
      'Åbner Lens: sigt, markér teksten, og tryk på Del → Vinoozy.';

  @override
  String get addChoiceImportHint =>
      'Et billede af etiketten, som du allerede har taget.';

  @override
  String get addChoiceWriteHint => 'Tom formular med \"Indsæt fra Lens\".';

  @override
  String get lensInstructionsTitle => 'Google Lens kan ikke åbnes herfra';

  @override
  String get lensInstructionsStep1 => 'Åbn Google Lens, og sigt på etiketten';

  @override
  String get lensInstructionsStep2 => 'Markér etikettens tekst';

  @override
  String get lensInstructionsStep3 => 'Tryk på Del → Vinoozy';

  @override
  String get lensInstructionsOk => 'Forstået';

  @override
  String get levelLabel => 'Niveau';

  @override
  String get levelEveryday => 'Hverdag (billig)';

  @override
  String get levelGood => 'God';

  @override
  String get levelAging => 'Til lagring';

  @override
  String get levelNone => 'Intet';

  @override
  String get levelEverydayShort => 'drik tidligt';

  @override
  String get levelGoodShort => 'normalt estimat';

  @override
  String get levelAgingShort => 'holder længere';

  @override
  String get levelSuggested => 'foreslået';

  @override
  String levelSuggestedReason(String qualifier) {
    return 'Foreslået, fordi der står \"$qualifier\" i navnet: det gemmes sådan, medmindre du ændrer det. Vælg et andet, eller tryk på \"Intet\".';
  }

  @override
  String levelSuggestedSemantics(String qualifier) {
    return 'foreslået, fordi der står $qualifier i navnet';
  }

  @override
  String levelOptionSemantics(String option, int index, int count) {
    return 'Niveau, $option, $index af $count';
  }

  @override
  String get levelWhatChanges => 'Hvad ændrer sig';

  @override
  String get levelEverydayExamples =>
      'Vinduet bliver kortere. F.eks. husets vin, Lambrusco, enkel Prosecco, Bardolino, Vinho Verde.';

  @override
  String get levelGoodExamples =>
      'Det normale estimat, og det der gælder, når du ikke vælger noget. F.eks. Chianti Classico, Barbera d\'Asti Superiore, Rioja Crianza, Côtes du Rhône.';

  @override
  String get levelAgingExamples =>
      'Vinduet bliver længere. F.eks. Barolo, Brunello, Amarone, Bordeaux Grand Cru, Rioja Gran Reserva, Vintage Port.';

  @override
  String levelPreviewBefore(String start, String end) {
    return 'Før $start – $end';
  }

  @override
  String levelPreviewWith(String level, String start, String end) {
    return 'Med \"$level\" $start – $end';
  }

  @override
  String levelPreviewNow(String start, String end) {
    return 'Drikkeklar $start – til $end';
  }

  @override
  String levelDetail(String level) {
    return 'Niveau: $level';
  }

  @override
  String get overrideCorrect => 'Ret';

  @override
  String get overrideRestore => 'Gendan estimat';

  @override
  String get overrideCorrectedByYou => 'rettet af dig';

  @override
  String overrideAppEstimate(String year) {
    return 'Appens estimat: til $year';
  }

  @override
  String get overrideSheetTitle => 'Anbefales til og med';

  @override
  String overrideSheetHint(String start) {
    return 'Vælg året. Det må ikke ligge før \"Drikkeklar fra $start\".';
  }

  @override
  String overridePeakNotice(String peak) {
    return 'Hvis du vælger et år før $peak (bedst), flytter \"bedst\" også til samme år.';
  }

  @override
  String get overrideMore => 'flere…';

  @override
  String get overrideSave => 'Gem rettelse';

  @override
  String overrideRestoreTitle(String year) {
    return 'Gå tilbage til appens estimat (til $year)?';
  }

  @override
  String get overrideRestoreConfirm => 'Gendan';

  @override
  String get overrideSaved => 'Rettelsen er gemt';

  @override
  String get overrideRestored => 'Estimatet er gendannet';

  @override
  String get estimateSourceCorrectedByYou => 'rettet af dig';

  @override
  String estimateFromDenomination(String name) {
    return 'Estimat ud fra appellationen $name';
  }

  @override
  String estimateFromDenominationQualifier(String name, String qualifier) {
    return 'Estimat ud fra appellationen $name, $qualifier';
  }

  @override
  String estimateFromGrape(String name) {
    return 'Estimat ud fra druesorten $name';
  }

  @override
  String get estimateFromType => 'Estimat ud fra vintypen';

  @override
  String get autofillReading => 'Jeg læser teksten…';

  @override
  String get guideChip => 'Guidet tjek';

  @override
  String guideProgress(int n, int total) {
    return 'Spørgsmål $n af $total';
  }

  @override
  String get guideClose => 'Luk';

  @override
  String get guideIsDenomination => 'er det appellationen?';

  @override
  String get guideIsProducer => 'er det producenten?';

  @override
  String get guideIsName => 'er det vinens navn?';

  @override
  String get guideIsVintage => 'Årgang';

  @override
  String guideAskDenomination(String value) {
    return 'Er $value appellationen?';
  }

  @override
  String guideAskProducer(String value) {
    return 'Er $value producenten?';
  }

  @override
  String guideAskName(String value) {
    return 'Er $value vinens navn?';
  }

  @override
  String get guideAskVintage => 'Hvilken årgang er det?';

  @override
  String guideQuestionSemantics(int n, int total, String question) {
    return 'Spørgsmål $n af $total: $question';
  }

  @override
  String get guideNoProposal => 'Jeg kunne ikke finde det i teksten';

  @override
  String get guideYes => 'Ja';

  @override
  String get guideNo => 'Nej, et andet';

  @override
  String get guideEdit => 'Rediger';

  @override
  String get guideSkip => 'Spring over';

  @override
  String get guideConfirm => 'Bekræft';

  @override
  String get guideCancel => 'Annuller';

  @override
  String guideRejected(String value) {
    return 'Ikke \"$value\": her er det næste';
  }

  @override
  String get guideNoMore =>
      'Ingen flere forslag: sammensæt det selv, eller spring over';

  @override
  String guideProposalAnnounce(String value) {
    return 'Forslag: $value';
  }

  @override
  String get guideComposeLabel =>
      'Eller sammensæt det ved at trykke på ord i teksten';

  @override
  String get guideComposePreview => 'Forhåndsvisning';

  @override
  String get guideComposeEmpty => 'Tryk på et eller flere ord';

  @override
  String get guideComposeLimit => 'Op til 8 ord og 80 tegn';

  @override
  String guideTableMatchSemantics(String name) {
    return 'svarer til $name';
  }

  @override
  String guideLine(int n, int total) {
    return 'Linje $n af $total';
  }

  @override
  String guideWordSelected(String word, int order) {
    return '$word, valgt, $order';
  }

  @override
  String guideWordUnavailable(String word) {
    return '$word, ikke tilgængeligt';
  }

  @override
  String guideWordUsedFor(String word, String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'appellationen',
      'producer': 'producenten',
      'other': 'navnet',
    });
    return '$word, brugt til $_temp0';
  }

  @override
  String guideUsedMark(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'appellation',
      'producer': 'producent',
      'other': 'navn',
    });
    return '$_temp0';
  }

  @override
  String guideOtherYears(String years) {
    return 'Også i teksten: $years';
  }

  @override
  String get guideWheelFromText => 'år fundet i teksten';

  @override
  String get guideWheelTypeYear => 'Skriv året';

  @override
  String guideWheelConfirm(String year) {
    return 'Bekræft $year';
  }

  @override
  String get guideNoVintage => 'Uden årgang';

  @override
  String guideSkippedNotice(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'Appellation sprunget over',
      'producer': 'Producent sprunget over',
      'vintage': 'Årgang sprunget over',
      'other': 'Navn sprunget over',
    });
    return '$_temp0: skriv selv, eller genoptag guiden';
  }

  @override
  String guideSkippedMany(int count) {
    return '$count felter sprunget over: skriv dem selv, eller genoptag guiden';
  }

  @override
  String get guideInvalidValue =>
      'Denne tekst indeholder tegn, som ikke kan gemmes';

  @override
  String get brandStudio => 'Bottazzini Softworks';

  @override
  String get suggestedMark => '✦ foreslået';

  @override
  String suggestedSemantics(String field, String value) {
    return '$field, $value, foreslået';
  }

  @override
  String get restoreSuggestion => 'Gendan forslag';

  @override
  String get restoreSuggestionDone => 'Forslaget er gendannet';

  @override
  String get styleLabel => 'Stil';

  @override
  String styleGroupSemantics(String value, int index, int count) {
    return 'Stil, $value, $index af $count';
  }

  @override
  String get styleRedFresh => 'Frisk';

  @override
  String get styleRedMedium => 'Mellem';

  @override
  String get styleRedAge => 'Til lagring';

  @override
  String get styleRedLong => 'Lang lagring';

  @override
  String get styleWhiteFresh => 'Frisk';

  @override
  String get styleWhiteMedium => 'Mellem';

  @override
  String get styleWhiteAge => 'Til lagring';

  @override
  String get styleRoseFresh => 'Frisk';

  @override
  String get styleClassicFresh => 'Frisk';

  @override
  String get styleClassicAge => 'Til lagring';

  @override
  String get styleTankFresh => 'Frisk';

  @override
  String get styleLambrusco => 'Lambrusco';

  @override
  String get styleSweetAromatic => 'Aromatisk';

  @override
  String get styleSweetPassito => 'Tørrede druer';

  @override
  String get styleSweetBotrytis => 'Botrytis';

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
  String get styleFortifiedOther => 'Andet';

  @override
  String get profileNameRFresh => 'Frugtig rødvin';

  @override
  String get profileNameRMedium => 'Mellemfyldig rødvin';

  @override
  String get profileNameRAge => 'Rødvin til lagring';

  @override
  String get profileNameRLong => 'Rødvin til lang lagring';

  @override
  String get profileNameWFresh => 'Frisk aromatisk hvidvin';

  @override
  String get profileNameWMedium => 'Mellemfyldig hvidvin';

  @override
  String get profileNameWAge => 'Hvidvin til lagring';

  @override
  String get profileNameRoseFresh => 'Frisk rosé';

  @override
  String get profileNameSpTank => 'Frisk mousserende, tankmetode';

  @override
  String get profileNameLamFresh => 'Frisk Lambrusco';

  @override
  String get profileNameSpClassic => 'Frisk mousserende, traditionel metode';

  @override
  String get profileNameSpClassicAge =>
      'Mousserende til lagring, traditionel metode';

  @override
  String get profileNameSwAromatic => 'Ung aromatisk sød vin';

  @override
  String get profileNameSwPassito => 'Sød vin af tørrede druer';

  @override
  String get profileNameSwBotrytis => 'Sød botrytisvin';

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
  String get profileNameFortUnknown => 'Hedvin, ukendt stil';

  @override
  String get profileNameUnknown => 'Stil ikke genkendt';

  @override
  String estimateFromProfile(String profile, String denomination) {
    return 'Estimat ud fra profilen $profile ($denomination)';
  }

  @override
  String estimateFromProfileType(String profile) {
    return 'Estimat ud fra profilen $profile, efter type';
  }

  @override
  String estimateFromProfileGrape(String profile, String grape) {
    return 'Estimat ud fra profilen $profile, efter druesorten $grape';
  }

  @override
  String get estimateFromEntryDateDisgorgement =>
      'Fra tilføjelsesdatoen: angiv degorgeringsdatoen for et bedre estimat';

  @override
  String get estimateFromEntryDateBottling =>
      'Fra tilføjelsesdatoen: angiv aftapningsdatoen for et bedre estimat';

  @override
  String get styleToConfirmBanner =>
      '⚠︎ Stilen skal bekræftes: estimatet er vejledende';

  @override
  String get chooseTypePrompt => 'Vælg typen';

  @override
  String estimateUpdatedAnnouncement(String summary) {
    return 'Estimat opdateret: $summary';
  }

  @override
  String get agingStartDisgorgement => 'Degorgering';

  @override
  String get agingStartBottling => 'Aftapning';

  @override
  String get agingStartMonth => 'Måned';

  @override
  String get agingStartYear => 'År';

  @override
  String get agingStartHint => 'Det står som regel på bagetiketten.';

  @override
  String get agingStartIncomplete => 'Angiv måned og år';

  @override
  String get agingStartFuture => 'Datoen må ikke ligge i fremtiden';

  @override
  String get agingStartBeforeVintage => 'Den må ikke ligge før årgangen';

  @override
  String get windowNoEnd => 'Drikkeklar, ingen slutning estimeret';

  @override
  String get windowNoEndShort => 'ingen slutning estimeret';

  @override
  String windowDrinkWithin(String date) {
    return 'senest $date';
  }

  @override
  String get levelNoEffect => 'Niveauet ændrer ikke dette estimat';

  @override
  String get dashboardToConfirmTitle => 'Skal bekræftes';

  @override
  String dashboardToConfirmCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vine',
      one: '1 vin',
    );
    return '$_temp0';
  }

  @override
  String aboutDbClassified(String percent) {
    return '$percent % af vinene med en genkendt type';
  }

  @override
  String get planTitle => 'Pakke';

  @override
  String get planFree => 'Gratis';

  @override
  String get planPlus => 'Plus';

  @override
  String get planPlusGift => 'Plus (gave)';

  @override
  String get planDevUnlockAll => 'DEV · Test-Plus';

  @override
  String get planDevSimulateFree => 'DEV · Simuleret gratispakke';

  @override
  String get planDevSimulateExpired => 'DEV · Simuleret udløbet Plus';

  @override
  String get planDiscoverPlus => 'Se Plus';

  @override
  String get plusTitle => 'Vinoozy Plus';

  @override
  String get plusBenefitsTitle => 'Med Plus';

  @override
  String get plusBenefitNoAds => 'Ingen annoncer';

  @override
  String get plusBenefitNoLimit => 'Ingen grænse for vinene i din kælder';

  @override
  String get plusComingSoon => 'Plus kommer snart';

  @override
  String get plusLoading => 'Henter priserne fra Google Play';

  @override
  String get plusStoreUnavailable =>
      'Priserne kunne ikke hentes fra Google Play. Prøv igen senere.';

  @override
  String plusPriceMonthly(String price) {
    return '$price pr. måned';
  }

  @override
  String plusPriceAnnual(String price) {
    return '$price pr. år';
  }

  @override
  String get plusRenewal =>
      'Abonnementet fornyes automatisk til den viste pris, indtil du opsiger det i Google Play.';

  @override
  String get plusTerms =>
      'Betalingen trækkes på din Google Play-konto, når du bekræfter købet. Du kan opsige når som helst: Plus er aktivt indtil udgangen af den periode, du allerede har betalt for. Når Plus slutter, bliver alle dine vine stående.';

  @override
  String get plusRestore => 'Gendan køb';

  @override
  String get plusManage => 'Administrer eller opsig abonnementet i Google Play';

  @override
  String get plusActive => 'Plus er aktivt på denne konto';

  @override
  String get plusActiveGift =>
      'Du har fået Plus i gave: ingen betalinger og ingen fornyelser.';

  @override
  String get plusPending =>
      'Betalingen afventer: Plus bliver aktivt, når Google Play bekræfter den.';

  @override
  String get plusVerifying => 'Bekræfter købet';

  @override
  String get plusVerified =>
      'Købet er bekræftet: Plus er aktivt om få sekunder.';

  @override
  String get plusPurchaseFailed => 'Købet blev ikke gennemført. Prøv igen.';

  @override
  String get plusInvalidPurchase =>
      'Google Play har ikke bekræftet dette køb til Vinoozy.';

  @override
  String get plusOwnedByOther =>
      'Dette abonnement tilhører allerede en anden Vinoozy-konto.';

  @override
  String get plusVerificationUnavailable =>
      'Købet kunne ikke bekræftes lige nu. Prøv igen senere: abonnementet bliver i Google Play.';

  @override
  String get capacityLimitTitle => 'Du har nået grænsen for gratispakken';

  @override
  String capacityLimitBody(int limit) {
    return 'Gratispakken omfatter op til $limit forskellige vine i din kælder. Du kan altid redigere, drikke og lægge flasker til de vine, du allerede har. Hvis du vil tilføje en ny, skal du drikke en vin op eller slette en, eller skifte til Plus.';
  }

  @override
  String capacityLimitBodyComingSoon(int limit) {
    return 'Gratispakken omfatter op til $limit forskellige vine i din kælder. Du kan altid redigere, drikke og lægge flasker til de vine, du allerede har. Hvis du vil tilføje en ny, skal du drikke en vin op eller slette en. Plus kommer snart.';
  }

  @override
  String get rejectedCapacityLimit =>
      'Ikke synkroniseret: det overskrider vingrænsen for gratispakken. Ændringen bliver på denne telefon.';

  @override
  String get rejectedCapacityConflict =>
      'Ikke synkroniseret: kælderen blev ændret på en anden enhed samtidig. Ændringen bliver på denne telefon: prøv igen.';

  @override
  String writeRejectedCapacityLimit(String name) {
    return '$name: ikke synkroniseret, over grænsen for gratispakken';
  }

  @override
  String writeRejectedCapacityConflict(String name) {
    return '$name: ikke synkroniseret, kælderen blev ændret på en anden enhed';
  }

  @override
  String get freeIntroTitle => 'Gratispakken';

  @override
  String freeIntroLimit(int limit) {
    return 'Du kan gratis holde styr på op til $limit forskellige vine.';
  }

  @override
  String get freeIntroAds =>
      'Let brug er uden annoncer. Hvis du kommer over tjenestens månedlige forbrugsgrænse, kan du se enkelte annoncer, som hjælper med at dække udgifterne til servere og synkronisering.';

  @override
  String get freeIntroNoAds => 'Ingen annoncer i lanceringsversionen.';

  @override
  String get freeIntroPlus =>
      'Med Plus fjerner du annoncerne og kældergrænsen.';

  @override
  String get noticeGotIt => 'Forstået';

  @override
  String get thresholdTitle => 'Annoncer hjælper med at holde Vinoozy gratis';

  @override
  String get thresholdBody =>
      'Du har nået den månedlige grænse for brug uden annoncer. Fra nu af kan du se enkelte annoncer: de hjælper os med at dække udgifterne til servere og synkronisering, så Vinoozy kan forblive gratis.';

  @override
  String get thresholdReset =>
      'Tællingen starter forfra næste måned. Med Plus kan du bruge appen uden annoncer og uden kældergrænsen.';

  @override
  String thresholdNextReset(String date) {
    return 'Næste nulstilling: $date';
  }

  @override
  String get thresholdHowItWorks => 'Sådan fungerer det';

  @override
  String get thresholdHowItWorksBody =>
      'Grænsen afhænger af et estimat af de synkroniseringer med skyen, som denne konto har foretaget i løbet af måneden. Offlinebrug alene skaber ikke nye handlinger i skyen. Annoncer vises højst én gang om dagen, kun i Oversigt, og aldrig mens du gemmer eller eksporterer dine data.';

  @override
  String get adLabel => 'Annonce';

  @override
  String get devToolsTitle => 'Udviklerværktøjer';

  @override
  String get devUnlockAll => 'Lås alt op — test-Plus';

  @override
  String get devSimulateFree => 'Simuler gratispakke';

  @override
  String get devSimulateExpired => 'Simuler udløbet Plus';

  @override
  String get devRestore => 'Gendan normal tilstand';

  @override
  String get devNoOverride => 'Ingen simulering aktiv';

  @override
  String get devApplied => 'Scenariet er også anvendt i Firestore-emulatoren';

  @override
  String get devIncomplete =>
      'Ufuldstændig simulering: Firestore-emulatoren bekræftede ikke testrettigheden. Serverreglerne ser ikke dette scenarie.';

  @override
  String get devNotice =>
      'Kun udviklingsbuilds med emulatoren: ingen betalinger, tokens eller kvitteringer.';

  @override
  String get settingsTitle => 'Indstillinger';

  @override
  String get settingsGuide => 'Se guiden igen';

  @override
  String get settingsShare => 'Del appen';

  @override
  String get settingsRate => 'Bedøm appen';

  @override
  String get settingsFeedback => 'Send feedback';

  @override
  String get settingsFaq => 'Ofte stillede spørgsmål';

  @override
  String get settingsShareFailed => 'Deling kunne ikke åbnes. Prøv igen';

  @override
  String get settingsRateFailed => 'Google Play kunne ikke åbnes. Prøv igen';

  @override
  String get guideAddTitle => 'Tilføj en vin';

  @override
  String get guideAddBody =>
      'Tryk på Tilføj for at lægge en flaske i din kælder. Navnet er nok til at starte.';

  @override
  String get guideLabelTitle => 'Læs etiketten';

  @override
  String get guideLabelBody =>
      'Under Tilføj kan du også fotografere etiketten: Vinoozy læser navn, årgang og oprindelsesbetegnelse, og du tjekker dem, før du gemmer.';

  @override
  String get guideTabsTitle => 'Oversigt, Kælder, Historik';

  @override
  String get guideTabsBody =>
      'Oversigten fortæller, hvilke vine du skal åbne nu, Kælderen viser dine flasker, og Historikken gemmer dem, du har drukket.';

  @override
  String get guideMenuTitle => 'Kældermenuen';

  @override
  String get guideMenuBody =>
      'Her finder du din profil, de personer, du deler kælderen med, de drukne vine og Indstillinger, hvor du kan se denne guide igen.';

  @override
  String get guideDone => 'Færdig';

  @override
  String guideStepOf(int step, int count) {
    return 'Trin $step af $count';
  }

  @override
  String get hintDashboard =>
      'Her ser du, hvilke vine der er klar til at drikke nu, og hvilke der hellere må vente.';

  @override
  String get hintHistory =>
      'Hver flaske, du drikker, havner her med din bedømmelse og dine noter.';

  @override
  String get hintAddWine =>
      'Start med navnet: årgang, type og oprindelsesbetegnelse gør drikkevinduet mere præcist.';

  @override
  String get shareAppSubject => 'Vinoozy, din vinkælder';

  @override
  String shareAppMessage(String link) {
    return 'Jeg holder styr på min vinkælder med Vinoozy: den fortæller mig, hvornår hver flaske er bedst. Prøv den: $link';
  }

  @override
  String get feedbackSubject => 'Feedback om Vinoozy';

  @override
  String get feedbackTechHeader => 'Tekniske data (slet dem ikke):';

  @override
  String get feedbackNoEmailTitle => 'Ingen mailapp';

  @override
  String feedbackNoEmailBody(String email) {
    return 'Der er ingen mailapp på denne telefon. Skriv til os på $email';
  }

  @override
  String get feedbackCopy => 'Kopiér';

  @override
  String get feedbackCopied => 'Adressen er kopieret';

  @override
  String get faqAddQuestion => 'Hvordan tilføjer jeg en vin manuelt?';

  @override
  String get faqAddAnswer =>
      'Tryk på Tilføj i Kælderen og derefter på Skriv. Kun navnet er påkrævet; årgang, type, land og oprindelsesbetegnelse forbedrer vurderingen. Gem, så ligger vinen i kælderen.';

  @override
  String get faqLabelQuestion =>
      'Hvordan læser jeg en etiket, også med Google Lens?';

  @override
  String get faqLabelAnswer =>
      'Tryk på Tilføj og fotografér for- og bagside: Vinoozy læser etiketten direkte på telefonen. I Google Lens markerer du teksten og deler den med Vinoozy, eller du kopierer den og bruger Indsæt fra Lens i formularen. Tjek altid felterne, før du gemmer.';

  @override
  String get faqWindowQuestion =>
      'Hvordan beregnes det bedste tidspunkt at drikke, og kan jeg ændre det?';

  @override
  String get faqWindowAnswer =>
      'Vinoozy vurderer et vindue (start, top, slut) ud fra vinens type, oprindelsesbetegnelse, årgang og niveau. Det er vejledende: opbevaringen betyder også noget. Åbn vinen og tryk på Ret for at sætte din egen dato, eller skift Niveau.';

  @override
  String get faqOfflineQuestion => 'Virker den uden internet?';

  @override
  String get faqOfflineAnswer =>
      'Ja. Du kan tilføje, redigere og drikke vine offline: alt gemmes på telefonen og synkroniseres med din konto, så snart forbindelsen er tilbage.';

  @override
  String get faqShareQuestion => 'Hvordan deler jeg min kælder?';

  @override
  String get faqShareAnswer =>
      'Åbn Personer i Kældermenuen og invitér nogen med deres Google-mailadresse, kun læse eller med redigering. Personen installerer Vinoozy og logger ind med den konto.';

  @override
  String get faqPlusQuestion =>
      'Hvad indeholder den gratis plan, og hvad er Plus?';

  @override
  String faqPlusAnswer(int limit) {
    return 'Den gratis plan omfatter op til $limit forskellige vine i kælderen, med enkelte annoncer kun i Oversigten. Vinoozy Plus fjerner grænsen og annoncerne.';
  }

  @override
  String get faqDrinkQuestion =>
      'Hvorfor registrere, hvad jeg drak, og hvordan det var?';

  @override
  String get faqDrinkAnswer =>
      'Historikken gemmer, hvad du har drukket, og hvor godt du kunne lide det. Når du angiver, hvordan flasken var (stadig for ung, lige tilpas, over toppunktet), retter Vinoozy vurderingen for den samme vin.';

  @override
  String get faqDeleteQuestion => 'Hvordan sletter jeg min konto?';

  @override
  String get faqDeleteAnswer =>
      'Åbn Profil og tryk på Slet konto. Du skal have forbindelse og logger derefter ind igen med Google for at bekræfte. Din kælder, Historik og delinger slettes for altid.';

  @override
  String get faqNotFound => 'Fandt du ikke svaret? Skriv til os';
}
