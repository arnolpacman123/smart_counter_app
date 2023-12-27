import 'dart:async';

import 'package:path/path.dart';
import 'package:smart_counter_app/app/utils/database/counter_db.dart';
import 'package:smart_counter_app/app/utils/database/datail_db.dart';
import 'package:smart_counter_app/app/utils/database/group_db.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('smart_counter.db');
    return _database!;
  }

  static Future<String> get fullPath async {
    const name = 'smart_counter.db';
    final path = await getDatabasesPath();
    return join(path, name);
  }

  static Future<Database> _initDB(String name) async {
    final path = await fullPath;
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
      singleInstance: true,
    );
  }

  static FutureOr<void> _createDatabase(Database db, int version) async {
    await GroupDB.createTable(db);
    await CounterDB.createTable(db);
    await DetailDB.createTable(db);
  }
}
