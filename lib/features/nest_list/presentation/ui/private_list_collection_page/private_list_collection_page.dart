import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:movie_nest/core/services/nest_platform.dart';
import 'package:movie_nest/core/theme/theme_notifier.dart';
import 'package:movie_nest/core/widgets/nest_error_widget.dart';
import 'package:movie_nest/core/widgets/nest_refresh_button.dart';
import 'package:movie_nest/features/nest_list/presentation/viewmodels/private_nest_list_collection_viewmodel.dart';

class PrivateListCollectionPage extends ConsumerWidget {
  const PrivateListCollectionPage({super.key});

  void refresh(WidgetRef ref) {
    ref.invalidate(privateNestListCollectionViewmodelProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider).value!;
    final nestListsCollectionState = ref.watch(
      privateNestListCollectionViewmodelProvider,
    );
    return RefreshIndicator(
      backgroundColor: theme.secBackC,
      color: theme.mainC,
      onRefresh: () async {
        refresh(ref);
      },
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('My Lists', style: theme.largeBoldMain),
                if (!NestPlatform.isMobile)
                  nestListsCollectionState.when(
                    skipLoadingOnRefresh: false,
                    data: (data) {
                      return NestRefreshButton(
                        onRefresh: () {
                          refresh(ref);
                        },
                        isRefreshing: data.isLoading,
                      );
                    },
                    error: (Object error, StackTrace stackTrace) {
                      return NestRefreshButton(
                        onRefresh: () {
                          refresh(ref);
                        },
                        isRefreshing: false,
                      );
                    },
                    loading: () {
                      return NestRefreshButton(
                        isRefreshing: true,
                        onRefresh: () {},
                      );
                    },
                  ),
              ],
            ),
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
                      refresh(ref);
                    },
                  );
                }
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ...data.data!.map(
                      (list) => GestureDetector(
                        onTap: () {
                          context.push('/lists/${list.id}');
                        },
                        child: Container(
                          padding: const EdgeInsets.all(26),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: theme.mainC.withValues(alpha: 0.03),
                            border: Border.all(color: theme.borderC),
                          ),
                          child: Row(
                            spacing: 5,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: theme.mainC.withValues(alpha: 0.2),
                                ),
                                child: Text(
                                  list.name[0],
                                  style: theme.bigMainBold,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (list.date != null)
                                    Text(
                                      "Created at ${DateFormat('dd-MMM-yyyy').format(list.date!)}",
                                      style: theme.secSmall,
                                    ),
                                  Text(list.name, style: theme.bigBold),
                                ],
                              ),
                              Icon(
                                Icons.play_arrow_outlined,
                                color: theme.mainC,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (error, stack) => NestErrorWidget(
                title: 'Error',
                message: error.toString(),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
