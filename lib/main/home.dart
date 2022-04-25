import 'profile_img.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../common/shared.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  var selectedIndex = 0.obs, btnAngle = 1.0.obs;
  var displayIcons = false.obs;
  int endTime = 0;

  @override
  build(BuildContext context) {
    var state;
    return Obx(() => Scaffold(
          backgroundColor: bodyColor.value,
          key: scaffoldKey,
          appBar: appBar(),
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    Container(
                        color: bodyColor.value,
                        key: mainController.homeKey.value,
                        padding: EdgeInsets.symmetric(
                            horizontal: 10, vertical: Get.height * 0.02),
                        height: Get.height * 0.76,
                        child: mainController.connected.value
                            ? FutureBuilder(
                                future: mainController.getChats(),
                                builder: (context, AsyncSnapshot snap) {
                                  state = snap.connectionState;
                                  switch (snap.connectionState) {
                                    case ConnectionState.none:
                                      return Center(
                                          child: txt(
                                              "", bodyColor.value, 0, false));
                                    case ConnectionState.active:
                                    case ConnectionState.waiting:
                                      return Center(
                                          child: txt("load".tr, txtColor.value,
                                              22, true));
                                    case ConnectionState.done:
                                      if (snap.hasError) {
                                        print(
                                            "Errooooooooooooooooooooooooooooooooooooooor");
                                        print(snap.error);
                                      }
                                      return snap.hasData
                                          ? snap.data.length > 0
                                              ? Chats(snap.data)
                                              : loadingMsg(
                                                  "no".tr + " chats".tr)
                                          : loadingMsg("Something went wrong");
                                  }
                                })
                            : Chats(mainController.userChats)),
                  ],
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    width: Get.width,
                    height: Get.height * 0.12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        BottomIcon("chats".tr, Icons.messenger_outlined,
                            mainColor.value, null),
                        BottomIcon("people".tr, Icons.people_alt_sharp,
                            txtColor.value, "/contacts"),
                        BottomIcon("stories".tr, Icons.amp_stories,
                            txtColor.value, "/stories")
                      ],
                    ),
                  ),
                ),
                mainController.lang == 'en'
                    ? Positioned(
                        right: 12,
                        bottom: Get.height * 0.12,
                        child: SideIcons())
                    : Positioned(
                        left: 12, bottom: Get.height * 0.12, child: SideIcons())
              ],
            ),
          ),
        ));
  }

  SideIcons() {
    return Column(
      children: [
        displayIcons.isTrue
            ? Column(
                children: [
                  circleIcon(
                      mainColor.value,
                      Colors.white,
                      Icons.messenger_outlined,
                      28,
                      "",
                      false,
                      () => Get.toNamed("/newChat", arguments: "Chat with")),
                  Space(0, 7),
                  circleIcon(mainColor.value, Colors.white,
                      Icons.people_alt_sharp, 28, "", false, () {
                    //print("==========================");
                    // print(await chatController.getLastMsg(""));
                    mainController.resetSelectedUsers();
                    Get.toNamed("/newGroup", arguments: ["addGroup".tr, {}]);
                  }),
                ],
              )
            : Space(0, 0),
        Space(0, 7),
        circleIcon(
            mainColor.value,
            Colors.white,
            displayIcons.isTrue ? Icons.close : Icons.add,
            28,
            "",
            false,
            () => displayIcons.value = !displayIcons.value),
      ],
    );
  }
}

Widget Chats(List list) {
  List data = [];
  for (int i = 0; i < list.length; i++) {
    if (list[i]['lastMsgType'].isNotEmpty && list[i]['name'] != "null") {
      data.add(list[i]);
    }
  }
  return data.length > 0
      ? ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            data = mainController.sortByDate(data, true);
            var chat = data[index], msg, date = "${chat['lastMsgDate']}".obs;
            bool isGroup = chat['type'] == "group";
            String senderN = mainController.splitName(chat['lastMsgSender'], 8);
            if (chat['lastMsgType'].isNotEmpty) {
              msg = Padding(
                padding: const EdgeInsets.only(top: 3),
                child: chat['lastMsgType'] == "text" ||
                        chat['lastMsgType'] == "hint"
                    ? txt("$senderN: ${chat['lastMsg']}",
                        txtColor.value.withOpacity(0.6), 17, false)
                    : FileIcon(chat['lastMsg'], chat['lastMsgType'],
                        chat['lastMsgSender']),
              );
            }
//            print("chat $chat");
            Timer.periodic(
                Duration(minutes: 1),
                (Timer t) =>
                    date.value = mainController.msgDate(chat['date'], true));
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 3),
              horizontalTitleGap: 2,
              leading: GestureDetector(
                  child: ProfileImg(28, chat['img'], isGroup ? "group" : "user",
                      mainColor.value),
                  onTap: () {
                    if (chat['img'].isNotEmpty) {
                      Get.to(ProfileImgViewer(
                          false, chat['name'], chat['img'], () {}));
                    }
                  }),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  txt(chat['name'], txtColor.value, 18, false),
                  Obx(() => txt(
                      date.value, txtColor.value.withOpacity(0.5), 16, false)),
                ],
              ),
              subtitle: msg,
              onTap: () {
                mainController.goToChat(chat['id'], chat['name'], chat['img'],
                    chat['type'], chat['receivers']);
              },
            );
          },
        )
      : !mainController.connected.value
          ? loadingMsg("no".tr + " " + "internet".tr)
          : loadingMsg("no".tr + "chats".tr);
}
