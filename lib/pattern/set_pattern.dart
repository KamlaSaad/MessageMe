import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../common/shared.dart';

class SetPattern extends StatefulWidget {
  @override
  _SetPatternState createState() => _SetPatternState();
}

class _SetPatternState extends State<SetPattern> {
  bool isConfirm = false;
  List<int> pattern = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bodyColor.value,
      appBar: AppBar(
        backgroundColor: bodyColor.value,
        leading: myIcon(Icons.arrow_back, mainColor.value, 25, () => Get.back()),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Flexible(
            child: txt(isConfirm ? "Confirm pattern" : "Draw pattern",
                txtColor.value, 25, true),
          ),
          Pattern(
            (List<int> input) {
              if (input.length < 3) {
                snackMsg("At least 3 points required");
                return;
              }
              if (isConfirm) {
                if (listEquals<int>(input, pattern)) {
                  mainController.changePatternVals(
                      "pattern", "", pattern, true);
                  Get.back();
                } else {
                  snackMsg("Pattern doesn't match try again");
                  setState(() {
                    pattern = [];
                    isConfirm = false;
                  });
                }
              } else {
                setState(() {
                  pattern = input;
                  isConfirm = true;
                });
              }
            },
          ),
          Space(0, Get.height * 0.1),
        ],
      ),
    );
  }
}
