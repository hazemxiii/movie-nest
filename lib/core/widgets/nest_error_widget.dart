import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/theme/theme_notifier.dart';
import 'package:movie_nest/core/widgets/nest_button.dart';

class NestErrorWidget extends ConsumerWidget {
  const NestErrorWidget({
    super.key,
    this.title = 'Error',
    required this.message,
    required this.onTap,
  });
  final String title;
  final String message;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider).value!;
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 70,
            backgroundColor: theme.errorC.withAlpha(50),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: theme.errorC,
              child: Icon(Icons.close, color: theme.textC, size: 40),
            ),
          ),
          const SizedBox(height: 16),
          Text(title, style: theme.largeBold),
          const SizedBox(height: 8),
          Text(message, style: theme.bold),
          const SizedBox(height: 16),
          NestButton(
            text: 'Try again',
            onTap: onTap,
            backC: theme.errorC,
            textC: theme.textC,
            radius: 5,
          ),
        ],
      ),
    );
  }
}
