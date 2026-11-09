import 'package:cloud_firestore/cloud_firestore.dart' show FieldValue;
import 'package:estimation/estimation.dart';

import 'wine.dart';

/// Type, Level and Style of a wine with where they come from
/// (wine-style-profiles BR7.1, F5): what the detail writes when the owner
/// chooses a style, and what the one-off migration fills.
class WineClassification {
  const WineClassification({
    this.wineType,
    this.typeSource,
    this.level,
    this.levelSource,
    this.style,
    this.styleSource,
  });

  /// The classification stored on [wine].
  factory WineClassification.of(Wine wine) => WineClassification(
    wineType: WineType.tryParse(wine.wineType),
    typeSource: wine.typeSource,
    level: wine.level,
    levelSource: wine.levelSource,
    style: wine.style,
    styleSource: wine.styleSource,
  );

  final WineType? wineType;
  final FieldSource? typeSource;
  final WineLevel? level;
  final FieldSource? levelSource;
  final WineStyle? style;
  final FieldSource? styleSource;

  /// BR7.2: [preselection] fills only the fields that are empty or `auto`;
  /// a field chosen by the user never changes.
  WineClassification withPreselection(Preselection preselection) {
    final typeIsUser = typeSource == FieldSource.user && wineType != null;
    final levelIsUser = levelSource == FieldSource.user && level != null;
    final styleIsUser = styleSource == FieldSource.user && style != null;
    final newType = typeIsUser ? wineType : preselection.wineType;
    final newLevel = levelIsUser ? level : preselection.level;
    return WineClassification(
      wineType: newType,
      typeSource: typeIsUser
          ? FieldSource.user
          : (newType == null ? null : FieldSource.auto),
      level: newLevel,
      // A source only with its value (ENT-108).
      levelSource: newLevel == null
          ? null
          : (levelIsUser ? FieldSource.user : FieldSource.auto),
      style: styleIsUser ? style : _styleFor(preselection, newType),
      styleSource: styleIsUser
          ? FieldSource.user
          : (_styleFor(preselection, newType) == null
                ? null
                : FieldSource.auto),
    );
  }

  /// The proposed style when it belongs to [type] (BR5.2); a type kept by
  /// the user may not match the preselection's style.
  static WineStyle? _styleFor(Preselection preselection, WineType? type) {
    final style = preselection.style;
    if (style == null || type == null) return null;
    return style.wineTypes.contains(type) ? style : null;
  }

  /// The stored fields: a value, or a delete for an empty field.
  Map<String, Object> toFields() => {
    WineFields.wineType: wineType?.name ?? FieldValue.delete(),
    WineFields.typeSource: typeSource?.name ?? FieldValue.delete(),
    WineFields.level: level?.name ?? FieldValue.delete(),
    WineFields.levelSource: levelSource?.name ?? FieldValue.delete(),
    WineFields.style: style?.name ?? FieldValue.delete(),
    WineFields.styleSource: styleSource?.name ?? FieldValue.delete(),
  };

  @override
  bool operator ==(Object other) =>
      other is WineClassification &&
      other.wineType == wineType &&
      other.typeSource == typeSource &&
      other.level == level &&
      other.levelSource == levelSource &&
      other.style == style &&
      other.styleSource == styleSource;

  @override
  int get hashCode =>
      Object.hash(wineType, typeSource, level, levelSource, style, styleSource);

  @override
  String toString() =>
      'WineClassification(${wineType?.name}/${typeSource?.name}, '
      '${level?.name}/${levelSource?.name}, '
      '${style?.name}/${styleSource?.name})';
}
