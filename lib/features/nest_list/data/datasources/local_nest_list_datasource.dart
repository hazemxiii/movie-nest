import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/exceptions/nest_exception.dart';
import 'package:movie_nest/core/services/sqlite_service.dart';
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
    await _sqliteService.delete(
      _sqliteService.nestListTable,
      where: 'id = ?',
      whereArgs: [listId],
    );
    // TODO delete media too
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
}

final localNestListDatasourceProvider = Provider<LocalNestListDatasource>((
  ref,
) {
  return LocalNestListDatasource(
    sqliteService: ref.read(sqliteServiceProvider),
  );
});
