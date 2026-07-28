import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/theme/theme_notifier.dart';
import 'package:movie_nest/core/widgets/nest_back_button.dart';
import 'package:movie_nest/core/widgets/nest_refresh_button.dart';
import 'package:movie_nest/features/nest_list/presentation/ui/list_page/list_details_section.dart';
import 'package:movie_nest/features/nest_list/presentation/ui/list_page/private_media_widget.dart';
import 'package:movie_nest/features/nest_list/presentation/viewmodels/private_nest_list_viewmodel.dart';

class ListPage extends ConsumerWidget {
  const ListPage({super.key, required this.listId});
  final String listId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider).value!;
    final listState = ref.watch(privateNestListViewmodelProvider(listId));
    return RefreshIndicator(
      onRefresh: () async {
        refreshList(ref);
      },
      backgroundColor: theme.secBackC,
      color: theme.mainC,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const NestBackButton(),
                    listState.when(
                      skipLoadingOnRefresh: false,
                      data: (data) => NestRefreshButton(
                        isRefreshing: data.isLoading,
                        onRefresh: () => refreshList(ref),
                      ),
                      error: (error, stack) => NestRefreshButton(
                        isRefreshing: false,
                        onRefresh: () => refreshList(ref),
                      ),
                      loading: () =>
                          const NestRefreshButton(isRefreshing: true),
                    ),
                  ],
                ),
                ListDetailsSection(listId: listId),
              ],
            ),
          ),
          listState.when(
            data: (data) {
              if (data.data == null || data.error != null) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }
              final list = data.data!;
              return SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 300,
                  mainAxisExtent: 150,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  return PrivateMediaWidget(media: list.media[index]);
                }, childCount: list.media.length),
              );
            },
            error: (Object error, StackTrace stackTrace) {
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            },
            loading: () {
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            },
          ),
        ],
      ),
    );
  }

  void refreshList(WidgetRef ref) {
    ref.invalidate(privateNestListViewmodelProvider(listId));
  }
}
