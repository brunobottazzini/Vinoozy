// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppLocalizationsSv extends AppLocalizations {
  AppLocalizationsSv([String locale = 'sv']) : super(locale);

  @override
  String get appTitle => 'Vinoozy';

  @override
  String get signInTagline => 'Din vinkällare, i rätt tid';

  @override
  String get signInWithGoogle => 'Fortsätt med Google';

  @override
  String get signInInProgress => 'Loggar in';

  @override
  String get signInFailed => 'Inloggningen misslyckades';

  @override
  String get signInNeedsNetwork =>
      'Du behöver vara ansluten första gången du loggar in';

  @override
  String get signInSessionExpired => 'Din session har gått ut: logga in igen';

  @override
  String get retry => 'Försök igen';

  @override
  String get cancel => 'Avbryt';

  @override
  String blockedMessage(String email) {
    return 'Det finns ändringar av $email som ännu inte har sparats i molnet: logga in med det kontot och anslut till nätet';
  }

  @override
  String blockedSignInWith(String email) {
    return 'Logga in med $email';
  }

  @override
  String blockedDiscard(String email) {
    return 'Ta bort osparade ändringar av $email';
  }

  @override
  String get discardDialogTitle => 'Ta bort ändringarna?';

  @override
  String discardDialogBody(int count, String email) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count viner av $email finns ännu inte i molnet och tas bort från den här telefonen.',
      one:
          '1 vin av $email finns ännu inte i molnet och tas bort från den här telefonen.',
    );
    return '$_temp0';
  }

  @override
  String get discardConfirm => 'Ta bort';

  @override
  String get resetFailed => 'Det gick inte att rensa data på den här telefonen';

  @override
  String get restartRequired => 'Starta om appen för att slutföra';

  @override
  String get restartCloseApp => 'Stäng appen';

  @override
  String get startupFailed => 'Appen kunde inte starta';

  @override
  String get cellarTitle => 'Källare';

  @override
  String get defaultCellarName => 'Min källare';

  @override
  String get cellarLoading => 'Förbereder källaren';

  @override
  String get cellarSetupFailed => 'Det gick inte att förbereda källaren';

  @override
  String get cellarEmpty => 'Din källare är tom';

  @override
  String get addWine => 'Lägg till';

  @override
  String get estimatePending => 'Uppskattning på väg';

  @override
  String get noVintage => 'Utan årgång';

  @override
  String bottleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count flaskor',
      one: '1 flaska',
    );
    return '$_temp0';
  }

  @override
  String get syncInProgress => 'Synkroniserar';

  @override
  String get syncOffline => 'Offline - synkronisering väntar';

  @override
  String writeRejected(String name) {
    return 'Ändringen är inte tillåten: $name';
  }

  @override
  String get saveFailed => 'Det gick inte att spara, försök igen';

  @override
  String wineNotSaved(String name) {
    return 'Vinet $name sparades inte i molnet';
  }

  @override
  String get addAgain => 'Lägg till igen';

  @override
  String get ignore => 'Ignorera';

  @override
  String get addWineTitle => 'Skriv';

  @override
  String get wineNameLabel => 'Vin';

  @override
  String get vintageLabel => 'Årgång';

  @override
  String get quantityLabel => 'Antal';

  @override
  String get decreaseQuantity => 'Minska antalet';

  @override
  String get increaseQuantity => 'Öka antalet';

  @override
  String get save => 'Spara';

  @override
  String get nameRequired => 'Skriv vinets namn';

  @override
  String get nameTooLong => 'Högst 120 tecken';

  @override
  String vintageRange(String year) {
    return 'Årgång mellan 1900 och $year';
  }

  @override
  String get offAttribution => 'Data från Open Food Facts (ODbL)';

  @override
  String get dashboardTitle => 'Översikt';

  @override
  String dashboardTotalBottles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count flaskor i källaren',
      one: '1 flaska i källaren',
    );
    return '$_temp0';
  }

  @override
  String get dashboardSyncing => 'Synkroniserar källaren…';

  @override
  String get dashboardAddFirstWine => 'Lägg till ditt första vin';

  @override
  String get drinkSoonTitle => 'Drick snart';

  @override
  String get drinkSoonEmpty => 'Inga flaskor behöver drickas snart';

  @override
  String drinkSoonUntil(String year) {
    return 'senast $year';
  }

  @override
  String drinkSoonSeeAll(int count) {
    return 'Visa alla ($count)';
  }

  @override
  String get statusChartTitle => 'Flaskornas status';

  @override
  String get statusWaiting => 'bör vänta';

  @override
  String get statusReady => 'drickfärdig';

  @override
  String get statusDrinkSoon => 'drick snart';

  @override
  String get statusPastWindow => 'fönstret passerat';

  @override
  String toEstimateNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count flaskor utan uppskattning',
      one: '1 flaska utan uppskattning',
    );
    return '$_temp0';
  }

  @override
  String chartBarValue(String label, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count flaskor',
      one: '1 flaska',
    );
    return '$label: $_temp0';
  }

  @override
  String chartDescription(String title, String values) {
    return '$title: $values';
  }

  @override
  String get openListHint => 'Öppna listan';

  @override
  String get peakChartTitle => 'Toppår';

  @override
  String get peakPast => 'toppen passerad';

  @override
  String get peakBeyond => 'senare';

  @override
  String get breakdownTypeTitle => 'Flaskor per typ';

  @override
  String get breakdownRegionTitle => 'Flaskor per region';

  @override
  String get breakdownType => 'Typ';

  @override
  String get breakdownRegion => 'Region';

  @override
  String get familyRed => 'rött';

  @override
  String get familyWhite => 'vitt';

  @override
  String get familyRose => 'rosé';

  @override
  String get familySparkling => 'mousserande';

  @override
  String get familySweet => 'sött';

  @override
  String get breakdownUnspecified => 'ej angivet';

  @override
  String get breakdownOtherRegions => 'övriga';

  @override
  String get ok => 'OK';

  @override
  String get cellarMenu => 'Källarmeny';

  @override
  String get sharingPeopleTitle => 'Personer';

  @override
  String get sharingInviteTitle => 'Bjud in en person';

  @override
  String get sharingEmailLabel => 'Googles e-postadress';

  @override
  String get sharingPermissionRead => 'Endast läsa';

  @override
  String get sharingPermissionReadHint =>
      'Ser viner, uppskattningar, översikt och druckna flaskor';

  @override
  String get sharingPermissionEdit => 'Kan redigera';

  @override
  String get sharingPermissionEditHint =>
      'Lägger också till och ändrar viner och noterar druckna flaskor';

  @override
  String get sharingRoleOwner => 'ägare';

  @override
  String get sharingInviteButton => 'Bjud in';

  @override
  String sharingPlacesUsed(int used, int max) {
    return '$used/$max personer';
  }

  @override
  String get sharingInvalidEmail => 'Ange en giltig e-postadress';

  @override
  String get sharingSelfInvite => 'Du kan inte bjuda in dig själv';

  @override
  String get sharingAlreadyInvited => 'Den här personen är redan inbjuden';

  @override
  String sharingLimitReached(int max) {
    return 'Du har nått gränsen på $max personer';
  }

  @override
  String get sharingNotOwner =>
      'Du kan inte ändra delningen av den här källaren';

  @override
  String get sharingNotFound => 'Den här personen finns inte längre i listan';

  @override
  String get sharingFailed => 'Det gick inte, försök igen';

  @override
  String get sharingInviteFailed => 'Inbjudan misslyckades. Försök igen';

  @override
  String get sharingOfflineHint =>
      'Du behöver vara ansluten för att hantera delning';

  @override
  String get sharingStatusInvited => 'inbjuden';

  @override
  String get sharingStatusActive => 'aktiv';

  @override
  String get sharingStatusRevoked => 'återkallad';

  @override
  String get sharingStatusLeft => 'har lämnat';

  @override
  String sharingMemberSemantics(String name, String permission, String status) {
    return '$name, $permission, $status';
  }

  @override
  String get sharingClosedSection => 'Avslutad åtkomst';

  @override
  String get sharingNobody => 'Ingen annan ser den här källaren ännu';

  @override
  String sharingChangePermission(String name) {
    return 'Ändra behörighet för $name';
  }

  @override
  String get sharingRevoke => 'Återkalla';

  @override
  String sharingRevokeTitle(String name) {
    return 'Återkalla åtkomsten för $name?';
  }

  @override
  String sharingRevokeConfirmLabel(String name) {
    return 'Skriv $name för att bekräfta';
  }

  @override
  String get sharingRevokeDisabledHint => 'Aktiveras när namnet stämmer';

  @override
  String get sharingReinvite => 'Bjud in igen';

  @override
  String get sharingDeleteForGood => 'Ta bort permanent';

  @override
  String sharingOwnedBy(String owner) {
    return 'Källare som tillhör $owner';
  }

  @override
  String get sharingYourCellar => 'Din källare';

  @override
  String sharingYourPermission(String permission) {
    return 'Din behörighet: $permission';
  }

  @override
  String sharingSwitcherSemantics(String cellar, String permission) {
    return '$cellar, $permission. Tryck för att byta källare';
  }

  @override
  String get sharingLeave => 'Lämna den här källaren';

  @override
  String sharingLeaveTitle(String owner) {
    return 'Lämna källaren som tillhör $owner?';
  }

  @override
  String sharingLeaveBody(String owner) {
    return 'Du kommer inte längre att se den. $owner kan bjuda in dig igen.';
  }

  @override
  String get sharingLeaveConfirm => 'Lämna';

  @override
  String sharingSharedNotice(String owner) {
    return '$owner har delat sin källare med dig';
  }

  @override
  String sharingAccessLost(String owner) {
    return 'Du har inte längre åtkomst till källaren som tillhör $owner';
  }

  @override
  String sharingWritesLost(String owner) {
    return 'Vissa ändringar i källaren som tillhör $owner sparades inte eftersom du inte längre har åtkomst';
  }

  @override
  String get sharingSomeone => 'någon';

  @override
  String get sharingShareSubject => 'Inbjudan till Vinoozy';

  @override
  String sharingShareMessage(
    String owner,
    String cellar,
    String link,
    String email,
  ) {
    return '$owner har bjudit in dig till källaren ”$cellar” i Vinoozy. Installera appen från $link och logga in med Google-kontot $email: använd exakt den här adressen.';
  }

  @override
  String get cellarSearchHint => 'Sök på namn eller producent';

  @override
  String get cellarFilterStatus => 'Status';

  @override
  String get cellarFilterType => 'Typ';

  @override
  String get statusToEstimate => 'Utan uppskattning';

  @override
  String get filterTypeUnspecified => 'Ej angivet';

  @override
  String get cellarNoMatches => 'Inget vin med de här filtren';

  @override
  String get cellarClearFilters => 'Rensa filter';

  @override
  String get cellarArchiveTitle => 'Druckna';

  @override
  String get cellarArchiveEmpty => 'Inga urdruckna viner ännu';

  @override
  String get cellarArchiveFailed =>
      'Det gick inte att läsa in de urdruckna vinerna';

  @override
  String get wineDrink => 'Drucken';

  @override
  String wineDrinkTooltip(String name) {
    return 'Markera en flaska $name som drucken';
  }

  @override
  String confidenceLabel(String level) {
    return 'Säkerhet: $level';
  }

  @override
  String get confidenceHigh => 'hög';

  @override
  String get confidenceMedium => 'medel';

  @override
  String get confidenceLow => 'låg';

  @override
  String get windowStartLabel => 'Start';

  @override
  String get windowPeakLabel => 'Topp';

  @override
  String get windowEndLabel => 'Slut';

  @override
  String estimateSourceLabel(String source) {
    return 'Källa: $source';
  }

  @override
  String get estimateSourceCatalog => 'vindatabas';

  @override
  String get estimateSourceType => 'uppskattning för typen';

  @override
  String get estimateSourceCorrected =>
      'uppskattning justerad efter dina druckna flaskor';

  @override
  String get estimateDisclaimer =>
      'Ungefärlig uppskattning: den beror också på hur flaskan har förvarats';

  @override
  String get estimateUnavailable => 'Ingen uppskattning tillgänglig';

  @override
  String get pairingsTitle => 'Passar till';

  @override
  String get pairingsGeneric => 'allmänna matförslag för typen';

  @override
  String get pairingBraisedRedMeat => 'Bräserat rött kött';

  @override
  String get pairingGrilledRedMeat => 'Grillat rött kött';

  @override
  String get pairingGame => 'Vilt';

  @override
  String get pairingRoastPoultry => 'Stekt fågel';

  @override
  String get pairingPoultry => 'Fågel';

  @override
  String get pairingPork => 'Fläsk';

  @override
  String get pairingCuredMeats => 'Charkuterier';

  @override
  String get pairingPastaMeatSauce => 'Pasta med köttsås';

  @override
  String get pairingMushroomsTruffle => 'Svamp och tryffel';

  @override
  String get pairingAgedCheese => 'Lagrad ost';

  @override
  String get pairingFreshCheese => 'Färskost';

  @override
  String get pairingBlueCheese => 'Blåmögelost';

  @override
  String get pairingFish => 'Fisk';

  @override
  String get pairingSeafood => 'Skaldjur';

  @override
  String get pairingRawSeafood => 'Rå fisk och skaldjur';

  @override
  String get pairingFriedFood => 'Friterat';

  @override
  String get pairingVegetables => 'Grönsaker';

  @override
  String get pairingRisotto => 'Risotto';

  @override
  String get pairingPizza => 'Pizza';

  @override
  String get pairingAperitif => 'Aperitif';

  @override
  String get pairingPastries => 'Bakverk';

  @override
  String get pairingDryBiscuits => 'Torra småkakor';

  @override
  String get pairingChocolate => 'Choklad';

  @override
  String get pairingDriedFruit => 'Nötter och torkad frukt';

  @override
  String get pairingSpicyDishes => 'Kryddiga rätter';

  @override
  String get recentDrinksTitle => 'Senast druckna';

  @override
  String get noDrinksYet => 'Inget drucket ännu';

  @override
  String get wineEdit => 'Redigera';

  @override
  String get wineDelete => 'Ta bort';

  @override
  String get wineFinished => 'Slut: inga flaskor kvar';

  @override
  String get wineLoadFailed => 'Det gick inte att öppna vinet';

  @override
  String get wineNotFound => 'Det här vinet finns inte längre';

  @override
  String drinkDone(String name) {
    return 'Markerad som drucken: $name';
  }

  @override
  String get drinkUndo => 'Ångra';

  @override
  String get drinkAddNotes => 'Lägg till betyg och anteckningar';

  @override
  String get nothingToUndo => 'Det finns inget mer att ångra';

  @override
  String get cellarUndoRejected =>
      'Det gick inte att ångra: flaskan är fortfarande markerad som drucken';

  @override
  String get cellarDeleteFailed =>
      'Borttagningen är inte klar ännu: den slutförs så snart som möjligt';

  @override
  String get duplicateFull =>
      'Det här vinet har redan 99 flaskor: det går inte att lägga till fler.';

  @override
  String get recordSheetTitle => 'Betyg och anteckningar';

  @override
  String get recordRatingLabel => 'Betyg';

  @override
  String ratingStar(int n) {
    return 'Betyg $n av 5';
  }

  @override
  String get recordNotesLabel => 'Anteckningar';

  @override
  String get recordNotesTooLong => 'Högst 1000 tecken';

  @override
  String recordDateLabel(String date) {
    return 'Datum: $date';
  }

  @override
  String get recordDateInvalid =>
      'Datumet får inte ligga i framtiden eller före årgången';

  @override
  String get recordConditionTitle => 'Hur var det?';

  @override
  String get conditionTooYoung => 'Fortfarande för ungt';

  @override
  String get conditionJustRight => 'Precis lagom';

  @override
  String get conditionPastPeak => 'Förbi toppen';

  @override
  String get recordNoCondition => 'Inget svar';

  @override
  String get producerLabel => 'Producent (valfritt)';

  @override
  String get producerTooLong => 'Högst 120 tecken';

  @override
  String producerAddNew(String name) {
    return 'Lägg till ”$name” som ny producent';
  }

  @override
  String get wineTypeLabel => 'Typ';

  @override
  String get typeRedLight => 'Lätt rött';

  @override
  String get typeRedStructured => 'Fylligt rött';

  @override
  String get typeWhite => 'Vitt';

  @override
  String get typeRose => 'Rosé';

  @override
  String get typeSparklingClassic => 'Mousserande, traditionell metod';

  @override
  String get typeSparklingTank => 'Mousserande, tankmetod';

  @override
  String get typeSweet => 'Sött';

  @override
  String get typeFortified => 'Starkvin';

  @override
  String get suggestionFromCellar => 'I din källare';

  @override
  String get suggestionsLabel => 'Förslag';

  @override
  String get duplicateTitle => 'Finns redan i källaren';

  @override
  String duplicateBody(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count flaskor',
      one: '1 flaska',
      zero: 'inga flaskor',
    );
    return '$name finns redan, med $_temp0. Vill du lägga de nya flaskorna där?';
  }

  @override
  String duplicateAdd(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Lägg till $count flaskor',
      one: 'Lägg till 1 flaska',
    );
    return '$_temp0';
  }

  @override
  String get duplicateBanner => 'Möjlig dubblett';

  @override
  String get duplicateMerge => 'Slå ihop';

  @override
  String get duplicateDeleteHint =>
      'Ta bort den här posten om den är en dubblett';

  @override
  String get mergeTitle => 'Slå ihop de två posterna?';

  @override
  String get mergeBody =>
      'Flaskorna i den här posten flyttas till den äldre, sedan tas den här posten bort.';

  @override
  String get editWineTitle => 'Redigera vin';

  @override
  String get editDuplicate =>
      'Det finns redan ett vin med samma namn, producent och årgång';

  @override
  String deleteWineTitle(String name) {
    return 'Ta bort $name?';
  }

  @override
  String get deleteWineBody =>
      'Vinet och alla noteringar om druckna flaskor tas bort. Det går inte att ångra.';

  @override
  String get historyTitle => 'Historik';

  @override
  String get historyEmpty => 'Här hittar du flaskorna du har druckit';

  @override
  String get historyLoadFailed => 'Det gick inte att läsa in historiken';

  @override
  String drankOnLabel(String date) {
    return 'Drucken den $date';
  }

  @override
  String get addChoiceTitle => 'Lägg till ett vin';

  @override
  String get addChoicePhoto => 'Ta ett foto';

  @override
  String get addChoiceImport => 'Importera ett foto';

  @override
  String get addChoiceWrite => 'Skriv';

  @override
  String get labelReading => 'Jag läser etiketten…';

  @override
  String get labelRecognized => 'Jag kände igen:';

  @override
  String get labelCorrect => 'Rätta';

  @override
  String get labelConfirm => 'Bekräfta';

  @override
  String get labelUnreadable => 'Jag kan inte läsa etiketten';

  @override
  String get labelWriteByHand => 'Skriv själv';

  @override
  String get labelNotFound => 'Jag hittade inte vinet: kontrollera uppgifterna';

  @override
  String get labelCameraDenied =>
      'För att läsa etiketten behöver jag åtkomst till kameran';

  @override
  String get labelPhotosDenied =>
      'För att läsa etiketten behöver jag åtkomst till bilderna';

  @override
  String get labelOpenSettings => 'Öppna inställningar';

  @override
  String get labelCameraUnavailable => 'Kameran är inte tillgänglig';

  @override
  String get labelBarcodeNotFound =>
      'Jag läste streckkoden men hittar inte vinet';

  @override
  String get labelBarcodeFrontHint => 'Ta ett foto av etikettens framsida';

  @override
  String get labelSharedNotAllowed =>
      'Du kan inte lägga till viner i den här källaren';

  @override
  String get labelSharedFirstOnly => 'Jag använde bara det första fotot';

  @override
  String get labelSharedExpired =>
      'Det delade fotot kunde inte läsas: dela det igen';

  @override
  String get labelReplaceTitle =>
      'Du har ett osparat vin. Vill du läsa det nya fotot?';

  @override
  String get labelReplaceRead => 'Läs det nya fotot';

  @override
  String get labelReplaceKeep => 'Fortsätt med det öppna';

  @override
  String get labelWineAdded => 'Vinet har lagts till i källaren';

  @override
  String get onboardingPage1Title => 'Din vinkällare i fickan';

  @override
  String get onboardingPage1Body =>
      'Lägg till dina flaskor genom att skriva in dem eller med ett foto av etiketten, även utan nät.';

  @override
  String get onboardingPage2Title => 'I rätt tid';

  @override
  String get onboardingPage2Body =>
      'Vinoozy uppskattar när varje vin är som bäst och talar om vilka du bör öppna först.';

  @override
  String get onboardingPage3Title => 'Tillsammans';

  @override
  String get onboardingPage3Body =>
      'Dela din källare med upp till två personer och spara historiken för varje flaska du dricker.';

  @override
  String get onboardingSkip => 'Hoppa över';

  @override
  String get onboardingNext => 'Nästa';

  @override
  String get onboardingStart => 'Börja';

  @override
  String onboardingPageOf(int page) {
    return 'Sida $page av 3';
  }

  @override
  String get profileTitle => 'Profil';

  @override
  String get profilePhoto => 'Profilbild';

  @override
  String get profileSignOut => 'Logga ut';

  @override
  String get profileDeleteAccount => 'Radera konto';

  @override
  String get profilePrivacy => 'Integritetspolicy';

  @override
  String get profilePrivacyBody =>
      'Du kan läsa integritetspolicyn på den här adressen:';

  @override
  String get profileOpenLink => 'Öppna i webbläsaren';

  @override
  String get profileOpenLinkFailed =>
      'Det gick inte att öppna sidan. Du kan kopiera länken och öppna den i din webbläsare.';

  @override
  String get profileCopyLink => 'Kopiera länk';

  @override
  String get profileLinkCopied => 'Länken har kopierats';

  @override
  String get close => 'Stäng';

  @override
  String get signOutConfirmTitle => 'Vill du logga ut?';

  @override
  String signOutPendingWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Du har $count ändringar som inte har sparats ännu. Om du loggar ut och ett annat konto loggar in går de förlorade.',
      one: 'Du har 1 ändring som inte har sparats ännu. Om du loggar ut och ett annat konto loggar in går den förlorad.',
    );
    return '$_temp0';
  }

  @override
  String get signOutStayAndSync => 'Stanna och synkronisera';

  @override
  String get signOutAnyway => 'Logga ut ändå';

  @override
  String get syncAllSaved => 'Allt är sparat';

  @override
  String syncStillPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ändringar återstår att spara: kontrollera nätet',
      one: '1 ändring återstår att spara: kontrollera nätet',
    );
    return '$_temp0';
  }

  @override
  String get signOutFailed => 'Det gick inte att logga ut. Försök igen';

  @override
  String get signInAccountDeleted => 'Kontot har raderats';

  @override
  String get deleteAccountIntro => 'Det här raderas för gott:';

  @override
  String get deleteAccountItemCellar =>
      'Din källare, med dess viner och historik';

  @override
  String get deleteAccountItemShares =>
      'Delningarna du har gett: de inbjudna personerna förlorar åtkomsten';

  @override
  String get deleteAccountItemMemberships =>
      'Ditt deltagande i andras källare: dina druckna flaskor finns kvar där utan ditt namn';

  @override
  String get deleteAccountItemProfile => 'Din profil';

  @override
  String deleteAccountPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Du har $count ändringar som inte har sparats ännu: de sparas och raderas sedan med resten',
      one: 'Du har 1 ändring som inte har sparats ännu: den sparas och raderas sedan med resten',
    );
    return '$_temp0';
  }

  @override
  String get deleteAccountConfirmWord => 'RADERA';

  @override
  String deleteAccountTypeWord(String word) {
    return 'Skriv $word för att bekräfta';
  }

  @override
  String get deleteAccountReauthHint =>
      'Sedan loggar du in igen med Google för att bekräfta att det är du.';

  @override
  String get deleteAccountForever => 'Radera för alltid';

  @override
  String get deleteAccountNeedsNetwork =>
      'Anslut till internet för att radera kontot';

  @override
  String get deleteAccountSameAccount =>
      'Raderingen kräver att du loggar in med samma konto';

  @override
  String get deletionTitle => 'Raderar kontot';

  @override
  String get deletionStepPreparePhone => 'Sparar väntande ändringar';

  @override
  String get deletionStepMarkStarted => 'Startar raderingen';

  @override
  String get deletionStepLeaveOtherCellars => 'Lämnar andras källare';

  @override
  String get deletionStepCloseOwnInvitations => 'Avslutar dina delningar';

  @override
  String get deletionStepDeleteWinesAndRecords => 'Raderar viner och historik';

  @override
  String get deletionStepDeleteCellar => 'Raderar källaren';

  @override
  String get deletionStepDeleteProfileAndUser => 'Raderar profilen och kontot';

  @override
  String get deletionStepCleanUpPhone => 'Rensar den här telefonen';

  @override
  String deletionStepAnnounce(int step, String label) {
    return 'Steg $step av 8: $label';
  }

  @override
  String deletionDeletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count viner och druckna flaskor raderade',
      one: '1 vin eller drucken flaska raderad',
    );
    return '$_temp0';
  }

  @override
  String get deletionResumeHint =>
      'En radering av det här kontot är inte klar. Logga in igen med Google för att slutföra den.';

  @override
  String get deletionContinue => 'Fortsätt';

  @override
  String get deletionOffline =>
      'Anslut till internet för att slutföra raderingen';

  @override
  String get deletionPendingWrites =>
      'Jag kan inte spara de väntande ändringarna. Försök igen';

  @override
  String get deletionFailed =>
      'Det gick inte att slutföra raderingen. Försök igen';

  @override
  String get uxCountryLabel => 'Land';

  @override
  String get uxCountryOther => 'Annat land…';

  @override
  String get uxCountryNone => 'Inget land';

  @override
  String get uxAllCountriesTitle => 'Alla länder och territorier';

  @override
  String get uxAllCountriesSearch => 'Sök efter ett land';

  @override
  String get uxAllCountriesRare => 'Ovanliga för vin';

  @override
  String get uxAllCountriesAll => 'Alla, från A till Ö';

  @override
  String get uxAllCountriesNone => 'Inget land hittades';

  @override
  String get uxRegionLabel => 'Region';

  @override
  String uxRegionOf(String country) {
    return 'Region · $country';
  }

  @override
  String get uxRegionOther => 'Annan region';

  @override
  String get uxRegionFieldLabel => 'Skriv regionen';

  @override
  String get uxRegionTooLong => 'Högst 120 tecken';

  @override
  String get uxDrinkAction => 'Drack en';

  @override
  String uxDrinkActionTooltip(String name) {
    return 'Jag har druckit en flaska $name';
  }

  @override
  String get uxDrinkActionDetail => 'Jag har druckit en flaska';

  @override
  String get uxDrinkSheetLabel => 'Bekräfta drucken flaska';

  @override
  String get uxDrinkSheetBottles => 'Flaskor';

  @override
  String uxDrinkSheetBottlesChange(int before, int after) {
    return 'Flaskor: från $before till $after';
  }

  @override
  String get uxDrinkSheetRating => 'Hur var det? (valfritt)';

  @override
  String uxDrinkSheetStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stjärnor av 5',
      one: '1 stjärna av 5',
    );
    return '$_temp0';
  }

  @override
  String get uxDrinkSheetConfirm => 'Ja, den är drucken';

  @override
  String get uxRemoveBottle => 'Ta bort en flaska utan notering';

  @override
  String get uxRemoveBottleTitle => 'Ta bort en flaska?';

  @override
  String uxRemoveBottleBody(String name) {
    return 'En flaska $name tas bort utan att noteras som drucken.';
  }

  @override
  String get uxRemoveBottleConfirm => 'Ta bort';

  @override
  String get uxIdealTitle => 'Bästa tidpunkt';

  @override
  String uxIdealUntil(String year) {
    return 'Rekommenderas till och med $year';
  }

  @override
  String uxIdealUntilPast(String year) {
    return 'Rekommenderas till och med $year: det har passerat';
  }

  @override
  String uxIdealBest(String start, String end) {
    return 'Som bäst från $start till $end';
  }

  @override
  String uxIdealBar(String start, String end) {
    return 'Drickfönster från $start till $end';
  }

  @override
  String get uxIdealDisclaimer =>
      '⚠︎ Ungefärligt: en uppskattning utifrån typ, appellation och årgång. Förvaringen och den enskilda flaskan kan ändra den.';

  @override
  String get uxIdealUnavailableHint =>
      'Ange årgång och typ för att få en uppskattning.';

  @override
  String uxDashboardDrinkNow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count att dricka nu',
      one: '1 att dricka nu',
    );
    return '$_temp0';
  }

  @override
  String get uxFamilyRed => 'Rött';

  @override
  String get uxFamilyWhite => 'Vitt';

  @override
  String get uxFamilyRose => 'Rosé';

  @override
  String get uxFamilySparkling => 'Mousserande';

  @override
  String get uxFamilySweet => 'Sött';

  @override
  String get labelBackTitle => 'Nu baksidan';

  @override
  String get labelBackHint =>
      'På baksidan finns oftast streckkoden, producenten och årgången: de hjälper till att hitta vinet.';

  @override
  String get labelBackTake => 'Fota baksidan';

  @override
  String get labelBackGallery => 'Välj från galleriet';

  @override
  String get labelBackSkip => 'Hoppa över';

  @override
  String get labelStepFront => 'Framsida';

  @override
  String get labelStepBack => 'Baksida';

  @override
  String get labelStepBarcode => 'Streckkod';

  @override
  String get labelStepDatabase => 'Vindatabas på telefonen';

  @override
  String get labelStepPending => 'Väntar';

  @override
  String get labelStepRunning => 'Arbetar…';

  @override
  String get labelStepDone => 'Klar';

  @override
  String get labelStepSkipped => 'Överhoppad';

  @override
  String get labelStepFailed => 'Går inte att läsa';

  @override
  String labelStepStatus(String step, String status) {
    return '$step: $status';
  }

  @override
  String get labelOnPhoneNote =>
      'Allt sker på telefonen: fotona skickas inte till någon.';

  @override
  String get labelBackUnreadable => 'Baksidan går inte att läsa';

  @override
  String get labelSourceOffline => 'Från databasen på telefonen · offline';

  @override
  String get labelSourceCatalog => 'Från katalogen';

  @override
  String get labelSourceOnline => 'Från Open Food Facts · online';

  @override
  String get labelNotThis => 'Inte det här';

  @override
  String get labelOffAttribution => 'Data från Open Food Facts, ODbL-licens';

  @override
  String get labelCandidatesTitle => 'Vilket av dessa?';

  @override
  String labelCandidatesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count liknande viner',
      one: '1 liknande vin',
    );
    return '$_temp0';
  }

  @override
  String get labelCandidatesNone => 'Inget av dessa';

  @override
  String get labelChipOffline => 'offline';

  @override
  String get labelChipOnline => 'online';

  @override
  String get labelChipCatalog => 'katalog';

  @override
  String get labelNoProducer => 'producent ej angiven';

  @override
  String get labelNoMatch => 'Jag läste etiketten men känner inte igen vinet';

  @override
  String get labelReadText => 'Läst text';

  @override
  String get labelSearchOnline => 'Sök online';

  @override
  String get labelOpenLens => 'Öppna i Google Lens';

  @override
  String get labelLensLastResort =>
      'Google Lens är sista utvägen: fotot skickas till Google-appen bara om du bekräftar.';

  @override
  String get labelLensTitle => 'Öppna i Google Lens?';

  @override
  String get labelLensBody =>
      'Fotot av framsidan skickas till Google-appen på din telefon, eller till appen du väljer, som kan spara en kopia enligt sina egna regler. Vinoozy får inte resultaten: kom tillbaka hit för att välja eller skriva in vinet.';

  @override
  String get labelLensConfirm => 'Öppna Google Lens';

  @override
  String get labelLensFailed =>
      'Jag kan varken öppna Google Lens eller delningsmenyn';

  @override
  String get onlineSearchTitle => 'Sök online';

  @override
  String get onlineSearchSubtitle => 'Open Food Facts · endast viner';

  @override
  String get onlineSearchField => 'Sökord';

  @override
  String get onlineSearchHint => 'Du kan ändra orden innan du söker.';

  @override
  String get onlineSearchEmptyField => 'Skriv minst ett ord';

  @override
  String get onlineSearchButton => 'Sök';

  @override
  String get onlineSearchLoading => 'Söker…';

  @override
  String onlineSearchResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count resultat',
      one: '1 resultat',
    );
    return '$_temp0';
  }

  @override
  String get onlineSearchEmpty =>
      'Inget vin hittades: prova andra ord eller ”Skriv själv”.';

  @override
  String get onlineSearchOffline =>
      'Inget nät: jag söker bara i databasen på telefonen.';

  @override
  String get onlineSearchRateLimited =>
      'Onlinesökning är inte tillgänglig just nu, försök igen om några minuter.';

  @override
  String get onlineSearchUnavailable =>
      'Onlinesökning är inte aktiv i den här versionen av appen: jag söker bara i databasen på telefonen.';

  @override
  String get aboutTitle => 'Om';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aboutDbTitle => 'Vindatabas';

  @override
  String aboutDbCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count viner',
      one: '1 vin',
    );
    return '$_temp0';
  }

  @override
  String aboutDbDate(String date) {
    return 'Export från Open Food Facts från $date';
  }

  @override
  String get aboutDbSample =>
      'Exempeldatabas: några handskrivna testviner, inte data från Open Food Facts.';

  @override
  String get aboutDbLoading => 'Öppnar vindatabasen…';

  @override
  String get aboutDbUnavailable =>
      'Vindatabasen är inte tillgänglig i den här versionen';

  @override
  String aboutDbSource(String url) {
    return 'Den härledda databasen och verktyget som bygger den finns i det offentliga repot: $url';
  }

  @override
  String get aboutLicenseTitle => 'Licenser';

  @override
  String get aboutLicense =>
      'Innehåller information från Open Food Facts, som tillhandahålls under Open Database License (ODbL). Enskilt innehåll omfattas av Database Contents License (DbCL).';

  @override
  String get aboutPrivacyTitle => 'Etikettfoton';

  @override
  String get aboutPrivacy =>
      'Etikettfoton läses på telefonen och raderas när du lämnar resultatet. De lämnar telefonen bara om du trycker på ”Öppna i Google Lens” och bekräftar.';

  @override
  String get aboutAppellationsTitle => 'Appellationer';

  @override
  String get aboutAppellationsSource =>
      'Appellationer: registret eAmbrosia (EU) och officiella nationella register.';

  @override
  String get aboutAppellationsSample =>
      'Exempeltabell: ett handskrivet utdrag ur registren, tills de riktiga registren har hämtats.';

  @override
  String get denominationLabel => 'Appellation';

  @override
  String get denominationTooLong => 'Högst 120 tecken';

  @override
  String get autofillFilledNotice =>
      'Ifyllt från etiketten: kontrollera och spara';

  @override
  String get autofillPastedNotice =>
      'Ifyllt från texten: kontrollera och spara';

  @override
  String get autofillFromText => '✦ från texten';

  @override
  String get autofillFromTextSemantics => 'ifyllt från etiketten';

  @override
  String get autofillClear => 'Rensa';

  @override
  String get autofillLens => 'Lens';

  @override
  String get autofillClearTitle => 'Rensa formuläret?';

  @override
  String get autofillClearBody =>
      'Du har också skrivit själv i några fält. ”Rensa” tömmer namn, producent, appellation, årgång, typ, land, region och nivå. Antalet står kvar.';

  @override
  String get autofillClearConfirm => 'Rensa';

  @override
  String get autofillCleared => 'Formuläret har rensats';

  @override
  String get autofillPasteTitle => 'Har du texten från Google Lens?';

  @override
  String get autofillPasteHint =>
      'Markera etikettens text i Lens och tryck på ”Kopiera”, kom sedan tillbaka hit.';

  @override
  String get autofillPaste => 'Klistra in från Lens';

  @override
  String get autofillOpenLens => 'Från Google Lens';

  @override
  String get autofillOpenLensSemantics => 'öppnar Google Lens';

  @override
  String get autofillClipboardEmpty => 'Det finns ingen text i urklipp';

  @override
  String get autofillNoNewFields =>
      'Jag hittade inga uppgifter att lägga till i texten';

  @override
  String get autofillFromLens => 'Formuläret har fyllts i från Lens-texten';

  @override
  String get autofillShareEmpty => 'Ingen text togs emot';

  @override
  String get autofillShareUseTitle => 'Använda texten för de tomma fälten?';

  @override
  String get autofillShareUse => 'Använd';

  @override
  String get autofillShareIgnore => 'Ignorera';

  @override
  String get addChoiceLens => 'Från Google Lens';

  @override
  String get addChoicePhotoHint =>
      'Fram- och baksida: Vinoozy läser etiketten.';

  @override
  String get addChoiceLensHint =>
      'Öppnar Lens: sikta, markera texten och tryck på Dela → Vinoozy.';

  @override
  String get addChoiceImportHint =>
      'Ett foto av etiketten som du redan har tagit.';

  @override
  String get addChoiceWriteHint => 'Tomt formulär, med ”Klistra in från Lens”.';

  @override
  String get lensInstructionsTitle => 'Google Lens går inte att öppna härifrån';

  @override
  String get lensInstructionsStep1 =>
      'Öppna Google Lens och sikta på etiketten';

  @override
  String get lensInstructionsStep2 => 'Markera etikettens text';

  @override
  String get lensInstructionsStep3 => 'Tryck på Dela → Vinoozy';

  @override
  String get lensInstructionsOk => 'Jag förstår';

  @override
  String get levelLabel => 'Nivå';

  @override
  String get levelEveryday => 'Vardag (billigt)';

  @override
  String get levelGood => 'Bra';

  @override
  String get levelAging => 'För lagring';

  @override
  String get levelNone => 'Ingen';

  @override
  String get levelEverydayShort => 'drick tidigt';

  @override
  String get levelGoodShort => 'normal uppskattning';

  @override
  String get levelAgingShort => 'håller längre';

  @override
  String get levelSuggested => 'föreslagen';

  @override
  String levelSuggestedReason(String qualifier) {
    return 'Föreslagen eftersom det står ”$qualifier” i namnet: den sparas så om du inte ändrar. Välj en annan eller tryck på ”Ingen”.';
  }

  @override
  String levelSuggestedSemantics(String qualifier) {
    return 'föreslagen, eftersom det står $qualifier i namnet';
  }

  @override
  String levelOptionSemantics(String option, int index, int count) {
    return 'Nivå, $option, $index av $count';
  }

  @override
  String get levelWhatChanges => 'Vad som ändras';

  @override
  String get levelEverydayExamples =>
      'Fönstret blir kortare. T.ex. husets vin, Lambrusco, enkel Prosecco, Bardolino, Vinho Verde.';

  @override
  String get levelGoodExamples =>
      'Den normala uppskattningen, och det som gäller när du inte väljer något. T.ex. Chianti Classico, Barbera d\'Asti Superiore, Rioja Crianza, Côtes du Rhône.';

  @override
  String get levelAgingExamples =>
      'Fönstret blir längre. T.ex. Barolo, Brunello, Amarone, Bordeaux Grand Cru, Rioja Gran Reserva, Vintage Port.';

  @override
  String levelPreviewBefore(String start, String end) {
    return 'Före $start – $end';
  }

  @override
  String levelPreviewWith(String level, String start, String end) {
    return 'Med ”$level” $start – $end';
  }

  @override
  String levelPreviewNow(String start, String end) {
    return 'Drickfärdig $start – till $end';
  }

  @override
  String levelDetail(String level) {
    return 'Nivå: $level';
  }

  @override
  String get overrideCorrect => 'Rätta';

  @override
  String get overrideRestore => 'Återställ uppskattning';

  @override
  String get overrideCorrectedByYou => 'rättad av dig';

  @override
  String overrideAppEstimate(String year) {
    return 'Appens uppskattning: till $year';
  }

  @override
  String get overrideSheetTitle => 'Rekommenderas till och med';

  @override
  String overrideSheetHint(String start) {
    return 'Välj året. Det får inte ligga före ”Drickfärdig från $start”.';
  }

  @override
  String overridePeakNotice(String peak) {
    return 'Om du väljer ett år före $peak (som bäst) flyttas även ”som bäst” till samma år.';
  }

  @override
  String get overrideMore => 'fler…';

  @override
  String get overrideSave => 'Spara rättelse';

  @override
  String overrideRestoreTitle(String year) {
    return 'Gå tillbaka till appens uppskattning (till $year)?';
  }

  @override
  String get overrideRestoreConfirm => 'Återställ';

  @override
  String get overrideSaved => 'Rättelsen har sparats';

  @override
  String get overrideRestored => 'Uppskattningen har återställts';

  @override
  String get estimateSourceCorrectedByYou => 'rättad av dig';

  @override
  String estimateFromDenomination(String name) {
    return 'Uppskattning utifrån appellationen $name';
  }

  @override
  String estimateFromDenominationQualifier(String name, String qualifier) {
    return 'Uppskattning utifrån appellationen $name, $qualifier';
  }

  @override
  String estimateFromGrape(String name) {
    return 'Uppskattning utifrån druvan $name';
  }

  @override
  String get estimateFromType => 'Uppskattning utifrån vintypen';

  @override
  String get autofillReading => 'Jag läser texten…';

  @override
  String get guideChip => 'Guidad kontroll';

  @override
  String guideProgress(int n, int total) {
    return 'Fråga $n av $total';
  }

  @override
  String get guideClose => 'Stäng';

  @override
  String get guideIsDenomination => 'är det appellationen?';

  @override
  String get guideIsProducer => 'är det producenten?';

  @override
  String get guideIsName => 'är det vinets namn?';

  @override
  String get guideIsVintage => 'Årgång';

  @override
  String guideAskDenomination(String value) {
    return 'Är $value appellationen?';
  }

  @override
  String guideAskProducer(String value) {
    return 'Är $value producenten?';
  }

  @override
  String guideAskName(String value) {
    return 'Är $value vinets namn?';
  }

  @override
  String get guideAskVintage => 'Vilken årgång är det?';

  @override
  String guideQuestionSemantics(int n, int total, String question) {
    return 'Fråga $n av $total: $question';
  }

  @override
  String get guideNoProposal => 'Jag hittade det inte i texten';

  @override
  String get guideYes => 'Ja';

  @override
  String get guideNo => 'Nej, ett annat';

  @override
  String get guideEdit => 'Redigera';

  @override
  String get guideSkip => 'Hoppa över';

  @override
  String get guideConfirm => 'Bekräfta';

  @override
  String get guideCancel => 'Avbryt';

  @override
  String guideRejected(String value) {
    return 'Inte ”$value”: här är nästa';
  }

  @override
  String get guideNoMore =>
      'Inga fler förslag: sätt ihop det själv eller hoppa över';

  @override
  String guideProposalAnnounce(String value) {
    return 'Förslag: $value';
  }

  @override
  String get guideComposeLabel =>
      'Eller sätt ihop det genom att trycka på ord i texten';

  @override
  String get guideComposePreview => 'Förhandsvisning';

  @override
  String get guideComposeEmpty => 'Tryck på ett eller flera ord';

  @override
  String get guideComposeLimit => 'Upp till 8 ord och 80 tecken';

  @override
  String guideTableMatchSemantics(String name) {
    return 'motsvarar $name';
  }

  @override
  String guideLine(int n, int total) {
    return 'Rad $n av $total';
  }

  @override
  String guideWordSelected(String word, int order) {
    return '$word, valt, $order';
  }

  @override
  String guideWordUnavailable(String word) {
    return '$word, inte tillgängligt';
  }

  @override
  String guideWordUsedFor(String word, String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'appellationen',
      'producer': 'producenten',
      'other': 'namnet',
    });
    return '$word, används för $_temp0';
  }

  @override
  String guideUsedMark(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'appellation',
      'producer': 'producent',
      'other': 'namn',
    });
    return '$_temp0';
  }

  @override
  String guideOtherYears(String years) {
    return 'Finns också i texten: $years';
  }

  @override
  String get guideWheelFromText => 'år som hittades i texten';

  @override
  String get guideWheelTypeYear => 'Skriv året';

  @override
  String guideWheelConfirm(String year) {
    return 'Bekräfta $year';
  }

  @override
  String get guideNoVintage => 'Utan årgång';

  @override
  String guideSkippedNotice(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'Appellationen hoppades över',
      'producer': 'Producenten hoppades över',
      'vintage': 'Årgången hoppades över',
      'other': 'Namnet hoppades över',
    });
    return '$_temp0: skriv själv eller fortsätt guiden';
  }

  @override
  String guideSkippedMany(int count) {
    return '$count fält hoppades över: skriv dem själv eller fortsätt guiden';
  }

  @override
  String get guideInvalidValue =>
      'Den här texten innehåller tecken som inte kan sparas';

  @override
  String get brandStudio => 'Bottazzini Softworks';

  @override
  String get suggestedMark => '✦ föreslagen';

  @override
  String suggestedSemantics(String field, String value) {
    return '$field, $value, föreslagen';
  }

  @override
  String get restoreSuggestion => 'Återställ förslag';

  @override
  String get restoreSuggestionDone => 'Förslaget har återställts';

  @override
  String get styleLabel => 'Stil';

  @override
  String styleGroupSemantics(String value, int index, int count) {
    return 'Stil, $value, $index av $count';
  }

  @override
  String get styleRedFresh => 'Friskt';

  @override
  String get styleRedMedium => 'Medel';

  @override
  String get styleRedAge => 'För lagring';

  @override
  String get styleRedLong => 'Lång lagring';

  @override
  String get styleWhiteFresh => 'Friskt';

  @override
  String get styleWhiteMedium => 'Medel';

  @override
  String get styleWhiteAge => 'För lagring';

  @override
  String get styleRoseFresh => 'Friskt';

  @override
  String get styleClassicFresh => 'Friskt';

  @override
  String get styleClassicAge => 'För lagring';

  @override
  String get styleTankFresh => 'Friskt';

  @override
  String get styleLambrusco => 'Lambrusco';

  @override
  String get styleSweetAromatic => 'Aromatiskt';

  @override
  String get styleSweetPassito => 'Torkade druvor';

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
  String get styleFortifiedOther => 'Annat';

  @override
  String get profileNameRFresh => 'Fruktigt rött';

  @override
  String get profileNameRMedium => 'Medelfylligt rött';

  @override
  String get profileNameRAge => 'Rött för lagring';

  @override
  String get profileNameRLong => 'Rött för lång lagring';

  @override
  String get profileNameWFresh => 'Friskt aromatiskt vitt';

  @override
  String get profileNameWMedium => 'Medelfylligt vitt';

  @override
  String get profileNameWAge => 'Vitt för lagring';

  @override
  String get profileNameRoseFresh => 'Frisk rosé';

  @override
  String get profileNameSpTank => 'Friskt mousserande, tankmetod';

  @override
  String get profileNameLamFresh => 'Frisk Lambrusco';

  @override
  String get profileNameSpClassic => 'Friskt mousserande, traditionell metod';

  @override
  String get profileNameSpClassicAge =>
      'Mousserande för lagring, traditionell metod';

  @override
  String get profileNameSwAromatic => 'Ungt aromatiskt sött vin';

  @override
  String get profileNameSwPassito => 'Sött vin av torkade druvor';

  @override
  String get profileNameSwBotrytis => 'Sött botrytisvin';

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
  String get profileNameFortUnknown => 'Starkvin, okänd stil';

  @override
  String get profileNameUnknown => 'Stilen kunde inte identifieras';

  @override
  String estimateFromProfile(String profile, String denomination) {
    return 'Uppskattning utifrån profilen $profile ($denomination)';
  }

  @override
  String estimateFromProfileType(String profile) {
    return 'Uppskattning utifrån profilen $profile, efter typ';
  }

  @override
  String estimateFromProfileGrape(String profile, String grape) {
    return 'Uppskattning utifrån profilen $profile, efter druvan $grape';
  }

  @override
  String get estimateFromEntryDateDisgorgement =>
      'Från datumet då vinet lades till: ange degorgeringsdatum för en bättre uppskattning';

  @override
  String get estimateFromEntryDateBottling =>
      'Från datumet då vinet lades till: ange buteljeringsdatum för en bättre uppskattning';

  @override
  String get styleToConfirmBanner =>
      '⚠︎ Stilen behöver bekräftas: uppskattningen är ungefärlig';

  @override
  String get chooseTypePrompt => 'Välj typ';

  @override
  String estimateUpdatedAnnouncement(String summary) {
    return 'Uppskattningen har uppdaterats: $summary';
  }

  @override
  String get agingStartDisgorgement => 'Degorgering';

  @override
  String get agingStartBottling => 'Buteljering';

  @override
  String get agingStartMonth => 'Månad';

  @override
  String get agingStartYear => 'År';

  @override
  String get agingStartHint => 'Det står oftast på baksidesetiketten.';

  @override
  String get agingStartIncomplete => 'Ange månad och år';

  @override
  String get agingStartFuture => 'Datumet får inte ligga i framtiden';

  @override
  String get agingStartBeforeVintage => 'Det får inte ligga före årgången';

  @override
  String get windowNoEnd => 'Drickfärdig, inget slut uppskattat';

  @override
  String get windowNoEndShort => 'inget slut uppskattat';

  @override
  String windowDrinkWithin(String date) {
    return 'senast $date';
  }

  @override
  String get levelNoEffect => 'Nivån ändrar inte den här uppskattningen';

  @override
  String get dashboardToConfirmTitle => 'Att bekräfta';

  @override
  String dashboardToConfirmCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count viner',
      one: '1 vin',
    );
    return '$_temp0';
  }

  @override
  String aboutDbClassified(String percent) {
    return '$percent % av vinerna med en igenkänd typ';
  }

  @override
  String get planTitle => 'Abonnemang';

  @override
  String get planFree => 'Gratis';

  @override
  String get planPlus => 'Plus';

  @override
  String get planPlusGift => 'Plus (gåva)';

  @override
  String get planDevUnlockAll => 'DEV · Test-Plus';

  @override
  String get planDevSimulateFree => 'DEV · Simulerat gratisabonnemang';

  @override
  String get planDevSimulateExpired => 'DEV · Simulerat utgånget Plus';

  @override
  String get planDiscoverPlus => 'Upptäck Plus';

  @override
  String get plusTitle => 'Vinoozy Plus';

  @override
  String get plusBenefitsTitle => 'Med Plus';

  @override
  String get plusBenefitNoAds => 'Ingen reklam';

  @override
  String get plusBenefitNoLimit => 'Ingen gräns för vinerna i din källare';

  @override
  String get plusComingSoon => 'Plus kommer snart';

  @override
  String get plusLoading => 'Hämtar priserna från Google Play';

  @override
  String get plusStoreUnavailable =>
      'Det gick inte att hämta priserna från Google Play. Försök igen senare.';

  @override
  String plusPriceMonthly(String price) {
    return '$price per månad';
  }

  @override
  String plusPriceAnnual(String price) {
    return '$price per år';
  }

  @override
  String get plusRenewal =>
      'Prenumerationen förnyas automatiskt till det visade priset tills du säger upp den på Google Play.';

  @override
  String get plusTerms =>
      'Betalningen debiteras ditt Google Play-konto när du bekräftar köpet. Du kan säga upp när som helst: Plus är aktivt till slutet av den period du redan har betalat för. När Plus upphör finns alla dina viner kvar.';

  @override
  String get plusRestore => 'Återställ köp';

  @override
  String get plusManage =>
      'Hantera eller säg upp prenumerationen på Google Play';

  @override
  String get plusActive => 'Plus är aktivt på det här kontot';

  @override
  String get plusActiveGift =>
      'Du har fått Plus i gåva: inga avgifter och inga förnyelser.';

  @override
  String get plusPending =>
      'Betalningen väntar: Plus aktiveras när Google Play bekräftar den.';

  @override
  String get plusVerifying => 'Verifierar köpet';

  @override
  String get plusVerified =>
      'Köpet är verifierat: Plus är aktivt om några sekunder.';

  @override
  String get plusPurchaseFailed => 'Köpet slutfördes inte. Försök igen.';

  @override
  String get plusInvalidPurchase =>
      'Google Play bekräftade inte det här köpet för Vinoozy.';

  @override
  String get plusOwnedByOther =>
      'Den här prenumerationen tillhör redan ett annat Vinoozy-konto.';

  @override
  String get plusVerificationUnavailable =>
      'Köpet kunde inte verifieras just nu. Försök igen senare: prenumerationen finns kvar på Google Play.';

  @override
  String get capacityLimitTitle => 'Du har nått gränsen för gratisabonnemanget';

  @override
  String capacityLimitBody(int limit) {
    return 'Gratisabonnemanget omfattar upp till $limit olika viner i din källare. Du kan alltid redigera, dricka och lägga till flaskor för de viner du redan har. För att lägga till ett nytt behöver du dricka upp eller ta bort ett vin, eller byta till Plus.';
  }

  @override
  String capacityLimitBodyComingSoon(int limit) {
    return 'Gratisabonnemanget omfattar upp till $limit olika viner i din källare. Du kan alltid redigera, dricka och lägga till flaskor för de viner du redan har. För att lägga till ett nytt behöver du dricka upp eller ta bort ett vin. Plus kommer snart.';
  }

  @override
  String get rejectedCapacityLimit =>
      'Inte synkroniserat: det överskrider gratisabonnemangets vingräns. Ändringen finns kvar på den här telefonen.';

  @override
  String get rejectedCapacityConflict =>
      'Inte synkroniserat: källaren ändrades på en annan enhet samtidigt. Ändringen finns kvar på den här telefonen: försök igen.';

  @override
  String writeRejectedCapacityLimit(String name) {
    return '$name: inte synkroniserat, över gratisabonnemangets gräns';
  }

  @override
  String writeRejectedCapacityConflict(String name) {
    return '$name: inte synkroniserat, källaren ändrades på en annan enhet';
  }

  @override
  String get freeIntroTitle => 'Gratisabonnemanget';

  @override
  String freeIntroLimit(int limit) {
    return 'Du kan hantera upp till $limit olika viner gratis.';
  }

  @override
  String get freeIntroAds =>
      'Lätt användning är reklamfri. Om du går över tjänstens månatliga användningsgräns kan du se enstaka annonser som hjälper till att täcka kostnaderna för servrar och synkronisering.';

  @override
  String get freeIntroNoAds => 'Ingen reklam i lanseringsversionen.';

  @override
  String get freeIntroPlus => 'Med Plus slipper du reklamen och källargränsen.';

  @override
  String get noticeGotIt => 'Jag förstår';

  @override
  String get thresholdTitle => 'Reklam hjälper till att hålla Vinoozy gratis';

  @override
  String get thresholdBody =>
      'Du har nått den månatliga gränsen för reklamfri användning. Från och med nu kan du se enstaka annonser: de hjälper oss att täcka kostnaderna för servrar och synkronisering, så att Vinoozy kan förbli gratis.';

  @override
  String get thresholdReset =>
      'Räkningen börjar om nästa månad. Med Plus kan du använda appen utan reklam och utan källargränsen.';

  @override
  String thresholdNextReset(String date) {
    return 'Nästa återställning: $date';
  }

  @override
  String get thresholdHowItWorks => 'Så fungerar det';

  @override
  String get thresholdHowItWorksBody =>
      'Gränsen beror på en uppskattning av de synkroniseringar med molnet som det här kontot gör under månaden. Enbart offlineanvändning skapar inga nya molnåtgärder. Annonser visas högst en gång per dag, bara i Översikt, och aldrig medan du sparar eller exporterar dina data.';

  @override
  String get adLabel => 'Annons';

  @override
  String get devToolsTitle => 'Utvecklarverktyg';

  @override
  String get devUnlockAll => 'Lås upp allt — test-Plus';

  @override
  String get devSimulateFree => 'Simulera gratisabonnemang';

  @override
  String get devSimulateExpired => 'Simulera utgånget Plus';

  @override
  String get devRestore => 'Återställ normalt läge';

  @override
  String get devNoOverride => 'Ingen simulering aktiv';

  @override
  String get devApplied =>
      'Scenariot har också tillämpats i Firestore-emulatorn';

  @override
  String get devIncomplete =>
      'Ofullständig simulering: Firestore-emulatorn bekräftade inte testbehörigheten. Serverreglerna ser inte det här scenariot.';

  @override
  String get devNotice =>
      'Endast utvecklingsbyggen med emulatorn: inga betalningar, token eller kvitton.';
}
