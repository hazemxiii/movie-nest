import 'package:movie_nest/core/exceptions/nest_secret_exception.dart';
import 'package:movie_nest/core/services/nest_logger.dart';
import 'package:movie_nest/features/media/data/models/dtos/media_dto.dart';
import 'package:movie_nest/features/media/data/models/dtos/season_dto.dart';
import 'package:movie_nest/features/media/data/models/season.dart';

class Media {
  const Media({
    required this.id,
    required this.list,
    required this.tmdbId,
    required this.title,
    this._originalTitle,
    required this.description,
    required this.posterUrl,
    required this.type,
    required this.date,
    this.end,
    this.rating = 0,
    required this.runTime,
    this.genres = const [],
    this.episodeCount,
    this.seasonCount,
    required this.status,
    required this.tag,
    this.fieldsVersion,
    this.version = 1,
    required this.seasons,
    this.lastAirDate,
    this.nextAirDate,
  });

  factory Media.empty() {
    return Media(
      id: '',
      list: '',
      tmdbId: '',
      title: '',
      description: '',
      posterUrl: '',
      type: '',
      date: DateTime.now(),
      rating: 0,
      runTime: 0,
      genres: [],
      status: '',
      tag: '',
      seasons: [],
    );
  }

  factory Media.fromJson(dynamic json) {
    try {
      json = Map<String, dynamic>.from(json);
      return Media(
        id: (json['_id'] ?? json['id']) as String,
        list: (json['list'] ?? json['listId']) as String,
        tmdbId: json['tmdb_id'] as String,
        title: json['title'] as String,
        originalTitle: json['original_title'] as String?,
        description: json['description'] as String,
        posterUrl: json['poster_url'] as String,
        lastAirDate: json['last_air_date'] != null
            ? DateTime.parse(json['last_air_date'] as String)
            : null,
        nextAirDate: json['next_air_date'] != null
            ? DateTime.parse(json['next_air_date'] as String)
            : null,
        type: json['type'] as String,
        date: DateTime.parse(json['date'] as String),
        end: json['end'] != null ? DateTime.parse(json['end'] as String) : null,
        rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
        runTime: json['run_time'] as int,
        genres: (json['genres'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
        episodeCount: json['episode_count'] as int?,
        seasonCount: json['season_count'] as int?,
        status: json['status'] as String,
        tag: json['tag'] as String,
        fieldsVersion: json['fieldsVersion'] != null
            ? Map<String, num>.from(json['fieldsVersion'] as Map)
            : null,
        version: json['version'] ?? 1,
        seasons: [],
      );
    } catch (e) {
      final error = NestSecretException('0xMD');
      NestLogger.logError(e.toString(), code: error.objectCode);
      throw error;
    }
  }

  final String id;
  final String list;
  final String tmdbId;
  final String title;
  final String? _originalTitle;
  final String description;
  final String posterUrl;
  final String type;
  final DateTime? lastAirDate;
  final DateTime? nextAirDate;
  final DateTime date;
  final DateTime? end;
  final double rating;
  final int runTime;
  final List<String> genres;
  final int? episodeCount;
  final int? seasonCount;
  final String status;
  final String tag;
  final List<Season> seasons;
  final Map<String, num>? fieldsVersion;
  final int version;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'list': list,
      'tmdb_id': tmdbId,
      'title': title,
      'original_title': _originalTitle,
      'description': description,
      'poster_url': posterUrl,
      'type': type,
      'date': date.toIso8601String(),
      'end': end?.toIso8601String(),
      'last_air_date': lastAirDate?.toIso8601String(),
      'next_air_date': nextAirDate?.toIso8601String(),
      'rating': rating,
      'run_time': runTime,
      'genres': genres,
      'episode_count': episodeCount,
      'season_count': seasonCount,
      'status': status,
      'tag': tag,
      'fieldsVersion': fieldsVersion,
      'version': version,
    };
  }

  Media copyWith({
    String? id,
    String? list,
    String? tmdbId,
    String? title,
    String? originalTitle,
    String? description,
    String? posterUrl,
    String? type,
    DateTime? date,
    DateTime? end,
    DateTime? lastAirDate,
    DateTime? nextAirDate,
    double? rating,
    int? runTime,
    List<String>? genres,
    int? episodeCount,
    int? seasonCount,
    String? status,
    String? tag,
    List<Season>? seasons,
    Map<String, num>? fieldsVersion,
    int? version,
  }) {
    return Media(
      id: id ?? this.id,
      list: list ?? this.list,
      tmdbId: tmdbId ?? this.tmdbId,
      title: title ?? this.title,
      originalTitle: originalTitle ?? _originalTitle,
      description: description ?? this.description,
      posterUrl: posterUrl ?? this.posterUrl,
      type: type ?? this.type,
      date: date ?? this.date,
      end: end ?? this.end,
      lastAirDate: lastAirDate ?? this.lastAirDate,
      nextAirDate: nextAirDate ?? this.nextAirDate,
      rating: rating ?? this.rating,
      runTime: runTime ?? this.runTime,
      genres: genres ?? this.genres,
      episodeCount: episodeCount ?? this.episodeCount,
      seasonCount: seasonCount ?? this.seasonCount,
      status: status ?? this.status,
      tag: tag ?? this.tag,
      fieldsVersion: fieldsVersion ?? this.fieldsVersion,
      version: version ?? this.version,
      seasons: seasons ?? this.seasons,
    );
  }

  Media copyWithDto(MediaDto dto) {
    final seasonsDtoNum = <int, SeasonDto>{};
    for (var s in dto.seasonsDto) {
      seasonsDtoNum[s.number] = s;
    }

    return Media(
      id: dto.id,
      list: dto.list ?? list,
      tmdbId: dto.tmdbId ?? tmdbId,
      title: dto.title ?? title,
      originalTitle: dto.originalTitle ?? originalTitle,
      description: dto.description ?? description,
      posterUrl: dto.posterUrl ?? posterUrl,
      type: dto.type ?? type,
      date: dto.date ?? date,
      end: dto.end ?? end,
      lastAirDate: dto.lastAirDate ?? lastAirDate,
      nextAirDate: dto.nextAirDate ?? nextAirDate,
      rating: dto.rating ?? rating,
      runTime: dto.runTime ?? runTime,
      genres: dto.genres ?? genres,
      episodeCount: dto.episodeCount ?? episodeCount,
      seasonCount: dto.seasonCount ?? seasonCount,
      status: dto.status ?? status,
      tag: dto.tag ?? tag,
      fieldsVersion: dto.fieldsVersion,
      version: version,
      seasons: seasons.map((s) {
        final dto = seasonsDtoNum[s.number];
        if (dto == null) return s;
        return s.copyWithDto(dto);
      }).toList(),
    );
  }

  MediaDto toDto() {
    return MediaDto(
      id: id,
      list: list,
      tmdbId: tmdbId,
      title: title,
      originalTitle: _originalTitle,
      description: description,
      posterUrl: posterUrl,
      type: type,
      date: date,
      end: end,
      lastAirDate: lastAirDate,
      nextAirDate: nextAirDate,
      rating: rating,
      runTime: runTime,
      genres: genres,
      episodeCount: episodeCount,
      seasonCount: seasonCount,
      status: status,
      tag: tag,
      seasonsDto: seasons.map((s) => s.toDto()).toList(),
      fieldsVersion: fieldsVersion ?? {},
    );
  }

  String get originalTitle => _originalTitle ?? title;
  bool get isTv =>
      type.toLowerCase() == 'tv' && episodeCount != null && seasonCount != null;
  bool isEpisodeWatched(int season, int episode) {
    if (!isTv) return false;
    try {
      final seasonData = seasons.firstWhere((s) => s.number == season);
      return seasonData.watchedEpisodes.contains(episode);
    } catch (e) {
      return false;
    }
  }

  MediaProgress get progress {
    if (!isTv) return MediaProgress(totalEpisodes: 0, totalWatched: 0);
    int totalEpisodes = 0;
    int totalWatched = 0;
    for (final s in seasons) {
      if (s.number == 0) continue;
      totalEpisodes += s.episodeCount;
      totalWatched += s.watchedEpisodes.length;
    }
    return MediaProgress(
      totalEpisodes: totalEpisodes,
      totalWatched: totalWatched,
    );
  }
}

class MediaProgress {
  MediaProgress({required this.totalEpisodes, required this.totalWatched});
  final int totalEpisodes;
  final int totalWatched;

  double get progress => totalEpisodes > 0 ? totalWatched / totalEpisodes : 0.0;
}
