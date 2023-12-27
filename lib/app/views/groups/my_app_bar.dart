import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:smart_counter_app/app/controllers/groups_controller.dart';
import 'package:smart_counter_app/app/models/group_model.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  MyAppBar({super.key});

  final controller = Get.find<GroupsController>();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      leading: Builder(
        builder: (context) {
          return IconButton(
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          );
        },
      ),
      title: const Text(
        'Grupos',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      actions: [
        PopupMenuButton(
          icon: const Icon(
            Icons.more_vert,
            color: Colors.white,
          ),
          onSelected: (String result) async {
            switch (result) {
              case "Importar Grupo":
                // controller.importGroup();
                final file = await selectFile();
                if (file == null) return;
                // Leer el archivo json
                final json = await file.readAsString();
                final map = controller.jsonGroupToMap(json);
                if (map == null) {
                  showSnackBar(
                    'Error',
                    'El archivo seleccionado no tiene un formato correcto',
                  );
                  return;
                }
                // Crear el grupo
                final group = Group.fromJson(map);
                await controller.importGroup(group);
                break;
            }
          },
          itemBuilder: (context) => ["Importar Grupo"]
              .map(
                (String choice) => PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  void showSnackBar(String title, String message) {
    Get.snackbar(
      title,
      message,
      titleText: Center(
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      backgroundColor: Colors.red,
      colorText: Colors.white,
      borderRadius: 10,
    );
  }

  Future<File?> selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      allowMultiple: false,
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      return file;
    } else {
      return null;
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
