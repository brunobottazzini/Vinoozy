import '../app/device_info.dart';

/// The body of the feedback email (tester-feedback FR6.1): empty lines on
/// top for the person's message, then, under [techHeader] (translated, e.g.
/// "Technical data (please keep)"), the app version, the phone model, the
/// Android version and the language of the app. The person sees and edits
/// all of it before sending (FR6.2); nothing leaves the phone otherwise.
///
/// [device] is null when the phone did not answer: those lines are left out
/// instead of showing a guess.
String buildFeedbackBody({
  required String techHeader,
  required String appVersion,
  required DeviceInfo? device,
  required String languageTag,
}) {
  final lines = <String>[
    '',
    '',
    '',
    '—',
    techHeader,
    'Vinoozy $appVersion',
    if (device != null) ...[device.displayModel, 'Android ${device.release}'],
    languageTag,
  ];
  return lines.join('\n');
}
