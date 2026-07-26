import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/services/sqlite_service.dart';
import 'package:movie_nest/features/sync/data/datasources/sync_queue_datasource.dart';
import 'package:movie_nest/features/sync/data/models/sync_queue.dart';

class LocalSyncQueueDatasource implements SyncQueueDatasource {
  LocalSyncQueueDatasource(this._sqliteService);
  final SqliteService _sqliteService;
  @override
  Future<void> addOperation(SyncOperation operation) async {
    await _sqliteService.insert('sync_queue', operation.toMap());
  }

  @override
  Future<void> clearQueue() async {
    await _sqliteService.clearTable('sync_queue');
  }

  @override
  Future<List<SyncOperation>> getOperations() async {
    final operations = await _sqliteService.query('sync_queue');
    return operations.map(SyncOperation.fromMap).toList();
  }

  @override
  Future<void> removeOperation(String id) async {
    await _sqliteService.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> incrementTries(String id) async {
    final operation = await _sqliteService.query(
      'sync_queue',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (operation.isEmpty) {
      return;
    }
    final tries = operation.first['tries'] as int;
    await _sqliteService.update(
      'sync_queue',
      {'tries': tries + 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<bool> hasOperations() async {
    final operations = await getOperations();
    return operations.isNotEmpty;
  }
}

final localSyncQueueDatasourceProvider = Provider<LocalSyncQueueDatasource>((
  ref,
) {
  return LocalSyncQueueDatasource(ref.read(sqliteServiceProvider));
});
