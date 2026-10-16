import 'package:movie_nest/core/services/database_services/migrations/migration.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class RemoveNonNullOnMediaDate extends Migration {
  RemoveNonNullOnMediaDate() : super(name: 'remove_non_null_on_media_date');

  @override
  Future<void> migrate(Database db) async {
    await db.execute('''
CREATE TABLE IF NOT EXISTS media_temp ( 
  id TEXT PRIMARY KEY,
  listId TEXT NOT NULL,
  tmdb_id TEXT NOT NULL,
  title TEXT NOT NULL,
  original_title TEXT,
  description TEXT NOT NULL,
  poster_url TEXT NOT NULL,
  type TEXT NOT NULL,
  date TEXT,
  end TEXT,
  rating REAL NOT NULL DEFAULT 0,
  run_time INTEGER NOT NULL,
  genres TEXT DEFAULT '[]',
  episode_count INTEGER,
  season_count INTEGER,
  status TEXT NOT NULL,
  tag TEXT NOT NULL,
  fieldsVersion TEXT DEFAULT '{}' ,
  last_air_date TEXT,
  next_air_date TEXT);
''');

    await db.execute('''
    INSERT INTO media_temp SELECT * FROM media;
''');

    await db.execute('''
    DROP TABLE media;
''');

    await db.execute('''
    ALTER TABLE media_temp RENAME TO media;
''');
  }
}
