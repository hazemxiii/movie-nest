import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/services/api_service.dart';
import 'package:movie_nest/features/media/data/models/media.dart';
import 'package:movie_nest/features/nest_list/data/datasources/nest_list_datasource.dart';
import 'package:movie_nest/features/nest_list/data/models/nest_list.dart';

class RemoteNestListDatasource implements NestListDatasource {
  RemoteNestListDatasource(this._apiService);
  final ApiService _apiService;

  @override
  Future<NestList> getNestList(String listId) {
    throw UnimplementedError();
  }

  @override
  Future<NestList> getPublicNestList(String listId) async {
    final response = (await _apiService.get(
      'lists/public/list/$listId',
    ))['list'];

    final list = NestList.fromJson(response);
    final media = <Media>[];
    for (var item in response['media']) {
      media.add(Media.fromJson(item));
    }
    return list.copyWith(media: media);
  }

  @override
  Future<void> create(NestList list) {
    // TODO: implement create
    throw UnimplementedError();
  }
}

final remoteNestListDatasourceProvider = Provider<RemoteNestListDatasource>((
  ref,
) {
  return RemoteNestListDatasource(ref.read(apiServiceProvider));
});
