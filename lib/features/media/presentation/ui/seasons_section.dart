import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/theme/theme_notifier.dart';
import 'package:movie_nest/core/widgets/nest_button.dart';
import 'package:movie_nest/features/media/data/models/media.dart';
import 'package:movie_nest/features/media/data/models/season.dart';

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
  late Season selectedSeason;

  @override
  void initState() {
    super.initState();
    if (widget.media.seasons.isNotEmpty) {
      selectedSeason = widget.media.seasons.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider).value!;
    final progress = widget.media.progress;
    if (widget.media.seasons.isEmpty) {
      return const SizedBox.shrink();
    }
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Track episodes', style: theme.bigBold),
                  if (!widget.isPublic)
                    Text(
                      '${progress.totalWatched} of ${progress.totalEpisodes} watched . ${(progress.progress * 100).toStringAsFixed(0)}%',
                      style: theme.sec,
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
                borderC: selectedSeason != season ? theme.borderC : null,
                onTap: () {
                  setState(() {
                    selectedSeason = season;
                  });
                },
                text: 'Season ${season.number}',
                backC: selectedSeason == season ? theme.mainC : theme.secBackC,
                textC: selectedSeason == season ? theme.textC : theme.secTextC,
              );
            }).toList(),
          ),
          const SizedBox(height: 3),
          if (!widget.isPublic)
            Text(
              '${selectedSeason.watchedEpisodes.length}/${selectedSeason.episodeCount}',
              style: theme.sec,
            ),
          const SizedBox(height: 16),
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
                final isWatched = widget.isPublic
                    ? false
                    : widget.media.isEpisodeWatched(
                        selectedSeason.number,
                        index + 1,
                      );
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
                          // TODO: Handle episode watch toggle
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
}
