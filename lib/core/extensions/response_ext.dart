import 'package:http/http.dart';

extension ResponseExt on Response {
  bool get ok => statusCode >= 200 && statusCode < 300;
}
