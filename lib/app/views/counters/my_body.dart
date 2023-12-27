import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:vibration/vibration.dart';
import 'package:soundpool/soundpool.dart';

import 'package:smart_counter_app/app/views/counters/my_body_grid.dart';
import 'package:smart_counter_app/app/views/counters/my_body_list.dart';
import 'package:smart_counter_app/app/controllers/counters_controller.dart';

class MyBody extends StatefulWidget {
  const MyBody({
    super.key,
  });

  @override
  State<MyBody> createState() => _MyBodyState();
}

class _MyBodyState extends State<MyBody> {
  final controller = Get.find<CountersController>();
  late Soundpool pool;
  late int soundId;
  late final bool? hasVibrator;

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

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.counters.isEmpty
          ? const Center(
              child: Text(
                'No hay contadores',
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
              child: controller.group!.viewInGrid
                  ? const MyBodyGrid()
                  : const MyBodyList(),
            ),
    );
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
}
