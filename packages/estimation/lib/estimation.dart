/// Drinking-window, status and pairing estimation (contract C2 v1).
///
/// Only the C2 API is exported: the four functions, their value types,
/// [EstimationArgumentError] and the catalog functions added compatibly on
/// 2026-11-05 for the wine catalog (`normalizeWineText`,
/// `recognizeDenomination`, `denominationCatalog`). Everything under `src/`
/// that is not listed here (tables, recognizer, validation) is internal.
///
/// label-autofill-windows adds compatibly: the label-text extractor
/// (`extractLabelFields`, with `VintageParser` and `LabelLinePicker` moved
/// from the app), the level (`WineLevel`), the effective window with the
/// manual correction (`effectiveWindow`), the read-only view of the world
/// appellations (`appellations`, `findAppellation`) and the country names
/// of the labels (`countryCodeOfName`).
library;

export 'src/appellations.dart'
    show
        AppellationInfo,
        appellationOf,
        appellations,
        appellationsSource,
        findAppellation,
        generatedFieldSeparator,
        generatedListSeparator,
        grapeForms,
        grapeNameOf,
        parseGeneratedRow;
export 'src/catalog.dart'
    show
        DenominationInfo,
        RecognizedDenomination,
        denominationCatalog,
        normalizeWineText,
        recognizeDenomination;
export 'src/country_names.dart' show countryCodeOfName, wineCountryNames;
export 'src/effective_window.dart'
    show
        effectiveWindow,
        isValidOverrideYear,
        maxOverrideSpan,
        overrideYearRange;
export 'src/errors.dart' show EstimationArgumentError, EstimationErrorCode;
export 'src/label_fields.dart'
    show
        CandidateSignal,
        FieldCandidate,
        FieldCertainty,
        KeyField,
        KeyFieldAnalysis,
        LabelAnalysis,
        LabelFieldKeys,
        LabelFields,
        LabelWord,
        agingQualifierIn,
        analyzeLabelText,
        canSelect,
        composeValue,
        extractLabelFields,
        isCertainScore,
        labelCertaintyMargin,
        labelCertaintyThreshold,
        matchDenomination,
        maxComposedLength,
        maxComposedWords,
        maxLabelTextLength,
        maxLabelWords,
        sanitizeLabelText;
export 'src/label_line_picker.dart'
    show DenominationTest, LabelLinePicker, hasLetters;
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
        WineLevel,
        WineStatus,
        WineType,
        genericEstimateWarningCode;
export 'src/pairings.dart' show pairingsFor;
export 'src/qualifiers.dart' show agingQualifiers;
export 'src/status.dart' show statusOf;
export 'src/tables.dart' show estimationTablesVersion;
export 'src/vintage_parser.dart' show VintageParser;
export 'src/window.dart' show estimateWindow, needsRefinement;
export 'src/world_tables.dart' show TemplateKeys, appellationTemplates;
