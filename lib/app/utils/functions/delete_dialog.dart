import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<bool> deleteDialog({
    required String title,
    required String middleText,
    required Future<void> Function() onConfirm,
    required Future<void> Function() onCancel,
  }) async {
    bool dismissed = false;
    await Get.defaultDialog(
      contentPadding: const EdgeInsets.symmetric(
        vertical: 20,
        horizontal: 15,
      ),
      titlePadding: const EdgeInsets.all(20),
      title: title,
      middleText: middleText,
      confirm: TextButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(
            Colors.green,
          ),
        ),
        onPressed: () async {
          await onConfirm();
          dismissed = true;
          Get.back();
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
        onPressed: () async {
          await onCancel();
          dismissed = false;
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
    return dismissed;
  }