import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/models/watch_stream_data.dart';
import 'package:movie_nest/features/nest_list/data/datasources/remote_nest_list_datasource.dart';
import 'package:movie_nest/features/nest_list/data/models/nest_list.dart';
import 'package:movie_nest/features/nest_list/data/repositories/nest_list_repository_impl.dart';

abstract class NestListRepository {
  Stream<WatchStreamData<NestList>> watchPublicList(String listId);
  Future<void> createList(NestList list);
}

final nestListRepositoryProvider = Provider<NestListRepository>((ref) {
  return NestListRepositoryImpl(
    remoteNestListDatasource: ref.read(remoteNestListDatasourceProvider),
  );
});
