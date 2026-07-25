import 'package:flutter/material.dart';

class NestLogger {
  static void log(String message) {
    debugPrint('[NEST] $message\n');
  }

  static void logError(String message, {String? code}) {
    debugPrint('[NEST ERROR] ${code != null ? '$code: ' : ''}$message\n');
  }
}
