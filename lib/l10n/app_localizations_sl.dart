// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Slovenian (`sl`).
class AppLocalizationsSl extends AppLocalizations {
  AppLocalizationsSl([String locale = 'sl']) : super(locale);

  @override
  String get appTitle => 'Vinoozy';

  @override
  String get signInTagline => 'Vaša klet, ob pravem času';

  @override
  String get signInWithGoogle => 'Nadaljuj z računom Google';

  @override
  String get signInInProgress => 'Prijavljanje';

  @override
  String get signInFailed => 'Prijava ni uspela';

  @override
  String get signInNeedsNetwork => 'Za prvo prijavo je potrebna povezava';

  @override
  String get signInSessionExpired => 'Seja je potekla: znova se prijavite';

  @override
  String get retry => 'Poskusi znova';

  @override
  String get cancel => 'Prekliči';

  @override
  String blockedMessage(String email) {
    return 'Spremembe iz računa $email še niso shranjene v oblak: prijavite se s tem računom in se povežite z omrežjem';
  }

  @override
  String blockedSignInWith(String email) {
    return 'Prijava kot $email';
  }

  @override
  String blockedDiscard(String email) {
    return 'Izbriši neshranjene spremembe iz računa $email';
  }

  @override
  String get discardDialogTitle => 'Želite izbrisati spremembe?';

  @override
  String discardDialogBody(int count, String email) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count vin iz računa $email še ni v oblaku in bo izbrisanih iz tega telefona.',
      few:
          '$count vina iz računa $email še niso v oblaku in bodo izbrisana iz tega telefona.',
      two:
          '$count vini iz računa $email še nista v oblaku in bosta izbrisani iz tega telefona.',
      one:
          '$count vino iz računa $email še ni v oblaku in bo izbrisano iz tega telefona.',
    );
    return '$_temp0';
  }

  @override
  String get discardConfirm => 'Izbriši';

  @override
  String get resetFailed => 'Podatkov v tem telefonu ni bilo mogoče izbrisati';

  @override
  String get restartRequired => 'Za dokončanje znova zaženite aplikacijo';

  @override
  String get restartCloseApp => 'Zapri aplikacijo';

  @override
  String get startupFailed => 'Aplikacije ni bilo mogoče zagnati';

  @override
  String get cellarTitle => 'Klet';

  @override
  String get defaultCellarName => 'Moja klet';

  @override
  String get cellarLoading => 'Priprava kleti';

  @override
  String get cellarSetupFailed => 'Kleti ni bilo mogoče pripraviti';

  @override
  String get cellarEmpty => 'Vaša klet je prazna';

  @override
  String get addWine => 'Dodaj';

  @override
  String get estimatePending => 'Napoved prihaja';

  @override
  String get noVintage => 'Brez letnika';

  @override
  String bottleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steklenic',
      few: '$count steklenice',
      two: '$count steklenici',
      one: '$count steklenica',
    );
    return '$_temp0';
  }

  @override
  String get syncInProgress => 'Sinhronizacija';

  @override
  String get syncOffline => 'Brez povezave - sinhronizacija čaka';

  @override
  String writeRejected(String name) {
    return 'Sprememba ni dovoljena: $name';
  }

  @override
  String get saveFailed => 'Shranjevanje ni uspelo, poskusite znova';

  @override
  String wineNotSaved(String name) {
    return 'Vino $name ni bilo shranjeno v oblak';
  }

  @override
  String get addAgain => 'Dodaj znova';

  @override
  String get ignore => 'Prezri';

  @override
  String get addWineTitle => 'Vpiši';

  @override
  String get wineNameLabel => 'Vino';

  @override
  String get vintageLabel => 'Letnik';

  @override
  String get quantityLabel => 'Količina';

  @override
  String get decreaseQuantity => 'Zmanjšaj količino';

  @override
  String get increaseQuantity => 'Povečaj količino';

  @override
  String get save => 'Shrani';

  @override
  String get nameRequired => 'Vpišite ime vina';

  @override
  String get nameTooLong => 'Največ 120 znakov';

  @override
  String vintageRange(String year) {
    return 'Letnik med 1900 in $year';
  }

  @override
  String get offAttribution => 'Podatki iz Open Food Facts (ODbL)';

  @override
  String get dashboardTitle => 'Pregled';

  @override
  String dashboardTotalBottles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steklenic v kleti',
      few: '$count steklenice v kleti',
      two: '$count steklenici v kleti',
      one: '$count steklenica v kleti',
    );
    return '$_temp0';
  }

  @override
  String get dashboardSyncing => 'Sinhronizacija kleti…';

  @override
  String get dashboardAddFirstWine => 'Dodaj prvo vino';

  @override
  String get drinkSoonTitle => 'Popiti kmalu';

  @override
  String get drinkSoonEmpty =>
      'Ni steklenic, ki bi jih bilo treba kmalu popiti';

  @override
  String drinkSoonUntil(String year) {
    return 'do $year';
  }

  @override
  String drinkSoonSeeAll(int count) {
    return 'Prikaži vse ($count)';
  }

  @override
  String get statusChartTitle => 'Stanje steklenic';

  @override
  String get statusWaiting => 'počakati';

  @override
  String get statusReady => 'pripravljene';

  @override
  String get statusDrinkSoon => 'popiti kmalu';

  @override
  String get statusPastWindow => 'po oknu pitnosti';

  @override
  String toEstimateNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steklenic za napoved',
      few: '$count steklenice za napoved',
      two: '$count steklenici za napoved',
      one: '$count steklenica za napoved',
    );
    return '$_temp0';
  }

  @override
  String chartBarValue(String label, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count steklenic',
      few: '$count steklenice',
      two: '$count steklenici',
      one: '$count steklenica',
    );
    return '$label: $_temp0';
  }

  @override
  String chartDescription(String title, String values) {
    return '$title: $values';
  }

  @override
  String get openListHint => 'Odpri seznam';

  @override
  String get peakChartTitle => 'Leto vrhunca';

  @override
  String get peakPast => 'po vrhuncu';

  @override
  String get peakBeyond => 'pozneje';

  @override
  String get breakdownTypeTitle => 'Steklenice po vrsti';

  @override
  String get breakdownRegionTitle => 'Steklenice po regiji';

  @override
  String get breakdownType => 'Vrsta';

  @override
  String get breakdownRegion => 'Regija';

  @override
  String get familyRed => 'rdeče';

  @override
  String get familyWhite => 'belo';

  @override
  String get familyRose => 'rosé';

  @override
  String get familySparkling => 'peneče';

  @override
  String get familySweet => 'sladko';

  @override
  String get breakdownUnspecified => 'ni navedeno';

  @override
  String get breakdownOtherRegions => 'druge';

  @override
  String get ok => 'V redu';

  @override
  String get cellarMenu => 'Meni kleti';

  @override
  String get sharingPeopleTitle => 'Osebe';

  @override
  String get sharingInviteTitle => 'Povabi osebo';

  @override
  String get sharingEmailLabel => 'E-poštni naslov Google';

  @override
  String get sharingPermissionRead => 'Samo branje';

  @override
  String get sharingPermissionReadHint =>
      'Vidi vina, napovedi, pregled in popite steklenice';

  @override
  String get sharingPermissionEdit => 'Lahko ureja';

  @override
  String get sharingPermissionEditHint =>
      'Tudi dodaja in spreminja vina ter beleži popite steklenice';

  @override
  String get sharingRoleOwner => 'lastnik';

  @override
  String get sharingInviteButton => 'Povabi';

  @override
  String sharingPlacesUsed(int used, int max) {
    return 'Osebe: $used/$max';
  }

  @override
  String get sharingInvalidEmail => 'Vnesite veljaven e-poštni naslov';

  @override
  String get sharingSelfInvite => 'Sebe ne morete povabiti';

  @override
  String get sharingAlreadyInvited => 'Ta oseba je že povabljena';

  @override
  String sharingLimitReached(int max) {
    return 'Dosežena je omejitev števila oseb: $max';
  }

  @override
  String get sharingNotOwner => 'Deljenja te kleti ne morete spreminjati';

  @override
  String get sharingNotFound => 'Te osebe ni več na seznamu';

  @override
  String get sharingFailed => 'Ni uspelo, poskusite znova';

  @override
  String get sharingInviteFailed => 'Povabilo ni uspelo. Poskusite znova';

  @override
  String get sharingOfflineHint =>
      'Za upravljanje deljenja je potrebna povezava';

  @override
  String get sharingStatusInvited => 'povabljena';

  @override
  String get sharingStatusActive => 'aktivna';

  @override
  String get sharingStatusRevoked => 'dostop odvzet';

  @override
  String get sharingStatusLeft => 'zapustila klet';

  @override
  String sharingMemberSemantics(String name, String permission, String status) {
    return '$name, $permission, $status';
  }

  @override
  String get sharingClosedSection => 'Zaprti dostopi';

  @override
  String get sharingNobody => 'Te kleti še ne vidi nihče drug';

  @override
  String sharingChangePermission(String name) {
    return 'Spremeni dovoljenje: $name';
  }

  @override
  String get sharingRevoke => 'Odvzemi';

  @override
  String sharingRevokeTitle(String name) {
    return 'Želite odvzeti dostop uporabniku $name?';
  }

  @override
  String sharingRevokeConfirmLabel(String name) {
    return 'Za potrditev vpišite $name';
  }

  @override
  String get sharingRevokeDisabledHint => 'Omogočeno, ko se ime ujema';

  @override
  String get sharingReinvite => 'Povabi znova';

  @override
  String get sharingDeleteForGood => 'Trajno izbriši';

  @override
  String sharingOwnedBy(String owner) {
    return 'Klet: $owner';
  }

  @override
  String get sharingYourCellar => 'Vaša klet';

  @override
  String sharingYourPermission(String permission) {
    return 'Vaše dovoljenje: $permission';
  }

  @override
  String sharingSwitcherSemantics(String cellar, String permission) {
    return '$cellar, $permission. Dotaknite se za menjavo kleti';
  }

  @override
  String get sharingLeave => 'Zapusti to klet';

  @override
  String sharingLeaveTitle(String owner) {
    return 'Želite zapustiti klet, katere lastnik je $owner?';
  }

  @override
  String sharingLeaveBody(String owner) {
    return 'Ne boste je več videli. $owner vas lahko znova povabi.';
  }

  @override
  String get sharingLeaveConfirm => 'Zapusti';

  @override
  String sharingSharedNotice(String owner) {
    return '$owner deli svojo klet z vami';
  }

  @override
  String sharingAccessLost(String owner) {
    return 'Nimate več dostopa do kleti, katere lastnik je $owner';
  }

  @override
  String sharingWritesLost(String owner) {
    return 'Nekatere spremembe v kleti, katere lastnik je $owner, niso bile shranjene, ker nimate več dostopa';
  }

  @override
  String get sharingSomeone => 'nekdo';

  @override
  String get sharingShareSubject => 'Povabilo v Vinoozy';

  @override
  String sharingShareMessage(
    String owner,
    String cellar,
    String link,
    String email,
  ) {
    return '$owner vas vabi v klet „$cellar“ v aplikaciji Vinoozy. Namestite aplikacijo s $link in se prijavite z računom Google $email: uporabite natanko ta naslov.';
  }

  @override
  String get cellarSearchHint => 'Išči po imenu ali pridelovalcu';

  @override
  String get cellarFilterStatus => 'Stanje';

  @override
  String get cellarFilterType => 'Vrsta';

  @override
  String get statusToEstimate => 'Za napoved';

  @override
  String get filterTypeUnspecified => 'Ni navedeno';

  @override
  String get cellarNoMatches => 'Ni vin s temi filtri';

  @override
  String get cellarClearFilters => 'Počisti filtre';

  @override
  String get cellarArchiveTitle => 'Popito';

  @override
  String get cellarArchiveEmpty => 'Ni še dokončanih vin';

  @override
  String get cellarArchiveFailed => 'Dokončanih vin ni bilo mogoče naložiti';

  @override
  String get wineDrink => 'Popito';

  @override
  String wineDrinkTooltip(String name) {
    return 'Označi kot popito steklenico vina $name';
  }

  @override
  String confidenceLabel(String level) {
    return 'Zanesljivost: $level';
  }

  @override
  String get confidenceHigh => 'visoka';

  @override
  String get confidenceMedium => 'srednja';

  @override
  String get confidenceLow => 'nizka';

  @override
  String get windowStartLabel => 'Začetek';

  @override
  String get windowPeakLabel => 'Vrhunec';

  @override
  String get windowEndLabel => 'Konec';

  @override
  String estimateSourceLabel(String source) {
    return 'Vir: $source';
  }

  @override
  String get estimateSourceCatalog => 'zbirka vin';

  @override
  String get estimateSourceType => 'napoved za vrsto';

  @override
  String get estimateSourceCorrected =>
      'napoved, popravljena glede na popite steklenice';

  @override
  String get estimateDisclaimer =>
      'Okvirna napoved: odvisna je tudi od tega, kako je bila steklenica hranjena';

  @override
  String get estimateUnavailable => 'Napoved ni na voljo';

  @override
  String get pairingsTitle => 'Ujemanje s hrano';

  @override
  String get pairingsGeneric => 'splošno ujemanje za vrsto';

  @override
  String get pairingBraisedRedMeat => 'Dušeno rdeče meso';

  @override
  String get pairingGrilledRedMeat => 'Rdeče meso z žara';

  @override
  String get pairingGame => 'Divjačina';

  @override
  String get pairingRoastPoultry => 'Pečena perutnina';

  @override
  String get pairingPoultry => 'Perutnina';

  @override
  String get pairingPork => 'Svinjina';

  @override
  String get pairingCuredMeats => 'Suhomesni izdelki';

  @override
  String get pairingPastaMeatSauce => 'Testenine z mesno omako';

  @override
  String get pairingMushroomsTruffle => 'Gobe in tartufi';

  @override
  String get pairingAgedCheese => 'Zorjeni siri';

  @override
  String get pairingFreshCheese => 'Sveži siri';

  @override
  String get pairingBlueCheese => 'Siri z modro plesnijo';

  @override
  String get pairingFish => 'Ribe';

  @override
  String get pairingSeafood => 'Morski sadeži';

  @override
  String get pairingRawSeafood => 'Surovi morski sadeži';

  @override
  String get pairingFriedFood => 'Ocvrte jedi';

  @override
  String get pairingVegetables => 'Zelenjava';

  @override
  String get pairingRisotto => 'Rižota';

  @override
  String get pairingPizza => 'Pica';

  @override
  String get pairingAperitif => 'Aperitiv';

  @override
  String get pairingPastries => 'Slaščice';

  @override
  String get pairingDryBiscuits => 'Suhi piškoti';

  @override
  String get pairingChocolate => 'Čokolada';

  @override
  String get pairingDriedFruit => 'Oreščki in suho sadje';

  @override
  String get pairingSpicyDishes => 'Pikantne jedi';

  @override
  String get recentDrinksTitle => 'Nazadnje popito';

  @override
  String get noDrinksYet => 'Nič še ni popito';

  @override
  String get wineEdit => 'Uredi';

  @override
  String get wineDelete => 'Izbriši';

  @override
  String get wineFinished => 'Dokončano: ni več steklenic';

  @override
  String get wineLoadFailed => 'Vina ni bilo mogoče odpreti';

  @override
  String get wineNotFound => 'To vino ne obstaja več';

  @override
  String drinkDone(String name) {
    return 'Označeno kot popito: $name';
  }

  @override
  String get drinkUndo => 'Razveljavi';

  @override
  String get drinkAddNotes => 'Dodaj oceno in opombe';

  @override
  String get nothingToUndo => 'Ni več česa razveljaviti';

  @override
  String get cellarUndoRejected =>
      'Razveljavitev ni uspela: steklenica ostane označena kot popita';

  @override
  String get cellarDeleteFailed =>
      'Brisanje še ni končano: dokončalo se bo takoj, ko bo mogoče';

  @override
  String get duplicateFull =>
      'To vino ima že 99 steklenic: več jih ni mogoče dodati.';

  @override
  String get recordSheetTitle => 'Ocena in opombe';

  @override
  String get recordRatingLabel => 'Ocena';

  @override
  String ratingStar(int n) {
    return 'Ocena $n od 5';
  }

  @override
  String get recordNotesLabel => 'Opombe';

  @override
  String get recordNotesTooLong => 'Največ 1000 znakov';

  @override
  String recordDateLabel(String date) {
    return 'Datum: $date';
  }

  @override
  String get recordDateInvalid =>
      'Datum ne sme biti v prihodnosti ali pred letnikom';

  @override
  String get recordConditionTitle => 'Kakšno je bilo?';

  @override
  String get conditionTooYoung => 'Še premlado';

  @override
  String get conditionJustRight => 'Ravno prav';

  @override
  String get conditionPastPeak => 'Čez vrhunec';

  @override
  String get recordNoCondition => 'Brez odgovora';

  @override
  String get producerLabel => 'Pridelovalec (neobvezno)';

  @override
  String get producerTooLong => 'Največ 120 znakov';

  @override
  String producerAddNew(String name) {
    return 'Dodaj novega pridelovalca: „$name“';
  }

  @override
  String get wineTypeLabel => 'Vrsta';

  @override
  String get typeRedLight => 'Lahko rdeče';

  @override
  String get typeRedStructured => 'Rdeče polnega telesa';

  @override
  String get typeWhite => 'Belo';

  @override
  String get typeRose => 'Rosé';

  @override
  String get typeSparklingClassic => 'Peneče po klasični metodi';

  @override
  String get typeSparklingTank => 'Peneče po metodi Charmat';

  @override
  String get typeSweet => 'Sladko';

  @override
  String get typeFortified => 'Likersko';

  @override
  String get suggestionFromCellar => 'V vaši kleti';

  @override
  String get suggestionsLabel => 'Predlogi';

  @override
  String get duplicateTitle => 'Že v kleti';

  @override
  String duplicateBody(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ima $count steklenic',
      few: 'ima $count steklenice',
      two: 'ima $count steklenici',
      one: 'ima $count steklenico',
      zero: 'nima nobene steklenice',
    );
    return '$name: to vino je že v kleti, $_temp0. Mu želite dodati nove steklenice?';
  }

  @override
  String duplicateAdd(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dodaj $count steklenic',
      few: 'Dodaj $count steklenice',
      two: 'Dodaj $count steklenici',
      one: 'Dodaj $count steklenico',
    );
    return '$_temp0';
  }

  @override
  String get duplicateBanner => 'Možen dvojnik';

  @override
  String get duplicateMerge => 'Združi';

  @override
  String get duplicateDeleteHint => 'Če je dvojnik, ta vnos izbrišite';

  @override
  String get mergeTitle => 'Želite združiti vnosa?';

  @override
  String get mergeBody =>
      'Steklenice iz tega vnosa se prenesejo v starejšega, nato se ta vnos izbriše.';

  @override
  String get editWineTitle => 'Uredi vino';

  @override
  String get editDuplicate =>
      'Drugo vino z istim imenom, pridelovalcem in letnikom že obstaja';

  @override
  String deleteWineTitle(String name) {
    return 'Želite izbrisati vino $name?';
  }

  @override
  String get deleteWineBody =>
      'Vino in vsi zapisi o popitih steklenicah bodo izbrisani. Tega ni mogoče razveljaviti.';

  @override
  String get historyTitle => 'Zgodovina';

  @override
  String get historyEmpty => 'Tukaj boste našli popite steklenice';

  @override
  String get historyLoadFailed => 'Zgodovine ni bilo mogoče naložiti';

  @override
  String drankOnLabel(String date) {
    return 'Popito: $date';
  }

  @override
  String get addChoiceTitle => 'Dodaj vino';

  @override
  String get addChoicePhoto => 'Fotografiraj';

  @override
  String get addChoiceImport => 'Uvozi fotografijo';

  @override
  String get addChoiceWrite => 'Vpiši';

  @override
  String get labelReading => 'Berem etiketo…';

  @override
  String get labelRecognized => 'Prepoznano:';

  @override
  String get labelCorrect => 'Popravi';

  @override
  String get labelConfirm => 'Potrdi';

  @override
  String get labelUnreadable => 'Etikete ne morem prebrati';

  @override
  String get labelWriteByHand => 'Vpiši ročno';

  @override
  String get labelNotFound => 'Vina ni bilo mogoče najti: preverite podatke';

  @override
  String get labelCameraDenied =>
      'Za branje etikete je potreben dostop do fotoaparata';

  @override
  String get labelPhotosDenied =>
      'Za branje etikete je potreben dostop do fotografij';

  @override
  String get labelOpenSettings => 'Odpri nastavitve';

  @override
  String get labelCameraUnavailable => 'Fotoaparat ni na voljo';

  @override
  String get labelBarcodeNotFound =>
      'Črtna koda je prebrana, vendar vina ni mogoče najti';

  @override
  String get labelBarcodeFrontHint => 'Fotografirajte sprednjo etiketo';

  @override
  String get labelSharedNotAllowed => 'V to klet ne morete dodajati vin';

  @override
  String get labelSharedFirstOnly => 'Uporabljena je samo prva fotografija';

  @override
  String get labelSharedExpired =>
      'Deljene fotografije ni bilo mogoče prebrati: delite jo znova';

  @override
  String get labelReplaceTitle =>
      'Imate neshranjeno vino. Želite prebrati novo fotografijo?';

  @override
  String get labelReplaceRead => 'Preberi novo fotografijo';

  @override
  String get labelReplaceKeep => 'Nadaljuj z odprtim';

  @override
  String get labelWineAdded => 'Vino je dodano v klet';

  @override
  String get onboardingPage1Title => 'Vaša klet v žepu';

  @override
  String get onboardingPage1Body =>
      'Dodajajte steklenice z vpisom ali s fotografijo etikete, tudi brez omrežja.';

  @override
  String get onboardingPage2Title => 'Ob pravem času';

  @override
  String get onboardingPage2Body =>
      'Vinoozy napove, kdaj je vsako vino najboljše, in vam pove, katera odpreti najprej.';

  @override
  String get onboardingPage3Title => 'Skupaj';

  @override
  String get onboardingPage3Body =>
      'Delite klet z največ dvema osebama in hranite zgodovino vsake popite steklenice.';

  @override
  String get onboardingSkip => 'Preskoči';

  @override
  String get onboardingNext => 'Naprej';

  @override
  String get onboardingStart => 'Začni';

  @override
  String onboardingPageOf(int page) {
    return 'Stran $page od 3';
  }

  @override
  String get profileTitle => 'Profil';

  @override
  String get profilePhoto => 'Profilna fotografija';

  @override
  String get profileSignOut => 'Odjava';

  @override
  String get profileDeleteAccount => 'Izbriši račun';

  @override
  String get profilePrivacy => 'Pravilnik o zasebnosti';

  @override
  String get profilePrivacyBody =>
      'Pravilnik o zasebnosti lahko preberete na tem naslovu:';

  @override
  String get profileOpenLink => 'Odpri v brskalniku';

  @override
  String get profileOpenLinkFailed =>
      'Strani ni bilo mogoče odpreti. Povezavo lahko kopirate in jo odprete v brskalniku.';

  @override
  String get profileCopyLink => 'Kopiraj povezavo';

  @override
  String get profileLinkCopied => 'Povezava je kopirana';

  @override
  String get close => 'Zapri';

  @override
  String get signOutConfirmTitle => 'Se želite odjaviti?';

  @override
  String signOutPendingWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Imate $count še neshranjenih sprememb. Če se odjavite in se prijavi drug račun, bodo izgubljene.',
      few:
          'Imate $count še neshranjene spremembe. Če se odjavite in se prijavi drug račun, bodo izgubljene.',
      two:
          'Imate $count še neshranjeni spremembi. Če se odjavite in se prijavi drug račun, bosta izgubljeni.',
      one:
          'Imate $count še neshranjeno spremembo. Če se odjavite in se prijavi drug račun, bo izgubljena.',
    );
    return '$_temp0';
  }

  @override
  String get signOutStayAndSync => 'Ostani in sinhroniziraj';

  @override
  String get signOutAnyway => 'Vseeno se odjavi';

  @override
  String get syncAllSaved => 'Vse je shranjeno';

  @override
  String syncStillPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sprememb še čaka na shranjevanje: preverite omrežje',
      few: '$count spremembe še čakajo na shranjevanje: preverite omrežje',
      two: '$count spremembi še čakata na shranjevanje: preverite omrežje',
      one: '$count sprememba še čaka na shranjevanje: preverite omrežje',
    );
    return '$_temp0';
  }

  @override
  String get signOutFailed => 'Odjava ni uspela. Poskusite znova';

  @override
  String get signInAccountDeleted => 'Račun je izbrisan';

  @override
  String get deleteAccountIntro => 'Za vedno se izbriše:';

  @override
  String get deleteAccountItemCellar => 'Vaša klet z vini in Zgodovino';

  @override
  String get deleteAccountItemShares =>
      'Deljenja, ki ste jih odobrili: povabljene osebe izgubijo dostop';

  @override
  String get deleteAccountItemMemberships =>
      'Vaše sodelovanje v kleteh drugih: zapisi o steklenicah, ki ste jih popili, ostanejo tam brez vašega imena';

  @override
  String get deleteAccountItemProfile => 'Vaš profil';

  @override
  String deleteAccountPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Imate $count še neshranjenih sprememb: shranjene bodo in nato izbrisane z vsem drugim',
      few:
          'Imate $count še neshranjene spremembe: shranjene bodo in nato izbrisane z vsem drugim',
      two:
          'Imate $count še neshranjeni spremembi: shranjeni bosta in nato izbrisani z vsem drugim',
      one:
          'Imate $count še neshranjeno spremembo: shranjena bo in nato izbrisana z vsem drugim',
    );
    return '$_temp0';
  }

  @override
  String get deleteAccountConfirmWord => 'IZBRIŠI';

  @override
  String deleteAccountTypeWord(String word) {
    return 'Za potrditev vpišite $word';
  }

  @override
  String get deleteAccountReauthHint =>
      'Nato se boste znova prijavili z računom Google in potrdili, da ste to vi.';

  @override
  String get deleteAccountForever => 'Izbriši za vedno';

  @override
  String get deleteAccountNeedsNetwork =>
      'Za izbris računa se povežite z internetom';

  @override
  String get deleteAccountSameAccount =>
      'Izbris zahteva prijavo z istim računom';

  @override
  String get deletionTitle => 'Brisanje računa';

  @override
  String get deletionStepPreparePhone => 'Shranjevanje čakajočih sprememb';

  @override
  String get deletionStepMarkStarted => 'Začetek brisanja';

  @override
  String get deletionStepLeaveOtherCellars => 'Zapuščanje kleti drugih';

  @override
  String get deletionStepCloseOwnInvitations => 'Zapiranje vaših deljenj';

  @override
  String get deletionStepDeleteWinesAndRecords => 'Brisanje vin in Zgodovine';

  @override
  String get deletionStepDeleteCellar => 'Brisanje kleti';

  @override
  String get deletionStepDeleteProfileAndUser => 'Brisanje profila in računa';

  @override
  String get deletionStepCleanUpPhone => 'Čiščenje tega telefona';

  @override
  String deletionStepAnnounce(int step, String label) {
    return 'Korak $step od 8: $label';
  }

  @override
  String deletionDeletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Izbrisano: $count vin ali zapisov',
      few: 'Izbrisano: $count vina ali zapisi',
      two: 'Izbrisano: $count vini ali zapisa',
      one: 'Izbrisano: $count vino ali zapis',
    );
    return '$_temp0';
  }

  @override
  String get deletionResumeHint =>
      'Brisanje tega računa ni dokončano. Znova se prijavite z računom Google, da ga dokončate.';

  @override
  String get deletionContinue => 'Nadaljuj';

  @override
  String get deletionOffline =>
      'Za dokončanje brisanja se povežite z internetom';

  @override
  String get deletionPendingWrites =>
      'Čakajočih sprememb ne morem shraniti. Poskusite znova';

  @override
  String get deletionFailed =>
      'Brisanja ni bilo mogoče dokončati. Poskusite znova';

  @override
  String get uxCountryLabel => 'Država';

  @override
  String get uxCountryOther => 'Druga država…';

  @override
  String get uxCountryNone => 'Brez države';

  @override
  String get uxAllCountriesTitle => 'Vse države in ozemlja';

  @override
  String get uxAllCountriesSearch => 'Išči državo';

  @override
  String get uxAllCountriesRare => 'Redke za vino';

  @override
  String get uxAllCountriesAll => 'Vse, od A do Ž';

  @override
  String get uxAllCountriesNone => 'Ni najdene države';

  @override
  String get uxRegionLabel => 'Regija';

  @override
  String uxRegionOf(String country) {
    return 'Regija · $country';
  }

  @override
  String get uxRegionOther => 'Druga regija';

  @override
  String get uxRegionFieldLabel => 'Vpišite regijo';

  @override
  String get uxRegionTooLong => 'Največ 120 znakov';

  @override
  String get uxDrinkAction => 'Popito';

  @override
  String uxDrinkActionTooltip(String name) {
    return 'Popita steklenica vina $name';
  }

  @override
  String get uxDrinkActionDetail => 'Popita steklenica';

  @override
  String get uxDrinkSheetLabel => 'Potrditev popite steklenice';

  @override
  String get uxDrinkSheetBottles => 'Steklenice';

  @override
  String uxDrinkSheetBottlesChange(int before, int after) {
    return 'Steklenice: z $before na $after';
  }

  @override
  String get uxDrinkSheetRating => 'Kakšno je bilo? (neobvezno)';

  @override
  String uxDrinkSheetStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count zvezdic od 5',
      few: '$count zvezdice od 5',
      two: '$count zvezdici od 5',
      one: '$count zvezdica od 5',
    );
    return '$_temp0';
  }

  @override
  String get uxDrinkSheetConfirm => 'Da, popita je';

  @override
  String get uxRemoveBottle => 'Odstrani steklenico brez zapisa o pitju';

  @override
  String get uxRemoveBottleTitle => 'Želite odstraniti steklenico?';

  @override
  String uxRemoveBottleBody(String name) {
    return 'Ena steklenica vina $name se odstrani brez zapisa o pitju.';
  }

  @override
  String get uxRemoveBottleConfirm => 'Odstrani';

  @override
  String get uxIdealTitle => 'Idealen trenutek';

  @override
  String uxIdealUntil(String year) {
    return 'Priporočeno do $year';
  }

  @override
  String uxIdealUntilPast(String year) {
    return 'Priporočeno do $year: rok je minil';
  }

  @override
  String uxIdealBest(String start, String end) {
    return 'Najboljše od $start do $end';
  }

  @override
  String uxIdealBar(String start, String end) {
    return 'Okno pitnosti od $start do $end';
  }

  @override
  String get uxIdealDisclaimer =>
      '⚠︎ Okvirno: napoved na podlagi vrste, apelacije in letnika. Hramba in posamezna steklenica jo lahko spremenita.';

  @override
  String get uxIdealUnavailableHint => 'Za napoved dodajte letnik in vrsto.';

  @override
  String uxDashboardDrinkNow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count za pitje zdaj',
      few: '$count za pitje zdaj',
      two: '$count za pitje zdaj',
      one: '$count za pitje zdaj',
    );
    return '$_temp0';
  }

  @override
  String get uxFamilyRed => 'Rdeče';

  @override
  String get uxFamilyWhite => 'Belo';

  @override
  String get uxFamilyRose => 'Rosé';

  @override
  String get uxFamilySparkling => 'Peneče';

  @override
  String get uxFamilySweet => 'Sladko';

  @override
  String get labelBackTitle => 'Zdaj še zadnja stran';

  @override
  String get labelBackHint =>
      'Na zadnji etiketi so običajno črtna koda, pridelovalec in letnik: pomagajo najti vino.';

  @override
  String get labelBackTake => 'Fotografiraj zadnjo stran';

  @override
  String get labelBackGallery => 'Izberi iz galerije';

  @override
  String get labelBackSkip => 'Preskoči';

  @override
  String get labelStepFront => 'Sprednja stran';

  @override
  String get labelStepBack => 'Zadnja stran';

  @override
  String get labelStepBarcode => 'Črtna koda';

  @override
  String get labelStepDatabase => 'Zbirka vin v telefonu';

  @override
  String get labelStepPending => 'Čaka';

  @override
  String get labelStepRunning => 'Poteka…';

  @override
  String get labelStepDone => 'Končano';

  @override
  String get labelStepSkipped => 'Preskočeno';

  @override
  String get labelStepFailed => 'Ni berljivo';

  @override
  String labelStepStatus(String step, String status) {
    return '$step: $status';
  }

  @override
  String get labelOnPhoneNote =>
      'Vse poteka v telefonu: fotografije se ne pošiljajo nikomur.';

  @override
  String get labelBackUnreadable => 'Zadnja stran ni berljiva';

  @override
  String get labelSourceOffline => 'Iz zbirke v telefonu · offline';

  @override
  String get labelSourceCatalog => 'Iz kataloga';

  @override
  String get labelSourceOnline => 'Iz Open Food Facts · online';

  @override
  String get labelNotThis => 'Ni to';

  @override
  String get labelOffAttribution => 'Podatki iz Open Food Facts, licenca ODbL';

  @override
  String get labelCandidatesTitle => 'Katero od teh?';

  @override
  String labelCandidatesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count podobnih vin',
      few: '$count podobna vina',
      two: '$count podobni vini',
      one: '$count podobno vino',
    );
    return '$_temp0';
  }

  @override
  String get labelCandidatesNone => 'Nobeno od teh';

  @override
  String get labelChipOffline => 'offline';

  @override
  String get labelChipOnline => 'online';

  @override
  String get labelChipCatalog => 'katalog';

  @override
  String get labelNoProducer => 'pridelovalec ni naveden';

  @override
  String get labelNoMatch => 'Etiketa je prebrana, vendar vina ne prepoznam';

  @override
  String get labelReadText => 'Prebrano besedilo';

  @override
  String get labelSearchOnline => 'Išči na spletu';

  @override
  String get labelOpenLens => 'Odpri v Google Lens';

  @override
  String get labelLensLastResort =>
      'Google Lens je zadnja možnost: fotografija gre v Googlovo aplikacijo samo, če potrdite.';

  @override
  String get labelLensTitle => 'Želite odpreti v Google Lens?';

  @override
  String get labelLensBody =>
      'Fotografija sprednje etikete gre v Googlovo aplikacijo v vašem telefonu ali v aplikacijo, ki jo izberete; ta lahko po lastnih pravilih obdrži kopijo. Vinoozy ne prejme rezultatov: vrnite se sem in izberite ali vpišite vino.';

  @override
  String get labelLensConfirm => 'Odpri Google Lens';

  @override
  String get labelLensFailed =>
      'Ne morem odpreti Google Lens niti menija za deljenje';

  @override
  String get onlineSearchTitle => 'Išči na spletu';

  @override
  String get onlineSearchSubtitle => 'Open Food Facts · samo vina';

  @override
  String get onlineSearchField => 'Iskane besede';

  @override
  String get onlineSearchHint => 'Besede lahko pred iskanjem spremenite.';

  @override
  String get onlineSearchEmptyField => 'Vpišite vsaj eno besedo';

  @override
  String get onlineSearchButton => 'Išči';

  @override
  String get onlineSearchLoading => 'Iščem…';

  @override
  String onlineSearchResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rezultatov',
      few: '$count rezultati',
      two: '$count rezultata',
      one: '$count rezultat',
    );
    return '$_temp0';
  }

  @override
  String get onlineSearchEmpty =>
      'Ni najdenih vin: poskusite z drugimi besedami ali izberite „Vpiši ročno“.';

  @override
  String get onlineSearchOffline =>
      'Ni omrežja: iščem samo v zbirki v telefonu.';

  @override
  String get onlineSearchRateLimited =>
      'Iskanje na spletu zdaj ni na voljo, poskusite znova čez nekaj minut.';

  @override
  String get onlineSearchUnavailable =>
      'Iskanje na spletu v tej različici aplikacije ni aktivno: iščem samo v zbirki v telefonu.';

  @override
  String get aboutTitle => 'O aplikaciji';

  @override
  String aboutVersion(String version) {
    return 'Različica $version';
  }

  @override
  String get aboutDbTitle => 'Zbirka vin';

  @override
  String aboutDbCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vin',
      few: '$count vina',
      two: '$count vini',
      one: '$count vino',
    );
    return '$_temp0';
  }

  @override
  String aboutDbDate(String date) {
    return 'Izvoz Open Food Facts z dne $date';
  }

  @override
  String get aboutDbSample =>
      'Vzorčna zbirka: nekaj ročno vpisanih preizkusnih vin, ne podatki Open Food Facts.';

  @override
  String get aboutDbLoading => 'Odpiram zbirko vin…';

  @override
  String get aboutDbUnavailable => 'Zbirka vin v tej različici ni na voljo';

  @override
  String aboutDbSource(String url) {
    return 'Izpeljana zbirka in orodje, ki jo ustvari, sta v javnem repozitoriju: $url';
  }

  @override
  String get aboutLicenseTitle => 'Licence';

  @override
  String get aboutLicense =>
      'Vsebuje informacije iz Open Food Facts, ki so na voljo pod licenco Open Database License (ODbL). Posamezne vsebine so pod licenco Database Contents License (DbCL).';

  @override
  String get aboutPrivacyTitle => 'Fotografije etiket';

  @override
  String get aboutPrivacy =>
      'Fotografije etiket se preberejo v telefonu in izbrišejo, ko zapustite rezultat. Telefon zapustijo samo, če se dotaknete „Odpri v Google Lens“ in potrdite.';

  @override
  String get aboutAppellationsTitle => 'Apelacije';

  @override
  String get aboutAppellationsSource =>
      'Apelacije: register eAmbrosia (EU) in uradni nacionalni registri.';

  @override
  String get aboutAppellationsSample =>
      'Vzorčna tabela: ročno prepisan izvleček iz registrov, dokler se ne prenesejo pravi registri.';

  @override
  String get denominationLabel => 'Apelacija';

  @override
  String get denominationTooLong => 'Največ 120 znakov';

  @override
  String get autofillFilledNotice =>
      'Izpolnjeno z etikete: preverite in shranite';

  @override
  String get autofillPastedNotice =>
      'Izpolnjeno iz besedila: preverite in shranite';

  @override
  String get autofillFromText => '✦ iz besedila';

  @override
  String get autofillFromTextSemantics => 'izpolnjeno z etikete';

  @override
  String get autofillClear => 'Počisti';

  @override
  String get autofillLens => 'Lens';

  @override
  String get autofillClearTitle => 'Želite počistiti obrazec?';

  @override
  String get autofillClearBody =>
      'Nekatera polja so izpolnjena tudi ročno. „Počisti“ izprazni ime, pridelovalca, apelacijo, letnik, vrsto, državo, regijo in raven. Količina ostane.';

  @override
  String get autofillClearConfirm => 'Počisti';

  @override
  String get autofillCleared => 'Obrazec je počiščen';

  @override
  String get autofillPasteTitle => 'Imate besedilo iz aplikacije Google Lens?';

  @override
  String get autofillPasteHint =>
      'V Lensu označite besedilo etikete in se dotaknite „Kopiraj“, nato se vrnite sem.';

  @override
  String get autofillPaste => 'Prilepi iz Lensa';

  @override
  String get autofillOpenLens => 'Iz Google Lens';

  @override
  String get autofillOpenLensSemantics => 'odpre Google Lens';

  @override
  String get autofillClipboardEmpty => 'V odložišču ni besedila';

  @override
  String get autofillNoNewFields => 'V besedilu ni podatkov za dodajanje';

  @override
  String get autofillFromLens => 'Obrazec je izpolnjen z besedilom iz Lensa';

  @override
  String get autofillShareEmpty => 'Besedilo ni bilo prejeto';

  @override
  String get autofillShareUseTitle =>
      'Želite besedilo uporabiti za prazna polja?';

  @override
  String get autofillShareUse => 'Uporabi';

  @override
  String get autofillShareIgnore => 'Prezri';

  @override
  String get addChoiceLens => 'Iz Google Lens';

  @override
  String get addChoicePhotoHint =>
      'Sprednja in zadnja stran: Vinoozy prebere etiketo.';

  @override
  String get addChoiceLensHint =>
      'Odpre Lens: zajemite etiketo, označite besedilo in se dotaknite Deli → Vinoozy.';

  @override
  String get addChoiceImportHint => 'Fotografija etikete, ki jo že imate.';

  @override
  String get addChoiceWriteHint =>
      'Prazen obrazec z možnostjo „Prilepi iz Lensa“.';

  @override
  String get lensInstructionsTitle => 'Google Lens od tukaj ni mogoče odpreti';

  @override
  String get lensInstructionsStep1 => 'Odprite Google Lens in zajemite etiketo';

  @override
  String get lensInstructionsStep2 => 'Označite besedilo etikete';

  @override
  String get lensInstructionsStep3 => 'Dotaknite se Deli → Vinoozy';

  @override
  String get lensInstructionsOk => 'Razumem';

  @override
  String get levelLabel => 'Raven';

  @override
  String get levelEveryday => 'Vsakdanje (poceni)';

  @override
  String get levelGood => 'Dobro';

  @override
  String get levelAging => 'Za staranje';

  @override
  String get levelNone => 'Brez';

  @override
  String get levelEverydayShort => 'popiti mlado';

  @override
  String get levelGoodShort => 'običajna napoved';

  @override
  String get levelAgingShort => 'zdrži dlje';

  @override
  String get levelSuggested => 'predlagana';

  @override
  String levelSuggestedReason(String qualifier) {
    return 'Predlagana, ker ime vsebuje „$qualifier“: tako se shrani, če je ne spremenite. Izberite drugo ali se dotaknite „Brez“.';
  }

  @override
  String levelSuggestedSemantics(String qualifier) {
    return 'predlagana, ker ime vsebuje $qualifier';
  }

  @override
  String levelOptionSemantics(String option, int index, int count) {
    return 'Raven, $option, $index od $count';
  }

  @override
  String get levelWhatChanges => 'Kaj se spremeni';

  @override
  String get levelEverydayExamples =>
      'Okno se skrajša. Npr. namizno vino, Lambrusco, osnovni Prosecco, Bardolino, Vinho Verde.';

  @override
  String get levelGoodExamples =>
      'Običajna napoved, ki velja tudi, če ne izberete ničesar. Npr. Chianti Classico, Barbera d\'Asti Superiore, Rioja Crianza, Côtes du Rhône.';

  @override
  String get levelAgingExamples =>
      'Okno se podaljša. Npr. Barolo, Brunello, Amarone, Bordeaux Grand Cru, Rioja Gran Reserva, Vintage Port.';

  @override
  String levelPreviewBefore(String start, String end) {
    return 'Prej $start – $end';
  }

  @override
  String levelPreviewWith(String level, String start, String end) {
    return 'Z ravnjo „$level“ $start – $end';
  }

  @override
  String levelPreviewNow(String start, String end) {
    return 'Pripravljeno $start – do $end';
  }

  @override
  String levelDetail(String level) {
    return 'Raven: $level';
  }

  @override
  String get overrideCorrect => 'Popravi';

  @override
  String get overrideRestore => 'Obnovi napoved';

  @override
  String get overrideCorrectedByYou => 'popravili ste vi';

  @override
  String overrideAppEstimate(String year) {
    return 'Napoved aplikacije: do $year';
  }

  @override
  String get overrideSheetTitle => 'Priporočeno do';

  @override
  String overrideSheetHint(String start) {
    return 'Izberite leto. Ne sme biti pred „Pripravljeno od $start“.';
  }

  @override
  String overridePeakNotice(String peak) {
    return 'Če izberete leto pred $peak (najboljše), se na isto leto premakne tudi „najboljše“.';
  }

  @override
  String get overrideMore => 'več…';

  @override
  String get overrideSave => 'Shrani popravek';

  @override
  String overrideRestoreTitle(String year) {
    return 'Se želite vrniti na napoved aplikacije (do $year)?';
  }

  @override
  String get overrideRestoreConfirm => 'Obnovi';

  @override
  String get overrideSaved => 'Popravek je shranjen';

  @override
  String get overrideRestored => 'Napoved je obnovljena';

  @override
  String get estimateSourceCorrectedByYou => 'popravili ste vi';

  @override
  String estimateFromDenomination(String name) {
    return 'Napoved glede na apelacijo $name';
  }

  @override
  String estimateFromDenominationQualifier(String name, String qualifier) {
    return 'Napoved glede na apelacijo $name, $qualifier';
  }

  @override
  String estimateFromGrape(String name) {
    return 'Napoved glede na sorto $name';
  }

  @override
  String get estimateFromType => 'Napoved glede na vrsto vina';

  @override
  String get autofillReading => 'Berem besedilo…';

  @override
  String get guideChip => 'Vodnik';

  @override
  String guideProgress(int n, int total) {
    return 'Vprašanje $n od $total';
  }

  @override
  String get guideClose => 'Zapri';

  @override
  String get guideIsDenomination => 'je to apelacija?';

  @override
  String get guideIsProducer => 'je to pridelovalec?';

  @override
  String get guideIsName => 'je to ime vina?';

  @override
  String get guideIsVintage => 'Letnik';

  @override
  String guideAskDenomination(String value) {
    return 'Je $value apelacija?';
  }

  @override
  String guideAskProducer(String value) {
    return 'Je $value pridelovalec?';
  }

  @override
  String guideAskName(String value) {
    return 'Je $value ime vina?';
  }

  @override
  String get guideAskVintage => 'Kateri je letnik?';

  @override
  String guideQuestionSemantics(int n, int total, String question) {
    return 'Vprašanje $n od $total: $question';
  }

  @override
  String get guideNoProposal => 'V besedilu tega ni bilo mogoče najti';

  @override
  String get guideYes => 'Da';

  @override
  String get guideNo => 'Ne, nekaj drugega';

  @override
  String get guideEdit => 'Uredi';

  @override
  String get guideSkip => 'Preskoči';

  @override
  String get guideConfirm => 'Potrdi';

  @override
  String get guideCancel => 'Prekliči';

  @override
  String guideRejected(String value) {
    return 'Ni „$value“: tukaj je naslednji predlog';
  }

  @override
  String get guideNoMore =>
      'Ni drugih predlogov: sestavite ga iz besed ali preskočite';

  @override
  String guideProposalAnnounce(String value) {
    return 'Predlog: $value';
  }

  @override
  String get guideComposeLabel =>
      'Ali pa ga sestavite z dotikanjem besed iz besedila';

  @override
  String get guideComposePreview => 'Predogled';

  @override
  String get guideComposeEmpty => 'Dotaknite se ene ali več besed';

  @override
  String get guideComposeLimit => 'Največ 8 besed in 80 znakov';

  @override
  String guideTableMatchSemantics(String name) {
    return 'ustreza: $name';
  }

  @override
  String guideLine(int n, int total) {
    return 'Vrstica $n od $total';
  }

  @override
  String guideWordSelected(String word, int order) {
    return '$word, izbrano, $order';
  }

  @override
  String guideWordUnavailable(String word) {
    return '$word, ni na voljo';
  }

  @override
  String guideWordUsedFor(String word, String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'apelacija',
      'producer': 'pridelovalec',
      'other': 'ime',
    });
    return '$word, uporabljeno za polje: $_temp0';
  }

  @override
  String guideUsedMark(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'apelacija',
      'producer': 'pridelovalec',
      'other': 'ime',
    });
    return '$_temp0';
  }

  @override
  String guideOtherYears(String years) {
    return 'V besedilu so tudi: $years';
  }

  @override
  String get guideWheelFromText => 'leto, najdeno v besedilu';

  @override
  String get guideWheelTypeYear => 'Vpišite leto';

  @override
  String guideWheelConfirm(String year) {
    return 'Potrdi $year';
  }

  @override
  String get guideNoVintage => 'Brez letnika';

  @override
  String guideSkippedNotice(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'Apelacija je preskočena',
      'producer': 'Pridelovalec je preskočen',
      'vintage': 'Letnik je preskočen',
      'other': 'Ime je preskočeno',
    });
    return '$_temp0: vpišite ročno ali nadaljujte vodnik';
  }

  @override
  String guideSkippedMany(int count) {
    return 'Preskočena polja: $count. Vpišite jih ali nadaljujte vodnik';
  }

  @override
  String get guideInvalidValue =>
      'To besedilo vsebuje znake, ki jih ni mogoče shraniti';

  @override
  String get brandStudio => 'Bottazzini Softworks';

  @override
  String get suggestedMark => '✦ predlagano';

  @override
  String suggestedSemantics(String field, String value) {
    return '$field, $value, predlagano';
  }

  @override
  String get restoreSuggestion => 'Obnovi predlog';

  @override
  String get restoreSuggestionDone => 'Predlog je obnovljen';

  @override
  String get styleLabel => 'Slog';

  @override
  String styleGroupSemantics(String value, int index, int count) {
    return 'Slog, $value, $index od $count';
  }

  @override
  String get styleRedFresh => 'Sveže';

  @override
  String get styleRedMedium => 'Srednje';

  @override
  String get styleRedAge => 'Za staranje';

  @override
  String get styleRedLong => 'Dolgo staranje';

  @override
  String get styleWhiteFresh => 'Sveže';

  @override
  String get styleWhiteMedium => 'Srednje';

  @override
  String get styleWhiteAge => 'Za staranje';

  @override
  String get styleRoseFresh => 'Sveže';

  @override
  String get styleClassicFresh => 'Sveže';

  @override
  String get styleClassicAge => 'Za staranje';

  @override
  String get styleTankFresh => 'Sveže';

  @override
  String get styleLambrusco => 'Lambrusco';

  @override
  String get styleSweetAromatic => 'Aromatično';

  @override
  String get styleSweetPassito => 'Sušeno grozdje';

  @override
  String get styleSweetBotrytis => 'Plemenita plesen';

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
  String get styleFortifiedOther => 'Drugo';

  @override
  String get profileNameRFresh => 'Sadno rdeče';

  @override
  String get profileNameRMedium => 'Rdeče srednjega telesa';

  @override
  String get profileNameRAge => 'Rdeče za staranje';

  @override
  String get profileNameRLong => 'Rdeče za dolgo staranje';

  @override
  String get profileNameWFresh => 'Sveže aromatično belo';

  @override
  String get profileNameWMedium => 'Belo srednjega telesa';

  @override
  String get profileNameWAge => 'Belo za staranje';

  @override
  String get profileNameRoseFresh => 'Sveži rosé';

  @override
  String get profileNameSpTank => 'Sveže peneče po metodi Charmat';

  @override
  String get profileNameLamFresh => 'Sveži Lambrusco';

  @override
  String get profileNameSpClassic => 'Sveže peneče po klasični metodi';

  @override
  String get profileNameSpClassicAge => 'Peneče po klasični metodi za staranje';

  @override
  String get profileNameSwAromatic => 'Mlado aromatično sladko vino';

  @override
  String get profileNameSwPassito => 'Sladko vino iz sušenega grozdja';

  @override
  String get profileNameSwBotrytis => 'Sladko vino s plemenito plesnijo';

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
  String get profileNameFortUnknown => 'Likersko, neznan slog';

  @override
  String get profileNameUnknown => 'Slog ni prepoznan';

  @override
  String estimateFromProfile(String profile, String denomination) {
    return 'Napoved glede na profil: $profile ($denomination)';
  }

  @override
  String estimateFromProfileType(String profile) {
    return 'Napoved glede na profil: $profile, glede na vrsto';
  }

  @override
  String estimateFromProfileGrape(String profile, String grape) {
    return 'Napoved glede na profil: $profile, glede na sorto $grape';
  }

  @override
  String get estimateFromEntryDateDisgorgement =>
      'Od datuma dodajanja: za boljšo napoved dodajte datum degoržiranja';

  @override
  String get estimateFromEntryDateBottling =>
      'Od datuma dodajanja: za boljšo napoved dodajte datum polnitve';

  @override
  String get styleToConfirmBanner =>
      '⚠︎ Slog je treba potrditi: napoved je okvirna';

  @override
  String get chooseTypePrompt => 'Izberite vrsto';

  @override
  String estimateUpdatedAnnouncement(String summary) {
    return 'Napoved je posodobljena: $summary';
  }

  @override
  String get agingStartDisgorgement => 'Degoržiranje';

  @override
  String get agingStartBottling => 'Polnitev';

  @override
  String get agingStartMonth => 'Mesec';

  @override
  String get agingStartYear => 'Leto';

  @override
  String get agingStartHint => 'Običajno je na zadnji etiketi.';

  @override
  String get agingStartIncomplete => 'Vnesite mesec in leto';

  @override
  String get agingStartFuture => 'Datum ne sme biti v prihodnosti';

  @override
  String get agingStartBeforeVintage => 'Ne sme biti pred letnikom';

  @override
  String get windowNoEnd => 'Pripravljeno, konec ni napovedan';

  @override
  String get windowNoEndShort => 'konec ni napovedan';

  @override
  String windowDrinkWithin(String date) {
    return 'do $date';
  }

  @override
  String get levelNoEffect => 'Raven te napovedi ne spremeni';

  @override
  String get dashboardToConfirmTitle => 'Za potrditev';

  @override
  String dashboardToConfirmCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vin',
      few: '$count vina',
      two: '$count vini',
      one: '$count vino',
    );
    return '$_temp0';
  }

  @override
  String aboutDbClassified(String percent) {
    return '$percent % vin s prepoznano vrsto';
  }

  @override
  String get planTitle => 'Paket';

  @override
  String get planFree => 'Brezplačni';

  @override
  String get planPlus => 'Plus';

  @override
  String get planPlusGift => 'Plus (darilo)';

  @override
  String get planDevUnlockAll => 'DEV · Preizkusni Plus';

  @override
  String get planDevSimulateFree => 'DEV · Simuliran brezplačni paket';

  @override
  String get planDevSimulateExpired => 'DEV · Simuliran potekel Plus';

  @override
  String get planDiscoverPlus => 'Odkrij Plus';

  @override
  String get plusTitle => 'Vinoozy Plus';

  @override
  String get plusBenefitsTitle => 'S paketom Plus';

  @override
  String get plusBenefitNoAds => 'Brez oglasov';

  @override
  String get plusBenefitNoLimit => 'Brez omejitve števila vin v kleti';

  @override
  String get plusComingSoon => 'Plus prihaja kmalu';

  @override
  String get plusLoading => 'Nalagam cene iz trgovine Google Play';

  @override
  String get plusStoreUnavailable =>
      'Cen iz trgovine Google Play ni bilo mogoče naložiti. Poskusite pozneje.';

  @override
  String plusPriceMonthly(String price) {
    return '$price na mesec';
  }

  @override
  String plusPriceAnnual(String price) {
    return '$price na leto';
  }

  @override
  String get plusRenewal =>
      'Naročnina se samodejno podaljšuje po prikazani ceni, dokler je ne prekličete v trgovini Google Play.';

  @override
  String get plusTerms =>
      'Plačilo se zaračuna vašemu računu Google Play, ko potrdite nakup. Prekličete lahko kadar koli: Plus ostane aktiven do konca že plačanega obdobja. Ko se Plus konča, vsa vaša vina ostanejo.';

  @override
  String get plusRestore => 'Obnovi nakupe';

  @override
  String get plusManage =>
      'Upravljaj ali prekliči naročnino v trgovini Google Play';

  @override
  String get plusActive => 'Plus je aktiven v tem računu';

  @override
  String get plusActiveGift =>
      'Plus imate kot darilo: brez plačil in brez podaljšanj.';

  @override
  String get plusPending =>
      'Plačilo je v čakanju: Plus bo aktiven, ko ga potrdi Google Play.';

  @override
  String get plusVerifying => 'Preverjam nakup';

  @override
  String get plusVerified =>
      'Nakup je preverjen: Plus bo aktiven čez nekaj sekund.';

  @override
  String get plusPurchaseFailed => 'Nakup ni bil dokončan. Poskusite znova.';

  @override
  String get plusInvalidPurchase =>
      'Google Play tega nakupa ni potrdil za Vinoozy.';

  @override
  String get plusOwnedByOther =>
      'Ta naročnina že pripada drugemu računu Vinoozy.';

  @override
  String get plusVerificationUnavailable =>
      'Nakupa zdaj ni mogoče preveriti. Poskusite pozneje: naročnina ostane v trgovini Google Play.';

  @override
  String get capacityLimitTitle => 'Dosežena je omejitev brezplačnega paketa';

  @override
  String capacityLimitBody(int limit) {
    return 'Brezplačni paket vključuje največ toliko različnih vin v kleti: $limit. Vina, ki jih že imate, lahko vedno urejate, označite kot popita in jim dodajate steklenice. Če želite dodati novo, dokončajte ali izbrišite katero od vin ali preklopite na Plus.';
  }

  @override
  String capacityLimitBodyComingSoon(int limit) {
    return 'Brezplačni paket vključuje največ toliko različnih vin v kleti: $limit. Vina, ki jih že imate, lahko vedno urejate, označite kot popita in jim dodajate steklenice. Če želite dodati novo, dokončajte ali izbrišite katero od vin. Plus prihaja kmalu.';
  }

  @override
  String get rejectedCapacityLimit =>
      'Ni sinhronizirano: presega omejitev števila vin brezplačnega paketa. Sprememba ostane v tem telefonu.';

  @override
  String get rejectedCapacityConflict =>
      'Ni sinhronizirano: klet se je hkrati spremenila v drugi napravi. Sprememba ostane v tem telefonu: poskusite znova.';

  @override
  String writeRejectedCapacityLimit(String name) {
    return '$name: ni sinhronizirano, presežena omejitev brezplačnega paketa';
  }

  @override
  String writeRejectedCapacityConflict(String name) {
    return '$name: ni sinhronizirano, klet se je spremenila v drugi napravi';
  }

  @override
  String get freeIntroTitle => 'Brezplačni paket';

  @override
  String freeIntroLimit(int limit) {
    return 'Brezplačno lahko upravljate največ toliko različnih vin: $limit.';
  }

  @override
  String get freeIntroAds =>
      'Ob zmerni uporabi ni oglasov. Če presežete mesečni prag uporabe storitve, boste morda občasno videli oglase, ki pomagajo pokriti stroške strežnikov in sinhronizacije.';

  @override
  String get freeIntroNoAds => 'V začetni različici ni oglasov.';

  @override
  String get freeIntroPlus =>
      'S paketom Plus odstranite oglase in omejitev kleti.';

  @override
  String get noticeGotIt => 'Razumem';

  @override
  String get thresholdTitle => 'Oglasi pomagajo, da Vinoozy ostane brezplačen';

  @override
  String get thresholdBody =>
      'Dosežen je mesečni prag uporabe brez oglasov. Odslej boste morda občasno videli oglase: pomagajo nam pokriti stroške strežnikov in sinhronizacije, da Vinoozy ostane brezplačen.';

  @override
  String get thresholdReset =>
      'Štetje se znova začne naslednji mesec. S paketom Plus aplikacijo uporabljate brez oglasov in brez omejitve kleti.';

  @override
  String thresholdNextReset(String date) {
    return 'Naslednja ponastavitev: $date';
  }

  @override
  String get thresholdHowItWorks => 'Kako deluje';

  @override
  String get thresholdHowItWorksBody =>
      'Prag je odvisen od ocene števila sinhronizacij z oblakom, ki jih je ta račun opravil v mesecu. Sama uporaba brez povezave ne ustvarja novih operacij v oblaku. Oglasi se prikažejo največ enkrat na dan, samo v Pregledu, in nikoli med shranjevanjem ali izvozom podatkov.';

  @override
  String get adLabel => 'Oglas';

  @override
  String get devToolsTitle => 'Razvojna orodja';

  @override
  String get devUnlockAll => 'Odkleni vse — preizkusni Plus';

  @override
  String get devSimulateFree => 'Simuliraj brezplačni paket';

  @override
  String get devSimulateExpired => 'Simuliraj potekel Plus';

  @override
  String get devRestore => 'Obnovi običajno stanje';

  @override
  String get devNoOverride => 'Nobena simulacija ni aktivna';

  @override
  String get devApplied => 'Scenarij je uporabljen tudi v emulatorju Firestore';

  @override
  String get devIncomplete =>
      'Nepopolna simulacija: emulator Firestore ni potrdil preizkusne pravice. Pravila strežnika tega scenarija ne vidijo.';

  @override
  String get devNotice =>
      'Samo razvojne različice z emulatorjem: brez plačil, žetonov ali potrdil.';
}
