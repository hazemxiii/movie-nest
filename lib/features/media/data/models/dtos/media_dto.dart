import 'package:movie_nest/features/media/data/models/dtos/season_dto.dart';

class MediaDto {
  MediaDto({
    required this.id,
    this.list,
    this.tmdbId,
    this.title,
    this.originalTitle,
    this.description,
    this.posterUrl,
    this.type,
    this.date,
    this.end,
    this.rating,
    this.runTime,
    this.genres,
    this.episodeCount,
    this.seasonCount,
    this.status,
    this.tag,
    required this.seasonsDto,
    required this.fieldsVersion,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'listId': ?list,
      'tmdb_id': ?tmdbId,
      'title': ?title,
      'original_title': ?originalTitle,
      'description': ?description,
      'poster_url': ?posterUrl,
      'type': ?type,
      'date': ?date?.toIso8601String(),
      'end': ?end?.toIso8601String(),
      'rating': ?rating,
      'run_time': ?runTime,
      'genres': ?genres,
      'episode_count': ?episodeCount,
      'season_count': ?seasonCount,
      'status': ?status,
      'tag': ?tag,
      'seasons': seasonsDto.map((season) => season.toCreateJson()).toList(),
      'fieldsVersion': fieldsVersion,
    };
  }

  static List<String> get encodedFields => ['fieldsVersion', 'genres'];

  final String id;
  String? list;
  String? tmdbId;
  String? title;
  String? originalTitle;
  String? description;
  String? posterUrl;
  String? type;
  DateTime? date;
  DateTime? end;
  double? rating;
  int? runTime;
  List<String>? genres;
  int? episodeCount;
  int? seasonCount;
  String? status;
  String? tag;
  List<SeasonDto> seasonsDto;
  Map<String, num> fieldsVersion;
}
