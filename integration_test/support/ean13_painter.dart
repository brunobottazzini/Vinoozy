// Test-only EAN-13 encoder and painter for the label end-to-end test
// (u6-label-recognition cicd-pipeline.md §1): the barcode image is drawn on
// the emulator at run time, never stored in the repository.
import 'dart:ui';

const _leftOdd = [
  '0001101', '0011001', '0010011', '0111101', '0100011', //
  '0110001', '0101111', '0111011', '0110111', '0001011',
];
const _leftEven = [
  '0100111', '0110011', '0011011', '0100001', '0011101', //
  '0111001', '0000101', '0010001', '0001001', '0010111',
];
const _right = [
  '1110010', '1100110', '1101100', '1000010', '1011100', //
  '1001110', '1010000', '1000100', '1001000', '1110100',
];

/// Odd (L) / even (G) patterns of the left half, chosen by the first digit.
const _parity = [
  'LLLLLL', 'LLGLGG', 'LLGGLG', 'LLGGGL', 'LGLLGG', //
  'LGGLLG', 'LGGGLL', 'LGLGLG', 'LGLGGL', 'LGGLGL',
];

/// The 95 modules of [code] (13 digits, right check digit): '1' is a bar.
String ean13Modules(String code) {
  if (!RegExp(r'^\d{13}$').hasMatch(code)) {
    throw ArgumentError('an EAN-13 has 13 digits');
  }
  final digits = [for (final unit in code.codeUnits) unit - 0x30];
  final parity = _parity[digits.first];
  final buffer = StringBuffer('101');
  for (var i = 0; i < 6; i++) {
    final digit = digits[i + 1];
    buffer.write(parity[i] == 'L' ? _leftOdd[digit] : _leftEven[digit]);
  }
  buffer.write('01010');
  for (var i = 7; i < 13; i++) {
    buffer.write(_right[digits[i]]);
  }
  buffer.write('101');
  return buffer.toString();
}

/// Paints [code] in black on [canvas], from [origin], [module] pixels per
/// module and [height] pixels high. The caller leaves a white quiet zone.
void paintEan13(
  Canvas canvas,
  String code, {
  required Offset origin,
  double module = 8,
  double height = 400,
}) {
  final paint = Paint()..color = const Color(0xFF000000);
  final modules = ean13Modules(code);
  for (var i = 0; i < modules.length; i++) {
    if (modules[i] != '1') continue;
    canvas.drawRect(
      Rect.fromLTWH(origin.dx + i * module, origin.dy, module, height),
      paint,
    );
  }
}
