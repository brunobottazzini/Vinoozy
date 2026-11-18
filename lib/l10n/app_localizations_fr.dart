// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Vinoozy';

  @override
  String get signInTagline => 'Votre cave, au bon moment';

  @override
  String get signInWithGoogle => 'Continuer avec Google';

  @override
  String get signInInProgress => 'Connexion en cours';

  @override
  String get signInFailed => 'Échec de la connexion';

  @override
  String get signInNeedsNetwork =>
      'La première connexion nécessite un accès à Internet';

  @override
  String get signInSessionExpired =>
      'Votre session a expiré : reconnectez-vous';

  @override
  String get retry => 'Réessayer';

  @override
  String get cancel => 'Annuler';

  @override
  String blockedMessage(String email) {
    return 'Des modifications de $email ne sont pas encore enregistrées dans le cloud : connectez-vous avec ce compte et activez le réseau';
  }

  @override
  String blockedSignInWith(String email) {
    return 'Se connecter avec $email';
  }

  @override
  String blockedDiscard(String email) {
    return 'Supprimer les modifications non enregistrées de $email';
  }

  @override
  String get discardDialogTitle => 'Supprimer les modifications ?';

  @override
  String discardDialogBody(int count, String email) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count vins de $email ne sont pas encore dans le cloud et seront supprimés de ce téléphone.',
      one:
          '$count vin de $email n\'est pas encore dans le cloud et sera supprimé de ce téléphone.',
    );
    return '$_temp0';
  }

  @override
  String get discardConfirm => 'Supprimer';

  @override
  String get resetFailed => 'Impossible d\'effacer les données de ce téléphone';

  @override
  String get restartRequired => 'Redémarrez l\'application pour terminer';

  @override
  String get restartCloseApp => 'Fermer l\'application';

  @override
  String get startupFailed => 'Impossible de démarrer l\'application';

  @override
  String get cellarTitle => 'Cave';

  @override
  String get defaultCellarName => 'Ma cave';

  @override
  String get cellarLoading => 'Préparation de la cave';

  @override
  String get cellarSetupFailed => 'Impossible de préparer la cave';

  @override
  String get cellarEmpty => 'Votre cave est vide';

  @override
  String get addWine => 'Ajouter';

  @override
  String get estimatePending => 'Estimation à venir';

  @override
  String get noVintage => 'Sans millésime';

  @override
  String bottleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bouteilles',
      one: '$count bouteille',
    );
    return '$_temp0';
  }

  @override
  String get syncInProgress => 'Synchronisation en cours';

  @override
  String get syncOffline => 'Hors ligne - synchronisation en attente';

  @override
  String writeRejected(String name) {
    return 'Modification non autorisée : $name';
  }

  @override
  String get saveFailed => 'Enregistrement impossible, réessayez';

  @override
  String wineNotSaved(String name) {
    return 'Le vin $name n\'a pas été enregistré dans le cloud';
  }

  @override
  String get addAgain => 'Ajouter à nouveau';

  @override
  String get ignore => 'Ignorer';

  @override
  String get addWineTitle => 'Saisir';

  @override
  String get wineNameLabel => 'Vin';

  @override
  String get vintageLabel => 'Millésime';

  @override
  String get quantityLabel => 'Quantité';

  @override
  String get decreaseQuantity => 'Diminuer la quantité';

  @override
  String get increaseQuantity => 'Augmenter la quantité';

  @override
  String get save => 'Enregistrer';

  @override
  String get nameRequired => 'Saisissez le nom du vin';

  @override
  String get nameTooLong => '120 caractères maximum';

  @override
  String vintageRange(String year) {
    return 'Millésime entre 1900 et $year';
  }

  @override
  String get offAttribution => 'Données d\'Open Food Facts (ODbL)';

  @override
  String get dashboardTitle => 'Aperçu';

  @override
  String dashboardTotalBottles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bouteilles en cave',
      one: '$count bouteille en cave',
    );
    return '$_temp0';
  }

  @override
  String get dashboardSyncing => 'Synchronisation de la cave…';

  @override
  String get dashboardAddFirstWine => 'Ajouter votre premier vin';

  @override
  String get drinkSoonTitle => 'À boire bientôt';

  @override
  String get drinkSoonEmpty => 'Aucune bouteille à boire bientôt';

  @override
  String drinkSoonUntil(String year) {
    return 'd\'ici $year';
  }

  @override
  String drinkSoonSeeAll(int count) {
    return 'Tout voir ($count)';
  }

  @override
  String get statusChartTitle => 'État des bouteilles';

  @override
  String get statusWaiting => 'à attendre';

  @override
  String get statusReady => 'prêtes';

  @override
  String get statusDrinkSoon => 'à boire bientôt';

  @override
  String get statusPastWindow => 'fenêtre dépassée';

  @override
  String toEstimateNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bouteilles à estimer',
      one: '$count bouteille à estimer',
    );
    return '$_temp0';
  }

  @override
  String chartBarValue(String label, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bouteilles',
      one: '$count bouteille',
    );
    return '$label : $_temp0';
  }

  @override
  String chartDescription(String title, String values) {
    return '$title : $values';
  }

  @override
  String get openListHint => 'Ouvrir la liste';

  @override
  String get peakChartTitle => 'Année d\'apogée';

  @override
  String get peakPast => 'apogée passé';

  @override
  String get peakBeyond => 'plus tard';

  @override
  String get breakdownTypeTitle => 'Bouteilles par type';

  @override
  String get breakdownRegionTitle => 'Bouteilles par région';

  @override
  String get breakdownType => 'Type';

  @override
  String get breakdownRegion => 'Région';

  @override
  String get familyRed => 'rouge';

  @override
  String get familyWhite => 'blanc';

  @override
  String get familyRose => 'rosé';

  @override
  String get familySparkling => 'effervescent';

  @override
  String get familySweet => 'doux';

  @override
  String get breakdownUnspecified => 'non précisé';

  @override
  String get breakdownOtherRegions => 'autres';

  @override
  String get ok => 'OK';

  @override
  String get cellarMenu => 'Menu de la cave';

  @override
  String get sharingPeopleTitle => 'Personnes';

  @override
  String get sharingInviteTitle => 'Inviter une personne';

  @override
  String get sharingEmailLabel => 'Adresse e-mail Google';

  @override
  String get sharingPermissionRead => 'Lecture seule';

  @override
  String get sharingPermissionReadHint =>
      'Voit les vins, les estimations, l\'aperçu et les dégustations';

  @override
  String get sharingPermissionEdit => 'Peut modifier';

  @override
  String get sharingPermissionEditHint =>
      'Ajoute et modifie aussi des vins et enregistre des dégustations';

  @override
  String get sharingRoleOwner => 'propriétaire';

  @override
  String get sharingInviteButton => 'Inviter';

  @override
  String sharingPlacesUsed(int used, int max) {
    return '$used/$max personnes';
  }

  @override
  String get sharingInvalidEmail => 'Saisissez une adresse e-mail valide';

  @override
  String get sharingSelfInvite => 'Vous ne pouvez pas vous inviter vous-même';

  @override
  String get sharingAlreadyInvited => 'Cette personne est déjà invitée';

  @override
  String sharingLimitReached(int max) {
    return 'Vous avez atteint la limite de $max personnes';
  }

  @override
  String get sharingNotOwner =>
      'Vous ne pouvez pas modifier le partage de cette cave';

  @override
  String get sharingNotFound => 'Cette personne n\'est plus dans la liste';

  @override
  String get sharingFailed => 'Opération impossible, réessayez';

  @override
  String get sharingInviteFailed => 'Échec de l\'invitation. Réessayez';

  @override
  String get sharingOfflineHint =>
      'Une connexion est nécessaire pour gérer le partage';

  @override
  String get sharingStatusInvited => 'invitée';

  @override
  String get sharingStatusActive => 'active';

  @override
  String get sharingStatusRevoked => 'révoquée';

  @override
  String get sharingStatusLeft => 'partie';

  @override
  String sharingMemberSemantics(String name, String permission, String status) {
    return '$name, $permission, $status';
  }

  @override
  String get sharingClosedSection => 'Accès fermés';

  @override
  String get sharingNobody => 'Personne d\'autre ne voit encore cette cave';

  @override
  String sharingChangePermission(String name) {
    return 'Modifier l\'autorisation de $name';
  }

  @override
  String get sharingRevoke => 'Révoquer';

  @override
  String sharingRevokeTitle(String name) {
    return 'Révoquer l\'accès de $name ?';
  }

  @override
  String sharingRevokeConfirmLabel(String name) {
    return 'Saisissez $name pour confirmer';
  }

  @override
  String get sharingRevokeDisabledHint => 'Activé quand le nom correspond';

  @override
  String get sharingReinvite => 'Inviter à nouveau';

  @override
  String get sharingDeleteForGood => 'Supprimer définitivement';

  @override
  String sharingOwnedBy(String owner) {
    return 'Cave de $owner';
  }

  @override
  String get sharingYourCellar => 'Votre cave';

  @override
  String sharingYourPermission(String permission) {
    return 'Votre autorisation : $permission';
  }

  @override
  String sharingSwitcherSemantics(String cellar, String permission) {
    return '$cellar, $permission. Touchez pour changer de cave';
  }

  @override
  String get sharingLeave => 'Quitter cette cave';

  @override
  String sharingLeaveTitle(String owner) {
    return 'Quitter la cave de $owner ?';
  }

  @override
  String sharingLeaveBody(String owner) {
    return 'Vous ne la verrez plus. $owner pourra vous inviter à nouveau.';
  }

  @override
  String get sharingLeaveConfirm => 'Quitter';

  @override
  String sharingSharedNotice(String owner) {
    return '$owner a partagé sa cave avec vous';
  }

  @override
  String sharingAccessLost(String owner) {
    return 'Vous n\'avez plus accès à la cave de $owner';
  }

  @override
  String sharingWritesLost(String owner) {
    return 'Certaines modifications de la cave de $owner n\'ont pas été enregistrées, car vous n\'y avez plus accès';
  }

  @override
  String get sharingSomeone => 'quelqu\'un';

  @override
  String get sharingShareSubject => 'Invitation à Vinoozy';

  @override
  String sharingShareMessage(
    String owner,
    String cellar,
    String link,
    String email,
  ) {
    return '$owner vous a invité dans la cave « $cellar » sur Vinoozy. Installez l\'application depuis $link et connectez-vous avec le compte Google $email : utilisez exactement cette adresse.';
  }

  @override
  String get cellarSearchHint => 'Rechercher par nom ou producteur';

  @override
  String get cellarFilterStatus => 'État';

  @override
  String get cellarFilterType => 'Type';

  @override
  String get statusToEstimate => 'À estimer';

  @override
  String get filterTypeUnspecified => 'Non précisé';

  @override
  String get cellarNoMatches => 'Aucun vin avec ces filtres';

  @override
  String get cellarClearFilters => 'Effacer les filtres';

  @override
  String get cellarArchiveTitle => 'Vins bus';

  @override
  String get cellarArchiveEmpty => 'Aucun vin terminé pour l\'instant';

  @override
  String get cellarArchiveFailed => 'Impossible de charger les vins terminés';

  @override
  String get wineDrink => 'Bue';

  @override
  String wineDrinkTooltip(String name) {
    return 'Marquer une bouteille de $name comme bue';
  }

  @override
  String confidenceLabel(String level) {
    return 'Confiance : $level';
  }

  @override
  String get confidenceHigh => 'élevée';

  @override
  String get confidenceMedium => 'moyenne';

  @override
  String get confidenceLow => 'faible';

  @override
  String get windowStartLabel => 'Début';

  @override
  String get windowPeakLabel => 'Apogée';

  @override
  String get windowEndLabel => 'Fin';

  @override
  String estimateSourceLabel(String source) {
    return 'Source : $source';
  }

  @override
  String get estimateSourceCatalog => 'base de données de vins';

  @override
  String get estimateSourceType => 'estimation selon le type';

  @override
  String get estimateSourceCorrected =>
      'estimation corrigée par vos dégustations';

  @override
  String get estimateDisclaimer =>
      'Estimation indicative : elle dépend aussi de la conservation de la bouteille';

  @override
  String get estimateUnavailable => 'Estimation indisponible';

  @override
  String get pairingsTitle => 'Accords';

  @override
  String get pairingsGeneric => 'accords génériques pour le type';

  @override
  String get pairingBraisedRedMeat => 'Viande rouge braisée';

  @override
  String get pairingGrilledRedMeat => 'Viande rouge grillée';

  @override
  String get pairingGame => 'Gibier';

  @override
  String get pairingRoastPoultry => 'Volaille rôtie';

  @override
  String get pairingPoultry => 'Volaille';

  @override
  String get pairingPork => 'Porc';

  @override
  String get pairingCuredMeats => 'Charcuterie';

  @override
  String get pairingPastaMeatSauce => 'Pâtes à la bolognaise';

  @override
  String get pairingMushroomsTruffle => 'Champignons et truffe';

  @override
  String get pairingAgedCheese => 'Fromages affinés';

  @override
  String get pairingFreshCheese => 'Fromages frais';

  @override
  String get pairingBlueCheese => 'Fromages bleus';

  @override
  String get pairingFish => 'Poisson';

  @override
  String get pairingSeafood => 'Fruits de mer';

  @override
  String get pairingRawSeafood => 'Fruits de mer crus';

  @override
  String get pairingFriedFood => 'Fritures';

  @override
  String get pairingVegetables => 'Légumes';

  @override
  String get pairingRisotto => 'Risotto';

  @override
  String get pairingPizza => 'Pizza';

  @override
  String get pairingAperitif => 'Apéritif';

  @override
  String get pairingPastries => 'Pâtisseries';

  @override
  String get pairingDryBiscuits => 'Biscuits secs';

  @override
  String get pairingChocolate => 'Chocolat';

  @override
  String get pairingDriedFruit => 'Fruits secs';

  @override
  String get pairingSpicyDishes => 'Plats épicés';

  @override
  String get recentDrinksTitle => 'Dernières dégustations';

  @override
  String get noDrinksYet => 'Aucune dégustation';

  @override
  String get wineEdit => 'Modifier';

  @override
  String get wineDelete => 'Supprimer';

  @override
  String get wineFinished => 'Terminé : plus aucune bouteille';

  @override
  String get wineLoadFailed => 'Impossible d\'ouvrir le vin';

  @override
  String get wineNotFound => 'Ce vin n\'existe plus';

  @override
  String drinkDone(String name) {
    return 'Bouteille bue : $name';
  }

  @override
  String get drinkUndo => 'Annuler';

  @override
  String get drinkAddNotes => 'Ajouter note et commentaires';

  @override
  String get nothingToUndo => 'Plus rien à annuler';

  @override
  String get cellarUndoRejected =>
      'Annulation impossible : la bouteille reste marquée comme bue';

  @override
  String get cellarDeleteFailed =>
      'La suppression n\'est pas encore terminée : elle s\'achèvera dès que possible';

  @override
  String get duplicateFull =>
      'Ce vin compte déjà 99 bouteilles : impossible d\'en ajouter.';

  @override
  String get recordSheetTitle => 'Note et commentaires';

  @override
  String get recordRatingLabel => 'Note';

  @override
  String ratingStar(int n) {
    return 'Note $n sur 5';
  }

  @override
  String get recordNotesLabel => 'Commentaires';

  @override
  String get recordNotesTooLong => '1000 caractères maximum';

  @override
  String recordDateLabel(String date) {
    return 'Date : $date';
  }

  @override
  String get recordDateInvalid =>
      'La date ne peut être ni dans le futur ni antérieure au millésime';

  @override
  String get recordConditionTitle => 'Comment était-il ?';

  @override
  String get conditionTooYoung => 'Encore trop jeune';

  @override
  String get conditionJustRight => 'À point';

  @override
  String get conditionPastPeak => 'Sur le déclin';

  @override
  String get recordNoCondition => 'Sans réponse';

  @override
  String get producerLabel => 'Producteur (facultatif)';

  @override
  String get producerTooLong => '120 caractères maximum';

  @override
  String producerAddNew(String name) {
    return 'Ajouter « $name » comme nouveau producteur';
  }

  @override
  String get wineTypeLabel => 'Type';

  @override
  String get typeRedLight => 'Rouge léger';

  @override
  String get typeRedStructured => 'Rouge corsé';

  @override
  String get typeWhite => 'Blanc';

  @override
  String get typeRose => 'Rosé';

  @override
  String get typeSparklingClassic => 'Effervescent méthode traditionnelle';

  @override
  String get typeSparklingTank => 'Effervescent méthode Charmat';

  @override
  String get typeSweet => 'Doux';

  @override
  String get typeFortified => 'Muté';

  @override
  String get suggestionFromCellar => 'Dans votre cave';

  @override
  String get suggestionsLabel => 'Suggestions';

  @override
  String get duplicateTitle => 'Déjà dans la cave';

  @override
  String duplicateBody(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bouteilles',
      one: '$count bouteille',
      zero: 'aucune bouteille',
    );
    return '$name y figure déjà, avec $_temp0. Y ajouter les nouvelles bouteilles ?';
  }

  @override
  String duplicateAdd(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ajouter $count bouteilles',
      one: 'Ajouter $count bouteille',
    );
    return '$_temp0';
  }

  @override
  String get duplicateBanner => 'Doublon possible';

  @override
  String get duplicateMerge => 'Fusionner';

  @override
  String get duplicateDeleteHint =>
      'Supprimez cette entrée s\'il s\'agit d\'un doublon';

  @override
  String get mergeTitle => 'Fusionner les deux entrées ?';

  @override
  String get mergeBody =>
      'Les bouteilles de cette entrée passent dans la plus ancienne, puis cette entrée est supprimée.';

  @override
  String get editWineTitle => 'Modifier le vin';

  @override
  String get editDuplicate =>
      'Un autre vin porte déjà le même nom, le même producteur et le même millésime';

  @override
  String deleteWineTitle(String name) {
    return 'Supprimer $name ?';
  }

  @override
  String get deleteWineBody =>
      'Le vin et toutes ses dégustations sont supprimés. Cette action est irréversible.';

  @override
  String get historyTitle => 'Historique';

  @override
  String get historyEmpty =>
      'Vous retrouverez ici les bouteilles que vous avez bues';

  @override
  String get historyLoadFailed => 'Impossible de charger l\'historique';

  @override
  String drankOnLabel(String date) {
    return 'Bue le $date';
  }

  @override
  String get addChoiceTitle => 'Ajouter un vin';

  @override
  String get addChoicePhoto => 'Prendre une photo';

  @override
  String get addChoiceImport => 'Importer une photo';

  @override
  String get addChoiceWrite => 'Saisir';

  @override
  String get labelReading => 'Lecture de l\'étiquette…';

  @override
  String get labelRecognized => 'J\'ai reconnu :';

  @override
  String get labelCorrect => 'Corriger';

  @override
  String get labelConfirm => 'Confirmer';

  @override
  String get labelUnreadable => 'Je n\'arrive pas à lire l\'étiquette';

  @override
  String get labelWriteByHand => 'Saisir à la main';

  @override
  String get labelNotFound =>
      'Je n\'ai pas trouvé le vin : vérifiez les informations';

  @override
  String get labelCameraDenied =>
      'Pour lire l\'étiquette, j\'ai besoin d\'accéder à l\'appareil photo';

  @override
  String get labelPhotosDenied =>
      'Pour lire l\'étiquette, j\'ai besoin d\'accéder aux photos';

  @override
  String get labelOpenSettings => 'Ouvrir les paramètres';

  @override
  String get labelCameraUnavailable => 'Appareil photo indisponible';

  @override
  String get labelBarcodeNotFound =>
      'J\'ai lu le code-barres, mais je ne trouve pas le vin';

  @override
  String get labelBarcodeFrontHint =>
      'Photographiez la face avant de l\'étiquette';

  @override
  String get labelSharedNotAllowed =>
      'Vous ne pouvez pas ajouter de vins à cette cave';

  @override
  String get labelSharedFirstOnly => 'Je n\'ai utilisé que la première photo';

  @override
  String get labelSharedExpired =>
      'Impossible de lire la photo partagée : partagez-la à nouveau';

  @override
  String get labelReplaceTitle =>
      'Vous avez un vin non enregistré. Lire la nouvelle photo ?';

  @override
  String get labelReplaceRead => 'Lire la nouvelle photo';

  @override
  String get labelReplaceKeep => 'Continuer avec le vin ouvert';

  @override
  String get labelWineAdded => 'Vin ajouté à la cave';

  @override
  String get onboardingPage1Title => 'Votre cave dans la poche';

  @override
  String get onboardingPage1Body =>
      'Ajoutez vos bouteilles en les saisissant ou en photographiant l\'étiquette, même sans réseau.';

  @override
  String get onboardingPage2Title => 'Au bon moment';

  @override
  String get onboardingPage2Body =>
      'Vinoozy estime quand chaque vin est à son apogée et vous indique lesquels ouvrir en premier.';

  @override
  String get onboardingPage3Title => 'Ensemble';

  @override
  String get onboardingPage3Body =>
      'Partagez votre cave avec deux personnes au maximum et gardez l\'historique de chaque bouteille bue.';

  @override
  String get onboardingSkip => 'Passer';

  @override
  String get onboardingNext => 'Suivant';

  @override
  String get onboardingStart => 'Commencer';

  @override
  String onboardingPageOf(int page) {
    return 'Page $page sur 3';
  }

  @override
  String get profileTitle => 'Profil';

  @override
  String get profilePhoto => 'Photo de profil';

  @override
  String get profileSignOut => 'Se déconnecter';

  @override
  String get profileDeleteAccount => 'Supprimer le compte';

  @override
  String get profilePrivacy => 'Politique de confidentialité';

  @override
  String get profilePrivacyBody =>
      'Vous pouvez lire la politique de confidentialité à cette adresse :';

  @override
  String get profileOpenLink => 'Ouvrir dans le navigateur';

  @override
  String get profileOpenLinkFailed =>
      'Impossible d\'ouvrir la page. Vous pouvez copier le lien et l\'ouvrir dans votre navigateur.';

  @override
  String get profileCopyLink => 'Copier le lien';

  @override
  String get profileLinkCopied => 'Lien copié';

  @override
  String get close => 'Fermer';

  @override
  String get signOutConfirmTitle => 'Voulez-vous vous déconnecter ?';

  @override
  String signOutPendingWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Vous avez $count modifications pas encore enregistrées. Si vous vous déconnectez et qu\'un autre compte se connecte, elles seront perdues.',
      one:
          'Vous avez $count modification pas encore enregistrée. Si vous vous déconnectez et qu\'un autre compte se connecte, elle sera perdue.',
    );
    return '$_temp0';
  }

  @override
  String get signOutStayAndSync => 'Rester et synchroniser';

  @override
  String get signOutAnyway => 'Se déconnecter quand même';

  @override
  String get syncAllSaved => 'Tout est enregistré';

  @override
  String syncStillPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Encore $count modifications à enregistrer : vérifiez le réseau',
      one: 'Encore $count modification à enregistrer : vérifiez le réseau',
    );
    return '$_temp0';
  }

  @override
  String get signOutFailed => 'Déconnexion impossible. Réessayez';

  @override
  String get signInAccountDeleted => 'Compte supprimé';

  @override
  String get deleteAccountIntro => 'Seront supprimés définitivement :';

  @override
  String get deleteAccountItemCellar =>
      'Votre cave, avec ses vins et son Historique';

  @override
  String get deleteAccountItemShares =>
      'Les partages que vous avez accordés : les personnes invitées perdent l\'accès';

  @override
  String get deleteAccountItemMemberships =>
      'Votre participation aux caves d\'autres personnes : vos dégustations y restent, sans votre nom';

  @override
  String get deleteAccountItemProfile => 'Votre profil';

  @override
  String deleteAccountPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Vous avez $count modifications pas encore enregistrées : elles seront enregistrées, puis supprimées avec le reste',
      one:
          'Vous avez $count modification pas encore enregistrée : elle sera enregistrée, puis supprimée avec le reste',
    );
    return '$_temp0';
  }

  @override
  String get deleteAccountConfirmWord => 'SUPPRIMER';

  @override
  String deleteAccountTypeWord(String word) {
    return 'Saisissez $word pour confirmer';
  }

  @override
  String get deleteAccountReauthHint =>
      'Vous vous reconnecterez ensuite avec Google pour confirmer qu\'il s\'agit bien de vous.';

  @override
  String get deleteAccountForever => 'Supprimer pour toujours';

  @override
  String get deleteAccountNeedsNetwork =>
      'Connectez-vous à Internet pour supprimer le compte';

  @override
  String get deleteAccountSameAccount =>
      'La suppression exige de se connecter avec le même compte';

  @override
  String get deletionTitle => 'Suppression du compte';

  @override
  String get deletionStepPreparePhone =>
      'Enregistrement des modifications en attente';

  @override
  String get deletionStepMarkStarted => 'Démarrage de la suppression';

  @override
  String get deletionStepLeaveOtherCellars =>
      'Sortie des caves d\'autres personnes';

  @override
  String get deletionStepCloseOwnInvitations => 'Fermeture de vos partages';

  @override
  String get deletionStepDeleteWinesAndRecords =>
      'Suppression des vins et de l\'Historique';

  @override
  String get deletionStepDeleteCellar => 'Suppression de la cave';

  @override
  String get deletionStepDeleteProfileAndUser =>
      'Suppression du profil et du compte';

  @override
  String get deletionStepCleanUpPhone => 'Nettoyage de ce téléphone';

  @override
  String deletionStepAnnounce(int step, String label) {
    return 'Étape $step sur 8 : $label';
  }

  @override
  String deletionDeletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vins et dégustations supprimés',
      one: '$count vin ou dégustation supprimé',
    );
    return '$_temp0';
  }

  @override
  String get deletionResumeHint =>
      'La suppression de ce compte n\'est pas terminée. Reconnectez-vous avec Google pour la finaliser.';

  @override
  String get deletionContinue => 'Continuer';

  @override
  String get deletionOffline =>
      'Connectez-vous à Internet pour terminer la suppression';

  @override
  String get deletionPendingWrites =>
      'Je n\'arrive pas à enregistrer les modifications en attente. Réessayez';

  @override
  String get deletionFailed =>
      'Impossible de terminer la suppression. Réessayez';

  @override
  String get uxCountryLabel => 'Pays';

  @override
  String get uxCountryOther => 'Autre pays…';

  @override
  String get uxCountryNone => 'Aucun pays';

  @override
  String get uxAllCountriesTitle => 'Tous les pays et territoires';

  @override
  String get uxAllCountriesSearch => 'Rechercher un pays';

  @override
  String get uxAllCountriesRare => 'Rares pour le vin';

  @override
  String get uxAllCountriesAll => 'Tous, de A à Z';

  @override
  String get uxAllCountriesNone => 'Aucun pays trouvé';

  @override
  String get uxRegionLabel => 'Région';

  @override
  String uxRegionOf(String country) {
    return 'Région · $country';
  }

  @override
  String get uxRegionOther => 'Autre région';

  @override
  String get uxRegionFieldLabel => 'Saisissez la région';

  @override
  String get uxRegionTooLong => '120 caractères maximum';

  @override
  String get uxDrinkAction => 'J\'en ai bu une';

  @override
  String uxDrinkActionTooltip(String name) {
    return 'J\'ai bu une bouteille de $name';
  }

  @override
  String get uxDrinkActionDetail => 'J\'ai bu une bouteille';

  @override
  String get uxDrinkSheetLabel => 'Confirmer la dégustation';

  @override
  String get uxDrinkSheetBottles => 'Bouteilles';

  @override
  String uxDrinkSheetBottlesChange(int before, int after) {
    return 'Bouteilles : de $before à $after';
  }

  @override
  String get uxDrinkSheetRating => 'Comment était-il ? (facultatif)';

  @override
  String uxDrinkSheetStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count étoiles sur 5',
      one: '$count étoile sur 5',
    );
    return '$_temp0';
  }

  @override
  String get uxDrinkSheetConfirm => 'Oui, je l\'ai bue';

  @override
  String get uxRemoveBottle => 'Retirer une bouteille sans dégustation';

  @override
  String get uxRemoveBottleTitle => 'Retirer une bouteille ?';

  @override
  String uxRemoveBottleBody(String name) {
    return 'Une bouteille de $name est retirée sans enregistrer de dégustation.';
  }

  @override
  String get uxRemoveBottleConfirm => 'Retirer';

  @override
  String get uxIdealTitle => 'Moment idéal';

  @override
  String uxIdealUntil(String year) {
    return 'Conseillé jusqu\'en $year';
  }

  @override
  String uxIdealUntilPast(String year) {
    return 'Conseillé jusqu\'en $year : date dépassée';
  }

  @override
  String uxIdealBest(String start, String end) {
    return 'À son meilleur de $start à $end';
  }

  @override
  String uxIdealBar(String start, String end) {
    return 'Fenêtre de dégustation de $start à $end';
  }

  @override
  String get uxIdealDisclaimer =>
      '⚠︎ Indicatif : estimation fondée sur le type, l\'appellation et le millésime. La conservation et chaque bouteille peuvent la modifier.';

  @override
  String get uxIdealUnavailableHint =>
      'Ajoutez le millésime et le type pour obtenir une estimation.';

  @override
  String uxDashboardDrinkNow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count à boire maintenant',
      one: '$count à boire maintenant',
    );
    return '$_temp0';
  }

  @override
  String get uxFamilyRed => 'Rouge';

  @override
  String get uxFamilyWhite => 'Blanc';

  @override
  String get uxFamilyRose => 'Rosé';

  @override
  String get uxFamilySparkling => 'Effervescent';

  @override
  String get uxFamilySweet => 'Doux';

  @override
  String get labelBackTitle => 'Maintenant le dos';

  @override
  String get labelBackHint =>
      'Le dos porte généralement le code-barres, le producteur et le millésime : ils aident à trouver le vin.';

  @override
  String get labelBackTake => 'Photographier le dos';

  @override
  String get labelBackGallery => 'Choisir dans la galerie';

  @override
  String get labelBackSkip => 'Passer';

  @override
  String get labelStepFront => 'Face';

  @override
  String get labelStepBack => 'Dos';

  @override
  String get labelStepBarcode => 'Code-barres';

  @override
  String get labelStepDatabase => 'Base de vins sur le téléphone';

  @override
  String get labelStepPending => 'En attente';

  @override
  String get labelStepRunning => 'En cours…';

  @override
  String get labelStepDone => 'Terminé';

  @override
  String get labelStepSkipped => 'Ignoré';

  @override
  String get labelStepFailed => 'Illisible';

  @override
  String labelStepStatus(String step, String status) {
    return '$step : $status';
  }

  @override
  String get labelOnPhoneNote =>
      'Tout se passe sur le téléphone : les photos ne sont envoyées à personne.';

  @override
  String get labelBackUnreadable => 'Dos illisible';

  @override
  String get labelSourceOffline => 'De la base sur le téléphone · hors ligne';

  @override
  String get labelSourceCatalog => 'Du catalogue';

  @override
  String get labelSourceOnline => 'D\'Open Food Facts · en ligne';

  @override
  String get labelNotThis => 'Pas celui-ci';

  @override
  String get labelOffAttribution => 'Données d\'Open Food Facts, licence ODbL';

  @override
  String get labelCandidatesTitle => 'Lequel de ceux-ci ?';

  @override
  String labelCandidatesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vins similaires',
      one: '$count vin similaire',
    );
    return '$_temp0';
  }

  @override
  String get labelCandidatesNone => 'Aucun de ceux-ci';

  @override
  String get labelChipOffline => 'hors ligne';

  @override
  String get labelChipOnline => 'en ligne';

  @override
  String get labelChipCatalog => 'catalogue';

  @override
  String get labelNoProducer => 'producteur non précisé';

  @override
  String get labelNoMatch =>
      'J\'ai lu l\'étiquette, mais je ne reconnais pas le vin';

  @override
  String get labelReadText => 'Texte lu';

  @override
  String get labelSearchOnline => 'Rechercher en ligne';

  @override
  String get labelOpenLens => 'Ouvrir dans Google Lens';

  @override
  String get labelLensLastResort =>
      'Google Lens est le dernier recours : la photo n\'est transmise à l\'application Google que si vous confirmez.';

  @override
  String get labelLensTitle => 'Ouvrir dans Google Lens ?';

  @override
  String get labelLensBody =>
      'La photo de la face avant sera transmise à l\'application Google de votre téléphone, ou à l\'application de votre choix, qui peut en conserver une copie selon ses propres règles. Vinoozy ne reçoit pas les résultats : revenez ici pour choisir ou saisir le vin.';

  @override
  String get labelLensConfirm => 'Ouvrir Google Lens';

  @override
  String get labelLensFailed =>
      'Impossible d\'ouvrir Google Lens ou le menu de partage';

  @override
  String get onlineSearchTitle => 'Rechercher en ligne';

  @override
  String get onlineSearchSubtitle => 'Open Food Facts · vins uniquement';

  @override
  String get onlineSearchField => 'Mots à rechercher';

  @override
  String get onlineSearchHint =>
      'Vous pouvez modifier les mots avant de lancer la recherche.';

  @override
  String get onlineSearchEmptyField => 'Saisissez au moins un mot';

  @override
  String get onlineSearchButton => 'Rechercher';

  @override
  String get onlineSearchLoading => 'Recherche…';

  @override
  String onlineSearchResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count résultats',
      one: '$count résultat',
    );
    return '$_temp0';
  }

  @override
  String get onlineSearchEmpty =>
      'Aucun vin trouvé : essayez d\'autres mots ou « Saisir à la main ».';

  @override
  String get onlineSearchOffline =>
      'Pas de réseau : je cherche uniquement dans la base sur le téléphone.';

  @override
  String get onlineSearchRateLimited =>
      'La recherche en ligne est indisponible pour le moment, réessayez dans quelques minutes.';

  @override
  String get onlineSearchUnavailable =>
      'La recherche en ligne n\'est pas active dans cette version de l\'application : je cherche uniquement dans la base sur le téléphone.';

  @override
  String get aboutTitle => 'À propos';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aboutDbTitle => 'Base de vins';

  @override
  String aboutDbCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vins',
      one: '$count vin',
    );
    return '$_temp0';
  }

  @override
  String aboutDbDate(String date) {
    return 'Export Open Food Facts du $date';
  }

  @override
  String get aboutDbSample =>
      'Base d\'exemple : quelques vins de test saisis à la main, pas des données d\'Open Food Facts.';

  @override
  String get aboutDbLoading => 'Ouverture de la base de vins…';

  @override
  String get aboutDbUnavailable =>
      'La base de vins n\'est pas disponible dans cette version';

  @override
  String aboutDbSource(String url) {
    return 'La base dérivée et l\'outil qui la génère se trouvent dans le dépôt public : $url';
  }

  @override
  String get aboutLicenseTitle => 'Licences';

  @override
  String get aboutLicense =>
      'Contient des informations d\'Open Food Facts, mises à disposition sous Open Database License (ODbL). Les contenus individuels sont sous Database Contents License (DbCL).';

  @override
  String get aboutPrivacyTitle => 'Photos d\'étiquettes';

  @override
  String get aboutPrivacy =>
      'Les photos d\'étiquettes sont lues sur le téléphone et supprimées quand vous quittez le résultat. Elles ne quittent le téléphone que si vous touchez « Ouvrir dans Google Lens » et confirmez.';

  @override
  String get aboutAppellationsTitle => 'Appellations';

  @override
  String get aboutAppellationsSource =>
      'Appellations : registre eAmbrosia (UE) et registres nationaux officiels.';

  @override
  String get aboutAppellationsSample =>
      'Table d\'exemple : un extrait des registres saisi à la main, en attendant le téléchargement des registres réels.';

  @override
  String get denominationLabel => 'Appellation';

  @override
  String get denominationTooLong => '120 caractères maximum';

  @override
  String get autofillFilledNotice =>
      'Rempli d\'après l\'étiquette : vérifiez et enregistrez';

  @override
  String get autofillPastedNotice =>
      'Rempli d\'après le texte : vérifiez et enregistrez';

  @override
  String get autofillFromText => '✦ d\'après le texte';

  @override
  String get autofillFromTextSemantics => 'rempli d\'après l\'étiquette';

  @override
  String get autofillClear => 'Effacer';

  @override
  String get autofillLens => 'Lens';

  @override
  String get autofillClearTitle => 'Effacer le formulaire ?';

  @override
  String get autofillClearBody =>
      'Vous avez aussi écrit dans certains champs. « Effacer » vide le nom, le producteur, l\'appellation, le millésime, le type, le pays, la région et le niveau. La quantité est conservée.';

  @override
  String get autofillClearConfirm => 'Effacer';

  @override
  String get autofillCleared => 'Formulaire effacé';

  @override
  String get autofillPasteTitle => 'Avez-vous le texte de Google Lens ?';

  @override
  String get autofillPasteHint =>
      'Dans Lens, sélectionnez le texte de l\'étiquette et touchez « Copier », puis revenez ici.';

  @override
  String get autofillPaste => 'Coller depuis Lens';

  @override
  String get autofillOpenLens => 'Depuis Google Lens';

  @override
  String get autofillOpenLensSemantics => 'ouvre Google Lens';

  @override
  String get autofillClipboardEmpty =>
      'Le presse-papiers ne contient pas de texte';

  @override
  String get autofillNoNewFields =>
      'Je n\'ai trouvé aucune donnée à ajouter dans le texte';

  @override
  String get autofillFromLens => 'Formulaire rempli d\'après le texte de Lens';

  @override
  String get autofillShareEmpty => 'Aucun texte reçu';

  @override
  String get autofillShareUseTitle =>
      'Utiliser le texte pour les champs vides ?';

  @override
  String get autofillShareUse => 'Utiliser';

  @override
  String get autofillShareIgnore => 'Ignorer';

  @override
  String get addChoiceLens => 'Depuis Google Lens';

  @override
  String get addChoicePhotoHint => 'Face et dos : Vinoozy lit l\'étiquette.';

  @override
  String get addChoiceLensHint =>
      'Ouvre Lens : cadrez, sélectionnez le texte et touchez Partager → Vinoozy.';

  @override
  String get addChoiceImportHint => 'Une photo de l\'étiquette déjà prise.';

  @override
  String get addChoiceWriteHint =>
      'Formulaire vide, avec « Coller depuis Lens ».';

  @override
  String get lensInstructionsTitle => 'Impossible d\'ouvrir Google Lens d\'ici';

  @override
  String get lensInstructionsStep1 =>
      'Ouvrez Google Lens et cadrez l\'étiquette';

  @override
  String get lensInstructionsStep2 => 'Sélectionnez le texte de l\'étiquette';

  @override
  String get lensInstructionsStep3 => 'Touchez Partager → Vinoozy';

  @override
  String get lensInstructionsOk => 'Compris';

  @override
  String get levelLabel => 'Niveau';

  @override
  String get levelEveryday => 'Quotidien (économique)';

  @override
  String get levelGood => 'Bon';

  @override
  String get levelAging => 'De garde';

  @override
  String get levelNone => 'Aucun';

  @override
  String get levelEverydayShort => 'à boire jeune';

  @override
  String get levelGoodShort => 'estimation normale';

  @override
  String get levelAgingShort => 'se garde longtemps';

  @override
  String get levelSuggested => 'suggéré';

  @override
  String levelSuggestedReason(String qualifier) {
    return 'Suggéré, car le nom contient « $qualifier » : il est enregistré ainsi sauf si vous le modifiez. Choisissez-en un autre ou touchez « Aucun ».';
  }

  @override
  String levelSuggestedSemantics(String qualifier) {
    return 'suggéré, car le nom contient $qualifier';
  }

  @override
  String levelOptionSemantics(String option, int index, int count) {
    return 'Niveau, $option, $index sur $count';
  }

  @override
  String get levelWhatChanges => 'Ce qui change';

  @override
  String get levelEverydayExamples =>
      'La fenêtre raccourcit. Ex. : vin de la maison, Lambrusco, Prosecco de base, Bardolino, Vinho Verde.';

  @override
  String get levelGoodExamples =>
      'L\'estimation normale, et la valeur retenue si vous ne choisissez rien. Ex. : Chianti Classico, Barbera d\'Asti Superiore, Rioja Crianza, Côtes du Rhône.';

  @override
  String get levelAgingExamples =>
      'La fenêtre s\'allonge. Ex. : Barolo, Brunello, Amarone, Bordeaux Grand Cru, Rioja Gran Reserva, Porto Vintage.';

  @override
  String levelPreviewBefore(String start, String end) {
    return 'Avant $start – $end';
  }

  @override
  String levelPreviewWith(String level, String start, String end) {
    return 'Avec « $level » $start – $end';
  }

  @override
  String levelPreviewNow(String start, String end) {
    return 'Prêt $start – jusqu\'en $end';
  }

  @override
  String levelDetail(String level) {
    return 'Niveau : $level';
  }

  @override
  String get overrideCorrect => 'Corriger';

  @override
  String get overrideRestore => 'Rétablir l\'estimation';

  @override
  String get overrideCorrectedByYou => 'corrigé par vous';

  @override
  String overrideAppEstimate(String year) {
    return 'Estimation de l\'application : jusqu\'en $year';
  }

  @override
  String get overrideSheetTitle => 'Conseillé jusqu\'en';

  @override
  String overrideSheetHint(String start) {
    return 'Choisissez l\'année. Elle ne peut pas précéder « Prêt à partir de $start ».';
  }

  @override
  String overridePeakNotice(String peak) {
    return 'Si vous choisissez une année antérieure à $peak (à son meilleur), « à son meilleur » passe aussi à cette année.';
  }

  @override
  String get overrideMore => 'plus…';

  @override
  String get overrideSave => 'Enregistrer la correction';

  @override
  String overrideRestoreTitle(String year) {
    return 'Revenir à l\'estimation de l\'application (jusqu\'en $year) ?';
  }

  @override
  String get overrideRestoreConfirm => 'Rétablir';

  @override
  String get overrideSaved => 'Correction enregistrée';

  @override
  String get overrideRestored => 'Estimation rétablie';

  @override
  String get estimateSourceCorrectedByYou => 'corrigée par vous';

  @override
  String estimateFromDenomination(String name) {
    return 'Estimation d\'après l\'appellation $name';
  }

  @override
  String estimateFromDenominationQualifier(String name, String qualifier) {
    return 'Estimation d\'après l\'appellation $name, $qualifier';
  }

  @override
  String estimateFromGrape(String name) {
    return 'Estimation d\'après le cépage $name';
  }

  @override
  String get estimateFromType => 'Estimation d\'après le type de vin';

  @override
  String get autofillReading => 'Lecture du texte…';

  @override
  String get guideChip => 'Vérification guidée';

  @override
  String guideProgress(int n, int total) {
    return 'Question $n sur $total';
  }

  @override
  String get guideClose => 'Fermer';

  @override
  String get guideIsDenomination => 'est-ce l\'appellation ?';

  @override
  String get guideIsProducer => 'est-ce le producteur ?';

  @override
  String get guideIsName => 'est-ce le nom du vin ?';

  @override
  String get guideIsVintage => 'Millésime';

  @override
  String guideAskDenomination(String value) {
    return 'Est-ce que $value est l\'appellation ?';
  }

  @override
  String guideAskProducer(String value) {
    return 'Est-ce que $value est le producteur ?';
  }

  @override
  String guideAskName(String value) {
    return 'Est-ce que $value est le nom du vin ?';
  }

  @override
  String get guideAskVintage => 'Quel est le millésime ?';

  @override
  String guideQuestionSemantics(int n, int total, String question) {
    return 'Question $n sur $total : $question';
  }

  @override
  String get guideNoProposal => 'Je ne l\'ai pas trouvé dans le texte';

  @override
  String get guideYes => 'Oui';

  @override
  String get guideNo => 'Non, autre';

  @override
  String get guideEdit => 'Modifier';

  @override
  String get guideSkip => 'Passer';

  @override
  String get guideConfirm => 'Confirmer';

  @override
  String get guideCancel => 'Annuler';

  @override
  String guideRejected(String value) {
    return 'Pas « $value » : voici la suggestion suivante';
  }

  @override
  String get guideNoMore => 'Aucune autre suggestion : composez-la ou passez';

  @override
  String guideProposalAnnounce(String value) {
    return 'Suggestion : $value';
  }

  @override
  String get guideComposeLabel =>
      'Ou composez-la en touchant des mots du texte';

  @override
  String get guideComposePreview => 'Prévisualisation';

  @override
  String get guideComposeEmpty => 'Touchez un ou plusieurs mots';

  @override
  String get guideComposeLimit => '8 mots et 80 caractères maximum';

  @override
  String guideTableMatchSemantics(String name) {
    return 'correspond à $name';
  }

  @override
  String guideLine(int n, int total) {
    return 'Ligne $n sur $total';
  }

  @override
  String guideWordSelected(String word, int order) {
    return '$word, sélectionné, $order';
  }

  @override
  String guideWordUnavailable(String word) {
    return '$word, indisponible';
  }

  @override
  String guideWordUsedFor(String word, String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'l\'appellation',
      'producer': 'le producteur',
      'other': 'le nom',
    });
    return '$word, utilisé pour $_temp0';
  }

  @override
  String guideUsedMark(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'appellation',
      'producer': 'producteur',
      'other': 'nom',
    });
    return '$_temp0';
  }

  @override
  String guideOtherYears(String years) {
    return 'Aussi dans le texte : $years';
  }

  @override
  String get guideWheelFromText => 'année trouvée dans le texte';

  @override
  String get guideWheelTypeYear => 'Saisissez l\'année';

  @override
  String guideWheelConfirm(String year) {
    return 'Confirmer $year';
  }

  @override
  String get guideNoVintage => 'Sans millésime';

  @override
  String guideSkippedNotice(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'Appellation ignorée',
      'producer': 'Producteur ignoré',
      'vintage': 'Millésime ignoré',
      'other': 'Nom ignoré',
    });
    return '$_temp0 : saisissez ce champ ou reprenez le guide';
  }

  @override
  String guideSkippedMany(int count) {
    return '$count champs ignorés : saisissez-les ou reprenez le guide';
  }

  @override
  String get guideInvalidValue =>
      'Ce texte contient des caractères qui ne peuvent pas être enregistrés';

  @override
  String get brandStudio => 'Bottazzini Softworks';

  @override
  String get suggestedMark => '✦ suggéré';

  @override
  String suggestedSemantics(String field, String value) {
    return '$field, $value, suggéré';
  }

  @override
  String get restoreSuggestion => 'Rétablir la suggestion';

  @override
  String get restoreSuggestionDone => 'Suggestion rétablie';

  @override
  String get styleLabel => 'Style';

  @override
  String styleGroupSemantics(String value, int index, int count) {
    return 'Style, $value, $index sur $count';
  }

  @override
  String get styleRedFresh => 'Frais';

  @override
  String get styleRedMedium => 'Moyen';

  @override
  String get styleRedAge => 'De garde';

  @override
  String get styleRedLong => 'Longue garde';

  @override
  String get styleWhiteFresh => 'Frais';

  @override
  String get styleWhiteMedium => 'Moyen';

  @override
  String get styleWhiteAge => 'De garde';

  @override
  String get styleRoseFresh => 'Frais';

  @override
  String get styleClassicFresh => 'Frais';

  @override
  String get styleClassicAge => 'De garde';

  @override
  String get styleTankFresh => 'Frais';

  @override
  String get styleLambrusco => 'Lambrusco';

  @override
  String get styleSweetAromatic => 'Aromatique';

  @override
  String get styleSweetPassito => 'Passerillé';

  @override
  String get styleSweetBotrytis => 'Botrytisé';

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
  String get styleMadeira => 'Madère';

  @override
  String get styleFortifiedOther => 'Autre';

  @override
  String get profileNameRFresh => 'Rouge sur le fruit';

  @override
  String get profileNameRMedium => 'Rouge de corps moyen';

  @override
  String get profileNameRAge => 'Rouge de garde';

  @override
  String get profileNameRLong => 'Rouge de longue garde';

  @override
  String get profileNameWFresh => 'Blanc frais et aromatique';

  @override
  String get profileNameWMedium => 'Blanc de corps moyen';

  @override
  String get profileNameWAge => 'Blanc de garde';

  @override
  String get profileNameRoseFresh => 'Rosé frais';

  @override
  String get profileNameSpTank => 'Effervescent Charmat frais';

  @override
  String get profileNameLamFresh => 'Lambrusco frais';

  @override
  String get profileNameSpClassic => 'Méthode traditionnelle, frais';

  @override
  String get profileNameSpClassicAge => 'Méthode traditionnelle, de garde';

  @override
  String get profileNameSwAromatic => 'Vin doux aromatique jeune';

  @override
  String get profileNameSwPassito => 'Vin doux passerillé';

  @override
  String get profileNameSwBotrytis => 'Vin doux botrytisé';

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
  String get profileNameShPx => 'Xérès Pedro Ximénez';

  @override
  String get profileNameFortUnknown => 'Vin muté, style inconnu';

  @override
  String get profileNameUnknown => 'Style non identifié';

  @override
  String estimateFromProfile(String profile, String denomination) {
    return 'Estimation d\'après le profil $profile ($denomination)';
  }

  @override
  String estimateFromProfileType(String profile) {
    return 'Estimation d\'après le profil $profile, selon le type';
  }

  @override
  String estimateFromProfileGrape(String profile, String grape) {
    return 'Estimation d\'après le profil $profile, selon le cépage $grape';
  }

  @override
  String get estimateFromEntryDateDisgorgement =>
      'D\'après la date d\'ajout : ajoutez la date de dégorgement pour une meilleure estimation';

  @override
  String get estimateFromEntryDateBottling =>
      'D\'après la date d\'ajout : ajoutez la date de mise en bouteille pour une meilleure estimation';

  @override
  String get styleToConfirmBanner =>
      '⚠︎ Style à confirmer : l\'estimation est indicative';

  @override
  String get chooseTypePrompt => 'Choisissez le type';

  @override
  String estimateUpdatedAnnouncement(String summary) {
    return 'Estimation mise à jour : $summary';
  }

  @override
  String get agingStartDisgorgement => 'Dégorgement';

  @override
  String get agingStartBottling => 'Mise en bouteille';

  @override
  String get agingStartMonth => 'Mois';

  @override
  String get agingStartYear => 'Année';

  @override
  String get agingStartHint =>
      'Elle figure généralement sur la contre-étiquette.';

  @override
  String get agingStartIncomplete => 'Indiquez le mois et l\'année';

  @override
  String get agingStartFuture => 'La date ne peut pas être dans le futur';

  @override
  String get agingStartBeforeVintage =>
      'Elle ne peut pas précéder le millésime';

  @override
  String get windowNoEnd => 'Prêt, sans fin estimée';

  @override
  String get windowNoEndShort => 'sans fin estimée';

  @override
  String windowDrinkWithin(String date) {
    return 'd\'ici $date';
  }

  @override
  String get levelNoEffect => 'Le niveau ne modifie pas cette estimation';

  @override
  String get dashboardToConfirmTitle => 'À confirmer';

  @override
  String dashboardToConfirmCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vins',
      one: '$count vin',
    );
    return '$_temp0';
  }

  @override
  String aboutDbClassified(String percent) {
    return '$percent % des vins dont le type est reconnu';
  }

  @override
  String get planTitle => 'Formule';

  @override
  String get planFree => 'Gratuite';

  @override
  String get planPlus => 'Plus';

  @override
  String get planPlusGift => 'Plus (offert)';

  @override
  String get planDevUnlockAll => 'DEV · Plus de test';

  @override
  String get planDevSimulateFree => 'DEV · Formule gratuite simulée';

  @override
  String get planDevSimulateExpired => 'DEV · Plus expiré simulé';

  @override
  String get planDiscoverPlus => 'Découvrir Plus';

  @override
  String get plusTitle => 'Vinoozy Plus';

  @override
  String get plusBenefitsTitle => 'Avec Plus';

  @override
  String get plusBenefitNoAds => 'Sans publicité';

  @override
  String get plusBenefitNoLimit => 'Aucune limite de vins dans votre cave';

  @override
  String get plusComingSoon => 'Plus arrive bientôt';

  @override
  String get plusLoading => 'Lecture des prix sur Google Play';

  @override
  String get plusStoreUnavailable =>
      'Impossible de lire les prix sur Google Play. Réessayez plus tard.';

  @override
  String plusPriceMonthly(String price) {
    return '$price par mois';
  }

  @override
  String plusPriceAnnual(String price) {
    return '$price par an';
  }

  @override
  String get plusRenewal =>
      'L\'abonnement se renouvelle automatiquement au prix indiqué jusqu\'à ce que vous le résiliiez sur Google Play.';

  @override
  String get plusTerms =>
      'Le paiement est débité de votre compte Google Play à la confirmation de l\'achat. Vous pouvez résilier à tout moment : Plus reste actif jusqu\'à la fin de la période déjà payée. Quand Plus prend fin, tous vos vins sont conservés.';

  @override
  String get plusRestore => 'Restaurer les achats';

  @override
  String get plusManage => 'Gérer ou résilier l\'abonnement sur Google Play';

  @override
  String get plusActive => 'Plus est actif sur ce compte';

  @override
  String get plusActiveGift =>
      'Plus vous est offert : aucun débit, aucun renouvellement.';

  @override
  String get plusPending =>
      'Paiement en attente : Plus sera actif dès que Google Play l\'aura confirmé.';

  @override
  String get plusVerifying => 'Vérification de l\'achat';

  @override
  String get plusVerified =>
      'Achat vérifié : Plus sera actif dans quelques secondes.';

  @override
  String get plusPurchaseFailed => 'L\'achat n\'a pas abouti. Réessayez.';

  @override
  String get plusInvalidPurchase =>
      'Google Play n\'a pas confirmé cet achat pour Vinoozy.';

  @override
  String get plusOwnedByOther =>
      'Cet abonnement appartient déjà à un autre compte Vinoozy.';

  @override
  String get plusVerificationUnavailable =>
      'Impossible de vérifier l\'achat pour le moment. Réessayez plus tard : l\'abonnement reste sur Google Play.';

  @override
  String get capacityLimitTitle =>
      'Vous avez atteint la limite de la formule gratuite';

  @override
  String capacityLimitBody(int limit) {
    return 'La formule gratuite comprend jusqu\'à $limit vins différents dans votre cave. Vous pouvez toujours modifier, boire et ajouter des bouteilles aux vins que vous avez déjà. Pour en ajouter un nouveau, terminez ou supprimez un vin, ou passez à Plus.';
  }

  @override
  String capacityLimitBodyComingSoon(int limit) {
    return 'La formule gratuite comprend jusqu\'à $limit vins différents dans votre cave. Vous pouvez toujours modifier, boire et ajouter des bouteilles aux vins que vous avez déjà. Pour en ajouter un nouveau, terminez ou supprimez un vin. Plus arrive bientôt.';
  }

  @override
  String get rejectedCapacityLimit =>
      'Non synchronisé : la limite de vins de la formule gratuite est dépassée. La modification reste sur ce téléphone.';

  @override
  String get rejectedCapacityConflict =>
      'Non synchronisé : la cave a changé au même moment sur un autre appareil. La modification reste sur ce téléphone : réessayez.';

  @override
  String writeRejectedCapacityLimit(String name) {
    return '$name : non synchronisé, limite de la formule gratuite dépassée';
  }

  @override
  String writeRejectedCapacityConflict(String name) {
    return '$name : non synchronisé, la cave a changé sur un autre appareil';
  }

  @override
  String get freeIntroTitle => 'La formule gratuite';

  @override
  String freeIntroLimit(int limit) {
    return 'Vous pouvez gérer gratuitement jusqu\'à $limit vins différents.';
  }

  @override
  String get freeIntroAds =>
      'Une utilisation légère est sans publicité. Si vous dépassez le seuil mensuel d\'utilisation du service, vous verrez peut-être des publicités occasionnelles qui aident à couvrir les coûts des serveurs et de la synchronisation.';

  @override
  String get freeIntroNoAds => 'Aucune publicité dans la version de lancement.';

  @override
  String get freeIntroPlus =>
      'Avec Plus, vous supprimez les publicités et la limite de la cave.';

  @override
  String get noticeGotIt => 'Compris';

  @override
  String get thresholdTitle => 'Les publicités aident à garder Vinoozy gratuit';

  @override
  String get thresholdBody =>
      'Vous avez atteint le seuil mensuel d\'utilisation sans publicité. Désormais, vous verrez peut-être des publicités occasionnelles : elles nous aident à couvrir les coûts des serveurs et de la synchronisation, pour que Vinoozy reste gratuit.';

  @override
  String get thresholdReset =>
      'Le compteur repart à zéro le mois prochain. Avec Plus, vous utilisez l\'application sans publicité et sans limite de cave.';

  @override
  String thresholdNextReset(String date) {
    return 'Prochaine remise à zéro : $date';
  }

  @override
  String get thresholdHowItWorks => 'Comment ça marche';

  @override
  String get thresholdHowItWorksBody =>
      'Le seuil dépend d\'une estimation des synchronisations avec le cloud effectuées par ce compte au cours du mois. L\'utilisation hors ligne ne crée à elle seule aucune nouvelle opération dans le cloud. Les publicités apparaissent au maximum une fois par jour, uniquement dans l\'Aperçu, et jamais pendant que vous enregistrez ou exportez vos données.';

  @override
  String get adLabel => 'Publicité';

  @override
  String get devToolsTitle => 'Outils de développement';

  @override
  String get devUnlockAll => 'Tout débloquer — Plus de test';

  @override
  String get devSimulateFree => 'Simuler la formule gratuite';

  @override
  String get devSimulateExpired => 'Simuler Plus expiré';

  @override
  String get devRestore => 'Rétablir l\'état normal';

  @override
  String get devNoOverride => 'Aucune simulation active';

  @override
  String get devApplied =>
      'Scénario appliqué aussi dans l\'émulateur Firestore';

  @override
  String get devIncomplete =>
      'Simulation incomplète : l\'émulateur Firestore n\'a pas confirmé le droit de test. Les règles du serveur ne voient pas ce scénario.';

  @override
  String get devNotice =>
      'Builds de développement avec l\'émulateur uniquement : aucun paiement, jeton ou reçu.';
}
