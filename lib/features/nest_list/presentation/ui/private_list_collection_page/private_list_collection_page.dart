import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/theme/theme_notifier.dart';
import 'package:movie_nest/core/widgets/nest_error_widget.dart';
import 'package:movie_nest/features/nest_list/presentation/viewmodels/private_nest_list_collection_viewmodel.dart';

class PrivateListCollectionPage extends ConsumerWidget {
  const PrivateListCollectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider).value!;
    final nestListsCollectionState = ref.watch(
      privateNestListCollectionViewmodelProvider,
    );
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('My Lists', style: theme.largeBoldMain),
          Text(
            'Group titles by mood, project, or watch order. Set one as default to speed up quick-adds.',
            style: theme.sec,
          ),
          const SizedBox(height: 16),
          nestListsCollectionState.when(
            data: (data) {
              if (data.data == null || data.error != null) {
                return NestErrorWidget(
                  title: 'Error',
                  message: data.error ?? 'Unknown error',
                  onTap: () {
                    // TODO try again
                    // TODO error widget everywhere
                  },
                );
              }
              return Column(
                children: data.data!
                    .map(
                      (list) => Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: theme.borderC),
                          ),
                        ),
                        child: Text(list.name, style: theme.bold),
                      ),
                    )
                    .toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => NestErrorWidget(
              title: 'Error',
              message: error.toString(),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
