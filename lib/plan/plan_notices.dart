import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers.dart';
import '../sync/ledger/key_value_store.dart';

/// Where the once-only plan notices are remembered on the phone, created at
/// start-up. Without it (tests of other units) no notice is ever shown: a
/// notice that cannot be remembered would come back at every start.
final planNoticeStoreProvider = Provider<KeyValueStore?>((ref) => null);

/// One once-only notice: [key] holds [value] once it was shown.
typedef PlanNoticeKey = ({String key, String value});

/// The free-plan presentation of [uid], shown once (freemium-plus FR8.2).
PlanNoticeKey freePlanIntroNotice(String uid) =>
    (key: 'plan.notice.freeIntro.v1/$uid', value: 'seen');

/// The threshold explanation of [uid], once per UTC month [periodId]
/// (FR7.5).
PlanNoticeKey thresholdNotice(String uid, String periodId) =>
    (key: 'plan.notice.threshold.v1/$uid', value: periodId);

/// Whether a notice was already shown; `true` (never show) while unknown,
/// without a store, or when the store cannot be read.
final planNoticeSeenProvider =
    AsyncNotifierProvider.family<PlanNoticeSeen, bool, PlanNoticeKey>(
      PlanNoticeSeen.new,
    );

class PlanNoticeSeen extends AsyncNotifier<bool> {
  PlanNoticeSeen(this.notice);

  final PlanNoticeKey notice;

  @override
  Future<bool> build() async {
    final store = ref.watch(planNoticeStoreProvider);
    if (store == null) return true;
    try {
      return await store.read(notice.key) == notice.value;
    } catch (error, stack) {
      await ref
          .read(errorReporterProvider)
          .report(error, stack, reason: 'PlanNoticeFailed');
      return true;
    }
  }

  /// The person closed the notice: hidden now, and remembered.
  Future<void> dismiss() async {
    state = const AsyncData(true);
    await markSeen();
  }

  /// Remembers that the notice was shown; it stays on screen until it is
  /// closed or the screen goes away.
  Future<void> markSeen() async {
    final store = ref.read(planNoticeStoreProvider);
    if (store == null) return;
    try {
      await store.write(notice.key, notice.value);
    } catch (error, stack) {
      await ref
          .read(errorReporterProvider)
          .report(error, stack, reason: 'PlanNoticeFailed');
    }
  }
}
