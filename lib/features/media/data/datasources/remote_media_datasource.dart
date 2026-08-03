import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/services/api_service.dart';
import 'package:movie_nest/features/media/data/datasources/media_datasource.dart';
import 'package:movie_nest/features/media/data/models/dtos/media_dto.dart';
import 'package:movie_nest/features/media/data/models/media.dart';
import 'package:movie_nest/features/media/data/models/season.dart';

class RemoteMediaDatasource extends MediaDatasource {
  RemoteMediaDatasource({required this._apiService});

  final ApiService _apiService;
  @override
  Future<Media> getPublicMedia(String tmdbId, bool isTv) async {
    final response = await _apiService.fetch(
      "media/public/$tmdbId?type=${isTv ? 'tv' : 'movie'}",
      ApiMethod.get,
    );
    final seasons = (response['seasons'] as List? ?? [])
        .map(Season.fromJson)
        .toList();
    return Media.fromJson(response['media']).copyWith(seasons: seasons);
  }

  @override
  Future<void> createMedia(MediaDto dto) async {
    await _apiService.fetch('media', ApiMethod.post, requestBody: dto.toJson());
  }

  @override
  Future<Media> getPrivateMedia(String mediaId) async {
    final response = await _apiService.fetch('media/$mediaId', ApiMethod.get);
    final seasons = (response['seasons'] as List? ?? [])
        .map(Season.fromJson)
        .toList();
    return Media.fromJson(response).copyWith(seasons: seasons);
  }

  @override
  Future<Season> toggleEpisode(
    String mediaId,
    int seasonNumber,
    List<int> added,
    List<int> removed,
  ) async {
    final response = await _apiService.fetch(
      'media/$mediaId/toggle-watched',
      ApiMethod.post,
      requestBody: {'added': added, 'removed': removed, 'season': seasonNumber},
    );
    return Season.fromJson(response);
  }

  @override
  Future<Media> update(MediaDto dto) async {
    final response = await _apiService.fetch(
      'media/${dto.id}',
      ApiMethod.patch,
      requestBody: dto.toJson(),
    );
    return Media.fromJson(response);
  }

  @override
  Future<void> delete(String mediaId) async {
    await _apiService.fetch('media/$mediaId', ApiMethod.delete);
  }
}

final remoteMediaDatasourceProvider = Provider<RemoteMediaDatasource>((ref) {
  return RemoteMediaDatasource(apiService: ref.read(apiServiceProvider));
});
