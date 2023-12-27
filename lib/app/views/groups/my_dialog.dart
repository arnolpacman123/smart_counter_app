import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:smart_counter_app/app/utils/widgets/list_color.dart';

class MyDialog extends StatelessWidget {
  const MyDialog({
    super.key,
    required this.backgroundColor,
    required this.textColor,
    this.onWillPop,
    required this.nameController,
    this.changeBackgroundColor,
    this.changeTextColor,
    required this.colors,
    required this.onConfirm,
    required this.onCancel,
    required this.textCancel,
    required this.textConfirm,
    this.changeName,
  });
  final String backgroundColor;
  final String textColor;
  final void Function()? onWillPop;
  final TextEditingController nameController;
  final void Function(String selected)? changeBackgroundColor;
  final void Function(String selected)? changeTextColor;
  final void Function(String name)? changeName;
  final List<String> colors;
  final void Function() onConfirm;
  final void Function() onCancel;
  final String textCancel;
  final String textConfirm;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (_) {
        if (onWillPop != null) {
          onWillPop!();
        }
      },
      child: Dialog(
        backgroundColor: Color(
          int.parse(
            backgroundColor.replaceAll("#", "0xFF"),
          ),
        ),
        child: Container(
          width: double.infinity,
          height: 350,
          margin: const EdgeInsets.symmetric(
            horizontal: 30,
            vertical: 20,
          ),
          child: ListView(
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
                    borderSide: BorderSide(
                      color:
                          Color(int.parse(textColor.replaceAll("#", "0xFF"))),
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color:
                          Color(int.parse(textColor.replaceAll("#", "0xFF"))),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color:
                          Color(int.parse(textColor.replaceAll("#", "0xFF"))),
                    ),
                  ),
                  label: Text(
                    'Nombre del grupo',
                    style: TextStyle(
                      color: Color(
                        int.parse(textColor.replaceAll("#", "0xFF")),
                      ),
                    ),
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
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
              const SizedBox(height: 25),
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
    );
  }
}
