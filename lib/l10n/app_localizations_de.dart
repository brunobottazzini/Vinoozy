// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Vinoozy';

  @override
  String get signInTagline => 'Dein Weinkeller, zur richtigen Zeit';

  @override
  String get signInWithGoogle => 'Weiter mit Google';

  @override
  String get signInInProgress => 'Anmeldung läuft';

  @override
  String get signInFailed => 'Anmeldung fehlgeschlagen';

  @override
  String get signInNeedsNetwork =>
      'Für die erste Anmeldung brauchst du eine Verbindung';

  @override
  String get signInSessionExpired =>
      'Deine Sitzung ist abgelaufen: Melde dich erneut an';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String blockedMessage(String email) {
    return 'Es gibt Änderungen von $email, die noch nicht in der Cloud gespeichert sind: Melde dich mit diesem Konto an und stelle eine Netzverbindung her';
  }

  @override
  String blockedSignInWith(String email) {
    return 'Mit $email anmelden';
  }

  @override
  String blockedDiscard(String email) {
    return 'Ungespeicherte Änderungen von $email löschen';
  }

  @override
  String get discardDialogTitle => 'Änderungen löschen?';

  @override
  String discardDialogBody(int count, String email) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count Weine von $email sind noch nicht in der Cloud und werden von diesem Telefon gelöscht.',
      one:
          '1 Wein von $email ist noch nicht in der Cloud und wird von diesem Telefon gelöscht.',
    );
    return '$_temp0';
  }

  @override
  String get discardConfirm => 'Löschen';

  @override
  String get resetFailed =>
      'Die Daten auf diesem Telefon konnten nicht gelöscht werden';

  @override
  String get restartRequired => 'Starte die App neu, um abzuschließen';

  @override
  String get restartCloseApp => 'App schließen';

  @override
  String get startupFailed => 'Die App konnte nicht gestartet werden';

  @override
  String get cellarTitle => 'Keller';

  @override
  String get defaultCellarName => 'Mein Keller';

  @override
  String get cellarLoading => 'Keller wird vorbereitet';

  @override
  String get cellarSetupFailed => 'Der Keller konnte nicht vorbereitet werden';

  @override
  String get cellarEmpty => 'Dein Keller ist leer';

  @override
  String get addWine => 'Hinzufügen';

  @override
  String get estimatePending => 'Schätzung folgt';

  @override
  String get noVintage => 'Ohne Jahrgang';

  @override
  String bottleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Flaschen',
      one: '1 Flasche',
    );
    return '$_temp0';
  }

  @override
  String get syncInProgress => 'Synchronisiert';

  @override
  String get syncOffline => 'Offline - Synchronisierung ausstehend';

  @override
  String writeRejected(String name) {
    return 'Änderung nicht erlaubt: $name';
  }

  @override
  String get saveFailed => 'Speichern fehlgeschlagen, versuch es noch einmal';

  @override
  String wineNotSaved(String name) {
    return 'Der Wein $name wurde nicht in der Cloud gespeichert';
  }

  @override
  String get addAgain => 'Erneut hinzufügen';

  @override
  String get ignore => 'Ignorieren';

  @override
  String get addWineTitle => 'Eingeben';

  @override
  String get wineNameLabel => 'Wein';

  @override
  String get vintageLabel => 'Jahrgang';

  @override
  String get quantityLabel => 'Anzahl';

  @override
  String get decreaseQuantity => 'Anzahl verringern';

  @override
  String get increaseQuantity => 'Anzahl erhöhen';

  @override
  String get save => 'Speichern';

  @override
  String get nameRequired => 'Gib den Namen des Weins ein';

  @override
  String get nameTooLong => 'Höchstens 120 Zeichen';

  @override
  String vintageRange(String year) {
    return 'Jahrgang zwischen 1900 und $year';
  }

  @override
  String get offAttribution => 'Daten von Open Food Facts (ODbL)';

  @override
  String get dashboardTitle => 'Übersicht';

  @override
  String dashboardTotalBottles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Flaschen im Keller',
      one: '1 Flasche im Keller',
    );
    return '$_temp0';
  }

  @override
  String get dashboardSyncing => 'Keller wird synchronisiert…';

  @override
  String get dashboardAddFirstWine => 'Ersten Wein hinzufügen';

  @override
  String get drinkSoonTitle => 'Bald trinken';

  @override
  String get drinkSoonEmpty => 'Keine Flaschen bald fällig';

  @override
  String drinkSoonUntil(String year) {
    return 'bis $year';
  }

  @override
  String drinkSoonSeeAll(int count) {
    return 'Alle anzeigen ($count)';
  }

  @override
  String get statusChartTitle => 'Status der Flaschen';

  @override
  String get statusWaiting => 'noch lagern';

  @override
  String get statusReady => 'trinkreif';

  @override
  String get statusDrinkSoon => 'bald trinken';

  @override
  String get statusPastWindow => 'Fenster vorbei';

  @override
  String toEstimateNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Flaschen ohne Schätzung',
      one: '1 Flasche ohne Schätzung',
    );
    return '$_temp0';
  }

  @override
  String chartBarValue(String label, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Flaschen',
      one: '1 Flasche',
    );
    return '$label: $_temp0';
  }

  @override
  String chartDescription(String title, String values) {
    return '$title: $values';
  }

  @override
  String get openListHint => 'Liste öffnen';

  @override
  String get peakChartTitle => 'Jahr des Höhepunkts';

  @override
  String get peakPast => 'Höhepunkt vorbei';

  @override
  String get peakBeyond => 'später';

  @override
  String get breakdownTypeTitle => 'Flaschen nach Typ';

  @override
  String get breakdownRegionTitle => 'Flaschen nach Region';

  @override
  String get breakdownType => 'Typ';

  @override
  String get breakdownRegion => 'Region';

  @override
  String get familyRed => 'rot';

  @override
  String get familyWhite => 'weiß';

  @override
  String get familyRose => 'rosé';

  @override
  String get familySparkling => 'Schaumwein';

  @override
  String get familySweet => 'süß';

  @override
  String get breakdownUnspecified => 'ohne Angabe';

  @override
  String get breakdownOtherRegions => 'andere';

  @override
  String get ok => 'OK';

  @override
  String get cellarMenu => 'Kellermenü';

  @override
  String get sharingPeopleTitle => 'Personen';

  @override
  String get sharingInviteTitle => 'Person einladen';

  @override
  String get sharingEmailLabel => 'Google-E-Mail-Adresse';

  @override
  String get sharingPermissionRead => 'Nur lesen';

  @override
  String get sharingPermissionReadHint =>
      'Sieht Weine, Schätzungen, Übersicht und Getrunkenes';

  @override
  String get sharingPermissionEdit => 'Darf bearbeiten';

  @override
  String get sharingPermissionEditHint =>
      'Fügt auch Weine hinzu, ändert sie und trägt Getrunkenes ein';

  @override
  String get sharingRoleOwner => 'Inhaber';

  @override
  String get sharingInviteButton => 'Einladen';

  @override
  String sharingPlacesUsed(int used, int max) {
    return '$used/$max Personen';
  }

  @override
  String get sharingInvalidEmail => 'Gib eine gültige E-Mail-Adresse ein';

  @override
  String get sharingSelfInvite => 'Du kannst dich nicht selbst einladen';

  @override
  String get sharingAlreadyInvited => 'Diese Person ist schon eingeladen';

  @override
  String sharingLimitReached(int max) {
    return 'Du hast das Limit von $max Personen erreicht';
  }

  @override
  String get sharingNotOwner =>
      'Du kannst die Freigabe dieses Kellers nicht ändern';

  @override
  String get sharingNotFound => 'Diese Person steht nicht mehr in der Liste';

  @override
  String get sharingFailed => 'Das hat nicht geklappt, versuch es noch einmal';

  @override
  String get sharingInviteFailed =>
      'Einladung fehlgeschlagen. Versuch es noch einmal';

  @override
  String get sharingOfflineHint =>
      'Für die Freigabe brauchst du eine Verbindung';

  @override
  String get sharingStatusInvited => 'eingeladen';

  @override
  String get sharingStatusActive => 'aktiv';

  @override
  String get sharingStatusRevoked => 'entzogen';

  @override
  String get sharingStatusLeft => 'ausgetreten';

  @override
  String sharingMemberSemantics(String name, String permission, String status) {
    return '$name, $permission, $status';
  }

  @override
  String get sharingClosedSection => 'Beendete Zugriffe';

  @override
  String get sharingNobody => 'Noch sieht niemand sonst diesen Keller';

  @override
  String sharingChangePermission(String name) {
    return 'Berechtigung von $name ändern';
  }

  @override
  String get sharingRevoke => 'Entziehen';

  @override
  String sharingRevokeTitle(String name) {
    return '$name den Zugriff entziehen?';
  }

  @override
  String sharingRevokeConfirmLabel(String name) {
    return 'Gib zur Bestätigung $name ein';
  }

  @override
  String get sharingRevokeDisabledHint =>
      'Aktiv, sobald der Name übereinstimmt';

  @override
  String get sharingReinvite => 'Erneut einladen';

  @override
  String get sharingDeleteForGood => 'Endgültig löschen';

  @override
  String sharingOwnedBy(String owner) {
    return 'Keller von $owner';
  }

  @override
  String get sharingYourCellar => 'Dein Keller';

  @override
  String sharingYourPermission(String permission) {
    return 'Deine Berechtigung: $permission';
  }

  @override
  String sharingSwitcherSemantics(String cellar, String permission) {
    return '$cellar, $permission. Tippen, um den Keller zu wechseln';
  }

  @override
  String get sharingLeave => 'Diesen Keller verlassen';

  @override
  String sharingLeaveTitle(String owner) {
    return 'Keller von $owner verlassen?';
  }

  @override
  String sharingLeaveBody(String owner) {
    return 'Du siehst ihn dann nicht mehr. $owner kann dich erneut einladen.';
  }

  @override
  String get sharingLeaveConfirm => 'Verlassen';

  @override
  String sharingSharedNotice(String owner) {
    return '$owner hat den eigenen Keller mit dir geteilt';
  }

  @override
  String sharingAccessLost(String owner) {
    return 'Du hast keinen Zugriff mehr auf den Keller von $owner';
  }

  @override
  String sharingWritesLost(String owner) {
    return 'Einige Änderungen am Keller von $owner wurden nicht gespeichert, weil du keinen Zugriff mehr hast';
  }

  @override
  String get sharingSomeone => 'jemand';

  @override
  String get sharingShareSubject => 'Einladung zu Vinoozy';

  @override
  String sharingShareMessage(
    String owner,
    String cellar,
    String link,
    String email,
  ) {
    return '$owner hat dich in den Keller „$cellar“ bei Vinoozy eingeladen. Installiere die App über $link und melde dich mit dem Google-Konto $email an: Verwende genau diese Adresse.';
  }

  @override
  String get cellarSearchHint => 'Nach Name oder Erzeuger suchen';

  @override
  String get cellarFilterStatus => 'Status';

  @override
  String get cellarFilterType => 'Typ';

  @override
  String get statusToEstimate => 'Ohne Schätzung';

  @override
  String get filterTypeUnspecified => 'Ohne Angabe';

  @override
  String get cellarNoMatches => 'Kein Wein mit diesen Filtern';

  @override
  String get cellarClearFilters => 'Filter löschen';

  @override
  String get cellarArchiveTitle => 'Getrunken';

  @override
  String get cellarArchiveEmpty => 'Noch keine ausgetrunkenen Weine';

  @override
  String get cellarArchiveFailed =>
      'Die ausgetrunkenen Weine konnten nicht geladen werden';

  @override
  String get wineDrink => 'Getrunken';

  @override
  String wineDrinkTooltip(String name) {
    return 'Eine Flasche $name als getrunken markieren';
  }

  @override
  String confidenceLabel(String level) {
    return 'Sicherheit: $level';
  }

  @override
  String get confidenceHigh => 'hoch';

  @override
  String get confidenceMedium => 'mittel';

  @override
  String get confidenceLow => 'niedrig';

  @override
  String get windowStartLabel => 'Beginn';

  @override
  String get windowPeakLabel => 'Höhepunkt';

  @override
  String get windowEndLabel => 'Ende';

  @override
  String estimateSourceLabel(String source) {
    return 'Quelle: $source';
  }

  @override
  String get estimateSourceCatalog => 'Weindatenbank';

  @override
  String get estimateSourceType => 'Schätzung nach Typ';

  @override
  String get estimateSourceCorrected =>
      'Schätzung, korrigiert durch deine getrunkenen Flaschen';

  @override
  String get estimateDisclaimer =>
      'Richtwert: Er hängt auch davon ab, wie die Flasche gelagert wurde';

  @override
  String get estimateUnavailable => 'Keine Schätzung verfügbar';

  @override
  String get pairingsTitle => 'Passt zu';

  @override
  String get pairingsGeneric => 'allgemeine Speiseempfehlungen für den Typ';

  @override
  String get pairingBraisedRedMeat => 'Geschmortes rotes Fleisch';

  @override
  String get pairingGrilledRedMeat => 'Gegrilltes rotes Fleisch';

  @override
  String get pairingGame => 'Wild';

  @override
  String get pairingRoastPoultry => 'Gebratenes Geflügel';

  @override
  String get pairingPoultry => 'Geflügel';

  @override
  String get pairingPork => 'Schwein';

  @override
  String get pairingCuredMeats => 'Wurst und Schinken';

  @override
  String get pairingPastaMeatSauce => 'Pasta mit Fleischsauce';

  @override
  String get pairingMushroomsTruffle => 'Pilze und Trüffel';

  @override
  String get pairingAgedCheese => 'Gereifter Käse';

  @override
  String get pairingFreshCheese => 'Frischkäse';

  @override
  String get pairingBlueCheese => 'Blauschimmelkäse';

  @override
  String get pairingFish => 'Fisch';

  @override
  String get pairingSeafood => 'Meeresfrüchte';

  @override
  String get pairingRawSeafood => 'Rohe Meeresfrüchte';

  @override
  String get pairingFriedFood => 'Frittiertes';

  @override
  String get pairingVegetables => 'Gemüse';

  @override
  String get pairingRisotto => 'Risotto';

  @override
  String get pairingPizza => 'Pizza';

  @override
  String get pairingAperitif => 'Aperitif';

  @override
  String get pairingPastries => 'Feingebäck';

  @override
  String get pairingDryBiscuits => 'Trockengebäck';

  @override
  String get pairingChocolate => 'Schokolade';

  @override
  String get pairingDriedFruit => 'Nüsse und Trockenfrüchte';

  @override
  String get pairingSpicyDishes => 'Würzige Gerichte';

  @override
  String get recentDrinksTitle => 'Zuletzt getrunken';

  @override
  String get noDrinksYet => 'Noch nichts getrunken';

  @override
  String get wineEdit => 'Bearbeiten';

  @override
  String get wineDelete => 'Löschen';

  @override
  String get wineFinished => 'Ausgetrunken: keine Flasche mehr';

  @override
  String get wineLoadFailed => 'Der Wein konnte nicht geöffnet werden';

  @override
  String get wineNotFound => 'Diesen Wein gibt es nicht mehr';

  @override
  String drinkDone(String name) {
    return 'Als getrunken markiert: $name';
  }

  @override
  String get drinkUndo => 'Rückgängig';

  @override
  String get drinkAddNotes => 'Bewertung und Notizen hinzufügen';

  @override
  String get nothingToUndo => 'Nichts mehr rückgängig zu machen';

  @override
  String get cellarUndoRejected =>
      'Rückgängig fehlgeschlagen: Die Flasche bleibt als getrunken markiert';

  @override
  String get cellarDeleteFailed =>
      'Das Löschen ist noch nicht abgeschlossen: Es wird so bald wie möglich beendet';

  @override
  String get duplicateFull =>
      'Dieser Wein hat schon 99 Flaschen: Mehr geht nicht.';

  @override
  String get recordSheetTitle => 'Bewertung und Notizen';

  @override
  String get recordRatingLabel => 'Bewertung';

  @override
  String ratingStar(int n) {
    return 'Bewertung $n von 5';
  }

  @override
  String get recordNotesLabel => 'Notizen';

  @override
  String get recordNotesTooLong => 'Höchstens 1000 Zeichen';

  @override
  String recordDateLabel(String date) {
    return 'Datum: $date';
  }

  @override
  String get recordDateInvalid =>
      'Das Datum darf nicht in der Zukunft und nicht vor dem Jahrgang liegen';

  @override
  String get recordConditionTitle => 'Wie war er?';

  @override
  String get conditionTooYoung => 'Noch zu jung';

  @override
  String get conditionJustRight => 'Genau richtig';

  @override
  String get conditionPastPeak => 'Höhepunkt schon vorbei';

  @override
  String get recordNoCondition => 'Keine Angabe';

  @override
  String get producerLabel => 'Erzeuger (optional)';

  @override
  String get producerTooLong => 'Höchstens 120 Zeichen';

  @override
  String producerAddNew(String name) {
    return '„$name“ als neuen Erzeuger hinzufügen';
  }

  @override
  String get wineTypeLabel => 'Typ';

  @override
  String get typeRedLight => 'Leichter Rotwein';

  @override
  String get typeRedStructured => 'Kräftiger Rotwein';

  @override
  String get typeWhite => 'Weißwein';

  @override
  String get typeRose => 'Rosé';

  @override
  String get typeSparklingClassic => 'Schaumwein, Flaschengärung';

  @override
  String get typeSparklingTank => 'Schaumwein, Tankgärung';

  @override
  String get typeSweet => 'Süßwein';

  @override
  String get typeFortified => 'Likörwein';

  @override
  String get suggestionFromCellar => 'In deinem Keller';

  @override
  String get suggestionsLabel => 'Vorschläge';

  @override
  String get duplicateTitle => 'Schon im Keller';

  @override
  String duplicateBody(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Flaschen',
      one: '1 Flasche',
      zero: 'keiner Flasche',
    );
    return '$name ist schon da, mit $_temp0. Die neuen Flaschen dort hinzufügen?';
  }

  @override
  String duplicateAdd(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Flaschen hinzufügen',
      one: '1 Flasche hinzufügen',
    );
    return '$_temp0';
  }

  @override
  String get duplicateBanner => 'Mögliches Duplikat';

  @override
  String get duplicateMerge => 'Zusammenführen';

  @override
  String get duplicateDeleteHint =>
      'Lösche diesen Eintrag, wenn er ein Duplikat ist';

  @override
  String get mergeTitle => 'Beide Einträge zusammenführen?';

  @override
  String get mergeBody =>
      'Die Flaschen dieses Eintrags gehen an den älteren, dann wird dieser Eintrag gelöscht.';

  @override
  String get editWineTitle => 'Wein bearbeiten';

  @override
  String get editDuplicate =>
      'Es gibt schon einen Wein mit gleichem Namen, Erzeuger und Jahrgang';

  @override
  String deleteWineTitle(String name) {
    return '$name löschen?';
  }

  @override
  String get deleteWineBody =>
      'Der Wein und alle Einträge zu getrunkenen Flaschen werden gelöscht. Das lässt sich nicht rückgängig machen.';

  @override
  String get historyTitle => 'Verlauf';

  @override
  String get historyEmpty =>
      'Hier findest du die Flaschen, die du getrunken hast';

  @override
  String get historyLoadFailed => 'Der Verlauf konnte nicht geladen werden';

  @override
  String drankOnLabel(String date) {
    return 'Getrunken am $date';
  }

  @override
  String get addChoiceTitle => 'Wein hinzufügen';

  @override
  String get addChoicePhoto => 'Foto aufnehmen';

  @override
  String get addChoiceImport => 'Foto importieren';

  @override
  String get addChoiceWrite => 'Eingeben';

  @override
  String get labelReading => 'Ich lese das Etikett…';

  @override
  String get labelRecognized => 'Ich habe erkannt:';

  @override
  String get labelCorrect => 'Korrigieren';

  @override
  String get labelConfirm => 'Bestätigen';

  @override
  String get labelUnreadable => 'Ich kann das Etikett nicht lesen';

  @override
  String get labelWriteByHand => 'Von Hand eingeben';

  @override
  String get labelNotFound =>
      'Ich habe den Wein nicht gefunden: Prüfe die Angaben';

  @override
  String get labelCameraDenied =>
      'Um das Etikett zu lesen, brauche ich Zugriff auf die Kamera';

  @override
  String get labelPhotosDenied =>
      'Um das Etikett zu lesen, brauche ich Zugriff auf die Fotos';

  @override
  String get labelOpenSettings => 'Einstellungen öffnen';

  @override
  String get labelCameraUnavailable => 'Kamera nicht verfügbar';

  @override
  String get labelBarcodeNotFound =>
      'Ich habe den Barcode gelesen, finde den Wein aber nicht';

  @override
  String get labelBarcodeFrontHint =>
      'Fotografiere die Vorderseite des Etiketts';

  @override
  String get labelSharedNotAllowed =>
      'Du kannst diesem Keller keine Weine hinzufügen';

  @override
  String get labelSharedFirstOnly => 'Ich habe nur das erste Foto verwendet';

  @override
  String get labelSharedExpired =>
      'Das geteilte Foto konnte nicht gelesen werden: Teile es noch einmal';

  @override
  String get labelReplaceTitle =>
      'Du hast einen ungespeicherten Wein. Das neue Foto lesen?';

  @override
  String get labelReplaceRead => 'Neues Foto lesen';

  @override
  String get labelReplaceKeep => 'Mit dem offenen weitermachen';

  @override
  String get labelWineAdded => 'Wein zum Keller hinzugefügt';

  @override
  String get onboardingPage1Title => 'Dein Weinkeller in der Tasche';

  @override
  String get onboardingPage1Body =>
      'Trag deine Flaschen ein, von Hand oder mit einem Foto des Etiketts, auch ohne Netz.';

  @override
  String get onboardingPage2Title => 'Zur richtigen Zeit';

  @override
  String get onboardingPage2Body =>
      'Vinoozy schätzt, wann jeder Wein am besten ist, und sagt dir, welche du zuerst öffnen solltest.';

  @override
  String get onboardingPage3Title => 'Gemeinsam';

  @override
  String get onboardingPage3Body =>
      'Teile deinen Keller mit bis zu zwei Personen und behalte den Verlauf jeder getrunkenen Flasche.';

  @override
  String get onboardingSkip => 'Überspringen';

  @override
  String get onboardingNext => 'Weiter';

  @override
  String get onboardingStart => 'Starten';

  @override
  String onboardingPageOf(int page) {
    return 'Seite $page von 3';
  }

  @override
  String get profileTitle => 'Profil';

  @override
  String get profilePhoto => 'Profilfoto';

  @override
  String get profileSignOut => 'Abmelden';

  @override
  String get profileDeleteAccount => 'Konto löschen';

  @override
  String get profilePrivacy => 'Datenschutzerklärung';

  @override
  String get profilePrivacyBody =>
      'Die Datenschutzerklärung findest du unter dieser Adresse:';

  @override
  String get profileOpenLink => 'Im Browser öffnen';

  @override
  String get profileOpenLinkFailed =>
      'Die Seite konnte nicht geöffnet werden. Du kannst den Link kopieren und im Browser öffnen.';

  @override
  String get profileCopyLink => 'Link kopieren';

  @override
  String get profileLinkCopied => 'Link kopiert';

  @override
  String get close => 'Schließen';

  @override
  String get signOutConfirmTitle => 'Möchtest du dich abmelden?';

  @override
  String signOutPendingWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Du hast $count noch nicht gespeicherte Änderungen. Wenn du dich abmeldest und sich ein anderes Konto anmeldet, gehen sie verloren.',
      one: 'Du hast 1 noch nicht gespeicherte Änderung. Wenn du dich abmeldest und sich ein anderes Konto anmeldet, geht sie verloren.',
    );
    return '$_temp0';
  }

  @override
  String get signOutStayAndSync => 'Bleiben und synchronisieren';

  @override
  String get signOutAnyway => 'Trotzdem abmelden';

  @override
  String get syncAllSaved => 'Alles gespeichert';

  @override
  String syncStillPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Noch $count Änderungen zu speichern: Prüfe das Netz',
      one: 'Noch 1 Änderung zu speichern: Prüfe das Netz',
    );
    return '$_temp0';
  }

  @override
  String get signOutFailed => 'Abmelden fehlgeschlagen. Versuch es noch einmal';

  @override
  String get signInAccountDeleted => 'Konto gelöscht';

  @override
  String get deleteAccountIntro => 'Das wird endgültig gelöscht:';

  @override
  String get deleteAccountItemCellar =>
      'Dein Keller mit seinen Weinen und dem Verlauf';

  @override
  String get deleteAccountItemShares =>
      'Deine Freigaben: Die eingeladenen Personen verlieren den Zugriff';

  @override
  String get deleteAccountItemMemberships =>
      'Deine Teilnahme an fremden Kellern: Deine Einträge zu getrunkenen Flaschen bleiben dort ohne deinen Namen';

  @override
  String get deleteAccountItemProfile => 'Dein Profil';

  @override
  String deleteAccountPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Du hast $count noch nicht gespeicherte Änderungen: Sie werden gespeichert und dann mit dem Rest gelöscht',
      one: 'Du hast 1 noch nicht gespeicherte Änderung: Sie wird gespeichert und dann mit dem Rest gelöscht',
    );
    return '$_temp0';
  }

  @override
  String get deleteAccountConfirmWord => 'LÖSCHEN';

  @override
  String deleteAccountTypeWord(String word) {
    return 'Gib zur Bestätigung $word ein';
  }

  @override
  String get deleteAccountReauthHint =>
      'Danach meldest du dich noch einmal mit Google an, um zu bestätigen, dass du es bist.';

  @override
  String get deleteAccountForever => 'Für immer löschen';

  @override
  String get deleteAccountNeedsNetwork =>
      'Verbinde dich mit dem Internet, um das Konto zu löschen';

  @override
  String get deleteAccountSameAccount =>
      'Zum Löschen musst du dich mit demselben Konto anmelden';

  @override
  String get deletionTitle => 'Konto wird gelöscht';

  @override
  String get deletionStepPreparePhone =>
      'Ausstehende Änderungen werden gespeichert';

  @override
  String get deletionStepMarkStarted => 'Löschen wird gestartet';

  @override
  String get deletionStepLeaveOtherCellars => 'Fremde Keller werden verlassen';

  @override
  String get deletionStepCloseOwnInvitations =>
      'Deine Freigaben werden beendet';

  @override
  String get deletionStepDeleteWinesAndRecords =>
      'Weine und Verlauf werden gelöscht';

  @override
  String get deletionStepDeleteCellar => 'Keller wird gelöscht';

  @override
  String get deletionStepDeleteProfileAndUser =>
      'Profil und Konto werden gelöscht';

  @override
  String get deletionStepCleanUpPhone => 'Dieses Telefon wird bereinigt';

  @override
  String deletionStepAnnounce(int step, String label) {
    return 'Schritt $step von 8: $label';
  }

  @override
  String deletionDeletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Weine und Einträge gelöscht',
      one: '1 Wein oder Eintrag gelöscht',
    );
    return '$_temp0';
  }

  @override
  String get deletionResumeHint =>
      'Das Löschen dieses Kontos ist nicht abgeschlossen. Melde dich erneut mit Google an, um es abzuschließen.';

  @override
  String get deletionContinue => 'Fortsetzen';

  @override
  String get deletionOffline =>
      'Verbinde dich mit dem Internet, um das Löschen abzuschließen';

  @override
  String get deletionPendingWrites =>
      'Ich kann die ausstehenden Änderungen nicht speichern. Versuch es noch einmal';

  @override
  String get deletionFailed =>
      'Das Löschen konnte nicht abgeschlossen werden. Versuch es noch einmal';

  @override
  String get uxCountryLabel => 'Land';

  @override
  String get uxCountryOther => 'Anderes Land…';

  @override
  String get uxCountryNone => 'Kein Land';

  @override
  String get uxAllCountriesTitle => 'Alle Länder und Gebiete';

  @override
  String get uxAllCountriesSearch => 'Land suchen';

  @override
  String get uxAllCountriesRare => 'Selten für Wein';

  @override
  String get uxAllCountriesAll => 'Alle, von A bis Z';

  @override
  String get uxAllCountriesNone => 'Kein Land gefunden';

  @override
  String get uxRegionLabel => 'Region';

  @override
  String uxRegionOf(String country) {
    return 'Region · $country';
  }

  @override
  String get uxRegionOther => 'Andere Region';

  @override
  String get uxRegionFieldLabel => 'Region eingeben';

  @override
  String get uxRegionTooLong => 'Höchstens 120 Zeichen';

  @override
  String get uxDrinkAction => 'Eine getrunken';

  @override
  String uxDrinkActionTooltip(String name) {
    return 'Ich habe eine Flasche $name getrunken';
  }

  @override
  String get uxDrinkActionDetail => 'Eine Flasche getrunken';

  @override
  String get uxDrinkSheetLabel => 'Getrunken bestätigen';

  @override
  String get uxDrinkSheetBottles => 'Flaschen';

  @override
  String uxDrinkSheetBottlesChange(int before, int after) {
    return 'Flaschen: von $before auf $after';
  }

  @override
  String get uxDrinkSheetRating => 'Wie war er? (optional)';

  @override
  String uxDrinkSheetStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Sterne von 5',
      one: '1 Stern von 5',
    );
    return '$_temp0';
  }

  @override
  String get uxDrinkSheetConfirm => 'Ja, getrunken';

  @override
  String get uxRemoveBottle => 'Flasche ohne Eintrag entfernen';

  @override
  String get uxRemoveBottleTitle => 'Eine Flasche entfernen?';

  @override
  String uxRemoveBottleBody(String name) {
    return 'Eine Flasche $name wird entfernt, ohne sie als getrunken einzutragen.';
  }

  @override
  String get uxRemoveBottleConfirm => 'Entfernen';

  @override
  String get uxIdealTitle => 'Idealer Zeitpunkt';

  @override
  String uxIdealUntil(String year) {
    return 'Empfohlen bis $year';
  }

  @override
  String uxIdealUntilPast(String year) {
    return 'Empfohlen bis $year: schon vorbei';
  }

  @override
  String uxIdealBest(String start, String end) {
    return 'Am besten von $start bis $end';
  }

  @override
  String uxIdealBar(String start, String end) {
    return 'Trinkfenster von $start bis $end';
  }

  @override
  String get uxIdealDisclaimer =>
      '⚠︎ Richtwert: eine Schätzung nach Typ, Appellation und Jahrgang. Lagerung und die einzelne Flasche können sie verändern.';

  @override
  String get uxIdealUnavailableHint =>
      'Gib Jahrgang und Typ an, um eine Schätzung zu erhalten.';

  @override
  String uxDashboardDrinkNow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jetzt trinken',
      one: '1 jetzt trinken',
    );
    return '$_temp0';
  }

  @override
  String get uxFamilyRed => 'Rot';

  @override
  String get uxFamilyWhite => 'Weiß';

  @override
  String get uxFamilyRose => 'Rosé';

  @override
  String get uxFamilySparkling => 'Schaumwein';

  @override
  String get uxFamilySweet => 'Süß';

  @override
  String get labelBackTitle => 'Jetzt die Rückseite';

  @override
  String get labelBackHint =>
      'Auf der Rückseite stehen meist Barcode, Erzeuger und Jahrgang: Sie helfen, den Wein zu finden.';

  @override
  String get labelBackTake => 'Rückseite aufnehmen';

  @override
  String get labelBackGallery => 'Aus der Galerie wählen';

  @override
  String get labelBackSkip => 'Überspringen';

  @override
  String get labelStepFront => 'Vorderseite';

  @override
  String get labelStepBack => 'Rückseite';

  @override
  String get labelStepBarcode => 'Barcode';

  @override
  String get labelStepDatabase => 'Weindatenbank auf dem Telefon';

  @override
  String get labelStepPending => 'Wartet';

  @override
  String get labelStepRunning => 'Läuft…';

  @override
  String get labelStepDone => 'Fertig';

  @override
  String get labelStepSkipped => 'Übersprungen';

  @override
  String get labelStepFailed => 'Nicht lesbar';

  @override
  String labelStepStatus(String step, String status) {
    return '$step: $status';
  }

  @override
  String get labelOnPhoneNote =>
      'Alles geschieht auf dem Telefon: Die Fotos werden an niemanden gesendet.';

  @override
  String get labelBackUnreadable => 'Rückseite nicht lesbar';

  @override
  String get labelSourceOffline =>
      'Aus der Datenbank auf dem Telefon · offline';

  @override
  String get labelSourceCatalog => 'Aus dem Katalog';

  @override
  String get labelSourceOnline => 'Von Open Food Facts · online';

  @override
  String get labelNotThis => 'Nicht dieser';

  @override
  String get labelOffAttribution => 'Daten von Open Food Facts, ODbL-Lizenz';

  @override
  String get labelCandidatesTitle => 'Welcher davon?';

  @override
  String labelCandidatesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ähnliche Weine',
      one: '1 ähnlicher Wein',
    );
    return '$_temp0';
  }

  @override
  String get labelCandidatesNone => 'Keiner davon';

  @override
  String get labelChipOffline => 'offline';

  @override
  String get labelChipOnline => 'online';

  @override
  String get labelChipCatalog => 'Katalog';

  @override
  String get labelNoProducer => 'Erzeuger nicht angegeben';

  @override
  String get labelNoMatch =>
      'Ich habe das Etikett gelesen, erkenne den Wein aber nicht';

  @override
  String get labelReadText => 'Gelesener Text';

  @override
  String get labelSearchOnline => 'Online suchen';

  @override
  String get labelOpenLens => 'In Google Lens öffnen';

  @override
  String get labelLensLastResort =>
      'Google Lens ist der letzte Ausweg: Das Foto geht nur an die Google App, wenn du es bestätigst.';

  @override
  String get labelLensTitle => 'In Google Lens öffnen?';

  @override
  String get labelLensBody =>
      'Das Foto der Vorderseite geht an die Google App auf deinem Telefon oder an die App, die du wählst; sie kann nach eigenen Regeln eine Kopie behalten. Vinoozy erhält die Ergebnisse nicht: Komm hierher zurück, um den Wein auszuwählen oder einzugeben.';

  @override
  String get labelLensConfirm => 'Google Lens öffnen';

  @override
  String get labelLensFailed =>
      'Ich kann weder Google Lens noch das Teilen-Menü öffnen';

  @override
  String get onlineSearchTitle => 'Online suchen';

  @override
  String get onlineSearchSubtitle => 'Open Food Facts · nur Weine';

  @override
  String get onlineSearchField => 'Suchbegriffe';

  @override
  String get onlineSearchHint => 'Du kannst die Begriffe vor der Suche ändern.';

  @override
  String get onlineSearchEmptyField => 'Gib mindestens ein Wort ein';

  @override
  String get onlineSearchButton => 'Suchen';

  @override
  String get onlineSearchLoading => 'Suche läuft…';

  @override
  String onlineSearchResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Ergebnisse',
      one: '1 Ergebnis',
    );
    return '$_temp0';
  }

  @override
  String get onlineSearchEmpty =>
      'Kein Wein gefunden: Probier andere Begriffe oder „Von Hand eingeben“.';

  @override
  String get onlineSearchOffline =>
      'Kein Netz: Ich suche nur in der Datenbank auf dem Telefon.';

  @override
  String get onlineSearchRateLimited =>
      'Die Online-Suche ist gerade nicht verfügbar, versuch es in ein paar Minuten noch einmal.';

  @override
  String get onlineSearchUnavailable =>
      'Die Online-Suche ist in dieser App-Version nicht aktiv: Ich suche nur in der Datenbank auf dem Telefon.';

  @override
  String get aboutTitle => 'Info';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aboutDbTitle => 'Weindatenbank';

  @override
  String aboutDbCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Weine',
      one: '1 Wein',
    );
    return '$_temp0';
  }

  @override
  String aboutDbDate(String date) {
    return 'Open Food Facts-Export vom $date';
  }

  @override
  String get aboutDbSample =>
      'Beispieldatenbank: ein paar von Hand geschriebene Testweine, keine Daten von Open Food Facts.';

  @override
  String get aboutDbLoading => 'Weindatenbank wird geöffnet…';

  @override
  String get aboutDbUnavailable =>
      'Die Weindatenbank ist in dieser Version nicht verfügbar';

  @override
  String aboutDbSource(String url) {
    return 'Die abgeleitete Datenbank und das Werkzeug, das sie erstellt, liegen im öffentlichen Repository: $url';
  }

  @override
  String get aboutLicenseTitle => 'Lizenzen';

  @override
  String get aboutLicense =>
      'Enthält Informationen von Open Food Facts, bereitgestellt unter der Open Database License (ODbL). Einzelne Inhalte stehen unter der Database Contents License (DbCL).';

  @override
  String get aboutPrivacyTitle => 'Etikettenfotos';

  @override
  String get aboutPrivacy =>
      'Etikettenfotos werden auf dem Telefon gelesen und gelöscht, wenn du das Ergebnis verlässt. Sie verlassen das Telefon nur, wenn du auf „In Google Lens öffnen“ tippst und bestätigst.';

  @override
  String get aboutAppellationsTitle => 'Appellationen';

  @override
  String get aboutAppellationsSource =>
      'Appellationen: Register eAmbrosia (EU) und offizielle nationale Register.';

  @override
  String get aboutAppellationsSample =>
      'Beispieltabelle: ein von Hand geschriebener Auszug der Register, bis die echten Register heruntergeladen sind.';

  @override
  String get denominationLabel => 'Appellation';

  @override
  String get denominationTooLong => 'Höchstens 120 Zeichen';

  @override
  String get autofillFilledNotice =>
      'Aus dem Etikett ausgefüllt: prüfen und speichern';

  @override
  String get autofillPastedNotice =>
      'Aus dem Text ausgefüllt: prüfen und speichern';

  @override
  String get autofillFromText => '✦ aus dem Text';

  @override
  String get autofillFromTextSemantics => 'aus dem Etikett ausgefüllt';

  @override
  String get autofillClear => 'Leeren';

  @override
  String get autofillLens => 'Lens';

  @override
  String get autofillClearTitle => 'Formular leeren?';

  @override
  String get autofillClearBody =>
      'Du hast in einige Felder auch selbst geschrieben. „Leeren“ löscht Name, Erzeuger, Appellation, Jahrgang, Typ, Land, Region und Stufe. Die Anzahl bleibt.';

  @override
  String get autofillClearConfirm => 'Leeren';

  @override
  String get autofillCleared => 'Formular geleert';

  @override
  String get autofillPasteTitle => 'Hast du den Text aus Google Lens?';

  @override
  String get autofillPasteHint =>
      'Markiere in Lens den Text des Etiketts und tippe auf „Kopieren“, dann komm hierher zurück.';

  @override
  String get autofillPaste => 'Aus Lens einfügen';

  @override
  String get autofillOpenLens => 'Aus Google Lens';

  @override
  String get autofillOpenLensSemantics => 'öffnet Google Lens';

  @override
  String get autofillClipboardEmpty => 'In der Zwischenablage ist kein Text';

  @override
  String get autofillNoNewFields =>
      'Ich habe im Text keine neuen Angaben gefunden';

  @override
  String get autofillFromLens => 'Formular aus dem Lens-Text ausgefüllt';

  @override
  String get autofillShareEmpty => 'Kein Text erhalten';

  @override
  String get autofillShareUseTitle =>
      'Den Text für die leeren Felder verwenden?';

  @override
  String get autofillShareUse => 'Verwenden';

  @override
  String get autofillShareIgnore => 'Ignorieren';

  @override
  String get addChoiceLens => 'Aus Google Lens';

  @override
  String get addChoicePhotoHint =>
      'Vorder- und Rückseite: Vinoozy liest das Etikett.';

  @override
  String get addChoiceLensHint =>
      'Öffnet Lens: Etikett erfassen, Text markieren und auf Teilen → Vinoozy tippen.';

  @override
  String get addChoiceImportHint => 'Ein Foto des Etiketts, das du schon hast.';

  @override
  String get addChoiceWriteHint => 'Leeres Formular, mit „Aus Lens einfügen“.';

  @override
  String get lensInstructionsTitle =>
      'Google Lens lässt sich von hier nicht öffnen';

  @override
  String get lensInstructionsStep1 =>
      'Öffne Google Lens und richte die Kamera auf das Etikett';

  @override
  String get lensInstructionsStep2 => 'Markiere den Text des Etiketts';

  @override
  String get lensInstructionsStep3 => 'Tippe auf Teilen → Vinoozy';

  @override
  String get lensInstructionsOk => 'Verstanden';

  @override
  String get levelLabel => 'Stufe';

  @override
  String get levelEveryday => 'Alltag (günstig)';

  @override
  String get levelGood => 'Gut';

  @override
  String get levelAging => 'Zum Lagern';

  @override
  String get levelNone => 'Keine';

  @override
  String get levelEverydayShort => 'früh trinken';

  @override
  String get levelGoodShort => 'normale Schätzung';

  @override
  String get levelAgingShort => 'hält länger';

  @override
  String get levelSuggested => 'vorgeschlagen';

  @override
  String levelSuggestedReason(String qualifier) {
    return 'Vorgeschlagen, weil im Namen „$qualifier“ steht: So wird es gespeichert, wenn du nichts änderst. Wähle eine andere oder tippe auf „Keine“.';
  }

  @override
  String levelSuggestedSemantics(String qualifier) {
    return 'vorgeschlagen, weil im Namen $qualifier steht';
  }

  @override
  String levelOptionSemantics(String option, int index, int count) {
    return 'Stufe, $option, $index von $count';
  }

  @override
  String get levelWhatChanges => 'Was sich ändert';

  @override
  String get levelEverydayExamples =>
      'Das Fenster wird kürzer. Z. B. Hauswein, Lambrusco, einfacher Prosecco, Bardolino, Vinho Verde.';

  @override
  String get levelGoodExamples =>
      'Die normale Schätzung, auch wenn du nichts wählst. Z. B. Chianti Classico, Barbera d\'Asti Superiore, Rioja Crianza, Côtes du Rhône.';

  @override
  String get levelAgingExamples =>
      'Das Fenster wird länger. Z. B. Barolo, Brunello, Amarone, Bordeaux Grand Cru, Rioja Gran Reserva, Vintage Port.';

  @override
  String levelPreviewBefore(String start, String end) {
    return 'Vorher $start – $end';
  }

  @override
  String levelPreviewWith(String level, String start, String end) {
    return 'Mit „$level“ $start – $end';
  }

  @override
  String levelPreviewNow(String start, String end) {
    return 'Trinkreif $start – bis $end';
  }

  @override
  String levelDetail(String level) {
    return 'Stufe: $level';
  }

  @override
  String get overrideCorrect => 'Korrigieren';

  @override
  String get overrideRestore => 'Schätzung wiederherstellen';

  @override
  String get overrideCorrectedByYou => 'von dir korrigiert';

  @override
  String overrideAppEstimate(String year) {
    return 'Schätzung der App: bis $year';
  }

  @override
  String get overrideSheetTitle => 'Empfohlen bis';

  @override
  String overrideSheetHint(String start) {
    return 'Wähle das Jahr. Es darf nicht vor „Trinkreif ab $start“ liegen.';
  }

  @override
  String overridePeakNotice(String peak) {
    return 'Wenn du ein Jahr vor $peak (am besten) wählst, rückt auch „am besten“ auf dasselbe Jahr.';
  }

  @override
  String get overrideMore => 'mehr…';

  @override
  String get overrideSave => 'Korrektur speichern';

  @override
  String overrideRestoreTitle(String year) {
    return 'Zur Schätzung der App zurückkehren (bis $year)?';
  }

  @override
  String get overrideRestoreConfirm => 'Wiederherstellen';

  @override
  String get overrideSaved => 'Korrektur gespeichert';

  @override
  String get overrideRestored => 'Schätzung wiederhergestellt';

  @override
  String get estimateSourceCorrectedByYou => 'von dir korrigiert';

  @override
  String estimateFromDenomination(String name) {
    return 'Schätzung nach der Appellation $name';
  }

  @override
  String estimateFromDenominationQualifier(String name, String qualifier) {
    return 'Schätzung nach der Appellation $name, $qualifier';
  }

  @override
  String estimateFromGrape(String name) {
    return 'Schätzung nach der Rebsorte $name';
  }

  @override
  String get estimateFromType => 'Schätzung nach dem Weintyp';

  @override
  String get autofillReading => 'Ich lese den Text…';

  @override
  String get guideChip => 'Geführte Prüfung';

  @override
  String guideProgress(int n, int total) {
    return 'Frage $n von $total';
  }

  @override
  String get guideClose => 'Schließen';

  @override
  String get guideIsDenomination => 'ist das die Appellation?';

  @override
  String get guideIsProducer => 'ist das der Erzeuger?';

  @override
  String get guideIsName => 'ist das der Name des Weins?';

  @override
  String get guideIsVintage => 'Jahrgang';

  @override
  String guideAskDenomination(String value) {
    return 'Ist $value die Appellation?';
  }

  @override
  String guideAskProducer(String value) {
    return 'Ist $value der Erzeuger?';
  }

  @override
  String guideAskName(String value) {
    return 'Ist $value der Name des Weins?';
  }

  @override
  String get guideAskVintage => 'Welcher Jahrgang ist es?';

  @override
  String guideQuestionSemantics(int n, int total, String question) {
    return 'Frage $n von $total: $question';
  }

  @override
  String get guideNoProposal => 'Im Text habe ich nichts dazu gefunden';

  @override
  String get guideYes => 'Ja';

  @override
  String get guideNo => 'Nein, anders';

  @override
  String get guideEdit => 'Bearbeiten';

  @override
  String get guideSkip => 'Überspringen';

  @override
  String get guideConfirm => 'Bestätigen';

  @override
  String get guideCancel => 'Abbrechen';

  @override
  String guideRejected(String value) {
    return 'Nicht „$value“: Hier ist der nächste Vorschlag';
  }

  @override
  String get guideNoMore =>
      'Kein weiterer Vorschlag: selbst zusammenstellen oder überspringen';

  @override
  String guideProposalAnnounce(String value) {
    return 'Vorschlag: $value';
  }

  @override
  String get guideComposeLabel =>
      'Oder tippe Wörter aus dem Text an, um es zusammenzustellen';

  @override
  String get guideComposePreview => 'Vorschau';

  @override
  String get guideComposeEmpty => 'Tippe auf ein oder mehrere Wörter';

  @override
  String get guideComposeLimit => 'Bis zu 8 Wörter und 80 Zeichen';

  @override
  String guideTableMatchSemantics(String name) {
    return 'entspricht $name';
  }

  @override
  String guideLine(int n, int total) {
    return 'Zeile $n von $total';
  }

  @override
  String guideWordSelected(String word, int order) {
    return '$word, ausgewählt, $order';
  }

  @override
  String guideWordUnavailable(String word) {
    return '$word, nicht verfügbar';
  }

  @override
  String guideWordUsedFor(String word, String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'die Appellation',
      'producer': 'den Erzeuger',
      'other': 'den Namen',
    });
    return '$word, verwendet für $_temp0';
  }

  @override
  String guideUsedMark(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'Appellation',
      'producer': 'Erzeuger',
      'other': 'Name',
    });
    return '$_temp0';
  }

  @override
  String guideOtherYears(String years) {
    return 'Auch im Text: $years';
  }

  @override
  String get guideWheelFromText => 'Jahr aus dem Text';

  @override
  String get guideWheelTypeYear => 'Jahr eingeben';

  @override
  String guideWheelConfirm(String year) {
    return '$year bestätigen';
  }

  @override
  String get guideNoVintage => 'Ohne Jahrgang';

  @override
  String guideSkippedNotice(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'Appellation übersprungen',
      'producer': 'Erzeuger übersprungen',
      'vintage': 'Jahrgang übersprungen',
      'other': 'Name übersprungen',
    });
    return '$_temp0: selbst eingeben oder die Führung fortsetzen';
  }

  @override
  String guideSkippedMany(int count) {
    return '$count Felder übersprungen: selbst eingeben oder die Führung fortsetzen';
  }

  @override
  String get guideInvalidValue =>
      'Dieser Text enthält Zeichen, die nicht gespeichert werden können';

  @override
  String get brandStudio => 'Bottazzini Softworks';

  @override
  String get suggestedMark => '✦ vorgeschlagen';

  @override
  String suggestedSemantics(String field, String value) {
    return '$field, $value, vorgeschlagen';
  }

  @override
  String get restoreSuggestion => 'Vorschlag wiederherstellen';

  @override
  String get restoreSuggestionDone => 'Vorschlag wiederhergestellt';

  @override
  String get styleLabel => 'Stil';

  @override
  String styleGroupSemantics(String value, int index, int count) {
    return 'Stil, $value, $index von $count';
  }

  @override
  String get styleRedFresh => 'Frisch';

  @override
  String get styleRedMedium => 'Mittel';

  @override
  String get styleRedAge => 'Zum Lagern';

  @override
  String get styleRedLong => 'Lange Lagerung';

  @override
  String get styleWhiteFresh => 'Frisch';

  @override
  String get styleWhiteMedium => 'Mittel';

  @override
  String get styleWhiteAge => 'Zum Lagern';

  @override
  String get styleRoseFresh => 'Frisch';

  @override
  String get styleClassicFresh => 'Frisch';

  @override
  String get styleClassicAge => 'Zum Lagern';

  @override
  String get styleTankFresh => 'Frisch';

  @override
  String get styleLambrusco => 'Lambrusco';

  @override
  String get styleSweetAromatic => 'Aromatisch';

  @override
  String get styleSweetPassito => 'Strohwein';

  @override
  String get styleSweetBotrytis => 'Botrytis';

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
  String get styleFortifiedOther => 'Andere';

  @override
  String get profileNameRFresh => 'Fruchtbetonter Rotwein';

  @override
  String get profileNameRMedium => 'Mittelkräftiger Rotwein';

  @override
  String get profileNameRAge => 'Rotwein zum Lagern';

  @override
  String get profileNameRLong => 'Rotwein für lange Lagerung';

  @override
  String get profileNameWFresh => 'Frischer aromatischer Weißwein';

  @override
  String get profileNameWMedium => 'Mittelkräftiger Weißwein';

  @override
  String get profileNameWAge => 'Weißwein zum Lagern';

  @override
  String get profileNameRoseFresh => 'Frischer Rosé';

  @override
  String get profileNameSpTank => 'Frischer Schaumwein, Tankgärung';

  @override
  String get profileNameLamFresh => 'Frischer Lambrusco';

  @override
  String get profileNameSpClassic => 'Frischer Schaumwein, Flaschengärung';

  @override
  String get profileNameSpClassicAge => 'Schaumwein zum Lagern, Flaschengärung';

  @override
  String get profileNameSwAromatic => 'Junger aromatischer Süßwein';

  @override
  String get profileNameSwPassito => 'Süßwein aus getrockneten Trauben';

  @override
  String get profileNameSwBotrytis => 'Edelsüßer Botrytis-Wein';

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
  String get profileNameFortUnknown => 'Likörwein, Stil unbekannt';

  @override
  String get profileNameUnknown => 'Stil nicht erkannt';

  @override
  String estimateFromProfile(String profile, String denomination) {
    return 'Schätzung nach dem Profil $profile ($denomination)';
  }

  @override
  String estimateFromProfileType(String profile) {
    return 'Schätzung nach dem Profil $profile, nach Typ';
  }

  @override
  String estimateFromProfileGrape(String profile, String grape) {
    return 'Schätzung nach dem Profil $profile, nach der Rebsorte $grape';
  }

  @override
  String get estimateFromEntryDateDisgorgement =>
      'Ab dem Eintragsdatum: Gib das Degorgierdatum an für eine bessere Schätzung';

  @override
  String get estimateFromEntryDateBottling =>
      'Ab dem Eintragsdatum: Gib das Abfülldatum an für eine bessere Schätzung';

  @override
  String get styleToConfirmBanner =>
      '⚠︎ Stil noch zu bestätigen: Die Schätzung ist ein Richtwert';

  @override
  String get chooseTypePrompt => 'Typ wählen';

  @override
  String estimateUpdatedAnnouncement(String summary) {
    return 'Schätzung aktualisiert: $summary';
  }

  @override
  String get agingStartDisgorgement => 'Degorgierung';

  @override
  String get agingStartBottling => 'Abfüllung';

  @override
  String get agingStartMonth => 'Monat';

  @override
  String get agingStartYear => 'Jahr';

  @override
  String get agingStartHint => 'Steht meist auf dem Rückenetikett.';

  @override
  String get agingStartIncomplete => 'Gib Monat und Jahr an';

  @override
  String get agingStartFuture => 'Das Datum darf nicht in der Zukunft liegen';

  @override
  String get agingStartBeforeVintage => 'Es darf nicht vor dem Jahrgang liegen';

  @override
  String get windowNoEnd => 'Trinkreif, kein Ende geschätzt';

  @override
  String get windowNoEndShort => 'kein Ende geschätzt';

  @override
  String windowDrinkWithin(String date) {
    return 'bis $date';
  }

  @override
  String get levelNoEffect => 'Die Stufe ändert diese Schätzung nicht';

  @override
  String get dashboardToConfirmTitle => 'Zu bestätigen';

  @override
  String dashboardToConfirmCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Weine',
      one: '1 Wein',
    );
    return '$_temp0';
  }

  @override
  String aboutDbClassified(String percent) {
    return '$percent % der Weine mit erkanntem Typ';
  }

  @override
  String get planTitle => 'Tarif';

  @override
  String get planFree => 'Kostenlos';

  @override
  String get planPlus => 'Plus';

  @override
  String get planPlusGift => 'Plus (Geschenk)';

  @override
  String get planDevUnlockAll => 'DEV · Test-Plus';

  @override
  String get planDevSimulateFree => 'DEV · Kostenloser Tarif simuliert';

  @override
  String get planDevSimulateExpired => 'DEV · Abgelaufenes Plus simuliert';

  @override
  String get planDiscoverPlus => 'Plus entdecken';

  @override
  String get plusTitle => 'Vinoozy Plus';

  @override
  String get plusBenefitsTitle => 'Mit Plus';

  @override
  String get plusBenefitNoAds => 'Keine Werbung';

  @override
  String get plusBenefitNoLimit => 'Kein Limit für die Weine in deinem Keller';

  @override
  String get plusComingSoon => 'Plus kommt bald';

  @override
  String get plusLoading => 'Preise werden von Google Play geladen';

  @override
  String get plusStoreUnavailable =>
      'Die Preise konnten nicht von Google Play geladen werden. Versuch es später noch einmal.';

  @override
  String plusPriceMonthly(String price) {
    return '$price pro Monat';
  }

  @override
  String plusPriceAnnual(String price) {
    return '$price pro Jahr';
  }

  @override
  String get plusRenewal =>
      'Das Abo verlängert sich automatisch zum angezeigten Preis, bis du es bei Google Play kündigst.';

  @override
  String get plusTerms =>
      'Die Zahlung wird deinem Google Play-Konto belastet, sobald du den Kauf bestätigst. Du kannst jederzeit kündigen: Plus bleibt bis zum Ende des bereits bezahlten Zeitraums aktiv. Wenn Plus endet, bleiben alle deine Weine erhalten.';

  @override
  String get plusRestore => 'Käufe wiederherstellen';

  @override
  String get plusManage => 'Abo bei Google Play verwalten oder kündigen';

  @override
  String get plusActive => 'Plus ist in diesem Konto aktiv';

  @override
  String get plusActiveGift =>
      'Du hast Plus als Geschenk: keine Kosten und keine Verlängerungen.';

  @override
  String get plusPending =>
      'Zahlung ausstehend: Plus wird aktiv, sobald Google Play sie bestätigt.';

  @override
  String get plusVerifying => 'Kauf wird geprüft';

  @override
  String get plusVerified =>
      'Kauf geprüft: Plus ist in wenigen Sekunden aktiv.';

  @override
  String get plusPurchaseFailed =>
      'Der Kauf wurde nicht abgeschlossen. Versuch es noch einmal.';

  @override
  String get plusInvalidPurchase =>
      'Google Play hat diesen Kauf für Vinoozy nicht bestätigt.';

  @override
  String get plusOwnedByOther =>
      'Dieses Abo gehört schon zu einem anderen Vinoozy-Konto.';

  @override
  String get plusVerificationUnavailable =>
      'Der Kauf konnte gerade nicht geprüft werden. Versuch es später noch einmal: Das Abo bleibt bei Google Play bestehen.';

  @override
  String get capacityLimitTitle =>
      'Du hast das Limit des kostenlosen Tarifs erreicht';

  @override
  String capacityLimitBody(int limit) {
    return 'Der kostenlose Tarif umfasst bis zu $limit verschiedene Weine in deinem Keller. Die Weine, die du schon hast, kannst du immer bearbeiten, trinken und um Flaschen ergänzen. Um einen neuen hinzuzufügen, trink einen Wein aus oder lösche einen, oder wechsle zu Plus.';
  }

  @override
  String capacityLimitBodyComingSoon(int limit) {
    return 'Der kostenlose Tarif umfasst bis zu $limit verschiedene Weine in deinem Keller. Die Weine, die du schon hast, kannst du immer bearbeiten, trinken und um Flaschen ergänzen. Um einen neuen hinzuzufügen, trink einen Wein aus oder lösche einen. Plus kommt bald.';
  }

  @override
  String get rejectedCapacityLimit =>
      'Nicht synchronisiert: Das Weinlimit des kostenlosen Tarifs wäre überschritten. Die Änderung bleibt auf diesem Telefon.';

  @override
  String get rejectedCapacityConflict =>
      'Nicht synchronisiert: Der Keller wurde gleichzeitig auf einem anderen Gerät geändert. Die Änderung bleibt auf diesem Telefon: Versuch es noch einmal.';

  @override
  String writeRejectedCapacityLimit(String name) {
    return '$name: nicht synchronisiert, über dem Limit des kostenlosen Tarifs';
  }

  @override
  String writeRejectedCapacityConflict(String name) {
    return '$name: nicht synchronisiert, der Keller wurde auf einem anderen Gerät geändert';
  }

  @override
  String get freeIntroTitle => 'Der kostenlose Tarif';

  @override
  String freeIntroLimit(int limit) {
    return 'Du kannst bis zu $limit verschiedene Weine kostenlos verwalten.';
  }

  @override
  String get freeIntroAds =>
      'Bei leichter Nutzung bleibt die App werbefrei. Wenn du die monatliche Nutzungsschwelle des Dienstes überschreitest, siehst du vielleicht gelegentlich Werbung, die hilft, die Kosten für Server und Synchronisierung zu decken.';

  @override
  String get freeIntroNoAds => 'Keine Werbung in der Startversion.';

  @override
  String get freeIntroPlus =>
      'Mit Plus entfallen die Werbung und das Kellerlimit.';

  @override
  String get noticeGotIt => 'Verstanden';

  @override
  String get thresholdTitle => 'Werbung hilft, Vinoozy kostenlos zu halten';

  @override
  String get thresholdBody =>
      'Du hast die monatliche Schwelle für werbefreie Nutzung erreicht. Ab jetzt siehst du vielleicht gelegentlich Werbung: Sie hilft uns, die Kosten für Server und Synchronisierung zu decken, damit Vinoozy kostenlos bleibt.';

  @override
  String get thresholdReset =>
      'Die Zählung beginnt nächsten Monat neu. Mit Plus nutzt du die App ohne Werbung und ohne Kellerlimit.';

  @override
  String thresholdNextReset(String date) {
    return 'Nächste Zurücksetzung: $date';
  }

  @override
  String get thresholdHowItWorks => 'So funktioniert es';

  @override
  String get thresholdHowItWorksBody =>
      'Die Schwelle hängt von einer Schätzung der Synchronisierungen mit der Cloud ab, die dieses Konto im Monat durchführt. Offline-Nutzung allein erzeugt keine neuen Cloud-Vorgänge. Werbung erscheint höchstens einmal am Tag, nur in der Übersicht, und nie, während du deine Daten speicherst oder exportierst.';

  @override
  String get adLabel => 'Anzeige';

  @override
  String get devToolsTitle => 'Entwicklerwerkzeuge';

  @override
  String get devUnlockAll => 'Alles freischalten — Test-Plus';

  @override
  String get devSimulateFree => 'Kostenlosen Tarif simulieren';

  @override
  String get devSimulateExpired => 'Abgelaufenes Plus simulieren';

  @override
  String get devRestore => 'Normalzustand wiederherstellen';

  @override
  String get devNoOverride => 'Keine Simulation aktiv';

  @override
  String get devApplied => 'Szenario auch im Firestore-Emulator angewendet';

  @override
  String get devIncomplete =>
      'Unvollständige Simulation: Der Firestore-Emulator hat die Testberechtigung nicht bestätigt. Die Serverregeln sehen dieses Szenario nicht.';

  @override
  String get devNotice =>
      'Nur Entwicklungs-Builds mit dem Emulator: keine Zahlungen, Tokens oder Belege.';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsGuide => 'Anleitung erneut ansehen';

  @override
  String get settingsShare => 'App teilen';

  @override
  String get settingsRate => 'App bewerten';

  @override
  String get settingsFeedback => 'Feedback senden';

  @override
  String get settingsFaq => 'Häufige Fragen';

  @override
  String get settingsShareFailed =>
      'Teilen konnte nicht geöffnet werden. Bitte erneut versuchen';

  @override
  String get settingsRateFailed =>
      'Google Play konnte nicht geöffnet werden. Bitte erneut versuchen';

  @override
  String get guideAddTitle => 'Wein hinzufügen';

  @override
  String get guideAddBody =>
      'Tippe auf Hinzufügen, um eine Flasche in deinen Keller zu legen. Für den Anfang reicht der Name.';

  @override
  String get guideLabelTitle => 'Etikett lesen';

  @override
  String get guideLabelBody =>
      'Unter Hinzufügen kannst du auch das Etikett fotografieren: Vinoozy liest Name, Jahrgang und Herkunftsbezeichnung, und du prüfst sie vor dem Speichern.';

  @override
  String get guideTabsTitle => 'Übersicht, Keller, Verlauf';

  @override
  String get guideTabsBody =>
      'Die Übersicht zeigt, welche Weine du jetzt öffnen solltest, der Keller listet deine Flaschen und der Verlauf bewahrt die getrunkenen auf.';

  @override
  String get guideMenuTitle => 'Das Kellermenü';

  @override
  String get guideMenuBody =>
      'Hier findest du dein Profil, die Personen, mit denen du den Keller teilst, die getrunkenen Weine und die Einstellungen, wo du diese Anleitung erneut ansehen kannst.';

  @override
  String get guideDone => 'Fertig';

  @override
  String guideStepOf(int step, int count) {
    return 'Schritt $step von $count';
  }

  @override
  String get hintDashboard =>
      'Hier siehst du, welche Weine jetzt trinkreif sind und welche du besser noch liegen lässt.';

  @override
  String get hintHistory =>
      'Jede Flasche, die du trinkst, landet hier, mit deiner Bewertung und deinen Notizen.';

  @override
  String get hintAddWine =>
      'Fang mit dem Namen an: Jahrgang, Art und Herkunftsbezeichnung machen das Trinkfenster genauer.';

  @override
  String get shareAppSubject => 'Vinoozy, dein Weinkeller';

  @override
  String shareAppMessage(String link) {
    return 'Ich verwalte meinen Weinkeller mit Vinoozy: Die App sagt mir, wann jede Flasche am besten ist. Probier sie aus: $link';
  }

  @override
  String get feedbackSubject => 'Feedback zu Vinoozy';

  @override
  String get feedbackTechHeader => 'Technische Daten (bitte nicht löschen):';

  @override
  String get feedbackNoEmailTitle => 'Keine E-Mail-App';

  @override
  String feedbackNoEmailBody(String email) {
    return 'Auf diesem Telefon gibt es keine E-Mail-App. Schreib uns an $email';
  }

  @override
  String get feedbackCopy => 'Kopieren';

  @override
  String get feedbackCopied => 'Adresse kopiert';

  @override
  String get faqAddQuestion => 'Wie füge ich einen Wein von Hand hinzu?';

  @override
  String get faqAddAnswer =>
      'Tippe im Keller auf Hinzufügen und dann auf Eingeben. Nur der Name ist Pflicht; Jahrgang, Art, Land und Herkunftsbezeichnung verbessern die Schätzung. Speichern, und der Wein liegt in deinem Keller.';

  @override
  String get faqLabelQuestion =>
      'Wie lese ich ein Etikett, auch mit Google Lens?';

  @override
  String get faqLabelAnswer =>
      'Tippe auf Hinzufügen und fotografiere Vorder- und Rückseite: Vinoozy liest das Etikett direkt auf dem Telefon. In Google Lens markierst du den Text und teilst ihn mit Vinoozy, oder du kopierst ihn und nutzt im Formular Aus Lens einfügen. Prüfe die Felder immer vor dem Speichern.';

  @override
  String get faqWindowQuestion =>
      'Wie wird der beste Trinkzeitpunkt berechnet, und kann ich ihn ändern?';

  @override
  String get faqWindowAnswer =>
      'Vinoozy schätzt ein Fenster (Beginn, Höhepunkt, Ende) aus Art, Herkunftsbezeichnung, Jahrgang und Stufe des Weins. Das ist ein Richtwert: Auch die Lagerung zählt. Öffne den Wein und tippe auf Korrigieren, um dein eigenes Datum zu setzen, oder ändere die Stufe.';

  @override
  String get faqOfflineQuestion => 'Funktioniert es ohne Internet?';

  @override
  String get faqOfflineAnswer =>
      'Ja. Du kannst Weine offline hinzufügen, bearbeiten und trinken: Alles wird auf dem Telefon gespeichert und mit deinem Konto synchronisiert, sobald die Verbindung zurück ist.';

  @override
  String get faqShareQuestion => 'Wie teile ich meinen Keller?';

  @override
  String get faqShareAnswer =>
      'Öffne im Kellermenü Personen und lade jemanden mit seiner Google-E-Mail-Adresse ein, nur lesend oder mit Bearbeitung. Die Person installiert Vinoozy und meldet sich mit diesem Konto an.';

  @override
  String get faqPlusQuestion =>
      'Was enthält der kostenlose Plan, und was ist Plus?';

  @override
  String faqPlusAnswer(int limit) {
    return 'Der kostenlose Plan umfasst bis zu $limit verschiedene Weine im Keller, mit gelegentlicher Werbung nur in der Übersicht. Vinoozy Plus entfernt das Limit und die Werbung.';
  }

  @override
  String get faqDrinkQuestion =>
      'Warum getrunkene Flaschen und ihren Zustand festhalten?';

  @override
  String get faqDrinkAnswer =>
      'Der Verlauf bewahrt, was du getrunken hast und wie es dir gefallen hat. Wenn du angibst, wie die Flasche war (noch zu jung, genau richtig, Höhepunkt schon vorbei), korrigiert Vinoozy die Schätzung für denselben Wein.';

  @override
  String get faqDeleteQuestion => 'Wie lösche ich mein Konto?';

  @override
  String get faqDeleteAnswer =>
      'Öffne Profil und tippe auf Konto löschen. Du brauchst eine Verbindung und meldest dich zur Bestätigung erneut mit Google an. Dein Keller, der Verlauf und deine Freigaben werden endgültig gelöscht.';

  @override
  String get faqNotFound => 'Keine Antwort gefunden? Schreib uns';
}
