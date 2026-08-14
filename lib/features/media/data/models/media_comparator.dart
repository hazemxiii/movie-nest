import 'package:movie_nest/features/media/data/models/media.dart';

class MediaComparator {
  MediaComparator(Media media1, Media media2) {
    title = _compareText(media1.title, media2.title);
    originalTitle = _compareText(media1.originalTitle, media2.originalTitle);
    description = _compareText(media1.description, media2.description);
    tag = _compareText(media1.tag, media2.tag);
    status = _compareText(media1.status, media2.status);
    rating = media1.rating != media2.rating;
    runTime = media1.runTime != media2.runTime;
    posterUrl = _compareText(media1.posterUrl, media2.posterUrl);
    date = _compareDates(media1.date, media2.date);
    end = _compareDates(media1.end, media2.end);
    genres = _compareText(media1.genres.join(','), media2.genres.join(','));
    episodeCount = media1.episodeCount != media2.episodeCount;
    seasonCount = media1.seasonCount != media2.seasonCount;
    lastAirDate = _compareDates(media1.lastAirDate, media2.lastAirDate);
    nextAirDate = _compareDates(media1.nextAirDate, media2.nextAirDate);
  }
  late final bool title;
  late final bool originalTitle;
  late final bool description;
  late final bool tag;
  late final bool status;
  late final bool rating;
  late final bool runTime;
  late final bool posterUrl;
  late final bool date;
  late final bool end;
  late final bool genres;
  late final bool episodeCount;
  late final bool seasonCount;
  late final bool lastAirDate;
  late final bool nextAirDate;

  bool _compareDates(DateTime? date1, DateTime? date2) {
    if (date1 == null && date2 == null) {
      return false;
    }
    if (date1 == null || date2 == null) {
      return true;
    }
    return date1.compareTo(date2) != 0;
  }

  bool _compareText(String text1, String text2) {
    return text1.trim().toLowerCase().compareTo(text2.trim().toLowerCase()) !=
        0;
  }

  int get changesCount {
    int count = 0;
    if (title) count++;
    if (originalTitle) count++;
    if (description) count++;
    if (tag) count++;
    if (status) count++;
    if (rating) count++;
    if (runTime) count++;
    if (posterUrl) count++;
    if (date) count++;
    if (end) count++;
    if (genres) count++;
    if (episodeCount) count++;
    if (seasonCount) count++;
    if (lastAirDate) count++;
    if (nextAirDate) count++;
    return count;
  }
}
