import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/theme/theme_notifier.dart';

class NestDropDownOption {
  const NestDropDownOption({required this.value, required this.label});
  final String value;
  final String label;
}

class NestDropDown extends ConsumerWidget {
  const NestDropDown({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    required this.title,
  });
  final List<NestDropDownOption> options;
  final String selected;
  final Function(String) onChanged;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider).value!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.secBold),
        const SizedBox(height: 5),
        DropdownMenu(
          menuStyle: MenuStyle(
            backgroundColor: WidgetStatePropertyAll(theme.inputBackC),
            maximumSize: const WidgetStatePropertyAll(Size(200, 100)),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),

          textStyle: theme.normal,
          selectOnly: true,
          width: double.infinity,
          decorationBuilder: (context, child) {
            return InputDecoration(
              fillColor: theme.inputBackC,
              filled: true,
              border: OutlineInputBorder(
                borderSide: BorderSide(color: theme.borderC),
                borderRadius: BorderRadius.circular(999),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: theme.borderC),
                borderRadius: BorderRadius.circular(999),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: theme.mainC),
                borderRadius: BorderRadius.circular(999),
              ),
            );
          },
          dropdownMenuEntries: options.map((option) {
            return DropdownMenuEntry<String>(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(theme.inputBackC),
                foregroundColor: WidgetStatePropertyAll(theme.textC),
              ),
              value: option.value,
              label: option.label,
            );
          }).toList(),
          initialSelection: selected,
          onSelected: (value) {
            onChanged(value!);
          },
        ),
      ],
    );
  }
}
