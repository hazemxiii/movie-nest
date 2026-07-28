import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/theme/theme_notifier.dart';
import 'package:shimmer/shimmer.dart';

class ListDetailsSectionShimmer extends ConsumerWidget {
  const ListDetailsSectionShimmer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider).value!;
    Widget line({required double width, double height = 14}) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: theme.secBackC,
          borderRadius: BorderRadius.circular(height / 2),
        ),
      );
    }

    return Shimmer.fromColors(
      baseColor: theme.secBackC.withValues(alpha: 0.6),
      highlightColor: theme.backC,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          line(width: 180, height: 22),
          const SizedBox(height: 12),

          line(width: 110),
          const SizedBox(height: 8),

          line(width: double.infinity),
          const SizedBox(height: 6),

          line(width: 260),
          const SizedBox(height: 20),

          line(width: 140),
          const SizedBox(height: 8),

          line(width: 220),
          const SizedBox(height: 6),

          line(width: 170),
        ],
      ),
    );
  }
}
