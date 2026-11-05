import 'package:cloud_firestore/cloud_firestore.dart';

/// Converts document data to plain Dart values for the domain layer: every
/// `Timestamp` becomes a [DateTime] (UTC), so the domain stays free of SDK
/// types. Nested maps and lists are converted too.
Map<String, Object?> decodeDocument(Map<String, dynamic>? data) => {
  for (final entry in (data ?? const <String, dynamic>{}).entries)
    entry.key: _decode(entry.value),
};

Object? _decode(Object? value) => switch (value) {
  final Timestamp timestamp => timestamp.toDate().toUtc(),
  final Map<String, dynamic> map => decodeDocument(map),
  final List<dynamic> list => [for (final item in list) _decode(item)],
  _ => value,
};

/// Path of the wines collection of a cellar (C3).
String winesPath(String cellarId) => 'cellars/$cellarId/wines';

/// Path of one wine document (C3).
String winePath(String cellarId, String wineId) =>
    '${winesPath(cellarId)}/$wineId';

/// Path of a cellar document (C3).
String cellarPath(String cellarId) => 'cellars/$cellarId';

/// Path of a user profile document (C3).
String userPath(String uid) => 'users/$uid';
