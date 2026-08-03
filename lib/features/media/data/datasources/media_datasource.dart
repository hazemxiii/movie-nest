import 'package:movie_nest/features/media/data/models/dtos/media_dto.dart';
import 'package:movie_nest/features/media/data/models/media.dart';
import 'package:movie_nest/features/media/data/models/season.dart';

abstract class MediaDatasource {
  Future<Media> getPublicMedia(String tmdbId, bool isTv);
  Future<void> createMedia(MediaDto dto);
  Future<Media> getPrivateMedia(String mediaId);
  Future<Media> update(MediaDto dto);
  Future<void> delete(String mediaId);
  Future<Season> toggleEpisode(
    String mediaId,
    int seasonNumber,
    List<int> added,
    List<int> removed,
  );
}
