// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Croatian (`hr`).
class AppLocalizationsHr extends AppLocalizations {
  AppLocalizationsHr([String locale = 'hr']) : super(locale);

  @override
  String get appTitle => 'Vinoozy';

  @override
  String get signInTagline => 'Vaš podrum, u pravo vrijeme';

  @override
  String get signInWithGoogle => 'Nastavi uz Google';

  @override
  String get signInInProgress => 'Prijava u tijeku';

  @override
  String get signInFailed => 'Prijava nije uspjela';

  @override
  String get signInNeedsNetwork => 'Za prvu prijavu potrebna je veza';

  @override
  String get signInSessionExpired => 'Sesija je istekla: prijavite se ponovno';

  @override
  String get retry => 'Pokušaj ponovno';

  @override
  String get cancel => 'Odustani';

  @override
  String blockedMessage(String email) {
    return 'Promjene s računa $email još nisu spremljene u oblak: prijavite se tim računom i povežite se s mrežom';
  }

  @override
  String blockedSignInWith(String email) {
    return 'Prijavi se kao $email';
  }

  @override
  String blockedDiscard(String email) {
    return 'Izbriši nespremljene promjene s računa $email';
  }

  @override
  String get discardDialogTitle => 'Izbrisati promjene?';

  @override
  String discardDialogBody(int count, String email) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count vina s računa $email još nije u oblaku i izbrisat će se s ovog telefona.',
      few:
          '$count vina s računa $email još nisu u oblaku i izbrisat će se s ovog telefona.',
      one:
          '$count vino s računa $email još nije u oblaku i izbrisat će se s ovog telefona.',
    );
    return '$_temp0';
  }

  @override
  String get discardConfirm => 'Izbriši';

  @override
  String get resetFailed => 'Podatke na ovom telefonu nije moguće izbrisati';

  @override
  String get restartRequired => 'Ponovno pokrenite aplikaciju za dovršetak';

  @override
  String get restartCloseApp => 'Zatvori aplikaciju';

  @override
  String get startupFailed => 'Aplikaciju nije moguće pokrenuti';

  @override
  String get cellarTitle => 'Podrum';

  @override
  String get defaultCellarName => 'Moj podrum';

  @override
  String get cellarLoading => 'Priprema podruma';

  @override
  String get cellarSetupFailed => 'Podrum nije moguće pripremiti';

  @override
  String get cellarEmpty => 'Vaš podrum je prazan';

  @override
  String get addWine => 'Dodaj';

  @override
  String get estimatePending => 'Procjena stiže';

  @override
  String get noVintage => 'Bez berbe';

  @override
  String bottleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count boca',
      few: '$count boce',
      one: '$count boca',
    );
    return '$_temp0';
  }

  @override
  String get syncInProgress => 'Sinkronizacija';

  @override
  String get syncOffline => 'Izvan mreže - sinkronizacija čeka';

  @override
  String writeRejected(String name) {
    return 'Promjena nije dopuštena: $name';
  }

  @override
  String get saveFailed => 'Spremanje nije uspjelo, pokušajte ponovno';

  @override
  String wineNotSaved(String name) {
    return 'Vino $name nije spremljeno u oblak';
  }

  @override
  String get addAgain => 'Dodaj ponovno';

  @override
  String get ignore => 'Zanemari';

  @override
  String get addWineTitle => 'Upiši';

  @override
  String get wineNameLabel => 'Vino';

  @override
  String get vintageLabel => 'Berba';

  @override
  String get quantityLabel => 'Količina';

  @override
  String get decreaseQuantity => 'Smanji količinu';

  @override
  String get increaseQuantity => 'Povećaj količinu';

  @override
  String get save => 'Spremi';

  @override
  String get nameRequired => 'Upišite naziv vina';

  @override
  String get nameTooLong => 'Najviše 120 znakova';

  @override
  String vintageRange(String year) {
    return 'Berba od 1900. do $year.';
  }

  @override
  String get offAttribution => 'Podaci iz Open Food Facts (ODbL)';

  @override
  String get dashboardTitle => 'Pregled';

  @override
  String dashboardTotalBottles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count boca u podrumu',
      few: '$count boce u podrumu',
      one: '$count boca u podrumu',
    );
    return '$_temp0';
  }

  @override
  String get dashboardSyncing => 'Sinkronizacija podruma…';

  @override
  String get dashboardAddFirstWine => 'Dodaj prvo vino';

  @override
  String get drinkSoonTitle => 'Popiti uskoro';

  @override
  String get drinkSoonEmpty => 'Nema boca koje treba uskoro popiti';

  @override
  String drinkSoonUntil(String year) {
    return 'do $year.';
  }

  @override
  String drinkSoonSeeAll(int count) {
    return 'Prikaži sve ($count)';
  }

  @override
  String get statusChartTitle => 'Stanje boca';

  @override
  String get statusWaiting => 'pričekati';

  @override
  String get statusReady => 'spremne';

  @override
  String get statusDrinkSoon => 'popiti uskoro';

  @override
  String get statusPastWindow => 'nakon prozora';

  @override
  String toEstimateNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count boca za procjenu',
      few: '$count boce za procjenu',
      one: '$count boca za procjenu',
    );
    return '$_temp0';
  }

  @override
  String chartBarValue(String label, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count boca',
      few: '$count boce',
      one: '$count boca',
    );
    return '$label: $_temp0';
  }

  @override
  String chartDescription(String title, String values) {
    return '$title: $values';
  }

  @override
  String get openListHint => 'Otvori popis';

  @override
  String get peakChartTitle => 'Godina vrhunca';

  @override
  String get peakPast => 'nakon vrhunca';

  @override
  String get peakBeyond => 'kasnije';

  @override
  String get breakdownTypeTitle => 'Boce po vrsti';

  @override
  String get breakdownRegionTitle => 'Boce po regiji';

  @override
  String get breakdownType => 'Vrsta';

  @override
  String get breakdownRegion => 'Regija';

  @override
  String get familyRed => 'crno';

  @override
  String get familyWhite => 'bijelo';

  @override
  String get familyRose => 'ružičasto';

  @override
  String get familySparkling => 'pjenušavo';

  @override
  String get familySweet => 'slatko';

  @override
  String get breakdownUnspecified => 'nije navedeno';

  @override
  String get breakdownOtherRegions => 'ostale';

  @override
  String get ok => 'U redu';

  @override
  String get cellarMenu => 'Izbornik podruma';

  @override
  String get sharingPeopleTitle => 'Osobe';

  @override
  String get sharingInviteTitle => 'Pozovi osobu';

  @override
  String get sharingEmailLabel => 'Google adresa e-pošte';

  @override
  String get sharingPermissionRead => 'Samo čitanje';

  @override
  String get sharingPermissionReadHint =>
      'Vidi vina, procjene, pregled i popijene boce';

  @override
  String get sharingPermissionEdit => 'Može uređivati';

  @override
  String get sharingPermissionEditHint =>
      'Dodaje i mijenja vina te bilježi popijene boce';

  @override
  String get sharingRoleOwner => 'vlasnik';

  @override
  String get sharingInviteButton => 'Pozovi';

  @override
  String sharingPlacesUsed(int used, int max) {
    return 'Osobe: $used/$max';
  }

  @override
  String get sharingInvalidEmail => 'Unesite valjanu adresu e-pošte';

  @override
  String get sharingSelfInvite => 'Ne možete pozvati sami sebe';

  @override
  String get sharingAlreadyInvited => 'Ta je osoba već pozvana';

  @override
  String sharingLimitReached(int max) {
    return 'Dosegnuto je ograničenje broja osoba: $max';
  }

  @override
  String get sharingNotOwner => 'Ne možete mijenjati dijeljenje ovog podruma';

  @override
  String get sharingNotFound => 'Ta osoba više nije na popisu';

  @override
  String get sharingFailed => 'Nije uspjelo, pokušajte ponovno';

  @override
  String get sharingInviteFailed => 'Pozivanje nije uspjelo. Pokušajte ponovno';

  @override
  String get sharingOfflineHint =>
      'Za upravljanje dijeljenjem potrebna je veza';

  @override
  String get sharingStatusInvited => 'pozvana';

  @override
  String get sharingStatusActive => 'aktivna';

  @override
  String get sharingStatusRevoked => 'pristup opozvan';

  @override
  String get sharingStatusLeft => 'napustila podrum';

  @override
  String sharingMemberSemantics(String name, String permission, String status) {
    return '$name, $permission, $status';
  }

  @override
  String get sharingClosedSection => 'Zatvoreni pristupi';

  @override
  String get sharingNobody => 'Ovaj podrum još nitko drugi ne vidi';

  @override
  String sharingChangePermission(String name) {
    return 'Promijeni dopuštenje: $name';
  }

  @override
  String get sharingRevoke => 'Opozovi';

  @override
  String sharingRevokeTitle(String name) {
    return 'Opozvati pristup korisniku $name?';
  }

  @override
  String sharingRevokeConfirmLabel(String name) {
    return 'Upišite $name za potvrdu';
  }

  @override
  String get sharingRevokeDisabledHint => 'Omogućeno kad se ime podudara';

  @override
  String get sharingReinvite => 'Pozovi ponovno';

  @override
  String get sharingDeleteForGood => 'Izbriši trajno';

  @override
  String sharingOwnedBy(String owner) {
    return 'Podrum: $owner';
  }

  @override
  String get sharingYourCellar => 'Vaš podrum';

  @override
  String sharingYourPermission(String permission) {
    return 'Vaše dopuštenje: $permission';
  }

  @override
  String sharingSwitcherSemantics(String cellar, String permission) {
    return '$cellar, $permission. Dodirnite za promjenu podruma';
  }

  @override
  String get sharingLeave => 'Napusti ovaj podrum';

  @override
  String sharingLeaveTitle(String owner) {
    return 'Napustiti podrum čiji je vlasnik $owner?';
  }

  @override
  String sharingLeaveBody(String owner) {
    return 'Više ga nećete vidjeti. $owner vas može ponovno pozvati.';
  }

  @override
  String get sharingLeaveConfirm => 'Napusti';

  @override
  String sharingSharedNotice(String owner) {
    return '$owner dijeli svoj podrum s vama';
  }

  @override
  String sharingAccessLost(String owner) {
    return 'Više nemate pristup podrumu čiji je vlasnik $owner';
  }

  @override
  String sharingWritesLost(String owner) {
    return 'Neke promjene u podrumu čiji je vlasnik $owner nisu spremljene jer više nemate pristup';
  }

  @override
  String get sharingSomeone => 'netko';

  @override
  String get sharingShareSubject => 'Pozivnica za Vinoozy';

  @override
  String sharingShareMessage(
    String owner,
    String cellar,
    String link,
    String email,
  ) {
    return '$owner vas poziva u podrum „$cellar” u aplikaciji Vinoozy. Instalirajte aplikaciju s $link i prijavite se Google računom $email: upotrijebite točno tu adresu.';
  }

  @override
  String get cellarSearchHint => 'Traži po nazivu ili vinariji';

  @override
  String get cellarFilterStatus => 'Stanje';

  @override
  String get cellarFilterType => 'Vrsta';

  @override
  String get statusToEstimate => 'Za procjenu';

  @override
  String get filterTypeUnspecified => 'Nije navedeno';

  @override
  String get cellarNoMatches => 'Nema vina s ovim filtrima';

  @override
  String get cellarClearFilters => 'Očisti filtre';

  @override
  String get cellarArchiveTitle => 'Popijeno';

  @override
  String get cellarArchiveEmpty => 'Još nema dovršenih vina';

  @override
  String get cellarArchiveFailed => 'Dovršena vina nije moguće učitati';

  @override
  String get wineDrink => 'Popijeno';

  @override
  String wineDrinkTooltip(String name) {
    return 'Označi kao popijenu bocu vina $name';
  }

  @override
  String confidenceLabel(String level) {
    return 'Pouzdanost: $level';
  }

  @override
  String get confidenceHigh => 'visoka';

  @override
  String get confidenceMedium => 'srednja';

  @override
  String get confidenceLow => 'niska';

  @override
  String get windowStartLabel => 'Početak';

  @override
  String get windowPeakLabel => 'Vrhunac';

  @override
  String get windowEndLabel => 'Kraj';

  @override
  String estimateSourceLabel(String source) {
    return 'Izvor: $source';
  }

  @override
  String get estimateSourceCatalog => 'baza vina';

  @override
  String get estimateSourceType => 'procjena za vrstu';

  @override
  String get estimateSourceCorrected =>
      'procjena ispravljena prema popijenim bocama';

  @override
  String get estimateDisclaimer =>
      'Okvirna procjena: ovisi i o tome kako je boca čuvana';

  @override
  String get estimateUnavailable => 'Procjena nije dostupna';

  @override
  String get pairingsTitle => 'Sljubljivanje';

  @override
  String get pairingsGeneric => 'općenito sljubljivanje za vrstu';

  @override
  String get pairingBraisedRedMeat => 'Pirjano crveno meso';

  @override
  String get pairingGrilledRedMeat => 'Crveno meso s roštilja';

  @override
  String get pairingGame => 'Divljač';

  @override
  String get pairingRoastPoultry => 'Pečena perad';

  @override
  String get pairingPoultry => 'Perad';

  @override
  String get pairingPork => 'Svinjetina';

  @override
  String get pairingCuredMeats => 'Suhomesnati proizvodi';

  @override
  String get pairingPastaMeatSauce => 'Tjestenina s umakom od mesa';

  @override
  String get pairingMushroomsTruffle => 'Gljive i tartufi';

  @override
  String get pairingAgedCheese => 'Zreli sirevi';

  @override
  String get pairingFreshCheese => 'Svježi sirevi';

  @override
  String get pairingBlueCheese => 'Sirevi s plavom plijesni';

  @override
  String get pairingFish => 'Riba';

  @override
  String get pairingSeafood => 'Plodovi mora';

  @override
  String get pairingRawSeafood => 'Sirovi plodovi mora';

  @override
  String get pairingFriedFood => 'Pržena jela';

  @override
  String get pairingVegetables => 'Povrće';

  @override
  String get pairingRisotto => 'Rižoto';

  @override
  String get pairingPizza => 'Pizza';

  @override
  String get pairingAperitif => 'Aperitiv';

  @override
  String get pairingPastries => 'Kolači';

  @override
  String get pairingDryBiscuits => 'Suhi keksi';

  @override
  String get pairingChocolate => 'Čokolada';

  @override
  String get pairingDriedFruit => 'Orašasti plodovi i suho voće';

  @override
  String get pairingSpicyDishes => 'Začinjena jela';

  @override
  String get recentDrinksTitle => 'Posljednje popijeno';

  @override
  String get noDrinksYet => 'Još ništa nije popijeno';

  @override
  String get wineEdit => 'Uredi';

  @override
  String get wineDelete => 'Izbriši';

  @override
  String get wineFinished => 'Dovršeno: nema više boca';

  @override
  String get wineLoadFailed => 'Vino nije moguće otvoriti';

  @override
  String get wineNotFound => 'Ovo vino više ne postoji';

  @override
  String drinkDone(String name) {
    return 'Označeno kao popijeno: $name';
  }

  @override
  String get drinkUndo => 'Poništi';

  @override
  String get drinkAddNotes => 'Dodaj ocjenu i bilješke';

  @override
  String get nothingToUndo => 'Nema se više što poništiti';

  @override
  String get cellarUndoRejected =>
      'Poništavanje nije uspjelo: boca ostaje označena kao popijena';

  @override
  String get cellarDeleteFailed =>
      'Brisanje još nije dovršeno: dovršit će se čim bude moguće';

  @override
  String get duplicateFull =>
      'Ovo vino već ima 99 boca: nije moguće dodati više.';

  @override
  String get recordSheetTitle => 'Ocjena i bilješke';

  @override
  String get recordRatingLabel => 'Ocjena';

  @override
  String ratingStar(int n) {
    return 'Ocjena $n od 5';
  }

  @override
  String get recordNotesLabel => 'Bilješke';

  @override
  String get recordNotesTooLong => 'Najviše 1000 znakova';

  @override
  String recordDateLabel(String date) {
    return 'Datum: $date';
  }

  @override
  String get recordDateInvalid =>
      'Datum ne može biti u budućnosti ni prije berbe';

  @override
  String get recordConditionTitle => 'Kakvo je bilo?';

  @override
  String get conditionTooYoung => 'Još premlado';

  @override
  String get conditionJustRight => 'Baš kako treba';

  @override
  String get conditionPastPeak => 'Prošlo vrhunac';

  @override
  String get recordNoCondition => 'Bez odgovora';

  @override
  String get producerLabel => 'Vinarija (neobavezno)';

  @override
  String get producerTooLong => 'Najviše 120 znakova';

  @override
  String producerAddNew(String name) {
    return 'Dodaj novu vinariju: „$name”';
  }

  @override
  String get wineTypeLabel => 'Vrsta';

  @override
  String get typeRedLight => 'Lagano crno';

  @override
  String get typeRedStructured => 'Crno punog tijela';

  @override
  String get typeWhite => 'Bijelo';

  @override
  String get typeRose => 'Ružičasto';

  @override
  String get typeSparklingClassic => 'Pjenušavo klasičnom metodom';

  @override
  String get typeSparklingTank => 'Pjenušavo metodom Charmat';

  @override
  String get typeSweet => 'Slatko';

  @override
  String get typeFortified => 'Likersko';

  @override
  String get suggestionFromCellar => 'U vašem podrumu';

  @override
  String get suggestionsLabel => 'Prijedlozi';

  @override
  String get duplicateTitle => 'Već je u podrumu';

  @override
  String duplicateBody(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ima $count boca',
      few: 'ima $count boce',
      one: 'ima $count bocu',
      zero: 'nema nijednu bocu',
    );
    return '$name: ovo vino već je u podrumu, $_temp0. Dodati mu nove boce?';
  }

  @override
  String duplicateAdd(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dodaj $count boca',
      few: 'Dodaj $count boce',
      one: 'Dodaj $count bocu',
    );
    return '$_temp0';
  }

  @override
  String get duplicateBanner => 'Mogući duplikat';

  @override
  String get duplicateMerge => 'Spoji';

  @override
  String get duplicateDeleteHint => 'Izbrišite ovaj unos ako je duplikat';

  @override
  String get mergeTitle => 'Spojiti dva unosa?';

  @override
  String get mergeBody =>
      'Boce iz ovog unosa prelaze u stariji, a ovaj se unos briše.';

  @override
  String get editWineTitle => 'Uredi vino';

  @override
  String get editDuplicate =>
      'Već postoji drugo vino s istim nazivom, vinarijom i berbom';

  @override
  String deleteWineTitle(String name) {
    return 'Izbrisati vino $name?';
  }

  @override
  String get deleteWineBody =>
      'Vino i svi zapisi o popijenim bocama bit će izbrisani. To se ne može poništiti.';

  @override
  String get historyTitle => 'Povijest';

  @override
  String get historyEmpty => 'Ovdje ćete naći popijene boce';

  @override
  String get historyLoadFailed => 'Povijest nije moguće učitati';

  @override
  String drankOnLabel(String date) {
    return 'Popijeno: $date';
  }

  @override
  String get addChoiceTitle => 'Dodaj vino';

  @override
  String get addChoicePhoto => 'Fotografiraj';

  @override
  String get addChoiceImport => 'Uvezi fotografiju';

  @override
  String get addChoiceWrite => 'Upiši';

  @override
  String get labelReading => 'Čitam etiketu…';

  @override
  String get labelRecognized => 'Prepoznato:';

  @override
  String get labelCorrect => 'Ispravi';

  @override
  String get labelConfirm => 'Potvrdi';

  @override
  String get labelUnreadable => 'Ne mogu pročitati etiketu';

  @override
  String get labelWriteByHand => 'Upiši ručno';

  @override
  String get labelNotFound => 'Vino nije pronađeno: provjerite podatke';

  @override
  String get labelCameraDenied =>
      'Za čitanje etikete potreban je pristup kameri';

  @override
  String get labelPhotosDenied =>
      'Za čitanje etikete potreban je pristup fotografijama';

  @override
  String get labelOpenSettings => 'Otvori postavke';

  @override
  String get labelCameraUnavailable => 'Kamera nije dostupna';

  @override
  String get labelBarcodeNotFound =>
      'Crtični kod je pročitan, ali vino nije pronađeno';

  @override
  String get labelBarcodeFrontHint => 'Fotografirajte prednju etiketu';

  @override
  String get labelSharedNotAllowed => 'Ne možete dodavati vina u ovaj podrum';

  @override
  String get labelSharedFirstOnly => 'Upotrijebljena je samo prva fotografija';

  @override
  String get labelSharedExpired =>
      'Podijeljenu fotografiju nije moguće pročitati: podijelite je ponovno';

  @override
  String get labelReplaceTitle =>
      'Imate nespremljeno vino. Pročitati novu fotografiju?';

  @override
  String get labelReplaceRead => 'Pročitaj novu fotografiju';

  @override
  String get labelReplaceKeep => 'Nastavi s otvorenim';

  @override
  String get labelWineAdded => 'Vino je dodano u podrum';

  @override
  String get onboardingPage1Title => 'Vaš podrum u džepu';

  @override
  String get onboardingPage1Body =>
      'Dodajte boce upisom ili fotografijom etikete, čak i bez mreže.';

  @override
  String get onboardingPage2Title => 'U pravo vrijeme';

  @override
  String get onboardingPage2Body =>
      'Vinoozy procjenjuje kada je svako vino najbolje i govori vam koja otvoriti prva.';

  @override
  String get onboardingPage3Title => 'Zajedno';

  @override
  String get onboardingPage3Body =>
      'Podijelite podrum s najviše dvije osobe i čuvajte povijest svake popijene boce.';

  @override
  String get onboardingSkip => 'Preskoči';

  @override
  String get onboardingNext => 'Dalje';

  @override
  String get onboardingStart => 'Započni';

  @override
  String onboardingPageOf(int page) {
    return 'Stranica $page od 3';
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
  String get profilePrivacy => 'Pravila o privatnosti';

  @override
  String get profilePrivacyBody =>
      'Pravila o privatnosti možete pročitati na ovoj adresi:';

  @override
  String get profileOpenLink => 'Otvori u pregledniku';

  @override
  String get profileOpenLinkFailed =>
      'Stranicu nije moguće otvoriti. Možete kopirati poveznicu i otvoriti je u pregledniku.';

  @override
  String get profileCopyLink => 'Kopiraj poveznicu';

  @override
  String get profileLinkCopied => 'Poveznica je kopirana';

  @override
  String get close => 'Zatvori';

  @override
  String get signOutConfirmTitle => 'Želite li se odjaviti?';

  @override
  String signOutPendingWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Imate $count još nespremljenih promjena. Ako se odjavite, a prijavi se drugi račun, bit će izgubljene.',
      few:
          'Imate $count još nespremljene promjene. Ako se odjavite, a prijavi se drugi račun, bit će izgubljene.',
      one:
          'Imate $count još nespremljenu promjenu. Ako se odjavite, a prijavi se drugi račun, bit će izgubljena.',
    );
    return '$_temp0';
  }

  @override
  String get signOutStayAndSync => 'Ostani i sinkroniziraj';

  @override
  String get signOutAnyway => 'Svejedno se odjavi';

  @override
  String get syncAllSaved => 'Sve je spremljeno';

  @override
  String syncStillPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count promjena još čeka spremanje: provjerite mrežu',
      few: '$count promjene još čekaju spremanje: provjerite mrežu',
      one: '$count promjena još čeka spremanje: provjerite mrežu',
    );
    return '$_temp0';
  }

  @override
  String get signOutFailed => 'Odjava nije uspjela. Pokušajte ponovno';

  @override
  String get signInAccountDeleted => 'Račun je izbrisan';

  @override
  String get deleteAccountIntro => 'Trajno se briše:';

  @override
  String get deleteAccountItemCellar => 'Vaš podrum, s vinima i Poviješću';

  @override
  String get deleteAccountItemShares =>
      'Dijeljenja koja ste odobrili: pozvane osobe gube pristup';

  @override
  String get deleteAccountItemMemberships =>
      'Vaše sudjelovanje u tuđim podrumima: zapisi o bocama koje ste popili ostaju ondje bez vašeg imena';

  @override
  String get deleteAccountItemProfile => 'Vaš profil';

  @override
  String deleteAccountPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Imate $count još nespremljenih promjena: bit će spremljene, a zatim izbrisane s ostalim',
      few:
          'Imate $count još nespremljene promjene: bit će spremljene, a zatim izbrisane s ostalim',
      one:
          'Imate $count još nespremljenu promjenu: bit će spremljena, a zatim izbrisana s ostalim',
    );
    return '$_temp0';
  }

  @override
  String get deleteAccountConfirmWord => 'IZBRIŠI';

  @override
  String deleteAccountTypeWord(String word) {
    return 'Upišite $word za potvrdu';
  }

  @override
  String get deleteAccountReauthHint =>
      'Zatim ćete se ponovno prijaviti Google računom kako biste potvrdili da ste to vi.';

  @override
  String get deleteAccountForever => 'Izbriši zauvijek';

  @override
  String get deleteAccountNeedsNetwork =>
      'Povežite se s internetom da biste izbrisali račun';

  @override
  String get deleteAccountSameAccount =>
      'Brisanje zahtijeva prijavu istim računom';

  @override
  String get deletionTitle => 'Brisanje računa';

  @override
  String get deletionStepPreparePhone => 'Spremanje promjena na čekanju';

  @override
  String get deletionStepMarkStarted => 'Pokretanje brisanja';

  @override
  String get deletionStepLeaveOtherCellars => 'Napuštanje tuđih podruma';

  @override
  String get deletionStepCloseOwnInvitations => 'Zatvaranje vaših dijeljenja';

  @override
  String get deletionStepDeleteWinesAndRecords => 'Brisanje vina i Povijesti';

  @override
  String get deletionStepDeleteCellar => 'Brisanje podruma';

  @override
  String get deletionStepDeleteProfileAndUser => 'Brisanje profila i računa';

  @override
  String get deletionStepCleanUpPhone => 'Čišćenje ovog telefona';

  @override
  String deletionStepAnnounce(int step, String label) {
    return 'Korak $step od 8: $label';
  }

  @override
  String deletionDeletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Izbrisano $count vina i zapisa',
      few: 'Izbrisana $count vina i zapisa',
      one: 'Izbrisano $count vino ili zapis',
    );
    return '$_temp0';
  }

  @override
  String get deletionResumeHint =>
      'Brisanje ovog računa nije dovršeno. Ponovno se prijavite Google računom da biste ga dovršili.';

  @override
  String get deletionContinue => 'Nastavi';

  @override
  String get deletionOffline =>
      'Povežite se s internetom da biste dovršili brisanje';

  @override
  String get deletionPendingWrites =>
      'Ne mogu spremiti promjene na čekanju. Pokušajte ponovno';

  @override
  String get deletionFailed =>
      'Brisanje nije moguće dovršiti. Pokušajte ponovno';

  @override
  String get uxCountryLabel => 'Zemlja';

  @override
  String get uxCountryOther => 'Druga zemlja…';

  @override
  String get uxCountryNone => 'Bez zemlje';

  @override
  String get uxAllCountriesTitle => 'Sve zemlje i teritoriji';

  @override
  String get uxAllCountriesSearch => 'Traži zemlju';

  @override
  String get uxAllCountriesRare => 'Rijetke za vino';

  @override
  String get uxAllCountriesAll => 'Sve, od A do Ž';

  @override
  String get uxAllCountriesNone => 'Nijedna zemlja nije pronađena';

  @override
  String get uxRegionLabel => 'Regija';

  @override
  String uxRegionOf(String country) {
    return 'Regija · $country';
  }

  @override
  String get uxRegionOther => 'Druga regija';

  @override
  String get uxRegionFieldLabel => 'Upišite regiju';

  @override
  String get uxRegionTooLong => 'Najviše 120 znakova';

  @override
  String get uxDrinkAction => 'Popijeno';

  @override
  String uxDrinkActionTooltip(String name) {
    return 'Popijena boca vina $name';
  }

  @override
  String get uxDrinkActionDetail => 'Popijena boca';

  @override
  String get uxDrinkSheetLabel => 'Potvrdite ispijanje';

  @override
  String get uxDrinkSheetBottles => 'Boce';

  @override
  String uxDrinkSheetBottlesChange(int before, int after) {
    return 'Boce: s $before na $after';
  }

  @override
  String get uxDrinkSheetRating => 'Kakvo je bilo? (neobavezno)';

  @override
  String uxDrinkSheetStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count zvjezdica od 5',
      few: '$count zvjezdice od 5',
      one: '$count zvjezdica od 5',
    );
    return '$_temp0';
  }

  @override
  String get uxDrinkSheetConfirm => 'Da, popijena je';

  @override
  String get uxRemoveBottle => 'Ukloni bocu bez zapisa o ispijanju';

  @override
  String get uxRemoveBottleTitle => 'Ukloniti bocu?';

  @override
  String uxRemoveBottleBody(String name) {
    return 'Jedna boca vina $name uklanja se bez zapisa o ispijanju.';
  }

  @override
  String get uxRemoveBottleConfirm => 'Ukloni';

  @override
  String get uxIdealTitle => 'Idealan trenutak';

  @override
  String uxIdealUntil(String year) {
    return 'Preporučeno do $year.';
  }

  @override
  String uxIdealUntilPast(String year) {
    return 'Preporučeno do $year. – rok je prošao';
  }

  @override
  String uxIdealBest(String start, String end) {
    return 'Najbolje od $start. do $end.';
  }

  @override
  String uxIdealBar(String start, String end) {
    return 'Prozor pitkosti od $start. do $end.';
  }

  @override
  String get uxIdealDisclaimer =>
      '⚠︎ Okvirno: procjena na temelju vrste, apelacije i berbe. Čuvanje i pojedina boca mogu je promijeniti.';

  @override
  String get uxIdealUnavailableHint =>
      'Dodajte berbu i vrstu da biste dobili procjenu.';

  @override
  String uxDashboardDrinkNow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count za ispijanje sada',
      few: '$count za ispijanje sada',
      one: '$count za ispijanje sada',
    );
    return '$_temp0';
  }

  @override
  String get uxFamilyRed => 'Crno';

  @override
  String get uxFamilyWhite => 'Bijelo';

  @override
  String get uxFamilyRose => 'Ružičasto';

  @override
  String get uxFamilySparkling => 'Pjenušavo';

  @override
  String get uxFamilySweet => 'Slatko';

  @override
  String get labelBackTitle => 'Sada stražnja strana';

  @override
  String get labelBackHint =>
      'Na stražnjoj etiketi obično su crtični kod, vinarija i berba: pomažu pronaći vino.';

  @override
  String get labelBackTake => 'Fotografiraj stražnju';

  @override
  String get labelBackGallery => 'Odaberi iz galerije';

  @override
  String get labelBackSkip => 'Preskoči';

  @override
  String get labelStepFront => 'Prednja strana';

  @override
  String get labelStepBack => 'Stražnja strana';

  @override
  String get labelStepBarcode => 'Crtični kod';

  @override
  String get labelStepDatabase => 'Baza vina na telefonu';

  @override
  String get labelStepPending => 'Čeka';

  @override
  String get labelStepRunning => 'U tijeku…';

  @override
  String get labelStepDone => 'Gotovo';

  @override
  String get labelStepSkipped => 'Preskočeno';

  @override
  String get labelStepFailed => 'Nečitljivo';

  @override
  String labelStepStatus(String step, String status) {
    return '$step: $status';
  }

  @override
  String get labelOnPhoneNote =>
      'Sve se odvija na telefonu: fotografije se nikome ne šalju.';

  @override
  String get labelBackUnreadable => 'Stražnja strana nije čitljiva';

  @override
  String get labelSourceOffline => 'Iz baze na telefonu · offline';

  @override
  String get labelSourceCatalog => 'Iz kataloga';

  @override
  String get labelSourceOnline => 'Iz Open Food Facts · online';

  @override
  String get labelNotThis => 'Nije ovo';

  @override
  String get labelOffAttribution => 'Podaci iz Open Food Facts, licenca ODbL';

  @override
  String get labelCandidatesTitle => 'Koje od ovih?';

  @override
  String labelCandidatesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sličnih vina',
      few: '$count slična vina',
      one: '$count slično vino',
    );
    return '$_temp0';
  }

  @override
  String get labelCandidatesNone => 'Nijedno od ovih';

  @override
  String get labelChipOffline => 'offline';

  @override
  String get labelChipOnline => 'online';

  @override
  String get labelChipCatalog => 'katalog';

  @override
  String get labelNoProducer => 'vinarija nije navedena';

  @override
  String get labelNoMatch => 'Etiketa je pročitana, ali ne prepoznajem vino';

  @override
  String get labelReadText => 'Pročitani tekst';

  @override
  String get labelSearchOnline => 'Traži na internetu';

  @override
  String get labelOpenLens => 'Otvori u Google Lens';

  @override
  String get labelLensLastResort =>
      'Google Lens je zadnja mogućnost: fotografija ide u Googleovu aplikaciju samo ako potvrdite.';

  @override
  String get labelLensTitle => 'Otvoriti u Google Lens?';

  @override
  String get labelLensBody =>
      'Fotografija prednje etikete ide u Googleovu aplikaciju na vašem telefonu ili u aplikaciju koju odaberete, a ona može zadržati kopiju prema vlastitim pravilima. Vinoozy ne prima rezultate: vratite se ovamo da odaberete ili upišete vino.';

  @override
  String get labelLensConfirm => 'Otvori Google Lens';

  @override
  String get labelLensFailed =>
      'Ne mogu otvoriti Google Lens ni izbornik dijeljenja';

  @override
  String get onlineSearchTitle => 'Traži na internetu';

  @override
  String get onlineSearchSubtitle => 'Open Food Facts · samo vina';

  @override
  String get onlineSearchField => 'Riječi za pretragu';

  @override
  String get onlineSearchHint => 'Riječi možete promijeniti prije pretrage.';

  @override
  String get onlineSearchEmptyField => 'Upišite barem jednu riječ';

  @override
  String get onlineSearchButton => 'Traži';

  @override
  String get onlineSearchLoading => 'Tražim…';

  @override
  String onlineSearchResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rezultata',
      few: '$count rezultata',
      one: '$count rezultat',
    );
    return '$_temp0';
  }

  @override
  String get onlineSearchEmpty =>
      'Nijedno vino nije pronađeno: pokušajte s drugim riječima ili „Upiši ručno”.';

  @override
  String get onlineSearchOffline =>
      'Nema mreže: tražim samo u bazi na telefonu.';

  @override
  String get onlineSearchRateLimited =>
      'Pretraga na internetu trenutačno nije dostupna, pokušajte ponovno za nekoliko minuta.';

  @override
  String get onlineSearchUnavailable =>
      'Pretraga na internetu nije aktivna u ovoj verziji aplikacije: tražim samo u bazi na telefonu.';

  @override
  String get aboutTitle => 'O aplikaciji';

  @override
  String aboutVersion(String version) {
    return 'Verzija $version';
  }

  @override
  String get aboutDbTitle => 'Baza vina';

  @override
  String aboutDbCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vina',
      few: '$count vina',
      one: '$count vino',
    );
    return '$_temp0';
  }

  @override
  String aboutDbDate(String date) {
    return 'Izvoz Open Food Facts od $date';
  }

  @override
  String get aboutDbSample =>
      'Ogledna baza: nekoliko ručno upisanih probnih vina, ne podaci Open Food Facts.';

  @override
  String get aboutDbLoading => 'Otvaram bazu vina…';

  @override
  String get aboutDbUnavailable => 'Baza vina nije dostupna u ovoj verziji';

  @override
  String aboutDbSource(String url) {
    return 'Izvedena baza i alat koji je izrađuje nalaze se u javnom repozitoriju: $url';
  }

  @override
  String get aboutLicenseTitle => 'Licence';

  @override
  String get aboutLicense =>
      'Sadrži informacije iz Open Food Facts, dostupne pod licencom Open Database License (ODbL). Pojedinačni sadržaji podliježu licenci Database Contents License (DbCL).';

  @override
  String get aboutPrivacyTitle => 'Fotografije etiketa';

  @override
  String get aboutPrivacy =>
      'Fotografije etiketa čitaju se na telefonu i brišu kad napustite rezultat. Telefon napuštaju samo ako dodirnete „Otvori u Google Lens” i potvrdite.';

  @override
  String get aboutAppellationsTitle => 'Apelacije';

  @override
  String get aboutAppellationsSource =>
      'Apelacije: registar eAmbrosia (EU) i službeni nacionalni registri.';

  @override
  String get aboutAppellationsSample =>
      'Ogledna tablica: ručno prepisan izvadak iz registara, dok se ne preuzmu pravi registri.';

  @override
  String get denominationLabel => 'Apelacija';

  @override
  String get denominationTooLong => 'Najviše 120 znakova';

  @override
  String get autofillFilledNotice =>
      'Ispunjeno s etikete: provjerite i spremite';

  @override
  String get autofillPastedNotice =>
      'Ispunjeno iz teksta: provjerite i spremite';

  @override
  String get autofillFromText => '✦ iz teksta';

  @override
  String get autofillFromTextSemantics => 'ispunjeno s etikete';

  @override
  String get autofillClear => 'Očisti';

  @override
  String get autofillLens => 'Lens';

  @override
  String get autofillClearTitle => 'Očistiti obrazac?';

  @override
  String get autofillClearBody =>
      'Neka su polja ispunjena i ručno. „Očisti” prazni naziv, vinariju, apelaciju, berbu, vrstu, zemlju, regiju i razinu. Količina ostaje.';

  @override
  String get autofillClearConfirm => 'Očisti';

  @override
  String get autofillCleared => 'Obrazac je očišćen';

  @override
  String get autofillPasteTitle => 'Imate tekst iz aplikacije Google Lens?';

  @override
  String get autofillPasteHint =>
      'U Lensu označite tekst etikete i dodirnite „Kopiraj”, zatim se vratite ovamo.';

  @override
  String get autofillPaste => 'Zalijepi iz Lensa';

  @override
  String get autofillOpenLens => 'Iz Google Lens';

  @override
  String get autofillOpenLensSemantics => 'otvara Google Lens';

  @override
  String get autofillClipboardEmpty => 'U međuspremniku nema teksta';

  @override
  String get autofillNoNewFields => 'U tekstu nema podataka za dodavanje';

  @override
  String get autofillFromLens => 'Obrazac je ispunjen tekstom iz Lensa';

  @override
  String get autofillShareEmpty => 'Nije primljen tekst';

  @override
  String get autofillShareUseTitle => 'Upotrijebiti tekst za prazna polja?';

  @override
  String get autofillShareUse => 'Upotrijebi';

  @override
  String get autofillShareIgnore => 'Zanemari';

  @override
  String get addChoiceLens => 'Iz Google Lens';

  @override
  String get addChoicePhotoHint =>
      'Prednja i stražnja strana: Vinoozy čita etiketu.';

  @override
  String get addChoiceLensHint =>
      'Otvara Lens: kadrirajte, označite tekst i dodirnite Dijeli → Vinoozy.';

  @override
  String get addChoiceImportHint => 'Fotografija etikete koju već imate.';

  @override
  String get addChoiceWriteHint =>
      'Prazan obrazac, s opcijom „Zalijepi iz Lensa”.';

  @override
  String get lensInstructionsTitle => 'Google Lens nije moguće otvoriti odavde';

  @override
  String get lensInstructionsStep1 =>
      'Otvorite Google Lens i kadrirajte etiketu';

  @override
  String get lensInstructionsStep2 => 'Označite tekst etikete';

  @override
  String get lensInstructionsStep3 => 'Dodirnite Dijeli → Vinoozy';

  @override
  String get lensInstructionsOk => 'Razumijem';

  @override
  String get levelLabel => 'Razina';

  @override
  String get levelEveryday => 'Svakodnevno (povoljno)';

  @override
  String get levelGood => 'Dobro';

  @override
  String get levelAging => 'Za čuvanje';

  @override
  String get levelNone => 'Nijedna';

  @override
  String get levelEverydayShort => 'popiti mlado';

  @override
  String get levelGoodShort => 'uobičajena procjena';

  @override
  String get levelAgingShort => 'traje dulje';

  @override
  String get levelSuggested => 'predložena';

  @override
  String levelSuggestedReason(String qualifier) {
    return 'Predložena jer naziv sadrži „$qualifier”: tako se sprema ako je ne promijenite. Odaberite drugu ili dodirnite „Nijedna”.';
  }

  @override
  String levelSuggestedSemantics(String qualifier) {
    return 'predložena jer naziv sadrži $qualifier';
  }

  @override
  String levelOptionSemantics(String option, int index, int count) {
    return 'Razina, $option, $index od $count';
  }

  @override
  String get levelWhatChanges => 'Što se mijenja';

  @override
  String get levelEverydayExamples =>
      'Prozor se skraćuje. Npr. stolno vino, Lambrusco, osnovni Prosecco, Bardolino, Vinho Verde.';

  @override
  String get levelGoodExamples =>
      'Uobičajena procjena, koja vrijedi i kad ništa ne odaberete. Npr. Chianti Classico, Barbera d\'Asti Superiore, Rioja Crianza, Côtes du Rhône.';

  @override
  String get levelAgingExamples =>
      'Prozor se produljuje. Npr. Barolo, Brunello, Amarone, Bordeaux Grand Cru, Rioja Gran Reserva, Vintage Port.';

  @override
  String levelPreviewBefore(String start, String end) {
    return 'Prije $start – $end';
  }

  @override
  String levelPreviewWith(String level, String start, String end) {
    return 'Uz „$level” $start – $end';
  }

  @override
  String levelPreviewNow(String start, String end) {
    return 'Spremno $start – do $end';
  }

  @override
  String levelDetail(String level) {
    return 'Razina: $level';
  }

  @override
  String get overrideCorrect => 'Ispravi';

  @override
  String get overrideRestore => 'Vrati procjenu';

  @override
  String get overrideCorrectedByYou => 'ispravili ste vi';

  @override
  String overrideAppEstimate(String year) {
    return 'Procjena aplikacije: do $year.';
  }

  @override
  String get overrideSheetTitle => 'Preporučeno do';

  @override
  String overrideSheetHint(String start) {
    return 'Odaberite godinu. Ne može biti prije „Spremno od $start”.';
  }

  @override
  String overridePeakNotice(String peak) {
    return 'Ako odaberete godinu prije $peak. (najbolje), i „najbolje” se pomiče na istu godinu.';
  }

  @override
  String get overrideMore => 'više…';

  @override
  String get overrideSave => 'Spremi ispravak';

  @override
  String overrideRestoreTitle(String year) {
    return 'Vratiti se na procjenu aplikacije (do $year.)?';
  }

  @override
  String get overrideRestoreConfirm => 'Vrati';

  @override
  String get overrideSaved => 'Ispravak je spremljen';

  @override
  String get overrideRestored => 'Procjena je vraćena';

  @override
  String get estimateSourceCorrectedByYou => 'ispravili ste vi';

  @override
  String estimateFromDenomination(String name) {
    return 'Procjena prema apelaciji $name';
  }

  @override
  String estimateFromDenominationQualifier(String name, String qualifier) {
    return 'Procjena prema apelaciji $name, $qualifier';
  }

  @override
  String estimateFromGrape(String name) {
    return 'Procjena prema sorti $name';
  }

  @override
  String get estimateFromType => 'Procjena prema vrsti vina';

  @override
  String get autofillReading => 'Čitam tekst…';

  @override
  String get guideChip => 'Vodič';

  @override
  String guideProgress(int n, int total) {
    return 'Pitanje $n od $total';
  }

  @override
  String get guideClose => 'Zatvori';

  @override
  String get guideIsDenomination => 'je li to apelacija?';

  @override
  String get guideIsProducer => 'je li to vinarija?';

  @override
  String get guideIsName => 'je li to naziv vina?';

  @override
  String get guideIsVintage => 'Berba';

  @override
  String guideAskDenomination(String value) {
    return 'Je li $value apelacija?';
  }

  @override
  String guideAskProducer(String value) {
    return 'Je li $value vinarija?';
  }

  @override
  String guideAskName(String value) {
    return 'Je li $value naziv vina?';
  }

  @override
  String get guideAskVintage => 'Koja je berba?';

  @override
  String guideQuestionSemantics(int n, int total, String question) {
    return 'Pitanje $n od $total: $question';
  }

  @override
  String get guideNoProposal => 'Nije pronađeno u tekstu';

  @override
  String get guideYes => 'Da';

  @override
  String get guideNo => 'Ne, nešto drugo';

  @override
  String get guideEdit => 'Uredi';

  @override
  String get guideSkip => 'Preskoči';

  @override
  String get guideConfirm => 'Potvrdi';

  @override
  String get guideCancel => 'Odustani';

  @override
  String guideRejected(String value) {
    return 'Nije „$value”: evo sljedećeg prijedloga';
  }

  @override
  String get guideNoMore =>
      'Nema drugih prijedloga: složite ga od riječi ili preskočite';

  @override
  String guideProposalAnnounce(String value) {
    return 'Prijedlog: $value';
  }

  @override
  String get guideComposeLabel => 'Ili ga složite dodirom riječi iz teksta';

  @override
  String get guideComposePreview => 'Prikaz';

  @override
  String get guideComposeEmpty => 'Dodirnite jednu ili više riječi';

  @override
  String get guideComposeLimit => 'Najviše 8 riječi i 80 znakova';

  @override
  String guideTableMatchSemantics(String name) {
    return 'odgovara: $name';
  }

  @override
  String guideLine(int n, int total) {
    return 'Redak $n od $total';
  }

  @override
  String guideWordSelected(String word, int order) {
    return '$word, odabrano, $order';
  }

  @override
  String guideWordUnavailable(String word) {
    return '$word, nedostupno';
  }

  @override
  String guideWordUsedFor(String word, String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'apelacija',
      'producer': 'vinarija',
      'other': 'naziv',
    });
    return '$word, upotrijebljeno za polje: $_temp0';
  }

  @override
  String guideUsedMark(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'apelacija',
      'producer': 'vinarija',
      'other': 'naziv',
    });
    return '$_temp0';
  }

  @override
  String guideOtherYears(String years) {
    return 'U tekstu su i: $years';
  }

  @override
  String get guideWheelFromText => 'godina pronađena u tekstu';

  @override
  String get guideWheelTypeYear => 'Upišite godinu';

  @override
  String guideWheelConfirm(String year) {
    return 'Potvrdi $year';
  }

  @override
  String get guideNoVintage => 'Bez berbe';

  @override
  String guideSkippedNotice(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'Apelacija je preskočena',
      'producer': 'Vinarija je preskočena',
      'vintage': 'Berba je preskočena',
      'other': 'Naziv je preskočen',
    });
    return '$_temp0: upišite ručno ili nastavite vodič';
  }

  @override
  String guideSkippedMany(int count) {
    return 'Preskočena polja: $count. Upišite ih ili nastavite vodič';
  }

  @override
  String get guideInvalidValue =>
      'Ovaj tekst sadrži znakove koji se ne mogu spremiti';

  @override
  String get brandStudio => 'Bottazzini Softworks';

  @override
  String get suggestedMark => '✦ predloženo';

  @override
  String suggestedSemantics(String field, String value) {
    return '$field, $value, predloženo';
  }

  @override
  String get restoreSuggestion => 'Vrati prijedlog';

  @override
  String get restoreSuggestionDone => 'Prijedlog je vraćen';

  @override
  String get styleLabel => 'Stil';

  @override
  String styleGroupSemantics(String value, int index, int count) {
    return 'Stil, $value, $index od $count';
  }

  @override
  String get styleRedFresh => 'Svježe';

  @override
  String get styleRedMedium => 'Srednje';

  @override
  String get styleRedAge => 'Za čuvanje';

  @override
  String get styleRedLong => 'Dugo čuvanje';

  @override
  String get styleWhiteFresh => 'Svježe';

  @override
  String get styleWhiteMedium => 'Srednje';

  @override
  String get styleWhiteAge => 'Za čuvanje';

  @override
  String get styleRoseFresh => 'Svježe';

  @override
  String get styleClassicFresh => 'Svježe';

  @override
  String get styleClassicAge => 'Za čuvanje';

  @override
  String get styleTankFresh => 'Svježe';

  @override
  String get styleLambrusco => 'Lambrusco';

  @override
  String get styleSweetAromatic => 'Aromatično';

  @override
  String get styleSweetPassito => 'Prosušeno grožđe';

  @override
  String get styleSweetBotrytis => 'Plemenita plijesan';

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
  String get styleFortifiedOther => 'Ostalo';

  @override
  String get profileNameRFresh => 'Voćno crno';

  @override
  String get profileNameRMedium => 'Crno srednjeg tijela';

  @override
  String get profileNameRAge => 'Crno za čuvanje';

  @override
  String get profileNameRLong => 'Crno za dugo čuvanje';

  @override
  String get profileNameWFresh => 'Svježe aromatično bijelo';

  @override
  String get profileNameWMedium => 'Bijelo srednjeg tijela';

  @override
  String get profileNameWAge => 'Bijelo za čuvanje';

  @override
  String get profileNameRoseFresh => 'Svježe ružičasto';

  @override
  String get profileNameSpTank => 'Svježe pjenušavo metodom Charmat';

  @override
  String get profileNameLamFresh => 'Svježi Lambrusco';

  @override
  String get profileNameSpClassic => 'Svježe pjenušavo klasičnom metodom';

  @override
  String get profileNameSpClassicAge =>
      'Pjenušavo klasičnom metodom za čuvanje';

  @override
  String get profileNameSwAromatic => 'Mlado aromatično slatko vino';

  @override
  String get profileNameSwPassito => 'Slatko vino od prosušenog grožđa';

  @override
  String get profileNameSwBotrytis => 'Slatko vino s plemenitom plijesni';

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
  String get profileNameFortUnknown => 'Likersko, nepoznat stil';

  @override
  String get profileNameUnknown => 'Stil nije prepoznat';

  @override
  String estimateFromProfile(String profile, String denomination) {
    return 'Procjena prema profilu: $profile ($denomination)';
  }

  @override
  String estimateFromProfileType(String profile) {
    return 'Procjena prema profilu: $profile, prema vrsti';
  }

  @override
  String estimateFromProfileGrape(String profile, String grape) {
    return 'Procjena prema profilu: $profile, prema sorti $grape';
  }

  @override
  String get estimateFromEntryDateDisgorgement =>
      'Od datuma dodavanja: za bolju procjenu dodajte datum degoržiranja';

  @override
  String get estimateFromEntryDateBottling =>
      'Od datuma dodavanja: za bolju procjenu dodajte datum punjenja';

  @override
  String get styleToConfirmBanner =>
      '⚠︎ Stil treba potvrditi: procjena je okvirna';

  @override
  String get chooseTypePrompt => 'Odaberite vrstu';

  @override
  String estimateUpdatedAnnouncement(String summary) {
    return 'Procjena je ažurirana: $summary';
  }

  @override
  String get agingStartDisgorgement => 'Degoržiranje';

  @override
  String get agingStartBottling => 'Punjenje';

  @override
  String get agingStartMonth => 'Mjesec';

  @override
  String get agingStartYear => 'Godina';

  @override
  String get agingStartHint => 'Obično je na stražnjoj etiketi.';

  @override
  String get agingStartIncomplete => 'Unesite mjesec i godinu';

  @override
  String get agingStartFuture => 'Datum ne može biti u budućnosti';

  @override
  String get agingStartBeforeVintage => 'Ne može biti prije berbe';

  @override
  String get windowNoEnd => 'Spremno, kraj nije procijenjen';

  @override
  String get windowNoEndShort => 'kraj nije procijenjen';

  @override
  String windowDrinkWithin(String date) {
    return 'do $date';
  }

  @override
  String get levelNoEffect => 'Razina ne mijenja ovu procjenu';

  @override
  String get dashboardToConfirmTitle => 'Za potvrdu';

  @override
  String dashboardToConfirmCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vina',
      few: '$count vina',
      one: '$count vino',
    );
    return '$_temp0';
  }

  @override
  String aboutDbClassified(String percent) {
    return '$percent % vina s prepoznatom vrstom';
  }

  @override
  String get planTitle => 'Plan';

  @override
  String get planFree => 'Besplatni';

  @override
  String get planPlus => 'Plus';

  @override
  String get planPlusGift => 'Plus (dar)';

  @override
  String get planDevUnlockAll => 'DEV · Probni Plus';

  @override
  String get planDevSimulateFree => 'DEV · Simulirani besplatni plan';

  @override
  String get planDevSimulateExpired => 'DEV · Simulirani istekli Plus';

  @override
  String get planDiscoverPlus => 'Otkrij Plus';

  @override
  String get plusTitle => 'Vinoozy Plus';

  @override
  String get plusBenefitsTitle => 'Uz Plus';

  @override
  String get plusBenefitNoAds => 'Bez oglasa';

  @override
  String get plusBenefitNoLimit => 'Bez ograničenja broja vina u podrumu';

  @override
  String get plusComingSoon => 'Plus stiže uskoro';

  @override
  String get plusLoading => 'Učitavam cijene iz trgovine Google Play';

  @override
  String get plusStoreUnavailable =>
      'Cijene iz trgovine Google Play nije moguće učitati. Pokušajte kasnije.';

  @override
  String plusPriceMonthly(String price) {
    return '$price mjesečno';
  }

  @override
  String plusPriceAnnual(String price) {
    return '$price godišnje';
  }

  @override
  String get plusRenewal =>
      'Pretplata se automatski obnavlja po prikazanoj cijeni dok je ne otkažete u trgovini Google Play.';

  @override
  String get plusTerms =>
      'Plaćanje se tereti s vašeg Google Play računa kad potvrdite kupnju. Možete otkazati u bilo kojem trenutku: Plus ostaje aktivan do kraja već plaćenog razdoblja. Kad Plus završi, sva vaša vina ostaju.';

  @override
  String get plusRestore => 'Vrati kupnje';

  @override
  String get plusManage =>
      'Upravljaj pretplatom ili je otkaži u trgovini Google Play';

  @override
  String get plusActive => 'Plus je aktivan na ovom računu';

  @override
  String get plusActiveGift =>
      'Imate Plus na dar: bez naplate i bez obnavljanja.';

  @override
  String get plusPending =>
      'Plaćanje je na čekanju: Plus će biti aktivan kad ga Google Play potvrdi.';

  @override
  String get plusVerifying => 'Provjeravam kupnju';

  @override
  String get plusVerified =>
      'Kupnja je provjerena: Plus će biti aktivan za nekoliko sekundi.';

  @override
  String get plusPurchaseFailed => 'Kupnja nije dovršena. Pokušajte ponovno.';

  @override
  String get plusInvalidPurchase =>
      'Google Play nije potvrdio ovu kupnju za Vinoozy.';

  @override
  String get plusOwnedByOther =>
      'Ova pretplata već pripada drugom Vinoozy računu.';

  @override
  String get plusVerificationUnavailable =>
      'Kupnju trenutačno nije moguće provjeriti. Pokušajte kasnije: pretplata ostaje u trgovini Google Play.';

  @override
  String get capacityLimitTitle => 'Dosegnuto je ograničenje besplatnog plana';

  @override
  String capacityLimitBody(int limit) {
    return 'Besplatni plan uključuje najviše ovoliko različitih vina u podrumu: $limit. Vina koja već imate uvijek možete uređivati, označiti kao popijena i dodavati im boce. Da biste dodali novo, dovršite ili izbrišite neko vino ili prijeđite na Plus.';
  }

  @override
  String capacityLimitBodyComingSoon(int limit) {
    return 'Besplatni plan uključuje najviše ovoliko različitih vina u podrumu: $limit. Vina koja već imate uvijek možete uređivati, označiti kao popijena i dodavati im boce. Da biste dodali novo, dovršite ili izbrišite neko vino. Plus stiže uskoro.';
  }

  @override
  String get rejectedCapacityLimit =>
      'Nije sinkronizirano: prelazi ograničenje broja vina besplatnog plana. Promjena ostaje na ovom telefonu.';

  @override
  String get rejectedCapacityConflict =>
      'Nije sinkronizirano: podrum se istodobno promijenio na drugom uređaju. Promjena ostaje na ovom telefonu: pokušajte ponovno.';

  @override
  String writeRejectedCapacityLimit(String name) {
    return '$name: nije sinkronizirano, prijeđeno ograničenje besplatnog plana';
  }

  @override
  String writeRejectedCapacityConflict(String name) {
    return '$name: nije sinkronizirano, podrum se promijenio na drugom uređaju';
  }

  @override
  String get freeIntroTitle => 'Besplatni plan';

  @override
  String freeIntroLimit(int limit) {
    return 'Besplatno možete voditi najviše ovoliko različitih vina: $limit.';
  }

  @override
  String get freeIntroAds =>
      'Uz umjereno korištenje nema oglasa. Ako prijeđete mjesečni prag korištenja usluge, možda ćete povremeno vidjeti oglase koji pomažu pokriti troškove poslužitelja i sinkronizacije.';

  @override
  String get freeIntroNoAds => 'U početnoj verziji nema oglasa.';

  @override
  String get freeIntroPlus => 'Uz Plus uklanjate oglase i ograničenje podruma.';

  @override
  String get noticeGotIt => 'Razumijem';

  @override
  String get thresholdTitle => 'Oglasi pomažu da Vinoozy ostane besplatan';

  @override
  String get thresholdBody =>
      'Dosegnut je mjesečni prag korištenja bez oglasa. Odsad ćete možda povremeno vidjeti oglase: pomažu nam pokriti troškove poslužitelja i sinkronizacije, tako da Vinoozy ostaje besplatan.';

  @override
  String get thresholdReset =>
      'Brojanje kreće ispočetka sljedeći mjesec. Uz Plus aplikaciju koristite bez oglasa i bez ograničenja podruma.';

  @override
  String thresholdNextReset(String date) {
    return 'Sljedeće poništavanje: $date';
  }

  @override
  String get thresholdHowItWorks => 'Kako to funkcionira';

  @override
  String get thresholdHowItWorksBody =>
      'Prag ovisi o procjeni broja sinkronizacija s oblakom koje je ovaj račun obavio tijekom mjeseca. Samo korištenje izvan mreže ne stvara nove operacije u oblaku. Oglasi se prikazuju najviše jednom dnevno, samo na Pregledu, i nikad dok spremate ili izvozite podatke.';

  @override
  String get adLabel => 'Oglas';

  @override
  String get devToolsTitle => 'Razvojni alati';

  @override
  String get devUnlockAll => 'Otključaj sve — probni Plus';

  @override
  String get devSimulateFree => 'Simuliraj besplatni plan';

  @override
  String get devSimulateExpired => 'Simuliraj istekli Plus';

  @override
  String get devRestore => 'Vrati uobičajeno stanje';

  @override
  String get devNoOverride => 'Nijedna simulacija nije aktivna';

  @override
  String get devApplied => 'Scenarij je primijenjen i u emulatoru Firestore';

  @override
  String get devIncomplete =>
      'Nepotpuna simulacija: emulator Firestore nije potvrdio probno pravo. Pravila poslužitelja ne vide ovaj scenarij.';

  @override
  String get devNotice =>
      'Samo razvojne verzije s emulatorom: bez plaćanja, tokena i računa.';

  @override
  String get settingsTitle => 'Postavke';

  @override
  String get settingsGuide => 'Ponovno pogledaj vodič';

  @override
  String get settingsShare => 'Podijeli aplikaciju';

  @override
  String get settingsRate => 'Ocijeni aplikaciju';

  @override
  String get settingsFeedback => 'Pošalji povratne informacije';

  @override
  String get settingsFaq => 'Česta pitanja';

  @override
  String get settingsShareFailed =>
      'Dijeljenje se nije moglo otvoriti. Pokušajte ponovno';

  @override
  String get settingsRateFailed =>
      'Google Play se nije mogao otvoriti. Pokušajte ponovno';

  @override
  String get guideAddTitle => 'Dodajte vino';

  @override
  String get guideAddBody =>
      'Dodirnite Dodaj i stavite bocu u svoj podrum. Za početak je dovoljno ime.';

  @override
  String get guideLabelTitle => 'Pročitajte etiketu';

  @override
  String get guideLabelBody =>
      'Pod Dodaj možete i fotografirati etiketu: Vinoozy čita ime, berbu i oznaku podrijetla, a vi ih provjerite prije spremanja.';

  @override
  String get guideTabsTitle => 'Pregled, Podrum, Povijest';

  @override
  String get guideTabsBody =>
      'Pregled vam govori koja vina otvoriti sada, Podrum prikazuje vaše boce, a Povijest čuva one koje ste popili.';

  @override
  String get guideMenuTitle => 'Izbornik podruma';

  @override
  String get guideMenuBody =>
      'Ovdje su vaš profil, osobe s kojima dijelite podrum, popijena vina i Postavke, gdje možete ponovno pogledati ovaj vodič.';

  @override
  String get guideDone => 'Gotovo';

  @override
  String guideStepOf(int step, int count) {
    return 'Korak $step od $count';
  }

  @override
  String get hintDashboard =>
      'Ovdje vidite koja su vina spremna za pijenje sada, a koja je bolje još čuvati.';

  @override
  String get hintHistory =>
      'Svaka boca koju popijete završi ovdje, s vašom ocjenom i bilješkama.';

  @override
  String get hintAddWine =>
      'Počnite s imenom: berba, vrsta i oznaka podrijetla čine razdoblje pijenja preciznijim.';

  @override
  String get shareAppSubject => 'Vinoozy, vaš vinski podrum';

  @override
  String shareAppMessage(String link) {
    return 'Svoj vinski podrum vodim u aplikaciji Vinoozy: kaže mi kada je svaka boca u najboljem trenutku. Isprobajte je: $link';
  }

  @override
  String get feedbackSubject => 'Povratne informacije o aplikaciji Vinoozy';

  @override
  String get feedbackTechHeader => 'Tehnički podaci (molimo ne brisati):';

  @override
  String get feedbackNoEmailTitle => 'Nema aplikacije za e-poštu';

  @override
  String feedbackNoEmailBody(String email) {
    return 'Na ovom telefonu nema aplikacije za e-poštu. Pišite nam na $email';
  }

  @override
  String get feedbackCopy => 'Kopiraj';

  @override
  String get feedbackCopied => 'Adresa je kopirana';

  @override
  String get faqAddQuestion => 'Kako ručno dodati vino?';

  @override
  String get faqAddAnswer =>
      'U Podrumu dodirnite Dodaj, zatim Upiši. Obavezno je samo ime; berba, vrsta, zemlja i oznaka podrijetla poboljšavaju procjenu. Spremite i vino je u podrumu.';

  @override
  String get faqLabelQuestion => 'Kako pročitati etiketu, i s Google Lensom?';

  @override
  String get faqLabelAnswer =>
      'Dodirnite Dodaj i fotografirajte prednju i stražnju stranu: Vinoozy čita etiketu na samom telefonu. U Google Lensu označite tekst i podijelite ga s aplikacijom Vinoozy ili ga kopirajte i u obrascu upotrijebite Zalijepi iz Lensa. Uvijek provjerite polja prije spremanja.';

  @override
  String get faqWindowQuestion =>
      'Kako se računa najbolji trenutak za pijenje i mogu li ga promijeniti?';

  @override
  String get faqWindowAnswer =>
      'Vinoozy procjenjuje razdoblje (početak, vrhunac, kraj) prema vrsti, oznaci podrijetla, berbi i razini vina. To je okvirno: važno je i kako je boca čuvana. Otvorite vino i dodirnite Ispravi da postavite svoj datum ili promijenite Razinu.';

  @override
  String get faqOfflineQuestion => 'Radi li bez interneta?';

  @override
  String get faqOfflineAnswer =>
      'Da. Vina možete dodavati, uređivati i piti bez veze: sve se sprema na telefonu i sinkronizira s vašim računom čim se veza vrati.';

  @override
  String get faqShareQuestion => 'Kako podijeliti svoj podrum?';

  @override
  String get faqShareAnswer =>
      'U izborniku Podruma otvorite Osobe i pozovite nekoga njegovom Google adresom e-pošte, samo za čitanje ili s uređivanjem. Ta osoba instalira Vinoozy i prijavi se tim računom.';

  @override
  String get faqPlusQuestion => 'Što uključuje besplatni plan, a što je Plus?';

  @override
  String faqPlusAnswer(int limit) {
    return 'Besplatni plan uključuje do $limit različitih vina u podrumu, uz povremene oglase samo u Pregledu. Vinoozy Plus uklanja ograničenje i oglase.';
  }

  @override
  String get faqDrinkQuestion =>
      'Zašto bilježiti što sam popio i kakvo je bilo?';

  @override
  String get faqDrinkAnswer =>
      'Povijest čuva što ste popili i koliko vam se svidjelo. Kad kažete kakva je boca bila (još premlado, baš kako treba, prošlo vrhunac), Vinoozy ispravlja procjenu za isto vino.';

  @override
  String get faqDeleteQuestion => 'Kako izbrisati svoj račun?';

  @override
  String get faqDeleteAnswer =>
      'Otvorite Profil i dodirnite Izbriši račun. Potrebna je veza, a zatim se ponovno prijavite Googleom radi potvrde. Podrum, Povijest i dijeljenja trajno se brišu.';

  @override
  String get faqNotFound => 'Niste pronašli odgovor? Pišite nam';
}
