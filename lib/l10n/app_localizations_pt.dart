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
  String get signInTagline => 'Your cellar, at the right time';

  @override
  String get signInWithGoogle => 'Continue with Google';

  @override
  String get signInInProgress => 'Signing in';

  @override
  String get signInFailed => 'Sign-in failed';

  @override
  String get signInNeedsNetwork =>
      'You need a connection for the first sign-in';

  @override
  String get signInSessionExpired => 'Your session has expired: sign in again';

  @override
  String get retry => 'Try again';

  @override
  String get cancel => 'Cancel';

  @override
  String blockedMessage(String email) {
    return 'There are changes by $email not yet saved to the cloud: sign in with that account and connect to the network';
  }

  @override
  String blockedSignInWith(String email) {
    return 'Sign in with $email';
  }

  @override
  String blockedDiscard(String email) {
    return 'Delete unsaved changes by $email';
  }

  @override
  String get discardDialogTitle => 'Delete the changes?';

  @override
  String discardDialogBody(int count, String email) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count wines by $email are not in the cloud yet and will be deleted from this phone.',
      one:
          '1 wine by $email is not in the cloud yet and will be deleted from this phone.',
    );
    return '$_temp0';
  }

  @override
  String get discardConfirm => 'Delete';

  @override
  String get resetFailed => 'Could not clear the data on this phone';

  @override
  String get restartRequired => 'Restart the app to finish';

  @override
  String get restartCloseApp => 'Close the app';

  @override
  String get startupFailed => 'The app could not start';

  @override
  String get cellarTitle => 'Cellar';

  @override
  String get defaultCellarName => 'My cellar';

  @override
  String get cellarLoading => 'Preparing the cellar';

  @override
  String get cellarSetupFailed => 'Could not prepare the cellar';

  @override
  String get cellarEmpty => 'Your cellar is empty';

  @override
  String get addWine => 'Add';

  @override
  String get estimatePending => 'Estimate coming';

  @override
  String get noVintage => 'No vintage';

  @override
  String bottleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bottles',
      one: '1 bottle',
    );
    return '$_temp0';
  }

  @override
  String get syncInProgress => 'Syncing';

  @override
  String get syncOffline => 'Offline - sync pending';

  @override
  String writeRejected(String name) {
    return 'Change not allowed: $name';
  }

  @override
  String get saveFailed => 'Could not save, try again';

  @override
  String wineNotSaved(String name) {
    return 'The wine $name was not saved to the cloud';
  }

  @override
  String get addAgain => 'Add again';

  @override
  String get ignore => 'Ignore';

  @override
  String get addWineTitle => 'Write';

  @override
  String get wineNameLabel => 'Wine';

  @override
  String get vintageLabel => 'Vintage';

  @override
  String get quantityLabel => 'Quantity';

  @override
  String get decreaseQuantity => 'Decrease quantity';

  @override
  String get increaseQuantity => 'Increase quantity';

  @override
  String get save => 'Save';

  @override
  String get nameRequired => 'Write the name of the wine';

  @override
  String get nameTooLong => 'Maximum 120 characters';

  @override
  String vintageRange(String year) {
    return 'Vintage between 1900 and $year';
  }
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
}
