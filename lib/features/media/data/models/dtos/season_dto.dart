class SeasonDto {
  SeasonDto({
    required this.number,
    this.episodeCount,
    this.name,
    this.description,
    this.posterUrl,
    this.media,
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
    };
  }

  void addWatchedEpisode(int episodeNumber) {
    addedWatchedEpisodes.add(episodeNumber);
    removedWatchedEpisodes.remove(episodeNumber);
  }

  void removeWatchedEpisode(int episodeNumber) {
    removedWatchedEpisodes.add(episodeNumber);
    addedWatchedEpisodes.remove(episodeNumber);
  }

  static List<String> get encodedFields => [
    'fieldsVersion',
    'watched_episodes',
  ];

  late final int number;
  int? episodeCount;
  List<int> addedWatchedEpisodes = [];
  List<int> removedWatchedEpisodes = [];
  String? name;
  String? description;
  String? posterUrl;
  String? media;
  Map<String, int> fieldsVersion;
}
