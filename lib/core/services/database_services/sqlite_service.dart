import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movie_nest/core/exceptions/nest_secret_exception.dart';
import 'package:movie_nest/core/services/database_services/migrations/add_next_last_air_dates.dart';
import 'package:movie_nest/core/services/database_services/migrations/migration.dart';
import 'package:movie_nest/core/services/nest_logger.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class SqliteService {
  SqliteService();

  late final Database _database;

  final String nestListTable = 'nest_lists';
  final String mediaTable = 'media';
  final String seasonsTable = 'seasons';
  final String migrationTable = 'migrations';

  final Map<String, List<String>> encodedFields = {
    'nest_lists': ['fieldsVersion'],
    'media': ['genres', 'fieldsVersion'],
    'seasons': ['fieldsVersion', 'watched_episodes'],
  };

  List<Migration> get migrations => [AddNextLastAirDates()];

  Future<void> init() async {
    final databaseFactory = databaseFactoryFfi;
    final io.Directory appDocumentsDir =
        await getApplicationDocumentsDirectory();
    final dbPath = p.join(appDocumentsDir.path, 'movie-nest', 'db.db');
    NestLogger.log('Database path: $dbPath');
    _database = await databaseFactory.openDatabase(dbPath);
    await _createTables();
    await _runMigrations();
  }

  Future<void> _runMigrations() async {
    final appliedMigrationsNames = await query(
      migrationTable,
    ).then((rows) => rows.map((row) => row['name'] as String).toList());
    for (final migration in migrations) {
      if (appliedMigrationsNames.contains(migration.name)) {
        continue;
      }
      await migration.migrate(_database);
      await insert(migrationTable, {
        'name': migration.name,
        'applied_at': DateTime.now().toUtc().toIso8601String(),
      });
    }
  }

  Future<void> _createTables() async {
    await _database.execute('''
    CREATE TABLE IF NOT EXISTS migrations (
    name TEXT PRIMARY KEY,
    applied_at TEXT NOT NULL
);
''');

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
    await _database.execute('''
    CREATE TABLE IF NOT EXISTS media (
    id TEXT PRIMARY KEY,
    listId TEXT NOT NULL,
    tmdb_id TEXT NOT NULL,
    title TEXT NOT NULL,
    original_title TEXT,
    description TEXT NOT NULL,
    poster_url TEXT NOT NULL,
    type TEXT NOT NULL,
    date TEXT NOT NULL,
    end TEXT,
    rating REAL NOT NULL DEFAULT 0,
    run_time INTEGER NOT NULL,
    genres TEXT DEFAULT '[]',
    episode_count INTEGER,
    season_count INTEGER,
    status TEXT NOT NULL,
    tag TEXT NOT NULL,
    fieldsVersion TEXT DEFAULT '{}'
);
''');
    await _database.execute('''
  CREATE TABLE IF NOT EXISTS seasons (
    id TEXT PRIMARY KEY,
    media TEXT NOT NULL,
    number INTEGER NOT NULL,
    episode_count INTEGER NOT NULL,
    name TEXT,
    description TEXT,
    poster_url TEXT,
    watched_episodes TEXT DEFAULT '[]',
    fieldsVersion TEXT DEFAULT '{}'
);
''');
  }

  Future<void> insert(
    String table,
    Map<String, dynamic> values, {
    List<String> encodeFields = const [],
  }) async {
    final encode = encodedFields[table] ?? [];
    try {
      for (final field in encode) {
        if (values.containsKey(field)) {
          values[field] = jsonEncode(values[field]);
        }
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
    List<String> encodeFields = const [],
  }) async {
    try {
      final encode = encodedFields[table] ?? [];
      for (final field in encode) {
        if (values.containsKey(field)) {
          values[field] = jsonEncode(values[field]);
        }
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
    List<String> decodeFields = const [],
  }) async {
    try {
      final decode = encodedFields[table] ?? [];
      NestLogger.log('Querying $table where: $where whereArgs: $whereArgs');
      final query = await _database.query(
        table,
        where: where,
        whereArgs: whereArgs,
      );
      return query.map((e) {
        final out = Map<String, dynamic>.from(e);
        for (final field in decode) {
          if (out.containsKey(field)) {
            out[field] = jsonDecode(out[field].toString());
          }
        }
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
