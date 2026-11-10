import 'domain/usage_counters.dart';

/// The estimated monthly cloud cost of an account and the threshold test
/// (study §7.3, freemium-plus FR6.2, plan decision D3).
///
/// `C_hat = R·0.035/100000 + W·0.104/100000 + B·0.12/GiB` (fx = 1), compared
/// with `usageBudgetEuro` in exact integer arithmetic: both sides are
/// multiplied by `10^8 · 2^30`, so
///
/// `C_hat > T` ⇔ `R·35·2^30 + W·104·2^30 + B·12·10^6 > T·10^8·2^30`
///
/// with [BigInt]: no decimal dependency, no rounding at any step. The budget
/// is a plain decimal string ("0.005") and enters as `n / 10^k`.
abstract final class UsageCost {
  static final BigInt _gib = BigInt.two.pow(30);
  static final BigInt _readUnits = BigInt.from(35) * _gib;
  static final BigInt _writeUnits = BigInt.from(104) * _gib;
  static final BigInt _byteUnits = BigInt.from(12000000);

  /// `10^8 · 2^30`: one euro in the units of [scaledCost].
  static final BigInt euroUnits = BigInt.from(100000000) * _gib;

  /// `C_hat · 10^8 · 2^30`, an exact integer.
  static BigInt scaledCost(UsageCounters usage) =>
      BigInt.from(usage.reads) * _readUnits +
      BigInt.from(usage.writes) * _writeUnits +
      BigInt.from(usage.egressBytes) * _byteUnits;

  /// Whether `C_hat` is strictly above [budgetEuro] (study §7.3: at equality
  /// no ads). A budget that is not a plain non-negative decimal throws
  /// [FormatException]: `PlanPolicy` never lets one through.
  static bool isAboveBudget(UsageCounters usage, String budgetEuro) {
    final (numerator, scale) = _decimal(budgetEuro);
    return scaledCost(usage) * scale > numerator * euroUnits;
  }

  static final RegExp _pattern = RegExp(r'^([0-9]+)(?:\.([0-9]+))?$');

  /// [text] as `numerator / scale`, with `scale = 10^digits`.
  static (BigInt, BigInt) _decimal(String text) {
    final match = _pattern.firstMatch(text);
    if (match == null) throw FormatException('not a decimal budget', text);
    final fraction = match.group(2) ?? '';
    return (
      BigInt.parse('${match.group(1)}$fraction'),
      BigInt.from(10).pow(fraction.length),
    );
  }
}
