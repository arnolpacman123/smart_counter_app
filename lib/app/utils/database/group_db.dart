import 'package:sqflite/sqflite.dart';

import 'package:smart_counter_app/app/models/counter_model.dart';
import 'package:smart_counter_app/app/models/group_model.dart';
import 'package:smart_counter_app/app/utils/database/counter_db.dart';
import 'package:smart_counter_app/app/utils/database/database_service.dart';
import 'package:smart_counter_app/app/utils/database/datail_db.dart';

class GroupDB {
  static const tableName = 'groups';
  static final futureDatabase = DatabaseService.database;

  static Future<void> createTable(Database db) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        background_color TEXT NOT NULL,
        text_color TEXT NOT NULL,
        sort_order INTEGER NOT NULL,
        view_in_grid INTEGER DEFAULT 0,
        grid_count INTEGER
      );
    ''');
  }

  static Future<List<Group>> all() async {
    const tableNameGroup = GroupDB.tableName;
    const tableNameCounter = CounterDB.tableName;

    const query = '''
      SELECT $tableNameGroup.id, $tableNameGroup.name, $tableNameGroup.background_color, $tableNameGroup.text_color, $tableNameGroup.sort_order, COUNT($tableNameCounter.id) AS counters_count, $tableNameGroup.view_in_grid, $tableNameGroup.grid_count
      FROM $tableNameGroup
      LEFT JOIN $tableNameCounter ON $tableNameCounter.group_id = $tableNameGroup.id
      GROUP BY $tableNameGroup.id
      ORDER BY $tableNameGroup.sort_order ASC
    ''';

    final db = await futureDatabase;
    final result = await db.rawQuery(query);

    final groups = result.map((json) => Group.fromJson(json)).toList();

    for (int i = 0; i < groups.length; i++) {
      final counters = await CounterDB.allFromGroup(groups[i].id!);
      groups[i].counters = counters;
    }

    return groups;
  }

  static Future<Group> find(int id) async {
    const tableNameGroup = GroupDB.tableName;
    const tableNameCounter = CounterDB.tableName;

    final db = await futureDatabase;

    const query = '''
      SELECT $tableNameGroup.id, $tableNameGroup.name, $tableNameGroup.background_color, $tableNameGroup.text_color, $tableNameGroup.sort_order, COUNT($tableNameCounter.id) AS counters_count, $tableNameGroup.view_in_grid
      FROM $tableNameGroup
      LEFT JOIN $tableNameCounter ON $tableNameCounter.group_id = $tableNameGroup.id
      WHERE $tableNameGroup.id = ?
      GROUP BY $tableNameGroup.id
    ''';

    final groupResult = await db.rawQuery(query, [id]);

    if (groupResult.isEmpty) {
      throw Exception('Group not found');
    }

    Group group = Group.fromJson(groupResult.first);

    final counterResults = await db.query(
      tableNameCounter,
      where: 'group_id = ?',
      whereArgs: [id],
    );

    final counters = counterResults.map((e) => Counter.fromJson(e)).toList();

    group.counters = counters;

    return group;
  }

  static Future<Group> create(Group group) async {
    final db = await futureDatabase;
    final id = await db.insert(tableName, group.toJson());
    return await find(id);
  }

  static Future<Group> update(Group group) async {
    final db = await futureDatabase;

    await db.update(
      tableName,
      group.toJson(),
      where: 'id = ?',
      whereArgs: [group.id],
    );

    final groupFound = await find(group.id!);
    return groupFound;
  }

  static Future<bool> delete(int id) async {
    final db = await futureDatabase;
    final result = await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    final counterResult = await db.delete(
      CounterDB.tableName,
      where: 'group_id = ?',
      whereArgs: [id],
    );
    final detailResult = await db.delete(
      DetailDB.tableName,
      where: 'group_id = ?',
      whereArgs: [id],
    );

    return result > 0 && counterResult >= 0 && detailResult >= 0;
  }
}
