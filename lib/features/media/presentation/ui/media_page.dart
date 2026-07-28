import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/models/watch_stream_data.dart';
import 'package:movie_nest/core/widgets/nest_back_button.dart';
import 'package:movie_nest/features/media/data/models/media.dart';
import 'package:movie_nest/features/media/presentation/ui/media_header.dart';
import 'package:movie_nest/features/media/presentation/ui/seasons_section.dart';
import 'package:movie_nest/features/media/presentation/viewmodels/private_media_viewmodel.dart';
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
  // TODO private media
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaState = isPublic
        ? ref.watch(publicMediaProvider((mediaId, isTv)))
        : ref.watch(privateMediaViewmodelProvider(mediaId));
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const NestBackButton(),
          const SizedBox(height: 5),
          MediaHeader(mediaId: mediaId, isTv: isTv, isPublic: isPublic),
          const SizedBox(height: 30),
          mediaState.when(
            data: (data) {
              Media? media;
              if (data is WatchStreamData) {
                media = data.data;
              } else if (data is Media?) {
                media = data;
              }
              if (media == null) {
                return const SizedBox.shrink();
              }
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
