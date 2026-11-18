// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Serbian (`sr`).
class AppLocalizationsSr extends AppLocalizations {
  AppLocalizationsSr([String locale = 'sr']) : super(locale);

  @override
  String get appTitle => 'Vinoozy';

  @override
  String get signInTagline => 'Ваш подрум, у право време';

  @override
  String get signInWithGoogle => 'Настави помоћу Google-а';

  @override
  String get signInInProgress => 'Пријављивање';

  @override
  String get signInFailed => 'Пријављивање није успело';

  @override
  String get signInNeedsNetwork => 'За прво пријављивање потребна је веза';

  @override
  String get signInSessionExpired => 'Сесија је истекла: пријавите се поново';

  @override
  String get retry => 'Пробај поново';

  @override
  String get cancel => 'Откажи';

  @override
  String blockedMessage(String email) {
    return 'Постоје измене налога $email које још нису сачуване у облаку: пријавите се тим налогом и повежите се на мрежу';
  }

  @override
  String blockedSignInWith(String email) {
    return 'Пријави се као $email';
  }

  @override
  String blockedDiscard(String email) {
    return 'Обриши несачуване измене налога $email';
  }

  @override
  String get discardDialogTitle => 'Обрисати измене?';

  @override
  String discardDialogBody(int count, String email) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count вина налога $email још није у облаку и биће обрисано са овог телефона.',
      few:
          '$count вина налога $email још нису у облаку и биће обрисана са овог телефона.',
      one:
          '$count вино налога $email још није у облаку и биће обрисано са овог телефона.',
    );
    return '$_temp0';
  }

  @override
  String get discardConfirm => 'Обриши';

  @override
  String get resetFailed => 'Брисање података са овог телефона није успело';

  @override
  String get restartRequired => 'Поново покрените апликацију да бисте завршили';

  @override
  String get restartCloseApp => 'Затвори апликацију';

  @override
  String get startupFailed => 'Апликација није могла да се покрене';

  @override
  String get cellarTitle => 'Подрум';

  @override
  String get defaultCellarName => 'Мој подрум';

  @override
  String get cellarLoading => 'Припрема подрума';

  @override
  String get cellarSetupFailed => 'Припрема подрума није успела';

  @override
  String get cellarEmpty => 'Ваш подрум је празан';

  @override
  String get addWine => 'Додај';

  @override
  String get estimatePending => 'Процена стиже';

  @override
  String get noVintage => 'Без бербе';

  @override
  String bottleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count боца',
      few: '$count боце',
      one: '$count боца',
    );
    return '$_temp0';
  }

  @override
  String get syncInProgress => 'Синхронизација';

  @override
  String get syncOffline => 'Офлајн – синхронизација на чекању';

  @override
  String writeRejected(String name) {
    return 'Измена није дозвољена: $name';
  }

  @override
  String get saveFailed => 'Чување није успело, пробајте поново';

  @override
  String wineNotSaved(String name) {
    return 'Вино $name није сачувано у облаку';
  }

  @override
  String get addAgain => 'Додај поново';

  @override
  String get ignore => 'Занемари';

  @override
  String get addWineTitle => 'Упиши';

  @override
  String get wineNameLabel => 'Вино';

  @override
  String get vintageLabel => 'Берба';

  @override
  String get quantityLabel => 'Количина';

  @override
  String get decreaseQuantity => 'Смањи количину';

  @override
  String get increaseQuantity => 'Повећај количину';

  @override
  String get save => 'Сачувај';

  @override
  String get nameRequired => 'Упишите назив вина';

  @override
  String get nameTooLong => 'Највише 120 знакова';

  @override
  String vintageRange(String year) {
    return 'Берба између 1900. и $year.';
  }

  @override
  String get offAttribution => 'Подаци из Open Food Facts (ODbL)';

  @override
  String get dashboardTitle => 'Преглед';

  @override
  String dashboardTotalBottles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count боца у подруму',
      few: '$count боце у подруму',
      one: '$count боца у подруму',
    );
    return '$_temp0';
  }

  @override
  String get dashboardSyncing => 'Синхронизација подрума…';

  @override
  String get dashboardAddFirstWine => 'Додајте прво вино';

  @override
  String get drinkSoonTitle => 'Попити ускоро';

  @override
  String get drinkSoonEmpty => 'Нема боца које треба ускоро попити';

  @override
  String drinkSoonUntil(String year) {
    return 'до $year.';
  }

  @override
  String drinkSoonSeeAll(int count) {
    return 'Прикажи све ($count)';
  }

  @override
  String get statusChartTitle => 'Стање боца';

  @override
  String get statusWaiting => 'за чекање';

  @override
  String get statusReady => 'спремне';

  @override
  String get statusDrinkSoon => 'попити ускоро';

  @override
  String get statusPastWindow => 'после прозора';

  @override
  String toEstimateNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count боца без процене',
      few: '$count боце без процене',
      one: '$count боца без процене',
    );
    return '$_temp0';
  }

  @override
  String chartBarValue(String label, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count боца',
      few: '$count боце',
      one: '$count боца',
    );
    return '$label: $_temp0';
  }

  @override
  String chartDescription(String title, String values) {
    return '$title: $values';
  }

  @override
  String get openListHint => 'Отвори листу';

  @override
  String get peakChartTitle => 'Година врхунца';

  @override
  String get peakPast => 'врхунац прошао';

  @override
  String get peakBeyond => 'касније';

  @override
  String get breakdownTypeTitle => 'Боце по врсти';

  @override
  String get breakdownRegionTitle => 'Боце по региону';

  @override
  String get breakdownType => 'Врста';

  @override
  String get breakdownRegion => 'Регион';

  @override
  String get familyRed => 'црвено';

  @override
  String get familyWhite => 'бело';

  @override
  String get familyRose => 'розе';

  @override
  String get familySparkling => 'пенушаво';

  @override
  String get familySweet => 'слатко';

  @override
  String get breakdownUnspecified => 'није наведено';

  @override
  String get breakdownOtherRegions => 'остало';

  @override
  String get ok => 'У реду';

  @override
  String get cellarMenu => 'Мени подрума';

  @override
  String get sharingPeopleTitle => 'Особе';

  @override
  String get sharingInviteTitle => 'Позовите особу';

  @override
  String get sharingEmailLabel => 'Google имејл адреса';

  @override
  String get sharingPermissionRead => 'Само преглед';

  @override
  String get sharingPermissionReadHint =>
      'Види вина, процене, Преглед и попијене боце';

  @override
  String get sharingPermissionEdit => 'Може да мења';

  @override
  String get sharingPermissionEditHint =>
      'Такође додаје и мења вина и бележи попијене боце';

  @override
  String get sharingRoleOwner => 'власник';

  @override
  String get sharingInviteButton => 'Позови';

  @override
  String sharingPlacesUsed(int used, int max) {
    return 'Особе: $used/$max';
  }

  @override
  String get sharingInvalidEmail => 'Унесите важећу имејл адресу';

  @override
  String get sharingSelfInvite => 'Не можете да позовете себе';

  @override
  String get sharingAlreadyInvited => 'Ова особа је већ позвана';

  @override
  String sharingLimitReached(int max) {
    return 'Достигли сте највећи број особа: $max';
  }

  @override
  String get sharingNotOwner => 'Не можете да мењате дељење овог подрума';

  @override
  String get sharingNotFound => 'Ова особа више није на листи';

  @override
  String get sharingFailed => 'Није успело, пробајте поново';

  @override
  String get sharingInviteFailed => 'Позивање није успело. Пробајте поново';

  @override
  String get sharingOfflineHint => 'За управљање дељењем потребна је веза';

  @override
  String get sharingStatusInvited => 'позив послат';

  @override
  String get sharingStatusActive => 'има приступ';

  @override
  String get sharingStatusRevoked => 'приступ опозван';

  @override
  String get sharingStatusLeft => 'подрум напуштен';

  @override
  String sharingMemberSemantics(String name, String permission, String status) {
    return '$name, $permission, $status';
  }

  @override
  String get sharingClosedSection => 'Затворени приступи';

  @override
  String get sharingNobody => 'Још нико други не види овај подрум';

  @override
  String sharingChangePermission(String name) {
    return 'Промена дозволе кориснику $name';
  }

  @override
  String get sharingRevoke => 'Опозови';

  @override
  String sharingRevokeTitle(String name) {
    return 'Опозвати приступ кориснику $name?';
  }

  @override
  String sharingRevokeConfirmLabel(String name) {
    return 'Упишите $name за потврду';
  }

  @override
  String get sharingRevokeDisabledHint => 'Омогућава се када се име поклопи';

  @override
  String get sharingReinvite => 'Позови поново';

  @override
  String get sharingDeleteForGood => 'Обриши трајно';

  @override
  String sharingOwnedBy(String owner) {
    return 'Подрум корисника $owner';
  }

  @override
  String get sharingYourCellar => 'Ваш подрум';

  @override
  String sharingYourPermission(String permission) {
    return 'Ваша дозвола: $permission';
  }

  @override
  String sharingSwitcherSemantics(String cellar, String permission) {
    return '$cellar, $permission. Додирните да бисте променили подрум';
  }

  @override
  String get sharingLeave => 'Напусти овај подрум';

  @override
  String sharingLeaveTitle(String owner) {
    return 'Напустити подрум корисника $owner?';
  }

  @override
  String sharingLeaveBody(String owner) {
    return 'Више га нећете видети. Корисник $owner може поново да вас позове.';
  }

  @override
  String get sharingLeaveConfirm => 'Напусти';

  @override
  String sharingSharedNotice(String owner) {
    return 'Корисник $owner дели свој подрум са вама';
  }

  @override
  String sharingAccessLost(String owner) {
    return 'Више немате приступ подруму корисника $owner';
  }

  @override
  String sharingWritesLost(String owner) {
    return 'Неке измене у подруму корисника $owner нису сачуване јер више немате приступ';
  }

  @override
  String get sharingSomeone => 'без имена';

  @override
  String get sharingShareSubject => 'Позив у Vinoozy';

  @override
  String sharingShareMessage(
    String owner,
    String cellar,
    String link,
    String email,
  ) {
    return '$owner вас позива у подрум „$cellar“ у апликацији Vinoozy. Инсталирајте апликацију са $link и пријавите се Google налогом $email: користите баш ову адресу.';
  }

  @override
  String get cellarSearchHint => 'Претрага по називу или произвођачу';

  @override
  String get cellarFilterStatus => 'Стање';

  @override
  String get cellarFilterType => 'Врста';

  @override
  String get statusToEstimate => 'Без процене';

  @override
  String get filterTypeUnspecified => 'Није наведена';

  @override
  String get cellarNoMatches => 'Нема вина са овим филтерима';

  @override
  String get cellarClearFilters => 'Обриши филтере';

  @override
  String get cellarArchiveTitle => 'Попијено';

  @override
  String get cellarArchiveEmpty => 'Још нема завршених вина';

  @override
  String get cellarArchiveFailed => 'Учитавање завршених вина није успело';

  @override
  String get wineDrink => 'Попијено';

  @override
  String wineDrinkTooltip(String name) {
    return 'Означи боцу вина $name као попијену';
  }

  @override
  String confidenceLabel(String level) {
    return 'Поузданост: $level';
  }

  @override
  String get confidenceHigh => 'висока';

  @override
  String get confidenceMedium => 'средња';

  @override
  String get confidenceLow => 'ниска';

  @override
  String get windowStartLabel => 'Почетак';

  @override
  String get windowPeakLabel => 'Врхунац';

  @override
  String get windowEndLabel => 'Крај';

  @override
  String estimateSourceLabel(String source) {
    return 'Извор: $source';
  }

  @override
  String get estimateSourceCatalog => 'база вина';

  @override
  String get estimateSourceType => 'процена према врсти';

  @override
  String get estimateSourceCorrected =>
      'процена исправљена према вашим попијеним боцама';

  @override
  String get estimateDisclaimer =>
      'Оквирна процена: зависи и од тога како је боца чувана';

  @override
  String get estimateUnavailable => 'Процена није доступна';

  @override
  String get pairingsTitle => 'Слагање с храном';

  @override
  String get pairingsGeneric => 'општа слагања за ову врсту';

  @override
  String get pairingBraisedRedMeat => 'Динстано црвено месо';

  @override
  String get pairingGrilledRedMeat => 'Црвено месо са роштиља';

  @override
  String get pairingGame => 'Дивљач';

  @override
  String get pairingRoastPoultry => 'Печена живина';

  @override
  String get pairingPoultry => 'Живина';

  @override
  String get pairingPork => 'Свињетина';

  @override
  String get pairingCuredMeats => 'Сухомеснати производи';

  @override
  String get pairingPastaMeatSauce => 'Тестенина са месним сосом';

  @override
  String get pairingMushroomsTruffle => 'Печурке и тартуфи';

  @override
  String get pairingAgedCheese => 'Зрели сиреви';

  @override
  String get pairingFreshCheese => 'Млади сиреви';

  @override
  String get pairingBlueCheese => 'Плави сиреви';

  @override
  String get pairingFish => 'Риба';

  @override
  String get pairingSeafood => 'Плодови мора';

  @override
  String get pairingRawSeafood => 'Сирови плодови мора';

  @override
  String get pairingFriedFood => 'Пржена храна';

  @override
  String get pairingVegetables => 'Поврће';

  @override
  String get pairingRisotto => 'Рижото';

  @override
  String get pairingPizza => 'Пица';

  @override
  String get pairingAperitif => 'Аперитив';

  @override
  String get pairingPastries => 'Колачи';

  @override
  String get pairingDryBiscuits => 'Суви кекс';

  @override
  String get pairingChocolate => 'Чоколада';

  @override
  String get pairingDriedFruit => 'Орашасти плодови и сушено воће';

  @override
  String get pairingSpicyDishes => 'Зачињена јела';

  @override
  String get recentDrinksTitle => 'Последње попијено';

  @override
  String get noDrinksYet => 'Још нема попијених боца';

  @override
  String get wineEdit => 'Измени';

  @override
  String get wineDelete => 'Обриши';

  @override
  String get wineFinished => 'Завршено: нема више боца';

  @override
  String get wineLoadFailed => 'Отварање вина није успело';

  @override
  String get wineNotFound => 'Ово вино више не постоји';

  @override
  String drinkDone(String name) {
    return 'Означено као попијено: $name';
  }

  @override
  String get drinkUndo => 'Поништи';

  @override
  String get drinkAddNotes => 'Додај оцену и белешке';

  @override
  String get nothingToUndo => 'Нема више шта да се поништи';

  @override
  String get cellarUndoRejected =>
      'Поништавање није успело: боца остаје означена као попијена';

  @override
  String get cellarDeleteFailed =>
      'Брисање још није завршено: довршиће се чим буде могуће';

  @override
  String get duplicateFull =>
      'Ово вино већ има 99 боца: не може се додати више.';

  @override
  String get recordSheetTitle => 'Оцена и белешке';

  @override
  String get recordRatingLabel => 'Оцена';

  @override
  String ratingStar(int n) {
    return 'Оцена $n од 5';
  }

  @override
  String get recordNotesLabel => 'Белешке';

  @override
  String get recordNotesTooLong => 'Највише 1000 знакова';

  @override
  String recordDateLabel(String date) {
    return 'Датум: $date';
  }

  @override
  String get recordDateInvalid =>
      'Датум не може бити у будућности ни пре бербе';

  @override
  String get recordConditionTitle => 'Какво је било?';

  @override
  String get conditionTooYoung => 'Још премладо';

  @override
  String get conditionJustRight => 'Баш како треба';

  @override
  String get conditionPastPeak => 'Прошло врхунац';

  @override
  String get recordNoCondition => 'Без одговора';

  @override
  String get producerLabel => 'Произвођач (опционо)';

  @override
  String get producerTooLong => 'Највише 120 знакова';

  @override
  String producerAddNew(String name) {
    return 'Додај „$name“ као новог произвођача';
  }

  @override
  String get wineTypeLabel => 'Врста';

  @override
  String get typeRedLight => 'Лагано црвено';

  @override
  String get typeRedStructured => 'Пуно црвено';

  @override
  String get typeWhite => 'Бело';

  @override
  String get typeRose => 'Розе';

  @override
  String get typeSparklingClassic => 'Пенушаво, класична метода';

  @override
  String get typeSparklingTank => 'Пенушаво, шарма метода';

  @override
  String get typeSweet => 'Слатко';

  @override
  String get typeFortified => 'Ликерско';

  @override
  String get suggestionFromCellar => 'У вашем подруму';

  @override
  String get suggestionsLabel => 'Предлози';

  @override
  String get duplicateTitle => 'Већ је у подруму';

  @override
  String duplicateBody(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'са $count боца',
      few: 'са $count боце',
      one: 'са $count боцом',
      zero: 'без иједне боце',
    );
    return '$name је већ ту, $_temp0. Додати нове боце том вину?';
  }

  @override
  String duplicateAdd(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Додај $count боца',
      few: 'Додај $count боце',
      one: 'Додај $count боцу',
    );
    return '$_temp0';
  }

  @override
  String get duplicateBanner => 'Могући дупликат';

  @override
  String get duplicateMerge => 'Споји';

  @override
  String get duplicateDeleteHint => 'Обришите овај унос ако је дупликат';

  @override
  String get mergeTitle => 'Спојити два уноса?';

  @override
  String get mergeBody =>
      'Боце из овог уноса прелазе у старији, а затим се овај унос брише.';

  @override
  String get editWineTitle => 'Измена вина';

  @override
  String get editDuplicate =>
      'Већ постоји друго вино са истим називом, произвођачем и бербом';

  @override
  String deleteWineTitle(String name) {
    return 'Обрисати $name?';
  }

  @override
  String get deleteWineBody =>
      'Вино и све његове попијене боце се бришу. Ово се не може поништити.';

  @override
  String get historyTitle => 'Историја';

  @override
  String get historyEmpty => 'Овде ћете наћи боце које сте попили';

  @override
  String get historyLoadFailed => 'Учитавање историје није успело';

  @override
  String drankOnLabel(String date) {
    return 'Попијено $date';
  }

  @override
  String get addChoiceTitle => 'Додајте вино';

  @override
  String get addChoicePhoto => 'Сликај';

  @override
  String get addChoiceImport => 'Увези фотографију';

  @override
  String get addChoiceWrite => 'Упиши';

  @override
  String get labelReading => 'Читам етикету…';

  @override
  String get labelRecognized => 'Препознато:';

  @override
  String get labelCorrect => 'Исправи';

  @override
  String get labelConfirm => 'Потврди';

  @override
  String get labelUnreadable => 'Не могу да прочитам етикету';

  @override
  String get labelWriteByHand => 'Упиши ручно';

  @override
  String get labelNotFound => 'Вино није пронађено: проверите податке';

  @override
  String get labelCameraDenied =>
      'За читање етикете потребан ми је приступ камери';

  @override
  String get labelPhotosDenied =>
      'За читање етикете потребан ми је приступ фотографијама';

  @override
  String get labelOpenSettings => 'Отвори подешавања';

  @override
  String get labelCameraUnavailable => 'Камера није доступна';

  @override
  String get labelBarcodeNotFound => 'Бар-код је прочитан, али не налазим вино';

  @override
  String get labelBarcodeFrontHint => 'Сликајте предњу страну етикете';

  @override
  String get labelSharedNotAllowed =>
      'Не можете да додајете вина у овај подрум';

  @override
  String get labelSharedFirstOnly => 'Коришћена је само прва фотографија';

  @override
  String get labelSharedExpired =>
      'Дељена фотографија није могла да се прочита: поделите је поново';

  @override
  String get labelReplaceTitle =>
      'Имате несачувано вино. Прочитати нову фотографију?';

  @override
  String get labelReplaceRead => 'Прочитај нову фотографију';

  @override
  String get labelReplaceKeep => 'Настави са отвореним';

  @override
  String get labelWineAdded => 'Вино је додато у подрум';

  @override
  String get onboardingPage1Title => 'Ваш подрум у џепу';

  @override
  String get onboardingPage1Body =>
      'Додајте боце тако што ћете их уписати или сликати етикету, чак и без мреже.';

  @override
  String get onboardingPage2Title => 'У право време';

  @override
  String get onboardingPage2Body =>
      'Vinoozy процењује када је свако вино најбоље и говори вам које боце треба прво отворити.';

  @override
  String get onboardingPage3Title => 'Заједно';

  @override
  String get onboardingPage3Body =>
      'Делите подрум са највише две особе и чувајте историју сваке попијене боце.';

  @override
  String get onboardingSkip => 'Прескочи';

  @override
  String get onboardingNext => 'Даље';

  @override
  String get onboardingStart => 'Почни';

  @override
  String onboardingPageOf(int page) {
    return 'Страна $page од 3';
  }

  @override
  String get profileTitle => 'Профил';

  @override
  String get profilePhoto => 'Слика профила';

  @override
  String get profileSignOut => 'Одјави ме';

  @override
  String get profileDeleteAccount => 'Обриши налог';

  @override
  String get profilePrivacy => 'Политика приватности';

  @override
  String get profilePrivacyBody =>
      'Политику приватности можете прочитати на овој адреси:';

  @override
  String get profileOpenLink => 'Отвори у прегледачу';

  @override
  String get profileOpenLinkFailed =>
      'Страница није могла да се отвори. Можете да копирате линк и отворите га у прегледачу.';

  @override
  String get profileCopyLink => 'Копирај линк';

  @override
  String get profileLinkCopied => 'Линк је копиран';

  @override
  String get close => 'Затвори';

  @override
  String get signOutConfirmTitle => 'Желите ли да се одјавите?';

  @override
  String signOutPendingWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Имате $count измена које још нису сачуване. Ако се одјавите и пријави се други налог, биће изгубљене.',
      few:
          'Имате $count измене које још нису сачуване. Ако се одјавите и пријави се други налог, биће изгубљене.',
      one:
          'Имате $count измену која још није сачувана. Ако се одјавите и пријави се други налог, биће изгубљена.',
    );
    return '$_temp0';
  }

  @override
  String get signOutStayAndSync => 'Остани и синхронизуј';

  @override
  String get signOutAnyway => 'Ипак ме одјави';

  @override
  String get syncAllSaved => 'Све је сачувано';

  @override
  String syncStillPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Још $count измена чека на чување: проверите мрежу',
      few: 'Још $count измене чекају на чување: проверите мрежу',
      one: 'Још $count измена чека на чување: проверите мрежу',
    );
    return '$_temp0';
  }

  @override
  String get signOutFailed => 'Одјављивање није успело. Пробајте поново';

  @override
  String get signInAccountDeleted => 'Налог је обрисан';

  @override
  String get deleteAccountIntro => 'Трајно се брише:';

  @override
  String get deleteAccountItemCellar => 'Ваш подрум, са винима и историјом';

  @override
  String get deleteAccountItemShares =>
      'Дељења која сте дали: позване особе губе приступ';

  @override
  String get deleteAccountItemMemberships =>
      'Ваше учешће у туђим подрумима: ваше попијене боце остају тамо без вашег имена';

  @override
  String get deleteAccountItemProfile => 'Ваш профил';

  @override
  String deleteAccountPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Имате $count измена које још нису сачуване: биће сачуване, а затим обрисане са осталим',
      few:
          'Имате $count измене које још нису сачуване: биће сачуване, а затим обрисане са осталим',
      one:
          'Имате $count измену која још није сачувана: биће сачувана, а затим обрисана са осталим',
    );
    return '$_temp0';
  }

  @override
  String get deleteAccountConfirmWord => 'ОБРИШИ';

  @override
  String deleteAccountTypeWord(String word) {
    return 'Упишите $word за потврду';
  }

  @override
  String get deleteAccountReauthHint =>
      'Затим ћете се поново пријавити помоћу Google-а да бисте потврдили да сте то ви.';

  @override
  String get deleteAccountForever => 'Обриши заувек';

  @override
  String get deleteAccountNeedsNetwork =>
      'Повежите се на интернет да бисте обрисали налог';

  @override
  String get deleteAccountSameAccount =>
      'За брисање је потребно пријављивање истим налогом';

  @override
  String get deletionTitle => 'Брисање налога';

  @override
  String get deletionStepPreparePhone => 'Чување измена на чекању';

  @override
  String get deletionStepMarkStarted => 'Покретање брисања';

  @override
  String get deletionStepLeaveOtherCellars => 'Напуштање туђих подрума';

  @override
  String get deletionStepCloseOwnInvitations => 'Затварање ваших дељења';

  @override
  String get deletionStepDeleteWinesAndRecords => 'Брисање вина и историје';

  @override
  String get deletionStepDeleteCellar => 'Брисање подрума';

  @override
  String get deletionStepDeleteProfileAndUser => 'Брисање профила и налога';

  @override
  String get deletionStepCleanUpPhone => 'Чишћење овог телефона';

  @override
  String deletionStepAnnounce(int step, String label) {
    return 'Корак $step од 8: $label';
  }

  @override
  String deletionDeletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Обрисано је $count ставки: вина и попијених боца',
      few: 'Обрисане су $count ставке: вина и попијене боце',
      one: 'Обрисана је $count ставка: вино или попијена боца',
    );
    return '$_temp0';
  }

  @override
  String get deletionResumeHint =>
      'Брисање овог налога није завршено. Пријавите се поново помоћу Google-а да бисте га довршили.';

  @override
  String get deletionContinue => 'Настави';

  @override
  String get deletionOffline =>
      'Повежите се на интернет да бисте довршили брисање';

  @override
  String get deletionPendingWrites =>
      'Не могу да сачувам измене на чекању. Пробајте поново';

  @override
  String get deletionFailed =>
      'Брисање није могло да се доврши. Пробајте поново';

  @override
  String get uxCountryLabel => 'Држава';

  @override
  String get uxCountryOther => 'Друга држава…';

  @override
  String get uxCountryNone => 'Без државе';

  @override
  String get uxAllCountriesTitle => 'Све државе и територије';

  @override
  String get uxAllCountriesSearch => 'Претражите државе';

  @override
  String get uxAllCountriesRare => 'Ретке за вино';

  @override
  String get uxAllCountriesAll => 'Све, од А до Ш';

  @override
  String get uxAllCountriesNone => 'Ниједна држава није пронађена';

  @override
  String get uxRegionLabel => 'Регион';

  @override
  String uxRegionOf(String country) {
    return 'Регион · $country';
  }

  @override
  String get uxRegionOther => 'Други регион';

  @override
  String get uxRegionFieldLabel => 'Упишите регион';

  @override
  String get uxRegionTooLong => 'Највише 120 знакова';

  @override
  String get uxDrinkAction => 'Попијено';

  @override
  String uxDrinkActionTooltip(String name) {
    return 'Попијена боца вина $name';
  }

  @override
  String get uxDrinkActionDetail => 'Попијена боца';

  @override
  String get uxDrinkSheetLabel => 'Потврда попијене боце';

  @override
  String get uxDrinkSheetBottles => 'Боце';

  @override
  String uxDrinkSheetBottlesChange(int before, int after) {
    return 'Боце: са $before на $after';
  }

  @override
  String get uxDrinkSheetRating => 'Какво је било? (опционо)';

  @override
  String uxDrinkSheetStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count звездица од 5',
      few: '$count звездице од 5',
      one: '$count звездица од 5',
    );
    return '$_temp0';
  }

  @override
  String get uxDrinkSheetConfirm => 'Да, попијена је';

  @override
  String get uxRemoveBottle => 'Уклони боцу која није попијена';

  @override
  String get uxRemoveBottleTitle => 'Уклонити боцу?';

  @override
  String uxRemoveBottleBody(String name) {
    return 'Једна боца вина $name се уклања, а да се не бележи као попијена.';
  }

  @override
  String get uxRemoveBottleConfirm => 'Уклони';

  @override
  String get uxIdealTitle => 'Идеалан тренутак';

  @override
  String uxIdealUntil(String year) {
    return 'Препоручено до $year.';
  }

  @override
  String uxIdealUntilPast(String year) {
    return 'Препоручено до $year. – већ је прошло';
  }

  @override
  String uxIdealBest(String start, String end) {
    return 'Најбоље од $start. до $end.';
  }

  @override
  String uxIdealBar(String start, String end) {
    return 'Прозор испијања од $start. до $end.';
  }

  @override
  String get uxIdealDisclaimer =>
      '⚠︎ Оквирно: процена према врсти, апелацији и берби. Чување и појединачна боца могу да је промене.';

  @override
  String get uxIdealUnavailableHint =>
      'Додајте бербу и врсту да бисте добили процену.';

  @override
  String uxDashboardDrinkNow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count боца за испијање сада',
      few: '$count боце за испијање сада',
      one: '$count боца за испијање сада',
    );
    return '$_temp0';
  }

  @override
  String get uxFamilyRed => 'Црвено';

  @override
  String get uxFamilyWhite => 'Бело';

  @override
  String get uxFamilyRose => 'Розе';

  @override
  String get uxFamilySparkling => 'Пенушаво';

  @override
  String get uxFamilySweet => 'Слатко';

  @override
  String get labelBackTitle => 'Сада полеђина';

  @override
  String get labelBackHint =>
      'На полеђини су обично бар-код, произвођач и берба: помажу да се вино пронађе.';

  @override
  String get labelBackTake => 'Сликај полеђину';

  @override
  String get labelBackGallery => 'Изабери из галерије';

  @override
  String get labelBackSkip => 'Прескочи';

  @override
  String get labelStepFront => 'Предња страна';

  @override
  String get labelStepBack => 'Полеђина';

  @override
  String get labelStepBarcode => 'Бар-код';

  @override
  String get labelStepDatabase => 'База вина на телефону';

  @override
  String get labelStepPending => 'На чекању';

  @override
  String get labelStepRunning => 'У току…';

  @override
  String get labelStepDone => 'Готово';

  @override
  String get labelStepSkipped => 'Прескочено';

  @override
  String get labelStepFailed => 'Нечитљиво';

  @override
  String labelStepStatus(String step, String status) {
    return '$step: $status';
  }

  @override
  String get labelOnPhoneNote =>
      'Све се дешава на телефону: фотографије се никоме не шаљу.';

  @override
  String get labelBackUnreadable => 'Полеђина није читљива';

  @override
  String get labelSourceOffline => 'Из базе на телефону · офлајн';

  @override
  String get labelSourceCatalog => 'Из каталога';

  @override
  String get labelSourceOnline => 'Из Open Food Facts · онлајн';

  @override
  String get labelNotThis => 'Није ово';

  @override
  String get labelOffAttribution => 'Подаци из Open Food Facts, лиценца ODbL';

  @override
  String get labelCandidatesTitle => 'Које од ових?';

  @override
  String labelCandidatesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count сличних вина',
      few: '$count слична вина',
      one: '$count слично вино',
    );
    return '$_temp0';
  }

  @override
  String get labelCandidatesNone => 'Ниједно од ових';

  @override
  String get labelChipOffline => 'офлајн';

  @override
  String get labelChipOnline => 'онлајн';

  @override
  String get labelChipCatalog => 'каталог';

  @override
  String get labelNoProducer => 'произвођач није наведен';

  @override
  String get labelNoMatch => 'Етикета је прочитана, али не препознајем вино';

  @override
  String get labelReadText => 'Прочитани текст';

  @override
  String get labelSearchOnline => 'Претражи онлајн';

  @override
  String get labelOpenLens => 'Отвори у Google Lens-у';

  @override
  String get labelLensLastResort =>
      'Google Lens је последња могућност: фотографија иде у Google апликацију само ако потврдите.';

  @override
  String get labelLensTitle => 'Отворити у Google Lens-у?';

  @override
  String get labelLensBody =>
      'Фотографија предње стране биће прослеђена Google апликацији на вашем телефону, или апликацији коју изаберете, која може да задржи копију према својим правилима. Vinoozy не добија резултате: вратите се овде да изаберете или упишете вино.';

  @override
  String get labelLensConfirm => 'Отвори Google Lens';

  @override
  String get labelLensFailed =>
      'Не могу да отворим ни Google Lens ни мени за дељење';

  @override
  String get onlineSearchTitle => 'Претражи онлајн';

  @override
  String get onlineSearchSubtitle => 'Open Food Facts · само вина';

  @override
  String get onlineSearchField => 'Речи за претрагу';

  @override
  String get onlineSearchHint => 'Речи можете да промените пре претраге.';

  @override
  String get onlineSearchEmptyField => 'Упишите бар једну реч';

  @override
  String get onlineSearchButton => 'Претражи';

  @override
  String get onlineSearchLoading => 'Тражим…';

  @override
  String onlineSearchResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count резултата',
      few: '$count резултата',
      one: '$count резултат',
    );
    return '$_temp0';
  }

  @override
  String get onlineSearchEmpty =>
      'Ниједно вино није пронађено: пробајте друге речи или „Упиши ручно“.';

  @override
  String get onlineSearchOffline =>
      'Нема мреже: тражим само у бази на телефону.';

  @override
  String get onlineSearchRateLimited =>
      'Претрага онлајн тренутно није доступна, пробајте поново за неколико минута.';

  @override
  String get onlineSearchUnavailable =>
      'Претрага онлајн није активна у овој верзији апликације: тражим само у бази на телефону.';

  @override
  String get aboutTitle => 'О апликацији';

  @override
  String aboutVersion(String version) {
    return 'Верзија $version';
  }

  @override
  String get aboutDbTitle => 'База вина';

  @override
  String aboutDbCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count вина',
      few: '$count вина',
      one: '$count вино',
    );
    return '$_temp0';
  }

  @override
  String aboutDbDate(String date) {
    return 'Извоз из Open Food Facts, $date';
  }

  @override
  String get aboutDbSample =>
      'Пробна база: неколико ручно уписаних тест вина, а не подаци из Open Food Facts.';

  @override
  String get aboutDbLoading => 'Отварам базу вина…';

  @override
  String get aboutDbUnavailable => 'База вина није доступна у овој верзији';

  @override
  String aboutDbSource(String url) {
    return 'Изведена база и алат који је прави налазе се у јавном репозиторијуму: $url';
  }

  @override
  String get aboutLicenseTitle => 'Лиценце';

  @override
  String get aboutLicense =>
      'Садржи информације из Open Food Facts, доступне под лиценцом Open Database License (ODbL). Појединачни садржаји су под лиценцом Database Contents License (DbCL).';

  @override
  String get aboutPrivacyTitle => 'Фотографије етикета';

  @override
  String get aboutPrivacy =>
      'Фотографије етикета се читају на телефону и бришу када напустите резултат. Телефон напуштају само ако додирнете „Отвори у Google Lens-у“ и потврдите.';

  @override
  String get aboutAppellationsTitle => 'Апелације';

  @override
  String get aboutAppellationsSource =>
      'Апелације: регистар eAmbrosia (ЕУ) и званични национални регистри.';

  @override
  String get aboutAppellationsSample =>
      'Пробна табела: ручно уписан извод из регистара, док се не преузму прави регистри.';

  @override
  String get denominationLabel => 'Апелација';

  @override
  String get denominationTooLong => 'Највише 120 знакова';

  @override
  String get autofillFilledNotice =>
      'Попуњено са етикете: проверите и сачувајте';

  @override
  String get autofillPastedNotice =>
      'Попуњено из текста: проверите и сачувајте';

  @override
  String get autofillFromText => '✦ из текста';

  @override
  String get autofillFromTextSemantics => 'попуњено са етикете';

  @override
  String get autofillClear => 'Очисти';

  @override
  String get autofillLens => 'Lens';

  @override
  String get autofillClearTitle => 'Очистити образац?';

  @override
  String get autofillClearBody =>
      'И ви сте уписали нешто у нека поља. „Очисти“ празни назив, произвођача, апелацију, бербу, врсту, државу, регион и ниво. Количина остаје.';

  @override
  String get autofillClearConfirm => 'Очисти';

  @override
  String get autofillCleared => 'Образац је очишћен';

  @override
  String get autofillPasteTitle => 'Имате текст из Google Lens-а?';

  @override
  String get autofillPasteHint =>
      'У Lens-у изаберите текст етикете и додирните „Копирај“, па се вратите овде.';

  @override
  String get autofillPaste => 'Налепи из Lens-а';

  @override
  String get autofillOpenLens => 'Из Google Lens-а';

  @override
  String get autofillOpenLensSemantics => 'отвара Google Lens';

  @override
  String get autofillClipboardEmpty => 'У привременој меморији нема текста';

  @override
  String get autofillNoNewFields => 'У тексту нема података за додавање';

  @override
  String get autofillFromLens => 'Образац је попуњен текстом из Lens-а';

  @override
  String get autofillShareEmpty => 'Текст није примљен';

  @override
  String get autofillShareUseTitle => 'Користити текст за празна поља?';

  @override
  String get autofillShareUse => 'Користи';

  @override
  String get autofillShareIgnore => 'Занемари';

  @override
  String get addChoiceLens => 'Из Google Lens-а';

  @override
  String get addChoicePhotoHint =>
      'Предња страна и полеђина: Vinoozy чита етикету.';

  @override
  String get addChoiceLensHint =>
      'Отвара Lens: усмерите камеру, изаберите текст и додирните „Дели“ → Vinoozy.';

  @override
  String get addChoiceImportHint => 'Већ снимљена фотографија етикете.';

  @override
  String get addChoiceWriteHint => 'Празан образац, са „Налепи из Lens-а“.';

  @override
  String get lensInstructionsTitle => 'Google Lens не може да се отвори одавде';

  @override
  String get lensInstructionsStep1 =>
      'Отворите Google Lens и усмерите га на етикету';

  @override
  String get lensInstructionsStep2 => 'Изаберите текст етикете';

  @override
  String get lensInstructionsStep3 => 'Додирните „Дели“ → Vinoozy';

  @override
  String get lensInstructionsOk => 'Разумем';

  @override
  String get levelLabel => 'Ниво';

  @override
  String get levelEveryday => 'Свакодневно (јефтино)';

  @override
  String get levelGood => 'Добро';

  @override
  String get levelAging => 'За одлежавање';

  @override
  String get levelNone => 'Ниједан';

  @override
  String get levelEverydayShort => 'попити рано';

  @override
  String get levelGoodShort => 'уобичајена процена';

  @override
  String get levelAgingShort => 'траје дуже';

  @override
  String get levelSuggested => 'предложено';

  @override
  String levelSuggestedReason(String qualifier) {
    return 'Предложено јер назив садржи „$qualifier“: тако ће се сачувати ако не промените. Изаберите други или додирните „Ниједан“.';
  }

  @override
  String levelSuggestedSemantics(String qualifier) {
    return 'предложено, јер назив садржи $qualifier';
  }

  @override
  String levelOptionSemantics(String option, int index, int count) {
    return 'Ниво, $option, $index од $count';
  }

  @override
  String get levelWhatChanges => 'Шта се мења';

  @override
  String get levelEverydayExamples =>
      'Прозор се скраћује. Нпр. кућно вино, Lambrusco, основни Prosecco, Bardolino, Vinho Verde.';

  @override
  String get levelGoodExamples =>
      'Уобичајена процена, и вредност када ништа не изаберете. Нпр. Chianti Classico, Barbera d\'Asti Superiore, Rioja Crianza, Côtes du Rhône.';

  @override
  String get levelAgingExamples =>
      'Прозор се продужава. Нпр. Barolo, Brunello, Amarone, Bordeaux Grand Cru, Rioja Gran Reserva, Porto Vintage.';

  @override
  String levelPreviewBefore(String start, String end) {
    return 'Пре $start – $end';
  }

  @override
  String levelPreviewWith(String level, String start, String end) {
    return 'Уз „$level“ $start – $end';
  }

  @override
  String levelPreviewNow(String start, String end) {
    return 'Спремно $start – до $end';
  }

  @override
  String levelDetail(String level) {
    return 'Ниво: $level';
  }

  @override
  String get overrideCorrect => 'Исправи';

  @override
  String get overrideRestore => 'Врати процену';

  @override
  String get overrideCorrectedByYou => 'ваша исправка';

  @override
  String overrideAppEstimate(String year) {
    return 'Процена апликације: до $year.';
  }

  @override
  String get overrideSheetTitle => 'Препоручено до';

  @override
  String overrideSheetHint(String start) {
    return 'Изаберите годину. Не може бити пре „Спремно од $start“.';
  }

  @override
  String overridePeakNotice(String peak) {
    return 'Ако изаберете годину пре $peak. (најбоље), и „најбоље“ се помера на исту годину.';
  }

  @override
  String get overrideMore => 'још…';

  @override
  String get overrideSave => 'Сачувај исправку';

  @override
  String overrideRestoreTitle(String year) {
    return 'Вратити процену апликације (до $year.)?';
  }

  @override
  String get overrideRestoreConfirm => 'Врати';

  @override
  String get overrideSaved => 'Исправка је сачувана';

  @override
  String get overrideRestored => 'Процена је враћена';

  @override
  String get estimateSourceCorrectedByYou => 'ваша исправка';

  @override
  String estimateFromDenomination(String name) {
    return 'Процена према апелацији $name';
  }

  @override
  String estimateFromDenominationQualifier(String name, String qualifier) {
    return 'Процена према апелацији $name, $qualifier';
  }

  @override
  String estimateFromGrape(String name) {
    return 'Процена према сорти $name';
  }

  @override
  String get estimateFromType => 'Процена према врсти вина';

  @override
  String get autofillReading => 'Читам текст…';

  @override
  String get guideChip => 'Вођена провера';

  @override
  String guideProgress(int n, int total) {
    return 'Питање $n од $total';
  }

  @override
  String get guideClose => 'Затвори';

  @override
  String get guideIsDenomination => 'да ли је ово апелација?';

  @override
  String get guideIsProducer => 'да ли је ово произвођач?';

  @override
  String get guideIsName => 'да ли је ово назив вина?';

  @override
  String get guideIsVintage => 'Берба';

  @override
  String guideAskDenomination(String value) {
    return 'Да ли је $value апелација?';
  }

  @override
  String guideAskProducer(String value) {
    return 'Да ли је $value произвођач?';
  }

  @override
  String guideAskName(String value) {
    return 'Да ли је $value назив вина?';
  }

  @override
  String get guideAskVintage => 'Која је берба?';

  @override
  String guideQuestionSemantics(int n, int total, String question) {
    return 'Питање $n од $total: $question';
  }

  @override
  String get guideNoProposal => 'Није пронађено у тексту';

  @override
  String get guideYes => 'Да';

  @override
  String get guideNo => 'Не, друго';

  @override
  String get guideEdit => 'Измени';

  @override
  String get guideSkip => 'Прескочи';

  @override
  String get guideConfirm => 'Потврди';

  @override
  String get guideCancel => 'Откажи';

  @override
  String guideRejected(String value) {
    return 'Није „$value“: ево следећег';
  }

  @override
  String get guideNoMore =>
      'Нема других предлога: саставите сами или прескочите';

  @override
  String guideProposalAnnounce(String value) {
    return 'Предлог: $value';
  }

  @override
  String get guideComposeLabel => 'Или саставите додиривањем речи из текста';

  @override
  String get guideComposePreview => 'Приказ';

  @override
  String get guideComposeEmpty => 'Додирните једну или више речи';

  @override
  String get guideComposeLimit => 'Највише 8 речи и 80 знакова';

  @override
  String guideTableMatchSemantics(String name) {
    return 'одговара уносу $name';
  }

  @override
  String guideLine(int n, int total) {
    return 'Ред $n од $total';
  }

  @override
  String guideWordSelected(String word, int order) {
    return '$word, изабрана, $order';
  }

  @override
  String guideWordUnavailable(String word) {
    return '$word, недоступна';
  }

  @override
  String guideWordUsedFor(String word, String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'апелација',
      'producer': 'произвођач',
      'other': 'назив',
    });
    return '$word, већ у пољу: $_temp0';
  }

  @override
  String guideUsedMark(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'апелација',
      'producer': 'произвођач',
      'other': 'назив',
    });
    return '$_temp0';
  }

  @override
  String guideOtherYears(String years) {
    return 'У тексту су и: $years';
  }

  @override
  String get guideWheelFromText => 'година пронађена у тексту';

  @override
  String get guideWheelTypeYear => 'Упишите годину';

  @override
  String guideWheelConfirm(String year) {
    return 'Потврди $year';
  }

  @override
  String get guideNoVintage => 'Без бербе';

  @override
  String guideSkippedNotice(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'Апелација је прескочена',
      'producer': 'Произвођач је прескочен',
      'vintage': 'Берба је прескочена',
      'other': 'Назив је прескочен',
    });
    return '$_temp0: упишите ручно или наставите вођену проверу';
  }

  @override
  String guideSkippedMany(int count) {
    return 'Прескочених поља: $count. Упишите их ручно или наставите вођену проверу';
  }

  @override
  String get guideInvalidValue =>
      'Овај текст садржи знакове који се не могу сачувати';

  @override
  String get brandStudio => 'Bottazzini Softworks';

  @override
  String get suggestedMark => '✦ предложено';

  @override
  String suggestedSemantics(String field, String value) {
    return '$field, $value, предложено';
  }

  @override
  String get restoreSuggestion => 'Врати предлог';

  @override
  String get restoreSuggestionDone => 'Предлог је враћен';

  @override
  String get styleLabel => 'Стил';

  @override
  String styleGroupSemantics(String value, int index, int count) {
    return 'Стил, $value, $index од $count';
  }

  @override
  String get styleRedFresh => 'Свеже';

  @override
  String get styleRedMedium => 'Средње';

  @override
  String get styleRedAge => 'За одлежавање';

  @override
  String get styleRedLong => 'Дуго одлежавање';

  @override
  String get styleWhiteFresh => 'Свеже';

  @override
  String get styleWhiteMedium => 'Средње';

  @override
  String get styleWhiteAge => 'За одлежавање';

  @override
  String get styleRoseFresh => 'Свеже';

  @override
  String get styleClassicFresh => 'Свеже';

  @override
  String get styleClassicAge => 'За одлежавање';

  @override
  String get styleTankFresh => 'Свеже';

  @override
  String get styleLambrusco => 'Lambrusco';

  @override
  String get styleSweetAromatic => 'Ароматично';

  @override
  String get styleSweetPassito => 'Passito';

  @override
  String get styleSweetBotrytis => 'Ботритизовано';

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
  String get profileNameRFresh => 'Воћно црвено';

  @override
  String get profileNameRMedium => 'Црвено средњег тела';

  @override
  String get profileNameRAge => 'Црвено за одлежавање';

  @override
  String get profileNameRLong => 'Црвено за дуго одлежавање';

  @override
  String get profileNameWFresh => 'Свеже ароматично бело';

  @override
  String get profileNameWMedium => 'Бело средњег тела';

  @override
  String get profileNameWAge => 'Бело за одлежавање';

  @override
  String get profileNameRoseFresh => 'Свеже розе';

  @override
  String get profileNameSpTank => 'Свеже пенушаво, шарма метода';

  @override
  String get profileNameLamFresh => 'Свежи Lambrusco';

  @override
  String get profileNameSpClassic => 'Свеже пенушаво, класична метода';

  @override
  String get profileNameSpClassicAge =>
      'Пенушаво за одлежавање, класична метода';

  @override
  String get profileNameSwAromatic => 'Младо ароматично слатко вино';

  @override
  String get profileNameSwPassito => 'Слатко вино од просушеног грожђа';

  @override
  String get profileNameSwBotrytis => 'Ботритизовано слатко вино';

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
  String get profileNameFortUnknown => 'Ликерско, непознат стил';

  @override
  String get profileNameUnknown => 'Стил није препознат';

  @override
  String estimateFromProfile(String profile, String denomination) {
    return 'Процена према профилу „$profile“ ($denomination)';
  }

  @override
  String estimateFromProfileType(String profile) {
    return 'Процена према профилу „$profile“, према врсти';
  }

  @override
  String estimateFromProfileGrape(String profile, String grape) {
    return 'Процена према профилу „$profile“, према сорти $grape';
  }

  @override
  String get estimateFromEntryDateDisgorgement =>
      'Према датуму уноса: додајте датум дегоржирања за бољу процену';

  @override
  String get estimateFromEntryDateBottling =>
      'Према датуму уноса: додајте датум пуњења за бољу процену';

  @override
  String get styleToConfirmBanner =>
      '⚠︎ Стил треба потврдити: процена је оквирна';

  @override
  String get chooseTypePrompt => 'Изаберите врсту';

  @override
  String estimateUpdatedAnnouncement(String summary) {
    return 'Процена је ажурирана: $summary';
  }

  @override
  String get agingStartDisgorgement => 'Дегоржирање';

  @override
  String get agingStartBottling => 'Пуњење';

  @override
  String get agingStartMonth => 'Месец';

  @override
  String get agingStartYear => 'Година';

  @override
  String get agingStartHint => 'Обично је на задњој етикети.';

  @override
  String get agingStartIncomplete => 'Унесите месец и годину';

  @override
  String get agingStartFuture => 'Датум не може бити у будућности';

  @override
  String get agingStartBeforeVintage => 'Не може бити пре бербе';

  @override
  String get windowNoEnd => 'Спремно, крај није процењен';

  @override
  String get windowNoEndShort => 'крај није процењен';

  @override
  String windowDrinkWithin(String date) {
    return 'најкасније: $date';
  }

  @override
  String get levelNoEffect => 'Ниво не мења ову процену';

  @override
  String get dashboardToConfirmTitle => 'За потврду';

  @override
  String dashboardToConfirmCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count вина',
      few: '$count вина',
      one: '$count вино',
    );
    return '$_temp0';
  }

  @override
  String aboutDbClassified(String percent) {
    return '$percent% вина има препознату врсту';
  }

  @override
  String get planTitle => 'План';

  @override
  String get planFree => 'Бесплатан';

  @override
  String get planPlus => 'Plus';

  @override
  String get planPlusGift => 'Plus (поклон)';

  @override
  String get planDevUnlockAll => 'DEV · Тест Plus';

  @override
  String get planDevSimulateFree => 'DEV · Симулиран бесплатан план';

  @override
  String get planDevSimulateExpired => 'DEV · Симулиран истекли Plus';

  @override
  String get planDiscoverPlus => 'Откријте Plus';

  @override
  String get plusTitle => 'Vinoozy Plus';

  @override
  String get plusBenefitsTitle => 'Уз Plus';

  @override
  String get plusBenefitNoAds => 'Без огласа';

  @override
  String get plusBenefitNoLimit => 'Без ограничења броја вина у подруму';

  @override
  String get plusComingSoon => 'Plus стиже ускоро';

  @override
  String get plusLoading => 'Читање цена са Google Play-а';

  @override
  String get plusStoreUnavailable =>
      'Цене са Google Play-а нису могле да се прочитају. Пробајте поново касније.';

  @override
  String plusPriceMonthly(String price) {
    return '$price месечно';
  }

  @override
  String plusPriceAnnual(String price) {
    return '$price годишње';
  }

  @override
  String get plusRenewal =>
      'Претплата се аутоматски обнавља по приказаној цени док је не откажете на Google Play-у.';

  @override
  String get plusTerms =>
      'Плаћање се наплаћује са вашег Google Play налога када потврдите куповину. Можете да откажете у било ком тренутку: Plus остаје активан до краја већ плаћеног периода. Када Plus истекне, сва ваша вина остају.';

  @override
  String get plusRestore => 'Врати куповине';

  @override
  String get plusManage =>
      'Управљајте претплатом или је откажите на Google Play-у';

  @override
  String get plusActive => 'Plus је активан на овом налогу';

  @override
  String get plusActiveGift =>
      'Имате Plus на поклон: без наплате и без обнављања.';

  @override
  String get plusPending =>
      'Плаћање је на чекању: Plus ће се активирати када га Google Play потврди.';

  @override
  String get plusVerifying => 'Провера куповине';

  @override
  String get plusVerified =>
      'Куповина је проверена: Plus ће се активирати за неколико секунди.';

  @override
  String get plusPurchaseFailed => 'Куповина није довршена. Пробајте поново.';

  @override
  String get plusInvalidPurchase =>
      'Google Play није потврдио ову куповину за Vinoozy.';

  @override
  String get plusOwnedByOther =>
      'Ова претплата већ припада другом Vinoozy налогу.';

  @override
  String get plusVerificationUnavailable =>
      'Куповина тренутно не може да се провери. Пробајте поново касније: претплата остаје на Google Play-у.';

  @override
  String get capacityLimitTitle => 'Достигли сте ограничење бесплатног плана';

  @override
  String capacityLimitBody(int limit) {
    return 'Бесплатан план обухвата до $limit различитих вина у подруму. Увек можете да мењате, пијете и додајете боце винима која већ имате. Да бисте додали ново, довршите или обришите неко вино, или пређите на Plus.';
  }

  @override
  String capacityLimitBodyComingSoon(int limit) {
    return 'Бесплатан план обухвата до $limit различитих вина у подруму. Увек можете да мењате, пијете и додајете боце винима која већ имате. Да бисте додали ново, довршите или обришите неко вино. Plus стиже ускоро.';
  }

  @override
  String get rejectedCapacityLimit =>
      'Није синхронизовано: прелази ограничење броја вина бесплатног плана. Измена остаје на овом телефону.';

  @override
  String get rejectedCapacityConflict =>
      'Није синхронизовано: подрум је истовремено промењен на другом уређају. Измена остаје на овом телефону: пробајте поново.';

  @override
  String writeRejectedCapacityLimit(String name) {
    return '$name: није синхронизовано, прелази ограничење бесплатног плана';
  }

  @override
  String writeRejectedCapacityConflict(String name) {
    return '$name: није синхронизовано, подрум је промењен на другом уређају';
  }

  @override
  String get freeIntroTitle => 'Бесплатан план';

  @override
  String freeIntroLimit(int limit) {
    return 'Бесплатно можете да водите до $limit различитих вина.';
  }

  @override
  String get freeIntroAds =>
      'Уз умерено коришћење нема огласа. Ако пређете месечни праг коришћења услуге, можда ћете повремено видети огласе који помажу да се покрију трошкови сервера и синхронизације.';

  @override
  String get freeIntroNoAds => 'Без огласа у почетној верзији.';

  @override
  String get freeIntroPlus => 'Уз Plus уклањате огласе и ограничење подрума.';

  @override
  String get noticeGotIt => 'Разумем';

  @override
  String get thresholdTitle => 'Огласи помажу да Vinoozy остане бесплатан';

  @override
  String get thresholdBody =>
      'Достигли сте месечни праг коришћења без огласа. Од сада ћете можда повремено видети огласе: помажу нам да покријемо трошкове сервера и синхронизације, како би Vinoozy остао бесплатан.';

  @override
  String get thresholdReset =>
      'Бројање почиње поново следећег месеца. Уз Plus можете да користите апликацију без огласа и без ограничења подрума.';

  @override
  String thresholdNextReset(String date) {
    return 'Следеће ресетовање: $date';
  }

  @override
  String get thresholdHowItWorks => 'Како функционише';

  @override
  String get thresholdHowItWorksBody =>
      'Праг зависи од приближног броја синхронизација са облаком које је овај налог обавио током месеца. Само коришћење офлајн не ствара нове операције у облаку. Огласи се приказују највише једном дневно, само на Прегледу, и никада док чувате или извозите своје податке.';

  @override
  String get adLabel => 'Оглас';

  @override
  String get devToolsTitle => 'Алатке за програмере';

  @override
  String get devUnlockAll => 'Откључај све — тест Plus';

  @override
  String get devSimulateFree => 'Симулирај бесплатан план';

  @override
  String get devSimulateExpired => 'Симулирај истекли Plus';

  @override
  String get devRestore => 'Врати уобичајено стање';

  @override
  String get devNoOverride => 'Нема активне симулације';

  @override
  String get devApplied => 'Сценарио је примењен и у Firestore емулатору';

  @override
  String get devIncomplete =>
      'Непотпуна симулација: Firestore емулатор није потврдио тест право. Правила сервера не виде овај сценарио.';

  @override
  String get devNotice =>
      'Само за развојне верзије са емулатором: без плаћања, токена и рачуна.';
}
