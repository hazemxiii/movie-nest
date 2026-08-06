import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:movie_nest/core/theme/theme_notifier.dart';

class NestDatePicker extends ConsumerStatefulWidget {
  const NestDatePicker({
    super.key,
    required this.onDateSelected,
    this.value,
    this.firstDate,
    this.lastDate,
    required this.label,
  });
  final Function(DateTime) onDateSelected;
  final DateTime? value;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String label;

  @override
  ConsumerState<NestDatePicker> createState() => _NestDatePickerState();
}

class _NestDatePickerState extends ConsumerState<NestDatePicker> {
  DateTime? _value;

  @override
  void initState() {
    _value = widget.value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider).value!;
    return Column(
      spacing: 5,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: theme.secBold),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _value ?? DateTime.now(),
              firstDate: widget.firstDate ?? DateTime(1900),
              lastDate: widget.lastDate ?? DateTime(2100),
            );
            if (date != null) {
              setState(() {
                _value = date;
              });
              widget.onDateSelected(date);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: theme.inputBackC,
              border: Border.all(color: theme.borderC),
              borderRadius: BorderRadius.circular(99),
            ),
            child: _value != null
                ? Text(
                    DateFormat('dd-MM-yyyy').format(_value!),
                    style: theme.normal,
                  )
                : Text('Select Date', style: theme.secBold),
          ),
        ),
      ],
    );
  }
}
