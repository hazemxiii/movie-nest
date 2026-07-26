import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/theme/theme_notifier.dart';
import 'package:movie_nest/features/sync/presentation/viewmodels/sync_viewmodel.dart';

class SyncIndicatorButton extends ConsumerWidget {
  const SyncIndicatorButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncViewModelProvider);
    final theme = ref.watch(themeProvider).value!;
    return syncState.when(
      data: (data) {
        if (data) {
          return Icon(Icons.cloud_outlined, color: theme.textC);
        }
        return Icon(Icons.cloud_off, color: theme.secTextC);
      },
      error: (Object error, StackTrace stackTrace) {
        return Icon(Icons.cloud_off, color: theme.secTextC);
      },
      loading: () {
        return SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: theme.mainC),
        );
      },
    );
  }
}
