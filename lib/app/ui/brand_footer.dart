import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../l10n/app_localizations.dart';
import 'about_screen.dart';
import 'brand_splash.dart';

/// Version shown to the owner: name and build number, e.g. "0.1.0 (12)",
/// so a phone build can be told apart from the previous one.
final appVersionLabelProvider = FutureProvider<String?>((ref) async {
  try {
    final info = await PackageInfo.fromPlatform();
    return info.buildNumber.isEmpty
        ? info.version
        : '${info.version} (${info.buildNumber})';
  } on Object {
    // The label is informative only: without it the footer shows no version.
    return null;
  }
});

/// Bottom of the Dashboard: the Bottazzini Softworks logo, the studio name
/// and the app version. A tap opens "Informazioni".
class BrandFooter extends ConsumerWidget {
  const BrandFooter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final version = ref.watch(appVersionLabelProvider).value;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    // Owner feedback: the logo bigger, on the left, across the whole row.
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: InkWell(
        key: const Key('brand-footer'),
        borderRadius: BorderRadius.circular(16),
        onTap: () => AboutScreen.open(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Row(
            children: [
              ClipOval(
                child: Image.asset(
                  BrandSplash.studioLogoAsset,
                  width: 96,
                  height: 96,
                  excludeFromSemantics: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.brandStudio,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (version != null)
                      Text(
                        l10n.aboutVersion(version),
                        key: const Key('brand-footer-version'),
                        style: muted,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
