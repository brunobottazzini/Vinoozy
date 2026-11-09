import 'dart:async';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Opening brand intro shown once at app start, over the real home, as in
/// Trasloco: the Bottazzini Softworks logo fades in, stays, and the intro
/// fades away leaving the app underneath. The Vinoozy icon is not repeated
/// here, because Android already shows it in its own launch splash (owner
/// feedback: one Vinoozy logo is enough). A tap after [skipEnabledAfter]
/// ends the intro at once.
///
/// The home is built from the start (under the intro), so sign-in and data
/// loading are not delayed by the animation.
class BrandSplash extends StatefulWidget {
  const BrandSplash({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1400),
    this.skipEnabledAfter = const Duration(milliseconds: 500),
  });

  /// The app shown under and after the intro.
  final Widget child;

  /// How long the studio logo stays, fade-in included.
  final Duration duration;

  /// Taps before this delay are ignored, so a tap meant for the app is not
  /// swallowed the instant it opens.
  final Duration skipEnabledAfter;

  static const String studioLogoAsset =
      'assets/branding/bottazzini_softworks.png';

  @override
  State<BrandSplash> createState() => _BrandSplashState();
}

class _BrandSplashState extends State<BrandSplash> {
  static const _fade = Duration(milliseconds: 250);

  bool _done = false;
  bool _visible = false;
  bool _skipEnabled = false;
  final List<Timer> _timers = [];

  @override
  void initState() {
    super.initState();
    // Start transparent and fade the logo in on the next frame.
    _after(Duration.zero, () => setState(() => _visible = true));
    _after(widget.skipEnabledAfter, () => _skipEnabled = true);
    _after(widget.duration, _finish);
  }

  void _after(Duration delay, VoidCallback action) {
    _timers.add(
      Timer(delay, () {
        if (mounted && !_done) action();
      }),
    );
  }

  void _finish() {
    for (final timer in _timers) {
      timer.cancel();
    }
    if (mounted) setState(() => _done = true);
  }

  @override
  void dispose() {
    for (final timer in _timers) {
      timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        IgnorePointer(
          ignoring: _done,
          child: AnimatedOpacity(
            opacity: _done ? 0 : 1,
            duration: _fade,
            child: _done
                ? const SizedBox.shrink()
                : GestureDetector(
                    key: const Key('brand-splash'),
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (_skipEnabled) _finish();
                    },
                    child: _SplashBody(visible: _visible),
                  ),
          ),
        ),
      ],
    );
  }
}

class _SplashBody extends StatelessWidget {
  const _SplashBody({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.primary,
      child: Center(
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 250),
          child: ClipOval(
            key: const Key('brand-splash-studio'),
            child: Image.asset(
              BrandSplash.studioLogoAsset,
              width: 220,
              height: 220,
              semanticLabel: AppLocalizations.of(context).brandStudio,
            ),
          ),
        ),
      ),
    );
  }
}
