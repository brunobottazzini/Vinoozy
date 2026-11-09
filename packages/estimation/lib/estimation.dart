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
///
/// wine-style-profiles adds compatibly: the style profiles and keys
/// (`StyleProfile`, `WineStyle`), the months of a window (`monthIndex`,
/// `monthOfIndex`), the style resolution (`resolveStyle`) and the
/// classification (`classifyWine`). `estimateWindow` may now return `null`
/// ("To estimate", BR2.9).
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
export 'src/classifier.dart'
    show
        Preselection,
        PreselectionReason,
        classifyWine,
        extraGrapeTypes,
        suggestedLevel;
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
        maxOverrideMonths,
        maxOverrideSpan,
        overrideMonthRange,
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
        genericEstimateWarningCode,
        monthIndex,
        monthOfIndex;
export 'src/profiles.dart'
    show AgingAnchor, ProfileEvidence, StyleProfile, WindowUnit, WineStyle;
export 'src/style_resolver.dart'
    show
        ResolutionSource,
        StyleResolution,
        hasSeveralStyles,
        resolveStyle,
        typeDefaultProfiles;
export 'src/pairings.dart' show pairingsFor;
export 'src/qualifiers.dart'
    show agingQualifiers, selectionQualifiers, suggestsAgingLevel;
export 'src/status.dart' show statusOf;
export 'src/tables.dart' show estimationTablesVersion;
export 'src/vintage_parser.dart' show VintageParser;
export 'src/window.dart'
    show estimateWindow, needsRefinement, windowOfResolution;
export 'src/world_tables.dart' show TemplateKeys, appellationTemplates;
