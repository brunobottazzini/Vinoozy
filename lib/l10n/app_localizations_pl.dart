// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Vinoozy';

  @override
  String get signInTagline => 'Twoja piwniczka, we właściwym czasie';

  @override
  String get signInWithGoogle => 'Kontynuuj z Google';

  @override
  String get signInInProgress => 'Logowanie';

  @override
  String get signInFailed => 'Logowanie nie powiodło się';

  @override
  String get signInNeedsNetwork =>
      'Do pierwszego logowania potrzebne jest połączenie';

  @override
  String get signInSessionExpired => 'Sesja wygasła: zaloguj się ponownie';

  @override
  String get retry => 'Spróbuj ponownie';

  @override
  String get cancel => 'Anuluj';

  @override
  String blockedMessage(String email) {
    return 'Zmiany z konta $email nie zostały jeszcze zapisane w chmurze: zaloguj się na to konto i połącz się z siecią';
  }

  @override
  String blockedSignInWith(String email) {
    return 'Zaloguj się jako $email';
  }

  @override
  String blockedDiscard(String email) {
    return 'Usuń niezapisane zmiany z konta $email';
  }

  @override
  String get discardDialogTitle => 'Usunąć zmiany?';

  @override
  String discardDialogBody(int count, String email) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count wina z konta $email nie jest jeszcze w chmurze i zostanie usunięte z tego telefonu.',
      many:
          '$count win z konta $email nie jest jeszcze w chmurze i zostanie usuniętych z tego telefonu.',
      few:
          '$count wina z konta $email nie są jeszcze w chmurze i zostaną usunięte z tego telefonu.',
      one:
          '$count wino z konta $email nie jest jeszcze w chmurze i zostanie usunięte z tego telefonu.',
    );
    return '$_temp0';
  }

  @override
  String get discardConfirm => 'Usuń';

  @override
  String get resetFailed => 'Nie udało się wyczyścić danych w tym telefonie';

  @override
  String get restartRequired => 'Uruchom aplikację ponownie, aby dokończyć';

  @override
  String get restartCloseApp => 'Zamknij aplikację';

  @override
  String get startupFailed => 'Nie udało się uruchomić aplikacji';

  @override
  String get cellarTitle => 'Piwniczka';

  @override
  String get defaultCellarName => 'Moja piwniczka';

  @override
  String get cellarLoading => 'Przygotowywanie piwniczki';

  @override
  String get cellarSetupFailed => 'Nie udało się przygotować piwniczki';

  @override
  String get cellarEmpty => 'Twoja piwniczka jest pusta';

  @override
  String get addWine => 'Dodaj';

  @override
  String get estimatePending => 'Szacunek w drodze';

  @override
  String get noVintage => 'Bez rocznika';

  @override
  String bottleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count butelki',
      many: '$count butelek',
      few: '$count butelki',
      one: '$count butelka',
    );
    return '$_temp0';
  }

  @override
  String get syncInProgress => 'Synchronizacja';

  @override
  String get syncOffline => 'Offline - synchronizacja czeka';

  @override
  String writeRejected(String name) {
    return 'Zmiana niedozwolona: $name';
  }

  @override
  String get saveFailed => 'Nie udało się zapisać, spróbuj ponownie';

  @override
  String wineNotSaved(String name) {
    return 'Wino $name nie zostało zapisane w chmurze';
  }

  @override
  String get addAgain => 'Dodaj ponownie';

  @override
  String get ignore => 'Ignoruj';

  @override
  String get addWineTitle => 'Wpisz';

  @override
  String get wineNameLabel => 'Wino';

  @override
  String get vintageLabel => 'Rocznik';

  @override
  String get quantityLabel => 'Ilość';

  @override
  String get decreaseQuantity => 'Zmniejsz ilość';

  @override
  String get increaseQuantity => 'Zwiększ ilość';

  @override
  String get save => 'Zapisz';

  @override
  String get nameRequired => 'Wpisz nazwę wina';

  @override
  String get nameTooLong => 'Maksymalnie 120 znaków';

  @override
  String vintageRange(String year) {
    return 'Rocznik od 1900 do $year';
  }

  @override
  String get offAttribution => 'Dane z Open Food Facts (ODbL)';

  @override
  String get dashboardTitle => 'Pulpit';

  @override
  String dashboardTotalBottles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count butelki w piwniczce',
      many: '$count butelek w piwniczce',
      few: '$count butelki w piwniczce',
      one: '$count butelka w piwniczce',
    );
    return '$_temp0';
  }

  @override
  String get dashboardSyncing => 'Synchronizacja piwniczki…';

  @override
  String get dashboardAddFirstWine => 'Dodaj pierwsze wino';

  @override
  String get drinkSoonTitle => 'Wypić wkrótce';

  @override
  String get drinkSoonEmpty => 'Brak butelek do wypicia wkrótce';

  @override
  String drinkSoonUntil(String year) {
    return 'do $year';
  }

  @override
  String drinkSoonSeeAll(int count) {
    return 'Zobacz wszystkie ($count)';
  }

  @override
  String get statusChartTitle => 'Stan butelek';

  @override
  String get statusWaiting => 'poczekać';

  @override
  String get statusReady => 'gotowe';

  @override
  String get statusDrinkSoon => 'wypić wkrótce';

  @override
  String get statusPastWindow => 'po oknie picia';

  @override
  String toEstimateNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count butelki do oszacowania',
      many: '$count butelek do oszacowania',
      few: '$count butelki do oszacowania',
      one: '$count butelka do oszacowania',
    );
    return '$_temp0';
  }

  @override
  String chartBarValue(String label, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count butelki',
      many: '$count butelek',
      few: '$count butelki',
      one: '$count butelka',
    );
    return '$label: $_temp0';
  }

  @override
  String chartDescription(String title, String values) {
    return '$title: $values';
  }

  @override
  String get openListHint => 'Otwórz listę';

  @override
  String get peakChartTitle => 'Rok szczytu';

  @override
  String get peakPast => 'po szczycie';

  @override
  String get peakBeyond => 'później';

  @override
  String get breakdownTypeTitle => 'Butelki według typu';

  @override
  String get breakdownRegionTitle => 'Butelki według regionu';

  @override
  String get breakdownType => 'Typ';

  @override
  String get breakdownRegion => 'Region';

  @override
  String get familyRed => 'czerwone';

  @override
  String get familyWhite => 'białe';

  @override
  String get familyRose => 'różowe';

  @override
  String get familySparkling => 'musujące';

  @override
  String get familySweet => 'słodkie';

  @override
  String get breakdownUnspecified => 'nie podano';

  @override
  String get breakdownOtherRegions => 'inne';

  @override
  String get ok => 'OK';

  @override
  String get cellarMenu => 'Menu piwniczki';

  @override
  String get sharingPeopleTitle => 'Osoby';

  @override
  String get sharingInviteTitle => 'Zaproś osobę';

  @override
  String get sharingEmailLabel => 'Adres e-mail Google';

  @override
  String get sharingPermissionRead => 'Tylko odczyt';

  @override
  String get sharingPermissionReadHint =>
      'Widzi wina, szacunki, pulpit i wypite butelki';

  @override
  String get sharingPermissionEdit => 'Może edytować';

  @override
  String get sharingPermissionEditHint =>
      'Dodaje i zmienia wina oraz zapisuje wypite butelki';

  @override
  String get sharingRoleOwner => 'właściciel';

  @override
  String get sharingInviteButton => 'Zaproś';

  @override
  String sharingPlacesUsed(int used, int max) {
    return 'Osoby: $used/$max';
  }

  @override
  String get sharingInvalidEmail => 'Podaj prawidłowy adres e-mail';

  @override
  String get sharingSelfInvite => 'Nie możesz zaprosić siebie';

  @override
  String get sharingAlreadyInvited => 'Ta osoba ma już zaproszenie';

  @override
  String sharingLimitReached(int max) {
    return 'Osiągnięto limit osób: $max';
  }

  @override
  String get sharingNotOwner =>
      'Nie możesz zmieniać udostępniania tej piwniczki';

  @override
  String get sharingNotFound => 'Tej osoby nie ma już na liście';

  @override
  String get sharingFailed => 'Nie udało się, spróbuj ponownie';

  @override
  String get sharingInviteFailed =>
      'Zaproszenie nie powiodło się. Spróbuj ponownie';

  @override
  String get sharingOfflineHint =>
      'Do zarządzania udostępnianiem potrzebne jest połączenie';

  @override
  String get sharingStatusInvited => 'zaproszona';

  @override
  String get sharingStatusActive => 'aktywna';

  @override
  String get sharingStatusRevoked => 'dostęp odebrany';

  @override
  String get sharingStatusLeft => 'opuściła piwniczkę';

  @override
  String sharingMemberSemantics(String name, String permission, String status) {
    return '$name, $permission, $status';
  }

  @override
  String get sharingClosedSection => 'Zamknięte dostępy';

  @override
  String get sharingNobody => 'Nikt inny nie widzi jeszcze tej piwniczki';

  @override
  String sharingChangePermission(String name) {
    return 'Zmień uprawnienie: $name';
  }

  @override
  String get sharingRevoke => 'Odbierz dostęp';

  @override
  String sharingRevokeTitle(String name) {
    return 'Odebrać dostęp użytkownikowi $name?';
  }

  @override
  String sharingRevokeConfirmLabel(String name) {
    return 'Wpisz $name, aby potwierdzić';
  }

  @override
  String get sharingRevokeDisabledHint => 'Aktywne, gdy nazwa się zgadza';

  @override
  String get sharingReinvite => 'Zaproś ponownie';

  @override
  String get sharingDeleteForGood => 'Usuń na stałe';

  @override
  String sharingOwnedBy(String owner) {
    return 'Piwniczka: $owner';
  }

  @override
  String get sharingYourCellar => 'Twoja piwniczka';

  @override
  String sharingYourPermission(String permission) {
    return 'Twoje uprawnienie: $permission';
  }

  @override
  String sharingSwitcherSemantics(String cellar, String permission) {
    return '$cellar, $permission. Dotknij, aby zmienić piwniczkę';
  }

  @override
  String get sharingLeave => 'Opuść tę piwniczkę';

  @override
  String sharingLeaveTitle(String owner) {
    return 'Opuścić piwniczkę, której właścicielem jest $owner?';
  }

  @override
  String sharingLeaveBody(String owner) {
    return 'Przestaniesz ją widzieć. $owner może zaprosić Cię ponownie.';
  }

  @override
  String get sharingLeaveConfirm => 'Opuść';

  @override
  String sharingSharedNotice(String owner) {
    return '$owner udostępnia Ci swoją piwniczkę';
  }

  @override
  String sharingAccessLost(String owner) {
    return 'Nie masz już dostępu do piwniczki, której właścicielem jest $owner';
  }

  @override
  String sharingWritesLost(String owner) {
    return 'Część zmian w piwniczce, której właścicielem jest $owner, nie została zapisana, bo nie masz już dostępu';
  }

  @override
  String get sharingSomeone => 'ktoś';

  @override
  String get sharingShareSubject => 'Zaproszenie do Vinoozy';

  @override
  String sharingShareMessage(
    String owner,
    String cellar,
    String link,
    String email,
  ) {
    return '$owner zaprasza Cię do piwniczki „$cellar” w Vinoozy. Zainstaluj aplikację z $link i zaloguj się na konto Google $email: użyj dokładnie tego adresu.';
  }

  @override
  String get cellarSearchHint => 'Szukaj po nazwie lub producencie';

  @override
  String get cellarFilterStatus => 'Stan';

  @override
  String get cellarFilterType => 'Typ';

  @override
  String get statusToEstimate => 'Do oszacowania';

  @override
  String get filterTypeUnspecified => 'Nie podano';

  @override
  String get cellarNoMatches => 'Brak win dla tych filtrów';

  @override
  String get cellarClearFilters => 'Wyczyść filtry';

  @override
  String get cellarArchiveTitle => 'Wypite';

  @override
  String get cellarArchiveEmpty => 'Nie ma jeszcze skończonych win';

  @override
  String get cellarArchiveFailed => 'Nie udało się wczytać skończonych win';

  @override
  String get wineDrink => 'Wypite';

  @override
  String wineDrinkTooltip(String name) {
    return 'Oznacz jako wypitą butelkę wina $name';
  }

  @override
  String confidenceLabel(String level) {
    return 'Pewność: $level';
  }

  @override
  String get confidenceHigh => 'wysoka';

  @override
  String get confidenceMedium => 'średnia';

  @override
  String get confidenceLow => 'niska';

  @override
  String get windowStartLabel => 'Początek';

  @override
  String get windowPeakLabel => 'Szczyt';

  @override
  String get windowEndLabel => 'Koniec';

  @override
  String estimateSourceLabel(String source) {
    return 'Źródło: $source';
  }

  @override
  String get estimateSourceCatalog => 'baza win';

  @override
  String get estimateSourceType => 'szacunek dla typu';

  @override
  String get estimateSourceCorrected =>
      'szacunek skorygowany na podstawie wypitych butelek';

  @override
  String get estimateDisclaimer =>
      'Szacunek orientacyjny: zależy też od tego, jak przechowywano butelkę';

  @override
  String get estimateUnavailable => 'Szacunek niedostępny';

  @override
  String get pairingsTitle => 'Pasuje do';

  @override
  String get pairingsGeneric => 'ogólne propozycje dla typu';

  @override
  String get pairingBraisedRedMeat => 'Duszone czerwone mięso';

  @override
  String get pairingGrilledRedMeat => 'Czerwone mięso z grilla';

  @override
  String get pairingGame => 'Dziczyzna';

  @override
  String get pairingRoastPoultry => 'Pieczony drób';

  @override
  String get pairingPoultry => 'Drób';

  @override
  String get pairingPork => 'Wieprzowina';

  @override
  String get pairingCuredMeats => 'Wędliny';

  @override
  String get pairingPastaMeatSauce => 'Makaron z sosem mięsnym';

  @override
  String get pairingMushroomsTruffle => 'Grzyby i trufle';

  @override
  String get pairingAgedCheese => 'Sery dojrzewające';

  @override
  String get pairingFreshCheese => 'Sery świeże';

  @override
  String get pairingBlueCheese => 'Sery pleśniowe';

  @override
  String get pairingFish => 'Ryby';

  @override
  String get pairingSeafood => 'Owoce morza';

  @override
  String get pairingRawSeafood => 'Surowe owoce morza';

  @override
  String get pairingFriedFood => 'Potrawy smażone';

  @override
  String get pairingVegetables => 'Warzywa';

  @override
  String get pairingRisotto => 'Risotto';

  @override
  String get pairingPizza => 'Pizza';

  @override
  String get pairingAperitif => 'Aperitif';

  @override
  String get pairingPastries => 'Wypieki';

  @override
  String get pairingDryBiscuits => 'Kruche ciastka';

  @override
  String get pairingChocolate => 'Czekolada';

  @override
  String get pairingDriedFruit => 'Bakalie';

  @override
  String get pairingSpicyDishes => 'Dania pikantne';

  @override
  String get recentDrinksTitle => 'Ostatnio wypite';

  @override
  String get noDrinksYet => 'Nic jeszcze nie wypito';

  @override
  String get wineEdit => 'Edytuj';

  @override
  String get wineDelete => 'Usuń';

  @override
  String get wineFinished => 'Skończone: nie ma już butelek';

  @override
  String get wineLoadFailed => 'Nie udało się otworzyć wina';

  @override
  String get wineNotFound => 'To wino już nie istnieje';

  @override
  String drinkDone(String name) {
    return 'Oznaczono jako wypite: $name';
  }

  @override
  String get drinkUndo => 'Cofnij';

  @override
  String get drinkAddNotes => 'Dodaj ocenę i notatki';

  @override
  String get nothingToUndo => 'Nie ma już czego cofać';

  @override
  String get cellarUndoRejected =>
      'Cofnięcie nie powiodło się: butelka pozostaje oznaczona jako wypita';

  @override
  String get cellarDeleteFailed =>
      'Usuwanie nie jest jeszcze zakończone: dokończy się, gdy tylko będzie to możliwe';

  @override
  String get duplicateFull =>
      'To wino ma już 99 butelek: nie można dodać więcej.';

  @override
  String get recordSheetTitle => 'Ocena i notatki';

  @override
  String get recordRatingLabel => 'Ocena';

  @override
  String ratingStar(int n) {
    return 'Ocena $n z 5';
  }

  @override
  String get recordNotesLabel => 'Notatki';

  @override
  String get recordNotesTooLong => 'Maksymalnie 1000 znaków';

  @override
  String recordDateLabel(String date) {
    return 'Data: $date';
  }

  @override
  String get recordDateInvalid =>
      'Data nie może być w przyszłości ani przed rocznikiem';

  @override
  String get recordConditionTitle => 'Jakie było?';

  @override
  String get conditionTooYoung => 'Jeszcze za młode';

  @override
  String get conditionJustRight => 'W sam raz';

  @override
  String get conditionPastPeak => 'Po szczycie';

  @override
  String get recordNoCondition => 'Bez odpowiedzi';

  @override
  String get producerLabel => 'Producent (opcjonalnie)';

  @override
  String get producerTooLong => 'Maksymalnie 120 znaków';

  @override
  String producerAddNew(String name) {
    return 'Dodaj nowego producenta: „$name”';
  }

  @override
  String get wineTypeLabel => 'Typ';

  @override
  String get typeRedLight => 'Czerwone lekkie';

  @override
  String get typeRedStructured => 'Czerwone treściwe';

  @override
  String get typeWhite => 'Białe';

  @override
  String get typeRose => 'Różowe';

  @override
  String get typeSparklingClassic => 'Musujące metodą klasyczną';

  @override
  String get typeSparklingTank => 'Musujące metodą Charmata';

  @override
  String get typeSweet => 'Słodkie';

  @override
  String get typeFortified => 'Wzmacniane';

  @override
  String get suggestionFromCellar => 'W Twojej piwniczce';

  @override
  String get suggestionsLabel => 'Podpowiedzi';

  @override
  String get duplicateTitle => 'Już w piwniczce';

  @override
  String duplicateBody(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ma $count butelki',
      many: 'ma $count butelek',
      few: 'ma $count butelki',
      one: 'ma $count butelkę',
      zero: 'nie ma butelek',
    );
    return '$name: to wino już tu jest, $_temp0. Dodać do niego nowe butelki?';
  }

  @override
  String duplicateAdd(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dodaj $count butelki',
      many: 'Dodaj $count butelek',
      few: 'Dodaj $count butelki',
      one: 'Dodaj $count butelkę',
    );
    return '$_temp0';
  }

  @override
  String get duplicateBanner => 'Możliwy duplikat';

  @override
  String get duplicateMerge => 'Scal';

  @override
  String get duplicateDeleteHint => 'Usuń ten wpis, jeśli to duplikat';

  @override
  String get mergeTitle => 'Scalić oba wpisy?';

  @override
  String get mergeBody =>
      'Butelki z tego wpisu przejdą do starszego, a ten wpis zostanie usunięty.';

  @override
  String get editWineTitle => 'Edytuj wino';

  @override
  String get editDuplicate =>
      'Istnieje już inne wino o tej samej nazwie, producencie i roczniku';

  @override
  String deleteWineTitle(String name) {
    return 'Usunąć wino $name?';
  }

  @override
  String get deleteWineBody =>
      'Wino i wszystkie zapisy o wypitych butelkach zostaną usunięte. Tego nie można cofnąć.';

  @override
  String get historyTitle => 'Historia';

  @override
  String get historyEmpty => 'Tu znajdziesz wypite butelki';

  @override
  String get historyLoadFailed => 'Nie udało się wczytać historii';

  @override
  String drankOnLabel(String date) {
    return 'Wypite: $date';
  }

  @override
  String get addChoiceTitle => 'Dodaj wino';

  @override
  String get addChoicePhoto => 'Zrób zdjęcie';

  @override
  String get addChoiceImport => 'Importuj zdjęcie';

  @override
  String get addChoiceWrite => 'Wpisz';

  @override
  String get labelReading => 'Odczytuję etykietę…';

  @override
  String get labelRecognized => 'Rozpoznano:';

  @override
  String get labelCorrect => 'Popraw';

  @override
  String get labelConfirm => 'Potwierdź';

  @override
  String get labelUnreadable => 'Nie mogę odczytać etykiety';

  @override
  String get labelWriteByHand => 'Wpisz ręcznie';

  @override
  String get labelNotFound => 'Nie znaleziono wina: sprawdź dane';

  @override
  String get labelCameraDenied =>
      'Aby odczytać etykietę, potrzebuję dostępu do aparatu';

  @override
  String get labelPhotosDenied =>
      'Aby odczytać etykietę, potrzebuję dostępu do zdjęć';

  @override
  String get labelOpenSettings => 'Otwórz ustawienia';

  @override
  String get labelCameraUnavailable => 'Aparat niedostępny';

  @override
  String get labelBarcodeNotFound =>
      'Kod kreskowy odczytany, ale nie znaleziono wina';

  @override
  String get labelBarcodeFrontHint => 'Zrób zdjęcie przedniej etykiety';

  @override
  String get labelSharedNotAllowed => 'Nie możesz dodawać win do tej piwniczki';

  @override
  String get labelSharedFirstOnly => 'Użyto tylko pierwszego zdjęcia';

  @override
  String get labelSharedExpired =>
      'Nie udało się odczytać udostępnionego zdjęcia: udostępnij je ponownie';

  @override
  String get labelReplaceTitle =>
      'Masz niezapisane wino. Odczytać nowe zdjęcie?';

  @override
  String get labelReplaceRead => 'Odczytaj nowe zdjęcie';

  @override
  String get labelReplaceKeep => 'Zostań przy otwartym';

  @override
  String get labelWineAdded => 'Wino dodane do piwniczki';

  @override
  String get onboardingPage1Title => 'Twoja piwniczka w kieszeni';

  @override
  String get onboardingPage1Body =>
      'Dodawaj butelki, wpisując je lub robiąc zdjęcie etykiety, także bez sieci.';

  @override
  String get onboardingPage2Title => 'We właściwym czasie';

  @override
  String get onboardingPage2Body =>
      'Vinoozy szacuje, kiedy każde wino jest w najlepszej formie, i podpowiada, które otworzyć najpierw.';

  @override
  String get onboardingPage3Title => 'Razem';

  @override
  String get onboardingPage3Body =>
      'Udostępnij piwniczkę maksymalnie dwóm osobom i prowadź historię każdej wypitej butelki.';

  @override
  String get onboardingSkip => 'Pomiń';

  @override
  String get onboardingNext => 'Dalej';

  @override
  String get onboardingStart => 'Zaczynamy';

  @override
  String onboardingPageOf(int page) {
    return 'Strona $page z 3';
  }

  @override
  String get profileTitle => 'Profil';

  @override
  String get profilePhoto => 'Zdjęcie profilowe';

  @override
  String get profileSignOut => 'Wyloguj się';

  @override
  String get profileDeleteAccount => 'Usuń konto';

  @override
  String get profilePrivacy => 'Polityka prywatności';

  @override
  String get profilePrivacyBody =>
      'Politykę prywatności możesz przeczytać pod tym adresem:';

  @override
  String get profileOpenLink => 'Otwórz w przeglądarce';

  @override
  String get profileOpenLinkFailed =>
      'Nie udało się otworzyć strony. Możesz skopiować link i otworzyć go w przeglądarce.';

  @override
  String get profileCopyLink => 'Kopiuj link';

  @override
  String get profileLinkCopied => 'Link skopiowany';

  @override
  String get close => 'Zamknij';

  @override
  String get signOutConfirmTitle => 'Chcesz się wylogować?';

  @override
  String signOutPendingWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Masz $count niezapisanej jeszcze zmiany. Jeśli się wylogujesz, a zaloguje się inne konto, zostaną utracone.',
      many:
          'Masz $count niezapisanych jeszcze zmian. Jeśli się wylogujesz, a zaloguje się inne konto, zostaną utracone.',
      few:
          'Masz $count niezapisane jeszcze zmiany. Jeśli się wylogujesz, a zaloguje się inne konto, zostaną utracone.',
      one:
          'Masz $count niezapisaną jeszcze zmianę. Jeśli się wylogujesz, a zaloguje się inne konto, zostanie utracona.',
    );
    return '$_temp0';
  }

  @override
  String get signOutStayAndSync => 'Zostań i synchronizuj';

  @override
  String get signOutAnyway => 'Wyloguj mimo to';

  @override
  String get syncAllSaved => 'Wszystko zapisane';

  @override
  String syncStillPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count zmiany czeka na zapisanie: sprawdź sieć',
      many: '$count zmian czeka na zapisanie: sprawdź sieć',
      few: '$count zmiany czekają na zapisanie: sprawdź sieć',
      one: '$count zmiana czeka na zapisanie: sprawdź sieć',
    );
    return '$_temp0';
  }

  @override
  String get signOutFailed => 'Nie udało się wylogować. Spróbuj ponownie';

  @override
  String get signInAccountDeleted => 'Konto usunięte';

  @override
  String get deleteAccountIntro => 'Na stałe zostaną usunięte:';

  @override
  String get deleteAccountItemCellar => 'Twoja piwniczka z winami i Historią';

  @override
  String get deleteAccountItemShares =>
      'Udzielone przez Ciebie dostępy: zaproszone osoby stracą dostęp';

  @override
  String get deleteAccountItemMemberships =>
      'Twój udział w cudzych piwniczkach: zapisy o wypitych przez Ciebie butelkach zostaną tam bez Twojego imienia';

  @override
  String get deleteAccountItemProfile => 'Twój profil';

  @override
  String deleteAccountPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Masz $count niezapisanej jeszcze zmiany: zostaną zapisane, a potem usunięte razem z resztą',
      many:
          'Masz $count niezapisanych jeszcze zmian: zostaną zapisane, a potem usunięte razem z resztą',
      few:
          'Masz $count niezapisane jeszcze zmiany: zostaną zapisane, a potem usunięte razem z resztą',
      one:
          'Masz $count niezapisaną jeszcze zmianę: zostanie zapisana, a potem usunięta razem z resztą',
    );
    return '$_temp0';
  }

  @override
  String get deleteAccountConfirmWord => 'USUŃ';

  @override
  String deleteAccountTypeWord(String word) {
    return 'Wpisz $word, aby potwierdzić';
  }

  @override
  String get deleteAccountReauthHint =>
      'Potem zalogujesz się ponownie przez Google, aby potwierdzić, że to Ty.';

  @override
  String get deleteAccountForever => 'Usuń na zawsze';

  @override
  String get deleteAccountNeedsNetwork =>
      'Połącz się z internetem, aby usunąć konto';

  @override
  String get deleteAccountSameAccount =>
      'Usunięcie wymaga zalogowania się na to samo konto';

  @override
  String get deletionTitle => 'Usuwanie konta';

  @override
  String get deletionStepPreparePhone => 'Zapisywanie oczekujących zmian';

  @override
  String get deletionStepMarkStarted => 'Rozpoczynanie usuwania';

  @override
  String get deletionStepLeaveOtherCellars => 'Opuszczanie cudzych piwniczek';

  @override
  String get deletionStepCloseOwnInvitations => 'Zamykanie Twoich udostępnień';

  @override
  String get deletionStepDeleteWinesAndRecords => 'Usuwanie win i Historii';

  @override
  String get deletionStepDeleteCellar => 'Usuwanie piwniczki';

  @override
  String get deletionStepDeleteProfileAndUser => 'Usuwanie profilu i konta';

  @override
  String get deletionStepCleanUpPhone => 'Czyszczenie tego telefonu';

  @override
  String deletionStepAnnounce(int step, String label) {
    return 'Krok $step z 8: $label';
  }

  @override
  String deletionDeletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Usunięto $count wina i wpisu',
      many: 'Usunięto $count win i wpisów',
      few: 'Usunięto $count wina i wpisy',
      one: 'Usunięto $count wino lub wpis',
    );
    return '$_temp0';
  }

  @override
  String get deletionResumeHint =>
      'Usuwanie tego konta nie zostało dokończone. Zaloguj się ponownie przez Google, aby je dokończyć.';

  @override
  String get deletionContinue => 'Kontynuuj';

  @override
  String get deletionOffline =>
      'Połącz się z internetem, aby dokończyć usuwanie';

  @override
  String get deletionPendingWrites =>
      'Nie mogę zapisać oczekujących zmian. Spróbuj ponownie';

  @override
  String get deletionFailed =>
      'Nie udało się dokończyć usuwania. Spróbuj ponownie';

  @override
  String get uxCountryLabel => 'Kraj';

  @override
  String get uxCountryOther => 'Inny kraj…';

  @override
  String get uxCountryNone => 'Bez kraju';

  @override
  String get uxAllCountriesTitle => 'Wszystkie kraje i terytoria';

  @override
  String get uxAllCountriesSearch => 'Szukaj kraju';

  @override
  String get uxAllCountriesRare => 'Rzadkie dla wina';

  @override
  String get uxAllCountriesAll => 'Wszystkie, od A do Z';

  @override
  String get uxAllCountriesNone => 'Nie znaleziono kraju';

  @override
  String get uxRegionLabel => 'Region';

  @override
  String uxRegionOf(String country) {
    return 'Region · $country';
  }

  @override
  String get uxRegionOther => 'Inny region';

  @override
  String get uxRegionFieldLabel => 'Wpisz region';

  @override
  String get uxRegionTooLong => 'Maksymalnie 120 znaków';

  @override
  String get uxDrinkAction => 'Wypita';

  @override
  String uxDrinkActionTooltip(String name) {
    return 'Wypita butelka wina $name';
  }

  @override
  String get uxDrinkActionDetail => 'Wypita butelka';

  @override
  String get uxDrinkSheetLabel => 'Potwierdź wypicie';

  @override
  String get uxDrinkSheetBottles => 'Butelki';

  @override
  String uxDrinkSheetBottlesChange(int before, int after) {
    return 'Butelki: z $before na $after';
  }

  @override
  String get uxDrinkSheetRating => 'Jakie było? (opcjonalnie)';

  @override
  String uxDrinkSheetStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gwiazdki z 5',
      many: '$count gwiazdek z 5',
      few: '$count gwiazdki z 5',
      one: '$count gwiazdka z 5',
    );
    return '$_temp0';
  }

  @override
  String get uxDrinkSheetConfirm => 'Tak, wypita';

  @override
  String get uxRemoveBottle => 'Usuń butelkę bez zapisu wypicia';

  @override
  String get uxRemoveBottleTitle => 'Usunąć butelkę?';

  @override
  String uxRemoveBottleBody(String name) {
    return 'Jedna butelka wina $name zostanie usunięta bez zapisu wypicia.';
  }

  @override
  String get uxRemoveBottleConfirm => 'Usuń';

  @override
  String get uxIdealTitle => 'Najlepszy moment';

  @override
  String uxIdealUntil(String year) {
    return 'Zalecane do $year';
  }

  @override
  String uxIdealUntilPast(String year) {
    return 'Zalecane do $year: termin minął';
  }

  @override
  String uxIdealBest(String start, String end) {
    return 'W najlepszej formie od $start do $end';
  }

  @override
  String uxIdealBar(String start, String end) {
    return 'Okno picia od $start do $end';
  }

  @override
  String get uxIdealDisclaimer =>
      '⚠︎ Orientacyjnie: szacunek na podstawie typu, apelacji i rocznika. Przechowywanie i konkretna butelka mogą go zmienić.';

  @override
  String get uxIdealUnavailableHint =>
      'Dodaj rocznik i typ, aby uzyskać szacunek.';

  @override
  String uxDashboardDrinkNow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count do wypicia teraz',
      many: '$count do wypicia teraz',
      few: '$count do wypicia teraz',
      one: '$count do wypicia teraz',
    );
    return '$_temp0';
  }

  @override
  String get uxFamilyRed => 'Czerwone';

  @override
  String get uxFamilyWhite => 'Białe';

  @override
  String get uxFamilyRose => 'Różowe';

  @override
  String get uxFamilySparkling => 'Musujące';

  @override
  String get uxFamilySweet => 'Słodkie';

  @override
  String get labelBackTitle => 'Teraz tył';

  @override
  String get labelBackHint =>
      'Na kontretykiecie zwykle są kod kreskowy, producent i rocznik: pomagają znaleźć wino.';

  @override
  String get labelBackTake => 'Sfotografuj tył';

  @override
  String get labelBackGallery => 'Wybierz z galerii';

  @override
  String get labelBackSkip => 'Pomiń';

  @override
  String get labelStepFront => 'Przód';

  @override
  String get labelStepBack => 'Tył';

  @override
  String get labelStepBarcode => 'Kod kreskowy';

  @override
  String get labelStepDatabase => 'Baza win w telefonie';

  @override
  String get labelStepPending => 'Oczekuje';

  @override
  String get labelStepRunning => 'W toku…';

  @override
  String get labelStepDone => 'Gotowe';

  @override
  String get labelStepSkipped => 'Pominięto';

  @override
  String get labelStepFailed => 'Nieczytelne';

  @override
  String labelStepStatus(String step, String status) {
    return '$step: $status';
  }

  @override
  String get labelOnPhoneNote =>
      'Wszystko dzieje się w telefonie: zdjęcia nie są nikomu wysyłane.';

  @override
  String get labelBackUnreadable => 'Tył nieczytelny';

  @override
  String get labelSourceOffline => 'Z bazy w telefonie · offline';

  @override
  String get labelSourceCatalog => 'Z katalogu';

  @override
  String get labelSourceOnline => 'Z Open Food Facts · online';

  @override
  String get labelNotThis => 'To nie to';

  @override
  String get labelOffAttribution => 'Dane z Open Food Facts, licencja ODbL';

  @override
  String get labelCandidatesTitle => 'Które z nich?';

  @override
  String labelCandidatesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count podobnego wina',
      many: '$count podobnych win',
      few: '$count podobne wina',
      one: '$count podobne wino',
    );
    return '$_temp0';
  }

  @override
  String get labelCandidatesNone => 'Żadne z nich';

  @override
  String get labelChipOffline => 'offline';

  @override
  String get labelChipOnline => 'online';

  @override
  String get labelChipCatalog => 'katalog';

  @override
  String get labelNoProducer => 'nie podano producenta';

  @override
  String get labelNoMatch => 'Etykieta odczytana, ale nie rozpoznaję wina';

  @override
  String get labelReadText => 'Odczytany tekst';

  @override
  String get labelSearchOnline => 'Szukaj online';

  @override
  String get labelOpenLens => 'Otwórz w Google Lens';

  @override
  String get labelLensLastResort =>
      'Google Lens to ostateczność: zdjęcie trafi do aplikacji Google tylko po Twoim potwierdzeniu.';

  @override
  String get labelLensTitle => 'Otworzyć w Google Lens?';

  @override
  String get labelLensBody =>
      'Zdjęcie przedniej etykiety trafi do aplikacji Google w Twoim telefonie albo do wybranej przez Ciebie aplikacji, która może zachować kopię zgodnie z własnymi zasadami. Vinoozy nie otrzymuje wyników: wróć tutaj, aby wybrać lub wpisać wino.';

  @override
  String get labelLensConfirm => 'Otwórz Google Lens';

  @override
  String get labelLensFailed =>
      'Nie mogę otworzyć Google Lens ani menu udostępniania';

  @override
  String get onlineSearchTitle => 'Szukaj online';

  @override
  String get onlineSearchSubtitle => 'Open Food Facts · tylko wina';

  @override
  String get onlineSearchField => 'Szukane słowa';

  @override
  String get onlineSearchHint => 'Przed wyszukaniem możesz zmienić słowa.';

  @override
  String get onlineSearchEmptyField => 'Wpisz co najmniej jedno słowo';

  @override
  String get onlineSearchButton => 'Szukaj';

  @override
  String get onlineSearchLoading => 'Szukam…';

  @override
  String onlineSearchResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wyniku',
      many: '$count wyników',
      few: '$count wyniki',
      one: '$count wynik',
    );
    return '$_temp0';
  }

  @override
  String get onlineSearchEmpty =>
      'Nie znaleziono wina: spróbuj innych słów lub „Wpisz ręcznie”.';

  @override
  String get onlineSearchOffline =>
      'Brak sieci: szukam tylko w bazie w telefonie.';

  @override
  String get onlineSearchRateLimited =>
      'Wyszukiwanie online jest teraz niedostępne, spróbuj ponownie za kilka minut.';

  @override
  String get onlineSearchUnavailable =>
      'Wyszukiwanie online nie jest aktywne w tej wersji aplikacji: szukam tylko w bazie w telefonie.';

  @override
  String get aboutTitle => 'O aplikacji';

  @override
  String aboutVersion(String version) {
    return 'Wersja $version';
  }

  @override
  String get aboutDbTitle => 'Baza win';

  @override
  String aboutDbCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wina',
      many: '$count win',
      few: '$count wina',
      one: '$count wino',
    );
    return '$_temp0';
  }

  @override
  String aboutDbDate(String date) {
    return 'Eksport Open Food Facts z dnia $date';
  }

  @override
  String get aboutDbSample =>
      'Baza przykładowa: kilka ręcznie wpisanych win testowych, a nie dane Open Food Facts.';

  @override
  String get aboutDbLoading => 'Otwieram bazę win…';

  @override
  String get aboutDbUnavailable => 'Baza win nie jest dostępna w tej wersji';

  @override
  String aboutDbSource(String url) {
    return 'Pochodna baza danych i narzędzie, które ją tworzy, są w publicznym repozytorium: $url';
  }

  @override
  String get aboutLicenseTitle => 'Licencje';

  @override
  String get aboutLicense =>
      'Zawiera informacje z Open Food Facts, udostępnione na licencji Open Database License (ODbL). Poszczególne treści są objęte licencją Database Contents License (DbCL).';

  @override
  String get aboutPrivacyTitle => 'Zdjęcia etykiet';

  @override
  String get aboutPrivacy =>
      'Zdjęcia etykiet są odczytywane w telefonie i usuwane, gdy opuszczasz ekran wyniku. Opuszczają telefon tylko wtedy, gdy dotkniesz „Otwórz w Google Lens” i potwierdzisz.';

  @override
  String get aboutAppellationsTitle => 'Apelacje';

  @override
  String get aboutAppellationsSource =>
      'Apelacje: rejestr eAmbrosia (UE) i oficjalne rejestry krajowe.';

  @override
  String get aboutAppellationsSample =>
      'Tabela przykładowa: ręcznie przepisany wyciąg z rejestrów, do czasu pobrania prawdziwych rejestrów.';

  @override
  String get denominationLabel => 'Apelacja';

  @override
  String get denominationTooLong => 'Maksymalnie 120 znaków';

  @override
  String get autofillFilledNotice => 'Wypełniono z etykiety: sprawdź i zapisz';

  @override
  String get autofillPastedNotice => 'Wypełniono z tekstu: sprawdź i zapisz';

  @override
  String get autofillFromText => '✦ z tekstu';

  @override
  String get autofillFromTextSemantics => 'wypełniono z etykiety';

  @override
  String get autofillClear => 'Wyczyść';

  @override
  String get autofillLens => 'Lens';

  @override
  String get autofillClearTitle => 'Wyczyścić formularz?';

  @override
  String get autofillClearBody =>
      'Część pól wypełniono też ręcznie. „Wyczyść” opróżnia nazwę, producenta, apelację, rocznik, typ, kraj, region i poziom. Ilość zostaje.';

  @override
  String get autofillClearConfirm => 'Wyczyść';

  @override
  String get autofillCleared => 'Formularz wyczyszczony';

  @override
  String get autofillPasteTitle => 'Masz tekst z Google Lens?';

  @override
  String get autofillPasteHint =>
      'W Lens zaznacz tekst etykiety i dotknij „Kopiuj”, a potem wróć tutaj.';

  @override
  String get autofillPaste => 'Wklej z Lens';

  @override
  String get autofillOpenLens => 'Z Google Lens';

  @override
  String get autofillOpenLensSemantics => 'otwiera Google Lens';

  @override
  String get autofillClipboardEmpty => 'W schowku nie ma tekstu';

  @override
  String get autofillNoNewFields =>
      'W tekście nie znaleziono danych do dodania';

  @override
  String get autofillFromLens => 'Formularz wypełniony tekstem z Lens';

  @override
  String get autofillShareEmpty => 'Nie otrzymano tekstu';

  @override
  String get autofillShareUseTitle => 'Użyć tekstu do pustych pól?';

  @override
  String get autofillShareUse => 'Użyj';

  @override
  String get autofillShareIgnore => 'Ignoruj';

  @override
  String get addChoiceLens => 'Z Google Lens';

  @override
  String get addChoicePhotoHint => 'Przód i tył: Vinoozy odczyta etykietę.';

  @override
  String get addChoiceLensHint =>
      'Otwiera Lens: skadruj, zaznacz tekst i dotknij Udostępnij → Vinoozy.';

  @override
  String get addChoiceImportHint => 'Zdjęcie etykiety, które już masz.';

  @override
  String get addChoiceWriteHint => 'Pusty formularz z opcją „Wklej z Lens”.';

  @override
  String get lensInstructionsTitle => 'Nie można stąd otworzyć Google Lens';

  @override
  String get lensInstructionsStep1 => 'Otwórz Google Lens i skadruj etykietę';

  @override
  String get lensInstructionsStep2 => 'Zaznacz tekst etykiety';

  @override
  String get lensInstructionsStep3 => 'Dotknij Udostępnij → Vinoozy';

  @override
  String get lensInstructionsOk => 'Rozumiem';

  @override
  String get levelLabel => 'Poziom';

  @override
  String get levelEveryday => 'Codzienne (niedrogie)';

  @override
  String get levelGood => 'Dobre';

  @override
  String get levelAging => 'Do leżakowania';

  @override
  String get levelNone => 'Brak';

  @override
  String get levelEverydayShort => 'wypić wcześnie';

  @override
  String get levelGoodShort => 'zwykły szacunek';

  @override
  String get levelAgingShort => 'wytrzyma dłużej';

  @override
  String get levelSuggested => 'sugerowany';

  @override
  String levelSuggestedReason(String qualifier) {
    return 'Sugerowany, bo w nazwie jest „$qualifier”: tak zostanie zapisany, jeśli go nie zmienisz. Wybierz inny lub dotknij „Brak”.';
  }

  @override
  String levelSuggestedSemantics(String qualifier) {
    return 'sugerowany, bo w nazwie jest $qualifier';
  }

  @override
  String levelOptionSemantics(String option, int index, int count) {
    return 'Poziom, $option, $index z $count';
  }

  @override
  String get levelWhatChanges => 'Co się zmienia';

  @override
  String get levelEverydayExamples =>
      'Okno się skraca. Np. wino stołowe, Lambrusco, podstawowe Prosecco, Bardolino, Vinho Verde.';

  @override
  String get levelGoodExamples =>
      'Zwykły szacunek, stosowany też wtedy, gdy nic nie wybierzesz. Np. Chianti Classico, Barbera d\'Asti Superiore, Rioja Crianza, Côtes du Rhône.';

  @override
  String get levelAgingExamples =>
      'Okno się wydłuża. Np. Barolo, Brunello, Amarone, Bordeaux Grand Cru, Rioja Gran Reserva, Vintage Port.';

  @override
  String levelPreviewBefore(String start, String end) {
    return 'Przedtem $start – $end';
  }

  @override
  String levelPreviewWith(String level, String start, String end) {
    return 'Z poziomem „$level” $start – $end';
  }

  @override
  String levelPreviewNow(String start, String end) {
    return 'Gotowe $start – do $end';
  }

  @override
  String levelDetail(String level) {
    return 'Poziom: $level';
  }

  @override
  String get overrideCorrect => 'Popraw';

  @override
  String get overrideRestore => 'Przywróć szacunek';

  @override
  String get overrideCorrectedByYou => 'skorygowane przez Ciebie';

  @override
  String overrideAppEstimate(String year) {
    return 'Szacunek aplikacji: do $year';
  }

  @override
  String get overrideSheetTitle => 'Zalecane do';

  @override
  String overrideSheetHint(String start) {
    return 'Wybierz rok. Nie może być wcześniejszy niż „Gotowe od $start”.';
  }

  @override
  String overridePeakNotice(String peak) {
    return 'Jeśli wybierzesz rok wcześniejszy niż $peak (w najlepszej formie), „w najlepszej formie” też przesunie się na ten rok.';
  }

  @override
  String get overrideMore => 'więcej…';

  @override
  String get overrideSave => 'Zapisz korektę';

  @override
  String overrideRestoreTitle(String year) {
    return 'Wrócić do szacunku aplikacji (do $year)?';
  }

  @override
  String get overrideRestoreConfirm => 'Przywróć';

  @override
  String get overrideSaved => 'Korekta zapisana';

  @override
  String get overrideRestored => 'Szacunek przywrócony';

  @override
  String get estimateSourceCorrectedByYou => 'skorygowane przez Ciebie';

  @override
  String estimateFromDenomination(String name) {
    return 'Szacunek na podstawie apelacji $name';
  }

  @override
  String estimateFromDenominationQualifier(String name, String qualifier) {
    return 'Szacunek na podstawie apelacji $name, $qualifier';
  }

  @override
  String estimateFromGrape(String name) {
    return 'Szacunek na podstawie szczepu $name';
  }

  @override
  String get estimateFromType => 'Szacunek na podstawie typu wina';

  @override
  String get autofillReading => 'Odczytuję tekst…';

  @override
  String get guideChip => 'Przewodnik';

  @override
  String guideProgress(int n, int total) {
    return 'Pytanie $n z $total';
  }

  @override
  String get guideClose => 'Zamknij';

  @override
  String get guideIsDenomination => 'czy to apelacja?';

  @override
  String get guideIsProducer => 'czy to producent?';

  @override
  String get guideIsName => 'czy to nazwa wina?';

  @override
  String get guideIsVintage => 'Rocznik';

  @override
  String guideAskDenomination(String value) {
    return 'Czy $value to apelacja?';
  }

  @override
  String guideAskProducer(String value) {
    return 'Czy $value to producent?';
  }

  @override
  String guideAskName(String value) {
    return 'Czy $value to nazwa wina?';
  }

  @override
  String get guideAskVintage => 'Jaki to rocznik?';

  @override
  String guideQuestionSemantics(int n, int total, String question) {
    return 'Pytanie $n z $total: $question';
  }

  @override
  String get guideNoProposal => 'Nie znaleziono tego w tekście';

  @override
  String get guideYes => 'Tak';

  @override
  String get guideNo => 'Nie, coś innego';

  @override
  String get guideEdit => 'Edytuj';

  @override
  String get guideSkip => 'Pomiń';

  @override
  String get guideConfirm => 'Potwierdź';

  @override
  String get guideCancel => 'Anuluj';

  @override
  String guideRejected(String value) {
    return 'Nie „$value”: oto następna propozycja';
  }

  @override
  String get guideNoMore => 'Brak innych propozycji: ułóż ją ze słów lub pomiń';

  @override
  String guideProposalAnnounce(String value) {
    return 'Propozycja: $value';
  }

  @override
  String get guideComposeLabel => 'Albo ułóż, dotykając słów z tekstu';

  @override
  String get guideComposePreview => 'Podgląd';

  @override
  String get guideComposeEmpty => 'Dotknij jednego lub kilku słów';

  @override
  String get guideComposeLimit => 'Do 8 słów i 80 znaków';

  @override
  String guideTableMatchSemantics(String name) {
    return 'odpowiada: $name';
  }

  @override
  String guideLine(int n, int total) {
    return 'Wiersz $n z $total';
  }

  @override
  String guideWordSelected(String word, int order) {
    return '$word, zaznaczone, $order';
  }

  @override
  String guideWordUnavailable(String word) {
    return '$word, niedostępne';
  }

  @override
  String guideWordUsedFor(String word, String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'apelacja',
      'producer': 'producent',
      'other': 'nazwa',
    });
    return '$word, użyte w polu: $_temp0';
  }

  @override
  String guideUsedMark(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'apelacja',
      'producer': 'producent',
      'other': 'nazwa',
    });
    return '$_temp0';
  }

  @override
  String guideOtherYears(String years) {
    return 'W tekście są też: $years';
  }

  @override
  String get guideWheelFromText => 'rok znaleziony w tekście';

  @override
  String get guideWheelTypeYear => 'Wpisz rok';

  @override
  String guideWheelConfirm(String year) {
    return 'Potwierdź $year';
  }

  @override
  String get guideNoVintage => 'Bez rocznika';

  @override
  String guideSkippedNotice(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'Pominięto apelację',
      'producer': 'Pominięto producenta',
      'vintage': 'Pominięto rocznik',
      'other': 'Pominięto nazwę',
    });
    return '$_temp0: wpisz ręcznie lub wróć do przewodnika';
  }

  @override
  String guideSkippedMany(int count) {
    return 'Pominięte pola: $count. Wpisz je lub wróć do przewodnika';
  }

  @override
  String get guideInvalidValue =>
      'Ten tekst zawiera znaki, których nie można zapisać';

  @override
  String get brandStudio => 'Bottazzini Softworks';

  @override
  String get suggestedMark => '✦ sugerowane';

  @override
  String suggestedSemantics(String field, String value) {
    return '$field, $value, sugerowane';
  }

  @override
  String get restoreSuggestion => 'Przywróć sugestię';

  @override
  String get restoreSuggestionDone => 'Sugestia przywrócona';

  @override
  String get styleLabel => 'Styl';

  @override
  String styleGroupSemantics(String value, int index, int count) {
    return 'Styl, $value, $index z $count';
  }

  @override
  String get styleRedFresh => 'Świeże';

  @override
  String get styleRedMedium => 'Średnie';

  @override
  String get styleRedAge => 'Do leżakowania';

  @override
  String get styleRedLong => 'Długie leżakowanie';

  @override
  String get styleWhiteFresh => 'Świeże';

  @override
  String get styleWhiteMedium => 'Średnie';

  @override
  String get styleWhiteAge => 'Do leżakowania';

  @override
  String get styleRoseFresh => 'Świeże';

  @override
  String get styleClassicFresh => 'Świeże';

  @override
  String get styleClassicAge => 'Do leżakowania';

  @override
  String get styleTankFresh => 'Świeże';

  @override
  String get styleLambrusco => 'Lambrusco';

  @override
  String get styleSweetAromatic => 'Aromatyczne';

  @override
  String get styleSweetPassito => 'Z podsuszanych gron';

  @override
  String get styleSweetBotrytis => 'Botrytyzowane';

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
  String get styleFortifiedOther => 'Inne';

  @override
  String get profileNameRFresh => 'Czerwone owocowe';

  @override
  String get profileNameRMedium => 'Czerwone średniej budowy';

  @override
  String get profileNameRAge => 'Czerwone do leżakowania';

  @override
  String get profileNameRLong => 'Czerwone do długiego leżakowania';

  @override
  String get profileNameWFresh => 'Białe świeże i aromatyczne';

  @override
  String get profileNameWMedium => 'Białe średniej budowy';

  @override
  String get profileNameWAge => 'Białe do leżakowania';

  @override
  String get profileNameRoseFresh => 'Różowe świeże';

  @override
  String get profileNameSpTank => 'Musujące świeże metodą Charmata';

  @override
  String get profileNameLamFresh => 'Lambrusco świeże';

  @override
  String get profileNameSpClassic => 'Musujące świeże metodą klasyczną';

  @override
  String get profileNameSpClassicAge =>
      'Musujące metodą klasyczną do leżakowania';

  @override
  String get profileNameSwAromatic => 'Słodkie młode i aromatyczne';

  @override
  String get profileNameSwPassito => 'Słodkie z podsuszanych gron';

  @override
  String get profileNameSwBotrytis => 'Słodkie botrytyzowane';

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
  String get profileNameFortUnknown => 'Wzmacniane, styl nieznany';

  @override
  String get profileNameUnknown => 'Styl nierozpoznany';

  @override
  String estimateFromProfile(String profile, String denomination) {
    return 'Szacunek na podstawie profilu: $profile ($denomination)';
  }

  @override
  String estimateFromProfileType(String profile) {
    return 'Szacunek na podstawie profilu: $profile, według typu';
  }

  @override
  String estimateFromProfileGrape(String profile, String grape) {
    return 'Szacunek na podstawie profilu: $profile, według szczepu $grape';
  }

  @override
  String get estimateFromEntryDateDisgorgement =>
      'Od daty dodania: podaj datę degorżowania, aby poprawić szacunek';

  @override
  String get estimateFromEntryDateBottling =>
      'Od daty dodania: podaj datę butelkowania, aby poprawić szacunek';

  @override
  String get styleToConfirmBanner =>
      '⚠︎ Styl do potwierdzenia: szacunek jest orientacyjny';

  @override
  String get chooseTypePrompt => 'Wybierz typ';

  @override
  String estimateUpdatedAnnouncement(String summary) {
    return 'Szacunek zaktualizowany: $summary';
  }

  @override
  String get agingStartDisgorgement => 'Degorżowanie';

  @override
  String get agingStartBottling => 'Butelkowanie';

  @override
  String get agingStartMonth => 'Miesiąc';

  @override
  String get agingStartYear => 'Rok';

  @override
  String get agingStartHint => 'Zwykle jest na kontretykiecie.';

  @override
  String get agingStartIncomplete => 'Podaj miesiąc i rok';

  @override
  String get agingStartFuture => 'Data nie może być w przyszłości';

  @override
  String get agingStartBeforeVintage => 'Nie może być przed rocznikiem';

  @override
  String get windowNoEnd => 'Gotowe, bez szacowanego końca';

  @override
  String get windowNoEndShort => 'bez szacowanego końca';

  @override
  String windowDrinkWithin(String date) {
    return 'do $date';
  }

  @override
  String get levelNoEffect => 'Poziom nie zmienia tego szacunku';

  @override
  String get dashboardToConfirmTitle => 'Do potwierdzenia';

  @override
  String dashboardToConfirmCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wina',
      many: '$count win',
      few: '$count wina',
      one: '$count wino',
    );
    return '$_temp0';
  }

  @override
  String aboutDbClassified(String percent) {
    return '$percent% win z rozpoznanym typem';
  }

  @override
  String get planTitle => 'Plan';

  @override
  String get planFree => 'Bezpłatny';

  @override
  String get planPlus => 'Plus';

  @override
  String get planPlusGift => 'Plus (prezent)';

  @override
  String get planDevUnlockAll => 'DEV · Testowy Plus';

  @override
  String get planDevSimulateFree => 'DEV · Symulowany plan bezpłatny';

  @override
  String get planDevSimulateExpired => 'DEV · Symulowany wygasły Plus';

  @override
  String get planDiscoverPlus => 'Poznaj Plus';

  @override
  String get plusTitle => 'Vinoozy Plus';

  @override
  String get plusBenefitsTitle => 'Z Plus';

  @override
  String get plusBenefitNoAds => 'Bez reklam';

  @override
  String get plusBenefitNoLimit => 'Bez limitu win w piwniczce';

  @override
  String get plusComingSoon => 'Plus już wkrótce';

  @override
  String get plusLoading => 'Pobieram ceny z Google Play';

  @override
  String get plusStoreUnavailable =>
      'Nie udało się pobrać cen z Google Play. Spróbuj później.';

  @override
  String plusPriceMonthly(String price) {
    return '$price miesięcznie';
  }

  @override
  String plusPriceAnnual(String price) {
    return '$price rocznie';
  }

  @override
  String get plusRenewal =>
      'Subskrypcja odnawia się automatycznie w podanej cenie, dopóki nie anulujesz jej w Google Play.';

  @override
  String get plusTerms =>
      'Płatność obciąża Twoje konto Google Play w chwili potwierdzenia zakupu. Możesz zrezygnować w każdej chwili: Plus pozostaje aktywny do końca opłaconego okresu. Gdy Plus się skończy, wszystkie Twoje wina zostają.';

  @override
  String get plusRestore => 'Przywróć zakupy';

  @override
  String get plusManage => 'Zarządzaj subskrypcją lub anuluj ją w Google Play';

  @override
  String get plusActive => 'Plus jest aktywny na tym koncie';

  @override
  String get plusActiveGift =>
      'Masz Plus w prezencie: bez opłat i bez odnowień.';

  @override
  String get plusPending =>
      'Płatność oczekuje: Plus będzie aktywny, gdy Google Play ją potwierdzi.';

  @override
  String get plusVerifying => 'Weryfikuję zakup';

  @override
  String get plusVerified =>
      'Zakup zweryfikowany: Plus będzie aktywny za kilka sekund.';

  @override
  String get plusPurchaseFailed =>
      'Zakup nie został dokończony. Spróbuj ponownie.';

  @override
  String get plusInvalidPurchase =>
      'Google Play nie potwierdził tego zakupu dla Vinoozy.';

  @override
  String get plusOwnedByOther =>
      'Ta subskrypcja należy już do innego konta Vinoozy.';

  @override
  String get plusVerificationUnavailable =>
      'Nie można teraz zweryfikować zakupu. Spróbuj później: subskrypcja pozostaje w Google Play.';

  @override
  String get capacityLimitTitle => 'Osiągnięto limit planu bezpłatnego';

  @override
  String capacityLimitBody(int limit) {
    return 'Plan bezpłatny obejmuje maksymalnie tyle różnych win w piwniczce: $limit. Wina, które już masz, zawsze możesz edytować, oznaczać jako wypite i uzupełniać o kolejne butelki. Aby dodać nowe wino, skończ lub usuń któreś z win albo przejdź na Plus.';
  }

  @override
  String capacityLimitBodyComingSoon(int limit) {
    return 'Plan bezpłatny obejmuje maksymalnie tyle różnych win w piwniczce: $limit. Wina, które już masz, zawsze możesz edytować, oznaczać jako wypite i uzupełniać o kolejne butelki. Aby dodać nowe wino, skończ lub usuń któreś z win. Plus już wkrótce.';
  }

  @override
  String get rejectedCapacityLimit =>
      'Nie zsynchronizowano: przekroczony limit win planu bezpłatnego. Zmiana zostaje w tym telefonie.';

  @override
  String get rejectedCapacityConflict =>
      'Nie zsynchronizowano: piwniczka zmieniła się w tym samym czasie na innym urządzeniu. Zmiana zostaje w tym telefonie: spróbuj ponownie.';

  @override
  String writeRejectedCapacityLimit(String name) {
    return '$name: nie zsynchronizowano, przekroczony limit planu bezpłatnego';
  }

  @override
  String writeRejectedCapacityConflict(String name) {
    return '$name: nie zsynchronizowano, piwniczka zmieniła się na innym urządzeniu';
  }

  @override
  String get freeIntroTitle => 'Plan bezpłatny';

  @override
  String freeIntroLimit(int limit) {
    return 'Bezpłatnie możesz prowadzić piwniczkę do takiej liczby różnych win: $limit.';
  }

  @override
  String get freeIntroAds =>
      'Przy niewielkim użyciu reklam nie ma. Po przekroczeniu miesięcznego progu użycia usługi mogą pojawiać się sporadyczne reklamy, które pomagają pokryć koszty serwerów i synchronizacji.';

  @override
  String get freeIntroNoAds => 'W wersji startowej nie ma reklam.';

  @override
  String get freeIntroPlus => 'Plus usuwa reklamy i limit piwniczki.';

  @override
  String get noticeGotIt => 'Rozumiem';

  @override
  String get thresholdTitle => 'Dzięki reklamom Vinoozy jest bezpłatne';

  @override
  String get thresholdBody =>
      'Osiągnięto miesięczny próg użycia bez reklam. Od teraz mogą pojawiać się sporadyczne reklamy: pomagają nam pokryć koszty serwerów i synchronizacji, dzięki czemu Vinoozy pozostaje bezpłatne.';

  @override
  String get thresholdReset =>
      'Licznik zeruje się w przyszłym miesiącu. Z Plus korzystasz z aplikacji bez reklam i bez limitu piwniczki.';

  @override
  String thresholdNextReset(String date) {
    return 'Następne zerowanie: $date';
  }

  @override
  String get thresholdHowItWorks => 'Jak to działa';

  @override
  String get thresholdHowItWorksBody =>
      'Próg zależy od szacowanej liczby synchronizacji z chmurą wykonanych przez to konto w ciągu miesiąca. Samo korzystanie offline nie tworzy nowych operacji w chmurze. Reklamy pojawiają się najwyżej raz dziennie, tylko na Pulpicie, i nigdy podczas zapisywania lub eksportu danych.';

  @override
  String get adLabel => 'Reklama';

  @override
  String get devToolsTitle => 'Narzędzia deweloperskie';

  @override
  String get devUnlockAll => 'Odblokuj wszystko — testowy Plus';

  @override
  String get devSimulateFree => 'Symuluj plan bezpłatny';

  @override
  String get devSimulateExpired => 'Symuluj wygasły Plus';

  @override
  String get devRestore => 'Przywróć normalny stan';

  @override
  String get devNoOverride => 'Brak aktywnej symulacji';

  @override
  String get devApplied =>
      'Scenariusz zastosowano także w emulatorze Firestore';

  @override
  String get devIncomplete =>
      'Symulacja niepełna: emulator Firestore nie potwierdził testowego uprawnienia. Reguły serwera nie widzą tego scenariusza.';

  @override
  String get devNotice =>
      'Tylko kompilacje deweloperskie z emulatorem: bez płatności, tokenów i paragonów.';
}
