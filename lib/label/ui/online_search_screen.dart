import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme.dart';
import '../../catalog/core/wine_catalog.dart';
import '../../catalog/platform/catalog_providers.dart';
import '../../l10n/app_localizations.dart';
import 'candidate_list.dart';
import 'label_capture_flow.dart';
import 'label_message_layout.dart';

/// The states of "Cerca online" (frontend-components.md).
enum OnlineSearchView {
  idle,
  loading,
  results,
  empty,
  offline,
  rateLimited,
  unavailable,
}

/// "Cerca online" (label-recognition FR3.2-FR3.4, BR4.1-BR4.4, L7, L8;
/// mockup "Cerca online"):
/// - the field starts with the most significant words read and can be
///   changed; "Cerca" is disabled while it is empty ("Scrivi almeno una
///   parola"); 1 to 120 characters;
/// - offline results first, then Open Food Facts ones, at most 10, with
///   the attribution;
/// - without a network only the database on the phone is searched, and the
///   screen says so; with Open Food Facts over its limits or failing, a
///   message asks to try again later; with Open Food Facts off in this
///   build, another message says online search is not active (BR4.3,
///   review R-03);
/// - a result opens the U4 form filled, above this screen.
class OnlineSearchScreen extends ConsumerStatefulWidget {
  const OnlineSearchScreen({
    super.key,
    required this.target,
    this.initialQuery = '',
    this.catalog,
  });

  final LabelTarget target;
  final String initialQuery;

  /// The catalog of the reading that opened this screen (see
  /// `LabelServices`); `null` uses the one of this screen.
  final WineCatalog? catalog;

  /// Longest query (frontend-components.md, Validazione).
  static const int maxQueryLength = 120;

  @override
  ConsumerState<OnlineSearchScreen> createState() => _OnlineSearchScreenState();
}

class _OnlineSearchScreenState extends ConsumerState<OnlineSearchScreen> {
  late final TextEditingController _query;
  OnlineSearchView _view = OnlineSearchView.idle;
  List<WineCandidate> _results = const [];
  int _search = 0;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialQuery;
    _query = TextEditingController(
      text: initial.length <= OnlineSearchScreen.maxQueryLength
          ? initial
          : initial.substring(0, OnlineSearchScreen.maxQueryLength),
    );
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  bool get _canSearch =>
      _query.text.trim().isNotEmpty && _view != OnlineSearchView.loading;

  Future<void> _run() async {
    if (!_canSearch) return;
    final id = ++_search;
    final locale = CatalogLocale.fromLanguageTag(
      Localizations.localeOf(context).toLanguageTag(),
    );
    setState(() => _view = OnlineSearchView.loading);
    final WineCatalog catalog = widget.catalog ?? ref.read(catalogProvider);
    OnlineSearchResult result;
    try {
      result = await catalog.searchOnline(_query.text.trim(), locale: locale);
    } catch (_) {
      // The catalog never fails on a valid query; anything else is "not
      // available now", never an error without a way out (NFR4.9).
      result = const OnlineSearchResult(
        candidates: [],
        status: OnlineSearchStatus.rateLimited,
      );
    }
    if (!mounted || id != _search) return;
    setState(() {
      _results = result.candidates;
      _view = switch (result.status) {
        OnlineSearchStatus.offline => OnlineSearchView.offline,
        OnlineSearchStatus.rateLimited => OnlineSearchView.rateLimited,
        OnlineSearchStatus.unavailable => OnlineSearchView.unavailable,
        OnlineSearchStatus.ok =>
          result.candidates.isEmpty
              ? OnlineSearchView.empty
              : OnlineSearchView.results,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final empty = _query.text.trim().isEmpty;
    return Scaffold(
      key: const Key('online-search-screen'),
      appBar: AppBar(title: Text(l10n.onlineSearchTitle)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.onlineSearchSubtitle,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              TextField(
                key: const Key('online-search-field'),
                controller: _query,
                textInputAction: TextInputAction.search,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(
                    OnlineSearchScreen.maxQueryLength,
                  ),
                ],
                decoration: InputDecoration(
                  labelText: l10n.onlineSearchField,
                  helperText: empty
                      ? l10n.onlineSearchEmptyField
                      : l10n.onlineSearchHint,
                  helperMaxLines: 3,
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _run(),
              ),
              const SizedBox(height: 12),
              FilledButton(
                key: const Key('online-search-submit'),
                style: labelActionStyle(),
                onPressed: _canSearch ? _run : null,
                child: Text(l10n.onlineSearchButton),
              ),
              const SizedBox(height: 16),
              ..._body(l10n, theme),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _body(AppLocalizations l10n, ThemeData theme) {
    if (_view == OnlineSearchView.idle) return const [];
    if (_view == OnlineSearchView.loading) {
      return [
        const Center(child: CircularProgressIndicator()),
        const SizedBox(height: 12),
        Semantics(
          liveRegion: true,
          child: Text(
            l10n.onlineSearchLoading,
            key: const Key('online-search-loading'),
            textAlign: TextAlign.center,
          ),
        ),
      ];
    }
    final notice = switch (_view) {
      OnlineSearchView.offline => l10n.onlineSearchOffline,
      OnlineSearchView.rateLimited => l10n.onlineSearchRateLimited,
      OnlineSearchView.unavailable => l10n.onlineSearchUnavailable,
      _ => null,
    };
    return [
      if (notice != null) ...[
        _Notice(key: Key('online-search-${_view.name}'), text: notice),
        const SizedBox(height: 12),
      ],
      if (_results.isEmpty)
        Semantics(
          liveRegion: true,
          child: Text(
            l10n.onlineSearchEmpty,
            key: const Key('online-search-empty'),
            style: theme.textTheme.bodyLarge,
          ),
        )
      else ...[
        Semantics(
          liveRegion: true,
          child: Text(
            l10n.onlineSearchResults(_results.length),
            key: const Key('online-search-count'),
            style: theme.textTheme.titleSmall,
          ),
        ),
        const SizedBox(height: 8),
        CandidateList(
          candidates: _results,
          // The offline results come from the hand-written sample: no
          // attribution for them (review R-02).
          offlineIsSample: ref.watch(wineDbLoaderProvider).isSample,
          onPick: (candidate) => LabelCaptureFlow.openCandidateForm(
            context,
            widget.target,
            candidate,
          ),
        ),
      ],
    ];
  }
}

/// A warning in the `wait` colors (design-system mapping, L6).
class _Notice extends StatelessWidget {
  const _Notice({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = StatusColors.of(context);
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.waitingChip,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: colors.onWaitingChip),
        ),
      ),
    );
  }
}
