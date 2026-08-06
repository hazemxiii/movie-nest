import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/exceptions/nest_exception.dart';
import 'package:movie_nest/core/services/database_services/sqlite_service.dart';
import 'package:movie_nest/features/media/data/models/dtos/media_dto.dart';
import 'package:movie_nest/features/media/data/models/dtos/season_dto.dart';
import 'package:movie_nest/features/media/data/models/media.dart';
import 'package:movie_nest/features/media/data/models/season.dart';
import 'package:movie_nest/features/nest_list/data/datasources/nest_list_datasource.dart';
import 'package:movie_nest/features/nest_list/data/models/nest_list.dart';
import 'package:movie_nest/features/nest_list/data/models/nest_list_dto.dart';

class LocalNestListDatasource extends NestListDatasource {
  LocalNestListDatasource({required this._sqliteService});

  final SqliteService _sqliteService;
  @override
  Future<void> create(NestListDto list) async {
    final existingList = await _sqliteService.query(
      _sqliteService.nestListTable,
      where: 'id = ?',
      whereArgs: [list.id],
    );

    if (existingList.isNotEmpty) {
      throw NestException('List with id ${list.id} already exists');
    }
    await _sqliteService.insert(
      _sqliteService.nestListTable,
      list.toCreateJson(),
    );
  }

  @override
  Future<NestList> getPublicNestList(String listId) {
    throw NestException('Public nest lists are not supported in local mode');
  }

  @override
  Future<List<NestList>> getPrivateListCollectionSummary() async {
    final results = await _sqliteService.query(_sqliteService.nestListTable);
    return results.map(NestList.fromJson).toList();
  }

  @override
  Future<void> delete(String listId, {String? moveToListId}) async {
    if (moveToListId == null) {
      final mediaMap = await _sqliteService.query(
        _sqliteService.mediaTable,
        where: 'listId = ?',
        whereArgs: [listId],
      );
      final mediaIds = <String>{};
      for (final media in mediaMap) {
        mediaIds.add(media['id'] as String);
      }
      await _sqliteService.delete(
        _sqliteService.seasonsTable,
        where: 'media IN (${mediaIds.map((id) => '?').join(',')})',
        whereArgs: mediaIds.toList(),
      );
      await _sqliteService.delete(
        _sqliteService.mediaTable,
        where: 'listId = ?',
        whereArgs: [listId],
      );
    } else {
      await _sqliteService.update(
        _sqliteService.mediaTable,
        {'listId': moveToListId},
        where: 'listId = ?',
        whereArgs: [listId],
      );
    }
    await _sqliteService.delete(
      _sqliteService.nestListTable,
      where: 'id = ?',
      whereArgs: [listId],
    );
  }

  @override
  Future<NestList> update(String listId, NestListDto list) async {
    await _sqliteService.update(
      _sqliteService.nestListTable,
      list.toUpdateJson(),
      where: 'id = ?',
      whereArgs: [listId],
    );
    final updatedList = await _sqliteService.query(
      _sqliteService.nestListTable,
      where: 'id = ?',
      whereArgs: [listId],
    );
    return NestList.fromJson(updatedList.first);
  }

  @override
  Future<NestList> getPrivateNestList(String listId) async {
    final mediaMap = await _sqliteService.query(
      _sqliteService.mediaTable,
      where: 'listId = ?',
      whereArgs: [listId],
      decodeFields: MediaDto.encodedFields,
    );
    final media = <Media>[];
    for (final m in mediaMap) {
      final seasons = <Season>[];
      final mediaMapUpdated = Map<String, dynamic>.from(m);
      mediaMapUpdated['list'] = listId;
      final seasonsMap = await _sqliteService.query(
        _sqliteService.seasonsTable,
        where: 'media = ?',
        whereArgs: [m['id']],
        decodeFields: SeasonDto.encodedFields,
      );
      for (final s in seasonsMap) {
        seasons.add(Season.fromJson(s));
      }
      media.add(Media.fromJson(mediaMapUpdated).copyWith(seasons: seasons));
    }
    final listDoc = (await _sqliteService.query(
      _sqliteService.nestListTable,
      where: 'id = ?',
      whereArgs: [listId],
    )).first;
    return NestList.fromJson(listDoc).copyWith(media: media);
  }
}

final localNestListDatasourceProvider = Provider<LocalNestListDatasource>((
  ref,
) {
  return LocalNestListDatasource(
    sqliteService: ref.read(sqliteServiceProvider),
  );
});
