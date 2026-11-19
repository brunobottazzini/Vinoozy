// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Norwegian Bokmål (`nb`).
class AppLocalizationsNb extends AppLocalizations {
  AppLocalizationsNb([String locale = 'nb']) : super(locale);

  @override
  String get appTitle => 'Vinoozy';

  @override
  String get signInTagline => 'Vinkjelleren din, til rett tid';

  @override
  String get signInWithGoogle => 'Fortsett med Google';

  @override
  String get signInInProgress => 'Logger inn';

  @override
  String get signInFailed => 'Innloggingen mislyktes';

  @override
  String get signInNeedsNetwork =>
      'Du må ha nettforbindelse første gang du logger inn';

  @override
  String get signInSessionExpired => 'Økten din er utløpt: logg inn på nytt';

  @override
  String get retry => 'Prøv igjen';

  @override
  String get cancel => 'Avbryt';

  @override
  String blockedMessage(String email) {
    return 'Det finnes endringer fra $email som ennå ikke er lagret i skyen: logg inn med den kontoen og koble til nettet';
  }

  @override
  String blockedSignInWith(String email) {
    return 'Logg inn med $email';
  }

  @override
  String blockedDiscard(String email) {
    return 'Slett ulagrede endringer fra $email';
  }

  @override
  String get discardDialogTitle => 'Slette endringene?';

  @override
  String discardDialogBody(int count, String email) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count viner fra $email er ennå ikke i skyen og blir slettet fra denne telefonen.',
      one:
          '1 vin fra $email er ennå ikke i skyen og blir slettet fra denne telefonen.',
    );
    return '$_temp0';
  }

  @override
  String get discardConfirm => 'Slett';

  @override
  String get resetFailed => 'Kunne ikke tømme dataene på denne telefonen';

  @override
  String get restartRequired => 'Start appen på nytt for å fullføre';

  @override
  String get restartCloseApp => 'Lukk appen';

  @override
  String get startupFailed => 'Appen kunne ikke starte';

  @override
  String get cellarTitle => 'Kjeller';

  @override
  String get defaultCellarName => 'Min kjeller';

  @override
  String get cellarLoading => 'Klargjør kjelleren';

  @override
  String get cellarSetupFailed => 'Kunne ikke klargjøre kjelleren';

  @override
  String get cellarEmpty => 'Kjelleren din er tom';

  @override
  String get addWine => 'Legg til';

  @override
  String get estimatePending => 'Anslag kommer';

  @override
  String get noVintage => 'Uten årgang';

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
  String get syncOffline => 'Frakoblet - synkronisering venter';

  @override
  String writeRejected(String name) {
    return 'Endringen er ikke tillatt: $name';
  }

  @override
  String get saveFailed => 'Kunne ikke lagre, prøv igjen';

  @override
  String wineNotSaved(String name) {
    return 'Vinen $name ble ikke lagret i skyen';
  }

  @override
  String get addAgain => 'Legg til på nytt';

  @override
  String get ignore => 'Ignorer';

  @override
  String get addWineTitle => 'Skriv';

  @override
  String get wineNameLabel => 'Vin';

  @override
  String get vintageLabel => 'Årgang';

  @override
  String get quantityLabel => 'Antall';

  @override
  String get decreaseQuantity => 'Reduser antall';

  @override
  String get increaseQuantity => 'Øk antall';

  @override
  String get save => 'Lagre';

  @override
  String get nameRequired => 'Skriv navnet på vinen';

  @override
  String get nameTooLong => 'Maks 120 tegn';

  @override
  String vintageRange(String year) {
    return 'Årgang mellom 1900 og $year';
  }

  @override
  String get offAttribution => 'Data fra Open Food Facts (ODbL)';

  @override
  String get dashboardTitle => 'Oversikt';

  @override
  String dashboardTotalBottles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count flasker i kjelleren',
      one: '1 flaske i kjelleren',
    );
    return '$_temp0';
  }

  @override
  String get dashboardSyncing => 'Synkroniserer kjelleren…';

  @override
  String get dashboardAddFirstWine => 'Legg til din første vin';

  @override
  String get drinkSoonTitle => 'Drikk snart';

  @override
  String get drinkSoonEmpty => 'Ingen flasker må drikkes snart';

  @override
  String drinkSoonUntil(String year) {
    return 'innen $year';
  }

  @override
  String drinkSoonSeeAll(int count) {
    return 'Se alle ($count)';
  }

  @override
  String get statusChartTitle => 'Status for flaskene';

  @override
  String get statusWaiting => 'bør vente';

  @override
  String get statusReady => 'drikkeklar';

  @override
  String get statusDrinkSoon => 'drikk snart';

  @override
  String get statusPastWindow => 'vinduet er over';

  @override
  String toEstimateNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count flasker uten anslag',
      one: '1 flaske uten anslag',
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
  String get openListHint => 'Åpne listen';

  @override
  String get peakChartTitle => 'Toppår';

  @override
  String get peakPast => 'toppen passert';

  @override
  String get peakBeyond => 'senere';

  @override
  String get breakdownTypeTitle => 'Flasker etter type';

  @override
  String get breakdownRegionTitle => 'Flasker etter region';

  @override
  String get breakdownType => 'Type';

  @override
  String get breakdownRegion => 'Region';

  @override
  String get familyRed => 'rød';

  @override
  String get familyWhite => 'hvit';

  @override
  String get familyRose => 'rosé';

  @override
  String get familySparkling => 'musserende';

  @override
  String get familySweet => 'søt';

  @override
  String get breakdownUnspecified => 'ikke oppgitt';

  @override
  String get breakdownOtherRegions => 'andre';

  @override
  String get ok => 'OK';

  @override
  String get cellarMenu => 'Kjellermeny';

  @override
  String get sharingPeopleTitle => 'Personer';

  @override
  String get sharingInviteTitle => 'Inviter en person';

  @override
  String get sharingEmailLabel => 'Google-e-postadresse';

  @override
  String get sharingPermissionRead => 'Kun lese';

  @override
  String get sharingPermissionReadHint =>
      'Ser viner, anslag, oversikt og drukne flasker';

  @override
  String get sharingPermissionEdit => 'Kan redigere';

  @override
  String get sharingPermissionEditHint =>
      'Legger også til og endrer viner og noterer drukne flasker';

  @override
  String get sharingRoleOwner => 'eier';

  @override
  String get sharingInviteButton => 'Inviter';

  @override
  String sharingPlacesUsed(int used, int max) {
    return '$used/$max personer';
  }

  @override
  String get sharingInvalidEmail => 'Skriv inn en gyldig e-postadresse';

  @override
  String get sharingSelfInvite => 'Du kan ikke invitere deg selv';

  @override
  String get sharingAlreadyInvited => 'Denne personen er allerede invitert';

  @override
  String sharingLimitReached(int max) {
    return 'Du har nådd grensen på $max personer';
  }

  @override
  String get sharingNotOwner => 'Du kan ikke endre delingen av denne kjelleren';

  @override
  String get sharingNotFound => 'Denne personen står ikke lenger på listen';

  @override
  String get sharingFailed => 'Det gikk ikke, prøv igjen';

  @override
  String get sharingInviteFailed => 'Invitasjonen mislyktes. Prøv igjen';

  @override
  String get sharingOfflineHint =>
      'Du må ha nettforbindelse for å administrere deling';

  @override
  String get sharingStatusInvited => 'invitert';

  @override
  String get sharingStatusActive => 'aktiv';

  @override
  String get sharingStatusRevoked => 'trukket tilbake';

  @override
  String get sharingStatusLeft => 'har forlatt';

  @override
  String sharingMemberSemantics(String name, String permission, String status) {
    return '$name, $permission, $status';
  }

  @override
  String get sharingClosedSection => 'Avsluttet tilgang';

  @override
  String get sharingNobody => 'Ingen andre ser denne kjelleren ennå';

  @override
  String sharingChangePermission(String name) {
    return 'Endre tillatelsen til $name';
  }

  @override
  String get sharingRevoke => 'Trekk tilbake';

  @override
  String sharingRevokeTitle(String name) {
    return 'Trekke tilbake tilgangen til $name?';
  }

  @override
  String sharingRevokeConfirmLabel(String name) {
    return 'Skriv $name for å bekrefte';
  }

  @override
  String get sharingRevokeDisabledHint => 'Aktiveres når navnet stemmer';

  @override
  String get sharingReinvite => 'Inviter på nytt';

  @override
  String get sharingDeleteForGood => 'Slett for godt';

  @override
  String sharingOwnedBy(String owner) {
    return 'Kjelleren til $owner';
  }

  @override
  String get sharingYourCellar => 'Din kjeller';

  @override
  String sharingYourPermission(String permission) {
    return 'Din tillatelse: $permission';
  }

  @override
  String sharingSwitcherSemantics(String cellar, String permission) {
    return '$cellar, $permission. Trykk for å bytte kjeller';
  }

  @override
  String get sharingLeave => 'Forlat denne kjelleren';

  @override
  String sharingLeaveTitle(String owner) {
    return 'Forlate kjelleren til $owner?';
  }

  @override
  String sharingLeaveBody(String owner) {
    return 'Du vil ikke lenger se den. $owner kan invitere deg på nytt.';
  }

  @override
  String get sharingLeaveConfirm => 'Forlat';

  @override
  String sharingSharedNotice(String owner) {
    return '$owner har delt kjelleren sin med deg';
  }

  @override
  String sharingAccessLost(String owner) {
    return 'Du har ikke lenger tilgang til kjelleren til $owner';
  }

  @override
  String sharingWritesLost(String owner) {
    return 'Noen endringer i kjelleren til $owner ble ikke lagret fordi du ikke lenger har tilgang';
  }

  @override
  String get sharingSomeone => 'noen';

  @override
  String get sharingShareSubject => 'Invitasjon til Vinoozy';

  @override
  String sharingShareMessage(
    String owner,
    String cellar,
    String link,
    String email,
  ) {
    return '$owner har invitert deg til kjelleren «$cellar» i Vinoozy. Installer appen fra $link og logg inn med Google-kontoen $email: bruk akkurat denne adressen.';
  }

  @override
  String get cellarSearchHint => 'Søk etter navn eller produsent';

  @override
  String get cellarFilterStatus => 'Status';

  @override
  String get cellarFilterType => 'Type';

  @override
  String get statusToEstimate => 'Uten anslag';

  @override
  String get filterTypeUnspecified => 'Ikke oppgitt';

  @override
  String get cellarNoMatches => 'Ingen vin med disse filtrene';

  @override
  String get cellarClearFilters => 'Fjern filtre';

  @override
  String get cellarArchiveTitle => 'Drukket';

  @override
  String get cellarArchiveEmpty => 'Ingen viner er drukket opp ennå';

  @override
  String get cellarArchiveFailed =>
      'Kunne ikke laste inn vinene som er drukket opp';

  @override
  String get wineDrink => 'Drukket';

  @override
  String wineDrinkTooltip(String name) {
    return 'Merk en flaske $name som drukket';
  }

  @override
  String confidenceLabel(String level) {
    return 'Sikkerhet: $level';
  }

  @override
  String get confidenceHigh => 'høy';

  @override
  String get confidenceMedium => 'middels';

  @override
  String get confidenceLow => 'lav';

  @override
  String get windowStartLabel => 'Start';

  @override
  String get windowPeakLabel => 'Topp';

  @override
  String get windowEndLabel => 'Slutt';

  @override
  String estimateSourceLabel(String source) {
    return 'Kilde: $source';
  }

  @override
  String get estimateSourceCatalog => 'vindatabase';

  @override
  String get estimateSourceType => 'anslag for typen';

  @override
  String get estimateSourceCorrected =>
      'anslag justert etter de drukne flaskene dine';

  @override
  String get estimateDisclaimer =>
      'Veiledende anslag: det avhenger også av hvordan flasken er oppbevart';

  @override
  String get estimateUnavailable => 'Ingen anslag tilgjengelig';

  @override
  String get pairingsTitle => 'Passer til';

  @override
  String get pairingsGeneric => 'generelle matforslag for typen';

  @override
  String get pairingBraisedRedMeat => 'Braisert rødt kjøtt';

  @override
  String get pairingGrilledRedMeat => 'Grillet rødt kjøtt';

  @override
  String get pairingGame => 'Vilt';

  @override
  String get pairingRoastPoultry => 'Stekt fjærfe';

  @override
  String get pairingPoultry => 'Fjærfe';

  @override
  String get pairingPork => 'Svinekjøtt';

  @override
  String get pairingCuredMeats => 'Spekemat';

  @override
  String get pairingPastaMeatSauce => 'Pasta med kjøttsaus';

  @override
  String get pairingMushroomsTruffle => 'Sopp og trøffel';

  @override
  String get pairingAgedCheese => 'Lagret ost';

  @override
  String get pairingFreshCheese => 'Ferskost';

  @override
  String get pairingBlueCheese => 'Blåmuggost';

  @override
  String get pairingFish => 'Fisk';

  @override
  String get pairingSeafood => 'Skalldyr';

  @override
  String get pairingRawSeafood => 'Rå fisk og skalldyr';

  @override
  String get pairingFriedFood => 'Frityrstekt';

  @override
  String get pairingVegetables => 'Grønnsaker';

  @override
  String get pairingRisotto => 'Risotto';

  @override
  String get pairingPizza => 'Pizza';

  @override
  String get pairingAperitif => 'Aperitiff';

  @override
  String get pairingPastries => 'Bakverk';

  @override
  String get pairingDryBiscuits => 'Tørre småkaker';

  @override
  String get pairingChocolate => 'Sjokolade';

  @override
  String get pairingDriedFruit => 'Nøtter og tørket frukt';

  @override
  String get pairingSpicyDishes => 'Krydrede retter';

  @override
  String get recentDrinksTitle => 'Sist drukket';

  @override
  String get noDrinksYet => 'Ingenting drukket ennå';

  @override
  String get wineEdit => 'Rediger';

  @override
  String get wineDelete => 'Slett';

  @override
  String get wineFinished => 'Tom: ingen flasker igjen';

  @override
  String get wineLoadFailed => 'Kunne ikke åpne vinen';

  @override
  String get wineNotFound => 'Denne vinen finnes ikke lenger';

  @override
  String drinkDone(String name) {
    return 'Merket som drukket: $name';
  }

  @override
  String get drinkUndo => 'Angre';

  @override
  String get drinkAddNotes => 'Legg til vurdering og notater';

  @override
  String get nothingToUndo => 'Det er ikke mer å angre';

  @override
  String get cellarUndoRejected =>
      'Kunne ikke angre: flasken er fortsatt merket som drukket';

  @override
  String get cellarDeleteFailed =>
      'Slettingen er ikke ferdig ennå: den fullføres så snart som mulig';

  @override
  String get duplicateFull =>
      'Denne vinen har allerede 99 flasker: det går ikke å legge til flere.';

  @override
  String get recordSheetTitle => 'Vurdering og notater';

  @override
  String get recordRatingLabel => 'Vurdering';

  @override
  String ratingStar(int n) {
    return 'Vurdering $n av 5';
  }

  @override
  String get recordNotesLabel => 'Notater';

  @override
  String get recordNotesTooLong => 'Maks 1000 tegn';

  @override
  String recordDateLabel(String date) {
    return 'Dato: $date';
  }

  @override
  String get recordDateInvalid =>
      'Datoen kan ikke være i fremtiden eller før årgangen';

  @override
  String get recordConditionTitle => 'Hvordan var den?';

  @override
  String get conditionTooYoung => 'Fortsatt for ung';

  @override
  String get conditionJustRight => 'Akkurat passe';

  @override
  String get conditionPastPeak => 'Forbi toppen';

  @override
  String get recordNoCondition => 'Ikke noe svar';

  @override
  String get producerLabel => 'Produsent (valgfritt)';

  @override
  String get producerTooLong => 'Maks 120 tegn';

  @override
  String producerAddNew(String name) {
    return 'Legg til «$name» som ny produsent';
  }

  @override
  String get wineTypeLabel => 'Type';

  @override
  String get typeRedLight => 'Lett rødvin';

  @override
  String get typeRedStructured => 'Fyldig rødvin';

  @override
  String get typeWhite => 'Hvitvin';

  @override
  String get typeRose => 'Rosé';

  @override
  String get typeSparklingClassic => 'Musserende, tradisjonell metode';

  @override
  String get typeSparklingTank => 'Musserende, tankmetode';

  @override
  String get typeSweet => 'Søt vin';

  @override
  String get typeFortified => 'Sterkvin';

  @override
  String get suggestionFromCellar => 'I kjelleren din';

  @override
  String get suggestionsLabel => 'Forslag';

  @override
  String get duplicateTitle => 'Allerede i kjelleren';

  @override
  String duplicateBody(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count flasker',
      one: '1 flaske',
      zero: 'ingen flasker',
    );
    return '$name finnes allerede, med $_temp0. Vil du legge de nye flaskene dit?';
  }

  @override
  String duplicateAdd(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Legg til $count flasker',
      one: 'Legg til 1 flaske',
    );
    return '$_temp0';
  }

  @override
  String get duplicateBanner => 'Mulig duplikat';

  @override
  String get duplicateMerge => 'Slå sammen';

  @override
  String get duplicateDeleteHint =>
      'Slett denne oppføringen hvis den er et duplikat';

  @override
  String get mergeTitle => 'Slå sammen de to oppføringene?';

  @override
  String get mergeBody =>
      'Flaskene i denne oppføringen flyttes til den eldste, og så slettes denne oppføringen.';

  @override
  String get editWineTitle => 'Rediger vin';

  @override
  String get editDuplicate =>
      'Det finnes allerede en vin med samme navn, produsent og årgang';

  @override
  String deleteWineTitle(String name) {
    return 'Slette $name?';
  }

  @override
  String get deleteWineBody =>
      'Vinen og alle noteringer om drukne flasker slettes. Dette kan ikke angres.';

  @override
  String get historyTitle => 'Historikk';

  @override
  String get historyEmpty => 'Her finner du flaskene du har drukket';

  @override
  String get historyLoadFailed => 'Kunne ikke laste inn historikken';

  @override
  String drankOnLabel(String date) {
    return 'Drukket $date';
  }

  @override
  String get addChoiceTitle => 'Legg til en vin';

  @override
  String get addChoicePhoto => 'Ta et bilde';

  @override
  String get addChoiceImport => 'Importer et bilde';

  @override
  String get addChoiceWrite => 'Skriv';

  @override
  String get labelReading => 'Jeg leser etiketten…';

  @override
  String get labelRecognized => 'Jeg kjente igjen:';

  @override
  String get labelCorrect => 'Rett';

  @override
  String get labelConfirm => 'Bekreft';

  @override
  String get labelUnreadable => 'Jeg klarer ikke å lese etiketten';

  @override
  String get labelWriteByHand => 'Skriv selv';

  @override
  String get labelNotFound => 'Jeg fant ikke vinen: sjekk opplysningene';

  @override
  String get labelCameraDenied =>
      'For å lese etiketten trenger jeg tilgang til kameraet';

  @override
  String get labelPhotosDenied =>
      'For å lese etiketten trenger jeg tilgang til bildene';

  @override
  String get labelOpenSettings => 'Åpne innstillinger';

  @override
  String get labelCameraUnavailable => 'Kameraet er ikke tilgjengelig';

  @override
  String get labelBarcodeNotFound =>
      'Jeg leste strekkoden, men finner ikke vinen';

  @override
  String get labelBarcodeFrontHint => 'Ta et bilde av forsiden av etiketten';

  @override
  String get labelSharedNotAllowed =>
      'Du kan ikke legge til viner i denne kjelleren';

  @override
  String get labelSharedFirstOnly => 'Jeg brukte bare det første bildet';

  @override
  String get labelSharedExpired =>
      'Det delte bildet kunne ikke leses: del det på nytt';

  @override
  String get labelReplaceTitle =>
      'Du har en vin som ikke er lagret. Vil du lese det nye bildet?';

  @override
  String get labelReplaceRead => 'Les det nye bildet';

  @override
  String get labelReplaceKeep => 'Fortsett med den åpne';

  @override
  String get labelWineAdded => 'Vinen er lagt til i kjelleren';

  @override
  String get onboardingPage1Title => 'Vinkjelleren din i lomma';

  @override
  String get onboardingPage1Body =>
      'Legg til flaskene dine ved å skrive dem inn eller med et bilde av etiketten, også uten nett.';

  @override
  String get onboardingPage2Title => 'Til rett tid';

  @override
  String get onboardingPage2Body =>
      'Vinoozy anslår når hver vin er på sitt beste, og forteller deg hvilke du bør åpne først.';

  @override
  String get onboardingPage3Title => 'Sammen';

  @override
  String get onboardingPage3Body =>
      'Del kjelleren din med opptil to personer, og ta vare på historikken for hver flaske du drikker.';

  @override
  String get onboardingSkip => 'Hopp over';

  @override
  String get onboardingNext => 'Neste';

  @override
  String get onboardingStart => 'Start';

  @override
  String onboardingPageOf(int page) {
    return 'Side $page av 3';
  }

  @override
  String get profileTitle => 'Profil';

  @override
  String get profilePhoto => 'Profilbilde';

  @override
  String get profileSignOut => 'Logg ut';

  @override
  String get profileDeleteAccount => 'Slett konto';

  @override
  String get profilePrivacy => 'Personvernerklæring';

  @override
  String get profilePrivacyBody =>
      'Du kan lese personvernerklæringen på denne adressen:';

  @override
  String get profileOpenLink => 'Åpne i nettleseren';

  @override
  String get profileOpenLinkFailed =>
      'Kunne ikke åpne siden. Du kan kopiere lenken og åpne den i nettleseren.';

  @override
  String get profileCopyLink => 'Kopier lenke';

  @override
  String get profileLinkCopied => 'Lenken er kopiert';

  @override
  String get close => 'Lukk';

  @override
  String get signOutConfirmTitle => 'Vil du logge ut?';

  @override
  String signOutPendingWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Du har $count endringer som ikke er lagret ennå. Hvis du logger ut og en annen konto logger inn, går de tapt.',
      one: 'Du har 1 endring som ikke er lagret ennå. Hvis du logger ut og en annen konto logger inn, går den tapt.',
    );
    return '$_temp0';
  }

  @override
  String get signOutStayAndSync => 'Bli og synkroniser';

  @override
  String get signOutAnyway => 'Logg ut likevel';

  @override
  String get syncAllSaved => 'Alt er lagret';

  @override
  String syncStillPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count endringer gjenstår å lagre: sjekk nettet',
      one: '1 endring gjenstår å lagre: sjekk nettet',
    );
    return '$_temp0';
  }

  @override
  String get signOutFailed => 'Kunne ikke logge ut. Prøv igjen';

  @override
  String get signInAccountDeleted => 'Kontoen er slettet';

  @override
  String get deleteAccountIntro => 'Dette slettes for godt:';

  @override
  String get deleteAccountItemCellar =>
      'Kjelleren din, med vinene og historikken';

  @override
  String get deleteAccountItemShares =>
      'Delingene du har gitt: de inviterte personene mister tilgangen';

  @override
  String get deleteAccountItemMemberships =>
      'Deltakelsen din i andres kjellere: de drukne flaskene dine blir stående der uten navnet ditt';

  @override
  String get deleteAccountItemProfile => 'Profilen din';

  @override
  String deleteAccountPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Du har $count endringer som ikke er lagret ennå: de lagres og slettes deretter sammen med resten',
      one: 'Du har 1 endring som ikke er lagret ennå: den lagres og slettes deretter sammen med resten',
    );
    return '$_temp0';
  }

  @override
  String get deleteAccountConfirmWord => 'SLETT';

  @override
  String deleteAccountTypeWord(String word) {
    return 'Skriv $word for å bekrefte';
  }

  @override
  String get deleteAccountReauthHint =>
      'Deretter logger du inn på nytt med Google for å bekrefte at det er deg.';

  @override
  String get deleteAccountForever => 'Slett for alltid';

  @override
  String get deleteAccountNeedsNetwork =>
      'Koble til internett for å slette kontoen';

  @override
  String get deleteAccountSameAccount =>
      'Slettingen krever at du logger inn med samme konto';

  @override
  String get deletionTitle => 'Sletter kontoen';

  @override
  String get deletionStepPreparePhone => 'Lagrer ventende endringer';

  @override
  String get deletionStepMarkStarted => 'Starter slettingen';

  @override
  String get deletionStepLeaveOtherCellars => 'Forlater andres kjellere';

  @override
  String get deletionStepCloseOwnInvitations => 'Avslutter delingene dine';

  @override
  String get deletionStepDeleteWinesAndRecords => 'Sletter viner og historikk';

  @override
  String get deletionStepDeleteCellar => 'Sletter kjelleren';

  @override
  String get deletionStepDeleteProfileAndUser => 'Sletter profilen og kontoen';

  @override
  String get deletionStepCleanUpPhone => 'Rydder opp på denne telefonen';

  @override
  String deletionStepAnnounce(int step, String label) {
    return 'Trinn $step av 8: $label';
  }

  @override
  String deletionDeletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count viner og drukne flasker slettet',
      one: '1 vin eller drukket flaske slettet',
    );
    return '$_temp0';
  }

  @override
  String get deletionResumeHint =>
      'En sletting av denne kontoen er ikke fullført. Logg inn på nytt med Google for å fullføre den.';

  @override
  String get deletionContinue => 'Fortsett';

  @override
  String get deletionOffline => 'Koble til internett for å fullføre slettingen';

  @override
  String get deletionPendingWrites =>
      'Jeg klarer ikke å lagre de ventende endringene. Prøv igjen';

  @override
  String get deletionFailed => 'Kunne ikke fullføre slettingen. Prøv igjen';

  @override
  String get uxCountryLabel => 'Land';

  @override
  String get uxCountryOther => 'Annet land…';

  @override
  String get uxCountryNone => 'Ingen land';

  @override
  String get uxAllCountriesTitle => 'Alle land og territorier';

  @override
  String get uxAllCountriesSearch => 'Søk etter et land';

  @override
  String get uxAllCountriesRare => 'Sjeldne for vin';

  @override
  String get uxAllCountriesAll => 'Alle, fra A til Å';

  @override
  String get uxAllCountriesNone => 'Fant ingen land';

  @override
  String get uxRegionLabel => 'Region';

  @override
  String uxRegionOf(String country) {
    return 'Region · $country';
  }

  @override
  String get uxRegionOther => 'Annen region';

  @override
  String get uxRegionFieldLabel => 'Skriv regionen';

  @override
  String get uxRegionTooLong => 'Maks 120 tegn';

  @override
  String get uxDrinkAction => 'Drakk en';

  @override
  String uxDrinkActionTooltip(String name) {
    return 'Jeg har drukket en flaske $name';
  }

  @override
  String get uxDrinkActionDetail => 'Jeg har drukket en flaske';

  @override
  String get uxDrinkSheetLabel => 'Bekreft drukket flaske';

  @override
  String get uxDrinkSheetBottles => 'Flasker';

  @override
  String uxDrinkSheetBottlesChange(int before, int after) {
    return 'Flasker: fra $before til $after';
  }

  @override
  String get uxDrinkSheetRating => 'Hvordan var den? (valgfritt)';

  @override
  String uxDrinkSheetStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stjerner av 5',
      one: '1 stjerne av 5',
    );
    return '$_temp0';
  }

  @override
  String get uxDrinkSheetConfirm => 'Ja, den er drukket';

  @override
  String get uxRemoveBottle => 'Fjern en flaske uten notering';

  @override
  String get uxRemoveBottleTitle => 'Fjerne en flaske?';

  @override
  String uxRemoveBottleBody(String name) {
    return 'En flaske $name fjernes uten å bli notert som drukket.';
  }

  @override
  String get uxRemoveBottleConfirm => 'Fjern';

  @override
  String get uxIdealTitle => 'Ideelt tidspunkt';

  @override
  String uxIdealUntil(String year) {
    return 'Anbefalt til og med $year';
  }

  @override
  String uxIdealUntilPast(String year) {
    return 'Anbefalt til og med $year: det er passert';
  }

  @override
  String uxIdealBest(String start, String end) {
    return 'På sitt beste fra $start til $end';
  }

  @override
  String uxIdealBar(String start, String end) {
    return 'Drikkevindu fra $start til $end';
  }

  @override
  String get uxIdealDisclaimer =>
      '⚠︎ Veiledende: et anslag ut fra type, appellasjon og årgang. Oppbevaring og den enkelte flasken kan endre det.';

  @override
  String get uxIdealUnavailableHint =>
      'Oppgi årgang og type for å få et anslag.';

  @override
  String uxDashboardDrinkNow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count å drikke nå',
      one: '1 å drikke nå',
    );
    return '$_temp0';
  }

  @override
  String get uxFamilyRed => 'Rød';

  @override
  String get uxFamilyWhite => 'Hvit';

  @override
  String get uxFamilyRose => 'Rosé';

  @override
  String get uxFamilySparkling => 'Musserende';

  @override
  String get uxFamilySweet => 'Søt';

  @override
  String get labelBackTitle => 'Nå baksiden';

  @override
  String get labelBackHint =>
      'På baksiden står som regel strekkoden, produsenten og årgangen: de hjelper med å finne vinen.';

  @override
  String get labelBackTake => 'Ta bilde av baksiden';

  @override
  String get labelBackGallery => 'Velg fra galleriet';

  @override
  String get labelBackSkip => 'Hopp over';

  @override
  String get labelStepFront => 'Forside';

  @override
  String get labelStepBack => 'Bakside';

  @override
  String get labelStepBarcode => 'Strekkode';

  @override
  String get labelStepDatabase => 'Vindatabase på telefonen';

  @override
  String get labelStepPending => 'Venter';

  @override
  String get labelStepRunning => 'Jobber…';

  @override
  String get labelStepDone => 'Ferdig';

  @override
  String get labelStepSkipped => 'Hoppet over';

  @override
  String get labelStepFailed => 'Kan ikke leses';

  @override
  String labelStepStatus(String step, String status) {
    return '$step: $status';
  }

  @override
  String get labelOnPhoneNote =>
      'Alt skjer på telefonen: bildene sendes ikke til noen.';

  @override
  String get labelBackUnreadable => 'Baksiden kan ikke leses';

  @override
  String get labelSourceOffline => 'Fra databasen på telefonen · frakoblet';

  @override
  String get labelSourceCatalog => 'Fra katalogen';

  @override
  String get labelSourceOnline => 'Fra Open Food Facts · på nett';

  @override
  String get labelNotThis => 'Ikke denne';

  @override
  String get labelOffAttribution => 'Data fra Open Food Facts, ODbL-lisens';

  @override
  String get labelCandidatesTitle => 'Hvilken av disse?';

  @override
  String labelCandidatesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lignende viner',
      one: '1 lignende vin',
    );
    return '$_temp0';
  }

  @override
  String get labelCandidatesNone => 'Ingen av disse';

  @override
  String get labelChipOffline => 'frakoblet';

  @override
  String get labelChipOnline => 'på nett';

  @override
  String get labelChipCatalog => 'katalog';

  @override
  String get labelNoProducer => 'produsent ikke oppgitt';

  @override
  String get labelNoMatch =>
      'Jeg leste etiketten, men kjenner ikke igjen vinen';

  @override
  String get labelReadText => 'Lest tekst';

  @override
  String get labelSearchOnline => 'Søk på nett';

  @override
  String get labelOpenLens => 'Åpne i Google Lens';

  @override
  String get labelLensLastResort =>
      'Google Lens er siste utvei: bildet sendes bare til Google-appen hvis du bekrefter.';

  @override
  String get labelLensTitle => 'Åpne i Google Lens?';

  @override
  String get labelLensBody =>
      'Bildet av forsiden sendes til Google-appen på telefonen din, eller til appen du velger, som kan beholde en kopi etter sine egne regler. Vinoozy mottar ikke resultatene: kom tilbake hit for å velge eller skrive inn vinen.';

  @override
  String get labelLensConfirm => 'Åpne Google Lens';

  @override
  String get labelLensFailed =>
      'Jeg klarer ikke å åpne Google Lens eller delingsmenyen';

  @override
  String get onlineSearchTitle => 'Søk på nett';

  @override
  String get onlineSearchSubtitle => 'Open Food Facts · bare viner';

  @override
  String get onlineSearchField => 'Søkeord';

  @override
  String get onlineSearchHint => 'Du kan endre ordene før du søker.';

  @override
  String get onlineSearchEmptyField => 'Skriv minst ett ord';

  @override
  String get onlineSearchButton => 'Søk';

  @override
  String get onlineSearchLoading => 'Søker…';

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
      'Fant ingen vin: prøv andre ord eller «Skriv selv».';

  @override
  String get onlineSearchOffline =>
      'Ikke noe nett: jeg søker bare i databasen på telefonen.';

  @override
  String get onlineSearchRateLimited =>
      'Søk på nett er ikke tilgjengelig akkurat nå, prøv igjen om noen minutter.';

  @override
  String get onlineSearchUnavailable =>
      'Søk på nett er ikke aktivt i denne versjonen av appen: jeg søker bare i databasen på telefonen.';

  @override
  String get aboutTitle => 'Om';

  @override
  String aboutVersion(String version) {
    return 'Versjon $version';
  }

  @override
  String get aboutDbTitle => 'Vindatabase';

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
    return 'Eksport fra Open Food Facts fra $date';
  }

  @override
  String get aboutDbSample =>
      'Eksempeldatabase: noen få håndskrevne testviner, ikke data fra Open Food Facts.';

  @override
  String get aboutDbLoading => 'Åpner vindatabasen…';

  @override
  String get aboutDbUnavailable =>
      'Vindatabasen er ikke tilgjengelig i denne versjonen';

  @override
  String aboutDbSource(String url) {
    return 'Den avledede databasen og verktøyet som bygger den, ligger i det offentlige repositoriet: $url';
  }

  @override
  String get aboutLicenseTitle => 'Lisenser';

  @override
  String get aboutLicense =>
      'Inneholder informasjon fra Open Food Facts, gjort tilgjengelig under Open Database License (ODbL). Enkeltinnhold er underlagt Database Contents License (DbCL).';

  @override
  String get aboutPrivacyTitle => 'Etikettbilder';

  @override
  String get aboutPrivacy =>
      'Etikettbilder leses på telefonen og slettes når du forlater resultatet. De forlater telefonen bare hvis du trykker på «Åpne i Google Lens» og bekrefter.';

  @override
  String get aboutAppellationsTitle => 'Appellasjoner';

  @override
  String get aboutAppellationsSource =>
      'Appellasjoner: eAmbrosia-registeret (EU) og offisielle nasjonale registre.';

  @override
  String get aboutAppellationsSample =>
      'Eksempeltabell: et håndskrevet utdrag av registrene, inntil de ekte registrene er lastet ned.';

  @override
  String get denominationLabel => 'Appellasjon';

  @override
  String get denominationTooLong => 'Maks 120 tegn';

  @override
  String get autofillFilledNotice => 'Fylt ut fra etiketten: sjekk og lagre';

  @override
  String get autofillPastedNotice => 'Fylt ut fra teksten: sjekk og lagre';

  @override
  String get autofillFromText => '✦ fra teksten';

  @override
  String get autofillFromTextSemantics => 'fylt ut fra etiketten';

  @override
  String get autofillClear => 'Tøm';

  @override
  String get autofillLens => 'Lens';

  @override
  String get autofillClearTitle => 'Tømme skjemaet?';

  @override
  String get autofillClearBody =>
      'Du har også skrevet selv i noen felt. «Tøm» tømmer navn, produsent, appellasjon, årgang, type, land, region og nivå. Antallet blir stående.';

  @override
  String get autofillClearConfirm => 'Tøm';

  @override
  String get autofillCleared => 'Skjemaet er tømt';

  @override
  String get autofillPasteTitle => 'Har du teksten fra Google Lens?';

  @override
  String get autofillPasteHint =>
      'Merk teksten på etiketten i Lens og trykk på «Kopier», og kom så tilbake hit.';

  @override
  String get autofillPaste => 'Lim inn fra Lens';

  @override
  String get autofillOpenLens => 'Fra Google Lens';

  @override
  String get autofillOpenLensSemantics => 'åpner Google Lens';

  @override
  String get autofillClipboardEmpty => 'Det er ingen tekst på utklippstavlen';

  @override
  String get autofillNoNewFields =>
      'Jeg fant ingen opplysninger å legge til i teksten';

  @override
  String get autofillFromLens => 'Skjemaet er fylt ut fra Lens-teksten';

  @override
  String get autofillShareEmpty => 'Ingen tekst mottatt';

  @override
  String get autofillShareUseTitle => 'Bruke teksten til de tomme feltene?';

  @override
  String get autofillShareUse => 'Bruk';

  @override
  String get autofillShareIgnore => 'Ignorer';

  @override
  String get addChoiceLens => 'Fra Google Lens';

  @override
  String get addChoicePhotoHint =>
      'Forside og bakside: Vinoozy leser etiketten.';

  @override
  String get addChoiceLensHint =>
      'Åpner Lens: sikt, merk teksten og trykk på Del → Vinoozy.';

  @override
  String get addChoiceImportHint =>
      'Et bilde av etiketten som du allerede har tatt.';

  @override
  String get addChoiceWriteHint => 'Tomt skjema, med «Lim inn fra Lens».';

  @override
  String get lensInstructionsTitle => 'Google Lens kan ikke åpnes herfra';

  @override
  String get lensInstructionsStep1 => 'Åpne Google Lens og sikt på etiketten';

  @override
  String get lensInstructionsStep2 => 'Merk teksten på etiketten';

  @override
  String get lensInstructionsStep3 => 'Trykk på Del → Vinoozy';

  @override
  String get lensInstructionsOk => 'Skjønner';

  @override
  String get levelLabel => 'Nivå';

  @override
  String get levelEveryday => 'Hverdag (rimelig)';

  @override
  String get levelGood => 'God';

  @override
  String get levelAging => 'Til lagring';

  @override
  String get levelNone => 'Ingen';

  @override
  String get levelEverydayShort => 'drikk tidlig';

  @override
  String get levelGoodShort => 'normalt anslag';

  @override
  String get levelAgingShort => 'holder lenger';

  @override
  String get levelSuggested => 'foreslått';

  @override
  String levelSuggestedReason(String qualifier) {
    return 'Foreslått fordi det står «$qualifier» i navnet: det lagres slik hvis du ikke endrer det. Velg et annet eller trykk på «Ingen».';
  }

  @override
  String levelSuggestedSemantics(String qualifier) {
    return 'foreslått, fordi det står $qualifier i navnet';
  }

  @override
  String levelOptionSemantics(String option, int index, int count) {
    return 'Nivå, $option, $index av $count';
  }

  @override
  String get levelWhatChanges => 'Hva som endres';

  @override
  String get levelEverydayExamples =>
      'Vinduet blir kortere. F.eks. husets vin, Lambrusco, enkel Prosecco, Bardolino, Vinho Verde.';

  @override
  String get levelGoodExamples =>
      'Det normale anslaget, og det som gjelder når du ikke velger noe. F.eks. Chianti Classico, Barbera d\'Asti Superiore, Rioja Crianza, Côtes du Rhône.';

  @override
  String get levelAgingExamples =>
      'Vinduet blir lengre. F.eks. Barolo, Brunello, Amarone, Bordeaux Grand Cru, Rioja Gran Reserva, Vintage Port.';

  @override
  String levelPreviewBefore(String start, String end) {
    return 'Før $start – $end';
  }

  @override
  String levelPreviewWith(String level, String start, String end) {
    return 'Med «$level» $start – $end';
  }

  @override
  String levelPreviewNow(String start, String end) {
    return 'Drikkeklar $start – til $end';
  }

  @override
  String levelDetail(String level) {
    return 'Nivå: $level';
  }

  @override
  String get overrideCorrect => 'Rett';

  @override
  String get overrideRestore => 'Gjenopprett anslag';

  @override
  String get overrideCorrectedByYou => 'rettet av deg';

  @override
  String overrideAppEstimate(String year) {
    return 'Appens anslag: til $year';
  }

  @override
  String get overrideSheetTitle => 'Anbefalt til og med';

  @override
  String overrideSheetHint(String start) {
    return 'Velg året. Det kan ikke være før «Drikkeklar fra $start».';
  }

  @override
  String overridePeakNotice(String peak) {
    return 'Hvis du velger et år før $peak (på sitt beste), flyttes også «på sitt beste» til samme år.';
  }

  @override
  String get overrideMore => 'flere…';

  @override
  String get overrideSave => 'Lagre rettelse';

  @override
  String overrideRestoreTitle(String year) {
    return 'Gå tilbake til appens anslag (til $year)?';
  }

  @override
  String get overrideRestoreConfirm => 'Gjenopprett';

  @override
  String get overrideSaved => 'Rettelsen er lagret';

  @override
  String get overrideRestored => 'Anslaget er gjenopprettet';

  @override
  String get estimateSourceCorrectedByYou => 'rettet av deg';

  @override
  String estimateFromDenomination(String name) {
    return 'Anslag ut fra appellasjonen $name';
  }

  @override
  String estimateFromDenominationQualifier(String name, String qualifier) {
    return 'Anslag ut fra appellasjonen $name, $qualifier';
  }

  @override
  String estimateFromGrape(String name) {
    return 'Anslag ut fra druesorten $name';
  }

  @override
  String get estimateFromType => 'Anslag ut fra vintypen';

  @override
  String get autofillReading => 'Jeg leser teksten…';

  @override
  String get guideChip => 'Veiledet sjekk';

  @override
  String guideProgress(int n, int total) {
    return 'Spørsmål $n av $total';
  }

  @override
  String get guideClose => 'Lukk';

  @override
  String get guideIsDenomination => 'er det appellasjonen?';

  @override
  String get guideIsProducer => 'er det produsenten?';

  @override
  String get guideIsName => 'er det navnet på vinen?';

  @override
  String get guideIsVintage => 'Årgang';

  @override
  String guideAskDenomination(String value) {
    return 'Er $value appellasjonen?';
  }

  @override
  String guideAskProducer(String value) {
    return 'Er $value produsenten?';
  }

  @override
  String guideAskName(String value) {
    return 'Er $value navnet på vinen?';
  }

  @override
  String get guideAskVintage => 'Hvilken årgang er det?';

  @override
  String guideQuestionSemantics(int n, int total, String question) {
    return 'Spørsmål $n av $total: $question';
  }

  @override
  String get guideNoProposal => 'Jeg fant det ikke i teksten';

  @override
  String get guideYes => 'Ja';

  @override
  String get guideNo => 'Nei, et annet';

  @override
  String get guideEdit => 'Rediger';

  @override
  String get guideSkip => 'Hopp over';

  @override
  String get guideConfirm => 'Bekreft';

  @override
  String get guideCancel => 'Avbryt';

  @override
  String guideRejected(String value) {
    return 'Ikke «$value»: her er det neste';
  }

  @override
  String get guideNoMore =>
      'Ingen flere forslag: sett det sammen selv eller hopp over';

  @override
  String guideProposalAnnounce(String value) {
    return 'Forslag: $value';
  }

  @override
  String get guideComposeLabel =>
      'Eller sett det sammen ved å trykke på ord i teksten';

  @override
  String get guideComposePreview => 'Forhåndsvisning';

  @override
  String get guideComposeEmpty => 'Trykk på ett eller flere ord';

  @override
  String get guideComposeLimit => 'Opptil 8 ord og 80 tegn';

  @override
  String guideTableMatchSemantics(String name) {
    return 'samsvarer med $name';
  }

  @override
  String guideLine(int n, int total) {
    return 'Linje $n av $total';
  }

  @override
  String guideWordSelected(String word, int order) {
    return '$word, valgt, $order';
  }

  @override
  String guideWordUnavailable(String word) {
    return '$word, ikke tilgjengelig';
  }

  @override
  String guideWordUsedFor(String word, String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'appellasjonen',
      'producer': 'produsenten',
      'other': 'navnet',
    });
    return '$word, brukt til $_temp0';
  }

  @override
  String guideUsedMark(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'appellasjon',
      'producer': 'produsent',
      'other': 'navn',
    });
    return '$_temp0';
  }

  @override
  String guideOtherYears(String years) {
    return 'Også i teksten: $years';
  }

  @override
  String get guideWheelFromText => 'år funnet i teksten';

  @override
  String get guideWheelTypeYear => 'Skriv året';

  @override
  String guideWheelConfirm(String year) {
    return 'Bekreft $year';
  }

  @override
  String get guideNoVintage => 'Uten årgang';

  @override
  String guideSkippedNotice(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'Appellasjonen ble hoppet over',
      'producer': 'Produsenten ble hoppet over',
      'vintage': 'Årgangen ble hoppet over',
      'other': 'Navnet ble hoppet over',
    });
    return '$_temp0: skriv selv eller fortsett veiledningen';
  }

  @override
  String guideSkippedMany(int count) {
    return '$count felt ble hoppet over: skriv dem selv eller fortsett veiledningen';
  }

  @override
  String get guideInvalidValue =>
      'Denne teksten inneholder tegn som ikke kan lagres';

  @override
  String get brandStudio => 'Bottazzini Softworks';

  @override
  String get suggestedMark => '✦ foreslått';

  @override
  String suggestedSemantics(String field, String value) {
    return '$field, $value, foreslått';
  }

  @override
  String get restoreSuggestion => 'Gjenopprett forslag';

  @override
  String get restoreSuggestionDone => 'Forslaget er gjenopprettet';

  @override
  String get styleLabel => 'Stil';

  @override
  String styleGroupSemantics(String value, int index, int count) {
    return 'Stil, $value, $index av $count';
  }

  @override
  String get styleRedFresh => 'Frisk';

  @override
  String get styleRedMedium => 'Middels';

  @override
  String get styleRedAge => 'Til lagring';

  @override
  String get styleRedLong => 'Lang lagring';

  @override
  String get styleWhiteFresh => 'Frisk';

  @override
  String get styleWhiteMedium => 'Middels';

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
  String get styleSweetPassito => 'Tørkede druer';

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
  String get styleFortifiedOther => 'Annet';

  @override
  String get profileNameRFresh => 'Fruktig rødvin';

  @override
  String get profileNameRMedium => 'Middels fyldig rødvin';

  @override
  String get profileNameRAge => 'Rødvin til lagring';

  @override
  String get profileNameRLong => 'Rødvin til lang lagring';

  @override
  String get profileNameWFresh => 'Frisk aromatisk hvitvin';

  @override
  String get profileNameWMedium => 'Middels fyldig hvitvin';

  @override
  String get profileNameWAge => 'Hvitvin til lagring';

  @override
  String get profileNameRoseFresh => 'Frisk rosé';

  @override
  String get profileNameSpTank => 'Frisk musserende, tankmetode';

  @override
  String get profileNameLamFresh => 'Frisk Lambrusco';

  @override
  String get profileNameSpClassic => 'Frisk musserende, tradisjonell metode';

  @override
  String get profileNameSpClassicAge =>
      'Musserende til lagring, tradisjonell metode';

  @override
  String get profileNameSwAromatic => 'Ung aromatisk søt vin';

  @override
  String get profileNameSwPassito => 'Søt vin av tørkede druer';

  @override
  String get profileNameSwBotrytis => 'Søt botrytisvin';

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
  String get profileNameFortUnknown => 'Sterkvin, ukjent stil';

  @override
  String get profileNameUnknown => 'Stilen er ikke identifisert';

  @override
  String estimateFromProfile(String profile, String denomination) {
    return 'Anslag ut fra profilen $profile ($denomination)';
  }

  @override
  String estimateFromProfileType(String profile) {
    return 'Anslag ut fra profilen $profile, etter type';
  }

  @override
  String estimateFromProfileGrape(String profile, String grape) {
    return 'Anslag ut fra profilen $profile, etter druesorten $grape';
  }

  @override
  String get estimateFromEntryDateDisgorgement =>
      'Fra datoen vinen ble lagt til: oppgi degorgeringsdatoen for et bedre anslag';

  @override
  String get estimateFromEntryDateBottling =>
      'Fra datoen vinen ble lagt til: oppgi tappedatoen for et bedre anslag';

  @override
  String get styleToConfirmBanner =>
      '⚠︎ Stilen må bekreftes: anslaget er veiledende';

  @override
  String get chooseTypePrompt => 'Velg type';

  @override
  String estimateUpdatedAnnouncement(String summary) {
    return 'Anslaget er oppdatert: $summary';
  }

  @override
  String get agingStartDisgorgement => 'Degorgering';

  @override
  String get agingStartBottling => 'Tapping';

  @override
  String get agingStartMonth => 'Måned';

  @override
  String get agingStartYear => 'År';

  @override
  String get agingStartHint => 'Det står som regel på baketiketten.';

  @override
  String get agingStartIncomplete => 'Oppgi måned og år';

  @override
  String get agingStartFuture => 'Datoen kan ikke være i fremtiden';

  @override
  String get agingStartBeforeVintage => 'Den kan ikke være før årgangen';

  @override
  String get windowNoEnd => 'Drikkeklar, ingen slutt anslått';

  @override
  String get windowNoEndShort => 'ingen slutt anslått';

  @override
  String windowDrinkWithin(String date) {
    return 'innen $date';
  }

  @override
  String get levelNoEffect => 'Nivået endrer ikke dette anslaget';

  @override
  String get dashboardToConfirmTitle => 'Må bekreftes';

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
    return '$percent % av vinene med en gjenkjent type';
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
  String get planDevSimulateFree => 'DEV · Simulert gratispakke';

  @override
  String get planDevSimulateExpired => 'DEV · Simulert utløpt Plus';

  @override
  String get planDiscoverPlus => 'Oppdag Plus';

  @override
  String get plusTitle => 'Vinoozy Plus';

  @override
  String get plusBenefitsTitle => 'Med Plus';

  @override
  String get plusBenefitNoAds => 'Ingen annonser';

  @override
  String get plusBenefitNoLimit => 'Ingen grense for vinene i kjelleren din';

  @override
  String get plusComingSoon => 'Plus kommer snart';

  @override
  String get plusLoading => 'Henter prisene fra Google Play';

  @override
  String get plusStoreUnavailable =>
      'Kunne ikke hente prisene fra Google Play. Prøv igjen senere.';

  @override
  String plusPriceMonthly(String price) {
    return '$price per måned';
  }

  @override
  String plusPriceAnnual(String price) {
    return '$price per år';
  }

  @override
  String get plusRenewal =>
      'Abonnementet fornyes automatisk til prisen som vises, helt til du sier det opp på Google Play.';

  @override
  String get plusTerms =>
      'Betalingen belastes Google Play-kontoen din når du bekrefter kjøpet. Du kan si opp når som helst: Plus er aktivt ut perioden du allerede har betalt for. Når Plus avsluttes, blir alle vinene dine stående.';

  @override
  String get plusRestore => 'Gjenopprett kjøp';

  @override
  String get plusManage =>
      'Administrer eller si opp abonnementet på Google Play';

  @override
  String get plusActive => 'Plus er aktivt på denne kontoen';

  @override
  String get plusActiveGift =>
      'Du har fått Plus i gave: ingen belastninger og ingen fornyelser.';

  @override
  String get plusPending =>
      'Betalingen venter: Plus blir aktivt når Google Play bekrefter den.';

  @override
  String get plusVerifying => 'Bekrefter kjøpet';

  @override
  String get plusVerified =>
      'Kjøpet er bekreftet: Plus er aktivt om noen sekunder.';

  @override
  String get plusPurchaseFailed => 'Kjøpet ble ikke fullført. Prøv igjen.';

  @override
  String get plusInvalidPurchase =>
      'Google Play bekreftet ikke dette kjøpet for Vinoozy.';

  @override
  String get plusOwnedByOther =>
      'Dette abonnementet tilhører allerede en annen Vinoozy-konto.';

  @override
  String get plusVerificationUnavailable =>
      'Kjøpet kunne ikke bekreftes akkurat nå. Prøv igjen senere: abonnementet blir værende på Google Play.';

  @override
  String get capacityLimitTitle => 'Du har nådd grensen for gratispakken';

  @override
  String capacityLimitBody(int limit) {
    return 'Gratispakken omfatter opptil $limit forskjellige viner i kjelleren din. Du kan alltid redigere, drikke og legge til flasker for vinene du allerede har. For å legge til en ny må du drikke opp eller slette en vin, eller bytte til Plus.';
  }

  @override
  String capacityLimitBodyComingSoon(int limit) {
    return 'Gratispakken omfatter opptil $limit forskjellige viner i kjelleren din. Du kan alltid redigere, drikke og legge til flasker for vinene du allerede har. For å legge til en ny må du drikke opp eller slette en vin. Plus kommer snart.';
  }

  @override
  String get rejectedCapacityLimit =>
      'Ikke synkronisert: det går over vingrensen for gratispakken. Endringen blir værende på denne telefonen.';

  @override
  String get rejectedCapacityConflict =>
      'Ikke synkronisert: kjelleren ble endret på en annen enhet samtidig. Endringen blir værende på denne telefonen: prøv igjen.';

  @override
  String writeRejectedCapacityLimit(String name) {
    return '$name: ikke synkronisert, over grensen for gratispakken';
  }

  @override
  String writeRejectedCapacityConflict(String name) {
    return '$name: ikke synkronisert, kjelleren ble endret på en annen enhet';
  }

  @override
  String get freeIntroTitle => 'Gratispakken';

  @override
  String freeIntroLimit(int limit) {
    return 'Du kan holde orden på opptil $limit forskjellige viner gratis.';
  }

  @override
  String get freeIntroAds =>
      'Lett bruk er uten annonser. Hvis du går over tjenestens månedlige bruksgrense, kan du se enkelte annonser som bidrar til å dekke kostnadene til servere og synkronisering.';

  @override
  String get freeIntroNoAds => 'Ingen annonser i lanseringsversjonen.';

  @override
  String get freeIntroPlus =>
      'Med Plus fjerner du annonsene og kjellergrensen.';

  @override
  String get noticeGotIt => 'Skjønner';

  @override
  String get thresholdTitle => 'Annonser bidrar til å holde Vinoozy gratis';

  @override
  String get thresholdBody =>
      'Du har nådd den månedlige grensen for bruk uten annonser. Fra nå av kan du se enkelte annonser: de hjelper oss med å dekke kostnadene til servere og synkronisering, slik at Vinoozy kan forbli gratis.';

  @override
  String get thresholdReset =>
      'Tellingen starter på nytt neste måned. Med Plus kan du bruke appen uten annonser og uten kjellergrensen.';

  @override
  String thresholdNextReset(String date) {
    return 'Neste nullstilling: $date';
  }

  @override
  String get thresholdHowItWorks => 'Slik fungerer det';

  @override
  String get thresholdHowItWorksBody =>
      'Grensen avhenger av et anslag over synkroniseringene med skyen som denne kontoen gjør i løpet av måneden. Bruk uten nett alene skaper ingen nye skyoperasjoner. Annonser vises høyst én gang om dagen, bare i Oversikt, og aldri mens du lagrer eller eksporterer dataene dine.';

  @override
  String get adLabel => 'Annonse';

  @override
  String get devToolsTitle => 'Utviklerverktøy';

  @override
  String get devUnlockAll => 'Lås opp alt — test-Plus';

  @override
  String get devSimulateFree => 'Simuler gratispakke';

  @override
  String get devSimulateExpired => 'Simuler utløpt Plus';

  @override
  String get devRestore => 'Gjenopprett normal tilstand';

  @override
  String get devNoOverride => 'Ingen simulering aktiv';

  @override
  String get devApplied => 'Scenarioet er også brukt i Firestore-emulatoren';

  @override
  String get devIncomplete =>
      'Ufullstendig simulering: Firestore-emulatoren bekreftet ikke testrettigheten. Serverreglene ser ikke dette scenarioet.';

  @override
  String get devNotice =>
      'Bare utviklingsbygg med emulatoren: ingen betalinger, tokener eller kvitteringer.';

  @override
  String get settingsTitle => 'Innstillinger';

  @override
  String get settingsGuide => 'Se veiledningen igjen';

  @override
  String get settingsShare => 'Del appen';

  @override
  String get settingsRate => 'Vurder appen';

  @override
  String get settingsFeedback => 'Send tilbakemelding';

  @override
  String get settingsFaq => 'Vanlige spørsmål';

  @override
  String get settingsShareFailed => 'Kunne ikke åpne deling. Prøv igjen';

  @override
  String get settingsRateFailed => 'Kunne ikke åpne Google Play. Prøv igjen';

  @override
  String get guideAddTitle => 'Legg til en vin';

  @override
  String get guideAddBody =>
      'Trykk på Legg til for å legge en flaske i kjelleren. Navnet holder for å begynne.';

  @override
  String get guideLabelTitle => 'Les etiketten';

  @override
  String get guideLabelBody =>
      'Under Legg til kan du også fotografere etiketten: Vinoozy leser navn, årgang og opprinnelsesbetegnelse, og du sjekker dem før du lagrer.';

  @override
  String get guideTabsTitle => 'Oversikt, Kjeller, Historikk';

  @override
  String get guideTabsBody =>
      'Oversikten forteller hvilke viner du bør åpne nå, Kjelleren viser flaskene dine og Historikken tar vare på dem du har drukket.';

  @override
  String get guideMenuTitle => 'Kjellermenyen';

  @override
  String get guideMenuBody =>
      'Her finner du profilen din, personene du deler kjelleren med, de drukne vinene og Innstillinger, der du kan se denne veiledningen igjen.';

  @override
  String get guideDone => 'Ferdig';

  @override
  String guideStepOf(int step, int count) {
    return 'Trinn $step av $count';
  }

  @override
  String get hintDashboard =>
      'Her ser du hvilke viner som er klare til å drikkes nå, og hvilke som bør vente litt til.';

  @override
  String get hintHistory =>
      'Hver flaske du drikker havner her, med vurderingen og notatene dine.';

  @override
  String get hintAddWine =>
      'Begynn med navnet: årgang, type og opprinnelsesbetegnelse gjør drikkevinduet mer presist.';

  @override
  String get shareAppSubject => 'Vinoozy, vinkjelleren din';

  @override
  String shareAppMessage(String link) {
    return 'Jeg holder orden på vinkjelleren min med Vinoozy: den forteller meg når hver flaske er på sitt beste. Prøv den: $link';
  }

  @override
  String get feedbackSubject => 'Tilbakemelding om Vinoozy';

  @override
  String get feedbackTechHeader => 'Tekniske data (ikke slett):';

  @override
  String get feedbackNoEmailTitle => 'Ingen e-postapp';

  @override
  String feedbackNoEmailBody(String email) {
    return 'Det finnes ingen e-postapp på denne telefonen. Skriv til oss på $email';
  }

  @override
  String get feedbackCopy => 'Kopier';

  @override
  String get feedbackCopied => 'Adressen er kopiert';

  @override
  String get faqAddQuestion => 'Hvordan legger jeg til en vin manuelt?';

  @override
  String get faqAddAnswer =>
      'Trykk på Legg til i Kjelleren og deretter på Skriv. Bare navnet er påkrevd; årgang, type, land og opprinnelsesbetegnelse forbedrer anslaget. Lagre, så ligger vinen i kjelleren.';

  @override
  String get faqLabelQuestion =>
      'Hvordan leser jeg en etikett, også med Google Lens?';

  @override
  String get faqLabelAnswer =>
      'Trykk på Legg til og fotografer for- og baksiden: Vinoozy leser etiketten direkte på telefonen. Merk teksten i Google Lens og del den med Vinoozy, eller kopier den og bruk Lim inn fra Lens i skjemaet. Sjekk alltid feltene før du lagrer.';

  @override
  String get faqWindowQuestion =>
      'Hvordan beregnes det beste tidspunktet å drikke, og kan jeg endre det?';

  @override
  String get faqWindowAnswer =>
      'Vinoozy anslår et vindu (start, topp, slutt) ut fra vinens type, opprinnelsesbetegnelse, årgang og nivå. Det er veiledende: lagringen teller også. Åpne vinen og trykk på Rett for å sette din egen dato, eller endre Nivå.';

  @override
  String get faqOfflineQuestion => 'Fungerer den uten internett?';

  @override
  String get faqOfflineAnswer =>
      'Ja. Du kan legge til, redigere og drikke viner uten nett: alt lagres på telefonen og synkroniseres med kontoen din så snart forbindelsen er tilbake.';

  @override
  String get faqShareQuestion => 'Hvordan deler jeg kjelleren min?';

  @override
  String get faqShareAnswer =>
      'Åpne Personer i kjellermenyen og inviter noen med Google-e-postadressen deres, kun lese eller med redigering. Personen installerer Vinoozy og logger inn med den kontoen.';

  @override
  String get faqPlusQuestion => 'Hva inneholder gratisplanen, og hva er Plus?';

  @override
  String faqPlusAnswer(int limit) {
    return 'Gratisplanen omfatter opptil $limit forskjellige viner i kjelleren, med enkelte annonser bare i Oversikten. Vinoozy Plus fjerner grensen og annonsene.';
  }

  @override
  String get faqDrinkQuestion =>
      'Hvorfor registrere hva jeg drakk og hvordan det var?';

  @override
  String get faqDrinkAnswer =>
      'Historikken tar vare på hva du har drukket og hvor godt du likte det. Når du oppgir hvordan flasken var (fortsatt for ung, akkurat passe, forbi toppen), retter Vinoozy anslaget for den samme vinen.';

  @override
  String get faqDeleteQuestion => 'Hvordan sletter jeg kontoen min?';

  @override
  String get faqDeleteAnswer =>
      'Åpne Profil og trykk på Slett konto. Du trenger nett og logger deretter inn igjen med Google for å bekrefte. Kjelleren, Historikken og delingene slettes for godt.';

  @override
  String get faqNotFound => 'Fant du ikke svaret? Skriv til oss';
}
