// Front and back of a label read as one (label-recognition BR1.2, BR1.3,
// BR1.5; entities.md `MergedReading`). Pure Dart.

import 'package:estimation/estimation.dart' show normalizeWineText;

import 'barcode_filter.dart';
import 'label_reading.dart';

/// Which photo the barcode was read on.
enum BarcodeSide { front, back }

/// What the back photo gave.
enum BackStatus {
  /// No back photo: "Salta", camera cancelled or access denied (BR1.6).
  skipped,

  /// Read and used.
  taken,

  /// Taken but not readable, or its reading failed: "Retro non leggibile"
  /// (BR1.5).
  unreadable,
}

/// Front and back merged (entities.md `MergedReading`).
class MergedReading {
  const MergedReading({
    required this.text,
    this.barcode,
    this.barcodeSide,
    this.backStatus = BackStatus.skipped,
  });

  /// At most this many characters per photo (BR1.2).
  static const int maxTextPerPhoto = 2000;

  /// At most this many characters in all (BR1.2).
  static const int maxText = 4000;

  /// Front lines, then the back lines not already there.
  final String text;

  /// The first valid barcode, normalised; front before back (BR1.3).
  final String? barcode;
  final BarcodeSide? barcodeSide;
  final BackStatus backStatus;

  /// Neither photo has a barcode nor text: "unreadable" (BR1.5, BR3.4).
  bool get isUnreadable => barcode == null && !hasLetters(text);

  @override
  String toString() =>
      'MergedReading(${text.length} chars, barcode: ${barcodeSide?.name}, '
      'back: ${backStatus.name})';
}

/// Merges the readings (BR1.2, BR1.3, BR1.5): [front] or [back] is `null`
/// when that reading failed; [backTaken] is false when no back photo was
/// given (BR1.6).
MergedReading mergeLabelReadings({
  required LabelReading? front,
  LabelReading? back,
  bool backTaken = false,
  BarcodeFilter barcodes = const BarcodeFilter(),
}) {
  final frontText = _clamp(front?.text ?? '');
  final backText = _clamp(back?.text ?? '');
  final frontCode = front == null ? null : barcodes.firstValid(front.barcodes);
  final backCode = back == null ? null : barcodes.firstValid(back.barcodes);
  final backReadable =
      back != null && (backCode != null || hasLetters(backText));
  final backStatus = !backTaken
      ? BackStatus.skipped
      : backReadable
      ? BackStatus.taken
      : BackStatus.unreadable;
  final text = _mergeLines(
    frontText,
    backStatus == BackStatus.taken ? backText : '',
  );
  final code = frontCode ?? (backStatus == BackStatus.taken ? backCode : null);
  return MergedReading(
    text: text,
    barcode: code,
    barcodeSide: code == null
        ? null
        : frontCode != null
        ? BarcodeSide.front
        : BarcodeSide.back,
    backStatus: backStatus,
  );
}

String _clamp(String text) => text.length <= MergedReading.maxTextPerPhoto
    ? text
    : text.substring(0, MergedReading.maxTextPerPhoto);

/// Front lines, then the back lines whose comparison key (no capitals, no
/// accents, single spaces) is not already present; cut to 4000.
String _mergeLines(String front, String back) {
  final lines = <String>[];
  final seen = <String>{};
  for (final source in [front, back]) {
    for (final line in source.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      final key = normalizeWineText(trimmed);
      if (!seen.add(key.isEmpty ? trimmed : key)) continue;
      lines.add(trimmed);
    }
  }
  final merged = lines.join('\n');
  return merged.length <= MergedReading.maxText
      ? merged
      : merged.substring(0, MergedReading.maxText);
}
