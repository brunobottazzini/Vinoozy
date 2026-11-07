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
  String get labelOfflineNotice =>
      'Senza rete riconosco solo la denominazione: controlla i dati';

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
  String get labelBarcodeNeedsNetwork =>
      'Ho letto il codice a barre: serve la rete per cercarlo';

  @override
  String get labelRetryOnline => 'Riprova quando torna la rete';

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
}
