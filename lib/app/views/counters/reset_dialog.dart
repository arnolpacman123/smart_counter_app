import 'package:flutter/material.dart';
import 'package:get/get.dart';

void resetDialog({
  required VoidCallback onConfirm,
}) {
  // Diálogo de confirmación si desea reiniciar
  Get.defaultDialog(
    contentPadding: const EdgeInsets.symmetric(
      vertical: 20,
      horizontal: 15,
    ),
    titlePadding: const EdgeInsets.all(20),
    title: "Reiniciar contador",
    middleText: "¿Está seguro que desea reiniciar el contador?",
    confirm: TextButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          Colors.green,
        ),
      ),
      onPressed: () async {
        onConfirm();
      },
      child: const Text(
        "Sí",
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    ),
    cancel: TextButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(
          Colors.red,
        ),
      ),
      onPressed: () {
        Get.back();
      },
      child: const Text(
        "No",
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    ),
  );
}
