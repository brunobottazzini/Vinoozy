// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bulgarian (`bg`).
class AppLocalizationsBg extends AppLocalizations {
  AppLocalizationsBg([String locale = 'bg']) : super(locale);

  @override
  String get appTitle => 'Vinoozy';

  @override
  String get signInTagline => 'Вашата изба в точния момент';

  @override
  String get signInWithGoogle => 'Продължаване с Google';

  @override
  String get signInInProgress => 'Влизане';

  @override
  String get signInFailed => 'Влизането не бе успешно';

  @override
  String get signInNeedsNetwork =>
      'За първото влизане е нужна връзка с интернет';

  @override
  String get signInSessionExpired => 'Сесията ви изтече: влезте отново';

  @override
  String get retry => 'Нов опит';

  @override
  String get cancel => 'Отказ';

  @override
  String blockedMessage(String email) {
    return 'Има промени от $email, които още не са запазени в облака: влезте с този акаунт и се свържете с мрежата';
  }

  @override
  String blockedSignInWith(String email) {
    return 'Вход с $email';
  }

  @override
  String blockedDiscard(String email) {
    return 'Изтриване на незапазените промени от $email';
  }

  @override
  String get discardDialogTitle => 'Да се изтрият ли промените?';

  @override
  String discardDialogBody(int count, String email) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count вина от $email още не са в облака и ще бъдат изтрити от този телефон.',
      one:
          '1 вино от $email още не е в облака и ще бъде изтрито от този телефон.',
    );
    return '$_temp0';
  }

  @override
  String get discardConfirm => 'Изтриване';

  @override
  String get resetFailed =>
      'Данните на този телефон не можаха да бъдат изчистени';

  @override
  String get restartRequired => 'Рестартирайте приложението, за да завършите';

  @override
  String get restartCloseApp => 'Затваряне на приложението';

  @override
  String get startupFailed => 'Приложението не можа да се стартира';

  @override
  String get cellarTitle => 'Изба';

  @override
  String get defaultCellarName => 'Моята изба';

  @override
  String get cellarLoading => 'Избата се подготвя';

  @override
  String get cellarSetupFailed => 'Избата не можа да бъде подготвена';

  @override
  String get cellarEmpty => 'Избата ви е празна';

  @override
  String get addWine => 'Добавяне';

  @override
  String get estimatePending => 'Прогнозата предстои';

  @override
  String get noVintage => 'Без реколта';

  @override
  String bottleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count бутилки',
      one: '1 бутилка',
    );
    return '$_temp0';
  }

  @override
  String get syncInProgress => 'Синхронизиране';

  @override
  String get syncOffline => 'Офлайн – изчаква синхронизиране';

  @override
  String writeRejected(String name) {
    return 'Промяната не е разрешена: $name';
  }

  @override
  String get saveFailed => 'Запазването не бе успешно, опитайте отново';

  @override
  String wineNotSaved(String name) {
    return 'Виното $name не беше запазено в облака';
  }

  @override
  String get addAgain => 'Добавяне отново';

  @override
  String get ignore => 'Пренебрегване';

  @override
  String get addWineTitle => 'Въвеждане';

  @override
  String get wineNameLabel => 'Вино';

  @override
  String get vintageLabel => 'Реколта';

  @override
  String get quantityLabel => 'Количество';

  @override
  String get decreaseQuantity => 'Намаляване на количеството';

  @override
  String get increaseQuantity => 'Увеличаване на количеството';

  @override
  String get save => 'Запазване';

  @override
  String get nameRequired => 'Въведете името на виното';

  @override
  String get nameTooLong => 'Най-много 120 знака';

  @override
  String vintageRange(String year) {
    return 'Реколта между 1900 и $year';
  }

  @override
  String get offAttribution => 'Данни от Open Food Facts (ODbL)';

  @override
  String get dashboardTitle => 'Табло';

  @override
  String dashboardTotalBottles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count бутилки в избата',
      one: '1 бутилка в избата',
    );
    return '$_temp0';
  }

  @override
  String get dashboardSyncing => 'Избата се синхронизира…';

  @override
  String get dashboardAddFirstWine => 'Добавете първото си вино';

  @override
  String get drinkSoonTitle => 'За пиене скоро';

  @override
  String get drinkSoonEmpty => 'Няма бутилки за пиене скоро';

  @override
  String drinkSoonUntil(String year) {
    return 'до $year г.';
  }

  @override
  String drinkSoonSeeAll(int count) {
    return 'Вижте всички ($count)';
  }

  @override
  String get statusChartTitle => 'Състояние на бутилките';

  @override
  String get statusWaiting => 'за изчакване';

  @override
  String get statusReady => 'готови';

  @override
  String get statusDrinkSoon => 'за пиене скоро';

  @override
  String get statusPastWindow => 'след прозореца';

  @override
  String toEstimateNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count бутилки без прогноза',
      one: '1 бутилка без прогноза',
    );
    return '$_temp0';
  }

  @override
  String chartBarValue(String label, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count бутилки',
      one: '1 бутилка',
    );
    return '$label: $_temp0';
  }

  @override
  String chartDescription(String title, String values) {
    return '$title: $values';
  }

  @override
  String get openListHint => 'Отваряне на списъка';

  @override
  String get peakChartTitle => 'Година на върха';

  @override
  String get peakPast => 'отминал връх';

  @override
  String get peakBeyond => 'по-късно';

  @override
  String get breakdownTypeTitle => 'Бутилки по тип';

  @override
  String get breakdownRegionTitle => 'Бутилки по регион';

  @override
  String get breakdownType => 'Тип';

  @override
  String get breakdownRegion => 'Регион';

  @override
  String get familyRed => 'червено';

  @override
  String get familyWhite => 'бяло';

  @override
  String get familyRose => 'розе';

  @override
  String get familySparkling => 'пенливо';

  @override
  String get familySweet => 'сладко';

  @override
  String get breakdownUnspecified => 'без данни';

  @override
  String get breakdownOtherRegions => 'други';

  @override
  String get ok => 'OK';

  @override
  String get cellarMenu => 'Меню на избата';

  @override
  String get sharingPeopleTitle => 'Хора';

  @override
  String get sharingInviteTitle => 'Поканете човек';

  @override
  String get sharingEmailLabel => 'Имейл адрес в Google';

  @override
  String get sharingPermissionRead => 'Само преглед';

  @override
  String get sharingPermissionReadHint =>
      'Вижда вината, прогнозите, таблото и изпитите бутилки';

  @override
  String get sharingPermissionEdit => 'Може да редактира';

  @override
  String get sharingPermissionEditHint =>
      'Също добавя и променя вина и отбелязва изпити бутилки';

  @override
  String get sharingRoleOwner => 'собственик';

  @override
  String get sharingInviteButton => 'Покана';

  @override
  String sharingPlacesUsed(int used, int max) {
    return '$used/$max души';
  }

  @override
  String get sharingInvalidEmail => 'Въведете валиден имейл';

  @override
  String get sharingSelfInvite => 'Не можете да поканите себе си';

  @override
  String get sharingAlreadyInvited => 'Този човек вече е поканен';

  @override
  String sharingLimitReached(int max) {
    return 'Достигнахте лимита от $max души';
  }

  @override
  String get sharingNotOwner =>
      'Не можете да променяте споделянето на тази изба';

  @override
  String get sharingNotFound => 'Този човек вече не е в списъка';

  @override
  String get sharingFailed => 'Неуспешно, опитайте отново';

  @override
  String get sharingInviteFailed => 'Поканата не бе успешна. Опитайте отново';

  @override
  String get sharingOfflineHint =>
      'За управление на споделянето е нужна връзка';

  @override
  String get sharingStatusInvited => 'с покана';

  @override
  String get sharingStatusActive => 'с достъп';

  @override
  String get sharingStatusRevoked => 'отнет достъп';

  @override
  String get sharingStatusLeft => 'напусна';

  @override
  String sharingMemberSemantics(String name, String permission, String status) {
    return '$name, $permission, $status';
  }

  @override
  String get sharingClosedSection => 'Прекратен достъп';

  @override
  String get sharingNobody => 'Още никой друг не вижда тази изба';

  @override
  String sharingChangePermission(String name) {
    return 'Промяна на разрешението на $name';
  }

  @override
  String get sharingRevoke => 'Отнемане';

  @override
  String sharingRevokeTitle(String name) {
    return 'Да се отнеме ли достъпът на $name?';
  }

  @override
  String sharingRevokeConfirmLabel(String name) {
    return 'Въведете $name за потвърждение';
  }

  @override
  String get sharingRevokeDisabledHint => 'Активира се, когато името съвпадне';

  @override
  String get sharingReinvite => 'Нова покана';

  @override
  String get sharingDeleteForGood => 'Изтриване завинаги';

  @override
  String sharingOwnedBy(String owner) {
    return 'Избата на $owner';
  }

  @override
  String get sharingYourCellar => 'Вашата изба';

  @override
  String sharingYourPermission(String permission) {
    return 'Вашето разрешение: $permission';
  }

  @override
  String sharingSwitcherSemantics(String cellar, String permission) {
    return '$cellar, $permission. Докоснете, за да смените избата';
  }

  @override
  String get sharingLeave => 'Напускане на тази изба';

  @override
  String sharingLeaveTitle(String owner) {
    return 'Да напуснете ли избата на $owner?';
  }

  @override
  String sharingLeaveBody(String owner) {
    return 'Вече няма да я виждате. $owner може да ви покани отново.';
  }

  @override
  String get sharingLeaveConfirm => 'Напускане';

  @override
  String sharingSharedNotice(String owner) {
    return '$owner сподели избата си с вас';
  }

  @override
  String sharingAccessLost(String owner) {
    return 'Вече нямате достъп до избата на $owner';
  }

  @override
  String sharingWritesLost(String owner) {
    return 'Някои промени в избата на $owner не бяха запазени, защото вече нямате достъп';
  }

  @override
  String get sharingSomeone => 'някой';

  @override
  String get sharingShareSubject => 'Покана за Vinoozy';

  @override
  String sharingShareMessage(
    String owner,
    String cellar,
    String link,
    String email,
  ) {
    return '$owner ви кани в избата „$cellar“ във Vinoozy. Инсталирайте приложението от $link и влезте с акаунта в Google $email: използвайте точно този адрес.';
  }

  @override
  String get cellarSearchHint => 'Търсене по име или производител';

  @override
  String get cellarFilterStatus => 'Състояние';

  @override
  String get cellarFilterType => 'Тип';

  @override
  String get statusToEstimate => 'Без прогноза';

  @override
  String get filterTypeUnspecified => 'Без данни';

  @override
  String get cellarNoMatches => 'Няма вина с тези филтри';

  @override
  String get cellarClearFilters => 'Изчистване на филтрите';

  @override
  String get cellarArchiveTitle => 'Изпити';

  @override
  String get cellarArchiveEmpty => 'Все още няма свършили вина';

  @override
  String get cellarArchiveFailed => 'Свършилите вина не можаха да се заредят';

  @override
  String get wineDrink => 'Изпита';

  @override
  String wineDrinkTooltip(String name) {
    return 'Отбелязване на бутилка $name като изпита';
  }

  @override
  String confidenceLabel(String level) {
    return 'Сигурност: $level';
  }

  @override
  String get confidenceHigh => 'висока';

  @override
  String get confidenceMedium => 'средна';

  @override
  String get confidenceLow => 'ниска';

  @override
  String get windowStartLabel => 'Начало';

  @override
  String get windowPeakLabel => 'Връх';

  @override
  String get windowEndLabel => 'Край';

  @override
  String estimateSourceLabel(String source) {
    return 'Източник: $source';
  }

  @override
  String get estimateSourceCatalog => 'база данни за вина';

  @override
  String get estimateSourceType => 'прогноза по тип';

  @override
  String get estimateSourceCorrected =>
      'прогноза, коригирана според изпитите ви бутилки';

  @override
  String get estimateDisclaimer =>
      'Ориентировъчна прогноза: зависи и от това как е съхранявана бутилката';

  @override
  String get estimateUnavailable => 'Няма прогноза';

  @override
  String get pairingsTitle => 'Съчетания';

  @override
  String get pairingsGeneric => 'общи съчетания за типа';

  @override
  String get pairingBraisedRedMeat => 'Задушено червено месо';

  @override
  String get pairingGrilledRedMeat => 'Червено месо на скара';

  @override
  String get pairingGame => 'Дивеч';

  @override
  String get pairingRoastPoultry => 'Печено птиче месо';

  @override
  String get pairingPoultry => 'Птиче месо';

  @override
  String get pairingPork => 'Свинско';

  @override
  String get pairingCuredMeats => 'Колбаси';

  @override
  String get pairingPastaMeatSauce => 'Паста с месен сос';

  @override
  String get pairingMushroomsTruffle => 'Гъби и трюфели';

  @override
  String get pairingAgedCheese => 'Зрели сирена';

  @override
  String get pairingFreshCheese => 'Пресни сирена';

  @override
  String get pairingBlueCheese => 'Сини сирена';

  @override
  String get pairingFish => 'Риба';

  @override
  String get pairingSeafood => 'Морски дарове';

  @override
  String get pairingRawSeafood => 'Сурови морски дарове';

  @override
  String get pairingFriedFood => 'Пържени ястия';

  @override
  String get pairingVegetables => 'Зеленчуци';

  @override
  String get pairingRisotto => 'Ризото';

  @override
  String get pairingPizza => 'Пица';

  @override
  String get pairingAperitif => 'Аперитив';

  @override
  String get pairingPastries => 'Сладкиши';

  @override
  String get pairingDryBiscuits => 'Сухи бисквити';

  @override
  String get pairingChocolate => 'Шоколад';

  @override
  String get pairingDriedFruit => 'Ядки и сушени плодове';

  @override
  String get pairingSpicyDishes => 'Пикантни ястия';

  @override
  String get recentDrinksTitle => 'Последно изпити';

  @override
  String get noDrinksYet => 'Все още няма изпити бутилки';

  @override
  String get wineEdit => 'Редактиране';

  @override
  String get wineDelete => 'Изтриване';

  @override
  String get wineFinished => 'Свършило: няма бутилки';

  @override
  String get wineLoadFailed => 'Виното не можа да се отвори';

  @override
  String get wineNotFound => 'Това вино вече не съществува';

  @override
  String drinkDone(String name) {
    return 'Отбелязана като изпита: $name';
  }

  @override
  String get drinkUndo => 'Отмяна';

  @override
  String get drinkAddNotes => 'Добавяне на оценка и бележки';

  @override
  String get nothingToUndo => 'Няма какво повече да се отмени';

  @override
  String get cellarUndoRejected =>
      'Отмяната не бе успешна: бутилката остава отбелязана като изпита';

  @override
  String get cellarDeleteFailed =>
      'Изтриването още не е завършило: ще приключи при първа възможност';

  @override
  String get duplicateFull =>
      'Това вино вече има 99 бутилки: не могат да се добавят повече.';

  @override
  String get recordSheetTitle => 'Оценка и бележки';

  @override
  String get recordRatingLabel => 'Оценка';

  @override
  String ratingStar(int n) {
    return 'Оценка $n от 5';
  }

  @override
  String get recordNotesLabel => 'Бележки';

  @override
  String get recordNotesTooLong => 'Най-много 1000 знака';

  @override
  String recordDateLabel(String date) {
    return 'Дата: $date';
  }

  @override
  String get recordDateInvalid =>
      'Датата не може да е в бъдещето или преди реколтата';

  @override
  String get recordConditionTitle => 'Как беше?';

  @override
  String get conditionTooYoung => 'Още твърде младо';

  @override
  String get conditionJustRight => 'Точно навреме';

  @override
  String get conditionPastPeak => 'Вече след върха си';

  @override
  String get recordNoCondition => 'Без отговор';

  @override
  String get producerLabel => 'Производител (по избор)';

  @override
  String get producerTooLong => 'Най-много 120 знака';

  @override
  String producerAddNew(String name) {
    return 'Добавяне на „$name“ като нов производител';
  }

  @override
  String get wineTypeLabel => 'Тип';

  @override
  String get typeRedLight => 'Леко червено';

  @override
  String get typeRedStructured => 'Плътно червено';

  @override
  String get typeWhite => 'Бяло';

  @override
  String get typeRose => 'Розе';

  @override
  String get typeSparklingClassic => 'Пенливо, класически метод';

  @override
  String get typeSparklingTank => 'Пенливо, метод Шарма';

  @override
  String get typeSweet => 'Сладко';

  @override
  String get typeFortified => 'Подсилено';

  @override
  String get suggestionFromCellar => 'Във вашата изба';

  @override
  String get suggestionsLabel => 'Предложения';

  @override
  String get duplicateTitle => 'Вече е в избата';

  @override
  String duplicateBody(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count бутилки',
      one: '1 бутилка',
      zero: 'нито една бутилка',
    );
    return '$name вече е там с $_temp0. Да добавим ли новите бутилки към него?';
  }

  @override
  String duplicateAdd(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Добавяне на $count бутилки',
      one: 'Добавяне на 1 бутилка',
    );
    return '$_temp0';
  }

  @override
  String get duplicateBanner => 'Възможен дубликат';

  @override
  String get duplicateMerge => 'Обединяване';

  @override
  String get duplicateDeleteHint => 'Изтрийте този запис, ако е дубликат';

  @override
  String get mergeTitle => 'Да се обединят ли двата записа?';

  @override
  String get mergeBody =>
      'Бутилките от този запис се прехвърлят към по-стария, след което този запис се изтрива.';

  @override
  String get editWineTitle => 'Редактиране на вино';

  @override
  String get editDuplicate =>
      'Вече има друго вино със същото име, производител и реколта';

  @override
  String deleteWineTitle(String name) {
    return 'Изтриване на $name?';
  }

  @override
  String get deleteWineBody =>
      'Виното и всичките му изпити бутилки се изтриват. Това не може да се отмени.';

  @override
  String get historyTitle => 'История';

  @override
  String get historyEmpty => 'Тук ще намерите бутилките, които сте изпили';

  @override
  String get historyLoadFailed => 'Историята не можа да се зареди';

  @override
  String drankOnLabel(String date) {
    return 'Изпита на $date';
  }

  @override
  String get addChoiceTitle => 'Добавяне на вино';

  @override
  String get addChoicePhoto => 'Снимане';

  @override
  String get addChoiceImport => 'Импортиране на снимка';

  @override
  String get addChoiceWrite => 'Въвеждане';

  @override
  String get labelReading => 'Чета етикета…';

  @override
  String get labelRecognized => 'Разпознах:';

  @override
  String get labelCorrect => 'Поправка';

  @override
  String get labelConfirm => 'Потвърждаване';

  @override
  String get labelUnreadable => 'Не мога да прочета етикета';

  @override
  String get labelWriteByHand => 'Ръчно въвеждане';

  @override
  String get labelNotFound => 'Не намерих виното: проверете данните';

  @override
  String get labelCameraDenied =>
      'За да прочета етикета, ми трябва достъп до камерата';

  @override
  String get labelPhotosDenied =>
      'За да прочета етикета, ми трябва достъп до снимките';

  @override
  String get labelOpenSettings => 'Отваряне на настройките';

  @override
  String get labelCameraUnavailable => 'Камерата не е налична';

  @override
  String get labelBarcodeNotFound => 'Прочетох баркода, но не намирам виното';

  @override
  String get labelBarcodeFrontHint => 'Снимайте предния етикет';

  @override
  String get labelSharedNotAllowed => 'Не можете да добавяте вина в тази изба';

  @override
  String get labelSharedFirstOnly => 'Използвах само първата снимка';

  @override
  String get labelSharedExpired =>
      'Споделената снимка не можа да бъде прочетена: споделете я отново';

  @override
  String get labelReplaceTitle =>
      'Имате незапазено вино. Да прочета ли новата снимка?';

  @override
  String get labelReplaceRead => 'Прочитане на новата снимка';

  @override
  String get labelReplaceKeep => 'Продължаване с отвореното';

  @override
  String get labelWineAdded => 'Виното е добавено в избата';

  @override
  String get onboardingPage1Title => 'Избата ви в джоба';

  @override
  String get onboardingPage1Body =>
      'Добавяйте бутилките си, като ги въвеждате или снимате етикета – дори без мрежа.';

  @override
  String get onboardingPage2Title => 'В точния момент';

  @override
  String get onboardingPage2Body =>
      'Vinoozy прогнозира кога всяко вино е в най-добра форма и ви казва кои да отворите първи.';

  @override
  String get onboardingPage3Title => 'Заедно';

  @override
  String get onboardingPage3Body =>
      'Споделете избата си с до двама души и пазете история на всяка изпита бутилка.';

  @override
  String get onboardingSkip => 'Пропускане';

  @override
  String get onboardingNext => 'Напред';

  @override
  String get onboardingStart => 'Старт';

  @override
  String onboardingPageOf(int page) {
    return 'Страница $page от 3';
  }

  @override
  String get profileTitle => 'Профил';

  @override
  String get profilePhoto => 'Профилна снимка';

  @override
  String get profileSignOut => 'Изход';

  @override
  String get profileDeleteAccount => 'Изтриване на акаунта';

  @override
  String get profilePrivacy => 'Политика за поверителност';

  @override
  String get profilePrivacyBody =>
      'Можете да прочетете политиката за поверителност на този адрес:';

  @override
  String get profileOpenLink => 'Отваряне в браузъра';

  @override
  String get profileOpenLinkFailed =>
      'Страницата не можа да се отвори. Можете да копирате връзката и да я отворите в браузъра.';

  @override
  String get profileCopyLink => 'Копиране на връзката';

  @override
  String get profileLinkCopied => 'Връзката е копирана';

  @override
  String get close => 'Затваряне';

  @override
  String get signOutConfirmTitle => 'Искате ли да излезете?';

  @override
  String signOutPendingWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Имате $count промени, които още не са запазени. Ако излезете и влезе друг акаунт, те ще бъдат загубени.',
      one: 'Имате 1 промяна, която още не е запазена. Ако излезете и влезе друг акаунт, тя ще бъде загубена.',
    );
    return '$_temp0';
  }

  @override
  String get signOutStayAndSync => 'Оставане и синхронизиране';

  @override
  String get signOutAnyway => 'Изход въпреки това';

  @override
  String get syncAllSaved => 'Всичко е запазено';

  @override
  String syncStillPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Остават $count промени за запазване: проверете мрежата',
      one: 'Остава 1 промяна за запазване: проверете мрежата',
    );
    return '$_temp0';
  }

  @override
  String get signOutFailed => 'Излизането не бе успешно. Опитайте отново';

  @override
  String get signInAccountDeleted => 'Акаунтът е изтрит';

  @override
  String get deleteAccountIntro => 'Завинаги се изтриват:';

  @override
  String get deleteAccountItemCellar => 'Вашата изба с вината и историята';

  @override
  String get deleteAccountItemShares =>
      'Споделянията, които сте дали: поканените хора губят достъп';

  @override
  String get deleteAccountItemMemberships =>
      'Участието ви в чужди изби: изпитите от вас бутилки остават там без името ви';

  @override
  String get deleteAccountItemProfile => 'Вашият профил';

  @override
  String deleteAccountPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Имате $count промени, които още не са запазени: те ще бъдат запазени и после изтрити с останалото',
      one: 'Имате 1 промяна, която още не е запазена: тя ще бъде запазена и после изтрита с останалото',
    );
    return '$_temp0';
  }

  @override
  String get deleteAccountConfirmWord => 'ИЗТРИВАНЕ';

  @override
  String deleteAccountTypeWord(String word) {
    return 'Въведете $word за потвърждение';
  }

  @override
  String get deleteAccountReauthHint =>
      'След това ще влезете отново с Google, за да потвърдите, че сте вие.';

  @override
  String get deleteAccountForever => 'Изтриване завинаги';

  @override
  String get deleteAccountNeedsNetwork =>
      'Свържете се с интернет, за да изтриете акаунта';

  @override
  String get deleteAccountSameAccount =>
      'За изтриването трябва да влезете със същия акаунт';

  @override
  String get deletionTitle => 'Изтриване на акаунта';

  @override
  String get deletionStepPreparePhone => 'Запазване на чакащите промени';

  @override
  String get deletionStepMarkStarted => 'Започване на изтриването';

  @override
  String get deletionStepLeaveOtherCellars => 'Напускане на чуждите изби';

  @override
  String get deletionStepCloseOwnInvitations =>
      'Прекратяване на вашите споделяния';

  @override
  String get deletionStepDeleteWinesAndRecords =>
      'Изтриване на вината и историята';

  @override
  String get deletionStepDeleteCellar => 'Изтриване на избата';

  @override
  String get deletionStepDeleteProfileAndUser =>
      'Изтриване на профила и акаунта';

  @override
  String get deletionStepCleanUpPhone => 'Почистване на този телефон';

  @override
  String deletionStepAnnounce(int step, String label) {
    return 'Стъпка $step от 8: $label';
  }

  @override
  String deletionDeletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Изтрити са $count вина и изпити бутилки',
      one: 'Изтрито е 1 вино или изпита бутилка',
    );
    return '$_temp0';
  }

  @override
  String get deletionResumeHint =>
      'Изтриването на този акаунт не е завършило. Влезте отново с Google, за да го довършите.';

  @override
  String get deletionContinue => 'Продължаване';

  @override
  String get deletionOffline =>
      'Свържете се с интернет, за да завършите изтриването';

  @override
  String get deletionPendingWrites =>
      'Не мога да запазя чакащите промени. Опитайте отново';

  @override
  String get deletionFailed =>
      'Изтриването не можа да завърши. Опитайте отново';

  @override
  String get uxCountryLabel => 'Държава';

  @override
  String get uxCountryOther => 'Друга държава…';

  @override
  String get uxCountryNone => 'Без държава';

  @override
  String get uxAllCountriesTitle => 'Всички държави и територии';

  @override
  String get uxAllCountriesSearch => 'Търсене на държава';

  @override
  String get uxAllCountriesRare => 'Редки за виното';

  @override
  String get uxAllCountriesAll => 'Всички, от А до Я';

  @override
  String get uxAllCountriesNone => 'Няма намерена държава';

  @override
  String get uxRegionLabel => 'Регион';

  @override
  String uxRegionOf(String country) {
    return 'Регион · $country';
  }

  @override
  String get uxRegionOther => 'Друг регион';

  @override
  String get uxRegionFieldLabel => 'Въведете региона';

  @override
  String get uxRegionTooLong => 'Най-много 120 знака';

  @override
  String get uxDrinkAction => 'Изпих една';

  @override
  String uxDrinkActionTooltip(String name) {
    return 'Изпих бутилка $name';
  }

  @override
  String get uxDrinkActionDetail => 'Изпих бутилка';

  @override
  String get uxDrinkSheetLabel => 'Потвърждаване на изпитата бутилка';

  @override
  String get uxDrinkSheetBottles => 'Бутилки';

  @override
  String uxDrinkSheetBottlesChange(int before, int after) {
    return 'Бутилки: от $before на $after';
  }

  @override
  String get uxDrinkSheetRating => 'Как беше? (по избор)';

  @override
  String uxDrinkSheetStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count звезди от 5',
      one: '1 звезда от 5',
    );
    return '$_temp0';
  }

  @override
  String get uxDrinkSheetConfirm => 'Да, изпих я';

  @override
  String get uxRemoveBottle => 'Премахване на бутилка, без да е изпита';

  @override
  String get uxRemoveBottleTitle => 'Да се премахне ли бутилка?';

  @override
  String uxRemoveBottleBody(String name) {
    return 'Една бутилка $name се премахва, без да се отбелязва като изпита.';
  }

  @override
  String get uxRemoveBottleConfirm => 'Премахване';

  @override
  String get uxIdealTitle => 'Идеален момент';

  @override
  String uxIdealUntil(String year) {
    return 'Препоръчително до $year г.';
  }

  @override
  String uxIdealUntilPast(String year) {
    return 'Препоръчително до $year г.: вече е отминало';
  }

  @override
  String uxIdealBest(String start, String end) {
    return 'В най-добра форма от $start до $end г.';
  }

  @override
  String uxIdealBar(String start, String end) {
    return 'Прозорец за консумация от $start до $end г.';
  }

  @override
  String get uxIdealDisclaimer =>
      '⚠︎ Ориентировъчно: прогноза според типа, апелацията и реколтата. Съхранението и конкретната бутилка могат да я променят.';

  @override
  String get uxIdealUnavailableHint =>
      'Добавете реколтата и типа, за да получите прогноза.';

  @override
  String uxDashboardDrinkNow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count за пиене сега',
      one: '1 за пиене сега',
    );
    return '$_temp0';
  }

  @override
  String get uxFamilyRed => 'Червено';

  @override
  String get uxFamilyWhite => 'Бяло';

  @override
  String get uxFamilyRose => 'Розе';

  @override
  String get uxFamilySparkling => 'Пенливо';

  @override
  String get uxFamilySweet => 'Сладко';

  @override
  String get labelBackTitle => 'Сега гърбът';

  @override
  String get labelBackHint =>
      'На гърба обикновено са баркодът, производителят и реколтата: те помагат да се намери виното.';

  @override
  String get labelBackTake => 'Снимане на гърба';

  @override
  String get labelBackGallery => 'Избор от галерията';

  @override
  String get labelBackSkip => 'Пропускане';

  @override
  String get labelStepFront => 'Лице';

  @override
  String get labelStepBack => 'Гръб';

  @override
  String get labelStepBarcode => 'Баркод';

  @override
  String get labelStepDatabase => 'База данни за вина в телефона';

  @override
  String get labelStepPending => 'Изчаква';

  @override
  String get labelStepRunning => 'В ход…';

  @override
  String get labelStepDone => 'Готово';

  @override
  String get labelStepSkipped => 'Пропуснато';

  @override
  String get labelStepFailed => 'Не се чете';

  @override
  String labelStepStatus(String step, String status) {
    return '$step: $status';
  }

  @override
  String get labelOnPhoneNote =>
      'Всичко става в телефона: снимките не се изпращат на никого.';

  @override
  String get labelBackUnreadable => 'Гърбът не се чете';

  @override
  String get labelSourceOffline => 'От базата в телефона · офлайн';

  @override
  String get labelSourceCatalog => 'От каталога';

  @override
  String get labelSourceOnline => 'От Open Food Facts · онлайн';

  @override
  String get labelNotThis => 'Не е това';

  @override
  String get labelOffAttribution => 'Данни от Open Food Facts, лиценз ODbL';

  @override
  String get labelCandidatesTitle => 'Кое от тези?';

  @override
  String labelCandidatesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count подобни вина',
      one: '1 подобно вино',
    );
    return '$_temp0';
  }

  @override
  String get labelCandidatesNone => 'Нито едно от тези';

  @override
  String get labelChipOffline => 'офлайн';

  @override
  String get labelChipOnline => 'онлайн';

  @override
  String get labelChipCatalog => 'каталог';

  @override
  String get labelNoProducer => 'без посочен производител';

  @override
  String get labelNoMatch => 'Прочетох етикета, но не разпознавам виното';

  @override
  String get labelReadText => 'Прочетен текст';

  @override
  String get labelSearchOnline => 'Търсене онлайн';

  @override
  String get labelOpenLens => 'Отваряне в Google Lens';

  @override
  String get labelLensLastResort =>
      'Google Lens е последната възможност: снимката отива в приложението Google само ако потвърдите.';

  @override
  String get labelLensTitle => 'Да се отвори ли в Google Lens?';

  @override
  String get labelLensBody =>
      'Снимката на лицето ще бъде предадена на приложението Google в телефона ви или на избраното от вас приложение, което може да запази копие според собствените си правила. Vinoozy не получава резултатите: върнете се тук, за да изберете или въведете виното.';

  @override
  String get labelLensConfirm => 'Отваряне на Google Lens';

  @override
  String get labelLensFailed =>
      'Не мога да отворя Google Lens, нито менюто за споделяне';

  @override
  String get onlineSearchTitle => 'Търсене онлайн';

  @override
  String get onlineSearchSubtitle => 'Open Food Facts · само вина';

  @override
  String get onlineSearchField => 'Думи за търсене';

  @override
  String get onlineSearchHint => 'Можете да промените думите преди търсенето.';

  @override
  String get onlineSearchEmptyField => 'Въведете поне една дума';

  @override
  String get onlineSearchButton => 'Търсене';

  @override
  String get onlineSearchLoading => 'Търся…';

  @override
  String onlineSearchResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count резултата',
      one: '1 резултат',
    );
    return '$_temp0';
  }

  @override
  String get onlineSearchEmpty =>
      'Няма намерено вино: опитайте с други думи или с „Ръчно въвеждане“.';

  @override
  String get onlineSearchOffline =>
      'Няма мрежа: търся само в базата в телефона.';

  @override
  String get onlineSearchRateLimited =>
      'Търсенето онлайн не е достъпно в момента, опитайте отново след няколко минути.';

  @override
  String get onlineSearchUnavailable =>
      'Търсенето онлайн не е активно в тази версия на приложението: търся само в базата в телефона.';

  @override
  String get aboutTitle => 'За приложението';

  @override
  String aboutVersion(String version) {
    return 'Версия $version';
  }

  @override
  String get aboutDbTitle => 'База данни за вина';

  @override
  String aboutDbCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count вина',
      one: '1 вино',
    );
    return '$_temp0';
  }

  @override
  String aboutDbDate(String date) {
    return 'Експорт от Open Food Facts от $date';
  }

  @override
  String get aboutDbSample =>
      'Примерна база: няколко ръчно въведени тестови вина, а не данни от Open Food Facts.';

  @override
  String get aboutDbLoading => 'Отварям базата данни за вина…';

  @override
  String get aboutDbUnavailable =>
      'Базата данни за вина не е налична в тази версия';

  @override
  String aboutDbSource(String url) {
    return 'Производната база и инструментът, който я създава, са в публичното хранилище: $url';
  }

  @override
  String get aboutLicenseTitle => 'Лицензи';

  @override
  String get aboutLicense =>
      'Съдържа информация от Open Food Facts, предоставена съгласно Open Database License (ODbL). Отделните съдържания са под Database Contents License (DbCL).';

  @override
  String get aboutPrivacyTitle => 'Снимки на етикети';

  @override
  String get aboutPrivacy =>
      'Снимките на етикети се четат в телефона и се изтриват, когато напуснете резултата. Те напускат телефона само ако докоснете „Отваряне в Google Lens“ и потвърдите.';

  @override
  String get aboutAppellationsTitle => 'Апелации';

  @override
  String get aboutAppellationsSource =>
      'Апелации: регистър eAmbrosia (ЕС) и официални национални регистри.';

  @override
  String get aboutAppellationsSample =>
      'Примерна таблица: ръчно въведена извадка от регистрите, докато не бъдат изтеглени истинските регистри.';

  @override
  String get denominationLabel => 'Апелация';

  @override
  String get denominationTooLong => 'Най-много 120 знака';

  @override
  String get autofillFilledNotice =>
      'Попълнено от етикета: проверете и запазете';

  @override
  String get autofillPastedNotice =>
      'Попълнено от текста: проверете и запазете';

  @override
  String get autofillFromText => '✦ от текста';

  @override
  String get autofillFromTextSemantics => 'попълнено от етикета';

  @override
  String get autofillClear => 'Изчистване';

  @override
  String get autofillLens => 'Lens';

  @override
  String get autofillClearTitle => 'Да се изчисти ли формулярът?';

  @override
  String get autofillClearBody =>
      'Вие също сте писали в някои полета. „Изчистване“ изпразва име, производител, апелация, реколта, тип, държава, регион и ниво. Количеството остава.';

  @override
  String get autofillClearConfirm => 'Изчистване';

  @override
  String get autofillCleared => 'Формулярът е изчистен';

  @override
  String get autofillPasteTitle => 'Имате ли текста от Google Lens?';

  @override
  String get autofillPasteHint =>
      'В Lens изберете текста на етикета и докоснете „Копиране“, после се върнете тук.';

  @override
  String get autofillPaste => 'Поставяне от Lens';

  @override
  String get autofillOpenLens => 'От Google Lens';

  @override
  String get autofillOpenLensSemantics => 'отваря Google Lens';

  @override
  String get autofillClipboardEmpty => 'В клипборда няма текст';

  @override
  String get autofillNoNewFields => 'Не намерих в текста данни за добавяне';

  @override
  String get autofillFromLens => 'Формулярът е попълнен от текста от Lens';

  @override
  String get autofillShareEmpty => 'Не е получен текст';

  @override
  String get autofillShareUseTitle =>
      'Да се използва ли текстът за празните полета?';

  @override
  String get autofillShareUse => 'Използване';

  @override
  String get autofillShareIgnore => 'Пренебрегване';

  @override
  String get addChoiceLens => 'От Google Lens';

  @override
  String get addChoicePhotoHint => 'Лице и гръб: Vinoozy чете етикета.';

  @override
  String get addChoiceLensHint =>
      'Отваря Lens: насочете, изберете текста и докоснете „Споделяне“ → Vinoozy.';

  @override
  String get addChoiceImportHint => 'Вече направена снимка на етикета.';

  @override
  String get addChoiceWriteHint => 'Празен формуляр с „Поставяне от Lens“.';

  @override
  String get lensInstructionsTitle => 'Google Lens не може да се отвори оттук';

  @override
  String get lensInstructionsStep1 =>
      'Отворете Google Lens и насочете към етикета';

  @override
  String get lensInstructionsStep2 => 'Изберете текста на етикета';

  @override
  String get lensInstructionsStep3 => 'Докоснете „Споделяне“ → Vinoozy';

  @override
  String get lensInstructionsOk => 'Разбрах';

  @override
  String get levelLabel => 'Ниво';

  @override
  String get levelEveryday => 'Ежедневно (евтино)';

  @override
  String get levelGood => 'Добро';

  @override
  String get levelAging => 'За отлежаване';

  @override
  String get levelNone => 'Няма';

  @override
  String get levelEverydayShort => 'за пиене рано';

  @override
  String get levelGoodShort => 'нормална прогноза';

  @override
  String get levelAgingShort => 'издържа по-дълго';

  @override
  String get levelSuggested => 'предложено';

  @override
  String levelSuggestedReason(String qualifier) {
    return 'Предложено, защото името съдържа „$qualifier“: ще се запази така, ако не го промените. Изберете друго или докоснете „Няма“.';
  }

  @override
  String levelSuggestedSemantics(String qualifier) {
    return 'предложено, защото името съдържа $qualifier';
  }

  @override
  String levelOptionSemantics(String option, int index, int count) {
    return 'Ниво, $option, $index от $count';
  }

  @override
  String get levelWhatChanges => 'Какво се променя';

  @override
  String get levelEverydayExamples =>
      'Прозорецът се скъсява. Напр. наливно вино, Lambrusco, обикновено Prosecco, Bardolino, Vinho Verde.';

  @override
  String get levelGoodExamples =>
      'Нормалната прогноза и стойността, когато не изберете нищо. Напр. Chianti Classico, Barbera d\'Asti Superiore, Rioja Crianza, Côtes du Rhône.';

  @override
  String get levelAgingExamples =>
      'Прозорецът се удължава. Напр. Barolo, Brunello, Amarone, Bordeaux Grand Cru, Rioja Gran Reserva, Porto Vintage.';

  @override
  String levelPreviewBefore(String start, String end) {
    return 'Преди $start – $end';
  }

  @override
  String levelPreviewWith(String level, String start, String end) {
    return 'С „$level“ $start – $end';
  }

  @override
  String levelPreviewNow(String start, String end) {
    return 'Готово $start – до $end';
  }

  @override
  String levelDetail(String level) {
    return 'Ниво: $level';
  }

  @override
  String get overrideCorrect => 'Поправка';

  @override
  String get overrideRestore => 'Възстановяване на прогнозата';

  @override
  String get overrideCorrectedByYou => 'ваша корекция';

  @override
  String overrideAppEstimate(String year) {
    return 'Прогноза на приложението: до $year г.';
  }

  @override
  String get overrideSheetTitle => 'Препоръчително до';

  @override
  String overrideSheetHint(String start) {
    return 'Изберете годината. Не може да е преди „Готово от $start“.';
  }

  @override
  String overridePeakNotice(String peak) {
    return 'Ако изберете година преди $peak (в най-добра форма), „в най-добра форма“ също се премества на същата година.';
  }

  @override
  String get overrideMore => 'още…';

  @override
  String get overrideSave => 'Запазване на корекцията';

  @override
  String overrideRestoreTitle(String year) {
    return 'Връщане към прогнозата на приложението (до $year г.)?';
  }

  @override
  String get overrideRestoreConfirm => 'Възстановяване';

  @override
  String get overrideSaved => 'Корекцията е запазена';

  @override
  String get overrideRestored => 'Прогнозата е възстановена';

  @override
  String get estimateSourceCorrectedByYou => 'ваша корекция';

  @override
  String estimateFromDenomination(String name) {
    return 'Прогноза според апелацията $name';
  }

  @override
  String estimateFromDenominationQualifier(String name, String qualifier) {
    return 'Прогноза според апелацията $name, $qualifier';
  }

  @override
  String estimateFromGrape(String name) {
    return 'Прогноза според сорта $name';
  }

  @override
  String get estimateFromType => 'Прогноза според типа вино';

  @override
  String get autofillReading => 'Чета текста…';

  @override
  String get guideChip => 'Насочена проверка';

  @override
  String guideProgress(int n, int total) {
    return 'Въпрос $n от $total';
  }

  @override
  String get guideClose => 'Затваряне';

  @override
  String get guideIsDenomination => 'това апелацията ли е?';

  @override
  String get guideIsProducer => 'това производителят ли е?';

  @override
  String get guideIsName => 'това името на виното ли е?';

  @override
  String get guideIsVintage => 'Реколта';

  @override
  String guideAskDenomination(String value) {
    return '$value апелацията ли е?';
  }

  @override
  String guideAskProducer(String value) {
    return '$value производителят ли е?';
  }

  @override
  String guideAskName(String value) {
    return '$value името на виното ли е?';
  }

  @override
  String get guideAskVintage => 'Коя е реколтата?';

  @override
  String guideQuestionSemantics(int n, int total, String question) {
    return 'Въпрос $n от $total: $question';
  }

  @override
  String get guideNoProposal => 'Не го намерих в текста';

  @override
  String get guideYes => 'Да';

  @override
  String get guideNo => 'Не, друго';

  @override
  String get guideEdit => 'Редактиране';

  @override
  String get guideSkip => 'Пропускане';

  @override
  String get guideConfirm => 'Потвърждаване';

  @override
  String get guideCancel => 'Отказ';

  @override
  String guideRejected(String value) {
    return 'Не е „$value“: ето следващото';
  }

  @override
  String get guideNoMore =>
      'Няма други предложения: съставете го или пропуснете';

  @override
  String guideProposalAnnounce(String value) {
    return 'Предложение: $value';
  }

  @override
  String get guideComposeLabel =>
      'Или го съставете, като докосвате думи от текста';

  @override
  String get guideComposePreview => 'Преглед';

  @override
  String get guideComposeEmpty => 'Докоснете една или повече думи';

  @override
  String get guideComposeLimit => 'До 8 думи и 80 знака';

  @override
  String guideTableMatchSemantics(String name) {
    return 'съвпада с $name';
  }

  @override
  String guideLine(int n, int total) {
    return 'Ред $n от $total';
  }

  @override
  String guideWordSelected(String word, int order) {
    return '$word, избрана, $order';
  }

  @override
  String guideWordUnavailable(String word) {
    return '$word, недостъпна';
  }

  @override
  String guideWordUsedFor(String word, String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'апелацията',
      'producer': 'производителя',
      'other': 'името',
    });
    return '$word, използвана за $_temp0';
  }

  @override
  String guideUsedMark(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'апелация',
      'producer': 'производител',
      'other': 'име',
    });
    return '$_temp0';
  }

  @override
  String guideOtherYears(String years) {
    return 'В текста има още: $years';
  }

  @override
  String get guideWheelFromText => 'година, намерена в текста';

  @override
  String get guideWheelTypeYear => 'Въведете годината';

  @override
  String guideWheelConfirm(String year) {
    return 'Потвърждаване на $year';
  }

  @override
  String get guideNoVintage => 'Без реколта';

  @override
  String guideSkippedNotice(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'Апелацията е пропусната',
      'producer': 'Производителят е пропуснат',
      'vintage': 'Реколтата е пропусната',
      'other': 'Името е пропуснато',
    });
    return '$_temp0: въведете ръчно или продължете проверката';
  }

  @override
  String guideSkippedMany(int count) {
    return 'Пропуснати полета: $count. Въведете ги ръчно или продължете проверката';
  }

  @override
  String get guideInvalidValue =>
      'Този текст съдържа знаци, които не могат да бъдат запазени';

  @override
  String get brandStudio => 'Bottazzini Softworks';

  @override
  String get suggestedMark => '✦ предложено';

  @override
  String suggestedSemantics(String field, String value) {
    return '$field, $value, предложено';
  }

  @override
  String get restoreSuggestion => 'Възстановяване на предложението';

  @override
  String get restoreSuggestionDone => 'Предложението е възстановено';

  @override
  String get styleLabel => 'Стил';

  @override
  String styleGroupSemantics(String value, int index, int count) {
    return 'Стил, $value, $index от $count';
  }

  @override
  String get styleRedFresh => 'Свежо';

  @override
  String get styleRedMedium => 'Средно';

  @override
  String get styleRedAge => 'За отлежаване';

  @override
  String get styleRedLong => 'Дълго отлежаване';

  @override
  String get styleWhiteFresh => 'Свежо';

  @override
  String get styleWhiteMedium => 'Средно';

  @override
  String get styleWhiteAge => 'За отлежаване';

  @override
  String get styleRoseFresh => 'Свежо';

  @override
  String get styleClassicFresh => 'Свежо';

  @override
  String get styleClassicAge => 'За отлежаване';

  @override
  String get styleTankFresh => 'Свежо';

  @override
  String get styleLambrusco => 'Lambrusco';

  @override
  String get styleSweetAromatic => 'Ароматно';

  @override
  String get styleSweetPassito => 'Passito';

  @override
  String get styleSweetBotrytis => 'Ботритизирано';

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
  String get styleFortifiedOther => 'Друго';

  @override
  String get profileNameRFresh => 'Плодово червено';

  @override
  String get profileNameRMedium => 'Средно плътно червено';

  @override
  String get profileNameRAge => 'Червено за отлежаване';

  @override
  String get profileNameRLong => 'Червено за дълго отлежаване';

  @override
  String get profileNameWFresh => 'Свежо ароматно бяло';

  @override
  String get profileNameWMedium => 'Средно плътно бяло';

  @override
  String get profileNameWAge => 'Бяло за отлежаване';

  @override
  String get profileNameRoseFresh => 'Свежо розе';

  @override
  String get profileNameSpTank => 'Свежо пенливо, метод Шарма';

  @override
  String get profileNameLamFresh => 'Свежо Lambrusco';

  @override
  String get profileNameSpClassic => 'Свежо пенливо, класически метод';

  @override
  String get profileNameSpClassicAge =>
      'Пенливо за отлежаване, класически метод';

  @override
  String get profileNameSwAromatic => 'Младо ароматно сладко вино';

  @override
  String get profileNameSwPassito => 'Сладко вино от стафидирано грозде';

  @override
  String get profileNameSwBotrytis => 'Ботритизирано сладко вино';

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
  String get profileNameFortUnknown => 'Подсилено, неизвестен стил';

  @override
  String get profileNameUnknown => 'Неразпознат стил';

  @override
  String estimateFromProfile(String profile, String denomination) {
    return 'Прогноза според профила „$profile“ ($denomination)';
  }

  @override
  String estimateFromProfileType(String profile) {
    return 'Прогноза според профила „$profile“, по тип';
  }

  @override
  String estimateFromProfileGrape(String profile, String grape) {
    return 'Прогноза според профила „$profile“, по сорта $grape';
  }

  @override
  String get estimateFromEntryDateDisgorgement =>
      'По датата на добавяне: добавете датата на дегоржиране за по-добра прогноза';

  @override
  String get estimateFromEntryDateBottling =>
      'По датата на добавяне: добавете датата на бутилиране за по-добра прогноза';

  @override
  String get styleToConfirmBanner =>
      '⚠︎ Стилът е за потвърждение: прогнозата е ориентировъчна';

  @override
  String get chooseTypePrompt => 'Изберете типа';

  @override
  String estimateUpdatedAnnouncement(String summary) {
    return 'Прогнозата е обновена: $summary';
  }

  @override
  String get agingStartDisgorgement => 'Дегоржиране';

  @override
  String get agingStartBottling => 'Бутилиране';

  @override
  String get agingStartMonth => 'Месец';

  @override
  String get agingStartYear => 'Година';

  @override
  String get agingStartHint => 'Обикновено е на задния етикет.';

  @override
  String get agingStartIncomplete => 'Въведете месец и година';

  @override
  String get agingStartFuture => 'Датата не може да е в бъдещето';

  @override
  String get agingStartBeforeVintage => 'Не може да е преди реколтата';

  @override
  String get windowNoEnd => 'Готово, без прогнозиран край';

  @override
  String get windowNoEndShort => 'без прогнозиран край';

  @override
  String windowDrinkWithin(String date) {
    return 'до $date';
  }

  @override
  String get levelNoEffect => 'Нивото не променя тази прогноза';

  @override
  String get dashboardToConfirmTitle => 'За потвърждение';

  @override
  String dashboardToConfirmCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count вина',
      one: '1 вино',
    );
    return '$_temp0';
  }

  @override
  String aboutDbClassified(String percent) {
    return '$percent% от вината са с разпознат тип';
  }

  @override
  String get planTitle => 'План';

  @override
  String get planFree => 'Безплатен';

  @override
  String get planPlus => 'Plus';

  @override
  String get planPlusGift => 'Plus (подарък)';

  @override
  String get planDevUnlockAll => 'DEV · Тестов Plus';

  @override
  String get planDevSimulateFree => 'DEV · Симулиран безплатен план';

  @override
  String get planDevSimulateExpired => 'DEV · Симулиран изтекъл Plus';

  @override
  String get planDiscoverPlus => 'Открийте Plus';

  @override
  String get plusTitle => 'Vinoozy Plus';

  @override
  String get plusBenefitsTitle => 'С Plus';

  @override
  String get plusBenefitNoAds => 'Без реклами';

  @override
  String get plusBenefitNoLimit => 'Без лимит за вината в избата';

  @override
  String get plusComingSoon => 'Plus идва скоро';

  @override
  String get plusLoading => 'Четене на цените от Google Play';

  @override
  String get plusStoreUnavailable =>
      'Цените от Google Play не можаха да бъдат прочетени. Опитайте отново по-късно.';

  @override
  String plusPriceMonthly(String price) {
    return '$price на месец';
  }

  @override
  String plusPriceAnnual(String price) {
    return '$price на година';
  }

  @override
  String get plusRenewal =>
      'Абонаментът се подновява автоматично на посочената цена, докато не го анулирате в Google Play.';

  @override
  String get plusTerms =>
      'Плащането се начислява в акаунта ви в Google Play, когато потвърдите покупката. Можете да анулирате по всяко време: Plus остава активен до края на вече платения период. Когато Plus приключи, всичките ви вина остават.';

  @override
  String get plusRestore => 'Възстановяване на покупките';

  @override
  String get plusManage =>
      'Управление или анулиране на абонамента в Google Play';

  @override
  String get plusActive => 'Plus е активен в този акаунт';

  @override
  String get plusActiveGift =>
      'Имате Plus като подарък: без такси и без подновяване.';

  @override
  String get plusPending =>
      'Плащането се изчаква: Plus ще се активира, когато Google Play го потвърди.';

  @override
  String get plusVerifying => 'Покупката се проверява';

  @override
  String get plusVerified =>
      'Покупката е потвърдена: Plus ще се активира след няколко секунди.';

  @override
  String get plusPurchaseFailed =>
      'Покупката не бе завършена. Опитайте отново.';

  @override
  String get plusInvalidPurchase =>
      'Google Play не потвърди тази покупка за Vinoozy.';

  @override
  String get plusOwnedByOther =>
      'Този абонамент вече принадлежи на друг акаунт във Vinoozy.';

  @override
  String get plusVerificationUnavailable =>
      'Покупката не можа да бъде проверена сега. Опитайте отново по-късно: абонаментът остава в Google Play.';

  @override
  String get capacityLimitTitle => 'Достигнахте лимита на безплатния план';

  @override
  String capacityLimitBody(int limit) {
    return 'Безплатният план включва до $limit различни вина в избата. Винаги можете да редактирате, да пиете и да добавяте бутилки към вината, които вече имате. За да добавите ново, довършете или изтрийте някое вино или преминете към Plus.';
  }

  @override
  String capacityLimitBodyComingSoon(int limit) {
    return 'Безплатният план включва до $limit различни вина в избата. Винаги можете да редактирате, да пиете и да добавяте бутилки към вината, които вече имате. За да добавите ново, довършете или изтрийте някое вино. Plus идва скоро.';
  }

  @override
  String get rejectedCapacityLimit =>
      'Не е синхронизирано: надхвърля лимита за вина на безплатния план. Промяната остава на този телефон.';

  @override
  String get rejectedCapacityConflict =>
      'Не е синхронизирано: избата е била променена по същото време на друго устройство. Промяната остава на този телефон: опитайте отново.';

  @override
  String writeRejectedCapacityLimit(String name) {
    return '$name: не е синхронизирано, надхвърля лимита на безплатния план';
  }

  @override
  String writeRejectedCapacityConflict(String name) {
    return '$name: не е синхронизирано, избата е променена на друго устройство';
  }

  @override
  String get freeIntroTitle => 'Безплатният план';

  @override
  String freeIntroLimit(int limit) {
    return 'Можете да управлявате безплатно до $limit различни вина.';
  }

  @override
  String get freeIntroAds =>
      'При леко използване няма реклами. Ако надхвърлите месечния праг за използване на услугата, може от време на време да виждате реклами, които помагат за покриване на разходите за сървъри и синхронизиране.';

  @override
  String get freeIntroNoAds => 'Без реклами във версията при старта.';

  @override
  String get freeIntroPlus => 'С Plus премахвате рекламите и лимита на избата.';

  @override
  String get noticeGotIt => 'Разбрах';

  @override
  String get thresholdTitle => 'Рекламите помагат Vinoozy да остане безплатен';

  @override
  String get thresholdBody =>
      'Достигнахте месечния праг за използване без реклами. Отсега може от време на време да виждате реклами: те ни помагат да покриваме разходите за сървъри и синхронизиране, така че Vinoozy да остане безплатен.';

  @override
  String get thresholdReset =>
      'Броенето започва отново следващия месец. С Plus можете да използвате приложението без реклами и без лимита на избата.';

  @override
  String thresholdNextReset(String date) {
    return 'Следващо нулиране: $date';
  }

  @override
  String get thresholdHowItWorks => 'Как работи';

  @override
  String get thresholdHowItWorksBody =>
      'Прагът зависи от приблизителна оценка на синхронизиранията с облака, направени от този акаунт през месеца. Използването офлайн само по себе си не създава нови операции в облака. Рекламите се показват най-много веднъж дневно, само в таблото, и никога докато запазвате или експортирате данните си.';

  @override
  String get adLabel => 'Реклама';

  @override
  String get devToolsTitle => 'Инструменти за разработчици';

  @override
  String get devUnlockAll => 'Отключване на всичко — тестов Plus';

  @override
  String get devSimulateFree => 'Симулиране на безплатен план';

  @override
  String get devSimulateExpired => 'Симулиране на изтекъл Plus';

  @override
  String get devRestore => 'Възстановяване на нормалното състояние';

  @override
  String get devNoOverride => 'Няма активна симулация';

  @override
  String get devApplied => 'Сценарият е приложен и в емулатора на Firestore';

  @override
  String get devIncomplete =>
      'Непълна симулация: емулаторът на Firestore не потвърди тестовото право. Правилата на сървъра не виждат този сценарий.';

  @override
  String get devNotice =>
      'Само за версии за разработка с емулатора: без плащания, токени или разписки.';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsGuide => 'Вижте ръководството отново';

  @override
  String get settingsShare => 'Споделяне на приложението';

  @override
  String get settingsRate => 'Оценка на приложението';

  @override
  String get settingsFeedback => 'Изпращане на отзив';

  @override
  String get settingsFaq => 'Често задавани въпроси';

  @override
  String get settingsShareFailed =>
      'Споделянето не можа да се отвори. Опитайте отново';

  @override
  String get settingsRateFailed =>
      'Google Play не можа да се отвори. Опитайте отново';

  @override
  String get guideAddTitle => 'Добавете вино';

  @override
  String get guideAddBody =>
      'Докоснете Добавяне, за да сложите бутилка в избата си. За начало стига името.';

  @override
  String get guideLabelTitle => 'Прочетете етикета';

  @override
  String get guideLabelBody =>
      'От Добавяне можете и да снимате етикета: Vinoozy чете името, реколтата и наименованието за произход, а вие ги проверявате, преди да запазите.';

  @override
  String get guideTabsTitle => 'Табло, Изба, История';

  @override
  String get guideTabsBody =>
      'Таблото ви казва кои вина да отворите сега, Избата показва бутилките ви, а Историята пази изпитите.';

  @override
  String get guideMenuTitle => 'Менюто на избата';

  @override
  String get guideMenuBody =>
      'Тук са профилът ви, хората, с които споделяте избата, изпитите вина и Настройките, където можете да видите това ръководство отново.';

  @override
  String get guideDone => 'Готово';

  @override
  String guideStepOf(int step, int count) {
    return 'Стъпка $step от $count';
  }

  @override
  String get hintDashboard =>
      'Тук виждате кои вина са готови за пиене сега и кои е по-добре да почакат.';

  @override
  String get hintHistory =>
      'Всяка бутилка, която изпиете, идва тук, с вашата оценка и бележки.';

  @override
  String get hintAddWine =>
      'Започнете с името: реколтата, видът и наименованието за произход правят прозореца за консумация по-точен.';

  @override
  String get shareAppSubject => 'Vinoozy, вашата винена изба';

  @override
  String shareAppMessage(String link) {
    return 'Водя винената си изба с Vinoozy: казва ми кога всяка бутилка е в най-добрата си форма. Опитайте го: $link';
  }

  @override
  String get feedbackSubject => 'Отзив за Vinoozy';

  @override
  String get feedbackTechHeader => 'Технически данни (не ги изтривайте):';

  @override
  String get feedbackNoEmailTitle => 'Няма приложение за имейл';

  @override
  String feedbackNoEmailBody(String email) {
    return 'На този телефон няма приложение за имейл. Пишете ни на $email';
  }

  @override
  String get feedbackCopy => 'Копиране';

  @override
  String get feedbackCopied => 'Адресът е копиран';

  @override
  String get faqAddQuestion => 'Как да добавя вино ръчно?';

  @override
  String get faqAddAnswer =>
      'В Избата докоснете Добавяне, после Въвеждане. Задължително е само името; реколтата, видът, държавата и наименованието за произход подобряват оценката. Запазете и виното е в избата.';

  @override
  String get faqLabelQuestion => 'Как да прочета етикет, и с Google Lens?';

  @override
  String get faqLabelAnswer =>
      'Докоснете Добавяне и снимайте предната и задната страна: Vinoozy чете етикета направо на телефона. В Google Lens изберете текста и го споделете с Vinoozy или го копирайте и във формуляра използвайте Поставяне от Lens. Винаги проверявайте полетата, преди да запазите.';

  @override
  String get faqWindowQuestion =>
      'Как се изчислява най-подходящият момент за пиене и мога ли да го променя?';

  @override
  String get faqWindowAnswer =>
      'Vinoozy оценява прозорец (начало, връх, край) по вида, наименованието за произход, реколтата и нивото на виното. Това е ориентир: значение има и как е съхранявана бутилката. Отворете виното и докоснете Поправка, за да зададете своя дата, или сменете Нивото.';

  @override
  String get faqOfflineQuestion => 'Работи ли без интернет?';

  @override
  String get faqOfflineAnswer =>
      'Да. Можете да добавяте, редактирате и пиете вина без връзка: всичко се запазва на телефона и се синхронизира с акаунта ви, щом връзката се възстанови.';

  @override
  String get faqShareQuestion => 'Как да споделя избата си?';

  @override
  String get faqShareAnswer =>
      'От менюто на Избата отворете Хора и поканете някого с неговия имейл адрес в Google, само за преглед или с редактиране. Човекът инсталира Vinoozy и влиза с този акаунт.';

  @override
  String get faqPlusQuestion =>
      'Какво включва безплатният план и какво е Plus?';

  @override
  String faqPlusAnswer(int limit) {
    return 'Безплатният план включва до $limit различни вина в избата, с реклами от време на време само в Таблото. Vinoozy Plus премахва ограничението и рекламите.';
  }

  @override
  String get faqDrinkQuestion =>
      'Защо да записвам какво съм изпил и какво е било?';

  @override
  String get faqDrinkAnswer =>
      'Историята пази какво сте изпили и колко ви е харесало. Когато кажете каква е била бутилката (още твърде младо, точно навреме, вече след върха си), Vinoozy поправя оценката за същото вино.';

  @override
  String get faqDeleteQuestion => 'Как да изтрия акаунта си?';

  @override
  String get faqDeleteAnswer =>
      'Отворете Профил и докоснете Изтриване на акаунта. Нужна е връзка, след което влизате отново с Google за потвърждение. Избата, Историята и споделянията се изтриват завинаги.';

  @override
  String get faqNotFound => 'Не намерихте отговора? Пишете ни';
}
