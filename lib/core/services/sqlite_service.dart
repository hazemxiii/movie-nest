import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/exceptions/nest_secret_exception.dart';
import 'package:movie_nest/core/services/nest_logger.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class SqliteService {
  SqliteService();

  late final Database _database;

  final String nestListTable = 'nest_lists';

  Future<void> init() async {
    final databaseFactory = databaseFactoryFfi;
    final io.Directory appDocumentsDir =
        await getApplicationDocumentsDirectory();
    final dbPath = p.join(appDocumentsDir.path, 'movie-nest', 'db.db');
    NestLogger.log('Database path: $dbPath');
    _database = await databaseFactory.openDatabase(dbPath);
    await _createTables();
  }

  Future<void> _createTables() async {
    await _database.execute('''
    CREATE TABLE IF NOT EXISTS nest_lists (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    date TEXT,
    fieldsVersion TEXT NOT NULL
);
  ''');
    await _database.execute('''
    CREATE TABLE IF NOT EXISTS sync_queue (
    id TEXT PRIMARY KEY,
    type TEXT NOT NULL,
    entityType TEXT NOT NULL,
    entityId TEXT NOT NULL,
    url TEXT NOT NULL,
    tries INTEGER NOT NULL DEFAULT 0,
    method TEXT NOT NULL,
    body TEXT NOT NULL,
    createdAt TEXT NOT NULL
);
  ''');
  }

  Future<void> insert(String table, Map<String, dynamic> values) async {
    try {
      if (values.containsKey('fieldsVersion')) {
        values['fieldsVersion'] = jsonEncode(values['fieldsVersion']);
      }
      NestLogger.log('Inserting into $table: $values');
      await _database.insert(table, values);
    } catch (e) {
      NestLogger.logError(e.toString());
      throw NestSecretException('DB_INS');
    }
  }

  Future<void> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    try {
      if (values.containsKey('fieldsVersion')) {
        values['fieldsVersion'] = jsonEncode(values['fieldsVersion']);
      }
      NestLogger.log(
        'Updating $table with values: $values where: $where whereArgs: $whereArgs',
      );
      await _database.update(table, values, where: where, whereArgs: whereArgs);
    } catch (e) {
      NestLogger.logError(e.toString());
      throw NestSecretException('DB_UPD');
    }
  }

  Future<void> clearTable(String table) async {
    try {
      NestLogger.log('Clearing table: $table');
      await _database.delete(table);
    } catch (e) {
      NestLogger.logError(e.toString());
      throw NestSecretException('DB_CLR');
    }
  }

  Future<void> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    try {
      NestLogger.log(
        'Deleting from $table where: $where whereArgs: $whereArgs',
      );
      await _database.delete(table, where: where, whereArgs: whereArgs);
    } catch (e) {
      NestLogger.logError(e.toString());
      throw NestSecretException('DB_DEL');
    }
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    try {
      NestLogger.log('Querying $table where: $where whereArgs: $whereArgs');
      final query = await _database.query(
        table,
        where: where,
        whereArgs: whereArgs,
      );
      return query.map((e) {
        final out = Map<String, dynamic>.from(e);
        out['fieldsVersion'] = jsonDecode(e['fieldsVersion'].toString());
        return out;
      }).toList();
    } catch (e) {
      NestLogger.logError(e.toString());
      throw NestSecretException('DB_QRY');
    }
  }
}

final sqliteServiceProvider = Provider<SqliteService>((ref) {
  return SqliteService();
});
