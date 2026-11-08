import 'package:estimation/estimation.dart';
import 'package:flutter/material.dart';

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
};

/// The origin of the estimate in one line (interaction-spec "Origine della
/// stima"): the appellation with its qualifier, the grape, or the type;
/// `null` for a catalog window, whose source line stays.
String? estimateOriginText(AppLocalizations l10n, DrinkingWindow window) {
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
