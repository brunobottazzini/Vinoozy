import 'package:estimation/estimation.dart';

import 'wine.dart';

/// Status filter of the cellar (BR1.8): the four statuses of C2 plus "to
/// estimate" for a wine without a usable window.
enum StatusFilter {
  waiting,
  ready,
  drinkSoon,
  pastWindow,
  toEstimate;

  /// The filter matching a C2 status.
  static StatusFilter of(WineStatus status) => switch (status) {
    WineStatus.waiting => StatusFilter.waiting,
    WineStatus.ready => StatusFilter.ready,
    WineStatus.drinkSoon => StatusFilter.drinkSoon,
    WineStatus.pastWindow => StatusFilter.pastWindow,
  };
}

/// Type filter of the cellar (BR1.8): the five families plus "not
/// specified".
enum TypeFilter {
  red,
  white,
  rose,
  sparkling,
  sweet,
  notSpecified;

  /// Family of a stored `wineType` string; [notSpecified] when it is absent
  /// or not recognised by `WineType.tryParse`.
  static TypeFilter of(String? wineType) => switch (WineType.tryParse(
    wineType,
  )) {
    null => TypeFilter.notSpecified,
    WineType.redLight || WineType.redStructured => TypeFilter.red,
    WineType.white => TypeFilter.white,
    WineType.rose => TypeFilter.rose,
    WineType.sparklingClassic || WineType.sparklingTank => TypeFilter.sparkling,
    WineType.sweet || WineType.fortified => TypeFilter.sweet,
  };
}

/// Status of [wine] on [today] for the list and the filters: "to estimate"
/// when the window is missing or inconsistent (statusOf throws).
StatusFilter wineStatusOn(Wine wine, DateTime today) {
  final window = wine.window;
  if (window == null) return StatusFilter.toEstimate;
  try {
    return StatusFilter.of(statusOf(window, today));
  } on Object {
    return StatusFilter.toEstimate;
  }
}

/// Statuses of a whole list, computed once per list and day
/// (performance-design.md §2), by wine id.
Map<String, StatusFilter> statusIndexOf(List<Wine> wines, DateTime today) => {
  for (final wine in wines) wine.id: wineStatusOn(wine, today),
};

/// Search and filters of the cellar list (BR1.8). Pure and in memory: no
/// query per search (NFR2.1).
///
/// - the search looks in name and producer, ignoring case and accents
///   (`normalizeWineText` of C2);
/// - inside a group the chosen values are alternatives, the groups combine;
/// - an empty group does not filter.
class CellarFilter {
  const CellarFilter({
    this.query = '',
    this.statuses = const {},
    this.types = const {},
  });

  static const CellarFilter none = CellarFilter();

  final String query;
  final Set<StatusFilter> statuses;
  final Set<TypeFilter> types;

  bool get isEmpty => query.trim().isEmpty && statuses.isEmpty && types.isEmpty;

  CellarFilter copyWith({
    String? query,
    Set<StatusFilter>? statuses,
    Set<TypeFilter>? types,
  }) => CellarFilter(
    query: query ?? this.query,
    statuses: statuses ?? this.statuses,
    types: types ?? this.types,
  );

  /// [wines] in their order, keeping only the matching ones. [statusIndex]
  /// is reused when given (see [statusIndexOf]).
  List<Wine> apply(
    List<Wine> wines,
    DateTime today, {
    Map<String, StatusFilter>? statusIndex,
  }) {
    if (isEmpty) return wines;
    final needle = normalizeWineText(query);
    return [
      for (final wine in wines)
        if (_matchesText(wine, needle) &&
            _matchesStatus(wine, today, statusIndex) &&
            (types.isEmpty || types.contains(TypeFilter.of(wine.wineType))))
          wine,
    ];
  }

  bool _matchesText(Wine wine, String needle) {
    if (needle.isEmpty) return true;
    if (normalizeWineText(wine.name).contains(needle)) return true;
    final producer = wine.producer;
    return producer != null && normalizeWineText(producer).contains(needle);
  }

  bool _matchesStatus(
    Wine wine,
    DateTime today,
    Map<String, StatusFilter>? statusIndex,
  ) {
    if (statuses.isEmpty) return true;
    final status = statusIndex?[wine.id] ?? wineStatusOn(wine, today);
    return statuses.contains(status);
  }

  @override
  bool operator ==(Object other) =>
      other is CellarFilter &&
      other.query == query &&
      _sameSet(other.statuses, statuses) &&
      _sameSet(other.types, types);

  @override
  int get hashCode => Object.hash(
    query,
    Object.hashAllUnordered(statuses),
    Object.hashAllUnordered(types),
  );

  static bool _sameSet<T>(Set<T> a, Set<T> b) =>
      a.length == b.length && a.containsAll(b);
}
