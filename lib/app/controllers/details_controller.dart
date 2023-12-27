import 'dart:io';

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smart_counter_app/app/controllers/groups_controller.dart';
import 'package:smart_counter_app/app/models/datail_model.dart';
import 'package:smart_counter_app/app/models/group_model.dart';
import 'package:smart_counter_app/app/utils/database/datail_db.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

class DetailsController extends GetxController {
  final groupsController = Get.find<GroupsController>();
  final _details = <Detail>[].obs;

  Group? get group => groupsController.selectedGroupRx.value;

  set group(Group? value) => groupsController.selectedGroupRx.value = value;

  List<Detail> get details => _details.toList();

  late Worker _refreshDetailsWorker;

  @override
  void onInit() {
    _refreshDetailsWorker = ever(groupsController.selectedGroupRx, (_) {
      if (group != null) {
        group = _;
        refreshDetails();
      }
    });
    refreshDetails();
    super.onInit();
  }

  @override
  void onClose() {
    _refreshDetailsWorker.dispose();
    _details.close();
    super.onClose();
  }

  Future<void> refreshDetails() async {
    _details.assignAll(await DetailDB.allFromGroup(group!.id!));
  }

  Future<void> addDetail(Detail detail) async {
    await DetailDB.create(detail);
    await refreshDetails();
  }

  Future<void> deleteAllFromGroup() async {
    if (await DetailDB.deleteAllFromGroup(group!.id!)) {
      await refreshDetails();
    }
  }

  String shareDetailedHistory() {
    String text = "";
    for (var detail in details) {
      text +=
          "${detail.name},${DateFormat('EEE. dd/MM/yyyy HH:mm:ss', 'es').format(detail.date).capitalize},${detail.action},${detail.value}\n";
    }
    return text;
  }

  String getStringDetailedHistory() {
    String text = "";
    for (var detail in details) {
      text +=
          "${detail.name},${DateFormat('EEE. dd/MM/yyyy HH:mm:ss', 'es').format(detail.date).capitalize},${detail.action},${detail.value}\n";
    }
    return text;
  }

  Future<void> createExcel(List<Detail> details) async {
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];
    for (int i = 0; i < details.length; i++) {
      sheet.getRangeByName('A${i + 1}').setText(details[i].name);
      sheet.getRangeByName('B${i + 1}').setText(
            DateFormat('EEE. dd/MM/yyyy HH:mm:ss', 'es')
                .format(details[i].date)
                .capitalize,
          );
      sheet.getRangeByName('C${i + 1}').setText(details[i].action);
      sheet
          .getRangeByName('D${i + 1}')
          .setNumber(double.parse("${details[i].value}"));
    }
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final String path = (await getApplicationSupportDirectory()).path;
    final String fileName = "$path/${group!.name}.xlsx";
    final File file = File(fileName);
    await file.writeAsBytes(
      bytes,
      flush: true,
    );
    await OpenFile.open(fileName);
  }

  Future<File> createExcelFileWithSyncfusionWithFrequency({
    required List<Detail> details,
    required int minutes,
    required DateTime startDateTime,
    required DateTime endDateTime,
  }) async {
    // Crea un nuevo libro de trabajo
    final Workbook workbook = Workbook();
    final Worksheet sheet1 = workbook.worksheets[0];
    sheet1.name = "Frecuencias";

    final List<String> names = searchNames(details);

    // Guardar en una lista la hora desde inicio hasta fin, cada 5 minutos
    final List<DateTime> times = [];
    for (var i = startDateTime;
        i.isBefore(endDateTime);
        i = i.add(Duration(minutes: minutes))) {
      times.add(i);
    }
    times.add(endDateTime);

    // Iterar por ejemplo, desde las 07:00 hasta las 08:00, cada 5 minutos. Ejemplo: primer ciclo: 07:00 - 07:05, segundo ciclo: 07:05 - 07:10, etc.
    for (int i = 0; i < names.length; i++) {
      sheet1.getRangeByName('${String.fromCharCode(i + 67)}1').setText(
            names[i],
          );
    }

    for (int i = 0; i < times.length - 1; i++) {
      // Obtener el detalle de la hora actual
      sheet1.getRangeByName('${String.fromCharCode(65)}${i + 2}').setValue(
            DateFormat('HH:mm', 'es').format(times[i]),
          );
      sheet1.getRangeByName('${String.fromCharCode(66)}${i + 2}').setValue(
            DateFormat('HH:mm', 'es').format(times[i + 1]),
          );
      for (int j = 0; j < names.length; j++) {
        final name = names[j];
        // Obtener la cantidad de veces que se repite el nombre en la hora actual
        final int count = details
            .where((detail) =>
                detail.name == name &&
                detail.date.isAfter(times[i]) &&
                detail.date.isBefore(times[i + 1]))
            .length;
        sheet1
            .getRangeByName('${String.fromCharCode(j + 67)}${i + 2}')
            .numberFormat = '0';
        sheet1
            .getRangeByName('${String.fromCharCode(j + 67)}${i + 2}')
            .setValue(count);
      }
    }

    for (int i = 0; i < names.length; i++) {
      sheet1
          .getRangeByName('${String.fromCharCode(i + 67)}${times.length + 1}')
          .setFormula(
            "=SUM(${String.fromCharCode(i + 67)}2:${String.fromCharCode(i + 67)}${times.length})",
          );
    }

    final sheet2 = workbook.worksheets.addWithName("Detallado");

    for (int i = 0; i < details.length; i++) {
      sheet2.getRangeByName('A${i + 1}').setText(details[i].name);
      sheet2.getRangeByName('B${i + 1}').setText(
            DateFormat('EEE. dd/MM/yyyy HH:mm:ss', 'es')
                .format(details[i].date)
                .capitalize,
          );
      sheet2.getRangeByName('C${i + 1}').setText(details[i].action);
      sheet2
          .getRangeByName('D${i + 1}')
          .setNumber(double.parse("${details[i].value}"));
    }

    // Guarda el archivo en el almacenamiento temporal del dispositivo
    final directory = await getTemporaryDirectory();
    final file =
        File('${directory.path}/${group!.name.replaceAll("/", "-")}.txt');
    final List<int> bytes = workbook.saveAsStream();
    await file.writeAsBytes(bytes);

    // Cierra el libro de trabajo
    workbook.dispose();

    return file;
  }

  Future<void> shareFile(File file) async {
    final xFile = XFile(
      file.path,
    );
    await Share.shareXFiles(
      [xFile],
      text: "Historial detallado de ${group!.name}",
    );
  }

  List<String> searchNames(List<Detail> details) {
    final List<String> names = [];
    for (var detail in details) {
      if (!names.contains(detail.name)) {
        names.add(detail.name);
      }
    }
    return names;
  }

  Future<File> createTxtFile(List<Detail> details) async {
    final String text = getStringDetailedHistory();
    final directory = await getTemporaryDirectory();
    final file =
        File('${directory.path}/${group!.name.replaceAll("/", "-")}.txt');
    return file.writeAsString(text);
  }

  Future<File> createExcelFileWithSyncfusion(List<Detail> details) async {
    // Crea un nuevo libro de trabajo
    final Workbook workbook = Workbook();
    final Worksheet sheet = workbook.worksheets[0];

    final List<String> names = searchNames(details);

    // Iterar cada nombre y agregarlo a la hoja de cálculo
    for (int i = 0; i < names.length; i++) {
      for (int j = 0; j < details.length; j++) {
        if (details[j].name == names[i]) {
          sheet.getRangeByName('A${j + 1}').setText(details[j].name);
          sheet.getRangeByName('B${j + 1}').setValue(
                DateFormat('dd/MM/yyyy', 'es').format(details[j].date),
              );
          sheet.getRangeByName('C${j + 1}').setValue(
                DateFormat('HH:mm:ss', 'es').format(details[j].date),
              );
          sheet.getRangeByName('D${j + 1}').setText(details[j].action);
          sheet
              .getRangeByName('E${j + 1}')
              .setNumber(double.parse("${details[j].value}"));
        }
      }
    }

    // Guarda el archivo en el almacenamiento temporal del dispositivo
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/${group!.name}.xlsx');
    final List<int> bytes = workbook.saveAsStream();
    await file.writeAsBytes(bytes);

    // Cierra el libro de trabajo
    workbook.dispose();

    return file;
  }

  Future<void> shareDetailedHistoryWithSyncfusion() async {
    final File file = await createExcelFileWithSyncfusion(details);
    await shareFile(file);
  }
}
