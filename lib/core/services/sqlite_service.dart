import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class SqliteService {
  SqliteService();

  late final Database _database;

  Future<void> init() async {
    final databaseFactory = databaseFactoryFfi;
    final io.Directory appDocumentsDir =
        await getApplicationDocumentsDirectory();
    final dbPath = p.join(appDocumentsDir.path, 'movie-nest', 'db.db');
    _database = await databaseFactory.openDatabase(dbPath);
    await _createTables();
  }

  Future<void> _createTables() async {
    // Drop all tables
    await _database.execute('DROP TABLE IF EXISTS nest_lists');

    await _database.execute('''
    CREATE TABLE IF NOT EXISTS nest_lists (
    _id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    date TEXT,
    fieldsVersion TEXT NOT NULL
);
  ''');
  }

  Future<void> insert(String table, Map<String, dynamic> values) async {
    values['fieldsVersion'] = jsonEncode(values['fieldsVersion']);
    await _database.insert(table, values);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
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
  }
}

final sqliteServiceProvider = Provider<SqliteService>((ref) {
  return SqliteService();
});
