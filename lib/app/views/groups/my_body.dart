import 'dart:async';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';
import 'package:get/get.dart';
import 'package:smart_counter_app/app/controllers/counters_controller.dart';
import 'package:smart_counter_app/app/controllers/groups_controller.dart';
import 'package:smart_counter_app/app/models/group_model.dart';
import 'package:smart_counter_app/app/utils/functions/delete_dialog.dart';
import 'package:smart_counter_app/app/views/counters/counters_view.dart';
import 'package:smart_counter_app/app/views/details/details_view.dart';
import 'package:smart_counter_app/app/views/groups/my_dialog.dart';

class MyBody extends StatefulWidget {
  const MyBody({
    super.key,
  });

  @override
  State<MyBody> createState() => _MyBodyState();
}

class _MyBodyState extends State<MyBody> {
  final controller = Get.find<GroupsController>();
  StreamSubscription<List<SharedFile>>? _intentDataStreamSubscription;

  @override
  void initState() {
    super.initState();
    // readIntentOpenApp();
    readIntentCloseApp();
  }

  @override
  void dispose() {
    super.dispose();
    _intentDataStreamSubscription?.cancel();
  }

  Future<void> readIntentCloseApp() async {
    FlutterSharingIntent.instance.getInitialSharing().then(
      (List<SharedFile> value) {
        if (value.isEmpty) {
          return;
        }
        Get.defaultDialog(
          title: "Importar grupo",
          middleText: "¿Está seguro de importar el grupo?",
          textConfirm: "Importar",
          textCancel: "Cancelar",
          onConfirm: () async {
            final file = File(value.first.value!);
            final fileContent = await file.readAsString();
            final group = groupFromJson(fileContent);
            await controller.importGroup(group);
            Get.back();
          },
          onCancel: () {
            Get.back();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.groups.isEmpty
          ? const Center(
              child: Text(
                'No hay grupos',
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
            )
          : Container(
              margin: const EdgeInsets.only(
                top: 5,
                bottom: 70,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: ReorderableListView(
                onReorder: (oldIndex, newIndex) async {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  await controller.updateSortOrder(
                    oldIndex,
                    newIndex,
                  );
                },
                children: controller.groups.map(
                  (group) {
                    return Dismissible(
                      key: Key(group.id.toString()),
                      confirmDismiss: (direction) async {
                        final result = await deleteDialog(
                          title: "Eliminar grupo",
                          middleText: "¿Está seguro de eliminar el grupo?",
                          onConfirm: () async {
                            await controller.deleteGroup(
                              group,
                            );
                          },
                          onCancel: () async {
                            await controller.refreshGroups();
                          },
                        );
                        await controller.refreshGroups();
                        return result;
                      },
                      child: Container(
                        height: 110,
                        margin: const EdgeInsets.all(5),
                        child: Card(
                          margin: const EdgeInsets.all(0),
                          elevation: 7,
                          color: Color(
                            int.parse(
                              group.backgroundColor.replaceAll("#", "0xFF"),
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () {
                              controller.selectedGroup = group;
                              Get.lazyPut(
                                () => CountersController(),
                              );
                              Get.to(
                                () => const CountersView(),
                                transition: Transition.leftToRight,
                                duration: const Duration(
                                  milliseconds: 500,
                                ),
                              );
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    const SizedBox(
                                      height: 0,
                                      width: 30,
                                    ),
                                    SizedBox(
                                      width: 215,
                                      child: AutoSizeText(
                                        group.name,
                                        maxLines: 1,
                                        minFontSize: 10,
                                        maxFontSize: 16,
                                        overflow: TextOverflow.ellipsis,
                                        wrapWords: true,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Color(
                                            int.parse(
                                              group.textColor
                                                  .replaceAll("#", "0xFF"),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    PopupMenuButton<String>(
                                      icon: Icon(
                                        Icons.more_vert,
                                        color: Color(
                                          int.parse(
                                            group.textColor
                                                .replaceAll("#", "0xFF"),
                                          ),
                                        ),
                                      ),
                                      onSelected: (value) async {
                                        switch (value) {
                                          case "Opciones de Grupo":
                                            controller.editGroup = group;
                                            controller.nameController.text =
                                                controller.editGroup!.name;
                                            Get.dialog(
                                              Obx(
                                                () => MyDialog(
                                                  textCancel: "Cancelar",
                                                  textConfirm: "Actualizar",
                                                  backgroundColor: controller
                                                      .editGroup!
                                                      .backgroundColor,
                                                  textColor: controller
                                                      .editGroup!.textColor,
                                                  nameController:
                                                      controller.nameController,
                                                  changeBackgroundColor:
                                                      (selected) {
                                                    controller.editGroup =
                                                        controller.editGroup!
                                                            .copyWith(
                                                                backgroundColor:
                                                                    selected);
                                                  },
                                                  changeTextColor: (selected) {
                                                    controller.editGroup =
                                                        controller.editGroup!
                                                            .copyWith(
                                                                textColor:
                                                                    selected);
                                                  },
                                                  changeName: (name) {
                                                    controller.editGroup =
                                                        controller.editGroup!
                                                            .copyWith(
                                                                name: name);
                                                  },
                                                  colors: controller.colors,
                                                  onConfirm: () async {
                                                    await controller
                                                        .updateGroup(
                                                      controller.editGroup!,
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
                                            break;
                                          case "Duplicar":
                                            await controller.duplicateGroup(
                                              group,
                                            );
                                            break;
                                          case "Compartir Grupo":
                                            await controller.exportGroup(group);
                                            break;
                                          case "Eliminar":
                                            await deleteDialog(
                                              title: "Eliminar grupo",
                                              middleText:
                                                  "¿Está seguro de eliminar el grupo?",
                                              onConfirm: () async {
                                                await controller.deleteGroup(
                                                  group,
                                                );
                                              },
                                              onCancel: () async {
                                                await controller
                                                    .refreshGroups();
                                              },
                                            );
                                            await controller.refreshGroups();
                                            break;
                                          case "Estado":
                                            controller.selectedGroup = group;
                                            Get.to(
                                              () => DetailsView(),
                                              transition:
                                                  Transition.leftToRight,
                                              duration: const Duration(
                                                milliseconds: 500,
                                              ),
                                            );
                                            break;
                                        }
                                      },
                                      itemBuilder: (context) {
                                        return [
                                          "Opciones de Grupo",
                                          "Duplicar",
                                          "Compartir Grupo",
                                          "Eliminar",
                                          "Estado",
                                        ].map((String choice) {
                                          return PopupMenuItem<String>(
                                            value: choice,
                                            child: Text(choice),
                                          );
                                        }).toList();
                                      },
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const SizedBox(
                                      height: 0,
                                      width: 30,
                                    ),
                                    AutoSizeText(
                                      'Contadores:',
                                      maxLines: 1,
                                      minFontSize: 10,
                                      maxFontSize: 16,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(
                                          int.parse(
                                            group.textColor
                                                .replaceAll("#", "0xFF"),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    AutoSizeText(
                                      group.counters!.length.toString(),
                                      maxLines: 1,
                                      minFontSize: 10,
                                      maxFontSize: 16,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(
                                          int.parse(
                                            group.textColor
                                                .replaceAll("#", "0xFF"),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 0,
                                      width: 20,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),
            ),
    );
  }
}
