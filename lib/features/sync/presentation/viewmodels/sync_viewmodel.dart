import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/features/sync/domain/repositories/sync_repository.dart';

class SyncViewModel extends AsyncNotifier<bool> {
  @override
  FutureOr<bool> build() async {
    try {
      await ref.read(syncRepositoryProvider).sync();
      return true;
    } catch (e) {
      return false;
    }
  }
}

final syncViewModelProvider = AsyncNotifierProvider<SyncViewModel, bool>(
  SyncViewModel.new,
);
