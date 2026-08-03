import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_nest/core/theme/theme_notifier.dart';
import 'package:movie_nest/core/widgets/nest_image.dart';
import 'package:movie_nest/features/media/data/models/media.dart';

class PrivateMediaWidget extends ConsumerWidget {
  const PrivateMediaWidget({super.key, required this.media});
  final Media media;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider).value!;
    return GestureDetector(
      onTap: () {
        context.push('/media/${media.id}');
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.secBackC2,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.borderC),
        ),
        child: Row(
          children: [
            NestImage(url: media.posterUrl, width: 100, borderRadius: 12),
            const SizedBox(width: 5),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    media.title,
                    style: theme.bold,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(media.genres.join(' • '), style: theme.secSmall),
                  const Spacer(),
                  if (media.isTv) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            overflow: TextOverflow.ellipsis,
                            '${media.progress.totalWatched}/${media.progress.totalEpisodes} Episodes',
                            style: theme.secSmallBold,
                          ),
                        ),
                        Text(
                          '${(media.progress.progress * 100).toInt()}%',
                          style: theme.mainSmallBold,
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    LinearProgressIndicator(
                      value: media.progress.progress,
                      backgroundColor: theme.borderC,
                      color: theme.mainC,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
