import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/theme/theme_notifier.dart';
import 'package:movie_nest/core/widgets/nest_error_widget.dart';
import 'package:movie_nest/features/nest_list/presentation/viewmodels/private_nest_list_collection_viewmodel.dart';

class SelectListDialog extends ConsumerWidget {
  const SelectListDialog({super.key, this.excludedLists = const []});
  final List<String> excludedLists;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider).value!;
    final listsState = ref.watch(privateNestListCollectionViewmodelProvider);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('SELECT LIST', style: theme.bigBold),
      backgroundColor: theme.secBackC,
      content: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: SingleChildScrollView(
          child: listsState.when(
            data: (data) {
              if (data.data == null || data.error != null) {
                return NestErrorWidget(
                  message: data.error ?? 'Couldn\'t load lists',
                  onTap: () {},
                );
              }
              final filteredLists = data.data!
                  .where((l) => !excludedLists.contains(l.id))
                  .toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...filteredLists.asMap().entries.map((entry) {
                    final l = entry.value;
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(
                          context,
                          SelectListModel(id: l.id, name: l.name),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: theme.borderC,
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(child: Text(l.name, style: theme.normal)),
                          ],
                        ),
                      ),
                    );
                  }),
                  // GestureDetector(
                  //   onTap: () async {
                  //     final result = await showDialog<NestListDto>(
                  //       context: context,
                  //       builder: (context) => const AddNestListDialog(),
                  //     );
                  //     if (result != null && context.mounted) {
                  //       Navigator.pop(
                  //         context,
                  //         SelectListModel(id: '', name: result.name ?? ''),
                  //       );
                  //     }
                  //   },
                  //   child: Container(
                  //     padding: const EdgeInsets.symmetric(
                  //       vertical: 12,
                  //       horizontal: 16,
                  //     ),
                  //     child: Row(
                  //       children: [
                  //         Icon(Icons.add, color: theme.mainC, size: 20),
                  //         const SizedBox(width: 8),
                  //         Text('Create new list', style: theme.main),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                ],
              );
            },
            error: (Object error, StackTrace stackTrace) {
              return NestErrorWidget(
                message: 'Couldn\'t load lists',
                onTap: () {},
              );
            },
            loading: () {
              return Center(
                child: CircularProgressIndicator(color: theme.mainC),
              );
            },
          ),
        ),
      ),
    );
  }
}

class SelectListModel {
  SelectListModel({required this.id, required this.name});
  final String id;
  final String name;
}
