// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Georgian (`ka`).
class AppLocalizationsKa extends AppLocalizations {
  AppLocalizationsKa([String locale = 'ka']) : super(locale);

  @override
  String get appTitle => 'Vinoozy';

  @override
  String get signInTagline => 'თქვენი მარანი — საჭირო დროს';

  @override
  String get signInWithGoogle => 'Google-ით გაგრძელება';

  @override
  String get signInInProgress => 'მიმდინარეობს შესვლა';

  @override
  String get signInFailed => 'შესვლა ვერ მოხერხდა';

  @override
  String get signInNeedsNetwork => 'პირველი შესვლისთვის საჭიროა კავშირი';

  @override
  String get signInSessionExpired => 'სესიის ვადა ამოიწურა: შედით ხელახლა';

  @override
  String get retry => 'ხელახლა ცდა';

  @override
  String get cancel => 'გაუქმება';

  @override
  String blockedMessage(String email) {
    return 'ანგარიშს $email აქვს ცვლილებები, რომლებიც ჯერ არ შენახულა ღრუბელში: შედით ამ ანგარიშით და დაუკავშირდით ქსელს';
  }

  @override
  String blockedSignInWith(String email) {
    return 'შესვლა: $email';
  }

  @override
  String blockedDiscard(String email) {
    return 'შეუნახავი ცვლილებების წაშლა ($email)';
  }

  @override
  String get discardDialogTitle => 'წაიშალოს ცვლილებები?';

  @override
  String discardDialogBody(int count, String email) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'ანგარიშის $email $count ღვინო ჯერ არ არის ღრუბელში და წაიშლება ამ ტელეფონიდან.',
      one:
          'ანგარიშის $email 1 ღვინო ჯერ არ არის ღრუბელში და წაიშლება ამ ტელეფონიდან.',
    );
    return '$_temp0';
  }

  @override
  String get discardConfirm => 'წაშლა';

  @override
  String get resetFailed => 'ამ ტელეფონის მონაცემების გასუფთავება ვერ მოხერხდა';

  @override
  String get restartRequired => 'დასასრულებლად გადატვირთეთ აპი';

  @override
  String get restartCloseApp => 'აპის დახურვა';

  @override
  String get startupFailed => 'აპის გაშვება ვერ მოხერხდა';

  @override
  String get cellarTitle => 'მარანი';

  @override
  String get defaultCellarName => 'ჩემი მარანი';

  @override
  String get cellarLoading => 'მარნის მომზადება';

  @override
  String get cellarSetupFailed => 'მარნის მომზადება ვერ მოხერხდა';

  @override
  String get cellarEmpty => 'თქვენი მარანი ცარიელია';

  @override
  String get addWine => 'დამატება';

  @override
  String get estimatePending => 'პროგნოზი მალე იქნება';

  @override
  String get noVintage => 'მოსავლის წლის გარეშე';

  @override
  String bottleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ბოთლი',
      one: '1 ბოთლი',
    );
    return '$_temp0';
  }

  @override
  String get syncInProgress => 'სინქრონიზაცია';

  @override
  String get syncOffline => 'ხაზგარეშე – სინქრონიზაცია მოლოდინშია';

  @override
  String writeRejected(String name) {
    return 'ცვლილება დაუშვებელია: $name';
  }

  @override
  String get saveFailed => 'შენახვა ვერ მოხერხდა, სცადეთ ხელახლა';

  @override
  String wineNotSaved(String name) {
    return 'ღვინო $name ღრუბელში არ შენახულა';
  }

  @override
  String get addAgain => 'ხელახლა დამატება';

  @override
  String get ignore => 'იგნორირება';

  @override
  String get addWineTitle => 'ჩაწერა';

  @override
  String get wineNameLabel => 'ღვინო';

  @override
  String get vintageLabel => 'მოსავლის წელი';

  @override
  String get quantityLabel => 'რაოდენობა';

  @override
  String get decreaseQuantity => 'რაოდენობის შემცირება';

  @override
  String get increaseQuantity => 'რაოდენობის გაზრდა';

  @override
  String get save => 'შენახვა';

  @override
  String get nameRequired => 'ჩაწერეთ ღვინის სახელი';

  @override
  String get nameTooLong => 'მაქსიმუმ 120 სიმბოლო';

  @override
  String vintageRange(String year) {
    return 'მოსავლის წელი: 1900-დან $year-მდე';
  }

  @override
  String get offAttribution => 'მონაცემები: Open Food Facts (ODbL)';

  @override
  String get dashboardTitle => 'მიმოხილვა';

  @override
  String dashboardTotalBottles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ბოთლი მარანში',
      one: '1 ბოთლი მარანში',
    );
    return '$_temp0';
  }

  @override
  String get dashboardSyncing => 'მარნის სინქრონიზაცია…';

  @override
  String get dashboardAddFirstWine => 'დაამატეთ პირველი ღვინო';

  @override
  String get drinkSoonTitle => 'მალე დასალევი';

  @override
  String get drinkSoonEmpty => 'მალე დასალევი ბოთლები არ არის';

  @override
  String drinkSoonUntil(String year) {
    return '$year წლამდე';
  }

  @override
  String drinkSoonSeeAll(int count) {
    return 'ყველას ნახვა ($count)';
  }

  @override
  String get statusChartTitle => 'ბოთლების მდგომარეობა';

  @override
  String get statusWaiting => 'მოსაცდელი';

  @override
  String get statusReady => 'მზადაა';

  @override
  String get statusDrinkSoon => 'მალე დასალევი';

  @override
  String get statusPastWindow => 'პერიოდი გასულია';

  @override
  String toEstimateNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ბოთლი პროგნოზის გარეშე',
      one: '1 ბოთლი პროგნოზის გარეშე',
    );
    return '$_temp0';
  }

  @override
  String chartBarValue(String label, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ბოთლი',
      one: '1 ბოთლი',
    );
    return '$label: $_temp0';
  }

  @override
  String chartDescription(String title, String values) {
    return '$title: $values';
  }

  @override
  String get openListHint => 'სიის გახსნა';

  @override
  String get peakChartTitle => 'პიკის წელი';

  @override
  String get peakPast => 'პიკი გასულია';

  @override
  String get peakBeyond => 'მოგვიანებით';

  @override
  String get breakdownTypeTitle => 'ბოთლები ტიპის მიხედვით';

  @override
  String get breakdownRegionTitle => 'ბოთლები რეგიონის მიხედვით';

  @override
  String get breakdownType => 'ტიპი';

  @override
  String get breakdownRegion => 'რეგიონი';

  @override
  String get familyRed => 'წითელი';

  @override
  String get familyWhite => 'თეთრი';

  @override
  String get familyRose => 'ვარდისფერი';

  @override
  String get familySparkling => 'ცქრიალა';

  @override
  String get familySweet => 'ტკბილი';

  @override
  String get breakdownUnspecified => 'მითითებული არ არის';

  @override
  String get breakdownOtherRegions => 'სხვა';

  @override
  String get ok => 'OK';

  @override
  String get cellarMenu => 'მარნის მენიუ';

  @override
  String get sharingPeopleTitle => 'ადამიანები';

  @override
  String get sharingInviteTitle => 'ადამიანის მოწვევა';

  @override
  String get sharingEmailLabel => 'Google-ის ელფოსტის მისამართი';

  @override
  String get sharingPermissionRead => 'მხოლოდ ნახვა';

  @override
  String get sharingPermissionReadHint =>
      'ხედავს ღვინოებს, პროგნოზებს, მიმოხილვას და დალეულ ბოთლებს';

  @override
  String get sharingPermissionEdit => 'შეუძლია რედაქტირება';

  @override
  String get sharingPermissionEditHint =>
      'ასევე ამატებს და ცვლის ღვინოებს და აღნიშნავს დალეულ ბოთლებს';

  @override
  String get sharingRoleOwner => 'მფლობელი';

  @override
  String get sharingInviteButton => 'მოწვევა';

  @override
  String sharingPlacesUsed(int used, int max) {
    return 'ადამიანები: $used/$max';
  }

  @override
  String get sharingInvalidEmail => 'შეიყვანეთ სწორი ელფოსტა';

  @override
  String get sharingSelfInvite => 'საკუთარ თავს ვერ მოიწვევთ';

  @override
  String get sharingAlreadyInvited => 'ეს ადამიანი უკვე მოწვეულია';

  @override
  String sharingLimitReached(int max) {
    return 'მიღწეულია ადამიანების ლიმიტი: $max';
  }

  @override
  String get sharingNotOwner => 'ამ მარნის გაზიარებას ვერ შეცვლით';

  @override
  String get sharingNotFound => 'ეს ადამიანი სიაში აღარ არის';

  @override
  String get sharingFailed => 'ვერ მოხერხდა, სცადეთ ხელახლა';

  @override
  String get sharingInviteFailed => 'მოწვევა ვერ მოხერხდა. სცადეთ ხელახლა';

  @override
  String get sharingOfflineHint => 'გაზიარების სამართავად საჭიროა კავშირი';

  @override
  String get sharingStatusInvited => 'მოწვეულია';

  @override
  String get sharingStatusActive => 'აქტიურია';

  @override
  String get sharingStatusRevoked => 'წვდომა ჩამორთმეულია';

  @override
  String get sharingStatusLeft => 'გასულია';

  @override
  String sharingMemberSemantics(String name, String permission, String status) {
    return '$name, $permission, $status';
  }

  @override
  String get sharingClosedSection => 'დახურული წვდომები';

  @override
  String get sharingNobody => 'ამ მარანს ჯერ სხვა არავინ ხედავს';

  @override
  String sharingChangePermission(String name) {
    return 'ნებართვის შეცვლა: $name';
  }

  @override
  String get sharingRevoke => 'ჩამორთმევა';

  @override
  String sharingRevokeTitle(String name) {
    return 'წვდომის ჩამორთმევა: $name?';
  }

  @override
  String sharingRevokeConfirmLabel(String name) {
    return 'დასადასტურებლად ჩაწერეთ $name';
  }

  @override
  String get sharingRevokeDisabledHint => 'აქტიურდება, როცა სახელი დაემთხვევა';

  @override
  String get sharingReinvite => 'ხელახლა მოწვევა';

  @override
  String get sharingDeleteForGood => 'სამუდამოდ წაშლა';

  @override
  String sharingOwnedBy(String owner) {
    return 'მარანი · $owner';
  }

  @override
  String get sharingYourCellar => 'თქვენი მარანი';

  @override
  String sharingYourPermission(String permission) {
    return 'თქვენი ნებართვა: $permission';
  }

  @override
  String sharingSwitcherSemantics(String cellar, String permission) {
    return '$cellar, $permission. შეეხეთ მარნის შესაცვლელად';
  }

  @override
  String get sharingLeave => 'ამ მარნის დატოვება';

  @override
  String sharingLeaveTitle(String owner) {
    return 'დატოვებთ მარანს, რომლის მფლობელია $owner?';
  }

  @override
  String sharingLeaveBody(String owner) {
    return 'მას ვეღარ ნახავთ. $owner შეძლებს ხელახლა მოგიწვიოთ.';
  }

  @override
  String get sharingLeaveConfirm => 'დატოვება';

  @override
  String sharingSharedNotice(String owner) {
    return '$owner გიზიარებთ თავის მარანს';
  }

  @override
  String sharingAccessLost(String owner) {
    return 'აღარ გაქვთ წვდომა მარანზე, რომლის მფლობელია $owner';
  }

  @override
  String sharingWritesLost(String owner) {
    return 'ზოგი ცვლილება არ შენახულა, რადგან აღარ გაქვთ წვდომა მარანზე, რომლის მფლობელია $owner';
  }

  @override
  String get sharingSomeone => 'ვიღაც';

  @override
  String get sharingShareSubject => 'მოწვევა Vinoozy-ში';

  @override
  String sharingShareMessage(
    String owner,
    String cellar,
    String link,
    String email,
  ) {
    return '$owner გიწვევთ მარანში „$cellar“ აპში Vinoozy. დააინსტალირეთ აპი ბმულიდან $link და შედით Google ანგარიშით $email: გამოიყენეთ ზუსტად ეს მისამართი.';
  }

  @override
  String get cellarSearchHint => 'ძიება სახელით ან მწარმოებლით';

  @override
  String get cellarFilterStatus => 'მდგომარეობა';

  @override
  String get cellarFilterType => 'ტიპი';

  @override
  String get statusToEstimate => 'პროგნოზის გარეშე';

  @override
  String get filterTypeUnspecified => 'მითითებული არ არის';

  @override
  String get cellarNoMatches => 'ამ ფილტრებით ღვინო არ არის';

  @override
  String get cellarClearFilters => 'ფილტრების გასუფთავება';

  @override
  String get cellarArchiveTitle => 'დალეული';

  @override
  String get cellarArchiveEmpty => 'ჯერ არცერთი ღვინო არ დასრულებულა';

  @override
  String get cellarArchiveFailed =>
      'დასრულებული ღვინოების ჩატვირთვა ვერ მოხერხდა';

  @override
  String get wineDrink => 'დალეულია';

  @override
  String wineDrinkTooltip(String name) {
    return '$name: ერთი ბოთლის დალეულად მონიშვნა';
  }

  @override
  String confidenceLabel(String level) {
    return 'სანდოობა: $level';
  }

  @override
  String get confidenceHigh => 'მაღალი';

  @override
  String get confidenceMedium => 'საშუალო';

  @override
  String get confidenceLow => 'დაბალი';

  @override
  String get windowStartLabel => 'დასაწყისი';

  @override
  String get windowPeakLabel => 'პიკი';

  @override
  String get windowEndLabel => 'დასასრული';

  @override
  String estimateSourceLabel(String source) {
    return 'წყარო: $source';
  }

  @override
  String get estimateSourceCatalog => 'ღვინოების ბაზა';

  @override
  String get estimateSourceType => 'პროგნოზი ტიპის მიხედვით';

  @override
  String get estimateSourceCorrected =>
      'პროგნოზი, შესწორებული თქვენი დალეული ბოთლებით';

  @override
  String get estimateDisclaimer =>
      'სავარაუდო პროგნოზი: დამოკიდებულია იმაზეც, თუ როგორ ინახებოდა ბოთლი';

  @override
  String get estimateUnavailable => 'პროგნოზი მიუწვდომელია';

  @override
  String get pairingsTitle => 'შეხამება';

  @override
  String get pairingsGeneric => 'ზოგადი შეხამებები ამ ტიპისთვის';

  @override
  String get pairingBraisedRedMeat => 'ჩაშუშული წითელი ხორცი';

  @override
  String get pairingGrilledRedMeat => 'გრილზე შემწვარი წითელი ხორცი';

  @override
  String get pairingGame => 'ნანადირევი';

  @override
  String get pairingRoastPoultry => 'შემწვარი ფრინველი';

  @override
  String get pairingPoultry => 'ფრინველი';

  @override
  String get pairingPork => 'ღორის ხორცი';

  @override
  String get pairingCuredMeats => 'ძეხვეული';

  @override
  String get pairingPastaMeatSauce => 'პასტა ხორცის სოუსით';

  @override
  String get pairingMushroomsTruffle => 'სოკო და ტრიუფელი';

  @override
  String get pairingAgedCheese => 'დაძველებული ყველი';

  @override
  String get pairingFreshCheese => 'ახალი ყველი';

  @override
  String get pairingBlueCheese => 'ლურჯი ყველი';

  @override
  String get pairingFish => 'თევზი';

  @override
  String get pairingSeafood => 'ზღვის პროდუქტები';

  @override
  String get pairingRawSeafood => 'უმი ზღვის პროდუქტები';

  @override
  String get pairingFriedFood => 'შემწვარი კერძები';

  @override
  String get pairingVegetables => 'ბოსტნეული';

  @override
  String get pairingRisotto => 'რიზოტო';

  @override
  String get pairingPizza => 'პიცა';

  @override
  String get pairingAperitif => 'აპერიტივი';

  @override
  String get pairingPastries => 'ნამცხვრები';

  @override
  String get pairingDryBiscuits => 'მშრალი ორცხობილა';

  @override
  String get pairingChocolate => 'შოკოლადი';

  @override
  String get pairingDriedFruit => 'თხილეული და ჩირი';

  @override
  String get pairingSpicyDishes => 'ცხარე კერძები';

  @override
  String get recentDrinksTitle => 'ბოლოს დალეული';

  @override
  String get noDrinksYet => 'ჯერ დალეული ბოთლები არ არის';

  @override
  String get wineEdit => 'რედაქტირება';

  @override
  String get wineDelete => 'წაშლა';

  @override
  String get wineFinished => 'დასრულდა: ბოთლი აღარ დარჩა';

  @override
  String get wineLoadFailed => 'ღვინის გახსნა ვერ მოხერხდა';

  @override
  String get wineNotFound => 'ეს ღვინო აღარ არსებობს';

  @override
  String drinkDone(String name) {
    return 'მოინიშნა დალეულად: $name';
  }

  @override
  String get drinkUndo => 'დაბრუნება';

  @override
  String get drinkAddNotes => 'შეფასებისა და შენიშვნების დამატება';

  @override
  String get nothingToUndo => 'დასაბრუნებელი აღარაფერია';

  @override
  String get cellarUndoRejected =>
      'დაბრუნება ვერ მოხერხდა: ბოთლი დალეულად რჩება მონიშნული';

  @override
  String get cellarDeleteFailed =>
      'წაშლა ჯერ არ დასრულებულა: დასრულდება პირველივე შესაძლებლობისას';

  @override
  String get duplicateFull =>
      'ამ ღვინოს უკვე 99 ბოთლი აქვს: მეტის დამატება შეუძლებელია.';

  @override
  String get recordSheetTitle => 'შეფასება და შენიშვნები';

  @override
  String get recordRatingLabel => 'შეფასება';

  @override
  String ratingStar(int n) {
    return 'შეფასება: $n 5-დან';
  }

  @override
  String get recordNotesLabel => 'შენიშვნები';

  @override
  String get recordNotesTooLong => 'მაქსიმუმ 1000 სიმბოლო';

  @override
  String recordDateLabel(String date) {
    return 'თარიღი: $date';
  }

  @override
  String get recordDateInvalid =>
      'თარიღი არ შეიძლება იყოს მომავალში ან მოსავლის წელზე ადრე';

  @override
  String get recordConditionTitle => 'როგორი იყო?';

  @override
  String get conditionTooYoung => 'ჯერ ძალიან ახალგაზრდაა';

  @override
  String get conditionJustRight => 'ზუსტად დროზე';

  @override
  String get conditionPastPeak => 'პიკი უკვე გასული ჰქონდა';

  @override
  String get recordNoCondition => 'პასუხის გარეშე';

  @override
  String get producerLabel => 'მწარმოებელი (არასავალდებულო)';

  @override
  String get producerTooLong => 'მაქსიმუმ 120 სიმბოლო';

  @override
  String producerAddNew(String name) {
    return 'ახალი მწარმოებლის დამატება: „$name“';
  }

  @override
  String get wineTypeLabel => 'ტიპი';

  @override
  String get typeRedLight => 'მსუბუქი წითელი';

  @override
  String get typeRedStructured => 'სხეულიანი წითელი';

  @override
  String get typeWhite => 'თეთრი';

  @override
  String get typeRose => 'ვარდისფერი';

  @override
  String get typeSparklingClassic => 'ცქრიალა, კლასიკური მეთოდი';

  @override
  String get typeSparklingTank => 'ცქრიალა, რეზერვუარული მეთოდი';

  @override
  String get typeSweet => 'ტკბილი';

  @override
  String get typeFortified => 'შემაგრებული';

  @override
  String get suggestionFromCellar => 'თქვენს მარანში';

  @override
  String get suggestionsLabel => 'შეთავაზებები';

  @override
  String get duplicateTitle => 'უკვე მარანშია';

  @override
  String duplicateBody(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ბოთლი',
      one: '1 ბოთლი',
      zero: 'ბოთლების გარეშე',
    );
    return '$name უკვე არის: $_temp0. დაემატოს ახალი ბოთლები მას?';
  }

  @override
  String duplicateAdd(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ბოთლის დამატება',
      one: '1 ბოთლის დამატება',
    );
    return '$_temp0';
  }

  @override
  String get duplicateBanner => 'შესაძლო დუბლიკატი';

  @override
  String get duplicateMerge => 'გაერთიანება';

  @override
  String get duplicateDeleteHint => 'წაშალეთ ეს ჩანაწერი, თუ დუბლიკატია';

  @override
  String get mergeTitle => 'გაერთიანდეს ორი ჩანაწერი?';

  @override
  String get mergeBody =>
      'ამ ჩანაწერის ბოთლები უფრო ძველ ჩანაწერში გადავა, შემდეგ კი ეს ჩანაწერი წაიშლება.';

  @override
  String get editWineTitle => 'ღვინის რედაქტირება';

  @override
  String get editDuplicate =>
      'უკვე არსებობს სხვა ღვინო იმავე სახელით, მწარმოებლითა და მოსავლის წლით';

  @override
  String deleteWineTitle(String name) {
    return 'წაიშალოს $name?';
  }

  @override
  String get deleteWineBody =>
      'ღვინო და მისი ყველა დალეული ბოთლი წაიშლება. ამის დაბრუნება შეუძლებელია.';

  @override
  String get historyTitle => 'ისტორია';

  @override
  String get historyEmpty => 'აქ ნახავთ ბოთლებს, რომლებიც დალიეთ';

  @override
  String get historyLoadFailed => 'ისტორიის ჩატვირთვა ვერ მოხერხდა';

  @override
  String drankOnLabel(String date) {
    return 'დალეულია: $date';
  }

  @override
  String get addChoiceTitle => 'ღვინის დამატება';

  @override
  String get addChoicePhoto => 'ფოტოს გადაღება';

  @override
  String get addChoiceImport => 'ფოტოს იმპორტი';

  @override
  String get addChoiceWrite => 'ჩაწერა';

  @override
  String get labelReading => 'ვკითხულობ ეტიკეტს…';

  @override
  String get labelRecognized => 'ამოვიცანი:';

  @override
  String get labelCorrect => 'შესწორება';

  @override
  String get labelConfirm => 'დადასტურება';

  @override
  String get labelUnreadable => 'ეტიკეტს ვერ ვკითხულობ';

  @override
  String get labelWriteByHand => 'ხელით ჩაწერა';

  @override
  String get labelNotFound => 'ღვინო ვერ ვიპოვე: შეამოწმეთ მონაცემები';

  @override
  String get labelCameraDenied =>
      'ეტიკეტის წასაკითხად მჭირდება წვდომა კამერაზე';

  @override
  String get labelPhotosDenied =>
      'ეტიკეტის წასაკითხად მჭირდება წვდომა ფოტოებზე';

  @override
  String get labelOpenSettings => 'პარამეტრების გახსნა';

  @override
  String get labelCameraUnavailable => 'კამერა მიუწვდომელია';

  @override
  String get labelBarcodeNotFound =>
      'შტრიხკოდი წავიკითხე, მაგრამ ღვინოს ვერ ვპოულობ';

  @override
  String get labelBarcodeFrontHint => 'გადაუღეთ ფოტო ეტიკეტის წინა მხარეს';

  @override
  String get labelSharedNotAllowed => 'ამ მარანში ღვინოებს ვერ დაამატებთ';

  @override
  String get labelSharedFirstOnly => 'მხოლოდ პირველი ფოტო გამოვიყენე';

  @override
  String get labelSharedExpired =>
      'გაზიარებული ფოტოს წაკითხვა ვერ მოხერხდა: გააზიარეთ ხელახლა';

  @override
  String get labelReplaceTitle =>
      'გაქვთ შეუნახავი ღვინო. წავიკითხო ახალი ფოტო?';

  @override
  String get labelReplaceRead => 'ახალი ფოტოს წაკითხვა';

  @override
  String get labelReplaceKeep => 'გახსნილით გაგრძელება';

  @override
  String get labelWineAdded => 'ღვინო დაემატა მარანს';

  @override
  String get onboardingPage1Title => 'თქვენი მარანი ჯიბეში';

  @override
  String get onboardingPage1Body =>
      'დაამატეთ ბოთლები ხელით ჩაწერით ან ეტიკეტის ფოტოთი, ქსელის გარეშეც.';

  @override
  String get onboardingPage2Title => 'საჭირო დროს';

  @override
  String get onboardingPage2Body =>
      'Vinoozy პროგნოზირებს, როდის არის თითოეული ღვინო საუკეთესო ფორმაში, და გეუბნებათ, რომელი გახსნათ პირველად.';

  @override
  String get onboardingPage3Title => 'ერთად';

  @override
  String get onboardingPage3Body =>
      'გაუზიარეთ მარანი მაქსიმუმ ორ ადამიანს და შეინახეთ ყოველი დალეული ბოთლის ისტორია.';

  @override
  String get onboardingSkip => 'გამოტოვება';

  @override
  String get onboardingNext => 'შემდეგი';

  @override
  String get onboardingStart => 'დაწყება';

  @override
  String onboardingPageOf(int page) {
    return 'გვერდი $page 3-დან';
  }

  @override
  String get profileTitle => 'პროფილი';

  @override
  String get profilePhoto => 'პროფილის ფოტო';

  @override
  String get profileSignOut => 'გასვლა';

  @override
  String get profileDeleteAccount => 'ანგარიშის წაშლა';

  @override
  String get profilePrivacy => 'კონფიდენციალურობის პოლიტიკა';

  @override
  String get profilePrivacyBody =>
      'კონფიდენციალურობის პოლიტიკის წაკითხვა შეგიძლიათ ამ მისამართზე:';

  @override
  String get profileOpenLink => 'ბრაუზერში გახსნა';

  @override
  String get profileOpenLinkFailed =>
      'გვერდის გახსნა ვერ მოხერხდა. შეგიძლიათ დააკოპიროთ ბმული და გახსნათ ბრაუზერში.';

  @override
  String get profileCopyLink => 'ბმულის კოპირება';

  @override
  String get profileLinkCopied => 'ბმული დაკოპირდა';

  @override
  String get close => 'დახურვა';

  @override
  String get signOutConfirmTitle => 'გსურთ გასვლა?';

  @override
  String signOutPendingWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'გაქვთ $count ცვლილება, რომელიც ჯერ არ შენახულა. თუ გახვალთ და სხვა ანგარიში შევა, ისინი დაიკარგება.',
      one: 'გაქვთ 1 ცვლილება, რომელიც ჯერ არ შენახულა. თუ გახვალთ და სხვა ანგარიში შევა, ის დაიკარგება.',
    );
    return '$_temp0';
  }

  @override
  String get signOutStayAndSync => 'დარჩენა და სინქრონიზაცია';

  @override
  String get signOutAnyway => 'მაინც გასვლა';

  @override
  String get syncAllSaved => 'ყველაფერი შენახულია';

  @override
  String syncStillPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'შესანახი დარჩა $count ცვლილება: შეამოწმეთ ქსელი',
      one: 'შესანახი დარჩა 1 ცვლილება: შეამოწმეთ ქსელი',
    );
    return '$_temp0';
  }

  @override
  String get signOutFailed => 'გასვლა ვერ მოხერხდა. სცადეთ ხელახლა';

  @override
  String get signInAccountDeleted => 'ანგარიში წაიშალა';

  @override
  String get deleteAccountIntro => 'სამუდამოდ წაიშლება:';

  @override
  String get deleteAccountItemCellar => 'თქვენი მარანი ღვინოებითა და ისტორიით';

  @override
  String get deleteAccountItemShares =>
      'თქვენ მიერ გაცემული გაზიარებები: მოწვეული ადამიანები წვდომას კარგავენ';

  @override
  String get deleteAccountItemMemberships =>
      'თქვენი მონაწილეობა სხვების მარნებში: თქვენი დალეული ბოთლები იქ რჩება თქვენი სახელის გარეშე';

  @override
  String get deleteAccountItemProfile => 'თქვენი პროფილი';

  @override
  String deleteAccountPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'გაქვთ $count ცვლილება, რომელიც ჯერ არ შენახულა: ისინი შეინახება და შემდეგ დანარჩენთან ერთად წაიშლება',
      one: 'გაქვთ 1 ცვლილება, რომელიც ჯერ არ შენახულა: ის შეინახება და შემდეგ დანარჩენთან ერთად წაიშლება',
    );
    return '$_temp0';
  }

  @override
  String get deleteAccountConfirmWord => 'წაშლა';

  @override
  String deleteAccountTypeWord(String word) {
    return 'დასადასტურებლად ჩაწერეთ $word';
  }

  @override
  String get deleteAccountReauthHint =>
      'შემდეგ ხელახლა შეხვალთ Google-ით, რათა დაადასტუროთ, რომ ეს თქვენ ხართ.';

  @override
  String get deleteAccountForever => 'სამუდამოდ წაშლა';

  @override
  String get deleteAccountNeedsNetwork =>
      'ანგარიშის წასაშლელად დაუკავშირდით ინტერნეტს';

  @override
  String get deleteAccountSameAccount =>
      'წაშლისთვის საჭიროა იმავე ანგარიშით შესვლა';

  @override
  String get deletionTitle => 'ანგარიშის წაშლა';

  @override
  String get deletionStepPreparePhone => 'მოლოდინში მყოფი ცვლილებების შენახვა';

  @override
  String get deletionStepMarkStarted => 'წაშლის დაწყება';

  @override
  String get deletionStepLeaveOtherCellars => 'სხვების მარნებიდან გასვლა';

  @override
  String get deletionStepCloseOwnInvitations => 'თქვენი გაზიარებების დახურვა';

  @override
  String get deletionStepDeleteWinesAndRecords =>
      'ღვინოებისა და ისტორიის წაშლა';

  @override
  String get deletionStepDeleteCellar => 'მარნის წაშლა';

  @override
  String get deletionStepDeleteProfileAndUser => 'პროფილისა და ანგარიშის წაშლა';

  @override
  String get deletionStepCleanUpPhone => 'ამ ტელეფონის გასუფთავება';

  @override
  String deletionStepAnnounce(int step, String label) {
    return 'ნაბიჯი $step 8-დან: $label';
  }

  @override
  String deletionDeletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'წაიშალა $count ღვინო და დალეული ბოთლი',
      one: 'წაიშალა 1 ღვინო ან დალეული ბოთლი',
    );
    return '$_temp0';
  }

  @override
  String get deletionResumeHint =>
      'ამ ანგარიშის წაშლა არ დასრულებულა. დასასრულებლად ხელახლა შედით Google-ით.';

  @override
  String get deletionContinue => 'გაგრძელება';

  @override
  String get deletionOffline => 'წაშლის დასასრულებლად დაუკავშირდით ინტერნეტს';

  @override
  String get deletionPendingWrites =>
      'მოლოდინში მყოფ ცვლილებებს ვერ ვინახავ. სცადეთ ხელახლა';

  @override
  String get deletionFailed => 'წაშლის დასრულება ვერ მოხერხდა. სცადეთ ხელახლა';

  @override
  String get uxCountryLabel => 'ქვეყანა';

  @override
  String get uxCountryOther => 'სხვა ქვეყანა…';

  @override
  String get uxCountryNone => 'ქვეყნის გარეშე';

  @override
  String get uxAllCountriesTitle => 'ყველა ქვეყანა და ტერიტორია';

  @override
  String get uxAllCountriesSearch => 'ქვეყნის ძიება';

  @override
  String get uxAllCountriesRare => 'ღვინისთვის იშვიათი';

  @override
  String get uxAllCountriesAll => 'ყველა, ა-დან ჰ-მდე';

  @override
  String get uxAllCountriesNone => 'ქვეყანა ვერ მოიძებნა';

  @override
  String get uxRegionLabel => 'რეგიონი';

  @override
  String uxRegionOf(String country) {
    return 'რეგიონი · $country';
  }

  @override
  String get uxRegionOther => 'სხვა რეგიონი';

  @override
  String get uxRegionFieldLabel => 'ჩაწერეთ რეგიონი';

  @override
  String get uxRegionTooLong => 'მაქსიმუმ 120 სიმბოლო';

  @override
  String get uxDrinkAction => 'დავლიე';

  @override
  String uxDrinkActionTooltip(String name) {
    return 'დავლიე ერთი ბოთლი: $name';
  }

  @override
  String get uxDrinkActionDetail => 'დავლიე ერთი ბოთლი';

  @override
  String get uxDrinkSheetLabel => 'დალევის დადასტურება';

  @override
  String get uxDrinkSheetBottles => 'ბოთლები';

  @override
  String uxDrinkSheetBottlesChange(int before, int after) {
    return 'ბოთლები: იყო $before, იქნება $after';
  }

  @override
  String get uxDrinkSheetRating => 'როგორი იყო? (არასავალდებულო)';

  @override
  String uxDrinkSheetStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ვარსკვლავი 5-დან',
      one: '1 ვარსკვლავი 5-დან',
    );
    return '$_temp0';
  }

  @override
  String get uxDrinkSheetConfirm => 'დიახ, დავლიე';

  @override
  String get uxRemoveBottle => 'ბოთლის მოშორება დალევის გარეშე';

  @override
  String get uxRemoveBottleTitle => 'მოვაშოროთ ერთი ბოთლი?';

  @override
  String uxRemoveBottleBody(String name) {
    return 'ერთი ბოთლი ($name) მოშორდება დალევის აღნიშვნის გარეშე.';
  }

  @override
  String get uxRemoveBottleConfirm => 'მოშორება';

  @override
  String get uxIdealTitle => 'იდეალური მომენტი';

  @override
  String uxIdealUntil(String year) {
    return 'რეკომენდებულია $year წლამდე';
  }

  @override
  String uxIdealUntilPast(String year) {
    return 'რეკომენდებულია $year წლამდე: ვადა გასულია';
  }

  @override
  String uxIdealBest(String start, String end) {
    return 'საუკეთესოა: $start–$end';
  }

  @override
  String uxIdealBar(String start, String end) {
    return 'დალევის პერიოდი: $start–$end';
  }

  @override
  String get uxIdealDisclaimer =>
      '⚠︎ სავარაუდოა: პროგნოზი ეფუძნება ტიპს, ადგილწარმოშობასა და მოსავლის წელს. შენახვამ და კონკრეტულმა ბოთლმა შეიძლება შეცვალოს იგი.';

  @override
  String get uxIdealUnavailableHint =>
      'პროგნოზის მისაღებად მიუთითეთ მოსავლის წელი და ტიპი.';

  @override
  String uxDashboardDrinkNow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ახლა დასალევი',
      one: '1 ახლა დასალევი',
    );
    return '$_temp0';
  }

  @override
  String get uxFamilyRed => 'წითელი';

  @override
  String get uxFamilyWhite => 'თეთრი';

  @override
  String get uxFamilyRose => 'ვარდისფერი';

  @override
  String get uxFamilySparkling => 'ცქრიალა';

  @override
  String get uxFamilySweet => 'ტკბილი';

  @override
  String get labelBackTitle => 'ახლა უკანა მხარე';

  @override
  String get labelBackHint =>
      'უკანა მხარეს ჩვეულებრივ არის შტრიხკოდი, მწარმოებელი და მოსავლის წელი: ისინი ღვინის პოვნაში გვეხმარება.';

  @override
  String get labelBackTake => 'უკანა მხარის გადაღება';

  @override
  String get labelBackGallery => 'გალერეიდან არჩევა';

  @override
  String get labelBackSkip => 'გამოტოვება';

  @override
  String get labelStepFront => 'წინა მხარე';

  @override
  String get labelStepBack => 'უკანა მხარე';

  @override
  String get labelStepBarcode => 'შტრიხკოდი';

  @override
  String get labelStepDatabase => 'ღვინოების ბაზა ტელეფონში';

  @override
  String get labelStepPending => 'მოლოდინშია';

  @override
  String get labelStepRunning => 'მიმდინარეობს…';

  @override
  String get labelStepDone => 'დასრულდა';

  @override
  String get labelStepSkipped => 'გამოტოვებულია';

  @override
  String get labelStepFailed => 'არ იკითხება';

  @override
  String labelStepStatus(String step, String status) {
    return '$step: $status';
  }

  @override
  String get labelOnPhoneNote =>
      'ყველაფერი ტელეფონში ხდება: ფოტოები არავის ეგზავნება.';

  @override
  String get labelBackUnreadable => 'უკანა მხარე არ იკითხება';

  @override
  String get labelSourceOffline => 'ტელეფონის ბაზიდან · ხაზგარეშე';

  @override
  String get labelSourceCatalog => 'კატალოგიდან';

  @override
  String get labelSourceOnline => 'Open Food Facts-იდან · ონლაინ';

  @override
  String get labelNotThis => 'ეს არ არის';

  @override
  String get labelOffAttribution =>
      'მონაცემები: Open Food Facts, ლიცენზია ODbL';

  @override
  String get labelCandidatesTitle => 'რომელია ამათგან?';

  @override
  String labelCandidatesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count მსგავსი ღვინო',
      one: '1 მსგავსი ღვინო',
    );
    return '$_temp0';
  }

  @override
  String get labelCandidatesNone => 'არცერთი ამათგანი';

  @override
  String get labelChipOffline => 'ხაზგარეშე';

  @override
  String get labelChipOnline => 'ონლაინ';

  @override
  String get labelChipCatalog => 'კატალოგი';

  @override
  String get labelNoProducer => 'მწარმოებელი მითითებული არ არის';

  @override
  String get labelNoMatch => 'ეტიკეტი წავიკითხე, მაგრამ ღვინოს ვერ ვცნობ';

  @override
  String get labelReadText => 'წაკითხული ტექსტი';

  @override
  String get labelSearchOnline => 'ონლაინ ძიება';

  @override
  String get labelOpenLens => 'Google Lens-ში გახსნა';

  @override
  String get labelLensLastResort =>
      'Google Lens ბოლო საშუალებაა: ფოტო Google-ის აპს მხოლოდ თქვენი დადასტურების შემდეგ გადაეცემა.';

  @override
  String get labelLensTitle => 'გაიხსნას Google Lens-ში?';

  @override
  String get labelLensBody =>
      'წინა მხარის ფოტო გადაეცემა Google-ის აპს თქვენს ტელეფონში, ან თქვენ მიერ არჩეულ აპს, რომელმაც შეიძლება ასლი შეინახოს საკუთარი წესების მიხედვით. Vinoozy შედეგებს არ იღებს: დაბრუნდით აქ, რომ ღვინო აირჩიოთ ან ჩაწეროთ.';

  @override
  String get labelLensConfirm => 'Google Lens-ის გახსნა';

  @override
  String get labelLensFailed =>
      'ვერ ვხსნი ვერც Google Lens-ს და ვერც გაზიარების მენიუს';

  @override
  String get onlineSearchTitle => 'ონლაინ ძიება';

  @override
  String get onlineSearchSubtitle => 'Open Food Facts · მხოლოდ ღვინოები';

  @override
  String get onlineSearchField => 'საძიებო სიტყვები';

  @override
  String get onlineSearchHint => 'ძიებამდე სიტყვების შეცვლა შეგიძლიათ.';

  @override
  String get onlineSearchEmptyField => 'ჩაწერეთ მინიმუმ ერთი სიტყვა';

  @override
  String get onlineSearchButton => 'ძიება';

  @override
  String get onlineSearchLoading => 'ვეძებ…';

  @override
  String onlineSearchResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count შედეგი',
      one: '1 შედეგი',
    );
    return '$_temp0';
  }

  @override
  String get onlineSearchEmpty =>
      'ღვინო ვერ მოიძებნა: სცადეთ სხვა სიტყვები ან „ხელით ჩაწერა“.';

  @override
  String get onlineSearchOffline =>
      'ქსელი არ არის: ვეძებ მხოლოდ ტელეფონის ბაზაში.';

  @override
  String get onlineSearchRateLimited =>
      'ონლაინ ძიება ახლა მიუწვდომელია, სცადეთ რამდენიმე წუთში.';

  @override
  String get onlineSearchUnavailable =>
      'ონლაინ ძიება აპის ამ ვერსიაში ჩართული არ არის: ვეძებ მხოლოდ ტელეფონის ბაზაში.';

  @override
  String get aboutTitle => 'აპის შესახებ';

  @override
  String aboutVersion(String version) {
    return 'ვერსია $version';
  }

  @override
  String get aboutDbTitle => 'ღვინოების ბაზა';

  @override
  String aboutDbCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ღვინო',
      one: '1 ღვინო',
    );
    return '$_temp0';
  }

  @override
  String aboutDbDate(String date) {
    return 'Open Food Facts-ის ექსპორტი: $date';
  }

  @override
  String get aboutDbSample =>
      'საცდელი ბაზა: ხელით ჩაწერილი რამდენიმე სატესტო ღვინო და არა Open Food Facts-ის მონაცემები.';

  @override
  String get aboutDbLoading => 'ვხსნი ღვინოების ბაზას…';

  @override
  String get aboutDbUnavailable => 'ღვინოების ბაზა ამ ვერსიაში მიუწვდომელია';

  @override
  String aboutDbSource(String url) {
    return 'წარმოებული ბაზა და მისი შემქმნელი ინსტრუმენტი საჯარო რეპოზიტორიშია: $url';
  }

  @override
  String get aboutLicenseTitle => 'ლიცენზიები';

  @override
  String get aboutLicense =>
      'შეიცავს ინფორმაციას Open Food Facts-იდან, რომელიც ხელმისაწვდომია ლიცენზიით Open Database License (ODbL). ცალკეული შიგთავსი ვრცელდება ლიცენზიით Database Contents License (DbCL).';

  @override
  String get aboutPrivacyTitle => 'ეტიკეტების ფოტოები';

  @override
  String get aboutPrivacy =>
      'ეტიკეტების ფოტოები ტელეფონში იკითხება და იშლება, როცა შედეგის ეკრანს ტოვებთ. ტელეფონს ისინი მხოლოდ მაშინ ტოვებს, თუ შეეხებით ღილაკს „Google Lens-ში გახსნა“ და დაადასტურებთ.';

  @override
  String get aboutAppellationsTitle => 'ადგილწარმოშობები';

  @override
  String get aboutAppellationsSource =>
      'ადგილწარმოშობები: eAmbrosia-ს რეესტრი (ევროკავშირი) და ოფიციალური ეროვნული რეესტრები.';

  @override
  String get aboutAppellationsSample =>
      'საცდელი ცხრილი: რეესტრების ხელით ჩაწერილი ამონარიდი, სანამ ნამდვილი რეესტრები ჩამოიტვირთება.';

  @override
  String get denominationLabel => 'ადგილწარმოშობა';

  @override
  String get denominationTooLong => 'მაქსიმუმ 120 სიმბოლო';

  @override
  String get autofillFilledNotice => 'შეივსო ეტიკეტიდან: შეამოწმეთ და შეინახეთ';

  @override
  String get autofillPastedNotice => 'შეივსო ტექსტიდან: შეამოწმეთ და შეინახეთ';

  @override
  String get autofillFromText => '✦ ტექსტიდან';

  @override
  String get autofillFromTextSemantics => 'შევსებულია ეტიკეტიდან';

  @override
  String get autofillClear => 'გასუფთავება';

  @override
  String get autofillLens => 'Lens';

  @override
  String get autofillClearTitle => 'გასუფთავდეს ფორმა?';

  @override
  String get autofillClearBody =>
      'ზოგ ველში თქვენც ჩაწერეთ რაღაც. „გასუფთავება“ აცარიელებს სახელს, მწარმოებელს, ადგილწარმოშობას, მოსავლის წელს, ტიპს, ქვეყანას, რეგიონსა და დონეს. რაოდენობა რჩება.';

  @override
  String get autofillClearConfirm => 'გასუფთავება';

  @override
  String get autofillCleared => 'ფორმა გასუფთავდა';

  @override
  String get autofillPasteTitle => 'გაქვთ ტექსტი Google Lens-იდან?';

  @override
  String get autofillPasteHint =>
      'Lens-ში მონიშნეთ ეტიკეტის ტექსტი და შეეხეთ ღილაკს „კოპირება“, შემდეგ დაბრუნდით აქ.';

  @override
  String get autofillPaste => 'ჩასმა Lens-იდან';

  @override
  String get autofillOpenLens => 'Google Lens-იდან';

  @override
  String get autofillOpenLensSemantics => 'ხსნის Google Lens-ს';

  @override
  String get autofillClipboardEmpty => 'გაცვლის ბუფერში ტექსტი არ არის';

  @override
  String get autofillNoNewFields =>
      'ტექსტში დასამატებელი მონაცემები ვერ ვიპოვე';

  @override
  String get autofillFromLens => 'ფორმა შეივსო Lens-ის ტექსტიდან';

  @override
  String get autofillShareEmpty => 'ტექსტი არ მიღებულა';

  @override
  String get autofillShareUseTitle => 'გამოვიყენოთ ტექსტი ცარიელი ველებისთვის?';

  @override
  String get autofillShareUse => 'გამოყენება';

  @override
  String get autofillShareIgnore => 'იგნორირება';

  @override
  String get addChoiceLens => 'Google Lens-იდან';

  @override
  String get addChoicePhotoHint =>
      'წინა და უკანა მხარე: Vinoozy კითხულობს ეტიკეტს.';

  @override
  String get addChoiceLensHint =>
      'ხსნის Lens-ს: მიმართეთ კამერა, მონიშნეთ ტექსტი და შეეხეთ „გაზიარება“ → Vinoozy.';

  @override
  String get addChoiceImportHint => 'ეტიკეტის უკვე გადაღებული ფოტო.';

  @override
  String get addChoiceWriteHint => 'ცარიელი ფორმა ღილაკით „ჩასმა Lens-იდან“.';

  @override
  String get lensInstructionsTitle => 'Google Lens აქედან ვერ იხსნება';

  @override
  String get lensInstructionsStep1 =>
      'გახსენით Google Lens და მიმართეთ ეტიკეტს';

  @override
  String get lensInstructionsStep2 => 'მონიშნეთ ეტიკეტის ტექსტი';

  @override
  String get lensInstructionsStep3 => 'შეეხეთ „გაზიარება“ → Vinoozy';

  @override
  String get lensInstructionsOk => 'გასაგებია';

  @override
  String get levelLabel => 'დონე';

  @override
  String get levelEveryday => 'ყოველდღიური (იაფი)';

  @override
  String get levelGood => 'კარგი';

  @override
  String get levelAging => 'დასაძველებელი';

  @override
  String get levelNone => 'არცერთი';

  @override
  String get levelEverydayShort => 'ადრე დასალევი';

  @override
  String get levelGoodShort => 'ჩვეულებრივი პროგნოზი';

  @override
  String get levelAgingShort => 'უფრო დიდხანს ძლებს';

  @override
  String get levelSuggested => 'შეთავაზებული';

  @override
  String levelSuggestedReason(String qualifier) {
    return 'შეთავაზებულია, რადგან სახელი შეიცავს „$qualifier“: ასე შეინახება, თუ არ შეცვლით. აირჩიეთ სხვა ან შეეხეთ „არცერთი“.';
  }

  @override
  String levelSuggestedSemantics(String qualifier) {
    return 'შეთავაზებული, რადგან სახელი შეიცავს $qualifier';
  }

  @override
  String levelOptionSemantics(String option, int index, int count) {
    return 'დონე, $option, $index $count-დან';
  }

  @override
  String get levelWhatChanges => 'რა იცვლება';

  @override
  String get levelEverydayExamples =>
      'პერიოდი მოკლდება. მაგ.: სუფრის ღვინო, Lambrusco, ჩვეულებრივი Prosecco, Bardolino, Vinho Verde.';

  @override
  String get levelGoodExamples =>
      'ჩვეულებრივი პროგნოზი და მნიშვნელობა, როცა არაფერს ირჩევთ. მაგ.: Chianti Classico, Barbera d\'Asti Superiore, Rioja Crianza, Côtes du Rhône.';

  @override
  String get levelAgingExamples =>
      'პერიოდი გრძელდება. მაგ.: Barolo, Brunello, Amarone, Bordeaux Grand Cru, Rioja Gran Reserva, Porto Vintage.';

  @override
  String levelPreviewBefore(String start, String end) {
    return 'ადრე: $start – $end';
  }

  @override
  String levelPreviewWith(String level, String start, String end) {
    return '„$level“: $start – $end';
  }

  @override
  String levelPreviewNow(String start, String end) {
    return 'მზადაა $start – $end-მდე';
  }

  @override
  String levelDetail(String level) {
    return 'დონე: $level';
  }

  @override
  String get overrideCorrect => 'შესწორება';

  @override
  String get overrideRestore => 'პროგნოზის აღდგენა';

  @override
  String get overrideCorrectedByYou => 'თქვენი შესწორება';

  @override
  String overrideAppEstimate(String year) {
    return 'აპის პროგნოზი: $year წლამდე';
  }

  @override
  String get overrideSheetTitle => 'რეკომენდებულია ამ წლამდე';

  @override
  String overrideSheetHint(String start) {
    return 'აირჩიეთ წელი. ის არ შეიძლება იყოს უფრო ადრე, ვიდრე „მზადაა $start-დან“.';
  }

  @override
  String overridePeakNotice(String peak) {
    return 'თუ აირჩევთ წელს $peak-მდე (საუკეთესოა), „საუკეთესოა“ იმავე წელზე გადაინაცვლებს.';
  }

  @override
  String get overrideMore => 'სხვა…';

  @override
  String get overrideSave => 'შესწორების შენახვა';

  @override
  String overrideRestoreTitle(String year) {
    return 'დავუბრუნდეთ აპის პროგნოზს ($year წლამდე)?';
  }

  @override
  String get overrideRestoreConfirm => 'აღდგენა';

  @override
  String get overrideSaved => 'შესწორება შენახულია';

  @override
  String get overrideRestored => 'პროგნოზი აღდგა';

  @override
  String get estimateSourceCorrectedByYou => 'თქვენი შესწორება';

  @override
  String estimateFromDenomination(String name) {
    return 'პროგნოზი ადგილწარმოშობის მიხედვით: $name';
  }

  @override
  String estimateFromDenominationQualifier(String name, String qualifier) {
    return 'პროგნოზი ადგილწარმოშობის მიხედვით: $name, $qualifier';
  }

  @override
  String estimateFromGrape(String name) {
    return 'პროგნოზი ყურძნის ჯიშის მიხედვით: $name';
  }

  @override
  String get estimateFromType => 'პროგნოზი ღვინის ტიპის მიხედვით';

  @override
  String get autofillReading => 'ვკითხულობ ტექსტს…';

  @override
  String get guideChip => 'ეტაპობრივი შემოწმება';

  @override
  String guideProgress(int n, int total) {
    return 'კითხვა $n $total-დან';
  }

  @override
  String get guideClose => 'დახურვა';

  @override
  String get guideIsDenomination => 'ეს ადგილწარმოშობაა?';

  @override
  String get guideIsProducer => 'ეს მწარმოებელია?';

  @override
  String get guideIsName => 'ეს ღვინის სახელია?';

  @override
  String get guideIsVintage => 'მოსავლის წელი';

  @override
  String guideAskDenomination(String value) {
    return '$value — ეს ადგილწარმოშობაა?';
  }

  @override
  String guideAskProducer(String value) {
    return '$value — ეს მწარმოებელია?';
  }

  @override
  String guideAskName(String value) {
    return '$value — ეს ღვინის სახელია?';
  }

  @override
  String get guideAskVintage => 'რომელია მოსავლის წელი?';

  @override
  String guideQuestionSemantics(int n, int total, String question) {
    return 'კითხვა $n $total-დან: $question';
  }

  @override
  String get guideNoProposal => 'ტექსტში ვერ ვიპოვე';

  @override
  String get guideYes => 'დიახ';

  @override
  String get guideNo => 'არა, სხვა';

  @override
  String get guideEdit => 'რედაქტირება';

  @override
  String get guideSkip => 'გამოტოვება';

  @override
  String get guideConfirm => 'დადასტურება';

  @override
  String get guideCancel => 'გაუქმება';

  @override
  String guideRejected(String value) {
    return '„$value“ არა: აი, შემდეგი';
  }

  @override
  String get guideNoMore =>
      'სხვა შეთავაზება არ არის: შეადგინეთ თავად ან გამოტოვეთ';

  @override
  String guideProposalAnnounce(String value) {
    return 'შეთავაზება: $value';
  }

  @override
  String get guideComposeLabel => 'ან შეადგინეთ ტექსტის სიტყვებზე შეხებით';

  @override
  String get guideComposePreview => 'წინასწარი ნახვა';

  @override
  String get guideComposeEmpty => 'შეეხეთ ერთ ან რამდენიმე სიტყვას';

  @override
  String get guideComposeLimit => 'მაქსიმუმ 8 სიტყვა და 80 სიმბოლო';

  @override
  String guideTableMatchSemantics(String name) {
    return 'ემთხვევა: $name';
  }

  @override
  String guideLine(int n, int total) {
    return 'სტრიქონი $n $total-დან';
  }

  @override
  String guideWordSelected(String word, int order) {
    return '$word, არჩეულია, $order';
  }

  @override
  String guideWordUnavailable(String word) {
    return '$word, მიუწვდომელია';
  }

  @override
  String guideWordUsedFor(String word, String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'ადგილწარმოშობა',
      'producer': 'მწარმოებელი',
      'other': 'სახელი',
    });
    return '$word, გამოყენებულია ველში: $_temp0';
  }

  @override
  String guideUsedMark(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'ადგილწარმოშობა',
      'producer': 'მწარმოებელი',
      'other': 'სახელი',
    });
    return '$_temp0';
  }

  @override
  String guideOtherYears(String years) {
    return 'ტექსტში ასევე არის: $years';
  }

  @override
  String get guideWheelFromText => 'ტექსტში ნაპოვნი წელი';

  @override
  String get guideWheelTypeYear => 'ჩაწერეთ წელი';

  @override
  String guideWheelConfirm(String year) {
    return 'დადასტურება: $year';
  }

  @override
  String get guideNoVintage => 'მოსავლის წლის გარეშე';

  @override
  String guideSkippedNotice(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'ადგილწარმოშობა გამოტოვებულია',
      'producer': 'მწარმოებელი გამოტოვებულია',
      'vintage': 'მოსავლის წელი გამოტოვებულია',
      'other': 'სახელი გამოტოვებულია',
    });
    return '$_temp0: ჩაწერეთ ხელით ან გააგრძელეთ შემოწმება';
  }

  @override
  String guideSkippedMany(int count) {
    return 'გამოტოვებული ველები: $count. ჩაწერეთ ხელით ან გააგრძელეთ შემოწმება';
  }

  @override
  String get guideInvalidValue =>
      'ეს ტექსტი შეიცავს სიმბოლოებს, რომელთა შენახვა შეუძლებელია';

  @override
  String get brandStudio => 'Bottazzini Softworks';

  @override
  String get suggestedMark => '✦ შეთავაზებული';

  @override
  String suggestedSemantics(String field, String value) {
    return '$field, $value, შეთავაზებული';
  }

  @override
  String get restoreSuggestion => 'შეთავაზების აღდგენა';

  @override
  String get restoreSuggestionDone => 'შეთავაზება აღდგა';

  @override
  String get styleLabel => 'სტილი';

  @override
  String styleGroupSemantics(String value, int index, int count) {
    return 'სტილი, $value, $index $count-დან';
  }

  @override
  String get styleRedFresh => 'ხალისიანი';

  @override
  String get styleRedMedium => 'საშუალო';

  @override
  String get styleRedAge => 'დასაძველებელი';

  @override
  String get styleRedLong => 'ხანგრძლივი დაძველება';

  @override
  String get styleWhiteFresh => 'ხალისიანი';

  @override
  String get styleWhiteMedium => 'საშუალო';

  @override
  String get styleWhiteAge => 'დასაძველებელი';

  @override
  String get styleRoseFresh => 'ხალისიანი';

  @override
  String get styleClassicFresh => 'ხალისიანი';

  @override
  String get styleClassicAge => 'დასაძველებელი';

  @override
  String get styleTankFresh => 'ხალისიანი';

  @override
  String get styleLambrusco => 'Lambrusco';

  @override
  String get styleSweetAromatic => 'არომატული';

  @override
  String get styleSweetPassito => 'Passito';

  @override
  String get styleSweetBotrytis => 'ბოტრიტისიანი';

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
  String get styleFortifiedOther => 'სხვა';

  @override
  String get profileNameRFresh => 'ხილის ტონებიანი წითელი';

  @override
  String get profileNameRMedium => 'საშუალო სხეულის წითელი';

  @override
  String get profileNameRAge => 'დასაძველებელი წითელი';

  @override
  String get profileNameRLong => 'ხანგრძლივად დასაძველებელი წითელი';

  @override
  String get profileNameWFresh => 'ხალისიანი არომატული თეთრი';

  @override
  String get profileNameWMedium => 'საშუალო სხეულის თეთრი';

  @override
  String get profileNameWAge => 'დასაძველებელი თეთრი';

  @override
  String get profileNameRoseFresh => 'ხალისიანი ვარდისფერი';

  @override
  String get profileNameSpTank => 'ხალისიანი ცქრიალა, რეზერვუარული მეთოდი';

  @override
  String get profileNameLamFresh => 'ხალისიანი Lambrusco';

  @override
  String get profileNameSpClassic => 'ხალისიანი ცქრიალა, კლასიკური მეთოდი';

  @override
  String get profileNameSpClassicAge =>
      'დასაძველებელი ცქრიალა, კლასიკური მეთოდი';

  @override
  String get profileNameSwAromatic => 'ახალგაზრდა არომატული ტკბილი ღვინო';

  @override
  String get profileNameSwPassito => 'ტკბილი ღვინო შემჭკნარი ყურძნისგან';

  @override
  String get profileNameSwBotrytis => 'ბოტრიტისიანი ტკბილი ღვინო';

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
  String get profileNameFortUnknown => 'შემაგრებული, სტილი უცნობია';

  @override
  String get profileNameUnknown => 'სტილი ვერ დადგინდა';

  @override
  String estimateFromProfile(String profile, String denomination) {
    return 'პროგნოზი პროფილის მიხედვით: „$profile“ ($denomination)';
  }

  @override
  String estimateFromProfileType(String profile) {
    return 'პროგნოზი პროფილის მიხედვით: „$profile“, ტიპით';
  }

  @override
  String estimateFromProfileGrape(String profile, String grape) {
    return 'პროგნოზი პროფილის მიხედვით: „$profile“, ყურძნის ჯიშით: $grape';
  }

  @override
  String get estimateFromEntryDateDisgorgement =>
      'დამატების თარიღის მიხედვით: უკეთესი პროგნოზისთვის მიუთითეთ დეგორჟაჟის თარიღი';

  @override
  String get estimateFromEntryDateBottling =>
      'დამატების თარიღის მიხედვით: უკეთესი პროგნოზისთვის მიუთითეთ ჩამოსხმის თარიღი';

  @override
  String get styleToConfirmBanner =>
      '⚠︎ სტილი დასადასტურებელია: პროგნოზი სავარაუდოა';

  @override
  String get chooseTypePrompt => 'აირჩიეთ ტიპი';

  @override
  String estimateUpdatedAnnouncement(String summary) {
    return 'პროგნოზი განახლდა: $summary';
  }

  @override
  String get agingStartDisgorgement => 'დეგორჟაჟი';

  @override
  String get agingStartBottling => 'ჩამოსხმა';

  @override
  String get agingStartMonth => 'თვე';

  @override
  String get agingStartYear => 'წელი';

  @override
  String get agingStartHint => 'ჩვეულებრივ უკანა ეტიკეტზე წერია.';

  @override
  String get agingStartIncomplete => 'მიუთითეთ თვე და წელი';

  @override
  String get agingStartFuture => 'თარიღი არ შეიძლება იყოს მომავალში';

  @override
  String get agingStartBeforeVintage => 'არ შეიძლება იყოს მოსავლის წელზე ადრე';

  @override
  String get windowNoEnd => 'მზადაა, დასასრული არ არის პროგნოზირებული';

  @override
  String get windowNoEndShort => 'დასასრული არ არის პროგნოზირებული';

  @override
  String windowDrinkWithin(String date) {
    return 'ვადა: $date';
  }

  @override
  String get levelNoEffect => 'დონე ამ პროგნოზს არ ცვლის';

  @override
  String get dashboardToConfirmTitle => 'დასადასტურებელი';

  @override
  String dashboardToConfirmCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ღვინო',
      one: '1 ღვინო',
    );
    return '$_temp0';
  }

  @override
  String aboutDbClassified(String percent) {
    return 'ღვინოების $percent%-ს ტიპი ამოცნობილი აქვს';
  }

  @override
  String get planTitle => 'გეგმა';

  @override
  String get planFree => 'უფასო';

  @override
  String get planPlus => 'Plus';

  @override
  String get planPlusGift => 'Plus (საჩუქარი)';

  @override
  String get planDevUnlockAll => 'DEV · სატესტო Plus';

  @override
  String get planDevSimulateFree => 'DEV · უფასო გეგმის სიმულაცია';

  @override
  String get planDevSimulateExpired => 'DEV · ვადაგასული Plus-ის სიმულაცია';

  @override
  String get planDiscoverPlus => 'გაიცანით Plus';

  @override
  String get plusTitle => 'Vinoozy Plus';

  @override
  String get plusBenefitsTitle => 'Plus-ით';

  @override
  String get plusBenefitNoAds => 'რეკლამის გარეშე';

  @override
  String get plusBenefitNoLimit => 'მარანში ღვინოების ლიმიტის გარეშე';

  @override
  String get plusComingSoon => 'Plus მალე გამოჩნდება';

  @override
  String get plusLoading => 'ფასების წაკითხვა Google Play-დან';

  @override
  String get plusStoreUnavailable =>
      'Google Play-დან ფასების წაკითხვა ვერ მოხერხდა. სცადეთ მოგვიანებით.';

  @override
  String plusPriceMonthly(String price) {
    return '$price თვეში';
  }

  @override
  String plusPriceAnnual(String price) {
    return '$price წელიწადში';
  }

  @override
  String get plusRenewal =>
      'გამოწერა ავტომატურად ახლდება მითითებულ ფასად, სანამ არ გააუქმებთ Google Play-ში.';

  @override
  String get plusTerms =>
      'გადასახადი ჩამოიჭრება თქვენი Google Play ანგარიშიდან, როცა შენაძენს დაადასტურებთ. გაუქმება ნებისმიერ დროს შეგიძლიათ: Plus აქტიური რჩება უკვე გადახდილი პერიოდის ბოლომდე. Plus-ის დასრულების შემდეგ თქვენი ყველა ღვინო რჩება.';

  @override
  String get plusRestore => 'შენაძენების აღდგენა';

  @override
  String get plusManage => 'გამოწერის მართვა ან გაუქმება Google Play-ში';

  @override
  String get plusActive => 'Plus აქტიურია ამ ანგარიშზე';

  @override
  String get plusActiveGift =>
      'Plus საჩუქრად გაქვთ: გადასახადისა და განახლების გარეშე.';

  @override
  String get plusPending =>
      'გადახდა მოლოდინშია: Plus გააქტიურდება, როცა Google Play დაადასტურებს.';

  @override
  String get plusVerifying => 'შენაძენის შემოწმება';

  @override
  String get plusVerified =>
      'შენაძენი შემოწმდა: Plus რამდენიმე წამში გააქტიურდება.';

  @override
  String get plusPurchaseFailed => 'შენაძენი არ დასრულებულა. სცადეთ ხელახლა.';

  @override
  String get plusInvalidPurchase =>
      'Google Play-მ ეს შენაძენი Vinoozy-სთვის არ დაადასტურა.';

  @override
  String get plusOwnedByOther =>
      'ეს გამოწერა უკვე Vinoozy-ს სხვა ანგარიშს ეკუთვნის.';

  @override
  String get plusVerificationUnavailable =>
      'შენაძენის შემოწმება ახლა ვერ მოხერხდა. სცადეთ მოგვიანებით: გამოწერა Google Play-ში რჩება.';

  @override
  String get capacityLimitTitle => 'მიაღწიეთ უფასო გეგმის ლიმიტს';

  @override
  String capacityLimitBody(int limit) {
    return 'უფასო გეგმა მოიცავს მაქსიმუმ $limit სხვადასხვა ღვინოს მარანში. ყოველთვის შეგიძლიათ უკვე არსებული ღვინოების რედაქტირება, დალევა და მათთვის ბოთლების დამატება. ახლის დასამატებლად დაასრულეთ ან წაშალეთ რომელიმე ღვინო, ან გადადით Plus-ზე.';
  }

  @override
  String capacityLimitBodyComingSoon(int limit) {
    return 'უფასო გეგმა მოიცავს მაქსიმუმ $limit სხვადასხვა ღვინოს მარანში. ყოველთვის შეგიძლიათ უკვე არსებული ღვინოების რედაქტირება, დალევა და მათთვის ბოთლების დამატება. ახლის დასამატებლად დაასრულეთ ან წაშალეთ რომელიმე ღვინო. Plus მალე გამოჩნდება.';
  }

  @override
  String get rejectedCapacityLimit =>
      'არ არის სინქრონიზებული: აჭარბებს უფასო გეგმის ღვინოების ლიმიტს. ცვლილება ამ ტელეფონში რჩება.';

  @override
  String get rejectedCapacityConflict =>
      'არ არის სინქრონიზებული: მარანი იმავდროულად შეიცვალა სხვა მოწყობილობაზე. ცვლილება ამ ტელეფონში რჩება: სცადეთ ხელახლა.';

  @override
  String writeRejectedCapacityLimit(String name) {
    return '$name: არ არის სინქრონიზებული, აჭარბებს უფასო გეგმის ლიმიტს';
  }

  @override
  String writeRejectedCapacityConflict(String name) {
    return '$name: არ არის სინქრონიზებული, მარანი შეიცვალა სხვა მოწყობილობაზე';
  }

  @override
  String get freeIntroTitle => 'უფასო გეგმა';

  @override
  String freeIntroLimit(int limit) {
    return 'უფასოდ შეგიძლიათ მართოთ მაქსიმუმ $limit სხვადასხვა ღვინო.';
  }

  @override
  String get freeIntroAds =>
      'მსუბუქი გამოყენება რეკლამის გარეშეა. თუ სერვისის გამოყენების ყოველთვიურ ზღვარს გადააჭარბებთ, შეიძლება დროდადრო ნახოთ რეკლამა, რომელიც სერვერებისა და სინქრონიზაციის ხარჯების დაფარვაში გვეხმარება.';

  @override
  String get freeIntroNoAds => 'საწყის ვერსიაში რეკლამა არ არის.';

  @override
  String get freeIntroPlus => 'Plus-ით ხსნით რეკლამასა და მარნის ლიმიტს.';

  @override
  String get noticeGotIt => 'გასაგებია';

  @override
  String get thresholdTitle => 'რეკლამა გვეხმარება, რომ Vinoozy უფასო დარჩეს';

  @override
  String get thresholdBody =>
      'მიაღწიეთ რეკლამის გარეშე გამოყენების ყოველთვიურ ზღვარს. ამიერიდან შეიძლება დროდადრო ნახოთ რეკლამა: ის გვეხმარება სერვერებისა და სინქრონიზაციის ხარჯების დაფარვაში, რათა Vinoozy უფასო დარჩეს.';

  @override
  String get thresholdReset =>
      'ათვლა თავიდან დაიწყება შემდეგ თვეს. Plus-ით აპის გამოყენება შეგიძლიათ რეკლამისა და მარნის ლიმიტის გარეშე.';

  @override
  String thresholdNextReset(String date) {
    return 'შემდეგი განულება: $date';
  }

  @override
  String get thresholdHowItWorks => 'როგორ მუშაობს';

  @override
  String get thresholdHowItWorksBody =>
      'ზღვარი დამოკიდებულია ღრუბელთან სინქრონიზაციების მიახლოებით რაოდენობაზე, რომელიც ამ ანგარიშმა თვის განმავლობაში შეასრულა. მხოლოდ ხაზგარეშე გამოყენება ღრუბელში ახალ ოპერაციებს არ ქმნის. რეკლამა ჩნდება მაქსიმუმ დღეში ერთხელ, მხოლოდ მიმოხილვის ეკრანზე, და არასდროს — მონაცემების შენახვის ან ექსპორტის დროს.';

  @override
  String get adLabel => 'რეკლამა';

  @override
  String get devToolsTitle => 'დეველოპერის ინსტრუმენტები';

  @override
  String get devUnlockAll => 'ყველაფრის განბლოკვა — სატესტო Plus';

  @override
  String get devSimulateFree => 'უფასო გეგმის სიმულაცია';

  @override
  String get devSimulateExpired => 'ვადაგასული Plus-ის სიმულაცია';

  @override
  String get devRestore => 'ჩვეულებრივი მდგომარეობის აღდგენა';

  @override
  String get devNoOverride => 'აქტიური სიმულაცია არ არის';

  @override
  String get devApplied => 'სცენარი Firestore-ის ემულატორშიც გამოყენებულია';

  @override
  String get devIncomplete =>
      'არასრული სიმულაცია: Firestore-ის ემულატორმა სატესტო უფლება არ დაადასტურა. სერვერის წესები ამ სცენარს ვერ ხედავს.';

  @override
  String get devNotice =>
      'მხოლოდ დეველოპერული ვერსიებისთვის ემულატორით: გადახდების, ტოკენებისა და ქვითრების გარეშე.';
}
