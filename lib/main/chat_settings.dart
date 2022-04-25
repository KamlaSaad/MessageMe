import 'package:chatting/main/zoom_media.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../common/shared.dart';
import 'profile_img.dart';

class ChatSettings extends StatefulWidget {
  @override
  _ChatSettingsState createState() => _ChatSettingsState();
}

class _ChatSettingsState extends State<ChatSettings> {
  var chatData = chatController.chatData.value;
  String chatName = "";
  Color favColor = mainColor.value;
  bool isGroup = false;

  @override
  Widget build(BuildContext context) {
    isGroup = chatData['type'] != "chat";
    favColor = Color(chatData["mainColor"]);
    print(chatData["id"]);
    return Scaffold(
      backgroundColor: bodyColor.value,
      appBar: AppBar(
          elevation: 0,
          backgroundColor: bodyColor.value,
          leading: myIcon(Icons.arrow_back, favColor, 30, () => Get.back())),
      body: Obx(() => ListView(
            padding: EdgeInsets.symmetric(horizontal: 14),
            children: [
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: Get.height * 0.23,
                      width: Get.width * 0.65,
                      child: Stack(
                        children: [
                          !isGroup
                              ? Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: ProfileImg(
                                      Get.width * 0.17,
                                      mainController.userImg.value,
                                      "user",
                                      favColor))
                              : Space(0, 0),
                          Positioned(
                              left:
                                  isGroup ? Get.width * 0.11 : Get.width * 0.05,
                              bottom: -5,
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                      radius: Get.width * 0.2,
                                      backgroundColor: bodyColor.value,
                                      child: ProfileImg(
                                          80,
                                          chatController.chatImg.value,
                                          "group",
                                          favColor)),
                                  isGroup
                                      ? Positioned(
                                          right: 0,
                                          bottom: 5,
                                          child: circleIcon(
                                              favColor,
                                              Colors.white,
                                              Icons.camera_alt,
                                              25,
                                              "",
                                              false,
                                              () async => chatController
                                                  .changeChatImg()))
                                      : Space(0, 0),
                                ],
                              )),
                        ],
                      ),
                    ),
                    Space(0, 12),
                    TxtBtn(chatController.chatName.value, txtColor.value, 1,
                        () {
                      String val = "";
                      print(isGroup);
                      if (isGroup) {
                        EditBox("Edit group name",
                            chatController.chatName.value, (v) => val = v, () {
                          if (chatController.chatName.value != val) {
                            loadBox();
                            chatController.changeChatName(val);
                          }
                          Get.back();
                        });
                      }
                    }),
                    Space(0, 6),
                    FutureBuilder(
                        key: mainController.homeKey.value,
                        future: chatController
                            .getMsgsLength(chatController.chatId.value),
                        builder: (context, AsyncSnapshot snap) {
                          print(snap.data);
                          var text;
                          if (snap.hasData) {
                            int l = snap.data;
                            text = l > 0
                                ? txt(l == 1 ? "1 Message" : "$l Messages",
                                    favColor, 20, false)
                                : Space(0, 6);
                          } else
                            text = Space(0, 0);
                          return text;
                        }),
                    Space(0, 15),
                    isGroup
                        ? SizedBox(
                            width: Get.width * 0.5,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                circleIcon(boxColor.value, txtColor.value,
                                    Icons.person_add_alt_1, 24, "", false, () {
                                  mainController.resetSelectedUsers();
                                  Get.toNamed("/addMember",
                                      arguments: [chatData['users'], favColor]);
                                }),
                                circleIcon(boxColor.value, txtColor.value,
                                    Icons.call, 24, "", false, () {}),
                                circleIcon(boxColor.value, txtColor.value,
                                    Icons.video_call, 24, "", false, () {}),
                              ],
                            ),
                          )
                        : Space(0, 0),
                  ],
                ),
              ),
              //Chat Settings
              Space(0, 20),
              txt("settings".tr, favColor, 18, false),
              Space(0, 15),
              ListItem(Icons.photo, "change".tr + " " + "backImg".tr,
                  () async => chatController.changeBackground()),
              ListItem(
                  Icons.color_lens_sharp,
                  "change".tr + " " + "mainColor.value".tr,
                  () => showColorPicker()),
              ListItem(Icons.delete, "delete".tr + " " + "chat".tr,
                  () async => await deleteChat()),
              isGroup
                  ? ListItem(Icons.exit_to_app, "Leave Chat", () async {
                      confirmBox("Leave Chat",
                          "Are you sure to leave this chat", "Leave", () async {
                        Get.back();
                        loadBox();
                        await chatController.deleteMember(myId);
                        Get.back();
                        Get.back();
                        await chatController.addMsg("left group", "", "hint",
                            chatData['id'], chatController.chatMembers, "");
                      }, () => Get.back());
                    })
                  : Space(0, 0),

              //Chat media
              Space(0, 12),
              MediaBuilder("img"),
              Space(0, 12),
              MediaBuilder("video"),
              Space(0, 12),
              isGroup ? txt("Members", favColor, 20, false) : Space(0, 0),
              Space(0, 12),
              isGroup ? Members() : Space(0, 0),
              Space(0, 12),
//          VideosBuilder(),

              //members
            ],
          )),
    );
  }

  Widget Members() {
    List users = chatController.chatMembers;
    List<Widget> list = [];
    for (int i = 0; i < users.length; i++) {
      var userData = mainController.getUser(users[i]);
      String img = mainController.getFriendImg(userData['imgUrl']),
          contactN = mainController.isContact(userData['phone']),
          name = contactN.isEmpty ? "${userData['username']}" : contactN;
      userData['img'] = img;
      userData['name'] = name;
      bool isAdmin = users[i] == chatData['creator'],
          meAdmin = myId == chatController.chatData['creator'],
          isMe = users[i] == myId;
      String subT = contactN.isEmpty
          ? (isMe ? userData['phone'] : userData['email'])
          : userData['phone'];
      list.add(ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 3),
        horizontalTitleGap: 2,
        leading: ProfileImg(26, img, "user", favColor),
        title: txt(name, txtColor.value, 20, false),
        subtitle: Container(
          padding: EdgeInsets.only(top: 3),
          width: Get.width * 0.68,
          child: largeTxt("$subT", Colors.grey, 19),
        ),
        trailing: isAdmin
            ? txt("Admin", favColor, 19, false)
            : (meAdmin
                ? myIcon(Icons.delete, txtColor.value, 26, () {
                    confirmBox(
                        "Delete $name",
                        "Are you sure to delete this person",
                        "delete".tr, () async {
                      Get.back();
                      loadBox();
                      await chatController.deleteMember(userData['id']);
                      Get.back();
                    }, () => Get.back());
                  })
                : Space(0, 0)),
        onTap: () {
          isMe
              ? mainController.goToProfile()
              : Get.toNamed("/userProfile", arguments: userData);
        },
      ));
    }
    return Column(children: list);
  }

  Widget MediaBuilder(String type) {
    var media = [].obs;
    String text = type == "img" ? "photos".tr : "videos".tr;
    VideoPlayerController vpc;
    return Obx(() => FutureBuilder(
        future: chatController.getChatMedia(type),
        builder: (context, AsyncSnapshot snap) {
          var data = snap.data;
          if (snap.hasData) {
            media.value = data;
          }
          return media.length > 0
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    txt(text, favColor, 20, false),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: SizedBox(
                        height: 90,
                        child: ListView.builder(
                            itemCount: media.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (BuildContext ctx, int i) {
//                          String type = media[i]['type'];
                              vpc = VideoPlayerController.network(
                                  media[i]['url'] ?? "");
                              return Container(
                                color: boxColor.value,
                                padding: EdgeInsets.all(3),
                                width: 90,
                                height: 90,
                                child: GestureDetector(
                                  child: type == "img"
                                      ? Image.network(
                                          media[i]['url'] ?? "",
                                          fit: BoxFit.fill,
                                        )
                                      : VideoPlayer(vpc),
                                  onTap: () =>
                                      Get.to(ZoomMedia(type, media[i]['url'])),
                                ),
                              );
                            }),
                      ),
                    ),
                  ],
                )
              : Space(0, 0);
        }));
  }

  Widget ListItem(IconData icon, String title, tap) {
    return GestureDetector(
      child: Row(
        children: [
          myIcon(icon, favColor, 30, () => null),
          txt(title, txtColor.value, 21, false),
        ],
      ),
      onTap: tap,
    );
  }

  showColorPicker() {
    Color pColor = favColor;
    Get.defaultDialog(
      backgroundColor: boxColor.value,
      title: "mainColor".tr,
      titleStyle: TextStyle(color: mainColor.value),
      content: Center(
        child: ColorPicker(
            pickerColor: pColor, onColorChanged: (color) => pColor = color),
      ),
      confirm: TxtBtn("confirm".tr, favColor, 5, () async {
        setState(() {
          favColor = pColor;
          chatController.chatData["mainColor"] = favColor.value;
        });
        chatController.chatColor.value = favColor;
        Get.back();
        await chatController.changeChatData("mainColor", favColor.value);
      }),
      cancel: TxtBtn("cancel".tr, txtColor.value, 5, () => Get.back()),
    );
  }

  deleteChat() async {
    if (chatData['id'].toString().isNotEmpty) {
      confirmBox("delete".tr + "" + "chat".tr, "confirmDel".tr, "delete".tr,
          () async {
        await chatController.deleteChatFor(chatData['id']);
      }, () => Get.back());
    }
  }
}
