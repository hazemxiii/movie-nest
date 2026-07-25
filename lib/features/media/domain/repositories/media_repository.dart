import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/features/media/data/datasources/remote_media_datasource.dart';
import 'package:movie_nest/features/media/data/models/media.dart';
import 'package:movie_nest/features/media/data/repositories/media_repository_impl.dart';

abstract class MediaRepository {
  Future<Media> getPublicMedia(String tmdbId, bool isTv);
}

final mediaRepositoryProvider = Provider<MediaRepository>((ref) {
  return MediaRepositoryImpl(ref.read(remoteMediaDatasourceProvider));
});
