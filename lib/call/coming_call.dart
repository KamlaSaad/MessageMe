import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../common/shared.dart';
import 'call_controller.dart';

class IncomingCall extends StatefulWidget {
  @override
  _IncomingCallState createState() => _IncomingCallState();
}

class _IncomingCallState extends State<IncomingCall> {
  CallController callController = Get.put(CallController());
  Map call = Get.arguments;
  double w = Get.width * 0.12;
  String userName = "";
  @override
  Widget build(BuildContext context) {
//    var user = mainController.getUser(call["callerId"]);
//    String cN = mainController.isContact(user['phone']);
//    userName = cN.isEmpty ? user['username'] : cN;
    userName = call['name'];
    return Scaffold(
      backgroundColor: bodyColor.value,
      body: Padding(
        padding: EdgeInsets.only(top: Get.height * 0.1, right: w, left: w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            txt("${call['type']}", txtColor.value, 22, false),
            Space(0, 20),
            txt(userName, mainColor.value, 25, true),
            Space(0, Get.height * 0.2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                circleIcon(Colors.red, Colors.white, Icons.close, 30, "Reject",
                    false, () => callController.leaveCall()),
                circleIcon(Colors.green, Colors.white, Icons.phone, 30,
                    "Accept", false, () {
                  callController.channelName.value = call['channel'];
                  callController.remoteUid.value = 454564545;
                  Get.offNamed(
                      call['type'] == "Audio Call"
                          ? "/audioCall"
                          : "/videoCall",
                      arguments: [false, call]);
                }),
              ],
            )
          ],
        ),
      ),
    );
  }
}
