// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hungarian (`hu`).
class AppLocalizationsHu extends AppLocalizations {
  AppLocalizationsHu([String locale = 'hu']) : super(locale);

  @override
  String get appTitle => 'Vinoozy';

  @override
  String get signInTagline => 'A pincéd, a megfelelő időben';

  @override
  String get signInWithGoogle => 'Folytatás Google-fiókkal';

  @override
  String get signInInProgress => 'Bejelentkezés folyamatban';

  @override
  String get signInFailed => 'A bejelentkezés nem sikerült';

  @override
  String get signInNeedsNetwork =>
      'Az első bejelentkezéshez internetkapcsolat kell';

  @override
  String get signInSessionExpired => 'A munkamenet lejárt: jelentkezz be újra';

  @override
  String get retry => 'Újra';

  @override
  String get cancel => 'Mégse';

  @override
  String blockedMessage(String email) {
    return 'Ennek a fióknak vannak még felhőbe nem mentett módosításai: $email. Jelentkezz be vele, és csatlakozz a hálózathoz';
  }

  @override
  String blockedSignInWith(String email) {
    return 'Bejelentkezés ezzel: $email';
  }

  @override
  String blockedDiscard(String email) {
    return 'Nem mentett módosítások törlése ($email)';
  }

  @override
  String get discardDialogTitle => 'Törlöd a módosításokat?';

  @override
  String discardDialogBody(int count, String email) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$email: $count bor még nincs a felhőben, ezért törlődik erről a telefonról.',
      one:
          '$email: 1 bor még nincs a felhőben, ezért törlődik erről a telefonról.',
    );
    return '$_temp0';
  }

  @override
  String get discardConfirm => 'Törlés';

  @override
  String get resetFailed => 'Nem sikerült törölni a telefonon lévő adatokat';

  @override
  String get restartRequired => 'A befejezéshez indítsd újra az appot';

  @override
  String get restartCloseApp => 'App bezárása';

  @override
  String get startupFailed => 'Az app nem tudott elindulni';

  @override
  String get cellarTitle => 'Pince';

  @override
  String get defaultCellarName => 'Az én pincém';

  @override
  String get cellarLoading => 'Pince előkészítése';

  @override
  String get cellarSetupFailed => 'Nem sikerült előkészíteni a pincét';

  @override
  String get cellarEmpty => 'A pincéd üres';

  @override
  String get addWine => 'Hozzáadás';

  @override
  String get estimatePending => 'Becslés készül';

  @override
  String get noVintage => 'Évjárat nélkül';

  @override
  String bottleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count palack',
      one: '1 palack',
    );
    return '$_temp0';
  }

  @override
  String get syncInProgress => 'Szinkronizálás';

  @override
  String get syncOffline => 'Offline - szinkronizálásra vár';

  @override
  String writeRejected(String name) {
    return 'Nem engedélyezett módosítás: $name';
  }

  @override
  String get saveFailed => 'Nem sikerült menteni, próbáld újra';

  @override
  String wineNotSaved(String name) {
    return 'Ez a bor nem lett mentve a felhőbe: $name';
  }

  @override
  String get addAgain => 'Hozzáadás újra';

  @override
  String get ignore => 'Mellőzés';

  @override
  String get addWineTitle => 'Beírás';

  @override
  String get wineNameLabel => 'Bor';

  @override
  String get vintageLabel => 'Évjárat';

  @override
  String get quantityLabel => 'Mennyiség';

  @override
  String get decreaseQuantity => 'Mennyiség csökkentése';

  @override
  String get increaseQuantity => 'Mennyiség növelése';

  @override
  String get save => 'Mentés';

  @override
  String get nameRequired => 'Írd be a bor nevét';

  @override
  String get nameTooLong => 'Legfeljebb 120 karakter';

  @override
  String vintageRange(String year) {
    return 'Évjárat: 1900–$year';
  }

  @override
  String get offAttribution => 'Adatok: Open Food Facts (ODbL)';

  @override
  String get dashboardTitle => 'Áttekintés';

  @override
  String dashboardTotalBottles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count palack a pincében',
      one: '1 palack a pincében',
    );
    return '$_temp0';
  }

  @override
  String get dashboardSyncing => 'Pince szinkronizálása…';

  @override
  String get dashboardAddFirstWine => 'Add hozzá az első borod';

  @override
  String get drinkSoonTitle => 'Idd meg hamar';

  @override
  String get drinkSoonEmpty => 'Nincs sürgős palack';

  @override
  String drinkSoonUntil(String year) {
    return '$year-ig';
  }

  @override
  String drinkSoonSeeAll(int count) {
    return 'Összes ($count)';
  }

  @override
  String get statusChartTitle => 'Palackok állapota';

  @override
  String get statusWaiting => 'várni kell';

  @override
  String get statusReady => 'iható';

  @override
  String get statusDrinkSoon => 'idd meg hamar';

  @override
  String get statusPastWindow => 'ablakon túl';

  @override
  String toEstimateNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count palack becslésre vár',
      one: '1 palack becslésre vár',
    );
    return '$_temp0';
  }

  @override
  String chartBarValue(String label, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count palack',
      one: '1 palack',
    );
    return '$label: $_temp0';
  }

  @override
  String chartDescription(String title, String values) {
    return '$title: $values';
  }

  @override
  String get openListHint => 'Lista megnyitása';

  @override
  String get peakChartTitle => 'Csúcs éve';

  @override
  String get peakPast => 'csúcson túl';

  @override
  String get peakBeyond => 'később';

  @override
  String get breakdownTypeTitle => 'Palackok típus szerint';

  @override
  String get breakdownRegionTitle => 'Palackok régió szerint';

  @override
  String get breakdownType => 'Típus';

  @override
  String get breakdownRegion => 'Régió';

  @override
  String get familyRed => 'vörös';

  @override
  String get familyWhite => 'fehér';

  @override
  String get familyRose => 'rozé';

  @override
  String get familySparkling => 'pezsgő';

  @override
  String get familySweet => 'édes';

  @override
  String get breakdownUnspecified => 'nincs megadva';

  @override
  String get breakdownOtherRegions => 'egyéb';

  @override
  String get ok => 'OK';

  @override
  String get cellarMenu => 'Pince menüje';

  @override
  String get sharingPeopleTitle => 'Személyek';

  @override
  String get sharingInviteTitle => 'Személy meghívása';

  @override
  String get sharingEmailLabel => 'Google e-mail-cím';

  @override
  String get sharingPermissionRead => 'Csak olvasás';

  @override
  String get sharingPermissionReadHint =>
      'Látja a borokat, a becsléseket, az áttekintést és a kóstolásokat';

  @override
  String get sharingPermissionEdit => 'Szerkeszthet';

  @override
  String get sharingPermissionEditHint =>
      'Borokat is hozzáad és módosít, kóstolást rögzít';

  @override
  String get sharingRoleOwner => 'tulajdonos';

  @override
  String get sharingInviteButton => 'Meghívás';

  @override
  String sharingPlacesUsed(int used, int max) {
    return '$used/$max fő';
  }

  @override
  String get sharingInvalidEmail => 'Adj meg érvényes e-mail-címet';

  @override
  String get sharingSelfInvite => 'Magadat nem hívhatod meg';

  @override
  String get sharingAlreadyInvited => 'Ez a személy már meg van hívva';

  @override
  String sharingLimitReached(int max) {
    return 'Elérted a korlátot: $max fő';
  }

  @override
  String get sharingNotOwner =>
      'Ennek a pincének a megosztását nem módosíthatod';

  @override
  String get sharingNotFound => 'Ez a személy már nincs a listán';

  @override
  String get sharingFailed => 'Nem sikerült, próbáld újra';

  @override
  String get sharingInviteFailed => 'A meghívás nem sikerült. Próbáld újra';

  @override
  String get sharingOfflineHint =>
      'A megosztás kezeléséhez internetkapcsolat kell';

  @override
  String get sharingStatusInvited => 'meghívva';

  @override
  String get sharingStatusActive => 'aktív';

  @override
  String get sharingStatusRevoked => 'visszavonva';

  @override
  String get sharingStatusLeft => 'kilépett';

  @override
  String sharingMemberSemantics(String name, String permission, String status) {
    return '$name, $permission, $status';
  }

  @override
  String get sharingClosedSection => 'Lezárt hozzáférések';

  @override
  String get sharingNobody => 'Ezt a pincét még senki más nem látja';

  @override
  String sharingChangePermission(String name) {
    return '$name jogosultságának módosítása';
  }

  @override
  String get sharingRevoke => 'Visszavonás';

  @override
  String sharingRevokeTitle(String name) {
    return 'Visszavonod $name hozzáférését?';
  }

  @override
  String sharingRevokeConfirmLabel(String name) {
    return 'A megerősítéshez írd be: $name';
  }

  @override
  String get sharingRevokeDisabledHint => 'Akkor aktív, ha a név egyezik';

  @override
  String get sharingReinvite => 'Meghívás újra';

  @override
  String get sharingDeleteForGood => 'Végleges törlés';

  @override
  String sharingOwnedBy(String owner) {
    return '$owner pincéje';
  }

  @override
  String get sharingYourCellar => 'A te pincéd';

  @override
  String sharingYourPermission(String permission) {
    return 'Jogosultságod: $permission';
  }

  @override
  String sharingSwitcherSemantics(String cellar, String permission) {
    return '$cellar, $permission. Koppints a pinceváltáshoz';
  }

  @override
  String get sharingLeave => 'Kilépés ebből a pincéből';

  @override
  String sharingLeaveTitle(String owner) {
    return 'Kilépsz $owner pincéjéből?';
  }

  @override
  String sharingLeaveBody(String owner) {
    return 'Többé nem fogod látni. $owner újra meghívhat.';
  }

  @override
  String get sharingLeaveConfirm => 'Kilépés';

  @override
  String sharingSharedNotice(String owner) {
    return '$owner megosztotta veled a pincéjét';
  }

  @override
  String sharingAccessLost(String owner) {
    return 'Már nem férsz hozzá $owner pincéjéhez';
  }

  @override
  String sharingWritesLost(String owner) {
    return '$owner pincéjének néhány módosítása nem lett mentve, mert már nincs hozzáférésed';
  }

  @override
  String get sharingSomeone => 'valaki';

  @override
  String get sharingShareSubject => 'Vinoozy-meghívó';

  @override
  String sharingShareMessage(
    String owner,
    String cellar,
    String link,
    String email,
  ) {
    return '$owner meghívott a pincéjébe („$cellar”) a Vinoozy appban. Telepítsd az appot innen: $link, majd jelentkezz be ezzel a Google-fiókkal: $email. Pontosan ezt a címet használd.';
  }

  @override
  String get cellarSearchHint => 'Keresés név vagy termelő szerint';

  @override
  String get cellarFilterStatus => 'Állapot';

  @override
  String get cellarFilterType => 'Típus';

  @override
  String get statusToEstimate => 'Becslésre vár';

  @override
  String get filterTypeUnspecified => 'Nincs megadva';

  @override
  String get cellarNoMatches => 'Nincs bor ezekkel a szűrőkkel';

  @override
  String get cellarClearFilters => 'Szűrők törlése';

  @override
  String get cellarArchiveTitle => 'Megivott';

  @override
  String get cellarArchiveEmpty => 'Még nincs elfogyott bor';

  @override
  String get cellarArchiveFailed =>
      'Nem sikerült betölteni az elfogyott borokat';

  @override
  String get wineDrink => 'Megittam';

  @override
  String wineDrinkTooltip(String name) {
    return 'Egy palack megivottnak jelölése: $name';
  }

  @override
  String confidenceLabel(String level) {
    return 'Megbízhatóság: $level';
  }

  @override
  String get confidenceHigh => 'magas';

  @override
  String get confidenceMedium => 'közepes';

  @override
  String get confidenceLow => 'alacsony';

  @override
  String get windowStartLabel => 'Kezdet';

  @override
  String get windowPeakLabel => 'Csúcs';

  @override
  String get windowEndLabel => 'Vége';

  @override
  String estimateSourceLabel(String source) {
    return 'Forrás: $source';
  }

  @override
  String get estimateSourceCatalog => 'boradatbázis';

  @override
  String get estimateSourceType => 'típus szerinti becslés';

  @override
  String get estimateSourceCorrected =>
      'a kóstolásaid alapján javított becslés';

  @override
  String get estimateDisclaimer =>
      'Tájékoztató becslés: a palack tárolásától is függ';

  @override
  String get estimateUnavailable => 'Nincs becslés';

  @override
  String get pairingsTitle => 'Párosítások';

  @override
  String get pairingsGeneric => 'általános párosítások a típushoz';

  @override
  String get pairingBraisedRedMeat => 'Párolt vörös hús';

  @override
  String get pairingGrilledRedMeat => 'Grillezett vörös hús';

  @override
  String get pairingGame => 'Vadhús';

  @override
  String get pairingRoastPoultry => 'Sült szárnyas';

  @override
  String get pairingPoultry => 'Szárnyas';

  @override
  String get pairingPork => 'Sertéshús';

  @override
  String get pairingCuredMeats => 'Felvágottak';

  @override
  String get pairingPastaMeatSauce => 'Tészta húsraguval';

  @override
  String get pairingMushroomsTruffle => 'Gomba és szarvasgomba';

  @override
  String get pairingAgedCheese => 'Érlelt sajt';

  @override
  String get pairingFreshCheese => 'Friss sajt';

  @override
  String get pairingBlueCheese => 'Kéksajt';

  @override
  String get pairingFish => 'Hal';

  @override
  String get pairingSeafood => 'Tenger gyümölcsei';

  @override
  String get pairingRawSeafood => 'Nyers tenger gyümölcsei';

  @override
  String get pairingFriedFood => 'Rántott ételek';

  @override
  String get pairingVegetables => 'Zöldségek';

  @override
  String get pairingRisotto => 'Rizottó';

  @override
  String get pairingPizza => 'Pizza';

  @override
  String get pairingAperitif => 'Aperitif';

  @override
  String get pairingPastries => 'Sütemények';

  @override
  String get pairingDryBiscuits => 'Száraz keksz';

  @override
  String get pairingChocolate => 'Csokoládé';

  @override
  String get pairingDriedFruit => 'Diófélék és aszalt gyümölcs';

  @override
  String get pairingSpicyDishes => 'Csípős ételek';

  @override
  String get recentDrinksTitle => 'Legutóbbi kóstolások';

  @override
  String get noDrinksYet => 'Még nincs kóstolás';

  @override
  String get wineEdit => 'Szerkesztés';

  @override
  String get wineDelete => 'Törlés';

  @override
  String get wineFinished => 'Elfogyott: nincs több palack';

  @override
  String get wineLoadFailed => 'Nem sikerült megnyitni a bort';

  @override
  String get wineNotFound => 'Ez a bor már nem létezik';

  @override
  String drinkDone(String name) {
    return 'Megivottnak jelölve: $name';
  }

  @override
  String get drinkUndo => 'Visszavonás';

  @override
  String get drinkAddNotes => 'Értékelés és jegyzet';

  @override
  String get nothingToUndo => 'Nincs mit visszavonni';

  @override
  String get cellarUndoRejected =>
      'A visszavonás nem sikerült: a palack megivottként marad';

  @override
  String get cellarDeleteFailed =>
      'A törlés még nem teljes: amint lehet, befejeződik';

  @override
  String get duplicateFull =>
      'Ebből a borból már 99 palack van: több nem adható hozzá.';

  @override
  String get recordSheetTitle => 'Értékelés és jegyzetek';

  @override
  String get recordRatingLabel => 'Értékelés';

  @override
  String ratingStar(int n) {
    return 'Értékelés: $n / 5';
  }

  @override
  String get recordNotesLabel => 'Jegyzetek';

  @override
  String get recordNotesTooLong => 'Legfeljebb 1000 karakter';

  @override
  String recordDateLabel(String date) {
    return 'Dátum: $date';
  }

  @override
  String get recordDateInvalid =>
      'A dátum nem lehet jövőbeli vagy az évjáratnál korábbi';

  @override
  String get recordConditionTitle => 'Milyen volt?';

  @override
  String get conditionTooYoung => 'Még túl fiatal';

  @override
  String get conditionJustRight => 'Éppen jó';

  @override
  String get conditionPastPeak => 'Túl a csúcson';

  @override
  String get recordNoCondition => 'Nincs válasz';

  @override
  String get producerLabel => 'Termelő (nem kötelező)';

  @override
  String get producerTooLong => 'Legfeljebb 120 karakter';

  @override
  String producerAddNew(String name) {
    return '„$name” hozzáadása új termelőként';
  }

  @override
  String get wineTypeLabel => 'Típus';

  @override
  String get typeRedLight => 'Könnyű vörös';

  @override
  String get typeRedStructured => 'Testes vörös';

  @override
  String get typeWhite => 'Fehér';

  @override
  String get typeRose => 'Rozé';

  @override
  String get typeSparklingClassic => 'Tradicionális pezsgő';

  @override
  String get typeSparklingTank => 'Tankpezsgő';

  @override
  String get typeSweet => 'Édes';

  @override
  String get typeFortified => 'Erősített';

  @override
  String get suggestionFromCellar => 'A pincédben';

  @override
  String get suggestionsLabel => 'Javaslatok';

  @override
  String get duplicateTitle => 'Már a pincében van';

  @override
  String duplicateBody(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count palack',
      one: '1 palack',
      zero: 'nincs palack',
    );
    return '$name már szerepel a pincében ($_temp0). Ehhez adod az új palackokat?';
  }

  @override
  String duplicateAdd(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count palack hozzáadása',
      one: '1 palack hozzáadása',
    );
    return '$_temp0';
  }

  @override
  String get duplicateBanner => 'Lehetséges duplikátum';

  @override
  String get duplicateMerge => 'Egyesítés';

  @override
  String get duplicateDeleteHint => 'Töröld ezt a tételt, ha duplikátum';

  @override
  String get mergeTitle => 'Egyesíted a két tételt?';

  @override
  String get mergeBody =>
      'Ennek a tételnek a palackjai a régebbihez kerülnek, majd ez a tétel törlődik.';

  @override
  String get editWineTitle => 'Bor szerkesztése';

  @override
  String get editDuplicate => 'Már van ilyen nevű, termelőjű és évjáratú bor';

  @override
  String deleteWineTitle(String name) {
    return 'Törlöd ezt: $name?';
  }

  @override
  String get deleteWineBody =>
      'A bor és minden kóstolása törlődik. Ez nem vonható vissza.';

  @override
  String get historyTitle => 'Előzmények';

  @override
  String get historyEmpty => 'Itt találod majd a megivott palackokat';

  @override
  String get historyLoadFailed => 'Nem sikerült betölteni az előzményeket';

  @override
  String drankOnLabel(String date) {
    return 'Megivva: $date';
  }

  @override
  String get addChoiceTitle => 'Bor hozzáadása';

  @override
  String get addChoicePhoto => 'Fotó készítése';

  @override
  String get addChoiceImport => 'Fotó importálása';

  @override
  String get addChoiceWrite => 'Beírás';

  @override
  String get labelReading => 'Címke olvasása…';

  @override
  String get labelRecognized => 'Ezt ismertem fel:';

  @override
  String get labelCorrect => 'Javítás';

  @override
  String get labelConfirm => 'Megerősítés';

  @override
  String get labelUnreadable => 'Nem tudom elolvasni a címkét';

  @override
  String get labelWriteByHand => 'Beírás kézzel';

  @override
  String get labelNotFound => 'Nem találtam meg a bort: ellenőrizd az adatokat';

  @override
  String get labelCameraDenied =>
      'A címke olvasásához hozzáférés kell a kamerához';

  @override
  String get labelPhotosDenied =>
      'A címke olvasásához hozzáférés kell a fotókhoz';

  @override
  String get labelOpenSettings => 'Beállítások megnyitása';

  @override
  String get labelCameraUnavailable => 'A kamera nem érhető el';

  @override
  String get labelBarcodeNotFound =>
      'Beolvastam a vonalkódot, de nem találom a bort';

  @override
  String get labelBarcodeFrontHint => 'Fotózd le a címke elejét';

  @override
  String get labelSharedNotAllowed => 'Ehhez a pincéhez nem adhatsz hozzá bort';

  @override
  String get labelSharedFirstOnly => 'Csak az első fotót használtam';

  @override
  String get labelSharedExpired =>
      'A megosztott fotót nem sikerült beolvasni: oszd meg újra';

  @override
  String get labelReplaceTitle =>
      'Van egy nem mentett borod. Beolvassam az új fotót?';

  @override
  String get labelReplaceRead => 'Új fotó beolvasása';

  @override
  String get labelReplaceKeep => 'Folytatás a megnyitottal';

  @override
  String get labelWineAdded => 'A bor bekerült a pincébe';

  @override
  String get onboardingPage1Title => 'A pincéd a zsebedben';

  @override
  String get onboardingPage1Body =>
      'Vidd fel a palackjaidat beírással vagy a címke fotójával, akár hálózat nélkül is.';

  @override
  String get onboardingPage2Title => 'A megfelelő időben';

  @override
  String get onboardingPage2Body =>
      'A Vinoozy megbecsüli, mikor van csúcson egy-egy bor, és megmondja, melyiket érdemes előbb kinyitni.';

  @override
  String get onboardingPage3Title => 'Együtt';

  @override
  String get onboardingPage3Body =>
      'Oszd meg a pincédet legfeljebb két személlyel, és őrizd meg minden megivott palack előzményeit.';

  @override
  String get onboardingSkip => 'Kihagyás';

  @override
  String get onboardingNext => 'Tovább';

  @override
  String get onboardingStart => 'Kezdés';

  @override
  String onboardingPageOf(int page) {
    return '$page. oldal, összesen 3';
  }

  @override
  String get profileTitle => 'Profil';

  @override
  String get profilePhoto => 'Profilkép';

  @override
  String get profileSignOut => 'Kijelentkezés';

  @override
  String get profileDeleteAccount => 'Fiók törlése';

  @override
  String get profilePrivacy => 'Adatvédelmi irányelvek';

  @override
  String get profilePrivacyBody =>
      'Az adatvédelmi irányelveket ezen a címen olvashatod:';

  @override
  String get profileOpenLink => 'Megnyitás böngészőben';

  @override
  String get profileOpenLinkFailed =>
      'Nem sikerült megnyitni az oldalt. Másold ki a linket, és nyisd meg a böngésződben.';

  @override
  String get profileCopyLink => 'Link másolása';

  @override
  String get profileLinkCopied => 'Link kimásolva';

  @override
  String get close => 'Bezárás';

  @override
  String get signOutConfirmTitle => 'Kijelentkezel?';

  @override
  String signOutPendingWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count módosításod még nincs mentve. Ha kijelentkezel, és másik fiók lép be, elvesznek.',
      one: '1 módosításod még nincs mentve. Ha kijelentkezel, és másik fiók lép be, elvész.',
    );
    return '$_temp0';
  }

  @override
  String get signOutStayAndSync => 'Maradok és szinkronizálok';

  @override
  String get signOutAnyway => 'Kijelentkezés mégis';

  @override
  String get syncAllSaved => 'Minden mentve';

  @override
  String syncStillPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count módosítás még mentésre vár: ellenőrizd a hálózatot',
      one: '1 módosítás még mentésre vár: ellenőrizd a hálózatot',
    );
    return '$_temp0';
  }

  @override
  String get signOutFailed => 'A kijelentkezés nem sikerült. Próbáld újra';

  @override
  String get signInAccountDeleted => 'Fiók törölve';

  @override
  String get deleteAccountIntro => 'Ez véglegesen törli:';

  @override
  String get deleteAccountItemCellar =>
      'A pincédet a borokkal és az előzményekkel';

  @override
  String get deleteAccountItemShares =>
      'Az általad adott megosztásokat: a meghívottak elveszítik a hozzáférést';

  @override
  String get deleteAccountItemMemberships =>
      'A részvételedet mások pincéiben: a kóstolásaid ott maradnak a neved nélkül';

  @override
  String get deleteAccountItemProfile => 'A profilodat';

  @override
  String deleteAccountPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count módosításod még nincs mentve: előbb mentjük, aztán a többivel együtt töröljük',
      one: '1 módosításod még nincs mentve: előbb mentjük, aztán a többivel együtt töröljük',
    );
    return '$_temp0';
  }

  @override
  String get deleteAccountConfirmWord => 'TÖRLÉS';

  @override
  String deleteAccountTypeWord(String word) {
    return 'A megerősítéshez írd be: $word';
  }

  @override
  String get deleteAccountReauthHint =>
      'Ezután újra bejelentkezel a Google-fiókoddal, hogy igazold: te vagy az.';

  @override
  String get deleteAccountForever => 'Végleges törlés';

  @override
  String get deleteAccountNeedsNetwork =>
      'A fiók törléséhez csatlakozz az internethez';

  @override
  String get deleteAccountSameAccount =>
      'A törléshez ugyanazzal a fiókkal kell bejelentkezned';

  @override
  String get deletionTitle => 'Fiók törlése';

  @override
  String get deletionStepPreparePhone => 'Függő módosítások mentése';

  @override
  String get deletionStepMarkStarted => 'Törlés indítása';

  @override
  String get deletionStepLeaveOtherCellars => 'Kilépés mások pincéiből';

  @override
  String get deletionStepCloseOwnInvitations => 'Megosztásaid lezárása';

  @override
  String get deletionStepDeleteWinesAndRecords => 'Borok és előzmények törlése';

  @override
  String get deletionStepDeleteCellar => 'Pince törlése';

  @override
  String get deletionStepDeleteProfileAndUser => 'Profil és fiók törlése';

  @override
  String get deletionStepCleanUpPhone => 'A telefon megtisztítása';

  @override
  String deletionStepAnnounce(int step, String label) {
    return '$step. lépés, összesen 8: $label';
  }

  @override
  String deletionDeletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bor és kóstolás törölve',
      one: '1 bor vagy kóstolás törölve',
    );
    return '$_temp0';
  }

  @override
  String get deletionResumeHint =>
      'Ennek a fióknak a törlése nem fejeződött be. A befejezéshez jelentkezz be újra a Google-fiókoddal.';

  @override
  String get deletionContinue => 'Folytatás';

  @override
  String get deletionOffline =>
      'A törlés befejezéséhez csatlakozz az internethez';

  @override
  String get deletionPendingWrites =>
      'Nem tudom menteni a függő módosításokat. Próbáld újra';

  @override
  String get deletionFailed => 'Nem sikerült befejezni a törlést. Próbáld újra';

  @override
  String get uxCountryLabel => 'Ország';

  @override
  String get uxCountryOther => 'Más ország…';

  @override
  String get uxCountryNone => 'Nincs ország';

  @override
  String get uxAllCountriesTitle => 'Minden ország és terület';

  @override
  String get uxAllCountriesSearch => 'Ország keresése';

  @override
  String get uxAllCountriesRare => 'Ritka borországok';

  @override
  String get uxAllCountriesAll => 'Mind, A-tól Z-ig';

  @override
  String get uxAllCountriesNone => 'Nincs ilyen ország';

  @override
  String get uxRegionLabel => 'Régió';

  @override
  String uxRegionOf(String country) {
    return 'Régió · $country';
  }

  @override
  String get uxRegionOther => 'Más régió';

  @override
  String get uxRegionFieldLabel => 'Írd be a régiót';

  @override
  String get uxRegionTooLong => 'Legfeljebb 120 karakter';

  @override
  String get uxDrinkAction => 'Megittam egyet';

  @override
  String uxDrinkActionTooltip(String name) {
    return 'Megittam egy palackot: $name';
  }

  @override
  String get uxDrinkActionDetail => 'Megittam egy palackot';

  @override
  String get uxDrinkSheetLabel => 'Kóstolás megerősítése';

  @override
  String get uxDrinkSheetBottles => 'Palackok';

  @override
  String uxDrinkSheetBottlesChange(int before, int after) {
    return 'Palackok száma: $before helyett $after';
  }

  @override
  String get uxDrinkSheetRating => 'Milyen volt? (nem kötelező)';

  @override
  String uxDrinkSheetStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count csillag az 5-ből',
      one: '1 csillag az 5-ből',
    );
    return '$_temp0';
  }

  @override
  String get uxDrinkSheetConfirm => 'Igen, megittam';

  @override
  String get uxRemoveBottle => 'Palack kivétele kóstolás nélkül';

  @override
  String get uxRemoveBottleTitle => 'Kiveszel egy palackot?';

  @override
  String uxRemoveBottleBody(String name) {
    return 'Egy palack kóstolás rögzítése nélkül kerül ki a pincéből: $name.';
  }

  @override
  String get uxRemoveBottleConfirm => 'Kivétel';

  @override
  String get uxIdealTitle => 'Ideális időpont';

  @override
  String uxIdealUntil(String year) {
    return 'Ajánlott: $year-ig';
  }

  @override
  String uxIdealUntilPast(String year) {
    return 'Ajánlott: $year-ig – már elmúlt';
  }

  @override
  String uxIdealBest(String start, String end) {
    return 'Csúcson: $start–$end';
  }

  @override
  String uxIdealBar(String start, String end) {
    return 'Ivási ablak: $start–$end';
  }

  @override
  String get uxIdealDisclaimer =>
      '⚠︎ Tájékoztató: típus, eredetmegjelölés és évjárat alapján készült becslés. A tárolás és az adott palack módosíthatja.';

  @override
  String get uxIdealUnavailableHint =>
      'Becsléshez add meg az évjáratot és a típust.';

  @override
  String uxDashboardDrinkNow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count most iható',
      one: '1 most iható',
    );
    return '$_temp0';
  }

  @override
  String get uxFamilyRed => 'Vörös';

  @override
  String get uxFamilyWhite => 'Fehér';

  @override
  String get uxFamilyRose => 'Rozé';

  @override
  String get uxFamilySparkling => 'Pezsgő';

  @override
  String get uxFamilySweet => 'Édes';

  @override
  String get labelBackTitle => 'Most a hátcímke';

  @override
  String get labelBackHint =>
      'A hátcímkén szokott lenni a vonalkód, a termelő és az évjárat: ezek segítenek megtalálni a bort.';

  @override
  String get labelBackTake => 'Hátcímke fotózása';

  @override
  String get labelBackGallery => 'Választás a galériából';

  @override
  String get labelBackSkip => 'Kihagyás';

  @override
  String get labelStepFront => 'Elöl';

  @override
  String get labelStepBack => 'Hátul';

  @override
  String get labelStepBarcode => 'Vonalkód';

  @override
  String get labelStepDatabase => 'Boradatbázis a telefonon';

  @override
  String get labelStepPending => 'Várakozik';

  @override
  String get labelStepRunning => 'Folyamatban…';

  @override
  String get labelStepDone => 'Kész';

  @override
  String get labelStepSkipped => 'Kihagyva';

  @override
  String get labelStepFailed => 'Nem olvasható';

  @override
  String labelStepStatus(String step, String status) {
    return '$step: $status';
  }

  @override
  String get labelOnPhoneNote =>
      'Minden a telefonon történik: a fotókat senki nem kapja meg.';

  @override
  String get labelBackUnreadable => 'A hátcímke nem olvasható';

  @override
  String get labelSourceOffline => 'A telefon adatbázisából · offline';

  @override
  String get labelSourceCatalog => 'A katalógusból';

  @override
  String get labelSourceOnline => 'Open Food Facts · online';

  @override
  String get labelNotThis => 'Nem ez az';

  @override
  String get labelOffAttribution => 'Adatok: Open Food Facts, ODbL licenc';

  @override
  String get labelCandidatesTitle => 'Melyik ezek közül?';

  @override
  String labelCandidatesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hasonló bor',
      one: '1 hasonló bor',
    );
    return '$_temp0';
  }

  @override
  String get labelCandidatesNone => 'Egyik sem';

  @override
  String get labelChipOffline => 'offline';

  @override
  String get labelChipOnline => 'online';

  @override
  String get labelChipCatalog => 'katalógus';

  @override
  String get labelNoProducer => 'nincs megadva termelő';

  @override
  String get labelNoMatch => 'Elolvastam a címkét, de nem ismerem fel a bort';

  @override
  String get labelReadText => 'Beolvasott szöveg';

  @override
  String get labelSearchOnline => 'Keresés online';

  @override
  String get labelOpenLens => 'Megnyitás a Google Lensben';

  @override
  String get labelLensLastResort =>
      'A Google Lens a végső megoldás: a fotó csak akkor kerül a Google apphoz, ha megerősíted.';

  @override
  String get labelLensTitle => 'Megnyitod a Google Lensben?';

  @override
  String get labelLensBody =>
      'A címke elejének fotója a telefonodon lévő Google apphoz vagy az általad választott apphoz kerül, amely a saját szabályai szerint megőrizhet egy másolatot. A Vinoozy nem kapja meg az eredményeket: térj vissza ide, és válaszd ki vagy írd be a bort.';

  @override
  String get labelLensConfirm => 'Google Lens megnyitása';

  @override
  String get labelLensFailed =>
      'Nem tudom megnyitni a Google Lenst vagy a megosztási menüt';

  @override
  String get onlineSearchTitle => 'Keresés online';

  @override
  String get onlineSearchSubtitle => 'Open Food Facts · csak borok';

  @override
  String get onlineSearchField => 'Keresőszavak';

  @override
  String get onlineSearchHint => 'Keresés előtt módosíthatod a szavakat.';

  @override
  String get onlineSearchEmptyField => 'Írj be legalább egy szót';

  @override
  String get onlineSearchButton => 'Keresés';

  @override
  String get onlineSearchLoading => 'Keresés…';

  @override
  String onlineSearchResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count találat',
      one: '1 találat',
    );
    return '$_temp0';
  }

  @override
  String get onlineSearchEmpty =>
      'Nincs találat: próbálj más szavakat vagy a „Beírás kézzel” lehetőséget.';

  @override
  String get onlineSearchOffline =>
      'Nincs hálózat: csak a telefon adatbázisában keresek.';

  @override
  String get onlineSearchRateLimited =>
      'Az online keresés most nem érhető el, próbáld újra néhány perc múlva.';

  @override
  String get onlineSearchUnavailable =>
      'Az online keresés nem aktív az app ezen verziójában: csak a telefon adatbázisában keresek.';

  @override
  String get aboutTitle => 'Névjegy';

  @override
  String aboutVersion(String version) {
    return 'Verzió: $version';
  }

  @override
  String get aboutDbTitle => 'Boradatbázis';

  @override
  String aboutDbCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bor',
      one: '1 bor',
    );
    return '$_temp0';
  }

  @override
  String aboutDbDate(String date) {
    return 'Open Food Facts export, dátum: $date';
  }

  @override
  String get aboutDbSample =>
      'Mintaadatbázis: néhány kézzel írt tesztbor, nem Open Food Facts-adat.';

  @override
  String get aboutDbLoading => 'Boradatbázis megnyitása…';

  @override
  String get aboutDbUnavailable =>
      'A boradatbázis ebben a verzióban nem érhető el';

  @override
  String aboutDbSource(String url) {
    return 'A származtatott adatbázis és az azt előállító eszköz a nyilvános tárolóban található: $url';
  }

  @override
  String get aboutLicenseTitle => 'Licencek';

  @override
  String get aboutLicense =>
      'Az Open Food Facts adatait tartalmazza, amelyek az Open Database License (ODbL) alapján érhetők el. Az egyes tartalmakra a Database Contents License (DbCL) vonatkozik.';

  @override
  String get aboutPrivacyTitle => 'Címkefotók';

  @override
  String get aboutPrivacy =>
      'A címkefotókat a telefon olvassa be, és törlődnek, amikor elhagyod az eredményt. Csak akkor hagyják el a telefont, ha a „Megnyitás a Google Lensben” gombra koppintasz, és megerősíted.';

  @override
  String get aboutAppellationsTitle => 'Eredetmegjelölések';

  @override
  String get aboutAppellationsSource =>
      'Eredetmegjelölések: eAmbrosia nyilvántartás (EU) és hivatalos nemzeti nyilvántartások.';

  @override
  String get aboutAppellationsSample =>
      'Mintatáblázat: a nyilvántartások kézzel írt kivonata, amíg a valódi nyilvántartások le nem töltődnek.';

  @override
  String get denominationLabel => 'Eredetmegjelölés';

  @override
  String get denominationTooLong => 'Legfeljebb 120 karakter';

  @override
  String get autofillFilledNotice =>
      'A címkéről kitöltve: ellenőrizd és mentsd';

  @override
  String get autofillPastedNotice =>
      'A szövegből kitöltve: ellenőrizd és mentsd';

  @override
  String get autofillFromText => '✦ a szövegből';

  @override
  String get autofillFromTextSemantics => 'a címkéről kitöltve';

  @override
  String get autofillClear => 'Ürítés';

  @override
  String get autofillLens => 'Lens';

  @override
  String get autofillClearTitle => 'Üríted az űrlapot?';

  @override
  String get autofillClearBody =>
      'Néhány mezőbe te is írtál. Az „Ürítés” törli a nevet, a termelőt, az eredetmegjelölést, az évjáratot, a típust, az országot, a régiót és a szintet. A mennyiség megmarad.';

  @override
  String get autofillClearConfirm => 'Ürítés';

  @override
  String get autofillCleared => 'Űrlap kiürítve';

  @override
  String get autofillPasteTitle => 'Megvan a szöveg a Google Lensből?';

  @override
  String get autofillPasteHint =>
      'A Lensben jelöld ki a címke szövegét, koppints a „Másolás” gombra, majd térj vissza ide.';

  @override
  String get autofillPaste => 'Beillesztés a Lensből';

  @override
  String get autofillOpenLens => 'Google Lensből';

  @override
  String get autofillOpenLensSemantics => 'megnyitja a Google Lenst';

  @override
  String get autofillClipboardEmpty => 'Nincs szöveg a vágólapon';

  @override
  String get autofillNoNewFields =>
      'A szövegben nem találtam hozzáadható adatot';

  @override
  String get autofillFromLens => 'Űrlap kitöltve a Lens szövegéből';

  @override
  String get autofillShareEmpty => 'Nem érkezett szöveg';

  @override
  String get autofillShareUseTitle =>
      'Felhasználod a szöveget az üres mezőkhöz?';

  @override
  String get autofillShareUse => 'Felhasználás';

  @override
  String get autofillShareIgnore => 'Mellőzés';

  @override
  String get addChoiceLens => 'Google Lensből';

  @override
  String get addChoicePhotoHint =>
      'Elöl és hátul: a Vinoozy elolvassa a címkét.';

  @override
  String get addChoiceLensHint =>
      'Megnyitja a Lenst: irányítsd rá, jelöld ki a szöveget, majd Megosztás → Vinoozy.';

  @override
  String get addChoiceImportHint => 'Egy korábban készült fotó a címkéről.';

  @override
  String get addChoiceWriteHint =>
      'Üres űrlap, „Beillesztés a Lensből” gombbal.';

  @override
  String get lensInstructionsTitle => 'A Google Lens innen nem nyitható meg';

  @override
  String get lensInstructionsStep1 =>
      'Nyisd meg a Google Lenst, és irányítsd a címkére';

  @override
  String get lensInstructionsStep2 => 'Jelöld ki a címke szövegét';

  @override
  String get lensInstructionsStep3 => 'Koppints: Megosztás → Vinoozy';

  @override
  String get lensInstructionsOk => 'Értem';

  @override
  String get levelLabel => 'Szint';

  @override
  String get levelEveryday => 'Hétköznapi (olcsó)';

  @override
  String get levelGood => 'Jó';

  @override
  String get levelAging => 'Érlelhető';

  @override
  String get levelNone => 'Nincs';

  @override
  String get levelEverydayShort => 'idd meg korán';

  @override
  String get levelGoodShort => 'normál becslés';

  @override
  String get levelAgingShort => 'tovább eláll';

  @override
  String get levelSuggested => 'javasolt';

  @override
  String levelSuggestedReason(String qualifier) {
    return 'Javasolt, mert a névben ez szerepel: „$qualifier”. Így mentjük, ha nem módosítod. Válassz másikat, vagy koppints a „Nincs” lehetőségre.';
  }

  @override
  String levelSuggestedSemantics(String qualifier) {
    return 'javasolt, mert a névben ez szerepel: $qualifier';
  }

  @override
  String levelOptionSemantics(String option, int index, int count) {
    return 'Szint, $option, $index., összesen $count';
  }

  @override
  String get levelWhatChanges => 'Mi változik';

  @override
  String get levelEverydayExamples =>
      'Az ablak rövidebb lesz. Pl. házibor, Lambrusco, alap Prosecco, Bardolino, Vinho Verde.';

  @override
  String get levelGoodExamples =>
      'A normál becslés, és ez az érték akkor is, ha semmit sem választasz. Pl. Chianti Classico, Barbera d\'Asti Superiore, Rioja Crianza, Côtes du Rhône.';

  @override
  String get levelAgingExamples =>
      'Az ablak hosszabb lesz. Pl. Barolo, Brunello, Amarone, Bordeaux Grand Cru, Rioja Gran Reserva, Vintage Port.';

  @override
  String levelPreviewBefore(String start, String end) {
    return 'Előtte: $start – $end';
  }

  @override
  String levelPreviewWith(String level, String start, String end) {
    return '„$level” szinttel: $start – $end';
  }

  @override
  String levelPreviewNow(String start, String end) {
    return 'Iható: $start – $end';
  }

  @override
  String levelDetail(String level) {
    return 'Szint: $level';
  }

  @override
  String get overrideCorrect => 'Javítás';

  @override
  String get overrideRestore => 'Becslés visszaállítása';

  @override
  String get overrideCorrectedByYou => 'te javítottad';

  @override
  String overrideAppEstimate(String year) {
    return 'Az app becslése: $year-ig';
  }

  @override
  String get overrideSheetTitle => 'Ajánlott eddig';

  @override
  String overrideSheetHint(String start) {
    return 'Válaszd ki az évet. Nem lehet korábbi ennél: „Iható ettől: $start”.';
  }

  @override
  String overridePeakNotice(String peak) {
    return 'Ha a csúcs événél ($peak) korábbit választasz, a csúcs is ugyanarra az évre kerül.';
  }

  @override
  String get overrideMore => 'több…';

  @override
  String get overrideSave => 'Javítás mentése';

  @override
  String overrideRestoreTitle(String year) {
    return 'Visszatérsz az app becsléséhez ($year-ig)?';
  }

  @override
  String get overrideRestoreConfirm => 'Visszaállítás';

  @override
  String get overrideSaved => 'Javítás mentve';

  @override
  String get overrideRestored => 'Becslés visszaállítva';

  @override
  String get estimateSourceCorrectedByYou => 'te javítottad';

  @override
  String estimateFromDenomination(String name) {
    return 'Becslés az eredetmegjelölés alapján: $name';
  }

  @override
  String estimateFromDenominationQualifier(String name, String qualifier) {
    return 'Becslés az eredetmegjelölés alapján: $name, $qualifier';
  }

  @override
  String estimateFromGrape(String name) {
    return 'Becslés a szőlőfajta alapján: $name';
  }

  @override
  String get estimateFromType => 'Becslés a bor típusa alapján';

  @override
  String get autofillReading => 'Szöveg olvasása…';

  @override
  String get guideChip => 'Vezetett ellenőrzés';

  @override
  String guideProgress(int n, int total) {
    return '$n. kérdés, összesen $total';
  }

  @override
  String get guideClose => 'Bezárás';

  @override
  String get guideIsDenomination => 'ez az eredetmegjelölés?';

  @override
  String get guideIsProducer => 'ez a termelő?';

  @override
  String get guideIsName => 'ez a bor neve?';

  @override
  String get guideIsVintage => 'Évjárat';

  @override
  String guideAskDenomination(String value) {
    return 'Ez az eredetmegjelölés: $value?';
  }

  @override
  String guideAskProducer(String value) {
    return 'Ez a termelő: $value?';
  }

  @override
  String guideAskName(String value) {
    return 'Ez a bor neve: $value?';
  }

  @override
  String get guideAskVintage => 'Melyik az évjárat?';

  @override
  String guideQuestionSemantics(int n, int total, String question) {
    return '$n. kérdés, összesen $total: $question';
  }

  @override
  String get guideNoProposal => 'Nem találtam meg a szövegben';

  @override
  String get guideYes => 'Igen';

  @override
  String get guideNo => 'Nem, másik';

  @override
  String get guideEdit => 'Szerkesztés';

  @override
  String get guideSkip => 'Kihagyás';

  @override
  String get guideConfirm => 'Megerősítés';

  @override
  String get guideCancel => 'Mégse';

  @override
  String guideRejected(String value) {
    return 'Nem „$value”: itt a következő';
  }

  @override
  String get guideNoMore => 'Nincs több javaslat: állítsd össze, vagy hagyd ki';

  @override
  String guideProposalAnnounce(String value) {
    return 'Javaslat: $value';
  }

  @override
  String get guideComposeLabel =>
      'Vagy állítsd össze a szöveg szavaira koppintva';

  @override
  String get guideComposePreview => 'Előnézet';

  @override
  String get guideComposeEmpty => 'Koppints egy vagy több szóra';

  @override
  String get guideComposeLimit => 'Legfeljebb 8 szó és 80 karakter';

  @override
  String guideTableMatchSemantics(String name) {
    return 'egyezik ezzel: $name';
  }

  @override
  String guideLine(int n, int total) {
    return '$n. sor, összesen $total';
  }

  @override
  String guideWordSelected(String word, int order) {
    return '$word, kijelölve, $order';
  }

  @override
  String guideWordUnavailable(String word) {
    return '$word, nem érhető el';
  }

  @override
  String guideWordUsedFor(String word, String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'eredetmegjelölés',
      'producer': 'termelő',
      'other': 'név',
    });
    return '$word, már használva itt: $_temp0';
  }

  @override
  String guideUsedMark(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'eredetmegjelölés',
      'producer': 'termelő',
      'other': 'név',
    });
    return '$_temp0';
  }

  @override
  String guideOtherYears(String years) {
    return 'A szövegben még: $years';
  }

  @override
  String get guideWheelFromText => 'a szövegben talált év';

  @override
  String get guideWheelTypeYear => 'Írd be az évet';

  @override
  String guideWheelConfirm(String year) {
    return 'Megerősítés: $year';
  }

  @override
  String get guideNoVintage => 'Évjárat nélkül';

  @override
  String guideSkippedNotice(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'Eredetmegjelölés kihagyva',
      'producer': 'Termelő kihagyva',
      'vintage': 'Évjárat kihagyva',
      'other': 'Név kihagyva',
    });
    return '$_temp0: írd be, vagy folytasd a segédet';
  }

  @override
  String guideSkippedMany(int count) {
    return 'Kihagyott mezők: $count. Írd be őket, vagy folytasd a segédet';
  }

  @override
  String get guideInvalidValue =>
      'Ez a szöveg nem menthető karaktereket tartalmaz';

  @override
  String get brandStudio => 'Bottazzini Softworks';

  @override
  String get suggestedMark => '✦ javasolt';

  @override
  String suggestedSemantics(String field, String value) {
    return '$field, $value, javasolt';
  }

  @override
  String get restoreSuggestion => 'Javaslat visszaállítása';

  @override
  String get restoreSuggestionDone => 'Javaslat visszaállítva';

  @override
  String get styleLabel => 'Stílus';

  @override
  String styleGroupSemantics(String value, int index, int count) {
    return 'Stílus, $value, $index., összesen $count';
  }

  @override
  String get styleRedFresh => 'Friss';

  @override
  String get styleRedMedium => 'Közepes';

  @override
  String get styleRedAge => 'Érlelhető';

  @override
  String get styleRedLong => 'Hosszan érlelhető';

  @override
  String get styleWhiteFresh => 'Friss';

  @override
  String get styleWhiteMedium => 'Közepes';

  @override
  String get styleWhiteAge => 'Érlelhető';

  @override
  String get styleRoseFresh => 'Friss';

  @override
  String get styleClassicFresh => 'Friss';

  @override
  String get styleClassicAge => 'Érlelhető';

  @override
  String get styleTankFresh => 'Friss';

  @override
  String get styleLambrusco => 'Lambrusco';

  @override
  String get styleSweetAromatic => 'Illatos';

  @override
  String get styleSweetPassito => 'Töppedt szőlőből';

  @override
  String get styleSweetBotrytis => 'Aszúsodott';

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
  String get styleFortifiedOther => 'Egyéb';

  @override
  String get profileNameRFresh => 'Gyümölcsös vörös';

  @override
  String get profileNameRMedium => 'Közepes testű vörös';

  @override
  String get profileNameRAge => 'Érlelhető vörös';

  @override
  String get profileNameRLong => 'Hosszan érlelhető vörös';

  @override
  String get profileNameWFresh => 'Friss, illatos fehér';

  @override
  String get profileNameWMedium => 'Közepes testű fehér';

  @override
  String get profileNameWAge => 'Érlelhető fehér';

  @override
  String get profileNameRoseFresh => 'Friss rozé';

  @override
  String get profileNameSpTank => 'Friss tankpezsgő';

  @override
  String get profileNameLamFresh => 'Friss Lambrusco';

  @override
  String get profileNameSpClassic => 'Friss tradicionális pezsgő';

  @override
  String get profileNameSpClassicAge => 'Érlelhető tradicionális pezsgő';

  @override
  String get profileNameSwAromatic => 'Fiatal, illatos édes bor';

  @override
  String get profileNameSwPassito => 'Édes bor töppedt szőlőből';

  @override
  String get profileNameSwBotrytis => 'Aszúsodott édes bor';

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
  String get profileNameFortUnknown => 'Erősített, ismeretlen stílus';

  @override
  String get profileNameUnknown => 'Azonosítatlan stílus';

  @override
  String estimateFromProfile(String profile, String denomination) {
    return 'Becslés a profil alapján: $profile ($denomination)';
  }

  @override
  String estimateFromProfileType(String profile) {
    return 'Becslés a profil alapján: $profile, típus szerint';
  }

  @override
  String estimateFromProfileGrape(String profile, String grape) {
    return 'Becslés a profil alapján: $profile, szőlőfajta: $grape';
  }

  @override
  String get estimateFromEntryDateDisgorgement =>
      'A hozzáadás dátumától: jobb becsléshez add meg a degorzsálás dátumát';

  @override
  String get estimateFromEntryDateBottling =>
      'A hozzáadás dátumától: jobb becsléshez add meg a palackozás dátumát';

  @override
  String get styleToConfirmBanner =>
      '⚠︎ Megerősítendő stílus: a becslés tájékoztató';

  @override
  String get chooseTypePrompt => 'Válassz típust';

  @override
  String estimateUpdatedAnnouncement(String summary) {
    return 'Becslés frissítve: $summary';
  }

  @override
  String get agingStartDisgorgement => 'Degorzsálás';

  @override
  String get agingStartBottling => 'Palackozás';

  @override
  String get agingStartMonth => 'Hónap';

  @override
  String get agingStartYear => 'Év';

  @override
  String get agingStartHint => 'Általában a hátcímkén található.';

  @override
  String get agingStartIncomplete => 'Add meg a hónapot és az évet';

  @override
  String get agingStartFuture => 'A dátum nem lehet jövőbeli';

  @override
  String get agingStartBeforeVintage => 'Nem lehet az évjáratnál korábbi';

  @override
  String get windowNoEnd => 'Iható, nincs becsült vége';

  @override
  String get windowNoEndShort => 'nincs becsült vége';

  @override
  String windowDrinkWithin(String date) {
    return 'legkésőbb: $date';
  }

  @override
  String get levelNoEffect => 'A szint nem módosítja ezt a becslést';

  @override
  String get dashboardToConfirmTitle => 'Megerősítendő';

  @override
  String dashboardToConfirmCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bor',
      one: '1 bor',
    );
    return '$_temp0';
  }

  @override
  String aboutDbClassified(String percent) {
    return 'Felismert típusú borok aránya: $percent%';
  }

  @override
  String get planTitle => 'Csomag';

  @override
  String get planFree => 'Ingyenes';

  @override
  String get planPlus => 'Plus';

  @override
  String get planPlusGift => 'Plus (ajándék)';

  @override
  String get planDevUnlockAll => 'DEV · Teszt Plus';

  @override
  String get planDevSimulateFree => 'DEV · Szimulált ingyenes csomag';

  @override
  String get planDevSimulateExpired => 'DEV · Szimulált lejárt Plus';

  @override
  String get planDiscoverPlus => 'Ismerd meg a Plust';

  @override
  String get plusTitle => 'Vinoozy Plus';

  @override
  String get plusBenefitsTitle => 'A Plusszal';

  @override
  String get plusBenefitNoAds => 'Hirdetések nélkül';

  @override
  String get plusBenefitNoLimit => 'Nincs korlát a pincédben lévő borokra';

  @override
  String get plusComingSoon => 'A Plus hamarosan érkezik';

  @override
  String get plusLoading => 'Árak beolvasása a Google Playről';

  @override
  String get plusStoreUnavailable =>
      'Nem sikerült beolvasni az árakat a Google Playről. Próbáld újra később.';

  @override
  String plusPriceMonthly(String price) {
    return '$price / hó';
  }

  @override
  String plusPriceAnnual(String price) {
    return '$price / év';
  }

  @override
  String get plusRenewal =>
      'Az előfizetés a megjelenített áron automatikusan megújul, amíg le nem mondod a Google Playen.';

  @override
  String get plusTerms =>
      'A fizetés a vásárlás megerősítésekor a Google Play-fiókodat terheli. Bármikor lemondhatod: a Plus a már kifizetett időszak végéig aktív marad. Amikor a Plus véget ér, minden borod megmarad.';

  @override
  String get plusRestore => 'Vásárlások visszaállítása';

  @override
  String get plusManage => 'Előfizetés kezelése vagy lemondása a Google Playen';

  @override
  String get plusActive => 'A Plus aktív ezen a fiókon';

  @override
  String get plusActiveGift =>
      'A Plust ajándékba kaptad: nincs díj és nincs megújítás.';

  @override
  String get plusPending =>
      'Függő fizetés: a Plus akkor lesz aktív, amikor a Google Play megerősíti.';

  @override
  String get plusVerifying => 'Vásárlás ellenőrzése';

  @override
  String get plusVerified =>
      'Vásárlás ellenőrizve: a Plus néhány másodpercen belül aktív lesz.';

  @override
  String get plusPurchaseFailed =>
      'A vásárlás nem fejeződött be. Próbáld újra.';

  @override
  String get plusInvalidPurchase =>
      'A Google Play nem erősítette meg ezt a vásárlást a Vinoozy számára.';

  @override
  String get plusOwnedByOther =>
      'Ez az előfizetés már egy másik Vinoozy-fiókhoz tartozik.';

  @override
  String get plusVerificationUnavailable =>
      'A vásárlást most nem sikerült ellenőrizni. Próbáld újra később: az előfizetés megmarad a Google Playen.';

  @override
  String get capacityLimitTitle => 'Elérted az ingyenes csomag korlátját';

  @override
  String capacityLimitBody(int limit) {
    return 'Az ingyenes csomagban legfeljebb $limit különböző bor lehet a pincédben. A meglévő boraidat bármikor szerkesztheted, megihatod, és palackot is adhatsz hozzájuk. Új bor felvételéhez fogyassz el vagy törölj egy bort, vagy válts Plusra.';
  }

  @override
  String capacityLimitBodyComingSoon(int limit) {
    return 'Az ingyenes csomagban legfeljebb $limit különböző bor lehet a pincédben. A meglévő boraidat bármikor szerkesztheted, megihatod, és palackot is adhatsz hozzájuk. Új bor felvételéhez fogyassz el vagy törölj egy bort. A Plus hamarosan érkezik.';
  }

  @override
  String get rejectedCapacityLimit =>
      'Nincs szinkronizálva: túllépi az ingyenes csomag borkorlátját. A módosítás ezen a telefonon marad.';

  @override
  String get rejectedCapacityConflict =>
      'Nincs szinkronizálva: a pince ugyanakkor egy másik eszközön is változott. A módosítás ezen a telefonon marad: próbáld újra.';

  @override
  String writeRejectedCapacityLimit(String name) {
    return '$name: nincs szinkronizálva, túllépi az ingyenes csomag korlátját';
  }

  @override
  String writeRejectedCapacityConflict(String name) {
    return '$name: nincs szinkronizálva, a pince egy másik eszközön változott';
  }

  @override
  String get freeIntroTitle => 'Az ingyenes csomag';

  @override
  String freeIntroLimit(int limit) {
    return 'Ingyen legfeljebb $limit különböző bort kezelhetsz.';
  }

  @override
  String get freeIntroAds =>
      'Kevés használat mellett nincsenek hirdetések. Ha túlléped a szolgáltatás havi használati küszöbét, alkalmanként hirdetéseket láthatsz, amelyek segítenek fedezni a szerverek és a szinkronizálás költségeit.';

  @override
  String get freeIntroNoAds => 'Az induló verzióban nincsenek hirdetések.';

  @override
  String get freeIntroPlus =>
      'A Plusszal megszűnnek a hirdetések és a pince korlátja.';

  @override
  String get noticeGotIt => 'Értem';

  @override
  String get thresholdTitle =>
      'A hirdetések segítenek, hogy a Vinoozy ingyenes maradjon';

  @override
  String get thresholdBody =>
      'Elérted a hirdetésmentes használat havi küszöbét. Mostantól alkalmanként hirdetéseket láthatsz: ezek segítenek fedezni a szerverek és a szinkronizálás költségeit, így a Vinoozy ingyenes maradhat.';

  @override
  String get thresholdReset =>
      'A számlálás a következő hónapban újraindul. A Plusszal hirdetések és pincekorlát nélkül használhatod az appot.';

  @override
  String thresholdNextReset(String date) {
    return 'Következő nullázás: $date';
  }

  @override
  String get thresholdHowItWorks => 'Hogyan működik';

  @override
  String get thresholdHowItWorksBody =>
      'A küszöb azon alapul, hogy becslés szerint ez a fiók a hónap során hányszor szinkronizált a felhővel. Az offline használat önmagában nem hoz létre új felhőműveletet. Hirdetés legfeljebb naponta egyszer jelenik meg, csak az Áttekintésben, és soha nem akkor, amikor az adataidat mented vagy exportálod.';

  @override
  String get adLabel => 'Hirdetés';

  @override
  String get devToolsTitle => 'Fejlesztői eszközök';

  @override
  String get devUnlockAll => 'Minden feloldása — teszt Plus';

  @override
  String get devSimulateFree => 'Ingyenes csomag szimulálása';

  @override
  String get devSimulateExpired => 'Lejárt Plus szimulálása';

  @override
  String get devRestore => 'Normál állapot visszaállítása';

  @override
  String get devNoOverride => 'Nincs aktív szimuláció';

  @override
  String get devApplied =>
      'A forgatókönyv a Firestore-emulátorban is érvényben van';

  @override
  String get devIncomplete =>
      'Hiányos szimuláció: a Firestore-emulátor nem erősítette meg a tesztjogosultságot. A szerverszabályok nem látják ezt a forgatókönyvet.';

  @override
  String get devNotice =>
      'Csak fejlesztői buildek emulátorral: nincs fizetés, token vagy nyugta.';
}
