import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/services/toast_service.dart';
import 'package:movie_nest/core/theme/theme_notifier.dart';

class NestInput extends ConsumerWidget {
  const NestInput({
    super.key,
    required this.label,
    required this.controller,
    this.onChanged,
    this.isTitle = false,
    this.keyboardType,
    this.formatters = const [],
    this.isNumber = false,
    this.min,
    this.max,
    this.minLines,
    this.maxLines = 1,
    this.radius = 99,
    this.showNumberButtons = false,
  });
  final String label;
  final bool isTitle;
  final TextEditingController controller;
  final Function(String)? onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter> formatters;
  final bool isNumber;
  final double? min;
  final double? max;
  final int? minLines;
  final int? maxLines;
  final double radius;
  final bool showNumberButtons;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider).value!;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: theme.borderC),
    );
    final borderF = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: theme.mainC),
    );
    final textField = TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: [
        if (isNumber)
          TextInputFormatter.withFunction((old, v) {
            if (v.text.isEmpty) {
              return TextEditingValue(text: '0', selection: v.selection);
            }
            final parsed = double.tryParse(v.text);
            if (parsed == null) {
              return old;
            }
            if (min != null && max != null) {
              if (parsed < min! || parsed > max!) {
                ToastService.error(
                  context,
                  theme,
                  message: '$label must be between ${min!} and ${max!}',
                  title: 'Invalid $label',
                );
                return old;
              }
            }
            if (parsed % 1 == 0) {
              return TextEditingValue(
                text: parsed.toInt().toString(),
                selection: v.selection,
              );
            }
            return v;
          }),
        ...formatters,
      ],
      style: theme.normal,
      cursorColor: theme.textC,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: isTitle ? null : label,
        labelStyle: theme.sec,
        border: border,
        enabledBorder: border,
        focusedBorder: borderF,
        fillColor: theme.inputBackC,
        filled: true,
      ),
      minLines: minLines,
      maxLines: maxLines,
    );

    final child = showNumberButtons && isNumber
        ? Row(
            children: [
              IconButton(
                icon: CircleAvatar(
                  backgroundColor: theme.inputBackC,
                  radius: 18,
                  child: Icon(Icons.remove, color: theme.textC),
                ),
                onPressed: () {
                  final current = double.tryParse(controller.text) ?? 0;
                  final newValue = (current - 1).clamp(
                    min ?? 0,
                    max ?? double.infinity,
                  );
                  controller.text = newValue.toString();
                  onChanged?.call(newValue.toString());
                },
              ),
              Expanded(child: textField),
              IconButton(
                color: theme.textC,
                icon: CircleAvatar(
                  backgroundColor: theme.inputBackC,
                  radius: 18,
                  child: Icon(Icons.add, color: theme.textC),
                ),
                onPressed: () {
                  final current = double.tryParse(controller.text) ?? 0;
                  final newValue = (current + 1).clamp(
                    min ?? 0,
                    max ?? double.infinity,
                  );
                  controller.text = newValue.toString();
                  onChanged?.call(newValue.toString());
                },
              ),
            ],
          )
        : textField;

    if (isTitle) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: theme.secBold),
          const SizedBox(height: 5),
          child,
        ],
      );
    }

    return child;
  }
}

/*
if (showNumberButtons && isNumber)
            Row(
              children: [
                IconButton(
                  icon: CircleAvatar(
                    backgroundColor: theme.inputBackC,
                    radius: 18,
                    child: Icon(Icons.remove, color: theme.textC),
                  ),
                  onPressed: () {
                    final current = double.tryParse(controller.text) ?? 0;
                    final newValue = (current - 1).clamp(
                      min ?? 0,
                      max ?? double.infinity,
                    );
                    controller.text = newValue.toString();
                    onChanged?.call(newValue.toString());
                  },
                ),
                Expanded(child: textField),
                IconButton(
                  color: theme.textC,
                  icon: CircleAvatar(
                    backgroundColor: theme.inputBackC,
                    radius: 18,
                    child: Icon(Icons.add, color: theme.textC),
                  ),
                  onPressed: () {
                    final current = double.tryParse(controller.text) ?? 0;
                    final newValue = (current + 1).clamp(
                      min ?? 0,
                      max ?? double.infinity,
                    );
                    controller.text = newValue.toString();
                    onChanged?.call(newValue.toString());
                  },
                ),
              ],
            )
*/
