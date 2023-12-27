import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:smart_counter_app/app/controllers/groups_controller.dart';
import 'package:smart_counter_app/app/models/group_model.dart';
import 'package:smart_counter_app/app/views/counters/counters_view.dart';
import 'package:smart_counter_app/app/views/groups/my_dialog.dart';

class MyFloatingActionButton extends StatelessWidget {
  MyFloatingActionButton({
    super.key,
  });

  final controller = Get.find<GroupsController>();

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Get.dialog(
          Obx(
            () => MyDialog(
              textCancel: "Cancelar",
              textConfirm: "Agregar",
              backgroundColor: controller.backgroundColor,
              textColor: controller.textColor,
              nameController: controller.nameController,
              changeBackgroundColor: (selected) {
                controller.backgroundColor = selected;
              },
              changeTextColor: (selected) {
                controller.textColor = selected;
              },
              changeName: (name) {
                controller.nameController.text = name;
              },
              colors: controller.colors,
              onConfirm: () async {
                await controller.addGroup(
                  Group(
                    name: controller.nameController.text,
                    backgroundColor: controller.backgroundColor,
                    textColor: controller.textColor,
                    sortOrder: controller.groups.length + 1,
                    viewInGrid: false,
                  ),
                );
                controller.selectedGroupRx.value = controller.groups.last;
                Get.to(
                  () => const CountersView(),
                  transition: Transition.rightToLeft,
                );
                controller.resetFields();
              },
              onCancel: () {
                controller.resetFields();
              },
              onWillPop: () {
                controller.resetFields();
              },
            ),
          ),
        );
      },
      child: const Icon(Icons.add),
    );
  }
}
