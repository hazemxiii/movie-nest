import 'package:movie_nest/core/exceptions/nest_internet_exception.dart';
import 'package:movie_nest/core/models/watch_stream_data.dart';
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
  });
  final NestListDatasource _remoteNestListDatasource;
  final NestListDatasource _localNestListDatasource;
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
    try {
      localLists = await _localNestListDatasource
          .getPrivateListCollectionSummary();
      localIds.addAll(localLists.map((e) => e.id));
      yield WatchStreamData(data: localLists, isLoading: true);
    } catch (e) {
      yield WatchStreamData(data: null, isLoading: true, error: e.toString());
    }
    try {
      final remoteLists = await _remoteNestListDatasource
          .getPrivateListCollectionSummary();
      if (!(await _syncQueueDatasource.hasOperations())) {
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
      }
      yield WatchStreamData(data: remoteLists, isLoading: false);
    } on NestInternetException {
      yield WatchStreamData(data: localLists, isLoading: false);
    } catch (e) {
      yield WatchStreamData(data: null, isLoading: false, error: e.toString());
    }
  }

  @override
  Future<void> deleteList(String listId) async {
    await _localNestListDatasource.delete(listId);
    await _remoteNestListDatasource.delete(listId);
  }

  @override
  Future<NestList> updateList(
    String listId,
    NestListDto list,
    Map<String, int> fieldsVersion,
  ) async {
    await _localNestListDatasource.update(listId, list);
    final remoteList = await _remoteNestListDatasource.update(listId, list);
    await _localNestListDatasource.update(
      listId,
      NestListDto(
        name: remoteList.name,
        fieldsVersion: remoteList.fieldsVersion,
      ),
    );
    return remoteList;
  }
}
