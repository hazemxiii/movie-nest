import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/theme/theme_notifier.dart';

class NestInput extends ConsumerWidget {
  const NestInput({
    super.key,
    required this.label,
    required this.controller,
    this.onChanged,
  });
  final String label;
  final TextEditingController controller;
  final Function(String)? onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider).value!;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(99),
      borderSide: BorderSide(color: theme.borderC),
    );
    final borderF = OutlineInputBorder(
      borderRadius: BorderRadius.circular(99),
      borderSide: BorderSide(color: theme.mainC),
    );
    return TextField(
      controller: controller,
      style: theme.normal,
      cursorColor: theme.textC,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: theme.sec,
        border: border,
        enabledBorder: border,
        focusedBorder: borderF,
        fillColor: theme.inputBackC,
        filled: true,
      ),
    );
  }
}
