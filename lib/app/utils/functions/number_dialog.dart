import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<int?> numberDialog(String text, List<int> numbers) async {
  int? gridCount;
  await Get.dialog(
    Dialog(
      child: SizedBox(
        height: 180,
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text),
            const SizedBox(height: 10),
            Container(
              height: 70,
              margin: const EdgeInsets.symmetric(horizontal: 15),
              child: ListView.separated(
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                scrollDirection: Axis.horizontal,
                itemCount: numbers.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return ElevatedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                    onPressed: () {
                      gridCount = numbers[index];
                      Get.back();
                    },
                    child: Text(
                      numbers[index].toString(),
                      style: const TextStyle(fontSize: 11),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
  return gridCount;
}
