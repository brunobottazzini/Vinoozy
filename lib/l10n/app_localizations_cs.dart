// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Czech (`cs`).
class AppLocalizationsCs extends AppLocalizations {
  AppLocalizationsCs([String locale = 'cs']) : super(locale);

  @override
  String get appTitle => 'Vinoozy';

  @override
  String get signInTagline => 'Váš sklep, v pravý čas';

  @override
  String get signInWithGoogle => 'Pokračovat přes Google';

  @override
  String get signInInProgress => 'Přihlašování';

  @override
  String get signInFailed => 'Přihlášení se nezdařilo';

  @override
  String get signInNeedsNetwork => 'K prvnímu přihlášení je potřeba připojení';

  @override
  String get signInSessionExpired => 'Relace vypršela: přihlaste se znovu';

  @override
  String get retry => 'Zkusit znovu';

  @override
  String get cancel => 'Zrušit';

  @override
  String blockedMessage(String email) {
    return 'Změny z účtu $email ještě nejsou uložené v cloudu: přihlaste se tímto účtem a připojte se k síti';
  }

  @override
  String blockedSignInWith(String email) {
    return 'Přihlásit se jako $email';
  }

  @override
  String blockedDiscard(String email) {
    return 'Smazat neuložené změny z účtu $email';
  }

  @override
  String get discardDialogTitle => 'Smazat změny?';

  @override
  String discardDialogBody(int count, String email) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count vín z účtu $email ještě není v cloudu a z tohoto telefonu se smaže.',
      many:
          '$count vína z účtu $email ještě není v cloudu a z tohoto telefonu se smaže.',
      few:
          '$count vína z účtu $email ještě nejsou v cloudu a z tohoto telefonu se smažou.',
      one:
          '$count víno z účtu $email ještě není v cloudu a z tohoto telefonu se smaže.',
    );
    return '$_temp0';
  }

  @override
  String get discardConfirm => 'Smazat';

  @override
  String get resetFailed => 'Data v tomto telefonu se nepodařilo vymazat';

  @override
  String get restartRequired => 'Pro dokončení aplikaci restartujte';

  @override
  String get restartCloseApp => 'Zavřít aplikaci';

  @override
  String get startupFailed => 'Aplikaci se nepodařilo spustit';

  @override
  String get cellarTitle => 'Sklep';

  @override
  String get defaultCellarName => 'Můj sklep';

  @override
  String get cellarLoading => 'Příprava sklepa';

  @override
  String get cellarSetupFailed => 'Sklep se nepodařilo připravit';

  @override
  String get cellarEmpty => 'Váš sklep je prázdný';

  @override
  String get addWine => 'Přidat';

  @override
  String get estimatePending => 'Odhad se připravuje';

  @override
  String get noVintage => 'Bez ročníku';

  @override
  String bottleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lahví',
      many: '$count lahve',
      few: '$count lahve',
      one: '$count láhev',
    );
    return '$_temp0';
  }

  @override
  String get syncInProgress => 'Synchronizace';

  @override
  String get syncOffline => 'Offline - synchronizace čeká';

  @override
  String writeRejected(String name) {
    return 'Změna není povolena: $name';
  }

  @override
  String get saveFailed => 'Uložení se nezdařilo, zkuste to znovu';

  @override
  String wineNotSaved(String name) {
    return 'Víno $name se neuložilo do cloudu';
  }

  @override
  String get addAgain => 'Přidat znovu';

  @override
  String get ignore => 'Ignorovat';

  @override
  String get addWineTitle => 'Napsat';

  @override
  String get wineNameLabel => 'Víno';

  @override
  String get vintageLabel => 'Ročník';

  @override
  String get quantityLabel => 'Množství';

  @override
  String get decreaseQuantity => 'Snížit množství';

  @override
  String get increaseQuantity => 'Zvýšit množství';

  @override
  String get save => 'Uložit';

  @override
  String get nameRequired => 'Napište název vína';

  @override
  String get nameTooLong => 'Nejvýše 120 znaků';

  @override
  String vintageRange(String year) {
    return 'Ročník mezi 1900 a $year';
  }

  @override
  String get offAttribution => 'Data z Open Food Facts (ODbL)';

  @override
  String get dashboardTitle => 'Přehled';

  @override
  String dashboardTotalBottles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lahví ve sklepě',
      many: '$count lahve ve sklepě',
      few: '$count lahve ve sklepě',
      one: '$count láhev ve sklepě',
    );
    return '$_temp0';
  }

  @override
  String get dashboardSyncing => 'Synchronizace sklepa…';

  @override
  String get dashboardAddFirstWine => 'Přidat první víno';

  @override
  String get drinkSoonTitle => 'Vypít brzy';

  @override
  String get drinkSoonEmpty => 'Žádné lahve k brzkému vypití';

  @override
  String drinkSoonUntil(String year) {
    return 'do $year';
  }

  @override
  String drinkSoonSeeAll(int count) {
    return 'Zobrazit vše ($count)';
  }

  @override
  String get statusChartTitle => 'Stav lahví';

  @override
  String get statusWaiting => 'počkat';

  @override
  String get statusReady => 'připravené';

  @override
  String get statusDrinkSoon => 'vypít brzy';

  @override
  String get statusPastWindow => 'po okně pitelnosti';

  @override
  String toEstimateNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lahví k odhadu',
      many: '$count lahve k odhadu',
      few: '$count lahve k odhadu',
      one: '$count láhev k odhadu',
    );
    return '$_temp0';
  }

  @override
  String chartBarValue(String label, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lahví',
      many: '$count lahve',
      few: '$count lahve',
      one: '$count láhev',
    );
    return '$label: $_temp0';
  }

  @override
  String chartDescription(String title, String values) {
    return '$title: $values';
  }

  @override
  String get openListHint => 'Otevřít seznam';

  @override
  String get peakChartTitle => 'Rok vrcholu';

  @override
  String get peakPast => 'po vrcholu';

  @override
  String get peakBeyond => 'později';

  @override
  String get breakdownTypeTitle => 'Lahve podle typu';

  @override
  String get breakdownRegionTitle => 'Lahve podle regionu';

  @override
  String get breakdownType => 'Typ';

  @override
  String get breakdownRegion => 'Region';

  @override
  String get familyRed => 'červené';

  @override
  String get familyWhite => 'bílé';

  @override
  String get familyRose => 'růžové';

  @override
  String get familySparkling => 'šumivé';

  @override
  String get familySweet => 'sladké';

  @override
  String get breakdownUnspecified => 'neuvedeno';

  @override
  String get breakdownOtherRegions => 'ostatní';

  @override
  String get ok => 'OK';

  @override
  String get cellarMenu => 'Nabídka sklepa';

  @override
  String get sharingPeopleTitle => 'Lidé';

  @override
  String get sharingInviteTitle => 'Pozvat někoho';

  @override
  String get sharingEmailLabel => 'E-mailová adresa Google';

  @override
  String get sharingPermissionRead => 'Jen pro čtení';

  @override
  String get sharingPermissionReadHint =>
      'Vidí vína, odhady, přehled a vypité lahve';

  @override
  String get sharingPermissionEdit => 'Může upravovat';

  @override
  String get sharingPermissionEditHint =>
      'Také přidává a mění vína a zapisuje vypité lahve';

  @override
  String get sharingRoleOwner => 'vlastník';

  @override
  String get sharingInviteButton => 'Pozvat';

  @override
  String sharingPlacesUsed(int used, int max) {
    return 'Lidé: $used/$max';
  }

  @override
  String get sharingInvalidEmail => 'Zadejte platný e-mail';

  @override
  String get sharingSelfInvite => 'Nemůžete pozvat sami sebe';

  @override
  String get sharingAlreadyInvited => 'Tento člověk už pozvánku má';

  @override
  String sharingLimitReached(int max) {
    return 'Limit počtu lidí je vyčerpán: $max';
  }

  @override
  String get sharingNotOwner => 'Sdílení tohoto sklepa nemůžete měnit';

  @override
  String get sharingNotFound => 'Tento člověk už v seznamu není';

  @override
  String get sharingFailed => 'Nepodařilo se, zkuste to znovu';

  @override
  String get sharingInviteFailed => 'Pozvání se nezdařilo. Zkuste to znovu';

  @override
  String get sharingOfflineHint => 'Ke správě sdílení je potřeba připojení';

  @override
  String get sharingStatusInvited => 'pozvánka odeslána';

  @override
  String get sharingStatusActive => 'aktivní';

  @override
  String get sharingStatusRevoked => 'přístup odebrán';

  @override
  String get sharingStatusLeft => 'sklep opuštěn';

  @override
  String sharingMemberSemantics(String name, String permission, String status) {
    return '$name, $permission, $status';
  }

  @override
  String get sharingClosedSection => 'Uzavřené přístupy';

  @override
  String get sharingNobody => 'Tento sklep zatím nikdo další nevidí';

  @override
  String sharingChangePermission(String name) {
    return 'Změnit oprávnění: $name';
  }

  @override
  String get sharingRevoke => 'Odebrat';

  @override
  String sharingRevokeTitle(String name) {
    return 'Odebrat přístup uživateli $name?';
  }

  @override
  String sharingRevokeConfirmLabel(String name) {
    return 'Potvrďte napsáním: $name';
  }

  @override
  String get sharingRevokeDisabledHint => 'Aktivní, jakmile se jméno shoduje';

  @override
  String get sharingReinvite => 'Pozvat znovu';

  @override
  String get sharingDeleteForGood => 'Smazat natrvalo';

  @override
  String sharingOwnedBy(String owner) {
    return 'Sklep: $owner';
  }

  @override
  String get sharingYourCellar => 'Váš sklep';

  @override
  String sharingYourPermission(String permission) {
    return 'Vaše oprávnění: $permission';
  }

  @override
  String sharingSwitcherSemantics(String cellar, String permission) {
    return '$cellar, $permission. Klepnutím změníte sklep';
  }

  @override
  String get sharingLeave => 'Opustit tento sklep';

  @override
  String sharingLeaveTitle(String owner) {
    return 'Opustit sklep, jehož vlastníkem je $owner?';
  }

  @override
  String sharingLeaveBody(String owner) {
    return 'Už ho neuvidíte. $owner vás může pozvat znovu.';
  }

  @override
  String get sharingLeaveConfirm => 'Opustit';

  @override
  String sharingSharedNotice(String owner) {
    return '$owner s vámi sdílí svůj sklep';
  }

  @override
  String sharingAccessLost(String owner) {
    return 'Už nemáte přístup do sklepa, jehož vlastníkem je $owner';
  }

  @override
  String sharingWritesLost(String owner) {
    return 'Některé změny ve sklepě, jehož vlastníkem je $owner, se neuložily, protože už nemáte přístup';
  }

  @override
  String get sharingSomeone => 'někdo';

  @override
  String get sharingShareSubject => 'Pozvánka do Vinoozy';

  @override
  String sharingShareMessage(
    String owner,
    String cellar,
    String link,
    String email,
  ) {
    return '$owner vás zve do sklepa „$cellar“ ve Vinoozy. Nainstalujte si aplikaci z $link a přihlaste se účtem Google $email: použijte přesně tuto adresu.';
  }

  @override
  String get cellarSearchHint => 'Hledat podle názvu nebo vinařství';

  @override
  String get cellarFilterStatus => 'Stav';

  @override
  String get cellarFilterType => 'Typ';

  @override
  String get statusToEstimate => 'K odhadu';

  @override
  String get filterTypeUnspecified => 'Neuvedeno';

  @override
  String get cellarNoMatches => 'Těmto filtrům neodpovídá žádné víno';

  @override
  String get cellarClearFilters => 'Vymazat filtry';

  @override
  String get cellarArchiveTitle => 'Vypité';

  @override
  String get cellarArchiveEmpty => 'Zatím žádná dopitá vína';

  @override
  String get cellarArchiveFailed => 'Dopitá vína se nepodařilo načíst';

  @override
  String get wineDrink => 'Vypito';

  @override
  String wineDrinkTooltip(String name) {
    return 'Označit jako vypitou láhev vína $name';
  }

  @override
  String confidenceLabel(String level) {
    return 'Spolehlivost: $level';
  }

  @override
  String get confidenceHigh => 'vysoká';

  @override
  String get confidenceMedium => 'střední';

  @override
  String get confidenceLow => 'nízká';

  @override
  String get windowStartLabel => 'Začátek';

  @override
  String get windowPeakLabel => 'Vrchol';

  @override
  String get windowEndLabel => 'Konec';

  @override
  String estimateSourceLabel(String source) {
    return 'Zdroj: $source';
  }

  @override
  String get estimateSourceCatalog => 'databáze vín';

  @override
  String get estimateSourceType => 'odhad pro typ';

  @override
  String get estimateSourceCorrected => 'odhad upravený podle vypitých lahví';

  @override
  String get estimateDisclaimer =>
      'Orientační odhad: záleží také na tom, jak byla láhev skladována';

  @override
  String get estimateUnavailable => 'Odhad není k dispozici';

  @override
  String get pairingsTitle => 'Párování';

  @override
  String get pairingsGeneric => 'obecné párování pro typ';

  @override
  String get pairingBraisedRedMeat => 'Dušené červené maso';

  @override
  String get pairingGrilledRedMeat => 'Grilované červené maso';

  @override
  String get pairingGame => 'Zvěřina';

  @override
  String get pairingRoastPoultry => 'Pečená drůbež';

  @override
  String get pairingPoultry => 'Drůbež';

  @override
  String get pairingPork => 'Vepřové maso';

  @override
  String get pairingCuredMeats => 'Uzeniny';

  @override
  String get pairingPastaMeatSauce => 'Těstoviny s masovou omáčkou';

  @override
  String get pairingMushroomsTruffle => 'Houby a lanýže';

  @override
  String get pairingAgedCheese => 'Zrající sýry';

  @override
  String get pairingFreshCheese => 'Čerstvé sýry';

  @override
  String get pairingBlueCheese => 'Sýry s modrou plísní';

  @override
  String get pairingFish => 'Ryby';

  @override
  String get pairingSeafood => 'Mořské plody';

  @override
  String get pairingRawSeafood => 'Syrové mořské plody';

  @override
  String get pairingFriedFood => 'Smažená jídla';

  @override
  String get pairingVegetables => 'Zelenina';

  @override
  String get pairingRisotto => 'Rizoto';

  @override
  String get pairingPizza => 'Pizza';

  @override
  String get pairingAperitif => 'Aperitiv';

  @override
  String get pairingPastries => 'Sladké pečivo';

  @override
  String get pairingDryBiscuits => 'Suché sušenky';

  @override
  String get pairingChocolate => 'Čokoláda';

  @override
  String get pairingDriedFruit => 'Ořechy a sušené ovoce';

  @override
  String get pairingSpicyDishes => 'Pikantní jídla';

  @override
  String get recentDrinksTitle => 'Naposledy vypité';

  @override
  String get noDrinksYet => 'Zatím nic vypitého';

  @override
  String get wineEdit => 'Upravit';

  @override
  String get wineDelete => 'Smazat';

  @override
  String get wineFinished => 'Dopito: žádné lahve nezbývají';

  @override
  String get wineLoadFailed => 'Víno se nepodařilo otevřít';

  @override
  String get wineNotFound => 'Toto víno už neexistuje';

  @override
  String drinkDone(String name) {
    return 'Označeno jako vypité: $name';
  }

  @override
  String get drinkUndo => 'Vrátit zpět';

  @override
  String get drinkAddNotes => 'Přidat hodnocení a poznámky';

  @override
  String get nothingToUndo => 'Už není co vrátit';

  @override
  String get cellarUndoRejected =>
      'Vrácení se nezdařilo: láhev zůstává označená jako vypitá';

  @override
  String get cellarDeleteFailed =>
      'Mazání ještě není dokončeno: dokončí se, jakmile to půjde';

  @override
  String get duplicateFull => 'Toto víno už má 99 lahví: další přidat nelze.';

  @override
  String get recordSheetTitle => 'Hodnocení a poznámky';

  @override
  String get recordRatingLabel => 'Hodnocení';

  @override
  String ratingStar(int n) {
    return 'Hodnocení $n z 5';
  }

  @override
  String get recordNotesLabel => 'Poznámky';

  @override
  String get recordNotesTooLong => 'Nejvýše 1000 znaků';

  @override
  String recordDateLabel(String date) {
    return 'Datum: $date';
  }

  @override
  String get recordDateInvalid =>
      'Datum nesmí být v budoucnosti ani před ročníkem';

  @override
  String get recordConditionTitle => 'Jaké bylo?';

  @override
  String get conditionTooYoung => 'Ještě příliš mladé';

  @override
  String get conditionJustRight => 'Tak akorát';

  @override
  String get conditionPastPeak => 'Za vrcholem';

  @override
  String get recordNoCondition => 'Bez odpovědi';

  @override
  String get producerLabel => 'Vinařství (nepovinné)';

  @override
  String get producerTooLong => 'Nejvýše 120 znaků';

  @override
  String producerAddNew(String name) {
    return 'Přidat nové vinařství: „$name“';
  }

  @override
  String get wineTypeLabel => 'Typ';

  @override
  String get typeRedLight => 'Lehké červené';

  @override
  String get typeRedStructured => 'Plné červené';

  @override
  String get typeWhite => 'Bílé';

  @override
  String get typeRose => 'Růžové';

  @override
  String get typeSparklingClassic => 'Šumivé klasickou metodou';

  @override
  String get typeSparklingTank => 'Šumivé metodou Charmat';

  @override
  String get typeSweet => 'Sladké';

  @override
  String get typeFortified => 'Fortifikované';

  @override
  String get suggestionFromCellar => 'Ve vašem sklepě';

  @override
  String get suggestionsLabel => 'Návrhy';

  @override
  String get duplicateTitle => 'Už je ve sklepě';

  @override
  String duplicateBody(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'má $count lahví',
      many: 'má $count lahve',
      few: 'má $count lahve',
      one: 'má $count láhev',
      zero: 'nemá žádné lahve',
    );
    return '$name: toto víno už ve sklepě je, $_temp0. Přidat nové lahve k němu?';
  }

  @override
  String duplicateAdd(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Přidat $count lahví',
      many: 'Přidat $count lahve',
      few: 'Přidat $count lahve',
      one: 'Přidat $count láhev',
    );
    return '$_temp0';
  }

  @override
  String get duplicateBanner => 'Možný duplikát';

  @override
  String get duplicateMerge => 'Sloučit';

  @override
  String get duplicateDeleteHint => 'Pokud jde o duplikát, tento záznam smažte';

  @override
  String get mergeTitle => 'Sloučit oba záznamy?';

  @override
  String get mergeBody =>
      'Lahve z tohoto záznamu se přesunou do staršího a tento záznam se smaže.';

  @override
  String get editWineTitle => 'Upravit víno';

  @override
  String get editDuplicate =>
      'Jiné víno se stejným názvem, vinařstvím a ročníkem už existuje';

  @override
  String deleteWineTitle(String name) {
    return 'Smazat víno $name?';
  }

  @override
  String get deleteWineBody =>
      'Víno i všechny záznamy o vypitých lahvích se smažou. Nejde to vrátit zpět.';

  @override
  String get historyTitle => 'Historie';

  @override
  String get historyEmpty => 'Tady najdete vypité lahve';

  @override
  String get historyLoadFailed => 'Historii se nepodařilo načíst';

  @override
  String drankOnLabel(String date) {
    return 'Vypito: $date';
  }

  @override
  String get addChoiceTitle => 'Přidat víno';

  @override
  String get addChoicePhoto => 'Vyfotit';

  @override
  String get addChoiceImport => 'Importovat fotku';

  @override
  String get addChoiceWrite => 'Napsat';

  @override
  String get labelReading => 'Čtu etiketu…';

  @override
  String get labelRecognized => 'Rozpoznáno:';

  @override
  String get labelCorrect => 'Opravit';

  @override
  String get labelConfirm => 'Potvrdit';

  @override
  String get labelUnreadable => 'Etiketu se nedaří přečíst';

  @override
  String get labelWriteByHand => 'Napsat ručně';

  @override
  String get labelNotFound => 'Víno nenalezeno: zkontrolujte údaje';

  @override
  String get labelCameraDenied =>
      'Ke čtení etikety je potřeba přístup k fotoaparátu';

  @override
  String get labelPhotosDenied =>
      'Ke čtení etikety je potřeba přístup k fotkám';

  @override
  String get labelOpenSettings => 'Otevřít nastavení';

  @override
  String get labelCameraUnavailable => 'Fotoaparát není k dispozici';

  @override
  String get labelBarcodeNotFound =>
      'Čárový kód je přečtený, ale víno se nenašlo';

  @override
  String get labelBarcodeFrontHint => 'Vyfoťte přední etiketu';

  @override
  String get labelSharedNotAllowed => 'Do tohoto sklepa nemůžete přidávat vína';

  @override
  String get labelSharedFirstOnly => 'Použita jen první fotka';

  @override
  String get labelSharedExpired =>
      'Sdílenou fotku se nepodařilo přečíst: sdílejte ji znovu';

  @override
  String get labelReplaceTitle => 'Máte neuložené víno. Přečíst novou fotku?';

  @override
  String get labelReplaceRead => 'Přečíst novou fotku';

  @override
  String get labelReplaceKeep => 'Pokračovat s otevřeným';

  @override
  String get labelWineAdded => 'Víno přidáno do sklepa';

  @override
  String get onboardingPage1Title => 'Váš sklep v kapse';

  @override
  String get onboardingPage1Body =>
      'Přidávejte lahve zápisem nebo fotkou etikety, i bez sítě.';

  @override
  String get onboardingPage2Title => 'V pravý čas';

  @override
  String get onboardingPage2Body =>
      'Vinoozy odhaduje, kdy je každé víno nejlepší, a poradí, která otevřít dřív.';

  @override
  String get onboardingPage3Title => 'Společně';

  @override
  String get onboardingPage3Body =>
      'Sdílejte sklep až se dvěma lidmi a veďte si historii každé vypité lahve.';

  @override
  String get onboardingSkip => 'Přeskočit';

  @override
  String get onboardingNext => 'Další';

  @override
  String get onboardingStart => 'Začít';

  @override
  String onboardingPageOf(int page) {
    return 'Strana $page ze 3';
  }

  @override
  String get profileTitle => 'Profil';

  @override
  String get profilePhoto => 'Profilová fotka';

  @override
  String get profileSignOut => 'Odhlásit se';

  @override
  String get profileDeleteAccount => 'Smazat účet';

  @override
  String get profilePrivacy => 'Zásady ochrany soukromí';

  @override
  String get profilePrivacyBody =>
      'Zásady ochrany soukromí si můžete přečíst na této adrese:';

  @override
  String get profileOpenLink => 'Otevřít v prohlížeči';

  @override
  String get profileOpenLinkFailed =>
      'Stránku se nepodařilo otevřít. Odkaz můžete zkopírovat a otevřít v prohlížeči.';

  @override
  String get profileCopyLink => 'Kopírovat odkaz';

  @override
  String get profileLinkCopied => 'Odkaz zkopírován';

  @override
  String get close => 'Zavřít';

  @override
  String get signOutConfirmTitle => 'Chcete se odhlásit?';

  @override
  String signOutPendingWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Máte $count dosud neuložených změn. Pokud se odhlásíte a přihlásí se jiný účet, ztratí se.',
      many:
          'Máte $count dosud neuložené změny. Pokud se odhlásíte a přihlásí se jiný účet, ztratí se.',
      few:
          'Máte $count dosud neuložené změny. Pokud se odhlásíte a přihlásí se jiný účet, ztratí se.',
      one:
          'Máte $count dosud neuloženou změnu. Pokud se odhlásíte a přihlásí se jiný účet, ztratí se.',
    );
    return '$_temp0';
  }

  @override
  String get signOutStayAndSync => 'Zůstat a synchronizovat';

  @override
  String get signOutAnyway => 'Přesto se odhlásit';

  @override
  String get syncAllSaved => 'Vše uloženo';

  @override
  String syncStillPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count změn ještě čeká na uložení: zkontrolujte síť',
      many: '$count změny ještě čeká na uložení: zkontrolujte síť',
      few: '$count změny ještě čekají na uložení: zkontrolujte síť',
      one: '$count změna ještě čeká na uložení: zkontrolujte síť',
    );
    return '$_temp0';
  }

  @override
  String get signOutFailed => 'Odhlášení se nezdařilo. Zkuste to znovu';

  @override
  String get signInAccountDeleted => 'Účet smazán';

  @override
  String get deleteAccountIntro => 'Natrvalo se smaže:';

  @override
  String get deleteAccountItemCellar => 'Váš sklep s víny a Historií';

  @override
  String get deleteAccountItemShares =>
      'Vaše sdílení: pozvaní lidé ztratí přístup';

  @override
  String get deleteAccountItemMemberships =>
      'Vaše účast v cizích sklepech: záznamy o vámi vypitých lahvích tam zůstanou bez vašeho jména';

  @override
  String get deleteAccountItemProfile => 'Váš profil';

  @override
  String deleteAccountPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Máte $count dosud neuložených změn: uloží se a pak se smažou se vším ostatním',
      many:
          'Máte $count dosud neuložené změny: uloží se a pak se smažou se vším ostatním',
      few:
          'Máte $count dosud neuložené změny: uloží se a pak se smažou se vším ostatním',
      one:
          'Máte $count dosud neuloženou změnu: uloží se a pak se smaže se vším ostatním',
    );
    return '$_temp0';
  }

  @override
  String get deleteAccountConfirmWord => 'SMAZAT';

  @override
  String deleteAccountTypeWord(String word) {
    return 'Potvrďte napsáním slova $word';
  }

  @override
  String get deleteAccountReauthHint =>
      'Poté se znovu přihlásíte přes Google, abyste potvrdili, že jste to vy.';

  @override
  String get deleteAccountForever => 'Smazat navždy';

  @override
  String get deleteAccountNeedsNetwork =>
      'Ke smazání účtu se připojte k internetu';

  @override
  String get deleteAccountSameAccount =>
      'Smazání vyžaduje přihlášení stejným účtem';

  @override
  String get deletionTitle => 'Mazání účtu';

  @override
  String get deletionStepPreparePhone => 'Ukládání čekajících změn';

  @override
  String get deletionStepMarkStarted => 'Zahajování mazání';

  @override
  String get deletionStepLeaveOtherCellars => 'Opouštění cizích sklepů';

  @override
  String get deletionStepCloseOwnInvitations => 'Ukončování vašich sdílení';

  @override
  String get deletionStepDeleteWinesAndRecords => 'Mazání vín a Historie';

  @override
  String get deletionStepDeleteCellar => 'Mazání sklepa';

  @override
  String get deletionStepDeleteProfileAndUser => 'Mazání profilu a účtu';

  @override
  String get deletionStepCleanUpPhone => 'Čištění tohoto telefonu';

  @override
  String deletionStepAnnounce(int step, String label) {
    return 'Krok $step z 8: $label';
  }

  @override
  String deletionDeletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Smazáno $count vín a záznamů',
      many: 'Smazáno $count vína a záznamu',
      few: 'Smazána $count vína a záznamy',
      one: 'Smazáno $count víno nebo záznam',
    );
    return '$_temp0';
  }

  @override
  String get deletionResumeHint =>
      'Mazání tohoto účtu není dokončeno. Dokončíte ho, když se znovu přihlásíte přes Google.';

  @override
  String get deletionContinue => 'Pokračovat';

  @override
  String get deletionOffline => 'K dokončení mazání se připojte k internetu';

  @override
  String get deletionPendingWrites =>
      'Čekající změny se nedaří uložit. Zkuste to znovu';

  @override
  String get deletionFailed => 'Mazání se nepodařilo dokončit. Zkuste to znovu';

  @override
  String get uxCountryLabel => 'Země';

  @override
  String get uxCountryOther => 'Jiná země…';

  @override
  String get uxCountryNone => 'Bez země';

  @override
  String get uxAllCountriesTitle => 'Všechny země a území';

  @override
  String get uxAllCountriesSearch => 'Hledat zemi';

  @override
  String get uxAllCountriesRare => 'U vína vzácné';

  @override
  String get uxAllCountriesAll => 'Všechny, od A do Z';

  @override
  String get uxAllCountriesNone => 'Žádná země nenalezena';

  @override
  String get uxRegionLabel => 'Region';

  @override
  String uxRegionOf(String country) {
    return 'Region · $country';
  }

  @override
  String get uxRegionOther => 'Jiný region';

  @override
  String get uxRegionFieldLabel => 'Napište region';

  @override
  String get uxRegionTooLong => 'Nejvýše 120 znaků';

  @override
  String get uxDrinkAction => 'Vypito';

  @override
  String uxDrinkActionTooltip(String name) {
    return 'Vypitá láhev vína $name';
  }

  @override
  String get uxDrinkActionDetail => 'Vypitá láhev';

  @override
  String get uxDrinkSheetLabel => 'Potvrzení vypití';

  @override
  String get uxDrinkSheetBottles => 'Lahve';

  @override
  String uxDrinkSheetBottlesChange(int before, int after) {
    return 'Lahve: z $before na $after';
  }

  @override
  String get uxDrinkSheetRating => 'Jaké bylo? (nepovinné)';

  @override
  String uxDrinkSheetStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hvězdiček z 5',
      many: '$count hvězdičky z 5',
      few: '$count hvězdičky z 5',
      one: '$count hvězdička z 5',
    );
    return '$_temp0';
  }

  @override
  String get uxDrinkSheetConfirm => 'Ano, vypito';

  @override
  String get uxRemoveBottle => 'Odebrat láhev bez záznamu o vypití';

  @override
  String get uxRemoveBottleTitle => 'Odebrat láhev?';

  @override
  String uxRemoveBottleBody(String name) {
    return 'Jedna láhev vína $name se odebere bez záznamu o vypití.';
  }

  @override
  String get uxRemoveBottleConfirm => 'Odebrat';

  @override
  String get uxIdealTitle => 'Ideální chvíle';

  @override
  String uxIdealUntil(String year) {
    return 'Doporučeno do $year';
  }

  @override
  String uxIdealUntilPast(String year) {
    return 'Doporučeno do $year: už uplynulo';
  }

  @override
  String uxIdealBest(String start, String end) {
    return 'Nejlepší od $start do $end';
  }

  @override
  String uxIdealBar(String start, String end) {
    return 'Okno pitelnosti od $start do $end';
  }

  @override
  String get uxIdealDisclaimer =>
      '⚠︎ Orientační: odhad podle typu, apelace a ročníku. Skladování a konkrétní láhev ho mohou změnit.';

  @override
  String get uxIdealUnavailableHint => 'Pro odhad doplňte ročník a typ.';

  @override
  String uxDashboardDrinkNow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count k vypití teď',
      many: '$count k vypití teď',
      few: '$count k vypití teď',
      one: '$count k vypití teď',
    );
    return '$_temp0';
  }

  @override
  String get uxFamilyRed => 'Červené';

  @override
  String get uxFamilyWhite => 'Bílé';

  @override
  String get uxFamilyRose => 'Růžové';

  @override
  String get uxFamilySparkling => 'Šumivé';

  @override
  String get uxFamilySweet => 'Sladké';

  @override
  String get labelBackTitle => 'Teď zadní strana';

  @override
  String get labelBackHint =>
      'Na zadní etiketě bývá čárový kód, vinařství a ročník: pomáhají víno najít.';

  @override
  String get labelBackTake => 'Vyfotit zadní stranu';

  @override
  String get labelBackGallery => 'Vybrat z galerie';

  @override
  String get labelBackSkip => 'Přeskočit';

  @override
  String get labelStepFront => 'Přední strana';

  @override
  String get labelStepBack => 'Zadní strana';

  @override
  String get labelStepBarcode => 'Čárový kód';

  @override
  String get labelStepDatabase => 'Databáze vín v telefonu';

  @override
  String get labelStepPending => 'Čeká';

  @override
  String get labelStepRunning => 'Probíhá…';

  @override
  String get labelStepDone => 'Hotovo';

  @override
  String get labelStepSkipped => 'Přeskočeno';

  @override
  String get labelStepFailed => 'Nečitelné';

  @override
  String labelStepStatus(String step, String status) {
    return '$step: $status';
  }

  @override
  String get labelOnPhoneNote =>
      'Vše probíhá v telefonu: fotky se nikomu neposílají.';

  @override
  String get labelBackUnreadable => 'Zadní strana nečitelná';

  @override
  String get labelSourceOffline => 'Z databáze v telefonu · offline';

  @override
  String get labelSourceCatalog => 'Z katalogu';

  @override
  String get labelSourceOnline => 'Z Open Food Facts · online';

  @override
  String get labelNotThis => 'Tohle ne';

  @override
  String get labelOffAttribution => 'Data z Open Food Facts, licence ODbL';

  @override
  String get labelCandidatesTitle => 'Které z nich?';

  @override
  String labelCandidatesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count podobných vín',
      many: '$count podobného vína',
      few: '$count podobná vína',
      one: '$count podobné víno',
    );
    return '$_temp0';
  }

  @override
  String get labelCandidatesNone => 'Žádné z nich';

  @override
  String get labelChipOffline => 'offline';

  @override
  String get labelChipOnline => 'online';

  @override
  String get labelChipCatalog => 'katalog';

  @override
  String get labelNoProducer => 'vinařství neuvedeno';

  @override
  String get labelNoMatch => 'Etiketa je přečtená, ale víno nepoznávám';

  @override
  String get labelReadText => 'Přečtený text';

  @override
  String get labelSearchOnline => 'Hledat online';

  @override
  String get labelOpenLens => 'Otevřít v Google Lens';

  @override
  String get labelLensLastResort =>
      'Google Lens je poslední možnost: fotka se do aplikace Google odešle jen po vašem potvrzení.';

  @override
  String get labelLensTitle => 'Otevřít v Google Lens?';

  @override
  String get labelLensBody =>
      'Fotka přední etikety se odešle do aplikace Google ve vašem telefonu nebo do aplikace, kterou zvolíte; ta si může kopii ponechat podle vlastních pravidel. Vinoozy výsledky nedostává: vraťte se sem a víno vyberte nebo napište.';

  @override
  String get labelLensConfirm => 'Otevřít Google Lens';

  @override
  String get labelLensFailed =>
      'Google Lens ani nabídku sdílení se nedaří otevřít';

  @override
  String get onlineSearchTitle => 'Hledat online';

  @override
  String get onlineSearchSubtitle => 'Open Food Facts · jen vína';

  @override
  String get onlineSearchField => 'Hledaná slova';

  @override
  String get onlineSearchHint => 'Slova můžete před hledáním změnit.';

  @override
  String get onlineSearchEmptyField => 'Napište aspoň jedno slovo';

  @override
  String get onlineSearchButton => 'Hledat';

  @override
  String get onlineSearchLoading => 'Hledám…';

  @override
  String onlineSearchResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count výsledků',
      many: '$count výsledku',
      few: '$count výsledky',
      one: '$count výsledek',
    );
    return '$_temp0';
  }

  @override
  String get onlineSearchEmpty =>
      'Žádné víno nenalezeno: zkuste jiná slova nebo „Napsat ručně“.';

  @override
  String get onlineSearchOffline =>
      'Bez sítě: hledám jen v databázi v telefonu.';

  @override
  String get onlineSearchRateLimited =>
      'Hledání online teď není dostupné, zkuste to znovu za pár minut.';

  @override
  String get onlineSearchUnavailable =>
      'Hledání online není v této verzi aplikace aktivní: hledám jen v databázi v telefonu.';

  @override
  String get aboutTitle => 'O aplikaci';

  @override
  String aboutVersion(String version) {
    return 'Verze $version';
  }

  @override
  String get aboutDbTitle => 'Databáze vín';

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
    return 'Export Open Food Facts ze dne $date';
  }

  @override
  String get aboutDbSample =>
      'Ukázková databáze: několik ručně zapsaných testovacích vín, ne data Open Food Facts.';

  @override
  String get aboutDbLoading => 'Otevírám databázi vín…';

  @override
  String get aboutDbUnavailable => 'Databáze vín není v této verzi k dispozici';

  @override
  String aboutDbSource(String url) {
    return 'Odvozená databáze a nástroj, který ji vytváří, jsou ve veřejném repozitáři: $url';
  }

  @override
  String get aboutLicenseTitle => 'Licence';

  @override
  String get aboutLicense =>
      'Obsahuje informace z Open Food Facts zpřístupněné pod licencí Open Database License (ODbL). Jednotlivý obsah podléhá licenci Database Contents License (DbCL).';

  @override
  String get aboutPrivacyTitle => 'Fotky etiket';

  @override
  String get aboutPrivacy =>
      'Fotky etiket se čtou v telefonu a mažou se, když opustíte výsledek. Telefon opustí, jen když klepnete na „Otevřít v Google Lens“ a potvrdíte to.';

  @override
  String get aboutAppellationsTitle => 'Apelace';

  @override
  String get aboutAppellationsSource =>
      'Apelace: registr eAmbrosia (EU) a oficiální národní registry.';

  @override
  String get aboutAppellationsSample =>
      'Ukázková tabulka: ručně zapsaný výtah z registrů, dokud se nestáhnou skutečné registry.';

  @override
  String get denominationLabel => 'Apelace';

  @override
  String get denominationTooLong => 'Nejvýše 120 znaků';

  @override
  String get autofillFilledNotice =>
      'Vyplněno z etikety: zkontrolujte a uložte';

  @override
  String get autofillPastedNotice => 'Vyplněno z textu: zkontrolujte a uložte';

  @override
  String get autofillFromText => '✦ z textu';

  @override
  String get autofillFromTextSemantics => 'vyplněno z etikety';

  @override
  String get autofillClear => 'Vymazat';

  @override
  String get autofillLens => 'Lens';

  @override
  String get autofillClearTitle => 'Vymazat formulář?';

  @override
  String get autofillClearBody =>
      'Některá pole jsou vyplněná i ručně. „Vymazat“ vyprázdní název, vinařství, apelaci, ročník, typ, zemi, region a úroveň. Množství zůstane.';

  @override
  String get autofillClearConfirm => 'Vymazat';

  @override
  String get autofillCleared => 'Formulář vymazán';

  @override
  String get autofillPasteTitle => 'Máte text z Google Lens?';

  @override
  String get autofillPasteHint =>
      'V Lens označte text etikety, klepněte na „Kopírovat“ a vraťte se sem.';

  @override
  String get autofillPaste => 'Vložit z Lens';

  @override
  String get autofillOpenLens => 'Z Google Lens';

  @override
  String get autofillOpenLensSemantics => 'otevře Google Lens';

  @override
  String get autofillClipboardEmpty => 'Ve schránce není žádný text';

  @override
  String get autofillNoNewFields => 'V textu nejsou žádné údaje k doplnění';

  @override
  String get autofillFromLens => 'Formulář vyplněn textem z Lens';

  @override
  String get autofillShareEmpty => 'Nepřišel žádný text';

  @override
  String get autofillShareUseTitle => 'Použít text pro prázdná pole?';

  @override
  String get autofillShareUse => 'Použít';

  @override
  String get autofillShareIgnore => 'Ignorovat';

  @override
  String get addChoiceLens => 'Z Google Lens';

  @override
  String get addChoicePhotoHint =>
      'Přední a zadní strana: Vinoozy etiketu přečte.';

  @override
  String get addChoiceLensHint =>
      'Otevře Lens: zaměřte, označte text a klepněte na Sdílet → Vinoozy.';

  @override
  String get addChoiceImportHint => 'Fotka etikety, kterou už máte.';

  @override
  String get addChoiceWriteHint =>
      'Prázdný formulář s možností „Vložit z Lens“.';

  @override
  String get lensInstructionsTitle => 'Google Lens odsud nejde otevřít';

  @override
  String get lensInstructionsStep1 => 'Otevřete Google Lens a zaměřte etiketu';

  @override
  String get lensInstructionsStep2 => 'Označte text etikety';

  @override
  String get lensInstructionsStep3 => 'Klepněte na Sdílet → Vinoozy';

  @override
  String get lensInstructionsOk => 'Rozumím';

  @override
  String get levelLabel => 'Úroveň';

  @override
  String get levelEveryday => 'Každodenní (levné)';

  @override
  String get levelGood => 'Dobré';

  @override
  String get levelAging => 'K archivaci';

  @override
  String get levelNone => 'Žádná';

  @override
  String get levelEverydayShort => 'vypít mladé';

  @override
  String get levelGoodShort => 'běžný odhad';

  @override
  String get levelAgingShort => 'vydrží déle';

  @override
  String get levelSuggested => 'navržená';

  @override
  String levelSuggestedReason(String qualifier) {
    return 'Navržená, protože v názvu je „$qualifier“: uloží se takto, pokud ji nezměníte. Vyberte jinou nebo klepněte na „Žádná“.';
  }

  @override
  String levelSuggestedSemantics(String qualifier) {
    return 'navržená, protože v názvu je $qualifier';
  }

  @override
  String levelOptionSemantics(String option, int index, int count) {
    return 'Úroveň, $option, $index z $count';
  }

  @override
  String get levelWhatChanges => 'Co se změní';

  @override
  String get levelEverydayExamples =>
      'Okno se zkrátí. Např. stolní víno, Lambrusco, základní Prosecco, Bardolino, Vinho Verde.';

  @override
  String get levelGoodExamples =>
      'Běžný odhad, který platí i tehdy, když nic nevyberete. Např. Chianti Classico, Barbera d\'Asti Superiore, Rioja Crianza, Côtes du Rhône.';

  @override
  String get levelAgingExamples =>
      'Okno se prodlouží. Např. Barolo, Brunello, Amarone, Bordeaux Grand Cru, Rioja Gran Reserva, Vintage Port.';

  @override
  String levelPreviewBefore(String start, String end) {
    return 'Předtím $start – $end';
  }

  @override
  String levelPreviewWith(String level, String start, String end) {
    return 'S úrovní „$level“ $start – $end';
  }

  @override
  String levelPreviewNow(String start, String end) {
    return 'Připravené $start – do $end';
  }

  @override
  String levelDetail(String level) {
    return 'Úroveň: $level';
  }

  @override
  String get overrideCorrect => 'Opravit';

  @override
  String get overrideRestore => 'Obnovit odhad';

  @override
  String get overrideCorrectedByYou => 'opraveno vámi';

  @override
  String overrideAppEstimate(String year) {
    return 'Odhad aplikace: do $year';
  }

  @override
  String get overrideSheetTitle => 'Doporučeno do';

  @override
  String overrideSheetHint(String start) {
    return 'Vyberte rok. Nesmí být dřív než „Připravené od $start“.';
  }

  @override
  String overridePeakNotice(String peak) {
    return 'Pokud vyberete rok před $peak (nejlepší), posune se na stejný rok i „nejlepší“.';
  }

  @override
  String get overrideMore => 'další…';

  @override
  String get overrideSave => 'Uložit opravu';

  @override
  String overrideRestoreTitle(String year) {
    return 'Vrátit se k odhadu aplikace (do $year)?';
  }

  @override
  String get overrideRestoreConfirm => 'Obnovit';

  @override
  String get overrideSaved => 'Oprava uložena';

  @override
  String get overrideRestored => 'Odhad obnoven';

  @override
  String get estimateSourceCorrectedByYou => 'opraveno vámi';

  @override
  String estimateFromDenomination(String name) {
    return 'Odhad podle apelace $name';
  }

  @override
  String estimateFromDenominationQualifier(String name, String qualifier) {
    return 'Odhad podle apelace $name, $qualifier';
  }

  @override
  String estimateFromGrape(String name) {
    return 'Odhad podle odrůdy $name';
  }

  @override
  String get estimateFromType => 'Odhad podle typu vína';

  @override
  String get autofillReading => 'Čtu text…';

  @override
  String get guideChip => 'Průvodce';

  @override
  String guideProgress(int n, int total) {
    return 'Otázka $n z $total';
  }

  @override
  String get guideClose => 'Zavřít';

  @override
  String get guideIsDenomination => 'je to apelace?';

  @override
  String get guideIsProducer => 'je to vinařství?';

  @override
  String get guideIsName => 'je to název vína?';

  @override
  String get guideIsVintage => 'Ročník';

  @override
  String guideAskDenomination(String value) {
    return 'Je $value apelace?';
  }

  @override
  String guideAskProducer(String value) {
    return 'Je $value vinařství?';
  }

  @override
  String guideAskName(String value) {
    return 'Je $value název vína?';
  }

  @override
  String get guideAskVintage => 'Jaký je ročník?';

  @override
  String guideQuestionSemantics(int n, int total, String question) {
    return 'Otázka $n z $total: $question';
  }

  @override
  String get guideNoProposal => 'V textu se to nenašlo';

  @override
  String get guideYes => 'Ano';

  @override
  String get guideNo => 'Ne, něco jiného';

  @override
  String get guideEdit => 'Upravit';

  @override
  String get guideSkip => 'Přeskočit';

  @override
  String get guideConfirm => 'Potvrdit';

  @override
  String get guideCancel => 'Zrušit';

  @override
  String guideRejected(String value) {
    return '„$value“ ne: tady je další návrh';
  }

  @override
  String get guideNoMore =>
      'Žádný další návrh: složte ho ze slov, nebo přeskočte';

  @override
  String guideProposalAnnounce(String value) {
    return 'Návrh: $value';
  }

  @override
  String get guideComposeLabel => 'Nebo ho složte klepáním na slova z textu';

  @override
  String get guideComposePreview => 'Náhled';

  @override
  String get guideComposeEmpty => 'Klepněte na jedno nebo více slov';

  @override
  String get guideComposeLimit => 'Nejvýše 8 slov a 80 znaků';

  @override
  String guideTableMatchSemantics(String name) {
    return 'odpovídá: $name';
  }

  @override
  String guideLine(int n, int total) {
    return 'Řádek $n z $total';
  }

  @override
  String guideWordSelected(String word, int order) {
    return '$word, vybráno, $order';
  }

  @override
  String guideWordUnavailable(String word) {
    return '$word, nedostupné';
  }

  @override
  String guideWordUsedFor(String word, String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'apelace',
      'producer': 'vinařství',
      'other': 'název',
    });
    return '$word, použito pro pole: $_temp0';
  }

  @override
  String guideUsedMark(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'apelace',
      'producer': 'vinařství',
      'other': 'název',
    });
    return '$_temp0';
  }

  @override
  String guideOtherYears(String years) {
    return 'V textu je také: $years';
  }

  @override
  String get guideWheelFromText => 'rok nalezený v textu';

  @override
  String get guideWheelTypeYear => 'Napište rok';

  @override
  String guideWheelConfirm(String year) {
    return 'Potvrdit $year';
  }

  @override
  String get guideNoVintage => 'Bez ročníku';

  @override
  String guideSkippedNotice(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'Apelace přeskočena',
      'producer': 'Vinařství přeskočeno',
      'vintage': 'Ročník přeskočen',
      'other': 'Název přeskočen',
    });
    return '$_temp0: doplňte ručně, nebo se vraťte k průvodci';
  }

  @override
  String guideSkippedMany(int count) {
    return 'Přeskočená pole: $count. Doplňte je ručně, nebo se vraťte k průvodci';
  }

  @override
  String get guideInvalidValue =>
      'Tento text obsahuje znaky, které nelze uložit';

  @override
  String get brandStudio => 'Bottazzini Softworks';

  @override
  String get suggestedMark => '✦ navrženo';

  @override
  String suggestedSemantics(String field, String value) {
    return '$field, $value, navrženo';
  }

  @override
  String get restoreSuggestion => 'Obnovit návrh';

  @override
  String get restoreSuggestionDone => 'Návrh obnoven';

  @override
  String get styleLabel => 'Styl';

  @override
  String styleGroupSemantics(String value, int index, int count) {
    return 'Styl, $value, $index z $count';
  }

  @override
  String get styleRedFresh => 'Svěží';

  @override
  String get styleRedMedium => 'Střední';

  @override
  String get styleRedAge => 'K archivaci';

  @override
  String get styleRedLong => 'Dlouhá archivace';

  @override
  String get styleWhiteFresh => 'Svěží';

  @override
  String get styleWhiteMedium => 'Střední';

  @override
  String get styleWhiteAge => 'K archivaci';

  @override
  String get styleRoseFresh => 'Svěží';

  @override
  String get styleClassicFresh => 'Svěží';

  @override
  String get styleClassicAge => 'K archivaci';

  @override
  String get styleTankFresh => 'Svěží';

  @override
  String get styleLambrusco => 'Lambrusco';

  @override
  String get styleSweetAromatic => 'Aromatické';

  @override
  String get styleSweetPassito => 'Slámové';

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
  String get styleFortifiedOther => 'Jiné';

  @override
  String get profileNameRFresh => 'Ovocné červené';

  @override
  String get profileNameRMedium => 'Středně plné červené';

  @override
  String get profileNameRAge => 'Červené k archivaci';

  @override
  String get profileNameRLong => 'Červené k dlouhé archivaci';

  @override
  String get profileNameWFresh => 'Svěží aromatické bílé';

  @override
  String get profileNameWMedium => 'Středně plné bílé';

  @override
  String get profileNameWAge => 'Bílé k archivaci';

  @override
  String get profileNameRoseFresh => 'Svěží růžové';

  @override
  String get profileNameSpTank => 'Svěží šumivé metodou Charmat';

  @override
  String get profileNameLamFresh => 'Svěží Lambrusco';

  @override
  String get profileNameSpClassic => 'Svěží šumivé klasickou metodou';

  @override
  String get profileNameSpClassicAge => 'Šumivé klasickou metodou k archivaci';

  @override
  String get profileNameSwAromatic => 'Mladé aromatické sladké víno';

  @override
  String get profileNameSwPassito => 'Sladké slámové víno';

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
  String get profileNameFortUnknown => 'Fortifikované, neznámý styl';

  @override
  String get profileNameUnknown => 'Styl nerozpoznán';

  @override
  String estimateFromProfile(String profile, String denomination) {
    return 'Odhad podle profilu: $profile ($denomination)';
  }

  @override
  String estimateFromProfileType(String profile) {
    return 'Odhad podle profilu: $profile, podle typu';
  }

  @override
  String estimateFromProfileGrape(String profile, String grape) {
    return 'Odhad podle profilu: $profile, podle odrůdy $grape';
  }

  @override
  String get estimateFromEntryDateDisgorgement =>
      'Od data přidání: pro lepší odhad doplňte datum degoržáže';

  @override
  String get estimateFromEntryDateBottling =>
      'Od data přidání: pro lepší odhad doplňte datum lahvování';

  @override
  String get styleToConfirmBanner => '⚠︎ Styl k potvrzení: odhad je orientační';

  @override
  String get chooseTypePrompt => 'Vyberte typ';

  @override
  String estimateUpdatedAnnouncement(String summary) {
    return 'Odhad aktualizován: $summary';
  }

  @override
  String get agingStartDisgorgement => 'Degoržáž';

  @override
  String get agingStartBottling => 'Lahvování';

  @override
  String get agingStartMonth => 'Měsíc';

  @override
  String get agingStartYear => 'Rok';

  @override
  String get agingStartHint => 'Obvykle bývá na zadní etiketě.';

  @override
  String get agingStartIncomplete => 'Zadejte měsíc a rok';

  @override
  String get agingStartFuture => 'Datum nesmí být v budoucnosti';

  @override
  String get agingStartBeforeVintage => 'Nesmí být před ročníkem';

  @override
  String get windowNoEnd => 'Připravené, konec není odhadnut';

  @override
  String get windowNoEndShort => 'konec není odhadnut';

  @override
  String windowDrinkWithin(String date) {
    return 'do $date';
  }

  @override
  String get levelNoEffect => 'Úroveň tento odhad nemění';

  @override
  String get dashboardToConfirmTitle => 'K potvrzení';

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
    return '$percent % vín s rozpoznaným typem';
  }

  @override
  String get planTitle => 'Tarif';

  @override
  String get planFree => 'Bezplatný';

  @override
  String get planPlus => 'Plus';

  @override
  String get planPlusGift => 'Plus (dárek)';

  @override
  String get planDevUnlockAll => 'DEV · Testovací Plus';

  @override
  String get planDevSimulateFree => 'DEV · Simulovaný bezplatný tarif';

  @override
  String get planDevSimulateExpired => 'DEV · Simulovaný prošlý Plus';

  @override
  String get planDiscoverPlus => 'Objevit Plus';

  @override
  String get plusTitle => 'Vinoozy Plus';

  @override
  String get plusBenefitsTitle => 'S Plus';

  @override
  String get plusBenefitNoAds => 'Bez reklam';

  @override
  String get plusBenefitNoLimit => 'Bez limitu vín ve sklepě';

  @override
  String get plusComingSoon => 'Plus bude brzy';

  @override
  String get plusLoading => 'Načítám ceny z Google Play';

  @override
  String get plusStoreUnavailable =>
      'Ceny z Google Play se nepodařilo načíst. Zkuste to později.';

  @override
  String plusPriceMonthly(String price) {
    return '$price měsíčně';
  }

  @override
  String plusPriceAnnual(String price) {
    return '$price ročně';
  }

  @override
  String get plusRenewal =>
      'Předplatné se automaticky obnovuje za uvedenou cenu, dokud ho nezrušíte v Google Play.';

  @override
  String get plusTerms =>
      'Platba se strhne z vašeho účtu Google Play při potvrzení nákupu. Zrušit můžete kdykoli: Plus zůstane aktivní do konce zaplaceného období. Až Plus skončí, všechna vaše vína zůstanou.';

  @override
  String get plusRestore => 'Obnovit nákupy';

  @override
  String get plusManage => 'Spravovat nebo zrušit předplatné v Google Play';

  @override
  String get plusActive => 'Plus je na tomto účtu aktivní';

  @override
  String get plusActiveGift =>
      'Máte Plus jako dárek: žádné platby ani obnovování.';

  @override
  String get plusPending =>
      'Platba čeká: Plus se aktivuje, až ji Google Play potvrdí.';

  @override
  String get plusVerifying => 'Ověřuji nákup';

  @override
  String get plusVerified => 'Nákup ověřen: Plus bude aktivní za pár sekund.';

  @override
  String get plusPurchaseFailed => 'Nákup se nedokončil. Zkuste to znovu.';

  @override
  String get plusInvalidPurchase =>
      'Google Play tento nákup pro Vinoozy nepotvrdil.';

  @override
  String get plusOwnedByOther =>
      'Toto předplatné už patří k jinému účtu Vinoozy.';

  @override
  String get plusVerificationUnavailable =>
      'Nákup teď nejde ověřit. Zkuste to později: předplatné zůstává v Google Play.';

  @override
  String get capacityLimitTitle => 'Limit bezplatného tarifu je vyčerpán';

  @override
  String capacityLimitBody(int limit) {
    return 'Bezplatný tarif zahrnuje nejvýše tento počet různých vín ve sklepě: $limit. Vína, která už máte, můžete vždy upravovat, označovat jako vypitá a přidávat k nim lahve. Chcete-li přidat nové, dopijte nebo smažte některé víno, nebo přejděte na Plus.';
  }

  @override
  String capacityLimitBodyComingSoon(int limit) {
    return 'Bezplatný tarif zahrnuje nejvýše tento počet různých vín ve sklepě: $limit. Vína, která už máte, můžete vždy upravovat, označovat jako vypitá a přidávat k nim lahve. Chcete-li přidat nové, dopijte nebo smažte některé víno. Plus bude brzy.';
  }

  @override
  String get rejectedCapacityLimit =>
      'Nesynchronizováno: překračuje limit vín bezplatného tarifu. Změna zůstává v tomto telefonu.';

  @override
  String get rejectedCapacityConflict =>
      'Nesynchronizováno: sklep se ve stejnou chvíli změnil na jiném zařízení. Změna zůstává v tomto telefonu: zkuste to znovu.';

  @override
  String writeRejectedCapacityLimit(String name) {
    return '$name: nesynchronizováno, překročen limit bezplatného tarifu';
  }

  @override
  String writeRejectedCapacityConflict(String name) {
    return '$name: nesynchronizováno, sklep se změnil na jiném zařízení';
  }

  @override
  String get freeIntroTitle => 'Bezplatný tarif';

  @override
  String freeIntroLimit(int limit) {
    return 'Zdarma můžete spravovat nejvýše tento počet různých vín: $limit.';
  }

  @override
  String get freeIntroAds =>
      'Při běžném používání se reklamy nezobrazují. Když překročíte měsíční práh využití služby, můžete občas vidět reklamy, které pomáhají pokrýt náklady na servery a synchronizaci.';

  @override
  String get freeIntroNoAds => 'V úvodní verzi nejsou žádné reklamy.';

  @override
  String get freeIntroPlus => 'S Plus zmizí reklamy i limit sklepa.';

  @override
  String get noticeGotIt => 'Rozumím';

  @override
  String get thresholdTitle => 'Díky reklamám zůstává Vinoozy zdarma';

  @override
  String get thresholdBody =>
      'Měsíční práh využití bez reklam je vyčerpán. Odteď můžete občas vidět reklamy: pomáhají nám pokrýt náklady na servery a synchronizaci, a Vinoozy tak zůstává zdarma.';

  @override
  String get thresholdReset =>
      'Počítání začne znovu příští měsíc. S Plus používáte aplikaci bez reklam a bez limitu sklepa.';

  @override
  String thresholdNextReset(String date) {
    return 'Další vynulování: $date';
  }

  @override
  String get thresholdHowItWorks => 'Jak to funguje';

  @override
  String get thresholdHowItWorksBody =>
      'Práh vychází z odhadu počtu synchronizací s cloudem, které tento účet během měsíce provedl. Samotné používání offline nové operace v cloudu nevytváří. Reklamy se zobrazují nejvýše jednou denně, jen na Přehledu, a nikdy při ukládání nebo exportu dat.';

  @override
  String get adLabel => 'Reklama';

  @override
  String get devToolsTitle => 'Vývojářské nástroje';

  @override
  String get devUnlockAll => 'Odemknout vše — testovací Plus';

  @override
  String get devSimulateFree => 'Simulovat bezplatný tarif';

  @override
  String get devSimulateExpired => 'Simulovat prošlý Plus';

  @override
  String get devRestore => 'Obnovit běžný stav';

  @override
  String get devNoOverride => 'Žádná simulace není aktivní';

  @override
  String get devApplied => 'Scénář použit i v emulátoru Firestore';

  @override
  String get devIncomplete =>
      'Neúplná simulace: emulátor Firestore testovací oprávnění nepotvrdil. Pravidla serveru tento scénář nevidí.';

  @override
  String get devNotice =>
      'Jen vývojové buildy s emulátorem: žádné platby, tokeny ani účtenky.';

  @override
  String get settingsTitle => 'Nastavení';

  @override
  String get settingsGuide => 'Znovu zobrazit průvodce';

  @override
  String get settingsShare => 'Sdílet aplikaci';

  @override
  String get settingsRate => 'Ohodnotit aplikaci';

  @override
  String get settingsFeedback => 'Poslat zpětnou vazbu';

  @override
  String get settingsFaq => 'Časté dotazy';

  @override
  String get settingsShareFailed =>
      'Sdílení se nepodařilo otevřít. Zkuste to znovu';

  @override
  String get settingsRateFailed =>
      'Google Play se nepodařilo otevřít. Zkuste to znovu';

  @override
  String get guideAddTitle => 'Přidejte víno';

  @override
  String get guideAddBody =>
      'Klepněte na Přidat a uložte láhev do sklepa. Na začátek stačí název.';

  @override
  String get guideLabelTitle => 'Přečtěte etiketu';

  @override
  String get guideLabelBody =>
      'V nabídce Přidat můžete etiketu také vyfotit: Vinoozy přečte název, ročník a označení původu a vy je před uložením zkontrolujete.';

  @override
  String get guideTabsTitle => 'Přehled, Sklep, Historie';

  @override
  String get guideTabsBody =>
      'Přehled vám řekne, která vína otevřít teď, Sklep ukazuje vaše láhve a Historie uchovává ty, které jste vypili.';

  @override
  String get guideMenuTitle => 'Nabídka sklepa';

  @override
  String get guideMenuBody =>
      'Najdete tu svůj profil, lidi, se kterými sklep sdílíte, vypitá vína a Nastavení, kde si tohoto průvodce můžete znovu zobrazit.';

  @override
  String get guideDone => 'Hotovo';

  @override
  String guideStepOf(int step, int count) {
    return 'Krok $step z $count';
  }

  @override
  String get hintDashboard =>
      'Tady vidíte, která vína jsou teď připravená k pití a která je lepší ještě nechat ležet.';

  @override
  String get hintHistory =>
      'Každá láhev, kterou vypijete, skončí tady, s vaším hodnocením a poznámkami.';

  @override
  String get hintAddWine =>
      'Začněte názvem: ročník, typ a označení původu zpřesní okno pro pití.';

  @override
  String get shareAppSubject => 'Vinoozy, váš vinný sklep';

  @override
  String shareAppMessage(String link) {
    return 'Svůj vinný sklep vedu ve Vinoozy: řekne mi, kdy je každá láhev v nejlepší kondici. Vyzkoušejte ji: $link';
  }

  @override
  String get feedbackSubject => 'Zpětná vazba k aplikaci Vinoozy';

  @override
  String get feedbackTechHeader => 'Technické údaje (nemažte):';

  @override
  String get feedbackNoEmailTitle => 'Žádná e-mailová aplikace';

  @override
  String feedbackNoEmailBody(String email) {
    return 'V tomto telefonu není žádná e-mailová aplikace. Napište nám na $email';
  }

  @override
  String get feedbackCopy => 'Kopírovat';

  @override
  String get feedbackCopied => 'Adresa zkopírována';

  @override
  String get faqAddQuestion => 'Jak ručně přidám víno?';

  @override
  String get faqAddAnswer =>
      'Ve Sklepu klepněte na Přidat a pak na Napsat. Povinný je jen název; ročník, typ, země a označení původu zlepšují odhad. Uložte a víno je ve sklepě.';

  @override
  String get faqLabelQuestion => 'Jak přečtu etiketu, i pomocí Google Lens?';

  @override
  String get faqLabelAnswer =>
      'Klepněte na Přidat a vyfoťte přední i zadní stranu: Vinoozy přečte etiketu přímo v telefonu. V Google Lens označte text a sdílejte ho do Vinoozy, nebo ho zkopírujte a ve formuláři použijte Vložit z Lens. Před uložením vždy zkontrolujte pole.';

  @override
  String get faqWindowQuestion =>
      'Jak se počítá ideální doba k pití a mohu ji změnit?';

  @override
  String get faqWindowAnswer =>
      'Vinoozy odhaduje okno (začátek, vrchol, konec) podle typu, označení původu, ročníku a úrovně vína. Je to orientační: záleží i na tom, jak byla láhev skladována. Otevřete víno a klepněte na Opravit, abyste nastavili vlastní datum, nebo změňte Úroveň.';

  @override
  String get faqOfflineQuestion => 'Funguje bez internetu?';

  @override
  String get faqOfflineAnswer =>
      'Ano. Vína můžete přidávat, upravovat i pít bez připojení: vše se uloží v telefonu a synchronizuje s vaším účtem, jakmile se připojení obnoví.';

  @override
  String get faqShareQuestion => 'Jak sdílím svůj sklep?';

  @override
  String get faqShareAnswer =>
      'V nabídce Sklepa otevřete Lidé a pozvěte někoho přes jeho e-mailovou adresu Google, jen pro čtení nebo s úpravami. Ten si nainstaluje Vinoozy a přihlásí se tímto účtem.';

  @override
  String get faqPlusQuestion => 'Co zahrnuje bezplatný tarif a co je Plus?';

  @override
  String faqPlusAnswer(int limit) {
    return 'Bezplatný tarif zahrnuje až $limit různých vín ve sklepě, s občasnými reklamami jen v Přehledu. Vinoozy Plus odstraní limit i reklamy.';
  }

  @override
  String get faqDrinkQuestion =>
      'Proč zaznamenávat, co jsem vypil a jaké to bylo?';

  @override
  String get faqDrinkAnswer =>
      'Historie uchovává, co jste vypili a jak vám to chutnalo. Když uvedete, jaká láhev byla (ještě příliš mladé, tak akorát, za vrcholem), Vinoozy opraví odhad u stejného vína.';

  @override
  String get faqDeleteQuestion => 'Jak smažu svůj účet?';

  @override
  String get faqDeleteAnswer =>
      'Otevřete Profil a klepněte na Smazat účet. Potřebujete připojení a pak se pro potvrzení znovu přihlásíte přes Google. Sklep, Historie a sdílení se smažou natrvalo.';

  @override
  String get faqNotFound => 'Nenašli jste odpověď? Napište nám';
}
