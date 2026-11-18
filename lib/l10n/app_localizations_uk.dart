// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'Vinoozy';

  @override
  String get signInTagline => 'Ваш льох — у слушний час';

  @override
  String get signInWithGoogle => 'Продовжити з Google';

  @override
  String get signInInProgress => 'Вхід';

  @override
  String get signInFailed => 'Не вдалося ввійти';

  @override
  String get signInNeedsNetwork => 'Для першого входу потрібне з’єднання';

  @override
  String get signInSessionExpired => 'Сеанс завершився: увійдіть знову';

  @override
  String get retry => 'Повторити';

  @override
  String get cancel => 'Скасувати';

  @override
  String blockedMessage(String email) {
    return 'Є зміни облікового запису $email, ще не збережені в хмарі: увійдіть у цей обліковий запис і під’єднайтеся до мережі';
  }

  @override
  String blockedSignInWith(String email) {
    return 'Увійти як $email';
  }

  @override
  String blockedDiscard(String email) {
    return 'Видалити незбережені зміни облікового запису $email';
  }

  @override
  String get discardDialogTitle => 'Видалити зміни?';

  @override
  String discardDialogBody(int count, String email) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count вина облікового запису $email ще не збережено в хмарі, і їх буде видалено з цього телефона.',
      many:
          '$count вин облікового запису $email ще не збережено в хмарі, і їх буде видалено з цього телефона.',
      few:
          '$count вина облікового запису $email ще не збережено в хмарі, і їх буде видалено з цього телефона.',
      one:
          '$count вино облікового запису $email ще не збережено в хмарі, і його буде видалено з цього телефона.',
    );
    return '$_temp0';
  }

  @override
  String get discardConfirm => 'Видалити';

  @override
  String get resetFailed => 'Не вдалося очистити дані на цьому телефоні';

  @override
  String get restartRequired => 'Перезапустіть застосунок, щоб завершити';

  @override
  String get restartCloseApp => 'Закрити застосунок';

  @override
  String get startupFailed => 'Не вдалося запустити застосунок';

  @override
  String get cellarTitle => 'Льох';

  @override
  String get defaultCellarName => 'Мій льох';

  @override
  String get cellarLoading => 'Підготовка льоху';

  @override
  String get cellarSetupFailed => 'Не вдалося підготувати льох';

  @override
  String get cellarEmpty => 'Ваш льох порожній';

  @override
  String get addWine => 'Додати';

  @override
  String get estimatePending => 'Прогноз готується';

  @override
  String get noVintage => 'Без року урожаю';

  @override
  String bottleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count пляшки',
      many: '$count пляшок',
      few: '$count пляшки',
      one: '$count пляшка',
    );
    return '$_temp0';
  }

  @override
  String get syncInProgress => 'Синхронізація';

  @override
  String get syncOffline => 'Офлайн – синхронізація очікує';

  @override
  String writeRejected(String name) {
    return 'Зміну не дозволено: $name';
  }

  @override
  String get saveFailed => 'Не вдалося зберегти, спробуйте ще раз';

  @override
  String wineNotSaved(String name) {
    return 'Вино $name не збережено в хмарі';
  }

  @override
  String get addAgain => 'Додати знову';

  @override
  String get ignore => 'Ігнорувати';

  @override
  String get addWineTitle => 'Ввести';

  @override
  String get wineNameLabel => 'Вино';

  @override
  String get vintageLabel => 'Рік урожаю';

  @override
  String get quantityLabel => 'Кількість';

  @override
  String get decreaseQuantity => 'Зменшити кількість';

  @override
  String get increaseQuantity => 'Збільшити кількість';

  @override
  String get save => 'Зберегти';

  @override
  String get nameRequired => 'Введіть назву вина';

  @override
  String get nameTooLong => 'Не більше 120 символів';

  @override
  String vintageRange(String year) {
    return 'Рік урожаю від 1900 до $year';
  }

  @override
  String get offAttribution => 'Дані з Open Food Facts (ODbL)';

  @override
  String get dashboardTitle => 'Огляд';

  @override
  String dashboardTotalBottles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count пляшки в льоху',
      many: '$count пляшок у льоху',
      few: '$count пляшки в льоху',
      one: '$count пляшка в льоху',
    );
    return '$_temp0';
  }

  @override
  String get dashboardSyncing => 'Синхронізація льоху…';

  @override
  String get dashboardAddFirstWine => 'Додайте перше вино';

  @override
  String get drinkSoonTitle => 'Випити незабаром';

  @override
  String get drinkSoonEmpty => 'Немає пляшок, які час випити незабаром';

  @override
  String drinkSoonUntil(String year) {
    return 'до $year р.';
  }

  @override
  String drinkSoonSeeAll(int count) {
    return 'Показати всі ($count)';
  }

  @override
  String get statusChartTitle => 'Стан пляшок';

  @override
  String get statusWaiting => 'зачекати';

  @override
  String get statusReady => 'готові';

  @override
  String get statusDrinkSoon => 'випити незабаром';

  @override
  String get statusPastWindow => 'після вікна';

  @override
  String toEstimateNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count пляшки без прогнозу',
      many: '$count пляшок без прогнозу',
      few: '$count пляшки без прогнозу',
      one: '$count пляшка без прогнозу',
    );
    return '$_temp0';
  }

  @override
  String chartBarValue(String label, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count пляшки',
      many: '$count пляшок',
      few: '$count пляшки',
      one: '$count пляшка',
    );
    return '$label: $_temp0';
  }

  @override
  String chartDescription(String title, String values) {
    return '$title: $values';
  }

  @override
  String get openListHint => 'Відкрити список';

  @override
  String get peakChartTitle => 'Рік піку';

  @override
  String get peakPast => 'пік минув';

  @override
  String get peakBeyond => 'пізніше';

  @override
  String get breakdownTypeTitle => 'Пляшки за типом';

  @override
  String get breakdownRegionTitle => 'Пляшки за регіоном';

  @override
  String get breakdownType => 'Тип';

  @override
  String get breakdownRegion => 'Регіон';

  @override
  String get familyRed => 'червоне';

  @override
  String get familyWhite => 'біле';

  @override
  String get familyRose => 'рожеве';

  @override
  String get familySparkling => 'ігристе';

  @override
  String get familySweet => 'солодке';

  @override
  String get breakdownUnspecified => 'не вказано';

  @override
  String get breakdownOtherRegions => 'інші';

  @override
  String get ok => 'OK';

  @override
  String get cellarMenu => 'Меню льоху';

  @override
  String get sharingPeopleTitle => 'Люди';

  @override
  String get sharingInviteTitle => 'Запросити людину';

  @override
  String get sharingEmailLabel => 'Електронна адреса Google';

  @override
  String get sharingPermissionRead => 'Лише перегляд';

  @override
  String get sharingPermissionReadHint =>
      'Бачить вина, прогнози, огляд і випиті пляшки';

  @override
  String get sharingPermissionEdit => 'Може редагувати';

  @override
  String get sharingPermissionEditHint =>
      'Також додає і змінює вина та позначає випиті пляшки';

  @override
  String get sharingRoleOwner => 'власник';

  @override
  String get sharingInviteButton => 'Запросити';

  @override
  String sharingPlacesUsed(int used, int max) {
    return 'Люди: $used/$max';
  }

  @override
  String get sharingInvalidEmail => 'Введіть дійсну електронну адресу';

  @override
  String get sharingSelfInvite => 'Ви не можете запросити себе';

  @override
  String get sharingAlreadyInvited => 'Цю людину вже запрошено';

  @override
  String sharingLimitReached(int max) {
    return 'Досягнуто ліміту людей: $max';
  }

  @override
  String get sharingNotOwner =>
      'Ви не можете змінювати спільний доступ до цього льоху';

  @override
  String get sharingNotFound => 'Цієї людини вже немає у списку';

  @override
  String get sharingFailed => 'Не вдалося, спробуйте ще раз';

  @override
  String get sharingInviteFailed =>
      'Не вдалося надіслати запрошення. Спробуйте ще раз';

  @override
  String get sharingOfflineHint =>
      'Щоб керувати спільним доступом, потрібне з’єднання';

  @override
  String get sharingStatusInvited => 'запрошення надіслано';

  @override
  String get sharingStatusActive => 'має доступ';

  @override
  String get sharingStatusRevoked => 'доступ відкликано';

  @override
  String get sharingStatusLeft => 'льох залишено';

  @override
  String sharingMemberSemantics(String name, String permission, String status) {
    return '$name, $permission, $status';
  }

  @override
  String get sharingClosedSection => 'Закриті доступи';

  @override
  String get sharingNobody => 'Цей льох поки що не бачить ніхто інший';

  @override
  String sharingChangePermission(String name) {
    return 'Змінити дозвіл користувача $name';
  }

  @override
  String get sharingRevoke => 'Відкликати';

  @override
  String sharingRevokeTitle(String name) {
    return 'Відкликати доступ користувача $name?';
  }

  @override
  String sharingRevokeConfirmLabel(String name) {
    return 'Введіть $name для підтвердження';
  }

  @override
  String get sharingRevokeDisabledHint =>
      'Стане активною, коли ім’я збігатиметься';

  @override
  String get sharingReinvite => 'Запросити знову';

  @override
  String get sharingDeleteForGood => 'Видалити остаточно';

  @override
  String sharingOwnedBy(String owner) {
    return 'Льох користувача $owner';
  }

  @override
  String get sharingYourCellar => 'Ваш льох';

  @override
  String sharingYourPermission(String permission) {
    return 'Ваш дозвіл: $permission';
  }

  @override
  String sharingSwitcherSemantics(String cellar, String permission) {
    return '$cellar, $permission. Торкніться, щоб змінити льох';
  }

  @override
  String get sharingLeave => 'Залишити цей льох';

  @override
  String sharingLeaveTitle(String owner) {
    return 'Залишити льох користувача $owner?';
  }

  @override
  String sharingLeaveBody(String owner) {
    return 'Ви його більше не бачитимете. Користувач $owner може запросити вас знову.';
  }

  @override
  String get sharingLeaveConfirm => 'Залишити';

  @override
  String sharingSharedNotice(String owner) {
    return 'Користувач $owner ділиться з вами своїм льохом';
  }

  @override
  String sharingAccessLost(String owner) {
    return 'Ви більше не маєте доступу до льоху користувача $owner';
  }

  @override
  String sharingWritesLost(String owner) {
    return 'Деякі зміни в льоху користувача $owner не збережено, бо ви більше не маєте доступу';
  }

  @override
  String get sharingSomeone => 'без імені';

  @override
  String get sharingShareSubject => 'Запрошення до Vinoozy';

  @override
  String sharingShareMessage(
    String owner,
    String cellar,
    String link,
    String email,
  ) {
    return '$owner запрошує вас до льоху «$cellar» у Vinoozy. Установіть застосунок за посиланням $link і ввійдіть з обліковим записом Google $email: використовуйте саме цю адресу.';
  }

  @override
  String get cellarSearchHint => 'Пошук за назвою або виробником';

  @override
  String get cellarFilterStatus => 'Стан';

  @override
  String get cellarFilterType => 'Тип';

  @override
  String get statusToEstimate => 'Без прогнозу';

  @override
  String get filterTypeUnspecified => 'Не вказано';

  @override
  String get cellarNoMatches => 'Немає вин із такими фільтрами';

  @override
  String get cellarClearFilters => 'Скинути фільтри';

  @override
  String get cellarArchiveTitle => 'Випиті';

  @override
  String get cellarArchiveEmpty => 'Поки що немає допитих вин';

  @override
  String get cellarArchiveFailed => 'Не вдалося завантажити допиті вина';

  @override
  String get wineDrink => 'Випито';

  @override
  String wineDrinkTooltip(String name) {
    return 'Позначити пляшку вина $name як випиту';
  }

  @override
  String confidenceLabel(String level) {
    return 'Надійність: $level';
  }

  @override
  String get confidenceHigh => 'висока';

  @override
  String get confidenceMedium => 'середня';

  @override
  String get confidenceLow => 'низька';

  @override
  String get windowStartLabel => 'Початок';

  @override
  String get windowPeakLabel => 'Пік';

  @override
  String get windowEndLabel => 'Кінець';

  @override
  String estimateSourceLabel(String source) {
    return 'Джерело: $source';
  }

  @override
  String get estimateSourceCatalog => 'база вин';

  @override
  String get estimateSourceType => 'прогноз за типом';

  @override
  String get estimateSourceCorrected =>
      'прогноз, уточнений за вашими випитими пляшками';

  @override
  String get estimateDisclaimer =>
      'Орієнтовний прогноз: він залежить і від того, як зберігалася пляшка';

  @override
  String get estimateUnavailable => 'Прогноз недоступний';

  @override
  String get pairingsTitle => 'Поєднання';

  @override
  String get pairingsGeneric => 'загальні поєднання для типу';

  @override
  String get pairingBraisedRedMeat => 'Тушковане червоне м’ясо';

  @override
  String get pairingGrilledRedMeat => 'Червоне м’ясо на грилі';

  @override
  String get pairingGame => 'Дичина';

  @override
  String get pairingRoastPoultry => 'Запечена птиця';

  @override
  String get pairingPoultry => 'Птиця';

  @override
  String get pairingPork => 'Свинина';

  @override
  String get pairingCuredMeats => 'В’ялені м’ясні вироби';

  @override
  String get pairingPastaMeatSauce => 'Паста з м’ясним соусом';

  @override
  String get pairingMushroomsTruffle => 'Гриби й трюфелі';

  @override
  String get pairingAgedCheese => 'Витримані сири';

  @override
  String get pairingFreshCheese => 'Свіжі сири';

  @override
  String get pairingBlueCheese => 'Блакитні сири';

  @override
  String get pairingFish => 'Риба';

  @override
  String get pairingSeafood => 'Морепродукти';

  @override
  String get pairingRawSeafood => 'Сирі морепродукти';

  @override
  String get pairingFriedFood => 'Смажені страви';

  @override
  String get pairingVegetables => 'Овочі';

  @override
  String get pairingRisotto => 'Ризото';

  @override
  String get pairingPizza => 'Піца';

  @override
  String get pairingAperitif => 'Аперитив';

  @override
  String get pairingPastries => 'Випічка';

  @override
  String get pairingDryBiscuits => 'Сухе печиво';

  @override
  String get pairingChocolate => 'Шоколад';

  @override
  String get pairingDriedFruit => 'Горіхи та сухофрукти';

  @override
  String get pairingSpicyDishes => 'Гострі страви';

  @override
  String get recentDrinksTitle => 'Останні випиті';

  @override
  String get noDrinksYet => 'Поки що немає випитих пляшок';

  @override
  String get wineEdit => 'Редагувати';

  @override
  String get wineDelete => 'Видалити';

  @override
  String get wineFinished => 'Закінчилося: пляшок не лишилося';

  @override
  String get wineLoadFailed => 'Не вдалося відкрити вино';

  @override
  String get wineNotFound => 'Цього вина більше немає';

  @override
  String drinkDone(String name) {
    return 'Позначено як випите: $name';
  }

  @override
  String get drinkUndo => 'Відмінити';

  @override
  String get drinkAddNotes => 'Додати оцінку й нотатки';

  @override
  String get nothingToUndo => 'Більше нічого відміняти';

  @override
  String get cellarUndoRejected =>
      'Не вдалося відмінити: пляшка лишається позначеною як випита';

  @override
  String get cellarDeleteFailed =>
      'Видалення ще не завершено: воно закінчиться, щойно буде змога';

  @override
  String get duplicateFull =>
      'Це вино вже має 99 пляшок: більше додати не можна.';

  @override
  String get recordSheetTitle => 'Оцінка й нотатки';

  @override
  String get recordRatingLabel => 'Оцінка';

  @override
  String ratingStar(int n) {
    return 'Оцінка $n з 5';
  }

  @override
  String get recordNotesLabel => 'Нотатки';

  @override
  String get recordNotesTooLong => 'Не більше 1000 символів';

  @override
  String recordDateLabel(String date) {
    return 'Дата: $date';
  }

  @override
  String get recordDateInvalid =>
      'Дата не може бути в майбутньому або раніше року урожаю';

  @override
  String get recordConditionTitle => 'Яким воно було?';

  @override
  String get conditionTooYoung => 'Ще занадто молоде';

  @override
  String get conditionJustRight => 'Саме вчасно';

  @override
  String get conditionPastPeak => 'Пік уже минув';

  @override
  String get recordNoCondition => 'Без відповіді';

  @override
  String get producerLabel => 'Виробник (необов’язково)';

  @override
  String get producerTooLong => 'Не більше 120 символів';

  @override
  String producerAddNew(String name) {
    return 'Додати «$name» як нового виробника';
  }

  @override
  String get wineTypeLabel => 'Тип';

  @override
  String get typeRedLight => 'Легке червоне';

  @override
  String get typeRedStructured => 'Повнотіле червоне';

  @override
  String get typeWhite => 'Біле';

  @override
  String get typeRose => 'Рожеве';

  @override
  String get typeSparklingClassic => 'Ігристе, класичний метод';

  @override
  String get typeSparklingTank => 'Ігристе, метод Шарма';

  @override
  String get typeSweet => 'Солодке';

  @override
  String get typeFortified => 'Кріплене';

  @override
  String get suggestionFromCellar => 'У вашому льоху';

  @override
  String get suggestionsLabel => 'Пропозиції';

  @override
  String get duplicateTitle => 'Уже є в льоху';

  @override
  String duplicateBody(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count пляшки',
      many: '$count пляшок',
      few: '$count пляшки',
      one: '$count пляшка',
      zero: 'жодної пляшки',
    );
    return '$name уже є: $_temp0. Додати нові пляшки до цього вина?';
  }

  @override
  String duplicateAdd(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Додати $count пляшки',
      many: 'Додати $count пляшок',
      few: 'Додати $count пляшки',
      one: 'Додати $count пляшку',
    );
    return '$_temp0';
  }

  @override
  String get duplicateBanner => 'Можливий дублікат';

  @override
  String get duplicateMerge => 'Об’єднати';

  @override
  String get duplicateDeleteHint => 'Видаліть цей запис, якщо це дублікат';

  @override
  String get mergeTitle => 'Об’єднати два записи?';

  @override
  String get mergeBody =>
      'Пляшки з цього запису перейдуть до старішого, а цей запис буде видалено.';

  @override
  String get editWineTitle => 'Редагування вина';

  @override
  String get editDuplicate =>
      'Уже є інше вино з такою самою назвою, виробником і роком урожаю';

  @override
  String deleteWineTitle(String name) {
    return 'Видалити $name?';
  }

  @override
  String get deleteWineBody =>
      'Вино й усі його випиті пляшки буде видалено. Це не можна відмінити.';

  @override
  String get historyTitle => 'Історія';

  @override
  String get historyEmpty => 'Тут ви знайдете пляшки, які випили';

  @override
  String get historyLoadFailed => 'Не вдалося завантажити історію';

  @override
  String drankOnLabel(String date) {
    return 'Випито $date';
  }

  @override
  String get addChoiceTitle => 'Додати вино';

  @override
  String get addChoicePhoto => 'Сфотографувати';

  @override
  String get addChoiceImport => 'Імпортувати фото';

  @override
  String get addChoiceWrite => 'Ввести';

  @override
  String get labelReading => 'Читаю етикетку…';

  @override
  String get labelRecognized => 'Розпізнано:';

  @override
  String get labelCorrect => 'Виправити';

  @override
  String get labelConfirm => 'Підтвердити';

  @override
  String get labelUnreadable => 'Не можу прочитати етикетку';

  @override
  String get labelWriteByHand => 'Ввести вручну';

  @override
  String get labelNotFound => 'Вино не знайдено: перевірте дані';

  @override
  String get labelCameraDenied =>
      'Щоб прочитати етикетку, мені потрібен доступ до камери';

  @override
  String get labelPhotosDenied =>
      'Щоб прочитати етикетку, мені потрібен доступ до фото';

  @override
  String get labelOpenSettings => 'Відкрити налаштування';

  @override
  String get labelCameraUnavailable => 'Камера недоступна';

  @override
  String get labelBarcodeNotFound =>
      'Штрихкод прочитано, але я не можу знайти вино';

  @override
  String get labelBarcodeFrontHint => 'Сфотографуйте лицьовий бік етикетки';

  @override
  String get labelSharedNotAllowed =>
      'Ви не можете додавати вина до цього льоху';

  @override
  String get labelSharedFirstOnly => 'Використано лише перше фото';

  @override
  String get labelSharedExpired =>
      'Не вдалося прочитати надіслане фото: поділіться ним ще раз';

  @override
  String get labelReplaceTitle =>
      'У вас є незбережене вино. Прочитати нове фото?';

  @override
  String get labelReplaceRead => 'Прочитати нове фото';

  @override
  String get labelReplaceKeep => 'Продовжити з відкритим';

  @override
  String get labelWineAdded => 'Вино додано до льоху';

  @override
  String get onboardingPage1Title => 'Ваш льох у кишені';

  @override
  String get onboardingPage1Body =>
      'Додавайте пляшки вручну або за фото етикетки — навіть без мережі.';

  @override
  String get onboardingPage2Title => 'У слушний час';

  @override
  String get onboardingPage2Body =>
      'Vinoozy прогнозує, коли кожне вино найкраще, і підказує, які пляшки відкрити першими.';

  @override
  String get onboardingPage3Title => 'Разом';

  @override
  String get onboardingPage3Body =>
      'Поділіться льохом щонайбільше з двома людьми й зберігайте історію кожної випитої пляшки.';

  @override
  String get onboardingSkip => 'Пропустити';

  @override
  String get onboardingNext => 'Далі';

  @override
  String get onboardingStart => 'Почати';

  @override
  String onboardingPageOf(int page) {
    return 'Сторінка $page з 3';
  }

  @override
  String get profileTitle => 'Профіль';

  @override
  String get profilePhoto => 'Фото профілю';

  @override
  String get profileSignOut => 'Вийти';

  @override
  String get profileDeleteAccount => 'Видалити обліковий запис';

  @override
  String get profilePrivacy => 'Політика конфіденційності';

  @override
  String get profilePrivacyBody =>
      'Політику конфіденційності можна прочитати за цією адресою:';

  @override
  String get profileOpenLink => 'Відкрити в браузері';

  @override
  String get profileOpenLinkFailed =>
      'Не вдалося відкрити сторінку. Можете скопіювати посилання й відкрити його в браузері.';

  @override
  String get profileCopyLink => 'Копіювати посилання';

  @override
  String get profileLinkCopied => 'Посилання скопійовано';

  @override
  String get close => 'Закрити';

  @override
  String get signOutConfirmTitle => 'Вийти з облікового запису?';

  @override
  String signOutPendingWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'У вас є $count ще не збереженої зміни. Якщо ви вийдете й увійде інший обліковий запис, їх буде втрачено.',
      many:
          'У вас є $count ще не збережених змін. Якщо ви вийдете й увійде інший обліковий запис, їх буде втрачено.',
      few:
          'У вас є $count ще не збережені зміни. Якщо ви вийдете й увійде інший обліковий запис, їх буде втрачено.',
      one:
          'У вас є $count ще не збережена зміна. Якщо ви вийдете й увійде інший обліковий запис, її буде втрачено.',
    );
    return '$_temp0';
  }

  @override
  String get signOutStayAndSync => 'Залишитися й синхронізувати';

  @override
  String get signOutAnyway => 'Усе одно вийти';

  @override
  String get syncAllSaved => 'Усе збережено';

  @override
  String syncStillPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ще $count зміни чекають на збереження: перевірте мережу',
      many: 'Ще $count змін чекають на збереження: перевірте мережу',
      few: 'Ще $count зміни чекають на збереження: перевірте мережу',
      one: 'Ще $count зміна чекає на збереження: перевірте мережу',
    );
    return '$_temp0';
  }

  @override
  String get signOutFailed => 'Не вдалося вийти. Спробуйте ще раз';

  @override
  String get signInAccountDeleted => 'Обліковий запис видалено';

  @override
  String get deleteAccountIntro => 'Назавжди буде видалено:';

  @override
  String get deleteAccountItemCellar => 'Ваш льох із винами та історією';

  @override
  String get deleteAccountItemShares =>
      'Надані вами доступи: запрошені люди втратять доступ';

  @override
  String get deleteAccountItemMemberships =>
      'Вашу участь у чужих льохах: ваші випиті пляшки залишаться там без вашого імені';

  @override
  String get deleteAccountItemProfile => 'Ваш профіль';

  @override
  String deleteAccountPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'У вас є $count ще не збереженої зміни: їх буде збережено, а потім видалено разом з усім іншим',
      many:
          'У вас є $count ще не збережених змін: їх буде збережено, а потім видалено разом з усім іншим',
      few:
          'У вас є $count ще не збережені зміни: їх буде збережено, а потім видалено разом з усім іншим',
      one:
          'У вас є $count ще не збережена зміна: її буде збережено, а потім видалено разом з усім іншим',
    );
    return '$_temp0';
  }

  @override
  String get deleteAccountConfirmWord => 'ВИДАЛИТИ';

  @override
  String deleteAccountTypeWord(String word) {
    return 'Введіть $word для підтвердження';
  }

  @override
  String get deleteAccountReauthHint =>
      'Потім ви знову ввійдете через Google, щоб підтвердити, що це ви.';

  @override
  String get deleteAccountForever => 'Видалити назавжди';

  @override
  String get deleteAccountNeedsNetwork =>
      'Під’єднайтеся до інтернету, щоб видалити обліковий запис';

  @override
  String get deleteAccountSameAccount =>
      'Для видалення потрібно ввійти з тим самим обліковим записом';

  @override
  String get deletionTitle => 'Видалення облікового запису';

  @override
  String get deletionStepPreparePhone => 'Збереження змін, що очікують';

  @override
  String get deletionStepMarkStarted => 'Початок видалення';

  @override
  String get deletionStepLeaveOtherCellars => 'Вихід із чужих льохів';

  @override
  String get deletionStepCloseOwnInvitations =>
      'Закриття наданих вами доступів';

  @override
  String get deletionStepDeleteWinesAndRecords => 'Видалення вин та історії';

  @override
  String get deletionStepDeleteCellar => 'Видалення льоху';

  @override
  String get deletionStepDeleteProfileAndUser =>
      'Видалення профілю й облікового запису';

  @override
  String get deletionStepCleanUpPhone => 'Очищення цього телефона';

  @override
  String deletionStepAnnounce(int step, String label) {
    return 'Крок $step з 8: $label';
  }

  @override
  String deletionDeletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Видалено $count запису: вина й випиті пляшки',
      many: 'Видалено $count записів: вина й випиті пляшки',
      few: 'Видалено $count записи: вина й випиті пляшки',
      one: 'Видалено $count запис: вино або випиту пляшку',
    );
    return '$_temp0';
  }

  @override
  String get deletionResumeHint =>
      'Видалення цього облікового запису не завершено. Увійдіть знову через Google, щоб завершити його.';

  @override
  String get deletionContinue => 'Продовжити';

  @override
  String get deletionOffline =>
      'Під’єднайтеся до інтернету, щоб завершити видалення';

  @override
  String get deletionPendingWrites =>
      'Не можу зберегти зміни, що очікують. Спробуйте ще раз';

  @override
  String get deletionFailed =>
      'Не вдалося завершити видалення. Спробуйте ще раз';

  @override
  String get uxCountryLabel => 'Країна';

  @override
  String get uxCountryOther => 'Інша країна…';

  @override
  String get uxCountryNone => 'Без країни';

  @override
  String get uxAllCountriesTitle => 'Усі країни й території';

  @override
  String get uxAllCountriesSearch => 'Пошук країни';

  @override
  String get uxAllCountriesRare => 'Рідкісні для вина';

  @override
  String get uxAllCountriesAll => 'Усі, від А до Я';

  @override
  String get uxAllCountriesNone => 'Країну не знайдено';

  @override
  String get uxRegionLabel => 'Регіон';

  @override
  String uxRegionOf(String country) {
    return 'Регіон · $country';
  }

  @override
  String get uxRegionOther => 'Інший регіон';

  @override
  String get uxRegionFieldLabel => 'Введіть регіон';

  @override
  String get uxRegionTooLong => 'Не більше 120 символів';

  @override
  String get uxDrinkAction => 'Випито';

  @override
  String uxDrinkActionTooltip(String name) {
    return 'Випито пляшку вина $name';
  }

  @override
  String get uxDrinkActionDetail => 'Випито пляшку';

  @override
  String get uxDrinkSheetLabel => 'Підтвердження випитої пляшки';

  @override
  String get uxDrinkSheetBottles => 'Пляшки';

  @override
  String uxDrinkSheetBottlesChange(int before, int after) {
    return 'Пляшки: було $before, стане $after';
  }

  @override
  String get uxDrinkSheetRating => 'Яким воно було? (необов’язково)';

  @override
  String uxDrinkSheetStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count зірки з 5',
      many: '$count зірок із 5',
      few: '$count зірки з 5',
      one: '$count зірка з 5',
    );
    return '$_temp0';
  }

  @override
  String get uxDrinkSheetConfirm => 'Так, випито';

  @override
  String get uxRemoveBottle => 'Прибрати пляшку, не позначаючи випитою';

  @override
  String get uxRemoveBottleTitle => 'Прибрати пляшку?';

  @override
  String uxRemoveBottleBody(String name) {
    return 'Одну пляшку вина $name буде прибрано без позначки «випито».';
  }

  @override
  String get uxRemoveBottleConfirm => 'Прибрати';

  @override
  String get uxIdealTitle => 'Ідеальний момент';

  @override
  String uxIdealUntil(String year) {
    return 'Рекомендовано до $year р.';
  }

  @override
  String uxIdealUntilPast(String year) {
    return 'Рекомендовано до $year р.: цей час минув';
  }

  @override
  String uxIdealBest(String start, String end) {
    return 'Найкраще з $start до $end р.';
  }

  @override
  String uxIdealBar(String start, String end) {
    return 'Вікно споживання з $start до $end р.';
  }

  @override
  String get uxIdealDisclaimer =>
      '⚠︎ Орієнтовно: прогноз за типом, апелласьйоном і роком урожаю. Зберігання й конкретна пляшка можуть його змінити.';

  @override
  String get uxIdealUnavailableHint =>
      'Додайте рік урожаю й тип, щоб отримати прогноз.';

  @override
  String uxDashboardDrinkNow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count пляшки час пити зараз',
      many: '$count пляшок час пити зараз',
      few: '$count пляшки час пити зараз',
      one: '$count пляшку час пити зараз',
    );
    return '$_temp0';
  }

  @override
  String get uxFamilyRed => 'Червоне';

  @override
  String get uxFamilyWhite => 'Біле';

  @override
  String get uxFamilyRose => 'Рожеве';

  @override
  String get uxFamilySparkling => 'Ігристе';

  @override
  String get uxFamilySweet => 'Солодке';

  @override
  String get labelBackTitle => 'Тепер зворотний бік';

  @override
  String get labelBackHint =>
      'На зворотному боці зазвичай є штрихкод, виробник і рік урожаю: вони допомагають знайти вино.';

  @override
  String get labelBackTake => 'Сфотографувати зворотний бік';

  @override
  String get labelBackGallery => 'Вибрати з галереї';

  @override
  String get labelBackSkip => 'Пропустити';

  @override
  String get labelStepFront => 'Лицьовий бік';

  @override
  String get labelStepBack => 'Зворотний бік';

  @override
  String get labelStepBarcode => 'Штрихкод';

  @override
  String get labelStepDatabase => 'База вин на телефоні';

  @override
  String get labelStepPending => 'Очікує';

  @override
  String get labelStepRunning => 'Триває…';

  @override
  String get labelStepDone => 'Готово';

  @override
  String get labelStepSkipped => 'Пропущено';

  @override
  String get labelStepFailed => 'Не читається';

  @override
  String labelStepStatus(String step, String status) {
    return '$step: $status';
  }

  @override
  String get labelOnPhoneNote =>
      'Усе відбувається на телефоні: фото нікому не надсилаються.';

  @override
  String get labelBackUnreadable => 'Зворотний бік не читається';

  @override
  String get labelSourceOffline => 'З бази на телефоні · офлайн';

  @override
  String get labelSourceCatalog => 'З каталогу';

  @override
  String get labelSourceOnline => 'З Open Food Facts · онлайн';

  @override
  String get labelNotThis => 'Це не воно';

  @override
  String get labelOffAttribution => 'Дані з Open Food Facts, ліцензія ODbL';

  @override
  String get labelCandidatesTitle => 'Яке з цих?';

  @override
  String labelCandidatesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count схожого вина',
      many: '$count схожих вин',
      few: '$count схожі вина',
      one: '$count схоже вино',
    );
    return '$_temp0';
  }

  @override
  String get labelCandidatesNone => 'Жодне з цих';

  @override
  String get labelChipOffline => 'офлайн';

  @override
  String get labelChipOnline => 'онлайн';

  @override
  String get labelChipCatalog => 'каталог';

  @override
  String get labelNoProducer => 'виробника не вказано';

  @override
  String get labelNoMatch => 'Етикетку прочитано, але я не розпізнаю вино';

  @override
  String get labelReadText => 'Прочитаний текст';

  @override
  String get labelSearchOnline => 'Шукати онлайн';

  @override
  String get labelOpenLens => 'Відкрити в Google Lens';

  @override
  String get labelLensLastResort =>
      'Google Lens — остання можливість: фото потрапить до застосунку Google, лише якщо ви підтвердите.';

  @override
  String get labelLensTitle => 'Відкрити в Google Lens?';

  @override
  String get labelLensBody =>
      'Фото лицьового боку буде передано застосунку Google на вашому телефоні або застосунку, який ви виберете; він може зберегти копію за власними правилами. Vinoozy не отримує результатів: поверніться сюди, щоб вибрати або ввести вино.';

  @override
  String get labelLensConfirm => 'Відкрити Google Lens';

  @override
  String get labelLensFailed =>
      'Не можу відкрити ні Google Lens, ні меню «Поділитися»';

  @override
  String get onlineSearchTitle => 'Шукати онлайн';

  @override
  String get onlineSearchSubtitle => 'Open Food Facts · лише вина';

  @override
  String get onlineSearchField => 'Слова для пошуку';

  @override
  String get onlineSearchHint => 'Перед пошуком слова можна змінити.';

  @override
  String get onlineSearchEmptyField => 'Введіть принаймні одне слово';

  @override
  String get onlineSearchButton => 'Шукати';

  @override
  String get onlineSearchLoading => 'Шукаю…';

  @override
  String onlineSearchResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count результату',
      many: '$count результатів',
      few: '$count результати',
      one: '$count результат',
    );
    return '$_temp0';
  }

  @override
  String get onlineSearchEmpty =>
      'Вин не знайдено: спробуйте інші слова або «Ввести вручну».';

  @override
  String get onlineSearchOffline =>
      'Немає мережі: шукаю лише в базі на телефоні.';

  @override
  String get onlineSearchRateLimited =>
      'Пошук онлайн зараз недоступний, спробуйте ще раз за кілька хвилин.';

  @override
  String get onlineSearchUnavailable =>
      'Пошук онлайн не ввімкнено в цій версії застосунку: шукаю лише в базі на телефоні.';

  @override
  String get aboutTitle => 'Про застосунок';

  @override
  String aboutVersion(String version) {
    return 'Версія $version';
  }

  @override
  String get aboutDbTitle => 'База вин';

  @override
  String aboutDbCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count вина',
      many: '$count вин',
      few: '$count вина',
      one: '$count вино',
    );
    return '$_temp0';
  }

  @override
  String aboutDbDate(String date) {
    return 'Експорт Open Food Facts від $date';
  }

  @override
  String get aboutDbSample =>
      'Пробна база: кілька тестових вин, введених вручну, а не дані Open Food Facts.';

  @override
  String get aboutDbLoading => 'Відкриваю базу вин…';

  @override
  String get aboutDbUnavailable => 'База вин недоступна в цій версії';

  @override
  String aboutDbSource(String url) {
    return 'Похідна база й інструмент, який її створює, розміщені в публічному репозиторії: $url';
  }

  @override
  String get aboutLicenseTitle => 'Ліцензії';

  @override
  String get aboutLicense =>
      'Містить інформацію з Open Food Facts, доступну за ліцензією Open Database License (ODbL). Окремий вміст поширюється за ліцензією Database Contents License (DbCL).';

  @override
  String get aboutPrivacyTitle => 'Фото етикеток';

  @override
  String get aboutPrivacy =>
      'Фото етикеток читаються на телефоні й видаляються, коли ви закриваєте результат. Вони залишають телефон, лише якщо ви торкнетеся «Відкрити в Google Lens» і підтвердите.';

  @override
  String get aboutAppellationsTitle => 'Апелласьйони';

  @override
  String get aboutAppellationsSource =>
      'Апелласьйони: реєстр eAmbrosia (ЄС) та офіційні національні реєстри.';

  @override
  String get aboutAppellationsSample =>
      'Пробна таблиця: витяг із реєстрів, введений вручну, доки не завантажено справжні реєстри.';

  @override
  String get denominationLabel => 'Апелласьйон';

  @override
  String get denominationTooLong => 'Не більше 120 символів';

  @override
  String get autofillFilledNotice =>
      'Заповнено з етикетки: перевірте й збережіть';

  @override
  String get autofillPastedNotice =>
      'Заповнено з тексту: перевірте й збережіть';

  @override
  String get autofillFromText => '✦ з тексту';

  @override
  String get autofillFromTextSemantics => 'заповнено з етикетки';

  @override
  String get autofillClear => 'Очистити';

  @override
  String get autofillLens => 'Lens';

  @override
  String get autofillClearTitle => 'Очистити форму?';

  @override
  String get autofillClearBody =>
      'Ви теж щось ввели в деякі поля. «Очистити» спорожнить назву, виробника, апелласьйон, рік урожаю, тип, країну, регіон і рівень. Кількість залишиться.';

  @override
  String get autofillClearConfirm => 'Очистити';

  @override
  String get autofillCleared => 'Форму очищено';

  @override
  String get autofillPasteTitle => 'Маєте текст із Google Lens?';

  @override
  String get autofillPasteHint =>
      'У Lens виділіть текст етикетки й торкніться «Копіювати», а потім поверніться сюди.';

  @override
  String get autofillPaste => 'Вставити з Lens';

  @override
  String get autofillOpenLens => 'З Google Lens';

  @override
  String get autofillOpenLensSemantics => 'відкриває Google Lens';

  @override
  String get autofillClipboardEmpty => 'У буфері обміну немає тексту';

  @override
  String get autofillNoNewFields => 'У тексті немає даних, які можна додати';

  @override
  String get autofillFromLens => 'Форму заповнено текстом із Lens';

  @override
  String get autofillShareEmpty => 'Текст не отримано';

  @override
  String get autofillShareUseTitle => 'Використати текст для порожніх полів?';

  @override
  String get autofillShareUse => 'Використати';

  @override
  String get autofillShareIgnore => 'Ігнорувати';

  @override
  String get addChoiceLens => 'З Google Lens';

  @override
  String get addChoicePhotoHint =>
      'Лицьовий і зворотний бік: Vinoozy читає етикетку.';

  @override
  String get addChoiceLensHint =>
      'Відкриває Lens: наведіть камеру, виділіть текст і торкніться «Поділитися» → Vinoozy.';

  @override
  String get addChoiceImportHint => 'Уже зроблене фото етикетки.';

  @override
  String get addChoiceWriteHint => 'Порожня форма з кнопкою «Вставити з Lens».';

  @override
  String get lensInstructionsTitle => 'Google Lens не вдається відкрити звідси';

  @override
  String get lensInstructionsStep1 =>
      'Відкрийте Google Lens і наведіть на етикетку';

  @override
  String get lensInstructionsStep2 => 'Виділіть текст етикетки';

  @override
  String get lensInstructionsStep3 => 'Торкніться «Поділитися» → Vinoozy';

  @override
  String get lensInstructionsOk => 'Зрозуміло';

  @override
  String get levelLabel => 'Рівень';

  @override
  String get levelEveryday => 'Щоденне (недороге)';

  @override
  String get levelGood => 'Добре';

  @override
  String get levelAging => 'Для витримки';

  @override
  String get levelNone => 'Немає';

  @override
  String get levelEverydayShort => 'випити рано';

  @override
  String get levelGoodShort => 'звичайний прогноз';

  @override
  String get levelAgingShort => 'живе довше';

  @override
  String get levelSuggested => 'запропоновано';

  @override
  String levelSuggestedReason(String qualifier) {
    return 'Запропоновано, бо назва містить «$qualifier»: так і збережеться, якщо не зміните. Виберіть інший або торкніться «Немає».';
  }

  @override
  String levelSuggestedSemantics(String qualifier) {
    return 'запропоновано, бо назва містить $qualifier';
  }

  @override
  String levelOptionSemantics(String option, int index, int count) {
    return 'Рівень, $option, $index з $count';
  }

  @override
  String get levelWhatChanges => 'Що змінюється';

  @override
  String get levelEverydayExamples =>
      'Вікно коротшає. Напр.: домашнє вино, Lambrusco, базове Prosecco, Bardolino, Vinho Verde.';

  @override
  String get levelGoodExamples =>
      'Звичайний прогноз і значення, коли нічого не вибрано. Напр.: Chianti Classico, Barbera d\'Asti Superiore, Rioja Crianza, Côtes du Rhône.';

  @override
  String get levelAgingExamples =>
      'Вікно довшає. Напр.: Barolo, Brunello, Amarone, Bordeaux Grand Cru, Rioja Gran Reserva, Porto Vintage.';

  @override
  String levelPreviewBefore(String start, String end) {
    return 'Було $start – $end';
  }

  @override
  String levelPreviewWith(String level, String start, String end) {
    return 'З «$level»: $start – $end';
  }

  @override
  String levelPreviewNow(String start, String end) {
    return 'Готове $start – до $end';
  }

  @override
  String levelDetail(String level) {
    return 'Рівень: $level';
  }

  @override
  String get overrideCorrect => 'Виправити';

  @override
  String get overrideRestore => 'Відновити прогноз';

  @override
  String get overrideCorrectedByYou => 'ваше виправлення';

  @override
  String overrideAppEstimate(String year) {
    return 'Прогноз застосунку: до $year р.';
  }

  @override
  String get overrideSheetTitle => 'Рекомендовано до';

  @override
  String overrideSheetHint(String start) {
    return 'Виберіть рік. Він не може бути раніше за «Готове з $start».';
  }

  @override
  String overridePeakNotice(String peak) {
    return 'Якщо вибрати рік раніше за $peak (найкраще), «найкраще» теж переміститься на цей рік.';
  }

  @override
  String get overrideMore => 'ще…';

  @override
  String get overrideSave => 'Зберегти виправлення';

  @override
  String overrideRestoreTitle(String year) {
    return 'Повернутися до прогнозу застосунку (до $year р.)?';
  }

  @override
  String get overrideRestoreConfirm => 'Відновити';

  @override
  String get overrideSaved => 'Виправлення збережено';

  @override
  String get overrideRestored => 'Прогноз відновлено';

  @override
  String get estimateSourceCorrectedByYou => 'ваше виправлення';

  @override
  String estimateFromDenomination(String name) {
    return 'Прогноз за апелласьйоном $name';
  }

  @override
  String estimateFromDenominationQualifier(String name, String qualifier) {
    return 'Прогноз за апелласьйоном $name, $qualifier';
  }

  @override
  String estimateFromGrape(String name) {
    return 'Прогноз за сортом винограду $name';
  }

  @override
  String get estimateFromType => 'Прогноз за типом вина';

  @override
  String get autofillReading => 'Читаю текст…';

  @override
  String get guideChip => 'Покрокова перевірка';

  @override
  String guideProgress(int n, int total) {
    return 'Питання $n з $total';
  }

  @override
  String get guideClose => 'Закрити';

  @override
  String get guideIsDenomination => 'це апелласьйон?';

  @override
  String get guideIsProducer => 'це виробник?';

  @override
  String get guideIsName => 'це назва вина?';

  @override
  String get guideIsVintage => 'Рік урожаю';

  @override
  String guideAskDenomination(String value) {
    return '$value — це апелласьйон?';
  }

  @override
  String guideAskProducer(String value) {
    return '$value — це виробник?';
  }

  @override
  String guideAskName(String value) {
    return '$value — це назва вина?';
  }

  @override
  String get guideAskVintage => 'Який рік урожаю?';

  @override
  String guideQuestionSemantics(int n, int total, String question) {
    return 'Питання $n з $total: $question';
  }

  @override
  String get guideNoProposal => 'У тексті цього не знайдено';

  @override
  String get guideYes => 'Так';

  @override
  String get guideNo => 'Ні, інше';

  @override
  String get guideEdit => 'Змінити';

  @override
  String get guideSkip => 'Пропустити';

  @override
  String get guideConfirm => 'Підтвердити';

  @override
  String get guideCancel => 'Скасувати';

  @override
  String guideRejected(String value) {
    return 'Не «$value»: ось наступний варіант';
  }

  @override
  String get guideNoMore =>
      'Інших варіантів немає: складіть самі або пропустіть';

  @override
  String guideProposalAnnounce(String value) {
    return 'Варіант: $value';
  }

  @override
  String get guideComposeLabel => 'Або складіть, торкаючись слів із тексту';

  @override
  String get guideComposePreview => 'Попередній перегляд';

  @override
  String get guideComposeEmpty => 'Торкніться одного або кількох слів';

  @override
  String get guideComposeLimit => 'До 8 слів і 80 символів';

  @override
  String guideTableMatchSemantics(String name) {
    return 'відповідає запису $name';
  }

  @override
  String guideLine(int n, int total) {
    return 'Рядок $n з $total';
  }

  @override
  String guideWordSelected(String word, int order) {
    return '$word, вибрано, $order';
  }

  @override
  String guideWordUnavailable(String word) {
    return '$word, недоступне';
  }

  @override
  String guideWordUsedFor(String word, String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'апелласьйон',
      'producer': 'виробник',
      'other': 'назва',
    });
    return '$word, уже в полі: $_temp0';
  }

  @override
  String guideUsedMark(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'апелласьйон',
      'producer': 'виробник',
      'other': 'назва',
    });
    return '$_temp0';
  }

  @override
  String guideOtherYears(String years) {
    return 'У тексті також: $years';
  }

  @override
  String get guideWheelFromText => 'рік, знайдений у тексті';

  @override
  String get guideWheelTypeYear => 'Введіть рік';

  @override
  String guideWheelConfirm(String year) {
    return 'Підтвердити $year';
  }

  @override
  String get guideNoVintage => 'Без року урожаю';

  @override
  String guideSkippedNotice(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'Апелласьйон пропущено',
      'producer': 'Виробника пропущено',
      'vintage': 'Рік урожаю пропущено',
      'other': 'Назву пропущено',
    });
    return '$_temp0: введіть вручну або продовжте перевірку';
  }

  @override
  String guideSkippedMany(int count) {
    return 'Пропущено полів: $count. Введіть їх вручну або продовжте перевірку';
  }

  @override
  String get guideInvalidValue =>
      'Цей текст містить символи, які не можна зберегти';

  @override
  String get brandStudio => 'Bottazzini Softworks';

  @override
  String get suggestedMark => '✦ запропоновано';

  @override
  String suggestedSemantics(String field, String value) {
    return '$field, $value, запропоновано';
  }

  @override
  String get restoreSuggestion => 'Відновити пропозицію';

  @override
  String get restoreSuggestionDone => 'Пропозицію відновлено';

  @override
  String get styleLabel => 'Стиль';

  @override
  String styleGroupSemantics(String value, int index, int count) {
    return 'Стиль, $value, $index з $count';
  }

  @override
  String get styleRedFresh => 'Свіже';

  @override
  String get styleRedMedium => 'Середнє';

  @override
  String get styleRedAge => 'Для витримки';

  @override
  String get styleRedLong => 'Тривала витримка';

  @override
  String get styleWhiteFresh => 'Свіже';

  @override
  String get styleWhiteMedium => 'Середнє';

  @override
  String get styleWhiteAge => 'Для витримки';

  @override
  String get styleRoseFresh => 'Свіже';

  @override
  String get styleClassicFresh => 'Свіже';

  @override
  String get styleClassicAge => 'Для витримки';

  @override
  String get styleTankFresh => 'Свіже';

  @override
  String get styleLambrusco => 'Lambrusco';

  @override
  String get styleSweetAromatic => 'Ароматне';

  @override
  String get styleSweetPassito => 'Passito';

  @override
  String get styleSweetBotrytis => 'Ботритизоване';

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
  String get styleFortifiedOther => 'Інше';

  @override
  String get profileNameRFresh => 'Фруктове червоне';

  @override
  String get profileNameRMedium => 'Червоне середнього тіла';

  @override
  String get profileNameRAge => 'Червоне для витримки';

  @override
  String get profileNameRLong => 'Червоне для тривалої витримки';

  @override
  String get profileNameWFresh => 'Свіже ароматне біле';

  @override
  String get profileNameWMedium => 'Біле середнього тіла';

  @override
  String get profileNameWAge => 'Біле для витримки';

  @override
  String get profileNameRoseFresh => 'Свіже рожеве';

  @override
  String get profileNameSpTank => 'Свіже ігристе, метод Шарма';

  @override
  String get profileNameLamFresh => 'Свіже Lambrusco';

  @override
  String get profileNameSpClassic => 'Свіже ігристе, класичний метод';

  @override
  String get profileNameSpClassicAge => 'Ігристе для витримки, класичний метод';

  @override
  String get profileNameSwAromatic => 'Молоде ароматне солодке вино';

  @override
  String get profileNameSwPassito => 'Солодке вино з підв’яленого винограду';

  @override
  String get profileNameSwBotrytis => 'Ботритизоване солодке вино';

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
  String get profileNameFortUnknown => 'Кріплене, стиль невідомий';

  @override
  String get profileNameUnknown => 'Стиль не визначено';

  @override
  String estimateFromProfile(String profile, String denomination) {
    return 'Прогноз за профілем «$profile» ($denomination)';
  }

  @override
  String estimateFromProfileType(String profile) {
    return 'Прогноз за профілем «$profile», за типом';
  }

  @override
  String estimateFromProfileGrape(String profile, String grape) {
    return 'Прогноз за профілем «$profile», за сортом винограду $grape';
  }

  @override
  String get estimateFromEntryDateDisgorgement =>
      'За датою додавання: додайте дату дегоржажу, щоб прогноз був точнішим';

  @override
  String get estimateFromEntryDateBottling =>
      'За датою додавання: додайте дату розливу, щоб прогноз був точнішим';

  @override
  String get styleToConfirmBanner =>
      '⚠︎ Стиль потрібно підтвердити: прогноз орієнтовний';

  @override
  String get chooseTypePrompt => 'Виберіть тип';

  @override
  String estimateUpdatedAnnouncement(String summary) {
    return 'Прогноз оновлено: $summary';
  }

  @override
  String get agingStartDisgorgement => 'Дегоржаж';

  @override
  String get agingStartBottling => 'Розлив';

  @override
  String get agingStartMonth => 'Місяць';

  @override
  String get agingStartYear => 'Рік';

  @override
  String get agingStartHint => 'Зазвичай це вказано на контретикетці.';

  @override
  String get agingStartIncomplete => 'Введіть місяць і рік';

  @override
  String get agingStartFuture => 'Дата не може бути в майбутньому';

  @override
  String get agingStartBeforeVintage => 'Не може бути раніше року урожаю';

  @override
  String get windowNoEnd => 'Готове, кінець не спрогнозовано';

  @override
  String get windowNoEndShort => 'кінець не спрогнозовано';

  @override
  String windowDrinkWithin(String date) {
    return 'до: $date';
  }

  @override
  String get levelNoEffect => 'Рівень не змінює цей прогноз';

  @override
  String get dashboardToConfirmTitle => 'Потребують підтвердження';

  @override
  String dashboardToConfirmCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count вина',
      many: '$count вин',
      few: '$count вина',
      one: '$count вино',
    );
    return '$_temp0';
  }

  @override
  String aboutDbClassified(String percent) {
    return '$percent% вин із розпізнаним типом';
  }

  @override
  String get planTitle => 'План';

  @override
  String get planFree => 'Безплатний';

  @override
  String get planPlus => 'Plus';

  @override
  String get planPlusGift => 'Plus (подарунок)';

  @override
  String get planDevUnlockAll => 'DEV · Тестовий Plus';

  @override
  String get planDevSimulateFree => 'DEV · Імітація безплатного плану';

  @override
  String get planDevSimulateExpired => 'DEV · Імітація простроченого Plus';

  @override
  String get planDiscoverPlus => 'Дізнатися про Plus';

  @override
  String get plusTitle => 'Vinoozy Plus';

  @override
  String get plusBenefitsTitle => 'З Plus';

  @override
  String get plusBenefitNoAds => 'Без реклами';

  @override
  String get plusBenefitNoLimit => 'Без ліміту вин у льоху';

  @override
  String get plusComingSoon => 'Plus незабаром з’явиться';

  @override
  String get plusLoading => 'Отримання цін із Google Play';

  @override
  String get plusStoreUnavailable =>
      'Не вдалося отримати ціни з Google Play. Спробуйте пізніше.';

  @override
  String plusPriceMonthly(String price) {
    return '$price на місяць';
  }

  @override
  String plusPriceAnnual(String price) {
    return '$price на рік';
  }

  @override
  String get plusRenewal =>
      'Підписка автоматично поновлюється за вказаною ціною, доки ви не скасуєте її в Google Play.';

  @override
  String get plusTerms =>
      'Оплата списується з вашого облікового запису Google Play, коли ви підтверджуєте покупку. Скасувати можна будь-коли: Plus діятиме до кінця вже оплаченого періоду. Коли Plus закінчиться, усі ваші вина залишаться.';

  @override
  String get plusRestore => 'Відновити покупки';

  @override
  String get plusManage => 'Керувати підпискою або скасувати її в Google Play';

  @override
  String get plusActive => 'Plus активний у цьому обліковому записі';

  @override
  String get plusActiveGift =>
      'Ви маєте Plus у подарунок: без списань і без поновлень.';

  @override
  String get plusPending =>
      'Оплата очікує: Plus стане активним, коли Google Play її підтвердить.';

  @override
  String get plusVerifying => 'Перевірка покупки';

  @override
  String get plusVerified =>
      'Покупку перевірено: Plus стане активним за кілька секунд.';

  @override
  String get plusPurchaseFailed => 'Покупку не завершено. Спробуйте ще раз.';

  @override
  String get plusInvalidPurchase =>
      'Google Play не підтвердив цю покупку для Vinoozy.';

  @override
  String get plusOwnedByOther =>
      'Ця підписка вже належить іншому обліковому запису Vinoozy.';

  @override
  String get plusVerificationUnavailable =>
      'Зараз не вдалося перевірити покупку. Спробуйте пізніше: підписка залишається в Google Play.';

  @override
  String get capacityLimitTitle => 'Досягнуто ліміту безплатного плану';

  @override
  String capacityLimitBody(int limit) {
    return 'Безплатний план охоплює до $limit різних вин у льоху. Ви завжди можете редагувати, пити й додавати пляшки до вин, які вже маєте. Щоб додати нове, допийте або видаліть якесь вино чи перейдіть на Plus.';
  }

  @override
  String capacityLimitBodyComingSoon(int limit) {
    return 'Безплатний план охоплює до $limit різних вин у льоху. Ви завжди можете редагувати, пити й додавати пляшки до вин, які вже маєте. Щоб додати нове, допийте або видаліть якесь вино. Plus незабаром з’явиться.';
  }

  @override
  String get rejectedCapacityLimit =>
      'Не синхронізовано: перевищено ліміт вин безплатного плану. Зміна залишається на цьому телефоні.';

  @override
  String get rejectedCapacityConflict =>
      'Не синхронізовано: льох одночасно змінено на іншому пристрої. Зміна залишається на цьому телефоні: спробуйте ще раз.';

  @override
  String writeRejectedCapacityLimit(String name) {
    return '$name: не синхронізовано, перевищено ліміт безплатного плану';
  }

  @override
  String writeRejectedCapacityConflict(String name) {
    return '$name: не синхронізовано, льох змінено на іншому пристрої';
  }

  @override
  String get freeIntroTitle => 'Безплатний план';

  @override
  String freeIntroLimit(int limit) {
    return 'Безплатно можна вести до $limit різних вин.';
  }

  @override
  String get freeIntroAds =>
      'За помірного користування реклами немає. Якщо ви перевищите місячний поріг користування сервісом, інколи може з’являтися реклама, яка допомагає покривати витрати на сервери й синхронізацію.';

  @override
  String get freeIntroNoAds => 'У стартовій версії реклами немає.';

  @override
  String get freeIntroPlus => 'З Plus ви прибираєте рекламу й ліміт льоху.';

  @override
  String get noticeGotIt => 'Зрозуміло';

  @override
  String get thresholdTitle =>
      'Реклама допомагає Vinoozy залишатися безплатним';

  @override
  String get thresholdBody =>
      'Ви досягли місячного порогу користування без реклами. Відтепер інколи може з’являтися реклама: вона допомагає нам покривати витрати на сервери й синхронізацію, щоб Vinoozy залишався безплатним.';

  @override
  String get thresholdReset =>
      'Відлік почнеться знову наступного місяця. З Plus можна користуватися застосунком без реклами й без ліміту льоху.';

  @override
  String thresholdNextReset(String date) {
    return 'Наступне скидання: $date';
  }

  @override
  String get thresholdHowItWorks => 'Як це працює';

  @override
  String get thresholdHowItWorksBody =>
      'Поріг залежить від приблизної кількості синхронізацій із хмарою, виконаних цим обліковим записом за місяць. Саме лише користування офлайн не створює нових операцій у хмарі. Реклама з’являється щонайбільше раз на день, лише на екрані «Огляд», і ніколи — під час збереження чи експорту ваших даних.';

  @override
  String get adLabel => 'Реклама';

  @override
  String get devToolsTitle => 'Інструменти розробника';

  @override
  String get devUnlockAll => 'Розблокувати все — тестовий Plus';

  @override
  String get devSimulateFree => 'Імітувати безплатний план';

  @override
  String get devSimulateExpired => 'Імітувати прострочений Plus';

  @override
  String get devRestore => 'Відновити звичайний стан';

  @override
  String get devNoOverride => 'Імітацію не ввімкнено';

  @override
  String get devApplied => 'Сценарій застосовано й в емуляторі Firestore';

  @override
  String get devIncomplete =>
      'Неповна імітація: емулятор Firestore не підтвердив тестове право. Правила сервера не бачать цього сценарію.';

  @override
  String get devNotice =>
      'Лише для збірок розробки з емулятором: без платежів, токенів і квитанцій.';
}
