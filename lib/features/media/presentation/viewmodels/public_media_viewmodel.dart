import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/features/media/data/models/media.dart';
import 'package:movie_nest/features/media/domain/repositories/media_repository.dart';

class PublicMediaViewmodel extends AsyncNotifier<Media?> {
  PublicMediaViewmodel(this.tmdbId, this.isTv);
  final String tmdbId;
  final bool isTv;

  @override
  FutureOr<Media?> build() async {
    try {
      return await ref
          .read(mediaRepositoryProvider)
          .getPublicMedia(tmdbId, isTv);
    } catch (e) {
      return null;
    }
  }

  Future<void> onListChanged(ListsWithThisMedia list, bool isAdded) async {
    if (state.value != null) {
      state = AsyncValue.data(
        state.value!.copyWith(
          lists: isAdded
              ? [...state.value!.lists, list]
              : state.value!.lists.where((l) => l.id != list.id).toList(),
        ),
      );
    }
  }
}

final publicMediaProvider =
    AsyncNotifierProvider.family<PublicMediaViewmodel, Media?, (String, bool)>(
      (params) => PublicMediaViewmodel(params.$1, params.$2),
    );
