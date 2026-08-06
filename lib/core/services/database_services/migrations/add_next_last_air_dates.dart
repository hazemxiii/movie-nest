import 'package:movie_nest/core/services/database_services/migrations/migration.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class AddNextLastAirDates extends Migration {
  AddNextLastAirDates() : super(name: 'add_next_last_air_dates');

  @override
  Future<void> migrate(Database db) async {
    await db.execute('''
      ALTER TABLE media ADD COLUMN last_air_date TEXT;
    ''');
    await db.execute('''
      ALTER TABLE media ADD COLUMN next_air_date TEXT;
    ''');
  }
}
