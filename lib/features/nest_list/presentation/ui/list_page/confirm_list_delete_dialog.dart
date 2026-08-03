import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/theme/theme_notifier.dart';
import 'package:movie_nest/features/nest_list/data/models/nest_list.dart';
import 'package:movie_nest/features/nest_list/presentation/viewmodels/private_nest_list_collection_viewmodel.dart';

class ConfirmListDeleteDialogResult {
  ConfirmListDeleteDialogResult({required this.isConfirmed, this.moveToListId});
  final bool isConfirmed;
  final String? moveToListId;
}

class ConfirmListDeleteDialog extends ConsumerStatefulWidget {
  const ConfirmListDeleteDialog({super.key, required this.list});
  final NestList list;

  @override
  ConsumerState<ConfirmListDeleteDialog> createState() =>
      _ConfirmListDeleteDialogState();
}

class _ConfirmListDeleteDialogState
    extends ConsumerState<ConfirmListDeleteDialog> {
  String? _moveToListId;
  bool get _isDelete => _moveToListId == null;
  bool _isLoading = true;
  bool _isMoveDisabled = true;
  List<NestList> _lists = [];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final lists = await ref.read(
        privateNestListCollectionViewmodelProvider.future,
      );
      _lists = [...lists.data ?? []];
      _lists.removeWhere((list) => list.id == widget.list.id);
      _isMoveDisabled = _lists.isEmpty;
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider).value!;
    return AlertDialog(
      backgroundColor: theme.backC,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Delete List', style: theme.bigBold),
      content: Container(
        constraints: BoxConstraints(maxHeight: _isDelete ? 180 : 300),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            DeleteListOption(
              isDelete: true,
              isSelected: _isDelete,
              lists: const [],
              onTap: () {
                setState(() {
                  _moveToListId = null;
                });
              },
              onListTap: (list) {},
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Opacity(
                opacity: _isMoveDisabled ? 0.5 : 1.0,
                child: DeleteListOption(
                  lists: _isLoading ? null : _lists,
                  isDelete: false,
                  isSelected: !_isDelete,
                  selectedListId: _moveToListId,
                  onTap: _isMoveDisabled
                      ? () {}
                      : () {
                          setState(() {
                            _moveToListId = _lists.first.id;
                          });
                        },
                  onListTap: (list) {
                    setState(() {
                      _moveToListId = list.id;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        MaterialButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: BorderSide(color: theme.borderC),
          ),
          color: theme.backC,
          textColor: theme.textC,
          onPressed: () {
            Navigator.of(
              context,
            ).pop(ConfirmListDeleteDialogResult(isConfirmed: false));
          },
          child: const Text('Cancel'),
        ),
        MaterialButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: BorderSide(color: theme.borderC),
          ),
          color: _isDelete ? theme.errorC : theme.mainC,
          textColor: theme.textC,
          onPressed: () {
            Navigator.of(context).pop(
              ConfirmListDeleteDialogResult(
                isConfirmed: true,
                moveToListId: _moveToListId,
              ),
            );
          },
          child: Text(_isDelete ? 'Delete' : 'Move & Delete'),
        ),
      ],
    );
  }
}

class DeleteListOption extends ConsumerWidget {
  const DeleteListOption({
    super.key,
    required this._isDelete,
    required this._isSelected,
    required this._lists,
    required this.onTap,
    required this.onListTap,
    this._selectedListId,
  });
  final bool _isDelete;
  final bool _isSelected;
  final List<NestList>? _lists;
  final VoidCallback onTap;
  final Function(NestList) onListTap;
  final String? _selectedListId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider).value!;
    final title = _isDelete ? 'Delete list and its content' : 'Move content to';
    final selectionColor = _isDelete ? theme.errorC : theme.mainC;
    final subtitle = _isDelete
        ? 'This action cannot be undone'
        : 'Select a list to move the content to';
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: _isSelected
              ? selectionColor.withValues(alpha: 0.1)
              : theme.secBackC.withValues(alpha: 0.1),
          border: Border.all(
            color: _isSelected ? selectionColor : theme.borderC,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.bold),
              Text(subtitle, style: theme.sec),
              if (_lists != null && _isSelected) ...[
                const SizedBox(height: 8),
                ..._lists!.map(
                  (list) => GestureDetector(
                    onTap: () {
                      onTap();
                      onListTap(list);
                    },
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedListId == list.id
                              ? theme.mainC
                              : theme.borderC,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: theme.secBackC.withValues(alpha: 0.1),
                      ),
                      child: Text(list.name, style: theme.sec),
                    ),
                  ),
                ),
              ] else if (_isSelected) ...[
                const SizedBox(height: 8),
                Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: theme.mainC),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
