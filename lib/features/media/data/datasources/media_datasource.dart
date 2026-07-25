import 'package:movie_nest/features/media/data/models/media.dart';

abstract class MediaDatasource {
  Future<Media> getPublicMedia(String tmdbId, bool isTv);
}
