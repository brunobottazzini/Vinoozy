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
}

/// Invalid argument passed to a C2 function.
class EstimationArgumentError extends ArgumentError {
  EstimationArgumentError(this.code, String argumentName, [Object? value])
    : super.value(value, argumentName, code.name);

  /// Machine-readable reason, stable across versions.
  final EstimationErrorCode code;
}
