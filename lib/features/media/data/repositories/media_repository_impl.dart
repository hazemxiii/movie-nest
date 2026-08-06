import 'package:movie_nest/core/exceptions/nest_internet_exception.dart';
import 'package:movie_nest/core/models/watch_stream_data.dart';
import 'package:movie_nest/features/media/data/datasources/media_datasource.dart';
import 'package:movie_nest/features/media/data/models/dtos/media_dto.dart';
import 'package:movie_nest/features/media/data/models/media.dart';
import 'package:movie_nest/features/media/data/models/season.dart';
import 'package:movie_nest/features/media/domain/repositories/media_repository.dart';
import 'package:movie_nest/features/sync/data/datasources/sync_queue_datasource.dart';
import 'package:movie_nest/features/sync/data/models/sync_queue.dart';
import 'package:uuid/uuid.dart';

class MediaRepositoryImpl implements MediaRepository {
  MediaRepositoryImpl(
    this._remoteDatasource,
    this._localDatasource,
    this._syncQueueDatasource,
  );
  final MediaDatasource _remoteDatasource;
  final MediaDatasource _localDatasource;
  final SyncQueueDatasource _syncQueueDatasource;

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
    } on NestInternetException {
      await _syncQueueDatasource.addOperation(
        SyncOperation(
          id: const Uuid().v4(),
          url: 'media',
          type: SyncOperationType.create,
          method: 'POST',
          entityId: dto.id,
          body: dto.toJson(),
          entityType: 'media',
          createdAt: DateTime.now().toUtc(),
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Stream<WatchStreamData<Media>> watchPrivateMedia(String mediaId) async* {
    final localMedia = await _localDatasource.getPrivateMedia(mediaId);
    final willFetchRemote = !(await _syncQueueDatasource.hasOperations());
    yield WatchStreamData(data: localMedia, isLoading: willFetchRemote);
    if (!willFetchRemote) return;
    try {
      final remoteMedia = await _remoteDatasource.getPrivateMedia(mediaId);
      yield WatchStreamData(data: remoteMedia, isLoading: false);
      await _localDatasource.update(remoteMedia.toDto());
    } catch (e) {
      yield WatchStreamData(data: localMedia, isLoading: false);
    }
  }

  @override
  Future<Season> toggleEpisode(
    String mediaId,
    int seasonNumber,
    List<int> added,
    List<int> removed,
  ) async {
    final localSeason = await _localDatasource.toggleEpisode(
      mediaId,
      seasonNumber,
      added,
      removed,
    );
    try {
      return await _remoteDatasource.toggleEpisode(
        mediaId,
        seasonNumber,
        added,
        removed,
      );
    } on NestInternetException {
      _syncQueueDatasource.addOperation(
        SyncOperation(
          id: const Uuid().v4(),
          url: '/media/$mediaId/toggle-watched',
          type: SyncOperationType.update,
          method: 'POST',
          entityId: mediaId,
          body: {'season': seasonNumber, 'added': added, 'removed': removed},
          entityType: SyncOperationEntityType.media,
          createdAt: DateTime.now().toUtc(),
        ),
      );
      return localSeason;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteMedia(String mediaId) async {
    await _localDatasource.delete(mediaId);
    try {
      await _remoteDatasource.delete(mediaId);
    } on NestInternetException {
      _syncQueueDatasource.addOperation(
        SyncOperation(
          id: const Uuid().v4(),
          url: 'media/$mediaId',
          type: SyncOperationType.delete,
          method: 'DELETE',
          entityId: mediaId,
          body: {},
          entityType: SyncOperationEntityType.media,
          createdAt: DateTime.now().toUtc(),
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Media> updateMedia(MediaDto dto) async {
    final localMedia = await _localDatasource.update(dto);
    try {
      return await _remoteDatasource.update(dto);
    } on NestInternetException {
      _syncQueueDatasource.addOperation(
        SyncOperation(
          id: const Uuid().v4(),
          url: 'media/${dto.id}',
          type: SyncOperationType.update,
          method: 'PUT',
          entityId: dto.id,
          body: dto.toJson(),
          entityType: SyncOperationEntityType.media,
          createdAt: DateTime.now().toUtc(),
        ),
      );
      return localMedia;
    } catch (e) {
      rethrow;
    }
  }
}
