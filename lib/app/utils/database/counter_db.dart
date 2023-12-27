import 'package:smart_counter_app/app/models/counter_model.dart';
import 'package:smart_counter_app/app/utils/database/database_service.dart';
import 'package:sqflite/sqflite.dart';

class CounterDB {
  static const tableName = 'counters';
  static final database = DatabaseService.database;

  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        group_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        background_color TEXT NOT NULL,
        text_color TEXT NOT NULL,
        value INTEGER NOT NULL,
        reset INTEGER NOT NULL,
        incremental INTEGER NOT NULL,
        decremental INTEGER NOT NULL,
        sort_order INTEGER NOT NULL,
        FOREIGN KEY (group_id) REFERENCES groups (id)
      );
    ''');
  }

  static Future<List<Counter>> all() async {
    final db = await database;
    final result = await db.query(tableName);
    return result.map((e) => Counter.fromJson(e)).toList();
  }

  static Future<List<Counter>> allFromGroup(int groupId) async {
    final db = await database;
    final result = await db.query(
      tableName,
      where: 'group_id = ?',
      whereArgs: [groupId],
      orderBy: 'sort_order ASC',
    );
    return result.map((e) => Counter.fromJson(e)).toList();
  }

  static Future<Counter> create(Counter counter) async {
    final db = await database;
    final id = await db.insert(tableName, counter.toJson());
    return await find(id);
  }

  static Future<void> createMany(List<Counter> counters) async {
    final db = await database;
    final batch = db.batch();
    for (final counter in counters) {
      batch.insert(tableName, counter.toJson());
    }
    await batch.commit();
  }

  static Future<Counter> find(int id) async {
    final db = await database;
    final result = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    return Counter.fromJson(result.first);
  }

  static Future<Counter> update(Counter counter) async {
    final db = await database;
    await db.update(
      tableName,
      counter.toJson(),
      where: 'id = ?',
      whereArgs: [counter.id],
    );
    return await find(counter.id!);
  }

  static Future<bool> delete(int id) async {
    final db = await database;
    final result = await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    return result > 0;
  }
}
