import 'package:flutter/material.dart';

/// A Dashboard card: one semantics container whose label is the text
/// description of its content (BR1.7, security-design.md §3).
///
/// The visible title sits inside [ExcludeSemantics], because the
/// description already says it: TalkBack does not read it twice. [body]
/// decides itself which of its parts stay reachable (the status bars) and
/// which are excluded (the numbers already in the description).
class DashboardCard extends StatelessWidget {
  const DashboardCard({
    super.key,
    required this.title,
    required this.description,
    required this.body,
  });

  final String title;
  final String description;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      container: true,
      label: description,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        color: theme.colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ExcludeSemantics(
                child: Text(title, style: theme.textTheme.titleMedium),
              ),
              const SizedBox(height: 8),
              body,
            ],
          ),
        ),
      ),
    );
  }
}
