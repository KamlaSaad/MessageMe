import 'dart:async';
import '../Main/media_viewer.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import 'file_viewer.dart';
import 'package:get/get.dart';
import 'chat_controller.dart';
import '../common/shared.dart';
import 'location.dart';
import 'msg.dart';

//ChatController controller = Get.put(ChatController());
ScrollController scrollController = ScrollController();

class Chat extends StatefulWidget {
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  var msgContoller = TextEditingController(),
      msg = "".obs,
      chatData = chatController.chatData.value,
      msgKey = Key("").obs;
  String chatName = "", receiverId = "", online = "";

  Color chatColor = chatController.chatColor.value;
  double dismiss = Get.width * 0;
  Map msgData = {}, user = {};
  bool isBlocked = false,
      showReplyBox = true,
      showReactBox = true,
      isGroup = false;
  var queryMessages;
  @override
  build(BuildContext context) {
    chatName = mainController.splitName(chatData['name'], 15);
    receiverId = !isGroup ? chatData['receivers'][0] : "";
    user = mainController.getUser(receiverId);
    isGroup = chatData['type'] == 'chat' ? false : true;
    bool blocked = mainController.isBlocked(user['id']),
        meBlocked = mainController.blocked(user['blocked']);
//    chatColor = Color(chatController.chatColor.value ?? mainColor.value.value);
    queryMessages = chatController.messagesRef
        .orderByChild("chatId")
        .equalTo(chatData['id']);
    return Obx(() => Scaffold(
        backgroundColor: bodyColor.value,
        appBar: AppBar(
//            elevation: 0,
            backgroundColor: bodyColor.value,
            leading: myIcon(Icons.arrow_back, chatController.chatColor.value,
                30, () => Get.back()),
            titleSpacing: 2,
            title: GestureDetector(
                child: Row(
                  children: [
                    ProfileImg(
                        21,
                        chatController.chatImg.value,
                        isGroup ? "group" : "user",
                        chatController.chatColor.value),
                    Space(10, 0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        txt(chatController.chatName.value,
                            chatController.chatColor.value, 22, true),
                        subTitle()
                      ],
                    )
                  ],
                ),
                onTap: () => Get.toNamed("/chatSettings")),
            actions: isGroup
                ? []
                : [
                    myIcon(Icons.phone, chatController.chatColor.value, 30,
                        () async {
//                      print(receiverId);
//                      await chatController.addMsg(
//                          "😂😂😂😂💔", "", "text", chatData['id'], [myId], "");
                      if (blocked || meBlocked) {
                        snackMsg("cantCall".tr);
                      } else {}
                    }),
                    myIcon(Icons.video_call, chatController.chatColor.value, 30,
                        () {
                      if (blocked || meBlocked) {
                        snackMsg("cantCall".tr);
                      } else {}
                    }),
                    Space(5, 0)
                  ]),
        body: Container(
          width: Get.width,
          height: Get.height,
          child: Stack(
            children: [
              Obx(() => chatController.chatBackground.isNotEmpty
                  ? SizedBox(
                      width: Get.width,
                      height: Get.height,
                      child: Obx(() => Image.network(
                          chatController.chatBackground.value,
                          fit: BoxFit.fill)))
                  : Space(0, 0)),
              ListView(
                shrinkWrap: true,
                children: [
                  Stack(
                    children: [
                      Container(
                          height: Get.height * 0.78,
                          width: Get.width,
                          padding: EdgeInsets.only(top: 10, left: 6, right: 6),
                          child: chatController.chatId.isNotEmpty
                              ? Obx(
                                  () => FirebaseAnimatedList(
                                      shrinkWrap: true,
                                      key: chatController.msgKey.value,
                                      query: chatController.queryMsg.value,
                                      controller: scrollController,
                                      itemBuilder: (context,
                                          DataSnapshot snapshot,
                                          Animation<double> animation,
                                          int i) {
                                        var snap = snapshot.value;
                                        print("snap $snap");
                                        msgData = {
                                          "id": "${snapshot.key}",
                                          "text": "${snap["text"]}",
                                          "url": "${snap["mediaUrl"]}",
                                          "type": "${snap["type"]}",
                                          "status": "${snap["status"]}",
                                          "date": snap["date"],
                                          "time": mainController.msgDate(
                                              "${snap["date"]}", true),
                                          "reply": snap['reply'] ?? {},
                                          "react": snap['react'] ?? [],
                                          "sender": snap["senderId"],
                                          "hintedUser": snap["hintedUser"],
                                          "isSender": myId == snap["senderId"]
                                        };

                                        Timer.periodic(
                                            Duration(seconds: 1),
                                            (Timer t) => msgData['time'] =
                                                mainController.msgDate(
                                                    "${snap["date"]}", false));
                                        var senderData = mainController
                                            .getUser(snap["senderId"]);
                                        String txtT = snap["type"] == 'hint'
                                            ? (msgData['isSender']
                                                ? "I"
                                                : senderData['username']
                                                    .toString())
                                            : "";
                                        msgData['text'] =
                                            "$txtT ${msgData['text']}";
                                        chatController.isSender.value =
                                            msgData["isSender"];
                                        bool deleted = mainController
                                            .msgDeleted(msgData['id']);
                                        return deleted
                                            ? Space(0, 0)
                                            : Message(msgData, chatData['type'],
                                                chatController.chatColor.value);
//
                                      }),
                                )
                              : Space(0, 0)),
                      Positioned(
                          bottom: chatController.showReplyBox.isTrue
                              ? Get.height * 0.1
                              : Get.height * 0.06,
                          right: 10,
                          child: Column(
                            children: [
                              scrollBtn(Icons.arrow_upward),
                              Space(0, 5),
                              scrollBtn(Icons.arrow_downward),
                            ],
                          ))
                    ],
                  ),
                  Container(
                    height: Get.height * 0.1,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        myIcon(Icons.add_box_sharp,
                            chatController.chatColor.value, 40, () async {
                          if (blocked || meBlocked) {
                            snackMsg("cantMsg".tr);
                          } else {
                            await uploadMsg();
                          }
                        }),
                        Container(
                            width: Get.width * 0.7,
                            height: 42,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: boxColor.value,
                            ),
                            child: TextFormField(
                              style: TextStyle(
                                  color: txtColor.value, fontSize: 22),
                              controller: msgContoller,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
                                hintText: "type".tr + " " + "msg".tr + "..",
                                hintStyle: TextStyle(
                                    color: txtColor.value, fontSize: 22),
//                                suffixIcon: Icon(
//                                  Icons.face,
//                                  color: txtColor.value ,
//                                ),
                                enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide.none),
                                focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide.none),
                              ),
                            )),
                        circleIcon(chatController.chatColor.value, Colors.white,
                            Icons.send, 25, "", false, () async {
                          msg.value = msgContoller.text;
                          if (blocked || meBlocked) {
                            snackMsg("cantMsg".tr);
                          } else {
                            if (msg.value.isNotEmpty) {
                              msgContoller.clear();
                              await chatController.createMsg(
                                  msg.value, "", "text", "");
                            }
                          }
                        }),
                      ],
                    ),
                  )
                ],
              ),
              Obx(() => chatController.showReplyBox.isTrue
                  ? Positioned(
                      left: 0,
                      bottom: Get.height * 0.1,
                      child: Container(
                        color: boxColor.value,
                        width: Get.width,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: Stack(
                          children: [
                            replyBox(chatController.replyMsg.value,
                                chatController.isSender.value, true),
                            Positioned(
                              top: 0,
                              right: 3,
                              child: myIcon(Icons.close, Colors.grey, 25, () {
                                chatController.toggleReply(false, {}, false);
                              }),
                            )
                          ],
                        ),
                      ))
                  : Space(0, 0)),
              Obx(() => reactsBox(chatController.chatColor.value))
            ],
          ),
        )));
  }

//  void updateQuery(String id) {
//    setState(() {
//      chatData['id'] = id;
//      queryMessages = chatController.messagesRef
//          .orderByChild("chatId")
//          .equalTo(chatData['id']);
//    });
//  }
//
//  void updateMsgKey() {
//    msgKey.value = Key(randomString(5));
//    mainController.newChat.value = !mainController.newChat.value;
//  }

  Widget subTitle() {
    bool show = user['connected'] == true || isGroup;
    String online = (user['connected'] ?? false) ? "online" : "";
    return show
        ? Obx(() => txt(
            !isGroup
                ? "$online".tr
                : "${chatController.chatMembers.length} members",
            txtColor.value.withOpacity(0.8),
            17,
            false))
        : Space(0, 0);
  }

  void addMsg() async {
    await chatController.addMsg(
        msg.value, "", "text", chatData['id'], chatData['receivers'], "");
  }

  Widget scrollBtn(IconData icon) {
    return CircleAvatar(
      backgroundColor: boxColor.value,
      radius: 20,
      child: myIcon(
          icon,
          txtColor.value,
          26,
          () => icon == Icons.arrow_downward
              ? chatController.scrollToBottom(scrollController)
              : chatController.scrollToTop(scrollController)),
    );
  }

  uploadMsg() async {
    Get.snackbar("", "",
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(minutes: 2),
        backgroundColor: chatController.chatColor.value.withOpacity(0.8),
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        messageText: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                circleIcon(Colors.pinkAccent, Colors.white, Icons.image, 30,
                    "photo".tr, true, () async {
                  List filesData = await mainController
                      .uploadFile(true, ['jpg', 'png', 'jpeg', 'jif']);
                  Get.back();
                  if (filesData.isNotEmpty) {
                    Get.to(MediaViewer("msg", "imgs", filesData));
                  }
                }),
                circleIcon(Colors.purple, Colors.white, Icons.videocam, 30,
                    "video".tr, true, () async {
                  List filesData =
                      await mainController.uploadFile(true, ['mp4']);
                  if (filesData.isNotEmpty) {
                    Get.to(MediaViewer("msg", "videos", filesData));
                  }
                }),
                circleIcon(Colors.deepOrangeAccent, Colors.white, Icons.headset,
                    30, "voice".tr, true, () async {
                  List filesData =
                      await mainController.uploadFile(true, ['mp3']);
                  if (filesData.isNotEmpty) {
                    Get.to(FileViewer("audios", filesData));
                  }
                })
              ],
            ),
            Space(0, 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                circleIcon(Colors.deepPurpleAccent, Colors.white,
                    Icons.settings_voice, 30, "record".tr, true, () {
                  Get.back();
                  Get.toNamed("/recorder");
                }),
                circleIcon(Colors.deepPurpleAccent, Colors.white,
                    Icons.settings_voice, 30, "file".tr, true, () async {
                  List filesData = await mainController
                      .uploadFile(true, ['pdf', 'docs', 'html']);
                  if (filesData.isNotEmpty) {
                    Get.to(FileViewer("files", filesData));
                  }
                }),
                circleIcon(Colors.green, Colors.white, Icons.location_on, 30,
                    "location".tr, true, () async {
                  Get.back();
                  loadBox();
                  LocationService ls = LocationService();
                  var data = await ls.getLocation();
                  await chatController.addMsg(
                      "${data.latitude}",
                      "${data.longitude}",
                      "location",
                      chatData['id'],
                      chatData['receivers'],
                      "");
                  Get.back();
                }),
              ],
            )
          ],
        ));
  }
}
