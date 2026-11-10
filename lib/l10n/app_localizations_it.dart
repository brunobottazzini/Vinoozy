// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Vinoozy';

  @override
  String get signInTagline => 'La tua cantina, al momento giusto';

  @override
  String get signInWithGoogle => 'Continua con Google';

  @override
  String get signInInProgress => 'Accesso in corso';

  @override
  String get signInFailed => 'Accesso non riuscito';

  @override
  String get signInNeedsNetwork => 'Serve la connessione per il primo accesso';

  @override
  String get signInSessionExpired => 'La sessione è scaduta: accedi di nuovo';

  @override
  String get retry => 'Riprova';

  @override
  String get cancel => 'Annulla';

  @override
  String blockedMessage(String email) {
    return 'Ci sono modifiche di $email non ancora salvate nel cloud: accedi con quell\'account e collegati alla rete';
  }

  @override
  String blockedSignInWith(String email) {
    return 'Accedi con $email';
  }

  @override
  String blockedDiscard(String email) {
    return 'Elimina le modifiche non salvate di $email';
  }

  @override
  String get discardDialogTitle => 'Eliminare le modifiche?';

  @override
  String discardDialogBody(int count, String email) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count vini di $email non sono ancora nel cloud e verranno eliminati da questo telefono.',
      one:
          '1 vino di $email non è ancora nel cloud e verrà eliminato da questo telefono.',
    );
    return '$_temp0';
  }

  @override
  String get discardConfirm => 'Elimina';

  @override
  String get resetFailed => 'Impossibile cancellare i dati di questo telefono';

  @override
  String get restartRequired => 'Riavvia l\'app per completare';

  @override
  String get restartCloseApp => 'Chiudi l\'app';

  @override
  String get startupFailed => 'Impossibile avviare l\'app';

  @override
  String get cellarTitle => 'Cantina';

  @override
  String get defaultCellarName => 'La mia cantina';

  @override
  String get cellarLoading => 'Preparazione della cantina';

  @override
  String get cellarSetupFailed => 'Impossibile preparare la cantina';

  @override
  String get cellarEmpty => 'La tua cantina è vuota';

  @override
  String get addWine => 'Aggiungi';

  @override
  String get estimatePending => 'Stima in arrivo';

  @override
  String get noVintage => 'Senza annata';

  @override
  String bottleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bottiglie',
      one: '1 bottiglia',
    );
    return '$_temp0';
  }

  @override
  String get syncInProgress => 'Sincronizzazione in corso';

  @override
  String get syncOffline => 'Offline - sincronizzazione in attesa';

  @override
  String writeRejected(String name) {
    return 'Modifica non consentita: $name';
  }

  @override
  String get saveFailed => 'Impossibile salvare, riprova';

  @override
  String wineNotSaved(String name) {
    return 'Il vino $name non è stato salvato nel cloud';
  }

  @override
  String get addAgain => 'Aggiungi di nuovo';

  @override
  String get ignore => 'Ignora';

  @override
  String get addWineTitle => 'Scrivi';

  @override
  String get wineNameLabel => 'Vino';

  @override
  String get vintageLabel => 'Annata';

  @override
  String get quantityLabel => 'Quantità';

  @override
  String get decreaseQuantity => 'Diminuisci quantità';

  @override
  String get increaseQuantity => 'Aumenta quantità';

  @override
  String get save => 'Salva';

  @override
  String get nameRequired => 'Scrivi il nome del vino';

  @override
  String get nameTooLong => 'Massimo 120 caratteri';

  @override
  String vintageRange(String year) {
    return 'Annata tra 1900 e $year';
  }

  @override
  String get offAttribution => 'Dati da Open Food Facts (ODbL)';

  @override
  String get dashboardTitle => 'Cruscotto';

  @override
  String dashboardTotalBottles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bottiglie in cantina',
      one: '1 bottiglia in cantina',
    );
    return '$_temp0';
  }

  @override
  String get dashboardSyncing => 'Sincronizzazione della cantina…';

  @override
  String get dashboardAddFirstWine => 'Aggiungi il primo vino';

  @override
  String get drinkSoonTitle => 'Da bere presto';

  @override
  String get drinkSoonEmpty => 'Nessuna bottiglia in scadenza';

  @override
  String drinkSoonUntil(String year) {
    return 'entro il $year';
  }

  @override
  String drinkSoonSeeAll(int count) {
    return 'Vedi tutti ($count)';
  }

  @override
  String get statusChartTitle => 'Stato delle bottiglie';

  @override
  String get statusWaiting => 'da aspettare';

  @override
  String get statusReady => 'pronte';

  @override
  String get statusDrinkSoon => 'da bere presto';

  @override
  String get statusPastWindow => 'oltre la finestra';

  @override
  String toEstimateNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bottiglie da stimare',
      one: '1 bottiglia da stimare',
    );
    return '$_temp0';
  }

  @override
  String chartBarValue(String label, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bottiglie',
      one: '1 bottiglia',
    );
    return '$label: $_temp0';
  }

  @override
  String chartDescription(String title, String values) {
    return '$title: $values';
  }

  @override
  String get openListHint => 'Apri l\'elenco';

  @override
  String get peakChartTitle => 'Anno del picco';

  @override
  String get peakPast => 'picco passato';

  @override
  String get peakBeyond => 'oltre';

  @override
  String get breakdownTypeTitle => 'Bottiglie per tipologia';

  @override
  String get breakdownRegionTitle => 'Bottiglie per regione';

  @override
  String get breakdownType => 'Tipologia';

  @override
  String get breakdownRegion => 'Regione';

  @override
  String get familyRed => 'rosso';

  @override
  String get familyWhite => 'bianco';

  @override
  String get familyRose => 'rosato';

  @override
  String get familySparkling => 'spumante';

  @override
  String get familySweet => 'dolce';

  @override
  String get breakdownUnspecified => 'non indicata';

  @override
  String get breakdownOtherRegions => 'altre';

  @override
  String get ok => 'OK';

  @override
  String get cellarMenu => 'Menu della cantina';

  @override
  String get sharingPeopleTitle => 'Persone';

  @override
  String get sharingInviteTitle => 'Invita una persona';

  @override
  String get sharingEmailLabel => 'Indirizzo email Google';

  @override
  String get sharingPermissionRead => 'Solo lettura';

  @override
  String get sharingPermissionReadHint =>
      'Vede vini, stime, cruscotto e bevute';

  @override
  String get sharingPermissionEdit => 'Può modificare';

  @override
  String get sharingPermissionEditHint =>
      'Aggiunge e modifica vini e segna le bevute';

  @override
  String get sharingRoleOwner => 'proprietario';

  @override
  String get sharingInviteButton => 'Invita';

  @override
  String sharingPlacesUsed(int used, int max) {
    return '$used/$max persone';
  }

  @override
  String get sharingInvalidEmail => 'Inserisci un\'email valida';

  @override
  String get sharingSelfInvite => 'Non puoi invitare te stesso';

  @override
  String get sharingAlreadyInvited => 'Questa persona è già invitata';

  @override
  String sharingLimitReached(int max) {
    return 'Hai raggiunto il limite di $max persone';
  }

  @override
  String get sharingNotOwner =>
      'Non puoi modificare la condivisione di questa cantina';

  @override
  String get sharingNotFound => 'Questa persona non è più nell\'elenco';

  @override
  String get sharingFailed => 'Non riuscito, riprova';

  @override
  String get sharingInviteFailed => 'Invito non riuscito. Riprova';

  @override
  String get sharingOfflineHint =>
      'Serve la connessione per gestire la condivisione';

  @override
  String get sharingStatusInvited => 'invitata';

  @override
  String get sharingStatusActive => 'attiva';

  @override
  String get sharingStatusRevoked => 'revocata';

  @override
  String get sharingStatusLeft => 'uscita';

  @override
  String sharingMemberSemantics(String name, String permission, String status) {
    return '$name, $permission, $status';
  }

  @override
  String get sharingClosedSection => 'Accessi chiusi';

  @override
  String get sharingNobody => 'Nessun altro vede ancora questa cantina';

  @override
  String sharingChangePermission(String name) {
    return 'Cambia il permesso di $name';
  }

  @override
  String get sharingRevoke => 'Revoca';

  @override
  String sharingRevokeTitle(String name) {
    return 'Revocare l\'accesso di $name?';
  }

  @override
  String sharingRevokeConfirmLabel(String name) {
    return 'Scrivi $name per confermare';
  }

  @override
  String get sharingRevokeDisabledHint => 'Si attiva quando il nome coincide';

  @override
  String get sharingReinvite => 'Invita di nuovo';

  @override
  String get sharingDeleteForGood => 'Elimina definitivamente';

  @override
  String sharingOwnedBy(String owner) {
    return 'Cantina di $owner';
  }

  @override
  String get sharingYourCellar => 'La tua cantina';

  @override
  String sharingYourPermission(String permission) {
    return 'Il tuo permesso: $permission';
  }

  @override
  String sharingSwitcherSemantics(String cellar, String permission) {
    return '$cellar, $permission. Tocca per cambiare cantina';
  }

  @override
  String get sharingLeave => 'Esci da questa cantina';

  @override
  String sharingLeaveTitle(String owner) {
    return 'Uscire dalla cantina di $owner?';
  }

  @override
  String sharingLeaveBody(String owner) {
    return 'Non la vedrai più. $owner potrà invitarti di nuovo.';
  }

  @override
  String get sharingLeaveConfirm => 'Esci';

  @override
  String sharingSharedNotice(String owner) {
    return '$owner ti ha condiviso la sua cantina';
  }

  @override
  String sharingAccessLost(String owner) {
    return 'Non hai più accesso alla cantina di $owner';
  }

  @override
  String sharingWritesLost(String owner) {
    return 'Alcune modifiche alla cantina di $owner non sono state salvate perché non hai più accesso';
  }

  @override
  String get sharingSomeone => 'qualcuno';

  @override
  String get sharingShareSubject => 'Invito a Vinoozy';

  @override
  String sharingShareMessage(
    String owner,
    String cellar,
    String link,
    String email,
  ) {
    return '$owner ti ha invitato nella cantina \"$cellar\" su Vinoozy. Installa l\'app da $link e accedi con l\'account Google $email: usa proprio questo indirizzo.';
  }

  @override
  String get cellarSearchHint => 'Cerca per nome o produttore';

  @override
  String get cellarFilterStatus => 'Stato';

  @override
  String get cellarFilterType => 'Tipologia';

  @override
  String get statusToEstimate => 'Da stimare';

  @override
  String get filterTypeUnspecified => 'Non indicata';

  @override
  String get cellarNoMatches => 'Nessun vino con questi filtri';

  @override
  String get cellarClearFilters => 'Azzera filtri';

  @override
  String get cellarArchiveTitle => 'Bevuti';

  @override
  String get cellarArchiveEmpty => 'Nessun vino finito per ora';

  @override
  String get cellarArchiveFailed => 'Impossibile caricare i vini finiti';

  @override
  String get wineDrink => 'Bevuta';

  @override
  String wineDrinkTooltip(String name) {
    return 'Segna una bottiglia di $name come bevuta';
  }

  @override
  String confidenceLabel(String level) {
    return 'Fiducia: $level';
  }

  @override
  String get confidenceHigh => 'alta';

  @override
  String get confidenceMedium => 'media';

  @override
  String get confidenceLow => 'bassa';

  @override
  String get windowStartLabel => 'Inizio';

  @override
  String get windowPeakLabel => 'Picco';

  @override
  String get windowEndLabel => 'Fine';

  @override
  String estimateSourceLabel(String source) {
    return 'Fonte: $source';
  }

  @override
  String get estimateSourceCatalog => 'base dati vini';

  @override
  String get estimateSourceType => 'stima per tipologia';

  @override
  String get estimateSourceCorrected => 'stima corretta dalle tue bevute';

  @override
  String get estimateDisclaimer =>
      'Stima indicativa: dipende anche da come è stata conservata la bottiglia';

  @override
  String get estimateUnavailable => 'Stima non disponibile';

  @override
  String get pairingsTitle => 'Abbinamenti';

  @override
  String get pairingsGeneric => 'abbinamenti generici per la tipologia';

  @override
  String get pairingBraisedRedMeat => 'Brasati di carne rossa';

  @override
  String get pairingGrilledRedMeat => 'Carne rossa alla griglia';

  @override
  String get pairingGame => 'Selvaggina';

  @override
  String get pairingRoastPoultry => 'Pollame arrosto';

  @override
  String get pairingPoultry => 'Pollame';

  @override
  String get pairingPork => 'Maiale';

  @override
  String get pairingCuredMeats => 'Salumi';

  @override
  String get pairingPastaMeatSauce => 'Pasta al ragù';

  @override
  String get pairingMushroomsTruffle => 'Funghi e tartufo';

  @override
  String get pairingAgedCheese => 'Formaggi stagionati';

  @override
  String get pairingFreshCheese => 'Formaggi freschi';

  @override
  String get pairingBlueCheese => 'Formaggi erborinati';

  @override
  String get pairingFish => 'Pesce';

  @override
  String get pairingSeafood => 'Frutti di mare';

  @override
  String get pairingRawSeafood => 'Crudi di mare';

  @override
  String get pairingFriedFood => 'Fritti';

  @override
  String get pairingVegetables => 'Verdure';

  @override
  String get pairingRisotto => 'Risotti';

  @override
  String get pairingPizza => 'Pizza';

  @override
  String get pairingAperitif => 'Aperitivo';

  @override
  String get pairingPastries => 'Pasticceria';

  @override
  String get pairingDryBiscuits => 'Biscotti secchi';

  @override
  String get pairingChocolate => 'Cioccolato';

  @override
  String get pairingDriedFruit => 'Frutta secca';

  @override
  String get pairingSpicyDishes => 'Piatti speziati';

  @override
  String get recentDrinksTitle => 'Ultime bevute';

  @override
  String get noDrinksYet => 'Nessuna bevuta per ora';

  @override
  String get wineEdit => 'Modifica';

  @override
  String get wineDelete => 'Elimina';

  @override
  String get wineFinished => 'Finito: nessuna bottiglia';

  @override
  String get wineLoadFailed => 'Impossibile aprire il vino';

  @override
  String get wineNotFound => 'Questo vino non esiste più';

  @override
  String drinkDone(String name) {
    return 'Bevuta segnata: $name';
  }

  @override
  String get drinkUndo => 'Annulla';

  @override
  String get drinkAddNotes => 'Aggiungi voto e note';

  @override
  String get nothingToUndo => 'Non c\'è più nulla da annullare';

  @override
  String get cellarUndoRejected =>
      'Annulla non riuscito: la bottiglia resta segnata come bevuta';

  @override
  String get cellarDeleteFailed =>
      'L\'eliminazione non è ancora completa: continuerà appena possibile';

  @override
  String get duplicateFull =>
      'Questo vino ha già 99 bottiglie: non se ne possono aggiungere altre.';

  @override
  String get recordSheetTitle => 'Voto e note';

  @override
  String get recordRatingLabel => 'Voto';

  @override
  String ratingStar(int n) {
    return 'Voto $n su 5';
  }

  @override
  String get recordNotesLabel => 'Note';

  @override
  String get recordNotesTooLong => 'Al massimo 1000 caratteri';

  @override
  String recordDateLabel(String date) {
    return 'Data: $date';
  }

  @override
  String get recordDateInvalid =>
      'La data non può essere futura né precedente all\'annata';

  @override
  String get recordConditionTitle => 'Com\'era?';

  @override
  String get conditionTooYoung => 'Ancora troppo giovane';

  @override
  String get conditionJustRight => 'Al punto giusto';

  @override
  String get conditionPastPeak => 'Già in declino';

  @override
  String get recordNoCondition => 'Nessuna risposta';

  @override
  String get producerLabel => 'Produttore (facoltativo)';

  @override
  String get producerTooLong => 'Al massimo 120 caratteri';

  @override
  String producerAddNew(String name) {
    return 'Aggiungi «$name» come nuovo produttore';
  }

  @override
  String get wineTypeLabel => 'Tipologia';

  @override
  String get typeRedLight => 'Rosso leggero';

  @override
  String get typeRedStructured => 'Rosso strutturato';

  @override
  String get typeWhite => 'Bianco';

  @override
  String get typeRose => 'Rosato';

  @override
  String get typeSparklingClassic => 'Spumante metodo classico';

  @override
  String get typeSparklingTank => 'Spumante metodo Charmat';

  @override
  String get typeSweet => 'Dolce';

  @override
  String get typeFortified => 'Liquoroso';

  @override
  String get suggestionFromCellar => 'Nella tua cantina';

  @override
  String get suggestionsLabel => 'Proposte';

  @override
  String get duplicateTitle => 'Già in cantina';

  @override
  String duplicateBody(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bottiglie',
      one: '1 bottiglia',
      zero: 'nessuna bottiglia',
    );
    return '$name c\'è già, con $_temp0. Aggiungere lì le nuove bottiglie?';
  }

  @override
  String duplicateAdd(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Aggiungi $count bottiglie',
      one: 'Aggiungi 1 bottiglia',
    );
    return '$_temp0';
  }

  @override
  String get duplicateBanner => 'Possibile doppione';

  @override
  String get duplicateMerge => 'Unisci';

  @override
  String get duplicateDeleteHint => 'Elimina questa voce se è un doppione';

  @override
  String get mergeTitle => 'Unire le due voci?';

  @override
  String get mergeBody =>
      'Le bottiglie di questa voce passano a quella più vecchia, poi questa voce viene eliminata.';

  @override
  String get editWineTitle => 'Modifica vino';

  @override
  String get editDuplicate =>
      'Esiste già un altro vino con lo stesso nome, produttore e annata';

  @override
  String deleteWineTitle(String name) {
    return 'Eliminare $name?';
  }

  @override
  String get deleteWineBody =>
      'Il vino e tutte le sue bevute vengono eliminati. Non si può annullare.';

  @override
  String get historyTitle => 'Storico';

  @override
  String get historyEmpty => 'Qui troverai le bottiglie che hai bevuto';

  @override
  String get historyLoadFailed => 'Impossibile caricare lo Storico';

  @override
  String drankOnLabel(String date) {
    return 'Bevuta il $date';
  }

  @override
  String get addChoiceTitle => 'Aggiungi un vino';

  @override
  String get addChoicePhoto => 'Scatta foto';

  @override
  String get addChoiceImport => 'Importa una foto';

  @override
  String get addChoiceWrite => 'Scrivi';

  @override
  String get labelReading => 'Leggo l\'etichetta…';

  @override
  String get labelRecognized => 'Ho riconosciuto:';

  @override
  String get labelCorrect => 'Correggi';

  @override
  String get labelConfirm => 'Conferma';

  @override
  String get labelUnreadable => 'Non riesco a leggere l\'etichetta';

  @override
  String get labelWriteByHand => 'Scrivi a mano';

  @override
  String get labelNotFound => 'Non ho trovato il vino: controlla i dati';

  @override
  String get labelCameraDenied =>
      'Per leggere l\'etichetta serve l\'accesso alla fotocamera';

  @override
  String get labelPhotosDenied =>
      'Per leggere l\'etichetta serve l\'accesso alle foto';

  @override
  String get labelOpenSettings => 'Apri impostazioni';

  @override
  String get labelCameraUnavailable => 'Fotocamera non disponibile';

  @override
  String get labelBarcodeNotFound =>
      'Ho letto il codice a barre ma non trovo il vino';

  @override
  String get labelBarcodeFrontHint => 'Fotografa il fronte dell\'etichetta';

  @override
  String get labelSharedNotAllowed =>
      'Non puoi aggiungere vini a questa cantina';

  @override
  String get labelSharedFirstOnly => 'Ho usato solo la prima foto';

  @override
  String get labelSharedExpired =>
      'Non è stato possibile leggere la foto condivisa: riprova a condividerla';

  @override
  String get labelReplaceTitle =>
      'Hai un vino non salvato. Vuoi leggere la nuova foto?';

  @override
  String get labelReplaceRead => 'Leggi la nuova foto';

  @override
  String get labelReplaceKeep => 'Continua con quello aperto';

  @override
  String get labelWineAdded => 'Vino aggiunto alla cantina';

  @override
  String get onboardingPage1Title => 'La tua cantina in tasca';

  @override
  String get onboardingPage1Body =>
      'Aggiungi le bottiglie scrivendole o con una foto dell\'etichetta, anche senza rete.';

  @override
  String get onboardingPage2Title => 'Al momento giusto';

  @override
  String get onboardingPage2Body =>
      'Vinoozy stima quando ogni vino dà il meglio e ti dice quali aprire prima.';

  @override
  String get onboardingPage3Title => 'Insieme';

  @override
  String get onboardingPage3Body =>
      'Condividi la cantina con al massimo due persone e tieni lo Storico di ogni bottiglia bevuta.';

  @override
  String get onboardingSkip => 'Salta';

  @override
  String get onboardingNext => 'Avanti';

  @override
  String get onboardingStart => 'Inizia';

  @override
  String onboardingPageOf(int page) {
    return 'Pagina $page di 3';
  }

  @override
  String get profileTitle => 'Profilo';

  @override
  String get profilePhoto => 'Foto del profilo';

  @override
  String get profileSignOut => 'Esci';

  @override
  String get profileDeleteAccount => 'Cancella account';

  @override
  String get profilePrivacy => 'Informativa sulla privacy';

  @override
  String get profilePrivacyBody =>
      'Puoi leggere l\'informativa sulla privacy a questo indirizzo:';

  @override
  String get profileOpenLink => 'Apri nel browser';

  @override
  String get profileOpenLinkFailed =>
      'Non è stato possibile aprire la pagina. Puoi copiare il link e aprirlo nel browser.';

  @override
  String get profileCopyLink => 'Copia il link';

  @override
  String get profileLinkCopied => 'Link copiato';

  @override
  String get close => 'Chiudi';

  @override
  String get signOutConfirmTitle => 'Vuoi uscire?';

  @override
  String signOutPendingWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Hai $count modifiche non ancora salvate. Se esci e poi entra un altro account, andranno perse.',
      one: 'Hai 1 modifica non ancora salvata. Se esci e poi entra un altro account, andrà persa.',
    );
    return '$_temp0';
  }

  @override
  String get signOutStayAndSync => 'Resta e sincronizza';

  @override
  String get signOutAnyway => 'Esci comunque';

  @override
  String get syncAllSaved => 'Tutto salvato';

  @override
  String syncStillPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ancora $count modifiche da salvare: controlla la rete',
      one: 'Ancora 1 modifica da salvare: controlla la rete',
    );
    return '$_temp0';
  }

  @override
  String get signOutFailed => 'Non è stato possibile uscire. Riprova';

  @override
  String get signInAccountDeleted => 'Account cancellato';

  @override
  String get deleteAccountIntro => 'Si cancellano per sempre:';

  @override
  String get deleteAccountItemCellar =>
      'La tua cantina, con i vini e lo Storico';

  @override
  String get deleteAccountItemShares =>
      'Le condivisioni che hai dato: le persone invitate perdono l\'accesso';

  @override
  String get deleteAccountItemMemberships =>
      'La tua partecipazione alle cantine di altri: le tue bevute restano lì senza nome';

  @override
  String get deleteAccountItemProfile => 'Il tuo profilo';

  @override
  String deleteAccountPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Hai $count modifiche non ancora salvate: verranno salvate e poi cancellate con il resto',
      one: 'Hai 1 modifica non ancora salvata: verrà salvata e poi cancellata con il resto',
    );
    return '$_temp0';
  }

  @override
  String get deleteAccountConfirmWord => 'CANCELLA';

  @override
  String deleteAccountTypeWord(String word) {
    return 'Scrivi $word per confermare';
  }

  @override
  String get deleteAccountReauthHint =>
      'Poi accederai di nuovo con Google per confermare che sei tu.';

  @override
  String get deleteAccountForever => 'Cancella per sempre';

  @override
  String get deleteAccountNeedsNetwork =>
      'Collegati a Internet per cancellare l\'account';

  @override
  String get deleteAccountSameAccount =>
      'La cancellazione richiede l\'accesso con lo stesso account';

  @override
  String get deletionTitle => 'Cancellazione dell\'account';

  @override
  String get deletionStepPreparePhone =>
      'Salvataggio delle modifiche in sospeso';

  @override
  String get deletionStepMarkStarted => 'Avvio della cancellazione';

  @override
  String get deletionStepLeaveOtherCellars => 'Uscita dalle cantine di altri';

  @override
  String get deletionStepCloseOwnInvitations =>
      'Chiusura delle tue condivisioni';

  @override
  String get deletionStepDeleteWinesAndRecords =>
      'Cancellazione di vini e Storico';

  @override
  String get deletionStepDeleteCellar => 'Cancellazione della cantina';

  @override
  String get deletionStepDeleteProfileAndUser =>
      'Cancellazione del profilo e dell\'account';

  @override
  String get deletionStepCleanUpPhone => 'Pulizia del telefono';

  @override
  String deletionStepAnnounce(int step, String label) {
    return 'Passo $step di 8: $label';
  }

  @override
  String deletionDeletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vini e bevute cancellati',
      one: '1 vino o bevuta cancellati',
    );
    return '$_temp0';
  }

  @override
  String get deletionResumeHint =>
      'La cancellazione di questo account non è finita. Accedi di nuovo con Google per completarla.';

  @override
  String get deletionContinue => 'Continua';

  @override
  String get deletionOffline =>
      'Collegati a Internet per completare la cancellazione';

  @override
  String get deletionPendingWrites =>
      'Non riesco a salvare le modifiche in sospeso. Riprova';

  @override
  String get deletionFailed =>
      'Non è stato possibile completare la cancellazione. Riprova';

  @override
  String get uxCountryLabel => 'Paese';

  @override
  String get uxCountryOther => 'Altro paese…';

  @override
  String get uxCountryNone => 'Nessun paese';

  @override
  String get uxAllCountriesTitle => 'Tutti i paesi e territori';

  @override
  String get uxAllCountriesSearch => 'Cerca un paese';

  @override
  String get uxAllCountriesRare => 'Rari per il vino';

  @override
  String get uxAllCountriesAll => 'Tutti, dalla A alla Z';

  @override
  String get uxAllCountriesNone => 'Nessun paese trovato';

  @override
  String get uxRegionLabel => 'Regione';

  @override
  String uxRegionOf(String country) {
    return 'Regione · $country';
  }

  @override
  String get uxRegionOther => 'Altra regione';

  @override
  String get uxRegionFieldLabel => 'Scrivi la regione';

  @override
  String get uxRegionTooLong => 'Al massimo 120 caratteri';

  @override
  String get uxDrinkAction => 'Ho bevuto';

  @override
  String uxDrinkActionTooltip(String name) {
    return 'Ho bevuto una bottiglia di $name';
  }

  @override
  String get uxDrinkActionDetail => 'Ho bevuto una bottiglia';

  @override
  String get uxDrinkSheetLabel => 'Conferma bevuta';

  @override
  String get uxDrinkSheetBottles => 'Bottiglie';

  @override
  String uxDrinkSheetBottlesChange(int before, int after) {
    return 'Bottiglie: da $before a $after';
  }

  @override
  String get uxDrinkSheetRating => 'Com\'era? (facoltativo)';

  @override
  String uxDrinkSheetStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stelle su 5',
      one: '1 stella su 5',
    );
    return '$_temp0';
  }

  @override
  String get uxDrinkSheetConfirm => 'Sì, l\'ho bevuta';

  @override
  String get uxRemoveBottle => 'Togli una bottiglia senza bevuta';

  @override
  String get uxRemoveBottleTitle => 'Togliere una bottiglia?';

  @override
  String uxRemoveBottleBody(String name) {
    return 'Una bottiglia di $name viene tolta senza registrare una bevuta.';
  }

  @override
  String get uxRemoveBottleConfirm => 'Togli';

  @override
  String get uxIdealTitle => 'Momento ideale';

  @override
  String uxIdealUntil(String year) {
    return 'Consigliato fino al $year';
  }

  @override
  String uxIdealUntilPast(String year) {
    return 'Consigliato fino al $year: è passato';
  }

  @override
  String uxIdealBest(String start, String end) {
    return 'Al meglio dal $start al $end';
  }

  @override
  String uxIdealBar(String start, String end) {
    return 'Finestra di consumo dal $start al $end';
  }

  @override
  String get uxIdealDisclaimer =>
      '⚠︎ Indicativo: è una stima basata su tipo, denominazione e annata. Conservazione e singola bottiglia possono cambiarla.';

  @override
  String get uxIdealUnavailableHint =>
      'Indica annata e tipo per avere una stima.';

  @override
  String uxDashboardDrinkNow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count da bere ora',
      one: '1 da bere ora',
    );
    return '$_temp0';
  }

  @override
  String get uxFamilyRed => 'Rosso';

  @override
  String get uxFamilyWhite => 'Bianco';

  @override
  String get uxFamilyRose => 'Rosato';

  @override
  String get uxFamilySparkling => 'Bollicine';

  @override
  String get uxFamilySweet => 'Dolce';

  @override
  String get labelBackTitle => 'Ora il retro';

  @override
  String get labelBackHint =>
      'Sul retro di solito ci sono il codice a barre, il produttore e l\'annata: aiutano a trovare il vino.';

  @override
  String get labelBackTake => 'Scatta il retro';

  @override
  String get labelBackGallery => 'Scegli dalla galleria';

  @override
  String get labelBackSkip => 'Salta';

  @override
  String get labelStepFront => 'Fronte';

  @override
  String get labelStepBack => 'Retro';

  @override
  String get labelStepBarcode => 'Codice a barre';

  @override
  String get labelStepDatabase => 'Base dei vini sul telefono';

  @override
  String get labelStepPending => 'In attesa';

  @override
  String get labelStepRunning => 'In corso…';

  @override
  String get labelStepDone => 'Fatto';

  @override
  String get labelStepSkipped => 'Saltato';

  @override
  String get labelStepFailed => 'Non leggibile';

  @override
  String labelStepStatus(String step, String status) {
    return '$step: $status';
  }

  @override
  String get labelOnPhoneNote =>
      'Tutto avviene sul telefono: le foto non vengono inviate a nessuno.';

  @override
  String get labelBackUnreadable => 'Retro non leggibile';

  @override
  String get labelSourceOffline => 'Dalla base sul telefono · offline';

  @override
  String get labelSourceCatalog => 'Dal catalogo';

  @override
  String get labelSourceOnline => 'Da Open Food Facts · online';

  @override
  String get labelNotThis => 'Non è questo';

  @override
  String get labelOffAttribution => 'Dati da Open Food Facts, licenza ODbL';

  @override
  String get labelCandidatesTitle => 'Quale di questi?';

  @override
  String labelCandidatesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vini simili',
      one: '1 vino simile',
    );
    return '$_temp0';
  }

  @override
  String get labelCandidatesNone => 'Nessuno di questi';

  @override
  String get labelChipOffline => 'offline';

  @override
  String get labelChipOnline => 'online';

  @override
  String get labelChipCatalog => 'catalogo';

  @override
  String get labelNoProducer => 'produttore non indicato';

  @override
  String get labelNoMatch => 'Ho letto l\'etichetta ma non riconosco il vino';

  @override
  String get labelReadText => 'Testo letto';

  @override
  String get labelSearchOnline => 'Cerca online';

  @override
  String get labelOpenLens => 'Apri in Google Lens';

  @override
  String get labelLensLastResort =>
      'Google Lens è l\'ultima possibilità: la foto viene passata all\'app Google solo se lo confermi.';

  @override
  String get labelLensTitle => 'Apri in Google Lens?';

  @override
  String get labelLensBody =>
      'La foto del fronte verrà passata all\'app Google sul tuo telefono, o all\'app che scegli, che può conservarne una copia secondo le sue regole. Vinoozy non riceve i risultati: torna qui per scegliere o scrivere il vino.';

  @override
  String get labelLensConfirm => 'Apri Google Lens';

  @override
  String get labelLensFailed =>
      'Non riesco ad aprire Google Lens né il menu Condividi';

  @override
  String get onlineSearchTitle => 'Cerca online';

  @override
  String get onlineSearchSubtitle => 'Open Food Facts · solo vini';

  @override
  String get onlineSearchField => 'Parole da cercare';

  @override
  String get onlineSearchHint => 'Puoi cambiare le parole prima di cercare.';

  @override
  String get onlineSearchEmptyField => 'Scrivi almeno una parola';

  @override
  String get onlineSearchButton => 'Cerca';

  @override
  String get onlineSearchLoading => 'Cerco…';

  @override
  String onlineSearchResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count risultati',
      one: '1 risultato',
    );
    return '$_temp0';
  }

  @override
  String get onlineSearchEmpty =>
      'Nessun vino trovato: prova altre parole o \"Scrivi a mano\".';

  @override
  String get onlineSearchOffline =>
      'Senza rete: cerco solo nella base sul telefono.';

  @override
  String get onlineSearchRateLimited =>
      'Ricerca online non disponibile ora, riprova tra qualche minuto.';

  @override
  String get onlineSearchUnavailable =>
      'La ricerca online non è attiva in questa versione dell\'app: cerco solo nella base sul telefono.';

  @override
  String get aboutTitle => 'Informazioni';

  @override
  String aboutVersion(String version) {
    return 'Versione $version';
  }

  @override
  String get aboutDbTitle => 'Base dei vini';

  @override
  String aboutDbCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vini',
      one: '1 vino',
    );
    return '$_temp0';
  }

  @override
  String aboutDbDate(String date) {
    return 'Export di Open Food Facts del $date';
  }

  @override
  String get aboutDbSample =>
      'Base di prova: pochi vini di test scritti a mano, non dati di Open Food Facts.';

  @override
  String get aboutDbLoading => 'Apro la base dei vini…';

  @override
  String get aboutDbUnavailable =>
      'La base dei vini non è disponibile in questa versione';

  @override
  String aboutDbSource(String url) {
    return 'La base derivata e lo strumento che la genera sono nel repository pubblico: $url';
  }

  @override
  String get aboutLicenseTitle => 'Licenze';

  @override
  String get aboutLicense =>
      'Contiene informazioni da Open Food Facts, rese disponibili con la Open Database License (ODbL). I singoli contenuti sono sotto Database Contents License (DbCL).';

  @override
  String get aboutPrivacyTitle => 'Foto delle etichette';

  @override
  String get aboutPrivacy =>
      'Le foto delle etichette vengono lette sul telefono e cancellate quando lasci l\'esito. Lasciano il telefono solo se tocchi \"Apri in Google Lens\" e confermi.';

  @override
  String get aboutAppellationsTitle => 'Denominazioni';

  @override
  String get aboutAppellationsSource =>
      'Denominazioni: registro eAmbrosia (UE) e registri ufficiali nazionali.';

  @override
  String get aboutAppellationsSample =>
      'Tabella di prova: un estratto dei registri scritto a mano, finché non si scaricano i registri veri.';

  @override
  String get denominationLabel => 'Denominazione';

  @override
  String get denominationTooLong => 'Al massimo 120 caratteri';

  @override
  String get autofillFilledNotice =>
      'Compilato dall\'etichetta: controlla e salva';

  @override
  String get autofillPastedNotice => 'Compilato dal testo: controlla e salva';

  @override
  String get autofillFromText => '✦ dal testo';

  @override
  String get autofillFromTextSemantics => 'compilato dall\'etichetta';

  @override
  String get autofillClear => 'Pulisci';

  @override
  String get autofillLens => 'Lens';

  @override
  String get autofillClearTitle => 'Svuotare il modulo?';

  @override
  String get autofillClearBody =>
      'Hai scritto anche tu in alcuni campi. «Pulisci» svuota nome, produttore, denominazione, annata, tipo, paese, regione e livello. La quantità resta.';

  @override
  String get autofillClearConfirm => 'Svuota';

  @override
  String get autofillCleared => 'Modulo svuotato';

  @override
  String get autofillPasteTitle => 'Hai il testo da Google Lens?';

  @override
  String get autofillPasteHint =>
      'In Lens seleziona il testo dell\'etichetta e tocca «Copia», poi torna qui.';

  @override
  String get autofillPaste => 'Incolla da Lens';

  @override
  String get autofillOpenLens => 'Da Google Lens';

  @override
  String get autofillOpenLensSemantics => 'apre Google Lens';

  @override
  String get autofillClipboardEmpty => 'Negli appunti non c\'è testo';

  @override
  String get autofillNoNewFields =>
      'Nel testo non ho trovato dati da aggiungere';

  @override
  String get autofillFromLens => 'Modulo compilato dal testo di Lens';

  @override
  String get autofillShareEmpty => 'Nessun testo ricevuto';

  @override
  String get autofillShareUseTitle => 'Usare il testo per i campi vuoti?';

  @override
  String get autofillShareUse => 'Usa';

  @override
  String get autofillShareIgnore => 'Ignora';

  @override
  String get addChoiceLens => 'Da Google Lens';

  @override
  String get addChoicePhotoHint =>
      'Fronte e retro: Vinoozy legge l\'etichetta.';

  @override
  String get addChoiceLensHint =>
      'Apre Lens: inquadra, seleziona il testo e tocca Condividi → Vinoozy.';

  @override
  String get addChoiceImportHint => 'Una foto dell\'etichetta già scattata.';

  @override
  String get addChoiceWriteHint => 'Modulo vuoto, con «Incolla da Lens».';

  @override
  String get lensInstructionsTitle => 'Da qui Google Lens non si apre';

  @override
  String get lensInstructionsStep1 =>
      'Apri Google Lens e inquadra l\'etichetta';

  @override
  String get lensInstructionsStep2 => 'Seleziona il testo dell\'etichetta';

  @override
  String get lensInstructionsStep3 => 'Tocca Condividi → Vinoozy';

  @override
  String get lensInstructionsOk => 'Ho capito';

  @override
  String get levelLabel => 'Livello';

  @override
  String get levelEveryday => 'Quotidiano (economico)';

  @override
  String get levelGood => 'Buono';

  @override
  String get levelAging => 'Da invecchiamento';

  @override
  String get levelNone => 'Nessuno';

  @override
  String get levelEverydayShort => 'bere presto';

  @override
  String get levelGoodShort => 'stima normale';

  @override
  String get levelAgingShort => 'dura di più';

  @override
  String get levelSuggested => 'suggerito';

  @override
  String levelSuggestedReason(String qualifier) {
    return 'Suggerito perché il nome contiene «$qualifier»: si salva così se non cambi. Scegline un altro o tocca «Nessuno».';
  }

  @override
  String levelSuggestedSemantics(String qualifier) {
    return 'suggerito, perché il nome contiene $qualifier';
  }

  @override
  String levelOptionSemantics(String option, int index, int count) {
    return 'Livello, $option, $index di $count';
  }

  @override
  String get levelWhatChanges => 'Cosa cambia';

  @override
  String get levelEverydayExamples =>
      'La finestra si accorcia. Es. vino della casa, Lambrusco, Prosecco base, Bardolino, Vinho Verde.';

  @override
  String get levelGoodExamples =>
      'La stima normale, ed è il valore se non scegli nulla. Es. Chianti Classico, Barbera d\'Asti Superiore, Rioja Crianza, Côtes du Rhône.';

  @override
  String get levelAgingExamples =>
      'La finestra si allunga. Es. Barolo, Brunello, Amarone, Bordeaux Grand Cru, Rioja Gran Reserva, Porto Vintage.';

  @override
  String levelPreviewBefore(String start, String end) {
    return 'Prima $start – $end';
  }

  @override
  String levelPreviewWith(String level, String start, String end) {
    return 'Con «$level» $start – $end';
  }

  @override
  String levelPreviewNow(String start, String end) {
    return 'Pronto $start – fino al $end';
  }

  @override
  String levelDetail(String level) {
    return 'Livello: $level';
  }

  @override
  String get overrideCorrect => 'Correggi';

  @override
  String get overrideRestore => 'Ripristina stima';

  @override
  String get overrideCorrectedByYou => 'corretto da te';

  @override
  String overrideAppEstimate(String year) {
    return 'Stima dell\'app: fino al $year';
  }

  @override
  String get overrideSheetTitle => 'Consigliato fino al';

  @override
  String overrideSheetHint(String start) {
    return 'Scegli l\'anno. Non può essere prima di «Pronto dal $start».';
  }

  @override
  String overridePeakNotice(String peak) {
    return 'Se scegli un anno prima del $peak (al meglio), anche «al meglio» si sposta allo stesso anno.';
  }

  @override
  String get overrideMore => 'altro…';

  @override
  String get overrideSave => 'Salva correzione';

  @override
  String overrideRestoreTitle(String year) {
    return 'Tornare alla stima dell\'app (fino al $year)?';
  }

  @override
  String get overrideRestoreConfirm => 'Ripristina';

  @override
  String get overrideSaved => 'Correzione salvata';

  @override
  String get overrideRestored => 'Stima ripristinata';

  @override
  String get estimateSourceCorrectedByYou => 'corretta da te';

  @override
  String estimateFromDenomination(String name) {
    return 'Stima dalla denominazione $name';
  }

  @override
  String estimateFromDenominationQualifier(String name, String qualifier) {
    return 'Stima dalla denominazione $name, $qualifier';
  }

  @override
  String estimateFromGrape(String name) {
    return 'Stima dal vitigno $name';
  }

  @override
  String get estimateFromType => 'Stima dal tipo di vino';

  @override
  String get autofillReading => 'Leggo il testo…';

  @override
  String get guideChip => 'Conferma guidata';

  @override
  String guideProgress(int n, int total) {
    return 'Domanda $n di $total';
  }

  @override
  String get guideClose => 'Chiudi';

  @override
  String get guideIsDenomination => 'è la denominazione?';

  @override
  String get guideIsProducer => 'è il produttore?';

  @override
  String get guideIsName => 'è il nome del vino?';

  @override
  String get guideIsVintage => 'Annata';

  @override
  String guideAskDenomination(String value) {
    return '$value è la denominazione?';
  }

  @override
  String guideAskProducer(String value) {
    return '$value è il produttore?';
  }

  @override
  String guideAskName(String value) {
    return '$value è il nome del vino?';
  }

  @override
  String get guideAskVintage => 'Qual è l\'annata?';

  @override
  String guideQuestionSemantics(int n, int total, String question) {
    return 'Domanda $n di $total: $question';
  }

  @override
  String get guideNoProposal => 'Non l\'ho trovato nel testo';

  @override
  String get guideYes => 'Sì';

  @override
  String get guideNo => 'No, un\'altra';

  @override
  String get guideEdit => 'Modifica';

  @override
  String get guideSkip => 'Salta';

  @override
  String get guideConfirm => 'Conferma';

  @override
  String get guideCancel => 'Annulla';

  @override
  String guideRejected(String value) {
    return '\"$value\" no: ti propongo il prossimo';
  }

  @override
  String get guideNoMore => 'Nessun\'altra proposta: puoi comporla o saltare';

  @override
  String guideProposalAnnounce(String value) {
    return 'Proposta: $value';
  }

  @override
  String get guideComposeLabel =>
      'Oppure componila toccando le parole del testo';

  @override
  String get guideComposePreview => 'Anteprima';

  @override
  String get guideComposeEmpty => 'Tocca una o più parole';

  @override
  String get guideComposeLimit => 'Massimo 8 parole e 80 caratteri';

  @override
  String guideTableMatchSemantics(String name) {
    return 'corrisponde a $name';
  }

  @override
  String guideLine(int n, int total) {
    return 'Riga $n di $total';
  }

  @override
  String guideWordSelected(String word, int order) {
    return '$word, selezionata, $order';
  }

  @override
  String guideWordUnavailable(String word) {
    return '$word, non disponibile';
  }

  @override
  String guideWordUsedFor(String word, String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'la denominazione',
      'producer': 'il produttore',
      'other': 'il nome',
    });
    return '$word, usata per $_temp0';
  }

  @override
  String guideUsedMark(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'denominazione',
      'producer': 'produttore',
      'other': 'nome',
    });
    return '$_temp0';
  }

  @override
  String guideOtherYears(String years) {
    return 'Nel testo anche: $years';
  }

  @override
  String get guideWheelFromText => 'anno trovato nel testo';

  @override
  String get guideWheelTypeYear => 'Scrivi l\'anno';

  @override
  String guideWheelConfirm(String year) {
    return 'Conferma $year';
  }

  @override
  String get guideNoVintage => 'Senza annata';

  @override
  String guideSkippedNotice(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'Denominazione saltata',
      'producer': 'Produttore saltato',
      'vintage': 'Annata saltata',
      'other': 'Nome saltato',
    });
    return '$_temp0: puoi scriverlo o riprendere la guida';
  }

  @override
  String guideSkippedMany(int count) {
    return '$count campi saltati: puoi scriverli o riprendere la guida';
  }

  @override
  String get guideInvalidValue =>
      'Il testo contiene caratteri che non si possono salvare';

  @override
  String get brandStudio => 'Bottazzini Softworks';

  @override
  String get suggestedMark => '✦ suggerito';

  @override
  String suggestedSemantics(String field, String value) {
    return '$field, $value, suggerito';
  }

  @override
  String get restoreSuggestion => 'Ripristina suggerimento';

  @override
  String get restoreSuggestionDone => 'Suggerimento ripristinato';

  @override
  String get styleLabel => 'Stile';

  @override
  String styleGroupSemantics(String value, int index, int count) {
    return 'Stile, $value, $index di $count';
  }

  @override
  String get styleRedFresh => 'Fresco';

  @override
  String get styleRedMedium => 'Medio';

  @override
  String get styleRedAge => 'Da evoluzione';

  @override
  String get styleRedLong => 'Di lunga evoluzione';

  @override
  String get styleWhiteFresh => 'Fresco';

  @override
  String get styleWhiteMedium => 'Medio';

  @override
  String get styleWhiteAge => 'Da evoluzione';

  @override
  String get styleRoseFresh => 'Fresco';

  @override
  String get styleClassicFresh => 'Fresco';

  @override
  String get styleClassicAge => 'Da evoluzione';

  @override
  String get styleTankFresh => 'Fresco';

  @override
  String get styleLambrusco => 'Lambrusco';

  @override
  String get styleSweetAromatic => 'Aromatico';

  @override
  String get styleSweetPassito => 'Passito';

  @override
  String get styleSweetBotrytis => 'Botritizzato';

  @override
  String get stylePortVintage => 'Porto Vintage';

  @override
  String get stylePortLbv => 'Porto LBV/Ruby';

  @override
  String get stylePortTawny => 'Porto Tawny/Colheita';

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
  String get styleFortifiedOther => 'Altro';

  @override
  String get profileNameRFresh => 'Rosso orientato al frutto';

  @override
  String get profileNameRMedium => 'Rosso di struttura media';

  @override
  String get profileNameRAge => 'Rosso da evoluzione';

  @override
  String get profileNameRLong => 'Rosso di lunga evoluzione';

  @override
  String get profileNameWFresh => 'Bianco fresco e aromatico';

  @override
  String get profileNameWMedium => 'Bianco di struttura media';

  @override
  String get profileNameWAge => 'Bianco da evoluzione';

  @override
  String get profileNameRoseFresh => 'Rosato fresco';

  @override
  String get profileNameSpTank => 'Spumante Charmat fresco';

  @override
  String get profileNameLamFresh => 'Lambrusco fresco';

  @override
  String get profileNameSpClassic => 'Metodo classico fresco';

  @override
  String get profileNameSpClassicAge => 'Metodo classico da evoluzione';

  @override
  String get profileNameSwAromatic => 'Dolce aromatico giovane';

  @override
  String get profileNameSwPassito => 'Passito da evoluzione';

  @override
  String get profileNameSwBotrytis => 'Dolce botritizzato';

  @override
  String get profileNamePortVintage => 'Porto Vintage';

  @override
  String get profileNamePortLbv => 'Porto LBV/Ruby';

  @override
  String get profileNamePortOx => 'Porto Tawny/Colheita';

  @override
  String get profileNameShFino => 'Fino/Manzanilla';

  @override
  String get profileNameShAmont => 'Amontillado/Medium';

  @override
  String get profileNameShOloroso => 'Oloroso/Cream';

  @override
  String get profileNameShPx => 'Sherry Pedro Ximénez';

  @override
  String get profileNameFortUnknown => 'Liquoroso da distinguere';

  @override
  String get profileNameUnknown => 'Stile non identificato';

  @override
  String estimateFromProfile(String profile, String denomination) {
    return 'Stima dal profilo $profile ($denomination)';
  }

  @override
  String estimateFromProfileType(String profile) {
    return 'Stima dal profilo $profile, dal tipo';
  }

  @override
  String estimateFromProfileGrape(String profile, String grape) {
    return 'Stima dal profilo $profile, dal vitigno $grape';
  }

  @override
  String get estimateFromEntryDateDisgorgement =>
      'Dalla data di inserimento: aggiungi la sboccatura per una stima migliore';

  @override
  String get estimateFromEntryDateBottling =>
      'Dalla data di inserimento: aggiungi l\'imbottigliamento per una stima migliore';

  @override
  String get styleToConfirmBanner =>
      '⚠︎ Stile da confermare: la stima è indicativa';

  @override
  String get chooseTypePrompt => 'Scegli la tipologia';

  @override
  String estimateUpdatedAnnouncement(String summary) {
    return 'Stima aggiornata: $summary';
  }

  @override
  String get agingStartDisgorgement => 'Sboccatura';

  @override
  String get agingStartBottling => 'Imbottigliamento';

  @override
  String get agingStartMonth => 'Mese';

  @override
  String get agingStartYear => 'Anno';

  @override
  String get agingStartHint => 'Di solito è sull\'etichetta posteriore.';

  @override
  String get agingStartIncomplete => 'Indica mese e anno';

  @override
  String get agingStartFuture => 'La data non può essere nel futuro';

  @override
  String get agingStartBeforeVintage => 'Non può essere prima dell\'annata';

  @override
  String get windowNoEnd => 'Pronto, nessuna fine stimata';

  @override
  String get windowNoEndShort => 'nessuna fine stimata';

  @override
  String windowDrinkWithin(String date) {
    return 'entro $date';
  }

  @override
  String get levelNoEffect => 'Il livello non cambia questa stima';

  @override
  String get dashboardToConfirmTitle => 'Da confermare';

  @override
  String dashboardToConfirmCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vini',
      one: '1 vino',
    );
    return '$_temp0';
  }

  @override
  String aboutDbClassified(String percent) {
    return '$percent% dei vini con la tipologia riconosciuta';
  }

  @override
  String get planTitle => 'Piano';

  @override
  String get planFree => 'Gratuito';

  @override
  String get planPlus => 'Plus';

  @override
  String get planPlusGift => 'Plus in regalo';

  @override
  String get planDevUnlockAll => 'DEV · Plus di test';

  @override
  String get planDevSimulateFree => 'DEV · Piano gratuito simulato';

  @override
  String get planDevSimulateExpired => 'DEV · Plus scaduto simulato';

  @override
  String get planDiscoverPlus => 'Scopri Plus';

  @override
  String get plusTitle => 'Vinoozy Plus';

  @override
  String get plusBenefitsTitle => 'Con Plus';

  @override
  String get plusBenefitNoAds => 'Nessuna pubblicità';

  @override
  String get plusBenefitNoLimit => 'Nessun limite di vini in cantina';

  @override
  String get plusComingSoon => 'Plus arriverà presto';

  @override
  String get plusLoading => 'Lettura dei prezzi da Google Play';

  @override
  String get plusStoreUnavailable =>
      'Non è stato possibile leggere i prezzi da Google Play. Riprova più tardi.';

  @override
  String plusPriceMonthly(String price) {
    return '$price al mese';
  }

  @override
  String plusPriceAnnual(String price) {
    return '$price all\'anno';
  }

  @override
  String get plusRenewal =>
      'L\'abbonamento si rinnova automaticamente al prezzo indicato finché non lo annulli su Google Play.';

  @override
  String get plusTerms =>
      'Il pagamento viene addebitato sul tuo account Google Play quando confermi l\'acquisto. Puoi annullare in qualsiasi momento: Plus resta attivo fino alla fine del periodo già pagato. Quando Plus termina, tutti i tuoi vini restano.';

  @override
  String get plusRestore => 'Ripristina acquisti';

  @override
  String get plusManage => 'Gestisci o annulla l\'abbonamento su Google Play';

  @override
  String get plusActive => 'Plus è attivo su questo account';

  @override
  String get plusActiveGift =>
      'Hai Plus in regalo: nessun addebito e nessun rinnovo.';

  @override
  String get plusPending =>
      'Pagamento in attesa: Plus si attiverà quando Google Play lo conferma.';

  @override
  String get plusVerifying => 'Verifica dell\'acquisto in corso';

  @override
  String get plusVerified =>
      'Acquisto verificato: Plus si attiverà tra pochi secondi.';

  @override
  String get plusPurchaseFailed =>
      'L\'acquisto non è stato completato. Riprova.';

  @override
  String get plusInvalidPurchase =>
      'Google Play non ha confermato questo acquisto per Vinoozy.';

  @override
  String get plusOwnedByOther =>
      'Questo abbonamento appartiene già a un altro account Vinoozy.';

  @override
  String get plusVerificationUnavailable =>
      'Non è stato possibile verificare l\'acquisto ora. Riprova più tardi: l\'abbonamento resta su Google Play.';

  @override
  String get capacityLimitTitle => 'Hai raggiunto il limite del piano gratuito';

  @override
  String capacityLimitBody(int limit) {
    return 'Il piano gratuito comprende fino a $limit vini diversi in cantina. Puoi sempre modificare, bere e aggiungere bottiglie ai vini che hai già. Per aggiungerne uno nuovo, finisci o elimina un vino, oppure passa a Plus.';
  }

  @override
  String capacityLimitBodyComingSoon(int limit) {
    return 'Il piano gratuito comprende fino a $limit vini diversi in cantina. Puoi sempre modificare, bere e aggiungere bottiglie ai vini che hai già. Per aggiungerne uno nuovo, finisci o elimina un vino. Plus arriverà presto.';
  }

  @override
  String get rejectedCapacityLimit =>
      'Non sincronizzato: supera il limite di vini del piano gratuito. La modifica resta su questo telefono.';

  @override
  String get rejectedCapacityConflict =>
      'Non sincronizzato: la cantina è cambiata su un altro dispositivo nello stesso momento. La modifica resta su questo telefono: riprova.';

  @override
  String writeRejectedCapacityLimit(String name) {
    return '$name: non sincronizzato, supera il limite del piano gratuito';
  }

  @override
  String writeRejectedCapacityConflict(String name) {
    return '$name: non sincronizzato, la cantina è cambiata su un altro dispositivo';
  }

  @override
  String get freeIntroTitle => 'Il piano gratuito';

  @override
  String freeIntroLimit(int limit) {
    return 'Puoi gestire gratuitamente fino a $limit vini diversi.';
  }

  @override
  String get freeIntroAds =>
      'L\'uso leggero è senza pubblicità. Se superi la soglia mensile di utilizzo del servizio, potresti vedere annunci occasionali che contribuiscono ai costi dei server e della sincronizzazione.';

  @override
  String get freeIntroNoAds => 'Nessuna pubblicità nella versione di lancio.';

  @override
  String get freeIntroPlus =>
      'Con Plus elimini gli annunci e il limite di cantina.';

  @override
  String get noticeGotIt => 'Ho capito';

  @override
  String get thresholdTitle =>
      'Gli annunci aiutano a mantenere Vinoozy gratuito';

  @override
  String get thresholdBody =>
      'Hai raggiunto la soglia mensile di utilizzo senza pubblicità. Da questo momento potresti vedere annunci occasionali: ci aiutano a coprire i costi dei server e della sincronizzazione, mantenendo Vinoozy gratuito.';

  @override
  String get thresholdReset =>
      'Il conteggio si azzera il prossimo mese. Con Plus puoi usare l\'app senza pubblicità e senza il limite di cantina.';

  @override
  String thresholdNextReset(String date) {
    return 'Prossimo azzeramento: $date';
  }

  @override
  String get thresholdHowItWorks => 'Come funziona';

  @override
  String get thresholdHowItWorksBody =>
      'La soglia dipende da una stima delle sincronizzazioni con il cloud fatte da questo account nel mese. L\'uso offline non genera da solo nuove operazioni cloud. Gli annunci compaiono al massimo una volta al giorno, solo nella Dashboard, e mai mentre salvi o esporti i tuoi dati.';

  @override
  String get adLabel => 'Annuncio';

  @override
  String get devToolsTitle => 'Strumenti sviluppatore';

  @override
  String get devUnlockAll => 'Sblocca tutto — Plus di test';

  @override
  String get devSimulateFree => 'Simula piano gratuito';

  @override
  String get devSimulateExpired => 'Simula Plus scaduto';

  @override
  String get devRestore => 'Ripristina stato normale';

  @override
  String get devNoOverride => 'Nessuna simulazione attiva';

  @override
  String get devApplied => 'Scenario applicato anche nell\'emulatore Firestore';

  @override
  String get devIncomplete =>
      'Simulazione incompleta: l\'emulatore Firestore non ha confermato il diritto di test. Le regole del server non vedono questo scenario.';

  @override
  String get devNotice =>
      'Solo build di sviluppo con l\'emulatore: nessun pagamento, token o ricevuta.';
}
