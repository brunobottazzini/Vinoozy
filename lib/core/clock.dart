/// Source of the current time, injectable so tests never depend on the real
/// calendar (current year for vintage validation) or on real waiting.
abstract interface class Clock {
  DateTime now();
}

/// Production clock backed by [DateTime.now].
class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}
