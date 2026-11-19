// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Modern Greek (`el`).
class AppLocalizationsEl extends AppLocalizations {
  AppLocalizationsEl([String locale = 'el']) : super(locale);

  @override
  String get appTitle => 'Vinoozy';

  @override
  String get signInTagline => 'Η κάβα σας, την κατάλληλη στιγμή';

  @override
  String get signInWithGoogle => 'Συνέχεια με Google';

  @override
  String get signInInProgress => 'Σύνδεση σε εξέλιξη';

  @override
  String get signInFailed => 'Η σύνδεση απέτυχε';

  @override
  String get signInNeedsNetwork =>
      'Για την πρώτη σύνδεση χρειάζεται σύνδεση στο διαδίκτυο';

  @override
  String get signInSessionExpired => 'Η συνεδρία σας έληξε: συνδεθείτε ξανά';

  @override
  String get retry => 'Επανάληψη';

  @override
  String get cancel => 'Ακύρωση';

  @override
  String blockedMessage(String email) {
    return 'Υπάρχουν αλλαγές του λογαριασμού $email που δεν έχουν αποθηκευτεί ακόμη στο cloud: συνδεθείτε με αυτόν τον λογαριασμό και συνδεθείτε στο δίκτυο';
  }

  @override
  String blockedSignInWith(String email) {
    return 'Σύνδεση ως $email';
  }

  @override
  String blockedDiscard(String email) {
    return 'Διαγραφή μη αποθηκευμένων αλλαγών του $email';
  }

  @override
  String get discardDialogTitle => 'Διαγραφή των αλλαγών;';

  @override
  String discardDialogBody(int count, String email) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count κρασιά του λογαριασμού $email δεν είναι ακόμη στο cloud και θα διαγραφούν από αυτό το τηλέφωνο.',
      one:
          '1 κρασί του λογαριασμού $email δεν είναι ακόμη στο cloud και θα διαγραφεί από αυτό το τηλέφωνο.',
    );
    return '$_temp0';
  }

  @override
  String get discardConfirm => 'Διαγραφή';

  @override
  String get resetFailed =>
      'Δεν ήταν δυνατή η εκκαθάριση των δεδομένων σε αυτό το τηλέφωνο';

  @override
  String get restartRequired => 'Επανεκκινήστε την εφαρμογή για ολοκλήρωση';

  @override
  String get restartCloseApp => 'Κλείσιμο εφαρμογής';

  @override
  String get startupFailed => 'Δεν ήταν δυνατή η εκκίνηση της εφαρμογής';

  @override
  String get cellarTitle => 'Κάβα';

  @override
  String get defaultCellarName => 'Η κάβα μου';

  @override
  String get cellarLoading => 'Προετοιμασία της κάβας';

  @override
  String get cellarSetupFailed => 'Δεν ήταν δυνατή η προετοιμασία της κάβας';

  @override
  String get cellarEmpty => 'Η κάβα σας είναι άδεια';

  @override
  String get addWine => 'Προσθήκη';

  @override
  String get estimatePending => 'Η εκτίμηση έρχεται';

  @override
  String get noVintage => 'Χωρίς χρονιά';

  @override
  String bottleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count φιάλες',
      one: '1 φιάλη',
    );
    return '$_temp0';
  }

  @override
  String get syncInProgress => 'Συγχρονισμός';

  @override
  String get syncOffline => 'Εκτός σύνδεσης – ο συγχρονισμός εκκρεμεί';

  @override
  String writeRejected(String name) {
    return 'Η αλλαγή δεν επιτρέπεται: $name';
  }

  @override
  String get saveFailed => 'Η αποθήκευση απέτυχε, δοκιμάστε ξανά';

  @override
  String wineNotSaved(String name) {
    return 'Το κρασί $name δεν αποθηκεύτηκε στο cloud';
  }

  @override
  String get addAgain => 'Προσθήκη ξανά';

  @override
  String get ignore => 'Παράβλεψη';

  @override
  String get addWineTitle => 'Πληκτρολόγηση';

  @override
  String get wineNameLabel => 'Κρασί';

  @override
  String get vintageLabel => 'Χρονιά';

  @override
  String get quantityLabel => 'Ποσότητα';

  @override
  String get decreaseQuantity => 'Μείωση ποσότητας';

  @override
  String get increaseQuantity => 'Αύξηση ποσότητας';

  @override
  String get save => 'Αποθήκευση';

  @override
  String get nameRequired => 'Γράψτε το όνομα του κρασιού';

  @override
  String get nameTooLong => 'Έως 120 χαρακτήρες';

  @override
  String vintageRange(String year) {
    return 'Χρονιά από 1900 έως $year';
  }

  @override
  String get offAttribution => 'Δεδομένα από το Open Food Facts (ODbL)';

  @override
  String get dashboardTitle => 'Επισκόπηση';

  @override
  String dashboardTotalBottles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count φιάλες στην κάβα',
      one: '1 φιάλη στην κάβα',
    );
    return '$_temp0';
  }

  @override
  String get dashboardSyncing => 'Συγχρονισμός της κάβας…';

  @override
  String get dashboardAddFirstWine => 'Προσθέστε το πρώτο σας κρασί';

  @override
  String get drinkSoonTitle => 'Να πιωθούν σύντομα';

  @override
  String get drinkSoonEmpty => 'Καμία φιάλη που πρέπει να πιωθεί σύντομα';

  @override
  String drinkSoonUntil(String year) {
    return 'έως το $year';
  }

  @override
  String drinkSoonSeeAll(int count) {
    return 'Προβολή όλων ($count)';
  }

  @override
  String get statusChartTitle => 'Κατάσταση φιαλών';

  @override
  String get statusWaiting => 'σε αναμονή';

  @override
  String get statusReady => 'έτοιμες';

  @override
  String get statusDrinkSoon => 'να πιωθούν σύντομα';

  @override
  String get statusPastWindow => 'εκτός παραθύρου';

  @override
  String toEstimateNote(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count φιάλες χωρίς εκτίμηση',
      one: '1 φιάλη χωρίς εκτίμηση',
    );
    return '$_temp0';
  }

  @override
  String chartBarValue(String label, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count φιάλες',
      one: '1 φιάλη',
    );
    return '$label: $_temp0';
  }

  @override
  String chartDescription(String title, String values) {
    return '$title: $values';
  }

  @override
  String get openListHint => 'Άνοιγμα της λίστας';

  @override
  String get peakChartTitle => 'Έτος κορύφωσης';

  @override
  String get peakPast => 'πέρασε η κορύφωση';

  @override
  String get peakBeyond => 'αργότερα';

  @override
  String get breakdownTypeTitle => 'Φιάλες ανά τύπο';

  @override
  String get breakdownRegionTitle => 'Φιάλες ανά περιοχή';

  @override
  String get breakdownType => 'Τύπος';

  @override
  String get breakdownRegion => 'Περιοχή';

  @override
  String get familyRed => 'ερυθρό';

  @override
  String get familyWhite => 'λευκό';

  @override
  String get familyRose => 'ροζέ';

  @override
  String get familySparkling => 'αφρώδες';

  @override
  String get familySweet => 'γλυκό';

  @override
  String get breakdownUnspecified => 'χωρίς ένδειξη';

  @override
  String get breakdownOtherRegions => 'άλλες';

  @override
  String get ok => 'OK';

  @override
  String get cellarMenu => 'Μενού κάβας';

  @override
  String get sharingPeopleTitle => 'Άτομα';

  @override
  String get sharingInviteTitle => 'Προσκαλέστε ένα άτομο';

  @override
  String get sharingEmailLabel => 'Διεύθυνση email Google';

  @override
  String get sharingPermissionRead => 'Μόνο προβολή';

  @override
  String get sharingPermissionReadHint =>
      'Βλέπει κρασιά, εκτιμήσεις, επισκόπηση και καταναλώσεις';

  @override
  String get sharingPermissionEdit => 'Μπορεί να επεξεργαστεί';

  @override
  String get sharingPermissionEditHint =>
      'Επίσης προσθέτει και αλλάζει κρασιά και καταγράφει καταναλώσεις';

  @override
  String get sharingRoleOwner => 'κάτοχος';

  @override
  String get sharingInviteButton => 'Πρόσκληση';

  @override
  String sharingPlacesUsed(int used, int max) {
    return 'Άτομα: $used/$max';
  }

  @override
  String get sharingInvalidEmail => 'Εισαγάγετε ένα έγκυρο email';

  @override
  String get sharingSelfInvite => 'Δεν μπορείτε να προσκαλέσετε τον εαυτό σας';

  @override
  String get sharingAlreadyInvited => 'Αυτό το άτομο έχει ήδη προσκληθεί';

  @override
  String sharingLimitReached(int max) {
    return 'Φτάσατε το όριο ατόμων: $max';
  }

  @override
  String get sharingNotOwner =>
      'Δεν μπορείτε να αλλάξετε την κοινή χρήση αυτής της κάβας';

  @override
  String get sharingNotFound => 'Αυτό το άτομο δεν είναι πλέον στη λίστα';

  @override
  String get sharingFailed => 'Δεν ολοκληρώθηκε, δοκιμάστε ξανά';

  @override
  String get sharingInviteFailed => 'Η πρόσκληση απέτυχε. Δοκιμάστε ξανά';

  @override
  String get sharingOfflineHint =>
      'Χρειάζεται σύνδεση για τη διαχείριση της κοινής χρήσης';

  @override
  String get sharingStatusInvited => 'με πρόσκληση';

  @override
  String get sharingStatusActive => 'με πρόσβαση';

  @override
  String get sharingStatusRevoked => 'ανάκληση πρόσβασης';

  @override
  String get sharingStatusLeft => 'αποχώρηση';

  @override
  String sharingMemberSemantics(String name, String permission, String status) {
    return '$name, $permission, $status';
  }

  @override
  String get sharingClosedSection => 'Κλειστές προσβάσεις';

  @override
  String get sharingNobody => 'Κανείς άλλος δεν βλέπει ακόμη αυτή την κάβα';

  @override
  String sharingChangePermission(String name) {
    return 'Αλλαγή δικαιώματος: $name';
  }

  @override
  String get sharingRevoke => 'Ανάκληση';

  @override
  String sharingRevokeTitle(String name) {
    return 'Ανάκληση πρόσβασης για τον χρήστη $name;';
  }

  @override
  String sharingRevokeConfirmLabel(String name) {
    return 'Πληκτρολογήστε $name για επιβεβαίωση';
  }

  @override
  String get sharingRevokeDisabledHint =>
      'Ενεργοποιείται όταν το όνομα ταιριάζει';

  @override
  String get sharingReinvite => 'Νέα πρόσκληση';

  @override
  String get sharingDeleteForGood => 'Οριστική διαγραφή';

  @override
  String sharingOwnedBy(String owner) {
    return 'Κάβα του χρήστη $owner';
  }

  @override
  String get sharingYourCellar => 'Η κάβα σας';

  @override
  String sharingYourPermission(String permission) {
    return 'Το δικαίωμά σας: $permission';
  }

  @override
  String sharingSwitcherSemantics(String cellar, String permission) {
    return '$cellar, $permission. Πατήστε για αλλαγή κάβας';
  }

  @override
  String get sharingLeave => 'Αποχώρηση από αυτή την κάβα';

  @override
  String sharingLeaveTitle(String owner) {
    return 'Αποχώρηση από την κάβα του χρήστη $owner;';
  }

  @override
  String sharingLeaveBody(String owner) {
    return 'Δεν θα τη βλέπετε πλέον. Ο χρήστης $owner μπορεί να σας προσκαλέσει ξανά.';
  }

  @override
  String get sharingLeaveConfirm => 'Αποχώρηση';

  @override
  String sharingSharedNotice(String owner) {
    return 'Ο χρήστης $owner μοιράζεται την κάβα του μαζί σας';
  }

  @override
  String sharingAccessLost(String owner) {
    return 'Δεν έχετε πλέον πρόσβαση στην κάβα του χρήστη $owner';
  }

  @override
  String sharingWritesLost(String owner) {
    return 'Ορισμένες αλλαγές στην κάβα του χρήστη $owner δεν αποθηκεύτηκαν επειδή δεν έχετε πλέον πρόσβαση';
  }

  @override
  String get sharingSomeone => 'χωρίς όνομα';

  @override
  String get sharingShareSubject => 'Πρόσκληση στο Vinoozy';

  @override
  String sharingShareMessage(
    String owner,
    String cellar,
    String link,
    String email,
  ) {
    return 'Ο χρήστης $owner σας προσκαλεί στην κάβα «$cellar» στο Vinoozy. Εγκαταστήστε την εφαρμογή από το $link και συνδεθείτε με τον λογαριασμό Google $email: χρησιμοποιήστε ακριβώς αυτή τη διεύθυνση.';
  }

  @override
  String get cellarSearchHint => 'Αναζήτηση με όνομα ή παραγωγό';

  @override
  String get cellarFilterStatus => 'Κατάσταση';

  @override
  String get cellarFilterType => 'Τύπος';

  @override
  String get statusToEstimate => 'Χωρίς εκτίμηση';

  @override
  String get filterTypeUnspecified => 'Χωρίς ένδειξη';

  @override
  String get cellarNoMatches => 'Κανένα κρασί με αυτά τα φίλτρα';

  @override
  String get cellarClearFilters => 'Καθαρισμός φίλτρων';

  @override
  String get cellarArchiveTitle => 'Καταναλωμένα';

  @override
  String get cellarArchiveEmpty => 'Κανένα κρασί δεν έχει τελειώσει ακόμη';

  @override
  String get cellarArchiveFailed =>
      'Δεν ήταν δυνατή η φόρτωση των κρασιών που τελείωσαν';

  @override
  String get wineDrink => 'Το ήπια';

  @override
  String wineDrinkTooltip(String name) {
    return 'Σήμανση μιας φιάλης $name ως καταναλωμένης';
  }

  @override
  String confidenceLabel(String level) {
    return 'Αξιοπιστία: $level';
  }

  @override
  String get confidenceHigh => 'υψηλή';

  @override
  String get confidenceMedium => 'μέτρια';

  @override
  String get confidenceLow => 'χαμηλή';

  @override
  String get windowStartLabel => 'Έναρξη';

  @override
  String get windowPeakLabel => 'Κορύφωση';

  @override
  String get windowEndLabel => 'Λήξη';

  @override
  String estimateSourceLabel(String source) {
    return 'Πηγή: $source';
  }

  @override
  String get estimateSourceCatalog => 'βάση δεδομένων κρασιών';

  @override
  String get estimateSourceType => 'εκτίμηση βάσει τύπου';

  @override
  String get estimateSourceCorrected =>
      'εκτίμηση διορθωμένη από τις καταναλώσεις σας';

  @override
  String get estimateDisclaimer =>
      'Ενδεικτική εκτίμηση: εξαρτάται και από το πώς φυλάχτηκε η φιάλη';

  @override
  String get estimateUnavailable => 'Η εκτίμηση δεν είναι διαθέσιμη';

  @override
  String get pairingsTitle => 'Συνδυασμοί';

  @override
  String get pairingsGeneric => 'γενικοί συνδυασμοί για τον τύπο';

  @override
  String get pairingBraisedRedMeat => 'Κόκκινο κρέας κατσαρόλας';

  @override
  String get pairingGrilledRedMeat => 'Κόκκινο κρέας στη σχάρα';

  @override
  String get pairingGame => 'Κυνήγι';

  @override
  String get pairingRoastPoultry => 'Ψητά πουλερικά';

  @override
  String get pairingPoultry => 'Πουλερικά';

  @override
  String get pairingPork => 'Χοιρινό';

  @override
  String get pairingCuredMeats => 'Αλλαντικά';

  @override
  String get pairingPastaMeatSauce => 'Ζυμαρικά με σάλτσα κρέατος';

  @override
  String get pairingMushroomsTruffle => 'Μανιτάρια και τρούφα';

  @override
  String get pairingAgedCheese => 'Ώριμα τυριά';

  @override
  String get pairingFreshCheese => 'Φρέσκα τυριά';

  @override
  String get pairingBlueCheese => 'Μπλε τυριά';

  @override
  String get pairingFish => 'Ψάρι';

  @override
  String get pairingSeafood => 'Θαλασσινά';

  @override
  String get pairingRawSeafood => 'Ωμά θαλασσινά';

  @override
  String get pairingFriedFood => 'Τηγανητά';

  @override
  String get pairingVegetables => 'Λαχανικά';

  @override
  String get pairingRisotto => 'Ριζότο';

  @override
  String get pairingPizza => 'Πίτσα';

  @override
  String get pairingAperitif => 'Απεριτίφ';

  @override
  String get pairingPastries => 'Γλυκά ζαχαροπλαστικής';

  @override
  String get pairingDryBiscuits => 'Ξηρά μπισκότα';

  @override
  String get pairingChocolate => 'Σοκολάτα';

  @override
  String get pairingDriedFruit => 'Ξηροί καρποί';

  @override
  String get pairingSpicyDishes => 'Πικάντικα πιάτα';

  @override
  String get recentDrinksTitle => 'Τελευταίες καταναλώσεις';

  @override
  String get noDrinksYet => 'Καμία κατανάλωση ακόμη';

  @override
  String get wineEdit => 'Επεξεργασία';

  @override
  String get wineDelete => 'Διαγραφή';

  @override
  String get wineFinished => 'Τελείωσε: δεν έμεινε καμία φιάλη';

  @override
  String get wineLoadFailed => 'Δεν ήταν δυνατό το άνοιγμα του κρασιού';

  @override
  String get wineNotFound => 'Αυτό το κρασί δεν υπάρχει πλέον';

  @override
  String drinkDone(String name) {
    return 'Σημειώθηκε κατανάλωση: $name';
  }

  @override
  String get drinkUndo => 'Αναίρεση';

  @override
  String get drinkAddNotes => 'Προσθήκη βαθμολογίας και σημειώσεων';

  @override
  String get nothingToUndo => 'Δεν υπάρχει τίποτα άλλο για αναίρεση';

  @override
  String get cellarUndoRejected =>
      'Η αναίρεση απέτυχε: η φιάλη παραμένει σημειωμένη ως καταναλωμένη';

  @override
  String get cellarDeleteFailed =>
      'Η διαγραφή δεν έχει ολοκληρωθεί ακόμη: θα ολοκληρωθεί το συντομότερο δυνατό';

  @override
  String get duplicateFull =>
      'Αυτό το κρασί έχει ήδη 99 φιάλες: δεν μπορούν να προστεθούν άλλες.';

  @override
  String get recordSheetTitle => 'Βαθμολογία και σημειώσεις';

  @override
  String get recordRatingLabel => 'Βαθμολογία';

  @override
  String ratingStar(int n) {
    return 'Βαθμολογία $n στα 5';
  }

  @override
  String get recordNotesLabel => 'Σημειώσεις';

  @override
  String get recordNotesTooLong => 'Έως 1000 χαρακτήρες';

  @override
  String recordDateLabel(String date) {
    return 'Ημερομηνία: $date';
  }

  @override
  String get recordDateInvalid =>
      'Η ημερομηνία δεν μπορεί να είναι μελλοντική ούτε πριν από τη χρονιά του κρασιού';

  @override
  String get recordConditionTitle => 'Πώς ήταν;';

  @override
  String get conditionTooYoung => 'Ακόμη πολύ νέο';

  @override
  String get conditionJustRight => 'Στην ώρα του';

  @override
  String get conditionPastPeak => 'Μετά την κορύφωσή του';

  @override
  String get recordNoCondition => 'Χωρίς απάντηση';

  @override
  String get producerLabel => 'Παραγωγός (προαιρετικά)';

  @override
  String get producerTooLong => 'Έως 120 χαρακτήρες';

  @override
  String producerAddNew(String name) {
    return 'Προσθήκη νέου παραγωγού: «$name»';
  }

  @override
  String get wineTypeLabel => 'Τύπος';

  @override
  String get typeRedLight => 'Ελαφρύ ερυθρό';

  @override
  String get typeRedStructured => 'Ερυθρό με σώμα';

  @override
  String get typeWhite => 'Λευκό';

  @override
  String get typeRose => 'Ροζέ';

  @override
  String get typeSparklingClassic => 'Αφρώδες, παραδοσιακή μέθοδος';

  @override
  String get typeSparklingTank => 'Αφρώδες, μέθοδος δεξαμενής';

  @override
  String get typeSweet => 'Γλυκό';

  @override
  String get typeFortified => 'Ενισχυμένο';

  @override
  String get suggestionFromCellar => 'Στην κάβα σας';

  @override
  String get suggestionsLabel => 'Προτάσεις';

  @override
  String get duplicateTitle => 'Υπάρχει ήδη στην κάβα';

  @override
  String duplicateBody(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count φιάλες',
      one: '1 φιάλη',
      zero: 'καμία φιάλη',
    );
    return 'Το κρασί $name υπάρχει ήδη, με $_temp0. Να προστεθούν εκεί οι νέες φιάλες;';
  }

  @override
  String duplicateAdd(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Προσθήκη $count φιαλών',
      one: 'Προσθήκη 1 φιάλης',
    );
    return '$_temp0';
  }

  @override
  String get duplicateBanner => 'Πιθανή διπλή καταχώριση';

  @override
  String get duplicateMerge => 'Συγχώνευση';

  @override
  String get duplicateDeleteHint =>
      'Διαγράψτε αυτή την καταχώριση αν είναι διπλή';

  @override
  String get mergeTitle => 'Συγχώνευση των δύο καταχωρίσεων;';

  @override
  String get mergeBody =>
      'Οι φιάλες αυτής της καταχώρισης μεταφέρονται στην παλαιότερη και έπειτα αυτή η καταχώριση διαγράφεται.';

  @override
  String get editWineTitle => 'Επεξεργασία κρασιού';

  @override
  String get editDuplicate =>
      'Υπάρχει ήδη άλλο κρασί με το ίδιο όνομα, παραγωγό και χρονιά';

  @override
  String deleteWineTitle(String name) {
    return 'Διαγραφή: $name;';
  }

  @override
  String get deleteWineBody =>
      'Το κρασί και όλες οι καταναλώσεις του διαγράφονται. Η ενέργεια δεν αναιρείται.';

  @override
  String get historyTitle => 'Ιστορικό';

  @override
  String get historyEmpty => 'Εδώ θα βρείτε τις φιάλες που ήπιατε';

  @override
  String get historyLoadFailed => 'Δεν ήταν δυνατή η φόρτωση του ιστορικού';

  @override
  String drankOnLabel(String date) {
    return 'Κατανάλωση: $date';
  }

  @override
  String get addChoiceTitle => 'Προσθήκη κρασιού';

  @override
  String get addChoicePhoto => 'Λήψη φωτογραφίας';

  @override
  String get addChoiceImport => 'Εισαγωγή φωτογραφίας';

  @override
  String get addChoiceWrite => 'Πληκτρολόγηση';

  @override
  String get labelReading => 'Διαβάζω την ετικέτα…';

  @override
  String get labelRecognized => 'Αναγνώρισα:';

  @override
  String get labelCorrect => 'Διόρθωση';

  @override
  String get labelConfirm => 'Επιβεβαίωση';

  @override
  String get labelUnreadable => 'Δεν μπορώ να διαβάσω την ετικέτα';

  @override
  String get labelWriteByHand => 'Χειροκίνητη καταχώριση';

  @override
  String get labelNotFound => 'Δεν βρήκα το κρασί: ελέγξτε τα στοιχεία';

  @override
  String get labelCameraDenied =>
      'Για να διαβάσω την ετικέτα χρειάζομαι πρόσβαση στην κάμερα';

  @override
  String get labelPhotosDenied =>
      'Για να διαβάσω την ετικέτα χρειάζομαι πρόσβαση στις φωτογραφίες';

  @override
  String get labelOpenSettings => 'Άνοιγμα ρυθμίσεων';

  @override
  String get labelCameraUnavailable => 'Η κάμερα δεν είναι διαθέσιμη';

  @override
  String get labelBarcodeNotFound =>
      'Διάβασα τον γραμμωτό κώδικα αλλά δεν βρίσκω το κρασί';

  @override
  String get labelBarcodeFrontHint => 'Φωτογραφίστε την μπροστινή ετικέτα';

  @override
  String get labelSharedNotAllowed =>
      'Δεν μπορείτε να προσθέσετε κρασιά σε αυτή την κάβα';

  @override
  String get labelSharedFirstOnly => 'Χρησιμοποίησα μόνο την πρώτη φωτογραφία';

  @override
  String get labelSharedExpired =>
      'Δεν ήταν δυνατή η ανάγνωση της κοινοποιημένης φωτογραφίας: κοινοποιήστε την ξανά';

  @override
  String get labelReplaceTitle =>
      'Έχετε ένα κρασί που δεν αποθηκεύτηκε. Να διαβάσω τη νέα φωτογραφία;';

  @override
  String get labelReplaceRead => 'Ανάγνωση νέας φωτογραφίας';

  @override
  String get labelReplaceKeep => 'Συνέχεια με το ανοιχτό';

  @override
  String get labelWineAdded => 'Το κρασί προστέθηκε στην κάβα';

  @override
  String get onboardingPage1Title => 'Η κάβα σας στην τσέπη σας';

  @override
  String get onboardingPage1Body =>
      'Προσθέστε τις φιάλες σας πληκτρολογώντας τες ή με μια φωτογραφία της ετικέτας, ακόμη και χωρίς δίκτυο.';

  @override
  String get onboardingPage2Title => 'Την κατάλληλη στιγμή';

  @override
  String get onboardingPage2Body =>
      'Το Vinoozy εκτιμά πότε κάθε κρασί είναι στα καλύτερά του και σας λέει ποια να ανοίξετε πρώτα.';

  @override
  String get onboardingPage3Title => 'Μαζί';

  @override
  String get onboardingPage3Body =>
      'Μοιραστείτε την κάβα σας με έως δύο άτομα και κρατήστε το ιστορικό κάθε φιάλης που πίνετε.';

  @override
  String get onboardingSkip => 'Παράλειψη';

  @override
  String get onboardingNext => 'Επόμενο';

  @override
  String get onboardingStart => 'Έναρξη';

  @override
  String onboardingPageOf(int page) {
    return 'Σελίδα $page από 3';
  }

  @override
  String get profileTitle => 'Προφίλ';

  @override
  String get profilePhoto => 'Φωτογραφία προφίλ';

  @override
  String get profileSignOut => 'Αποσύνδεση';

  @override
  String get profileDeleteAccount => 'Διαγραφή λογαριασμού';

  @override
  String get profilePrivacy => 'Πολιτική απορρήτου';

  @override
  String get profilePrivacyBody =>
      'Μπορείτε να διαβάσετε την πολιτική απορρήτου σε αυτή τη διεύθυνση:';

  @override
  String get profileOpenLink => 'Άνοιγμα στο πρόγραμμα περιήγησης';

  @override
  String get profileOpenLinkFailed =>
      'Δεν ήταν δυνατό το άνοιγμα της σελίδας. Μπορείτε να αντιγράψετε τον σύνδεσμο και να τον ανοίξετε στο πρόγραμμα περιήγησης.';

  @override
  String get profileCopyLink => 'Αντιγραφή συνδέσμου';

  @override
  String get profileLinkCopied => 'Ο σύνδεσμος αντιγράφηκε';

  @override
  String get close => 'Κλείσιμο';

  @override
  String get signOutConfirmTitle => 'Θέλετε να αποσυνδεθείτε;';

  @override
  String signOutPendingWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Έχετε $count αλλαγές που δεν έχουν αποθηκευτεί ακόμη. Αν αποσυνδεθείτε και συνδεθεί άλλος λογαριασμός, θα χαθούν.',
      one: 'Έχετε 1 αλλαγή που δεν έχει αποθηκευτεί ακόμη. Αν αποσυνδεθείτε και συνδεθεί άλλος λογαριασμός, θα χαθεί.',
    );
    return '$_temp0';
  }

  @override
  String get signOutStayAndSync => 'Παραμονή και συγχρονισμός';

  @override
  String get signOutAnyway => 'Αποσύνδεση ούτως ή άλλως';

  @override
  String get syncAllSaved => 'Όλα αποθηκεύτηκαν';

  @override
  String syncStillPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Απομένουν $count αλλαγές για αποθήκευση: ελέγξτε το δίκτυο',
      one: 'Απομένει 1 αλλαγή για αποθήκευση: ελέγξτε το δίκτυο',
    );
    return '$_temp0';
  }

  @override
  String get signOutFailed => 'Η αποσύνδεση απέτυχε. Δοκιμάστε ξανά';

  @override
  String get signInAccountDeleted => 'Ο λογαριασμός διαγράφηκε';

  @override
  String get deleteAccountIntro => 'Διαγράφονται οριστικά:';

  @override
  String get deleteAccountItemCellar =>
      'Η κάβα σας, με τα κρασιά και το Ιστορικό της';

  @override
  String get deleteAccountItemShares =>
      'Οι κοινές χρήσεις που δώσατε: τα προσκεκλημένα άτομα χάνουν την πρόσβαση';

  @override
  String get deleteAccountItemMemberships =>
      'Η συμμετοχή σας σε κάβες άλλων: οι καταναλώσεις σας μένουν εκεί χωρίς το όνομά σας';

  @override
  String get deleteAccountItemProfile => 'Το προφίλ σας';

  @override
  String deleteAccountPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Έχετε $count αλλαγές που δεν έχουν αποθηκευτεί ακόμη: θα αποθηκευτούν και μετά θα διαγραφούν μαζί με τα υπόλοιπα',
      one: 'Έχετε 1 αλλαγή που δεν έχει αποθηκευτεί ακόμη: θα αποθηκευτεί και μετά θα διαγραφεί μαζί με τα υπόλοιπα',
    );
    return '$_temp0';
  }

  @override
  String get deleteAccountConfirmWord => 'ΔΙΑΓΡΑΦΗ';

  @override
  String deleteAccountTypeWord(String word) {
    return 'Πληκτρολογήστε $word για επιβεβαίωση';
  }

  @override
  String get deleteAccountReauthHint =>
      'Στη συνέχεια θα συνδεθείτε ξανά με Google για να επιβεβαιώσετε ότι είστε εσείς.';

  @override
  String get deleteAccountForever => 'Οριστική διαγραφή';

  @override
  String get deleteAccountNeedsNetwork =>
      'Συνδεθείτε στο διαδίκτυο για να διαγράψετε τον λογαριασμό';

  @override
  String get deleteAccountSameAccount =>
      'Η διαγραφή απαιτεί σύνδεση με τον ίδιο λογαριασμό';

  @override
  String get deletionTitle => 'Διαγραφή του λογαριασμού';

  @override
  String get deletionStepPreparePhone => 'Αποθήκευση εκκρεμών αλλαγών';

  @override
  String get deletionStepMarkStarted => 'Έναρξη της διαγραφής';

  @override
  String get deletionStepLeaveOtherCellars => 'Αποχώρηση από κάβες άλλων';

  @override
  String get deletionStepCloseOwnInvitations =>
      'Κλείσιμο των κοινών χρήσεών σας';

  @override
  String get deletionStepDeleteWinesAndRecords =>
      'Διαγραφή κρασιών και Ιστορικού';

  @override
  String get deletionStepDeleteCellar => 'Διαγραφή της κάβας';

  @override
  String get deletionStepDeleteProfileAndUser =>
      'Διαγραφή προφίλ και λογαριασμού';

  @override
  String get deletionStepCleanUpPhone => 'Εκκαθάριση αυτού του τηλεφώνου';

  @override
  String deletionStepAnnounce(int step, String label) {
    return 'Βήμα $step από 8: $label';
  }

  @override
  String deletionDeletedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Διαγράφηκαν $count κρασιά και καταναλώσεις',
      one: 'Διαγράφηκε 1 κρασί ή κατανάλωση',
    );
    return '$_temp0';
  }

  @override
  String get deletionResumeHint =>
      'Η διαγραφή αυτού του λογαριασμού δεν έχει ολοκληρωθεί. Συνδεθείτε ξανά με Google για να την ολοκληρώσετε.';

  @override
  String get deletionContinue => 'Συνέχεια';

  @override
  String get deletionOffline =>
      'Συνδεθείτε στο διαδίκτυο για να ολοκληρώσετε τη διαγραφή';

  @override
  String get deletionPendingWrites =>
      'Δεν μπορώ να αποθηκεύσω τις εκκρεμείς αλλαγές. Δοκιμάστε ξανά';

  @override
  String get deletionFailed =>
      'Δεν ήταν δυνατή η ολοκλήρωση της διαγραφής. Δοκιμάστε ξανά';

  @override
  String get uxCountryLabel => 'Χώρα';

  @override
  String get uxCountryOther => 'Άλλη χώρα…';

  @override
  String get uxCountryNone => 'Καμία χώρα';

  @override
  String get uxAllCountriesTitle => 'Όλες οι χώρες και τα εδάφη';

  @override
  String get uxAllCountriesSearch => 'Αναζήτηση χώρας';

  @override
  String get uxAllCountriesRare => 'Σπάνιες για κρασί';

  @override
  String get uxAllCountriesAll => 'Όλες, από το Α έως το Ω';

  @override
  String get uxAllCountriesNone => 'Δεν βρέθηκε χώρα';

  @override
  String get uxRegionLabel => 'Περιοχή';

  @override
  String uxRegionOf(String country) {
    return 'Περιοχή · $country';
  }

  @override
  String get uxRegionOther => 'Άλλη περιοχή';

  @override
  String get uxRegionFieldLabel => 'Γράψτε την περιοχή';

  @override
  String get uxRegionTooLong => 'Έως 120 χαρακτήρες';

  @override
  String get uxDrinkAction => 'Ήπια μία';

  @override
  String uxDrinkActionTooltip(String name) {
    return 'Ήπια μια φιάλη $name';
  }

  @override
  String get uxDrinkActionDetail => 'Ήπια μια φιάλη';

  @override
  String get uxDrinkSheetLabel => 'Επιβεβαίωση κατανάλωσης';

  @override
  String get uxDrinkSheetBottles => 'Φιάλες';

  @override
  String uxDrinkSheetBottlesChange(int before, int after) {
    return 'Φιάλες: από $before σε $after';
  }

  @override
  String get uxDrinkSheetRating => 'Πώς ήταν; (προαιρετικά)';

  @override
  String uxDrinkSheetStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count αστέρια στα 5',
      one: '1 αστέρι στα 5',
    );
    return '$_temp0';
  }

  @override
  String get uxDrinkSheetConfirm => 'Ναι, την ήπια';

  @override
  String get uxRemoveBottle => 'Αφαίρεση φιάλης χωρίς κατανάλωση';

  @override
  String get uxRemoveBottleTitle => 'Αφαίρεση μιας φιάλης;';

  @override
  String uxRemoveBottleBody(String name) {
    return 'Μία φιάλη $name αφαιρείται χωρίς να καταγραφεί κατανάλωση.';
  }

  @override
  String get uxRemoveBottleConfirm => 'Αφαίρεση';

  @override
  String get uxIdealTitle => 'Ιδανική στιγμή';

  @override
  String uxIdealUntil(String year) {
    return 'Συνιστάται έως το $year';
  }

  @override
  String uxIdealUntilPast(String year) {
    return 'Συνιστάται έως το $year: έχει περάσει';
  }

  @override
  String uxIdealBest(String start, String end) {
    return 'Στα καλύτερά του από το $start έως το $end';
  }

  @override
  String uxIdealBar(String start, String end) {
    return 'Παράθυρο κατανάλωσης από το $start έως το $end';
  }

  @override
  String get uxIdealDisclaimer =>
      '⚠︎ Ενδεικτικό: εκτίμηση βάσει τύπου, ονομασίας προέλευσης και χρονιάς. Η φύλαξη και η κάθε φιάλη μπορούν να την αλλάξουν.';

  @override
  String get uxIdealUnavailableHint =>
      'Προσθέστε χρονιά και τύπο για να λάβετε εκτίμηση.';

  @override
  String uxDashboardDrinkNow(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count να πιωθούν τώρα',
      one: '1 να πιωθεί τώρα',
    );
    return '$_temp0';
  }

  @override
  String get uxFamilyRed => 'Ερυθρό';

  @override
  String get uxFamilyWhite => 'Λευκό';

  @override
  String get uxFamilyRose => 'Ροζέ';

  @override
  String get uxFamilySparkling => 'Αφρώδες';

  @override
  String get uxFamilySweet => 'Γλυκό';

  @override
  String get labelBackTitle => 'Τώρα η πίσω ετικέτα';

  @override
  String get labelBackHint =>
      'Στην πίσω ετικέτα υπάρχουν συνήθως ο γραμμωτός κώδικας, ο παραγωγός και η χρονιά: βοηθούν να βρεθεί το κρασί.';

  @override
  String get labelBackTake => 'Λήψη πίσω ετικέτας';

  @override
  String get labelBackGallery => 'Επιλογή από τη συλλογή';

  @override
  String get labelBackSkip => 'Παράλειψη';

  @override
  String get labelStepFront => 'Μπροστά';

  @override
  String get labelStepBack => 'Πίσω';

  @override
  String get labelStepBarcode => 'Γραμμωτός κώδικας';

  @override
  String get labelStepDatabase => 'Βάση κρασιών στο τηλέφωνο';

  @override
  String get labelStepPending => 'Σε αναμονή';

  @override
  String get labelStepRunning => 'Σε εξέλιξη…';

  @override
  String get labelStepDone => 'Έγινε';

  @override
  String get labelStepSkipped => 'Παραλείφθηκε';

  @override
  String get labelStepFailed => 'Δεν διαβάζεται';

  @override
  String labelStepStatus(String step, String status) {
    return '$step: $status';
  }

  @override
  String get labelOnPhoneNote =>
      'Όλα γίνονται στο τηλέφωνο: οι φωτογραφίες δεν στέλνονται σε κανέναν.';

  @override
  String get labelBackUnreadable => 'Η πίσω ετικέτα δεν διαβάζεται';

  @override
  String get labelSourceOffline => 'Από τη βάση στο τηλέφωνο · εκτός σύνδεσης';

  @override
  String get labelSourceCatalog => 'Από τον κατάλογο';

  @override
  String get labelSourceOnline => 'Από το Open Food Facts · σε σύνδεση';

  @override
  String get labelNotThis => 'Δεν είναι αυτό';

  @override
  String get labelOffAttribution =>
      'Δεδομένα από το Open Food Facts, άδεια ODbL';

  @override
  String get labelCandidatesTitle => 'Ποιο από αυτά;';

  @override
  String labelCandidatesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count παρόμοια κρασιά',
      one: '1 παρόμοιο κρασί',
    );
    return '$_temp0';
  }

  @override
  String get labelCandidatesNone => 'Κανένα από αυτά';

  @override
  String get labelChipOffline => 'εκτός σύνδεσης';

  @override
  String get labelChipOnline => 'σε σύνδεση';

  @override
  String get labelChipCatalog => 'κατάλογος';

  @override
  String get labelNoProducer => 'χωρίς ένδειξη παραγωγού';

  @override
  String get labelNoMatch => 'Διάβασα την ετικέτα αλλά δεν αναγνωρίζω το κρασί';

  @override
  String get labelReadText => 'Κείμενο που διαβάστηκε';

  @override
  String get labelSearchOnline => 'Αναζήτηση στο διαδίκτυο';

  @override
  String get labelOpenLens => 'Άνοιγμα στο Google Lens';

  @override
  String get labelLensLastResort =>
      'Το Google Lens είναι η τελευταία λύση: η φωτογραφία πηγαίνει στην εφαρμογή Google μόνο αν το επιβεβαιώσετε.';

  @override
  String get labelLensTitle => 'Άνοιγμα στο Google Lens;';

  @override
  String get labelLensBody =>
      'Η φωτογραφία της μπροστινής ετικέτας θα μεταβιβαστεί στην εφαρμογή Google στο τηλέφωνό σας, ή στην εφαρμογή που θα επιλέξετε, η οποία μπορεί να κρατήσει αντίγραφο σύμφωνα με τους δικούς της κανόνες. Το Vinoozy δεν λαμβάνει τα αποτελέσματα: επιστρέψτε εδώ για να επιλέξετε ή να γράψετε το κρασί.';

  @override
  String get labelLensConfirm => 'Άνοιγμα Google Lens';

  @override
  String get labelLensFailed =>
      'Δεν μπορώ να ανοίξω ούτε το Google Lens ούτε το μενού κοινοποίησης';

  @override
  String get onlineSearchTitle => 'Αναζήτηση στο διαδίκτυο';

  @override
  String get onlineSearchSubtitle => 'Open Food Facts · μόνο κρασιά';

  @override
  String get onlineSearchField => 'Λέξεις αναζήτησης';

  @override
  String get onlineSearchHint =>
      'Μπορείτε να αλλάξετε τις λέξεις πριν από την αναζήτηση.';

  @override
  String get onlineSearchEmptyField => 'Γράψτε τουλάχιστον μία λέξη';

  @override
  String get onlineSearchButton => 'Αναζήτηση';

  @override
  String get onlineSearchLoading => 'Αναζητώ…';

  @override
  String onlineSearchResults(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count αποτελέσματα',
      one: '1 αποτέλεσμα',
    );
    return '$_temp0';
  }

  @override
  String get onlineSearchEmpty =>
      'Δεν βρέθηκε κρασί: δοκιμάστε άλλες λέξεις ή τη «Χειροκίνητη καταχώριση».';

  @override
  String get onlineSearchOffline =>
      'Χωρίς δίκτυο: αναζητώ μόνο στη βάση στο τηλέφωνο.';

  @override
  String get onlineSearchRateLimited =>
      'Η αναζήτηση στο διαδίκτυο δεν είναι διαθέσιμη τώρα, δοκιμάστε ξανά σε λίγα λεπτά.';

  @override
  String get onlineSearchUnavailable =>
      'Η αναζήτηση στο διαδίκτυο δεν είναι ενεργή σε αυτή την έκδοση της εφαρμογής: αναζητώ μόνο στη βάση στο τηλέφωνο.';

  @override
  String get aboutTitle => 'Πληροφορίες';

  @override
  String aboutVersion(String version) {
    return 'Έκδοση $version';
  }

  @override
  String get aboutDbTitle => 'Βάση κρασιών';

  @override
  String aboutDbCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count κρασιά',
      one: '1 κρασί',
    );
    return '$_temp0';
  }

  @override
  String aboutDbDate(String date) {
    return 'Εξαγωγή του Open Food Facts: $date';
  }

  @override
  String get aboutDbSample =>
      'Δοκιμαστική βάση: λίγα δοκιμαστικά κρασιά γραμμένα με το χέρι, όχι δεδομένα του Open Food Facts.';

  @override
  String get aboutDbLoading => 'Ανοίγω τη βάση κρασιών…';

  @override
  String get aboutDbUnavailable =>
      'Η βάση κρασιών δεν είναι διαθέσιμη σε αυτή την έκδοση';

  @override
  String aboutDbSource(String url) {
    return 'Η παράγωγη βάση και το εργαλείο που τη δημιουργεί βρίσκονται στο δημόσιο αποθετήριο: $url';
  }

  @override
  String get aboutLicenseTitle => 'Άδειες';

  @override
  String get aboutLicense =>
      'Περιέχει πληροφορίες από το Open Food Facts, που διατίθενται με την άδεια Open Database License (ODbL). Τα επιμέρους περιεχόμενα διέπονται από την άδεια Database Contents License (DbCL).';

  @override
  String get aboutPrivacyTitle => 'Φωτογραφίες ετικετών';

  @override
  String get aboutPrivacy =>
      'Οι φωτογραφίες ετικετών διαβάζονται στο τηλέφωνο και διαγράφονται όταν φύγετε από το αποτέλεσμα. Φεύγουν από το τηλέφωνο μόνο αν πατήσετε «Άνοιγμα στο Google Lens» και επιβεβαιώσετε.';

  @override
  String get aboutAppellationsTitle => 'Ονομασίες προέλευσης';

  @override
  String get aboutAppellationsSource =>
      'Ονομασίες προέλευσης: μητρώο eAmbrosia (ΕΕ) και επίσημα εθνικά μητρώα.';

  @override
  String get aboutAppellationsSample =>
      'Δοκιμαστικός πίνακας: απόσπασμα των μητρώων γραμμένο με το χέρι, μέχρι να ληφθούν τα πραγματικά μητρώα.';

  @override
  String get denominationLabel => 'Ονομασία προέλευσης';

  @override
  String get denominationTooLong => 'Έως 120 χαρακτήρες';

  @override
  String get autofillFilledNotice =>
      'Συμπληρώθηκε από την ετικέτα: ελέγξτε και αποθηκεύστε';

  @override
  String get autofillPastedNotice =>
      'Συμπληρώθηκε από το κείμενο: ελέγξτε και αποθηκεύστε';

  @override
  String get autofillFromText => '✦ από το κείμενο';

  @override
  String get autofillFromTextSemantics => 'συμπληρώθηκε από την ετικέτα';

  @override
  String get autofillClear => 'Εκκαθάριση';

  @override
  String get autofillLens => 'Lens';

  @override
  String get autofillClearTitle => 'Εκκαθάριση της φόρμας;';

  @override
  String get autofillClearBody =>
      'Γράψατε κι εσείς σε ορισμένα πεδία. Η «Εκκαθάριση» αδειάζει όνομα, παραγωγό, ονομασία προέλευσης, χρονιά, τύπο, χώρα, περιοχή και επίπεδο. Η ποσότητα μένει.';

  @override
  String get autofillClearConfirm => 'Εκκαθάριση';

  @override
  String get autofillCleared => 'Η φόρμα εκκαθαρίστηκε';

  @override
  String get autofillPasteTitle => 'Έχετε το κείμενο από το Google Lens;';

  @override
  String get autofillPasteHint =>
      'Στο Lens επιλέξτε το κείμενο της ετικέτας και πατήστε «Αντιγραφή», έπειτα επιστρέψτε εδώ.';

  @override
  String get autofillPaste => 'Επικόλληση από το Lens';

  @override
  String get autofillOpenLens => 'Από το Google Lens';

  @override
  String get autofillOpenLensSemantics => 'ανοίγει το Google Lens';

  @override
  String get autofillClipboardEmpty => 'Δεν υπάρχει κείμενο στο πρόχειρο';

  @override
  String get autofillNoNewFields =>
      'Δεν βρήκα στο κείμενο στοιχεία για προσθήκη';

  @override
  String get autofillFromLens => 'Η φόρμα συμπληρώθηκε από το κείμενο του Lens';

  @override
  String get autofillShareEmpty => 'Δεν ελήφθη κείμενο';

  @override
  String get autofillShareUseTitle => 'Χρήση του κειμένου για τα κενά πεδία;';

  @override
  String get autofillShareUse => 'Χρήση';

  @override
  String get autofillShareIgnore => 'Παράβλεψη';

  @override
  String get addChoiceLens => 'Από το Google Lens';

  @override
  String get addChoicePhotoHint =>
      'Μπροστά και πίσω: το Vinoozy διαβάζει την ετικέτα.';

  @override
  String get addChoiceLensHint =>
      'Ανοίγει το Lens: καδράρετε, επιλέξτε το κείμενο και πατήστε «Κοινοποίηση» → Vinoozy.';

  @override
  String get addChoiceImportHint =>
      'Μια φωτογραφία της ετικέτας που έχετε ήδη.';

  @override
  String get addChoiceWriteHint => 'Κενή φόρμα, με «Επικόλληση από το Lens».';

  @override
  String get lensInstructionsTitle => 'Το Google Lens δεν ανοίγει από εδώ';

  @override
  String get lensInstructionsStep1 =>
      'Ανοίξτε το Google Lens και καδράρετε την ετικέτα';

  @override
  String get lensInstructionsStep2 => 'Επιλέξτε το κείμενο της ετικέτας';

  @override
  String get lensInstructionsStep3 => 'Πατήστε «Κοινοποίηση» → Vinoozy';

  @override
  String get lensInstructionsOk => 'Κατάλαβα';

  @override
  String get levelLabel => 'Επίπεδο';

  @override
  String get levelEveryday => 'Καθημερινό (οικονομικό)';

  @override
  String get levelGood => 'Καλό';

  @override
  String get levelAging => 'Για παλαίωση';

  @override
  String get levelNone => 'Κανένα';

  @override
  String get levelEverydayShort => 'πίνεται νωρίς';

  @override
  String get levelGoodShort => 'κανονική εκτίμηση';

  @override
  String get levelAgingShort => 'αντέχει περισσότερο';

  @override
  String get levelSuggested => 'προτεινόμενο';

  @override
  String levelSuggestedReason(String qualifier) {
    return 'Προτείνεται επειδή το όνομα περιέχει «$qualifier»: έτσι θα αποθηκευτεί αν δεν το αλλάξετε. Επιλέξτε άλλο ή πατήστε «Κανένα».';
  }

  @override
  String levelSuggestedSemantics(String qualifier) {
    return 'προτεινόμενο, επειδή το όνομα περιέχει $qualifier';
  }

  @override
  String levelOptionSemantics(String option, int index, int count) {
    return 'Επίπεδο, $option, $index από $count';
  }

  @override
  String get levelWhatChanges => 'Τι αλλάζει';

  @override
  String get levelEverydayExamples =>
      'Το παράθυρο μικραίνει. Π.χ. χύμα κρασί, Lambrusco, απλό Prosecco, Bardolino, Vinho Verde.';

  @override
  String get levelGoodExamples =>
      'Η κανονική εκτίμηση, και η τιμή όταν δεν επιλέξετε τίποτα. Π.χ. Chianti Classico, Barbera d\'Asti Superiore, Rioja Crianza, Côtes du Rhône.';

  @override
  String get levelAgingExamples =>
      'Το παράθυρο μεγαλώνει. Π.χ. Barolo, Brunello, Amarone, Bordeaux Grand Cru, Rioja Gran Reserva, Porto Vintage.';

  @override
  String levelPreviewBefore(String start, String end) {
    return 'Πριν $start – $end';
  }

  @override
  String levelPreviewWith(String level, String start, String end) {
    return 'Με «$level» $start – $end';
  }

  @override
  String levelPreviewNow(String start, String end) {
    return 'Έτοιμο $start – έως $end';
  }

  @override
  String levelDetail(String level) {
    return 'Επίπεδο: $level';
  }

  @override
  String get overrideCorrect => 'Διόρθωση';

  @override
  String get overrideRestore => 'Επαναφορά εκτίμησης';

  @override
  String get overrideCorrectedByYou => 'δική σας διόρθωση';

  @override
  String overrideAppEstimate(String year) {
    return 'Εκτίμηση της εφαρμογής: έως το $year';
  }

  @override
  String get overrideSheetTitle => 'Συνιστάται έως';

  @override
  String overrideSheetHint(String start) {
    return 'Επιλέξτε το έτος. Δεν μπορεί να είναι πριν από το «Έτοιμο από $start».';
  }

  @override
  String overridePeakNotice(String peak) {
    return 'Αν επιλέξετε έτος πριν από το $peak (στα καλύτερά του), το «στα καλύτερά του» μετακινείται κι αυτό στο ίδιο έτος.';
  }

  @override
  String get overrideMore => 'περισσότερα…';

  @override
  String get overrideSave => 'Αποθήκευση διόρθωσης';

  @override
  String overrideRestoreTitle(String year) {
    return 'Επιστροφή στην εκτίμηση της εφαρμογής (έως το $year);';
  }

  @override
  String get overrideRestoreConfirm => 'Επαναφορά';

  @override
  String get overrideSaved => 'Η διόρθωση αποθηκεύτηκε';

  @override
  String get overrideRestored => 'Η εκτίμηση επανήλθε';

  @override
  String get estimateSourceCorrectedByYou => 'δική σας διόρθωση';

  @override
  String estimateFromDenomination(String name) {
    return 'Εκτίμηση από την ονομασία προέλευσης $name';
  }

  @override
  String estimateFromDenominationQualifier(String name, String qualifier) {
    return 'Εκτίμηση από την ονομασία προέλευσης $name, $qualifier';
  }

  @override
  String estimateFromGrape(String name) {
    return 'Εκτίμηση από την ποικιλία $name';
  }

  @override
  String get estimateFromType => 'Εκτίμηση από τον τύπο κρασιού';

  @override
  String get autofillReading => 'Διαβάζω το κείμενο…';

  @override
  String get guideChip => 'Καθοδηγούμενος έλεγχος';

  @override
  String guideProgress(int n, int total) {
    return 'Ερώτηση $n από $total';
  }

  @override
  String get guideClose => 'Κλείσιμο';

  @override
  String get guideIsDenomination => 'είναι η ονομασία προέλευσης;';

  @override
  String get guideIsProducer => 'είναι ο παραγωγός;';

  @override
  String get guideIsName => 'είναι το όνομα του κρασιού;';

  @override
  String get guideIsVintage => 'Χρονιά';

  @override
  String guideAskDenomination(String value) {
    return '$value: είναι η ονομασία προέλευσης;';
  }

  @override
  String guideAskProducer(String value) {
    return '$value: είναι ο παραγωγός;';
  }

  @override
  String guideAskName(String value) {
    return '$value: είναι το όνομα του κρασιού;';
  }

  @override
  String get guideAskVintage => 'Ποια είναι η χρονιά;';

  @override
  String guideQuestionSemantics(int n, int total, String question) {
    return 'Ερώτηση $n από $total: $question';
  }

  @override
  String get guideNoProposal => 'Δεν το βρήκα στο κείμενο';

  @override
  String get guideYes => 'Ναι';

  @override
  String get guideNo => 'Όχι, άλλο';

  @override
  String get guideEdit => 'Επεξεργασία';

  @override
  String get guideSkip => 'Παράλειψη';

  @override
  String get guideConfirm => 'Επιβεβαίωση';

  @override
  String get guideCancel => 'Ακύρωση';

  @override
  String guideRejected(String value) {
    return 'Όχι «$value»: ορίστε η επόμενη πρόταση';
  }

  @override
  String get guideNoMore => 'Καμία άλλη πρόταση: συνθέστε το ή παραλείψτε';

  @override
  String guideProposalAnnounce(String value) {
    return 'Πρόταση: $value';
  }

  @override
  String get guideComposeLabel => 'Ή συνθέστε το πατώντας λέξεις του κειμένου';

  @override
  String get guideComposePreview => 'Προεπισκόπηση';

  @override
  String get guideComposeEmpty => 'Πατήστε μία ή περισσότερες λέξεις';

  @override
  String get guideComposeLimit => 'Έως 8 λέξεις και 80 χαρακτήρες';

  @override
  String guideTableMatchSemantics(String name) {
    return 'αντιστοιχεί σε $name';
  }

  @override
  String guideLine(int n, int total) {
    return 'Γραμμή $n από $total';
  }

  @override
  String guideWordSelected(String word, int order) {
    return '$word, επιλεγμένη, $order';
  }

  @override
  String guideWordUnavailable(String word) {
    return '$word, μη διαθέσιμη';
  }

  @override
  String guideWordUsedFor(String word, String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'την ονομασία προέλευσης',
      'producer': 'τον παραγωγό',
      'other': 'το όνομα',
    });
    return '$word, χρησιμοποιείται για $_temp0';
  }

  @override
  String guideUsedMark(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'ονομασία προέλευσης',
      'producer': 'παραγωγός',
      'other': 'όνομα',
    });
    return '$_temp0';
  }

  @override
  String guideOtherYears(String years) {
    return 'Στο κείμενο υπάρχουν επίσης: $years';
  }

  @override
  String get guideWheelFromText => 'έτος που βρέθηκε στο κείμενο';

  @override
  String get guideWheelTypeYear => 'Πληκτρολογήστε το έτος';

  @override
  String guideWheelConfirm(String year) {
    return 'Επιβεβαίωση $year';
  }

  @override
  String get guideNoVintage => 'Χωρίς χρονιά';

  @override
  String guideSkippedNotice(String field) {
    String _temp0 = intl.Intl.selectLogic(field, {
      'denomination': 'Η ονομασία προέλευσης παραλείφθηκε',
      'producer': 'Ο παραγωγός παραλείφθηκε',
      'vintage': 'Η χρονιά παραλείφθηκε',
      'other': 'Το όνομα παραλείφθηκε',
    });
    return '$_temp0: γράψτε το ή συνεχίστε τον έλεγχο';
  }

  @override
  String guideSkippedMany(int count) {
    return 'Παραλείφθηκαν $count πεδία: γράψτε τα ή συνεχίστε τον έλεγχο';
  }

  @override
  String get guideInvalidValue =>
      'Το κείμενο περιέχει χαρακτήρες που δεν μπορούν να αποθηκευτούν';

  @override
  String get brandStudio => 'Bottazzini Softworks';

  @override
  String get suggestedMark => '✦ προτεινόμενο';

  @override
  String suggestedSemantics(String field, String value) {
    return '$field, $value, προτεινόμενο';
  }

  @override
  String get restoreSuggestion => 'Επαναφορά πρότασης';

  @override
  String get restoreSuggestionDone => 'Η πρόταση επανήλθε';

  @override
  String get styleLabel => 'Στιλ';

  @override
  String styleGroupSemantics(String value, int index, int count) {
    return 'Στιλ, $value, $index από $count';
  }

  @override
  String get styleRedFresh => 'Φρέσκο';

  @override
  String get styleRedMedium => 'Μέτριο';

  @override
  String get styleRedAge => 'Για παλαίωση';

  @override
  String get styleRedLong => 'Μακρά παλαίωση';

  @override
  String get styleWhiteFresh => 'Φρέσκο';

  @override
  String get styleWhiteMedium => 'Μέτριο';

  @override
  String get styleWhiteAge => 'Για παλαίωση';

  @override
  String get styleRoseFresh => 'Φρέσκο';

  @override
  String get styleClassicFresh => 'Φρέσκο';

  @override
  String get styleClassicAge => 'Για παλαίωση';

  @override
  String get styleTankFresh => 'Φρέσκο';

  @override
  String get styleLambrusco => 'Lambrusco';

  @override
  String get styleSweetAromatic => 'Αρωματικό';

  @override
  String get styleSweetPassito => 'Λιαστό';

  @override
  String get styleSweetBotrytis => 'Ευγενής σήψη';

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
  String get styleFortifiedOther => 'Άλλο';

  @override
  String get profileNameRFresh => 'Φρουτώδες ερυθρό';

  @override
  String get profileNameRMedium => 'Ερυθρό μέτριου σώματος';

  @override
  String get profileNameRAge => 'Ερυθρό για παλαίωση';

  @override
  String get profileNameRLong => 'Ερυθρό μακράς παλαίωσης';

  @override
  String get profileNameWFresh => 'Φρέσκο αρωματικό λευκό';

  @override
  String get profileNameWMedium => 'Λευκό μέτριου σώματος';

  @override
  String get profileNameWAge => 'Λευκό για παλαίωση';

  @override
  String get profileNameRoseFresh => 'Φρέσκο ροζέ';

  @override
  String get profileNameSpTank => 'Φρέσκο αφρώδες, μέθοδος δεξαμενής';

  @override
  String get profileNameLamFresh => 'Φρέσκο Lambrusco';

  @override
  String get profileNameSpClassic => 'Φρέσκο αφρώδες, παραδοσιακή μέθοδος';

  @override
  String get profileNameSpClassicAge =>
      'Αφρώδες για παλαίωση, παραδοσιακή μέθοδος';

  @override
  String get profileNameSwAromatic => 'Νεαρό αρωματικό γλυκό κρασί';

  @override
  String get profileNameSwPassito => 'Γλυκό λιαστό κρασί';

  @override
  String get profileNameSwBotrytis => 'Γλυκό κρασί ευγενούς σήψης';

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
  String get profileNameFortUnknown => 'Ενισχυμένο, άγνωστο στιλ';

  @override
  String get profileNameUnknown => 'Το στιλ δεν αναγνωρίστηκε';

  @override
  String estimateFromProfile(String profile, String denomination) {
    return 'Εκτίμηση από το προφίλ «$profile» ($denomination)';
  }

  @override
  String estimateFromProfileType(String profile) {
    return 'Εκτίμηση από το προφίλ «$profile», βάσει τύπου';
  }

  @override
  String estimateFromProfileGrape(String profile, String grape) {
    return 'Εκτίμηση από το προφίλ «$profile», βάσει της ποικιλίας $grape';
  }

  @override
  String get estimateFromEntryDateDisgorgement =>
      'Από την ημερομηνία καταχώρισης: προσθέστε την ημερομηνία ντεγκορζαρίσματος για καλύτερη εκτίμηση';

  @override
  String get estimateFromEntryDateBottling =>
      'Από την ημερομηνία καταχώρισης: προσθέστε την ημερομηνία εμφιάλωσης για καλύτερη εκτίμηση';

  @override
  String get styleToConfirmBanner =>
      '⚠︎ Στιλ προς επιβεβαίωση: η εκτίμηση είναι ενδεικτική';

  @override
  String get chooseTypePrompt => 'Επιλέξτε τον τύπο';

  @override
  String estimateUpdatedAnnouncement(String summary) {
    return 'Η εκτίμηση ενημερώθηκε: $summary';
  }

  @override
  String get agingStartDisgorgement => 'Ντεγκορζάρισμα';

  @override
  String get agingStartBottling => 'Εμφιάλωση';

  @override
  String get agingStartMonth => 'Μήνας';

  @override
  String get agingStartYear => 'Έτος';

  @override
  String get agingStartHint => 'Συνήθως αναγράφεται στην πίσω ετικέτα.';

  @override
  String get agingStartIncomplete => 'Συμπληρώστε μήνα και έτος';

  @override
  String get agingStartFuture => 'Η ημερομηνία δεν μπορεί να είναι μελλοντική';

  @override
  String get agingStartBeforeVintage =>
      'Δεν μπορεί να είναι πριν από τη χρονιά του κρασιού';

  @override
  String get windowNoEnd => 'Έτοιμο, χωρίς εκτίμηση λήξης';

  @override
  String get windowNoEndShort => 'χωρίς εκτίμηση λήξης';

  @override
  String windowDrinkWithin(String date) {
    return 'έως: $date';
  }

  @override
  String get levelNoEffect => 'Το επίπεδο δεν αλλάζει αυτή την εκτίμηση';

  @override
  String get dashboardToConfirmTitle => 'Προς επιβεβαίωση';

  @override
  String dashboardToConfirmCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count κρασιά',
      one: '1 κρασί',
    );
    return '$_temp0';
  }

  @override
  String aboutDbClassified(String percent) {
    return '$percent% των κρασιών με αναγνωρισμένο τύπο';
  }

  @override
  String get planTitle => 'Πρόγραμμα';

  @override
  String get planFree => 'Δωρεάν';

  @override
  String get planPlus => 'Plus';

  @override
  String get planPlusGift => 'Plus (δώρο)';

  @override
  String get planDevUnlockAll => 'DEV · Δοκιμαστικό Plus';

  @override
  String get planDevSimulateFree => 'DEV · Προσομοίωση δωρεάν προγράμματος';

  @override
  String get planDevSimulateExpired => 'DEV · Προσομοίωση ληγμένου Plus';

  @override
  String get planDiscoverPlus => 'Ανακαλύψτε το Plus';

  @override
  String get plusTitle => 'Vinoozy Plus';

  @override
  String get plusBenefitsTitle => 'Με το Plus';

  @override
  String get plusBenefitNoAds => 'Χωρίς διαφημίσεις';

  @override
  String get plusBenefitNoLimit => 'Χωρίς όριο στα κρασιά της κάβας σας';

  @override
  String get plusComingSoon => 'Το Plus έρχεται σύντομα';

  @override
  String get plusLoading => 'Ανάγνωση τιμών από το Google Play';

  @override
  String get plusStoreUnavailable =>
      'Δεν ήταν δυνατή η ανάγνωση των τιμών από το Google Play. Δοκιμάστε ξανά αργότερα.';

  @override
  String plusPriceMonthly(String price) {
    return '$price τον μήνα';
  }

  @override
  String plusPriceAnnual(String price) {
    return '$price τον χρόνο';
  }

  @override
  String get plusRenewal =>
      'Η συνδρομή ανανεώνεται αυτόματα στην τιμή που εμφανίζεται, μέχρι να την ακυρώσετε στο Google Play.';

  @override
  String get plusTerms =>
      'Η πληρωμή χρεώνεται στον λογαριασμό σας Google Play όταν επιβεβαιώσετε την αγορά. Μπορείτε να ακυρώσετε οποιαδήποτε στιγμή: το Plus παραμένει ενεργό έως το τέλος της περιόδου που έχετε ήδη πληρώσει. Όταν λήξει το Plus, όλα τα κρασιά σας παραμένουν.';

  @override
  String get plusRestore => 'Επαναφορά αγορών';

  @override
  String get plusManage => 'Διαχείριση ή ακύρωση της συνδρομής στο Google Play';

  @override
  String get plusActive => 'Το Plus είναι ενεργό σε αυτόν τον λογαριασμό';

  @override
  String get plusActiveGift =>
      'Έχετε το Plus ως δώρο: χωρίς χρεώσεις και χωρίς ανανεώσεις.';

  @override
  String get plusPending =>
      'Η πληρωμή εκκρεμεί: το Plus θα ενεργοποιηθεί όταν την επιβεβαιώσει το Google Play.';

  @override
  String get plusVerifying => 'Επαλήθευση της αγοράς';

  @override
  String get plusVerified =>
      'Η αγορά επαληθεύτηκε: το Plus θα ενεργοποιηθεί σε λίγα δευτερόλεπτα.';

  @override
  String get plusPurchaseFailed => 'Η αγορά δεν ολοκληρώθηκε. Δοκιμάστε ξανά.';

  @override
  String get plusInvalidPurchase =>
      'Το Google Play δεν επιβεβαίωσε αυτή την αγορά για το Vinoozy.';

  @override
  String get plusOwnedByOther =>
      'Αυτή η συνδρομή ανήκει ήδη σε άλλον λογαριασμό Vinoozy.';

  @override
  String get plusVerificationUnavailable =>
      'Δεν ήταν δυνατή η επαλήθευση της αγοράς τώρα. Δοκιμάστε ξανά αργότερα: η συνδρομή παραμένει στο Google Play.';

  @override
  String get capacityLimitTitle => 'Φτάσατε το όριο του δωρεάν προγράμματος';

  @override
  String capacityLimitBody(int limit) {
    return 'Το δωρεάν πρόγραμμα περιλαμβάνει έως $limit διαφορετικά κρασιά στην κάβα σας. Μπορείτε πάντα να επεξεργάζεστε, να πίνετε και να προσθέτετε φιάλες στα κρασιά που έχετε ήδη. Για να προσθέσετε ένα νέο, τελειώστε ή διαγράψτε ένα κρασί ή περάστε στο Plus.';
  }

  @override
  String capacityLimitBodyComingSoon(int limit) {
    return 'Το δωρεάν πρόγραμμα περιλαμβάνει έως $limit διαφορετικά κρασιά στην κάβα σας. Μπορείτε πάντα να επεξεργάζεστε, να πίνετε και να προσθέτετε φιάλες στα κρασιά που έχετε ήδη. Για να προσθέσετε ένα νέο, τελειώστε ή διαγράψτε ένα κρασί. Το Plus έρχεται σύντομα.';
  }

  @override
  String get rejectedCapacityLimit =>
      'Δεν συγχρονίστηκε: υπερβαίνει το όριο κρασιών του δωρεάν προγράμματος. Η αλλαγή παραμένει σε αυτό το τηλέφωνο.';

  @override
  String get rejectedCapacityConflict =>
      'Δεν συγχρονίστηκε: η κάβα άλλαξε ταυτόχρονα σε άλλη συσκευή. Η αλλαγή παραμένει σε αυτό το τηλέφωνο: δοκιμάστε ξανά.';

  @override
  String writeRejectedCapacityLimit(String name) {
    return '$name: δεν συγχρονίστηκε, υπερβαίνει το όριο του δωρεάν προγράμματος';
  }

  @override
  String writeRejectedCapacityConflict(String name) {
    return '$name: δεν συγχρονίστηκε, η κάβα άλλαξε σε άλλη συσκευή';
  }

  @override
  String get freeIntroTitle => 'Το δωρεάν πρόγραμμα';

  @override
  String freeIntroLimit(int limit) {
    return 'Μπορείτε να διαχειρίζεστε δωρεάν έως $limit διαφορετικά κρασιά.';
  }

  @override
  String get freeIntroAds =>
      'Η ελαφριά χρήση είναι χωρίς διαφημίσεις. Αν ξεπεράσετε το μηνιαίο κατώφλι χρήσης της υπηρεσίας, ενδέχεται να βλέπετε περιστασιακά διαφημίσεις που βοηθούν στην κάλυψη του κόστους των διακομιστών και του συγχρονισμού.';

  @override
  String get freeIntroNoAds => 'Χωρίς διαφημίσεις στην έκδοση κυκλοφορίας.';

  @override
  String get freeIntroPlus =>
      'Με το Plus καταργείτε τις διαφημίσεις και το όριο της κάβας.';

  @override
  String get noticeGotIt => 'Κατάλαβα';

  @override
  String get thresholdTitle =>
      'Οι διαφημίσεις βοηθούν το Vinoozy να παραμένει δωρεάν';

  @override
  String get thresholdBody =>
      'Φτάσατε το μηνιαίο κατώφλι χρήσης χωρίς διαφημίσεις. Από εδώ και πέρα ενδέχεται να βλέπετε περιστασιακά διαφημίσεις: μας βοηθούν να καλύπτουμε το κόστος των διακομιστών και του συγχρονισμού, ώστε το Vinoozy να παραμένει δωρεάν.';

  @override
  String get thresholdReset =>
      'Η μέτρηση ξεκινά ξανά τον επόμενο μήνα. Με το Plus μπορείτε να χρησιμοποιείτε την εφαρμογή χωρίς διαφημίσεις και χωρίς το όριο της κάβας.';

  @override
  String thresholdNextReset(String date) {
    return 'Επόμενος μηδενισμός: $date';
  }

  @override
  String get thresholdHowItWorks => 'Πώς λειτουργεί';

  @override
  String get thresholdHowItWorksBody =>
      'Το κατώφλι εξαρτάται από έναν κατά προσέγγιση υπολογισμό των συγχρονισμών με το cloud που έκανε αυτός ο λογαριασμός μέσα στον μήνα. Η χρήση εκτός σύνδεσης δεν δημιουργεί από μόνη της νέες λειτουργίες στο cloud. Οι διαφημίσεις εμφανίζονται το πολύ μία φορά την ημέρα, μόνο στην Επισκόπηση, και ποτέ ενώ αποθηκεύετε ή εξάγετε τα δεδομένα σας.';

  @override
  String get adLabel => 'Διαφήμιση';

  @override
  String get devToolsTitle => 'Εργαλεία προγραμματιστή';

  @override
  String get devUnlockAll => 'Ξεκλείδωμα όλων — δοκιμαστικό Plus';

  @override
  String get devSimulateFree => 'Προσομοίωση δωρεάν προγράμματος';

  @override
  String get devSimulateExpired => 'Προσομοίωση ληγμένου Plus';

  @override
  String get devRestore => 'Επαναφορά κανονικής κατάστασης';

  @override
  String get devNoOverride => 'Καμία ενεργή προσομοίωση';

  @override
  String get devApplied =>
      'Το σενάριο εφαρμόστηκε και στον εξομοιωτή Firestore';

  @override
  String get devIncomplete =>
      'Ελλιπής προσομοίωση: ο εξομοιωτής Firestore δεν επιβεβαίωσε το δοκιμαστικό δικαίωμα. Οι κανόνες του διακομιστή δεν βλέπουν αυτό το σενάριο.';

  @override
  String get devNotice =>
      'Μόνο για εκδόσεις ανάπτυξης με τον εξομοιωτή: χωρίς πληρωμές, διακριτικά ή αποδείξεις.';

  @override
  String get settingsTitle => 'Ρυθμίσεις';

  @override
  String get settingsGuide => 'Δείτε ξανά τον οδηγό';

  @override
  String get settingsShare => 'Κοινοποίηση της εφαρμογής';

  @override
  String get settingsRate => 'Αξιολόγηση της εφαρμογής';

  @override
  String get settingsFeedback => 'Αποστολή σχολίων';

  @override
  String get settingsFaq => 'Συχνές ερωτήσεις';

  @override
  String get settingsShareFailed =>
      'Δεν ήταν δυνατό να ανοίξει η κοινοποίηση. Δοκιμάστε ξανά';

  @override
  String get settingsRateFailed =>
      'Δεν ήταν δυνατό να ανοίξει το Google Play. Δοκιμάστε ξανά';

  @override
  String get guideAddTitle => 'Προσθέστε ένα κρασί';

  @override
  String get guideAddBody =>
      'Πατήστε Προσθήκη για να βάλετε ένα μπουκάλι στην κάβα σας. Για αρχή αρκεί το όνομα.';

  @override
  String get guideLabelTitle => 'Διαβάστε την ετικέτα';

  @override
  String get guideLabelBody =>
      'Από την Προσθήκη μπορείτε επίσης να φωτογραφίσετε την ετικέτα: το Vinoozy διαβάζει όνομα, σοδειά και ονομασία προέλευσης, και εσείς τα ελέγχετε πριν από την αποθήκευση.';

  @override
  String get guideTabsTitle => 'Επισκόπηση, Κάβα, Ιστορικό';

  @override
  String get guideTabsBody =>
      'Η Επισκόπηση σας λέει ποια κρασιά να ανοίξετε τώρα, η Κάβα δείχνει τα μπουκάλια σας και το Ιστορικό κρατά όσα ήπιατε.';

  @override
  String get guideMenuTitle => 'Το μενού της κάβας';

  @override
  String get guideMenuBody =>
      'Εδώ βρίσκετε το προφίλ σας, τα άτομα με τα οποία μοιράζεστε την κάβα, τα καταναλωμένα κρασιά και τις Ρυθμίσεις, όπου μπορείτε να δείτε ξανά αυτόν τον οδηγό.';

  @override
  String get guideDone => 'Τέλος';

  @override
  String guideStepOf(int step, int count) {
    return 'Βήμα $step από $count';
  }

  @override
  String get hintDashboard =>
      'Εδώ βλέπετε ποια κρασιά είναι έτοιμα να πιωθούν τώρα και ποια αξίζει να περιμένουν ακόμη.';

  @override
  String get hintHistory =>
      'Κάθε μπουκάλι που πίνετε καταλήγει εδώ, με τη βαθμολογία και τις σημειώσεις σας.';

  @override
  String get hintAddWine =>
      'Ξεκινήστε από το όνομα: η σοδειά, ο τύπος και η ονομασία προέλευσης κάνουν πιο ακριβές το παράθυρο κατανάλωσης.';

  @override
  String get shareAppSubject => 'Vinoozy, η κάβα σας';

  @override
  String shareAppMessage(String link) {
    return 'Οργανώνω την κάβα μου με το Vinoozy: μου λέει πότε κάθε μπουκάλι είναι στην καλύτερη στιγμή του. Δοκιμάστε το: $link';
  }

  @override
  String get feedbackSubject => 'Σχόλια για το Vinoozy';

  @override
  String get feedbackTechHeader => 'Τεχνικά στοιχεία (μην τα διαγράψετε):';

  @override
  String get feedbackNoEmailTitle => 'Καμία εφαρμογή email';

  @override
  String feedbackNoEmailBody(String email) {
    return 'Σε αυτό το τηλέφωνο δεν υπάρχει εφαρμογή email. Γράψτε μας στο $email';
  }

  @override
  String get feedbackCopy => 'Αντιγραφή';

  @override
  String get feedbackCopied => 'Η διεύθυνση αντιγράφηκε';

  @override
  String get faqAddQuestion => 'Πώς προσθέτω ένα κρασί χειροκίνητα;';

  @override
  String get faqAddAnswer =>
      'Στην Κάβα πατήστε Προσθήκη και μετά Πληκτρολόγηση. Μόνο το όνομα είναι υποχρεωτικό· η σοδειά, ο τύπος, η χώρα και η ονομασία προέλευσης βελτιώνουν την εκτίμηση. Αποθηκεύστε και το κρασί είναι στην κάβα σας.';

  @override
  String get faqLabelQuestion =>
      'Πώς διαβάζω μια ετικέτα, και με το Google Lens;';

  @override
  String get faqLabelAnswer =>
      'Πατήστε Προσθήκη και φωτογραφίστε την μπροστινή και την πίσω πλευρά: το Vinoozy διαβάζει την ετικέτα στο ίδιο το τηλέφωνο. Στο Google Lens επιλέξτε το κείμενο και κοινοποιήστε το στο Vinoozy, ή αντιγράψτε το και χρησιμοποιήστε την Επικόλληση από το Lens στη φόρμα. Ελέγχετε πάντα τα πεδία πριν από την αποθήκευση.';

  @override
  String get faqWindowQuestion =>
      'Πώς υπολογίζεται η ιδανική στιγμή για να το πιείτε, και μπορώ να την αλλάξω;';

  @override
  String get faqWindowAnswer =>
      'Το Vinoozy εκτιμά ένα παράθυρο (αρχή, κορύφωση, τέλος) από τον τύπο, την ονομασία προέλευσης, τη σοδειά και το επίπεδο του κρασιού. Είναι ενδεικτικό: μετράει και η φύλαξη της φιάλης. Ανοίξτε το κρασί και πατήστε Διόρθωση για να ορίσετε τη δική σας ημερομηνία, ή αλλάξτε το Επίπεδο.';

  @override
  String get faqOfflineQuestion => 'Λειτουργεί χωρίς internet;';

  @override
  String get faqOfflineAnswer =>
      'Ναι. Μπορείτε να προσθέτετε, να επεξεργάζεστε και να πίνετε κρασιά χωρίς σύνδεση: όλα αποθηκεύονται στο τηλέφωνο και συγχρονίζονται με τον λογαριασμό σας μόλις επανέλθει η σύνδεση.';

  @override
  String get faqShareQuestion => 'Πώς μοιράζομαι την κάβα μου;';

  @override
  String get faqShareAnswer =>
      'Στο μενού της Κάβας ανοίξτε τα Άτομα και προσκαλέστε κάποιον με τη διεύθυνση email Google του, μόνο για προβολή ή με επεξεργασία. Εκείνος εγκαθιστά το Vinoozy και συνδέεται με αυτόν τον λογαριασμό.';

  @override
  String get faqPlusQuestion =>
      'Τι περιλαμβάνει το δωρεάν πρόγραμμα, και τι είναι το Plus;';

  @override
  String faqPlusAnswer(int limit) {
    return 'Το δωρεάν πρόγραμμα περιλαμβάνει έως $limit διαφορετικά κρασιά στην κάβα σας, με περιστασιακές διαφημίσεις μόνο στην Επισκόπηση. Το Vinoozy Plus καταργεί το όριο και τις διαφημίσεις.';
  }

  @override
  String get faqDrinkQuestion => 'Γιατί να καταγράφω τι ήπια και πώς ήταν;';

  @override
  String get faqDrinkAnswer =>
      'Το Ιστορικό κρατά τι ήπιατε και πόσο σας άρεσε. Όταν λέτε πώς ήταν το μπουκάλι (ακόμη πολύ νέο, στην ώρα του, μετά την κορύφωσή του), το Vinoozy διορθώνει την εκτίμηση για το ίδιο κρασί.';

  @override
  String get faqDeleteQuestion => 'Πώς διαγράφω τον λογαριασμό μου;';

  @override
  String get faqDeleteAnswer =>
      'Ανοίξτε το Προφίλ και πατήστε Διαγραφή λογαριασμού. Χρειάζεστε σύνδεση και μετά συνδέεστε ξανά με το Google για επιβεβαίωση. Η κάβα, το Ιστορικό και οι κοινοποιήσεις σας διαγράφονται οριστικά.';

  @override
  String get faqNotFound => 'Δεν βρήκατε την απάντηση; Γράψτε μας';
}
