import 'package:movie_nest/core/models/watch_stream_data.dart';
import 'package:movie_nest/features/media/data/datasources/media_datasource.dart';
import 'package:movie_nest/features/media/data/models/dtos/media_dto.dart';
import 'package:movie_nest/features/media/data/models/media.dart';
import 'package:movie_nest/features/media/domain/repositories/media_repository.dart';

class MediaRepositoryImpl implements MediaRepository {
  MediaRepositoryImpl(this._remoteDatasource, this._localDatasource);
  final MediaDatasource _remoteDatasource;
  final MediaDatasource _localDatasource;

  @override
  Future<Media> getPublicMedia(String tmdbId, bool isTv) async {
    return await _remoteDatasource.getPublicMedia(tmdbId, isTv);
  }

  @override
  Future<void> createMedia(String listId, MediaDto dto) async {
    dto.list = listId;
    for (final season in dto.seasonsDto) {
      season.media = dto.id;
    }
    await _localDatasource.createMedia(dto);
    try {
      await _remoteDatasource.createMedia(dto);
    } catch (e) {
      // TODO handle create media error & offline sync
    }
  }

  @override
  Stream<WatchStreamData<Media>> watchPrivateMedia(String mediaId) async* {
    final localMedia = await _localDatasource.getPrivateMedia(mediaId);
    yield WatchStreamData(data: localMedia, isLoading: true);
    try {
      final remoteMedia = await _remoteDatasource.getPrivateMedia(mediaId);
      yield WatchStreamData(data: remoteMedia, isLoading: false);
    } catch (e) {
      yield WatchStreamData(data: localMedia, isLoading: false);
    }
    // TODO merge data
  }
}
