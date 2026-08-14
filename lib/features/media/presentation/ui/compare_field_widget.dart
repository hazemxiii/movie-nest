import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/theme/nest_theme.dart';
import 'package:movie_nest/core/theme/theme_notifier.dart';
import 'package:movie_nest/features/media/data/models/dtos/media_dto.dart';

// class CompareFieldWidget extends StatefulWidget {
//   const CompareFieldWidget({
//     super.key,
//     required this.originalField,
//     required this.serverField,
//     required this.dtoField,
//     required this.name,
//     required this.setField,
//     this.fieldToString,
//     required this.isDifferent,
//   });

//   final dynamic originalField;
//   final dynamic serverField;
//   final dynamic dtoField;
//   final String name;
//   final String Function(dynamic field)? fieldToString;
//   final Function(dynamic field) setField;
//   final bool isDifferent;

//   @override
//   State<CompareFieldWidget> createState() => _CompareFieldWidgetState();
// }

class CompareFieldWidget extends ConsumerWidget {
  const CompareFieldWidget({
    super.key,
    required this.originalField,
    required this.serverField,
    required this.dtoField,
    required this.name,
    required this.setField,
    this.fieldToString,
    required this.isDifferent,
  });

  final dynamic originalField;
  final dynamic serverField;
  final dynamic dtoField;
  final String name;
  final String Function(dynamic field)? fieldToString;
  final Function(dynamic field) setField;
  final bool isDifferent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isDifferent) {
      return const SizedBox.shrink();
    }
    late final bool approved;
    if (dtoField is NullablePatchField) {
      approved = dtoField.value == serverField && dtoField.isSet;
    } else {
      approved = dtoField == serverField;
    }
    final theme = ref.watch(themeProvider).value!;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: approved
            ? theme.mainC.withValues(alpha: 0.05)
            : Colors.transparent,
        border: Border(bottom: BorderSide(color: theme.borderC)),
      ),
      child: Column(
        spacing: 5,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,

        children: [
          Text(name.toUpperCase(), style: theme.secSmallBold),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              _fieldButton(
                approved ? theme.secBackC : theme.mainC.withValues(alpha: 0.05),
                () {
                  setField(originalField);
                },
                true,
                theme,
              ),
              _fieldButton(
                !approved
                    ? theme.secBackC
                    : theme.mainC.withValues(alpha: 0.05),
                () {
                  setField(serverField);
                },
                false,
                theme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fieldButton(
    Color color,
    VoidCallback onTap,
    bool isCurrent,
    NestTheme theme,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            border: Border.all(color: theme.borderC),
          ),
          child: Column(
            spacing: 5,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isCurrent ? 'Current' : 'Incoming',
                style: theme.secSmallBold,
              ),
              Text(
                fieldToString?.call(isCurrent ? originalField : serverField) ??
                    (isCurrent
                        ? originalField.toString()
                        : serverField.toString()),
                style: !isCurrent ? theme.mainSmallBold : theme.secSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
