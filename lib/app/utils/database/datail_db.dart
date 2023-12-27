import 'package:sqflite/sqflite.dart';

import 'package:smart_counter_app/app/utils/database/database_service.dart';
import 'package:smart_counter_app/app/models/datail_model.dart';

class DetailDB {
  static const tableName = 'detail';
  static final futureDatabase = DatabaseService.database;

  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        date TEXT NOT NULL,
        action TEXT NOT NULL,
        value INTEGER NOT NULL,
        group_id INTEGER NOT NULL
      );
    ''');
  }

  static Future<List<Detail>> allFromGroup(int groupId) async {
    final db = await futureDatabase;
    final result = await db.query(
      tableName,
      where: 'group_id = ?',
      whereArgs: [groupId],
      orderBy: 'id DESC',
    );
    return result.map((e) => Detail.fromJson(e)).toList();
  }

  static Future<Detail> find(int id) async {
    final db = await futureDatabase;
    final result = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    return Detail.fromJson(result.first);
  }

  static Future<Detail> create(Detail detail) async {
    final db = await futureDatabase;
    final id = await db.insert(tableName, detail.toJson());
    return await find(id);
  }

  static Future<Detail> update(Detail detail) async {
    final db = await futureDatabase;
    await db.update(
      tableName,
      detail.toJson(),
      where: 'id = ?',
      whereArgs: [detail.id!],
    );
    return await find(detail.id!);
  }

  static Future<bool> delete(int id) async {
    final db = await futureDatabase;
    final result = await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    return result > 0;
  }

  static Future<bool> deleteAllFromGroup(int groupId) async {
    final db = await futureDatabase;
    final result = await db.delete(
      tableName,
      where: 'group_id = ?',
      whereArgs: [groupId],
    );
    return result > 0;
  }
}
