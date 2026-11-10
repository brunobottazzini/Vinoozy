import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'cloud_usage_meter.dart';
import 'domain/usage_counters.dart';
import 'usage_uploader.dart';

/// The usage meter (freemium-plus FR6.1), created at start-up
/// (lib/app/bootstrap.dart). Null in tests that do not need it: nothing is
/// counted and the threshold is never verified, so no ad is ever shown
/// (NFR4).
final usageMeterProvider = Provider<CloudUsageMeter?>((ref) => null);

/// The uploader of the meter's counters (FR6.3), created at start-up.
final usageUploaderProvider = Provider<UsageUploader?>((ref) => null);

/// What the app knows of the account's usage in the current UTC month
/// (study §7.6, FR7.2, FR7.5).
class UsageStatus {
  const UsageStatus({
    required this.periodId,
    required this.nextResetUtc,
    required this.verified,
    required this.aboveBudget,
  });

  /// Not verified: no server answer for the month. Never leads to ads or to
  /// the threshold explanation (NFR4).
  factory UsageStatus.unverified(DateTime nowUtc) {
    final period = UsagePeriod.containing(nowUtc);
    return UsageStatus(
      periodId: period.id,
      nextResetUtc: period.nextResetUtc,
      verified: false,
      aboveBudget: false,
    );
  }

  /// `YYYY-MM` of the current UTC month by the estimated server time.
  final String periodId;

  /// When the counters start again; the UI shows it in local time (FR7.5).
  final DateTime nextResetUtc;

  /// The server answered for this month at least once.
  final bool verified;

  /// `C_hat` strictly above `usageBudgetEuro` (FR6.2).
  final bool aboveBudget;

  @override
  bool operator ==(Object other) =>
      other is UsageStatus &&
      other.periodId == periodId &&
      other.nextResetUtc == nextResetUtc &&
      other.verified == verified &&
      other.aboveBudget == aboveBudget;

  @override
  int get hashCode =>
      Object.hash(periodId, nextResetUtc, verified, aboveBudget);
}

/// The [UsageStatus] of the current month, again after every count and every
/// upload. Unverified without a meter or an uploader.
final usageStatusProvider = StreamProvider<UsageStatus>((ref) {
  final meter = ref.watch(usageMeterProvider);
  final uploader = ref.watch(usageUploaderProvider);
  if (meter == null || uploader == null) {
    return Stream.value(UsageStatus.unverified(DateTime.now().toUtc()));
  }
  UsageStatus current() {
    final period = meter.currentPeriod;
    return UsageStatus(
      periodId: period.id,
      nextResetUtc: period.nextResetUtc,
      verified: uploader.isVerified(period),
      aboveBudget: uploader.isAboveBudget(period),
    );
  }

  late final StreamController<UsageStatus> controller;
  final subscriptions = <StreamSubscription<Object?>>[];
  UsageStatus? last;
  void emit() {
    final next = current();
    if (next == last || controller.isClosed) return;
    last = next;
    controller.add(next);
  }

  controller = StreamController<UsageStatus>(
    onListen: () {
      emit();
      subscriptions
        ..add(meter.changes.listen((_) => emit()))
        ..add(uploader.updates.listen((_) => emit()));
    },
    onCancel: () async {
      for (final subscription in subscriptions) {
        await subscription.cancel();
      }
    },
  );
  return controller.stream;
});
