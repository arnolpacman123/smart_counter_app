import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'package:smart_counter_app/app/controllers/counters_controller.dart';
import 'package:smart_counter_app/app/utils/functions/number_dialog.dart';
import 'package:smart_counter_app/app/views/details/details_view.dart';
import 'package:smart_counter_app/app/views/groups/my_dialog.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  MyAppBar({
    super.key,
  });

  final controller = Get.find<CountersController>();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppBar(
        leadingWidth: 100,
        centerTitle: true,
        backgroundColor: controller.group == null
            ? Colors.transparent
            : Color(
                int.parse(
                    controller.group!.backgroundColor.replaceAll("#", "0xFF")),
              ),
        shadowColor: controller.group == null
            ? Colors.transparent
            : Color(
                int.parse(
                    controller.group!.backgroundColor.replaceAll("#", "0xFF")),
              ),
        foregroundColor: controller.group == null
            ? Colors.transparent
            : Color(
                int.parse(controller.group!.textColor.replaceAll("#", "0xFF")),
              ),
        leading: Row(
          children: [
            Builder(
              builder: (context) {
                return IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: Color(
                      int.parse(
                          controller.group!.textColor.replaceAll("#", "0xFF")),
                    ),
                  ),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                );
              },
            ),
            IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back_ios),
              color: Color(
                int.parse(
                  controller.group!.textColor.replaceAll("#", "0xFF"),
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {
              if (controller.group!.viewInGrid) {
                await controller.groupsController.updateGroup(
                  controller.group!.copyWith(
                    viewInGrid: !controller.group!.viewInGrid,
                    gridCount: null,
                  ),
                );
                controller.group = controller.groupsController.groups
                    .firstWhere(
                      (element) => element.id == controller.group!.id,
                    )
                    .copyWith();
              } else {
                int? gridCount = await numberDialog("Seleccione el número de columnas", [2, 3]);
                if (gridCount != null) {
                  await controller.groupsController.updateGroup(
                    controller.group!.copyWith(
                      viewInGrid: !controller.group!.viewInGrid,
                      gridCount: gridCount,
                    ),
                  );
                  controller.group = controller.groupsController.groups
                      .firstWhere(
                        (element) => element.id == controller.group!.id,
                      )
                      .copyWith();
                }
              }
            },
            icon: Icon(controller.group!.viewInGrid
                ? Icons.list
                : Icons.grid_view_rounded),
            color: Color(
              int.parse(controller.group!.textColor.replaceAll("#", "0xFF")),
            ),
          ),
          PopupMenuButton(
            icon: Icon(
              Icons.more_vert,
              color: Color(
                int.parse(controller.group!.textColor.replaceAll("#", "0xFF")),
              ),
            ),
            onSelected: (String result) {
              switch (result) {
                case "Opciones de Grupo":
                  controller.groupsController.editGroup =
                      controller.groupsController.selectedGroup;
                  controller.groupsController.nameController.text =
                      controller.groupsController.editGroup!.name;
                  Get.dialog(
                    Obx(
                      () => MyDialog(
                        textCancel: "Cancelar",
                        textConfirm: "Actualizar",
                        backgroundColor: controller
                            .groupsController.editGroup!.backgroundColor,
                        textColor:
                            controller.groupsController.editGroup!.textColor,
                        nameController:
                            controller.groupsController.nameController,
                        changeBackgroundColor: (selected) {
                          controller.groupsController.editGroup = controller
                              .groupsController.editGroup!
                              .copyWith(backgroundColor: selected);
                        },
                        changeTextColor: (selected) {
                          controller.groupsController.editGroup = controller
                              .groupsController.editGroup!
                              .copyWith(textColor: selected);
                        },
                        changeName: (name) {
                          controller.groupsController.editGroup = controller
                              .groupsController.editGroup!
                              .copyWith(name: name);
                        },
                        colors: controller.groupsController.colors,
                        onConfirm: () async {
                          await controller.groupsController.updateGroup(
                            controller.groupsController.editGroup!,
                          );
                          controller.groupsController.selectedGroup =
                              controller.groupsController.groups.firstWhere(
                            (element) =>
                                element.id ==
                                controller.groupsController.editGroup!.id,
                          );
                          controller.groupsController.resetFields();
                        },
                        onCancel: () {
                          controller.groupsController.resetFields();
                        },
                        onWillPop: () {
                          controller.groupsController.resetFields();
                        },
                      ),
                    ),
                  );
                  break;
                case "Estado":
                  Get.to(
                    () => DetailsView(),
                    transition: Transition.leftToRight,
                    duration: const Duration(milliseconds: 500),
                  );
                  break;
              }
            },
            itemBuilder: (context) => ["Opciones de Grupo", "Estado"]
                .map(
                  (String choice) => PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  ),
                )
                .toList(),
          ),
        ],
        title: Obx(
          () => AutoSizeText(
            controller.group == null ? '' : controller.group!.name,
            maxLines: 1,
            minFontSize: 10,
            style: TextStyle(
              color: controller.group == null
                  ? Colors.transparent
                  : Color(
                      int.parse(
                          controller.group!.textColor.replaceAll("#", "0xFF")),
                    ),
              fontSize: 17,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  Future<int?> getGridCount() async {
    int? gridCount;
    await Get.dialog(
      Dialog(
        child: SizedBox(
          height: 150,
          width: 80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Seleccione el número de columnas"),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      gridCount = 2;
                      Get.back();
                    },
                    child: const Text("2"),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      gridCount = 3;
                      Get.back();
                    },
                    child: const Text("3"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return gridCount;
  }
}
