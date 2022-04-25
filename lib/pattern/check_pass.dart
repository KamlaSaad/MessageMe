import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../common/shared.dart';

class CheckPass extends StatelessWidget {
  final StreamController<bool> verNotifier = StreamController<bool>.broadcast();
  var wrong = false.obs;
  bool cancel = Get.arguments ?? false;
  String pass = mainController.lockPIN.value;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bodyColor.value,
      appBar: AppBar(
        backgroundColor: bodyColor.value,
        leading: cancel
            ? myIcon(Icons.arrow_back, mainColor.value, 25, () => Get.back())
            : null,
      ),
      body: Pass("entr".tr + " " + "pass".tr, (val) {
        print("val $val");
        verNotifier.add(pass == val);
        if (pass == val) {
          if (cancel) {
            //cancel lock
            mainController.changePatternVals("", "", [], false);
            Get.back();
          } else {
            Get.offAllNamed("/home");
          }
        } else {
          wrong.value = true;
          snackMsg("wrong".tr + " " + "pass".tr + " " + "tryAgain".tr);
        }
      }, verNotifier.stream),
    );
  }
}
