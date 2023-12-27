import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'package:smart_counter_app/app/utils/widgets/list_color.dart';

class MyDialog extends StatelessWidget {
  const MyDialog({
    super.key,
    required this.colors,
    required this.nameController,
    required this.backgroundColor,
    required this.textColor,
    required this.viewParameters,
    this.changeBackgroundColor,
    this.changeTextColor,
    this.changeName,
    this.onWillPop,
    this.changeViewParameters,
    this.valueController,
    this.resetController,
    this.incrementalController,
    this.decrementalController,
    required this.onCancel,
    required this.onConfirm,
    this.textCancel = 'Cancelar',
    this.textConfirm = 'Confirmar',
  });

  final List<String> colors;
  final TextEditingController nameController;
  final TextEditingController? valueController;
  final TextEditingController? resetController;
  final TextEditingController? incrementalController;
  final TextEditingController? decrementalController;
  final String backgroundColor;
  final String textColor;
  final bool viewParameters;
  final void Function(String selected)? changeBackgroundColor;
  final void Function(String selected)? changeTextColor;
  final void Function(String)? changeName;
  final void Function()? onWillPop;
  final void Function()? changeViewParameters;
  final void Function() onCancel;
  final void Function() onConfirm;
  final String textCancel;
  final String textConfirm;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: Dialog(
        backgroundColor: Color(
          int.parse(backgroundColor.replaceAll('#', '0xFF')),
        ),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(
            horizontal: 30,
            vertical: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  onChanged: (value) {
                    if (changeName != null) {
                      changeName!(value);
                    }
                  },
                  style: TextStyle(
                    color: Color(
                      int.parse(textColor.replaceAll("#", "0xFF")),
                    ),
                  ),
                  cursorColor: Color(
                    int.parse(textColor.replaceAll("#", "0xFF")),
                  ),
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Color(
                          int.parse(textColor.replaceAll("#", "0xFF")),
                        ),
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Color(
                          int.parse(textColor.replaceAll("#", "0xFF")),
                        ),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Color(
                          int.parse(textColor.replaceAll("#", "0xFF")),
                        ),
                      ),
                    ),
                    labelStyle: TextStyle(
                      color: Color(
                        int.parse(textColor.replaceAll("#", "0xFF")),
                      ),
                    ),
                    counterStyle: TextStyle(
                      color: Color(
                        int.parse(textColor.replaceAll("#", "0xFF")),
                      ),
                    ),
                    hoverColor: Color(
                      int.parse(textColor.replaceAll("#", "0xFF")),
                    ),
                    fillColor: Color(
                      int.parse(textColor.replaceAll("#", "0xFF")),
                    ),
                    focusColor: Color(
                      int.parse(textColor.replaceAll("#", "0xFF")),
                    ),
                    labelText: 'Nombre del contador',
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Color del fondo',
                  style: TextStyle(
                    color: Color(
                      int.parse(
                        textColor.replaceAll("#", "0xFF"),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ListColor(
                  onSelected: (selected) {
                    if (changeBackgroundColor != null) {
                      changeBackgroundColor!(selected);
                    }
                  },
                  colors: colors,
                  indexSelected: colors.indexOf(
                    backgroundColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Color del texto',
                  style: TextStyle(
                    color: Color(
                      int.parse(
                        textColor.replaceAll("#", "0xFF"),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ListColor(
                  onSelected: (selected) {
                    if (changeTextColor != null) {
                      changeTextColor!(selected);
                    }
                  },
                  colors: colors,
                  indexSelected: colors.indexOf(
                    textColor,
                  ),
                ),
                const SizedBox(height: 10),
                if (viewParameters)
                  Column(
                    children: [
                      SizedBox(
                        height: 48,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: valueController,
                                style: TextStyle(
                                  color: Color(
                                    int.parse(
                                      textColor.replaceAll("#", "0xFF"),
                                    ),
                                  ),
                                ),
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Color(
                                        int.parse(
                                          textColor.replaceAll("#", "0xFF"),
                                        ),
                                      ),
                                    ),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Color(
                                        int.parse(
                                          textColor.replaceAll("#", "0xFF"),
                                        ),
                                      ),
                                    ),
                                  ),
                                  label: Text(
                                    'Valor',
                                    style: TextStyle(
                                      color: Color(
                                        int.parse(
                                          textColor.replaceAll("#", "0xFF"),
                                        ),
                                      ),
                                      fontSize: 13,
                                    ),
                                  ),
                                  border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: resetController,
                                style: TextStyle(
                                  color: Color(
                                    int.parse(
                                      textColor.replaceAll("#", "0xFF"),
                                    ),
                                  ),
                                ),
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Color(
                                        int.parse(
                                          textColor.replaceAll("#", "0xFF"),
                                        ),
                                      ),
                                    ),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Color(
                                        int.parse(
                                          textColor.replaceAll("#", "0xFF"),
                                        ),
                                      ),
                                    ),
                                  ),
                                  label: Text(
                                    'Valor de reinicio',
                                    style: TextStyle(
                                      color: Color(
                                        int.parse(
                                          textColor.replaceAll("#", "0xFF"),
                                        ),
                                      ),
                                      fontSize: 13,
                                    ),
                                  ),
                                  border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 48,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: incrementalController,
                                style: TextStyle(
                                  color: Color(
                                    int.parse(
                                      textColor.replaceAll("#", "0xFF"),
                                    ),
                                  ),
                                ),
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Color(
                                        int.parse(
                                          textColor.replaceAll("#", "0xFF"),
                                        ),
                                      ),
                                    ),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Color(
                                        int.parse(
                                          textColor.replaceAll("#", "0xFF"),
                                        ),
                                      ),
                                    ),
                                  ),
                                  label: Text(
                                    'Incremento(+)',
                                    style: TextStyle(
                                      color: Color(
                                        int.parse(
                                          textColor.replaceAll("#", "0xFF"),
                                        ),
                                      ),
                                      fontSize: 13,
                                    ),
                                  ),
                                  border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: decrementalController,
                                style: TextStyle(
                                  color: Color(
                                    int.parse(
                                      textColor.replaceAll("#", "0xFF"),
                                    ),
                                  ),
                                ),
                                decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Color(
                                        int.parse(
                                          textColor.replaceAll("#", "0xFF"),
                                        ),
                                      ),
                                    ),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: Color(
                                        int.parse(
                                          textColor.replaceAll("#", "0xFF"),
                                        ),
                                      ),
                                    ),
                                  ),
                                  label: Text(
                                    'Decremento(-)',
                                    style: TextStyle(
                                      color: Color(
                                        int.parse(
                                          textColor.replaceAll("#", "0xFF"),
                                        ),
                                      ),
                                      fontSize: 13,
                                    ),
                                  ),
                                  border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 10),
                Container(
                  height: 48,
                  width: 155,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Color(
                        int.parse(
                          textColor.replaceAll("#", "0xFF"),
                        ),
                      ),
                    ),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Color(
                        int.parse(
                          backgroundColor.replaceAll("#", "0xFF"),
                        ),
                      ),
                    ),
                    onPressed: () {
                      if (changeViewParameters != null) {
                        changeViewParameters!();
                      }
                    },
                    child: SizedBox(
                      width: 155,
                      child: AutoSizeText(
                        viewParameters
                            ? 'Ocultar parámetros'
                            : 'Ver parámetros',
                        maxLines: 1,
                        minFontSize: 11,
                        overflow: TextOverflow.ellipsis,
                        wrapWords: true,
                        style: TextStyle(
                          color: Color(
                            int.parse(
                              textColor.replaceAll("#", "0xFF"),
                            ),
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        onCancel();
                        Get.back(); // Cierra el diálogo
                      },
                      child: Text(
                        textCancel,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        onConfirm();
                        Get.back(); // Cierra el diálogo
                      },
                      child: Text(
                        textConfirm,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      onPopInvoked: (_) {
        if (onWillPop != null) {
          onWillPop!();
        }
      },
    );
  }
}