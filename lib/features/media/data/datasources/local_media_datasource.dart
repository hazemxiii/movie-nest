import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/exceptions/nest_exception.dart';
import 'package:movie_nest/core/services/sqlite_service.dart';
import 'package:movie_nest/features/media/data/datasources/media_datasource.dart';
import 'package:movie_nest/features/media/data/models/dtos/media_dto.dart';
import 'package:movie_nest/features/media/data/models/dtos/season_dto.dart';
import 'package:movie_nest/features/media/data/models/media.dart';
import 'package:movie_nest/features/media/data/models/season.dart';

class LocalMediaDatasource extends MediaDatasource {
  LocalMediaDatasource({required this._sqliteService});
  final SqliteService _sqliteService;

  @override
  Future<void> createMedia(MediaDto dto) async {
    final seasonDtos = dto.seasonsDto;
    final createJson = dto.toJson();
    createJson.remove('seasons');
    await _sqliteService.insert(
      'media',
      createJson,
      encodeFields: MediaDto.encodedFields,
    );
    for (final seasonDto in seasonDtos) {
      await _sqliteService.insert(
        'seasons',
        seasonDto.toCreateJson(),
        encodeFields: SeasonDto.encodedFields,
      );
    }
  }

  @override
  Future<Media> update(MediaDto dto) async {
    final seasonDtos = dto.seasonsDto;
    final updateJson = dto.toJson();
    updateJson.remove('seasons');
    await _sqliteService.update(
      'media',
      updateJson,
      where: 'id = ?',
      whereArgs: [dto.id],
    );
    final oldSeasonsNumbers = (await _sqliteService.query(
      'seasons',
      where: 'media = ?',
      whereArgs: [dto.id],
    )).map((e) => e['number'] as int).toSet();
    for (final seasonDto in seasonDtos) {
      if (oldSeasonsNumbers.contains(seasonDto.number)) {
        await _sqliteService.update(
          'seasons',
          seasonDto.toCreateJson(),
          where: 'number = ? AND media = ?',
          whereArgs: [seasonDto.number, dto.id],
        );
        oldSeasonsNumbers.remove(seasonDto.number);
      } else {
        await _sqliteService.insert(
          'seasons',
          seasonDto.toCreateJson(),
          encodeFields: SeasonDto.encodedFields,
        );
      }
    }
    for (final number in oldSeasonsNumbers) {
      await _sqliteService.delete(
        'seasons',
        where: 'number = ? AND media = ?',
        whereArgs: [number, dto.id],
      );
    }
    return await getPrivateMedia(dto.id);
  }

  @override
  Future<Media> getPublicMedia(String tmdbId, bool isTv) {
    throw NestException('Cannot get public media from local datasource');
  }

  @override
  Future<Media> getPrivateMedia(String mediaId) async {
    final mediaDoc = await _sqliteService.query(
      _sqliteService.mediaTable,
      where: 'id = ?',
      whereArgs: [mediaId],
      decodeFields: MediaDto.encodedFields,
    );
    if (mediaDoc.isEmpty) {
      throw NestException('Media not found');
    }
    final seasonsMap = await _sqliteService.query(
      _sqliteService.seasonsTable,
      where: 'media = ?',
      whereArgs: [mediaId],
      decodeFields: SeasonDto.encodedFields,
    );
    final seasons = <Season>[];
    for (final s in seasonsMap) {
      seasons.add(Season.fromJson(s));
    }
    return Media.fromJson(mediaDoc.first).copyWith(seasons: seasons);
  }

  @override
  Future<Season> toggleEpisode(
    String mediaId,
    int seasonNumber,
    List<int> added,
    List<int> removed,
  ) async {
    final oldSeasonDoc = (await _sqliteService.query(
      _sqliteService.seasonsTable,
      where: 'media = ? AND number = ?',
      whereArgs: [mediaId, seasonNumber],
      decodeFields: SeasonDto.encodedFields,
    )).firstOrNull;
    if (oldSeasonDoc == null) {
      throw NestException('Season not found');
    }
    final oldSeason = Season.fromJson(oldSeasonDoc);
    final oldEpisodes = oldSeason.watchedEpisodes;
    final newEpisodes = [...oldEpisodes, ...added];
    for (final episode in removed) {
      newEpisodes.remove(episode);
    }
    final newSeason = oldSeason.copyWith(watchedEpisodes: newEpisodes);
    _sqliteService.update(
      _sqliteService.seasonsTable,
      {'watched_episodes': newEpisodes},
      where: 'media = ? AND number = ?',
      whereArgs: [mediaId, seasonNumber],
    );
    return newSeason;
  }

  @override
  Future<void> delete(String mediaId) async {
    await _sqliteService.delete(
      _sqliteService.seasonsTable,
      where: 'media = ?',
      whereArgs: [mediaId],
    );
    await _sqliteService.delete(
      _sqliteService.mediaTable,
      where: 'id = ?',
      whereArgs: [mediaId],
    );
  }
}

final localMediaDatasourceProvider = Provider<LocalMediaDatasource>((ref) {
  return LocalMediaDatasource(sqliteService: ref.read(sqliteServiceProvider));
});
