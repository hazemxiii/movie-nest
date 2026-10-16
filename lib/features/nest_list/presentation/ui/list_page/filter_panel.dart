import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/theme/nest_theme.dart';
import 'package:movie_nest/core/theme/theme_notifier.dart';
import 'package:movie_nest/features/media/data/models/media.dart';
import 'package:movie_nest/features/nest_list/presentation/ui/list_page/filter_notifier.dart';

class FilterPanel extends ConsumerStatefulWidget {
  const FilterPanel({super.key, required this.allMedia});

  final List<Media> allMedia;

  @override
  ConsumerState<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends ConsumerState<FilterPanel> {
  final TextEditingController _tagSearchController = TextEditingController();
  String _tagSearchQuery = '';

  @override
  void dispose() {
    _tagSearchController.dispose();
    super.dispose();
  }

  Set<String> _getAllTags() {
    final tags = <String>{};
    for (final media in widget.allMedia) {
      if (media.genres.isNotEmpty) {
        tags.addAll(media.genres);
      }
    }
    return tags;
  }

  List<String> _getFilteredTags() {
    final allTags = _getAllTags();
    if (_tagSearchQuery.isEmpty) {
      return allTags.toList()..sort();
    }
    return allTags
        .where(
          (tag) => tag.toLowerCase().contains(_tagSearchQuery.toLowerCase()),
        )
        .toList()
      ..sort();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider).value!;
    final filterState = ref.watch(filterNotifierProvider);
    final filterNotifier = ref.read(filterNotifierProvider.notifier);
    final filteredTags = _getFilteredTags();

    return SingleChildScrollView(
      child: Container(
        color: theme.secBackC,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filters', style: theme.bigBold),
                TextButton(
                  onPressed: filterNotifier.clearFilters,
                  child: Text(
                    'Clear All',
                    style: theme.secSmall.copyWith(color: theme.mainC),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildFilterSection(
              theme,
              'TYPE',
              Row(
                children: [
                  _buildFilterChip(
                    theme,
                    'All',
                    filterState.typeFilter == null,
                    () {
                      filterNotifier.setTypeFilter(null);
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    theme,
                    'TV',
                    filterState.typeFilter == 'tv',
                    () {
                      filterNotifier.setTypeFilter('tv');
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    theme,
                    'Movie',
                    filterState.typeFilter == 'movie',
                    () {
                      filterNotifier.setTypeFilter('movie');
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // _buildFilterSection(
            //   theme,
            //   'STATUS',
            //   Row(
            //     children: [
            //       _buildFilterChip(
            //         theme,
            //         'All',
            //         filterState.statusFilter == null,
            //         () {
            //           filterNotifier.setStatusFilter(null);
            //         },
            //       ),
            //       const SizedBox(width: 8),
            //       _buildFilterChip(
            //         theme,
            //         'Finished',
            //         filterState.statusFilter == 'ended',
            //         () {
            //           filterNotifier.setStatusFilter('ended');
            //         },
            //       ),
            //       const SizedBox(width: 8),
            //       _buildFilterChip(
            //         theme,
            //         'Coming',
            //         filterState.statusFilter == 'returning',
            //         () {
            //           filterNotifier.setStatusFilter('returning');
            //         },
            //       ),
            //     ],
            //   ),
            // ),
            const SizedBox(height: 16),

            _buildFilterSection(
              theme,
              'EPISODES',
              Row(
                children: [
                  Expanded(
                    child: _buildNumberInput(
                      theme,
                      'Min',
                      filterState.episodeCountMin,
                      filterNotifier.setEpisodeCountMin,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildNumberInput(
                      theme,
                      'Max',
                      filterState.episodeCountMax,
                      filterNotifier.setEpisodeCountMax,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _buildFilterSection(
              theme,
              'TAGS',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _tagSearchController,
                    style: theme.secSmall,
                    decoration: InputDecoration(
                      hintText: 'Search tags...',
                      hintStyle: theme.secSmall.copyWith(
                        color: theme.mainC.withValues(alpha: 0.5),
                      ),
                      filled: true,
                      fillColor: theme.backC,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onChanged: (value) {
                      _tagSearchQuery = value;
                    },
                  ),
                  const SizedBox(height: 12),
                  if (filteredTags.isEmpty)
                    Text(
                      'No tags found',
                      style: theme.secSmall.copyWith(
                        color: theme.mainC.withValues(alpha: 0.5),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: filteredTags.map((tag) {
                        final isSelected = filterState.selectedTags.contains(
                          tag,
                        );
                        return FilterChip(
                          label: Text(tag, style: theme.small),
                          selected: isSelected,
                          onSelected: (selected) {
                            filterNotifier.toggleTag(tag);
                          },
                          selectedColor: theme.mainC,
                          checkmarkColor: theme.textC,
                          backgroundColor: theme.backC,
                          side: BorderSide(
                            color: isSelected
                                ? theme.mainC
                                : theme.mainC.withValues(alpha: 0.3),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(NestTheme theme, String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.secSmall.copyWith(
            color: theme.mainC.withValues(alpha: 0.7),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        content,
      ],
    );
  }

  Widget _buildFilterChip(
    NestTheme theme,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.mainC : theme.secBackC,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.mainC
                : theme.mainC.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: theme.secSmall.copyWith(
            color: isSelected
                ? theme.secBackC
                : theme.mainC.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildNumberInput(
    NestTheme theme,
    String label,
    int? value,
    Function(int?) onChanged,
  ) {
    final controller = TextEditingController(text: value?.toString() ?? '');
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: theme.secSmall,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: theme.secSmall.copyWith(
          color: theme.mainC.withValues(alpha: 0.7),
        ),
        filled: true,
        fillColor: theme.backC,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onChanged: (text) {
        final parsed = int.tryParse(text);
        onChanged(parsed);
      },
    );
  }
}
