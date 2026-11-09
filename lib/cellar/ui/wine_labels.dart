import 'package:estimation/estimation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../dashboard/ui/status_icons.dart';
import '../../l10n/app_localizations.dart';
import '../domain/cellar_filter.dart';
import '../domain/drinking_record.dart';
import '../domain/window_adjuster.dart';

// Translated labels of the cellar values. Every text comes from the
// translation files (it, en, pt-BR); the status is always icon plus text
// (FR4.5, NFR3.1), with the icons of the Dashboard.

/// Icon of a status filter; "to estimate" has its own.
IconData statusFilterIcon(StatusFilter status) => switch (status) {
  StatusFilter.waiting => statusIcons[WineStatus.waiting]!,
  StatusFilter.ready => statusIcons[WineStatus.ready]!,
  StatusFilter.drinkSoon => statusIcons[WineStatus.drinkSoon]!,
  StatusFilter.pastWindow => statusIcons[WineStatus.pastWindow]!,
  StatusFilter.toEstimate => Icons.help_outline,
};

String statusFilterLabel(AppLocalizations l10n, StatusFilter status) =>
    switch (status) {
      StatusFilter.waiting => l10n.statusWaiting,
      StatusFilter.ready => l10n.statusReady,
      StatusFilter.drinkSoon => l10n.statusDrinkSoon,
      StatusFilter.pastWindow => l10n.statusPastWindow,
      StatusFilter.toEstimate => l10n.statusToEstimate,
    };

String typeFilterLabel(AppLocalizations l10n, TypeFilter type) =>
    switch (type) {
      TypeFilter.red => l10n.familyRed,
      TypeFilter.white => l10n.familyWhite,
      TypeFilter.rose => l10n.familyRose,
      TypeFilter.sparkling => l10n.familySparkling,
      TypeFilter.sweet => l10n.familySweet,
      TypeFilter.notSpecified => l10n.filterTypeUnspecified,
    };

String wineTypeLabel(AppLocalizations l10n, WineType type) => switch (type) {
  WineType.redLight => l10n.typeRedLight,
  WineType.redStructured => l10n.typeRedStructured,
  WineType.white => l10n.typeWhite,
  WineType.rose => l10n.typeRose,
  WineType.sparklingClassic => l10n.typeSparklingClassic,
  WineType.sparklingTank => l10n.typeSparklingTank,
  WineType.sweet => l10n.typeSweet,
  WineType.fortified => l10n.typeFortified,
};

String confidenceText(AppLocalizations l10n, Confidence confidence) =>
    l10n.confidenceLabel(switch (confidence) {
      Confidence.high => l10n.confidenceHigh,
      Confidence.medium => l10n.confidenceMedium,
      Confidence.low => l10n.confidenceLow,
    });

String estimateSourceText(AppLocalizations l10n, EstimateLabel label) =>
    l10n.estimateSourceLabel(switch (label) {
      EstimateLabel.catalog => l10n.estimateSourceCatalog,
      EstimateLabel.typeEstimate => l10n.estimateSourceType,
      EstimateLabel.correctedByDrinks => l10n.estimateSourceCorrected,
      EstimateLabel.correctedByYou => l10n.estimateSourceCorrectedByYou,
    });

/// The name of a level (label-autofill-windows FR4.1).
String levelLabel(AppLocalizations l10n, WineLevel level) => switch (level) {
  WineLevel.everyday => l10n.levelEveryday,
  WineLevel.good => l10n.levelGood,
  WineLevel.aging => l10n.levelAging,
};

/// How a qualifier is written on labels: a term of the wine law, the same
/// in every language (label-autofill-windows BR1.8).
String qualifierDisplayName(Qualifier qualifier) => switch (qualifier) {
  Qualifier.riserva => 'Riserva',
  Qualifier.superiore => 'Superiore',
  Qualifier.granSelezione => 'Gran Selezione',
  Qualifier.crianza => 'Crianza',
  Qualifier.reserva => 'Reserva',
  Qualifier.granReserva => 'Gran Reserva',
  Qualifier.premierCru => 'Premier Cru',
  Qualifier.grandCru => 'Grand Cru',
  Qualifier.kabinett => 'Kabinett',
  Qualifier.spatlese => 'Spätlese',
  Qualifier.auslese => 'Auslese',
  Qualifier.vintage => 'Vintage',
  Qualifier.lbv => 'LBV',
  Qualifier.colheita => 'Colheita',
  Qualifier.beerenauslese => 'Beerenauslese',
  Qualifier.trockenbeerenauslese => 'Trockenbeerenauslese',
  Qualifier.eiswein => 'Eiswein',
};

/// The chip text of a style (wine-style-profiles BR5.2).
String styleLabel(AppLocalizations l10n, WineStyle style) => switch (style) {
  WineStyle.redFresh => l10n.styleRedFresh,
  WineStyle.redMedium => l10n.styleRedMedium,
  WineStyle.redAge => l10n.styleRedAge,
  WineStyle.redLong => l10n.styleRedLong,
  WineStyle.whiteFresh => l10n.styleWhiteFresh,
  WineStyle.whiteMedium => l10n.styleWhiteMedium,
  WineStyle.whiteAge => l10n.styleWhiteAge,
  WineStyle.roseFresh => l10n.styleRoseFresh,
  WineStyle.tankFresh => l10n.styleTankFresh,
  WineStyle.lambrusco => l10n.styleLambrusco,
  WineStyle.classicFresh => l10n.styleClassicFresh,
  WineStyle.classicAge => l10n.styleClassicAge,
  WineStyle.sweetAromatic => l10n.styleSweetAromatic,
  WineStyle.sweetPassito => l10n.styleSweetPassito,
  WineStyle.sweetBotrytis => l10n.styleSweetBotrytis,
  WineStyle.portVintage => l10n.stylePortVintage,
  WineStyle.portLbv => l10n.stylePortLbv,
  WineStyle.portTawny => l10n.stylePortTawny,
  WineStyle.sherryFino => l10n.styleSherryFino,
  WineStyle.sherryAmontillado => l10n.styleSherryAmontillado,
  WineStyle.sherryOloroso => l10n.styleSherryOloroso,
  WineStyle.sherryPx => l10n.styleSherryPx,
  WineStyle.madeira => l10n.styleMadeira,
  WineStyle.fortifiedOther => l10n.styleFortifiedOther,
};

/// The name of a profile (wine-style-profiles BR5.5).
String profileName(AppLocalizations l10n, StyleProfile profile) =>
    switch (profile) {
      StyleProfile.rFresh => l10n.profileNameRFresh,
      StyleProfile.rMedium => l10n.profileNameRMedium,
      StyleProfile.rAge => l10n.profileNameRAge,
      StyleProfile.rLong => l10n.profileNameRLong,
      StyleProfile.wFresh => l10n.profileNameWFresh,
      StyleProfile.wMedium => l10n.profileNameWMedium,
      StyleProfile.wAge => l10n.profileNameWAge,
      StyleProfile.roseFresh => l10n.profileNameRoseFresh,
      StyleProfile.spTank => l10n.profileNameSpTank,
      StyleProfile.lamFresh => l10n.profileNameLamFresh,
      StyleProfile.spClassic => l10n.profileNameSpClassic,
      StyleProfile.spClassicAge => l10n.profileNameSpClassicAge,
      StyleProfile.swAromatic => l10n.profileNameSwAromatic,
      StyleProfile.swPassito => l10n.profileNameSwPassito,
      StyleProfile.swBotrytis => l10n.profileNameSwBotrytis,
      StyleProfile.portVintage => l10n.profileNamePortVintage,
      StyleProfile.portLbv => l10n.profileNamePortLbv,
      StyleProfile.portOx => l10n.profileNamePortOx,
      StyleProfile.shFino => l10n.profileNameShFino,
      StyleProfile.shAmont => l10n.profileNameShAmont,
      StyleProfile.shOloroso => l10n.profileNameShOloroso,
      StyleProfile.shPx => l10n.profileNameShPx,
      StyleProfile.fortUnknown => l10n.profileNameFortUnknown,
      StyleProfile.unknown => l10n.profileNameUnknown,
    };

/// The label of the disgorgement or bottling date of [style] (BR8.1), or
/// `null` when its profile counts in years.
String? agingStartLabel(AppLocalizations l10n, WineStyle? style) =>
    switch (style?.agingStartLabel) {
      AgingAnchor.disgorgement => l10n.agingStartDisgorgement,
      AgingAnchor.bottling => l10n.agingStartBottling,
      _ => null,
    };

/// The language of [context] in the form intl expects ("pt_BR").
String intlLocaleOf(BuildContext context) =>
    Localizations.localeOf(context).toString();

/// "marzo 2027" / "March 2027" / "março de 2027" (BR6.6).
String formatMonthLong(BuildContext context, int year, int month) =>
    DateFormat.yMMMM(intlLocaleOf(context)).format(DateTime(year, month));

/// "mar 2027" / "Mar 2027" / "mar. de 2027" (BR6.6).
String formatMonthShort(BuildContext context, int year, int month) =>
    DateFormat.yMMM(intlLocaleOf(context)).format(DateTime(year, month));

/// The dates of a window as shown (BR6.6): the year for a window in years,
/// the month for a window in months, long or [short].
({String start, String? peak, String? end}) windowDates(
  BuildContext context,
  DrinkingWindow window, {
  bool short = false,
}) {
  String at(int year, int? month) {
    if (!window.inMonths || month == null) return '$year';
    return short
        ? formatMonthShort(context, year, month)
        : formatMonthLong(context, year, month);
  }

  return (
    start: at(window.startYear, window.startMonth),
    peak: window.peakYear == null
        ? null
        : at(window.peakYear!, window.peakMonth),
    end: window.endYear == null ? null : at(window.endYear!, window.endMonth),
  );
}

/// True when the level changes [window] (BR4.1): a window in years with a
/// peak and an end.
bool levelChangesWindow(DrinkingWindow window) =>
    !window.inMonths && window.peakYear != null && window.endYear != null;

/// The origin of the estimate in one line (interaction-spec "Origine della
/// stima"): the appellation with its qualifier, the grape, or the type;
/// `null` for a catalog window, whose source line stays.
String? estimateOriginText(AppLocalizations l10n, DrinkingWindow window) {
  // wine-style-profiles BR5.5: a window with its profile names it.
  final profile = window.profile;
  if (profile != null && window.source == WindowSource.internalRules) {
    final name = profileName(l10n, profile);
    switch (window.basis) {
      case EstimationBasis.denomination:
        final info = appellationOf(window.denominationKey);
        if (info != null) {
          return l10n.estimateFromProfile(name, info.displayName);
        }
      case EstimationBasis.grape:
        final grape = grapeNameOf(window.denominationKey);
        if (grape != null) return l10n.estimateFromProfileGrape(name, grape);
      case EstimationBasis.wineType ||
          EstimationBasis.generic ||
          EstimationBasis.catalog:
        break;
    }
    return l10n.estimateFromProfileType(name);
  }
  switch (window.basis) {
    case EstimationBasis.denomination:
      final info = appellationOf(window.denominationKey);
      if (info == null) return l10n.estimateFromType;
      final qualifier = window.qualifier;
      return qualifier == null
          ? l10n.estimateFromDenomination(info.displayName)
          : l10n.estimateFromDenominationQualifier(
              info.displayName,
              qualifierDisplayName(qualifier),
            );
    case EstimationBasis.grape:
      final name = grapeNameOf(window.denominationKey);
      return name == null
          ? l10n.estimateFromType
          : l10n.estimateFromGrape(name);
    case EstimationBasis.wineType || EstimationBasis.generic:
      return l10n.estimateFromType;
    case EstimationBasis.catalog:
      return null;
  }
}

String conditionLabel(AppLocalizations l10n, DrinkCondition condition) =>
    switch (condition) {
      DrinkCondition.tooYoung => l10n.conditionTooYoung,
      DrinkCondition.justRight => l10n.conditionJustRight,
      DrinkCondition.pastPeak => l10n.conditionPastPeak,
    };

String pairingLabel(AppLocalizations l10n, PairingCategory category) =>
    switch (category) {
      PairingCategory.braisedRedMeat => l10n.pairingBraisedRedMeat,
      PairingCategory.grilledRedMeat => l10n.pairingGrilledRedMeat,
      PairingCategory.game => l10n.pairingGame,
      PairingCategory.roastPoultry => l10n.pairingRoastPoultry,
      PairingCategory.poultry => l10n.pairingPoultry,
      PairingCategory.pork => l10n.pairingPork,
      PairingCategory.curedMeats => l10n.pairingCuredMeats,
      PairingCategory.pastaMeatSauce => l10n.pairingPastaMeatSauce,
      PairingCategory.mushroomsTruffle => l10n.pairingMushroomsTruffle,
      PairingCategory.agedCheese => l10n.pairingAgedCheese,
      PairingCategory.freshCheese => l10n.pairingFreshCheese,
      PairingCategory.blueCheese => l10n.pairingBlueCheese,
      PairingCategory.fish => l10n.pairingFish,
      PairingCategory.seafood => l10n.pairingSeafood,
      PairingCategory.rawSeafood => l10n.pairingRawSeafood,
      PairingCategory.friedFood => l10n.pairingFriedFood,
      PairingCategory.vegetables => l10n.pairingVegetables,
      PairingCategory.risotto => l10n.pairingRisotto,
      PairingCategory.pizza => l10n.pairingPizza,
      PairingCategory.aperitif => l10n.pairingAperitif,
      PairingCategory.pastries => l10n.pairingPastries,
      PairingCategory.dryBiscuits => l10n.pairingDryBiscuits,
      PairingCategory.chocolate => l10n.pairingChocolate,
      PairingCategory.driedFruit => l10n.pairingDriedFruit,
      PairingCategory.spicyDishes => l10n.pairingSpicyDishes,
    };

/// A date in the format of the app language.
String formatDay(BuildContext context, DateTime date) =>
    MaterialLocalizations.of(context).formatMediumDate(date);

/// "2016" or "no vintage".
String vintageText(AppLocalizations l10n, int? vintage) =>
    vintage?.toString() ?? l10n.noVintage;

/// The status as icon and text (FR4.5, NFR3.1).
class StatusLabel extends StatelessWidget {
  const StatusLabel({super.key, required this.status});

  final StatusFilter status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(statusFilterIcon(status), size: 18),
        const SizedBox(width: 4),
        Flexible(child: Text(statusFilterLabel(l10n, status))),
      ],
    );
  }
}
