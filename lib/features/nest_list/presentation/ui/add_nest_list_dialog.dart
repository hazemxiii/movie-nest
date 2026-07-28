import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/theme/theme_notifier.dart';
import 'package:movie_nest/core/widgets/nest_button.dart';
import 'package:movie_nest/core/widgets/nest_input.dart';
import 'package:movie_nest/features/nest_list/data/models/nest_list.dart';
import 'package:movie_nest/features/nest_list/data/models/nest_list_dto.dart';

class AddNestListDialog extends ConsumerStatefulWidget {
  const AddNestListDialog({super.key, required this.onCreated, this.nestList});
  final Future<void> Function(NestListDto) onCreated;
  final NestList? nestList;

  @override
  ConsumerState<AddNestListDialog> createState() => _AddNestListDialogState();
}

class _AddNestListDialogState extends ConsumerState<AddNestListDialog> {
  late final TextEditingController _nameController;

  bool get _isEdit => widget.nestList != null;
  late final NestListDto dto;
  String? _error;

  @override
  void initState() {
    super.initState();
    dto = NestListDto(fieldsVersion: widget.nestList?.fieldsVersion);
    _nameController = TextEditingController(text: widget.nestList?.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider).value!;
    return AlertDialog(
      backgroundColor: theme.secBackC,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.borderC),
      ),
      title: Text(
        _isEdit ? 'Edit Nest List' : 'Add Nest List',
        style: theme.bigBold,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Group titles you want to track together.', style: theme.sec),
          const SizedBox(height: 16),
          NestInput(
            label: 'List Name',
            controller: _nameController,
            onChanged: (value) {
              dto.name = value;
            },
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: theme.error),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel', style: theme.sec),
        ),
        NestButton(
          backC: theme.mainC,
          textC: theme.backC,
          onTap: () async {
            setState(() {
              _error = dto.validate(_isEdit);
            });
            if (_error == null) {
              await widget.onCreated(dto);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            }
          },
          text: _isEdit ? 'Update List' : 'Create List',
        ),
      ],
    );
  }
}
