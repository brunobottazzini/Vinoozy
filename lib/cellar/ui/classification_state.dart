import 'package:estimation/estimation.dart';

import '../domain/wine.dart';

/// Type, Style and the disgorgement/bottling date of an add or edit form
/// with where they come from (wine-style-profiles F2, BR4.6, BR5.1-BR5.3,
/// BR7.1-BR7.3, BR8.1): the preselection fills the empty and automatic
/// fields at every change of the name, producer or denomination; a choice
/// of the user is never overwritten; "Restore suggestion" brings a field
/// back to automatic. Plain state, held by the form's State.
class ClassificationState {
  ClassificationState({
    this.type,
    this.typeSource,
    this.style,
    this.styleSource,
    AgingStart? agingStart,
  }) : agingYear = agingStart?.year,
       agingMonth = agingStart?.month;

  /// The state of a saved wine (edit form). A field without a source is
  /// the user's when it has a value (saved before wine-style-profiles).
  factory ClassificationState.ofWine(Wine wine) {
    final type = WineType.tryParse(wine.wineType);
    return ClassificationState(
      type: type,
      typeSource: type == null ? null : wine.typeSource ?? FieldSource.user,
      style: wine.style,
      styleSource: wine.style == null
          ? null
          : wine.styleSource ?? FieldSource.user,
      agingStart: wine.agingStart,
    );
  }

  WineType? type;
  FieldSource? typeSource;
  WineStyle? style;
  FieldSource? styleSource;
  int? agingYear;
  int? agingMonth;

  /// The last preselection, for "Restore suggestion".
  Preselection? suggestion;

  /// The resolution of the facts of the form now (style, profile, notice).
  StyleResolution? resolution;

  bool get typeIsUser => typeSource == FieldSource.user;
  bool get styleIsUser => styleSource == FieldSource.user;

  /// Recomputes the suggestions and fills the automatic fields (BR7.2).
  void refresh({
    required String name,
    String? producer,
    String? denomination,
    int? vintage,
    String? country,
    WineType? dbType,
    required int referenceYear,
  }) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      suggestion = null;
      resolution = null;
      if (!typeIsUser) {
        type = null;
        typeSource = null;
      }
      if (!styleIsUser) {
        style = null;
        styleSource = null;
      }
      return;
    }
    final preselection = classifyWine(
      trimmed,
      producer: producer,
      denomination: denomination,
      country: country,
      vintage: vintage,
      dbType: dbType,
    );
    suggestion = preselection;
    if (!typeIsUser) {
      type = preselection.wineType;
      typeSource = type == null ? null : FieldSource.auto;
    }
    final current = type;
    final resolved = current == null
        ? null
        : resolveStyle(
            WineFacts(
              name: trimmed,
              producer: producer,
              denomination: denomination,
              vintage: vintage,
              wineType: current,
              referenceYear: referenceYear,
            ),
          );
    resolution = resolved;
    if (styleIsUser && style != null && !style!.wineTypes.contains(current)) {
      // A style of another type does not stay (BR5.2).
      style = null;
      styleSource = null;
    }
    if (!styleIsUser) {
      final proposed = suggestedStyle;
      style = proposed;
      styleSource = proposed == null ? null : FieldSource.auto;
    }
  }

  /// The style the preselection proposes for the type shown (BR5.3): the
  /// one of the classification when it fits the type, else the resolved
  /// one; none for a Sherry without a style word.
  WineStyle? get suggestedStyle {
    final current = type;
    if (current == null) return null;
    final fromClassification = suggestion?.style;
    if (suggestion?.wineType == current &&
        fromClassification != null &&
        fromClassification.wineTypes.contains(current)) {
      return fromClassification;
    }
    if (suggestion?.wineType == current && fromClassification == null) {
      return null;
    }
    final resolved = resolution?.style;
    return resolved != null && resolved.wineTypes.contains(current)
        ? resolved
        : null;
  }

  /// A tap on a type (or "not specified"): the user's choice.
  void chooseType(WineType? value) {
    type = value;
    typeSource = value == null ? null : FieldSource.user;
  }

  /// A tap on a chip, the suggested one too (BR5.4): the user's choice.
  void chooseStyle(WineStyle value) {
    style = value;
    styleSource = FieldSource.user;
  }

  /// "Restore suggestion" of the type (BR7.3).
  void restoreType() => typeSource = FieldSource.auto;

  /// "Restore suggestion" of the style (BR7.3).
  void restoreStyle() => styleSource = FieldSource.auto;

  /// BR7.3: shown only for a user field whose suggestion exists and
  /// differs.
  bool get canRestoreType =>
      typeIsUser &&
      suggestion?.wineType != null &&
      suggestion!.wineType != type;

  bool get canRestoreStyle =>
      styleIsUser && suggestedStyle != null && suggestedStyle != style;

  /// BR5.1: whether the Style field shows.
  bool get styleVisible {
    final current = type;
    if (current == null) return false;
    switch (current) {
      case WineType.sparklingClassic:
      case WineType.sparklingTank:
      case WineType.sweet:
      case WineType.fortified:
        return true;
      case WineType.rose:
        return false;
      case WineType.redLight:
      case WineType.redStructured:
      case WineType.white:
        final r = resolution;
        return r == null ||
            r.styleToConfirm ||
            r.profile == StyleProfile.unknown ||
            r.basis != EstimationBasis.denomination;
    }
  }

  /// The profile of the style shown, else of the type (BR8.1).
  StyleProfile? get profile =>
      style?.profile ??
      (type == null ? null : typeDefaultProfiles[type]) ??
      resolution?.profile;

  /// BR8.1: the date field shows for a profile in months.
  bool get agingStartVisible => profile?.inMonths ?? false;

  /// The anchor of the date (BR8.1): disgorgement or bottling.
  AgingAnchor? get agingStartAnchor =>
      agingStartVisible ? profile!.anchor : null;

  /// The date saved: only when the field shows and both parts are given.
  AgingStart? get agingStart {
    final year = agingYear;
    final month = agingMonth;
    if (!agingStartVisible || year == null || month == null) return null;
    return AgingStart(year, month);
  }

  /// BR5.4: "Style to confirm" while the style is a hypothesis.
  bool get styleToConfirm {
    if (styleIsUser) return style?.profile.isUnclear ?? false;
    final r = resolution;
    return r != null && (r.styleToConfirm || r.indicative);
  }
}
