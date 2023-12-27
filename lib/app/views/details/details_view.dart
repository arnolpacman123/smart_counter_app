import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:smart_counter_app/app/controllers/details_controller.dart';
import 'package:smart_counter_app/app/models/counter_model.dart';
import 'package:smart_counter_app/app/utils/functions/number_dialog.dart';

class DetailsView extends StatelessWidget {
  DetailsView({super.key});

  final controller = Get.find<DetailsController>();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.group == null
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : DefaultTabController(
              length: 2, // Número de pestañas
              initialIndex: 0, // Pestaña inicial
              child: Scaffold(
                appBar: MyAppBar(),
                body: const TabBarView(
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    Status(),
                    DetailedHistory(),
                  ],
                ),
              ),
            ),
    );
  }
}

class Status extends StatefulWidget {
  const Status({super.key});

  @override
  State<Status> createState() => _StatusState();
}

class _StatusState extends State<Status> {
  final controller = Get.find<DetailsController>();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.group!.counters!.isEmpty
          ? const Center(
              child: Text("No hay datos para mostrar"),
            )
          : Container(
              margin: const EdgeInsets.symmetric(
                vertical: 20,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: DoughnutSection(
                      counters: controller.group!.counters!,
                    ),
                  ),
                  Expanded(
                    child: BarSection(
                      counters: controller.group!.counters!,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class DoughnutSection extends StatelessWidget {
  const DoughnutSection({
    super.key,
    required this.counters,
  });

  final List<Counter> counters;

  @override
  Widget build(BuildContext context) {
    return SfCircularChart(
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      palette: const [
        Colors.red,
        Colors.blue,
        Colors.green,
        Colors.yellow,
        Colors.purple,
        Colors.orange,
        Colors.pink,
        Colors.brown,
        Colors.grey,
        Colors.teal,
        Colors.indigo,
        Colors.lime,
        Colors.cyan,
      ],
      legend: const Legend(
        isVisible: true,
        isResponsive: true,
        overflowMode: LegendItemOverflowMode.wrap,
        textStyle: TextStyle(
          color: Colors.black,
        ),
        position: LegendPosition.bottom,
        alignment: ChartAlignment.center,
        shouldAlwaysShowScrollbar: true,
      ),
      series: <CircularSeries>[
        DoughnutSeries<Counter, String>(
          dataSource: counters,
          xValueMapper: (Counter data, _) => data.name,
          yValueMapper: (Counter data, _) => data.value,
          enableTooltip: true,
          legendIconType: LegendIconType.circle,
          radius: "100%",
          innerRadius: "80%",
          dataLabelMapper: (Counter data, _) => "${data.name}\n${data.value}",
        ),
      ],
    );
  }
}

class BarSection extends StatelessWidget {
  const BarSection({
    super.key,
    required this.counters,
  });

  final List<Counter> counters;

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      margin: const EdgeInsets.symmetric(
        vertical: 20,
        horizontal: 10,
      ),
      primaryXAxis: CategoryAxis(
        labelStyle: const TextStyle(
          color: Colors.black,
        ),
      ),
      primaryYAxis: NumericAxis(
        labelStyle: const TextStyle(
          color: Colors.black,
        ),
      ),
      series: <ChartSeries>[
        BarSeries<Counter, String>(
          dataSource: counters,
          xValueMapper: (Counter data, _) => data.name,
          yValueMapper: (Counter data, _) => data.value,
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            textStyle: TextStyle(
              color: Colors.black,
            ),
          ),
          enableTooltip: true,
          legendIconType: LegendIconType.circle,
        ),
      ],
    );
  }
}

class DetailedHistory extends StatefulWidget {
  const DetailedHistory({super.key});

  @override
  State<DetailedHistory> createState() => _DetailedHistoryState();
}

class _DetailedHistoryState extends State<DetailedHistory> {
  final controller = Get.find<DetailsController>();

  @override
  void initState() {
    initializeDateFormatting();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        color: Color(
          int.parse(
            controller.group!.backgroundColor.replaceAll(
              "#",
              "0xFF",
            ),
          ),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              dividerThickness: 0,
              columns: ["Nombre", "Fecha", "Acción", "Valor"]
                  .map(
                    (e) => DataColumn(
                      label: Center(
                        child: Text(
                          e,
                          style: TextStyle(
                            color: Color(
                              int.parse(
                                controller.group!.textColor.replaceAll(
                                  "#",
                                  "0xFF",
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
              rows: controller.details
                  .map(
                    (e) => DataRow(
                      cells: [
                        DataCell(
                          Center(
                            child: Text(
                              e.name,
                              style: TextStyle(
                                color: Color(
                                  int.parse(
                                    controller.group!.textColor.replaceAll(
                                      "#",
                                      "0xFF",
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Center(
                            child: Text(
                              DateFormat('EEE., dd/MM/yyyy h:mm:ss a', 'es')
                                  .format(e.date)
                                  .toLowerCase(),
                              style: TextStyle(
                                color: Color(
                                  int.parse(
                                    controller.group!.textColor.replaceAll(
                                      "#",
                                      "0xFF",
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Center(
                            child: Text(
                              e.action,
                              style: TextStyle(
                                color: Color(
                                  int.parse(
                                    controller.group!.textColor.replaceAll(
                                      "#",
                                      "0xFF",
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Center(
                            child: Text(
                              e.value.toString(),
                              style: TextStyle(
                                color: Color(
                                  int.parse(
                                    controller.group!.textColor.replaceAll(
                                      "#",
                                      "0xFF",
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  MyAppBar({
    super.key,
  });

  final controller = Get.find<DetailsController>();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AppBar(
        elevation: 30,
        centerTitle: true,
        backgroundColor: Color(
          int.parse(
            controller.group!.backgroundColor.replaceAll(
              "#",
              "0xFF",
            ),
          ),
        ),
        title: AutoSizeText(
          controller.group!.name,
          maxLines: 1,
          minFontSize: 10,
          style: TextStyle(
            color: Color(
              int.parse(
                controller.group!.textColor.replaceAll("#", "0xFF"),
              ),
            ),
            fontSize: 17,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color(
              int.parse(
                controller.group!.textColor.replaceAll("#", "0xFF"),
              ),
            ),
          ),
          onPressed: () => Get.back(),
        ),
        actions: [
          PopupMenuButton(
            icon: Icon(
              Icons.more_vert,
              color: Color(
                int.parse(
                  controller.group!.textColor.replaceAll("#", "0xFF"),
                ),
              ),
            ),
            itemBuilder: (context) => [
              "Exportar En Texto",
              "Exportar En Excel",
            ]
                .map(
                  (e) => PopupMenuItem(
                    value: e,
                    child: Text(e),
                  ),
                )
                .toList(),
            onSelected: (value) async {
              switch (value) {
                case "Exportar En Texto":
                  final file = await controller.createTxtFile(
                    controller.details,
                  );
                  await controller.shareFile(file);
                  break;
                case "Exportar En Excel":
                  if (!context.mounted) return;
                  final datetime = await showDatePicker(
                    context: context,
                    locale: const Locale("es", "ES"),
                    initialDate: controller.details.isNotEmpty
                        ? controller.details.first.date
                        : DateTime.now(),
                    firstDate: DateTime(2010),
                    lastDate: DateTime(2030),
                  );
                  if (datetime == null) return;
                  if (!context.mounted) return;
                  final startTime = await showTimePicker(
                    context: context,
                    builder: (context, child) {
                      return MediaQuery(
                        data: MediaQuery.of(context).copyWith(
                          alwaysUse24HourFormat: true,
                        ),
                        child: child!,
                      );
                    },
                    initialTime: TimeOfDay.now(),
                    initialEntryMode: TimePickerEntryMode.input,
                    helpText: "Hora de inicio",
                    barrierLabel: "Hora de inicio",
                  );
                  if (startTime == null) return;
                  if (!context.mounted) return;
                  final endTime = await showTimePicker(
                    context: context,
                    builder: (context, child) {
                      return MediaQuery(
                        data: MediaQuery.of(context).copyWith(
                          alwaysUse24HourFormat: true,
                        ),
                        child: child!,
                      );
                    },
                    initialTime: TimeOfDay.now(),
                    initialEntryMode: TimePickerEntryMode.input,
                    helpText: "Hora de fin",
                    barrierLabel: "Hora de fin",
                  );
                  if (endTime == null) return;
                  final minutes = await numberDialog(
                    "¿Cada cuántos minutos?",
                    [1, 2, 3, 4, 5, 10, 15, 20, 30, 60],
                  );
                  if (minutes == null) return;
                  final startDateTime = DateTime(
                    datetime.year,
                    datetime.month,
                    datetime.day,
                    startTime.hour,
                    startTime.minute,
                  );
                  final endDateTime = DateTime(
                    datetime.year,
                    datetime.month,
                    datetime.day,
                    endTime.hour,
                    endTime.minute,
                  );
                  final file = await controller
                      .createExcelFileWithSyncfusionWithFrequency(
                    details: controller.details,
                    minutes: minutes,
                    startDateTime: startDateTime,
                    endDateTime: endDateTime,
                  );
                  await controller.shareFile(file);
                  break;
              }
            },
          ),
        ],
        bottom: TabBar(
          indicatorColor: Color(
            int.parse(
              controller.group!.textColor.replaceAll(
                "#",
                "0xFF",
              ),
            ),
          ),
          isScrollable: true,
          tabs: ["Estado", "Historial detallado"]
              .map(
                (e) => Tab(
                  child: Text(
                    e,
                    style: TextStyle(
                      color: Color(
                        int.parse(
                          controller.group!.textColor.replaceAll(
                            "#",
                            "0xFF",
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}
