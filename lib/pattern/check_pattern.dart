import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../common/shared.dart';

class CheckPattern extends StatelessWidget {
  bool cancel = Get.arguments ?? false;
  var wrong = false.obs;
  @override
  Widget build(BuildContext context) {
    List pattern = mainController.lockPattern.value;
    return Scaffold(
      backgroundColor: bodyColor.value,
      appBar: AppBar(
        backgroundColor: bodyColor.value,
        leading: cancel
            ? myIcon(Icons.arrow_back, mainColor.value, 25, () => Get.back())
            : Space(0, 0),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Flexible(child: txt("Draw Your pattern", txtColor.value, 25, true)),
          Pattern((List<int> input) {
            print(mainController.lockPattern.value);
            print(input);
            if (listEquals(input, pattern)) {
              print(pattern);
              if (cancel) {
                mainController.changePatternVals("", "", [], false);
                Get.back();
              } else {
                Get.offAllNamed("/home");
              }
            } else {
              wrong.value = true;
              snackMsg("Wrong pattern please try again");
            }
          }),
          lockBtn("pattern", 0.6)
        ],
      ),
    );
  }
}
