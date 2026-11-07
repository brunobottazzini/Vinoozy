import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// S0 — first-start presentation (u8-account BR1.1): three pages with a page
/// indicator, "Skip" and, on the last page, "Start". Both lead to sign-in;
/// [onDone] marks `onboarding.seen`.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onDone});

  final Future<void> Function() onDone;

  static const int pageCount = 3;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pages = PageController();
  int _page = 0;
  bool _leaving = false;

  bool get _isLast => _page == OnboardingScreen.pageCount - 1;

  Future<void> _done() async {
    if (_leaving) return;
    setState(() => _leaving = true);
    await widget.onDone();
  }

  void _next() => _pages.nextPage(
    duration: const Duration(milliseconds: 250),
    curve: Curves.easeOut,
  );

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pages = [
      (Icons.wine_bar, l10n.onboardingPage1Title, l10n.onboardingPage1Body),
      (Icons.schedule, l10n.onboardingPage2Title, l10n.onboardingPage2Body),
      (Icons.group, l10n.onboardingPage3Title, l10n.onboardingPage3Body),
    ];
    return Scaffold(
      key: const Key('onboarding-screen'),
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: TextButton(
                  key: const Key('onboarding-skip'),
                  onPressed: _leaving ? null : _done,
                  child: Text(l10n.onboardingSkip),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pages,
                onPageChanged: (page) => setState(() => _page = page),
                children: [
                  for (final (icon, title, body) in pages)
                    _OnboardingPage(icon: icon, title: title, body: body),
                ],
              ),
            ),
            Semantics(
              key: const Key('onboarding-indicator'),
              label: l10n.onboardingPageOf(_page + 1),
              liveRegion: true,
              excludeSemantics: true,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < OnboardingScreen.pageCount; i++)
                    _Dot(active: i == _page),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: _isLast
                    ? FilledButton(
                        key: const Key('onboarding-start'),
                        onPressed: _leaving ? null : _done,
                        child: Text(l10n.onboardingStart),
                      )
                    : FilledButton.tonal(
                        key: const Key('onboarding-next'),
                        onPressed: _next,
                        child: Text(l10n.onboardingNext),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Text at 200% scrolls instead of being cut (NFR3.1).
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Icon(icon, size: 96, color: theme.colorScheme.primary),
          const SizedBox(height: 24),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text(
            body,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? colors.primary : colors.outlineVariant,
      ),
    );
  }
}
