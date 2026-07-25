import 'package:movie_nest/core/exceptions/nest_exception.dart';

class NestSecretException extends NestException {
  NestSecretException(this.objectCode) : super('Unexpected Error');
  final String objectCode;

  @override
  String toString() {
    return 'Error code: $objectCode';
  }
}
