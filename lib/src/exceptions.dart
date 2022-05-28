abstract class SteganographException {}

class SteganographFileException implements SteganographException {
  final String message;
  final StackTrace? stackTrace;

  SteganographFileException(this.message, [this.stackTrace]);

  String get trace => stackTrace.toString();

  @override
  String toString() {
    return message;
  }
}

class SteganographDecodingException implements SteganographException {
  final String message;
  final StackTrace? stackTrace;

  SteganographDecodingException(this.message, [this.stackTrace]);

  String get trace => stackTrace.toString();

  @override
  String toString() {
    return message;
  }
}
