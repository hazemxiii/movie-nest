import 'package:movie_nest/core/models/watch_stream_data.dart';
import 'package:movie_nest/features/nest_list/data/datasources/nest_list_datasource.dart';
import 'package:movie_nest/features/nest_list/data/models/nest_list.dart';
import 'package:movie_nest/features/nest_list/domain/repositories/nest_list_repository.dart';

class NestListRepositoryImpl extends NestListRepository {
  NestListRepositoryImpl({required this._remoteNestListDatasource});
  final NestListDatasource _remoteNestListDatasource;

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
  Future<void> createList(NestList list) {
    // TODO: implement createList
    throw UnimplementedError();
  }
}
