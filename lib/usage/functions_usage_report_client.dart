import 'package:cloud_functions/cloud_functions.dart';

import '../firebase/functions_config.dart';
import 'domain/usage_counters.dart';
import 'usage_uploader.dart';

/// [UsageReportClient] over the callable `reportUsage` (freemium-plus FR6.3,
/// study §7.6). Authenticated and protected by App Check on the server; the
/// uid comes from the authentication, never from the payload. Only numbers
/// and identifiers travel (NFR6).
///
/// Request: `installationId`, `periodId` (`YYYY-MM`), `sequence`,
/// `policyVersion` and the cumulative counters
/// (`cumulativeReadCount`, `cumulativeWriteCount`, `cumulativeEgressBytes`).
/// Answer (functions/README.md): `accepted`, `reason`, the account total of
/// the period (`estimatedReadCount`, `estimatedWriteCount`,
/// `estimatedEgressBytes`), `serverTime` and `nextResetUtc` (ISO-8601).
class FunctionsUsageReportClient implements UsageReportClient {
  FunctionsUsageReportClient(this._functions);

  final FirebaseFunctions Function() _functions;

  static const String callableName = 'reportUsage';

  @override
  Future<UsageReportResult> report(UsageReport report) async {
    final result = await _functions().httpsCallable(callableName).call<Object?>(
      {
        'installationId': report.installationId,
        'periodId': report.periodId,
        'sequence': report.sequence,
        'policyVersion': report.policyVersion,
        ...report.cumulative.toCumulativeMap(),
      },
    );
    return parseUsageReportResult(result.data, periodId: report.periodId);
  }
}

/// The answer of `reportUsage`, read leniently. A missing server time throws
/// [FormatException]: the uploader reports it and sends the same cumulative
/// again later, so an answer it cannot read never counts as verified.
UsageReportResult parseUsageReportResult(
  Object? data, {
  required String periodId,
}) {
  final answer = callableMap(data);
  final serverTime = callableTime(answer['serverTime']);
  if (serverTime == null) {
    throw const FormatException('reportUsage answered without serverTime');
  }
  final total = answer['total'] is Map ? callableMap(answer['total']) : answer;
  final period = UsagePeriod.tryParse(periodId);
  final reason = answer['reason'];
  return UsageReportResult(
    accepted: answer['accepted'] != false,
    reason: reason is String ? reason : null,
    accountTotal: UsageCounters(
      reads: callableCount(total[UsageFields.estimatedReadCount]),
      writes: callableCount(total[UsageFields.estimatedWriteCount]),
      egressBytes: callableCount(total[UsageFields.estimatedEgressBytes]),
    ),
    serverTime: serverTime,
    nextResetUtc:
        callableTime(answer['nextResetUtc']) ??
        period?.nextResetUtc ??
        UsagePeriod.containing(serverTime).nextResetUtc,
  );
}
