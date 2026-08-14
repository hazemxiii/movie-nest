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
    // this.end,
    // this.lastAirDate,
    // this.nextAirDate,
    DateTime? end,
    DateTime? lastAirDate,
    DateTime? nextAirDate,
    this.rating,
    this.runTime,
    this.genres,
    this.episodeCount,
    this.seasonCount,
    this.status,
    this.tag,
    required this.seasonsDto,
    required this.fieldsVersion,
  }) {
    _end = NullablePatchField(end);
    _lastAirDate = NullablePatchField(lastAirDate);
    _nextAirDate = NullablePatchField(nextAirDate);
  }

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
      if (_end.isSet) 'end': _end.value?.toIso8601String(),
      if (_lastAirDate.isSet)
        'last_air_date': _lastAirDate.value?.toIso8601String(),
      if (_nextAirDate.isSet)
        'next_air_date': _nextAirDate.value?.toIso8601String(),
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
  // DateTime? end;
  // DateTime? lastAirDate;
  // DateTime? nextAirDate;
  late NullablePatchField<DateTime> _end;
  late NullablePatchField<DateTime> _lastAirDate;
  late NullablePatchField<DateTime> _nextAirDate;
  double? rating;
  int? runTime;
  List<String>? genres;
  int? episodeCount;
  int? seasonCount;
  String? status;
  String? tag;
  List<SeasonDto> seasonsDto;
  Map<String, num> fieldsVersion;

  NullablePatchField<DateTime> get end => _end;
  NullablePatchField<DateTime> get lastAirDate => _lastAirDate;
  NullablePatchField<DateTime> get nextAirDate => _nextAirDate;

  set end(DateTime? value) {
    _end.value = value;
    _end.isSet = true;
  }

  set lastAirDate(DateTime? value) {
    _lastAirDate.value = value;
    _lastAirDate.isSet = true;
  }

  set nextAirDate(DateTime? value) {
    _nextAirDate.value = value;
    _nextAirDate.isSet = true;
  }
}

class NullablePatchField<T> {
  NullablePatchField(this.value) {
    isSet = value != null;
  }
  T? value;
  bool isSet = false;
}
