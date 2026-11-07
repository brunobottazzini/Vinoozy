import 'package:flutter/material.dart';

/// The layout of the label outcomes with a message (unreadable, barcode
/// only, permission denied): an icon, the message (announced when it
/// appears, NFR3.2), an optional hint, then full-width buttons of at least
/// 48 dp (NFR3.1). It scrolls, so 200% text is never cut (NFR3.3).
class LabelMessageLayout extends StatelessWidget {
  const LabelMessageLayout({
    super.key,
    required this.icon,
    required this.message,
    required this.actions,
    this.hint,
  });

  final IconData icon;
  final String message;
  final String? hint;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ExcludeSemantics(
            child: Icon(icon, size: 56, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 16),
          Semantics(
            liveRegion: true,
            child: Text(
              message,
              key: const Key('label-message'),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
          ),
          if (hint != null) ...[
            const SizedBox(height: 8),
            Text(
              hint!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
          ],
          const SizedBox(height: 24),
          for (final (index, action) in actions.indexed) ...[
            if (index > 0) const SizedBox(height: 12),
            action,
          ],
        ],
      ),
    );
  }
}

/// A full-width button of the outcomes, at least 48 dp high.
ButtonStyle labelActionStyle() =>
    const ButtonStyle(minimumSize: WidgetStatePropertyAll(Size.fromHeight(48)));
