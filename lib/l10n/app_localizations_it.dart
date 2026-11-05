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
}
