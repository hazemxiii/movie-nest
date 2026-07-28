import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:movie_nest/core/models/watch_stream_data.dart';
import 'package:movie_nest/core/services/toast_service.dart';
import 'package:movie_nest/core/theme/theme_notifier.dart';
import 'package:movie_nest/core/widgets/nest_button.dart';
import 'package:movie_nest/core/widgets/nest_error_widget.dart';
import 'package:movie_nest/core/widgets/nest_image.dart';
import 'package:movie_nest/core/widgets/tag_widget.dart';
import 'package:movie_nest/features/media/data/models/media.dart';
import 'package:movie_nest/features/media/presentation/ui/media_page_shimmer.dart';
import 'package:movie_nest/features/media/presentation/ui/select_list_dialog.dart';
import 'package:movie_nest/features/media/presentation/viewmodels/private_media_viewmodel.dart';
import 'package:movie_nest/features/media/presentation/viewmodels/public_media_viewmodel.dart';
import 'package:movie_nest/features/nest_list/presentation/viewmodels/private_nest_list_viewmodel.dart';

class MediaHeader extends ConsumerWidget {
  const MediaHeader({
    super.key,
    required this.mediaId,
    required this.isTv,
    required this.isPublic,
  });
  final String mediaId;
  final bool isTv;
  final bool isPublic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaState = isPublic
        ? ref.watch(publicMediaProvider((mediaId, isTv)))
        : ref.watch(privateMediaViewmodelProvider(mediaId));
    final isMobile = MediaQuery.of(context).size.width < 600;
    final theme = ref.watch(themeProvider).value!;
    return mediaState.when(
      skipLoadingOnRefresh: false,
      data: (data) {
        Media? media;
        if (data is WatchStreamData) {
          media = data.data;
        } else if (data is Media?) {
          media = data;
        }
        if (media == null) {
          return NestErrorWidget(
            title: 'Error',
            message: 'Media not found',
            onTap: () => ref.invalidate(publicMediaProvider((mediaId, isTv))),
          );
        }
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
                  child: Container(color: Colors.black.withValues(alpha: 0.8)),
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
                                Text(media.originalTitle, style: theme.sec),
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
                          if (isPublic) ...[
                            const SizedBox(height: 20),
                            NestButton(
                              onTap: () async {
                                final selectedListId = await showDialog<String>(
                                  context: context,
                                  builder: (context) =>
                                      const SelectListDialog(),
                                );
                                if (selectedListId == null) return;
                                try {
                                  await ref
                                      .read(
                                        privateNestListViewmodelProvider(
                                          selectedListId,
                                        ).notifier,
                                      )
                                      .addMedia(media!.toDto());
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ToastService.error(
                                    context,
                                    theme,
                                    message: e.toString(),
                                    title: 'Couldn\'t add to list',
                                  );
                                }
                              },
                              backC: theme.mainC,
                              textC: theme.textC,
                              icon: Icons.add,
                              text: 'Add to List',
                            ),
                          ],
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
        return NestErrorWidget(
          onTap: () {
            ref.invalidate(publicMediaProvider((mediaId, isTv)));
          },
          title: 'Error',
          message: error.toString(),
        );
      },
      loading: () {
        return const MediaPageShimmer();
      },
    );
  }
}
