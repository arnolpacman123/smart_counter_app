import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_counter_app/app/controllers/counters_controller.dart';
import 'package:smart_counter_app/app/models/counter_model.dart';
import 'package:smart_counter_app/app/views/counters/my_dialog.dart';

class MyFloatingActionButton extends StatelessWidget {
  MyFloatingActionButton({
    super.key,
  });

  final controller = Get.find<CountersController>();

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Get.dialog(
          Obx(
            () => MyDialog(
              colors: controller.colors,
              backgroundColor: controller.backgroundColor,
              nameController: controller.nameController,
              valueController: controller.valueController,
              resetController: controller.resetController,
              incrementalController: controller.incrementalController,
              decrementalController: controller.decrementalController,
              textColor: controller.textColor,
              viewParameters: controller.viewParameters,
              changeBackgroundColor: (selected) {
                controller.backgroundColor = selected;
              },
              changeTextColor: (selected) {
                controller.textColor = selected;
              },
              changeName: (value) {
                controller.nameController.text = value;
              },
              onWillPop: () {
                controller.resetFields();
              },
              changeViewParameters: () {
                controller.viewParameters = !controller.viewParameters;
              },
              textCancel: 'Cancelar',
              textConfirm: 'Agregar',
              onCancel: () {
                controller.resetFields();
              },
              onConfirm: () async {
                await controller.addCounter(Counter(
                  name: controller.nameController.text,
                  value: int.parse(controller.valueController.text),
                  reset: int.parse(controller.resetController.text),
                  incremental: int.parse(controller.incrementalController.text),
                  decremental: int.parse(controller.decrementalController.text),
                  backgroundColor: controller.backgroundColor,
                  textColor: controller.textColor,
                  groupId: controller.group!.id!,
                  sortOrder: controller.counters.length,
                ));
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
