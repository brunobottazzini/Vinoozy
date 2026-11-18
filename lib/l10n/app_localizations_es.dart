// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Vinoozy';

  @override
  String get signInTagline => 'Tu bodega, en el momento justo';

  @override
  String get signInWithGoogle => 'Continuar con Google';

  @override
  String get signInInProgress => 'Iniciando sesión';

  @override
  String get signInFailed => 'Error al iniciar sesión';

  @override
  String get signInNeedsNetwork =>
      'Necesitas conexión para el primer inicio de sesión';

  @override
  String get signInSessionExpired =>
      'Tu sesión ha caducado: vuelve a iniciar sesión';

  @override
  String get retry => 'Reintentar';

  @override
  String get cancel => 'Cancelar';

  @override
  String blockedMessage(String email) {
    return 'Hay cambios de $email que aún no se han guardado en la nube: inicia sesión con esa cuenta y conéctate a la red';
  }

  @override
  String blockedSignInWith(String email) {
    return 'Iniciar sesión con $email';
  }

  @override
  String blockedDiscard(String email) {
    return 'Eliminar los cambios sin guardar de $email';
  }

  @override
  String get discardDialogTitle => '¿Eliminar los cambios?';

  @override
  String discardDialogBody(int count, String email) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count vinos de $email aún no están en la nube y se eliminarán de este teléfono.',
      one:
          '1 vino de $email aún no está en la nube y se eliminará de este teléfono.',
    );
    return '$_temp0';
  }

  @override
  String get discardConfirm => 'Eliminar';

  @override
  String get resetFailed =>
      'No se han podido borrar los datos de este teléfono';

  @override
  String get restartRequired => 'Reinicia la app para terminar';

  @override
  String get restartCloseApp => 'Cerrar la app';

  @override
  String get startupFailed => 'No se ha podido iniciar la app';

  @override
  String get cellarTitle => 'Bodega';

  @override
  String get defaultCellarName => 'Mi bodega';

  @override
  String get cellarLoading => 'Preparando la bodega';

  @override
  String get cellarSetupFailed => 'No se ha podido preparar la bodega';

  @override
  String get cellarEmpty => 'Tu bodega está vacía';

  @override
  String get addWine => 'Añadir';

  @override
  String get estimatePending => 'Estimación en camino';

  @override
  String get noVintage => 'Sin añada';

  @override
  String bottleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count botellas',
      one: '1 botella',
    );
    return '$_temp0';
  }

  @override
  String get syncInProgress => 'Sincronizando';

  @override
  String get syncOffline => 'Sin conexión - sincronización pendiente';

  @override
  String writeRejected(String name) {
    return 'Cambio no permitido: $name';
  }

  @override
  String get saveFailed => 'No se ha podido guardar, inténtalo de nuevo';

  @override
  String wineNotSaved(String name) {
    return 'El vino $name no se ha guardado en la nube';
  }

  @override
  String get addAgain => 'Añadir de nuevo';

  @override
  String get ignore => 'Ignorar';

  @override
  String get addWineTitle => 'Escribir';

  @override
  String get wineNameLabel => 'Vino';

  @override
  String get vintageLabel => 'Añada';

  @override
  String get quantityLabel => 'Cantidad';

  @override
  String get decreaseQuantity => 'Reducir cantidad';

  @override
  String get increaseQuantity => 'Aumentar cantidad';

  @override
  String get save => 'Guardar';

  @override
  String get nameRequired => 'Escribe el nombre del vino';

  @override
  String get nameTooLong => 'Máximo 120 caracteres';

  @override
  String vintageRange(String year) {
    return 'Añada entre 1900 y $year';
  }

  @override
  String get offAttribution => 'Datos de Open Food Facts (ODbL)';

  @override
  String get dashboardTitle => 'Panel';

  @override
  String dashboardTotalBottles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count botellas en la bodega',
      one: '1 botella en la bodega',
    );
    return '$_temp0';
  }

  @override
  String get dashboardSyncing => 'Sincronizando la bodega…';

  @override
  String get dashboardAddFirstWine => 'Añade tu primer vino';

  @override
  String get drinkSoonTitle => 'Beber pronto';

  @override
  String get drinkSoonEmpty => 'Ninguna botella para beber pronto';

  @override
  String drinkSoonUntil(String year) {
    return 'hasta $year';
  }

  @override
  String drinkSoonSeeAll(int count) {
    return 'Ver todos ($count)';
  }

  @override
  String get statusChartTitle => 'Estado de las botellas';

  @override
  String get statusWaiting => 'esperar';

  @override
  String get statusReady => 'listas';

  @override
  String get statusDrinkSoon => 'beber pronto';

  @override
  String get statusPastWindow => 'ventana superada';

  @override
  String toEstimateNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count botellas por estimar',
      one: '1 botella por estimar',
    );
    return '$_temp0';
  }

  @override
  String chartBarValue(String label, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count botellas',
      one: '1 botella',
    );
    return '$label: $_temp0';
  }

  @override
  String chartDescription(String title, String values) {
    return '$title: $values';
  }

  @override
  String get openListHint => 'Abrir la lista';

  @override
  String get peakChartTitle => 'Año de apogeo';

  @override
  String get peakPast => 'apogeo pasado';

  @override
  String get peakBeyond => 'más tarde';

  @override
  String get breakdownTypeTitle => 'Botellas por tipo';

  @override
  String get breakdownRegionTitle => 'Botellas por región';

  @override
  String get breakdownType => 'Tipo';

  @override
  String get breakdownRegion => 'Región';

  @override
  String get familyRed => 'tinto';

  @override
  String get familyWhite => 'blanco';

  @override
  String get familyRose => 'rosado';

  @override
  String get familySparkling => 'espumoso';

  @override
  String get familySweet => 'dulce';

  @override
  String get breakdownUnspecified => 'sin especificar';

  @override
  String get breakdownOtherRegions => 'otras';

  @override
  String get ok => 'Aceptar';

  @override
  String get cellarMenu => 'Menú de la bodega';

  @override
  String get sharingPeopleTitle => 'Personas';

  @override
  String get sharingInviteTitle => 'Invitar a una persona';

  @override
  String get sharingEmailLabel => 'Dirección de correo de Google';

  @override
  String get sharingPermissionRead => 'Solo lectura';

  @override
  String get sharingPermissionReadHint =>
      'Ve vinos, estimaciones, panel y consumos';

  @override
  String get sharingPermissionEdit => 'Puede editar';

  @override
  String get sharingPermissionEditHint =>
      'También añade y modifica vinos y registra consumos';

  @override
  String get sharingRoleOwner => 'propietario';

  @override
  String get sharingInviteButton => 'Invitar';

  @override
  String sharingPlacesUsed(int used, int max) {
    return '$used/$max personas';
  }

  @override
  String get sharingInvalidEmail => 'Introduce un correo válido';

  @override
  String get sharingSelfInvite => 'No puedes invitarte a ti mismo';

  @override
  String get sharingAlreadyInvited => 'Esta persona ya está invitada';

  @override
  String sharingLimitReached(int max) {
    return 'Has alcanzado el límite de $max personas';
  }

  @override
  String get sharingNotOwner =>
      'No puedes cambiar el uso compartido de esta bodega';

  @override
  String get sharingNotFound => 'Esta persona ya no está en la lista';

  @override
  String get sharingFailed => 'No se ha podido completar, inténtalo de nuevo';

  @override
  String get sharingInviteFailed =>
      'No se ha podido invitar. Inténtalo de nuevo';

  @override
  String get sharingOfflineHint =>
      'Necesitas conexión para gestionar el uso compartido';

  @override
  String get sharingStatusInvited => 'invitada';

  @override
  String get sharingStatusActive => 'activa';

  @override
  String get sharingStatusRevoked => 'revocada';

  @override
  String get sharingStatusLeft => 'salió';

  @override
  String sharingMemberSemantics(String name, String permission, String status) {
    return '$name, $permission, $status';
  }

  @override
  String get sharingClosedSection => 'Accesos cerrados';

  @override
  String get sharingNobody => 'Nadie más ve esta bodega todavía';

  @override
  String sharingChangePermission(String name) {
    return 'Cambiar el permiso de $name';
  }

  @override
  String get sharingRevoke => 'Revocar';

  @override
  String sharingRevokeTitle(String name) {
    return '¿Revocar el acceso de $name?';
  }

  @override
  String sharingRevokeConfirmLabel(String name) {
    return 'Escribe $name para confirmar';
  }

  @override
  String get sharingRevokeDisabledHint => 'Se activa cuando el nombre coincide';

  @override
  String get sharingReinvite => 'Invitar de nuevo';

  @override
  String get sharingDeleteForGood => 'Eliminar definitivamente';

  @override
  String sharingOwnedBy(String owner) {
    return 'Bodega de $owner';
  }

  @override
  String get sharingYourCellar => 'Tu bodega';

  @override
  String sharingYourPermission(String permission) {
    return 'Tu permiso: $permission';
  }

  @override
  String sharingSwitcherSemantics(String cellar, String permission) {
    return '$cellar, $permission. Toca para cambiar de bodega';
  }

  @override
  String get sharingLeave => 'Salir de esta bodega';

  @override
  String sharingLeaveTitle(String owner) {
    return '¿Salir de la bodega de $owner?';
  }

  @override
  String sharingLeaveBody(String owner) {
    return 'Dejarás de verla. $owner podrá invitarte de nuevo.';
  }

  @override
  String get sharingLeaveConfirm => 'Salir';

  @override
  String sharingSharedNotice(String owner) {
    return '$owner ha compartido su bodega contigo';
  }

  @override
  String sharingAccessLost(String owner) {
    return 'Ya no tienes acceso a la bodega de $owner';
  }

  @override
  String sharingWritesLost(String owner) {
    return 'Algunos cambios en la bodega de $owner no se han guardado porque ya no tienes acceso';
  }

  @override
  String get sharingSomeone => 'alguien';

  @override
  String get sharingShareSubject => 'Invitación a Vinoozy';

  @override
  String sharingShareMessage(
    String owner,
    String cellar,
    String link,
    String email,
  ) {
    return '$owner te ha invitado a la bodega «$cellar» en Vinoozy. Instala la app desde $link e inicia sesión con la cuenta de Google $email: usa exactamente esta dirección.';
  }

  @override
  String get cellarSearchHint => 'Buscar por nombre o productor';

  @override
  String get cellarFilterStatus => 'Estado';

  @override
  String get cellarFilterType => 'Tipo';

  @override
  String get statusToEstimate => 'Por estimar';

  @override
  String get filterTypeUnspecified => 'Sin especificar';

  @override
  String get cellarNoMatches => 'Ningún vino con estos filtros';

  @override
  String get cellarClearFilters => 'Borrar filtros';

  @override
  String get cellarArchiveTitle => 'Bebidos';

  @override
  String get cellarArchiveEmpty => 'Aún no hay vinos terminados';

  @override
  String get cellarArchiveFailed =>
      'No se han podido cargar los vinos terminados';

  @override
  String get wineDrink => 'Bebida';

  @override
  String wineDrinkTooltip(String name) {
    return 'Marcar una botella de $name como bebida';
  }

  @override
  String confidenceLabel(String level) {
    return 'Confianza: $level';
  }

  @override
  String get confidenceHigh => 'alta';

  @override
  String get confidenceMedium => 'media';

  @override
  String get confidenceLow => 'baja';

  @override
  String get windowStartLabel => 'Inicio';

  @override
  String get windowPeakLabel => 'Apogeo';

  @override
  String get windowEndLabel => 'Fin';

  @override
  String estimateSourceLabel(String source) {
    return 'Fuente: $source';
  }

  @override
  String get estimateSourceCatalog => 'base de datos de vinos';

  @override
  String get estimateSourceType => 'estimación por tipo';

  @override
  String get estimateSourceCorrected => 'estimación corregida por tus consumos';

  @override
  String get estimateDisclaimer =>
      'Estimación orientativa: también depende de cómo se haya conservado la botella';

  @override
  String get estimateUnavailable => 'Estimación no disponible';

  @override
  String get pairingsTitle => 'Maridajes';

  @override
  String get pairingsGeneric => 'maridajes genéricos para el tipo';

  @override
  String get pairingBraisedRedMeat => 'Carne roja estofada';

  @override
  String get pairingGrilledRedMeat => 'Carne roja a la parrilla';

  @override
  String get pairingGame => 'Caza';

  @override
  String get pairingRoastPoultry => 'Aves asadas';

  @override
  String get pairingPoultry => 'Aves';

  @override
  String get pairingPork => 'Cerdo';

  @override
  String get pairingCuredMeats => 'Embutidos';

  @override
  String get pairingPastaMeatSauce => 'Pasta con salsa de carne';

  @override
  String get pairingMushroomsTruffle => 'Setas y trufa';

  @override
  String get pairingAgedCheese => 'Quesos curados';

  @override
  String get pairingFreshCheese => 'Quesos frescos';

  @override
  String get pairingBlueCheese => 'Quesos azules';

  @override
  String get pairingFish => 'Pescado';

  @override
  String get pairingSeafood => 'Marisco';

  @override
  String get pairingRawSeafood => 'Marisco crudo';

  @override
  String get pairingFriedFood => 'Fritos';

  @override
  String get pairingVegetables => 'Verduras';

  @override
  String get pairingRisotto => 'Risotto';

  @override
  String get pairingPizza => 'Pizza';

  @override
  String get pairingAperitif => 'Aperitivo';

  @override
  String get pairingPastries => 'Repostería';

  @override
  String get pairingDryBiscuits => 'Pastas secas';

  @override
  String get pairingChocolate => 'Chocolate';

  @override
  String get pairingDriedFruit => 'Frutos secos';

  @override
  String get pairingSpicyDishes => 'Platos especiados';

  @override
  String get recentDrinksTitle => 'Últimos consumos';

  @override
  String get noDrinksYet => 'Aún no hay consumos';

  @override
  String get wineEdit => 'Editar';

  @override
  String get wineDelete => 'Eliminar';

  @override
  String get wineFinished => 'Terminado: no quedan botellas';

  @override
  String get wineLoadFailed => 'No se ha podido abrir el vino';

  @override
  String get wineNotFound => 'Este vino ya no existe';

  @override
  String drinkDone(String name) {
    return 'Marcada como bebida: $name';
  }

  @override
  String get drinkUndo => 'Deshacer';

  @override
  String get drinkAddNotes => 'Añadir valoración y notas';

  @override
  String get nothingToUndo => 'No queda nada que deshacer';

  @override
  String get cellarUndoRejected =>
      'No se ha podido deshacer: la botella sigue marcada como bebida';

  @override
  String get cellarDeleteFailed =>
      'La eliminación aún no ha terminado: se completará lo antes posible';

  @override
  String get duplicateFull =>
      'Este vino ya tiene 99 botellas: no se pueden añadir más.';

  @override
  String get recordSheetTitle => 'Valoración y notas';

  @override
  String get recordRatingLabel => 'Valoración';

  @override
  String ratingStar(int n) {
    return 'Valoración $n de 5';
  }

  @override
  String get recordNotesLabel => 'Notas';

  @override
  String get recordNotesTooLong => 'Máximo 1000 caracteres';

  @override
  String recordDateLabel(String date) {
    return 'Fecha: $date';
  }

  @override
  String get recordDateInvalid =>
      'La fecha no puede ser futura ni anterior a la añada';

  @override
  String get recordConditionTitle => '¿Cómo estaba?';

  @override
  String get conditionTooYoung => 'Aún demasiado joven';

  @override
  String get conditionJustRight => 'En su punto';

  @override
  String get conditionPastPeak => 'Ya en declive';

  @override
  String get recordNoCondition => 'Sin respuesta';

  @override
  String get producerLabel => 'Productor (opcional)';

  @override
  String get producerTooLong => 'Máximo 120 caracteres';

  @override
  String producerAddNew(String name) {
    return 'Añadir «$name» como nuevo productor';
  }

  @override
  String get wineTypeLabel => 'Tipo';

  @override
  String get typeRedLight => 'Tinto ligero';

  @override
  String get typeRedStructured => 'Tinto con cuerpo';

  @override
  String get typeWhite => 'Blanco';

  @override
  String get typeRose => 'Rosado';

  @override
  String get typeSparklingClassic => 'Espumoso método tradicional';

  @override
  String get typeSparklingTank => 'Espumoso método Charmat';

  @override
  String get typeSweet => 'Dulce';

  @override
  String get typeFortified => 'Generoso';

  @override
  String get suggestionFromCellar => 'En tu bodega';

  @override
  String get suggestionsLabel => 'Sugerencias';

  @override
  String get duplicateTitle => 'Ya está en la bodega';

  @override
  String duplicateBody(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count botellas',
      one: '1 botella',
      zero: 'ninguna botella',
    );
    return '$name ya está, con $_temp0. ¿Añadirle las botellas nuevas?';
  }

  @override
  String duplicateAdd(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Añadir $count botellas',
      one: 'Añadir 1 botella',
    );
    return '$_temp0';
  }

  @override
  String get duplicateBanner => 'Posible duplicado';

  @override
  String get duplicateMerge => 'Fusionar';

  @override
  String get duplicateDeleteHint => 'Elimina esta entrada si es un duplicado';

  @override
  String get mergeTitle => '¿Fusionar las dos entradas?';

  @override
  String get mergeBody =>
      'Las botellas de esta entrada pasan a la más antigua y después esta entrada se elimina.';

  @override
  String get editWineTitle => 'Editar vino';

  @override
  String get editDuplicate =>
      'Ya existe otro vino con el mismo nombre, productor y añada';

  @override
  String deleteWineTitle(String name) {
    return '¿Eliminar $name?';
  }

  @override
  String get deleteWineBody =>
      'Se eliminan el vino y todos sus consumos. No se puede deshacer.';

  @override
  String get historyTitle => 'Historial';

  @override
  String get historyEmpty => 'Aquí encontrarás las botellas que has bebido';

  @override
  String get historyLoadFailed => 'No se ha podido cargar el historial';

  @override
  String drankOnLabel(String date) {
    return 'Bebida el $date';
  }

  @override
  String get addChoiceTitle => 'Añadir un vino';

  @override
  String get addChoicePhoto => 'Hacer una foto';

  @override
  String get addChoiceImport => 'Importar una foto';

  @override
  String get addChoiceWrite => 'Escribir';

  @override
  String get labelReading => 'Leyendo la etiqueta…';

  @override
  String get labelRecognized => 'He reconocido:';

  @override
  String get labelCorrect => 'Corregir';

  @override
  String get labelConfirm => 'Confirmar';

  @override
  String get labelUnreadable => 'No consigo leer la etiqueta';

  @override
  String get labelWriteByHand => 'Escribir a mano';

  @override
  String get labelNotFound => 'No he encontrado el vino: revisa los datos';

  @override
  String get labelCameraDenied =>
      'Para leer la etiqueta necesito acceso a la cámara';

  @override
  String get labelPhotosDenied =>
      'Para leer la etiqueta necesito acceso a las fotos';

  @override
  String get labelOpenSettings => 'Abrir ajustes';

  @override
  String get labelCameraUnavailable => 'Cámara no disponible';

  @override
  String get labelBarcodeNotFound =>
      'He leído el código de barras, pero no encuentro el vino';

  @override
  String get labelBarcodeFrontHint => 'Haz una foto de la etiqueta frontal';

  @override
  String get labelSharedNotAllowed => 'No puedes añadir vinos a esta bodega';

  @override
  String get labelSharedFirstOnly => 'Solo he usado la primera foto';

  @override
  String get labelSharedExpired =>
      'No se ha podido leer la foto compartida: compártela de nuevo';

  @override
  String get labelReplaceTitle =>
      'Tienes un vino sin guardar. ¿Leer la nueva foto?';

  @override
  String get labelReplaceRead => 'Leer la nueva foto';

  @override
  String get labelReplaceKeep => 'Seguir con el abierto';

  @override
  String get labelWineAdded => 'Vino añadido a la bodega';

  @override
  String get onboardingPage1Title => 'Tu bodega en el bolsillo';

  @override
  String get onboardingPage1Body =>
      'Añade tus botellas escribiéndolas o con una foto de la etiqueta, incluso sin red.';

  @override
  String get onboardingPage2Title => 'En el momento justo';

  @override
  String get onboardingPage2Body =>
      'Vinoozy estima cuándo está cada vino en su mejor momento y te dice cuáles abrir primero.';

  @override
  String get onboardingPage3Title => 'Juntos';

  @override
  String get onboardingPage3Body =>
      'Comparte tu bodega con hasta dos personas y guarda el historial de cada botella que bebes.';

  @override
  String get onboardingSkip => 'Omitir';

  @override
  String get onboardingNext => 'Siguiente';

  @override
  String get onboardingStart => 'Empezar';

  @override
  String onboardingPageOf(int page) {
    return 'Página $page de 3';
  }

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profilePhoto => 'Foto de perfil';

  @override
  String get profileSignOut => 'Cerrar sesión';

  @override
  String get profileDeleteAccount => 'Eliminar cuenta';

  @override
  String get profilePrivacy => 'Política de privacidad';

  @override
  String get profilePrivacyBody =>
      'Puedes leer la política de privacidad en esta dirección:';

  @override
  String get profileOpenLink => 'Abrir en el navegador';

  @override
  String get profileOpenLinkFailed =>
      'No se ha podido abrir la página. Puedes copiar el enlace y abrirlo en tu navegador.';

  @override
  String get profileCopyLink => 'Copiar enlace';

  @override
  String get profileLinkCopied => 'Enlace copiado';

  @override
  String get close => 'Cerrar';

  @override
  String get signOutConfirmTitle => '¿Quieres cerrar sesión?';

  @override
  String signOutPendingWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Tienes $count cambios aún sin guardar. Si cierras sesión y entra otra cuenta, se perderán.',
      one: 'Tienes 1 cambio aún sin guardar. Si cierras sesión y entra otra cuenta, se perderá.',
    );
    return '$_temp0';
  }

  @override
  String get signOutStayAndSync => 'Quedarme y sincronizar';

  @override
  String get signOutAnyway => 'Cerrar sesión igualmente';

  @override
  String get syncAllSaved => 'Todo guardado';

  @override
  String syncStillPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Quedan $count cambios por guardar: comprueba la red',
      one: 'Queda 1 cambio por guardar: comprueba la red',
    );
    return '$_temp0';
  }

  @override
  String get signOutFailed =>
      'No se ha podido cerrar sesión. Inténtalo de nuevo';

  @override
  String get signInAccountDeleted => 'Cuenta eliminada';

  @override
  String get deleteAccountIntro => 'Se elimina para siempre:';

  @override
  String get deleteAccountItemCellar =>
      'Tu bodega, con sus vinos y su Historial';

  @override
  String get deleteAccountItemShares =>
      'Los accesos que has compartido: las personas invitadas pierden el acceso';

  @override
  String get deleteAccountItemMemberships =>
      'Tu participación en bodegas de otras personas: tus consumos se quedan allí sin tu nombre';

  @override
  String get deleteAccountItemProfile => 'Tu perfil';

  @override
  String deleteAccountPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Tienes $count cambios aún sin guardar: se guardarán y después se eliminarán con lo demás',
      one: 'Tienes 1 cambio aún sin guardar: se guardará y después se eliminará con lo demás',
    );
    return '$_temp0';
  }

  @override
  String get deleteAccountConfirmWord => 'ELIMINAR';

  @override
  String deleteAccountTypeWord(String word) {
    return 'Escribe $word para confirmar';
  }

  @override
  String get deleteAccountReauthHint =>
      'Después volverás a iniciar sesión con Google para confirmar que eres tú.';

  @override
  String get deleteAccountForever => 'Eliminar para siempre';

  @override
  String get deleteAccountNeedsNetwork =>
      'Conéctate a Internet para eliminar la cuenta';

  @override
  String get deleteAccountSameAccount =>
      'Para eliminarla hay que iniciar sesión con la misma cuenta';

  @override
  String get deletionTitle => 'Eliminando la cuenta';

  @override
  String get deletionStepPreparePhone => 'Guardando los cambios pendientes';

  @override
  String get deletionStepMarkStarted => 'Iniciando la eliminación';

  @override
  String get deletionStepLeaveOtherCellars =>
      'Saliendo de las bodegas de otras personas';

  @override
  String get deletionStepCloseOwnInvitations =>
      'Cerrando tus accesos compartidos';

  @override
  String get deletionStepDeleteWinesAndRecords =>
      'Eliminando vinos e Historial';

  @override
  String get deletionStepDeleteCellar => 'Eliminando la bodega';

  @override
  String get deletionStepDeleteProfileAndUser =>
      'Eliminando el perfil y la cuenta';

  @override
  String get deletionStepCleanUpPhone => 'Limpiando este teléfono';

  @override
  String deletionStepAnnounce(int step, String label) {
    return 'Paso $step de 8: $label';
  }

  @override
  String deletionDeletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vinos y consumos eliminados',
      one: '1 vino o consumo eliminado',
    );
    return '$_temp0';
  }

  @override
  String get deletionResumeHint =>
      'La eliminación de esta cuenta no ha terminado. Vuelve a iniciar sesión con Google para completarla.';

  @override
  String get deletionContinue => 'Continuar';

  @override
  String get deletionOffline =>
      'Conéctate a Internet para completar la eliminación';

  @override
  String get deletionPendingWrites =>
      'No consigo guardar los cambios pendientes. Inténtalo de nuevo';

  @override
  String get deletionFailed =>
      'No se ha podido completar la eliminación. Inténtalo de nuevo';

  @override
  String get uxCountryLabel => 'País';

  @override
  String get uxCountryOther => 'Otro país…';

  @override
  String get uxCountryNone => 'Ningún país';

  @override
  String get uxAllCountriesTitle => 'Todos los países y territorios';

  @override
  String get uxAllCountriesSearch => 'Buscar un país';

  @override
  String get uxAllCountriesRare => 'Raros para el vino';

  @override
  String get uxAllCountriesAll => 'Todos, de la A a la Z';

  @override
  String get uxAllCountriesNone => 'Ningún país encontrado';

  @override
  String get uxRegionLabel => 'Región';

  @override
  String uxRegionOf(String country) {
    return 'Región · $country';
  }

  @override
  String get uxRegionOther => 'Otra región';

  @override
  String get uxRegionFieldLabel => 'Escribe la región';

  @override
  String get uxRegionTooLong => 'Máximo 120 caracteres';

  @override
  String get uxDrinkAction => 'Me he bebido una';

  @override
  String uxDrinkActionTooltip(String name) {
    return 'Me he bebido una botella de $name';
  }

  @override
  String get uxDrinkActionDetail => 'Me he bebido una botella';

  @override
  String get uxDrinkSheetLabel => 'Confirmar el consumo';

  @override
  String get uxDrinkSheetBottles => 'Botellas';

  @override
  String uxDrinkSheetBottlesChange(int before, int after) {
    return 'Botellas: de $before a $after';
  }

  @override
  String get uxDrinkSheetRating => '¿Cómo estaba? (opcional)';

  @override
  String uxDrinkSheetStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count estrellas de 5',
      one: '1 estrella de 5',
    );
    return '$_temp0';
  }

  @override
  String get uxDrinkSheetConfirm => 'Sí, me la he bebido';

  @override
  String get uxRemoveBottle => 'Quitar una botella sin registrar consumo';

  @override
  String get uxRemoveBottleTitle => '¿Quitar una botella?';

  @override
  String uxRemoveBottleBody(String name) {
    return 'Se quita una botella de $name sin registrar un consumo.';
  }

  @override
  String get uxRemoveBottleConfirm => 'Quitar';

  @override
  String get uxIdealTitle => 'Momento ideal';

  @override
  String uxIdealUntil(String year) {
    return 'Recomendado hasta $year';
  }

  @override
  String uxIdealUntilPast(String year) {
    return 'Recomendado hasta $year: ya ha pasado';
  }

  @override
  String uxIdealBest(String start, String end) {
    return 'En su mejor momento de $start a $end';
  }

  @override
  String uxIdealBar(String start, String end) {
    return 'Ventana de consumo de $start a $end';
  }

  @override
  String get uxIdealDisclaimer =>
      '⚠︎ Orientativo: es una estimación basada en el tipo, la denominación y la añada. La conservación y cada botella pueden cambiarla.';

  @override
  String get uxIdealUnavailableHint =>
      'Indica la añada y el tipo para obtener una estimación.';

  @override
  String uxDashboardDrinkNow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count para beber ahora',
      one: '1 para beber ahora',
    );
    return '$_temp0';
  }

  @override
  String get uxFamilyRed => 'Tinto';

  @override
  String get uxFamilyWhite => 'Blanco';

  @override
  String get uxFamilyRose => 'Rosado';

  @override
  String get uxFamilySparkling => 'Espumoso';

  @override
  String get uxFamilySweet => 'Dulce';

  @override
  String get labelBackTitle => 'Ahora la contraetiqueta';

  @override
  String get labelBackHint =>
      'En la contraetiqueta suelen estar el código de barras, el productor y la añada: ayudan a encontrar el vino.';

  @override
  String get labelBackTake => 'Fotografiar contraetiqueta';

  @override
  String get labelBackGallery => 'Elegir de la galería';

  @override
  String get labelBackSkip => 'Omitir';

  @override
  String get labelStepFront => 'Frontal';

  @override
  String get labelStepBack => 'Contraetiqueta';

  @override
  String get labelStepBarcode => 'Código de barras';

  @override
  String get labelStepDatabase => 'Base de vinos en el teléfono';

  @override
  String get labelStepPending => 'En espera';

  @override
  String get labelStepRunning => 'En curso…';

  @override
  String get labelStepDone => 'Hecho';

  @override
  String get labelStepSkipped => 'Omitido';

  @override
  String get labelStepFailed => 'Ilegible';

  @override
  String labelStepStatus(String step, String status) {
    return '$step: $status';
  }

  @override
  String get labelOnPhoneNote =>
      'Todo ocurre en el teléfono: las fotos no se envían a nadie.';

  @override
  String get labelBackUnreadable => 'Contraetiqueta ilegible';

  @override
  String get labelSourceOffline => 'De la base del teléfono · sin conexión';

  @override
  String get labelSourceCatalog => 'Del catálogo';

  @override
  String get labelSourceOnline => 'De Open Food Facts · en línea';

  @override
  String get labelNotThis => 'No es este';

  @override
  String get labelOffAttribution => 'Datos de Open Food Facts, licencia ODbL';

  @override
  String get labelCandidatesTitle => '¿Cuál de estos?';

  @override
  String labelCandidatesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vinos parecidos',
      one: '1 vino parecido',
    );
    return '$_temp0';
  }

  @override
  String get labelCandidatesNone => 'Ninguno de estos';

  @override
  String get labelChipOffline => 'sin conexión';

  @override
  String get labelChipOnline => 'en línea';

  @override
  String get labelChipCatalog => 'catálogo';

  @override
  String get labelNoProducer => 'productor no indicado';

  @override
  String get labelNoMatch => 'He leído la etiqueta, pero no reconozco el vino';

  @override
  String get labelReadText => 'Texto leído';

  @override
  String get labelSearchOnline => 'Buscar en línea';

  @override
  String get labelOpenLens => 'Abrir en Google Lens';

  @override
  String get labelLensLastResort =>
      'Google Lens es el último recurso: la foto solo pasa a la app de Google si lo confirmas.';

  @override
  String get labelLensTitle => '¿Abrir en Google Lens?';

  @override
  String get labelLensBody =>
      'La foto de la etiqueta frontal pasará a la app de Google de tu teléfono, o a la app que elijas, que puede conservar una copia según sus propias normas. Vinoozy no recibe los resultados: vuelve aquí para elegir o escribir el vino.';

  @override
  String get labelLensConfirm => 'Abrir Google Lens';

  @override
  String get labelLensFailed =>
      'No consigo abrir Google Lens ni el menú de compartir';

  @override
  String get onlineSearchTitle => 'Buscar en línea';

  @override
  String get onlineSearchSubtitle => 'Open Food Facts · solo vinos';

  @override
  String get onlineSearchField => 'Palabras para buscar';

  @override
  String get onlineSearchHint => 'Puedes cambiar las palabras antes de buscar.';

  @override
  String get onlineSearchEmptyField => 'Escribe al menos una palabra';

  @override
  String get onlineSearchButton => 'Buscar';

  @override
  String get onlineSearchLoading => 'Buscando…';

  @override
  String onlineSearchResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count resultados',
      one: '1 resultado',
    );
    return '$_temp0';
  }

  @override
  String get onlineSearchEmpty =>
      'Ningún vino encontrado: prueba con otras palabras o con «Escribir a mano».';

  @override
  String get onlineSearchOffline =>
      'Sin red: solo busco en la base del teléfono.';

  @override
  String get onlineSearchRateLimited =>
      'La búsqueda en línea no está disponible ahora, inténtalo de nuevo en unos minutos.';

  @override
  String get onlineSearchUnavailable =>
      'La búsqueda en línea no está activa en esta versión de la app: solo busco en la base del teléfono.';

  @override
  String get aboutTitle => 'Acerca de';

  @override
  String aboutVersion(String version) {
    return 'Versión $version';
  }

  @override
  String get aboutDbTitle => 'Base de vinos';

  @override
  String aboutDbCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vinos',
      one: '1 vino',
    );
    return '$_temp0';
  }

  @override
  String aboutDbDate(String date) {
    return 'Exportación de Open Food Facts del $date';
  }

  @override
  String get aboutDbSample =>
      'Base de ejemplo: unos pocos vinos de prueba escritos a mano, no datos de Open Food Facts.';

  @override
  String get aboutDbLoading => 'Abriendo la base de vinos…';

  @override
  String get aboutDbUnavailable =>
      'La base de vinos no está disponible en esta versión';

  @override
  String aboutDbSource(String url) {
    return 'La base derivada y la herramienta que la genera están en el repositorio público: $url';
  }

  @override
  String get aboutLicenseTitle => 'Licencias';

  @override
  String get aboutLicense =>
      'Contiene información de Open Food Facts, disponible bajo la Open Database License (ODbL). Los contenidos individuales están bajo la Database Contents License (DbCL).';

  @override
  String get aboutPrivacyTitle => 'Fotos de etiquetas';

  @override
  String get aboutPrivacy =>
      'Las fotos de las etiquetas se leen en el teléfono y se borran al salir del resultado. Solo salen del teléfono si tocas «Abrir en Google Lens» y lo confirmas.';

  @override
  String get aboutAppellationsTitle => 'Denominaciones';

  @override
  String get aboutAppellationsSource =>
      'Denominaciones: registro eAmbrosia (UE) y registros nacionales oficiales.';

  @override
  String get aboutAppellationsSample =>
      'Tabla de ejemplo: un extracto de los registros escrito a mano, hasta que se descarguen los registros reales.';

  @override
  String get denominationLabel => 'Denominación';

  @override
  String get denominationTooLong => 'Máximo 120 caracteres';

  @override
  String get autofillFilledNotice =>
      'Rellenado a partir de la etiqueta: revisa y guarda';

  @override
  String get autofillPastedNotice =>
      'Rellenado a partir del texto: revisa y guarda';

  @override
  String get autofillFromText => '✦ del texto';

  @override
  String get autofillFromTextSemantics => 'rellenado a partir de la etiqueta';

  @override
  String get autofillClear => 'Vaciar';

  @override
  String get autofillLens => 'Lens';

  @override
  String get autofillClearTitle => '¿Vaciar el formulario?';

  @override
  String get autofillClearBody =>
      'También has escrito en algunos campos. «Vaciar» borra nombre, productor, denominación, añada, tipo, país, región y nivel. La cantidad se mantiene.';

  @override
  String get autofillClearConfirm => 'Vaciar';

  @override
  String get autofillCleared => 'Formulario vaciado';

  @override
  String get autofillPasteTitle => '¿Tienes el texto de Google Lens?';

  @override
  String get autofillPasteHint =>
      'En Lens, selecciona el texto de la etiqueta y toca «Copiar»; después vuelve aquí.';

  @override
  String get autofillPaste => 'Pegar desde Lens';

  @override
  String get autofillOpenLens => 'Desde Google Lens';

  @override
  String get autofillOpenLensSemantics => 'abre Google Lens';

  @override
  String get autofillClipboardEmpty => 'No hay texto en el portapapeles';

  @override
  String get autofillNoNewFields =>
      'No he encontrado datos que añadir en el texto';

  @override
  String get autofillFromLens => 'Formulario rellenado con el texto de Lens';

  @override
  String get autofillShareEmpty => 'Ningún texto recibido';

  @override
  String get autofillShareUseTitle => '¿Usar el texto para los campos vacíos?';

  @override
  String get autofillShareUse => 'Usar';

  @override
  String get autofillShareIgnore => 'Ignorar';

  @override
  String get addChoiceLens => 'Desde Google Lens';

  @override
  String get addChoicePhotoHint =>
      'Frontal y contraetiqueta: Vinoozy lee la etiqueta.';

  @override
  String get addChoiceLensHint =>
      'Abre Lens: encuadra, selecciona el texto y toca Compartir → Vinoozy.';

  @override
  String get addChoiceImportHint => 'Una foto de la etiqueta que ya tienes.';

  @override
  String get addChoiceWriteHint => 'Formulario vacío, con «Pegar desde Lens».';

  @override
  String get lensInstructionsTitle =>
      'Google Lens no se puede abrir desde aquí';

  @override
  String get lensInstructionsStep1 => 'Abre Google Lens y encuadra la etiqueta';

  @override
  String get lensInstructionsStep2 => 'Selecciona el texto de la etiqueta';

  @override
  String get lensInstructionsStep3 => 'Toca Compartir → Vinoozy';

  @override
  String get lensInstructionsOk => 'Entendido';

  @override
  String get levelLabel => 'Nivel';

  @override
  String get levelEveryday => 'Diario (económico)';

  @override
  String get levelGood => 'Bueno';

  @override
  String get levelAging => 'De guarda';

  @override
  String get levelNone => 'Ninguno';

  @override
  String get levelEverydayShort => 'beber joven';

  @override
  String get levelGoodShort => 'estimación normal';

  @override
  String get levelAgingShort => 'dura más';

  @override
  String get levelSuggested => 'sugerido';

  @override
  String levelSuggestedReason(String qualifier) {
    return 'Sugerido porque el nombre contiene «$qualifier»: se guarda así si no lo cambias. Elige otro o toca «Ninguno».';
  }

  @override
  String levelSuggestedSemantics(String qualifier) {
    return 'sugerido, porque el nombre contiene $qualifier';
  }

  @override
  String levelOptionSemantics(String option, int index, int count) {
    return 'Nivel, $option, $index de $count';
  }

  @override
  String get levelWhatChanges => 'Qué cambia';

  @override
  String get levelEverydayExamples =>
      'La ventana se acorta. Ej.: vino de la casa, Lambrusco, Prosecco básico, Bardolino, Vinho Verde.';

  @override
  String get levelGoodExamples =>
      'La estimación normal, y el valor si no eliges nada. Ej.: Chianti Classico, Barbera d\'Asti Superiore, Rioja Crianza, Côtes du Rhône.';

  @override
  String get levelAgingExamples =>
      'La ventana se alarga. Ej.: Barolo, Brunello, Amarone, Bordeaux Grand Cru, Rioja Gran Reserva, Oporto Vintage.';

  @override
  String levelPreviewBefore(String start, String end) {
    return 'Antes $start – $end';
  }

  @override
  String levelPreviewWith(String level, String start, String end) {
    return 'Con «$level» $start – $end';
  }

  @override
  String levelPreviewNow(String start, String end) {
    return 'Listo $start – hasta $end';
  }

  @override
  String levelDetail(String level) {
    return 'Nivel: $level';
  }

  @override
  String get overrideCorrect => 'Corregir';

  @override
  String get overrideRestore => 'Restaurar estimación';

  @override
  String get overrideCorrectedByYou => 'corregido por ti';

  @override
  String overrideAppEstimate(String year) {
    return 'Estimación de la app: hasta $year';
  }

  @override
  String get overrideSheetTitle => 'Recomendado hasta';

  @override
  String overrideSheetHint(String start) {
    return 'Elige el año. No puede ser anterior a «Listo desde $start».';
  }

  @override
  String overridePeakNotice(String peak) {
    return 'Si eliges un año anterior a $peak (en su mejor momento), «en su mejor momento» pasa también a ese año.';
  }

  @override
  String get overrideMore => 'más…';

  @override
  String get overrideSave => 'Guardar corrección';

  @override
  String overrideRestoreTitle(String year) {
    return '¿Volver a la estimación de la app (hasta $year)?';
  }

  @override
  String get overrideRestoreConfirm => 'Restaurar';

  @override
  String get overrideSaved => 'Corrección guardada';

  @override
  String get overrideRestored => 'Estimación restaurada';

  @override
  String get estimateSourceCorrectedByYou => 'corregida por ti';

  @override
  String estimateFromDenomination(String name) {
    return 'Estimación por la denominación $name';
  }

  @override
  String estimateFromDenominationQualifier(String name, String qualifier) {
    return 'Estimación por la denominación $name, $qualifier';
  }

  @override
  String estimateFromGrape(String name) {
    return 'Estimación por la variedad $name';
  }

  @override
  String get estimateFromType => 'Estimación por el tipo de vino';

  @override
  String get autofillReading => 'Leyendo el texto…';

  @override
  String get guideChip => 'Revisión guiada';

  @override
  String guideProgress(int n, int total) {
    return 'Pregunta $n de $total';
  }

  @override
  String get guideClose => 'Cerrar';

  @override
  String get guideIsDenomination => '¿es la denominación?';

  @override
  String get guideIsProducer => '¿es el productor?';

  @override
  String get guideIsName => '¿es el nombre del vino?';

  @override
  String get guideIsVintage => 'Añada';

  @override
  String guideAskDenomination(String value) {
    return '¿Es $value la denominación?';
  }

  @override
  String guideAskProducer(String value) {
    return '¿Es $value el productor?';
  }

  @override
  String guideAskName(String value) {
    return '¿Es $value el nombre del vino?';
  }

  @override
  String get guideAskVintage => '¿Cuál es la añada?';

  @override
  String guideQuestionSemantics(int n, int total, String question) {
    return 'Pregunta $n de $total: $question';
  }

  @override
  String get guideNoProposal => 'No lo he encontrado en el texto';

  @override
  String get guideYes => 'Sí';

  @override
  String get guideNo => 'No, otra';

  @override
  String get guideEdit => 'Editar';

  @override
  String get guideSkip => 'Omitir';

  @override
  String get guideConfirm => 'Confirmar';

  @override
  String get guideCancel => 'Cancelar';

  @override
  String guideRejected(String value) {
    return '«$value» no: aquí tienes la siguiente';
  }

  @override
  String get guideNoMore =>
      'No hay más sugerencias: créala tú u omite el campo';

  @override
  String guideProposalAnnounce(String value) {
    return 'Sugerencia: $value';
  }

  @override
  String get guideComposeLabel => 'O créala tocando palabras del texto';

  @override
  String get guideComposePreview => 'Vista previa';

  @override
  String get guideComposeEmpty => 'Toca una o varias palabras';

  @override
  String get guideComposeLimit => 'Hasta 8 palabras y 80 caracteres';

  @override
  String guideTableMatchSemantics(String name) {
    return 'coincide con $name';
  }

  @override
  String guideLine(int n, int total) {
    return 'Línea $n de $total';
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
      'denomination': 'la denominación',
      'producer': 'el productor',
      'other': 'el nombre',
    });
    return '$word, usada para $_temp0';
  }

  @override
  String guideUsedMark(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'denominación',
      'producer': 'productor',
      'other': 'nombre',
    });
    return '$_temp0';
  }

  @override
  String guideOtherYears(String years) {
    return 'También en el texto: $years';
  }

  @override
  String get guideWheelFromText => 'año encontrado en el texto';

  @override
  String get guideWheelTypeYear => 'Escribe el año';

  @override
  String guideWheelConfirm(String year) {
    return 'Confirmar $year';
  }

  @override
  String get guideNoVintage => 'Sin añada';

  @override
  String guideSkippedNotice(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'Denominación omitida',
      'producer': 'Productor omitido',
      'vintage': 'Añada omitida',
      'other': 'Nombre omitido',
    });
    return '$_temp0: escribe el dato o retoma la guía';
  }

  @override
  String guideSkippedMany(int count) {
    return '$count campos omitidos: escríbelos o retoma la guía';
  }

  @override
  String get guideInvalidValue =>
      'Este texto contiene caracteres que no se pueden guardar';

  @override
  String get brandStudio => 'Bottazzini Softworks';

  @override
  String get suggestedMark => '✦ sugerido';

  @override
  String suggestedSemantics(String field, String value) {
    return '$field, $value, sugerido';
  }

  @override
  String get restoreSuggestion => 'Restaurar sugerencia';

  @override
  String get restoreSuggestionDone => 'Sugerencia restaurada';

  @override
  String get styleLabel => 'Estilo';

  @override
  String styleGroupSemantics(String value, int index, int count) {
    return 'Estilo, $value, $index de $count';
  }

  @override
  String get styleRedFresh => 'Fresco';

  @override
  String get styleRedMedium => 'Medio';

  @override
  String get styleRedAge => 'De guarda';

  @override
  String get styleRedLong => 'Larga guarda';

  @override
  String get styleWhiteFresh => 'Fresco';

  @override
  String get styleWhiteMedium => 'Medio';

  @override
  String get styleWhiteAge => 'De guarda';

  @override
  String get styleRoseFresh => 'Fresco';

  @override
  String get styleClassicFresh => 'Fresco';

  @override
  String get styleClassicAge => 'De guarda';

  @override
  String get styleTankFresh => 'Fresco';

  @override
  String get styleLambrusco => 'Lambrusco';

  @override
  String get styleSweetAromatic => 'Aromático';

  @override
  String get styleSweetPassito => 'Uvas pasificadas';

  @override
  String get styleSweetBotrytis => 'Botritizado';

  @override
  String get stylePortVintage => 'Oporto Vintage';

  @override
  String get stylePortLbv => 'Oporto LBV/Ruby';

  @override
  String get stylePortTawny => 'Oporto Tawny/Colheita';

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
  String get styleFortifiedOther => 'Otro';

  @override
  String get profileNameRFresh => 'Tinto afrutado';

  @override
  String get profileNameRMedium => 'Tinto de cuerpo medio';

  @override
  String get profileNameRAge => 'Tinto de guarda';

  @override
  String get profileNameRLong => 'Tinto de larga guarda';

  @override
  String get profileNameWFresh => 'Blanco fresco y aromático';

  @override
  String get profileNameWMedium => 'Blanco de cuerpo medio';

  @override
  String get profileNameWAge => 'Blanco de guarda';

  @override
  String get profileNameRoseFresh => 'Rosado fresco';

  @override
  String get profileNameSpTank => 'Espumoso Charmat fresco';

  @override
  String get profileNameLamFresh => 'Lambrusco fresco';

  @override
  String get profileNameSpClassic => 'Método tradicional fresco';

  @override
  String get profileNameSpClassicAge => 'Método tradicional de guarda';

  @override
  String get profileNameSwAromatic => 'Dulce aromático joven';

  @override
  String get profileNameSwPassito => 'Dulce de uvas pasificadas';

  @override
  String get profileNameSwBotrytis => 'Dulce botritizado';

  @override
  String get profileNamePortVintage => 'Oporto Vintage';

  @override
  String get profileNamePortLbv => 'Oporto LBV/Ruby';

  @override
  String get profileNamePortOx => 'Oporto Tawny/Colheita';

  @override
  String get profileNameShFino => 'Fino/Manzanilla';

  @override
  String get profileNameShAmont => 'Amontillado/Medium';

  @override
  String get profileNameShOloroso => 'Oloroso/Cream';

  @override
  String get profileNameShPx => 'Jerez Pedro Ximénez';

  @override
  String get profileNameFortUnknown => 'Generoso, estilo desconocido';

  @override
  String get profileNameUnknown => 'Estilo no identificado';

  @override
  String estimateFromProfile(String profile, String denomination) {
    return 'Estimación por el perfil $profile ($denomination)';
  }

  @override
  String estimateFromProfileType(String profile) {
    return 'Estimación por el perfil $profile, según el tipo';
  }

  @override
  String estimateFromProfileGrape(String profile, String grape) {
    return 'Estimación por el perfil $profile, según la variedad $grape';
  }

  @override
  String get estimateFromEntryDateDisgorgement =>
      'Según la fecha de alta: añade la fecha de degüelle para una estimación mejor';

  @override
  String get estimateFromEntryDateBottling =>
      'Según la fecha de alta: añade la fecha de embotellado para una estimación mejor';

  @override
  String get styleToConfirmBanner =>
      '⚠︎ Estilo por confirmar: la estimación es orientativa';

  @override
  String get chooseTypePrompt => 'Elige el tipo';

  @override
  String estimateUpdatedAnnouncement(String summary) {
    return 'Estimación actualizada: $summary';
  }

  @override
  String get agingStartDisgorgement => 'Degüelle';

  @override
  String get agingStartBottling => 'Embotellado';

  @override
  String get agingStartMonth => 'Mes';

  @override
  String get agingStartYear => 'Año';

  @override
  String get agingStartHint => 'Suele estar en la contraetiqueta.';

  @override
  String get agingStartIncomplete => 'Indica mes y año';

  @override
  String get agingStartFuture => 'La fecha no puede ser futura';

  @override
  String get agingStartBeforeVintage => 'No puede ser anterior a la añada';

  @override
  String get windowNoEnd => 'Listo, sin final estimado';

  @override
  String get windowNoEndShort => 'sin final estimado';

  @override
  String windowDrinkWithin(String date) {
    return 'hasta $date';
  }

  @override
  String get levelNoEffect => 'El nivel no cambia esta estimación';

  @override
  String get dashboardToConfirmTitle => 'Por confirmar';

  @override
  String dashboardToConfirmCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vinos',
      one: '1 vino',
    );
    return '$_temp0';
  }

  @override
  String aboutDbClassified(String percent) {
    return '$percent % de los vinos con tipo reconocido';
  }

  @override
  String get planTitle => 'Plan';

  @override
  String get planFree => 'Gratuito';

  @override
  String get planPlus => 'Plus';

  @override
  String get planPlusGift => 'Plus (regalo)';

  @override
  String get planDevUnlockAll => 'DEV · Plus de prueba';

  @override
  String get planDevSimulateFree => 'DEV · Plan gratuito simulado';

  @override
  String get planDevSimulateExpired => 'DEV · Plus caducado simulado';

  @override
  String get planDiscoverPlus => 'Descubre Plus';

  @override
  String get plusTitle => 'Vinoozy Plus';

  @override
  String get plusBenefitsTitle => 'Con Plus';

  @override
  String get plusBenefitNoAds => 'Sin anuncios';

  @override
  String get plusBenefitNoLimit => 'Sin límite de vinos en tu bodega';

  @override
  String get plusComingSoon => 'Plus llegará pronto';

  @override
  String get plusLoading => 'Consultando los precios en Google Play';

  @override
  String get plusStoreUnavailable =>
      'No se han podido consultar los precios en Google Play. Inténtalo más tarde.';

  @override
  String plusPriceMonthly(String price) {
    return '$price al mes';
  }

  @override
  String plusPriceAnnual(String price) {
    return '$price al año';
  }

  @override
  String get plusRenewal =>
      'La suscripción se renueva automáticamente al precio indicado hasta que la canceles en Google Play.';

  @override
  String get plusTerms =>
      'El pago se carga en tu cuenta de Google Play al confirmar la compra. Puedes cancelar en cualquier momento: Plus sigue activo hasta el final del periodo ya pagado. Cuando Plus termina, conservas todos tus vinos.';

  @override
  String get plusRestore => 'Restaurar compras';

  @override
  String get plusManage => 'Gestionar o cancelar la suscripción en Google Play';

  @override
  String get plusActive => 'Plus está activo en esta cuenta';

  @override
  String get plusActiveGift =>
      'Tienes Plus de regalo: sin cargos ni renovaciones.';

  @override
  String get plusPending =>
      'Pago pendiente: Plus se activará cuando Google Play lo confirme.';

  @override
  String get plusVerifying => 'Verificando la compra';

  @override
  String get plusVerified =>
      'Compra verificada: Plus se activará en unos segundos.';

  @override
  String get plusPurchaseFailed =>
      'La compra no se ha completado. Inténtalo de nuevo.';

  @override
  String get plusInvalidPurchase =>
      'Google Play no ha confirmado esta compra para Vinoozy.';

  @override
  String get plusOwnedByOther =>
      'Esta suscripción ya pertenece a otra cuenta de Vinoozy.';

  @override
  String get plusVerificationUnavailable =>
      'Ahora no se ha podido verificar la compra. Inténtalo más tarde: la suscripción sigue en Google Play.';

  @override
  String get capacityLimitTitle => 'Has alcanzado el límite del plan gratuito';

  @override
  String capacityLimitBody(int limit) {
    return 'El plan gratuito incluye hasta $limit vinos distintos en tu bodega. Siempre puedes editar, beber y añadir botellas a los vinos que ya tienes. Para añadir uno nuevo, termina o elimina un vino, o pásate a Plus.';
  }

  @override
  String capacityLimitBodyComingSoon(int limit) {
    return 'El plan gratuito incluye hasta $limit vinos distintos en tu bodega. Siempre puedes editar, beber y añadir botellas a los vinos que ya tienes. Para añadir uno nuevo, termina o elimina un vino. Plus llegará pronto.';
  }

  @override
  String get rejectedCapacityLimit =>
      'No sincronizado: supera el límite de vinos del plan gratuito. El cambio se queda en este teléfono.';

  @override
  String get rejectedCapacityConflict =>
      'No sincronizado: la bodega ha cambiado en otro dispositivo al mismo tiempo. El cambio se queda en este teléfono: inténtalo de nuevo.';

  @override
  String writeRejectedCapacityLimit(String name) {
    return '$name: no sincronizado, supera el límite del plan gratuito';
  }

  @override
  String writeRejectedCapacityConflict(String name) {
    return '$name: no sincronizado, la bodega ha cambiado en otro dispositivo';
  }

  @override
  String get freeIntroTitle => 'El plan gratuito';

  @override
  String freeIntroLimit(int limit) {
    return 'Puedes gestionar gratis hasta $limit vinos distintos.';
  }

  @override
  String get freeIntroAds =>
      'El uso ligero no tiene anuncios. Si superas el umbral mensual de uso del servicio, puede que veas anuncios ocasionales que ayudan a cubrir los costes de los servidores y la sincronización.';

  @override
  String get freeIntroNoAds => 'Sin anuncios en la versión de lanzamiento.';

  @override
  String get freeIntroPlus =>
      'Con Plus quitas los anuncios y el límite de la bodega.';

  @override
  String get noticeGotIt => 'Entendido';

  @override
  String get thresholdTitle =>
      'Los anuncios ayudan a que Vinoozy siga siendo gratis';

  @override
  String get thresholdBody =>
      'Has alcanzado el umbral mensual de uso sin anuncios. A partir de ahora puede que veas anuncios ocasionales: nos ayudan a cubrir los costes de los servidores y la sincronización para que Vinoozy siga siendo gratis.';

  @override
  String get thresholdReset =>
      'El recuento empieza de nuevo el mes que viene. Con Plus puedes usar la app sin anuncios y sin el límite de la bodega.';

  @override
  String thresholdNextReset(String date) {
    return 'Próximo reinicio: $date';
  }

  @override
  String get thresholdHowItWorks => 'Cómo funciona';

  @override
  String get thresholdHowItWorksBody =>
      'El umbral depende de una estimación de las sincronizaciones con la nube que hace esta cuenta durante el mes. El uso sin conexión, por sí solo, no genera nuevas operaciones en la nube. Los anuncios aparecen como máximo una vez al día, solo en el Panel, y nunca mientras guardas o exportas tus datos.';

  @override
  String get adLabel => 'Publicidad';

  @override
  String get devToolsTitle => 'Herramientas de desarrollo';

  @override
  String get devUnlockAll => 'Desbloquear todo — Plus de prueba';

  @override
  String get devSimulateFree => 'Simular plan gratuito';

  @override
  String get devSimulateExpired => 'Simular Plus caducado';

  @override
  String get devRestore => 'Restaurar estado normal';

  @override
  String get devNoOverride => 'Ninguna simulación activa';

  @override
  String get devApplied =>
      'Escenario aplicado también en el emulador de Firestore';

  @override
  String get devIncomplete =>
      'Simulación incompleta: el emulador de Firestore no ha confirmado el derecho de prueba. Las reglas del servidor no ven este escenario.';

  @override
  String get devNotice =>
      'Solo compilaciones de desarrollo con el emulador: sin pagos, tokens ni recibos.';
}
