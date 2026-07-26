import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/services/api_service.dart';
import 'package:movie_nest/features/media/data/models/media.dart';
import 'package:movie_nest/features/nest_list/data/datasources/nest_list_datasource.dart';
import 'package:movie_nest/features/nest_list/data/models/nest_list.dart';
import 'package:movie_nest/features/nest_list/data/models/nest_list_dto.dart';

class RemoteNestListDatasource implements NestListDatasource {
  RemoteNestListDatasource(this._apiService);
  final ApiService _apiService;
  @override
  Future<NestList> getPublicNestList(String listId) async {
    final response = (await _apiService.fetch(
      'lists/public/list/$listId',
      ApiMethod.get,
    ))['list'];

    final list = NestList.fromJson(response);
    final media = <Media>[];
    for (var item in response['media']) {
      media.add(Media.fromJson(item));
    }
    return list.copyWith(media: media);
  }

  @override
  Future<void> create(NestListDto list) async {
    await _apiService.fetch(
      'lists',
      ApiMethod.post,
      requestBody: list.toCreateJson(),
    );
  }

  @override
  Future<List<NestList>> getPrivateListCollectionSummary() async {
    final response = await _apiService.fetch('lists', ApiMethod.get);
    return (response['lists'] as List).map(NestList.fromJson).toList();
  }

  @override
  Future<void> delete(String listId) async {
    await _apiService.fetch('lists/$listId', ApiMethod.delete);
  }

  @override
  Future<NestList> update(String listId, NestListDto list) async {
    final response = await _apiService.fetch(
      'lists/$listId',
      ApiMethod.patch,
      requestBody: list.toUpdateJson(),
    );
    return NestList.fromJson(response);
  }
}

final remoteNestListDatasourceProvider = Provider<RemoteNestListDatasource>((
  ref,
) {
  return RemoteNestListDatasource(ref.read(apiServiceProvider));
});
