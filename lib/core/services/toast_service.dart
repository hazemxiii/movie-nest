import 'package:flutter/material.dart';
import 'package:movie_nest/core/theme/nest_theme.dart';
import 'package:toastification/toastification.dart';

class ToastService {
  static void error(
    BuildContext context,
    NestTheme theme, {
    required String message,
    required String title,
  }) {
    Toastification().show(
      context: context,
      title: Text(title),
      backgroundColor: theme.secBackC,
      borderSide: BorderSide(color: theme.borderC),
      foregroundColor: theme.textC,
      alignment: Alignment.bottomRight,
      autoCloseDuration: const Duration(milliseconds: 3000),
      showProgressBar: true,
      icon: const Icon(Icons.close),
      description: Text(message),
      type: ToastificationType.error,
      style: ToastificationStyle.flat,
    );
  }
}
