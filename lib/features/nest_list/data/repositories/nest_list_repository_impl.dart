import 'package:movie_nest/core/exceptions/nest_internet_exception.dart';
import 'package:movie_nest/core/models/watch_stream_data.dart';
import 'package:movie_nest/features/media/data/datasources/media_datasource.dart';
import 'package:movie_nest/features/nest_list/data/datasources/nest_list_datasource.dart';
import 'package:movie_nest/features/nest_list/data/models/nest_list.dart';
import 'package:movie_nest/features/nest_list/data/models/nest_list_dto.dart';
import 'package:movie_nest/features/nest_list/domain/repositories/nest_list_repository.dart';
import 'package:movie_nest/features/sync/data/datasources/sync_queue_datasource.dart';
import 'package:movie_nest/features/sync/data/models/sync_queue.dart';
import 'package:uuid/uuid.dart';

class NestListRepositoryImpl extends NestListRepository {
  NestListRepositoryImpl({
    required this._remoteNestListDatasource,
    required this._localNestListDatasource,
    required this._syncQueueDatasource,
    required this._localMediaDatasource,
  });
  final NestListDatasource _remoteNestListDatasource;
  final NestListDatasource _localNestListDatasource;
  final MediaDatasource _localMediaDatasource;
  final SyncQueueDatasource _syncQueueDatasource;

  @override
  Stream<WatchStreamData<NestList>> watchPublicList(String listId) async* {
    try {
      yield WatchStreamData(
        data: await _remoteNestListDatasource.getPublicNestList(listId),
        isLoading: false,
      );
    } catch (e) {
      yield WatchStreamData(data: null, isLoading: false, error: e.toString());
    }
  }

  @override
  Future<void> createList(NestListDto list) async {
    await _localNestListDatasource.create(list);
    try {
      await _remoteNestListDatasource.create(list);
    } on NestInternetException {
      await _syncQueueDatasource.addOperation(
        SyncOperation(
          id: const Uuid().v4(),
          url: 'lists',
          type: SyncOperationType.create,
          method: 'post',
          entityId: list.id,
          body: list.toCreateJson(),
          entityType: SyncOperationEntityType.nestList,
          createdAt: DateTime.now().toUtc(),
        ),
      );
    } catch (e) {
      await _localNestListDatasource.delete(list.id);
      rethrow;
    }
  }

  @override
  Stream<WatchStreamData<List<NestList>>>
  watchPrivateListCollectionSummary() async* {
    List<NestList> localLists = [];
    final localIds = <String>{};
    final hasOperations = await _syncQueueDatasource.hasOperations();
    try {
      localLists = await _localNestListDatasource
          .getPrivateListCollectionSummary();
      localIds.addAll(localLists.map((e) => e.id));
      yield WatchStreamData(data: localLists, isLoading: !hasOperations);
    } catch (e) {
      yield WatchStreamData(
        data: null,
        isLoading: !hasOperations,
        error: e.toString(),
      );
    }
    if (hasOperations) return;
    try {
      final remoteLists = await _remoteNestListDatasource
          .getPrivateListCollectionSummary();
      for (final list in remoteLists) {
        if (!localIds.contains(list.id)) {
          await _localNestListDatasource.create(list.toDto());
        } else {
          await _localNestListDatasource.update(list.id, list.toDto());
          localIds.remove(list.id);
        }
      }
      for (final id in localIds) {
        await _localNestListDatasource.delete(id);
      }
      yield WatchStreamData(data: remoteLists, isLoading: false);
    } on NestInternetException {
      yield WatchStreamData(data: localLists, isLoading: false);
    } catch (e) {
      yield WatchStreamData(data: null, isLoading: false, error: e.toString());
    }
  }

  @override
  Future<void> deleteList(String listId, {String? moveToListId}) async {
    await _localNestListDatasource.delete(listId, moveToListId: moveToListId);
    try {
      await _remoteNestListDatasource.delete(
        listId,
        moveToListId: moveToListId,
      );
    } on NestInternetException {
      _syncQueueDatasource.addOperation(
        SyncOperation(
          id: const Uuid().v4(),
          url:
              'lists/$listId${moveToListId != null ? '?moveTo=$moveToListId' : ''}',
          type: SyncOperationType.delete,
          method: 'DELETE',
          entityId: listId,
          entityType: 'list',
          createdAt: DateTime.now().toUtc(),
          body: {},
        ),
      );
    }
  }

  @override
  Future<NestList> updateList(String listId, NestListDto list) async {
    final oldLocalList = await _localNestListDatasource.getPrivateNestList(
      listId,
    );
    await _localNestListDatasource.update(listId, list);
    try {
      final remoteList = await _remoteNestListDatasource.update(listId, list);
      await _localNestListDatasource.update(
        listId,
        NestListDto(
          name: remoteList.name,
          fieldsVersion: remoteList.fieldsVersion,
        ),
      );
      return remoteList;
    } on NestInternetException {
      _syncQueueDatasource.addOperation(
        SyncOperation(
          id: const Uuid().v4(),
          url: 'lists/$listId',
          type: SyncOperationType.update,
          method: 'PATCH',
          entityId: listId,
          body: list.toUpdateJson(),
          entityType: SyncOperationEntityType.nestList,
          createdAt: DateTime.now().toUtc(),
        ),
      );
      return oldLocalList.updateWith(list);
    } catch (e) {
      await _localNestListDatasource.update(listId, oldLocalList.toDto());
      rethrow;
    }
  }

  @override
  Stream<WatchStreamData<NestList>> watchPrivateList(String listId) async* {
    NestList? localList;
    String? localError;
    final localmediaIds = <String>{};
    try {
      localList = await _localNestListDatasource.getPrivateNestList(listId);
      for (final media in localList.media) {
        localmediaIds.add(media.id);
      }
    } catch (e) {
      localList = null;
      localError = e.toString();
    }
    final willFetchRemote = !(await _syncQueueDatasource.hasOperations());
    yield WatchStreamData(
      data: localList,
      isLoading: willFetchRemote,
      error: localError,
    );
    if (!willFetchRemote) return;
    try {
      final remoteList = await _remoteNestListDatasource.getPrivateNestList(
        listId,
      );
      await _localNestListDatasource.update(listId, remoteList.toDto());
      for (final remoteMedia in remoteList.media) {
        if (!localmediaIds.contains(remoteMedia.id)) {
          await _localMediaDatasource.createMedia(remoteMedia.toDto());
        } else {
          await _localMediaDatasource.update(remoteMedia.toDto());
          localmediaIds.remove(remoteMedia.id);
        }
      }
      for (final mediaId in localmediaIds) {
        await _localMediaDatasource.delete(mediaId);
      }
      yield WatchStreamData(data: remoteList, isLoading: false);
    } catch (e) {
      yield WatchStreamData(data: localList, isLoading: false);
    }
  }
}
