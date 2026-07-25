class NestException implements Exception {
  NestException(this.message);
  final String message;

  @override
  String toString() => message;
}
