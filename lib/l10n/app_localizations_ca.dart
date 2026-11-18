// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Catalan Valencian (`ca`).
class AppLocalizationsCa extends AppLocalizations {
  AppLocalizationsCa([String locale = 'ca']) : super(locale);

  @override
  String get appTitle => 'Vinoozy';

  @override
  String get signInTagline => 'El teu celler, en el moment just';

  @override
  String get signInWithGoogle => 'Continua amb Google';

  @override
  String get signInInProgress => 'S\'està iniciant la sessió';

  @override
  String get signInFailed => 'Error en iniciar la sessió';

  @override
  String get signInNeedsNetwork => 'Cal connexió per al primer inici de sessió';

  @override
  String get signInSessionExpired => 'La sessió ha caducat: torna a iniciar-la';

  @override
  String get retry => 'Torna-ho a provar';

  @override
  String get cancel => 'Cancel·la';

  @override
  String blockedMessage(String email) {
    return 'Hi ha canvis de $email que encara no s\'han desat al núvol: inicia la sessió amb aquest compte i connecta\'t a la xarxa';
  }

  @override
  String blockedSignInWith(String email) {
    return 'Inicia la sessió amb $email';
  }

  @override
  String blockedDiscard(String email) {
    return 'Suprimeix els canvis no desats de $email';
  }

  @override
  String get discardDialogTitle => 'Vols suprimir els canvis?';

  @override
  String discardDialogBody(int count, String email) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count vins de $email encara no són al núvol i se suprimiran d\'aquest telèfon.',
      one:
          '1 vi de $email encara no és al núvol i se suprimirà d\'aquest telèfon.',
    );
    return '$_temp0';
  }

  @override
  String get discardConfirm => 'Suprimeix';

  @override
  String get resetFailed =>
      'No s\'han pogut esborrar les dades d\'aquest telèfon';

  @override
  String get restartRequired => 'Reinicia l\'aplicació per acabar';

  @override
  String get restartCloseApp => 'Tanca l\'aplicació';

  @override
  String get startupFailed => 'No s\'ha pogut iniciar l\'aplicació';

  @override
  String get cellarTitle => 'Celler';

  @override
  String get defaultCellarName => 'El meu celler';

  @override
  String get cellarLoading => 'S\'està preparant el celler';

  @override
  String get cellarSetupFailed => 'No s\'ha pogut preparar el celler';

  @override
  String get cellarEmpty => 'El teu celler és buit';

  @override
  String get addWine => 'Afegeix';

  @override
  String get estimatePending => 'Estimació en camí';

  @override
  String get noVintage => 'Sense anyada';

  @override
  String bottleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ampolles',
      one: '1 ampolla',
    );
    return '$_temp0';
  }

  @override
  String get syncInProgress => 'S\'està sincronitzant';

  @override
  String get syncOffline => 'Sense connexió - sincronització pendent';

  @override
  String writeRejected(String name) {
    return 'Canvi no permès: $name';
  }

  @override
  String get saveFailed => 'No s\'ha pogut desar, torna-ho a provar';

  @override
  String wineNotSaved(String name) {
    return 'El vi $name no s\'ha desat al núvol';
  }

  @override
  String get addAgain => 'Torna\'l a afegir';

  @override
  String get ignore => 'Ignora';

  @override
  String get addWineTitle => 'Escriu';

  @override
  String get wineNameLabel => 'Vi';

  @override
  String get vintageLabel => 'Anyada';

  @override
  String get quantityLabel => 'Quantitat';

  @override
  String get decreaseQuantity => 'Redueix la quantitat';

  @override
  String get increaseQuantity => 'Augmenta la quantitat';

  @override
  String get save => 'Desa';

  @override
  String get nameRequired => 'Escriu el nom del vi';

  @override
  String get nameTooLong => 'Màxim 120 caràcters';

  @override
  String vintageRange(String year) {
    return 'Anyada entre 1900 i $year';
  }

  @override
  String get offAttribution => 'Dades d\'Open Food Facts (ODbL)';

  @override
  String get dashboardTitle => 'Tauler';

  @override
  String dashboardTotalBottles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ampolles al celler',
      one: '1 ampolla al celler',
    );
    return '$_temp0';
  }

  @override
  String get dashboardSyncing => 'S\'està sincronitzant el celler…';

  @override
  String get dashboardAddFirstWine => 'Afegeix el teu primer vi';

  @override
  String get drinkSoonTitle => 'Per beure aviat';

  @override
  String get drinkSoonEmpty => 'Cap ampolla per beure aviat';

  @override
  String drinkSoonUntil(String year) {
    return 'fins al $year';
  }

  @override
  String drinkSoonSeeAll(int count) {
    return 'Mostra\'ls tots ($count)';
  }

  @override
  String get statusChartTitle => 'Estat de les ampolles';

  @override
  String get statusWaiting => 'per esperar';

  @override
  String get statusReady => 'a punt';

  @override
  String get statusDrinkSoon => 'per beure aviat';

  @override
  String get statusPastWindow => 'finestra superada';

  @override
  String toEstimateNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ampolles per estimar',
      one: '1 ampolla per estimar',
    );
    return '$_temp0';
  }

  @override
  String chartBarValue(String label, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ampolles',
      one: '1 ampolla',
    );
    return '$label: $_temp0';
  }

  @override
  String chartDescription(String title, String values) {
    return '$title: $values';
  }

  @override
  String get openListHint => 'Obre la llista';

  @override
  String get peakChartTitle => 'Any de l\'apogeu';

  @override
  String get peakPast => 'apogeu passat';

  @override
  String get peakBeyond => 'més tard';

  @override
  String get breakdownTypeTitle => 'Ampolles per tipus';

  @override
  String get breakdownRegionTitle => 'Ampolles per regió';

  @override
  String get breakdownType => 'Tipus';

  @override
  String get breakdownRegion => 'Regió';

  @override
  String get familyRed => 'negre';

  @override
  String get familyWhite => 'blanc';

  @override
  String get familyRose => 'rosat';

  @override
  String get familySparkling => 'escumós';

  @override
  String get familySweet => 'dolç';

  @override
  String get breakdownUnspecified => 'sense especificar';

  @override
  String get breakdownOtherRegions => 'altres';

  @override
  String get ok => 'D\'acord';

  @override
  String get cellarMenu => 'Menú del celler';

  @override
  String get sharingPeopleTitle => 'Persones';

  @override
  String get sharingInviteTitle => 'Convida una persona';

  @override
  String get sharingEmailLabel => 'Adreça electrònica de Google';

  @override
  String get sharingPermissionRead => 'Només lectura';

  @override
  String get sharingPermissionReadHint =>
      'Veu vins, estimacions, tauler i consums';

  @override
  String get sharingPermissionEdit => 'Pot editar';

  @override
  String get sharingPermissionEditHint =>
      'També afegeix i modifica vins i registra consums';

  @override
  String get sharingRoleOwner => 'propietari';

  @override
  String get sharingInviteButton => 'Convida';

  @override
  String sharingPlacesUsed(int used, int max) {
    return '$used/$max persones';
  }

  @override
  String get sharingInvalidEmail => 'Introdueix una adreça electrònica vàlida';

  @override
  String get sharingSelfInvite => 'No et pots convidar a tu mateix';

  @override
  String get sharingAlreadyInvited => 'Aquesta persona ja està convidada';

  @override
  String sharingLimitReached(int max) {
    return 'Has arribat al límit de $max persones';
  }

  @override
  String get sharingNotOwner =>
      'No pots canviar la compartició d\'aquest celler';

  @override
  String get sharingNotFound => 'Aquesta persona ja no és a la llista';

  @override
  String get sharingFailed => 'No s\'ha pogut completar, torna-ho a provar';

  @override
  String get sharingInviteFailed =>
      'No s\'ha pogut convidar. Torna-ho a provar';

  @override
  String get sharingOfflineHint => 'Cal connexió per gestionar la compartició';

  @override
  String get sharingStatusInvited => 'convidada';

  @override
  String get sharingStatusActive => 'activa';

  @override
  String get sharingStatusRevoked => 'revocada';

  @override
  String get sharingStatusLeft => 'ha sortit';

  @override
  String sharingMemberSemantics(String name, String permission, String status) {
    return '$name, $permission, $status';
  }

  @override
  String get sharingClosedSection => 'Accessos tancats';

  @override
  String get sharingNobody => 'Ningú més veu encara aquest celler';

  @override
  String sharingChangePermission(String name) {
    return 'Canvia el permís de $name';
  }

  @override
  String get sharingRevoke => 'Revoca';

  @override
  String sharingRevokeTitle(String name) {
    return 'Vols revocar l\'accés de $name?';
  }

  @override
  String sharingRevokeConfirmLabel(String name) {
    return 'Escriu $name per confirmar';
  }

  @override
  String get sharingRevokeDisabledHint => 'S\'activa quan el nom coincideix';

  @override
  String get sharingReinvite => 'Torna a convidar';

  @override
  String get sharingDeleteForGood => 'Suprimeix definitivament';

  @override
  String sharingOwnedBy(String owner) {
    return 'Celler de $owner';
  }

  @override
  String get sharingYourCellar => 'El teu celler';

  @override
  String sharingYourPermission(String permission) {
    return 'El teu permís: $permission';
  }

  @override
  String sharingSwitcherSemantics(String cellar, String permission) {
    return '$cellar, $permission. Toca per canviar de celler';
  }

  @override
  String get sharingLeave => 'Surt d\'aquest celler';

  @override
  String sharingLeaveTitle(String owner) {
    return 'Vols sortir del celler de $owner?';
  }

  @override
  String sharingLeaveBody(String owner) {
    return 'Deixaràs de veure\'l. $owner et podrà tornar a convidar.';
  }

  @override
  String get sharingLeaveConfirm => 'Surt';

  @override
  String sharingSharedNotice(String owner) {
    return '$owner ha compartit el seu celler amb tu';
  }

  @override
  String sharingAccessLost(String owner) {
    return 'Ja no tens accés al celler de $owner';
  }

  @override
  String sharingWritesLost(String owner) {
    return 'Alguns canvis al celler de $owner no s\'han desat perquè ja no hi tens accés';
  }

  @override
  String get sharingSomeone => 'algú';

  @override
  String get sharingShareSubject => 'Invitació a Vinoozy';

  @override
  String sharingShareMessage(
    String owner,
    String cellar,
    String link,
    String email,
  ) {
    return '$owner t\'ha convidat al celler «$cellar» a Vinoozy. Instal·la l\'aplicació des de $link i inicia la sessió amb el compte de Google $email: fes servir exactament aquesta adreça.';
  }

  @override
  String get cellarSearchHint => 'Cerca per nom o productor';

  @override
  String get cellarFilterStatus => 'Estat';

  @override
  String get cellarFilterType => 'Tipus';

  @override
  String get statusToEstimate => 'Per estimar';

  @override
  String get filterTypeUnspecified => 'Sense especificar';

  @override
  String get cellarNoMatches => 'Cap vi amb aquests filtres';

  @override
  String get cellarClearFilters => 'Esborra els filtres';

  @override
  String get cellarArchiveTitle => 'Beguts';

  @override
  String get cellarArchiveEmpty => 'Encara no hi ha vins acabats';

  @override
  String get cellarArchiveFailed => 'No s\'han pogut carregar els vins acabats';

  @override
  String get wineDrink => 'Beguda';

  @override
  String wineDrinkTooltip(String name) {
    return 'Marca una ampolla de $name com a beguda';
  }

  @override
  String confidenceLabel(String level) {
    return 'Confiança: $level';
  }

  @override
  String get confidenceHigh => 'alta';

  @override
  String get confidenceMedium => 'mitjana';

  @override
  String get confidenceLow => 'baixa';

  @override
  String get windowStartLabel => 'Inici';

  @override
  String get windowPeakLabel => 'Apogeu';

  @override
  String get windowEndLabel => 'Final';

  @override
  String estimateSourceLabel(String source) {
    return 'Font: $source';
  }

  @override
  String get estimateSourceCatalog => 'base de dades de vins';

  @override
  String get estimateSourceType => 'estimació per tipus';

  @override
  String get estimateSourceCorrected => 'estimació corregida pels teus consums';

  @override
  String get estimateDisclaimer =>
      'Estimació orientativa: també depèn de com s\'ha conservat l\'ampolla';

  @override
  String get estimateUnavailable => 'Estimació no disponible';

  @override
  String get pairingsTitle => 'Maridatges';

  @override
  String get pairingsGeneric => 'maridatges genèrics per al tipus';

  @override
  String get pairingBraisedRedMeat => 'Carn vermella estofada';

  @override
  String get pairingGrilledRedMeat => 'Carn vermella a la brasa';

  @override
  String get pairingGame => 'Caça';

  @override
  String get pairingRoastPoultry => 'Aviram rostit';

  @override
  String get pairingPoultry => 'Aviram';

  @override
  String get pairingPork => 'Porc';

  @override
  String get pairingCuredMeats => 'Embotits';

  @override
  String get pairingPastaMeatSauce => 'Pasta amb salsa de carn';

  @override
  String get pairingMushroomsTruffle => 'Bolets i tòfona';

  @override
  String get pairingAgedCheese => 'Formatges curats';

  @override
  String get pairingFreshCheese => 'Formatges frescos';

  @override
  String get pairingBlueCheese => 'Formatges blaus';

  @override
  String get pairingFish => 'Peix';

  @override
  String get pairingSeafood => 'Marisc';

  @override
  String get pairingRawSeafood => 'Marisc cru';

  @override
  String get pairingFriedFood => 'Fregits';

  @override
  String get pairingVegetables => 'Verdures';

  @override
  String get pairingRisotto => 'Risotto';

  @override
  String get pairingPizza => 'Pizza';

  @override
  String get pairingAperitif => 'Aperitiu';

  @override
  String get pairingPastries => 'Pastisseria';

  @override
  String get pairingDryBiscuits => 'Pastes seques';

  @override
  String get pairingChocolate => 'Xocolata';

  @override
  String get pairingDriedFruit => 'Fruita seca';

  @override
  String get pairingSpicyDishes => 'Plats especiats';

  @override
  String get recentDrinksTitle => 'Últims consums';

  @override
  String get noDrinksYet => 'Encara no hi ha consums';

  @override
  String get wineEdit => 'Edita';

  @override
  String get wineDelete => 'Suprimeix';

  @override
  String get wineFinished => 'Acabat: no queden ampolles';

  @override
  String get wineLoadFailed => 'No s\'ha pogut obrir el vi';

  @override
  String get wineNotFound => 'Aquest vi ja no existeix';

  @override
  String drinkDone(String name) {
    return 'Marcada com a beguda: $name';
  }

  @override
  String get drinkUndo => 'Desfés';

  @override
  String get drinkAddNotes => 'Afegeix valoració i notes';

  @override
  String get nothingToUndo => 'No queda res per desfer';

  @override
  String get cellarUndoRejected =>
      'No s\'ha pogut desfer: l\'ampolla continua marcada com a beguda';

  @override
  String get cellarDeleteFailed =>
      'La supressió encara no ha acabat: es completarà tan aviat com es pugui';

  @override
  String get duplicateFull =>
      'Aquest vi ja té 99 ampolles: no se\'n poden afegir més.';

  @override
  String get recordSheetTitle => 'Valoració i notes';

  @override
  String get recordRatingLabel => 'Valoració';

  @override
  String ratingStar(int n) {
    return 'Valoració $n de 5';
  }

  @override
  String get recordNotesLabel => 'Notes';

  @override
  String get recordNotesTooLong => 'Màxim 1000 caràcters';

  @override
  String recordDateLabel(String date) {
    return 'Data: $date';
  }

  @override
  String get recordDateInvalid =>
      'La data no pot ser futura ni anterior a l\'anyada';

  @override
  String get recordConditionTitle => 'Com estava?';

  @override
  String get conditionTooYoung => 'Encara massa jove';

  @override
  String get conditionJustRight => 'Al punt';

  @override
  String get conditionPastPeak => 'Ja en declivi';

  @override
  String get recordNoCondition => 'Sense resposta';

  @override
  String get producerLabel => 'Productor (opcional)';

  @override
  String get producerTooLong => 'Màxim 120 caràcters';

  @override
  String producerAddNew(String name) {
    return 'Afegeix «$name» com a productor nou';
  }

  @override
  String get wineTypeLabel => 'Tipus';

  @override
  String get typeRedLight => 'Negre lleuger';

  @override
  String get typeRedStructured => 'Negre amb cos';

  @override
  String get typeWhite => 'Blanc';

  @override
  String get typeRose => 'Rosat';

  @override
  String get typeSparklingClassic => 'Escumós mètode tradicional';

  @override
  String get typeSparklingTank => 'Escumós mètode Charmat';

  @override
  String get typeSweet => 'Dolç';

  @override
  String get typeFortified => 'Generós';

  @override
  String get suggestionFromCellar => 'Al teu celler';

  @override
  String get suggestionsLabel => 'Suggeriments';

  @override
  String get duplicateTitle => 'Ja és al celler';

  @override
  String duplicateBody(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ampolles',
      one: '1 ampolla',
      zero: 'cap ampolla',
    );
    return '$name ja hi és, amb $_temp0. Vols afegir-hi les ampolles noves?';
  }

  @override
  String duplicateAdd(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Afegeix $count ampolles',
      one: 'Afegeix 1 ampolla',
    );
    return '$_temp0';
  }

  @override
  String get duplicateBanner => 'Possible duplicat';

  @override
  String get duplicateMerge => 'Fusiona';

  @override
  String get duplicateDeleteHint =>
      'Suprimeix aquesta entrada si és un duplicat';

  @override
  String get mergeTitle => 'Vols fusionar les dues entrades?';

  @override
  String get mergeBody =>
      'Les ampolles d\'aquesta entrada passen a la més antiga i després aquesta entrada se suprimeix.';

  @override
  String get editWineTitle => 'Edita el vi';

  @override
  String get editDuplicate =>
      'Ja hi ha un altre vi amb el mateix nom, productor i anyada';

  @override
  String deleteWineTitle(String name) {
    return 'Vols suprimir $name?';
  }

  @override
  String get deleteWineBody =>
      'Se suprimeixen el vi i tots els seus consums. No es pot desfer.';

  @override
  String get historyTitle => 'Historial';

  @override
  String get historyEmpty => 'Aquí trobaràs les ampolles que has begut';

  @override
  String get historyLoadFailed => 'No s\'ha pogut carregar l\'historial';

  @override
  String drankOnLabel(String date) {
    return 'Beguda el $date';
  }

  @override
  String get addChoiceTitle => 'Afegeix un vi';

  @override
  String get addChoicePhoto => 'Fes una foto';

  @override
  String get addChoiceImport => 'Importa una foto';

  @override
  String get addChoiceWrite => 'Escriu';

  @override
  String get labelReading => 'S\'està llegint l\'etiqueta…';

  @override
  String get labelRecognized => 'He reconegut:';

  @override
  String get labelCorrect => 'Corregeix';

  @override
  String get labelConfirm => 'Confirma';

  @override
  String get labelUnreadable => 'No aconsegueixo llegir l\'etiqueta';

  @override
  String get labelWriteByHand => 'Escriu a mà';

  @override
  String get labelNotFound => 'No he trobat el vi: revisa les dades';

  @override
  String get labelCameraDenied =>
      'Per llegir l\'etiqueta necessito accés a la càmera';

  @override
  String get labelPhotosDenied =>
      'Per llegir l\'etiqueta necessito accés a les fotos';

  @override
  String get labelOpenSettings => 'Obre la configuració';

  @override
  String get labelCameraUnavailable => 'Càmera no disponible';

  @override
  String get labelBarcodeNotFound =>
      'He llegit el codi de barres, però no trobo el vi';

  @override
  String get labelBarcodeFrontHint => 'Fes una foto de l\'etiqueta frontal';

  @override
  String get labelSharedNotAllowed => 'No pots afegir vins a aquest celler';

  @override
  String get labelSharedFirstOnly => 'Només he fet servir la primera foto';

  @override
  String get labelSharedExpired =>
      'No s\'ha pogut llegir la foto compartida: torna-la a compartir';

  @override
  String get labelReplaceTitle =>
      'Tens un vi sense desar. Vols llegir la foto nova?';

  @override
  String get labelReplaceRead => 'Llegeix la foto nova';

  @override
  String get labelReplaceKeep => 'Continua amb l\'obert';

  @override
  String get labelWineAdded => 'Vi afegit al celler';

  @override
  String get onboardingPage1Title => 'El teu celler a la butxaca';

  @override
  String get onboardingPage1Body =>
      'Afegeix les ampolles escrivint-les o amb una foto de l\'etiqueta, fins i tot sense xarxa.';

  @override
  String get onboardingPage2Title => 'En el moment just';

  @override
  String get onboardingPage2Body =>
      'Vinoozy estima quan cada vi és al seu millor moment i et diu quins has d\'obrir primer.';

  @override
  String get onboardingPage3Title => 'Junts';

  @override
  String get onboardingPage3Body =>
      'Comparteix el celler amb fins a dues persones i conserva l\'historial de cada ampolla que beus.';

  @override
  String get onboardingSkip => 'Omet';

  @override
  String get onboardingNext => 'Següent';

  @override
  String get onboardingStart => 'Comença';

  @override
  String onboardingPageOf(int page) {
    return 'Pàgina $page de 3';
  }

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profilePhoto => 'Foto de perfil';

  @override
  String get profileSignOut => 'Tanca la sessió';

  @override
  String get profileDeleteAccount => 'Suprimeix el compte';

  @override
  String get profilePrivacy => 'Política de privadesa';

  @override
  String get profilePrivacyBody =>
      'Pots llegir la política de privadesa en aquesta adreça:';

  @override
  String get profileOpenLink => 'Obre al navegador';

  @override
  String get profileOpenLinkFailed =>
      'No s\'ha pogut obrir la pàgina. Pots copiar l\'enllaç i obrir-lo al navegador.';

  @override
  String get profileCopyLink => 'Copia l\'enllaç';

  @override
  String get profileLinkCopied => 'Enllaç copiat';

  @override
  String get close => 'Tanca';

  @override
  String get signOutConfirmTitle => 'Vols tancar la sessió?';

  @override
  String signOutPendingWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Tens $count canvis encara sense desar. Si tanques la sessió i hi entra un altre compte, es perdran.',
      one: 'Tens 1 canvi encara sense desar. Si tanques la sessió i hi entra un altre compte, es perdrà.',
    );
    return '$_temp0';
  }

  @override
  String get signOutStayAndSync => 'Queda\'t i sincronitza';

  @override
  String get signOutAnyway => 'Tanca la sessió igualment';

  @override
  String get syncAllSaved => 'Tot desat';

  @override
  String syncStillPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Queden $count canvis per desar: comprova la xarxa',
      one: 'Queda 1 canvi per desar: comprova la xarxa',
    );
    return '$_temp0';
  }

  @override
  String get signOutFailed =>
      'No s\'ha pogut tancar la sessió. Torna-ho a provar';

  @override
  String get signInAccountDeleted => 'Compte suprimit';

  @override
  String get deleteAccountIntro => 'Se suprimeix per sempre:';

  @override
  String get deleteAccountItemCellar =>
      'El teu celler, amb els vins i l\'Historial';

  @override
  String get deleteAccountItemShares =>
      'Els accessos que has compartit: les persones convidades perden l\'accés';

  @override
  String get deleteAccountItemMemberships =>
      'La teva participació en cellers d\'altres persones: els teus consums s\'hi queden sense el teu nom';

  @override
  String get deleteAccountItemProfile => 'El teu perfil';

  @override
  String deleteAccountPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Tens $count canvis encara sense desar: es desaran i després se suprimiran amb la resta',
      one: 'Tens 1 canvi encara sense desar: es desarà i després se suprimirà amb la resta',
    );
    return '$_temp0';
  }

  @override
  String get deleteAccountConfirmWord => 'SUPRIMEIX';

  @override
  String deleteAccountTypeWord(String word) {
    return 'Escriu $word per confirmar';
  }

  @override
  String get deleteAccountReauthHint =>
      'Després tornaràs a iniciar la sessió amb Google per confirmar que ets tu.';

  @override
  String get deleteAccountForever => 'Suprimeix per sempre';

  @override
  String get deleteAccountNeedsNetwork =>
      'Connecta\'t a Internet per suprimir el compte';

  @override
  String get deleteAccountSameAccount =>
      'Per suprimir-lo cal iniciar la sessió amb el mateix compte';

  @override
  String get deletionTitle => 'S\'està suprimint el compte';

  @override
  String get deletionStepPreparePhone => 'S\'estan desant els canvis pendents';

  @override
  String get deletionStepMarkStarted => 'S\'està iniciant la supressió';

  @override
  String get deletionStepLeaveOtherCellars =>
      'S\'està sortint dels cellers d\'altres persones';

  @override
  String get deletionStepCloseOwnInvitations =>
      'S\'estan tancant els teus accessos compartits';

  @override
  String get deletionStepDeleteWinesAndRecords =>
      'S\'estan suprimint els vins i l\'Historial';

  @override
  String get deletionStepDeleteCellar => 'S\'està suprimint el celler';

  @override
  String get deletionStepDeleteProfileAndUser =>
      'S\'estan suprimint el perfil i el compte';

  @override
  String get deletionStepCleanUpPhone => 'S\'està netejant aquest telèfon';

  @override
  String deletionStepAnnounce(int step, String label) {
    return 'Pas $step de 8: $label';
  }

  @override
  String deletionDeletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vins i consums suprimits',
      one: '1 vi o consum suprimit',
    );
    return '$_temp0';
  }

  @override
  String get deletionResumeHint =>
      'La supressió d\'aquest compte no ha acabat. Torna a iniciar la sessió amb Google per completar-la.';

  @override
  String get deletionContinue => 'Continua';

  @override
  String get deletionOffline =>
      'Connecta\'t a Internet per completar la supressió';

  @override
  String get deletionPendingWrites =>
      'No aconsegueixo desar els canvis pendents. Torna-ho a provar';

  @override
  String get deletionFailed =>
      'No s\'ha pogut completar la supressió. Torna-ho a provar';

  @override
  String get uxCountryLabel => 'País';

  @override
  String get uxCountryOther => 'Un altre país…';

  @override
  String get uxCountryNone => 'Cap país';

  @override
  String get uxAllCountriesTitle => 'Tots els països i territoris';

  @override
  String get uxAllCountriesSearch => 'Cerca un país';

  @override
  String get uxAllCountriesRare => 'Rars per al vi';

  @override
  String get uxAllCountriesAll => 'Tots, de la A a la Z';

  @override
  String get uxAllCountriesNone => 'No s\'ha trobat cap país';

  @override
  String get uxRegionLabel => 'Regió';

  @override
  String uxRegionOf(String country) {
    return 'Regió · $country';
  }

  @override
  String get uxRegionOther => 'Una altra regió';

  @override
  String get uxRegionFieldLabel => 'Escriu la regió';

  @override
  String get uxRegionTooLong => 'Màxim 120 caràcters';

  @override
  String get uxDrinkAction => 'N\'he begut una';

  @override
  String uxDrinkActionTooltip(String name) {
    return 'He begut una ampolla de $name';
  }

  @override
  String get uxDrinkActionDetail => 'He begut una ampolla';

  @override
  String get uxDrinkSheetLabel => 'Confirma el consum';

  @override
  String get uxDrinkSheetBottles => 'Ampolles';

  @override
  String uxDrinkSheetBottlesChange(int before, int after) {
    return 'Ampolles: de $before a $after';
  }

  @override
  String get uxDrinkSheetRating => 'Com estava? (opcional)';

  @override
  String uxDrinkSheetStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count estrelles de 5',
      one: '1 estrella de 5',
    );
    return '$_temp0';
  }

  @override
  String get uxDrinkSheetConfirm => 'Sí, me l\'he beguda';

  @override
  String get uxRemoveBottle => 'Treu una ampolla sense registrar consum';

  @override
  String get uxRemoveBottleTitle => 'Vols treure una ampolla?';

  @override
  String uxRemoveBottleBody(String name) {
    return 'Es treu una ampolla de $name sense registrar cap consum.';
  }

  @override
  String get uxRemoveBottleConfirm => 'Treu';

  @override
  String get uxIdealTitle => 'Moment ideal';

  @override
  String uxIdealUntil(String year) {
    return 'Recomanat fins al $year';
  }

  @override
  String uxIdealUntilPast(String year) {
    return 'Recomanat fins al $year: ja ha passat';
  }

  @override
  String uxIdealBest(String start, String end) {
    return 'Al seu millor moment del $start al $end';
  }

  @override
  String uxIdealBar(String start, String end) {
    return 'Finestra de consum del $start al $end';
  }

  @override
  String get uxIdealDisclaimer =>
      '⚠︎ Orientatiu: és una estimació basada en el tipus, la denominació i l\'anyada. La conservació i cada ampolla la poden canviar.';

  @override
  String get uxIdealUnavailableHint =>
      'Indica l\'anyada i el tipus per obtenir una estimació.';

  @override
  String uxDashboardDrinkNow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count per beure ara',
      one: '1 per beure ara',
    );
    return '$_temp0';
  }

  @override
  String get uxFamilyRed => 'Negre';

  @override
  String get uxFamilyWhite => 'Blanc';

  @override
  String get uxFamilyRose => 'Rosat';

  @override
  String get uxFamilySparkling => 'Escumós';

  @override
  String get uxFamilySweet => 'Dolç';

  @override
  String get labelBackTitle => 'Ara la contraetiqueta';

  @override
  String get labelBackHint =>
      'A la contraetiqueta hi sol haver el codi de barres, el productor i l\'anyada: ajuden a trobar el vi.';

  @override
  String get labelBackTake => 'Fotografia la contraetiqueta';

  @override
  String get labelBackGallery => 'Tria de la galeria';

  @override
  String get labelBackSkip => 'Omet';

  @override
  String get labelStepFront => 'Frontal';

  @override
  String get labelStepBack => 'Contraetiqueta';

  @override
  String get labelStepBarcode => 'Codi de barres';

  @override
  String get labelStepDatabase => 'Base de vins al telèfon';

  @override
  String get labelStepPending => 'En espera';

  @override
  String get labelStepRunning => 'En curs…';

  @override
  String get labelStepDone => 'Fet';

  @override
  String get labelStepSkipped => 'Omès';

  @override
  String get labelStepFailed => 'Il·legible';

  @override
  String labelStepStatus(String step, String status) {
    return '$step: $status';
  }

  @override
  String get labelOnPhoneNote =>
      'Tot passa al telèfon: les fotos no s\'envien a ningú.';

  @override
  String get labelBackUnreadable => 'Contraetiqueta il·legible';

  @override
  String get labelSourceOffline => 'De la base del telèfon · sense connexió';

  @override
  String get labelSourceCatalog => 'Del catàleg';

  @override
  String get labelSourceOnline => 'D\'Open Food Facts · en línia';

  @override
  String get labelNotThis => 'No és aquest';

  @override
  String get labelOffAttribution => 'Dades d\'Open Food Facts, llicència ODbL';

  @override
  String get labelCandidatesTitle => 'Quin d\'aquests?';

  @override
  String labelCandidatesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vins semblants',
      one: '1 vi semblant',
    );
    return '$_temp0';
  }

  @override
  String get labelCandidatesNone => 'Cap d\'aquests';

  @override
  String get labelChipOffline => 'sense connexió';

  @override
  String get labelChipOnline => 'en línia';

  @override
  String get labelChipCatalog => 'catàleg';

  @override
  String get labelNoProducer => 'productor no indicat';

  @override
  String get labelNoMatch => 'He llegit l\'etiqueta, però no reconec el vi';

  @override
  String get labelReadText => 'Text llegit';

  @override
  String get labelSearchOnline => 'Cerca en línia';

  @override
  String get labelOpenLens => 'Obre a Google Lens';

  @override
  String get labelLensLastResort =>
      'Google Lens és l\'últim recurs: la foto només passa a l\'aplicació de Google si ho confirmes.';

  @override
  String get labelLensTitle => 'Vols obrir-la a Google Lens?';

  @override
  String get labelLensBody =>
      'La foto de l\'etiqueta frontal passarà a l\'aplicació de Google del teu telèfon, o a l\'aplicació que triïs, que en pot conservar una còpia segons les seves normes. Vinoozy no rep els resultats: torna aquí per triar o escriure el vi.';

  @override
  String get labelLensConfirm => 'Obre Google Lens';

  @override
  String get labelLensFailed =>
      'No aconsegueixo obrir Google Lens ni el menú de compartir';

  @override
  String get onlineSearchTitle => 'Cerca en línia';

  @override
  String get onlineSearchSubtitle => 'Open Food Facts · només vins';

  @override
  String get onlineSearchField => 'Paraules per cercar';

  @override
  String get onlineSearchHint => 'Pots canviar les paraules abans de cercar.';

  @override
  String get onlineSearchEmptyField => 'Escriu almenys una paraula';

  @override
  String get onlineSearchButton => 'Cerca';

  @override
  String get onlineSearchLoading => 'S\'està cercant…';

  @override
  String onlineSearchResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count resultats',
      one: '1 resultat',
    );
    return '$_temp0';
  }

  @override
  String get onlineSearchEmpty =>
      'No s\'ha trobat cap vi: prova altres paraules o «Escriu a mà».';

  @override
  String get onlineSearchOffline =>
      'Sense xarxa: només cerco a la base del telèfon.';

  @override
  String get onlineSearchRateLimited =>
      'La cerca en línia no està disponible ara, torna-ho a provar d\'aquí a uns minuts.';

  @override
  String get onlineSearchUnavailable =>
      'La cerca en línia no està activa en aquesta versió de l\'aplicació: només cerco a la base del telèfon.';

  @override
  String get aboutTitle => 'Quant a';

  @override
  String aboutVersion(String version) {
    return 'Versió $version';
  }

  @override
  String get aboutDbTitle => 'Base de vins';

  @override
  String aboutDbCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vins',
      one: '1 vi',
    );
    return '$_temp0';
  }

  @override
  String aboutDbDate(String date) {
    return 'Exportació d\'Open Food Facts del $date';
  }

  @override
  String get aboutDbSample =>
      'Base d\'exemple: uns quants vins de prova escrits a mà, no dades d\'Open Food Facts.';

  @override
  String get aboutDbLoading => 'S\'està obrint la base de vins…';

  @override
  String get aboutDbUnavailable =>
      'La base de vins no està disponible en aquesta versió';

  @override
  String aboutDbSource(String url) {
    return 'La base derivada i l\'eina que la genera són al repositori públic: $url';
  }

  @override
  String get aboutLicenseTitle => 'Llicències';

  @override
  String get aboutLicense =>
      'Conté informació d\'Open Food Facts, disponible sota l\'Open Database License (ODbL). Els continguts individuals estan sota la Database Contents License (DbCL).';

  @override
  String get aboutPrivacyTitle => 'Fotos d\'etiquetes';

  @override
  String get aboutPrivacy =>
      'Les fotos de les etiquetes es llegeixen al telèfon i s\'esborren quan surts del resultat. Només surten del telèfon si toques «Obre a Google Lens» i ho confirmes.';

  @override
  String get aboutAppellationsTitle => 'Denominacions';

  @override
  String get aboutAppellationsSource =>
      'Denominacions: registre eAmbrosia (UE) i registres nacionals oficials.';

  @override
  String get aboutAppellationsSample =>
      'Taula d\'exemple: un extracte dels registres escrit a mà, fins que es baixin els registres reals.';

  @override
  String get denominationLabel => 'Denominació';

  @override
  String get denominationTooLong => 'Màxim 120 caràcters';

  @override
  String get autofillFilledNotice =>
      'Emplenat a partir de l\'etiqueta: revisa-ho i desa';

  @override
  String get autofillPastedNotice =>
      'Emplenat a partir del text: revisa-ho i desa';

  @override
  String get autofillFromText => '✦ del text';

  @override
  String get autofillFromTextSemantics => 'emplenat a partir de l\'etiqueta';

  @override
  String get autofillClear => 'Buida';

  @override
  String get autofillLens => 'Lens';

  @override
  String get autofillClearTitle => 'Vols buidar el formulari?';

  @override
  String get autofillClearBody =>
      'També has escrit en alguns camps. «Buida» esborra nom, productor, denominació, anyada, tipus, país, regió i nivell. La quantitat es manté.';

  @override
  String get autofillClearConfirm => 'Buida';

  @override
  String get autofillCleared => 'Formulari buidat';

  @override
  String get autofillPasteTitle => 'Tens el text de Google Lens?';

  @override
  String get autofillPasteHint =>
      'A Lens, selecciona el text de l\'etiqueta i toca «Copia»; després torna aquí.';

  @override
  String get autofillPaste => 'Enganxa des de Lens';

  @override
  String get autofillOpenLens => 'Des de Google Lens';

  @override
  String get autofillOpenLensSemantics => 'obre Google Lens';

  @override
  String get autofillClipboardEmpty => 'No hi ha text al porta-retalls';

  @override
  String get autofillNoNewFields => 'No he trobat dades per afegir al text';

  @override
  String get autofillFromLens => 'Formulari emplenat amb el text de Lens';

  @override
  String get autofillShareEmpty => 'No s\'ha rebut cap text';

  @override
  String get autofillShareUseTitle =>
      'Vols fer servir el text per als camps buits?';

  @override
  String get autofillShareUse => 'Usa\'l';

  @override
  String get autofillShareIgnore => 'Ignora';

  @override
  String get addChoiceLens => 'Des de Google Lens';

  @override
  String get addChoicePhotoHint =>
      'Frontal i contraetiqueta: Vinoozy llegeix l\'etiqueta.';

  @override
  String get addChoiceLensHint =>
      'Obre Lens: enquadra, selecciona el text i toca Comparteix → Vinoozy.';

  @override
  String get addChoiceImportHint => 'Una foto de l\'etiqueta que ja tens.';

  @override
  String get addChoiceWriteHint => 'Formulari buit, amb «Enganxa des de Lens».';

  @override
  String get lensInstructionsTitle => 'Google Lens no es pot obrir des d\'aquí';

  @override
  String get lensInstructionsStep1 => 'Obre Google Lens i enquadra l\'etiqueta';

  @override
  String get lensInstructionsStep2 => 'Selecciona el text de l\'etiqueta';

  @override
  String get lensInstructionsStep3 => 'Toca Comparteix → Vinoozy';

  @override
  String get lensInstructionsOk => 'Entesos';

  @override
  String get levelLabel => 'Nivell';

  @override
  String get levelEveryday => 'Diari (econòmic)';

  @override
  String get levelGood => 'Bo';

  @override
  String get levelAging => 'De guarda';

  @override
  String get levelNone => 'Cap';

  @override
  String get levelEverydayShort => 'beure jove';

  @override
  String get levelGoodShort => 'estimació normal';

  @override
  String get levelAgingShort => 'dura més';

  @override
  String get levelSuggested => 'suggerit';

  @override
  String levelSuggestedReason(String qualifier) {
    return 'Suggerit perquè el nom conté «$qualifier»: es desa així si no el canvies. Tria\'n un altre o toca «Cap».';
  }

  @override
  String levelSuggestedSemantics(String qualifier) {
    return 'suggerit, perquè el nom conté $qualifier';
  }

  @override
  String levelOptionSemantics(String option, int index, int count) {
    return 'Nivell, $option, $index de $count';
  }

  @override
  String get levelWhatChanges => 'Què canvia';

  @override
  String get levelEverydayExamples =>
      'La finestra s\'escurça. P. ex.: vi de la casa, Lambrusco, Prosecco bàsic, Bardolino, Vinho Verde.';

  @override
  String get levelGoodExamples =>
      'L\'estimació normal, i el valor si no tries res. P. ex.: Chianti Classico, Barbera d\'Asti Superiore, Rioja Crianza, Côtes du Rhône.';

  @override
  String get levelAgingExamples =>
      'La finestra s\'allarga. P. ex.: Barolo, Brunello, Amarone, Bordeaux Grand Cru, Rioja Gran Reserva, Porto Vintage.';

  @override
  String levelPreviewBefore(String start, String end) {
    return 'Abans $start – $end';
  }

  @override
  String levelPreviewWith(String level, String start, String end) {
    return 'Amb «$level» $start – $end';
  }

  @override
  String levelPreviewNow(String start, String end) {
    return 'A punt $start – fins al $end';
  }

  @override
  String levelDetail(String level) {
    return 'Nivell: $level';
  }

  @override
  String get overrideCorrect => 'Corregeix';

  @override
  String get overrideRestore => 'Restaura l\'estimació';

  @override
  String get overrideCorrectedByYou => 'corregit per tu';

  @override
  String overrideAppEstimate(String year) {
    return 'Estimació de l\'aplicació: fins al $year';
  }

  @override
  String get overrideSheetTitle => 'Recomanat fins al';

  @override
  String overrideSheetHint(String start) {
    return 'Tria l\'any. No pot ser anterior a «A punt des del $start».';
  }

  @override
  String overridePeakNotice(String peak) {
    return 'Si tries un any anterior al $peak (al seu millor moment), «al seu millor moment» també passa a aquest any.';
  }

  @override
  String get overrideMore => 'més…';

  @override
  String get overrideSave => 'Desa la correcció';

  @override
  String overrideRestoreTitle(String year) {
    return 'Vols tornar a l\'estimació de l\'aplicació (fins al $year)?';
  }

  @override
  String get overrideRestoreConfirm => 'Restaura';

  @override
  String get overrideSaved => 'Correcció desada';

  @override
  String get overrideRestored => 'Estimació restaurada';

  @override
  String get estimateSourceCorrectedByYou => 'corregida per tu';

  @override
  String estimateFromDenomination(String name) {
    return 'Estimació per la denominació $name';
  }

  @override
  String estimateFromDenominationQualifier(String name, String qualifier) {
    return 'Estimació per la denominació $name, $qualifier';
  }

  @override
  String estimateFromGrape(String name) {
    return 'Estimació per la varietat $name';
  }

  @override
  String get estimateFromType => 'Estimació pel tipus de vi';

  @override
  String get autofillReading => 'S\'està llegint el text…';

  @override
  String get guideChip => 'Revisió guiada';

  @override
  String guideProgress(int n, int total) {
    return 'Pregunta $n de $total';
  }

  @override
  String get guideClose => 'Tanca';

  @override
  String get guideIsDenomination => 'és la denominació?';

  @override
  String get guideIsProducer => 'és el productor?';

  @override
  String get guideIsName => 'és el nom del vi?';

  @override
  String get guideIsVintage => 'Anyada';

  @override
  String guideAskDenomination(String value) {
    return '$value és la denominació?';
  }

  @override
  String guideAskProducer(String value) {
    return '$value és el productor?';
  }

  @override
  String guideAskName(String value) {
    return '$value és el nom del vi?';
  }

  @override
  String get guideAskVintage => 'Quina és l\'anyada?';

  @override
  String guideQuestionSemantics(int n, int total, String question) {
    return 'Pregunta $n de $total: $question';
  }

  @override
  String get guideNoProposal => 'No ho he trobat al text';

  @override
  String get guideYes => 'Sí';

  @override
  String get guideNo => 'No, un altre';

  @override
  String get guideEdit => 'Edita';

  @override
  String get guideSkip => 'Omet';

  @override
  String get guideConfirm => 'Confirma';

  @override
  String get guideCancel => 'Cancel·la';

  @override
  String guideRejected(String value) {
    return '«$value» no: aquí tens el següent';
  }

  @override
  String get guideNoMore =>
      'No hi ha més suggeriments: crea\'l tu o omet el camp';

  @override
  String guideProposalAnnounce(String value) {
    return 'Suggeriment: $value';
  }

  @override
  String get guideComposeLabel => 'O crea\'l tocant paraules del text';

  @override
  String get guideComposePreview => 'Previsualització';

  @override
  String get guideComposeEmpty => 'Toca una o diverses paraules';

  @override
  String get guideComposeLimit => 'Fins a 8 paraules i 80 caràcters';

  @override
  String guideTableMatchSemantics(String name) {
    return 'coincideix amb $name';
  }

  @override
  String guideLine(int n, int total) {
    return 'Línia $n de $total';
  }

  @override
  String guideWordSelected(String word, int order) {
    return '$word, seleccionada, $order';
  }

  @override
  String guideWordUnavailable(String word) {
    return '$word, no disponible';
  }

  @override
  String guideWordUsedFor(String word, String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'la denominació',
      'producer': 'el productor',
      'other': 'el nom',
    });
    return '$word, usada per a $_temp0';
  }

  @override
  String guideUsedMark(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'denominació',
      'producer': 'productor',
      'other': 'nom',
    });
    return '$_temp0';
  }

  @override
  String guideOtherYears(String years) {
    return 'També al text: $years';
  }

  @override
  String get guideWheelFromText => 'any trobat al text';

  @override
  String get guideWheelTypeYear => 'Escriu l\'any';

  @override
  String guideWheelConfirm(String year) {
    return 'Confirma $year';
  }

  @override
  String get guideNoVintage => 'Sense anyada';

  @override
  String guideSkippedNotice(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'Denominació omesa',
      'producer': 'Productor omès',
      'vintage': 'Anyada omesa',
      'other': 'Nom omès',
    });
    return '$_temp0: escriu la dada o reprèn la guia';
  }

  @override
  String guideSkippedMany(int count) {
    return '$count camps omesos: escriu-los o reprèn la guia';
  }

  @override
  String get guideInvalidValue =>
      'Aquest text conté caràcters que no es poden desar';

  @override
  String get brandStudio => 'Bottazzini Softworks';

  @override
  String get suggestedMark => '✦ suggerit';

  @override
  String suggestedSemantics(String field, String value) {
    return '$field, $value, suggerit';
  }

  @override
  String get restoreSuggestion => 'Restaura el suggeriment';

  @override
  String get restoreSuggestionDone => 'Suggeriment restaurat';

  @override
  String get styleLabel => 'Estil';

  @override
  String styleGroupSemantics(String value, int index, int count) {
    return 'Estil, $value, $index de $count';
  }

  @override
  String get styleRedFresh => 'Fresc';

  @override
  String get styleRedMedium => 'Mitjà';

  @override
  String get styleRedAge => 'De guarda';

  @override
  String get styleRedLong => 'Llarga guarda';

  @override
  String get styleWhiteFresh => 'Fresc';

  @override
  String get styleWhiteMedium => 'Mitjà';

  @override
  String get styleWhiteAge => 'De guarda';

  @override
  String get styleRoseFresh => 'Fresc';

  @override
  String get styleClassicFresh => 'Fresc';

  @override
  String get styleClassicAge => 'De guarda';

  @override
  String get styleTankFresh => 'Fresc';

  @override
  String get styleLambrusco => 'Lambrusco';

  @override
  String get styleSweetAromatic => 'Aromàtic';

  @override
  String get styleSweetPassito => 'Raïm pansificat';

  @override
  String get styleSweetBotrytis => 'Botritzat';

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
  String get styleFortifiedOther => 'Altre';

  @override
  String get profileNameRFresh => 'Negre afruitat';

  @override
  String get profileNameRMedium => 'Negre de cos mitjà';

  @override
  String get profileNameRAge => 'Negre de guarda';

  @override
  String get profileNameRLong => 'Negre de llarga guarda';

  @override
  String get profileNameWFresh => 'Blanc fresc i aromàtic';

  @override
  String get profileNameWMedium => 'Blanc de cos mitjà';

  @override
  String get profileNameWAge => 'Blanc de guarda';

  @override
  String get profileNameRoseFresh => 'Rosat fresc';

  @override
  String get profileNameSpTank => 'Escumós Charmat fresc';

  @override
  String get profileNameLamFresh => 'Lambrusco fresc';

  @override
  String get profileNameSpClassic => 'Mètode tradicional fresc';

  @override
  String get profileNameSpClassicAge => 'Mètode tradicional de guarda';

  @override
  String get profileNameSwAromatic => 'Dolç aromàtic jove';

  @override
  String get profileNameSwPassito => 'Dolç de raïm pansificat';

  @override
  String get profileNameSwBotrytis => 'Dolç botritzat';

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
  String get profileNameShPx => 'Xerès Pedro Ximénez';

  @override
  String get profileNameFortUnknown => 'Generós, estil desconegut';

  @override
  String get profileNameUnknown => 'Estil no identificat';

  @override
  String estimateFromProfile(String profile, String denomination) {
    return 'Estimació pel perfil $profile ($denomination)';
  }

  @override
  String estimateFromProfileType(String profile) {
    return 'Estimació pel perfil $profile, segons el tipus';
  }

  @override
  String estimateFromProfileGrape(String profile, String grape) {
    return 'Estimació pel perfil $profile, segons la varietat $grape';
  }

  @override
  String get estimateFromEntryDateDisgorgement =>
      'Segons la data d\'alta: afegeix la data de desgorjament per a una estimació millor';

  @override
  String get estimateFromEntryDateBottling =>
      'Segons la data d\'alta: afegeix la data d\'embotellament per a una estimació millor';

  @override
  String get styleToConfirmBanner =>
      '⚠︎ Estil per confirmar: l\'estimació és orientativa';

  @override
  String get chooseTypePrompt => 'Tria el tipus';

  @override
  String estimateUpdatedAnnouncement(String summary) {
    return 'Estimació actualitzada: $summary';
  }

  @override
  String get agingStartDisgorgement => 'Desgorjament';

  @override
  String get agingStartBottling => 'Embotellament';

  @override
  String get agingStartMonth => 'Mes';

  @override
  String get agingStartYear => 'Any';

  @override
  String get agingStartHint => 'Sol ser a la contraetiqueta.';

  @override
  String get agingStartIncomplete => 'Indica el mes i l\'any';

  @override
  String get agingStartFuture => 'La data no pot ser futura';

  @override
  String get agingStartBeforeVintage => 'No pot ser anterior a l\'anyada';

  @override
  String get windowNoEnd => 'A punt, sense final estimat';

  @override
  String get windowNoEndShort => 'sense final estimat';

  @override
  String windowDrinkWithin(String date) {
    return 'fins a $date';
  }

  @override
  String get levelNoEffect => 'El nivell no canvia aquesta estimació';

  @override
  String get dashboardToConfirmTitle => 'Per confirmar';

  @override
  String dashboardToConfirmCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vins',
      one: '1 vi',
    );
    return '$_temp0';
  }

  @override
  String aboutDbClassified(String percent) {
    return '$percent% dels vins amb tipus reconegut';
  }

  @override
  String get planTitle => 'Pla';

  @override
  String get planFree => 'Gratuït';

  @override
  String get planPlus => 'Plus';

  @override
  String get planPlusGift => 'Plus (regal)';

  @override
  String get planDevUnlockAll => 'DEV · Plus de prova';

  @override
  String get planDevSimulateFree => 'DEV · Pla gratuït simulat';

  @override
  String get planDevSimulateExpired => 'DEV · Plus caducat simulat';

  @override
  String get planDiscoverPlus => 'Descobreix Plus';

  @override
  String get plusTitle => 'Vinoozy Plus';

  @override
  String get plusBenefitsTitle => 'Amb Plus';

  @override
  String get plusBenefitNoAds => 'Sense anuncis';

  @override
  String get plusBenefitNoLimit => 'Sense límit de vins al teu celler';

  @override
  String get plusComingSoon => 'Plus arribarà aviat';

  @override
  String get plusLoading => 'S\'estan consultant els preus a Google Play';

  @override
  String get plusStoreUnavailable =>
      'No s\'han pogut consultar els preus a Google Play. Torna-ho a provar més tard.';

  @override
  String plusPriceMonthly(String price) {
    return '$price al mes';
  }

  @override
  String plusPriceAnnual(String price) {
    return '$price a l\'any';
  }

  @override
  String get plusRenewal =>
      'La subscripció es renova automàticament al preu indicat fins que la cancel·lis a Google Play.';

  @override
  String get plusTerms =>
      'El pagament es carrega al teu compte de Google Play quan confirmes la compra. Pots cancel·lar en qualsevol moment: Plus continua actiu fins al final del període ja pagat. Quan Plus s\'acaba, conserves tots els teus vins.';

  @override
  String get plusRestore => 'Restaura les compres';

  @override
  String get plusManage => 'Gestiona o cancel·la la subscripció a Google Play';

  @override
  String get plusActive => 'Plus està actiu en aquest compte';

  @override
  String get plusActiveGift =>
      'Tens Plus de regal: sense càrrecs ni renovacions.';

  @override
  String get plusPending =>
      'Pagament pendent: Plus s\'activarà quan Google Play el confirmi.';

  @override
  String get plusVerifying => 'S\'està verificant la compra';

  @override
  String get plusVerified =>
      'Compra verificada: Plus s\'activarà d\'aquí a uns segons.';

  @override
  String get plusPurchaseFailed =>
      'La compra no s\'ha completat. Torna-ho a provar.';

  @override
  String get plusInvalidPurchase =>
      'Google Play no ha confirmat aquesta compra per a Vinoozy.';

  @override
  String get plusOwnedByOther =>
      'Aquesta subscripció ja pertany a un altre compte de Vinoozy.';

  @override
  String get plusVerificationUnavailable =>
      'Ara no s\'ha pogut verificar la compra. Torna-ho a provar més tard: la subscripció continua a Google Play.';

  @override
  String get capacityLimitTitle => 'Has arribat al límit del pla gratuït';

  @override
  String capacityLimitBody(int limit) {
    return 'El pla gratuït inclou fins a $limit vins diferents al teu celler. Sempre pots editar, beure i afegir ampolles als vins que ja tens. Per afegir-ne un de nou, acaba o suprimeix un vi, o passa\'t a Plus.';
  }

  @override
  String capacityLimitBodyComingSoon(int limit) {
    return 'El pla gratuït inclou fins a $limit vins diferents al teu celler. Sempre pots editar, beure i afegir ampolles als vins que ja tens. Per afegir-ne un de nou, acaba o suprimeix un vi. Plus arribarà aviat.';
  }

  @override
  String get rejectedCapacityLimit =>
      'No sincronitzat: supera el límit de vins del pla gratuït. El canvi es queda en aquest telèfon.';

  @override
  String get rejectedCapacityConflict =>
      'No sincronitzat: el celler ha canviat en un altre dispositiu al mateix temps. El canvi es queda en aquest telèfon: torna-ho a provar.';

  @override
  String writeRejectedCapacityLimit(String name) {
    return '$name: no sincronitzat, supera el límit del pla gratuït';
  }

  @override
  String writeRejectedCapacityConflict(String name) {
    return '$name: no sincronitzat, el celler ha canviat en un altre dispositiu';
  }

  @override
  String get freeIntroTitle => 'El pla gratuït';

  @override
  String freeIntroLimit(int limit) {
    return 'Pots gestionar gratis fins a $limit vins diferents.';
  }

  @override
  String get freeIntroAds =>
      'L\'ús lleuger no té anuncis. Si superes el llindar mensual d\'ús del servei, pot ser que vegis anuncis ocasionals que ajuden a cobrir els costos dels servidors i la sincronització.';

  @override
  String get freeIntroNoAds => 'Sense anuncis a la versió de llançament.';

  @override
  String get freeIntroPlus =>
      'Amb Plus treus els anuncis i el límit del celler.';

  @override
  String get noticeGotIt => 'Entesos';

  @override
  String get thresholdTitle => 'Els anuncis ajuden a mantenir Vinoozy gratuït';

  @override
  String get thresholdBody =>
      'Has arribat al llindar mensual d\'ús sense anuncis. A partir d\'ara pot ser que vegis anuncis ocasionals: ens ajuden a cobrir els costos dels servidors i la sincronització perquè Vinoozy continuï sent gratuït.';

  @override
  String get thresholdReset =>
      'El recompte torna a començar el mes que ve. Amb Plus pots fer servir l\'aplicació sense anuncis i sense el límit del celler.';

  @override
  String thresholdNextReset(String date) {
    return 'Pròxim reinici: $date';
  }

  @override
  String get thresholdHowItWorks => 'Com funciona';

  @override
  String get thresholdHowItWorksBody =>
      'El llindar depèn d\'una estimació de les sincronitzacions amb el núvol que fa aquest compte durant el mes. L\'ús sense connexió, per si sol, no genera noves operacions al núvol. Els anuncis apareixen com a màxim un cop al dia, només al Tauler, i mai mentre deses o exportes les teves dades.';

  @override
  String get adLabel => 'Publicitat';

  @override
  String get devToolsTitle => 'Eines de desenvolupament';

  @override
  String get devUnlockAll => 'Desbloqueja-ho tot — Plus de prova';

  @override
  String get devSimulateFree => 'Simula el pla gratuït';

  @override
  String get devSimulateExpired => 'Simula Plus caducat';

  @override
  String get devRestore => 'Restaura l\'estat normal';

  @override
  String get devNoOverride => 'Cap simulació activa';

  @override
  String get devApplied => 'Escenari aplicat també a l\'emulador de Firestore';

  @override
  String get devIncomplete =>
      'Simulació incompleta: l\'emulador de Firestore no ha confirmat el dret de prova. Les regles del servidor no veuen aquest escenari.';

  @override
  String get devNotice =>
      'Només compilacions de desenvolupament amb l\'emulador: sense pagaments, tokens ni rebuts.';
}
