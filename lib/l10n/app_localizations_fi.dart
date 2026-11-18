// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Finnish (`fi`).
class AppLocalizationsFi extends AppLocalizations {
  AppLocalizationsFi([String locale = 'fi']) : super(locale);

  @override
  String get appTitle => 'Vinoozy';

  @override
  String get signInTagline => 'Kellarisi, oikeaan aikaan';

  @override
  String get signInWithGoogle => 'Jatka Google-tilillä';

  @override
  String get signInInProgress => 'Kirjaudutaan sisään';

  @override
  String get signInFailed => 'Kirjautuminen epäonnistui';

  @override
  String get signInNeedsNetwork =>
      'Ensimmäinen kirjautuminen vaatii verkkoyhteyden';

  @override
  String get signInSessionExpired =>
      'Istunto on vanhentunut: kirjaudu uudelleen';

  @override
  String get retry => 'Yritä uudelleen';

  @override
  String get cancel => 'Peruuta';

  @override
  String blockedMessage(String email) {
    return 'Tilin $email muutoksia ei ole vielä tallennettu pilveen: kirjaudu sillä tilillä ja yhdistä verkkoon';
  }

  @override
  String blockedSignInWith(String email) {
    return 'Kirjaudu tilillä $email';
  }

  @override
  String blockedDiscard(String email) {
    return 'Poista tilin $email tallentamattomat muutokset';
  }

  @override
  String get discardDialogTitle => 'Poistetaanko muutokset?';

  @override
  String discardDialogBody(int count, String email) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Tilin $email $count viiniä ei ole vielä pilvessä, ja ne poistetaan tästä puhelimesta.',
      one:
          'Tilin $email 1 viini ei ole vielä pilvessä, ja se poistetaan tästä puhelimesta.',
    );
    return '$_temp0';
  }

  @override
  String get discardConfirm => 'Poista';

  @override
  String get resetFailed => 'Puhelimen tietoja ei voitu tyhjentää';

  @override
  String get restartRequired => 'Viimeistele käynnistämällä sovellus uudelleen';

  @override
  String get restartCloseApp => 'Sulje sovellus';

  @override
  String get startupFailed => 'Sovellus ei käynnistynyt';

  @override
  String get cellarTitle => 'Kellari';

  @override
  String get defaultCellarName => 'Oma kellarini';

  @override
  String get cellarLoading => 'Kellaria valmistellaan';

  @override
  String get cellarSetupFailed => 'Kellarin valmistelu epäonnistui';

  @override
  String get cellarEmpty => 'Kellarisi on tyhjä';

  @override
  String get addWine => 'Lisää';

  @override
  String get estimatePending => 'Arvio tulossa';

  @override
  String get noVintage => 'Ei vuosikertaa';

  @override
  String bottleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pulloa',
      one: '1 pullo',
    );
    return '$_temp0';
  }

  @override
  String get syncInProgress => 'Synkronoidaan';

  @override
  String get syncOffline => 'Offline - synkronointi odottaa';

  @override
  String writeRejected(String name) {
    return 'Muutos ei ole sallittu: $name';
  }

  @override
  String get saveFailed => 'Tallennus epäonnistui, yritä uudelleen';

  @override
  String wineNotSaved(String name) {
    return 'Viiniä $name ei tallennettu pilveen';
  }

  @override
  String get addAgain => 'Lisää uudelleen';

  @override
  String get ignore => 'Ohita';

  @override
  String get addWineTitle => 'Kirjoita';

  @override
  String get wineNameLabel => 'Viini';

  @override
  String get vintageLabel => 'Vuosikerta';

  @override
  String get quantityLabel => 'Määrä';

  @override
  String get decreaseQuantity => 'Vähennä määrää';

  @override
  String get increaseQuantity => 'Lisää määrää';

  @override
  String get save => 'Tallenna';

  @override
  String get nameRequired => 'Kirjoita viinin nimi';

  @override
  String get nameTooLong => 'Enintään 120 merkkiä';

  @override
  String vintageRange(String year) {
    return 'Vuosikerta väliltä 1900–$year';
  }

  @override
  String get offAttribution => 'Tiedot: Open Food Facts (ODbL)';

  @override
  String get dashboardTitle => 'Yleiskuva';

  @override
  String dashboardTotalBottles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pulloa kellarissa',
      one: '1 pullo kellarissa',
    );
    return '$_temp0';
  }

  @override
  String get dashboardSyncing => 'Kellaria synkronoidaan…';

  @override
  String get dashboardAddFirstWine => 'Lisää ensimmäinen viinisi';

  @override
  String get drinkSoonTitle => 'Juo pian';

  @override
  String get drinkSoonEmpty => 'Ei pian juotavia pulloja';

  @override
  String drinkSoonUntil(String year) {
    return 'viimeistään $year';
  }

  @override
  String drinkSoonSeeAll(int count) {
    return 'Näytä kaikki ($count)';
  }

  @override
  String get statusChartTitle => 'Pullojen tila';

  @override
  String get statusWaiting => 'odota';

  @override
  String get statusReady => 'valmis';

  @override
  String get statusDrinkSoon => 'juo pian';

  @override
  String get statusPastWindow => 'ikkuna ohi';

  @override
  String toEstimateNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pulloa arvioimatta',
      one: '1 pullo arvioimatta',
    );
    return '$_temp0';
  }

  @override
  String chartBarValue(String label, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pulloa',
      one: '1 pullo',
    );
    return '$label: $_temp0';
  }

  @override
  String chartDescription(String title, String values) {
    return '$title: $values';
  }

  @override
  String get openListHint => 'Avaa luettelo';

  @override
  String get peakChartTitle => 'Huippuvuosi';

  @override
  String get peakPast => 'huippu ohi';

  @override
  String get peakBeyond => 'myöhemmin';

  @override
  String get breakdownTypeTitle => 'Pullot tyypeittäin';

  @override
  String get breakdownRegionTitle => 'Pullot alueittain';

  @override
  String get breakdownType => 'Tyyppi';

  @override
  String get breakdownRegion => 'Alue';

  @override
  String get familyRed => 'punaviini';

  @override
  String get familyWhite => 'valkoviini';

  @override
  String get familyRose => 'roseeviini';

  @override
  String get familySparkling => 'kuohuviini';

  @override
  String get familySweet => 'makea';

  @override
  String get breakdownUnspecified => 'ei määritetty';

  @override
  String get breakdownOtherRegions => 'muut';

  @override
  String get ok => 'OK';

  @override
  String get cellarMenu => 'Kellarivalikko';

  @override
  String get sharingPeopleTitle => 'Henkilöt';

  @override
  String get sharingInviteTitle => 'Kutsu henkilö';

  @override
  String get sharingEmailLabel => 'Google-sähköpostiosoite';

  @override
  String get sharingPermissionRead => 'Vain luku';

  @override
  String get sharingPermissionReadHint =>
      'Näkee viinit, arviot, yleiskuvan ja maistelut';

  @override
  String get sharingPermissionEdit => 'Voi muokata';

  @override
  String get sharingPermissionEditHint =>
      'Lisää ja muokkaa myös viinejä ja kirjaa maisteluja';

  @override
  String get sharingRoleOwner => 'omistaja';

  @override
  String get sharingInviteButton => 'Kutsu';

  @override
  String sharingPlacesUsed(int used, int max) {
    return '$used/$max henkilöä';
  }

  @override
  String get sharingInvalidEmail => 'Anna kelvollinen sähköpostiosoite';

  @override
  String get sharingSelfInvite => 'Et voi kutsua itseäsi';

  @override
  String get sharingAlreadyInvited => 'Tämä henkilö on jo kutsuttu';

  @override
  String sharingLimitReached(int max) {
    return 'Henkilöraja on täynnä: $max';
  }

  @override
  String get sharingNotOwner => 'Et voi muuttaa tämän kellarin jakamista';

  @override
  String get sharingNotFound => 'Tätä henkilöä ei enää ole luettelossa';

  @override
  String get sharingFailed => 'Ei onnistunut, yritä uudelleen';

  @override
  String get sharingInviteFailed => 'Kutsu epäonnistui. Yritä uudelleen';

  @override
  String get sharingOfflineHint => 'Jakamisen hallinta vaatii verkkoyhteyden';

  @override
  String get sharingStatusInvited => 'kutsuttu';

  @override
  String get sharingStatusActive => 'aktiivinen';

  @override
  String get sharingStatusRevoked => 'peruttu';

  @override
  String get sharingStatusLeft => 'poistunut';

  @override
  String sharingMemberSemantics(String name, String permission, String status) {
    return '$name, $permission, $status';
  }

  @override
  String get sharingClosedSection => 'Suljetut käyttöoikeudet';

  @override
  String get sharingNobody => 'Kukaan muu ei vielä näe tätä kellaria';

  @override
  String sharingChangePermission(String name) {
    return 'Muuta käyttöoikeutta: $name';
  }

  @override
  String get sharingRevoke => 'Peru';

  @override
  String sharingRevokeTitle(String name) {
    return 'Perutaanko käyttäjän $name käyttöoikeus?';
  }

  @override
  String sharingRevokeConfirmLabel(String name) {
    return 'Vahvista kirjoittamalla $name';
  }

  @override
  String get sharingRevokeDisabledHint => 'Käytössä, kun nimi täsmää';

  @override
  String get sharingReinvite => 'Kutsu uudelleen';

  @override
  String get sharingDeleteForGood => 'Poista pysyvästi';

  @override
  String sharingOwnedBy(String owner) {
    return 'Omistaja: $owner';
  }

  @override
  String get sharingYourCellar => 'Oma kellarisi';

  @override
  String sharingYourPermission(String permission) {
    return 'Käyttöoikeutesi: $permission';
  }

  @override
  String sharingSwitcherSemantics(String cellar, String permission) {
    return '$cellar, $permission. Vaihda kellaria napauttamalla';
  }

  @override
  String get sharingLeave => 'Poistu tästä kellarista';

  @override
  String sharingLeaveTitle(String owner) {
    return 'Poistutko kellarista (omistaja: $owner)?';
  }

  @override
  String sharingLeaveBody(String owner) {
    return 'Et näe sitä enää. $owner voi kutsua sinut uudelleen.';
  }

  @override
  String get sharingLeaveConfirm => 'Poistu';

  @override
  String sharingSharedNotice(String owner) {
    return '$owner jakoi kellarinsa kanssasi';
  }

  @override
  String sharingAccessLost(String owner) {
    return 'Sinulla ei ole enää pääsyä kellariin (omistaja: $owner)';
  }

  @override
  String sharingWritesLost(String owner) {
    return 'Osa muutoksista jäi tallentamatta, koska sinulla ei ole enää pääsyä kellariin (omistaja: $owner)';
  }

  @override
  String get sharingSomeone => 'joku';

  @override
  String get sharingShareSubject => 'Vinoozy-kutsu';

  @override
  String sharingShareMessage(
    String owner,
    String cellar,
    String link,
    String email,
  ) {
    return '$owner kutsui sinut Vinoozy-sovelluksessa kellariin ”$cellar”. Asenna sovellus osoitteesta $link ja kirjaudu Google-tilillä $email: käytä täsmälleen tätä osoitetta.';
  }

  @override
  String get cellarSearchHint => 'Hae nimellä tai tuottajalla';

  @override
  String get cellarFilterStatus => 'Tila';

  @override
  String get cellarFilterType => 'Tyyppi';

  @override
  String get statusToEstimate => 'Arvioimatta';

  @override
  String get filterTypeUnspecified => 'Ei määritetty';

  @override
  String get cellarNoMatches => 'Ei viinejä näillä suodattimilla';

  @override
  String get cellarClearFilters => 'Tyhjennä suodattimet';

  @override
  String get cellarArchiveTitle => 'Juodut';

  @override
  String get cellarArchiveEmpty => 'Ei vielä loppuneita viinejä';

  @override
  String get cellarArchiveFailed => 'Loppuneiden viinien lataus epäonnistui';

  @override
  String get wineDrink => 'Juotu';

  @override
  String wineDrinkTooltip(String name) {
    return 'Merkitse pullo juoduksi: $name';
  }

  @override
  String confidenceLabel(String level) {
    return 'Luotettavuus: $level';
  }

  @override
  String get confidenceHigh => 'hyvä';

  @override
  String get confidenceMedium => 'kohtalainen';

  @override
  String get confidenceLow => 'heikko';

  @override
  String get windowStartLabel => 'Alku';

  @override
  String get windowPeakLabel => 'Huippu';

  @override
  String get windowEndLabel => 'Loppu';

  @override
  String estimateSourceLabel(String source) {
    return 'Lähde: $source';
  }

  @override
  String get estimateSourceCatalog => 'viinitietokanta';

  @override
  String get estimateSourceType => 'tyypin mukainen arvio';

  @override
  String get estimateSourceCorrected => 'maistelujesi korjaama arvio';

  @override
  String get estimateDisclaimer =>
      'Suuntaa antava arvio: riippuu myös pullon säilytyksestä';

  @override
  String get estimateUnavailable => 'Arviota ei ole saatavilla';

  @override
  String get pairingsTitle => 'Ruokaparit';

  @override
  String get pairingsGeneric => 'tyypin yleiset ruokaparit';

  @override
  String get pairingBraisedRedMeat => 'Haudutettu punainen liha';

  @override
  String get pairingGrilledRedMeat => 'Grillattu punainen liha';

  @override
  String get pairingGame => 'Riista';

  @override
  String get pairingRoastPoultry => 'Paahdettu siipikarja';

  @override
  String get pairingPoultry => 'Siipikarja';

  @override
  String get pairingPork => 'Porsaanliha';

  @override
  String get pairingCuredMeats => 'Leikkeleet';

  @override
  String get pairingPastaMeatSauce => 'Pasta ja lihakastike';

  @override
  String get pairingMushroomsTruffle => 'Sienet ja tryffeli';

  @override
  String get pairingAgedCheese => 'Kypsytetty juusto';

  @override
  String get pairingFreshCheese => 'Tuorejuusto';

  @override
  String get pairingBlueCheese => 'Sinihomejuusto';

  @override
  String get pairingFish => 'Kala';

  @override
  String get pairingSeafood => 'Äyriäiset';

  @override
  String get pairingRawSeafood => 'Raa’at äyriäiset';

  @override
  String get pairingFriedFood => 'Friteeratut ruoat';

  @override
  String get pairingVegetables => 'Kasvikset';

  @override
  String get pairingRisotto => 'Risotto';

  @override
  String get pairingPizza => 'Pizza';

  @override
  String get pairingAperitif => 'Aperitiivi';

  @override
  String get pairingPastries => 'Leivonnaiset';

  @override
  String get pairingDryBiscuits => 'Kuivat keksit';

  @override
  String get pairingChocolate => 'Suklaa';

  @override
  String get pairingDriedFruit => 'Pähkinät ja kuivatut hedelmät';

  @override
  String get pairingSpicyDishes => 'Tuliset ruoat';

  @override
  String get recentDrinksTitle => 'Viime maistelut';

  @override
  String get noDrinksYet => 'Ei vielä maisteluja';

  @override
  String get wineEdit => 'Muokkaa';

  @override
  String get wineDelete => 'Poista';

  @override
  String get wineFinished => 'Loppu: pulloja ei ole jäljellä';

  @override
  String get wineLoadFailed => 'Viiniä ei voitu avata';

  @override
  String get wineNotFound => 'Tätä viiniä ei enää ole';

  @override
  String drinkDone(String name) {
    return 'Merkitty juoduksi: $name';
  }

  @override
  String get drinkUndo => 'Kumoa';

  @override
  String get drinkAddNotes => 'Lisää arvosana ja muistiinpanot';

  @override
  String get nothingToUndo => 'Ei kumottavaa';

  @override
  String get cellarUndoRejected =>
      'Kumoaminen epäonnistui: pullo jää merkityksi juoduksi';

  @override
  String get cellarDeleteFailed =>
      'Poisto ei ole vielä valmis: se viimeistellään mahdollisimman pian';

  @override
  String get duplicateFull =>
      'Tällä viinillä on jo 99 pulloa: enempää ei voi lisätä.';

  @override
  String get recordSheetTitle => 'Arvosana ja muistiinpanot';

  @override
  String get recordRatingLabel => 'Arvosana';

  @override
  String ratingStar(int n) {
    return 'Arvosana $n/5';
  }

  @override
  String get recordNotesLabel => 'Muistiinpanot';

  @override
  String get recordNotesTooLong => 'Enintään 1000 merkkiä';

  @override
  String recordDateLabel(String date) {
    return 'Päivämäärä: $date';
  }

  @override
  String get recordDateInvalid =>
      'Päivämäärä ei voi olla tulevaisuudessa eikä ennen vuosikertaa';

  @override
  String get recordConditionTitle => 'Millainen se oli?';

  @override
  String get conditionTooYoung => 'Vielä liian nuori';

  @override
  String get conditionJustRight => 'Juuri sopiva';

  @override
  String get conditionPastPeak => 'Huippu jo ohi';

  @override
  String get recordNoCondition => 'Ei vastausta';

  @override
  String get producerLabel => 'Tuottaja (valinnainen)';

  @override
  String get producerTooLong => 'Enintään 120 merkkiä';

  @override
  String producerAddNew(String name) {
    return 'Lisää ”$name” uutena tuottajana';
  }

  @override
  String get wineTypeLabel => 'Tyyppi';

  @override
  String get typeRedLight => 'Kevyt punaviini';

  @override
  String get typeRedStructured => 'Täyteläinen punaviini';

  @override
  String get typeWhite => 'Valkoviini';

  @override
  String get typeRose => 'Roseeviini';

  @override
  String get typeSparklingClassic => 'Kuohuviini, perinteinen menetelmä';

  @override
  String get typeSparklingTank => 'Kuohuviini, tankkimenetelmä';

  @override
  String get typeSweet => 'Makea';

  @override
  String get typeFortified => 'Väkevöity';

  @override
  String get suggestionFromCellar => 'Kellarissasi';

  @override
  String get suggestionsLabel => 'Ehdotukset';

  @override
  String get duplicateTitle => 'On jo kellarissa';

  @override
  String duplicateBody(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pulloa',
      one: '1 pullo',
      zero: 'ei pulloja',
    );
    return '$name on jo kellarissa ($_temp0). Lisätäänkö uudet pullot siihen?';
  }

  @override
  String duplicateAdd(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Lisää $count pulloa',
      one: 'Lisää 1 pullo',
    );
    return '$_temp0';
  }

  @override
  String get duplicateBanner => 'Mahdollinen kaksoiskappale';

  @override
  String get duplicateMerge => 'Yhdistä';

  @override
  String get duplicateDeleteHint =>
      'Poista tämä merkintä, jos se on kaksoiskappale';

  @override
  String get mergeTitle => 'Yhdistetäänkö merkinnät?';

  @override
  String get mergeBody =>
      'Tämän merkinnän pullot siirtyvät vanhempaan, ja tämä merkintä poistetaan.';

  @override
  String get editWineTitle => 'Muokkaa viiniä';

  @override
  String get editDuplicate =>
      'Samanniminen viini samalta tuottajalta ja vuosikerralta on jo olemassa';

  @override
  String deleteWineTitle(String name) {
    return 'Poistetaanko $name?';
  }

  @override
  String get deleteWineBody =>
      'Viini ja kaikki sen maistelut poistetaan. Tätä ei voi kumota.';

  @override
  String get historyTitle => 'Historia';

  @override
  String get historyEmpty => 'Täältä löydät juomasi pullot';

  @override
  String get historyLoadFailed => 'Historian lataus epäonnistui';

  @override
  String drankOnLabel(String date) {
    return 'Juotu $date';
  }

  @override
  String get addChoiceTitle => 'Lisää viini';

  @override
  String get addChoicePhoto => 'Ota kuva';

  @override
  String get addChoiceImport => 'Tuo kuva';

  @override
  String get addChoiceWrite => 'Kirjoita';

  @override
  String get labelReading => 'Luetaan etikettiä…';

  @override
  String get labelRecognized => 'Tunnistin:';

  @override
  String get labelCorrect => 'Korjaa';

  @override
  String get labelConfirm => 'Vahvista';

  @override
  String get labelUnreadable => 'En saa etiketistä selvää';

  @override
  String get labelWriteByHand => 'Kirjoita käsin';

  @override
  String get labelNotFound => 'En löytänyt viiniä: tarkista tiedot';

  @override
  String get labelCameraDenied =>
      'Etiketin lukemiseen tarvitsen kameran käyttöoikeuden';

  @override
  String get labelPhotosDenied =>
      'Etiketin lukemiseen tarvitsen kuvien käyttöoikeuden';

  @override
  String get labelOpenSettings => 'Avaa asetukset';

  @override
  String get labelCameraUnavailable => 'Kamera ei ole käytettävissä';

  @override
  String get labelBarcodeNotFound => 'Luin viivakoodin, mutta en löydä viiniä';

  @override
  String get labelBarcodeFrontHint => 'Ota kuva etiketin etupuolesta';

  @override
  String get labelSharedNotAllowed => 'Et voi lisätä viinejä tähän kellariin';

  @override
  String get labelSharedFirstOnly => 'Käytin vain ensimmäistä kuvaa';

  @override
  String get labelSharedExpired =>
      'Jaettua kuvaa ei voitu lukea: jaa se uudelleen';

  @override
  String get labelReplaceTitle =>
      'Sinulla on tallentamaton viini. Luetaanko uusi kuva?';

  @override
  String get labelReplaceRead => 'Lue uusi kuva';

  @override
  String get labelReplaceKeep => 'Jatka avoimella';

  @override
  String get labelWineAdded => 'Viini lisätty kellariin';

  @override
  String get onboardingPage1Title => 'Kellarisi taskussa';

  @override
  String get onboardingPage1Body =>
      'Lisää pullosi kirjoittamalla tai etiketin kuvalla, myös ilman verkkoa.';

  @override
  String get onboardingPage2Title => 'Oikeaan aikaan';

  @override
  String get onboardingPage2Body =>
      'Vinoozy arvioi, milloin kukin viini on parhaimmillaan, ja kertoo, mitkä kannattaa avata ensin.';

  @override
  String get onboardingPage3Title => 'Yhdessä';

  @override
  String get onboardingPage3Body =>
      'Jaa kellarisi enintään kahden henkilön kanssa ja säilytä jokaisen juomasi pullon historia.';

  @override
  String get onboardingSkip => 'Ohita';

  @override
  String get onboardingNext => 'Seuraava';

  @override
  String get onboardingStart => 'Aloita';

  @override
  String onboardingPageOf(int page) {
    return 'Sivu $page/3';
  }

  @override
  String get profileTitle => 'Profiili';

  @override
  String get profilePhoto => 'Profiilikuva';

  @override
  String get profileSignOut => 'Kirjaudu ulos';

  @override
  String get profileDeleteAccount => 'Poista tili';

  @override
  String get profilePrivacy => 'Tietosuojakäytäntö';

  @override
  String get profilePrivacyBody =>
      'Voit lukea tietosuojakäytännön tästä osoitteesta:';

  @override
  String get profileOpenLink => 'Avaa selaimessa';

  @override
  String get profileOpenLinkFailed =>
      'Sivua ei voitu avata. Voit kopioida linkin ja avata sen selaimessa.';

  @override
  String get profileCopyLink => 'Kopioi linkki';

  @override
  String get profileLinkCopied => 'Linkki kopioitu';

  @override
  String get close => 'Sulje';

  @override
  String get signOutConfirmTitle => 'Haluatko kirjautua ulos?';

  @override
  String signOutPendingWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Sinulla on $count tallentamatonta muutosta. Jos kirjaudut ulos ja toinen tili kirjautuu sisään, ne menetetään.',
      one: 'Sinulla on 1 tallentamaton muutos. Jos kirjaudut ulos ja toinen tili kirjautuu sisään, se menetetään.',
    );
    return '$_temp0';
  }

  @override
  String get signOutStayAndSync => 'Jää ja synkronoi';

  @override
  String get signOutAnyway => 'Kirjaudu silti ulos';

  @override
  String get syncAllSaved => 'Kaikki tallennettu';

  @override
  String syncStillPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count muutosta vielä tallentamatta: tarkista verkko',
      one: '1 muutos vielä tallentamatta: tarkista verkko',
    );
    return '$_temp0';
  }

  @override
  String get signOutFailed => 'Uloskirjautuminen epäonnistui. Yritä uudelleen';

  @override
  String get signInAccountDeleted => 'Tili poistettu';

  @override
  String get deleteAccountIntro => 'Tämä poistaa pysyvästi:';

  @override
  String get deleteAccountItemCellar => 'Kellarisi viineineen ja historioineen';

  @override
  String get deleteAccountItemShares =>
      'Antamasi jaot: kutsutut henkilöt menettävät pääsyn';

  @override
  String get deleteAccountItemMemberships =>
      'Osallisuutesi muiden kellareissa: maistelusi jäävät sinne ilman nimeäsi';

  @override
  String get deleteAccountItemProfile => 'Profiilisi';

  @override
  String deleteAccountPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Sinulla on $count tallentamatonta muutosta: ne tallennetaan ja poistetaan sitten muun mukana',
      one: 'Sinulla on 1 tallentamaton muutos: se tallennetaan ja poistetaan sitten muun mukana',
    );
    return '$_temp0';
  }

  @override
  String get deleteAccountConfirmWord => 'POISTA';

  @override
  String deleteAccountTypeWord(String word) {
    return 'Vahvista kirjoittamalla $word';
  }

  @override
  String get deleteAccountReauthHint =>
      'Sen jälkeen kirjaudut uudelleen Googlella vahvistaaksesi, että se olet sinä.';

  @override
  String get deleteAccountForever => 'Poista pysyvästi';

  @override
  String get deleteAccountNeedsNetwork =>
      'Yhdistä internetiin, jotta tili voidaan poistaa';

  @override
  String get deleteAccountSameAccount =>
      'Poisto edellyttää kirjautumista samalla tilillä';

  @override
  String get deletionTitle => 'Tiliä poistetaan';

  @override
  String get deletionStepPreparePhone => 'Tallennetaan odottavat muutokset';

  @override
  String get deletionStepMarkStarted => 'Aloitetaan poisto';

  @override
  String get deletionStepLeaveOtherCellars => 'Poistutaan muiden kellareista';

  @override
  String get deletionStepCloseOwnInvitations => 'Suljetaan jakosi';

  @override
  String get deletionStepDeleteWinesAndRecords =>
      'Poistetaan viinit ja historia';

  @override
  String get deletionStepDeleteCellar => 'Poistetaan kellari';

  @override
  String get deletionStepDeleteProfileAndUser => 'Poistetaan profiili ja tili';

  @override
  String get deletionStepCleanUpPhone => 'Siivotaan tämä puhelin';

  @override
  String deletionStepAnnounce(int step, String label) {
    return 'Vaihe $step/8: $label';
  }

  @override
  String deletionDeletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count viiniä ja maistelua poistettu',
      one: '1 viini tai maistelu poistettu',
    );
    return '$_temp0';
  }

  @override
  String get deletionResumeHint =>
      'Tämän tilin poisto on kesken. Viimeistele se kirjautumalla uudelleen Googlella.';

  @override
  String get deletionContinue => 'Jatka';

  @override
  String get deletionOffline =>
      'Yhdistä internetiin, jotta poisto voidaan viimeistellä';

  @override
  String get deletionPendingWrites =>
      'En voi tallentaa odottavia muutoksia. Yritä uudelleen';

  @override
  String get deletionFailed => 'Poistoa ei voitu viimeistellä. Yritä uudelleen';

  @override
  String get uxCountryLabel => 'Maa';

  @override
  String get uxCountryOther => 'Muu maa…';

  @override
  String get uxCountryNone => 'Ei maata';

  @override
  String get uxAllCountriesTitle => 'Kaikki maat ja alueet';

  @override
  String get uxAllCountriesSearch => 'Hae maata';

  @override
  String get uxAllCountriesRare => 'Harvinaiset viinimaat';

  @override
  String get uxAllCountriesAll => 'Kaikki, A–Ö';

  @override
  String get uxAllCountriesNone => 'Maata ei löytynyt';

  @override
  String get uxRegionLabel => 'Alue';

  @override
  String uxRegionOf(String country) {
    return 'Alue · $country';
  }

  @override
  String get uxRegionOther => 'Muu alue';

  @override
  String get uxRegionFieldLabel => 'Kirjoita alue';

  @override
  String get uxRegionTooLong => 'Enintään 120 merkkiä';

  @override
  String get uxDrinkAction => 'Join yhden';

  @override
  String uxDrinkActionTooltip(String name) {
    return 'Join pullon: $name';
  }

  @override
  String get uxDrinkActionDetail => 'Join pullon';

  @override
  String get uxDrinkSheetLabel => 'Vahvista maistelu';

  @override
  String get uxDrinkSheetBottles => 'Pullot';

  @override
  String uxDrinkSheetBottlesChange(int before, int after) {
    return 'Pulloja: ennen $before, jälkeen $after';
  }

  @override
  String get uxDrinkSheetRating => 'Millainen se oli? (valinnainen)';

  @override
  String uxDrinkSheetStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tähteä viidestä',
      one: '1 tähti viidestä',
    );
    return '$_temp0';
  }

  @override
  String get uxDrinkSheetConfirm => 'Kyllä, join sen';

  @override
  String get uxRemoveBottle => 'Poista pullo ilman maistelua';

  @override
  String get uxRemoveBottleTitle => 'Poistetaanko pullo?';

  @override
  String uxRemoveBottleBody(String name) {
    return 'Yksi pullo poistetaan kirjaamatta maistelua: $name.';
  }

  @override
  String get uxRemoveBottleConfirm => 'Poista';

  @override
  String get uxIdealTitle => 'Paras hetki';

  @override
  String uxIdealUntil(String year) {
    return 'Suositus: viimeistään $year';
  }

  @override
  String uxIdealUntilPast(String year) {
    return 'Suositus: viimeistään $year – aika on jo ohi';
  }

  @override
  String uxIdealBest(String start, String end) {
    return 'Parhaimmillaan $start–$end';
  }

  @override
  String uxIdealBar(String start, String end) {
    return 'Juonti-ikkuna $start–$end';
  }

  @override
  String get uxIdealDisclaimer =>
      '⚠︎ Suuntaa antava: arvio perustuu tyyppiin, appellaatioon ja vuosikertaan. Säilytys ja yksittäinen pullo voivat muuttaa sitä.';

  @override
  String get uxIdealUnavailableHint =>
      'Lisää vuosikerta ja tyyppi, niin saat arvion.';

  @override
  String uxDashboardDrinkNow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count juotavissa nyt',
      one: '1 juotavissa nyt',
    );
    return '$_temp0';
  }

  @override
  String get uxFamilyRed => 'Punaviini';

  @override
  String get uxFamilyWhite => 'Valkoviini';

  @override
  String get uxFamilyRose => 'Roseeviini';

  @override
  String get uxFamilySparkling => 'Kuohuviini';

  @override
  String get uxFamilySweet => 'Makea';

  @override
  String get labelBackTitle => 'Nyt takaetiketti';

  @override
  String get labelBackHint =>
      'Takaetiketissä on yleensä viivakoodi, tuottaja ja vuosikerta: ne auttavat löytämään viinin.';

  @override
  String get labelBackTake => 'Kuvaa takaetiketti';

  @override
  String get labelBackGallery => 'Valitse galleriasta';

  @override
  String get labelBackSkip => 'Ohita';

  @override
  String get labelStepFront => 'Etupuoli';

  @override
  String get labelStepBack => 'Takapuoli';

  @override
  String get labelStepBarcode => 'Viivakoodi';

  @override
  String get labelStepDatabase => 'Viinitietokanta puhelimessa';

  @override
  String get labelStepPending => 'Odottaa';

  @override
  String get labelStepRunning => 'Käynnissä…';

  @override
  String get labelStepDone => 'Valmis';

  @override
  String get labelStepSkipped => 'Ohitettu';

  @override
  String get labelStepFailed => 'Ei luettavissa';

  @override
  String labelStepStatus(String step, String status) {
    return '$step: $status';
  }

  @override
  String get labelOnPhoneNote =>
      'Kaikki tapahtuu puhelimessa: kuvia ei lähetetä kenellekään.';

  @override
  String get labelBackUnreadable => 'Takaetiketti ei ole luettavissa';

  @override
  String get labelSourceOffline => 'Puhelimen tietokannasta · offline';

  @override
  String get labelSourceCatalog => 'Luettelosta';

  @override
  String get labelSourceOnline => 'Open Food Facts · online';

  @override
  String get labelNotThis => 'Ei tämä';

  @override
  String get labelOffAttribution => 'Tiedot: Open Food Facts, ODbL-lisenssi';

  @override
  String get labelCandidatesTitle => 'Mikä näistä?';

  @override
  String labelCandidatesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count samankaltaista viiniä',
      one: '1 samankaltainen viini',
    );
    return '$_temp0';
  }

  @override
  String get labelCandidatesNone => 'Ei mikään näistä';

  @override
  String get labelChipOffline => 'offline';

  @override
  String get labelChipOnline => 'online';

  @override
  String get labelChipCatalog => 'luettelo';

  @override
  String get labelNoProducer => 'tuottajaa ei ilmoitettu';

  @override
  String get labelNoMatch => 'Luin etiketin, mutta en tunnista viiniä';

  @override
  String get labelReadText => 'Luettu teksti';

  @override
  String get labelSearchOnline => 'Hae verkosta';

  @override
  String get labelOpenLens => 'Avaa Google Lensissä';

  @override
  String get labelLensLastResort =>
      'Google Lens on viimeinen keino: kuva siirtyy Google-sovellukseen vain, jos vahvistat.';

  @override
  String get labelLensTitle => 'Avataanko Google Lensissä?';

  @override
  String get labelLensBody =>
      'Etupuolen kuva siirtyy puhelimesi Google-sovellukseen tai valitsemaasi sovellukseen, joka voi säilyttää kopion omien sääntöjensä mukaan. Vinoozy ei saa tuloksia: palaa tänne valitsemaan tai kirjoittamaan viini.';

  @override
  String get labelLensConfirm => 'Avaa Google Lens';

  @override
  String get labelLensFailed => 'En voi avata Google Lensiä tai jakovalikkoa';

  @override
  String get onlineSearchTitle => 'Hae verkosta';

  @override
  String get onlineSearchSubtitle => 'Open Food Facts · vain viinit';

  @override
  String get onlineSearchField => 'Hakusanat';

  @override
  String get onlineSearchHint => 'Voit muuttaa sanoja ennen hakua.';

  @override
  String get onlineSearchEmptyField => 'Kirjoita vähintään yksi sana';

  @override
  String get onlineSearchButton => 'Hae';

  @override
  String get onlineSearchLoading => 'Haetaan…';

  @override
  String onlineSearchResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tulosta',
      one: '1 tulos',
    );
    return '$_temp0';
  }

  @override
  String get onlineSearchEmpty =>
      'Viiniä ei löytynyt: kokeile muita sanoja tai valitse ”Kirjoita käsin”.';

  @override
  String get onlineSearchOffline =>
      'Ei verkkoa: haen vain puhelimen tietokannasta.';

  @override
  String get onlineSearchRateLimited =>
      'Verkkohaku ei ole nyt käytettävissä, yritä uudelleen muutaman minuutin kuluttua.';

  @override
  String get onlineSearchUnavailable =>
      'Verkkohaku ei ole käytössä tässä sovellusversiossa: haen vain puhelimen tietokannasta.';

  @override
  String get aboutTitle => 'Tietoja';

  @override
  String aboutVersion(String version) {
    return 'Versio $version';
  }

  @override
  String get aboutDbTitle => 'Viinitietokanta';

  @override
  String aboutDbCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count viiniä',
      one: '1 viini',
    );
    return '$_temp0';
  }

  @override
  String aboutDbDate(String date) {
    return 'Open Food Facts -vienti, $date';
  }

  @override
  String get aboutDbSample =>
      'Esimerkkitietokanta: muutama käsin kirjoitettu testiviini, ei Open Food Facts -tietoja.';

  @override
  String get aboutDbLoading => 'Avataan viinitietokantaa…';

  @override
  String get aboutDbUnavailable =>
      'Viinitietokanta ei ole käytettävissä tässä versiossa';

  @override
  String aboutDbSource(String url) {
    return 'Johdettu tietokanta ja sen rakentava työkalu ovat julkisessa repositoriossa: $url';
  }

  @override
  String get aboutLicenseTitle => 'Lisenssit';

  @override
  String get aboutLicense =>
      'Sisältää Open Food Factsin tietoja, jotka on julkaistu Open Database License (ODbL) -lisenssillä. Yksittäiset sisällöt ovat Database Contents License (DbCL) -lisenssin alaisia.';

  @override
  String get aboutPrivacyTitle => 'Etikettikuvat';

  @override
  String get aboutPrivacy =>
      'Etikettikuvat luetaan puhelimessa ja poistetaan, kun poistut tuloksesta. Ne lähtevät puhelimesta vain, jos napautat ”Avaa Google Lensissä” ja vahvistat.';

  @override
  String get aboutAppellationsTitle => 'Appellaatiot';

  @override
  String get aboutAppellationsSource =>
      'Appellaatiot: eAmbrosia-rekisteri (EU) ja viralliset kansalliset rekisterit.';

  @override
  String get aboutAppellationsSample =>
      'Esimerkkitaulukko: käsin kirjoitettu ote rekistereistä, kunnes oikeat rekisterit on ladattu.';

  @override
  String get denominationLabel => 'Appellaatio';

  @override
  String get denominationTooLong => 'Enintään 120 merkkiä';

  @override
  String get autofillFilledNotice =>
      'Täytetty etiketistä: tarkista ja tallenna';

  @override
  String get autofillPastedNotice => 'Täytetty tekstistä: tarkista ja tallenna';

  @override
  String get autofillFromText => '✦ tekstistä';

  @override
  String get autofillFromTextSemantics => 'täytetty etiketistä';

  @override
  String get autofillClear => 'Tyhjennä';

  @override
  String get autofillLens => 'Lens';

  @override
  String get autofillClearTitle => 'Tyhjennetäänkö lomake?';

  @override
  String get autofillClearBody =>
      'Kirjoitit itsekin joihinkin kenttiin. ”Tyhjennä” poistaa nimen, tuottajan, appellaation, vuosikerran, tyypin, maan, alueen ja tason. Määrä säilyy.';

  @override
  String get autofillClearConfirm => 'Tyhjennä';

  @override
  String get autofillCleared => 'Lomake tyhjennetty';

  @override
  String get autofillPasteTitle => 'Onko sinulla teksti Google Lensistä?';

  @override
  String get autofillPasteHint =>
      'Valitse Lensissä etiketin teksti ja napauta ”Kopioi”, palaa sitten tänne.';

  @override
  String get autofillPaste => 'Liitä Lensistä';

  @override
  String get autofillOpenLens => 'Google Lensistä';

  @override
  String get autofillOpenLensSemantics => 'avaa Google Lensin';

  @override
  String get autofillClipboardEmpty => 'Leikepöydällä ei ole tekstiä';

  @override
  String get autofillNoNewFields => 'En löytänyt tekstistä lisättäviä tietoja';

  @override
  String get autofillFromLens => 'Lomake täytetty Lensin tekstistä';

  @override
  String get autofillShareEmpty => 'Tekstiä ei vastaanotettu';

  @override
  String get autofillShareUseTitle => 'Käytetäänkö tekstiä tyhjiin kenttiin?';

  @override
  String get autofillShareUse => 'Käytä';

  @override
  String get autofillShareIgnore => 'Ohita';

  @override
  String get addChoiceLens => 'Google Lensistä';

  @override
  String get addChoicePhotoHint => 'Etu- ja takapuoli: Vinoozy lukee etiketin.';

  @override
  String get addChoiceLensHint =>
      'Avaa Lensin: rajaa, valitse teksti ja napauta Jaa → Vinoozy.';

  @override
  String get addChoiceImportHint => 'Aiemmin ottamasi kuva etiketistä.';

  @override
  String get addChoiceWriteHint => 'Tyhjä lomake, jossa ”Liitä Lensistä”.';

  @override
  String get lensInstructionsTitle => 'Google Lensiä ei voi avata täältä';

  @override
  String get lensInstructionsStep1 => 'Avaa Google Lens ja rajaa etiketti';

  @override
  String get lensInstructionsStep2 => 'Valitse etiketin teksti';

  @override
  String get lensInstructionsStep3 => 'Napauta Jaa → Vinoozy';

  @override
  String get lensInstructionsOk => 'Selvä';

  @override
  String get levelLabel => 'Taso';

  @override
  String get levelEveryday => 'Arkiviini (edullinen)';

  @override
  String get levelGood => 'Hyvä';

  @override
  String get levelAging => 'Kellaroitava';

  @override
  String get levelNone => 'Ei tasoa';

  @override
  String get levelEverydayShort => 'juo nuorena';

  @override
  String get levelGoodShort => 'tavallinen arvio';

  @override
  String get levelAgingShort => 'kestää pidempään';

  @override
  String get levelSuggested => 'ehdotettu';

  @override
  String levelSuggestedReason(String qualifier) {
    return 'Ehdotettu, koska nimessä lukee ”$qualifier”: tallennetaan näin, ellet muuta sitä. Valitse toinen tai napauta ”Ei tasoa”.';
  }

  @override
  String levelSuggestedSemantics(String qualifier) {
    return 'ehdotettu, koska nimessä lukee $qualifier';
  }

  @override
  String levelOptionSemantics(String option, int index, int count) {
    return 'Taso, $option, $index/$count';
  }

  @override
  String get levelWhatChanges => 'Mikä muuttuu';

  @override
  String get levelEverydayExamples =>
      'Ikkuna lyhenee. Esim. talon viini, Lambrusco, perus-Prosecco, Bardolino, Vinho Verde.';

  @override
  String get levelGoodExamples =>
      'Tavallinen arvio ja arvo silloin, kun et valitse mitään. Esim. Chianti Classico, Barbera d\'Asti Superiore, Rioja Crianza, Côtes du Rhône.';

  @override
  String get levelAgingExamples =>
      'Ikkuna pitenee. Esim. Barolo, Brunello, Amarone, Bordeaux Grand Cru, Rioja Gran Reserva, Vintage Port.';

  @override
  String levelPreviewBefore(String start, String end) {
    return 'Ennen $start – $end';
  }

  @override
  String levelPreviewWith(String level, String start, String end) {
    return 'Tasolla ”$level” $start – $end';
  }

  @override
  String levelPreviewNow(String start, String end) {
    return 'Valmis $start – viimeistään $end';
  }

  @override
  String levelDetail(String level) {
    return 'Taso: $level';
  }

  @override
  String get overrideCorrect => 'Korjaa';

  @override
  String get overrideRestore => 'Palauta arvio';

  @override
  String get overrideCorrectedByYou => 'itse korjattu';

  @override
  String overrideAppEstimate(String year) {
    return 'Sovelluksen arvio: viimeistään $year';
  }

  @override
  String get overrideSheetTitle => 'Suositus viimeistään';

  @override
  String overrideSheetHint(String start) {
    return 'Valitse vuosi. Se ei voi olla ennen kohtaa ”Valmis alkaen $start”.';
  }

  @override
  String overridePeakNotice(String peak) {
    return 'Jos valitset huippuvuotta ($peak) aiemman vuoden, myös huippu siirtyy samaan vuoteen.';
  }

  @override
  String get overrideMore => 'lisää…';

  @override
  String get overrideSave => 'Tallenna korjaus';

  @override
  String overrideRestoreTitle(String year) {
    return 'Palautetaanko sovelluksen arvio (viimeistään $year)?';
  }

  @override
  String get overrideRestoreConfirm => 'Palauta';

  @override
  String get overrideSaved => 'Korjaus tallennettu';

  @override
  String get overrideRestored => 'Arvio palautettu';

  @override
  String get estimateSourceCorrectedByYou => 'itse korjattu';

  @override
  String estimateFromDenomination(String name) {
    return 'Arvio appellaation perusteella: $name';
  }

  @override
  String estimateFromDenominationQualifier(String name, String qualifier) {
    return 'Arvio appellaation perusteella: $name, $qualifier';
  }

  @override
  String estimateFromGrape(String name) {
    return 'Arvio rypälelajikkeen perusteella: $name';
  }

  @override
  String get estimateFromType => 'Arvio viinityypin perusteella';

  @override
  String get autofillReading => 'Luetaan tekstiä…';

  @override
  String get guideChip => 'Ohjattu tarkistus';

  @override
  String guideProgress(int n, int total) {
    return 'Kysymys $n/$total';
  }

  @override
  String get guideClose => 'Sulje';

  @override
  String get guideIsDenomination => 'onko tämä appellaatio?';

  @override
  String get guideIsProducer => 'onko tämä tuottaja?';

  @override
  String get guideIsName => 'onko tämä viinin nimi?';

  @override
  String get guideIsVintage => 'Vuosikerta';

  @override
  String guideAskDenomination(String value) {
    return 'Onko $value appellaatio?';
  }

  @override
  String guideAskProducer(String value) {
    return 'Onko $value tuottaja?';
  }

  @override
  String guideAskName(String value) {
    return 'Onko $value viinin nimi?';
  }

  @override
  String get guideAskVintage => 'Mikä on vuosikerta?';

  @override
  String guideQuestionSemantics(int n, int total, String question) {
    return 'Kysymys $n/$total: $question';
  }

  @override
  String get guideNoProposal => 'En löytänyt sitä tekstistä';

  @override
  String get guideYes => 'Kyllä';

  @override
  String get guideNo => 'Ei, toinen';

  @override
  String get guideEdit => 'Muokkaa';

  @override
  String get guideSkip => 'Ohita';

  @override
  String get guideConfirm => 'Vahvista';

  @override
  String get guideCancel => 'Peruuta';

  @override
  String guideRejected(String value) {
    return 'Ei ”$value”: tässä seuraava';
  }

  @override
  String get guideNoMore => 'Ei muita ehdotuksia: koosta itse tai ohita';

  @override
  String guideProposalAnnounce(String value) {
    return 'Ehdotus: $value';
  }

  @override
  String get guideComposeLabel => 'Tai koosta napauttamalla tekstin sanoja';

  @override
  String get guideComposePreview => 'Esikatselu';

  @override
  String get guideComposeEmpty => 'Napauta yhtä tai useampaa sanaa';

  @override
  String get guideComposeLimit => 'Enintään 8 sanaa ja 80 merkkiä';

  @override
  String guideTableMatchSemantics(String name) {
    return 'vastaa: $name';
  }

  @override
  String guideLine(int n, int total) {
    return 'Rivi $n/$total';
  }

  @override
  String guideWordSelected(String word, int order) {
    return '$word, valittu, $order';
  }

  @override
  String guideWordUnavailable(String word) {
    return '$word, ei käytettävissä';
  }

  @override
  String guideWordUsedFor(String word, String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'appellaatio',
      'producer': 'tuottaja',
      'other': 'nimi',
    });
    return '$word, käytetty jo: $_temp0';
  }

  @override
  String guideUsedMark(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'appellaatio',
      'producer': 'tuottaja',
      'other': 'nimi',
    });
    return '$_temp0';
  }

  @override
  String guideOtherYears(String years) {
    return 'Tekstissä myös: $years';
  }

  @override
  String get guideWheelFromText => 'tekstistä löytynyt vuosi';

  @override
  String get guideWheelTypeYear => 'Kirjoita vuosi';

  @override
  String guideWheelConfirm(String year) {
    return 'Vahvista $year';
  }

  @override
  String get guideNoVintage => 'Ei vuosikertaa';

  @override
  String guideSkippedNotice(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'Appellaatio ohitettu',
      'producer': 'Tuottaja ohitettu',
      'vintage': 'Vuosikerta ohitettu',
      'other': 'Nimi ohitettu',
    });
    return '$_temp0: kirjoita se tai jatka opasta';
  }

  @override
  String guideSkippedMany(int count) {
    return 'Ohitettuja kenttiä: $count. Kirjoita ne tai jatka opasta';
  }

  @override
  String get guideInvalidValue =>
      'Tekstissä on merkkejä, joita ei voi tallentaa';

  @override
  String get brandStudio => 'Bottazzini Softworks';

  @override
  String get suggestedMark => '✦ ehdotettu';

  @override
  String suggestedSemantics(String field, String value) {
    return '$field, $value, ehdotettu';
  }

  @override
  String get restoreSuggestion => 'Palauta ehdotus';

  @override
  String get restoreSuggestionDone => 'Ehdotus palautettu';

  @override
  String get styleLabel => 'Tyyli';

  @override
  String styleGroupSemantics(String value, int index, int count) {
    return 'Tyyli, $value, $index/$count';
  }

  @override
  String get styleRedFresh => 'Raikas';

  @override
  String get styleRedMedium => 'Keskitäyteläinen';

  @override
  String get styleRedAge => 'Kellaroitava';

  @override
  String get styleRedLong => 'Pitkä kellarointi';

  @override
  String get styleWhiteFresh => 'Raikas';

  @override
  String get styleWhiteMedium => 'Keskitäyteläinen';

  @override
  String get styleWhiteAge => 'Kellaroitava';

  @override
  String get styleRoseFresh => 'Raikas';

  @override
  String get styleClassicFresh => 'Raikas';

  @override
  String get styleClassicAge => 'Kellaroitava';

  @override
  String get styleTankFresh => 'Raikas';

  @override
  String get styleLambrusco => 'Lambrusco';

  @override
  String get styleSweetAromatic => 'Aromaattinen';

  @override
  String get styleSweetPassito => 'Kuivatut rypäleet';

  @override
  String get styleSweetBotrytis => 'Jalohomeinen';

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
  String get styleFortifiedOther => 'Muu';

  @override
  String get profileNameRFresh => 'Hedelmäinen punaviini';

  @override
  String get profileNameRMedium => 'Keskitäyteläinen punaviini';

  @override
  String get profileNameRAge => 'Kellaroitava punaviini';

  @override
  String get profileNameRLong => 'Pitkään kellaroitava punaviini';

  @override
  String get profileNameWFresh => 'Raikas, aromaattinen valkoviini';

  @override
  String get profileNameWMedium => 'Keskitäyteläinen valkoviini';

  @override
  String get profileNameWAge => 'Kellaroitava valkoviini';

  @override
  String get profileNameRoseFresh => 'Raikas roseeviini';

  @override
  String get profileNameSpTank => 'Raikas kuohuviini, tankkimenetelmä';

  @override
  String get profileNameLamFresh => 'Raikas Lambrusco';

  @override
  String get profileNameSpClassic => 'Raikas kuohuviini, perinteinen menetelmä';

  @override
  String get profileNameSpClassicAge =>
      'Kellaroitava kuohuviini, perinteinen menetelmä';

  @override
  String get profileNameSwAromatic => 'Nuori, aromaattinen makea viini';

  @override
  String get profileNameSwPassito => 'Makea viini kuivatuista rypäleistä';

  @override
  String get profileNameSwBotrytis => 'Jalohomeinen makea viini';

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
  String get profileNameFortUnknown => 'Väkevöity, tyyli tuntematon';

  @override
  String get profileNameUnknown => 'Tyyliä ei tunnistettu';

  @override
  String estimateFromProfile(String profile, String denomination) {
    return 'Arvio profiilin perusteella: $profile ($denomination)';
  }

  @override
  String estimateFromProfileType(String profile) {
    return 'Arvio profiilin perusteella: $profile, tyypin mukaan';
  }

  @override
  String estimateFromProfileGrape(String profile, String grape) {
    return 'Arvio profiilin perusteella: $profile, rypälelajike: $grape';
  }

  @override
  String get estimateFromEntryDateDisgorgement =>
      'Lisäyspäivästä laskettu: lisää degorgointipäivä, niin arvio tarkentuu';

  @override
  String get estimateFromEntryDateBottling =>
      'Lisäyspäivästä laskettu: lisää pullotuspäivä, niin arvio tarkentuu';

  @override
  String get styleToConfirmBanner =>
      '⚠︎ Tyyli vahvistamatta: arvio on suuntaa antava';

  @override
  String get chooseTypePrompt => 'Valitse tyyppi';

  @override
  String estimateUpdatedAnnouncement(String summary) {
    return 'Arvio päivitetty: $summary';
  }

  @override
  String get agingStartDisgorgement => 'Degorgointi';

  @override
  String get agingStartBottling => 'Pullotus';

  @override
  String get agingStartMonth => 'Kuukausi';

  @override
  String get agingStartYear => 'Vuosi';

  @override
  String get agingStartHint => 'Löytyy yleensä takaetiketistä.';

  @override
  String get agingStartIncomplete => 'Anna kuukausi ja vuosi';

  @override
  String get agingStartFuture => 'Päivämäärä ei voi olla tulevaisuudessa';

  @override
  String get agingStartBeforeVintage => 'Ei voi olla ennen vuosikertaa';

  @override
  String get windowNoEnd => 'Valmis, loppua ei arvioitu';

  @override
  String get windowNoEndShort => 'loppua ei arvioitu';

  @override
  String windowDrinkWithin(String date) {
    return 'viimeistään $date';
  }

  @override
  String get levelNoEffect => 'Taso ei muuta tätä arviota';

  @override
  String get dashboardToConfirmTitle => 'Vahvistettavat';

  @override
  String dashboardToConfirmCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count viiniä',
      one: '1 viini',
    );
    return '$_temp0';
  }

  @override
  String aboutDbClassified(String percent) {
    return 'Tyyppi tunnistettu: $percent % viineistä';
  }

  @override
  String get planTitle => 'Paketti';

  @override
  String get planFree => 'Ilmainen';

  @override
  String get planPlus => 'Plus';

  @override
  String get planPlusGift => 'Plus (lahja)';

  @override
  String get planDevUnlockAll => 'DEV · Testi-Plus';

  @override
  String get planDevSimulateFree => 'DEV · Simuloitu ilmaispaketti';

  @override
  String get planDevSimulateExpired => 'DEV · Simuloitu päättynyt Plus';

  @override
  String get planDiscoverPlus => 'Tutustu Plusiin';

  @override
  String get plusTitle => 'Vinoozy Plus';

  @override
  String get plusBenefitsTitle => 'Plus-edut';

  @override
  String get plusBenefitNoAds => 'Ei mainoksia';

  @override
  String get plusBenefitNoLimit => 'Ei rajaa kellarisi viineille';

  @override
  String get plusComingSoon => 'Plus tulee pian';

  @override
  String get plusLoading => 'Luetaan hintoja Google Playsta';

  @override
  String get plusStoreUnavailable =>
      'Hintoja ei voitu lukea Google Playsta. Yritä myöhemmin uudelleen.';

  @override
  String plusPriceMonthly(String price) {
    return '$price/kk';
  }

  @override
  String plusPriceAnnual(String price) {
    return '$price/vuosi';
  }

  @override
  String get plusRenewal =>
      'Tilaus uusiutuu automaattisesti näytettyyn hintaan, kunnes perut sen Google Playssa.';

  @override
  String get plusTerms =>
      'Maksu veloitetaan Google Play -tililtäsi, kun vahvistat oston. Voit perua milloin tahansa: Plus pysyy voimassa jo maksetun jakson loppuun. Kun Plus päättyy, kaikki viinisi säilyvät.';

  @override
  String get plusRestore => 'Palauta ostot';

  @override
  String get plusManage => 'Hallitse tilausta tai peru se Google Playssa';

  @override
  String get plusActive => 'Plus on voimassa tällä tilillä';

  @override
  String get plusActiveGift =>
      'Sinulla on Plus lahjana: ei veloituksia eikä uusimisia.';

  @override
  String get plusPending =>
      'Maksu odottaa: Plus tulee voimaan, kun Google Play vahvistaa sen.';

  @override
  String get plusVerifying => 'Ostoa vahvistetaan';

  @override
  String get plusVerified =>
      'Osto vahvistettu: Plus tulee voimaan muutamassa sekunnissa.';

  @override
  String get plusPurchaseFailed => 'Ostoa ei viety loppuun. Yritä uudelleen.';

  @override
  String get plusInvalidPurchase =>
      'Google Play ei vahvistanut tätä Vinoozy-ostoa.';

  @override
  String get plusOwnedByOther =>
      'Tämä tilaus kuuluu jo toiselle Vinoozy-tilille.';

  @override
  String get plusVerificationUnavailable =>
      'Ostoa ei voitu nyt vahvistaa. Yritä myöhemmin uudelleen: tilaus säilyy Google Playssa.';

  @override
  String get capacityLimitTitle => 'Ilmaispaketin raja tuli täyteen';

  @override
  String capacityLimitBody(int limit) {
    return 'Ilmaispaketissa kellarissasi voi olla enintään $limit eri viiniä. Voit aina muokata ja juoda viinejäsi sekä lisätä pulloja nykyisiin viineihin. Jos haluat lisätä uuden, juo jokin viini loppuun tai poista se, tai siirry Plusiin.';
  }

  @override
  String capacityLimitBodyComingSoon(int limit) {
    return 'Ilmaispaketissa kellarissasi voi olla enintään $limit eri viiniä. Voit aina muokata ja juoda viinejäsi sekä lisätä pulloja nykyisiin viineihin. Jos haluat lisätä uuden, juo jokin viini loppuun tai poista se. Plus tulee pian.';
  }

  @override
  String get rejectedCapacityLimit =>
      'Ei synkronoitu: ilmaispaketin viiniraja ylittyy. Muutos säilyy tässä puhelimessa.';

  @override
  String get rejectedCapacityConflict =>
      'Ei synkronoitu: kellari muuttui samaan aikaan toisella laitteella. Muutos säilyy tässä puhelimessa: yritä uudelleen.';

  @override
  String writeRejectedCapacityLimit(String name) {
    return '$name: ei synkronoitu, ilmaispaketin raja ylittyy';
  }

  @override
  String writeRejectedCapacityConflict(String name) {
    return '$name: ei synkronoitu, kellari muuttui toisella laitteella';
  }

  @override
  String get freeIntroTitle => 'Ilmaispaketti';

  @override
  String freeIntroLimit(int limit) {
    return 'Voit hallita ilmaiseksi enintään $limit eri viiniä.';
  }

  @override
  String get freeIntroAds =>
      'Kevyt käyttö on mainoksetonta. Jos ylität palvelun kuukausittaisen käyttörajan, saatat nähdä satunnaisia mainoksia, jotka auttavat kattamaan palvelinten ja synkronoinnin kulut.';

  @override
  String get freeIntroNoAds => 'Julkaisuversiossa ei ole mainoksia.';

  @override
  String get freeIntroPlus => 'Plus poistaa mainokset ja kellarin rajan.';

  @override
  String get noticeGotIt => 'Selvä';

  @override
  String get thresholdTitle => 'Mainosten ansiosta Vinoozy pysyy ilmaisena';

  @override
  String get thresholdBody =>
      'Mainoksettoman käytön kuukausiraja tuli täyteen. Tästä eteenpäin saatat nähdä satunnaisia mainoksia: ne auttavat kattamaan palvelinten ja synkronoinnin kulut, jotta Vinoozy pysyy ilmaisena.';

  @override
  String get thresholdReset =>
      'Laskenta alkaa alusta ensi kuussa. Plus-tilauksella käytät sovellusta ilman mainoksia ja ilman kellarin rajaa.';

  @override
  String thresholdNextReset(String date) {
    return 'Seuraava nollaus: $date';
  }

  @override
  String get thresholdHowItWorks => 'Näin se toimii';

  @override
  String get thresholdHowItWorksBody =>
      'Raja perustuu arvioon siitä, kuinka monta kertaa tämä tili on kuukauden aikana synkronoinut pilven kanssa. Pelkkä offline-käyttö ei luo uusia pilvitoimintoja. Mainoksia näytetään enintään kerran päivässä, vain Yleiskuvassa, eikä koskaan silloin, kun tallennat tai viet tietojasi.';

  @override
  String get adLabel => 'Mainos';

  @override
  String get devToolsTitle => 'Kehittäjän työkalut';

  @override
  String get devUnlockAll => 'Avaa kaikki — testi-Plus';

  @override
  String get devSimulateFree => 'Simuloi ilmaispakettia';

  @override
  String get devSimulateExpired => 'Simuloi päättynyttä Plusia';

  @override
  String get devRestore => 'Palauta normaalitila';

  @override
  String get devNoOverride => 'Ei aktiivista simulaatiota';

  @override
  String get devApplied =>
      'Skenaario otettu käyttöön myös Firestore-emulaattorissa';

  @override
  String get devIncomplete =>
      'Simulaatio on vajaa: Firestore-emulaattori ei vahvistanut testioikeutta. Palvelimen säännöt eivät näe tätä skenaariota.';

  @override
  String get devNotice =>
      'Vain kehitysversiot emulaattorilla: ei maksuja, tokeneita eikä kuitteja.';
}
