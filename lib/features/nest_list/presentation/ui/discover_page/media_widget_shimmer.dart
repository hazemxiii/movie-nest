import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/theme/theme_notifier.dart';
import 'package:shimmer/shimmer.dart';

class MediaWidgetShimmer extends ConsumerWidget {
  const MediaWidgetShimmer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider).value!;
    return SizedBox(
      width: 200,
      child: Shimmer.fromColors(
        baseColor: theme.secBackC,
        highlightColor: theme.secBackC.withValues(alpha: 0.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.secBackC,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Title placeholder
            Container(
              height: 18,
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.secBackC,
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            const SizedBox(height: 6),

            // Optional second title line
            Container(
              height: 18,
              width: 120,
              decoration: BoxDecoration(
                color: theme.secBackC,
                borderRadius: BorderRadius.circular(4),
              ),
            ),

            const SizedBox(height: 8),

            // Year placeholder
            Container(
              height: 14,
              width: 50,
              decoration: BoxDecoration(
                color: theme.secBackC,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
