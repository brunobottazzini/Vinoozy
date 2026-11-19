// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appTitle => 'Vinoozy';

  @override
  String get signInTagline => 'Je wijnkelder, op het juiste moment';

  @override
  String get signInWithGoogle => 'Doorgaan met Google';

  @override
  String get signInInProgress => 'Bezig met inloggen';

  @override
  String get signInFailed => 'Inloggen mislukt';

  @override
  String get signInNeedsNetwork =>
      'Voor de eerste keer inloggen heb je verbinding nodig';

  @override
  String get signInSessionExpired => 'Je sessie is verlopen: log opnieuw in';

  @override
  String get retry => 'Opnieuw proberen';

  @override
  String get cancel => 'Annuleren';

  @override
  String blockedMessage(String email) {
    return 'Er zijn wijzigingen van $email die nog niet in de cloud zijn opgeslagen: log in met dat account en maak verbinding met het netwerk';
  }

  @override
  String blockedSignInWith(String email) {
    return 'Inloggen met $email';
  }

  @override
  String blockedDiscard(String email) {
    return 'Niet-opgeslagen wijzigingen van $email verwijderen';
  }

  @override
  String get discardDialogTitle => 'Wijzigingen verwijderen?';

  @override
  String discardDialogBody(int count, String email) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count wijnen van $email staan nog niet in de cloud en worden van deze telefoon verwijderd.',
      one:
          '1 wijn van $email staat nog niet in de cloud en wordt van deze telefoon verwijderd.',
    );
    return '$_temp0';
  }

  @override
  String get discardConfirm => 'Verwijderen';

  @override
  String get resetFailed =>
      'De gegevens op deze telefoon konden niet worden gewist';

  @override
  String get restartRequired => 'Start de app opnieuw om af te ronden';

  @override
  String get restartCloseApp => 'App sluiten';

  @override
  String get startupFailed => 'De app kon niet starten';

  @override
  String get cellarTitle => 'Kelder';

  @override
  String get defaultCellarName => 'Mijn kelder';

  @override
  String get cellarLoading => 'Kelder wordt voorbereid';

  @override
  String get cellarSetupFailed => 'De kelder kon niet worden voorbereid';

  @override
  String get cellarEmpty => 'Je kelder is leeg';

  @override
  String get addWine => 'Toevoegen';

  @override
  String get estimatePending => 'Schatting volgt';

  @override
  String get noVintage => 'Geen jaargang';

  @override
  String bottleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count flessen',
      one: '1 fles',
    );
    return '$_temp0';
  }

  @override
  String get syncInProgress => 'Synchroniseren';

  @override
  String get syncOffline => 'Offline - synchronisatie in afwachting';

  @override
  String writeRejected(String name) {
    return 'Wijziging niet toegestaan: $name';
  }

  @override
  String get saveFailed => 'Opslaan mislukt, probeer het opnieuw';

  @override
  String wineNotSaved(String name) {
    return 'De wijn $name is niet in de cloud opgeslagen';
  }

  @override
  String get addAgain => 'Opnieuw toevoegen';

  @override
  String get ignore => 'Negeren';

  @override
  String get addWineTitle => 'Invoeren';

  @override
  String get wineNameLabel => 'Wijn';

  @override
  String get vintageLabel => 'Jaargang';

  @override
  String get quantityLabel => 'Aantal';

  @override
  String get decreaseQuantity => 'Aantal verlagen';

  @override
  String get increaseQuantity => 'Aantal verhogen';

  @override
  String get save => 'Opslaan';

  @override
  String get nameRequired => 'Vul de naam van de wijn in';

  @override
  String get nameTooLong => 'Maximaal 120 tekens';

  @override
  String vintageRange(String year) {
    return 'Jaargang tussen 1900 en $year';
  }

  @override
  String get offAttribution => 'Gegevens van Open Food Facts (ODbL)';

  @override
  String get dashboardTitle => 'Overzicht';

  @override
  String dashboardTotalBottles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count flessen in de kelder',
      one: '1 fles in de kelder',
    );
    return '$_temp0';
  }

  @override
  String get dashboardSyncing => 'Kelder wordt gesynchroniseerd…';

  @override
  String get dashboardAddFirstWine => 'Voeg je eerste wijn toe';

  @override
  String get drinkSoonTitle => 'Binnenkort drinken';

  @override
  String get drinkSoonEmpty => 'Geen flessen die binnenkort op moeten';

  @override
  String drinkSoonUntil(String year) {
    return 'uiterlijk $year';
  }

  @override
  String drinkSoonSeeAll(int count) {
    return 'Alles bekijken ($count)';
  }

  @override
  String get statusChartTitle => 'Status van de flessen';

  @override
  String get statusWaiting => 'nog bewaren';

  @override
  String get statusReady => 'op dronk';

  @override
  String get statusDrinkSoon => 'binnenkort drinken';

  @override
  String get statusPastWindow => 'venster voorbij';

  @override
  String toEstimateNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count flessen zonder schatting',
      one: '1 fles zonder schatting',
    );
    return '$_temp0';
  }

  @override
  String chartBarValue(String label, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count flessen',
      one: '1 fles',
    );
    return '$label: $_temp0';
  }

  @override
  String chartDescription(String title, String values) {
    return '$title: $values';
  }

  @override
  String get openListHint => 'Lijst openen';

  @override
  String get peakChartTitle => 'Jaar van het hoogtepunt';

  @override
  String get peakPast => 'hoogtepunt voorbij';

  @override
  String get peakBeyond => 'later';

  @override
  String get breakdownTypeTitle => 'Flessen per type';

  @override
  String get breakdownRegionTitle => 'Flessen per regio';

  @override
  String get breakdownType => 'Type';

  @override
  String get breakdownRegion => 'Regio';

  @override
  String get familyRed => 'rood';

  @override
  String get familyWhite => 'wit';

  @override
  String get familyRose => 'rosé';

  @override
  String get familySparkling => 'mousserend';

  @override
  String get familySweet => 'zoet';

  @override
  String get breakdownUnspecified => 'niet opgegeven';

  @override
  String get breakdownOtherRegions => 'overige';

  @override
  String get ok => 'OK';

  @override
  String get cellarMenu => 'Keldermenu';

  @override
  String get sharingPeopleTitle => 'Personen';

  @override
  String get sharingInviteTitle => 'Iemand uitnodigen';

  @override
  String get sharingEmailLabel => 'Google-e-mailadres';

  @override
  String get sharingPermissionRead => 'Alleen lezen';

  @override
  String get sharingPermissionReadHint =>
      'Ziet wijnen, schattingen, overzicht en gedronken flessen';

  @override
  String get sharingPermissionEdit => 'Mag bewerken';

  @override
  String get sharingPermissionEditHint =>
      'Voegt ook wijnen toe, wijzigt ze en noteert gedronken flessen';

  @override
  String get sharingRoleOwner => 'eigenaar';

  @override
  String get sharingInviteButton => 'Uitnodigen';

  @override
  String sharingPlacesUsed(int used, int max) {
    return '$used/$max personen';
  }

  @override
  String get sharingInvalidEmail => 'Vul een geldig e-mailadres in';

  @override
  String get sharingSelfInvite => 'Je kunt jezelf niet uitnodigen';

  @override
  String get sharingAlreadyInvited => 'Deze persoon is al uitgenodigd';

  @override
  String sharingLimitReached(int max) {
    return 'Je hebt de limiet van $max personen bereikt';
  }

  @override
  String get sharingNotOwner =>
      'Je kunt het delen van deze kelder niet wijzigen';

  @override
  String get sharingNotFound => 'Deze persoon staat niet meer in de lijst';

  @override
  String get sharingFailed => 'Dat is niet gelukt, probeer het opnieuw';

  @override
  String get sharingInviteFailed => 'Uitnodigen mislukt. Probeer het opnieuw';

  @override
  String get sharingOfflineHint =>
      'Je hebt verbinding nodig om het delen te beheren';

  @override
  String get sharingStatusInvited => 'uitgenodigd';

  @override
  String get sharingStatusActive => 'actief';

  @override
  String get sharingStatusRevoked => 'ingetrokken';

  @override
  String get sharingStatusLeft => 'vertrokken';

  @override
  String sharingMemberSemantics(String name, String permission, String status) {
    return '$name, $permission, $status';
  }

  @override
  String get sharingClosedSection => 'Beëindigde toegang';

  @override
  String get sharingNobody => 'Nog niemand anders ziet deze kelder';

  @override
  String sharingChangePermission(String name) {
    return 'Rechten van $name wijzigen';
  }

  @override
  String get sharingRevoke => 'Intrekken';

  @override
  String sharingRevokeTitle(String name) {
    return 'Toegang van $name intrekken?';
  }

  @override
  String sharingRevokeConfirmLabel(String name) {
    return 'Typ $name om te bevestigen';
  }

  @override
  String get sharingRevokeDisabledHint => 'Actief zodra de naam overeenkomt';

  @override
  String get sharingReinvite => 'Opnieuw uitnodigen';

  @override
  String get sharingDeleteForGood => 'Definitief verwijderen';

  @override
  String sharingOwnedBy(String owner) {
    return 'Kelder van $owner';
  }

  @override
  String get sharingYourCellar => 'Jouw kelder';

  @override
  String sharingYourPermission(String permission) {
    return 'Jouw rechten: $permission';
  }

  @override
  String sharingSwitcherSemantics(String cellar, String permission) {
    return '$cellar, $permission. Tik om van kelder te wisselen';
  }

  @override
  String get sharingLeave => 'Deze kelder verlaten';

  @override
  String sharingLeaveTitle(String owner) {
    return 'De kelder van $owner verlaten?';
  }

  @override
  String sharingLeaveBody(String owner) {
    return 'Je ziet hem dan niet meer. $owner kan je opnieuw uitnodigen.';
  }

  @override
  String get sharingLeaveConfirm => 'Verlaten';

  @override
  String sharingSharedNotice(String owner) {
    return '$owner heeft een kelder met je gedeeld';
  }

  @override
  String sharingAccessLost(String owner) {
    return 'Je hebt geen toegang meer tot de kelder van $owner';
  }

  @override
  String sharingWritesLost(String owner) {
    return 'Sommige wijzigingen in de kelder van $owner zijn niet opgeslagen omdat je geen toegang meer hebt';
  }

  @override
  String get sharingSomeone => 'iemand';

  @override
  String get sharingShareSubject => 'Uitnodiging voor Vinoozy';

  @override
  String sharingShareMessage(
    String owner,
    String cellar,
    String link,
    String email,
  ) {
    return '$owner heeft je uitgenodigd voor de kelder \"$cellar\" in Vinoozy. Installeer de app via $link en log in met het Google-account $email: gebruik precies dit adres.';
  }

  @override
  String get cellarSearchHint => 'Zoek op naam of producent';

  @override
  String get cellarFilterStatus => 'Status';

  @override
  String get cellarFilterType => 'Type';

  @override
  String get statusToEstimate => 'Zonder schatting';

  @override
  String get filterTypeUnspecified => 'Niet opgegeven';

  @override
  String get cellarNoMatches => 'Geen wijn met deze filters';

  @override
  String get cellarClearFilters => 'Filters wissen';

  @override
  String get cellarArchiveTitle => 'Gedronken';

  @override
  String get cellarArchiveEmpty => 'Nog geen opgedronken wijnen';

  @override
  String get cellarArchiveFailed =>
      'De opgedronken wijnen konden niet worden geladen';

  @override
  String get wineDrink => 'Gedronken';

  @override
  String wineDrinkTooltip(String name) {
    return 'Een fles $name als gedronken markeren';
  }

  @override
  String confidenceLabel(String level) {
    return 'Zekerheid: $level';
  }

  @override
  String get confidenceHigh => 'hoog';

  @override
  String get confidenceMedium => 'gemiddeld';

  @override
  String get confidenceLow => 'laag';

  @override
  String get windowStartLabel => 'Begin';

  @override
  String get windowPeakLabel => 'Hoogtepunt';

  @override
  String get windowEndLabel => 'Einde';

  @override
  String estimateSourceLabel(String source) {
    return 'Bron: $source';
  }

  @override
  String get estimateSourceCatalog => 'wijndatabase';

  @override
  String get estimateSourceType => 'schatting voor het type';

  @override
  String get estimateSourceCorrected =>
      'schatting bijgesteld door je gedronken flessen';

  @override
  String get estimateDisclaimer =>
      'Indicatieve schatting: het hangt ook af van hoe de fles is bewaard';

  @override
  String get estimateUnavailable => 'Geen schatting beschikbaar';

  @override
  String get pairingsTitle => 'Past bij';

  @override
  String get pairingsGeneric => 'algemene wijn-spijscombinaties voor het type';

  @override
  String get pairingBraisedRedMeat => 'Gestoofd rood vlees';

  @override
  String get pairingGrilledRedMeat => 'Gegrild rood vlees';

  @override
  String get pairingGame => 'Wild';

  @override
  String get pairingRoastPoultry => 'Gebraden gevogelte';

  @override
  String get pairingPoultry => 'Gevogelte';

  @override
  String get pairingPork => 'Varkensvlees';

  @override
  String get pairingCuredMeats => 'Charcuterie';

  @override
  String get pairingPastaMeatSauce => 'Pasta met vleessaus';

  @override
  String get pairingMushroomsTruffle => 'Paddenstoelen en truffel';

  @override
  String get pairingAgedCheese => 'Gerijpte kaas';

  @override
  String get pairingFreshCheese => 'Verse kaas';

  @override
  String get pairingBlueCheese => 'Blauwe kaas';

  @override
  String get pairingFish => 'Vis';

  @override
  String get pairingSeafood => 'Zeevruchten';

  @override
  String get pairingRawSeafood => 'Rauwe zeevruchten';

  @override
  String get pairingFriedFood => 'Gefrituurd';

  @override
  String get pairingVegetables => 'Groenten';

  @override
  String get pairingRisotto => 'Risotto';

  @override
  String get pairingPizza => 'Pizza';

  @override
  String get pairingAperitif => 'Aperitief';

  @override
  String get pairingPastries => 'Gebak';

  @override
  String get pairingDryBiscuits => 'Droge koekjes';

  @override
  String get pairingChocolate => 'Chocolade';

  @override
  String get pairingDriedFruit => 'Noten en gedroogd fruit';

  @override
  String get pairingSpicyDishes => 'Kruidige gerechten';

  @override
  String get recentDrinksTitle => 'Laatst gedronken';

  @override
  String get noDrinksYet => 'Nog niets gedronken';

  @override
  String get wineEdit => 'Bewerken';

  @override
  String get wineDelete => 'Verwijderen';

  @override
  String get wineFinished => 'Op: geen flessen meer';

  @override
  String get wineLoadFailed => 'De wijn kon niet worden geopend';

  @override
  String get wineNotFound => 'Deze wijn bestaat niet meer';

  @override
  String drinkDone(String name) {
    return 'Als gedronken gemarkeerd: $name';
  }

  @override
  String get drinkUndo => 'Ongedaan maken';

  @override
  String get drinkAddNotes => 'Beoordeling en notities toevoegen';

  @override
  String get nothingToUndo => 'Er is niets meer om ongedaan te maken';

  @override
  String get cellarUndoRejected =>
      'Ongedaan maken mislukt: de fles blijft als gedronken gemarkeerd';

  @override
  String get cellarDeleteFailed =>
      'Het verwijderen is nog niet klaar: het wordt zo snel mogelijk afgerond';

  @override
  String get duplicateFull =>
      'Deze wijn heeft al 99 flessen: er kunnen er geen meer bij.';

  @override
  String get recordSheetTitle => 'Beoordeling en notities';

  @override
  String get recordRatingLabel => 'Beoordeling';

  @override
  String ratingStar(int n) {
    return 'Beoordeling $n van 5';
  }

  @override
  String get recordNotesLabel => 'Notities';

  @override
  String get recordNotesTooLong => 'Maximaal 1000 tekens';

  @override
  String recordDateLabel(String date) {
    return 'Datum: $date';
  }

  @override
  String get recordDateInvalid =>
      'De datum mag niet in de toekomst of vóór de jaargang liggen';

  @override
  String get recordConditionTitle => 'Hoe was de wijn?';

  @override
  String get conditionTooYoung => 'Nog te jong';

  @override
  String get conditionJustRight => 'Precies goed';

  @override
  String get conditionPastPeak => 'Over het hoogtepunt';

  @override
  String get recordNoCondition => 'Geen antwoord';

  @override
  String get producerLabel => 'Producent (optioneel)';

  @override
  String get producerTooLong => 'Maximaal 120 tekens';

  @override
  String producerAddNew(String name) {
    return '\"$name\" toevoegen als nieuwe producent';
  }

  @override
  String get wineTypeLabel => 'Type';

  @override
  String get typeRedLight => 'Lichte rode wijn';

  @override
  String get typeRedStructured => 'Volle rode wijn';

  @override
  String get typeWhite => 'Wit';

  @override
  String get typeRose => 'Rosé';

  @override
  String get typeSparklingClassic => 'Mousserend, traditionele methode';

  @override
  String get typeSparklingTank => 'Mousserend, tankmethode';

  @override
  String get typeSweet => 'Zoet';

  @override
  String get typeFortified => 'Versterkt';

  @override
  String get suggestionFromCellar => 'In je kelder';

  @override
  String get suggestionsLabel => 'Suggesties';

  @override
  String get duplicateTitle => 'Al in de kelder';

  @override
  String duplicateBody(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count flessen',
      one: '1 fles',
      zero: 'geen flessen',
    );
    return '$name staat er al, met $_temp0. De nieuwe flessen daaraan toevoegen?';
  }

  @override
  String duplicateAdd(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count flessen toevoegen',
      one: '1 fles toevoegen',
    );
    return '$_temp0';
  }

  @override
  String get duplicateBanner => 'Mogelijk dubbel';

  @override
  String get duplicateMerge => 'Samenvoegen';

  @override
  String get duplicateDeleteHint =>
      'Verwijder deze vermelding als die dubbel is';

  @override
  String get mergeTitle => 'De twee vermeldingen samenvoegen?';

  @override
  String get mergeBody =>
      'De flessen van deze vermelding gaan naar de oudste, daarna wordt deze vermelding verwijderd.';

  @override
  String get editWineTitle => 'Wijn bewerken';

  @override
  String get editDuplicate =>
      'Er bestaat al een wijn met dezelfde naam, producent en jaargang';

  @override
  String deleteWineTitle(String name) {
    return '$name verwijderen?';
  }

  @override
  String get deleteWineBody =>
      'De wijn en alle gegevens over gedronken flessen worden verwijderd. Dit kan niet ongedaan worden gemaakt.';

  @override
  String get historyTitle => 'Geschiedenis';

  @override
  String get historyEmpty => 'Hier vind je de flessen die je hebt gedronken';

  @override
  String get historyLoadFailed => 'De geschiedenis kon niet worden geladen';

  @override
  String drankOnLabel(String date) {
    return 'Gedronken op $date';
  }

  @override
  String get addChoiceTitle => 'Wijn toevoegen';

  @override
  String get addChoicePhoto => 'Foto maken';

  @override
  String get addChoiceImport => 'Foto importeren';

  @override
  String get addChoiceWrite => 'Invoeren';

  @override
  String get labelReading => 'Ik lees het etiket…';

  @override
  String get labelRecognized => 'Ik herkende:';

  @override
  String get labelCorrect => 'Corrigeren';

  @override
  String get labelConfirm => 'Bevestigen';

  @override
  String get labelUnreadable => 'Ik kan het etiket niet lezen';

  @override
  String get labelWriteByHand => 'Handmatig invoeren';

  @override
  String get labelNotFound =>
      'Ik heb de wijn niet gevonden: controleer de gegevens';

  @override
  String get labelCameraDenied =>
      'Om het etiket te lezen heb ik toegang tot de camera nodig';

  @override
  String get labelPhotosDenied =>
      'Om het etiket te lezen heb ik toegang tot de foto\'s nodig';

  @override
  String get labelOpenSettings => 'Instellingen openen';

  @override
  String get labelCameraUnavailable => 'Camera niet beschikbaar';

  @override
  String get labelBarcodeNotFound =>
      'Ik heb de streepjescode gelezen, maar kan de wijn niet vinden';

  @override
  String get labelBarcodeFrontHint =>
      'Maak een foto van de voorkant van het etiket';

  @override
  String get labelSharedNotAllowed =>
      'Je kunt geen wijnen aan deze kelder toevoegen';

  @override
  String get labelSharedFirstOnly => 'Ik heb alleen de eerste foto gebruikt';

  @override
  String get labelSharedExpired =>
      'De gedeelde foto kon niet worden gelezen: deel hem opnieuw';

  @override
  String get labelReplaceTitle =>
      'Je hebt een niet-opgeslagen wijn. De nieuwe foto lezen?';

  @override
  String get labelReplaceRead => 'Nieuwe foto lezen';

  @override
  String get labelReplaceKeep => 'Verder met de geopende wijn';

  @override
  String get labelWineAdded => 'Wijn toegevoegd aan de kelder';

  @override
  String get onboardingPage1Title => 'Je wijnkelder op zak';

  @override
  String get onboardingPage1Body =>
      'Voeg je flessen toe door ze in te voeren of met een foto van het etiket, ook zonder netwerk.';

  @override
  String get onboardingPage2Title => 'Op het juiste moment';

  @override
  String get onboardingPage2Body =>
      'Vinoozy schat wanneer elke wijn op zijn best is en vertelt je welke je het eerst moet openen.';

  @override
  String get onboardingPage3Title => 'Samen';

  @override
  String get onboardingPage3Body =>
      'Deel je kelder met maximaal twee personen en bewaar de geschiedenis van elke fles die je drinkt.';

  @override
  String get onboardingSkip => 'Overslaan';

  @override
  String get onboardingNext => 'Volgende';

  @override
  String get onboardingStart => 'Beginnen';

  @override
  String onboardingPageOf(int page) {
    return 'Pagina $page van 3';
  }

  @override
  String get profileTitle => 'Profiel';

  @override
  String get profilePhoto => 'Profielfoto';

  @override
  String get profileSignOut => 'Uitloggen';

  @override
  String get profileDeleteAccount => 'Account verwijderen';

  @override
  String get profilePrivacy => 'Privacybeleid';

  @override
  String get profilePrivacyBody =>
      'Je kunt het privacybeleid lezen op dit adres:';

  @override
  String get profileOpenLink => 'Openen in browser';

  @override
  String get profileOpenLinkFailed =>
      'De pagina kon niet worden geopend. Je kunt de link kopiëren en in je browser openen.';

  @override
  String get profileCopyLink => 'Link kopiëren';

  @override
  String get profileLinkCopied => 'Link gekopieerd';

  @override
  String get close => 'Sluiten';

  @override
  String get signOutConfirmTitle => 'Wil je uitloggen?';

  @override
  String signOutPendingWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Je hebt $count wijzigingen die nog niet zijn opgeslagen. Als je uitlogt en een ander account inlogt, gaan die verloren.',
      one: 'Je hebt 1 wijziging die nog niet is opgeslagen. Als je uitlogt en een ander account inlogt, gaat die verloren.',
    );
    return '$_temp0';
  }

  @override
  String get signOutStayAndSync => 'Blijven en synchroniseren';

  @override
  String get signOutAnyway => 'Toch uitloggen';

  @override
  String get syncAllSaved => 'Alles opgeslagen';

  @override
  String syncStillPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nog $count wijzigingen op te slaan: controleer het netwerk',
      one: 'Nog 1 wijziging op te slaan: controleer het netwerk',
    );
    return '$_temp0';
  }

  @override
  String get signOutFailed => 'Uitloggen mislukt. Probeer het opnieuw';

  @override
  String get signInAccountDeleted => 'Account verwijderd';

  @override
  String get deleteAccountIntro => 'Dit wordt definitief verwijderd:';

  @override
  String get deleteAccountItemCellar =>
      'Je kelder, met de wijnen en de geschiedenis';

  @override
  String get deleteAccountItemShares =>
      'Wat je hebt gedeeld: de uitgenodigde personen verliezen hun toegang';

  @override
  String get deleteAccountItemMemberships =>
      'Je deelname aan kelders van anderen: je gedronken flessen blijven daar staan zonder je naam';

  @override
  String get deleteAccountItemProfile => 'Je profiel';

  @override
  String deleteAccountPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Je hebt $count wijzigingen die nog niet zijn opgeslagen: die worden opgeslagen en daarna met de rest verwijderd',
      one: 'Je hebt 1 wijziging die nog niet is opgeslagen: die wordt opgeslagen en daarna met de rest verwijderd',
    );
    return '$_temp0';
  }

  @override
  String get deleteAccountConfirmWord => 'VERWIJDEREN';

  @override
  String deleteAccountTypeWord(String word) {
    return 'Typ $word om te bevestigen';
  }

  @override
  String get deleteAccountReauthHint =>
      'Daarna log je opnieuw in met Google om te bevestigen dat jij het bent.';

  @override
  String get deleteAccountForever => 'Voorgoed verwijderen';

  @override
  String get deleteAccountNeedsNetwork =>
      'Maak verbinding met internet om het account te verwijderen';

  @override
  String get deleteAccountSameAccount =>
      'Voor het verwijderen moet je met hetzelfde account inloggen';

  @override
  String get deletionTitle => 'Account wordt verwijderd';

  @override
  String get deletionStepPreparePhone => 'Openstaande wijzigingen opslaan';

  @override
  String get deletionStepMarkStarted => 'Verwijderen starten';

  @override
  String get deletionStepLeaveOtherCellars => 'Kelders van anderen verlaten';

  @override
  String get deletionStepCloseOwnInvitations =>
      'Je gedeelde toegang beëindigen';

  @override
  String get deletionStepDeleteWinesAndRecords =>
      'Wijnen en geschiedenis verwijderen';

  @override
  String get deletionStepDeleteCellar => 'Kelder verwijderen';

  @override
  String get deletionStepDeleteProfileAndUser =>
      'Profiel en account verwijderen';

  @override
  String get deletionStepCleanUpPhone => 'Deze telefoon opschonen';

  @override
  String deletionStepAnnounce(int step, String label) {
    return 'Stap $step van 8: $label';
  }

  @override
  String deletionDeletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wijnen en gedronken flessen verwijderd',
      one: '1 wijn of gedronken fles verwijderd',
    );
    return '$_temp0';
  }

  @override
  String get deletionResumeHint =>
      'Het verwijderen van dit account is niet afgerond. Log opnieuw in met Google om het af te maken.';

  @override
  String get deletionContinue => 'Doorgaan';

  @override
  String get deletionOffline =>
      'Maak verbinding met internet om het verwijderen af te ronden';

  @override
  String get deletionPendingWrites =>
      'Ik kan de openstaande wijzigingen niet opslaan. Probeer het opnieuw';

  @override
  String get deletionFailed =>
      'Het verwijderen kon niet worden afgerond. Probeer het opnieuw';

  @override
  String get uxCountryLabel => 'Land';

  @override
  String get uxCountryOther => 'Ander land…';

  @override
  String get uxCountryNone => 'Geen land';

  @override
  String get uxAllCountriesTitle => 'Alle landen en gebieden';

  @override
  String get uxAllCountriesSearch => 'Zoek een land';

  @override
  String get uxAllCountriesRare => 'Zeldzaam voor wijn';

  @override
  String get uxAllCountriesAll => 'Alle, van A tot Z';

  @override
  String get uxAllCountriesNone => 'Geen land gevonden';

  @override
  String get uxRegionLabel => 'Regio';

  @override
  String uxRegionOf(String country) {
    return 'Regio · $country';
  }

  @override
  String get uxRegionOther => 'Andere regio';

  @override
  String get uxRegionFieldLabel => 'Vul de regio in';

  @override
  String get uxRegionTooLong => 'Maximaal 120 tekens';

  @override
  String get uxDrinkAction => 'Eén gedronken';

  @override
  String uxDrinkActionTooltip(String name) {
    return 'Ik heb een fles $name gedronken';
  }

  @override
  String get uxDrinkActionDetail => 'Ik heb een fles gedronken';

  @override
  String get uxDrinkSheetLabel => 'Gedronken fles bevestigen';

  @override
  String get uxDrinkSheetBottles => 'Flessen';

  @override
  String uxDrinkSheetBottlesChange(int before, int after) {
    return 'Flessen: van $before naar $after';
  }

  @override
  String get uxDrinkSheetRating => 'Hoe was de wijn? (optioneel)';

  @override
  String uxDrinkSheetStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sterren van 5',
      one: '1 ster van 5',
    );
    return '$_temp0';
  }

  @override
  String get uxDrinkSheetConfirm => 'Ja, gedronken';

  @override
  String get uxRemoveBottle => 'Fles weghalen zonder te noteren';

  @override
  String get uxRemoveBottleTitle => 'Een fles weghalen?';

  @override
  String uxRemoveBottleBody(String name) {
    return 'Eén fles $name wordt weggehaald en niet als gedronken genoteerd.';
  }

  @override
  String get uxRemoveBottleConfirm => 'Weghalen';

  @override
  String get uxIdealTitle => 'Ideale moment';

  @override
  String uxIdealUntil(String year) {
    return 'Aanbevolen tot $year';
  }

  @override
  String uxIdealUntilPast(String year) {
    return 'Aanbevolen tot $year: dat is voorbij';
  }

  @override
  String uxIdealBest(String start, String end) {
    return 'Op zijn best van $start tot $end';
  }

  @override
  String uxIdealBar(String start, String end) {
    return 'Drinkvenster van $start tot $end';
  }

  @override
  String get uxIdealDisclaimer =>
      '⚠︎ Indicatief: een schatting op basis van type, appellatie en jaargang. Bewaring en de afzonderlijke fles kunnen dit veranderen.';

  @override
  String get uxIdealUnavailableHint =>
      'Vul de jaargang en het type in voor een schatting.';

  @override
  String uxDashboardDrinkNow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count om nu te drinken',
      one: '1 om nu te drinken',
    );
    return '$_temp0';
  }

  @override
  String get uxFamilyRed => 'Rood';

  @override
  String get uxFamilyWhite => 'Wit';

  @override
  String get uxFamilyRose => 'Rosé';

  @override
  String get uxFamilySparkling => 'Mousserend';

  @override
  String get uxFamilySweet => 'Zoet';

  @override
  String get labelBackTitle => 'Nu de achterkant';

  @override
  String get labelBackHint =>
      'Op de achterkant staan meestal de streepjescode, de producent en de jaargang: die helpen de wijn te vinden.';

  @override
  String get labelBackTake => 'Foto van achterkant';

  @override
  String get labelBackGallery => 'Kiezen uit de galerij';

  @override
  String get labelBackSkip => 'Overslaan';

  @override
  String get labelStepFront => 'Voorkant';

  @override
  String get labelStepBack => 'Achterkant';

  @override
  String get labelStepBarcode => 'Streepjescode';

  @override
  String get labelStepDatabase => 'Wijndatabase op de telefoon';

  @override
  String get labelStepPending => 'Wacht';

  @override
  String get labelStepRunning => 'Bezig…';

  @override
  String get labelStepDone => 'Klaar';

  @override
  String get labelStepSkipped => 'Overgeslagen';

  @override
  String get labelStepFailed => 'Niet leesbaar';

  @override
  String labelStepStatus(String step, String status) {
    return '$step: $status';
  }

  @override
  String get labelOnPhoneNote =>
      'Alles gebeurt op de telefoon: de foto\'s worden naar niemand gestuurd.';

  @override
  String get labelBackUnreadable => 'Achterkant niet leesbaar';

  @override
  String get labelSourceOffline => 'Uit de database op de telefoon · offline';

  @override
  String get labelSourceCatalog => 'Uit de catalogus';

  @override
  String get labelSourceOnline => 'Van Open Food Facts · online';

  @override
  String get labelNotThis => 'Niet deze';

  @override
  String get labelOffAttribution =>
      'Gegevens van Open Food Facts, ODbL-licentie';

  @override
  String get labelCandidatesTitle => 'Welke van deze?';

  @override
  String labelCandidatesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vergelijkbare wijnen',
      one: '1 vergelijkbare wijn',
    );
    return '$_temp0';
  }

  @override
  String get labelCandidatesNone => 'Geen van deze';

  @override
  String get labelChipOffline => 'offline';

  @override
  String get labelChipOnline => 'online';

  @override
  String get labelChipCatalog => 'catalogus';

  @override
  String get labelNoProducer => 'producent niet opgegeven';

  @override
  String get labelNoMatch =>
      'Ik heb het etiket gelezen, maar herken de wijn niet';

  @override
  String get labelReadText => 'Gelezen tekst';

  @override
  String get labelSearchOnline => 'Online zoeken';

  @override
  String get labelOpenLens => 'Openen in Google Lens';

  @override
  String get labelLensLastResort =>
      'Google Lens is het laatste redmiddel: de foto gaat alleen naar de Google-app als je dat bevestigt.';

  @override
  String get labelLensTitle => 'Openen in Google Lens?';

  @override
  String get labelLensBody =>
      'De foto van de voorkant gaat naar de Google-app op je telefoon, of naar de app die je kiest; die kan volgens eigen regels een kopie bewaren. Vinoozy ontvangt de resultaten niet: kom hier terug om de wijn te kiezen of in te voeren.';

  @override
  String get labelLensConfirm => 'Google Lens openen';

  @override
  String get labelLensFailed =>
      'Ik kan Google Lens en het deelmenu niet openen';

  @override
  String get onlineSearchTitle => 'Online zoeken';

  @override
  String get onlineSearchSubtitle => 'Open Food Facts · alleen wijnen';

  @override
  String get onlineSearchField => 'Zoekwoorden';

  @override
  String get onlineSearchHint =>
      'Je kunt de woorden aanpassen voordat je zoekt.';

  @override
  String get onlineSearchEmptyField => 'Vul minstens één woord in';

  @override
  String get onlineSearchButton => 'Zoeken';

  @override
  String get onlineSearchLoading => 'Zoeken…';

  @override
  String onlineSearchResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count resultaten',
      one: '1 resultaat',
    );
    return '$_temp0';
  }

  @override
  String get onlineSearchEmpty =>
      'Geen wijn gevonden: probeer andere woorden of \"Handmatig invoeren\".';

  @override
  String get onlineSearchOffline =>
      'Geen netwerk: ik zoek alleen in de database op de telefoon.';

  @override
  String get onlineSearchRateLimited =>
      'Online zoeken is nu niet beschikbaar, probeer het over een paar minuten opnieuw.';

  @override
  String get onlineSearchUnavailable =>
      'Online zoeken is niet actief in deze versie van de app: ik zoek alleen in de database op de telefoon.';

  @override
  String get aboutTitle => 'Over';

  @override
  String aboutVersion(String version) {
    return 'Versie $version';
  }

  @override
  String get aboutDbTitle => 'Wijndatabase';

  @override
  String aboutDbCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wijnen',
      one: '1 wijn',
    );
    return '$_temp0';
  }

  @override
  String aboutDbDate(String date) {
    return 'Export van Open Food Facts van $date';
  }

  @override
  String get aboutDbSample =>
      'Voorbeelddatabase: enkele met de hand geschreven testwijnen, geen gegevens van Open Food Facts.';

  @override
  String get aboutDbLoading => 'Wijndatabase wordt geopend…';

  @override
  String get aboutDbUnavailable =>
      'De wijndatabase is niet beschikbaar in deze versie';

  @override
  String aboutDbSource(String url) {
    return 'De afgeleide database en de tool waarmee die wordt gemaakt staan in de openbare repository: $url';
  }

  @override
  String get aboutLicenseTitle => 'Licenties';

  @override
  String get aboutLicense =>
      'Bevat informatie van Open Food Facts, beschikbaar gesteld onder de Open Database License (ODbL). Afzonderlijke inhoud valt onder de Database Contents License (DbCL).';

  @override
  String get aboutPrivacyTitle => 'Etiketfoto\'s';

  @override
  String get aboutPrivacy =>
      'Etiketfoto\'s worden op de telefoon gelezen en verwijderd wanneer je het resultaat verlaat. Ze verlaten de telefoon alleen als je op \"Openen in Google Lens\" tikt en bevestigt.';

  @override
  String get aboutAppellationsTitle => 'Appellaties';

  @override
  String get aboutAppellationsSource =>
      'Appellaties: het eAmbrosia-register (EU) en officiële nationale registers.';

  @override
  String get aboutAppellationsSample =>
      'Voorbeeldtabel: een met de hand geschreven uittreksel van de registers, tot de echte registers zijn gedownload.';

  @override
  String get denominationLabel => 'Appellatie';

  @override
  String get denominationTooLong => 'Maximaal 120 tekens';

  @override
  String get autofillFilledNotice =>
      'Ingevuld vanaf het etiket: controleer en sla op';

  @override
  String get autofillPastedNotice =>
      'Ingevuld vanuit de tekst: controleer en sla op';

  @override
  String get autofillFromText => '✦ uit de tekst';

  @override
  String get autofillFromTextSemantics => 'ingevuld vanaf het etiket';

  @override
  String get autofillClear => 'Wissen';

  @override
  String get autofillLens => 'Lens';

  @override
  String get autofillClearTitle => 'Formulier wissen?';

  @override
  String get autofillClearBody =>
      'Je hebt zelf ook in enkele velden getypt. \"Wissen\" maakt naam, producent, appellatie, jaargang, type, land, regio en niveau leeg. Het aantal blijft staan.';

  @override
  String get autofillClearConfirm => 'Wissen';

  @override
  String get autofillCleared => 'Formulier gewist';

  @override
  String get autofillPasteTitle => 'Heb je de tekst uit Google Lens?';

  @override
  String get autofillPasteHint =>
      'Selecteer in Lens de tekst van het etiket en tik op \"Kopiëren\", kom daarna hier terug.';

  @override
  String get autofillPaste => 'Plakken uit Lens';

  @override
  String get autofillOpenLens => 'Uit Google Lens';

  @override
  String get autofillOpenLensSemantics => 'opent Google Lens';

  @override
  String get autofillClipboardEmpty => 'Er staat geen tekst op het klembord';

  @override
  String get autofillNoNewFields =>
      'Ik vond in de tekst geen gegevens om toe te voegen';

  @override
  String get autofillFromLens => 'Formulier ingevuld met de tekst uit Lens';

  @override
  String get autofillShareEmpty => 'Geen tekst ontvangen';

  @override
  String get autofillShareUseTitle => 'De tekst gebruiken voor de lege velden?';

  @override
  String get autofillShareUse => 'Gebruiken';

  @override
  String get autofillShareIgnore => 'Negeren';

  @override
  String get addChoiceLens => 'Uit Google Lens';

  @override
  String get addChoicePhotoHint =>
      'Voor- en achterkant: Vinoozy leest het etiket.';

  @override
  String get addChoiceLensHint =>
      'Opent Lens: richt, selecteer de tekst en tik op Delen → Vinoozy.';

  @override
  String get addChoiceImportHint => 'Een foto van het etiket die je al hebt.';

  @override
  String get addChoiceWriteHint => 'Leeg formulier, met \"Plakken uit Lens\".';

  @override
  String get lensInstructionsTitle =>
      'Google Lens kan hiervandaan niet worden geopend';

  @override
  String get lensInstructionsStep1 => 'Open Google Lens en richt op het etiket';

  @override
  String get lensInstructionsStep2 => 'Selecteer de tekst van het etiket';

  @override
  String get lensInstructionsStep3 => 'Tik op Delen → Vinoozy';

  @override
  String get lensInstructionsOk => 'Begrepen';

  @override
  String get levelLabel => 'Niveau';

  @override
  String get levelEveryday => 'Alledaags (goedkoop)';

  @override
  String get levelGood => 'Goed';

  @override
  String get levelAging => 'Om te bewaren';

  @override
  String get levelNone => 'Geen';

  @override
  String get levelEverydayShort => 'vroeg drinken';

  @override
  String get levelGoodShort => 'normale schatting';

  @override
  String get levelAgingShort => 'gaat langer mee';

  @override
  String get levelSuggested => 'voorgesteld';

  @override
  String levelSuggestedReason(String qualifier) {
    return 'Voorgesteld omdat \"$qualifier\" in de naam staat: zo wordt het opgeslagen, tenzij je het wijzigt. Kies een ander niveau of tik op \"Geen\".';
  }

  @override
  String levelSuggestedSemantics(String qualifier) {
    return 'voorgesteld, omdat $qualifier in de naam staat';
  }

  @override
  String levelOptionSemantics(String option, int index, int count) {
    return 'Niveau, $option, $index van $count';
  }

  @override
  String get levelWhatChanges => 'Wat er verandert';

  @override
  String get levelEverydayExamples =>
      'Het venster wordt korter. Bv. huiswijn, Lambrusco, eenvoudige Prosecco, Bardolino, Vinho Verde.';

  @override
  String get levelGoodExamples =>
      'De normale schatting, ook als je niets kiest. Bv. Chianti Classico, Barbera d\'Asti Superiore, Rioja Crianza, Côtes du Rhône.';

  @override
  String get levelAgingExamples =>
      'Het venster wordt langer. Bv. Barolo, Brunello, Amarone, Bordeaux Grand Cru, Rioja Gran Reserva, Vintage Port.';

  @override
  String levelPreviewBefore(String start, String end) {
    return 'Eerst $start – $end';
  }

  @override
  String levelPreviewWith(String level, String start, String end) {
    return 'Met \"$level\" $start – $end';
  }

  @override
  String levelPreviewNow(String start, String end) {
    return 'Op dronk $start – tot $end';
  }

  @override
  String levelDetail(String level) {
    return 'Niveau: $level';
  }

  @override
  String get overrideCorrect => 'Corrigeren';

  @override
  String get overrideRestore => 'Schatting herstellen';

  @override
  String get overrideCorrectedByYou => 'door jou gecorrigeerd';

  @override
  String overrideAppEstimate(String year) {
    return 'Schatting van de app: tot $year';
  }

  @override
  String get overrideSheetTitle => 'Aanbevolen tot';

  @override
  String overrideSheetHint(String start) {
    return 'Kies het jaar. Het mag niet vóór \"Op dronk vanaf $start\" liggen.';
  }

  @override
  String overridePeakNotice(String peak) {
    return 'Als je een jaar vóór $peak (op zijn best) kiest, schuift ook \"op zijn best\" naar datzelfde jaar.';
  }

  @override
  String get overrideMore => 'meer…';

  @override
  String get overrideSave => 'Correctie opslaan';

  @override
  String overrideRestoreTitle(String year) {
    return 'Terug naar de schatting van de app (tot $year)?';
  }

  @override
  String get overrideRestoreConfirm => 'Herstellen';

  @override
  String get overrideSaved => 'Correctie opgeslagen';

  @override
  String get overrideRestored => 'Schatting hersteld';

  @override
  String get estimateSourceCorrectedByYou => 'door jou gecorrigeerd';

  @override
  String estimateFromDenomination(String name) {
    return 'Schatting op basis van de appellatie $name';
  }

  @override
  String estimateFromDenominationQualifier(String name, String qualifier) {
    return 'Schatting op basis van de appellatie $name, $qualifier';
  }

  @override
  String estimateFromGrape(String name) {
    return 'Schatting op basis van het druivenras $name';
  }

  @override
  String get estimateFromType => 'Schatting op basis van het type wijn';

  @override
  String get autofillReading => 'Ik lees de tekst…';

  @override
  String get guideChip => 'Begeleide controle';

  @override
  String guideProgress(int n, int total) {
    return 'Vraag $n van $total';
  }

  @override
  String get guideClose => 'Sluiten';

  @override
  String get guideIsDenomination => 'is dit de appellatie?';

  @override
  String get guideIsProducer => 'is dit de producent?';

  @override
  String get guideIsName => 'is dit de naam van de wijn?';

  @override
  String get guideIsVintage => 'Jaargang';

  @override
  String guideAskDenomination(String value) {
    return 'Is $value de appellatie?';
  }

  @override
  String guideAskProducer(String value) {
    return 'Is $value de producent?';
  }

  @override
  String guideAskName(String value) {
    return 'Is $value de naam van de wijn?';
  }

  @override
  String get guideAskVintage => 'Wat is de jaargang?';

  @override
  String guideQuestionSemantics(int n, int total, String question) {
    return 'Vraag $n van $total: $question';
  }

  @override
  String get guideNoProposal => 'Ik kon het niet in de tekst vinden';

  @override
  String get guideYes => 'Ja';

  @override
  String get guideNo => 'Nee, iets anders';

  @override
  String get guideEdit => 'Bewerken';

  @override
  String get guideSkip => 'Overslaan';

  @override
  String get guideConfirm => 'Bevestigen';

  @override
  String get guideCancel => 'Annuleren';

  @override
  String guideRejected(String value) {
    return 'Niet \"$value\": hier is het volgende voorstel';
  }

  @override
  String get guideNoMore =>
      'Geen ander voorstel: stel het zelf samen of sla over';

  @override
  String guideProposalAnnounce(String value) {
    return 'Voorstel: $value';
  }

  @override
  String get guideComposeLabel =>
      'Of stel het samen door op woorden uit de tekst te tikken';

  @override
  String get guideComposePreview => 'Voorbeeld';

  @override
  String get guideComposeEmpty => 'Tik op een of meer woorden';

  @override
  String get guideComposeLimit => 'Maximaal 8 woorden en 80 tekens';

  @override
  String guideTableMatchSemantics(String name) {
    return 'komt overeen met $name';
  }

  @override
  String guideLine(int n, int total) {
    return 'Regel $n van $total';
  }

  @override
  String guideWordSelected(String word, int order) {
    return '$word, geselecteerd, $order';
  }

  @override
  String guideWordUnavailable(String word) {
    return '$word, niet beschikbaar';
  }

  @override
  String guideWordUsedFor(String word, String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'de appellatie',
      'producer': 'de producent',
      'other': 'de naam',
    });
    return '$word, gebruikt voor $_temp0';
  }

  @override
  String guideUsedMark(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'appellatie',
      'producer': 'producent',
      'other': 'naam',
    });
    return '$_temp0';
  }

  @override
  String guideOtherYears(String years) {
    return 'Ook in de tekst: $years';
  }

  @override
  String get guideWheelFromText => 'jaar gevonden in de tekst';

  @override
  String get guideWheelTypeYear => 'Typ het jaar';

  @override
  String guideWheelConfirm(String year) {
    return '$year bevestigen';
  }

  @override
  String get guideNoVintage => 'Geen jaargang';

  @override
  String guideSkippedNotice(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'Appellatie overgeslagen',
      'producer': 'Producent overgeslagen',
      'vintage': 'Jaargang overgeslagen',
      'other': 'Naam overgeslagen',
    });
    return '$_temp0: vul zelf in of ga verder met de begeleiding';
  }

  @override
  String guideSkippedMany(int count) {
    return '$count velden overgeslagen: vul ze zelf in of ga verder met de begeleiding';
  }

  @override
  String get guideInvalidValue =>
      'Deze tekst bevat tekens die niet kunnen worden opgeslagen';

  @override
  String get brandStudio => 'Bottazzini Softworks';

  @override
  String get suggestedMark => '✦ voorgesteld';

  @override
  String suggestedSemantics(String field, String value) {
    return '$field, $value, voorgesteld';
  }

  @override
  String get restoreSuggestion => 'Voorstel herstellen';

  @override
  String get restoreSuggestionDone => 'Voorstel hersteld';

  @override
  String get styleLabel => 'Stijl';

  @override
  String styleGroupSemantics(String value, int index, int count) {
    return 'Stijl, $value, $index van $count';
  }

  @override
  String get styleRedFresh => 'Fris';

  @override
  String get styleRedMedium => 'Medium';

  @override
  String get styleRedAge => 'Om te bewaren';

  @override
  String get styleRedLong => 'Lang bewaren';

  @override
  String get styleWhiteFresh => 'Fris';

  @override
  String get styleWhiteMedium => 'Medium';

  @override
  String get styleWhiteAge => 'Om te bewaren';

  @override
  String get styleRoseFresh => 'Fris';

  @override
  String get styleClassicFresh => 'Fris';

  @override
  String get styleClassicAge => 'Om te bewaren';

  @override
  String get styleTankFresh => 'Fris';

  @override
  String get styleLambrusco => 'Lambrusco';

  @override
  String get styleSweetAromatic => 'Aromatisch';

  @override
  String get styleSweetPassito => 'Gedroogde druiven';

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
  String get styleFortifiedOther => 'Overig';

  @override
  String get profileNameRFresh => 'Fruitige rode wijn';

  @override
  String get profileNameRMedium => 'Middelvolle rode wijn';

  @override
  String get profileNameRAge => 'Rode bewaarwijn';

  @override
  String get profileNameRLong => 'Rode wijn om lang te bewaren';

  @override
  String get profileNameWFresh => 'Frisse aromatische witte wijn';

  @override
  String get profileNameWMedium => 'Middelvolle witte wijn';

  @override
  String get profileNameWAge => 'Witte bewaarwijn';

  @override
  String get profileNameRoseFresh => 'Frisse rosé';

  @override
  String get profileNameSpTank => 'Frisse mousserende wijn, tankmethode';

  @override
  String get profileNameLamFresh => 'Frisse Lambrusco';

  @override
  String get profileNameSpClassic =>
      'Frisse mousserende wijn, traditionele methode';

  @override
  String get profileNameSpClassicAge =>
      'Mousserende bewaarwijn, traditionele methode';

  @override
  String get profileNameSwAromatic => 'Jonge aromatische zoete wijn';

  @override
  String get profileNameSwPassito => 'Zoete wijn van gedroogde druiven';

  @override
  String get profileNameSwBotrytis => 'Zoete botrytiswijn';

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
  String get profileNameFortUnknown => 'Versterkt, stijl onbekend';

  @override
  String get profileNameUnknown => 'Stijl niet herkend';

  @override
  String estimateFromProfile(String profile, String denomination) {
    return 'Schatting op basis van het profiel $profile ($denomination)';
  }

  @override
  String estimateFromProfileType(String profile) {
    return 'Schatting op basis van het profiel $profile, volgens het type';
  }

  @override
  String estimateFromProfileGrape(String profile, String grape) {
    return 'Schatting op basis van het profiel $profile, volgens het druivenras $grape';
  }

  @override
  String get estimateFromEntryDateDisgorgement =>
      'Vanaf de datum van toevoegen: vul de datum van dégorgement in voor een betere schatting';

  @override
  String get estimateFromEntryDateBottling =>
      'Vanaf de datum van toevoegen: vul de botteldatum in voor een betere schatting';

  @override
  String get styleToConfirmBanner =>
      '⚠︎ Stijl nog te bevestigen: de schatting is indicatief';

  @override
  String get chooseTypePrompt => 'Kies het type';

  @override
  String estimateUpdatedAnnouncement(String summary) {
    return 'Schatting bijgewerkt: $summary';
  }

  @override
  String get agingStartDisgorgement => 'Dégorgement';

  @override
  String get agingStartBottling => 'Botteling';

  @override
  String get agingStartMonth => 'Maand';

  @override
  String get agingStartYear => 'Jaar';

  @override
  String get agingStartHint => 'Staat meestal op het achteretiket.';

  @override
  String get agingStartIncomplete => 'Vul maand en jaar in';

  @override
  String get agingStartFuture => 'De datum mag niet in de toekomst liggen';

  @override
  String get agingStartBeforeVintage => 'Dit mag niet vóór de jaargang liggen';

  @override
  String get windowNoEnd => 'Op dronk, geen einde geschat';

  @override
  String get windowNoEndShort => 'geen einde geschat';

  @override
  String windowDrinkWithin(String date) {
    return 'uiterlijk $date';
  }

  @override
  String get levelNoEffect => 'Het niveau verandert deze schatting niet';

  @override
  String get dashboardToConfirmTitle => 'Te bevestigen';

  @override
  String dashboardToConfirmCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wijnen',
      one: '1 wijn',
    );
    return '$_temp0';
  }

  @override
  String aboutDbClassified(String percent) {
    return '$percent% van de wijnen met een herkend type';
  }

  @override
  String get planTitle => 'Pakket';

  @override
  String get planFree => 'Gratis';

  @override
  String get planPlus => 'Plus';

  @override
  String get planPlusGift => 'Plus (cadeau)';

  @override
  String get planDevUnlockAll => 'DEV · Test-Plus';

  @override
  String get planDevSimulateFree => 'DEV · Gratis pakket gesimuleerd';

  @override
  String get planDevSimulateExpired => 'DEV · Verlopen Plus gesimuleerd';

  @override
  String get planDiscoverPlus => 'Ontdek Plus';

  @override
  String get plusTitle => 'Vinoozy Plus';

  @override
  String get plusBenefitsTitle => 'Met Plus';

  @override
  String get plusBenefitNoAds => 'Geen advertenties';

  @override
  String get plusBenefitNoLimit => 'Geen limiet op de wijnen in je kelder';

  @override
  String get plusComingSoon => 'Plus komt binnenkort';

  @override
  String get plusLoading => 'Prijzen ophalen bij Google Play';

  @override
  String get plusStoreUnavailable =>
      'De prijzen konden niet bij Google Play worden opgehaald. Probeer het later opnieuw.';

  @override
  String plusPriceMonthly(String price) {
    return '$price per maand';
  }

  @override
  String plusPriceAnnual(String price) {
    return '$price per jaar';
  }

  @override
  String get plusRenewal =>
      'Het abonnement wordt automatisch verlengd tegen de getoonde prijs tot je het opzegt in Google Play.';

  @override
  String get plusTerms =>
      'De betaling wordt van je Google Play-account afgeschreven wanneer je de aankoop bevestigt. Je kunt op elk moment opzeggen: Plus blijft actief tot het einde van de al betaalde periode. Als Plus afloopt, blijven al je wijnen staan.';

  @override
  String get plusRestore => 'Aankopen herstellen';

  @override
  String get plusManage => 'Abonnement beheren of opzeggen in Google Play';

  @override
  String get plusActive => 'Plus is actief op dit account';

  @override
  String get plusActiveGift =>
      'Je hebt Plus cadeau gekregen: geen kosten en geen verlengingen.';

  @override
  String get plusPending =>
      'Betaling in behandeling: Plus wordt actief zodra Google Play de betaling bevestigt.';

  @override
  String get plusVerifying => 'Aankoop wordt gecontroleerd';

  @override
  String get plusVerified =>
      'Aankoop gecontroleerd: Plus is over enkele seconden actief.';

  @override
  String get plusPurchaseFailed =>
      'De aankoop is niet voltooid. Probeer het opnieuw.';

  @override
  String get plusInvalidPurchase =>
      'Google Play heeft deze aankoop voor Vinoozy niet bevestigd.';

  @override
  String get plusOwnedByOther =>
      'Dit abonnement hoort al bij een ander Vinoozy-account.';

  @override
  String get plusVerificationUnavailable =>
      'De aankoop kon nu niet worden gecontroleerd. Probeer het later opnieuw: het abonnement blijft in Google Play staan.';

  @override
  String get capacityLimitTitle =>
      'Je hebt de limiet van het gratis pakket bereikt';

  @override
  String capacityLimitBody(int limit) {
    return 'Het gratis pakket biedt ruimte voor maximaal $limit verschillende wijnen in je kelder. De wijnen die je al hebt kun je altijd bewerken, drinken en met flessen aanvullen. Om een nieuwe toe te voegen drink je een wijn op of verwijder je er een, of stap je over op Plus.';
  }

  @override
  String capacityLimitBodyComingSoon(int limit) {
    return 'Het gratis pakket biedt ruimte voor maximaal $limit verschillende wijnen in je kelder. De wijnen die je al hebt kun je altijd bewerken, drinken en met flessen aanvullen. Om een nieuwe toe te voegen drink je een wijn op of verwijder je er een. Plus komt binnenkort.';
  }

  @override
  String get rejectedCapacityLimit =>
      'Niet gesynchroniseerd: dit gaat over de wijnlimiet van het gratis pakket. De wijziging blijft op deze telefoon staan.';

  @override
  String get rejectedCapacityConflict =>
      'Niet gesynchroniseerd: de kelder is tegelijk op een ander apparaat gewijzigd. De wijziging blijft op deze telefoon staan: probeer het opnieuw.';

  @override
  String writeRejectedCapacityLimit(String name) {
    return '$name: niet gesynchroniseerd, boven de limiet van het gratis pakket';
  }

  @override
  String writeRejectedCapacityConflict(String name) {
    return '$name: niet gesynchroniseerd, de kelder is op een ander apparaat gewijzigd';
  }

  @override
  String get freeIntroTitle => 'Het gratis pakket';

  @override
  String freeIntroLimit(int limit) {
    return 'Je kunt gratis tot $limit verschillende wijnen beheren.';
  }

  @override
  String get freeIntroAds =>
      'Bij licht gebruik zie je geen advertenties. Als je boven de maandelijkse gebruiksdrempel van de dienst komt, kun je af en toe advertenties zien die helpen de kosten van servers en synchronisatie te dekken.';

  @override
  String get freeIntroNoAds => 'Geen advertenties in de lanceringsversie.';

  @override
  String get freeIntroPlus =>
      'Met Plus verdwijnen de advertenties en de kelderlimiet.';

  @override
  String get noticeGotIt => 'Begrepen';

  @override
  String get thresholdTitle => 'Advertenties helpen Vinoozy gratis te houden';

  @override
  String get thresholdBody =>
      'Je hebt de maandelijkse drempel voor gebruik zonder advertenties bereikt. Vanaf nu kun je af en toe advertenties zien: ze helpen ons de kosten van servers en synchronisatie te dekken, zodat Vinoozy gratis blijft.';

  @override
  String get thresholdReset =>
      'De telling begint volgende maand opnieuw. Met Plus gebruik je de app zonder advertenties en zonder kelderlimiet.';

  @override
  String thresholdNextReset(String date) {
    return 'Volgende reset: $date';
  }

  @override
  String get thresholdHowItWorks => 'Hoe het werkt';

  @override
  String get thresholdHowItWorksBody =>
      'De drempel hangt af van een schatting van de synchronisaties met de cloud die dit account in de maand doet. Offline gebruik alleen zorgt niet voor nieuwe cloudbewerkingen. Advertenties verschijnen hooguit één keer per dag, alleen in het Overzicht, en nooit terwijl je je gegevens opslaat of exporteert.';

  @override
  String get adLabel => 'Advertentie';

  @override
  String get devToolsTitle => 'Ontwikkelaarstools';

  @override
  String get devUnlockAll => 'Alles ontgrendelen — test-Plus';

  @override
  String get devSimulateFree => 'Gratis pakket simuleren';

  @override
  String get devSimulateExpired => 'Verlopen Plus simuleren';

  @override
  String get devRestore => 'Normale toestand herstellen';

  @override
  String get devNoOverride => 'Geen simulatie actief';

  @override
  String get devApplied => 'Scenario ook toegepast in de Firestore-emulator';

  @override
  String get devIncomplete =>
      'Onvolledige simulatie: de Firestore-emulator heeft het testrecht niet bevestigd. De serverregels zien dit scenario niet.';

  @override
  String get devNotice =>
      'Alleen ontwikkelbuilds met de emulator: geen betalingen, tokens of bonnen.';

  @override
  String get settingsTitle => 'Instellingen';

  @override
  String get settingsGuide => 'De rondleiding opnieuw bekijken';

  @override
  String get settingsShare => 'De app delen';

  @override
  String get settingsRate => 'De app beoordelen';

  @override
  String get settingsFeedback => 'Feedback versturen';

  @override
  String get settingsFaq => 'Veelgestelde vragen';

  @override
  String get settingsShareFailed =>
      'Het deelmenu kon niet worden geopend. Probeer het opnieuw';

  @override
  String get settingsRateFailed =>
      'Google Play kon niet worden geopend. Probeer het opnieuw';

  @override
  String get guideAddTitle => 'Een wijn toevoegen';

  @override
  String get guideAddBody =>
      'Tik op Toevoegen om een fles in je kelder te leggen. Om te beginnen is de naam voldoende.';

  @override
  String get guideLabelTitle => 'Het etiket laten lezen';

  @override
  String get guideLabelBody =>
      'Onder Toevoegen kun je ook het etiket fotograferen: Vinoozy leest de naam, het oogstjaar en de herkomstbenaming, en jij controleert ze voordat je opslaat.';

  @override
  String get guideTabsTitle => 'Overzicht, Kelder, Geschiedenis';

  @override
  String get guideTabsBody =>
      'Het Overzicht vertelt je welke wijnen je nu kunt openen, de Kelder toont al je flessen en de Geschiedenis bewaart de flessen die je al hebt gedronken.';

  @override
  String get guideMenuTitle => 'Het kelder-menu';

  @override
  String get guideMenuBody =>
      'Hier vind je je profiel, de personen met wie je de kelder deelt, de gedronken wijnen en de Instellingen, waar je deze rondleiding altijd opnieuw kunt bekijken.';

  @override
  String get guideDone => 'Klaar';

  @override
  String guideStepOf(int step, int count) {
    return 'Stap $step van $count';
  }

  @override
  String get hintDashboard =>
      'Hier zie je welke wijnen nu klaar zijn om te drinken en welke je beter nog een tijdje kunt laten liggen.';

  @override
  String get hintHistory =>
      'Elke fles die je drinkt komt hier terecht, samen met je beoordeling en je notities.';

  @override
  String get hintAddWine =>
      'Begin met de naam: het oogstjaar, het type en de herkomstbenaming maken het drinkvenster nauwkeuriger.';

  @override
  String get shareAppSubject => 'Vinoozy, jouw wijnkelder';

  @override
  String shareAppMessage(String link) {
    return 'Ik beheer mijn wijnkelder met Vinoozy: de app vertelt me wanneer elke fles op haar best is. Probeer het zelf: $link';
  }

  @override
  String get feedbackSubject => 'Feedback over Vinoozy';

  @override
  String get feedbackTechHeader => 'Technische gegevens (graag laten staan):';

  @override
  String get feedbackNoEmailTitle => 'Geen e-mailapp gevonden';

  @override
  String feedbackNoEmailBody(String email) {
    return 'Er staat geen e-mailapp op deze telefoon. Schrijf ons op $email';
  }

  @override
  String get feedbackCopy => 'Kopiëren';

  @override
  String get feedbackCopied => 'Adres gekopieerd';

  @override
  String get faqAddQuestion => 'Hoe voeg ik met de hand een wijn toe?';

  @override
  String get faqAddAnswer =>
      'Tik in de Kelder op Toevoegen en daarna op Invoeren. Alleen de naam is verplicht; het oogstjaar, het type, het land en de herkomstbenaming maken de schatting beter. Sla op en de wijn ligt in je kelder.';

  @override
  String get faqLabelQuestion => 'Hoe lees ik een etiket, ook met Google Lens?';

  @override
  String get faqLabelAnswer =>
      'Tik op Toevoegen en fotografeer de voorkant en de achterkant: Vinoozy leest het etiket rechtstreeks op je telefoon. Selecteer in Google Lens de tekst en deel die met Vinoozy, of kopieer de tekst en gebruik Plakken uit Lens in het formulier. Controleer altijd de velden voordat je opslaat.';

  @override
  String get faqWindowQuestion =>
      'Hoe wordt het beste moment om te drinken berekend, en kan ik het aanpassen?';

  @override
  String get faqWindowAnswer =>
      'Vinoozy schat een venster (begin, hoogtepunt, einde) op basis van het type, de herkomstbenaming, het oogstjaar en het niveau van de wijn. Het is een richtlijn: ook de manier waarop de fles is bewaard telt mee. Open de wijn en tik op Corrigeren om je eigen datum in te stellen, of verander het Niveau.';

  @override
  String get faqOfflineQuestion => 'Werkt het zonder internet?';

  @override
  String get faqOfflineAnswer =>
      'Ja. Je kunt wijnen offline toevoegen, bewerken en drinken: alles wordt op de telefoon opgeslagen en met je account gesynchroniseerd zodra de verbinding terug is.';

  @override
  String get faqShareQuestion => 'Hoe deel ik mijn kelder?';

  @override
  String get faqShareAnswer =>
      'Open in het kelder-menu Personen en nodig iemand uit met zijn of haar Google-e-mailadres, alleen lezen of met bewerken. Die persoon installeert Vinoozy en logt in met dat account.';

  @override
  String get faqPlusQuestion =>
      'Wat zit er in het gratis abonnement, en wat is Plus?';

  @override
  String faqPlusAnswer(int limit) {
    return 'Het gratis abonnement omvat tot $limit verschillende wijnen in je kelder, met af en toe een advertentie, alleen in het Overzicht. Vinoozy Plus haalt de limiet en de advertenties weg.';
  }

  @override
  String get faqDrinkQuestion =>
      'Waarom zou ik bijhouden wat ik dronk en hoe het was?';

  @override
  String get faqDrinkAnswer =>
      'De Geschiedenis bewaart wat je hebt gedronken en hoe je het vond. Als je aangeeft hoe de fles was (nog te jong, precies goed, over het hoogtepunt), corrigeert Vinoozy de schatting voor dezelfde wijn.';

  @override
  String get faqDeleteQuestion => 'Hoe verwijder ik mijn account?';

  @override
  String get faqDeleteAnswer =>
      'Open Profiel en tik op Account verwijderen. Je hebt een verbinding nodig en logt daarna opnieuw in met Google om te bevestigen. Je kelder, de Geschiedenis en alles wat je hebt gedeeld worden definitief verwijderd.';

  @override
  String get faqNotFound => 'Het antwoord niet gevonden? Schrijf ons';
}
