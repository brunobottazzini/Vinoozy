// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Romanian Moldavian Moldovan (`ro`).
class AppLocalizationsRo extends AppLocalizations {
  AppLocalizationsRo([String locale = 'ro']) : super(locale);

  @override
  String get appTitle => 'Vinoozy';

  @override
  String get signInTagline => 'Pivnița ta, la momentul potrivit';

  @override
  String get signInWithGoogle => 'Continuă cu Google';

  @override
  String get signInInProgress => 'Conectare în curs';

  @override
  String get signInFailed => 'Conectarea nu a reușit';

  @override
  String get signInNeedsNetwork => 'Prima conectare are nevoie de internet';

  @override
  String get signInSessionExpired =>
      'Sesiunea a expirat: conectează-te din nou';

  @override
  String get retry => 'Reîncearcă';

  @override
  String get cancel => 'Anulează';

  @override
  String blockedMessage(String email) {
    return 'Există modificări ale contului $email nesalvate încă în cloud: conectează-te cu acel cont și la rețea';
  }

  @override
  String blockedSignInWith(String email) {
    return 'Conectează-te cu $email';
  }

  @override
  String blockedDiscard(String email) {
    return 'Șterge modificările nesalvate ale contului $email';
  }

  @override
  String get discardDialogTitle => 'Ștergi modificările?';

  @override
  String discardDialogBody(int count, String email) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count de vinuri ale contului $email nu sunt încă în cloud și vor fi șterse de pe acest telefon.',
      few:
          '$count vinuri ale contului $email nu sunt încă în cloud și vor fi șterse de pe acest telefon.',
      one:
          '1 vin al contului $email nu este încă în cloud și va fi șters de pe acest telefon.',
    );
    return '$_temp0';
  }

  @override
  String get discardConfirm => 'Șterge';

  @override
  String get resetFailed => 'Nu s-au putut șterge datele de pe acest telefon';

  @override
  String get restartRequired => 'Repornește aplicația pentru a termina';

  @override
  String get restartCloseApp => 'Închide aplicația';

  @override
  String get startupFailed => 'Aplicația nu a putut porni';

  @override
  String get cellarTitle => 'Pivniță';

  @override
  String get defaultCellarName => 'Pivnița mea';

  @override
  String get cellarLoading => 'Se pregătește pivnița';

  @override
  String get cellarSetupFailed => 'Nu s-a putut pregăti pivnița';

  @override
  String get cellarEmpty => 'Pivnița ta este goală';

  @override
  String get addWine => 'Adaugă';

  @override
  String get estimatePending => 'Estimare în curs';

  @override
  String get noVintage => 'Fără an de recoltă';

  @override
  String bottleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de sticle',
      few: '$count sticle',
      one: '1 sticlă',
    );
    return '$_temp0';
  }

  @override
  String get syncInProgress => 'Se sincronizează';

  @override
  String get syncOffline => 'Offline - sincronizare în așteptare';

  @override
  String writeRejected(String name) {
    return 'Modificare nepermisă: $name';
  }

  @override
  String get saveFailed => 'Nu s-a putut salva, încearcă din nou';

  @override
  String wineNotSaved(String name) {
    return 'Vinul $name nu a fost salvat în cloud';
  }

  @override
  String get addAgain => 'Adaugă din nou';

  @override
  String get ignore => 'Ignoră';

  @override
  String get addWineTitle => 'Scrie';

  @override
  String get wineNameLabel => 'Vin';

  @override
  String get vintageLabel => 'Recoltă';

  @override
  String get quantityLabel => 'Cantitate';

  @override
  String get decreaseQuantity => 'Micșorează cantitatea';

  @override
  String get increaseQuantity => 'Mărește cantitatea';

  @override
  String get save => 'Salvează';

  @override
  String get nameRequired => 'Scrie numele vinului';

  @override
  String get nameTooLong => 'Maximum 120 de caractere';

  @override
  String vintageRange(String year) {
    return 'Recoltă între 1900 și $year';
  }

  @override
  String get offAttribution => 'Date de la Open Food Facts (ODbL)';

  @override
  String get dashboardTitle => 'Panou';

  @override
  String dashboardTotalBottles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de sticle în pivniță',
      few: '$count sticle în pivniță',
      one: '1 sticlă în pivniță',
    );
    return '$_temp0';
  }

  @override
  String get dashboardSyncing => 'Se sincronizează pivnița…';

  @override
  String get dashboardAddFirstWine => 'Adaugă primul vin';

  @override
  String get drinkSoonTitle => 'De băut curând';

  @override
  String get drinkSoonEmpty => 'Nicio sticlă de băut curând';

  @override
  String drinkSoonUntil(String year) {
    return 'până în $year';
  }

  @override
  String drinkSoonSeeAll(int count) {
    return 'Vezi tot ($count)';
  }

  @override
  String get statusChartTitle => 'Starea sticlelor';

  @override
  String get statusWaiting => 'de așteptat';

  @override
  String get statusReady => 'gata';

  @override
  String get statusDrinkSoon => 'de băut curând';

  @override
  String get statusPastWindow => 'după fereastră';

  @override
  String toEstimateNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de sticle de estimat',
      few: '$count sticle de estimat',
      one: '1 sticlă de estimat',
    );
    return '$_temp0';
  }

  @override
  String chartBarValue(String label, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de sticle',
      few: '$count sticle',
      one: '1 sticlă',
    );
    return '$label: $_temp0';
  }

  @override
  String chartDescription(String title, String values) {
    return '$title: $values';
  }

  @override
  String get openListHint => 'Deschide lista';

  @override
  String get peakChartTitle => 'Anul apogeului';

  @override
  String get peakPast => 'apogeu depășit';

  @override
  String get peakBeyond => 'mai târziu';

  @override
  String get breakdownTypeTitle => 'Sticle după tip';

  @override
  String get breakdownRegionTitle => 'Sticle după regiune';

  @override
  String get breakdownType => 'Tip';

  @override
  String get breakdownRegion => 'Regiune';

  @override
  String get familyRed => 'roșu';

  @override
  String get familyWhite => 'alb';

  @override
  String get familyRose => 'rosé';

  @override
  String get familySparkling => 'spumant';

  @override
  String get familySweet => 'dulce';

  @override
  String get breakdownUnspecified => 'nespecificat';

  @override
  String get breakdownOtherRegions => 'altele';

  @override
  String get ok => 'OK';

  @override
  String get cellarMenu => 'Meniul pivniței';

  @override
  String get sharingPeopleTitle => 'Persoane';

  @override
  String get sharingInviteTitle => 'Invită o persoană';

  @override
  String get sharingEmailLabel => 'Adresă de e-mail Google';

  @override
  String get sharingPermissionRead => 'Doar citire';

  @override
  String get sharingPermissionReadHint =>
      'Vede vinurile, estimările, panoul și degustările';

  @override
  String get sharingPermissionEdit => 'Poate edita';

  @override
  String get sharingPermissionEditHint =>
      'În plus, adaugă și modifică vinuri și notează degustări';

  @override
  String get sharingRoleOwner => 'proprietar';

  @override
  String get sharingInviteButton => 'Invită';

  @override
  String sharingPlacesUsed(int used, int max) {
    return '$used/$max persoane';
  }

  @override
  String get sharingInvalidEmail => 'Introdu o adresă de e-mail validă';

  @override
  String get sharingSelfInvite => 'Nu te poți invita pe tine';

  @override
  String get sharingAlreadyInvited => 'Această persoană este deja invitată';

  @override
  String sharingLimitReached(int max) {
    return 'Ai atins limita de persoane: $max';
  }

  @override
  String get sharingNotOwner => 'Nu poți schimba partajarea acestei pivnițe';

  @override
  String get sharingNotFound => 'Această persoană nu mai este în listă';

  @override
  String get sharingFailed => 'Nu s-a putut finaliza, încearcă din nou';

  @override
  String get sharingInviteFailed => 'Invitația nu a reușit. Încearcă din nou';

  @override
  String get sharingOfflineHint =>
      'Ai nevoie de internet pentru a gestiona partajarea';

  @override
  String get sharingStatusInvited => 'invitat';

  @override
  String get sharingStatusActive => 'activ';

  @override
  String get sharingStatusRevoked => 'revocat';

  @override
  String get sharingStatusLeft => 'plecat';

  @override
  String sharingMemberSemantics(String name, String permission, String status) {
    return '$name, $permission, $status';
  }

  @override
  String get sharingClosedSection => 'Accesuri închise';

  @override
  String get sharingNobody => 'Nimeni altcineva nu vede încă această pivniță';

  @override
  String sharingChangePermission(String name) {
    return 'Schimbă permisiunea pentru $name';
  }

  @override
  String get sharingRevoke => 'Revocă';

  @override
  String sharingRevokeTitle(String name) {
    return 'Revoci accesul pentru $name?';
  }

  @override
  String sharingRevokeConfirmLabel(String name) {
    return 'Scrie $name pentru a confirma';
  }

  @override
  String get sharingRevokeDisabledHint =>
      'Se activează când numele se potrivește';

  @override
  String get sharingReinvite => 'Invită din nou';

  @override
  String get sharingDeleteForGood => 'Șterge definitiv';

  @override
  String sharingOwnedBy(String owner) {
    return 'Pivniță deținută de $owner';
  }

  @override
  String get sharingYourCellar => 'Pivnița ta';

  @override
  String sharingYourPermission(String permission) {
    return 'Permisiunea ta: $permission';
  }

  @override
  String sharingSwitcherSemantics(String cellar, String permission) {
    return '$cellar, $permission. Atinge pentru a schimba pivnița';
  }

  @override
  String get sharingLeave => 'Părăsește această pivniță';

  @override
  String sharingLeaveTitle(String owner) {
    return 'Părăsești pivnița deținută de $owner?';
  }

  @override
  String sharingLeaveBody(String owner) {
    return 'Nu o vei mai vedea. $owner te poate invita din nou.';
  }

  @override
  String get sharingLeaveConfirm => 'Părăsește';

  @override
  String sharingSharedNotice(String owner) {
    return '$owner și-a partajat pivnița cu tine';
  }

  @override
  String sharingAccessLost(String owner) {
    return 'Nu mai ai acces la pivnița deținută de $owner';
  }

  @override
  String sharingWritesLost(String owner) {
    return 'Unele modificări din pivnița deținută de $owner nu au fost salvate, pentru că nu mai ai acces';
  }

  @override
  String get sharingSomeone => 'cineva';

  @override
  String get sharingShareSubject => 'Invitație în Vinoozy';

  @override
  String sharingShareMessage(
    String owner,
    String cellar,
    String link,
    String email,
  ) {
    return '$owner te-a invitat în pivnița „$cellar” din Vinoozy. Instalează aplicația de la $link și conectează-te cu contul Google $email: folosește exact această adresă.';
  }

  @override
  String get cellarSearchHint => 'Caută după nume sau producător';

  @override
  String get cellarFilterStatus => 'Stare';

  @override
  String get cellarFilterType => 'Tip';

  @override
  String get statusToEstimate => 'De estimat';

  @override
  String get filterTypeUnspecified => 'Nespecificat';

  @override
  String get cellarNoMatches => 'Niciun vin cu aceste filtre';

  @override
  String get cellarClearFilters => 'Șterge filtrele';

  @override
  String get cellarArchiveTitle => 'Băute';

  @override
  String get cellarArchiveEmpty => 'Încă niciun vin terminat';

  @override
  String get cellarArchiveFailed => 'Nu s-au putut încărca vinurile terminate';

  @override
  String get wineDrink => 'Băută';

  @override
  String wineDrinkTooltip(String name) {
    return 'Marchează o sticlă de $name ca băută';
  }

  @override
  String confidenceLabel(String level) {
    return 'Încredere: $level';
  }

  @override
  String get confidenceHigh => 'ridicată';

  @override
  String get confidenceMedium => 'medie';

  @override
  String get confidenceLow => 'scăzută';

  @override
  String get windowStartLabel => 'Început';

  @override
  String get windowPeakLabel => 'Apogeu';

  @override
  String get windowEndLabel => 'Sfârșit';

  @override
  String estimateSourceLabel(String source) {
    return 'Sursă: $source';
  }

  @override
  String get estimateSourceCatalog => 'baza de date de vinuri';

  @override
  String get estimateSourceType => 'estimare după tip';

  @override
  String get estimateSourceCorrected =>
      'estimare corectată de degustările tale';

  @override
  String get estimateDisclaimer =>
      'Estimare orientativă: depinde și de cum a fost păstrată sticla';

  @override
  String get estimateUnavailable => 'Estimare indisponibilă';

  @override
  String get pairingsTitle => 'Asocieri';

  @override
  String get pairingsGeneric => 'asocieri generice pentru tip';

  @override
  String get pairingBraisedRedMeat => 'Carne roșie înăbușită';

  @override
  String get pairingGrilledRedMeat => 'Carne roșie la grătar';

  @override
  String get pairingGame => 'Vânat';

  @override
  String get pairingRoastPoultry => 'Pasăre la cuptor';

  @override
  String get pairingPoultry => 'Pasăre';

  @override
  String get pairingPork => 'Porc';

  @override
  String get pairingCuredMeats => 'Mezeluri';

  @override
  String get pairingPastaMeatSauce => 'Paste cu sos de carne';

  @override
  String get pairingMushroomsTruffle => 'Ciuperci și trufe';

  @override
  String get pairingAgedCheese => 'Brânză maturată';

  @override
  String get pairingFreshCheese => 'Brânză proaspătă';

  @override
  String get pairingBlueCheese => 'Brânză albastră';

  @override
  String get pairingFish => 'Pește';

  @override
  String get pairingSeafood => 'Fructe de mare';

  @override
  String get pairingRawSeafood => 'Fructe de mare crude';

  @override
  String get pairingFriedFood => 'Prăjeli';

  @override
  String get pairingVegetables => 'Legume';

  @override
  String get pairingRisotto => 'Risotto';

  @override
  String get pairingPizza => 'Pizza';

  @override
  String get pairingAperitif => 'Aperitiv';

  @override
  String get pairingPastries => 'Patiserie';

  @override
  String get pairingDryBiscuits => 'Biscuiți uscați';

  @override
  String get pairingChocolate => 'Ciocolată';

  @override
  String get pairingDriedFruit => 'Nuci și fructe uscate';

  @override
  String get pairingSpicyDishes => 'Mâncăruri picante';

  @override
  String get recentDrinksTitle => 'Ultimele degustări';

  @override
  String get noDrinksYet => 'Încă nicio degustare';

  @override
  String get wineEdit => 'Editează';

  @override
  String get wineDelete => 'Șterge';

  @override
  String get wineFinished => 'Terminat: nu mai sunt sticle';

  @override
  String get wineLoadFailed => 'Vinul nu a putut fi deschis';

  @override
  String get wineNotFound => 'Acest vin nu mai există';

  @override
  String drinkDone(String name) {
    return 'Marcată ca băută: $name';
  }

  @override
  String get drinkUndo => 'Anulează';

  @override
  String get drinkAddNotes => 'Adaugă evaluare și note';

  @override
  String get nothingToUndo => 'Nu mai este nimic de anulat';

  @override
  String get cellarUndoRejected =>
      'Anularea nu a reușit: sticla rămâne marcată ca băută';

  @override
  String get cellarDeleteFailed =>
      'Ștergerea nu este încă completă: se va termina cât mai curând';

  @override
  String get duplicateFull =>
      'Acest vin are deja 99 de sticle: nu se mai pot adăuga altele.';

  @override
  String get recordSheetTitle => 'Evaluare și note';

  @override
  String get recordRatingLabel => 'Evaluare';

  @override
  String ratingStar(int n) {
    return 'Evaluare $n din 5';
  }

  @override
  String get recordNotesLabel => 'Note';

  @override
  String get recordNotesTooLong => 'Cel mult 1000 de caractere';

  @override
  String recordDateLabel(String date) {
    return 'Data: $date';
  }

  @override
  String get recordDateInvalid =>
      'Data nu poate fi în viitor sau înainte de anul de recoltă';

  @override
  String get recordConditionTitle => 'Cum a fost?';

  @override
  String get conditionTooYoung => 'Încă prea tânăr';

  @override
  String get conditionJustRight => 'Tocmai bun';

  @override
  String get conditionPastPeak => 'Trecut de apogeu';

  @override
  String get recordNoCondition => 'Fără răspuns';

  @override
  String get producerLabel => 'Producător (opțional)';

  @override
  String get producerTooLong => 'Cel mult 120 de caractere';

  @override
  String producerAddNew(String name) {
    return 'Adaugă „$name” ca producător nou';
  }

  @override
  String get wineTypeLabel => 'Tip';

  @override
  String get typeRedLight => 'Roșu ușor';

  @override
  String get typeRedStructured => 'Roșu corpolent';

  @override
  String get typeWhite => 'Alb';

  @override
  String get typeRose => 'Rosé';

  @override
  String get typeSparklingClassic => 'Spumant metoda tradițională';

  @override
  String get typeSparklingTank => 'Spumant metoda Charmat';

  @override
  String get typeSweet => 'Dulce';

  @override
  String get typeFortified => 'Fortificat';

  @override
  String get suggestionFromCellar => 'În pivnița ta';

  @override
  String get suggestionsLabel => 'Sugestii';

  @override
  String get duplicateTitle => 'Există deja în pivniță';

  @override
  String duplicateBody(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de sticle',
      few: '$count sticle',
      one: '1 sticlă',
      zero: 'nicio sticlă',
    );
    return '$name există deja, cu $_temp0. Adaugi acolo noile sticle?';
  }

  @override
  String duplicateAdd(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Adaugă $count de sticle',
      few: 'Adaugă $count sticle',
      one: 'Adaugă 1 sticlă',
    );
    return '$_temp0';
  }

  @override
  String get duplicateBanner => 'Posibil duplicat';

  @override
  String get duplicateMerge => 'Unește';

  @override
  String get duplicateDeleteHint =>
      'Șterge această intrare dacă este un duplicat';

  @override
  String get mergeTitle => 'Unești cele două intrări?';

  @override
  String get mergeBody =>
      'Sticlele acestei intrări trec la cea mai veche, apoi această intrare este ștearsă.';

  @override
  String get editWineTitle => 'Editează vinul';

  @override
  String get editDuplicate =>
      'Există alt vin cu același nume, producător și an de recoltă';

  @override
  String deleteWineTitle(String name) {
    return 'Ștergi $name?';
  }

  @override
  String get deleteWineBody =>
      'Vinul și toate degustările lui sunt șterse. Acțiunea nu poate fi anulată.';

  @override
  String get historyTitle => 'Istoric';

  @override
  String get historyEmpty => 'Aici vei găsi sticlele pe care le-ai băut';

  @override
  String get historyLoadFailed => 'Istoricul nu a putut fi încărcat';

  @override
  String drankOnLabel(String date) {
    return 'Băută pe $date';
  }

  @override
  String get addChoiceTitle => 'Adaugă un vin';

  @override
  String get addChoicePhoto => 'Fă o fotografie';

  @override
  String get addChoiceImport => 'Importă o fotografie';

  @override
  String get addChoiceWrite => 'Scrie';

  @override
  String get labelReading => 'Citesc eticheta…';

  @override
  String get labelRecognized => 'Am recunoscut:';

  @override
  String get labelCorrect => 'Corectează';

  @override
  String get labelConfirm => 'Confirmă';

  @override
  String get labelUnreadable => 'Nu pot citi eticheta';

  @override
  String get labelWriteByHand => 'Scrie de mână';

  @override
  String get labelNotFound => 'Nu am găsit vinul: verifică datele';

  @override
  String get labelCameraDenied =>
      'Pentru a citi eticheta am nevoie de acces la cameră';

  @override
  String get labelPhotosDenied =>
      'Pentru a citi eticheta am nevoie de acces la fotografii';

  @override
  String get labelOpenSettings => 'Deschide setările';

  @override
  String get labelCameraUnavailable => 'Camera nu este disponibilă';

  @override
  String get labelBarcodeNotFound =>
      'Am citit codul de bare, dar nu găsesc vinul';

  @override
  String get labelBarcodeFrontHint => 'Fotografiază fața etichetei';

  @override
  String get labelSharedNotAllowed =>
      'Nu poți adăuga vinuri în această pivniță';

  @override
  String get labelSharedFirstOnly => 'Am folosit doar prima fotografie';

  @override
  String get labelSharedExpired =>
      'Fotografia partajată nu a putut fi citită: partajeaz-o din nou';

  @override
  String get labelReplaceTitle => 'Ai un vin nesalvat. Citesc noua fotografie?';

  @override
  String get labelReplaceRead => 'Citește noua fotografie';

  @override
  String get labelReplaceKeep => 'Continuă cu cel deschis';

  @override
  String get labelWineAdded => 'Vin adăugat în pivniță';

  @override
  String get onboardingPage1Title => 'Pivnița ta, în buzunar';

  @override
  String get onboardingPage1Body =>
      'Adaugă sticlele scriindu-le sau cu o fotografie a etichetei, chiar și fără rețea.';

  @override
  String get onboardingPage2Title => 'La momentul potrivit';

  @override
  String get onboardingPage2Body =>
      'Vinoozy estimează când este fiecare vin la apogeu și îți spune pe care să le deschizi primele.';

  @override
  String get onboardingPage3Title => 'Împreună';

  @override
  String get onboardingPage3Body =>
      'Partajează pivnița cu cel mult două persoane și păstrează istoricul fiecărei sticle băute.';

  @override
  String get onboardingSkip => 'Sari';

  @override
  String get onboardingNext => 'Înainte';

  @override
  String get onboardingStart => 'Începe';

  @override
  String onboardingPageOf(int page) {
    return 'Pagina $page din 3';
  }

  @override
  String get profileTitle => 'Profil';

  @override
  String get profilePhoto => 'Fotografie de profil';

  @override
  String get profileSignOut => 'Deconectare';

  @override
  String get profileDeleteAccount => 'Șterge contul';

  @override
  String get profilePrivacy => 'Politica de confidențialitate';

  @override
  String get profilePrivacyBody =>
      'Poți citi politica de confidențialitate la această adresă:';

  @override
  String get profileOpenLink => 'Deschide în browser';

  @override
  String get profileOpenLinkFailed =>
      'Pagina nu a putut fi deschisă. Poți copia linkul și îl poți deschide în browser.';

  @override
  String get profileCopyLink => 'Copiază linkul';

  @override
  String get profileLinkCopied => 'Link copiat';

  @override
  String get close => 'Închide';

  @override
  String get signOutConfirmTitle => 'Vrei să te deconectezi?';

  @override
  String signOutPendingWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Ai $count de modificări nesalvate încă. Dacă te deconectezi și se conectează alt cont, se vor pierde.',
      few:
          'Ai $count modificări nesalvate încă. Dacă te deconectezi și se conectează alt cont, se vor pierde.',
      one: 'Ai 1 modificare nesalvată încă. Dacă te deconectezi și se conectează alt cont, se va pierde.',
    );
    return '$_temp0';
  }

  @override
  String get signOutStayAndSync => 'Rămâi și sincronizează';

  @override
  String get signOutAnyway => 'Deconectează-te oricum';

  @override
  String get syncAllSaved => 'Totul este salvat';

  @override
  String syncStillPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de modificări încă de salvat: verifică rețeaua',
      few: '$count modificări încă de salvat: verifică rețeaua',
      one: '1 modificare încă de salvat: verifică rețeaua',
    );
    return '$_temp0';
  }

  @override
  String get signOutFailed => 'Deconectarea nu a reușit. Încearcă din nou';

  @override
  String get signInAccountDeleted => 'Cont șters';

  @override
  String get deleteAccountIntro => 'Se șterg definitiv:';

  @override
  String get deleteAccountItemCellar =>
      'Pivnița ta, cu vinurile și istoricul ei';

  @override
  String get deleteAccountItemShares =>
      'Partajările oferite de tine: persoanele invitate pierd accesul';

  @override
  String get deleteAccountItemMemberships =>
      'Participarea ta la pivnițele altora: degustările tale rămân acolo fără numele tău';

  @override
  String get deleteAccountItemProfile => 'Profilul tău';

  @override
  String deleteAccountPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Ai $count de modificări nesalvate încă: vor fi salvate și apoi șterse odată cu restul',
      few:
          'Ai $count modificări nesalvate încă: vor fi salvate și apoi șterse odată cu restul',
      one: 'Ai 1 modificare nesalvată încă: va fi salvată și apoi ștearsă odată cu restul',
    );
    return '$_temp0';
  }

  @override
  String get deleteAccountConfirmWord => 'ȘTERGE';

  @override
  String deleteAccountTypeWord(String word) {
    return 'Scrie $word pentru a confirma';
  }

  @override
  String get deleteAccountReauthHint =>
      'Apoi te vei conecta din nou cu Google, ca să confirmi că ești tu.';

  @override
  String get deleteAccountForever => 'Șterge definitiv';

  @override
  String get deleteAccountNeedsNetwork =>
      'Conectează-te la internet pentru a șterge contul';

  @override
  String get deleteAccountSameAccount =>
      'Pentru ștergere trebuie să te conectezi cu același cont';

  @override
  String get deletionTitle => 'Se șterge contul';

  @override
  String get deletionStepPreparePhone =>
      'Se salvează modificările în așteptare';

  @override
  String get deletionStepMarkStarted => 'Începe ștergerea';

  @override
  String get deletionStepLeaveOtherCellars => 'Se părăsesc pivnițele altora';

  @override
  String get deletionStepCloseOwnInvitations => 'Se închid partajările tale';

  @override
  String get deletionStepDeleteWinesAndRecords =>
      'Se șterg vinurile și istoricul';

  @override
  String get deletionStepDeleteCellar => 'Se șterge pivnița';

  @override
  String get deletionStepDeleteProfileAndUser => 'Se șterg profilul și contul';

  @override
  String get deletionStepCleanUpPhone => 'Se curăță acest telefon';

  @override
  String deletionStepAnnounce(int step, String label) {
    return 'Pasul $step din 8: $label';
  }

  @override
  String deletionDeletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'S-au șters $count de vinuri și degustări',
      few: 'S-au șters $count vinuri și degustări',
      one: 'S-a șters 1 vin sau degustare',
    );
    return '$_temp0';
  }

  @override
  String get deletionResumeHint =>
      'O ștergere a acestui cont nu s-a terminat. Conectează-te din nou cu Google pentru a o finaliza.';

  @override
  String get deletionContinue => 'Continuă';

  @override
  String get deletionOffline =>
      'Conectează-te la internet pentru a finaliza ștergerea';

  @override
  String get deletionPendingWrites =>
      'Nu pot salva modificările în așteptare. Încearcă din nou';

  @override
  String get deletionFailed =>
      'Ștergerea nu a putut fi finalizată. Încearcă din nou';

  @override
  String get uxCountryLabel => 'Țară';

  @override
  String get uxCountryOther => 'Altă țară…';

  @override
  String get uxCountryNone => 'Fără țară';

  @override
  String get uxAllCountriesTitle => 'Toate țările și teritoriile';

  @override
  String get uxAllCountriesSearch => 'Caută o țară';

  @override
  String get uxAllCountriesRare => 'Rare pentru vin';

  @override
  String get uxAllCountriesAll => 'Toate, de la A la Z';

  @override
  String get uxAllCountriesNone => 'Nicio țară găsită';

  @override
  String get uxRegionLabel => 'Regiune';

  @override
  String uxRegionOf(String country) {
    return 'Regiune · $country';
  }

  @override
  String get uxRegionOther => 'Altă regiune';

  @override
  String get uxRegionFieldLabel => 'Scrie regiunea';

  @override
  String get uxRegionTooLong => 'Cel mult 120 de caractere';

  @override
  String get uxDrinkAction => 'Am băut una';

  @override
  String uxDrinkActionTooltip(String name) {
    return 'Am băut o sticlă de $name';
  }

  @override
  String get uxDrinkActionDetail => 'Am băut o sticlă';

  @override
  String get uxDrinkSheetLabel => 'Confirmă degustarea';

  @override
  String get uxDrinkSheetBottles => 'Sticle';

  @override
  String uxDrinkSheetBottlesChange(int before, int after) {
    return 'Sticle: de la $before la $after';
  }

  @override
  String get uxDrinkSheetRating => 'Cum a fost? (opțional)';

  @override
  String uxDrinkSheetStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de stele din 5',
      few: '$count stele din 5',
      one: '1 stea din 5',
    );
    return '$_temp0';
  }

  @override
  String get uxDrinkSheetConfirm => 'Da, am băut-o';

  @override
  String get uxRemoveBottle => 'Scoate o sticlă fără degustare';

  @override
  String get uxRemoveBottleTitle => 'Scoți o sticlă?';

  @override
  String uxRemoveBottleBody(String name) {
    return 'O sticlă de $name este scoasă fără a nota o degustare.';
  }

  @override
  String get uxRemoveBottleConfirm => 'Scoate';

  @override
  String get uxIdealTitle => 'Momentul ideal';

  @override
  String uxIdealUntil(String year) {
    return 'Recomandat până în $year';
  }

  @override
  String uxIdealUntilPast(String year) {
    return 'Recomandat până în $year: a trecut';
  }

  @override
  String uxIdealBest(String start, String end) {
    return 'La apogeu din $start până în $end';
  }

  @override
  String uxIdealBar(String start, String end) {
    return 'Fereastră de consum din $start până în $end';
  }

  @override
  String get uxIdealDisclaimer =>
      '⚠︎ Orientativ: o estimare bazată pe tip, denumirea de origine și anul de recoltă. Păstrarea și sticla în sine o pot schimba.';

  @override
  String get uxIdealUnavailableHint =>
      'Adaugă anul de recoltă și tipul pentru a primi o estimare.';

  @override
  String uxDashboardDrinkNow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de băut acum',
      few: '$count de băut acum',
      one: '1 de băut acum',
    );
    return '$_temp0';
  }

  @override
  String get uxFamilyRed => 'Roșu';

  @override
  String get uxFamilyWhite => 'Alb';

  @override
  String get uxFamilyRose => 'Rosé';

  @override
  String get uxFamilySparkling => 'Spumant';

  @override
  String get uxFamilySweet => 'Dulce';

  @override
  String get labelBackTitle => 'Acum contraeticheta';

  @override
  String get labelBackHint =>
      'Pe contraetichetă sunt de obicei codul de bare, producătorul și anul de recoltă: ajută la găsirea vinului.';

  @override
  String get labelBackTake => 'Fotografiază spatele';

  @override
  String get labelBackGallery => 'Alege din galerie';

  @override
  String get labelBackSkip => 'Sari';

  @override
  String get labelStepFront => 'Față';

  @override
  String get labelStepBack => 'Spate';

  @override
  String get labelStepBarcode => 'Cod de bare';

  @override
  String get labelStepDatabase => 'Baza de date de vinuri de pe telefon';

  @override
  String get labelStepPending => 'În așteptare';

  @override
  String get labelStepRunning => 'În lucru…';

  @override
  String get labelStepDone => 'Gata';

  @override
  String get labelStepSkipped => 'Sărit';

  @override
  String get labelStepFailed => 'Ilizibil';

  @override
  String labelStepStatus(String step, String status) {
    return '$step: $status';
  }

  @override
  String get labelOnPhoneNote =>
      'Totul se întâmplă pe telefon: fotografiile nu sunt trimise nimănui.';

  @override
  String get labelBackUnreadable => 'Contraetichetă ilizibilă';

  @override
  String get labelSourceOffline => 'Din baza de date de pe telefon · offline';

  @override
  String get labelSourceCatalog => 'Din catalog';

  @override
  String get labelSourceOnline => 'De la Open Food Facts · online';

  @override
  String get labelNotThis => 'Nu este acesta';

  @override
  String get labelOffAttribution => 'Date de la Open Food Facts, licență ODbL';

  @override
  String get labelCandidatesTitle => 'Care dintre acestea?';

  @override
  String labelCandidatesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de vinuri asemănătoare',
      few: '$count vinuri asemănătoare',
      one: '1 vin asemănător',
    );
    return '$_temp0';
  }

  @override
  String get labelCandidatesNone => 'Niciunul dintre ele';

  @override
  String get labelChipOffline => 'offline';

  @override
  String get labelChipOnline => 'online';

  @override
  String get labelChipCatalog => 'catalog';

  @override
  String get labelNoProducer => 'producător neindicat';

  @override
  String get labelNoMatch => 'Am citit eticheta, dar nu recunosc vinul';

  @override
  String get labelReadText => 'Text citit';

  @override
  String get labelSearchOnline => 'Caută online';

  @override
  String get labelOpenLens => 'Deschide în Google Lens';

  @override
  String get labelLensLastResort =>
      'Google Lens este ultima soluție: fotografia ajunge la aplicația Google doar dacă confirmi.';

  @override
  String get labelLensTitle => 'Deschizi în Google Lens?';

  @override
  String get labelLensBody =>
      'Fotografia feței etichetei va ajunge la aplicația Google de pe telefon sau la aplicația aleasă de tine, care poate păstra o copie după propriile reguli. Vinoozy nu primește rezultatele: revino aici ca să alegi sau să scrii vinul.';

  @override
  String get labelLensConfirm => 'Deschide Google Lens';

  @override
  String get labelLensFailed =>
      'Nu pot deschide Google Lens sau meniul de partajare';

  @override
  String get onlineSearchTitle => 'Caută online';

  @override
  String get onlineSearchSubtitle => 'Open Food Facts · doar vinuri';

  @override
  String get onlineSearchField => 'Cuvinte de căutat';

  @override
  String get onlineSearchHint => 'Poți schimba cuvintele înainte de căutare.';

  @override
  String get onlineSearchEmptyField => 'Scrie cel puțin un cuvânt';

  @override
  String get onlineSearchButton => 'Caută';

  @override
  String get onlineSearchLoading => 'Caut…';

  @override
  String onlineSearchResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de rezultate',
      few: '$count rezultate',
      one: '1 rezultat',
    );
    return '$_temp0';
  }

  @override
  String get onlineSearchEmpty =>
      'Niciun vin găsit: încearcă alte cuvinte sau „Scrie de mână”.';

  @override
  String get onlineSearchOffline =>
      'Fără rețea: caut doar în baza de date de pe telefon.';

  @override
  String get onlineSearchRateLimited =>
      'Căutarea online nu este disponibilă acum, încearcă din nou peste câteva minute.';

  @override
  String get onlineSearchUnavailable =>
      'Căutarea online nu este activă în această versiune a aplicației: caut doar în baza de date de pe telefon.';

  @override
  String get aboutTitle => 'Despre';

  @override
  String aboutVersion(String version) {
    return 'Versiunea $version';
  }

  @override
  String get aboutDbTitle => 'Baza de date de vinuri';

  @override
  String aboutDbCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de vinuri',
      few: '$count vinuri',
      one: '1 vin',
    );
    return '$_temp0';
  }

  @override
  String aboutDbDate(String date) {
    return 'Export Open Food Facts din $date';
  }

  @override
  String get aboutDbSample =>
      'Bază de date de probă: câteva vinuri de test scrise de mână, nu date Open Food Facts.';

  @override
  String get aboutDbLoading => 'Se deschide baza de date de vinuri…';

  @override
  String get aboutDbUnavailable =>
      'Baza de date de vinuri nu este disponibilă în această versiune';

  @override
  String aboutDbSource(String url) {
    return 'Baza de date derivată și instrumentul care o construiește se află în depozitul public: $url';
  }

  @override
  String get aboutLicenseTitle => 'Licențe';

  @override
  String get aboutLicense =>
      'Conține informații de la Open Food Facts, puse la dispoziție sub Open Database License (ODbL). Conținuturile individuale sunt sub Database Contents License (DbCL).';

  @override
  String get aboutPrivacyTitle => 'Fotografiile etichetelor';

  @override
  String get aboutPrivacy =>
      'Fotografiile etichetelor sunt citite pe telefon și șterse când părăsești rezultatul. Ies din telefon doar dacă atingi „Deschide în Google Lens” și confirmi.';

  @override
  String get aboutAppellationsTitle => 'Denumiri de origine';

  @override
  String get aboutAppellationsSource =>
      'Denumiri de origine: registrul eAmbrosia (UE) și registrele naționale oficiale.';

  @override
  String get aboutAppellationsSample =>
      'Tabel de probă: un extras din registre scris de mână, până la descărcarea registrelor reale.';

  @override
  String get denominationLabel => 'Denumire de origine';

  @override
  String get denominationTooLong => 'Cel mult 120 de caractere';

  @override
  String get autofillFilledNotice =>
      'Completat din etichetă: verifică și salvează';

  @override
  String get autofillPastedNotice => 'Completat din text: verifică și salvează';

  @override
  String get autofillFromText => '✦ din text';

  @override
  String get autofillFromTextSemantics => 'completat din etichetă';

  @override
  String get autofillClear => 'Golește';

  @override
  String get autofillLens => 'Lens';

  @override
  String get autofillClearTitle => 'Golești formularul?';

  @override
  String get autofillClearBody =>
      'Ai scris și tu în unele câmpuri. „Golește” șterge numele, producătorul, denumirea de origine, anul de recoltă, tipul, țara, regiunea și nivelul. Cantitatea rămâne.';

  @override
  String get autofillClearConfirm => 'Golește';

  @override
  String get autofillCleared => 'Formular golit';

  @override
  String get autofillPasteTitle => 'Ai textul din Google Lens?';

  @override
  String get autofillPasteHint =>
      'În Lens selectează textul etichetei și atinge „Copiază”, apoi revino aici.';

  @override
  String get autofillPaste => 'Lipește din Lens';

  @override
  String get autofillOpenLens => 'Din Google Lens';

  @override
  String get autofillOpenLensSemantics => 'deschide Google Lens';

  @override
  String get autofillClipboardEmpty => 'Nu există text în clipboard';

  @override
  String get autofillNoNewFields => 'Nu am găsit în text date de adăugat';

  @override
  String get autofillFromLens => 'Formular completat din textul Lens';

  @override
  String get autofillShareEmpty => 'Niciun text primit';

  @override
  String get autofillShareUseTitle =>
      'Folosești textul pentru câmpurile goale?';

  @override
  String get autofillShareUse => 'Folosește';

  @override
  String get autofillShareIgnore => 'Ignoră';

  @override
  String get addChoiceLens => 'Din Google Lens';

  @override
  String get addChoicePhotoHint => 'Față și spate: Vinoozy citește eticheta.';

  @override
  String get addChoiceLensHint =>
      'Deschide Lens: încadrează, selectează textul și atinge Partajează → Vinoozy.';

  @override
  String get addChoiceImportHint => 'O fotografie a etichetei făcută deja.';

  @override
  String get addChoiceWriteHint => 'Formular gol, cu „Lipește din Lens”.';

  @override
  String get lensInstructionsTitle => 'Google Lens nu poate fi deschis de aici';

  @override
  String get lensInstructionsStep1 =>
      'Deschide Google Lens și încadrează eticheta';

  @override
  String get lensInstructionsStep2 => 'Selectează textul etichetei';

  @override
  String get lensInstructionsStep3 => 'Atinge Partajează → Vinoozy';

  @override
  String get lensInstructionsOk => 'Am înțeles';

  @override
  String get levelLabel => 'Nivel';

  @override
  String get levelEveryday => 'De zi cu zi (ieftin)';

  @override
  String get levelGood => 'Bun';

  @override
  String get levelAging => 'De învechire';

  @override
  String get levelNone => 'Niciunul';

  @override
  String get levelEverydayShort => 'de băut devreme';

  @override
  String get levelGoodShort => 'estimare normală';

  @override
  String get levelAgingShort => 'ține mai mult';

  @override
  String get levelSuggested => 'sugerat';

  @override
  String levelSuggestedReason(String qualifier) {
    return 'Sugerat pentru că numele conține „$qualifier”: se salvează așa dacă nu îl schimbi. Alege altul sau atinge „Niciunul”.';
  }

  @override
  String levelSuggestedSemantics(String qualifier) {
    return 'sugerat, pentru că numele conține $qualifier';
  }

  @override
  String levelOptionSemantics(String option, int index, int count) {
    return 'Nivel, $option, $index din $count';
  }

  @override
  String get levelWhatChanges => 'Ce se schimbă';

  @override
  String get levelEverydayExamples =>
      'Fereastra se scurtează. De ex. vinul casei, Lambrusco, Prosecco de bază, Bardolino, Vinho Verde.';

  @override
  String get levelGoodExamples =>
      'Estimarea normală și valoarea folosită când nu alegi nimic. De ex. Chianti Classico, Barbera d\'Asti Superiore, Rioja Crianza, Côtes du Rhône.';

  @override
  String get levelAgingExamples =>
      'Fereastra se lungește. De ex. Barolo, Brunello, Amarone, Bordeaux Grand Cru, Rioja Gran Reserva, Vintage Port.';

  @override
  String levelPreviewBefore(String start, String end) {
    return 'Înainte $start – $end';
  }

  @override
  String levelPreviewWith(String level, String start, String end) {
    return 'Cu „$level” $start – $end';
  }

  @override
  String levelPreviewNow(String start, String end) {
    return 'Gata $start – până în $end';
  }

  @override
  String levelDetail(String level) {
    return 'Nivel: $level';
  }

  @override
  String get overrideCorrect => 'Corectează';

  @override
  String get overrideRestore => 'Restabilește estimarea';

  @override
  String get overrideCorrectedByYou => 'corectat de tine';

  @override
  String overrideAppEstimate(String year) {
    return 'Estimarea aplicației: până în $year';
  }

  @override
  String get overrideSheetTitle => 'Recomandat până în';

  @override
  String overrideSheetHint(String start) {
    return 'Alege anul. Nu poate fi înainte de „Gata din $start”.';
  }

  @override
  String overridePeakNotice(String peak) {
    return 'Dacă alegi un an dinaintea apogeului ($peak), și apogeul se mută în același an.';
  }

  @override
  String get overrideMore => 'mai multe…';

  @override
  String get overrideSave => 'Salvează corecția';

  @override
  String overrideRestoreTitle(String year) {
    return 'Revii la estimarea aplicației (până în $year)?';
  }

  @override
  String get overrideRestoreConfirm => 'Restabilește';

  @override
  String get overrideSaved => 'Corecție salvată';

  @override
  String get overrideRestored => 'Estimare restabilită';

  @override
  String get estimateSourceCorrectedByYou => 'corectat de tine';

  @override
  String estimateFromDenomination(String name) {
    return 'Estimare după denumirea de origine $name';
  }

  @override
  String estimateFromDenominationQualifier(String name, String qualifier) {
    return 'Estimare după denumirea de origine $name, $qualifier';
  }

  @override
  String estimateFromGrape(String name) {
    return 'Estimare după soiul $name';
  }

  @override
  String get estimateFromType => 'Estimare după tipul de vin';

  @override
  String get autofillReading => 'Citesc textul…';

  @override
  String get guideChip => 'Verificare ghidată';

  @override
  String guideProgress(int n, int total) {
    return 'Întrebarea $n din $total';
  }

  @override
  String get guideClose => 'Închide';

  @override
  String get guideIsDenomination => 'este denumirea de origine?';

  @override
  String get guideIsProducer => 'este producătorul?';

  @override
  String get guideIsName => 'este numele vinului?';

  @override
  String get guideIsVintage => 'Recoltă';

  @override
  String guideAskDenomination(String value) {
    return 'Este $value denumirea de origine?';
  }

  @override
  String guideAskProducer(String value) {
    return 'Este $value producătorul?';
  }

  @override
  String guideAskName(String value) {
    return 'Este $value numele vinului?';
  }

  @override
  String get guideAskVintage => 'Care este anul de recoltă?';

  @override
  String guideQuestionSemantics(int n, int total, String question) {
    return 'Întrebarea $n din $total: $question';
  }

  @override
  String get guideNoProposal => 'Nu am găsit în text';

  @override
  String get guideYes => 'Da';

  @override
  String get guideNo => 'Nu, altul';

  @override
  String get guideEdit => 'Editează';

  @override
  String get guideSkip => 'Sari';

  @override
  String get guideConfirm => 'Confirmă';

  @override
  String get guideCancel => 'Anulează';

  @override
  String guideRejected(String value) {
    return 'Nu „$value”: iată următoarea sugestie';
  }

  @override
  String get guideNoMore => 'Nicio altă sugestie: compune sau sari';

  @override
  String guideProposalAnnounce(String value) {
    return 'Sugestie: $value';
  }

  @override
  String get guideComposeLabel => 'Sau compune atingând cuvinte din text';

  @override
  String get guideComposePreview => 'Previzualizare';

  @override
  String get guideComposeEmpty => 'Atinge unul sau mai multe cuvinte';

  @override
  String get guideComposeLimit => 'Cel mult 8 cuvinte și 80 de caractere';

  @override
  String guideTableMatchSemantics(String name) {
    return 'corespunde cu $name';
  }

  @override
  String guideLine(int n, int total) {
    return 'Rândul $n din $total';
  }

  @override
  String guideWordSelected(String word, int order) {
    return '$word, selectat, $order';
  }

  @override
  String guideWordUnavailable(String word) {
    return '$word, indisponibil';
  }

  @override
  String guideWordUsedFor(String word, String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'denumirea de origine',
      'producer': 'producător',
      'other': 'nume',
    });
    return '$word, folosit pentru $_temp0';
  }

  @override
  String guideUsedMark(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'denumire de origine',
      'producer': 'producător',
      'other': 'nume',
    });
    return '$_temp0';
  }

  @override
  String guideOtherYears(String years) {
    return 'Tot în text: $years';
  }

  @override
  String get guideWheelFromText => 'an găsit în text';

  @override
  String get guideWheelTypeYear => 'Scrie anul';

  @override
  String guideWheelConfirm(String year) {
    return 'Confirmă $year';
  }

  @override
  String get guideNoVintage => 'Fără an de recoltă';

  @override
  String guideSkippedNotice(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'Denumire de origine sărită',
      'producer': 'Producător sărit',
      'vintage': 'An de recoltă sărit',
      'other': 'Nume sărit',
    });
    return '$_temp0: scrie valoarea sau reia ghidul';
  }

  @override
  String guideSkippedMany(int count) {
    return 'Câmpuri sărite: $count. Scrie-le sau reia ghidul';
  }

  @override
  String get guideInvalidValue =>
      'Acest text conține caractere care nu pot fi salvate';

  @override
  String get brandStudio => 'Bottazzini Softworks';

  @override
  String get suggestedMark => '✦ sugerat';

  @override
  String suggestedSemantics(String field, String value) {
    return '$field, $value, sugerat';
  }

  @override
  String get restoreSuggestion => 'Restabilește sugestia';

  @override
  String get restoreSuggestionDone => 'Sugestie restabilită';

  @override
  String get styleLabel => 'Stil';

  @override
  String styleGroupSemantics(String value, int index, int count) {
    return 'Stil, $value, $index din $count';
  }

  @override
  String get styleRedFresh => 'Proaspăt';

  @override
  String get styleRedMedium => 'Mediu';

  @override
  String get styleRedAge => 'De învechire';

  @override
  String get styleRedLong => 'Învechire lungă';

  @override
  String get styleWhiteFresh => 'Proaspăt';

  @override
  String get styleWhiteMedium => 'Mediu';

  @override
  String get styleWhiteAge => 'De învechire';

  @override
  String get styleRoseFresh => 'Proaspăt';

  @override
  String get styleClassicFresh => 'Proaspăt';

  @override
  String get styleClassicAge => 'De învechire';

  @override
  String get styleTankFresh => 'Proaspăt';

  @override
  String get styleLambrusco => 'Lambrusco';

  @override
  String get styleSweetAromatic => 'Aromat';

  @override
  String get styleSweetPassito => 'Struguri stafidiți';

  @override
  String get styleSweetBotrytis => 'Botritizat';

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
  String get styleFortifiedOther => 'Altul';

  @override
  String get profileNameRFresh => 'Roșu fructat';

  @override
  String get profileNameRMedium => 'Roșu cu corp mediu';

  @override
  String get profileNameRAge => 'Roșu de învechire';

  @override
  String get profileNameRLong => 'Roșu de învechire lungă';

  @override
  String get profileNameWFresh => 'Alb proaspăt și aromat';

  @override
  String get profileNameWMedium => 'Alb cu corp mediu';

  @override
  String get profileNameWAge => 'Alb de învechire';

  @override
  String get profileNameRoseFresh => 'Rosé proaspăt';

  @override
  String get profileNameSpTank => 'Spumant proaspăt metoda Charmat';

  @override
  String get profileNameLamFresh => 'Lambrusco proaspăt';

  @override
  String get profileNameSpClassic => 'Spumant proaspăt metoda tradițională';

  @override
  String get profileNameSpClassicAge =>
      'Spumant metoda tradițională, de învechire';

  @override
  String get profileNameSwAromatic => 'Vin dulce aromat, tânăr';

  @override
  String get profileNameSwPassito => 'Vin dulce din struguri stafidiți';

  @override
  String get profileNameSwBotrytis => 'Vin dulce botritizat';

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
  String get profileNameFortUnknown => 'Fortificat, stil necunoscut';

  @override
  String get profileNameUnknown => 'Stil neidentificat';

  @override
  String estimateFromProfile(String profile, String denomination) {
    return 'Estimare după profilul $profile ($denomination)';
  }

  @override
  String estimateFromProfileType(String profile) {
    return 'Estimare după profilul $profile, pe baza tipului';
  }

  @override
  String estimateFromProfileGrape(String profile, String grape) {
    return 'Estimare după profilul $profile, pe baza soiului $grape';
  }

  @override
  String get estimateFromEntryDateDisgorgement =>
      'De la data adăugării: adaugă data degorjării pentru o estimare mai bună';

  @override
  String get estimateFromEntryDateBottling =>
      'De la data adăugării: adaugă data îmbutelierii pentru o estimare mai bună';

  @override
  String get styleToConfirmBanner =>
      '⚠︎ Stil de confirmat: estimarea este orientativă';

  @override
  String get chooseTypePrompt => 'Alege tipul';

  @override
  String estimateUpdatedAnnouncement(String summary) {
    return 'Estimare actualizată: $summary';
  }

  @override
  String get agingStartDisgorgement => 'Degorjare';

  @override
  String get agingStartBottling => 'Îmbuteliere';

  @override
  String get agingStartMonth => 'Lună';

  @override
  String get agingStartYear => 'An';

  @override
  String get agingStartHint => 'De obicei se află pe contraetichetă.';

  @override
  String get agingStartIncomplete => 'Introdu luna și anul';

  @override
  String get agingStartFuture => 'Data nu poate fi în viitor';

  @override
  String get agingStartBeforeVintage =>
      'Nu poate fi înainte de anul de recoltă';

  @override
  String get windowNoEnd => 'Gata, fără sfârșit estimat';

  @override
  String get windowNoEndShort => 'fără sfârșit estimat';

  @override
  String windowDrinkWithin(String date) {
    return 'până la $date';
  }

  @override
  String get levelNoEffect => 'Nivelul nu schimbă această estimare';

  @override
  String get dashboardToConfirmTitle => 'De confirmat';

  @override
  String dashboardToConfirmCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count de vinuri',
      few: '$count vinuri',
      one: '1 vin',
    );
    return '$_temp0';
  }

  @override
  String aboutDbClassified(String percent) {
    return '$percent% dintre vinuri au un tip recunoscut';
  }

  @override
  String get planTitle => 'Plan';

  @override
  String get planFree => 'Gratuit';

  @override
  String get planPlus => 'Plus';

  @override
  String get planPlusGift => 'Plus (cadou)';

  @override
  String get planDevUnlockAll => 'DEV · Plus de test';

  @override
  String get planDevSimulateFree => 'DEV · Plan gratuit simulat';

  @override
  String get planDevSimulateExpired => 'DEV · Plus expirat simulat';

  @override
  String get planDiscoverPlus => 'Descoperă Plus';

  @override
  String get plusTitle => 'Vinoozy Plus';

  @override
  String get plusBenefitsTitle => 'Cu Plus';

  @override
  String get plusBenefitNoAds => 'Fără reclame';

  @override
  String get plusBenefitNoLimit => 'Fără limită pentru vinurile din pivniță';

  @override
  String get plusComingSoon => 'Plus vine în curând';

  @override
  String get plusLoading => 'Se citesc prețurile din Google Play';

  @override
  String get plusStoreUnavailable =>
      'Prețurile nu au putut fi citite din Google Play. Încearcă mai târziu.';

  @override
  String plusPriceMonthly(String price) {
    return '$price pe lună';
  }

  @override
  String plusPriceAnnual(String price) {
    return '$price pe an';
  }

  @override
  String get plusRenewal =>
      'Abonamentul se reînnoiește automat la prețul afișat până când îl anulezi în Google Play.';

  @override
  String get plusTerms =>
      'Plata se face din contul tău Google Play când confirmi achiziția. Poți anula oricând: Plus rămâne activ până la sfârșitul perioadei deja plătite. Când Plus se încheie, toate vinurile tale rămân.';

  @override
  String get plusRestore => 'Restabilește achizițiile';

  @override
  String get plusManage =>
      'Gestionează sau anulează abonamentul în Google Play';

  @override
  String get plusActive => 'Plus este activ pe acest cont';

  @override
  String get plusActiveGift => 'Ai Plus cadou: fără costuri și fără reînnoiri.';

  @override
  String get plusPending =>
      'Plată în așteptare: Plus va fi activ când Google Play o confirmă.';

  @override
  String get plusVerifying => 'Se verifică achiziția';

  @override
  String get plusVerified =>
      'Achiziție verificată: Plus va fi activ în câteva secunde.';

  @override
  String get plusPurchaseFailed =>
      'Achiziția nu a fost finalizată. Încearcă din nou.';

  @override
  String get plusInvalidPurchase =>
      'Google Play nu a confirmat această achiziție pentru Vinoozy.';

  @override
  String get plusOwnedByOther =>
      'Acest abonament aparține deja altui cont Vinoozy.';

  @override
  String get plusVerificationUnavailable =>
      'Achiziția nu a putut fi verificată acum. Încearcă mai târziu: abonamentul rămâne în Google Play.';

  @override
  String get capacityLimitTitle => 'Ai atins limita planului gratuit';

  @override
  String capacityLimitBody(int limit) {
    return 'Planul gratuit are o limită de vinuri diferite în pivniță: $limit. Poți oricând să editezi, să bei și să adaugi sticle la vinurile pe care le ai deja. Ca să adaugi unul nou, termină sau șterge un vin ori treci la Plus.';
  }

  @override
  String capacityLimitBodyComingSoon(int limit) {
    return 'Planul gratuit are o limită de vinuri diferite în pivniță: $limit. Poți oricând să editezi, să bei și să adaugi sticle la vinurile pe care le ai deja. Ca să adaugi unul nou, termină sau șterge un vin. Plus vine în curând.';
  }

  @override
  String get rejectedCapacityLimit =>
      'Nesincronizat: depășește limita de vinuri a planului gratuit. Modificarea rămâne pe acest telefon.';

  @override
  String get rejectedCapacityConflict =>
      'Nesincronizat: pivnița s-a schimbat în același timp pe alt dispozitiv. Modificarea rămâne pe acest telefon: încearcă din nou.';

  @override
  String writeRejectedCapacityLimit(String name) {
    return '$name: nesincronizat, peste limita planului gratuit';
  }

  @override
  String writeRejectedCapacityConflict(String name) {
    return '$name: nesincronizat, pivnița s-a schimbat pe alt dispozitiv';
  }

  @override
  String get freeIntroTitle => 'Planul gratuit';

  @override
  String freeIntroLimit(int limit) {
    return 'Poți gestiona gratuit vinuri diferite, până la limita de $limit.';
  }

  @override
  String get freeIntroAds =>
      'Utilizarea ușoară este fără reclame. Dacă depășești pragul lunar de utilizare a serviciului, poți vedea ocazional reclame, care ajută la acoperirea costurilor pentru servere și sincronizare.';

  @override
  String get freeIntroNoAds => 'Fără reclame în versiunea de lansare.';

  @override
  String get freeIntroPlus => 'Cu Plus elimini reclamele și limita pivniței.';

  @override
  String get noticeGotIt => 'Am înțeles';

  @override
  String get thresholdTitle => 'Reclamele ajută Vinoozy să rămână gratuit';

  @override
  String get thresholdBody =>
      'Ai atins pragul lunar de utilizare fără reclame. De acum poți vedea ocazional reclame: ne ajută să acoperim costurile pentru servere și sincronizare, iar Vinoozy rămâne gratuit.';

  @override
  String get thresholdReset =>
      'Numărătoarea reîncepe luna viitoare. Cu Plus poți folosi aplicația fără reclame și fără limita pivniței.';

  @override
  String thresholdNextReset(String date) {
    return 'Următoarea resetare: $date';
  }

  @override
  String get thresholdHowItWorks => 'Cum funcționează';

  @override
  String get thresholdHowItWorksBody =>
      'Pragul depinde de o estimare a sincronizărilor cu cloudul făcute de acest cont în timpul lunii. Utilizarea offline nu creează singură operațiuni noi în cloud. Reclamele apar cel mult o dată pe zi, doar în Panou, și niciodată în timp ce salvezi sau exporți datele.';

  @override
  String get adLabel => 'Reclamă';

  @override
  String get devToolsTitle => 'Instrumente pentru dezvoltatori';

  @override
  String get devUnlockAll => 'Deblochează tot — Plus de test';

  @override
  String get devSimulateFree => 'Simulează planul gratuit';

  @override
  String get devSimulateExpired => 'Simulează Plus expirat';

  @override
  String get devRestore => 'Restabilește starea normală';

  @override
  String get devNoOverride => 'Nicio simulare activă';

  @override
  String get devApplied => 'Scenariu aplicat și în emulatorul Firestore';

  @override
  String get devIncomplete =>
      'Simulare incompletă: emulatorul Firestore nu a confirmat dreptul de test. Regulile de pe server nu văd acest scenariu.';

  @override
  String get devNotice =>
      'Doar versiuni de dezvoltare cu emulatorul: fără plăți, tokenuri sau chitanțe.';
}
