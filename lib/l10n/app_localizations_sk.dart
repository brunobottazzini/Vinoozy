// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Slovak (`sk`).
class AppLocalizationsSk extends AppLocalizations {
  AppLocalizationsSk([String locale = 'sk']) : super(locale);

  @override
  String get appTitle => 'Vinoozy';

  @override
  String get signInTagline => 'Vaša pivnica, v pravý čas';

  @override
  String get signInWithGoogle => 'Pokračovať cez Google';

  @override
  String get signInInProgress => 'Prihlasovanie';

  @override
  String get signInFailed => 'Prihlásenie zlyhalo';

  @override
  String get signInNeedsNetwork => 'Na prvé prihlásenie je potrebné pripojenie';

  @override
  String get signInSessionExpired => 'Relácia vypršala: prihláste sa znova';

  @override
  String get retry => 'Skúsiť znova';

  @override
  String get cancel => 'Zrušiť';

  @override
  String blockedMessage(String email) {
    return 'Zmeny z účtu $email ešte nie sú uložené v cloude: prihláste sa týmto účtom a pripojte sa k sieti';
  }

  @override
  String blockedSignInWith(String email) {
    return 'Prihlásiť sa ako $email';
  }

  @override
  String blockedDiscard(String email) {
    return 'Odstrániť neuložené zmeny z účtu $email';
  }

  @override
  String get discardDialogTitle => 'Odstrániť zmeny?';

  @override
  String discardDialogBody(int count, String email) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count vín z účtu $email ešte nie je v cloude a z tohto telefónu sa odstráni.',
      many:
          '$count vína z účtu $email ešte nie je v cloude a z tohto telefónu sa odstráni.',
      few:
          '$count vína z účtu $email ešte nie sú v cloude a z tohto telefónu sa odstránia.',
      one:
          '$count víno z účtu $email ešte nie je v cloude a z tohto telefónu sa odstráni.',
    );
    return '$_temp0';
  }

  @override
  String get discardConfirm => 'Odstrániť';

  @override
  String get resetFailed => 'Údaje v tomto telefóne sa nepodarilo vymazať';

  @override
  String get restartRequired => 'Na dokončenie aplikáciu reštartujte';

  @override
  String get restartCloseApp => 'Zavrieť aplikáciu';

  @override
  String get startupFailed => 'Aplikáciu sa nepodarilo spustiť';

  @override
  String get cellarTitle => 'Pivnica';

  @override
  String get defaultCellarName => 'Moja pivnica';

  @override
  String get cellarLoading => 'Príprava pivnice';

  @override
  String get cellarSetupFailed => 'Pivnicu sa nepodarilo pripraviť';

  @override
  String get cellarEmpty => 'Vaša pivnica je prázdna';

  @override
  String get addWine => 'Pridať';

  @override
  String get estimatePending => 'Odhad sa pripravuje';

  @override
  String get noVintage => 'Bez ročníka';

  @override
  String bottleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fliaš',
      many: '$count fľaše',
      few: '$count fľaše',
      one: '$count fľaša',
    );
    return '$_temp0';
  }

  @override
  String get syncInProgress => 'Synchronizácia';

  @override
  String get syncOffline => 'Offline - synchronizácia čaká';

  @override
  String writeRejected(String name) {
    return 'Zmena nie je povolená: $name';
  }

  @override
  String get saveFailed => 'Uloženie zlyhalo, skúste to znova';

  @override
  String wineNotSaved(String name) {
    return 'Víno $name sa neuložilo do cloudu';
  }

  @override
  String get addAgain => 'Pridať znova';

  @override
  String get ignore => 'Ignorovať';

  @override
  String get addWineTitle => 'Napísať';

  @override
  String get wineNameLabel => 'Víno';

  @override
  String get vintageLabel => 'Ročník';

  @override
  String get quantityLabel => 'Množstvo';

  @override
  String get decreaseQuantity => 'Znížiť množstvo';

  @override
  String get increaseQuantity => 'Zvýšiť množstvo';

  @override
  String get save => 'Uložiť';

  @override
  String get nameRequired => 'Napíšte názov vína';

  @override
  String get nameTooLong => 'Najviac 120 znakov';

  @override
  String vintageRange(String year) {
    return 'Ročník medzi 1900 a $year';
  }

  @override
  String get offAttribution => 'Údaje z Open Food Facts (ODbL)';

  @override
  String get dashboardTitle => 'Prehľad';

  @override
  String dashboardTotalBottles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fliaš v pivnici',
      many: '$count fľaše v pivnici',
      few: '$count fľaše v pivnici',
      one: '$count fľaša v pivnici',
    );
    return '$_temp0';
  }

  @override
  String get dashboardSyncing => 'Synchronizácia pivnice…';

  @override
  String get dashboardAddFirstWine => 'Pridať prvé víno';

  @override
  String get drinkSoonTitle => 'Vypiť čoskoro';

  @override
  String get drinkSoonEmpty => 'Žiadne fľaše na skoré vypitie';

  @override
  String drinkSoonUntil(String year) {
    return 'do $year';
  }

  @override
  String drinkSoonSeeAll(int count) {
    return 'Zobraziť všetko ($count)';
  }

  @override
  String get statusChartTitle => 'Stav fliaš';

  @override
  String get statusWaiting => 'počkať';

  @override
  String get statusReady => 'pripravené';

  @override
  String get statusDrinkSoon => 'vypiť čoskoro';

  @override
  String get statusPastWindow => 'po okne pitnosti';

  @override
  String toEstimateNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fliaš na odhad',
      many: '$count fľaše na odhad',
      few: '$count fľaše na odhad',
      one: '$count fľaša na odhad',
    );
    return '$_temp0';
  }

  @override
  String chartBarValue(String label, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fliaš',
      many: '$count fľaše',
      few: '$count fľaše',
      one: '$count fľaša',
    );
    return '$label: $_temp0';
  }

  @override
  String chartDescription(String title, String values) {
    return '$title: $values';
  }

  @override
  String get openListHint => 'Otvoriť zoznam';

  @override
  String get peakChartTitle => 'Rok vrcholu';

  @override
  String get peakPast => 'po vrchole';

  @override
  String get peakBeyond => 'neskôr';

  @override
  String get breakdownTypeTitle => 'Fľaše podľa typu';

  @override
  String get breakdownRegionTitle => 'Fľaše podľa regiónu';

  @override
  String get breakdownType => 'Typ';

  @override
  String get breakdownRegion => 'Región';

  @override
  String get familyRed => 'červené';

  @override
  String get familyWhite => 'biele';

  @override
  String get familyRose => 'ružové';

  @override
  String get familySparkling => 'šumivé';

  @override
  String get familySweet => 'sladké';

  @override
  String get breakdownUnspecified => 'neuvedené';

  @override
  String get breakdownOtherRegions => 'ostatné';

  @override
  String get ok => 'OK';

  @override
  String get cellarMenu => 'Ponuka pivnice';

  @override
  String get sharingPeopleTitle => 'Ľudia';

  @override
  String get sharingInviteTitle => 'Pozvať niekoho';

  @override
  String get sharingEmailLabel => 'E-mailová adresa Google';

  @override
  String get sharingPermissionRead => 'Len na čítanie';

  @override
  String get sharingPermissionReadHint =>
      'Vidí vína, odhady, prehľad a vypité fľaše';

  @override
  String get sharingPermissionEdit => 'Môže upravovať';

  @override
  String get sharingPermissionEditHint =>
      'Tiež pridáva a mení vína a zapisuje vypité fľaše';

  @override
  String get sharingRoleOwner => 'vlastník';

  @override
  String get sharingInviteButton => 'Pozvať';

  @override
  String sharingPlacesUsed(int used, int max) {
    return 'Ľudia: $used/$max';
  }

  @override
  String get sharingInvalidEmail => 'Zadajte platný e-mail';

  @override
  String get sharingSelfInvite => 'Nemôžete pozvať sami seba';

  @override
  String get sharingAlreadyInvited => 'Tento človek už pozvánku má';

  @override
  String sharingLimitReached(int max) {
    return 'Limit počtu ľudí je vyčerpaný: $max';
  }

  @override
  String get sharingNotOwner => 'Zdieľanie tejto pivnice nemôžete meniť';

  @override
  String get sharingNotFound => 'Tento človek už v zozname nie je';

  @override
  String get sharingFailed => 'Nepodarilo sa, skúste to znova';

  @override
  String get sharingInviteFailed => 'Pozvanie zlyhalo. Skúste to znova';

  @override
  String get sharingOfflineHint => 'Na správu zdieľania je potrebné pripojenie';

  @override
  String get sharingStatusInvited => 'pozvánka odoslaná';

  @override
  String get sharingStatusActive => 'aktívny prístup';

  @override
  String get sharingStatusRevoked => 'prístup odobratý';

  @override
  String get sharingStatusLeft => 'pivnica opustená';

  @override
  String sharingMemberSemantics(String name, String permission, String status) {
    return '$name, $permission, $status';
  }

  @override
  String get sharingClosedSection => 'Ukončené prístupy';

  @override
  String get sharingNobody => 'Túto pivnicu zatiaľ nikto ďalší nevidí';

  @override
  String sharingChangePermission(String name) {
    return 'Zmeniť oprávnenie: $name';
  }

  @override
  String get sharingRevoke => 'Odobrať';

  @override
  String sharingRevokeTitle(String name) {
    return 'Odobrať prístup používateľovi $name?';
  }

  @override
  String sharingRevokeConfirmLabel(String name) {
    return 'Potvrďte napísaním: $name';
  }

  @override
  String get sharingRevokeDisabledHint => 'Aktívne, keď sa meno zhoduje';

  @override
  String get sharingReinvite => 'Pozvať znova';

  @override
  String get sharingDeleteForGood => 'Odstrániť natrvalo';

  @override
  String sharingOwnedBy(String owner) {
    return 'Pivnica: $owner';
  }

  @override
  String get sharingYourCellar => 'Vaša pivnica';

  @override
  String sharingYourPermission(String permission) {
    return 'Vaše oprávnenie: $permission';
  }

  @override
  String sharingSwitcherSemantics(String cellar, String permission) {
    return '$cellar, $permission. Klepnutím zmeníte pivnicu';
  }

  @override
  String get sharingLeave => 'Opustiť túto pivnicu';

  @override
  String sharingLeaveTitle(String owner) {
    return 'Opustiť pivnicu, ktorej vlastníkom je $owner?';
  }

  @override
  String sharingLeaveBody(String owner) {
    return 'Už ju neuvidíte. $owner vás môže pozvať znova.';
  }

  @override
  String get sharingLeaveConfirm => 'Opustiť';

  @override
  String sharingSharedNotice(String owner) {
    return '$owner s vami zdieľa svoju pivnicu';
  }

  @override
  String sharingAccessLost(String owner) {
    return 'Už nemáte prístup do pivnice, ktorej vlastníkom je $owner';
  }

  @override
  String sharingWritesLost(String owner) {
    return 'Niektoré zmeny v pivnici, ktorej vlastníkom je $owner, sa neuložili, pretože už nemáte prístup';
  }

  @override
  String get sharingSomeone => 'niekto';

  @override
  String get sharingShareSubject => 'Pozvánka do Vinoozy';

  @override
  String sharingShareMessage(
    String owner,
    String cellar,
    String link,
    String email,
  ) {
    return '$owner vás pozýva do pivnice „$cellar“ vo Vinoozy. Nainštalujte si aplikáciu z $link a prihláste sa účtom Google $email: použite presne túto adresu.';
  }

  @override
  String get cellarSearchHint => 'Hľadať podľa názvu alebo vinárstva';

  @override
  String get cellarFilterStatus => 'Stav';

  @override
  String get cellarFilterType => 'Typ';

  @override
  String get statusToEstimate => 'Na odhad';

  @override
  String get filterTypeUnspecified => 'Neuvedené';

  @override
  String get cellarNoMatches => 'Týmto filtrom nezodpovedá žiadne víno';

  @override
  String get cellarClearFilters => 'Vymazať filtre';

  @override
  String get cellarArchiveTitle => 'Vypité';

  @override
  String get cellarArchiveEmpty => 'Zatiaľ žiadne dopité vína';

  @override
  String get cellarArchiveFailed => 'Dopité vína sa nepodarilo načítať';

  @override
  String get wineDrink => 'Vypité';

  @override
  String wineDrinkTooltip(String name) {
    return 'Označiť ako vypitú fľašu vína $name';
  }

  @override
  String confidenceLabel(String level) {
    return 'Spoľahlivosť: $level';
  }

  @override
  String get confidenceHigh => 'vysoká';

  @override
  String get confidenceMedium => 'stredná';

  @override
  String get confidenceLow => 'nízka';

  @override
  String get windowStartLabel => 'Začiatok';

  @override
  String get windowPeakLabel => 'Vrchol';

  @override
  String get windowEndLabel => 'Koniec';

  @override
  String estimateSourceLabel(String source) {
    return 'Zdroj: $source';
  }

  @override
  String get estimateSourceCatalog => 'databáza vín';

  @override
  String get estimateSourceType => 'odhad pre typ';

  @override
  String get estimateSourceCorrected => 'odhad upravený podľa vypitých fliaš';

  @override
  String get estimateDisclaimer =>
      'Orientačný odhad: závisí aj od toho, ako bola fľaša skladovaná';

  @override
  String get estimateUnavailable => 'Odhad nie je k dispozícii';

  @override
  String get pairingsTitle => 'Párovanie';

  @override
  String get pairingsGeneric => 'všeobecné párovanie pre typ';

  @override
  String get pairingBraisedRedMeat => 'Dusené červené mäso';

  @override
  String get pairingGrilledRedMeat => 'Grilované červené mäso';

  @override
  String get pairingGame => 'Divina';

  @override
  String get pairingRoastPoultry => 'Pečená hydina';

  @override
  String get pairingPoultry => 'Hydina';

  @override
  String get pairingPork => 'Bravčové mäso';

  @override
  String get pairingCuredMeats => 'Údeniny';

  @override
  String get pairingPastaMeatSauce => 'Cestoviny s mäsovou omáčkou';

  @override
  String get pairingMushroomsTruffle => 'Huby a hľuzovky';

  @override
  String get pairingAgedCheese => 'Zrejúce syry';

  @override
  String get pairingFreshCheese => 'Čerstvé syry';

  @override
  String get pairingBlueCheese => 'Syry s modrou plesňou';

  @override
  String get pairingFish => 'Ryby';

  @override
  String get pairingSeafood => 'Morské plody';

  @override
  String get pairingRawSeafood => 'Surové morské plody';

  @override
  String get pairingFriedFood => 'Vyprážané jedlá';

  @override
  String get pairingVegetables => 'Zelenina';

  @override
  String get pairingRisotto => 'Rizoto';

  @override
  String get pairingPizza => 'Pizza';

  @override
  String get pairingAperitif => 'Aperitív';

  @override
  String get pairingPastries => 'Sladké pečivo';

  @override
  String get pairingDryBiscuits => 'Suché sušienky';

  @override
  String get pairingChocolate => 'Čokoláda';

  @override
  String get pairingDriedFruit => 'Orechy a sušené ovocie';

  @override
  String get pairingSpicyDishes => 'Pikantné jedlá';

  @override
  String get recentDrinksTitle => 'Naposledy vypité';

  @override
  String get noDrinksYet => 'Zatiaľ nič vypité';

  @override
  String get wineEdit => 'Upraviť';

  @override
  String get wineDelete => 'Odstrániť';

  @override
  String get wineFinished => 'Dopité: žiadne fľaše nezostali';

  @override
  String get wineLoadFailed => 'Víno sa nepodarilo otvoriť';

  @override
  String get wineNotFound => 'Toto víno už neexistuje';

  @override
  String drinkDone(String name) {
    return 'Označené ako vypité: $name';
  }

  @override
  String get drinkUndo => 'Vrátiť späť';

  @override
  String get drinkAddNotes => 'Pridať hodnotenie a poznámky';

  @override
  String get nothingToUndo => 'Už nie je čo vrátiť';

  @override
  String get cellarUndoRejected =>
      'Vrátenie zlyhalo: fľaša zostáva označená ako vypitá';

  @override
  String get cellarDeleteFailed =>
      'Odstraňovanie ešte nie je dokončené: dokončí sa hneď, ako to bude možné';

  @override
  String get duplicateFull =>
      'Toto víno už má 99 fliaš: ďalšie sa pridať nedajú.';

  @override
  String get recordSheetTitle => 'Hodnotenie a poznámky';

  @override
  String get recordRatingLabel => 'Hodnotenie';

  @override
  String ratingStar(int n) {
    return 'Hodnotenie $n z 5';
  }

  @override
  String get recordNotesLabel => 'Poznámky';

  @override
  String get recordNotesTooLong => 'Najviac 1000 znakov';

  @override
  String recordDateLabel(String date) {
    return 'Dátum: $date';
  }

  @override
  String get recordDateInvalid =>
      'Dátum nesmie byť v budúcnosti ani pred ročníkom';

  @override
  String get recordConditionTitle => 'Aké bolo?';

  @override
  String get conditionTooYoung => 'Ešte príliš mladé';

  @override
  String get conditionJustRight => 'Tak akurát';

  @override
  String get conditionPastPeak => 'Za vrcholom';

  @override
  String get recordNoCondition => 'Bez odpovede';

  @override
  String get producerLabel => 'Vinárstvo (nepovinné)';

  @override
  String get producerTooLong => 'Najviac 120 znakov';

  @override
  String producerAddNew(String name) {
    return 'Pridať nové vinárstvo: „$name“';
  }

  @override
  String get wineTypeLabel => 'Typ';

  @override
  String get typeRedLight => 'Ľahké červené';

  @override
  String get typeRedStructured => 'Plné červené';

  @override
  String get typeWhite => 'Biele';

  @override
  String get typeRose => 'Ružové';

  @override
  String get typeSparklingClassic => 'Šumivé klasickou metódou';

  @override
  String get typeSparklingTank => 'Šumivé metódou Charmat';

  @override
  String get typeSweet => 'Sladké';

  @override
  String get typeFortified => 'Fortifikované';

  @override
  String get suggestionFromCellar => 'Vo vašej pivnici';

  @override
  String get suggestionsLabel => 'Návrhy';

  @override
  String get duplicateTitle => 'Už je v pivnici';

  @override
  String duplicateBody(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'má $count fliaš',
      many: 'má $count fľaše',
      few: 'má $count fľaše',
      one: 'má $count fľašu',
      zero: 'nemá žiadne fľaše',
    );
    return '$name: toto víno už v pivnici je, $_temp0. Pridať nové fľaše k nemu?';
  }

  @override
  String duplicateAdd(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Pridať $count fliaš',
      many: 'Pridať $count fľaše',
      few: 'Pridať $count fľaše',
      one: 'Pridať $count fľašu',
    );
    return '$_temp0';
  }

  @override
  String get duplicateBanner => 'Možný duplikát';

  @override
  String get duplicateMerge => 'Zlúčiť';

  @override
  String get duplicateDeleteHint => 'Ak ide o duplikát, tento záznam odstráňte';

  @override
  String get mergeTitle => 'Zlúčiť oba záznamy?';

  @override
  String get mergeBody =>
      'Fľaše z tohto záznamu sa presunú do staršieho a tento záznam sa odstráni.';

  @override
  String get editWineTitle => 'Upraviť víno';

  @override
  String get editDuplicate =>
      'Iné víno s rovnakým názvom, vinárstvom a ročníkom už existuje';

  @override
  String deleteWineTitle(String name) {
    return 'Odstrániť víno $name?';
  }

  @override
  String get deleteWineBody =>
      'Víno aj všetky záznamy o vypitých fľašiach sa odstránia. Nedá sa to vrátiť späť.';

  @override
  String get historyTitle => 'História';

  @override
  String get historyEmpty => 'Tu nájdete vypité fľaše';

  @override
  String get historyLoadFailed => 'Históriu sa nepodarilo načítať';

  @override
  String drankOnLabel(String date) {
    return 'Vypité: $date';
  }

  @override
  String get addChoiceTitle => 'Pridať víno';

  @override
  String get addChoicePhoto => 'Odfotiť';

  @override
  String get addChoiceImport => 'Importovať fotku';

  @override
  String get addChoiceWrite => 'Napísať';

  @override
  String get labelReading => 'Čítam etiketu…';

  @override
  String get labelRecognized => 'Rozpoznané:';

  @override
  String get labelCorrect => 'Opraviť';

  @override
  String get labelConfirm => 'Potvrdiť';

  @override
  String get labelUnreadable => 'Etiketu sa nedarí prečítať';

  @override
  String get labelWriteByHand => 'Napísať ručne';

  @override
  String get labelNotFound => 'Víno sa nenašlo: skontrolujte údaje';

  @override
  String get labelCameraDenied =>
      'Na čítanie etikety je potrebný prístup k fotoaparátu';

  @override
  String get labelPhotosDenied =>
      'Na čítanie etikety je potrebný prístup k fotkám';

  @override
  String get labelOpenSettings => 'Otvoriť nastavenia';

  @override
  String get labelCameraUnavailable => 'Fotoaparát nie je k dispozícii';

  @override
  String get labelBarcodeNotFound =>
      'Čiarový kód je prečítaný, ale víno sa nenašlo';

  @override
  String get labelBarcodeFrontHint => 'Odfoťte prednú etiketu';

  @override
  String get labelSharedNotAllowed => 'Do tejto pivnice nemôžete pridávať vína';

  @override
  String get labelSharedFirstOnly => 'Použitá len prvá fotka';

  @override
  String get labelSharedExpired =>
      'Zdieľanú fotku sa nepodarilo prečítať: zdieľajte ju znova';

  @override
  String get labelReplaceTitle => 'Máte neuložené víno. Prečítať novú fotku?';

  @override
  String get labelReplaceRead => 'Prečítať novú fotku';

  @override
  String get labelReplaceKeep => 'Pokračovať s otvoreným';

  @override
  String get labelWineAdded => 'Víno pridané do pivnice';

  @override
  String get onboardingPage1Title => 'Vaša pivnica vo vrecku';

  @override
  String get onboardingPage1Body =>
      'Pridávajte fľaše zápisom alebo fotkou etikety, aj bez siete.';

  @override
  String get onboardingPage2Title => 'V pravý čas';

  @override
  String get onboardingPage2Body =>
      'Vinoozy odhaduje, kedy je každé víno najlepšie, a poradí, ktoré otvoriť skôr.';

  @override
  String get onboardingPage3Title => 'Spoločne';

  @override
  String get onboardingPage3Body =>
      'Zdieľajte pivnicu až s dvoma ľuďmi a veďte si históriu každej vypitej fľaše.';

  @override
  String get onboardingSkip => 'Preskočiť';

  @override
  String get onboardingNext => 'Ďalej';

  @override
  String get onboardingStart => 'Začať';

  @override
  String onboardingPageOf(int page) {
    return 'Strana $page z 3';
  }

  @override
  String get profileTitle => 'Profil';

  @override
  String get profilePhoto => 'Profilová fotka';

  @override
  String get profileSignOut => 'Odhlásiť sa';

  @override
  String get profileDeleteAccount => 'Odstrániť účet';

  @override
  String get profilePrivacy => 'Zásady ochrany súkromia';

  @override
  String get profilePrivacyBody =>
      'Zásady ochrany súkromia si môžete prečítať na tejto adrese:';

  @override
  String get profileOpenLink => 'Otvoriť v prehliadači';

  @override
  String get profileOpenLinkFailed =>
      'Stránku sa nepodarilo otvoriť. Odkaz môžete skopírovať a otvoriť v prehliadači.';

  @override
  String get profileCopyLink => 'Kopírovať odkaz';

  @override
  String get profileLinkCopied => 'Odkaz skopírovaný';

  @override
  String get close => 'Zavrieť';

  @override
  String get signOutConfirmTitle => 'Chcete sa odhlásiť?';

  @override
  String signOutPendingWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Máte $count zatiaľ neuložených zmien. Ak sa odhlásite a prihlási sa iný účet, stratia sa.',
      many:
          'Máte $count zatiaľ neuloženej zmeny. Ak sa odhlásite a prihlási sa iný účet, stratia sa.',
      few:
          'Máte $count zatiaľ neuložené zmeny. Ak sa odhlásite a prihlási sa iný účet, stratia sa.',
      one:
          'Máte $count zatiaľ neuloženú zmenu. Ak sa odhlásite a prihlási sa iný účet, stratí sa.',
    );
    return '$_temp0';
  }

  @override
  String get signOutStayAndSync => 'Zostať a synchronizovať';

  @override
  String get signOutAnyway => 'Napriek tomu sa odhlásiť';

  @override
  String get syncAllSaved => 'Všetko uložené';

  @override
  String syncStillPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count zmien ešte čaká na uloženie: skontrolujte sieť',
      many: '$count zmeny ešte čaká na uloženie: skontrolujte sieť',
      few: '$count zmeny ešte čakajú na uloženie: skontrolujte sieť',
      one: '$count zmena ešte čaká na uloženie: skontrolujte sieť',
    );
    return '$_temp0';
  }

  @override
  String get signOutFailed => 'Odhlásenie zlyhalo. Skúste to znova';

  @override
  String get signInAccountDeleted => 'Účet odstránený';

  @override
  String get deleteAccountIntro => 'Natrvalo sa odstráni:';

  @override
  String get deleteAccountItemCellar => 'Vaša pivnica s vínami a Históriou';

  @override
  String get deleteAccountItemShares =>
      'Vaše zdieľania: pozvaní ľudia stratia prístup';

  @override
  String get deleteAccountItemMemberships =>
      'Vaša účasť v cudzích pivniciach: záznamy o fľašiach, ktoré ste vypili, tam zostanú bez vášho mena';

  @override
  String get deleteAccountItemProfile => 'Váš profil';

  @override
  String deleteAccountPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Máte $count zatiaľ neuložených zmien: uložia sa a potom sa odstránia so všetkým ostatným',
      many:
          'Máte $count zatiaľ neuloženej zmeny: uložia sa a potom sa odstránia so všetkým ostatným',
      few:
          'Máte $count zatiaľ neuložené zmeny: uložia sa a potom sa odstránia so všetkým ostatným',
      one:
          'Máte $count zatiaľ neuloženú zmenu: uloží sa a potom sa odstráni so všetkým ostatným',
    );
    return '$_temp0';
  }

  @override
  String get deleteAccountConfirmWord => 'ODSTRÁNIŤ';

  @override
  String deleteAccountTypeWord(String word) {
    return 'Potvrďte napísaním slova $word';
  }

  @override
  String get deleteAccountReauthHint =>
      'Potom sa znova prihlásite cez Google, aby ste potvrdili, že ste to vy.';

  @override
  String get deleteAccountForever => 'Odstrániť navždy';

  @override
  String get deleteAccountNeedsNetwork =>
      'Na odstránenie účtu sa pripojte k internetu';

  @override
  String get deleteAccountSameAccount =>
      'Odstránenie vyžaduje prihlásenie rovnakým účtom';

  @override
  String get deletionTitle => 'Odstraňovanie účtu';

  @override
  String get deletionStepPreparePhone => 'Ukladanie čakajúcich zmien';

  @override
  String get deletionStepMarkStarted => 'Spúšťanie odstraňovania';

  @override
  String get deletionStepLeaveOtherCellars => 'Opúšťanie cudzích pivníc';

  @override
  String get deletionStepCloseOwnInvitations => 'Ukončovanie vašich zdieľaní';

  @override
  String get deletionStepDeleteWinesAndRecords =>
      'Odstraňovanie vín a Histórie';

  @override
  String get deletionStepDeleteCellar => 'Odstraňovanie pivnice';

  @override
  String get deletionStepDeleteProfileAndUser => 'Odstraňovanie profilu a účtu';

  @override
  String get deletionStepCleanUpPhone => 'Čistenie tohto telefónu';

  @override
  String deletionStepAnnounce(int step, String label) {
    return 'Krok $step z 8: $label';
  }

  @override
  String deletionDeletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Odstránených $count vín a záznamov',
      many: 'Odstránené $count vína a záznamu',
      few: 'Odstránené $count vína a záznamy',
      one: 'Odstránené $count víno alebo záznam',
    );
    return '$_temp0';
  }

  @override
  String get deletionResumeHint =>
      'Odstraňovanie tohto účtu nie je dokončené. Dokončíte ho, keď sa znova prihlásite cez Google.';

  @override
  String get deletionContinue => 'Pokračovať';

  @override
  String get deletionOffline =>
      'Na dokončenie odstraňovania sa pripojte k internetu';

  @override
  String get deletionPendingWrites =>
      'Čakajúce zmeny sa nedarí uložiť. Skúste to znova';

  @override
  String get deletionFailed =>
      'Odstraňovanie sa nepodarilo dokončiť. Skúste to znova';

  @override
  String get uxCountryLabel => 'Krajina';

  @override
  String get uxCountryOther => 'Iná krajina…';

  @override
  String get uxCountryNone => 'Bez krajiny';

  @override
  String get uxAllCountriesTitle => 'Všetky krajiny a územia';

  @override
  String get uxAllCountriesSearch => 'Hľadať krajinu';

  @override
  String get uxAllCountriesRare => 'Pri víne zriedkavé';

  @override
  String get uxAllCountriesAll => 'Všetky, od A po Z';

  @override
  String get uxAllCountriesNone => 'Žiadna krajina sa nenašla';

  @override
  String get uxRegionLabel => 'Región';

  @override
  String uxRegionOf(String country) {
    return 'Región · $country';
  }

  @override
  String get uxRegionOther => 'Iný región';

  @override
  String get uxRegionFieldLabel => 'Napíšte región';

  @override
  String get uxRegionTooLong => 'Najviac 120 znakov';

  @override
  String get uxDrinkAction => 'Vypité';

  @override
  String uxDrinkActionTooltip(String name) {
    return 'Vypitá fľaša vína $name';
  }

  @override
  String get uxDrinkActionDetail => 'Vypitá fľaša';

  @override
  String get uxDrinkSheetLabel => 'Potvrdenie vypitia';

  @override
  String get uxDrinkSheetBottles => 'Fľaše';

  @override
  String uxDrinkSheetBottlesChange(int before, int after) {
    return 'Fľaše: z $before na $after';
  }

  @override
  String get uxDrinkSheetRating => 'Aké bolo? (nepovinné)';

  @override
  String uxDrinkSheetStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hviezdičiek z 5',
      many: '$count hviezdičky z 5',
      few: '$count hviezdičky z 5',
      one: '$count hviezdička z 5',
    );
    return '$_temp0';
  }

  @override
  String get uxDrinkSheetConfirm => 'Áno, vypité';

  @override
  String get uxRemoveBottle => 'Odobrať fľašu bez záznamu o vypití';

  @override
  String get uxRemoveBottleTitle => 'Odobrať fľašu?';

  @override
  String uxRemoveBottleBody(String name) {
    return 'Jedna fľaša vína $name sa odoberie bez záznamu o vypití.';
  }

  @override
  String get uxRemoveBottleConfirm => 'Odobrať';

  @override
  String get uxIdealTitle => 'Ideálna chvíľa';

  @override
  String uxIdealUntil(String year) {
    return 'Odporúčané do $year';
  }

  @override
  String uxIdealUntilPast(String year) {
    return 'Odporúčané do $year: už uplynulo';
  }

  @override
  String uxIdealBest(String start, String end) {
    return 'Najlepšie od $start do $end';
  }

  @override
  String uxIdealBar(String start, String end) {
    return 'Okno pitnosti od $start do $end';
  }

  @override
  String get uxIdealDisclaimer =>
      '⚠︎ Orientačné: odhad podľa typu, apelácie a ročníka. Skladovanie a konkrétna fľaša ho môžu zmeniť.';

  @override
  String get uxIdealUnavailableHint => 'Na odhad doplňte ročník a typ.';

  @override
  String uxDashboardDrinkNow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count na vypitie teraz',
      many: '$count na vypitie teraz',
      few: '$count na vypitie teraz',
      one: '$count na vypitie teraz',
    );
    return '$_temp0';
  }

  @override
  String get uxFamilyRed => 'Červené';

  @override
  String get uxFamilyWhite => 'Biele';

  @override
  String get uxFamilyRose => 'Ružové';

  @override
  String get uxFamilySparkling => 'Šumivé';

  @override
  String get uxFamilySweet => 'Sladké';

  @override
  String get labelBackTitle => 'Teraz zadná strana';

  @override
  String get labelBackHint =>
      'Na zadnej etikete býva čiarový kód, vinárstvo a ročník: pomáhajú víno nájsť.';

  @override
  String get labelBackTake => 'Odfotiť zadnú stranu';

  @override
  String get labelBackGallery => 'Vybrať z galérie';

  @override
  String get labelBackSkip => 'Preskočiť';

  @override
  String get labelStepFront => 'Predná strana';

  @override
  String get labelStepBack => 'Zadná strana';

  @override
  String get labelStepBarcode => 'Čiarový kód';

  @override
  String get labelStepDatabase => 'Databáza vín v telefóne';

  @override
  String get labelStepPending => 'Čaká';

  @override
  String get labelStepRunning => 'Prebieha…';

  @override
  String get labelStepDone => 'Hotovo';

  @override
  String get labelStepSkipped => 'Preskočené';

  @override
  String get labelStepFailed => 'Nečitateľné';

  @override
  String labelStepStatus(String step, String status) {
    return '$step: $status';
  }

  @override
  String get labelOnPhoneNote =>
      'Všetko prebieha v telefóne: fotky sa nikomu neposielajú.';

  @override
  String get labelBackUnreadable => 'Zadná strana nečitateľná';

  @override
  String get labelSourceOffline => 'Z databázy v telefóne · offline';

  @override
  String get labelSourceCatalog => 'Z katalógu';

  @override
  String get labelSourceOnline => 'Z Open Food Facts · online';

  @override
  String get labelNotThis => 'Toto nie';

  @override
  String get labelOffAttribution => 'Údaje z Open Food Facts, licencia ODbL';

  @override
  String get labelCandidatesTitle => 'Ktoré z nich?';

  @override
  String labelCandidatesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count podobných vín',
      many: '$count podobného vína',
      few: '$count podobné vína',
      one: '$count podobné víno',
    );
    return '$_temp0';
  }

  @override
  String get labelCandidatesNone => 'Žiadne z nich';

  @override
  String get labelChipOffline => 'offline';

  @override
  String get labelChipOnline => 'online';

  @override
  String get labelChipCatalog => 'katalóg';

  @override
  String get labelNoProducer => 'vinárstvo neuvedené';

  @override
  String get labelNoMatch => 'Etiketa je prečítaná, ale víno nespoznávam';

  @override
  String get labelReadText => 'Prečítaný text';

  @override
  String get labelSearchOnline => 'Hľadať online';

  @override
  String get labelOpenLens => 'Otvoriť v Google Lens';

  @override
  String get labelLensLastResort =>
      'Google Lens je posledná možnosť: fotka sa do aplikácie Google odošle len po vašom potvrdení.';

  @override
  String get labelLensTitle => 'Otvoriť v Google Lens?';

  @override
  String get labelLensBody =>
      'Fotka prednej etikety sa odošle do aplikácie Google vo vašom telefóne alebo do aplikácie, ktorú si vyberiete; tá si môže kópiu ponechať podľa vlastných pravidiel. Vinoozy výsledky nedostáva: vráťte sa sem a víno vyberte alebo napíšte.';

  @override
  String get labelLensConfirm => 'Otvoriť Google Lens';

  @override
  String get labelLensFailed =>
      'Google Lens ani ponuku zdieľania sa nedarí otvoriť';

  @override
  String get onlineSearchTitle => 'Hľadať online';

  @override
  String get onlineSearchSubtitle => 'Open Food Facts · len vína';

  @override
  String get onlineSearchField => 'Hľadané slová';

  @override
  String get onlineSearchHint => 'Slová môžete pred hľadaním zmeniť.';

  @override
  String get onlineSearchEmptyField => 'Napíšte aspoň jedno slovo';

  @override
  String get onlineSearchButton => 'Hľadať';

  @override
  String get onlineSearchLoading => 'Hľadám…';

  @override
  String onlineSearchResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count výsledkov',
      many: '$count výsledku',
      few: '$count výsledky',
      one: '$count výsledok',
    );
    return '$_temp0';
  }

  @override
  String get onlineSearchEmpty =>
      'Žiadne víno sa nenašlo: skúste iné slová alebo „Napísať ručne“.';

  @override
  String get onlineSearchOffline =>
      'Bez siete: hľadám len v databáze v telefóne.';

  @override
  String get onlineSearchRateLimited =>
      'Hľadanie online teraz nie je dostupné, skúste to znova o pár minút.';

  @override
  String get onlineSearchUnavailable =>
      'Hľadanie online nie je v tejto verzii aplikácie aktívne: hľadám len v databáze v telefóne.';

  @override
  String get aboutTitle => 'O aplikácii';

  @override
  String aboutVersion(String version) {
    return 'Verzia $version';
  }

  @override
  String get aboutDbTitle => 'Databáza vín';

  @override
  String aboutDbCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vín',
      many: '$count vína',
      few: '$count vína',
      one: '$count víno',
    );
    return '$_temp0';
  }

  @override
  String aboutDbDate(String date) {
    return 'Export Open Food Facts zo dňa $date';
  }

  @override
  String get aboutDbSample =>
      'Ukážková databáza: niekoľko ručne zapísaných testovacích vín, nie údaje Open Food Facts.';

  @override
  String get aboutDbLoading => 'Otváram databázu vín…';

  @override
  String get aboutDbUnavailable =>
      'Databáza vín nie je v tejto verzii k dispozícii';

  @override
  String aboutDbSource(String url) {
    return 'Odvodená databáza a nástroj, ktorý ju vytvára, sú vo verejnom repozitári: $url';
  }

  @override
  String get aboutLicenseTitle => 'Licencie';

  @override
  String get aboutLicense =>
      'Obsahuje informácie z Open Food Facts sprístupnené pod licenciou Open Database License (ODbL). Jednotlivý obsah podlieha licencii Database Contents License (DbCL).';

  @override
  String get aboutPrivacyTitle => 'Fotky etikiet';

  @override
  String get aboutPrivacy =>
      'Fotky etikiet sa čítajú v telefóne a odstránia sa, keď opustíte výsledok. Telefón opustia, len keď klepnete na „Otvoriť v Google Lens“ a potvrdíte to.';

  @override
  String get aboutAppellationsTitle => 'Apelácie';

  @override
  String get aboutAppellationsSource =>
      'Apelácie: register eAmbrosia (EÚ) a oficiálne národné registre.';

  @override
  String get aboutAppellationsSample =>
      'Ukážková tabuľka: ručne zapísaný výťah z registrov, kým sa nestiahnu skutočné registre.';

  @override
  String get denominationLabel => 'Apelácia';

  @override
  String get denominationTooLong => 'Najviac 120 znakov';

  @override
  String get autofillFilledNotice =>
      'Vyplnené z etikety: skontrolujte a uložte';

  @override
  String get autofillPastedNotice => 'Vyplnené z textu: skontrolujte a uložte';

  @override
  String get autofillFromText => '✦ z textu';

  @override
  String get autofillFromTextSemantics => 'vyplnené z etikety';

  @override
  String get autofillClear => 'Vymazať';

  @override
  String get autofillLens => 'Lens';

  @override
  String get autofillClearTitle => 'Vymazať formulár?';

  @override
  String get autofillClearBody =>
      'Niektoré polia sú vyplnené aj ručne. „Vymazať“ vyprázdni názov, vinárstvo, apeláciu, ročník, typ, krajinu, región a úroveň. Množstvo zostane.';

  @override
  String get autofillClearConfirm => 'Vymazať';

  @override
  String get autofillCleared => 'Formulár vymazaný';

  @override
  String get autofillPasteTitle => 'Máte text z Google Lens?';

  @override
  String get autofillPasteHint =>
      'V Lens označte text etikety, klepnite na „Kopírovať“ a vráťte sa sem.';

  @override
  String get autofillPaste => 'Vložiť z Lens';

  @override
  String get autofillOpenLens => 'Z Google Lens';

  @override
  String get autofillOpenLensSemantics => 'otvorí Google Lens';

  @override
  String get autofillClipboardEmpty => 'V schránke nie je žiadny text';

  @override
  String get autofillNoNewFields => 'V texte nie sú žiadne údaje na doplnenie';

  @override
  String get autofillFromLens => 'Formulár vyplnený textom z Lens';

  @override
  String get autofillShareEmpty => 'Neprišiel žiadny text';

  @override
  String get autofillShareUseTitle => 'Použiť text na prázdne polia?';

  @override
  String get autofillShareUse => 'Použiť';

  @override
  String get autofillShareIgnore => 'Ignorovať';

  @override
  String get addChoiceLens => 'Z Google Lens';

  @override
  String get addChoicePhotoHint =>
      'Predná a zadná strana: Vinoozy etiketu prečíta.';

  @override
  String get addChoiceLensHint =>
      'Otvorí Lens: zamerajte, označte text a klepnite na Zdieľať → Vinoozy.';

  @override
  String get addChoiceImportHint => 'Fotka etikety, ktorú už máte.';

  @override
  String get addChoiceWriteHint =>
      'Prázdny formulár s možnosťou „Vložiť z Lens“.';

  @override
  String get lensInstructionsTitle => 'Google Lens sa odtiaľto nedá otvoriť';

  @override
  String get lensInstructionsStep1 => 'Otvorte Google Lens a zamerajte etiketu';

  @override
  String get lensInstructionsStep2 => 'Označte text etikety';

  @override
  String get lensInstructionsStep3 => 'Klepnite na Zdieľať → Vinoozy';

  @override
  String get lensInstructionsOk => 'Rozumiem';

  @override
  String get levelLabel => 'Úroveň';

  @override
  String get levelEveryday => 'Každodenné (lacné)';

  @override
  String get levelGood => 'Dobré';

  @override
  String get levelAging => 'Na archiváciu';

  @override
  String get levelNone => 'Žiadna';

  @override
  String get levelEverydayShort => 'vypiť mladé';

  @override
  String get levelGoodShort => 'bežný odhad';

  @override
  String get levelAgingShort => 'vydrží dlhšie';

  @override
  String get levelSuggested => 'navrhnutá';

  @override
  String levelSuggestedReason(String qualifier) {
    return 'Navrhnutá, pretože v názve je „$qualifier“: uloží sa takto, ak ju nezmeníte. Vyberte inú alebo klepnite na „Žiadna“.';
  }

  @override
  String levelSuggestedSemantics(String qualifier) {
    return 'navrhnutá, pretože v názve je $qualifier';
  }

  @override
  String levelOptionSemantics(String option, int index, int count) {
    return 'Úroveň, $option, $index z $count';
  }

  @override
  String get levelWhatChanges => 'Čo sa zmení';

  @override
  String get levelEverydayExamples =>
      'Okno sa skráti. Napr. stolové víno, Lambrusco, základné Prosecco, Bardolino, Vinho Verde.';

  @override
  String get levelGoodExamples =>
      'Bežný odhad, ktorý platí aj vtedy, keď nič nevyberiete. Napr. Chianti Classico, Barbera d\'Asti Superiore, Rioja Crianza, Côtes du Rhône.';

  @override
  String get levelAgingExamples =>
      'Okno sa predĺži. Napr. Barolo, Brunello, Amarone, Bordeaux Grand Cru, Rioja Gran Reserva, Vintage Port.';

  @override
  String levelPreviewBefore(String start, String end) {
    return 'Predtým $start – $end';
  }

  @override
  String levelPreviewWith(String level, String start, String end) {
    return 'S úrovňou „$level“ $start – $end';
  }

  @override
  String levelPreviewNow(String start, String end) {
    return 'Pripravené $start – do $end';
  }

  @override
  String levelDetail(String level) {
    return 'Úroveň: $level';
  }

  @override
  String get overrideCorrect => 'Opraviť';

  @override
  String get overrideRestore => 'Obnoviť odhad';

  @override
  String get overrideCorrectedByYou => 'opravené vami';

  @override
  String overrideAppEstimate(String year) {
    return 'Odhad aplikácie: do $year';
  }

  @override
  String get overrideSheetTitle => 'Odporúčané do';

  @override
  String overrideSheetHint(String start) {
    return 'Vyberte rok. Nesmie byť skôr ako „Pripravené od $start“.';
  }

  @override
  String overridePeakNotice(String peak) {
    return 'Ak vyberiete rok pred $peak (najlepšie), posunie sa na rovnaký rok aj „najlepšie“.';
  }

  @override
  String get overrideMore => 'ďalšie…';

  @override
  String get overrideSave => 'Uložiť opravu';

  @override
  String overrideRestoreTitle(String year) {
    return 'Vrátiť sa k odhadu aplikácie (do $year)?';
  }

  @override
  String get overrideRestoreConfirm => 'Obnoviť';

  @override
  String get overrideSaved => 'Oprava uložená';

  @override
  String get overrideRestored => 'Odhad obnovený';

  @override
  String get estimateSourceCorrectedByYou => 'opravené vami';

  @override
  String estimateFromDenomination(String name) {
    return 'Odhad podľa apelácie $name';
  }

  @override
  String estimateFromDenominationQualifier(String name, String qualifier) {
    return 'Odhad podľa apelácie $name, $qualifier';
  }

  @override
  String estimateFromGrape(String name) {
    return 'Odhad podľa odrody $name';
  }

  @override
  String get estimateFromType => 'Odhad podľa typu vína';

  @override
  String get autofillReading => 'Čítam text…';

  @override
  String get guideChip => 'Sprievodca';

  @override
  String guideProgress(int n, int total) {
    return 'Otázka $n z $total';
  }

  @override
  String get guideClose => 'Zavrieť';

  @override
  String get guideIsDenomination => 'je to apelácia?';

  @override
  String get guideIsProducer => 'je to vinárstvo?';

  @override
  String get guideIsName => 'je to názov vína?';

  @override
  String get guideIsVintage => 'Ročník';

  @override
  String guideAskDenomination(String value) {
    return 'Je $value apelácia?';
  }

  @override
  String guideAskProducer(String value) {
    return 'Je $value vinárstvo?';
  }

  @override
  String guideAskName(String value) {
    return 'Je $value názov vína?';
  }

  @override
  String get guideAskVintage => 'Aký je ročník?';

  @override
  String guideQuestionSemantics(int n, int total, String question) {
    return 'Otázka $n z $total: $question';
  }

  @override
  String get guideNoProposal => 'V texte sa to nenašlo';

  @override
  String get guideYes => 'Áno';

  @override
  String get guideNo => 'Nie, niečo iné';

  @override
  String get guideEdit => 'Upraviť';

  @override
  String get guideSkip => 'Preskočiť';

  @override
  String get guideConfirm => 'Potvrdiť';

  @override
  String get guideCancel => 'Zrušiť';

  @override
  String guideRejected(String value) {
    return '„$value“ nie: tu je ďalší návrh';
  }

  @override
  String get guideNoMore =>
      'Žiadny ďalší návrh: zložte ho zo slov alebo preskočte';

  @override
  String guideProposalAnnounce(String value) {
    return 'Návrh: $value';
  }

  @override
  String get guideComposeLabel => 'Alebo ho zložte klepaním na slová z textu';

  @override
  String get guideComposePreview => 'Náhľad';

  @override
  String get guideComposeEmpty => 'Klepnite na jedno alebo viac slov';

  @override
  String get guideComposeLimit => 'Najviac 8 slov a 80 znakov';

  @override
  String guideTableMatchSemantics(String name) {
    return 'zodpovedá: $name';
  }

  @override
  String guideLine(int n, int total) {
    return 'Riadok $n z $total';
  }

  @override
  String guideWordSelected(String word, int order) {
    return '$word, vybrané, $order';
  }

  @override
  String guideWordUnavailable(String word) {
    return '$word, nedostupné';
  }

  @override
  String guideWordUsedFor(String word, String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'apelácia',
      'producer': 'vinárstvo',
      'other': 'názov',
    });
    return '$word, použité pre pole: $_temp0';
  }

  @override
  String guideUsedMark(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'apelácia',
      'producer': 'vinárstvo',
      'other': 'názov',
    });
    return '$_temp0';
  }

  @override
  String guideOtherYears(String years) {
    return 'V texte je aj: $years';
  }

  @override
  String get guideWheelFromText => 'rok nájdený v texte';

  @override
  String get guideWheelTypeYear => 'Napíšte rok';

  @override
  String guideWheelConfirm(String year) {
    return 'Potvrdiť $year';
  }

  @override
  String get guideNoVintage => 'Bez ročníka';

  @override
  String guideSkippedNotice(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'Apelácia preskočená',
      'producer': 'Vinárstvo preskočené',
      'vintage': 'Ročník preskočený',
      'other': 'Názov preskočený',
    });
    return '$_temp0: doplňte ručne alebo sa vráťte k sprievodcovi';
  }

  @override
  String guideSkippedMany(int count) {
    return 'Preskočené polia: $count. Doplňte ich ručne alebo sa vráťte k sprievodcovi';
  }

  @override
  String get guideInvalidValue =>
      'Tento text obsahuje znaky, ktoré sa nedajú uložiť';

  @override
  String get brandStudio => 'Bottazzini Softworks';

  @override
  String get suggestedMark => '✦ navrhnuté';

  @override
  String suggestedSemantics(String field, String value) {
    return '$field, $value, navrhnuté';
  }

  @override
  String get restoreSuggestion => 'Obnoviť návrh';

  @override
  String get restoreSuggestionDone => 'Návrh obnovený';

  @override
  String get styleLabel => 'Štýl';

  @override
  String styleGroupSemantics(String value, int index, int count) {
    return 'Štýl, $value, $index z $count';
  }

  @override
  String get styleRedFresh => 'Svieže';

  @override
  String get styleRedMedium => 'Stredné';

  @override
  String get styleRedAge => 'Na archiváciu';

  @override
  String get styleRedLong => 'Dlhá archivácia';

  @override
  String get styleWhiteFresh => 'Svieže';

  @override
  String get styleWhiteMedium => 'Stredné';

  @override
  String get styleWhiteAge => 'Na archiváciu';

  @override
  String get styleRoseFresh => 'Svieže';

  @override
  String get styleClassicFresh => 'Svieže';

  @override
  String get styleClassicAge => 'Na archiváciu';

  @override
  String get styleTankFresh => 'Svieže';

  @override
  String get styleLambrusco => 'Lambrusco';

  @override
  String get styleSweetAromatic => 'Aromatické';

  @override
  String get styleSweetPassito => 'Slamové';

  @override
  String get styleSweetBotrytis => 'Botrytické';

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
  String get styleFortifiedOther => 'Iné';

  @override
  String get profileNameRFresh => 'Ovocné červené';

  @override
  String get profileNameRMedium => 'Stredne plné červené';

  @override
  String get profileNameRAge => 'Červené na archiváciu';

  @override
  String get profileNameRLong => 'Červené na dlhú archiváciu';

  @override
  String get profileNameWFresh => 'Svieže aromatické biele';

  @override
  String get profileNameWMedium => 'Stredne plné biele';

  @override
  String get profileNameWAge => 'Biele na archiváciu';

  @override
  String get profileNameRoseFresh => 'Svieže ružové';

  @override
  String get profileNameSpTank => 'Svieže šumivé metódou Charmat';

  @override
  String get profileNameLamFresh => 'Svieže Lambrusco';

  @override
  String get profileNameSpClassic => 'Svieže šumivé klasickou metódou';

  @override
  String get profileNameSpClassicAge =>
      'Šumivé klasickou metódou na archiváciu';

  @override
  String get profileNameSwAromatic => 'Mladé aromatické sladké víno';

  @override
  String get profileNameSwPassito => 'Sladké slamové víno';

  @override
  String get profileNameSwBotrytis => 'Sladké botrytické víno';

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
  String get profileNameShPx => 'Sherry Pedro Ximénez';

  @override
  String get profileNameFortUnknown => 'Fortifikované, neznámy štýl';

  @override
  String get profileNameUnknown => 'Štýl nerozpoznaný';

  @override
  String estimateFromProfile(String profile, String denomination) {
    return 'Odhad podľa profilu: $profile ($denomination)';
  }

  @override
  String estimateFromProfileType(String profile) {
    return 'Odhad podľa profilu: $profile, podľa typu';
  }

  @override
  String estimateFromProfileGrape(String profile, String grape) {
    return 'Odhad podľa profilu: $profile, podľa odrody $grape';
  }

  @override
  String get estimateFromEntryDateDisgorgement =>
      'Od dátumu pridania: na lepší odhad doplňte dátum degoržáže';

  @override
  String get estimateFromEntryDateBottling =>
      'Od dátumu pridania: na lepší odhad doplňte dátum fľašovania';

  @override
  String get styleToConfirmBanner =>
      '⚠︎ Štýl na potvrdenie: odhad je orientačný';

  @override
  String get chooseTypePrompt => 'Vyberte typ';

  @override
  String estimateUpdatedAnnouncement(String summary) {
    return 'Odhad aktualizovaný: $summary';
  }

  @override
  String get agingStartDisgorgement => 'Degoržáž';

  @override
  String get agingStartBottling => 'Fľašovanie';

  @override
  String get agingStartMonth => 'Mesiac';

  @override
  String get agingStartYear => 'Rok';

  @override
  String get agingStartHint => 'Zvyčajne býva na zadnej etikete.';

  @override
  String get agingStartIncomplete => 'Zadajte mesiac a rok';

  @override
  String get agingStartFuture => 'Dátum nesmie byť v budúcnosti';

  @override
  String get agingStartBeforeVintage => 'Nesmie byť pred ročníkom';

  @override
  String get windowNoEnd => 'Pripravené, koniec nie je odhadnutý';

  @override
  String get windowNoEndShort => 'koniec nie je odhadnutý';

  @override
  String windowDrinkWithin(String date) {
    return 'do $date';
  }

  @override
  String get levelNoEffect => 'Úroveň tento odhad nemení';

  @override
  String get dashboardToConfirmTitle => 'Na potvrdenie';

  @override
  String dashboardToConfirmCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vín',
      many: '$count vína',
      few: '$count vína',
      one: '$count víno',
    );
    return '$_temp0';
  }

  @override
  String aboutDbClassified(String percent) {
    return '$percent % vín s rozpoznaným typom';
  }

  @override
  String get planTitle => 'Plán';

  @override
  String get planFree => 'Bezplatný';

  @override
  String get planPlus => 'Plus';

  @override
  String get planPlusGift => 'Plus (darček)';

  @override
  String get planDevUnlockAll => 'DEV · Testovací Plus';

  @override
  String get planDevSimulateFree => 'DEV · Simulovaný bezplatný plán';

  @override
  String get planDevSimulateExpired => 'DEV · Simulovaný vypršaný Plus';

  @override
  String get planDiscoverPlus => 'Objaviť Plus';

  @override
  String get plusTitle => 'Vinoozy Plus';

  @override
  String get plusBenefitsTitle => 'S Plus';

  @override
  String get plusBenefitNoAds => 'Bez reklám';

  @override
  String get plusBenefitNoLimit => 'Bez limitu vín v pivnici';

  @override
  String get plusComingSoon => 'Plus bude čoskoro';

  @override
  String get plusLoading => 'Načítavam ceny z Google Play';

  @override
  String get plusStoreUnavailable =>
      'Ceny z Google Play sa nepodarilo načítať. Skúste to neskôr.';

  @override
  String plusPriceMonthly(String price) {
    return '$price mesačne';
  }

  @override
  String plusPriceAnnual(String price) {
    return '$price ročne';
  }

  @override
  String get plusRenewal =>
      'Predplatné sa automaticky obnovuje za uvedenú cenu, kým ho nezrušíte v Google Play.';

  @override
  String get plusTerms =>
      'Platba sa stiahne z vášho účtu Google Play pri potvrdení nákupu. Zrušiť môžete kedykoľvek: Plus zostane aktívny do konca zaplateného obdobia. Keď Plus skončí, všetky vaše vína zostanú.';

  @override
  String get plusRestore => 'Obnoviť nákupy';

  @override
  String get plusManage => 'Spravovať alebo zrušiť predplatné v Google Play';

  @override
  String get plusActive => 'Plus je na tomto účte aktívny';

  @override
  String get plusActiveGift =>
      'Máte Plus ako darček: žiadne platby ani obnovovanie.';

  @override
  String get plusPending =>
      'Platba čaká: Plus sa aktivuje, keď ju Google Play potvrdí.';

  @override
  String get plusVerifying => 'Overujem nákup';

  @override
  String get plusVerified => 'Nákup overený: Plus bude aktívny o pár sekúnd.';

  @override
  String get plusPurchaseFailed => 'Nákup sa nedokončil. Skúste to znova.';

  @override
  String get plusInvalidPurchase =>
      'Google Play tento nákup pre Vinoozy nepotvrdil.';

  @override
  String get plusOwnedByOther =>
      'Toto predplatné už patrí k inému účtu Vinoozy.';

  @override
  String get plusVerificationUnavailable =>
      'Nákup sa teraz nedá overiť. Skúste to neskôr: predplatné zostáva v Google Play.';

  @override
  String get capacityLimitTitle => 'Limit bezplatného plánu je vyčerpaný';

  @override
  String capacityLimitBody(int limit) {
    return 'Bezplatný plán zahŕňa najviac tento počet rôznych vín v pivnici: $limit. Vína, ktoré už máte, môžete vždy upravovať, označovať ako vypité a pridávať k nim fľaše. Ak chcete pridať nové, dopite alebo odstráňte niektoré víno, alebo prejdite na Plus.';
  }

  @override
  String capacityLimitBodyComingSoon(int limit) {
    return 'Bezplatný plán zahŕňa najviac tento počet rôznych vín v pivnici: $limit. Vína, ktoré už máte, môžete vždy upravovať, označovať ako vypité a pridávať k nim fľaše. Ak chcete pridať nové, dopite alebo odstráňte niektoré víno. Plus bude čoskoro.';
  }

  @override
  String get rejectedCapacityLimit =>
      'Nesynchronizované: prekračuje limit vín bezplatného plánu. Zmena zostáva v tomto telefóne.';

  @override
  String get rejectedCapacityConflict =>
      'Nesynchronizované: pivnica sa v rovnakej chvíli zmenila na inom zariadení. Zmena zostáva v tomto telefóne: skúste to znova.';

  @override
  String writeRejectedCapacityLimit(String name) {
    return '$name: nesynchronizované, prekročený limit bezplatného plánu';
  }

  @override
  String writeRejectedCapacityConflict(String name) {
    return '$name: nesynchronizované, pivnica sa zmenila na inom zariadení';
  }

  @override
  String get freeIntroTitle => 'Bezplatný plán';

  @override
  String freeIntroLimit(int limit) {
    return 'Zadarmo môžete spravovať najviac tento počet rôznych vín: $limit.';
  }

  @override
  String get freeIntroAds =>
      'Pri bežnom používaní sa reklamy nezobrazujú. Keď prekročíte mesačný prah využívania služby, môžete občas vidieť reklamy, ktoré pomáhajú pokryť náklady na servery a synchronizáciu.';

  @override
  String get freeIntroNoAds => 'V úvodnej verzii nie sú žiadne reklamy.';

  @override
  String get freeIntroPlus => 'S Plus zmiznú reklamy aj limit pivnice.';

  @override
  String get noticeGotIt => 'Rozumiem';

  @override
  String get thresholdTitle => 'Vďaka reklamám zostáva Vinoozy zadarmo';

  @override
  String get thresholdBody =>
      'Mesačný prah využívania bez reklám je vyčerpaný. Odteraz môžete občas vidieť reklamy: pomáhajú nám pokryť náklady na servery a synchronizáciu, a Vinoozy tak zostáva zadarmo.';

  @override
  String get thresholdReset =>
      'Počítanie sa začne znova budúci mesiac. S Plus používate aplikáciu bez reklám a bez limitu pivnice.';

  @override
  String thresholdNextReset(String date) {
    return 'Ďalšie vynulovanie: $date';
  }

  @override
  String get thresholdHowItWorks => 'Ako to funguje';

  @override
  String get thresholdHowItWorksBody =>
      'Prah vychádza z odhadu počtu synchronizácií s cloudom, ktoré tento účet počas mesiaca vykonal. Samotné používanie offline nové operácie v cloude nevytvára. Reklamy sa zobrazujú najviac raz denne, len na Prehľade, a nikdy pri ukladaní alebo exporte údajov.';

  @override
  String get adLabel => 'Reklama';

  @override
  String get devToolsTitle => 'Vývojárske nástroje';

  @override
  String get devUnlockAll => 'Odomknúť všetko — testovací Plus';

  @override
  String get devSimulateFree => 'Simulovať bezplatný plán';

  @override
  String get devSimulateExpired => 'Simulovať vypršaný Plus';

  @override
  String get devRestore => 'Obnoviť bežný stav';

  @override
  String get devNoOverride => 'Žiadna simulácia nie je aktívna';

  @override
  String get devApplied => 'Scenár použitý aj v emulátore Firestore';

  @override
  String get devIncomplete =>
      'Neúplná simulácia: emulátor Firestore testovacie oprávnenie nepotvrdil. Pravidlá servera tento scenár nevidia.';

  @override
  String get devNotice =>
      'Len vývojové zostavy s emulátorom: žiadne platby, tokeny ani účtenky.';

  @override
  String get settingsTitle => 'Nastavenia';

  @override
  String get settingsGuide => 'Znova zobraziť sprievodcu';

  @override
  String get settingsShare => 'Zdieľať aplikáciu';

  @override
  String get settingsRate => 'Ohodnotiť aplikáciu';

  @override
  String get settingsFeedback => 'Poslať spätnú väzbu';

  @override
  String get settingsFaq => 'Časté otázky';

  @override
  String get settingsShareFailed =>
      'Zdieľanie sa nepodarilo otvoriť. Skúste to znova';

  @override
  String get settingsRateFailed =>
      'Google Play sa nepodarilo otvoriť. Skúste to znova';

  @override
  String get guideAddTitle => 'Pridajte víno';

  @override
  String get guideAddBody =>
      'Ťuknite na Pridať a uložte fľašu do pivnice. Na začiatok stačí názov.';

  @override
  String get guideLabelTitle => 'Prečítajte etiketu';

  @override
  String get guideLabelBody =>
      'V ponuke Pridať môžete etiketu aj odfotiť: Vinoozy prečíta názov, ročník a označenie pôvodu a vy ich pred uložením skontrolujete.';

  @override
  String get guideTabsTitle => 'Prehľad, Pivnica, História';

  @override
  String get guideTabsBody =>
      'Prehľad vám povie, ktoré vína otvoriť teraz, Pivnica ukazuje vaše fľaše a História uchováva tie, ktoré ste vypili.';

  @override
  String get guideMenuTitle => 'Ponuka pivnice';

  @override
  String get guideMenuBody =>
      'Nájdete tu svoj profil, ľudí, s ktorými pivnicu zdieľate, vypité vína a Nastavenia, kde si tohto sprievodcu môžete znova zobraziť.';

  @override
  String get guideDone => 'Hotovo';

  @override
  String guideStepOf(int step, int count) {
    return 'Krok $step z $count';
  }

  @override
  String get hintDashboard =>
      'Tu vidíte, ktoré vína sú teraz pripravené na pitie a ktoré je lepšie ešte nechať ležať.';

  @override
  String get hintHistory =>
      'Každá fľaša, ktorú vypijete, skončí tu, s vaším hodnotením a poznámkami.';

  @override
  String get hintAddWine =>
      'Začnite názvom: ročník, typ a označenie pôvodu spresnia okno na pitie.';

  @override
  String get shareAppSubject => 'Vinoozy, vaša vínna pivnica';

  @override
  String shareAppMessage(String link) {
    return 'Svoju vínnu pivnicu vediem vo Vinoozy: povie mi, kedy je každá fľaša v najlepšej forme. Vyskúšajte ju: $link';
  }

  @override
  String get feedbackSubject => 'Spätná väzba k aplikácii Vinoozy';

  @override
  String get feedbackTechHeader => 'Technické údaje (nemažte):';

  @override
  String get feedbackNoEmailTitle => 'Žiadna e-mailová aplikácia';

  @override
  String feedbackNoEmailBody(String email) {
    return 'V tomto telefóne nie je žiadna e-mailová aplikácia. Napíšte nám na $email';
  }

  @override
  String get feedbackCopy => 'Kopírovať';

  @override
  String get feedbackCopied => 'Adresa skopírovaná';

  @override
  String get faqAddQuestion => 'Ako ručne pridám víno?';

  @override
  String get faqAddAnswer =>
      'V Pivnici ťuknite na Pridať a potom na Napísať. Povinný je len názov; ročník, typ, krajina a označenie pôvodu zlepšujú odhad. Uložte a víno je v pivnici.';

  @override
  String get faqLabelQuestion =>
      'Ako prečítam etiketu, aj pomocou Google Lens?';

  @override
  String get faqLabelAnswer =>
      'Ťuknite na Pridať a odfoťte prednú aj zadnú stranu: Vinoozy prečíta etiketu priamo v telefóne. V Google Lens označte text a zdieľajte ho do Vinoozy, alebo ho skopírujte a vo formulári použite Vložiť z Lens. Pred uložením vždy skontrolujte polia.';

  @override
  String get faqWindowQuestion =>
      'Ako sa počíta ideálny čas na pitie a môžem ho zmeniť?';

  @override
  String get faqWindowAnswer =>
      'Vinoozy odhaduje okno (začiatok, vrchol, koniec) podľa typu, označenia pôvodu, ročníka a úrovne vína. Je to orientačné: záleží aj na tom, ako bola fľaša skladovaná. Otvorte víno a ťuknite na Opraviť, aby ste nastavili vlastný dátum, alebo zmeňte Úroveň.';

  @override
  String get faqOfflineQuestion => 'Funguje bez internetu?';

  @override
  String get faqOfflineAnswer =>
      'Áno. Vína môžete pridávať, upravovať aj piť bez pripojenia: všetko sa uloží v telefóne a synchronizuje s vaším účtom, hneď ako sa pripojenie obnoví.';

  @override
  String get faqShareQuestion => 'Ako zdieľam svoju pivnicu?';

  @override
  String get faqShareAnswer =>
      'V ponuke Pivnice otvorte Ľudia a pozvite niekoho cez jeho e-mailovú adresu Google, len na čítanie alebo s úpravami. Ten si nainštaluje Vinoozy a prihlási sa týmto účtom.';

  @override
  String get faqPlusQuestion => 'Čo zahŕňa bezplatný plán a čo je Plus?';

  @override
  String faqPlusAnswer(int limit) {
    return 'Bezplatný plán zahŕňa až $limit rôznych vín v pivnici, s občasnými reklamami len v Prehľade. Vinoozy Plus odstráni limit aj reklamy.';
  }

  @override
  String get faqDrinkQuestion =>
      'Prečo zaznamenávať, čo som vypil a aké to bolo?';

  @override
  String get faqDrinkAnswer =>
      'História uchováva, čo ste vypili a ako vám to chutilo. Keď uvediete, aká fľaša bola (ešte príliš mladé, tak akurát, za vrcholom), Vinoozy opraví odhad pri tom istom víne.';

  @override
  String get faqDeleteQuestion => 'Ako odstránim svoj účet?';

  @override
  String get faqDeleteAnswer =>
      'Otvorte Profil a ťuknite na Odstrániť účet. Potrebujete pripojenie a potom sa na potvrdenie znova prihlásite cez Google. Pivnica, História a zdieľania sa odstránia natrvalo.';

  @override
  String get faqNotFound => 'Nenašli ste odpoveď? Napíšte nám';
}
