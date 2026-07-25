import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/theme/theme_notifier.dart';

class TagWidget extends ConsumerWidget {
  const TagWidget({super.key, required this.tag});
  final String tag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider).value!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.borderC,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.secTextC),
      ),
      child: Text(tag, style: theme.sec),
    );
  }
}
