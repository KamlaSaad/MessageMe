import "package:flutter/material.dart";
import 'call_controller.dart';
import 'package:get/get.dart';
import '../common/shared.dart';
import '../main/timer.dart';
import 'dart:async';

class AudioCallScreen extends StatefulWidget {
  const AudioCallScreen({Key? key}) : super(key: key);

  @override
  _AudioCallScreenState createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> {
  CallController callController = Get.put(CallController());
  TimerController tc = TimerController();
  late Timer callTimer;
  var calling = false.obs;
  bool caller = Get.arguments[0], showTimer = false;
  Map call = Get.arguments[1];
  int i = 0;
  String name = "", img = "";
  @override
  void initState() {
    name = callController.callName.value;
    img = callController.callImg.value;
    caller
        ? callController.initCall(call['type'], call['receivers'])
        : callController.joinCall();
    if (callController.remoteUid != 0) {
      setState(() => showTimer = true);
      tc.startTimer();
    }
//    waitTimer =
//        Timer.periodic(Duration(seconds: 1), (timer) => incrementWaitTimer());
    super.initState();
  }

  @override
  void dispose() {
    tc.stopTimer();
    callController.leaveCall();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bodyColor.value,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ProfileImg(80, img, "user", mainColor.value),
                Space(0, 15),
                txt(name, mainColor.value, 24, true),
                Space(0, Get.height * 0.12),
                txt(!showTimer ? "Calling …" : "${tc.result}", txtColor.value,
                    20, true),
                Space(0, 10),
//                Obx(() => callController.calling.value
//                    ? txt("${tc.duration.value}", txtColor.value, 22, false)
//                    : Space(0, 0)),
              ],
            ),
          ),
          Positioned(
              bottom: Get.height * 0.02,
              right: Get.width * 0.1,
              child: myIcon(Icons.call_end, Colors.red, 54, () {
//                callController.calling.value = true;
                callController.leaveCall();
                tc.stopTimer();
              })),
        ],
      ),
    );
  }
}
