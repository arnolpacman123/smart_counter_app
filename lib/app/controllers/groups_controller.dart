import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smart_counter_app/app/controllers/counters_controller.dart';
import 'package:smart_counter_app/app/controllers/details_controller.dart';
import 'package:smart_counter_app/app/models/counter_model.dart';
import 'package:smart_counter_app/app/models/group_model.dart';
import 'package:smart_counter_app/app/utils/database/counter_db.dart';
import 'package:smart_counter_app/app/utils/database/group_db.dart';

class GroupsController extends GetxController {
  final _colors = [
    '#FF0000',
    '#DB124C',
    '#FFA500',
    '#FFDD00',
    '#FFFF00',
    '#B5DB12',
    '#008000',
    '#29C955',
    '#2DE71A',
    '#11F477',
    '#29CBFF',
    '#007AFF',
    '#0000FF',
    '#D429FF',
    '#8B29FF',
    '#8E29C9',
    '#FF2981',
    '#0F3654',
    '#533232',
    '#B4B4B4',
    '#000000',
    '#FFFFFF',
  ].obs;

  final _groups = <Group>[].obs;
  final _nameController = TextEditingController().obs;
  final _backgroundColor = '#FF0000'.obs;
  final _textColor = '#FFFFFF'.obs;

  List<Group> get groups => _groups;

  TextEditingController get nameController => _nameController.value;

  List<String> get colors => _colors.toList();

  String get backgroundColor => _backgroundColor.value;

  String get textColor => _textColor.value;
  final Rx<Group?> _editGroup = Rx<Group?>(null);

  Group? get editGroup => _editGroup.value;
  final Rx<Group?> _selectedGroup = Rx<Group?>(null);

  Group? get selectedGroup => _selectedGroup.value;

  Rx<Group?> get selectedGroupRx => _selectedGroup;

  set selectedGroup(Group? value) {
    _selectedGroup.value = value;
    Get.lazyPut<DetailsController>(
      () => DetailsController(),
    );
  }

  set editGroup(Group? value) => _editGroup.value = value;

  set backgroundColor(String value) => _backgroundColor.value = value;

  set textColor(String value) => _textColor.value = value;

  @override
  void onInit() {
    refreshGroups();
    super.onInit();
  }

  @override
  void onClose() {
    _nameController.close();
    _colors.close();
    _groups.close();
    _backgroundColor.close();
    _textColor.close();
    super.onClose();
  }

  Future<void> addGroup(Group group) async {
    Get.lazyPut<DetailsController>(
      () => DetailsController(),
    );
    Get.lazyPut<CountersController>(
      () => CountersController(),
    );
    await GroupDB.create(group);
    await refreshGroups();
  }

  Future<void> refreshGroups() async {
    _groups.assignAll(await GroupDB.all());
  }

  Future<void> deleteGroup(Group group) async {
    if (await GroupDB.delete(group.id!)) {
      groups.removeWhere((element) => element.id == group.id);
      for (final groupI in _groups) {
        if (groupI.sortOrder > group.sortOrder) {
          groupI.sortOrder = groupI.sortOrder - 1;
          await GroupDB.update(groupI);
        }
      }
    }
  }

  Future<void> updateGroup(Group group) async {
    await GroupDB.update(group);
    await refreshGroups();
  }

  void resetFields() {
    _nameController.value.text = '';
    _backgroundColor.value = _colors[0];
    _textColor.value = _colors[_colors.length - 1];
  }

  Future<void> updateSortOrder(int oldIndex, int newIndex) async {
    final group = groups.removeAt(oldIndex);
    group.sortOrder = newIndex + 1;
    groups.insert(newIndex, group);
    await GroupDB.update(group);
    for (int i = 0; i < groups.length; i++) {
      if (i != newIndex) {
        final groupI = groups[i];
        groupI.sortOrder = i + 1;
        await GroupDB.update(groupI);
      }
    }
    await refreshGroups();
  }

  Future<void> duplicateGroup(Group group) async {
    Group newGroup = Group(
      id: null,
      name: group.name,
      sortOrder: group.sortOrder + 1,
      backgroundColor: group.backgroundColor,
      textColor: group.textColor,
      viewInGrid: group.viewInGrid,
      gridCount: group.gridCount,
    );
    newGroup = await GroupDB.create(newGroup);

    if (group.counters == null) return;
    final counters = <Counter>[];
    for (final counter in group.counters!) {
      final newCounter = counter.copyWith(
        id: null,
        name: counter.name,
        value: 0,
        sortOrder: counter.sortOrder,
        groupId: newGroup.id,
      );
      counters.add(newCounter);
    }

    await CounterDB.createMany(counters);
    await refreshGroups();
  }

  Map<String, dynamic>? jsonGroupToMap(String json) {
    try {
      // Verificar que el json tenga el formato correcto
      final map = jsonDecode(json) as Map<String, dynamic>;
      if (map['name'] is! String ||
          (map['background_color'] is! String) ||
          map['text_color'] is! String ||
          map['counters'] is! List<dynamic> ||
          map['sort_order'] is! int) {
        return null;
      }
      // Verificar que el json tenga el formato correcto
      final counters = map['counters'] as List<dynamic>;
      for (final counter in counters) {
        if (counter['name'] is! String ||
            counter['background_color'] is! String ||
            counter['text_color'] is! String ||
            counter['value'] is! int ||
            counter['reset'] is! int ||
            counter['incremental'] is! int ||
            counter['decremental'] is! int ||
            counter['sort_order'] is! int) {
          return null;
        }
      }
      return map;
    } catch (e) {
      return null;
    }
  }

  Future<void> shareFile(File file) async {
    final xFile = XFile(
      file.path,
    );
    await Share.shareXFiles(
      [xFile],
    );
  }

  Future<void> exportGroup(Group group) async {
    group = Group(
      id: null,
      name: group.name,
      sortOrder: group.sortOrder,
      backgroundColor: group.backgroundColor,
      textColor: group.textColor,
      viewInGrid: group.viewInGrid,
      gridCount: group.gridCount,
      counters: group.counters!
          .map((counter) => Counter(
                id: null,
                name: counter.name,
                value: counter.value,
                sortOrder: counter.sortOrder,
                groupId: null,
                backgroundColor: counter.backgroundColor,
                textColor: counter.textColor,
                reset: counter.reset,
                incremental: counter.incremental,
                decremental: counter.decremental,
              ))
          .toList(),
    );

    final json = groupToJson2(group);
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/${group.name}.json');
    await file.writeAsString(json);
    await shareFile(file);
  }

  Future<void> importGroup(Group group) async {
    Group newGroup = Group(
      id: null,
      name: group.name,
      sortOrder: group.sortOrder + 1,
      backgroundColor: group.backgroundColor,
      textColor: group.textColor,
      viewInGrid: group.viewInGrid,
      gridCount: group.gridCount,
    );
    newGroup = await GroupDB.create(newGroup);

    if (group.counters == null) return;

    final counters = <Counter>[];
    for (final counter in group.counters!) {
      final newCounter = counter.copyWith(
        id: null,
        name: counter.name,
        value: counter.value,
        sortOrder: counter.sortOrder,
        groupId: newGroup.id,
      );
      counters.add(newCounter);
    }

    await CounterDB.createMany(counters);
    await refreshGroups();
  }
}
