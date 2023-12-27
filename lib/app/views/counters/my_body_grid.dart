import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:get/get.dart';
import 'package:smart_counter_app/app/views/counters/reset_dialog.dart';
import 'package:soundpool/soundpool.dart';
import 'package:vibration/vibration.dart';

import 'package:smart_counter_app/app/controllers/counters_controller.dart';
import 'package:smart_counter_app/app/utils/functions/delete_dialog.dart';
import 'package:smart_counter_app/app/views/counters/my_dialog.dart';

extension Properties on int {
  double get height => this == 2 ? 50 : 50;
  double get width => this == 2 ? 50 : 50;

  double get fontSize => this == 2 ? 50 : 50;
  double? get mainAxisExtent => this == 2 ? 150 : null;
}

class MyBodyGrid extends StatefulWidget {
  const MyBodyGrid({super.key});

  @override
  State<MyBodyGrid> createState() => _MyBodyGridState();
}

class _MyBodyGridState extends State<MyBodyGrid> {
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

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GridView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: controller.counters.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: controller.groupsController.selectedGroup!.gridCount!,
          crossAxisSpacing: 3,
          mainAxisSpacing: 8,
          mainAxisExtent: controller.group!.gridCount!.mainAxisExtent,
        ),
        itemBuilder: (context, index) {
          final counter = controller.counters[index];
          return Container(
            decoration: BoxDecoration(
              color: Color(
                int.parse(
                  counter.backgroundColor.replaceAll('#', '0xff'),
                ),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                // Posicionar al centro, arriba
                Positioned(
                  top: 7,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                    ),
                    height: 32,
                    child: AutoSizeText(
                      counter.name,
                      minFontSize: 10,
                      maxFontSize: 17,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 7,
                  top: 23,
                  child: IconButton(
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      // Diálogo de confirmación si desea reiniciar
                      resetDialog(
                        onConfirm: () async {
                          await playSound(soundId);
                          await controller.resetCounter(counter);
                          Get.back();
                        },
                      );
                    },
                  ),
                ),
                // Posicionar al centro
                Positioned(
                  top: 45,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SizedBox(
                      height: Get.height * 0.07,
                      child: AutoSizeText(
                        counter.value.toString(),
                        minFontSize: 10,
                        maxFontSize: 100,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 100,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 7,
                  top: 23,
                  child: PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: Color(
                        int.parse(counter.textColor.replaceAll("#", "0xFF")),
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
                                viewParameters: controller.viewParameters,
                                backgroundColor:
                                    controller.editCounter!.backgroundColor,
                                textColor: controller.editCounter!.textColor,
                                nameController: controller.nameController,
                                valueController: controller.valueController,
                                resetController: controller.resetController,
                                incrementalController:
                                    controller.incrementalController,
                                decrementalController:
                                    controller.decrementalController,
                                colors: controller.colors,
                                changeBackgroundColor: (selected) {
                                  controller.editCounter =
                                      controller.editCounter!.copyWith(
                                    id: controller.editCounter!.id,
                                    backgroundColor: selected,
                                  );
                                },
                                changeTextColor: (selected) {
                                  controller.editCounter =
                                      controller.editCounter!.copyWith(
                                    id: controller.editCounter!.id,
                                    textColor: selected,
                                  );
                                },
                                changeName: (name) {
                                  controller.editCounter =
                                      controller.editCounter!.copyWith(
                                    id: controller.editCounter!.id,
                                    name: name,
                                  );
                                },
                                onConfirm: () async {
                                  await pool.play(soundId);
                                  controller.editCounter =
                                      controller.editCounter!.copyWith(
                                    id: controller.editCounter!.id,
                                    value: int.parse(
                                        controller.valueController.value.text),
                                    reset: int.parse(
                                        controller.resetController.value.text),
                                    incremental: int.parse(controller
                                        .incrementalController.value.text),
                                    decremental: int.parse(controller
                                        .decrementalController.value.text),
                                  );
                                  await controller.updateCounter(
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
                                      !controller.viewParameters;
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
                ),
                // Posicionar al centro, abajo
                Positioned(
                  bottom: 3,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: !isLoading
                            ? IconButton(
                                icon: const Icon(
                                  Icons.remove,
                                  color: Colors.white,
                                ),
                                onPressed: () async {
                                  changeStateLoading(true);
                                  await playSound(soundId);
                                  await controller.decrementCounter(counter);
                                  changeStateLoading(false);
                                },
                              )
                            : const SizedBox(
                                height: 48,
                                width: 48,
                              ),
                      ),
                      Expanded(
                        child: Icon(
                          Icons.circle,
                          size: 15,
                          color: Color(
                            int.parse(
                              counter.textColor.replaceAll('#', '0xff'),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: !isLoading
                            ? IconButton(
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                                onPressed: () async {
                                  changeStateLoading(true);
                                  await playSound(soundId);
                                  await controller.incrementCounter(counter);
                                  changeStateLoading(false);
                                },
                              )
                            : const SizedBox(
                                height: 48,
                                width: 48,
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  changeStateLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }
}
