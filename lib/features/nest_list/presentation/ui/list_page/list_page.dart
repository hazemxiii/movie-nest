import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/theme/theme_notifier.dart';
import 'package:movie_nest/core/widgets/nest_back_button.dart';
import 'package:movie_nest/core/widgets/nest_refresh_button.dart';
import 'package:movie_nest/core/widgets/sort_button.dart';
import 'package:movie_nest/features/media/data/models/media.dart';
import 'package:movie_nest/features/nest_list/presentation/ui/list_page/filter_notifier.dart';
import 'package:movie_nest/features/nest_list/presentation/ui/list_page/filter_panel.dart';
import 'package:movie_nest/features/nest_list/presentation/ui/list_page/list_details_section.dart';
import 'package:movie_nest/features/nest_list/presentation/ui/list_page/private_media_widget.dart';
import 'package:movie_nest/features/nest_list/presentation/viewmodels/private_nest_list_viewmodel.dart';
import 'package:movie_nest/features/nest_user/presentation/viewmodels/user_viewmodel.dart';

enum SortType { dateAdded, name, releaseDate, episodeCount, nextAirDate }

class ListPage extends ConsumerStatefulWidget {
  const ListPage({super.key, required this.listId});
  final String listId;

  @override
  ConsumerState<ListPage> createState() => _ListPageState();
}

class _ListPageState extends ConsumerState<ListPage> {
  SortType _sortType = SortType.name;
  bool _ascending = true;

  List<Media> _filterMedia(List<Media> media, FilterState filterState) {
    var filtered = List<Media>.from(media);

    if (filterState.typeFilter != null) {
      filtered = filtered
          .where((m) => m.type.toLowerCase() == filterState.typeFilter)
          .toList();
    }

    // if (filterState.statusFilter != null) {
    //   filtered = filtered
    //       .where((m) => m.status.toLowerCase() == filterState.statusFilter)
    //       .toList();
    // }

    if (filterState.selectedTags.isNotEmpty) {
      for (final tag in filterState.selectedTags) {
        filtered = filtered.where((m) => m.genres.contains(tag)).toList();
      }
    }

    if (filterState.episodeCountMin != null) {
      filtered = filtered
          .where((m) => (m.episodeCount ?? 0) >= filterState.episodeCountMin!)
          .toList();
    }

    if (filterState.episodeCountMax != null) {
      filtered = filtered
          .where((m) => (m.episodeCount ?? 0) <= filterState.episodeCountMax!)
          .toList();
    }

    return filtered;
  }

  List<Media> _sortMedia(List<Media> media) {
    var sorted = List<Media>.from(media);
    switch (_sortType) {
      case SortType.dateAdded:
        sorted = [...media];
      case SortType.name:
        sorted.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;
      case SortType.releaseDate:
        sorted.sort((a, b) {
          if (a.date == null && b.date == null) return 0;
          if (a.date == null) return 1;
          if (b.date == null) return -1;
          return a.date!.compareTo(b.date!);
        });
        break;
      case SortType.episodeCount:
        sorted.sort((a, b) {
          final aCount = a.episodeCount ?? 0;
          final bCount = b.episodeCount ?? 0;
          return aCount.compareTo(bCount);
        });
        break;
      case SortType.nextAirDate:
        sorted.sort((a, b) {
          if (a.nextAirDate == null && b.nextAirDate == null) return 0;
          if (a.nextAirDate == null) return 1;
          if (b.nextAirDate == null) return -1;
          return a.nextAirDate!.compareTo(b.nextAirDate!);
        });
        break;
    }
    if (!_ascending) {
      sorted = sorted.reversed.toList();
    }
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider).value!;
    final listState = ref.watch(
      privateNestListViewmodelProvider(widget.listId),
    );
    final filterState = ref.watch(filterNotifierProvider);
    final user = ref.watch(userVMPrv).value;
    if (user == null) {
      return const Center(child: Text('Please sign in to view lists'));
    }
    return RefreshIndicator(
      onRefresh: () async {
        refreshList();
      },
      backgroundColor: theme.secBackC,
      color: theme.mainC,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const NestBackButton(),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              filterState.hasActiveFilters
                                  ? Icons.filter_alt
                                  : Icons.filter_list,
                              color: filterState.hasActiveFilters
                                  ? theme.mainC
                                  : theme.mainC.withValues(alpha: 0.7),
                            ),
                            onPressed: () => _showFilterPanel(context),
                          ),
                          const SizedBox(width: 8),
                          SortButton(
                            items: [
                              SortButtonItem(
                                text: 'Date Added',
                                onSort: () {
                                  setState(() {
                                    _sortType = SortType.dateAdded;
                                  });
                                },
                              ),
                              SortButtonItem(
                                text: 'Name',
                                onSort: () {
                                  setState(() {
                                    _sortType = SortType.name;
                                  });
                                },
                              ),
                              SortButtonItem(
                                text: 'Release Date',
                                onSort: () {
                                  setState(() {
                                    _sortType = SortType.releaseDate;
                                  });
                                },
                              ),
                              SortButtonItem(
                                text: 'Episode Count',
                                onSort: () {
                                  setState(() {
                                    _sortType = SortType.episodeCount;
                                  });
                                },
                              ),
                              SortButtonItem(
                                text: 'Next Air Date',
                                onSort: () {
                                  setState(() {
                                    _sortType = SortType.nextAirDate;
                                  });
                                },
                              ),
                            ],
                            ascending: _ascending,
                            onToggleDirection: () {
                              setState(() {
                                _ascending = !_ascending;
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          listState.when(
                            skipLoadingOnRefresh: false,
                            data: (data) => NestRefreshButton(
                              isRefreshing: data.isLoading,
                              onRefresh: refreshList,
                            ),
                            error: (error, stack) => NestRefreshButton(
                              isRefreshing: false,
                              onRefresh: refreshList,
                            ),
                            loading: () =>
                                const NestRefreshButton(isRefreshing: true),
                          ),
                        ],
                      ),
                    ],
                  ),
                  ListDetailsSection(listId: widget.listId),
                ],
              ),
            ),
          ),
          listState.when(
            data: (data) {
              if (data.data == null || data.error != null) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }
              final list = data.data!;
              final filteredMedia = _filterMedia(list.media, filterState);
              final sortedMedia = _sortMedia(filteredMedia);
              return SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 500,
                  mainAxisExtent: 150,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  return PrivateMediaWidget(media: sortedMedia[index]);
                }, childCount: sortedMedia.length),
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

  void refreshList() {
    ref.invalidate(privateNestListViewmodelProvider(widget.listId));
  }

  void _showFilterPanel(BuildContext context) {
    final listState = ref.read(privateNestListViewmodelProvider(widget.listId));
    final List<Media> allMedia = listState.when(
      data: (data) => data.data?.media ?? [],
      loading: () => [],
      error: (_, _) => [],
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: ref.watch(themeProvider).value!.secBackC,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: FilterPanel(allMedia: allMedia),
        ),
      ),
    );
  }
}
