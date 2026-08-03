import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_nest/core/services/toast_service.dart';
import 'package:movie_nest/core/theme/theme_notifier.dart';
import 'package:movie_nest/core/widgets/nest_button.dart';
import 'package:movie_nest/core/widgets/nest_error_widget.dart';
import 'package:movie_nest/features/nest_list/presentation/ui/add_nest_list_dialog.dart';
import 'package:movie_nest/features/nest_list/presentation/ui/list_page/confirm_list_delete_dialog.dart';
import 'package:movie_nest/features/nest_list/presentation/ui/list_page/list_details_section_shimmer.dart';
import 'package:movie_nest/features/nest_list/presentation/viewmodels/private_nest_list_collection_viewmodel.dart';
import 'package:movie_nest/features/nest_list/presentation/viewmodels/private_nest_list_viewmodel.dart';

class ListDetailsSection extends ConsumerWidget {
  const ListDetailsSection({super.key, required this.listId});
  final String listId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider).value!;
    final listState = ref.watch(privateNestListViewmodelProvider(listId));
    final listController = ref.read(
      privateNestListViewmodelProvider(listId).notifier,
    );
    return listState.when(
      data: (data) {
        if (data.data == null || data.error != null) {
          return NestErrorWidget(
            message: data.error ?? 'Unexpected Error',
            onTap: () {
              refreshList(ref);
            },
          );
        }
        final list = data.data!;
        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    list.name,
                    style: theme.largeBold,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text('${list.media.length} items', style: theme.sec),
                ],
              ),
            ),
            NestButton(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AddNestListDialog(
                      onCreated: (list) async {
                        try {
                          await listController.updateList(list);
                        } catch (e) {
                          if (!context.mounted) return;
                          ToastService.error(
                            context,
                            theme,
                            message: e.toString(),
                            title: 'Error updating list',
                          );
                        }
                      },
                      nestList: list,
                    );
                  },
                );
              },
              text: 'Edit',
              backC: theme.secBackC,
              textC: theme.textC,
              borderC: theme.borderC,
            ),
            const SizedBox(width: 6),
            NestButton(
              onTap: () async {
                try {
                  final result =
                      await showDialog<ConfirmListDeleteDialogResult>(
                        context: context,
                        builder: (context) {
                          return ConfirmListDeleteDialog(list: list);
                        },
                      );
                  if (result?.isConfirmed ?? false) {
                    await ref
                        .read(
                          privateNestListCollectionViewmodelProvider.notifier,
                        )
                        .deleteList(
                          list.id,
                          moveToListId: result!.moveToListId,
                        );
                    if (result.moveToListId != null) {
                      ref.invalidate(
                        privateNestListViewmodelProvider(result.moveToListId!),
                      );
                    }
                    if (context.mounted) {
                      context.pop();
                    }
                  }
                } catch (e) {
                  if (!context.mounted) return;
                  ToastService.error(
                    context,
                    theme,
                    message: e.toString(),
                    title: 'Error deleting list',
                  );
                }
              },
              text: 'Delete',
              backC: theme.errorC.withAlpha(20),
              textC: theme.errorC,
              borderC: theme.errorC,
            ),
          ],
        );
      },
      error: (error, stack) {
        return NestErrorWidget(
          message: error.toString(),
          onTap: () {
            refreshList(ref);
          },
        );
      },
      loading: () {
        return const ListDetailsSectionShimmer();
      },
    );
  }

  void refreshList(WidgetRef ref) {
    ref.invalidate(privateNestListViewmodelProvider(listId));
  }
}
