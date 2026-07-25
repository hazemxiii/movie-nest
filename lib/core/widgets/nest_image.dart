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
  });
  final String url;
  final double? width;
  final double? height;
  final double borderRadius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider).value!;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        url,
        fit: BoxFit.cover,
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        errorBuilder: (context, error, stackTrace) {
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
