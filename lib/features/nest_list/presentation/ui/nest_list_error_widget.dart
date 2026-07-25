import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/theme/theme_notifier.dart';

class NestListErrorWidget extends ConsumerWidget {
  const NestListErrorWidget({super.key, this.title, required this.message});
  final String? title;
  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider).value!;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: theme.errorC.withAlpha(20),
        border: Border.all(color: theme.errorC.withAlpha(100)),
      ),
      padding: const EdgeInsets.all(25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: theme.errorC.withAlpha(50),
            child: Icon(Icons.close, color: theme.textC, size: 50),
          ),
          const SizedBox(height: 10),
          Text(title ?? 'Error', style: theme.bigBold),
          const SizedBox(height: 10),
          Text(message, style: theme.sec),
        ],
      ),
    );
  }
}
