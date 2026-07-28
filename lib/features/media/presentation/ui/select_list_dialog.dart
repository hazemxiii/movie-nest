import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/theme/theme_notifier.dart';
import 'package:movie_nest/core/widgets/nest_error_widget.dart';
import 'package:movie_nest/features/nest_list/presentation/viewmodels/private_nest_list_collection_viewmodel.dart';

class SelectListDialog extends ConsumerWidget {
  const SelectListDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider).value!;
    final listsState = ref.watch(privateNestListCollectionViewmodelProvider);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Select List'),
      titleTextStyle: theme.bigBold,
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
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: data.data!.map((l) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context, l.id);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(l.name, style: theme.normal),
                    ),
                  );
                }).toList(),
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
