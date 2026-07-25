import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/theme/theme_notifier.dart';
import 'package:shimmer/shimmer.dart';

class MediaPageShimmer extends ConsumerWidget {
  const MediaPageShimmer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider).value!;

    Widget shimmerBox({
      required double width,
      required double height,
      double radius = 8,
    }) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: theme.secBackC,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          Positioned.fill(child: Container(color: theme.backC)),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(color: theme.backC.withValues(alpha: 0.8)),
            ),
          ),
          Shimmer.fromColors(
            baseColor: theme.secBackC,
            highlightColor: theme.secBackC.withValues(alpha: 0.5),
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.borderC),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poster
                  Container(
                    width: 180,
                    height: 270,
                    decoration: BoxDecoration(
                      color: theme.secBackC,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),

                  const SizedBox(width: 20),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        shimmerBox(width: 280, height: 28),
                        const SizedBox(height: 8),
                        shimmerBox(width: 180, height: 18),

                        const SizedBox(height: 20),

                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: List.generate(
                            4,
                            (_) =>
                                shimmerBox(width: 80, height: 18, radius: 20),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: List.generate(
                            5,
                            (_) =>
                                shimmerBox(width: 70, height: 32, radius: 16),
                          ),
                        ),

                        const SizedBox(height: 24),

                        shimmerBox(width: double.infinity, height: 16),
                        const SizedBox(height: 8),
                        shimmerBox(width: double.infinity, height: 16),
                        const SizedBox(height: 8),
                        shimmerBox(width: 260, height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
