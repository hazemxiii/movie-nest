import 'package:sqflite_common_ffi/sqflite_ffi.dart';

abstract class Migration {
  Migration({required this.name});
  final String name;
  Future<void> migrate(Database db);
}
