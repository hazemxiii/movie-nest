import 'package:flutter/material.dart';

class NestLogger {
  static void log(String message) {
    debugPrint('[NEST] $message\n');
  }

  static void logError(dynamic object, {String? code}) {
    debugPrint(
      '[NEST ERROR] ${code != null ? '$code: ' : ''}${object.toString()}\n',
    );
  }
}
