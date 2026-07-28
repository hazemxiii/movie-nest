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
}

final publicMediaProvider =
    AsyncNotifierProvider.family<PublicMediaViewmodel, Media?, (String, bool)>(
      (params) => PublicMediaViewmodel(params.$1, params.$2),
    );
