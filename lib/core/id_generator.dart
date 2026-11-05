import 'dart:math';

/// Generates document ids on the phone (BR2.4: the wine id is created once,
/// when the add-wine form opens, so a double tap cannot create two wines).
abstract interface class IdGenerator {
  String newId();
}

/// Firestore-style ids: 20 characters from a 62-symbol alphabet, drawn from a
/// cryptographically secure source (about 119 bits of entropy).
class RandomIdGenerator implements IdGenerator {
  RandomIdGenerator({Random? random}) : _random = random ?? Random.secure();

  static const int idLength = 20;
  static const String _alphabet =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';

  final Random _random;

  @override
  String newId() {
    final buffer = StringBuffer();
    for (var i = 0; i < idLength; i++) {
      buffer.write(_alphabet[_random.nextInt(_alphabet.length)]);
    }
    return buffer.toString();
  }
}
