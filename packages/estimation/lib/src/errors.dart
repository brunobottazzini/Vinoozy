// The only exception the C2 functions throw (security-design.md §2). Callers
// branch on [EstimationArgumentError.code], never on the message, which is
// English and meant for logs only.

/// Why an input was rejected (BR4.5, NFR4.2).
enum EstimationErrorCode {
  emptyName,
  vintageOutOfRange,
  referenceYearOutOfRange,
  missingReferenceYear,
  invalidWindow,

  /// wine-style-profiles (BR8.2, BR6.10): a month outside 1-12.
  monthOutOfRange,

  /// wine-style-profiles (BR8.2): a disgorgement or bottling date without
  /// both its year and its month, or with a year out of range.
  invalidAgingStart,
}

/// Invalid argument passed to a C2 function.
class EstimationArgumentError extends ArgumentError {
  EstimationArgumentError(this.code, String argumentName, [Object? value])
    : super.value(value, argumentName, code.name);

  /// Machine-readable reason, stable across versions.
  final EstimationErrorCode code;
}
