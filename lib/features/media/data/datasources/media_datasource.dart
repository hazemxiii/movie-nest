import 'package:movie_nest/features/media/data/models/dtos/media_dto.dart';
import 'package:movie_nest/features/media/data/models/media.dart';

abstract class MediaDatasource {
  Future<Media> getPublicMedia(String tmdbId, bool isTv);
  Future<void> createMedia(MediaDto dto);
  Future<Media> getPrivateMedia(String mediaId);
}
