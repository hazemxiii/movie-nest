import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/services/toast_service.dart';
import 'package:movie_nest/core/theme/theme_notifier.dart';
import 'package:movie_nest/core/widgets/nest_button.dart';
import 'package:movie_nest/features/media/data/models/media.dart';
import 'package:movie_nest/features/media/presentation/viewmodels/private_media_viewmodel.dart';

class SeasonsSection extends ConsumerStatefulWidget {
  const SeasonsSection({
    super.key,
    required this.media,
    required this.isPublic,
  });
  final Media media;
  final bool isPublic;

  @override
  ConsumerState<SeasonsSection> createState() => _SeasonsSectionState();
}

class _SeasonsSectionState extends ConsumerState<SeasonsSection> {
  // late Season selectedSeason;
  late int selectedSeasonNumber;

  @override
  void initState() {
    super.initState();
    if (widget.media.seasons.isNotEmpty) {
      // selectedSeason = widget.media.seasons.first;
      selectedSeasonNumber = widget.media.seasons.first.number;
    }
  }

  Timer? _debounce;
  final added = <int>[];
  final removed = <int>[];

  @override
  Widget build(BuildContext context) {
    final isScreenSmall = MediaQuery.of(context).size.width < 600;
    final theme = ref.watch(themeProvider).value!;
    final progress = widget.media.progress;
    if (widget.media.seasons.isEmpty) {
      return const SizedBox.shrink();
    }
    final selectedSeason = widget.media.seasons.firstWhere(
      (season) => season.number == selectedSeasonNumber,
    );
    return Container(
      padding: const EdgeInsets.all(30),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.borderC),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flex(
            spacing: 10,
            direction: isScreenSmall ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: isScreenSmall
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            mainAxisAlignment: isScreenSmall
                ? MainAxisAlignment.start
                : MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Track episodes', style: theme.bigBold),
                  if (!widget.isPublic)
                    RichText(
                      text: TextSpan(
                        text:
                            '${progress.totalWatched} of ${progress.totalEpisodes} watched  ',
                        style: theme.sec,
                        children: [
                          TextSpan(
                            text:
                                '${(progress.progress * 100).toStringAsFixed(0)}%',
                            style: theme.mainBold,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              if (!widget.isPublic)
                SizedBox(
                  width: 200,
                  child: LinearProgressIndicator(
                    borderRadius: BorderRadius.circular(4),
                    value: progress.progress,
                    backgroundColor: theme.borderC,
                    valueColor: AlwaysStoppedAnimation<Color>(theme.mainC),
                    minHeight: 6,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.media.seasons.map((season) {
              return NestButton(
                borderC: selectedSeasonNumber != season.number
                    ? theme.borderC
                    : null,
                onTap: () {
                  setState(() {
                    selectedSeasonNumber = season.number;
                  });
                },
                text: 'Season ${season.number} (${season.episodeCount})',
                backC: selectedSeasonNumber == season.number
                    ? theme.mainC
                    : theme.secBackC,
                textC: selectedSeasonNumber == season.number
                    ? theme.textC
                    : theme.secTextC,
              );
            }).toList(),
          ),
          const SizedBox(height: 5),
          if (!widget.isPublic)
            Text(
              '${selectedSeason.watchedEpisodes.length}/${selectedSeason.episodeCount}',
              style: theme.sec,
            ),
          const SizedBox(height: 16),
          if (!widget.isPublic) ...[
            Wrap(
              spacing: 10,
              runSpacing: 5,
              children: [
                NestButton(
                  onTap: () {
                    for (int i = 0; i < selectedSeason.episodeCount; i++) {
                      final number = i + 1;
                      if (!widget.media.isEpisodeWatched(
                            selectedSeason.number,
                            number,
                          ) &&
                          !added.contains(number)) {
                        added.add(number);
                        removed.remove(number);
                      }
                    }
                    _toggleAll(selectedSeasonNumber, added, removed);
                  },
                  text: 'Mark all as watched',
                ),
                NestButton(
                  onTap: () {
                    for (int i = 0; i < selectedSeason.episodeCount; i++) {
                      final number = i + 1;
                      if (widget.media.isEpisodeWatched(
                            selectedSeason.number,
                            number,
                          ) &&
                          !removed.contains(number)) {
                        removed.add(number);
                        added.remove(number);
                      }
                    }
                    _toggleAll(selectedSeasonNumber, added, removed);
                  },
                  text: 'Mark all as unwatched',
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.innerBorderC),
            ),
            width: double.infinity,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: selectedSeason.episodeCount,
              itemBuilder: (context, index) {
                final initIsWatched = widget.isPublic
                    ? false
                    : widget.media.isEpisodeWatched(
                        selectedSeason.number,
                        index + 1,
                      );
                final isWatched =
                    (initIsWatched || added.contains(index + 1)) &&
                    !removed.contains(index + 1);
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: theme.innerBorderC),
                    ),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _onEpisodeToggle(
                            selectedSeason.number,
                            index + 1,
                            !isWatched,
                          );
                        },
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isWatched ? theme.mainC : theme.secBackC,
                            border: Border.all(color: theme.borderC),
                            shape: BoxShape.circle,
                          ),
                          child: isWatched
                              ? Icon(Icons.check, size: 16, color: theme.textC)
                              : const SizedBox.shrink(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Episode ${index + 1}',
                        style: isWatched ? theme.secStrikeBold : theme.bold,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleAll(
    int seasonNumber,
    List<int> added,
    List<int> removed,
  ) async {
    try {
      await ref
          .read(privateMediaViewmodelProvider(widget.media.id).notifier)
          .toggleEpisodeWatched(seasonNumber, added, removed);
      added.clear();
      removed.clear();
    } catch (e) {
      if (mounted) {
        ToastService.error(
          context,
          ref.watch(themeProvider).value!,
          message: e.toString(),
          title: 'Failed to update episode status',
        );
      }
    }
  }

  void _onEpisodeToggle(int seasonNumber, int episodeNumber, bool isAdded) {
    setState(() {
      if (isAdded) {
        if (removed.contains(episodeNumber)) {
          removed.remove(episodeNumber);
        } else {
          added.add(episodeNumber);
        }
      } else {
        if (added.contains(episodeNumber)) {
          added.remove(episodeNumber);
        } else {
          removed.add(episodeNumber);
        }
      }
    });
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () async {
      try {
        await ref
            .read(privateMediaViewmodelProvider(widget.media.id).notifier)
            .toggleEpisodeWatched(seasonNumber, added, removed);
        added.clear();
        removed.clear();
      } catch (e) {
        if (mounted) {
          ToastService.error(
            context,
            ref.watch(themeProvider).value!,
            message: e.toString(),
            title: 'Failed to update episode status',
          );
        }
      }
    });
  }
}
