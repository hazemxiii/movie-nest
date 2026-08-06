class SeasonDto {
  SeasonDto({
    required this.number,
    this.episodeCount,
    this.name,
    this.description,
    this.posterUrl,
    this.media,
    this.watchedEpisodes,
    required this.fieldsVersion,
  });

  Map<String, dynamic> toCreateJson() {
    return {
      'number': number,
      'episode_count': ?episodeCount,
      'name': ?name,
      'description': ?description,
      'poster_url': ?posterUrl,
      'media': ?media,
      'fieldsVersion': {},
      'watched_episodes': ?watchedEpisodes,
    };
  }

  static List<String> get encodedFields => [
    'fieldsVersion',
    'watched_episodes',
  ];

  late int number;
  int? episodeCount;
  String? name;
  String? description;
  String? posterUrl;
  String? media;
  List<int>? watchedEpisodes = [];
  Map<String, int> fieldsVersion;
}
