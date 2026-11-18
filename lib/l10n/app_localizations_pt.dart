// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Vinoozy';

  @override
  String get signInTagline => 'A sua garrafeira, no momento certo';

  @override
  String get signInWithGoogle => 'Continuar com o Google';

  @override
  String get signInInProgress => 'A iniciar sessão';

  @override
  String get signInFailed => 'Falha ao iniciar sessão';

  @override
  String get signInNeedsNetwork =>
      'É necessária uma ligação para o primeiro início de sessão';

  @override
  String get signInSessionExpired =>
      'A sessão expirou: inicie sessão novamente';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get cancel => 'Cancelar';

  @override
  String blockedMessage(String email) {
    return 'Há alterações de $email ainda não guardadas na nuvem: inicie sessão com essa conta e ligue-se à rede';
  }

  @override
  String blockedSignInWith(String email) {
    return 'Iniciar sessão com $email';
  }

  @override
  String blockedDiscard(String email) {
    return 'Eliminar as alterações não guardadas de $email';
  }

  @override
  String get discardDialogTitle => 'Eliminar as alterações?';

  @override
  String discardDialogBody(int count, String email) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count vinhos de $email ainda não estão na nuvem e serão eliminados deste telemóvel.',
      one:
          '1 vinho de $email ainda não está na nuvem e será eliminado deste telemóvel.',
      zero:
          '$count vinhos de $email ainda não estão na nuvem e serão eliminados deste telemóvel.',
    );
    return '$_temp0';
  }

  @override
  String get discardConfirm => 'Eliminar';

  @override
  String get resetFailed => 'Não foi possível apagar os dados deste telemóvel';

  @override
  String get restartRequired => 'Reinicie a app para concluir';

  @override
  String get restartCloseApp => 'Fechar a app';

  @override
  String get startupFailed => 'Não foi possível iniciar a app';

  @override
  String get cellarTitle => 'Garrafeira';

  @override
  String get defaultCellarName => 'A minha garrafeira';

  @override
  String get cellarLoading => 'A preparar a garrafeira';

  @override
  String get cellarSetupFailed => 'Não foi possível preparar a garrafeira';

  @override
  String get cellarEmpty => 'A sua garrafeira está vazia';

  @override
  String get addWine => 'Adicionar';

  @override
  String get estimatePending => 'Estimativa a caminho';

  @override
  String get noVintage => 'Sem colheita';

  @override
  String bottleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count garrafas',
      one: '1 garrafa',
      zero: '$count garrafas',
    );
    return '$_temp0';
  }

  @override
  String get syncInProgress => 'A sincronizar';

  @override
  String get syncOffline => 'Offline - sincronização pendente';

  @override
  String writeRejected(String name) {
    return 'Alteração não permitida: $name';
  }

  @override
  String get saveFailed => 'Não foi possível guardar, tente novamente';

  @override
  String wineNotSaved(String name) {
    return 'O vinho $name não foi guardado na nuvem';
  }

  @override
  String get addAgain => 'Adicionar novamente';

  @override
  String get ignore => 'Ignorar';

  @override
  String get addWineTitle => 'Escrever';

  @override
  String get wineNameLabel => 'Vinho';

  @override
  String get vintageLabel => 'Colheita';

  @override
  String get quantityLabel => 'Quantidade';

  @override
  String get decreaseQuantity => 'Diminuir quantidade';

  @override
  String get increaseQuantity => 'Aumentar quantidade';

  @override
  String get save => 'Guardar';

  @override
  String get nameRequired => 'Escreva o nome do vinho';

  @override
  String get nameTooLong => 'Máximo de 120 carateres';

  @override
  String vintageRange(String year) {
    return 'Colheita entre 1900 e $year';
  }

  @override
  String get offAttribution => 'Dados do Open Food Facts (ODbL)';

  @override
  String get dashboardTitle => 'Painel';

  @override
  String dashboardTotalBottles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count garrafas na garrafeira',
      one: '1 garrafa na garrafeira',
      zero: '$count garrafas na garrafeira',
    );
    return '$_temp0';
  }

  @override
  String get dashboardSyncing => 'A sincronizar a garrafeira…';

  @override
  String get dashboardAddFirstWine => 'Adicionar o primeiro vinho';

  @override
  String get drinkSoonTitle => 'Beber em breve';

  @override
  String get drinkSoonEmpty => 'Nenhuma garrafa para beber em breve';

  @override
  String drinkSoonUntil(String year) {
    return 'até $year';
  }

  @override
  String drinkSoonSeeAll(int count) {
    return 'Ver todos ($count)';
  }

  @override
  String get statusChartTitle => 'Estado das garrafas';

  @override
  String get statusWaiting => 'a aguardar';

  @override
  String get statusReady => 'prontas';

  @override
  String get statusDrinkSoon => 'beber em breve';

  @override
  String get statusPastWindow => 'janela ultrapassada';

  @override
  String toEstimateNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count garrafas por estimar',
      one: '1 garrafa por estimar',
      zero: '$count garrafas por estimar',
    );
    return '$_temp0';
  }

  @override
  String chartBarValue(String label, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count garrafas',
      one: '1 garrafa',
      zero: '$count garrafas',
    );
    return '$label: $_temp0';
  }

  @override
  String chartDescription(String title, String values) {
    return '$title: $values';
  }

  @override
  String get openListHint => 'Abrir a lista';

  @override
  String get peakChartTitle => 'Ano do apogeu';

  @override
  String get peakPast => 'apogeu passado';

  @override
  String get peakBeyond => 'mais tarde';

  @override
  String get breakdownTypeTitle => 'Garrafas por tipo';

  @override
  String get breakdownRegionTitle => 'Garrafas por região';

  @override
  String get breakdownType => 'Tipo';

  @override
  String get breakdownRegion => 'Região';

  @override
  String get familyRed => 'tinto';

  @override
  String get familyWhite => 'branco';

  @override
  String get familyRose => 'rosé';

  @override
  String get familySparkling => 'espumante';

  @override
  String get familySweet => 'doce';

  @override
  String get breakdownUnspecified => 'não indicado';

  @override
  String get breakdownOtherRegions => 'outras';

  @override
  String get ok => 'OK';

  @override
  String get cellarMenu => 'Menu da garrafeira';

  @override
  String get sharingPeopleTitle => 'Pessoas';

  @override
  String get sharingInviteTitle => 'Convidar uma pessoa';

  @override
  String get sharingEmailLabel => 'Endereço de email Google';

  @override
  String get sharingPermissionRead => 'Só de leitura';

  @override
  String get sharingPermissionReadHint =>
      'Vê vinhos, estimativas, painel e consumos';

  @override
  String get sharingPermissionEdit => 'Pode editar';

  @override
  String get sharingPermissionEditHint =>
      'Também adiciona e altera vinhos e regista consumos';

  @override
  String get sharingRoleOwner => 'proprietário';

  @override
  String get sharingInviteButton => 'Convidar';

  @override
  String sharingPlacesUsed(int used, int max) {
    return '$used/$max pessoas';
  }

  @override
  String get sharingInvalidEmail => 'Introduza um email válido';

  @override
  String get sharingSelfInvite => 'Não se pode convidar a si próprio';

  @override
  String get sharingAlreadyInvited => 'Esta pessoa já foi convidada';

  @override
  String sharingLimitReached(int max) {
    return 'Atingiu o limite de $max pessoas';
  }

  @override
  String get sharingNotOwner => 'Não pode alterar a partilha desta garrafeira';

  @override
  String get sharingNotFound => 'Esta pessoa já não está na lista';

  @override
  String get sharingFailed => 'Não foi possível concluir, tente novamente';

  @override
  String get sharingInviteFailed =>
      'Não foi possível convidar. Tente novamente';

  @override
  String get sharingOfflineHint =>
      'É necessária uma ligação para gerir a partilha';

  @override
  String get sharingStatusInvited => 'convidada';

  @override
  String get sharingStatusActive => 'ativa';

  @override
  String get sharingStatusRevoked => 'revogada';

  @override
  String get sharingStatusLeft => 'saiu';

  @override
  String sharingMemberSemantics(String name, String permission, String status) {
    return '$name, $permission, $status';
  }

  @override
  String get sharingClosedSection => 'Acessos encerrados';

  @override
  String get sharingNobody => 'Ainda mais ninguém vê esta garrafeira';

  @override
  String sharingChangePermission(String name) {
    return 'Alterar a permissão de $name';
  }

  @override
  String get sharingRevoke => 'Revogar';

  @override
  String sharingRevokeTitle(String name) {
    return 'Revogar o acesso de $name?';
  }

  @override
  String sharingRevokeConfirmLabel(String name) {
    return 'Escreva $name para confirmar';
  }

  @override
  String get sharingRevokeDisabledHint => 'Fica ativo quando o nome coincidir';

  @override
  String get sharingReinvite => 'Convidar novamente';

  @override
  String get sharingDeleteForGood => 'Eliminar definitivamente';

  @override
  String sharingOwnedBy(String owner) {
    return 'Garrafeira de $owner';
  }

  @override
  String get sharingYourCellar => 'A sua garrafeira';

  @override
  String sharingYourPermission(String permission) {
    return 'A sua permissão: $permission';
  }

  @override
  String sharingSwitcherSemantics(String cellar, String permission) {
    return '$cellar, $permission. Toque para mudar de garrafeira';
  }

  @override
  String get sharingLeave => 'Sair desta garrafeira';

  @override
  String sharingLeaveTitle(String owner) {
    return 'Sair da garrafeira de $owner?';
  }

  @override
  String sharingLeaveBody(String owner) {
    return 'Deixará de a ver. $owner poderá enviar-lhe um novo convite.';
  }

  @override
  String get sharingLeaveConfirm => 'Sair';

  @override
  String sharingSharedNotice(String owner) {
    return '$owner partilhou a garrafeira consigo';
  }

  @override
  String sharingAccessLost(String owner) {
    return 'Já não tem acesso à garrafeira de $owner';
  }

  @override
  String sharingWritesLost(String owner) {
    return 'Algumas alterações à garrafeira de $owner não foram guardadas porque já não tem acesso';
  }

  @override
  String get sharingSomeone => 'alguém';

  @override
  String get sharingShareSubject => 'Convite para o Vinoozy';

  @override
  String sharingShareMessage(
    String owner,
    String cellar,
    String link,
    String email,
  ) {
    return '$owner enviou-lhe um convite para a garrafeira «$cellar» no Vinoozy. Instale a app a partir de $link e inicie sessão com a conta Google $email: use exatamente este endereço.';
  }

  @override
  String get cellarSearchHint => 'Pesquisar por nome ou produtor';

  @override
  String get cellarFilterStatus => 'Estado';

  @override
  String get cellarFilterType => 'Tipo';

  @override
  String get statusToEstimate => 'Por estimar';

  @override
  String get filterTypeUnspecified => 'Não indicado';

  @override
  String get cellarNoMatches => 'Nenhum vinho com estes filtros';

  @override
  String get cellarClearFilters => 'Limpar filtros';

  @override
  String get cellarArchiveTitle => 'Bebidos';

  @override
  String get cellarArchiveEmpty => 'Ainda não há vinhos terminados';

  @override
  String get cellarArchiveFailed =>
      'Não foi possível carregar os vinhos terminados';

  @override
  String get wineDrink => 'Bebida';

  @override
  String wineDrinkTooltip(String name) {
    return 'Marcar uma garrafa de $name como bebida';
  }

  @override
  String confidenceLabel(String level) {
    return 'Confiança: $level';
  }

  @override
  String get confidenceHigh => 'alta';

  @override
  String get confidenceMedium => 'média';

  @override
  String get confidenceLow => 'baixa';

  @override
  String get windowStartLabel => 'Início';

  @override
  String get windowPeakLabel => 'Apogeu';

  @override
  String get windowEndLabel => 'Fim';

  @override
  String estimateSourceLabel(String source) {
    return 'Fonte: $source';
  }

  @override
  String get estimateSourceCatalog => 'base de dados de vinhos';

  @override
  String get estimateSourceType => 'estimativa por tipo';

  @override
  String get estimateSourceCorrected =>
      'estimativa corrigida pelos seus consumos';

  @override
  String get estimateDisclaimer =>
      'Estimativa indicativa: depende também da forma como a garrafa foi conservada';

  @override
  String get estimateUnavailable => 'Estimativa indisponível';

  @override
  String get pairingsTitle => 'Harmonizações';

  @override
  String get pairingsGeneric => 'harmonizações genéricas para o tipo';

  @override
  String get pairingBraisedRedMeat => 'Carne vermelha estufada';

  @override
  String get pairingGrilledRedMeat => 'Carne vermelha grelhada';

  @override
  String get pairingGame => 'Caça';

  @override
  String get pairingRoastPoultry => 'Aves assadas';

  @override
  String get pairingPoultry => 'Aves';

  @override
  String get pairingPork => 'Porco';

  @override
  String get pairingCuredMeats => 'Charcutaria';

  @override
  String get pairingPastaMeatSauce => 'Massa com molho de carne';

  @override
  String get pairingMushroomsTruffle => 'Cogumelos e trufa';

  @override
  String get pairingAgedCheese => 'Queijos curados';

  @override
  String get pairingFreshCheese => 'Queijos frescos';

  @override
  String get pairingBlueCheese => 'Queijos azuis';

  @override
  String get pairingFish => 'Peixe';

  @override
  String get pairingSeafood => 'Marisco';

  @override
  String get pairingRawSeafood => 'Marisco cru';

  @override
  String get pairingFriedFood => 'Fritos';

  @override
  String get pairingVegetables => 'Legumes';

  @override
  String get pairingRisotto => 'Risotto';

  @override
  String get pairingPizza => 'Pizza';

  @override
  String get pairingAperitif => 'Aperitivo';

  @override
  String get pairingPastries => 'Pastelaria';

  @override
  String get pairingDryBiscuits => 'Biscoitos secos';

  @override
  String get pairingChocolate => 'Chocolate';

  @override
  String get pairingDriedFruit => 'Frutos secos';

  @override
  String get pairingSpicyDishes => 'Pratos condimentados';

  @override
  String get recentDrinksTitle => 'Últimos consumos';

  @override
  String get noDrinksYet => 'Ainda sem consumos';

  @override
  String get wineEdit => 'Editar';

  @override
  String get wineDelete => 'Eliminar';

  @override
  String get wineFinished => 'Terminado: sem garrafas';

  @override
  String get wineLoadFailed => 'Não foi possível abrir o vinho';

  @override
  String get wineNotFound => 'Este vinho já não existe';

  @override
  String drinkDone(String name) {
    return 'Marcada como bebida: $name';
  }

  @override
  String get drinkUndo => 'Anular';

  @override
  String get drinkAddNotes => 'Adicionar classificação e notas';

  @override
  String get nothingToUndo => 'Já não há nada para anular';

  @override
  String get cellarUndoRejected =>
      'Não foi possível anular: a garrafa continua marcada como bebida';

  @override
  String get cellarDeleteFailed =>
      'A eliminação ainda não está concluída: terminará assim que possível';

  @override
  String get duplicateFull =>
      'Este vinho já tem 99 garrafas: não é possível adicionar mais.';

  @override
  String get recordSheetTitle => 'Classificação e notas';

  @override
  String get recordRatingLabel => 'Classificação';

  @override
  String ratingStar(int n) {
    return 'Classificação $n de 5';
  }

  @override
  String get recordNotesLabel => 'Notas';

  @override
  String get recordNotesTooLong => 'No máximo 1000 carateres';

  @override
  String recordDateLabel(String date) {
    return 'Data: $date';
  }

  @override
  String get recordDateInvalid =>
      'A data não pode ser futura nem anterior à colheita';

  @override
  String get recordConditionTitle => 'Como estava?';

  @override
  String get conditionTooYoung => 'Ainda demasiado jovem';

  @override
  String get conditionJustRight => 'No ponto certo';

  @override
  String get conditionPastPeak => 'Já em declínio';

  @override
  String get recordNoCondition => 'Sem resposta';

  @override
  String get producerLabel => 'Produtor (opcional)';

  @override
  String get producerTooLong => 'No máximo 120 carateres';

  @override
  String producerAddNew(String name) {
    return 'Adicionar «$name» como novo produtor';
  }

  @override
  String get wineTypeLabel => 'Tipo';

  @override
  String get typeRedLight => 'Tinto ligeiro';

  @override
  String get typeRedStructured => 'Tinto encorpado';

  @override
  String get typeWhite => 'Branco';

  @override
  String get typeRose => 'Rosé';

  @override
  String get typeSparklingClassic => 'Espumante método clássico';

  @override
  String get typeSparklingTank => 'Espumante método Charmat';

  @override
  String get typeSweet => 'Doce';

  @override
  String get typeFortified => 'Fortificado';

  @override
  String get suggestionFromCellar => 'Na sua garrafeira';

  @override
  String get suggestionsLabel => 'Sugestões';

  @override
  String get duplicateTitle => 'Já está na garrafeira';

  @override
  String duplicateBody(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count garrafas',
      one: '1 garrafa',
      zero: 'nenhuma garrafa',
    );
    return '$name já lá está, com $_temp0. Adicionar-lhe as novas garrafas?';
  }

  @override
  String duplicateAdd(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Adicionar $count garrafas',
      one: 'Adicionar 1 garrafa',
      zero: 'Adicionar $count garrafas',
    );
    return '$_temp0';
  }

  @override
  String get duplicateBanner => 'Possível duplicado';

  @override
  String get duplicateMerge => 'Unir';

  @override
  String get duplicateDeleteHint => 'Elimine esta entrada se for um duplicado';

  @override
  String get mergeTitle => 'Unir as duas entradas?';

  @override
  String get mergeBody =>
      'As garrafas desta entrada passam para a mais antiga e, depois, esta entrada é eliminada.';

  @override
  String get editWineTitle => 'Editar vinho';

  @override
  String get editDuplicate =>
      'Já existe outro vinho com o mesmo nome, produtor e colheita';

  @override
  String deleteWineTitle(String name) {
    return 'Eliminar $name?';
  }

  @override
  String get deleteWineBody =>
      'O vinho e todos os seus consumos são eliminados. Não é possível anular.';

  @override
  String get historyTitle => 'Histórico';

  @override
  String get historyEmpty => 'Aqui encontrará as garrafas que bebeu';

  @override
  String get historyLoadFailed => 'Não foi possível carregar o histórico';

  @override
  String drankOnLabel(String date) {
    return 'Bebida a $date';
  }

  @override
  String get addChoiceTitle => 'Adicionar um vinho';

  @override
  String get addChoicePhoto => 'Tirar foto';

  @override
  String get addChoiceImport => 'Importar uma foto';

  @override
  String get addChoiceWrite => 'Escrever';

  @override
  String get labelReading => 'A ler o rótulo…';

  @override
  String get labelRecognized => 'Reconheci:';

  @override
  String get labelCorrect => 'Corrigir';

  @override
  String get labelConfirm => 'Confirmar';

  @override
  String get labelUnreadable => 'Não consigo ler o rótulo';

  @override
  String get labelWriteByHand => 'Escrever à mão';

  @override
  String get labelNotFound => 'Não encontrei o vinho: verifique os dados';

  @override
  String get labelCameraDenied =>
      'Para ler o rótulo, preciso de acesso à câmara';

  @override
  String get labelPhotosDenied =>
      'Para ler o rótulo, preciso de acesso às fotos';

  @override
  String get labelOpenSettings => 'Abrir definições';

  @override
  String get labelCameraUnavailable => 'Câmara indisponível';

  @override
  String get labelBarcodeNotFound =>
      'Li o código de barras, mas não encontro o vinho';

  @override
  String get labelBarcodeFrontHint => 'Fotografe o rótulo da frente';

  @override
  String get labelSharedNotAllowed =>
      'Não pode adicionar vinhos a esta garrafeira';

  @override
  String get labelSharedFirstOnly => 'Usei apenas a primeira foto';

  @override
  String get labelSharedExpired =>
      'Não foi possível ler a foto partilhada: partilhe-a novamente';

  @override
  String get labelReplaceTitle => 'Tem um vinho por guardar. Ler a nova foto?';

  @override
  String get labelReplaceRead => 'Ler a nova foto';

  @override
  String get labelReplaceKeep => 'Continuar com o que está aberto';

  @override
  String get labelWineAdded => 'Vinho adicionado à garrafeira';

  @override
  String get onboardingPage1Title => 'A sua garrafeira no bolso';

  @override
  String get onboardingPage1Body =>
      'Adicione as garrafas escrevendo-as ou com uma foto do rótulo, mesmo sem rede.';

  @override
  String get onboardingPage2Title => 'No momento certo';

  @override
  String get onboardingPage2Body =>
      'O Vinoozy estima quando cada vinho está no seu melhor e diz-lhe quais abrir primeiro.';

  @override
  String get onboardingPage3Title => 'Juntos';

  @override
  String get onboardingPage3Body =>
      'Partilhe a garrafeira com até duas pessoas e guarde o histórico de cada garrafa que bebe.';

  @override
  String get onboardingSkip => 'Ignorar';

  @override
  String get onboardingNext => 'Seguinte';

  @override
  String get onboardingStart => 'Começar';

  @override
  String onboardingPageOf(int page) {
    return 'Página $page de 3';
  }

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profilePhoto => 'Foto de perfil';

  @override
  String get profileSignOut => 'Terminar sessão';

  @override
  String get profileDeleteAccount => 'Eliminar conta';

  @override
  String get profilePrivacy => 'Política de privacidade';

  @override
  String get profilePrivacyBody =>
      'Pode ler a política de privacidade neste endereço:';

  @override
  String get profileOpenLink => 'Abrir no navegador';

  @override
  String get profileOpenLinkFailed =>
      'Não foi possível abrir a página. Pode copiar o link e abri-lo no navegador.';

  @override
  String get profileCopyLink => 'Copiar link';

  @override
  String get profileLinkCopied => 'Link copiado';

  @override
  String get close => 'Fechar';

  @override
  String get signOutConfirmTitle => 'Quer terminar sessão?';

  @override
  String signOutPendingWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Tem $count alterações ainda por guardar. Se terminar sessão e outra conta iniciar sessão, serão perdidas.',
      one: 'Tem 1 alteração ainda por guardar. Se terminar sessão e outra conta iniciar sessão, será perdida.',
      zero:
          'Tem $count alterações ainda por guardar. Se terminar sessão e outra conta iniciar sessão, serão perdidas.',
    );
    return '$_temp0';
  }

  @override
  String get signOutStayAndSync => 'Ficar e sincronizar';

  @override
  String get signOutAnyway => 'Terminar sessão mesmo assim';

  @override
  String get syncAllSaved => 'Tudo guardado';

  @override
  String syncStillPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ainda $count alterações por guardar: verifique a rede',
      one: 'Ainda 1 alteração por guardar: verifique a rede',
      zero: 'Ainda $count alterações por guardar: verifique a rede',
    );
    return '$_temp0';
  }

  @override
  String get signOutFailed =>
      'Não foi possível terminar sessão. Tente novamente';

  @override
  String get signInAccountDeleted => 'Conta eliminada';

  @override
  String get deleteAccountIntro => 'Será eliminado para sempre:';

  @override
  String get deleteAccountItemCellar =>
      'A sua garrafeira, com os vinhos e o Histórico';

  @override
  String get deleteAccountItemShares =>
      'As partilhas que concedeu: as pessoas convidadas perdem o acesso';

  @override
  String get deleteAccountItemMemberships =>
      'A sua participação nas garrafeiras de outras pessoas: os seus consumos ficam lá sem o seu nome';

  @override
  String get deleteAccountItemProfile => 'O seu perfil';

  @override
  String deleteAccountPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Tem $count alterações ainda por guardar: serão guardadas e depois eliminadas com o resto',
      one: 'Tem 1 alteração ainda por guardar: será guardada e depois eliminada com o resto',
      zero:
          'Tem $count alterações ainda por guardar: serão guardadas e depois eliminadas com o resto',
    );
    return '$_temp0';
  }

  @override
  String get deleteAccountConfirmWord => 'ELIMINAR';

  @override
  String deleteAccountTypeWord(String word) {
    return 'Escreva $word para confirmar';
  }

  @override
  String get deleteAccountReauthHint =>
      'Depois, iniciará sessão novamente com o Google para confirmar a sua identidade.';

  @override
  String get deleteAccountForever => 'Eliminar para sempre';

  @override
  String get deleteAccountNeedsNetwork =>
      'Ligue-se à Internet para eliminar a conta';

  @override
  String get deleteAccountSameAccount =>
      'A eliminação exige iniciar sessão com a mesma conta';

  @override
  String get deletionTitle => 'A eliminar a conta';

  @override
  String get deletionStepPreparePhone => 'A guardar as alterações pendentes';

  @override
  String get deletionStepMarkStarted => 'A iniciar a eliminação';

  @override
  String get deletionStepLeaveOtherCellars =>
      'A sair das garrafeiras de outras pessoas';

  @override
  String get deletionStepCloseOwnInvitations => 'A encerrar as suas partilhas';

  @override
  String get deletionStepDeleteWinesAndRecords =>
      'A eliminar vinhos e Histórico';

  @override
  String get deletionStepDeleteCellar => 'A eliminar a garrafeira';

  @override
  String get deletionStepDeleteProfileAndUser =>
      'A eliminar o perfil e a conta';

  @override
  String get deletionStepCleanUpPhone => 'A limpar este telemóvel';

  @override
  String deletionStepAnnounce(int step, String label) {
    return 'Passo $step de 8: $label';
  }

  @override
  String deletionDeletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vinhos e consumos eliminados',
      one: '1 vinho ou consumo eliminado',
      zero: '$count vinhos e consumos eliminados',
    );
    return '$_temp0';
  }

  @override
  String get deletionResumeHint =>
      'A eliminação desta conta não terminou. Inicie sessão novamente com o Google para a concluir.';

  @override
  String get deletionContinue => 'Continuar';

  @override
  String get deletionOffline =>
      'Ligue-se à Internet para concluir a eliminação';

  @override
  String get deletionPendingWrites =>
      'Não consigo guardar as alterações pendentes. Tente novamente';

  @override
  String get deletionFailed =>
      'Não foi possível concluir a eliminação. Tente novamente';

  @override
  String get uxCountryLabel => 'País';

  @override
  String get uxCountryOther => 'Outro país…';

  @override
  String get uxCountryNone => 'Nenhum país';

  @override
  String get uxAllCountriesTitle => 'Todos os países e territórios';

  @override
  String get uxAllCountriesSearch => 'Pesquisar um país';

  @override
  String get uxAllCountriesRare => 'Raros no vinho';

  @override
  String get uxAllCountriesAll => 'Todos, de A a Z';

  @override
  String get uxAllCountriesNone => 'Nenhum país encontrado';

  @override
  String get uxRegionLabel => 'Região';

  @override
  String uxRegionOf(String country) {
    return 'Região · $country';
  }

  @override
  String get uxRegionOther => 'Outra região';

  @override
  String get uxRegionFieldLabel => 'Escreva a região';

  @override
  String get uxRegionTooLong => 'No máximo 120 carateres';

  @override
  String get uxDrinkAction => 'Bebi uma';

  @override
  String uxDrinkActionTooltip(String name) {
    return 'Bebi uma garrafa de $name';
  }

  @override
  String get uxDrinkActionDetail => 'Bebi uma garrafa';

  @override
  String get uxDrinkSheetLabel => 'Confirmar o consumo';

  @override
  String get uxDrinkSheetBottles => 'Garrafas';

  @override
  String uxDrinkSheetBottlesChange(int before, int after) {
    return 'Garrafas: de $before para $after';
  }

  @override
  String get uxDrinkSheetRating => 'Como estava? (opcional)';

  @override
  String uxDrinkSheetStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count estrelas de 5',
      one: '1 estrela de 5',
      zero: '$count estrelas de 5',
    );
    return '$_temp0';
  }

  @override
  String get uxDrinkSheetConfirm => 'Sim, bebi-a';

  @override
  String get uxRemoveBottle => 'Retirar uma garrafa sem registar consumo';

  @override
  String get uxRemoveBottleTitle => 'Retirar uma garrafa?';

  @override
  String uxRemoveBottleBody(String name) {
    return 'É retirada uma garrafa de $name sem registar um consumo.';
  }

  @override
  String get uxRemoveBottleConfirm => 'Retirar';

  @override
  String get uxIdealTitle => 'Momento ideal';

  @override
  String uxIdealUntil(String year) {
    return 'Recomendado até $year';
  }

  @override
  String uxIdealUntilPast(String year) {
    return 'Recomendado até $year: já passou';
  }

  @override
  String uxIdealBest(String start, String end) {
    return 'No seu melhor de $start a $end';
  }

  @override
  String uxIdealBar(String start, String end) {
    return 'Janela de consumo de $start a $end';
  }

  @override
  String get uxIdealDisclaimer =>
      '⚠︎ Indicativo: é uma estimativa baseada no tipo, na denominação e na colheita. A conservação e cada garrafa podem alterá-la.';

  @override
  String get uxIdealUnavailableHint =>
      'Indique a colheita e o tipo para obter uma estimativa.';

  @override
  String uxDashboardDrinkNow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count para beber agora',
      one: '1 para beber agora',
      zero: '$count para beber agora',
    );
    return '$_temp0';
  }

  @override
  String get uxFamilyRed => 'Tinto';

  @override
  String get uxFamilyWhite => 'Branco';

  @override
  String get uxFamilyRose => 'Rosé';

  @override
  String get uxFamilySparkling => 'Espumante';

  @override
  String get uxFamilySweet => 'Doce';

  @override
  String get labelBackTitle => 'Agora o contrarrótulo';

  @override
  String get labelBackHint =>
      'No contrarrótulo costumam estar o código de barras, o produtor e a colheita: ajudam a encontrar o vinho.';

  @override
  String get labelBackTake => 'Fotografar o contrarrótulo';

  @override
  String get labelBackGallery => 'Escolher da galeria';

  @override
  String get labelBackSkip => 'Ignorar';

  @override
  String get labelStepFront => 'Frente';

  @override
  String get labelStepBack => 'Contrarrótulo';

  @override
  String get labelStepBarcode => 'Código de barras';

  @override
  String get labelStepDatabase => 'Base de vinhos no telemóvel';

  @override
  String get labelStepPending => 'A aguardar';

  @override
  String get labelStepRunning => 'Em curso…';

  @override
  String get labelStepDone => 'Concluído';

  @override
  String get labelStepSkipped => 'Ignorado';

  @override
  String get labelStepFailed => 'Ilegível';

  @override
  String labelStepStatus(String step, String status) {
    return '$step: $status';
  }

  @override
  String get labelOnPhoneNote =>
      'Tudo acontece no telemóvel: as fotos não são enviadas a ninguém.';

  @override
  String get labelBackUnreadable => 'Contrarrótulo ilegível';

  @override
  String get labelSourceOffline => 'Da base no telemóvel · offline';

  @override
  String get labelSourceCatalog => 'Do catálogo';

  @override
  String get labelSourceOnline => 'Do Open Food Facts · online';

  @override
  String get labelNotThis => 'Não é este';

  @override
  String get labelOffAttribution => 'Dados do Open Food Facts, licença ODbL';

  @override
  String get labelCandidatesTitle => 'Qual destes?';

  @override
  String labelCandidatesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vinhos semelhantes',
      one: '1 vinho semelhante',
      zero: '$count vinhos semelhantes',
    );
    return '$_temp0';
  }

  @override
  String get labelCandidatesNone => 'Nenhum destes';

  @override
  String get labelChipOffline => 'offline';

  @override
  String get labelChipOnline => 'online';

  @override
  String get labelChipCatalog => 'catálogo';

  @override
  String get labelNoProducer => 'produtor não indicado';

  @override
  String get labelNoMatch => 'Li o rótulo, mas não reconheço o vinho';

  @override
  String get labelReadText => 'Texto lido';

  @override
  String get labelSearchOnline => 'Pesquisar online';

  @override
  String get labelOpenLens => 'Abrir no Google Lens';

  @override
  String get labelLensLastResort =>
      'O Google Lens é o último recurso: a foto só passa para a app Google se confirmar.';

  @override
  String get labelLensTitle => 'Abrir no Google Lens?';

  @override
  String get labelLensBody =>
      'A foto da frente passará para a app Google no seu telemóvel, ou para a app que escolher, que pode guardar uma cópia segundo as suas próprias regras. O Vinoozy não recebe os resultados: volte aqui para escolher ou escrever o vinho.';

  @override
  String get labelLensConfirm => 'Abrir o Google Lens';

  @override
  String get labelLensFailed =>
      'Não consigo abrir o Google Lens nem o menu de partilha';

  @override
  String get onlineSearchTitle => 'Pesquisar online';

  @override
  String get onlineSearchSubtitle => 'Open Food Facts · só vinhos';

  @override
  String get onlineSearchField => 'Palavras a pesquisar';

  @override
  String get onlineSearchHint => 'Pode alterar as palavras antes de pesquisar.';

  @override
  String get onlineSearchEmptyField => 'Escreva pelo menos uma palavra';

  @override
  String get onlineSearchButton => 'Pesquisar';

  @override
  String get onlineSearchLoading => 'A pesquisar…';

  @override
  String onlineSearchResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count resultados',
      one: '1 resultado',
      zero: '$count resultados',
    );
    return '$_temp0';
  }

  @override
  String get onlineSearchEmpty =>
      'Nenhum vinho encontrado: experimente outras palavras ou «Escrever à mão».';

  @override
  String get onlineSearchOffline =>
      'Sem rede: pesquiso apenas na base do telemóvel.';

  @override
  String get onlineSearchRateLimited =>
      'A pesquisa online não está disponível agora, tente novamente dentro de alguns minutos.';

  @override
  String get onlineSearchUnavailable =>
      'A pesquisa online não está ativa nesta versão da app: pesquiso apenas na base do telemóvel.';

  @override
  String get aboutTitle => 'Acerca';

  @override
  String aboutVersion(String version) {
    return 'Versão $version';
  }

  @override
  String get aboutDbTitle => 'Base de vinhos';

  @override
  String aboutDbCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vinhos',
      one: '1 vinho',
      zero: '$count vinhos',
    );
    return '$_temp0';
  }

  @override
  String aboutDbDate(String date) {
    return 'Exportação do Open Food Facts de $date';
  }

  @override
  String get aboutDbSample =>
      'Base de exemplo: alguns vinhos de teste escritos à mão, não dados do Open Food Facts.';

  @override
  String get aboutDbLoading => 'A abrir a base de vinhos…';

  @override
  String get aboutDbUnavailable =>
      'A base de vinhos não está disponível nesta versão';

  @override
  String aboutDbSource(String url) {
    return 'A base derivada e a ferramenta que a gera estão no repositório público: $url';
  }

  @override
  String get aboutLicenseTitle => 'Licenças';

  @override
  String get aboutLicense =>
      'Contém informações do Open Food Facts, disponibilizadas ao abrigo da Open Database License (ODbL). Os conteúdos individuais estão ao abrigo da Database Contents License (DbCL).';

  @override
  String get aboutPrivacyTitle => 'Fotos dos rótulos';

  @override
  String get aboutPrivacy =>
      'As fotos dos rótulos são lidas no telemóvel e apagadas quando sai do resultado. Só saem do telemóvel se tocar em «Abrir no Google Lens» e confirmar.';

  @override
  String get aboutAppellationsTitle => 'Denominações';

  @override
  String get aboutAppellationsSource =>
      'Denominações: registo eAmbrosia (UE) e registos oficiais nacionais.';

  @override
  String get aboutAppellationsSample =>
      'Tabela de exemplo: um extrato dos registos escrito à mão, até serem transferidos os registos reais.';

  @override
  String get denominationLabel => 'Denominação';

  @override
  String get denominationTooLong => 'No máximo 120 carateres';

  @override
  String get autofillFilledNotice =>
      'Preenchido a partir do rótulo: verifique e guarde';

  @override
  String get autofillPastedNotice =>
      'Preenchido a partir do texto: verifique e guarde';

  @override
  String get autofillFromText => '✦ do texto';

  @override
  String get autofillFromTextSemantics => 'preenchido a partir do rótulo';

  @override
  String get autofillClear => 'Limpar';

  @override
  String get autofillLens => 'Lens';

  @override
  String get autofillClearTitle => 'Limpar o formulário?';

  @override
  String get autofillClearBody =>
      'Também escreveu em alguns campos. «Limpar» esvazia nome, produtor, denominação, colheita, tipo, país, região e nível. A quantidade mantém-se.';

  @override
  String get autofillClearConfirm => 'Limpar';

  @override
  String get autofillCleared => 'Formulário limpo';

  @override
  String get autofillPasteTitle => 'Tem o texto do Google Lens?';

  @override
  String get autofillPasteHint =>
      'No Lens, selecione o texto do rótulo e toque em «Copiar»; depois volte aqui.';

  @override
  String get autofillPaste => 'Colar do Lens';

  @override
  String get autofillOpenLens => 'Do Google Lens';

  @override
  String get autofillOpenLensSemantics => 'abre o Google Lens';

  @override
  String get autofillClipboardEmpty => 'Não há texto na área de transferência';

  @override
  String get autofillNoNewFields =>
      'Não encontrei no texto dados para adicionar';

  @override
  String get autofillFromLens => 'Formulário preenchido com o texto do Lens';

  @override
  String get autofillShareEmpty => 'Nenhum texto recebido';

  @override
  String get autofillShareUseTitle => 'Usar o texto nos campos vazios?';

  @override
  String get autofillShareUse => 'Usar';

  @override
  String get autofillShareIgnore => 'Ignorar';

  @override
  String get addChoiceLens => 'Do Google Lens';

  @override
  String get addChoicePhotoHint =>
      'Frente e contrarrótulo: o Vinoozy lê o rótulo.';

  @override
  String get addChoiceLensHint =>
      'Abre o Lens: enquadre, selecione o texto e toque em Partilhar → Vinoozy.';

  @override
  String get addChoiceImportHint => 'Uma foto do rótulo que já tirou.';

  @override
  String get addChoiceWriteHint => 'Formulário vazio, com «Colar do Lens».';

  @override
  String get lensInstructionsTitle =>
      'Não é possível abrir o Google Lens a partir daqui';

  @override
  String get lensInstructionsStep1 => 'Abra o Google Lens e enquadre o rótulo';

  @override
  String get lensInstructionsStep2 => 'Selecione o texto do rótulo';

  @override
  String get lensInstructionsStep3 => 'Toque em Partilhar → Vinoozy';

  @override
  String get lensInstructionsOk => 'Percebi';

  @override
  String get levelLabel => 'Nível';

  @override
  String get levelEveryday => 'Dia a dia (económico)';

  @override
  String get levelGood => 'Bom';

  @override
  String get levelAging => 'De guarda';

  @override
  String get levelNone => 'Nenhum';

  @override
  String get levelEverydayShort => 'beber jovem';

  @override
  String get levelGoodShort => 'estimativa normal';

  @override
  String get levelAgingShort => 'dura mais';

  @override
  String get levelSuggested => 'sugerido';

  @override
  String levelSuggestedReason(String qualifier) {
    return 'Sugerido porque o nome contém «$qualifier»: fica guardado assim se não o alterar. Escolha outro ou toque em «Nenhum».';
  }

  @override
  String levelSuggestedSemantics(String qualifier) {
    return 'sugerido, porque o nome contém $qualifier';
  }

  @override
  String levelOptionSemantics(String option, int index, int count) {
    return 'Nível, $option, $index de $count';
  }

  @override
  String get levelWhatChanges => 'O que muda';

  @override
  String get levelEverydayExamples =>
      'A janela fica mais curta. Ex.: vinho da casa, Lambrusco, Prosecco básico, Bardolino, Vinho Verde.';

  @override
  String get levelGoodExamples =>
      'A estimativa normal, e o valor se não escolher nada. Ex.: Chianti Classico, Barbera d\'Asti Superiore, Rioja Crianza, Côtes du Rhône.';

  @override
  String get levelAgingExamples =>
      'A janela fica mais longa. Ex.: Barolo, Brunello, Amarone, Bordeaux Grand Cru, Rioja Gran Reserva, Porto Vintage.';

  @override
  String levelPreviewBefore(String start, String end) {
    return 'Antes $start – $end';
  }

  @override
  String levelPreviewWith(String level, String start, String end) {
    return 'Com «$level» $start – $end';
  }

  @override
  String levelPreviewNow(String start, String end) {
    return 'Pronto $start – até $end';
  }

  @override
  String levelDetail(String level) {
    return 'Nível: $level';
  }

  @override
  String get overrideCorrect => 'Corrigir';

  @override
  String get overrideRestore => 'Repor estimativa';

  @override
  String get overrideCorrectedByYou => 'corrigido por si';

  @override
  String overrideAppEstimate(String year) {
    return 'Estimativa da app: até $year';
  }

  @override
  String get overrideSheetTitle => 'Recomendado até';

  @override
  String overrideSheetHint(String start) {
    return 'Escolha o ano. Não pode ser anterior a «Pronto a partir de $start».';
  }

  @override
  String overridePeakNotice(String peak) {
    return 'Se escolher um ano anterior a $peak (no seu melhor), «no seu melhor» passa também para esse ano.';
  }

  @override
  String get overrideMore => 'mais…';

  @override
  String get overrideSave => 'Guardar correção';

  @override
  String overrideRestoreTitle(String year) {
    return 'Voltar à estimativa da app (até $year)?';
  }

  @override
  String get overrideRestoreConfirm => 'Repor';

  @override
  String get overrideSaved => 'Correção guardada';

  @override
  String get overrideRestored => 'Estimativa reposta';

  @override
  String get estimateSourceCorrectedByYou => 'corrigida por si';

  @override
  String estimateFromDenomination(String name) {
    return 'Estimativa pela denominação $name';
  }

  @override
  String estimateFromDenominationQualifier(String name, String qualifier) {
    return 'Estimativa pela denominação $name, $qualifier';
  }

  @override
  String estimateFromGrape(String name) {
    return 'Estimativa pela casta $name';
  }

  @override
  String get estimateFromType => 'Estimativa pelo tipo de vinho';

  @override
  String get autofillReading => 'A ler o texto…';

  @override
  String get guideChip => 'Verificação guiada';

  @override
  String guideProgress(int n, int total) {
    return 'Pergunta $n de $total';
  }

  @override
  String get guideClose => 'Fechar';

  @override
  String get guideIsDenomination => 'é a denominação?';

  @override
  String get guideIsProducer => 'é o produtor?';

  @override
  String get guideIsName => 'é o nome do vinho?';

  @override
  String get guideIsVintage => 'Colheita';

  @override
  String guideAskDenomination(String value) {
    return '$value é a denominação?';
  }

  @override
  String guideAskProducer(String value) {
    return '$value é o produtor?';
  }

  @override
  String guideAskName(String value) {
    return '$value é o nome do vinho?';
  }

  @override
  String get guideAskVintage => 'Qual é a colheita?';

  @override
  String guideQuestionSemantics(int n, int total, String question) {
    return 'Pergunta $n de $total: $question';
  }

  @override
  String get guideNoProposal => 'Não o encontrei no texto';

  @override
  String get guideYes => 'Sim';

  @override
  String get guideNo => 'Não, outra';

  @override
  String get guideEdit => 'Editar';

  @override
  String get guideSkip => 'Ignorar';

  @override
  String get guideConfirm => 'Confirmar';

  @override
  String get guideCancel => 'Cancelar';

  @override
  String guideRejected(String value) {
    return '«$value» não: eis a seguinte';
  }

  @override
  String get guideNoMore => 'Não há mais sugestões: componha-a ou ignore';

  @override
  String guideProposalAnnounce(String value) {
    return 'Sugestão: $value';
  }

  @override
  String get guideComposeLabel => 'Ou componha-a tocando nas palavras do texto';

  @override
  String get guideComposePreview => 'Pré-visualização';

  @override
  String get guideComposeEmpty => 'Toque numa ou em várias palavras';

  @override
  String get guideComposeLimit => 'No máximo 8 palavras e 80 carateres';

  @override
  String guideTableMatchSemantics(String name) {
    return 'corresponde a $name';
  }

  @override
  String guideLine(int n, int total) {
    return 'Linha $n de $total';
  }

  @override
  String guideWordSelected(String word, int order) {
    return '$word, selecionada, $order';
  }

  @override
  String guideWordUnavailable(String word) {
    return '$word, indisponível';
  }

  @override
  String guideWordUsedFor(String word, String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'na denominação',
      'producer': 'no produtor',
      'other': 'no nome',
    });
    return '$word, usada $_temp0';
  }

  @override
  String guideUsedMark(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'denominação',
      'producer': 'produtor',
      'other': 'nome',
    });
    return '$_temp0';
  }

  @override
  String guideOtherYears(String years) {
    return 'Também no texto: $years';
  }

  @override
  String get guideWheelFromText => 'ano encontrado no texto';

  @override
  String get guideWheelTypeYear => 'Escreva o ano';

  @override
  String guideWheelConfirm(String year) {
    return 'Confirmar $year';
  }

  @override
  String get guideNoVintage => 'Sem colheita';

  @override
  String guideSkippedNotice(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'Denominação ignorada',
      'producer': 'Produtor ignorado',
      'vintage': 'Colheita ignorada',
      'other': 'Nome ignorado',
    });
    return '$_temp0: escreva o dado ou retome o guia';
  }

  @override
  String guideSkippedMany(int count) {
    return '$count campos ignorados: escreva-os ou retome o guia';
  }

  @override
  String get guideInvalidValue =>
      'Este texto contém carateres que não podem ser guardados';

  @override
  String get brandStudio => 'Bottazzini Softworks';

  @override
  String get suggestedMark => '✦ sugerido';

  @override
  String suggestedSemantics(String field, String value) {
    return '$field, $value, sugerido';
  }

  @override
  String get restoreSuggestion => 'Repor sugestão';

  @override
  String get restoreSuggestionDone => 'Sugestão reposta';

  @override
  String get styleLabel => 'Estilo';

  @override
  String styleGroupSemantics(String value, int index, int count) {
    return 'Estilo, $value, $index de $count';
  }

  @override
  String get styleRedFresh => 'Fresco';

  @override
  String get styleRedMedium => 'Médio';

  @override
  String get styleRedAge => 'De guarda';

  @override
  String get styleRedLong => 'Longa guarda';

  @override
  String get styleWhiteFresh => 'Fresco';

  @override
  String get styleWhiteMedium => 'Médio';

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
  String get styleSweetPassito => 'Uvas passas';

  @override
  String get styleSweetBotrytis => 'Botritizado';

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
  String get styleFortifiedOther => 'Outro';

  @override
  String get profileNameRFresh => 'Tinto frutado';

  @override
  String get profileNameRMedium => 'Tinto de corpo médio';

  @override
  String get profileNameRAge => 'Tinto de guarda';

  @override
  String get profileNameRLong => 'Tinto de longa guarda';

  @override
  String get profileNameWFresh => 'Branco fresco e aromático';

  @override
  String get profileNameWMedium => 'Branco de corpo médio';

  @override
  String get profileNameWAge => 'Branco de guarda';

  @override
  String get profileNameRoseFresh => 'Rosé fresco';

  @override
  String get profileNameSpTank => 'Espumante Charmat fresco';

  @override
  String get profileNameLamFresh => 'Lambrusco fresco';

  @override
  String get profileNameSpClassic => 'Método clássico fresco';

  @override
  String get profileNameSpClassicAge => 'Método clássico de guarda';

  @override
  String get profileNameSwAromatic => 'Doce aromático jovem';

  @override
  String get profileNameSwPassito => 'Doce de uvas passas';

  @override
  String get profileNameSwBotrytis => 'Doce botritizado';

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
  String get profileNameShPx => 'Xerez Pedro Ximénez';

  @override
  String get profileNameFortUnknown => 'Fortificado, estilo desconhecido';

  @override
  String get profileNameUnknown => 'Estilo não identificado';

  @override
  String estimateFromProfile(String profile, String denomination) {
    return 'Estimativa pelo perfil $profile ($denomination)';
  }

  @override
  String estimateFromProfileType(String profile) {
    return 'Estimativa pelo perfil $profile, segundo o tipo';
  }

  @override
  String estimateFromProfileGrape(String profile, String grape) {
    return 'Estimativa pelo perfil $profile, segundo a casta $grape';
  }

  @override
  String get estimateFromEntryDateDisgorgement =>
      'Pela data de registo: adicione a data de dégorgement para uma estimativa melhor';

  @override
  String get estimateFromEntryDateBottling =>
      'Pela data de registo: adicione a data de engarrafamento para uma estimativa melhor';

  @override
  String get styleToConfirmBanner =>
      '⚠︎ Estilo por confirmar: a estimativa é indicativa';

  @override
  String get chooseTypePrompt => 'Escolha o tipo';

  @override
  String estimateUpdatedAnnouncement(String summary) {
    return 'Estimativa atualizada: $summary';
  }

  @override
  String get agingStartDisgorgement => 'Dégorgement';

  @override
  String get agingStartBottling => 'Engarrafamento';

  @override
  String get agingStartMonth => 'Mês';

  @override
  String get agingStartYear => 'Ano';

  @override
  String get agingStartHint => 'Costuma estar no contrarrótulo.';

  @override
  String get agingStartIncomplete => 'Indique o mês e o ano';

  @override
  String get agingStartFuture => 'A data não pode ser futura';

  @override
  String get agingStartBeforeVintage => 'Não pode ser anterior à colheita';

  @override
  String get windowNoEnd => 'Pronto, sem fim estimado';

  @override
  String get windowNoEndShort => 'sem fim estimado';

  @override
  String windowDrinkWithin(String date) {
    return 'até $date';
  }

  @override
  String get levelNoEffect => 'O nível não altera esta estimativa';

  @override
  String get dashboardToConfirmTitle => 'Por confirmar';

  @override
  String dashboardToConfirmCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vinhos',
      one: '1 vinho',
      zero: '$count vinhos',
    );
    return '$_temp0';
  }

  @override
  String aboutDbClassified(String percent) {
    return '$percent% dos vinhos com tipo reconhecido';
  }

  @override
  String get planTitle => 'Plano';

  @override
  String get planFree => 'Gratuito';

  @override
  String get planPlus => 'Plus';

  @override
  String get planPlusGift => 'Plus (oferta)';

  @override
  String get planDevUnlockAll => 'DEV · Plus de teste';

  @override
  String get planDevSimulateFree => 'DEV · Plano gratuito simulado';

  @override
  String get planDevSimulateExpired => 'DEV · Plus expirado simulado';

  @override
  String get planDiscoverPlus => 'Descobrir o Plus';

  @override
  String get plusTitle => 'Vinoozy Plus';

  @override
  String get plusBenefitsTitle => 'Com o Plus';

  @override
  String get plusBenefitNoAds => 'Sem anúncios';

  @override
  String get plusBenefitNoLimit => 'Sem limite de vinhos na sua garrafeira';

  @override
  String get plusComingSoon => 'O Plus chega em breve';

  @override
  String get plusLoading => 'A ler os preços no Google Play';

  @override
  String get plusStoreUnavailable =>
      'Não foi possível ler os preços no Google Play. Tente novamente mais tarde.';

  @override
  String plusPriceMonthly(String price) {
    return '$price por mês';
  }

  @override
  String plusPriceAnnual(String price) {
    return '$price por ano';
  }

  @override
  String get plusRenewal =>
      'A subscrição é renovada automaticamente ao preço indicado até a cancelar no Google Play.';

  @override
  String get plusTerms =>
      'O pagamento é debitado na sua conta do Google Play quando confirma a compra. Pode cancelar em qualquer altura: o Plus mantém-se ativo até ao fim do período já pago. Quando o Plus termina, todos os seus vinhos se mantêm.';

  @override
  String get plusRestore => 'Restaurar compras';

  @override
  String get plusManage => 'Gerir ou cancelar a subscrição no Google Play';

  @override
  String get plusActive => 'O Plus está ativo nesta conta';

  @override
  String get plusActiveGift =>
      'Tem o Plus como oferta: sem débitos e sem renovações.';

  @override
  String get plusPending =>
      'Pagamento pendente: o Plus fica ativo quando o Google Play o confirmar.';

  @override
  String get plusVerifying => 'A verificar a compra';

  @override
  String get plusVerified =>
      'Compra verificada: o Plus fica ativo dentro de alguns segundos.';

  @override
  String get plusPurchaseFailed =>
      'A compra não foi concluída. Tente novamente.';

  @override
  String get plusInvalidPurchase =>
      'O Google Play não confirmou esta compra para o Vinoozy.';

  @override
  String get plusOwnedByOther =>
      'Esta subscrição já pertence a outra conta do Vinoozy.';

  @override
  String get plusVerificationUnavailable =>
      'Não foi possível verificar a compra agora. Tente novamente mais tarde: a subscrição mantém-se no Google Play.';

  @override
  String get capacityLimitTitle => 'Atingiu o limite do plano gratuito';

  @override
  String capacityLimitBody(int limit) {
    return 'O plano gratuito inclui até $limit vinhos diferentes na sua garrafeira. Pode sempre editar, beber e adicionar garrafas aos vinhos que já tem. Para adicionar um novo, termine ou elimine um vinho, ou mude para o Plus.';
  }

  @override
  String capacityLimitBodyComingSoon(int limit) {
    return 'O plano gratuito inclui até $limit vinhos diferentes na sua garrafeira. Pode sempre editar, beber e adicionar garrafas aos vinhos que já tem. Para adicionar um novo, termine ou elimine um vinho. O Plus chega em breve.';
  }

  @override
  String get rejectedCapacityLimit =>
      'Não sincronizado: ultrapassa o limite de vinhos do plano gratuito. A alteração fica neste telemóvel.';

  @override
  String get rejectedCapacityConflict =>
      'Não sincronizado: a garrafeira mudou noutro dispositivo ao mesmo tempo. A alteração fica neste telemóvel: tente novamente.';

  @override
  String writeRejectedCapacityLimit(String name) {
    return '$name: não sincronizado, ultrapassa o limite do plano gratuito';
  }

  @override
  String writeRejectedCapacityConflict(String name) {
    return '$name: não sincronizado, a garrafeira mudou noutro dispositivo';
  }

  @override
  String get freeIntroTitle => 'O plano gratuito';

  @override
  String freeIntroLimit(int limit) {
    return 'Pode gerir gratuitamente até $limit vinhos diferentes.';
  }

  @override
  String get freeIntroAds =>
      'A utilização ligeira não tem anúncios. Se ultrapassar o limiar mensal de utilização do serviço, poderá ver anúncios ocasionais que ajudam a cobrir os custos dos servidores e da sincronização.';

  @override
  String get freeIntroNoAds => 'Sem anúncios na versão de lançamento.';

  @override
  String get freeIntroPlus =>
      'Com o Plus, remove os anúncios e o limite da garrafeira.';

  @override
  String get noticeGotIt => 'Percebi';

  @override
  String get thresholdTitle => 'Os anúncios ajudam a manter o Vinoozy gratuito';

  @override
  String get thresholdBody =>
      'Atingiu o limiar mensal de utilização sem anúncios. A partir de agora, poderá ver anúncios ocasionais: ajudam-nos a cobrir os custos dos servidores e da sincronização, mantendo o Vinoozy gratuito.';

  @override
  String get thresholdReset =>
      'A contagem recomeça no próximo mês. Com o Plus, pode usar a app sem anúncios e sem o limite da garrafeira.';

  @override
  String thresholdNextReset(String date) {
    return 'Próxima reposição: $date';
  }

  @override
  String get thresholdHowItWorks => 'Como funciona';

  @override
  String get thresholdHowItWorksBody =>
      'O limiar depende de uma estimativa das sincronizações com a nuvem feitas por esta conta durante o mês. A utilização offline, por si só, não gera novas operações na nuvem. Os anúncios aparecem, no máximo, uma vez por dia, apenas no Painel, e nunca enquanto guarda ou exporta os seus dados.';

  @override
  String get adLabel => 'Publicidade';

  @override
  String get devToolsTitle => 'Ferramentas de programador';

  @override
  String get devUnlockAll => 'Desbloquear tudo — Plus de teste';

  @override
  String get devSimulateFree => 'Simular plano gratuito';

  @override
  String get devSimulateExpired => 'Simular Plus expirado';

  @override
  String get devRestore => 'Repor estado normal';

  @override
  String get devNoOverride => 'Nenhuma simulação ativa';

  @override
  String get devApplied => 'Cenário aplicado também no emulador do Firestore';

  @override
  String get devIncomplete =>
      'Simulação incompleta: o emulador do Firestore não confirmou o direito de teste. As regras do servidor não veem este cenário.';

  @override
  String get devNotice =>
      'Apenas compilações de desenvolvimento com o emulador: sem pagamentos, tokens ou recibos.';
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

  @override
  String get appTitle => 'Vinoozy';

  @override
  String get signInTagline => 'Sua adega, no momento certo';

  @override
  String get signInWithGoogle => 'Continuar com o Google';

  @override
  String get signInInProgress => 'Entrando';

  @override
  String get signInFailed => 'Não foi possível entrar';

  @override
  String get signInNeedsNetwork => 'É preciso conexão para o primeiro acesso';

  @override
  String get signInSessionExpired => 'Sua sessão expirou: entre novamente';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get cancel => 'Cancelar';

  @override
  String blockedMessage(String email) {
    return 'Há alterações de $email ainda não salvas na nuvem: entre com essa conta e conecte-se à rede';
  }

  @override
  String blockedSignInWith(String email) {
    return 'Entrar com $email';
  }

  @override
  String blockedDiscard(String email) {
    return 'Excluir as alterações não salvas de $email';
  }

  @override
  String get discardDialogTitle => 'Excluir as alterações?';

  @override
  String discardDialogBody(int count, String email) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count vinhos de $email ainda não estão na nuvem e serão excluídos deste telefone.',
      one:
          '1 vinho de $email ainda não está na nuvem e será excluído deste telefone.',
      zero:
          '$count vinhos de $email ainda não estão na nuvem e serão excluídos deste telefone.',
    );
    return '$_temp0';
  }

  @override
  String get discardConfirm => 'Excluir';

  @override
  String get resetFailed => 'Não foi possível apagar os dados deste telefone';

  @override
  String get restartRequired => 'Reinicie o app para concluir';

  @override
  String get restartCloseApp => 'Fechar o app';

  @override
  String get startupFailed => 'Não foi possível iniciar o app';

  @override
  String get cellarTitle => 'Adega';

  @override
  String get defaultCellarName => 'Minha adega';

  @override
  String get cellarLoading => 'Preparando a adega';

  @override
  String get cellarSetupFailed => 'Não foi possível preparar a adega';

  @override
  String get cellarEmpty => 'Sua adega está vazia';

  @override
  String get addWine => 'Adicionar';

  @override
  String get estimatePending => 'Estimativa em breve';

  @override
  String get noVintage => 'Sem safra';

  @override
  String bottleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count garrafas',
      one: '1 garrafa',
      zero: '$count garrafas',
    );
    return '$_temp0';
  }

  @override
  String get syncInProgress => 'Sincronizando';

  @override
  String get syncOffline => 'Offline - sincronização pendente';

  @override
  String writeRejected(String name) {
    return 'Alteração não permitida: $name';
  }

  @override
  String get saveFailed => 'Não foi possível salvar, tente novamente';

  @override
  String wineNotSaved(String name) {
    return 'O vinho $name não foi salvo na nuvem';
  }

  @override
  String get addAgain => 'Adicionar novamente';

  @override
  String get ignore => 'Ignorar';

  @override
  String get addWineTitle => 'Escrever';

  @override
  String get wineNameLabel => 'Vinho';

  @override
  String get vintageLabel => 'Safra';

  @override
  String get quantityLabel => 'Quantidade';

  @override
  String get decreaseQuantity => 'Diminuir quantidade';

  @override
  String get increaseQuantity => 'Aumentar quantidade';

  @override
  String get save => 'Salvar';

  @override
  String get nameRequired => 'Escreva o nome do vinho';

  @override
  String get nameTooLong => 'Máximo de 120 caracteres';

  @override
  String vintageRange(String year) {
    return 'Safra entre 1900 e $year';
  }

  @override
  String get offAttribution => 'Dados do Open Food Facts (ODbL)';

  @override
  String get dashboardTitle => 'Painel';

  @override
  String dashboardTotalBottles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count garrafas na adega',
      one: '1 garrafa na adega',
      zero: '$count garrafas na adega',
    );
    return '$_temp0';
  }

  @override
  String get dashboardSyncing => 'Sincronizando a adega…';

  @override
  String get dashboardAddFirstWine => 'Adicionar o primeiro vinho';

  @override
  String get drinkSoonTitle => 'Beber em breve';

  @override
  String get drinkSoonEmpty => 'Nenhuma garrafa perto do fim';

  @override
  String drinkSoonUntil(String year) {
    return 'até $year';
  }

  @override
  String drinkSoonSeeAll(int count) {
    return 'Ver todos ($count)';
  }

  @override
  String get statusChartTitle => 'Situação das garrafas';

  @override
  String get statusWaiting => 'aguardar';

  @override
  String get statusReady => 'prontas';

  @override
  String get statusDrinkSoon => 'beber em breve';

  @override
  String get statusPastWindow => 'fora da janela';

  @override
  String toEstimateNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count garrafas a estimar',
      one: '1 garrafa a estimar',
      zero: '$count garrafas a estimar',
    );
    return '$_temp0';
  }

  @override
  String chartBarValue(String label, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count garrafas',
      one: '1 garrafa',
      zero: '$count garrafas',
    );
    return '$label: $_temp0';
  }

  @override
  String chartDescription(String title, String values) {
    return '$title: $values';
  }

  @override
  String get openListHint => 'Abrir a lista';

  @override
  String get peakChartTitle => 'Ano do auge';

  @override
  String get peakPast => 'auge passado';

  @override
  String get peakBeyond => 'depois';

  @override
  String get breakdownTypeTitle => 'Garrafas por tipo';

  @override
  String get breakdownRegionTitle => 'Garrafas por região';

  @override
  String get breakdownType => 'Tipo';

  @override
  String get breakdownRegion => 'Região';

  @override
  String get familyRed => 'tinto';

  @override
  String get familyWhite => 'branco';

  @override
  String get familyRose => 'rosé';

  @override
  String get familySparkling => 'espumante';

  @override
  String get familySweet => 'doce';

  @override
  String get breakdownUnspecified => 'não informado';

  @override
  String get breakdownOtherRegions => 'outras';

  @override
  String get ok => 'OK';

  @override
  String get cellarMenu => 'Menu da adega';

  @override
  String get sharingPeopleTitle => 'Pessoas';

  @override
  String get sharingInviteTitle => 'Convidar uma pessoa';

  @override
  String get sharingEmailLabel => 'Endereço de e-mail do Google';

  @override
  String get sharingPermissionRead => 'Somente leitura';

  @override
  String get sharingPermissionReadHint =>
      'Vê vinhos, estimativas, painel e consumos';

  @override
  String get sharingPermissionEdit => 'Pode editar';

  @override
  String get sharingPermissionEditHint =>
      'Também adiciona e altera vinhos e registra consumos';

  @override
  String get sharingRoleOwner => 'proprietário';

  @override
  String get sharingInviteButton => 'Convidar';

  @override
  String sharingPlacesUsed(int used, int max) {
    return '$used/$max pessoas';
  }

  @override
  String get sharingInvalidEmail => 'Digite um e-mail válido';

  @override
  String get sharingSelfInvite => 'Você não pode convidar a si mesmo';

  @override
  String get sharingAlreadyInvited => 'Esta pessoa já foi convidada';

  @override
  String sharingLimitReached(int max) {
    return 'Você atingiu o limite de $max pessoas';
  }

  @override
  String get sharingNotOwner =>
      'Você não pode alterar o compartilhamento desta adega';

  @override
  String get sharingNotFound => 'Esta pessoa não está mais na lista';

  @override
  String get sharingFailed => 'Não foi possível concluir, tente novamente';

  @override
  String get sharingInviteFailed => 'Convite não enviado. Tente novamente';

  @override
  String get sharingOfflineHint =>
      'É preciso conexão para gerenciar o compartilhamento';

  @override
  String get sharingStatusInvited => 'convidada';

  @override
  String get sharingStatusActive => 'ativa';

  @override
  String get sharingStatusRevoked => 'revogada';

  @override
  String get sharingStatusLeft => 'saiu';

  @override
  String sharingMemberSemantics(String name, String permission, String status) {
    return '$name, $permission, $status';
  }

  @override
  String get sharingClosedSection => 'Acessos encerrados';

  @override
  String get sharingNobody => 'Ninguém mais vê esta adega ainda';

  @override
  String sharingChangePermission(String name) {
    return 'Alterar a permissão de $name';
  }

  @override
  String get sharingRevoke => 'Revogar';

  @override
  String sharingRevokeTitle(String name) {
    return 'Revogar o acesso de $name?';
  }

  @override
  String sharingRevokeConfirmLabel(String name) {
    return 'Digite $name para confirmar';
  }

  @override
  String get sharingRevokeDisabledHint => 'Ativado quando o nome coincidir';

  @override
  String get sharingReinvite => 'Convidar novamente';

  @override
  String get sharingDeleteForGood => 'Excluir definitivamente';

  @override
  String sharingOwnedBy(String owner) {
    return 'Adega de $owner';
  }

  @override
  String get sharingYourCellar => 'Sua adega';

  @override
  String sharingYourPermission(String permission) {
    return 'Sua permissão: $permission';
  }

  @override
  String sharingSwitcherSemantics(String cellar, String permission) {
    return '$cellar, $permission. Toque para trocar de adega';
  }

  @override
  String get sharingLeave => 'Sair desta adega';

  @override
  String sharingLeaveTitle(String owner) {
    return 'Sair da adega de $owner?';
  }

  @override
  String sharingLeaveBody(String owner) {
    return 'Você não a verá mais. $owner poderá convidar você novamente.';
  }

  @override
  String get sharingLeaveConfirm => 'Sair';

  @override
  String sharingSharedNotice(String owner) {
    return '$owner compartilhou a adega com você';
  }

  @override
  String sharingAccessLost(String owner) {
    return 'Você não tem mais acesso à adega de $owner';
  }

  @override
  String sharingWritesLost(String owner) {
    return 'Algumas alterações na adega de $owner não foram salvas porque você não tem mais acesso';
  }

  @override
  String get sharingSomeone => 'alguém';

  @override
  String get sharingShareSubject => 'Convite para o Vinoozy';

  @override
  String sharingShareMessage(
    String owner,
    String cellar,
    String link,
    String email,
  ) {
    return '$owner convidou você para a adega \"$cellar\" no Vinoozy. Instale o app em $link e entre com a conta Google $email: use exatamente este endereço.';
  }

  @override
  String get cellarSearchHint => 'Buscar por nome ou produtor';

  @override
  String get cellarFilterStatus => 'Estado';

  @override
  String get cellarFilterType => 'Tipo';

  @override
  String get statusToEstimate => 'A estimar';

  @override
  String get filterTypeUnspecified => 'Não informado';

  @override
  String get cellarNoMatches => 'Nenhum vinho com estes filtros';

  @override
  String get cellarClearFilters => 'Limpar filtros';

  @override
  String get cellarArchiveTitle => 'Bebidos';

  @override
  String get cellarArchiveEmpty => 'Nenhum vinho terminado ainda';

  @override
  String get cellarArchiveFailed =>
      'Não foi possível carregar os vinhos terminados';

  @override
  String get wineDrink => 'Bebida';

  @override
  String wineDrinkTooltip(String name) {
    return 'Marcar uma garrafa de $name como bebida';
  }

  @override
  String confidenceLabel(String level) {
    return 'Confiança: $level';
  }

  @override
  String get confidenceHigh => 'alta';

  @override
  String get confidenceMedium => 'média';

  @override
  String get confidenceLow => 'baixa';

  @override
  String get windowStartLabel => 'Início';

  @override
  String get windowPeakLabel => 'Pico';

  @override
  String get windowEndLabel => 'Fim';

  @override
  String estimateSourceLabel(String source) {
    return 'Fonte: $source';
  }

  @override
  String get estimateSourceCatalog => 'base de dados de vinhos';

  @override
  String get estimateSourceType => 'estimativa por tipo';

  @override
  String get estimateSourceCorrected =>
      'estimativa corrigida pelas suas degustações';

  @override
  String get estimateDisclaimer =>
      'Estimativa indicativa: depende também de como a garrafa foi guardada';

  @override
  String get estimateUnavailable => 'Estimativa indisponível';

  @override
  String get pairingsTitle => 'Harmonizações';

  @override
  String get pairingsGeneric => 'harmonizações genéricas para o tipo';

  @override
  String get pairingBraisedRedMeat => 'Carne vermelha ensopada';

  @override
  String get pairingGrilledRedMeat => 'Carne vermelha grelhada';

  @override
  String get pairingGame => 'Caça';

  @override
  String get pairingRoastPoultry => 'Aves assadas';

  @override
  String get pairingPoultry => 'Aves';

  @override
  String get pairingPork => 'Carne de porco';

  @override
  String get pairingCuredMeats => 'Frios e embutidos';

  @override
  String get pairingPastaMeatSauce => 'Massa ao ragu';

  @override
  String get pairingMushroomsTruffle => 'Cogumelos e trufas';

  @override
  String get pairingAgedCheese => 'Queijos curados';

  @override
  String get pairingFreshCheese => 'Queijos frescos';

  @override
  String get pairingBlueCheese => 'Queijos azuis';

  @override
  String get pairingFish => 'Peixe';

  @override
  String get pairingSeafood => 'Frutos do mar';

  @override
  String get pairingRawSeafood => 'Frutos do mar crus';

  @override
  String get pairingFriedFood => 'Frituras';

  @override
  String get pairingVegetables => 'Legumes';

  @override
  String get pairingRisotto => 'Risoto';

  @override
  String get pairingPizza => 'Pizza';

  @override
  String get pairingAperitif => 'Aperitivo';

  @override
  String get pairingPastries => 'Confeitaria';

  @override
  String get pairingDryBiscuits => 'Biscoitos secos';

  @override
  String get pairingChocolate => 'Chocolate';

  @override
  String get pairingDriedFruit => 'Frutas secas';

  @override
  String get pairingSpicyDishes => 'Pratos condimentados';

  @override
  String get recentDrinksTitle => 'Últimas degustações';

  @override
  String get noDrinksYet => 'Nenhuma degustação ainda';

  @override
  String get wineEdit => 'Editar';

  @override
  String get wineDelete => 'Excluir';

  @override
  String get wineFinished => 'Terminado: nenhuma garrafa';

  @override
  String get wineLoadFailed => 'Não foi possível abrir o vinho';

  @override
  String get wineNotFound => 'Este vinho não existe mais';

  @override
  String drinkDone(String name) {
    return 'Degustação registrada: $name';
  }

  @override
  String get drinkUndo => 'Desfazer';

  @override
  String get drinkAddNotes => 'Adicionar nota e comentários';

  @override
  String get nothingToUndo => 'Não há mais nada para desfazer';

  @override
  String get cellarUndoRejected =>
      'Desfazer falhou: a garrafa continua marcada como bebida';

  @override
  String get cellarDeleteFailed =>
      'A exclusão ainda não foi concluída: continuará assim que possível';

  @override
  String get duplicateFull =>
      'Este vinho já tem 99 garrafas: não é possível adicionar mais.';

  @override
  String get recordSheetTitle => 'Nota e comentários';

  @override
  String get recordRatingLabel => 'Nota';

  @override
  String ratingStar(int n) {
    return 'Nota $n de 5';
  }

  @override
  String get recordNotesLabel => 'Comentários';

  @override
  String get recordNotesTooLong => 'No máximo 1000 caracteres';

  @override
  String recordDateLabel(String date) {
    return 'Data: $date';
  }

  @override
  String get recordDateInvalid =>
      'A data não pode ser futura nem anterior à safra';

  @override
  String get recordConditionTitle => 'Como estava?';

  @override
  String get conditionTooYoung => 'Ainda muito jovem';

  @override
  String get conditionJustRight => 'No ponto certo';

  @override
  String get conditionPastPeak => 'Já em declínio';

  @override
  String get recordNoCondition => 'Sem resposta';

  @override
  String get producerLabel => 'Produtor (opcional)';

  @override
  String get producerTooLong => 'No máximo 120 caracteres';

  @override
  String producerAddNew(String name) {
    return 'Adicionar «$name» como novo produtor';
  }

  @override
  String get wineTypeLabel => 'Tipo';

  @override
  String get typeRedLight => 'Tinto leve';

  @override
  String get typeRedStructured => 'Tinto encorpado';

  @override
  String get typeWhite => 'Branco';

  @override
  String get typeRose => 'Rosé';

  @override
  String get typeSparklingClassic => 'Espumante método clássico';

  @override
  String get typeSparklingTank => 'Espumante método Charmat';

  @override
  String get typeSweet => 'Doce';

  @override
  String get typeFortified => 'Fortificado';

  @override
  String get suggestionFromCellar => 'Na sua adega';

  @override
  String get suggestionsLabel => 'Sugestões';

  @override
  String get duplicateTitle => 'Já está na adega';

  @override
  String duplicateBody(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count garrafas',
      one: '1 garrafa',
      zero: 'nenhuma garrafa',
    );
    return '$name já está lá, com $_temp0. Adicionar as novas garrafas a ele?';
  }

  @override
  String duplicateAdd(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Adicionar $count garrafas',
      one: 'Adicionar 1 garrafa',
      zero: 'Adicionar $count garrafas',
    );
    return '$_temp0';
  }

  @override
  String get duplicateBanner => 'Possível duplicado';

  @override
  String get duplicateMerge => 'Mesclar';

  @override
  String get duplicateDeleteHint => 'Exclua esta entrada se for um duplicado';

  @override
  String get mergeTitle => 'Mesclar as duas entradas?';

  @override
  String get mergeBody =>
      'As garrafas desta entrada passam para a mais antiga, depois esta entrada é excluída.';

  @override
  String get editWineTitle => 'Editar vinho';

  @override
  String get editDuplicate =>
      'Já existe outro vinho com o mesmo nome, produtor e safra';

  @override
  String deleteWineTitle(String name) {
    return 'Excluir $name?';
  }

  @override
  String get deleteWineBody =>
      'O vinho e todas as suas degustações são excluídos. Não é possível desfazer.';

  @override
  String get historyTitle => 'Histórico';

  @override
  String get historyEmpty => 'Aqui você encontrará as garrafas que bebeu';

  @override
  String get historyLoadFailed => 'Não foi possível carregar o histórico';

  @override
  String drankOnLabel(String date) {
    return 'Bebida em $date';
  }

  @override
  String get addChoiceTitle => 'Adicionar um vinho';

  @override
  String get addChoicePhoto => 'Tirar foto';

  @override
  String get addChoiceImport => 'Importar uma foto';

  @override
  String get addChoiceWrite => 'Escrever';

  @override
  String get labelReading => 'Lendo o rótulo…';

  @override
  String get labelRecognized => 'Reconheci:';

  @override
  String get labelCorrect => 'Corrigir';

  @override
  String get labelConfirm => 'Confirmar';

  @override
  String get labelUnreadable => 'Não consigo ler o rótulo';

  @override
  String get labelWriteByHand => 'Escrever à mão';

  @override
  String get labelNotFound => 'Não encontrei o vinho: confira os dados';

  @override
  String get labelCameraDenied =>
      'Para ler o rótulo preciso de acesso à câmera';

  @override
  String get labelPhotosDenied =>
      'Para ler o rótulo preciso de acesso às fotos';

  @override
  String get labelOpenSettings => 'Abrir configurações';

  @override
  String get labelCameraUnavailable => 'Câmera indisponível';

  @override
  String get labelBarcodeNotFound =>
      'Li o código de barras, mas não encontro o vinho';

  @override
  String get labelBarcodeFrontHint => 'Fotografe a frente do rótulo';

  @override
  String get labelSharedNotAllowed =>
      'Você não pode adicionar vinhos a esta adega';

  @override
  String get labelSharedFirstOnly => 'Usei só a primeira foto';

  @override
  String get labelSharedExpired =>
      'Não foi possível ler a foto compartilhada: compartilhe de novo';

  @override
  String get labelReplaceTitle =>
      'Você tem um vinho não salvo. Quer ler a nova foto?';

  @override
  String get labelReplaceRead => 'Ler a nova foto';

  @override
  String get labelReplaceKeep => 'Continuar com o aberto';

  @override
  String get labelWineAdded => 'Vinho adicionado à adega';

  @override
  String get onboardingPage1Title => 'Sua adega no bolso';

  @override
  String get onboardingPage1Body =>
      'Adicione as garrafas digitando ou com uma foto do rótulo, mesmo sem internet.';

  @override
  String get onboardingPage2Title => 'No momento certo';

  @override
  String get onboardingPage2Body =>
      'O Vinoozy estima quando cada vinho está no auge e diz quais abrir primeiro.';

  @override
  String get onboardingPage3Title => 'Juntos';

  @override
  String get onboardingPage3Body =>
      'Compartilhe a adega com até duas pessoas e guarde o histórico de cada garrafa bebida.';

  @override
  String get onboardingSkip => 'Pular';

  @override
  String get onboardingNext => 'Avançar';

  @override
  String get onboardingStart => 'Começar';

  @override
  String onboardingPageOf(int page) {
    return 'Página $page de 3';
  }

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profilePhoto => 'Foto do perfil';

  @override
  String get profileSignOut => 'Sair';

  @override
  String get profileDeleteAccount => 'Excluir conta';

  @override
  String get profilePrivacy => 'Política de privacidade';

  @override
  String get profilePrivacyBody =>
      'Você pode ler a política de privacidade neste endereço:';

  @override
  String get profileOpenLink => 'Abrir no navegador';

  @override
  String get profileOpenLinkFailed =>
      'Não foi possível abrir a página. Você pode copiar o link e abri-lo no navegador.';

  @override
  String get profileCopyLink => 'Copiar link';

  @override
  String get profileLinkCopied => 'Link copiado';

  @override
  String get close => 'Fechar';

  @override
  String get signOutConfirmTitle => 'Quer sair?';

  @override
  String signOutPendingWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Você tem $count alterações ainda não salvas. Se sair e outra conta entrar, elas serão perdidas.',
      one: 'Você tem 1 alteração ainda não salva. Se sair e outra conta entrar, ela será perdida.',
      zero:
          'Você tem $count alterações ainda não salvas. Se sair e outra conta entrar, elas serão perdidas.',
    );
    return '$_temp0';
  }

  @override
  String get signOutStayAndSync => 'Ficar e sincronizar';

  @override
  String get signOutAnyway => 'Sair mesmo assim';

  @override
  String get syncAllSaved => 'Tudo salvo';

  @override
  String syncStillPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ainda $count alterações para salvar: verifique a internet',
      one: 'Ainda 1 alteração para salvar: verifique a internet',
      zero: 'Ainda $count alterações para salvar: verifique a internet',
    );
    return '$_temp0';
  }

  @override
  String get signOutFailed => 'Não foi possível sair. Tente novamente';

  @override
  String get signInAccountDeleted => 'Conta excluída';

  @override
  String get deleteAccountIntro => 'Serão excluídos para sempre:';

  @override
  String get deleteAccountItemCellar =>
      'Sua adega, com os vinhos e o Histórico';

  @override
  String get deleteAccountItemShares =>
      'Os compartilhamentos que você deu: as pessoas convidadas perdem o acesso';

  @override
  String get deleteAccountItemMemberships =>
      'Sua participação nas adegas de outras pessoas: suas degustações ficam lá sem o seu nome';

  @override
  String get deleteAccountItemProfile => 'Seu perfil';

  @override
  String deleteAccountPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Você tem $count alterações ainda não salvas: elas serão salvas e depois excluídas com o resto',
      one: 'Você tem 1 alteração ainda não salva: ela será salva e depois excluída com o resto',
      zero:
          'Você tem $count alterações ainda não salvas: elas serão salvas e depois excluídas com o resto',
    );
    return '$_temp0';
  }

  @override
  String get deleteAccountConfirmWord => 'EXCLUIR';

  @override
  String deleteAccountTypeWord(String word) {
    return 'Digite $word para confirmar';
  }

  @override
  String get deleteAccountReauthHint =>
      'Depois você vai entrar de novo com o Google para confirmar que é você.';

  @override
  String get deleteAccountForever => 'Excluir para sempre';

  @override
  String get deleteAccountNeedsNetwork =>
      'Conecte-se à internet para excluir a conta';

  @override
  String get deleteAccountSameAccount =>
      'A exclusão exige entrar com a mesma conta';

  @override
  String get deletionTitle => 'Excluindo a conta';

  @override
  String get deletionStepPreparePhone => 'Salvando as alterações pendentes';

  @override
  String get deletionStepMarkStarted => 'Iniciando a exclusão';

  @override
  String get deletionStepLeaveOtherCellars =>
      'Saindo das adegas de outras pessoas';

  @override
  String get deletionStepCloseOwnInvitations =>
      'Encerrando seus compartilhamentos';

  @override
  String get deletionStepDeleteWinesAndRecords =>
      'Excluindo vinhos e Histórico';

  @override
  String get deletionStepDeleteCellar => 'Excluindo a adega';

  @override
  String get deletionStepDeleteProfileAndUser => 'Excluindo o perfil e a conta';

  @override
  String get deletionStepCleanUpPhone => 'Limpando este celular';

  @override
  String deletionStepAnnounce(int step, String label) {
    return 'Passo $step de 8: $label';
  }

  @override
  String deletionDeletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vinhos e degustações excluídos',
      one: '1 vinho ou degustação excluído',
      zero: '$count vinhos e degustações excluídos',
    );
    return '$_temp0';
  }

  @override
  String get deletionResumeHint =>
      'A exclusão desta conta não terminou. Entre de novo com o Google para concluí-la.';

  @override
  String get deletionContinue => 'Continuar';

  @override
  String get deletionOffline =>
      'Conecte-se à internet para concluir a exclusão';

  @override
  String get deletionPendingWrites =>
      'Não consigo salvar as alterações pendentes. Tente novamente';

  @override
  String get deletionFailed =>
      'Não foi possível concluir a exclusão. Tente novamente';

  @override
  String get uxCountryLabel => 'País';

  @override
  String get uxCountryOther => 'Outro país…';

  @override
  String get uxCountryNone => 'Nenhum país';

  @override
  String get uxAllCountriesTitle => 'Todos os países e territórios';

  @override
  String get uxAllCountriesSearch => 'Buscar um país';

  @override
  String get uxAllCountriesRare => 'Raros para o vinho';

  @override
  String get uxAllCountriesAll => 'Todos, de A a Z';

  @override
  String get uxAllCountriesNone => 'Nenhum país encontrado';

  @override
  String get uxRegionLabel => 'Região';

  @override
  String uxRegionOf(String country) {
    return 'Região · $country';
  }

  @override
  String get uxRegionOther => 'Outra região';

  @override
  String get uxRegionFieldLabel => 'Escreva a região';

  @override
  String get uxRegionTooLong => 'No máximo 120 caracteres';

  @override
  String get uxDrinkAction => 'Bebi uma';

  @override
  String uxDrinkActionTooltip(String name) {
    return 'Bebi uma garrafa de $name';
  }

  @override
  String get uxDrinkActionDetail => 'Bebi uma garrafa';

  @override
  String get uxDrinkSheetLabel => 'Confirmar o consumo';

  @override
  String get uxDrinkSheetBottles => 'Garrafas';

  @override
  String uxDrinkSheetBottlesChange(int before, int after) {
    return 'Garrafas: de $before para $after';
  }

  @override
  String get uxDrinkSheetRating => 'Como estava? (opcional)';

  @override
  String uxDrinkSheetStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count estrelas de 5',
      one: '1 estrela de 5',
      zero: '$count estrelas de 5',
    );
    return '$_temp0';
  }

  @override
  String get uxDrinkSheetConfirm => 'Sim, eu bebi';

  @override
  String get uxRemoveBottle => 'Tirar uma garrafa sem registrar consumo';

  @override
  String get uxRemoveBottleTitle => 'Tirar uma garrafa?';

  @override
  String uxRemoveBottleBody(String name) {
    return 'Uma garrafa de $name é retirada sem registrar um consumo.';
  }

  @override
  String get uxRemoveBottleConfirm => 'Tirar';

  @override
  String get uxIdealTitle => 'Momento ideal';

  @override
  String uxIdealUntil(String year) {
    return 'Recomendado até $year';
  }

  @override
  String uxIdealUntilPast(String year) {
    return 'Recomendado até $year: já passou';
  }

  @override
  String uxIdealBest(String start, String end) {
    return 'No seu melhor de $start a $end';
  }

  @override
  String uxIdealBar(String start, String end) {
    return 'Janela de consumo de $start a $end';
  }

  @override
  String get uxIdealDisclaimer =>
      '⚠︎ Indicativo: é uma estimativa baseada em tipo, denominação e safra. A conservação e cada garrafa podem mudá-la.';

  @override
  String get uxIdealUnavailableHint =>
      'Informe a safra e o tipo para ter uma estimativa.';

  @override
  String uxDashboardDrinkNow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count para beber agora',
      one: '1 para beber agora',
      zero: '$count para beber agora',
    );
    return '$_temp0';
  }

  @override
  String get uxFamilyRed => 'Tinto';

  @override
  String get uxFamilyWhite => 'Branco';

  @override
  String get uxFamilyRose => 'Rosé';

  @override
  String get uxFamilySparkling => 'Espumante';

  @override
  String get uxFamilySweet => 'Doce';

  @override
  String get labelBackTitle => 'Agora o verso';

  @override
  String get labelBackHint =>
      'No verso geralmente estão o código de barras, o produtor e a safra: ajudam a encontrar o vinho.';

  @override
  String get labelBackTake => 'Fotografar o verso';

  @override
  String get labelBackGallery => 'Escolher da galeria';

  @override
  String get labelBackSkip => 'Pular';

  @override
  String get labelStepFront => 'Frente';

  @override
  String get labelStepBack => 'Verso';

  @override
  String get labelStepBarcode => 'Código de barras';

  @override
  String get labelStepDatabase => 'Base de vinhos no celular';

  @override
  String get labelStepPending => 'Aguardando';

  @override
  String get labelStepRunning => 'Em andamento…';

  @override
  String get labelStepDone => 'Pronto';

  @override
  String get labelStepSkipped => 'Pulado';

  @override
  String get labelStepFailed => 'Ilegível';

  @override
  String labelStepStatus(String step, String status) {
    return '$step: $status';
  }

  @override
  String get labelOnPhoneNote =>
      'Tudo acontece no celular: as fotos não são enviadas a ninguém.';

  @override
  String get labelBackUnreadable => 'Verso ilegível';

  @override
  String get labelSourceOffline => 'Da base no celular · offline';

  @override
  String get labelSourceCatalog => 'Do catálogo';

  @override
  String get labelSourceOnline => 'Do Open Food Facts · online';

  @override
  String get labelNotThis => 'Não é este';

  @override
  String get labelOffAttribution => 'Dados do Open Food Facts, licença ODbL';

  @override
  String get labelCandidatesTitle => 'Qual destes?';

  @override
  String labelCandidatesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vinhos parecidos',
      one: '1 vinho parecido',
      zero: '$count vinhos parecidos',
    );
    return '$_temp0';
  }

  @override
  String get labelCandidatesNone => 'Nenhum destes';

  @override
  String get labelChipOffline => 'offline';

  @override
  String get labelChipOnline => 'online';

  @override
  String get labelChipCatalog => 'catálogo';

  @override
  String get labelNoProducer => 'produtor não informado';

  @override
  String get labelNoMatch => 'Li o rótulo, mas não reconheço o vinho';

  @override
  String get labelReadText => 'Texto lido';

  @override
  String get labelSearchOnline => 'Buscar online';

  @override
  String get labelOpenLens => 'Abrir no Google Lens';

  @override
  String get labelLensLastResort =>
      'O Google Lens é a última opção: a foto vai para o app Google só se você confirmar.';

  @override
  String get labelLensTitle => 'Abrir no Google Lens?';

  @override
  String get labelLensBody =>
      'A foto da frente vai para o app Google no seu celular, ou para o app que você escolher, que pode guardar uma cópia segundo as regras dele. O Vinoozy não recebe os resultados: volte aqui para escolher ou escrever o vinho.';

  @override
  String get labelLensConfirm => 'Abrir o Google Lens';

  @override
  String get labelLensFailed =>
      'Não foi possível abrir o Google Lens nem o menu Compartilhar';

  @override
  String get onlineSearchTitle => 'Buscar online';

  @override
  String get onlineSearchSubtitle => 'Open Food Facts · só vinhos';

  @override
  String get onlineSearchField => 'Palavras para buscar';

  @override
  String get onlineSearchHint => 'Você pode mudar as palavras antes de buscar.';

  @override
  String get onlineSearchEmptyField => 'Escreva pelo menos uma palavra';

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
      zero: '$count resultados',
    );
    return '$_temp0';
  }

  @override
  String get onlineSearchEmpty =>
      'Nenhum vinho encontrado: tente outras palavras ou \"Escrever à mão\".';

  @override
  String get onlineSearchOffline => 'Sem rede: busco só na base do celular.';

  @override
  String get onlineSearchRateLimited =>
      'A busca online não está disponível agora, tente de novo em alguns minutos.';

  @override
  String get onlineSearchUnavailable =>
      'A busca online não está ativa nesta versão do app: busco só na base do celular.';

  @override
  String get aboutTitle => 'Sobre';

  @override
  String aboutVersion(String version) {
    return 'Versão $version';
  }

  @override
  String get aboutDbTitle => 'Base de vinhos';

  @override
  String aboutDbCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vinhos',
      one: '1 vinho',
      zero: '$count vinhos',
    );
    return '$_temp0';
  }

  @override
  String aboutDbDate(String date) {
    return 'Exportação do Open Food Facts de $date';
  }

  @override
  String get aboutDbSample =>
      'Base de teste: poucos vinhos de teste escritos à mão, não dados do Open Food Facts.';

  @override
  String get aboutDbLoading => 'Abrindo a base de vinhos…';

  @override
  String get aboutDbUnavailable =>
      'A base de vinhos não está disponível nesta versão';

  @override
  String aboutDbSource(String url) {
    return 'A base derivada e a ferramenta que a gera estão no repositório público: $url';
  }

  @override
  String get aboutLicenseTitle => 'Licenças';

  @override
  String get aboutLicense =>
      'Contém informações do Open Food Facts, disponibilizadas sob a Open Database License (ODbL). Os conteúdos individuais estão sob a Database Contents License (DbCL).';

  @override
  String get aboutPrivacyTitle => 'Fotos dos rótulos';

  @override
  String get aboutPrivacy =>
      'As fotos dos rótulos são lidas no celular e apagadas quando você sai do resultado. Só saem do celular se você tocar em \"Abrir no Google Lens\" e confirmar.';

  @override
  String get aboutAppellationsTitle => 'Denominações';

  @override
  String get aboutAppellationsSource =>
      'Denominações: registro eAmbrosia (UE) e registros oficiais nacionais.';

  @override
  String get aboutAppellationsSample =>
      'Tabela de teste: um extrato dos registros escrito à mão, até baixar os registros reais.';

  @override
  String get denominationLabel => 'Denominação';

  @override
  String get denominationTooLong => 'No máximo 120 caracteres';

  @override
  String get autofillFilledNotice => 'Preenchido pelo rótulo: confira e salve';

  @override
  String get autofillPastedNotice => 'Preenchido pelo texto: confira e salve';

  @override
  String get autofillFromText => '✦ do texto';

  @override
  String get autofillFromTextSemantics => 'preenchido pelo rótulo';

  @override
  String get autofillClear => 'Limpar';

  @override
  String get autofillLens => 'Lens';

  @override
  String get autofillClearTitle => 'Limpar o formulário?';

  @override
  String get autofillClearBody =>
      'Você também escreveu em alguns campos. \"Limpar\" esvazia nome, produtor, denominação, safra, tipo, país, região e nível. A quantidade fica.';

  @override
  String get autofillClearConfirm => 'Limpar';

  @override
  String get autofillCleared => 'Formulário limpo';

  @override
  String get autofillPasteTitle => 'Você tem o texto do Google Lens?';

  @override
  String get autofillPasteHint =>
      'No Lens selecione o texto do rótulo e toque em \"Copiar\", depois volte aqui.';

  @override
  String get autofillPaste => 'Colar do Lens';

  @override
  String get autofillOpenLens => 'Do Google Lens';

  @override
  String get autofillOpenLensSemantics => 'abre o Google Lens';

  @override
  String get autofillClipboardEmpty => 'Não há texto na área de transferência';

  @override
  String get autofillNoNewFields =>
      'Não encontrei dados para adicionar no texto';

  @override
  String get autofillFromLens => 'Formulário preenchido com o texto do Lens';

  @override
  String get autofillShareEmpty => 'Nenhum texto recebido';

  @override
  String get autofillShareUseTitle => 'Usar o texto nos campos vazios?';

  @override
  String get autofillShareUse => 'Usar';

  @override
  String get autofillShareIgnore => 'Ignorar';

  @override
  String get addChoiceLens => 'Do Google Lens';

  @override
  String get addChoicePhotoHint => 'Frente e verso: o Vinoozy lê o rótulo.';

  @override
  String get addChoiceLensHint =>
      'Abre o Lens: enquadre, selecione o texto e toque em Compartilhar → Vinoozy.';

  @override
  String get addChoiceImportHint => 'Uma foto do rótulo já tirada.';

  @override
  String get addChoiceWriteHint => 'Formulário vazio, com \"Colar do Lens\".';

  @override
  String get lensInstructionsTitle => 'Daqui o Google Lens não abre';

  @override
  String get lensInstructionsStep1 => 'Abra o Google Lens e enquadre o rótulo';

  @override
  String get lensInstructionsStep2 => 'Selecione o texto do rótulo';

  @override
  String get lensInstructionsStep3 => 'Toque em Compartilhar → Vinoozy';

  @override
  String get lensInstructionsOk => 'Entendi';

  @override
  String get levelLabel => 'Nível';

  @override
  String get levelEveryday => 'Cotidiano (econômico)';

  @override
  String get levelGood => 'Bom';

  @override
  String get levelAging => 'Para envelhecer';

  @override
  String get levelNone => 'Nenhum';

  @override
  String get levelEverydayShort => 'beber cedo';

  @override
  String get levelGoodShort => 'estimativa normal';

  @override
  String get levelAgingShort => 'dura mais';

  @override
  String get levelSuggested => 'sugerido';

  @override
  String levelSuggestedReason(String qualifier) {
    return 'Sugerido porque o nome contém \"$qualifier\": é salvo assim se você não mudar. Escolha outro ou toque em \"Nenhum\".';
  }

  @override
  String levelSuggestedSemantics(String qualifier) {
    return 'sugerido, porque o nome contém $qualifier';
  }

  @override
  String levelOptionSemantics(String option, int index, int count) {
    return 'Nível, $option, $index de $count';
  }

  @override
  String get levelWhatChanges => 'O que muda';

  @override
  String get levelEverydayExamples =>
      'A janela fica mais curta. Ex. vinho da casa, Lambrusco, Prosecco básico, Bardolino, Vinho Verde.';

  @override
  String get levelGoodExamples =>
      'A estimativa normal, e o valor se você não escolher nada. Ex. Chianti Classico, Barbera d\'Asti Superiore, Rioja Crianza, Côtes du Rhône.';

  @override
  String get levelAgingExamples =>
      'A janela fica mais longa. Ex. Barolo, Brunello, Amarone, Bordeaux Grand Cru, Rioja Gran Reserva, Porto Vintage.';

  @override
  String levelPreviewBefore(String start, String end) {
    return 'Antes $start – $end';
  }

  @override
  String levelPreviewWith(String level, String start, String end) {
    return 'Com \"$level\" $start – $end';
  }

  @override
  String levelPreviewNow(String start, String end) {
    return 'Pronto $start – até $end';
  }

  @override
  String levelDetail(String level) {
    return 'Nível: $level';
  }

  @override
  String get overrideCorrect => 'Corrigir';

  @override
  String get overrideRestore => 'Restaurar estimativa';

  @override
  String get overrideCorrectedByYou => 'corrigido por você';

  @override
  String overrideAppEstimate(String year) {
    return 'Estimativa do app: até $year';
  }

  @override
  String get overrideSheetTitle => 'Recomendado até';

  @override
  String overrideSheetHint(String start) {
    return 'Escolha o ano. Não pode ser antes de \"Pronto a partir de $start\".';
  }

  @override
  String overridePeakNotice(String peak) {
    return 'Se você escolher um ano antes de $peak (no auge), \"no auge\" também passa para o mesmo ano.';
  }

  @override
  String get overrideMore => 'mais…';

  @override
  String get overrideSave => 'Salvar correção';

  @override
  String overrideRestoreTitle(String year) {
    return 'Voltar para a estimativa do app (até $year)?';
  }

  @override
  String get overrideRestoreConfirm => 'Restaurar';

  @override
  String get overrideSaved => 'Correção salva';

  @override
  String get overrideRestored => 'Estimativa restaurada';

  @override
  String get estimateSourceCorrectedByYou => 'corrigida por você';

  @override
  String estimateFromDenomination(String name) {
    return 'Estimativa pela denominação $name';
  }

  @override
  String estimateFromDenominationQualifier(String name, String qualifier) {
    return 'Estimativa pela denominação $name, $qualifier';
  }

  @override
  String estimateFromGrape(String name) {
    return 'Estimativa pela uva $name';
  }

  @override
  String get estimateFromType => 'Estimativa pelo tipo de vinho';

  @override
  String get autofillReading => 'Lendo o texto…';

  @override
  String get guideChip => 'Confirmação guiada';

  @override
  String guideProgress(int n, int total) {
    return 'Pergunta $n de $total';
  }

  @override
  String get guideClose => 'Fechar';

  @override
  String get guideIsDenomination => 'é a denominação?';

  @override
  String get guideIsProducer => 'é o produtor?';

  @override
  String get guideIsName => 'é o nome do vinho?';

  @override
  String get guideIsVintage => 'Safra';

  @override
  String guideAskDenomination(String value) {
    return '$value é a denominação?';
  }

  @override
  String guideAskProducer(String value) {
    return '$value é o produtor?';
  }

  @override
  String guideAskName(String value) {
    return '$value é o nome do vinho?';
  }

  @override
  String get guideAskVintage => 'Qual é a safra?';

  @override
  String guideQuestionSemantics(int n, int total, String question) {
    return 'Pergunta $n de $total: $question';
  }

  @override
  String get guideNoProposal => 'Não encontrei no texto';

  @override
  String get guideYes => 'Sim';

  @override
  String get guideNo => 'Não, outra';

  @override
  String get guideEdit => 'Editar';

  @override
  String get guideSkip => 'Pular';

  @override
  String get guideConfirm => 'Confirmar';

  @override
  String get guideCancel => 'Cancelar';

  @override
  String guideRejected(String value) {
    return '\"$value\" não: aqui está o próximo';
  }

  @override
  String get guideNoMore => 'Nenhuma outra sugestão: componha ou pule';

  @override
  String guideProposalAnnounce(String value) {
    return 'Sugestão: $value';
  }

  @override
  String get guideComposeLabel => 'Ou monte tocando as palavras do texto';

  @override
  String get guideComposePreview => 'Prévia';

  @override
  String get guideComposeEmpty => 'Toque em uma ou mais palavras';

  @override
  String get guideComposeLimit => 'No máximo 8 palavras e 80 caracteres';

  @override
  String guideTableMatchSemantics(String name) {
    return 'corresponde a $name';
  }

  @override
  String guideLine(int n, int total) {
    return 'Linha $n de $total';
  }

  @override
  String guideWordSelected(String word, int order) {
    return '$word, selecionada, $order';
  }

  @override
  String guideWordUnavailable(String word) {
    return '$word, indisponível';
  }

  @override
  String guideWordUsedFor(String word, String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'na denominação',
      'producer': 'no produtor',
      'other': 'no nome',
    });
    return '$word, usada $_temp0';
  }

  @override
  String guideUsedMark(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'denominação',
      'producer': 'produtor',
      'other': 'nome',
    });
    return '$_temp0';
  }

  @override
  String guideOtherYears(String years) {
    return 'Também no texto: $years';
  }

  @override
  String get guideWheelFromText => 'ano encontrado no texto';

  @override
  String get guideWheelTypeYear => 'Digite o ano';

  @override
  String guideWheelConfirm(String year) {
    return 'Confirmar $year';
  }

  @override
  String get guideNoVintage => 'Sem safra';

  @override
  String guideSkippedNotice(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'Denominação pulada',
      'producer': 'Produtor pulado',
      'vintage': 'Safra pulada',
      'other': 'Nome pulado',
    });
    return '$_temp0: digite ou retome o guia';
  }

  @override
  String guideSkippedMany(int count) {
    return '$count campos pulados: digite-os ou retome o guia';
  }

  @override
  String get guideInvalidValue =>
      'O texto contém caracteres que não podem ser salvos';

  @override
  String get brandStudio => 'Bottazzini Softworks';

  @override
  String get suggestedMark => '✦ sugerido';

  @override
  String suggestedSemantics(String field, String value) {
    return '$field, $value, sugerido';
  }

  @override
  String get restoreSuggestion => 'Restaurar sugestão';

  @override
  String get restoreSuggestionDone => 'Sugestão restaurada';

  @override
  String get styleLabel => 'Estilo';

  @override
  String styleGroupSemantics(String value, int index, int count) {
    return 'Estilo, $value, $index de $count';
  }

  @override
  String get styleRedFresh => 'Fresco';

  @override
  String get styleRedMedium => 'Médio';

  @override
  String get styleRedAge => 'Para envelhecer';

  @override
  String get styleRedLong => 'Longa guarda';

  @override
  String get styleWhiteFresh => 'Fresco';

  @override
  String get styleWhiteMedium => 'Médio';

  @override
  String get styleWhiteAge => 'Para envelhecer';

  @override
  String get styleRoseFresh => 'Fresco';

  @override
  String get styleClassicFresh => 'Fresco';

  @override
  String get styleClassicAge => 'Para envelhecer';

  @override
  String get styleTankFresh => 'Fresco';

  @override
  String get styleLambrusco => 'Lambrusco';

  @override
  String get styleSweetAromatic => 'Aromático';

  @override
  String get styleSweetPassito => 'Passito';

  @override
  String get styleSweetBotrytis => 'Botritizado';

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
  String get styleFortifiedOther => 'Outro';

  @override
  String get profileNameRFresh => 'Tinto frutado';

  @override
  String get profileNameRMedium => 'Tinto de corpo médio';

  @override
  String get profileNameRAge => 'Tinto para envelhecer';

  @override
  String get profileNameRLong => 'Tinto de longa guarda';

  @override
  String get profileNameWFresh => 'Branco fresco e aromático';

  @override
  String get profileNameWMedium => 'Branco de corpo médio';

  @override
  String get profileNameWAge => 'Branco para envelhecer';

  @override
  String get profileNameRoseFresh => 'Rosé fresco';

  @override
  String get profileNameSpTank => 'Espumante Charmat fresco';

  @override
  String get profileNameLamFresh => 'Lambrusco fresco';

  @override
  String get profileNameSpClassic => 'Método tradicional fresco';

  @override
  String get profileNameSpClassicAge => 'Método tradicional para envelhecer';

  @override
  String get profileNameSwAromatic => 'Doce aromático jovem';

  @override
  String get profileNameSwPassito => 'Passito para envelhecer';

  @override
  String get profileNameSwBotrytis => 'Doce botritizado';

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
  String get profileNameShPx => 'Xerez Pedro Ximénez';

  @override
  String get profileNameFortUnknown => 'Fortificado a definir';

  @override
  String get profileNameUnknown => 'Estilo não identificado';

  @override
  String estimateFromProfile(String profile, String denomination) {
    return 'Estimativa pelo perfil $profile ($denomination)';
  }

  @override
  String estimateFromProfileType(String profile) {
    return 'Estimativa pelo perfil $profile, pelo tipo';
  }

  @override
  String estimateFromProfileGrape(String profile, String grape) {
    return 'Estimativa pelo perfil $profile, pela uva $grape';
  }

  @override
  String get estimateFromEntryDateDisgorgement =>
      'Pela data de inclusão: adicione o dégorgement para uma estimativa melhor';

  @override
  String get estimateFromEntryDateBottling =>
      'Pela data de inclusão: adicione o engarrafamento para uma estimativa melhor';

  @override
  String get styleToConfirmBanner =>
      '⚠︎ Estilo a confirmar: a estimativa é indicativa';

  @override
  String get chooseTypePrompt => 'Escolha o tipo';

  @override
  String estimateUpdatedAnnouncement(String summary) {
    return 'Estimativa atualizada: $summary';
  }

  @override
  String get agingStartDisgorgement => 'Dégorgement';

  @override
  String get agingStartBottling => 'Engarrafamento';

  @override
  String get agingStartMonth => 'Mês';

  @override
  String get agingStartYear => 'Ano';

  @override
  String get agingStartHint => 'Geralmente está no rótulo de trás.';

  @override
  String get agingStartIncomplete => 'Informe mês e ano';

  @override
  String get agingStartFuture => 'A data não pode estar no futuro';

  @override
  String get agingStartBeforeVintage => 'Não pode ser anterior à safra';

  @override
  String get windowNoEnd => 'Pronto, sem fim estimado';

  @override
  String get windowNoEndShort => 'sem fim estimado';

  @override
  String windowDrinkWithin(String date) {
    return 'até $date';
  }

  @override
  String get levelNoEffect => 'O nível não altera esta estimativa';

  @override
  String get dashboardToConfirmTitle => 'A confirmar';

  @override
  String dashboardToConfirmCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vinhos',
      one: '1 vinho',
      zero: '$count vinhos',
    );
    return '$_temp0';
  }

  @override
  String aboutDbClassified(String percent) {
    return '$percent% dos vinhos com o tipo reconhecido';
  }

  @override
  String get planTitle => 'Plano';

  @override
  String get planFree => 'Gratuito';

  @override
  String get planPlus => 'Plus';

  @override
  String get planPlusGift => 'Plus de presente';

  @override
  String get planDevUnlockAll => 'DEV · Plus de teste';

  @override
  String get planDevSimulateFree => 'DEV · Plano gratuito simulado';

  @override
  String get planDevSimulateExpired => 'DEV · Plus expirado simulado';

  @override
  String get planDiscoverPlus => 'Conheça o Plus';

  @override
  String get plusTitle => 'Vinoozy Plus';

  @override
  String get plusBenefitsTitle => 'Com o Plus';

  @override
  String get plusBenefitNoAds => 'Sem anúncios';

  @override
  String get plusBenefitNoLimit => 'Sem limite de vinhos na adega';

  @override
  String get plusComingSoon => 'O Plus chegará em breve';

  @override
  String get plusLoading => 'Lendo os preços no Google Play';

  @override
  String get plusStoreUnavailable =>
      'Não foi possível ler os preços no Google Play. Tente novamente mais tarde.';

  @override
  String plusPriceMonthly(String price) {
    return '$price por mês';
  }

  @override
  String plusPriceAnnual(String price) {
    return '$price por ano';
  }

  @override
  String get plusRenewal =>
      'A assinatura é renovada automaticamente pelo preço indicado até você cancelá-la no Google Play.';

  @override
  String get plusTerms =>
      'O pagamento é cobrado na sua conta do Google Play quando você confirma a compra. Você pode cancelar a qualquer momento: o Plus continua ativo até o fim do período já pago. Quando o Plus termina, todos os seus vinhos continuam.';

  @override
  String get plusRestore => 'Restaurar compras';

  @override
  String get plusManage => 'Gerenciar ou cancelar a assinatura no Google Play';

  @override
  String get plusActive => 'O Plus está ativo nesta conta';

  @override
  String get plusActiveGift =>
      'Você tem o Plus de presente: sem cobranças e sem renovações.';

  @override
  String get plusPending =>
      'Pagamento pendente: o Plus será ativado quando o Google Play confirmar.';

  @override
  String get plusVerifying => 'Verificando a compra';

  @override
  String get plusVerified =>
      'Compra verificada: o Plus será ativado em poucos segundos.';

  @override
  String get plusPurchaseFailed =>
      'A compra não foi concluída. Tente novamente.';

  @override
  String get plusInvalidPurchase =>
      'O Google Play não confirmou esta compra para o Vinoozy.';

  @override
  String get plusOwnedByOther =>
      'Esta assinatura já pertence a outra conta do Vinoozy.';

  @override
  String get plusVerificationUnavailable =>
      'Não foi possível verificar a compra agora. Tente novamente mais tarde: a assinatura continua no Google Play.';

  @override
  String get capacityLimitTitle => 'Você atingiu o limite do plano gratuito';

  @override
  String capacityLimitBody(int limit) {
    return 'O plano gratuito inclui até $limit vinhos diferentes na adega. Você sempre pode editar, beber e adicionar garrafas aos vinhos que já tem. Para adicionar um novo, termine ou exclua um vinho, ou passe para o Plus.';
  }

  @override
  String capacityLimitBodyComingSoon(int limit) {
    return 'O plano gratuito inclui até $limit vinhos diferentes na adega. Você sempre pode editar, beber e adicionar garrafas aos vinhos que já tem. Para adicionar um novo, termine ou exclua um vinho. O Plus chegará em breve.';
  }

  @override
  String get rejectedCapacityLimit =>
      'Não sincronizado: ultrapassa o limite de vinhos do plano gratuito. A alteração fica neste celular.';

  @override
  String get rejectedCapacityConflict =>
      'Não sincronizado: a adega mudou em outro dispositivo ao mesmo tempo. A alteração fica neste celular: tente novamente.';

  @override
  String writeRejectedCapacityLimit(String name) {
    return '$name: não sincronizado, ultrapassa o limite do plano gratuito';
  }

  @override
  String writeRejectedCapacityConflict(String name) {
    return '$name: não sincronizado, a adega mudou em outro dispositivo';
  }

  @override
  String get freeIntroTitle => 'O plano gratuito';

  @override
  String freeIntroLimit(int limit) {
    return 'Você pode gerenciar gratuitamente até $limit vinhos diferentes.';
  }

  @override
  String get freeIntroAds =>
      'O uso leve é sem anúncios. Se você ultrapassar o limite mensal de uso do serviço, poderá ver anúncios ocasionais que ajudam a cobrir os custos dos servidores e da sincronização.';

  @override
  String get freeIntroNoAds => 'Sem anúncios na versão de lançamento.';

  @override
  String get freeIntroPlus =>
      'Com o Plus você elimina os anúncios e o limite da adega.';

  @override
  String get noticeGotIt => 'Entendi';

  @override
  String get thresholdTitle => 'Os anúncios ajudam a manter o Vinoozy gratuito';

  @override
  String get thresholdBody =>
      'Você atingiu o limite mensal de uso sem anúncios. A partir de agora poderá ver anúncios ocasionais: eles nos ajudam a cobrir os custos dos servidores e da sincronização, mantendo o Vinoozy gratuito.';

  @override
  String get thresholdReset =>
      'A contagem recomeça no próximo mês. Com o Plus você pode usar o app sem anúncios e sem o limite da adega.';

  @override
  String thresholdNextReset(String date) {
    return 'Próximo reinício: $date';
  }

  @override
  String get thresholdHowItWorks => 'Como funciona';

  @override
  String get thresholdHowItWorksBody =>
      'O limite depende de uma estimativa das sincronizações com a nuvem feitas por esta conta no mês. O uso offline, sozinho, não gera novas operações na nuvem. Os anúncios aparecem no máximo uma vez por dia, só no Painel, e nunca enquanto você salva ou exporta seus dados.';

  @override
  String get adLabel => 'Anúncio';

  @override
  String get devToolsTitle => 'Ferramentas de desenvolvedor';

  @override
  String get devUnlockAll => 'Desbloquear tudo — Plus de teste';

  @override
  String get devSimulateFree => 'Simular plano gratuito';

  @override
  String get devSimulateExpired => 'Simular Plus expirado';

  @override
  String get devRestore => 'Restaurar estado normal';

  @override
  String get devNoOverride => 'Nenhuma simulação ativa';

  @override
  String get devApplied => 'Cenário aplicado também no emulador do Firestore';

  @override
  String get devIncomplete =>
      'Simulação incompleta: o emulador do Firestore não confirmou o direito de teste. As regras do servidor não veem este cenário.';

  @override
  String get devNotice =>
      'Somente builds de desenvolvimento com o emulador: nenhum pagamento, token ou recibo.';
}
