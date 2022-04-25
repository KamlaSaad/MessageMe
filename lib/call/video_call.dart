import 'package:chatting/common/shared.dart';
import 'package:chatting/main/timer.dart';
import "package:flutter/material.dart";
import 'call_controller.dart';
import 'package:get/get.dart';
import 'dart:async';

class VideoCall extends StatefulWidget {
  @override
  _VideoCallState createState() => _VideoCallState();
}

class _VideoCallState extends State<VideoCall> {
  CallController callController = Get.put(CallController());
  late TimerController tc;
  var calling = false.obs;
  bool caller = Get.arguments[0];
  Map call = Get.arguments[1];
  int i = 0;
  late Timer waitTimer;
  @override
  void initState() {
    super.initState();
    caller
        ? callController.initCall(call['type'], call['receivers'])
        : callController.joinCall();
//    waitTimer =Timer.periodic(Duration(seconds: 1), (timer) => incrementWaitTimer());
  }

  @override
  void dispose() {
    callController.leaveCall();
//    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bodyColor.value,
      body: Stack(
        children: [
          Center(
              child: callController.RemoteView(callController.remoteUid.value)),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: EdgeInsets.all(6),
                width: Get.width * 0.4,
                height: Get.height * 0.28,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: callController.LocalView()),
              ),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            child: Container(
              width: Get.width,
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  Obx(() => callController.calling.value
                      ? txt(tc.result.value, txtColor.value, 22, false)
                      : Space(0, 0)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      circleIcon(
                          boxColor.value,
                          txtColor.value,
                          callController.muted.value
                              ? Icons.mic_off
                              : Icons.mic,
                          26,
                          "",
                          false,
                          () => callController.toggleMute),
                      Space(Get.width * 0.1, 0),
                      circleIcon(Colors.red, Colors.white, Icons.call_end, 32,
                          "", false, () {
//                        callController.remoteUid.value = 1234567892;
                        callController.leaveCall();
                      }),
                      Space(Get.width * 0.1, 0),
                      circleIcon(
                          boxColor.value,
                          txtColor.value,
                          Icons.switch_camera,
                          26,
                          "",
                          false,
                          () => callController.switchCamera()),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
