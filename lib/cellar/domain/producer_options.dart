import 'package:estimation/estimation.dart';

/// One entry of the producer field (BR1.2).
class ProducerOption {
  const ProducerOption({required this.name, required this.isNew});

  /// The producer name, as known or as typed.
  final String name;

  /// True for the last entry "Add «text» as a new producer".
  final bool isNew;

  @override
  bool operator ==(Object other) =>
      other is ProducerOption && other.name == name && other.isNew == isNew;

  @override
  int get hashCode => Object.hash(name, isNew);

  @override
  String toString() => 'ProducerOption(new: $isNew)';
}

/// Producers proposed while typing (BR1.2). Pure.
///
/// The known producers (from the catalog proposals and from the wines loaded
/// in the cellar) that contain the typed text, ignoring case and accents,
/// without duplicates, at most [maxKnown], sorted by name. The last entry is
/// always "Add «text» as a new producer", with the text as typed (trimmed),
/// whenever something is typed.
List<ProducerOption> producerOptions(
  String typed, {
  Iterable<String?> catalogProducers = const [],
  Iterable<String?> cellarProducers = const [],
  int maxKnown = 8,
}) {
  final text = typed.trim();
  if (text.isEmpty) return const [];
  final needle = normalizeWineText(text);
  final known = <String, String>{};
  for (final producer in [...cellarProducers, ...catalogProducers]) {
    final name = producer?.trim();
    if (name == null || name.isEmpty) continue;
    final normalized = normalizeWineText(name);
    if (needle.isNotEmpty && !normalized.contains(needle)) continue;
    known.putIfAbsent(normalized, () => name);
  }
  final names = known.values.toList()
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return [
    for (final name in names.take(maxKnown))
      ProducerOption(name: name, isNew: false),
    ProducerOption(name: text, isNew: true),
  ];
}
