import 'package:movie_nest/core/exceptions/nest_exception.dart';

class NestInternetException implements NestException {
  NestInternetException(this.message);

  @override
  final String message;

  @override
  String toString() => message;
}
