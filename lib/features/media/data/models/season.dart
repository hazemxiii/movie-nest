import 'package:movie_nest/core/exceptions/nest_secret_exception.dart';
import 'package:movie_nest/core/services/nest_logger.dart';
import 'package:movie_nest/features/media/data/models/dtos/season_dto.dart';

class Season {
  factory Season.fromJson(dynamic json) {
    try {
      json = Map<String, dynamic>.from(json);
      return Season(
        number: json['number'] as int,
        episodeCount: json['episode_count'] as int,
        name: json['name'] as String?,
        description: json['description'] as String?,
        posterUrl: json['poster_url'] as String?,
        media: json['media'] as String,
        watchedEpisodes:
            (json['watched_episodes'] as List<dynamic>?)
                ?.map((e) => e as int)
                .toList() ??
            [],
        fieldsVersion: (json['fieldsVersion'] as Map<String, dynamic>?)?.map(
          (key, value) => MapEntry(key, value as int),
        ),
        version: json['version'] as int? ?? 1,
      );
    } catch (e) {
      final error = NestSecretException('0xSN');
      NestLogger.logError(e.toString(), code: error.objectCode);
      throw error;
    }
  }
  Season({
    required this.number,
    required this.episodeCount,
    this.name,
    required this.watchedEpisodes,
    this.description,
    this.posterUrl,
    required this.media,
    this.fieldsVersion,
    this.version = 1,
  });

  Season copyWithDto(SeasonDto dto) {
    return Season(
      number: dto.number,
      episodeCount: dto.episodeCount ?? episodeCount,
      name: dto.name,
      description: dto.description,
      posterUrl: dto.posterUrl,
      media: dto.media ?? media,
      fieldsVersion: dto.fieldsVersion,
      watchedEpisodes: dto.watchedEpisodes ?? watchedEpisodes,
    );
  }

  final int number;
  final int episodeCount;
  final List<int> watchedEpisodes;
  final String? name;
  final String? description;
  final String? posterUrl;
  final String media;
  final Map<String, int>? fieldsVersion;
  final int version;

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'episode_count': episodeCount,
      'name': name,
      'description': description,
      'poster_url': posterUrl,
      'media': media,
      'fieldsVersion': fieldsVersion,
      'version': version,
    };
  }

  SeasonDto toDto() {
    return SeasonDto(
      number: number,
      episodeCount: episodeCount,
      name: name,
      description: description,
      posterUrl: posterUrl,
      watchedEpisodes: watchedEpisodes,
      media: media,
      fieldsVersion: fieldsVersion ?? {},
    );
  }

  Season copyWith({
    int? number,
    int? episodeCount,
    String? name,
    String? description,
    String? posterUrl,
    String? media,
    Map<String, int>? fieldsVersion,
    int? version,
    List<int>? watchedEpisodes,
  }) {
    return Season(
      number: number ?? this.number,
      episodeCount: episodeCount ?? this.episodeCount,
      name: name ?? this.name,
      description: description ?? this.description,
      posterUrl: posterUrl ?? this.posterUrl,
      media: media ?? this.media,
      fieldsVersion: fieldsVersion ?? this.fieldsVersion,
      version: version ?? this.version,
      watchedEpisodes: watchedEpisodes ?? this.watchedEpisodes,
    );
  }
}
