import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../common/shared.dart';

class SetPass extends StatefulWidget {
  @override
  _SetPassState createState() => _SetPassState();
}

class _SetPassState extends State<SetPass> {
  final StreamController<bool> verNotifier = StreamController<bool>.broadcast();
  bool confirm = false;
  String pass = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: bodyColor.value,
        appBar: AppBar(
          backgroundColor: bodyColor.value,
          leading: myIcon(Icons.arrow_back, mainColor.value, 25, () => Get.back()),
        ),
        body: Pass(" ${confirm ? 'Reenter' : 'Enter'} Password", (val) {
          print("val $val");
          if (confirm) {
            if (pass == val) {
              mainController.changePatternVals("PIN", val, [], true);
              print("result $val");
              Get.back();
            } else {
              verNotifier.add(false);
              mainController.locked.value = false;
              setState(() => confirm = false);
              snackMsg("Password doesn't match");
            }
          } else {
            mainController.locked.value = false;
            setState(() {
              pass = val;
              confirm = true;
              verNotifier.add(false);
            });
          }
        }, verNotifier.stream));
  }
}
