import 'package:chatting/common/shared.dart';
import 'package:chatting/main/location.dart';
import 'package:chatting/main/record_msg.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

Widget Message(Map msgD, String chatType, Color favColor) {
  Map msgData = msgD;
  bool isSender = msgData['sender'] == myId,
      showName = isSender == false && chatType == "group";
  String date = mainController.msgDate(msgData['date'], false);
  double horiz = 10;
  Map reply = msgData['reply'];
  var displayDate = false.obs,
      msg = null,
      crossAxis = CrossAxisAlignment.center,
      friendData = mainController.getUser(msgData['sender']),
      hintedUserData = msgData['hintedUser'].isNotEmpty
          ? mainController.getUser(msgData['hintedUser'])
          : {},
      hintedUserName = hintedUserData.isNotEmpty
          ? ("${hintedUserData['name']}".isEmpty
              ? "${hintedUserData['username']}"
              : "${hintedUserData['name']}")
          : "",
      margin = EdgeInsets.symmetric(horizontal: horiz, vertical: 8);
  print(" hintedUser ${msgData['hintedUser']}");
  Color backBgColor = isSender ? boxColor.value : favColor,
      textColor =
          backBgColor == mainColor.value ? Colors.white : txtColor.value;
  var msgK = Key("");
  switch (msgData['type']) {
    case "hint":
      msg = txt(msgData['text'] + " $hintedUserName", textColor, 20, false);
      crossAxis = CrossAxisAlignment.center;
      break;
    case "img":
    case "video":
      msg = MediaMsg(
          msgData['type'] == "img", msgData['url'], msgData['text'], isSender);
      crossAxis = CrossAxisAlignment.end;
      break;
    case "audio":
      msg = RecordMsg(int.parse(msgData['text']), msgData['url']);
      break;
    case "file":
      msg = FileMsg(msgData['text']);
      break;
    case "location":
      msg = locationMsg(msgData['text'], msgData['url']);
      break;
    default:
      msg = RichText(
        text: TextSpan(
            text: msgData['text'],
            style: TextStyle(color: Colors.white, fontSize: 22)),
      );
  }
  return Row(
    mainAxisSize: MainAxisSize.max,
    crossAxisAlignment: crossAxis,
    mainAxisAlignment: msgData['type'] == 'hint'
        ? MainAxisAlignment.center
        : (isSender ? MainAxisAlignment.end : MainAxisAlignment.start),
    children: [
      Column(
        crossAxisAlignment: msgData['type'] == 'hint'
            ? CrossAxisAlignment.center
            : (isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start),
        children: [
          Stack(children: [
            GestureDetector(
              child: Padding(
                padding: margin,
                child: Column(
                  crossAxisAlignment: msgData['type'] == 'hint'
                      ? CrossAxisAlignment.center
                      : isSender
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                  children: [
                    showName
                        ? txt(friendData['name'],
                            txtColor.value.withOpacity(0.8), 16, false)
                        : Space(0, 0),
                    Space(0, 3),
                    Container(
                        key: msgK,
                        padding: margin,
                        constraints: BoxConstraints(
                            minWidth: 30, maxWidth: Get.width * 0.6),
                        decoration: BoxDecoration(
                            color: backBgColor,
                            borderRadius: BorderRadius.circular(12)),
                        child: reply.isNotEmpty
                            ? Column(
                                children: [
                                  replyBox(reply, isSender, false),
                                  msg
                                ],
                              )
                            : msg),
                  ],
                ),
              ),
              onTap: () => displayDate.value = !displayDate.value,
              onLongPress: () async {
                if (msgData['type'] != "hint") {
                  showMsgOptions(msgData, favColor);
                }
              },
            ),
            //reacts
            Obx(() => FutureBuilder(
                key: chatController.msgKey.value,
                future: chatController.getReacts(msgData['id']),
                builder: (context, AsyncSnapshot snap) {
                  return snap.hasData
                      ? snap.data.length > 0
                          ? (isSender
                              ? Positioned(
                                  bottom: 5,
                                  left: 0,
                                  child: reactIcon(
                                      backBgColor, isSender, snap.data))
                              : Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: reactIcon(
                                      backBgColor, isSender, snap.data)))
                          : Space(0, 0)
                      : Space(0, 0);
                }))
          ]),
          Obx(() => displayDate.value
              ? Padding(
                  padding: const EdgeInsets.all(5),
                  child: txt(date, txtColor.value.withOpacity(0.7), 16, false),
                )
              : Space(0, 0))
        ],
      ),
    ],
  );
}
