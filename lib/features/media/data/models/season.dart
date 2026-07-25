import 'package:movie_nest/core/exceptions/nest_secret_exception.dart';
import 'package:movie_nest/core/services/nest_logger.dart';

class Season {
  Season({
    required this.number,
    required this.episodeCount,
    this.name,
    required this.watchedEpisodes,
    this.description,
    this.posterUrl,
    required this.media,
    this.fieldVersions,
    this.version = 1,
  });

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
        fieldVersions: (json['fieldVersions'] as Map<String, dynamic>?)?.map(
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

  final int number;
  final int episodeCount;
  final List<int> watchedEpisodes;
  final String? name;
  final String? description;
  final String? posterUrl;
  final String media;
  final Map<String, int>? fieldVersions;
  final int version;

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'episode_count': episodeCount,
      'name': name,
      'description': description,
      'poster_url': posterUrl,
      'media': media,
      'fieldVersions': fieldVersions,
      'version': version,
    };
  }

  Season copyWith({
    int? number,
    int? episodeCount,
    String? name,
    String? description,
    String? posterUrl,
    String? media,
    Map<String, int>? fieldVersions,
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
      fieldVersions: fieldVersions ?? this.fieldVersions,
      version: version ?? this.version,
      watchedEpisodes: watchedEpisodes ?? this.watchedEpisodes,
    );
  }
}
