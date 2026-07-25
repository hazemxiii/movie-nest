import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_nest/core/theme/theme_notifier.dart';

class NestBackButton extends ConsumerWidget {
  const NestBackButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider).value!;
    return TextButton(
      style: TextButton.styleFrom(foregroundColor: theme.mainC),
      onPressed: () {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/');
        }
      },
      child: const Text('⬅ Back'),
    );
  }
}
