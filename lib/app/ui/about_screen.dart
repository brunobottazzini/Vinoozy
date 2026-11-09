import 'package:estimation/estimation.dart' show appellationsSource;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../catalog/platform/catalog_providers.dart';
import '../../catalog/platform/wine_db_loader.dart';
import '../../l10n/app_localizations.dart';

/// "Informazioni" (label-recognition BR6.3, FR2.2, NFR6.7, TS5; interaction
/// spec R-03), opened from the cellar menu: the app version, the offline
/// wine database (number of wines and date of the Open Food Facts export,
/// so the owner sees at once whether it is loaded and how old it is; for
/// the hand-written sample, a note that it is a sample), the
/// ODbL and DbCL licences with where the database is published, and the
/// photo privacy note. Sections as the Dashboard tiles; it scrolls, so 200%
/// text is never cut.
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  /// The public repository with the database and its tool (TS5, NFR5.7).
  static const String repositoryUrl =
      'https://github.com/brunobottazzini/Vinoozy';

  static Future<void> open(BuildContext context) =>
      Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => const AboutScreen()));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final version = ref.watch(catalogAppVersionProvider).value;
    final db = ref.watch(wineDbStatusProvider);
    final language = Localizations.localeOf(context).toLanguageTag();
    final dbLines = switch (db) {
      // The hand-written sample says so in place of an export date: it is
      // not Open Food Facts data (review R-02).
      AsyncData(value: WineDbReady(db: final ready))
          when ready.manifest.isSample =>
        [l10n.aboutDbCount(ready.wineCount), l10n.aboutDbSample],
      AsyncData(value: WineDbReady(db: final ready)) => [
        l10n.aboutDbCount(ready.wineCount),
        l10n.aboutDbDate(
          DateFormat.yMMMMd(language).format(ready.manifest.exportDate),
        ),
        // wine-style-profiles NFR6.1: the share with a Type (format 2).
        if (ready.manifest.classifiedTypeShare case final share?)
          l10n.aboutDbClassified(
            NumberFormat.decimalPatternDigits(
              locale: language,
              decimalDigits: 1,
            ).format(share * 100),
          ),
      ],
      AsyncData(value: WineDbUnavailable()) ||
      AsyncError() => [l10n.aboutDbUnavailable],
      _ => [l10n.aboutDbLoading],
    };
    return Scaffold(
      key: const Key('about-screen'),
      appBar: AppBar(title: Text(l10n.aboutTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Tile(
              key: const Key('about-version'),
              title: 'Vinoozy',
              lines: [if (version != null) l10n.aboutVersion(version)],
            ),
            _Tile(
              key: const Key('about-db'),
              title: l10n.aboutDbTitle,
              lines: dbLines,
            ),
            _Tile(
              key: const Key('about-license'),
              title: l10n.aboutLicenseTitle,
              lines: [l10n.aboutLicense, l10n.aboutDbSource(repositoryUrl)],
            ),
            // label-autofill-windows NFR5.7, TS3: the source of the
            // appellation table, and whether it is still the sample.
            _Tile(
              key: const Key('about-appellations'),
              title: l10n.aboutAppellationsTitle,
              lines: [
                l10n.aboutAppellationsSource,
                if (appellationsSource == 'sample')
                  l10n.aboutAppellationsSample,
              ],
            ),
            _Tile(
              key: const Key('about-privacy'),
              title: l10n.aboutPrivacyTitle,
              lines: [l10n.aboutPrivacy],
            ),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({super.key, required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(title, style: theme.textTheme.titleMedium),
            ),
            for (final line in lines) ...[
              const SizedBox(height: 8),
              Text(line, style: theme.textTheme.bodyLarge),
            ],
          ],
        ),
      ),
    );
  }
}
