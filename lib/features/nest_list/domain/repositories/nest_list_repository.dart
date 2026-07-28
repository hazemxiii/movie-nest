import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/models/watch_stream_data.dart';
import 'package:movie_nest/features/nest_list/data/datasources/local_nest_list_datasource.dart';
import 'package:movie_nest/features/nest_list/data/datasources/remote_nest_list_datasource.dart';
import 'package:movie_nest/features/nest_list/data/models/nest_list.dart';
import 'package:movie_nest/features/nest_list/data/models/nest_list_dto.dart';
import 'package:movie_nest/features/nest_list/data/repositories/nest_list_repository_impl.dart';
import 'package:movie_nest/features/sync/data/datasources/local_sync_queue_datasource.dart';

abstract class NestListRepository {
  Stream<WatchStreamData<NestList>> watchPublicList(String listId);
  Stream<WatchStreamData<NestList>> watchPrivateList(String listId);
  Stream<WatchStreamData<List<NestList>>> watchPrivateListCollectionSummary();
  Future<void> createList(NestListDto list);
  Future<void> deleteList(String listId);
  Future<NestList> updateList(String listId, NestListDto list);
}

final nestListRepositoryProvider = Provider<NestListRepository>((ref) {
  return NestListRepositoryImpl(
    remoteNestListDatasource: ref.read(remoteNestListDatasourceProvider),
    localNestListDatasource: ref.read(localNestListDatasourceProvider),
    syncQueueDatasource: ref.read(localSyncQueueDatasourceProvider),
  );
});
