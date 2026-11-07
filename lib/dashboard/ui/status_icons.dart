import 'package:estimation/estimation.dart';
import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../l10n/app_localizations.dart';

/// Icon of each wine status, shared by the Dashboard and the cellar list of
/// U4 (FR4.5): the status is never shown by color only (NFR3.5).
const Map<WineStatus, IconData> statusIcons = {
  WineStatus.waiting: Icons.hourglass_empty,
  WineStatus.ready: Icons.check_circle_outline,
  WineStatus.drinkSoon: Icons.alarm,
  WineStatus.pastWindow: Icons.history,
};

/// Translated label of [status] (BR1.4).
String statusLabel(AppLocalizations l10n, WineStatus status) =>
    switch (status) {
      WineStatus.waiting => l10n.statusWaiting,
      WineStatus.ready => l10n.statusReady,
      WineStatus.drinkSoon => l10n.statusDrinkSoon,
      WineStatus.pastWindow => l10n.statusPastWindow,
    };

/// Bar color of [status] from the theme (NFR3.2).
Color statusColor(StatusColors colors, WineStatus status) => switch (status) {
  WineStatus.waiting => colors.waiting,
  WineStatus.ready => colors.ready,
  WineStatus.drinkSoon => colors.drinkSoon,
  WineStatus.pastWindow => colors.pastWindow,
};
