/// Drinking-window, status and pairing estimation (contract C2 v1).
///
/// Only the C2 API is exported: the four functions, their value types,
/// [EstimationArgumentError] and the catalog functions added compatibly on
/// 2026-11-05 for the wine catalog (`normalizeWineText`,
/// `recognizeDenomination`, `denominationCatalog`). Everything under `src/`
/// that is not listed here (tables, recognizer, validation) is internal.
library;

export 'src/catalog.dart'
    show
        DenominationInfo,
        RecognizedDenomination,
        denominationCatalog,
        normalizeWineText,
        recognizeDenomination;
export 'src/errors.dart' show EstimationArgumentError, EstimationErrorCode;
export 'src/models.dart'
    show
        Confidence,
        DrinkingWindow,
        EstimationBasis,
        ExternalProfile,
        Pairings,
        PairingCategory,
        Qualifier,
        WindowSource,
        WineFacts,
        WineStatus,
        WineType,
        genericEstimateWarningCode;
export 'src/pairings.dart' show pairingsFor;
export 'src/status.dart' show statusOf;
export 'src/window.dart' show estimateWindow, needsRefinement;
