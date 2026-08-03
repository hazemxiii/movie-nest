import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/theme/theme_notifier.dart';
import 'package:movie_nest/features/nest_list/data/models/nest_list.dart';
import 'package:movie_nest/features/nest_list/presentation/ui/discover_page/media_widget.dart';
import 'package:movie_nest/features/nest_list/presentation/ui/discover_page/media_widget_shimmer.dart';
import 'package:shimmer/shimmer.dart';

class ListCarouselWidget extends ConsumerWidget {
  const ListCarouselWidget({
    super.key,
    required this.list,
    this.description,
    this.isShimmer = false,
  });
  ListCarouselWidget.shimmer({super.key})
    : list = NestList(name: '', media: [], id: '', fieldsVersion: {}),
      description = null,
      isShimmer = true;

  final NestList list;
  final String? description;
  final bool isShimmer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider).value!;
    final scrollController = ScrollController();
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isShimmer)
            Shimmer.fromColors(
              baseColor: theme.secBackC,
              highlightColor: theme.secBackC.withValues(alpha: 0.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 18,
                    width: 50,
                    decoration: BoxDecoration(
                      color: theme.secBackC,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 200,
                    decoration: BoxDecoration(
                      color: theme.secBackC,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            )
          else ...[
            Text(list.name, style: theme.bigBold),
            if (description != null) Text(description!, style: theme.sec),
          ],
          const SizedBox(height: 16),
          SizedBox(
            height: 350,
            child: ListView.builder(
              controller: scrollController,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: isShimmer ? 5 : list.media.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: isShimmer
                      ? const MediaWidgetShimmer()
                      : MediaWidget(media: list.media[index]),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
