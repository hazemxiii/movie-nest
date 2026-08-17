import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/theme/theme_notifier.dart';

class NestImage extends ConsumerWidget {
  const NestImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.borderRadius = 0,
    this.fallback,
  });
  final String url;
  final double? width;
  final double? height;
  final double borderRadius;
  final Widget? fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider).value!;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        errorWidget: (context, error, stackTrace) {
          debugPrint('LDxPFP: $error');
          if (fallback != null) {
            return fallback!;
          }
          return Container(
            color: theme.secBackC,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.broken_image_outlined,
                  size: 48,
                  color: theme.secTextC,
                ),
                const SizedBox(height: 8),
                Text('No Image', style: TextStyle(color: theme.secTextC)),
              ],
            ),
          );
        },
      ),
    );
  }
}
