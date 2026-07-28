import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/models/watch_stream_data.dart';
import 'package:movie_nest/features/media/data/datasources/local_media_datasource.dart';
import 'package:movie_nest/features/media/data/datasources/remote_media_datasource.dart';
import 'package:movie_nest/features/media/data/models/dtos/media_dto.dart';
import 'package:movie_nest/features/media/data/models/media.dart';
import 'package:movie_nest/features/media/data/repositories/media_repository_impl.dart';

abstract class MediaRepository {
  Future<Media> getPublicMedia(String tmdbId, bool isTv);
  Future<void> createMedia(String listId, MediaDto dto);
  Stream<WatchStreamData<Media>> watchPrivateMedia(String mediaId);
}

final mediaRepositoryProvider = Provider<MediaRepository>((ref) {
  return MediaRepositoryImpl(
    ref.read(remoteMediaDatasourceProvider),
    ref.read(localMediaDatasourceProvider),
  );
});
