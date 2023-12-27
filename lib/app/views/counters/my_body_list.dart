import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:smart_counter_app/app/controllers/counters_controller.dart';
import 'package:smart_counter_app/app/utils/functions/delete_dialog.dart';
import 'package:smart_counter_app/app/views/counters/my_dialog.dart';
import 'package:smart_counter_app/app/views/counters/reset_dialog.dart';
import 'package:soundpool/soundpool.dart';
import 'package:vibration/vibration.dart';

class MyBodyList extends StatefulWidget {
  const MyBodyList({super.key});

  @override
  State<MyBodyList> createState() => _MyBodyListState();
}

class _MyBodyListState extends State<MyBodyList> {
  final controller = Get.find<CountersController>();
  late Soundpool pool;
  late int soundId;
  late final bool? hasVibrator;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSound();
    _initVibrator();
  }

  @override
  void dispose() {
    pool.release();
    super.dispose();
  }

  Future<void> _initVibrator() async {
    hasVibrator = await Vibration.hasVibrator();
    setState(() {});
  }

  Future<void> _loadSound() async {
    pool = Soundpool.fromOptions(
      options: const SoundpoolOptions(
        streamType: StreamType.music,
        maxStreams: 32,
      ),
    );
    final ByteData data = await rootBundle.load("assets/audios/click.mp3");
    soundId = await pool.load(data);
  }

  Future<void> playSound(int soundId) async {
    await pool.play(soundId);
    if (hasVibrator == true) {
      await Vibration.vibrate(
        pattern: const [0, 100],
        intensities: const [255, 255],
      );
    }
  }

  void changeStateLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ReorderableListView(
        onReorder: (oldIndex, newIndex) async {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          await controller.updateSortOrder(
            oldIndex,
            newIndex,
          );
        },
        children: controller.counters.map((e) {
          final counter = e;
          return Dismissible(
            key: Key(counter.id.toString()),
            confirmDismiss: (direction) async {
              final result = await deleteDialog(
                title: "Eliminar contador",
                middleText: "¿Está seguro que desea eliminar el contador?",
                onCancel: () async {
                  await playSound(soundId);
                  await controller.refreshCounters();
                },
                onConfirm: () async {
                  await playSound(soundId);
                  await controller.deleteCounter(
                    counter,
                  );
                },
              );
              return result;
            },
            child: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              height: 110,
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              child: Card(
                elevation: 7,
                color: Color(
                  int.parse(
                    counter.backgroundColor.replaceAll("#", "0xFF"),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    // Botón de suma en la primera sección
                    Positioned(
                      left: 5,
                      top: 17,
                      bottom: 17,
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: !isLoading
                            ? IconButton(
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                    const CircleBorder(),
                                  ),
                                ),
                                icon: Icon(
                                  Icons.remove,
                                  color: Color(
                                    int.parse(counter.textColor
                                        .replaceAll("#", "0xFF")),
                                  ),
                                ),
                                onPressed: () async {
                                  changeStateLoading(true);
                                  await playSound(soundId);
                                  await controller.decrementCounter(counter);
                                  changeStateLoading(false);
                                },
                              )
                            : null,
                      ),
                    ),
                    // Sección central con botones y texto
                    Positioned.fill(
                      left: 75,
                      right: 75,
                      child: Container(
                        margin: const EdgeInsets.only(
                          top: 0,
                          bottom: 0,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 32,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      // Diálogo de confirmación si desea reiniciar
                                      resetDialog(
                                        onConfirm: () async {
                                          await playSound(soundId);
                                          await controller
                                              .resetCounter(counter);
                                          Get.back();
                                        },
                                      );
                                    },
                                    icon: Icon(
                                      Icons.refresh,
                                      color: Color(
                                        int.parse(counter.textColor
                                            .replaceAll("#", "0xFF")),
                                      ),
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    icon: Icon(
                                      Icons.more_vert,
                                      color: Color(
                                        int.parse(counter.textColor
                                            .replaceAll("#", "0xFF")),
                                      ),
                                    ),
                                    onSelected: (value) async {
                                      switch (value) {
                                        case "Opciones de Contador":
                                          controller.editCounter = counter;
                                          controller.assignTextControllers(
                                            controller.editCounter!,
                                          );

                                          Get.dialog(
                                            Obx(
                                              () => MyDialog(
                                                viewParameters:
                                                    controller.viewParameters,
                                                backgroundColor: controller
                                                    .editCounter!
                                                    .backgroundColor,
                                                textColor: controller
                                                    .editCounter!.textColor,
                                                nameController:
                                                    controller.nameController,
                                                valueController:
                                                    controller.valueController,
                                                resetController:
                                                    controller.resetController,
                                                incrementalController:
                                                    controller
                                                        .incrementalController,
                                                decrementalController:
                                                    controller
                                                        .decrementalController,
                                                colors: controller.colors,
                                                changeBackgroundColor:
                                                    (selected) {
                                                  controller.editCounter =
                                                      controller.editCounter!
                                                          .copyWith(
                                                    id: controller
                                                        .editCounter!.id,
                                                    backgroundColor: selected,
                                                  );
                                                },
                                                changeTextColor: (selected) {
                                                  controller.editCounter =
                                                      controller.editCounter!
                                                          .copyWith(
                                                    id: controller
                                                        .editCounter!.id,
                                                    textColor: selected,
                                                  );
                                                },
                                                changeName: (name) {
                                                  controller.editCounter =
                                                      controller.editCounter!
                                                          .copyWith(
                                                    id: controller
                                                        .editCounter!.id,
                                                    name: name,
                                                  );
                                                },
                                                onConfirm: () async {
                                                  await pool.play(soundId);
                                                  controller.editCounter =
                                                      controller.editCounter!
                                                          .copyWith(
                                                    id: controller
                                                        .editCounter!.id,
                                                    value: int.parse(controller
                                                        .valueController
                                                        .value
                                                        .text),
                                                    reset: int.parse(controller
                                                        .resetController
                                                        .value
                                                        .text),
                                                    incremental: int.parse(
                                                        controller
                                                            .incrementalController
                                                            .value
                                                            .text),
                                                    decremental: int.parse(
                                                        controller
                                                            .decrementalController
                                                            .value
                                                            .text),
                                                  );
                                                  await controller
                                                      .updateCounter(
                                                    controller.editCounter!,
                                                  );
                                                  controller.resetFields();
                                                },
                                                onCancel: () {
                                                  controller.resetFields();
                                                },
                                                textCancel: "Cancelar",
                                                textConfirm: "Actualizar",
                                                onWillPop: () {
                                                  controller.resetFields();
                                                },
                                                changeViewParameters: () {
                                                  controller.viewParameters =
                                                      !controller
                                                          .viewParameters;
                                                },
                                              ),
                                            ),
                                          );
                                          break;
                                        case "Eliminar":
                                          await deleteDialog(
                                            title: "Eliminar",
                                            middleText:
                                                "¿Está seguro que desea eliminar el contador?",
                                            onCancel: () async {
                                              await playSound(soundId);
                                            },
                                            onConfirm: () async {
                                              await playSound(soundId);
                                              await controller.deleteCounter(
                                                counter,
                                              );
                                            },
                                          );
                                          break;
                                        case "Duplicar":
                                          await controller.duplicate(
                                            counter,
                                          );
                                          break;
                                      }
                                    },
                                    itemBuilder: (context) {
                                      return [
                                        "Opciones de Contador",
                                        "Duplicar",
                                        "Eliminar",
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
                            ),
                            SizedBox(
                              height: 28,
                              child: AutoSizeText(
                                counter.name,
                                maxLines: 2,
                                minFontSize: 11,
                                overflow: TextOverflow.ellipsis,
                                wrapWords: true,
                                style: TextStyle(
                                  color: Color(
                                    int.parse(counter.textColor
                                        .replaceAll("#", "0xFF")),
                                  ),
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            Text(
                              counter.value.toString(),
                              style: TextStyle(
                                color: Color(
                                  int.parse(
                                    counter.textColor.replaceAll("#", "0xFF"),
                                  ),
                                ),
                                fontSize: 28,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Botón de resta en la tercera sección
                    Positioned(
                      right: 5,
                      top: 17,
                      bottom: 17,
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: !isLoading
                            ? IconButton(
                                style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                    const CircleBorder(),
                                  ),
                                ),
                                icon: Icon(
                                  Icons.add,
                                  color: Color(
                                    int.parse(counter.textColor
                                        .replaceAll("#", "0xFF")),
                                  ),
                                ),
                                onPressed: () async {
                                  changeStateLoading(true);
                                  await playSound(soundId);
                                  await controller.incrementCounter(counter);
                                  changeStateLoading(false);
                                },
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
