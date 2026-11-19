import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../plan/domain/plan_policy.dart';
import 'feedback_flow.dart';

/// Frequently asked questions (tester-feedback FR7): eight short answers
/// that open and close with a tap, all in the app (no network, FR7.2,
/// NFR6), and at the end "Didn't find the answer?", which opens the
/// feedback email (FR7.3).
///
/// The free-plan answer shows the app's own limit constant, never a number
/// written in the text (review R-07). The limit counts different active
/// wines, as the capacity sheet says, not bottles.
class FaqScreen extends ConsumerWidget {
  const FaqScreen({
    super.key,
    this.freeWineLimit = PlanPolicy.defaultFreeActiveWineLimit,
  });

  /// The free plan's active-wine limit shown in the Plus answer.
  final int freeWineLimit;

  static Future<void> open(BuildContext context) =>
      Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => const FaqScreen()));

  /// The eight questions and answers, in the order of FR7.1.
  static List<(String, String)> entriesOf(AppLocalizations l10n, int limit) => [
    (l10n.faqAddQuestion, l10n.faqAddAnswer),
    (l10n.faqLabelQuestion, l10n.faqLabelAnswer),
    (l10n.faqWindowQuestion, l10n.faqWindowAnswer),
    (l10n.faqOfflineQuestion, l10n.faqOfflineAnswer),
    (l10n.faqShareQuestion, l10n.faqShareAnswer),
    (l10n.faqPlusQuestion, l10n.faqPlusAnswer(limit)),
    (l10n.faqDrinkQuestion, l10n.faqDrinkAnswer),
    (l10n.faqDeleteQuestion, l10n.faqDeleteAnswer),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final entries = entriesOf(l10n, freeWineLimit);
    return Scaffold(
      key: const Key('faq-screen'),
      appBar: AppBar(title: Text(l10n.settingsFaq)),
      body: SafeArea(
        child: ListView(
          children: [
            for (final (index, (question, answer)) in entries.indexed)
              ExpansionTile(
                key: Key('faq-item-$index'),
                title: Text(question),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [Text(answer)],
              ),
            const Divider(),
            ListTile(
              key: const Key('faq-feedback'),
              minTileHeight: 56,
              leading: const Icon(Icons.mail_outline),
              title: Text(l10n.faqNotFound),
              onTap: () => sendFeedback(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}
