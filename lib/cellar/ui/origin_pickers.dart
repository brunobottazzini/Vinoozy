import 'package:flutter/material.dart';

import '../../app/ui/country_flag.dart';
import '../../l10n/app_localizations.dart';
import '../domain/wine_origins.dart';
import '../domain/wine_validator.dart';

/// The country grid of the wine form (ux-redesign FR1.1): the 21 wine
/// countries with flag and name in the app language, Old World then New
/// World, and last "Other country…", which opens [AllCountriesSheet]. A
/// country chosen there is shown first in the grid. Tapping the chosen
/// country again clears it (the country is optional). Every cell is a
/// button of at least 48 × 48 dp named by the country (NFR1, A3, A4).
class CountryPicker extends StatelessWidget {
  const CountryPicker({
    super.key,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
  });

  /// ISO code of the chosen country, or `null`.
  final String? selected;
  final ValueChanged<String?> onChanged;

  /// False while the form is saving.
  final bool enabled;

  /// The codes of the grid: [selected] first when it is not one of the 21.
  static List<String> gridCodes(String? selected) => [
    if (selected != null && !WineOrigins.wineCountryCodes.contains(selected))
      selected,
    ...WineOrigins.wineCountryCodes,
  ];

  Future<void> _openAll(BuildContext context) async {
    final code = await AllCountriesSheet.show(context);
    if (code != null) onChanged(code);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final language = Localizations.localeOf(context).languageCode;
    final scaler = MediaQuery.textScalerOf(context);
    return Column(
      key: const Key('country-picker'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.uxCountryLabel,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, constraints) {
            // Four columns as in the mockup; fewer with large text.
            final columns = (constraints.maxWidth / scaler.scale(80))
                .floor()
                .clamp(2, 4);
            const gap = 6.0;
            final width =
                (constraints.maxWidth - gap * (columns - 1)) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final code in gridCodes(selected))
                  SizedBox(
                    width: width,
                    child: _CountryCell(
                      key: Key('country-cell-$code'),
                      code: code,
                      name: WineOrigins.country(code)?.nameIn(language) ?? code,
                      selected: code == selected,
                      onTap: enabled
                          ? () => onChanged(code == selected ? null : code)
                          : null,
                    ),
                  ),
                SizedBox(
                  width: width,
                  child: _CountryCell(
                    key: const Key('country-other'),
                    name: l10n.uxCountryOther,
                    selected: false,
                    onTap: enabled ? () => _openAll(context) : null,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// One cell of the grid: the flag (or the globe for "Other country…") and
/// the name; bordeaux border when chosen.
class _CountryCell extends StatelessWidget {
  const _CountryCell({
    super.key,
    this.code,
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final String? code;
  final String name;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final code = this.code;
    return Semantics(
      button: true,
      selected: selected,
      enabled: onTap != null,
      label: name,
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: selected ? scheme.surfaceContainerHigh : scheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selected ? scheme.primary : scheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (code != null)
                    CountryFlag(code: code, size: 24)
                  else
                    Icon(Icons.public, size: 26, color: scheme.primary),
                  const SizedBox(height: 2),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Other country…" (FR1.1, owner request 2f5fe44e): every ISO 3166-1
/// country and territory with its flag; on top "Rare for wine" and the
/// search, which works offline in it, en and pt-BR ignoring case and
/// accents. [show] returns the chosen code, or `null`.
class AllCountriesSheet extends StatefulWidget {
  const AllCountriesSheet({super.key});

  static Future<String?> show(BuildContext context) =>
      showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => const FractionallySizedBox(
          heightFactor: 0.92,
          child: AllCountriesSheet(),
        ),
      );

  @override
  State<AllCountriesSheet> createState() => _AllCountriesSheetState();
}

class _AllCountriesSheetState extends State<AllCountriesSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final language = Localizations.localeOf(context).languageCode;
    final searching = _query.trim().isNotEmpty;
    final countries = WineOrigins.searchCountries(
      _query,
      languageCode: language,
    );
    final rare = WineOrigins.countriesOf(WineOrigins.rareWineCountryCodes);
    final section = theme.textTheme.labelLarge?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final rows = <Widget>[
      if (!searching) ...[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(l10n.uxAllCountriesRare, style: section),
        ),
        for (final country in rare)
          _CountryRow(
            key: Key('all-countries-rare-${country.code}'),
            country: country,
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(l10n.uxAllCountriesAll, style: section),
        ),
      ],
      if (countries.isEmpty)
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            l10n.uxAllCountriesNone,
            key: const Key('all-countries-none'),
          ),
        ),
    ];
    return Semantics(
      key: const Key('all-countries-sheet'),
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      label: l10n.uxAllCountriesTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              l10n.uxAllCountriesTitle,
              style: theme.textTheme.titleLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              key: const Key('all-countries-search'),
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                labelText: l10n.uxAllCountriesSearch,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              key: const Key('all-countries-list'),
              itemCount: rows.length + countries.length,
              itemBuilder: (context, index) {
                if (index < rows.length) return rows[index];
                final country = countries[index - rows.length];
                return _CountryRow(
                  key: Key('all-countries-row-${country.code}'),
                  country: country,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// A country of the sheet: flag, name in the app language, code and the
/// English name below (mockup 8).
class _CountryRow extends StatelessWidget {
  const _CountryRow({super.key, required this.country});

  final OriginCountry country;

  @override
  Widget build(BuildContext context) {
    final language = Localizations.localeOf(context).languageCode;
    final name = country.nameIn(language);
    return ListTile(
      leading: CountryFlag(code: country.code, size: 26),
      title: Text(name),
      subtitle: Text(
        language == 'en' ? country.code : '${country.code} · ${country.en}',
      ),
      onTap: () => Navigator.of(context).pop(country.code),
    );
  }
}

/// The regions of the chosen country as chips that wrap (FR1.2): for Italy
/// all 20, for the other wine countries the main ones, always "Other
/// region" with a free field (1-120 characters, review R-03). Without a
/// country only "Other region". The value given to [onChanged] is the
/// canonical name of a listed region, or the text written (review R-02).
class RegionPicker extends StatefulWidget {
  const RegionPicker({
    super.key,
    required this.country,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
  });

  final String? country;
  final String? selected;
  final ValueChanged<String?> onChanged;
  final bool enabled;

  @override
  State<RegionPicker> createState() => _RegionPickerState();
}

class _RegionPickerState extends State<RegionPicker> {
  late final TextEditingController _free;
  late bool _freeOpen;

  WineRegion? get _listed =>
      WineOrigins.findRegion(widget.country, widget.selected);

  @override
  void initState() {
    super.initState();
    final selected = widget.selected;
    final isFree = selected != null && _listed == null;
    _free = TextEditingController(text: isFree ? selected : '');
    _freeOpen = isFree;
  }

  @override
  void didUpdateWidget(RegionPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    final selected = widget.selected;
    if (selected == oldWidget.selected && widget.country == oldWidget.country) {
      return;
    }
    if (selected == null) {
      // A new country cleared the region (review R-06).
      if (widget.country != oldWidget.country) {
        _free.clear();
        _freeOpen = false;
      }
    } else if (_listed == null && _free.text != selected) {
      // Filled from the catalog or the label with a free text.
      _free.text = selected;
      _freeOpen = true;
    }
  }

  @override
  void dispose() {
    _free.dispose();
    super.dispose();
  }

  void _pick(WineRegion region) {
    setState(() => _freeOpen = false);
    final isSelected = _listed?.canonical == region.canonical;
    widget.onChanged(isSelected ? null : region.canonical);
  }

  void _openFree() {
    setState(() => _freeOpen = true);
    widget.onChanged(_free.text.trim().isEmpty ? null : _free.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final language = Localizations.localeOf(context).languageCode;
    final country = WineOrigins.country(widget.country);
    final regions = WineOrigins.regionsOf(widget.country);
    final listed = _listed;
    final tooLong = WineValidator.validateRegion(_free.text) != null;
    Widget chip({
      required Key key,
      required String label,
      required bool selected,
      required VoidCallback onSelected,
    }) => ChoiceChip(
      key: key,
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      selectedColor: scheme.primary,
      labelStyle: TextStyle(
        color: selected ? scheme.onPrimary : scheme.onSurface,
      ),
      onSelected: widget.enabled ? (_) => onSelected() : null,
    );
    return Column(
      key: const Key('region-picker'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          country == null
              ? l10n.uxRegionLabel
              : l10n.uxRegionOf(country.nameIn(language)),
          style: theme.textTheme.labelLarge?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 0,
          children: [
            for (final region in regions)
              chip(
                key: Key('region-chip-${region.canonical}'),
                label: region.nameIn(language),
                selected: listed?.canonical == region.canonical,
                onSelected: () => _pick(region),
              ),
            chip(
              key: const Key('region-other'),
              label: '＋ ${l10n.uxRegionOther}',
              selected: _freeOpen,
              onSelected: _openFree,
            ),
          ],
        ),
        if (_freeOpen)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: TextField(
              key: const Key('region-free-field'),
              controller: _free,
              enabled: widget.enabled,
              textCapitalization: TextCapitalization.words,
              onChanged: (value) {
                setState(() {});
                widget.onChanged(value.trim().isEmpty ? null : value);
              },
              decoration: InputDecoration(
                labelText: l10n.uxRegionFieldLabel,
                errorText: tooLong ? l10n.uxRegionTooLong : null,
                errorMaxLines: 2,
              ),
            ),
          ),
      ],
    );
  }
}
