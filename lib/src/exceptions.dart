sealed class SteganographException {}

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

class SteganographCloakException implements SteganographException {
  final String message;
  final StackTrace? stackTrace;

  SteganographCloakException(this.message, [this.stackTrace]);

  String get trace => stackTrace.toString();

  @override
  String toString() {
    return message;
  }
}