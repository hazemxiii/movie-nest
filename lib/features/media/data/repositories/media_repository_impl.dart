import 'package:movie_nest/features/media/data/datasources/media_datasource.dart';
import 'package:movie_nest/features/media/data/models/media.dart';
import 'package:movie_nest/features/media/domain/repositories/media_repository.dart';

class MediaRepositoryImpl implements MediaRepository {
  MediaRepositoryImpl(this._remoteDatasource);
  final MediaDatasource _remoteDatasource;

  @override
  Future<Media> getPublicMedia(String tmdbId, bool isTv) async {
    return await _remoteDatasource.getPublicMedia(tmdbId, isTv);
  }
}
