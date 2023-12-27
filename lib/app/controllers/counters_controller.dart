import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:smart_counter_app/app/controllers/details_controller.dart';
import 'package:smart_counter_app/app/controllers/groups_controller.dart';

import 'package:smart_counter_app/app/models/counter_model.dart';
import 'package:smart_counter_app/app/models/datail_model.dart';
import 'package:smart_counter_app/app/models/group_model.dart';
import 'package:smart_counter_app/app/utils/database/counter_db.dart';

class CountersController extends GetxController {
  final groupsController = Get.find<GroupsController>();

  Group? get group => groupsController.selectedGroupRx.value;

  set group(Group? value) => groupsController.selectedGroupRx.value = value;

  final _counters = <Counter>[].obs;

  final _colors = <String>[
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
  late final RxString _backgroundColor;
  late final RxString _textColor;
  final _nameController = TextEditingController().obs;
  final _valueController = TextEditingController().obs;
  final _incrementalController = TextEditingController().obs;
  final _decrementalController = TextEditingController().obs;
  final _resetController = TextEditingController().obs;
  final _viewParameters = false.obs;
  final Rx<Counter?> _editCounter = Rx<Counter?>(null);
  Counter? get editCounter => _editCounter.value;

  List<String> get colors => _colors.toList();
  String get backgroundColor => _backgroundColor.value;
  String get textColor => _textColor.value;
  List<Counter> get counters => _counters;
  TextEditingController get nameController => _nameController.value;
  TextEditingController get valueController => _valueController.value;
  TextEditingController get incrementalController =>
      _incrementalController.value;
  TextEditingController get decrementalController =>
      _decrementalController.value;
  TextEditingController get resetController => _resetController.value;
  bool get viewParameters => _viewParameters.value;

  set backgroundColor(String value) => _backgroundColor.value = value;
  set textColor(String value) => _textColor.value = value;
  set viewParameters(bool value) => _viewParameters.value = value;
  set editCounter(Counter? value) => _editCounter.value = value;
  late Worker _refreshCountersWorker;
  final detailsController = Get.find<DetailsController>();

  @override
  void onInit() {
    _backgroundColor = _colors.first.obs;
    _textColor = _colors.last.obs;
    _valueController.value.text = '0';
    _incrementalController.value.text = '1';
    _decrementalController.value.text = '1';
    _resetController.value.text = '0';
    _refreshCountersWorker = ever(groupsController.selectedGroupRx, (_) {
      if (_ != null) {
        refreshCounters();
        group = _;
      }
    });
    refreshCounters();
    super.onInit();
  }

  @override
  void onClose() {
    _nameController.value.dispose();
    _valueController.value.dispose();
    _incrementalController.value.dispose();
    _decrementalController.value.dispose();
    _resetController.value.dispose();
    _counters.clear();
    _refreshCountersWorker.dispose();
    super.onClose();
  }

  void resetFields() {
    _nameController.value.text = '';
    _valueController.value.text = '0';
    _incrementalController.value.text = '1';
    _decrementalController.value.text = '1';
    _resetController.value.text = '0';
    _backgroundColor.value = _colors.first;
    _textColor.value = _colors.last;
    _viewParameters.value = false;
  }

  Future<void> addCounter(Counter counter) async {
    await CounterDB.create(counter);
    await refreshCounters();
    await detailsController.addDetail(Detail(
      name: counter.name,
      date: DateTime.now(),
      action: "⇒",
      value: counter.value,
      groupId: counter.groupId!,
    ));
    await groupsController.refreshGroups();
    groupsController.selectedGroupRx.value = groupsController.groups.firstWhere(
      (element) => element.id == counter.groupId,
    );
  }

  Future<void> refreshCounters() async {
    _counters.assignAll(await CounterDB.allFromGroup(group!.id!));
  }

  Future<void> decrementCounter(Counter counter) async {
    await changeCounterValue(counter, -counter.decremental, "-");
  }

  Future<void> changeCounterValue(
    Counter counter,
    int value,
    String action,
  ) async {
    counter.value += value;
    await CounterDB.update(counter);
    await detailsController.addDetail(Detail(
      name: counter.name,
      date: DateTime.now(),
      action: action,
      value: counter.value,
      groupId: counter.groupId!,
    ));
    await refreshCounters();
    await groupsController.refreshGroups();
    groupsController.selectedGroupRx.value = groupsController.groups.firstWhere(
      (element) => element.id == counter.groupId,
    );
  }

  Future<void> incrementCounter(Counter counter) async {
    await changeCounterValue(counter, counter.incremental, "+");
  }

  Future<void> resetCounter(Counter counter) async {
    counter.value = counter.reset;
    await CounterDB.update(counter);
    await refreshCounters();
    await groupsController.refreshGroups();
    groupsController.selectedGroupRx.value = groupsController.groups.firstWhere(
      (element) => element.id == counter.groupId,
    );
  }

  void assignTextControllers(Counter counter) {
    _nameController.value.text = counter.name;
    _valueController.value.text = counter.value.toString();
    _incrementalController.value.text = counter.incremental.toString();
    _decrementalController.value.text = counter.decremental.toString();
    _resetController.value.text = counter.reset.toString();
    _backgroundColor.value = counter.backgroundColor;
    _textColor.value = counter.textColor;
    _viewParameters.value = true;
  }

  Future<void> updateCounter(Counter counter) async {
    await CounterDB.update(counter);
    await refreshCounters();
  }

  Future<void> deleteCounter(Counter counter) async {
    for (final element in counters) {
      if (element.sortOrder > counter.sortOrder) {
        element.sortOrder -= 1;
        await CounterDB.update(element);
      }
    }
    await CounterDB.delete(counter.id!);
    await refreshCounters();
    await groupsController.refreshGroups();
    groupsController.selectedGroupRx.value = groupsController.groups.firstWhere(
      (element) => element.id == counter.groupId,
    );
  }

  Future<void> updateSortOrder(int oldIndex, int newIndex) async {
    final counter = counters.removeAt(oldIndex);
    counter.sortOrder = newIndex + 1;
    counters.insert(newIndex, counter);
    await CounterDB.update(counter);
    for (int i = 0; i < counters.length; i++) {
      if (i != newIndex) {
        final counterI = counters[i];
        counterI.sortOrder = i + 1;
        await CounterDB.update(counterI);
      }
    }
    await refreshCounters();
  }

  Future<void> duplicate(Counter counter) async {
    final newCounter = counter.copyWith(
      id: null,
      sortOrder: counter.sortOrder + 1,
    );

    await CounterDB.create(newCounter);

    for (final element in counters) {
      if (element.sortOrder >= newCounter.sortOrder) {
        element.sortOrder += 1;
        await CounterDB.update(element);
      }
    }
    await refreshCounters();
  }
}
