import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/theme/nest_theme.dart' show NestTheme;
import 'package:movie_nest/core/theme/theme_notifier.dart';
import 'package:shimmer/shimmer.dart';

class ProfileShimmer extends ConsumerWidget {
  const ProfileShimmer({super.key, required this.isSmall});
  final bool isSmall;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider).value!;
    return Shimmer.fromColors(
      baseColor: theme.borderC.withValues(alpha: 0.25),
      highlightColor: theme.mainC.withValues(alpha: 0.15),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                color: theme.secBackC,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.borderC, width: 1),
              ),
              child: Flex(
                spacing: 16,
                mainAxisAlignment: isSmall
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.start,
                direction: isSmall ? Axis.vertical : Axis.horizontal,
                children: [
                  // Profile image
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: theme.secBackC,
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),

                  // Name + email
                  Column(
                    crossAxisAlignment: isSmall
                        ? CrossAxisAlignment.center
                        : CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: isSmall ? 140 : 180,
                        height: 25,
                        decoration: BoxDecoration(
                          color: theme.secBackC,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: isSmall ? 180 : 220,
                        height: 16,
                        decoration: BoxDecoration(
                          color: theme.secBackC,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),

                  if (!isSmall) const Spacer(),

                  // Sign out button
                  Container(
                    width: 90,
                    height: 42,
                    decoration: BoxDecoration(
                      color: theme.secBackC,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [_tagShimmer(theme), _tagShimmer(theme)],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tagShimmer(NestTheme theme) {
    return Container(
      padding: const EdgeInsets.all(15),
      constraints: const BoxConstraints(minWidth: 120),
      decoration: BoxDecoration(
        color: theme.secBackC,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.borderC, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 55,
            height: 16,
            decoration: BoxDecoration(
              color: theme.secBackC,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 30,
            decoration: BoxDecoration(
              color: theme.secBackC,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }
}
