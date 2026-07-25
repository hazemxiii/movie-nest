import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:movie_nest/core/theme/theme_notifier.dart';
import 'package:movie_nest/core/widgets/nest_back_button.dart';
import 'package:movie_nest/core/widgets/nest_image.dart';
import 'package:movie_nest/core/widgets/tag_widget.dart';
import 'package:movie_nest/features/media/presentation/ui/media_page_shimmer.dart';
import 'package:movie_nest/features/media/presentation/ui/seasons_section.dart';
import 'package:movie_nest/features/media/presentation/viewmodels/public_media_viewmodel.dart';

class MediaPage extends ConsumerWidget {
  const MediaPage({
    super.key,
    required this.mediaId,
    required this.isPublic,
    required this.isTv,
  });
  final String mediaId;
  final bool isPublic;
  final bool isTv;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaState = ref.watch(publicMediaProvider((mediaId, isTv)));
    final theme = ref.watch(themeProvider).value!;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const NestBackButton(),
          const SizedBox(height: 5),
          mediaState.when(
            data: (media) {
              final image = NestImage(
                url: media.posterUrl,
                width: 200,
                height: 300,
                borderRadius: 20,
              );
              return ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(media.posterUrl),
                            fit: BoxFit.cover,
                            alignment: Alignment.topLeft,
                            scale: 50,
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: theme.borderC),
                      ),
                      child: Flex(
                        direction: isMobile ? Axis.vertical : Axis.horizontal,
                        crossAxisAlignment: isMobile
                            ? CrossAxisAlignment.center
                            : CrossAxisAlignment.start,
                        children: [
                          image,
                          isMobile
                              ? const SizedBox(height: 20)
                              : const SizedBox(width: 20),
                          Expanded(
                            flex: isMobile ? 0 : 1,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 10,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            media.title,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.largeBold,
                                          ),
                                        ),
                                        Text(media.status, style: theme.sec),
                                      ],
                                    ),
                                    if (media.originalTitle.toLowerCase() !=
                                        media.title.toLowerCase())
                                      Text(
                                        media.originalTitle,
                                        style: theme.sec,
                                      ),
                                    Text(
                                      '"${media.tag}"',
                                      style: theme.sec.copyWith(
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          media.rating.toString(),
                                          style: theme.sec,
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "${DateFormat('MMMM dd, yyyy').format(media.date)}${media.end != null ? ' - ${DateFormat('MMMM dd, yyyy').format(media.end!)}' : ''}",
                                      style: theme.sec,
                                    ),
                                    Text(
                                      "${media.runTime.toString()} min${media.isTv ? '/ep' : ''}",
                                      style: theme.sec,
                                    ),
                                    if (media.isTv) ...[
                                      Text(
                                        '${media.seasonCount} Season${media.seasonCount! > 1 ? 's' : ''}',
                                        style: theme.sec,
                                      ),
                                      Text(
                                        '${media.episodeCount} Episode${media.episodeCount! > 1 ? 's' : ''}',
                                        style: theme.sec,
                                      ),
                                    ],
                                  ],
                                ),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    ...media.genres.map(
                                      (genre) => TagWidget(tag: genre),
                                    ),
                                  ],
                                ),
                                Text(
                                  media.description,
                                  style: theme.sec,
                                  maxLines: null,
                                  // overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            error: (Object error, StackTrace stackTrace) {
              return Center(child: Text('Error: ${error.toString()}'));
            },
            loading: () {
              return const MediaPageShimmer();
            },
          ),
          const SizedBox(height: 30),
          mediaState.when(
            data: (media) {
              return media.isTv
                  ? SeasonsSection(media: media, isPublic: isPublic)
                  : const SizedBox.shrink();
            },
            error: (Object error, StackTrace stackTrace) {
              return const SizedBox.shrink();
            },
            loading: () {
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
