import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:passcode_screen/passcode_screen.dart';
import 'package:pattern_lock/pattern_lock.dart';
//import 'package:audioplayer/audioplayer.dart';
import '../Main/record_msg.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:random_string/random_string.dart';
import 'package:video_player/video_player.dart';
//import 'package:audioplayers/audioplayers.dart';
//import 'package:get_storage/get_storage.dart';
import 'package:passcode_screen/circle.dart';
import 'package:passcode_screen/keyboard.dart';
//import 'package:google_fonts/google_fonts.dart';
import 'main_controller.dart';
import '../main/chat_controller.dart';
import '../main/zoom_media.dart';

var mainController = Get.put(MainController()),
    chatController = Get.put(ChatController());

//String myId = "${mainController.user?.uid}";
String myId = "EdUxxQttAVPf5FQZ9XvJauPA2Dk1";
//colors

var mainColor = Color(0xffd5005b).obs,
    txtColor = Colors.white.obs,
    bodyColor = Colors.black.obs,
    boxColor = Color(0xff232323).obs;
//var tbodyColor.value = Colors.black.obs;
//var storage = GetStorage();
Widget Direction(Widget child) {
  return Directionality(
    child: child,
    textDirection: mainController.lang.value == "en"
        ? TextDirection.ltr
        : TextDirection.rtl,
  );
}

Widget Bar() {
  return Container(
      width: Get.width,
      height: Get.height * 0.24,
      color: bodyColor.value,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Row(
            children: [
              txt("logo".tr, mainColor.value, 25, true),
              Space(Get.width * 0.34, 0),
              myIcon(Icons.search, Colors.white70, 28,
                  () => Get.toNamed("/newChat", arguments: "searchBy".tr)),
              myIcon(Icons.more_vert, txtColor.value, 28,
                  () => Get.toNamed("/settings")),
//            Space(5, 0)
            ],
          ),
          GestureDetector(
              child: Row(children: [
                ProfileImg(25, "${mainController.userImg.value}", "user",
                    mainColor.value),
                Space(5, 0),
                txt(mainController.userData['username'], txtColor.value, 23,
                    true)
              ]),
              onTap: () => mainController.goToProfile()),
          Space(0, Get.height * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              appBtn("chats", mainColor.value.withOpacity(0.4)),
              appBtn("people", boxColor.value),
              appBtn("stories", boxColor.value),
            ],
          ),
        ]),
      ));
}

AppBar appBar() {
  return AppBar(
    backgroundColor: bodyColor.value,
    leading: GestureDetector(
      child: ProfileImg(
          25, "${mainController.userImg.value}", "user", mainColor.value),
      onTap: () => mainController.goToProfile(),
    ),
    title: txt("logo".tr, mainColor.value, 27, true),
    actions: [
      myIcon(Icons.search, Colors.white70, 27,
          () => Get.toNamed("/newChat", arguments: "searchBy".tr)),
      myIcon(
          Icons.more_vert, txtColor.value, 28, () => Get.toNamed("/settings")),
      Space(5, 0)
    ],
  );
}

Widget appBtn(String text, Color color) {
  return GestureDetector(
    onTap: () => Get.toNamed("/contacts"),
    child: Container(
      height: Get.height * 0.05,
      width: Get.width * 0.29,

      decoration: radiusBox(color),
//        BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Center(child: txt("$text".tr, txtColor.value, 23, false)),
    ),
  );
}

Widget backCircle(double h) {
  return Transform.scale(
    scale: 1.5,
    child: Container(
      width: Get.width,
      height: h,
      decoration: BoxDecoration(
          color: mainColor.value,
          borderRadius: BorderRadius.circular(Get.height * 0.35)),
    ),
  );
}

Widget txt(String txt, Color color, double size, bool bold) {
  return Text(
    txt,
    style: TextStyle(
        color: color,
        fontSize: size,
        fontWeight: bold ? FontWeight.w600 : FontWeight.normal),
  );
}

Widget largeTxt(String txt, Color color, double size) {
  return RichText(
      text:
          TextSpan(text: txt, style: TextStyle(color: color, fontSize: size)));
}

Widget loadingMsg(String text) {
  return Center(child: txt(text, txtColor.value, 22, true));
}

Widget ProfileImg(double r, String src, String type, Color color) {
  var img = src.isNotEmpty ? NetworkImage(src) : AssetImage("imgs/$type.jpg");
  return Padding(
    padding: const EdgeInsets.all(4),
    child: CircleAvatar(
        radius: r,
        backgroundColor: color,
        backgroundImage: img as ImageProvider),
  );
}

Widget FileImg(double r, File file, String type, Color color) {
  var img = file != null ? FileImage(file) : AssetImage("imgs/$type.jpg");
  return Padding(
    padding: const EdgeInsets.all(4),
    child: CircleAvatar(
        radius: r,
        backgroundColor: color,
        backgroundImage: img as ImageProvider),
  );
}

Widget Online(bool con, double right, double radius) {
  bool ar = mainController.lang.value == "ar";
  var circle = CircleAvatar(
    radius: radius * 1.3,
    backgroundColor: bodyColor.value,
    child: CircleAvatar(
      radius: radius,
      backgroundColor: Colors.green,
    ),
  );
  return con
      ? (ar
          ? Positioned(bottom: 0, left: right, child: circle)
          : Positioned(bottom: 0, right: right, child: circle))
      : Space(0, 0);
}

Widget myIcon(IconData icon, Color color, double s, click) {
  return IconButton(
      icon: Icon(
        icon,
        size: s,
        color: color,
      ),
      onPressed: click);
}

Widget circleIcon(Color backC, Color iconC, IconData icon, double r, String t,
    bool whiteTxt, click) {
  return GestureDetector(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: r,
          backgroundColor: backC,
          child: Icon(
            icon,
            color: iconC,
            size: 26,
          ),
        ),
        t.isNotEmpty
            ? txt(t, whiteTxt ? Colors.white : txtColor.value, 21, false)
            : Space(0, 0)
      ],
    ),
    onTap: click,
  );
}

DialogMsg(String title, String body) {
  Get.defaultDialog(
    title: title,
    barrierDismissible: true,
    titleStyle: TextStyle(color: mainColor.value),
    content: txt(body, txtColor.value, 19, false),
    backgroundColor: boxColor.value,
  );
}

snackMsg(String title) {
//  bool b = body.isNotEmpty;
  Get.snackbar(
    "",
    "",
    duration: Duration(seconds: 2),
//    titleText: txt(title, b ? mainColor.value : txtColor.value, 20, false),
    titleText: txt(title, Colors.white, 20, false),
//    messageText: b ? txt(body, txtColor.value, 18, false) : Space(0, 0),
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: mainColor.value.withOpacity(0.9),
  );
}

Widget TxtInput(String lbl, String hint, String val, bool focus,
    TextInputType type, Color borderColor, Color fillColor, change) {
  var border = (Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(color: color, width: 1.5));
  return TextFormField(
//    controller: null,
    initialValue: val,
    autofocus: focus,
    keyboardType: type,
    style: TextStyle(color: txtColor.value, fontSize: 20),
    decoration: InputDecoration(
        fillColor: fillColor,
        filled: true,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        hintText: val,
        hintStyle: TextStyle(color: txtColor.value, fontSize: 20),
        label: txt(lbl, txtColor.value, 19, true),
        enabledBorder: border(borderColor),
        focusedBorder: border(borderColor),
        errorBorder: border(Colors.red)),
    onChanged: change,
  );
}

Widget mainBtn(
    Color color, double r, bool border, bool insideSnack, String text, click) {
  return GestureDetector(
      child: Container(
        width: insideSnack ? Get.width * 0.35 : Get.width * 0.9,
        height: insideSnack ? Get.height * 0.05 : Get.height * 0.075,
        decoration: BoxDecoration(
            border: Border.all(color: mainColor.value, width: border ? 2 : 0),
            color: color,
            borderRadius: BorderRadius.circular(r)),
        child: Center(
          child: txt(
              text,
              border
                  ? mainColor.value
                  : (color == mainColor.value ? Colors.white : txtColor.value),
              21,
              false),
        ),
      ),
      onTap: click);
}

Widget BottomIcon(String lbl, IconData icon, Color color, var page) {
  return GestureDetector(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: color,
          size: page == null ? 34 : 30,
        ),
        txt(lbl, color, page == null ? 21 : 19, true),
      ],
    ),
    onTap: () {
      color = color == txtColor.value ? mainColor.value : txtColor.value;
      page == null ? null : Get.offNamed(page);
    },
  );
}

Widget lockBtn(String type, double w) {
  String lang = mainController.lang.value;
  MainAxisAlignment align;
  if (lang == "ar") {
    align = type == "pattern" ? MainAxisAlignment.start : MainAxisAlignment.end;
  } else {
    align = type == "pattern" ? MainAxisAlignment.end : MainAxisAlignment.start;
  }
  print(lang);
  return SizedBox(
    width: Get.width * w,
    child: Row(
      mainAxisAlignment: align,
      children: [
        TxtBtn("forget".tr + " " + "$type".tr, mainColor.value, 10, () async {
          mainController.changePatternVals("", "", [], false);
          await mainController.auth.signOut();
          Get.offAllNamed("/verify");
        }),
      ],
    ),
  );
}

Widget TxtBtn(String text, Color color, double padding, action) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding * 0.5),
    child: GestureDetector(child: largeTxt(text, color, 21), onTap: action),
  );
}

Widget ImageBox(Widget img, click) {
  return SizedBox(
    width: Get.width * 0.52,
    height: Get.height * 0.22,
    child: Stack(
      children: [
        img,
        Positioned(
            bottom: 10,
            right: 27,
            child: CircleAvatar(
              radius: 25,
              backgroundColor: mainColor.value,
              child: myIcon(Icons.camera_alt, txtColor.value, 30, click),
            ))
      ],
    ),
  );
}

reactIcon(Color color, bool isSender, var data) {
  String emogy = data[data.length - 1]['react'];
  print("react $emogy");
  return GestureDetector(
      child: CircleAvatar(
          radius: 15,
          backgroundColor: color,
          child: Center(child: txt(emogy, txtColor.value, 20, false))),
      onTap: () {
        if (isSender) {
          chatController.msgReacts.value = data;
          chatController.showReactBox.value = true;
        }
      });
//        myIcon(Icons.face, color == mainColor.value ? txtColor.value : mainColor.value, 24,
}

Widget replyBox(Map reply, bool isSender, bool close) {
  var user = mainController.getUser(reply['sender'] ?? "");
  VideoPlayerController? vc = reply['type'] == "video"
      ? VideoPlayerController.network(reply['url'])
      : null;
  var msg = (IconData icon, String text) => Row(
            children: [
              myIcon(icon, Colors.grey, 26, () => null),
              txt(text, txtColor.value, 20, false),
            ],
          ),
      leftMsg,
      rightMsg;
//  if()
  switch (reply['type']) {
    case 'img':
      leftMsg = msg(Icons.photo, "photo".tr);
      rightMsg = GestureDetector(
        child: Image.network(
          reply['url'],
          width: 60,
          height: 60,
        ),
      );
      break;
    case 'video':
      leftMsg = msg(Icons.videocam, "video".tr);
      rightMsg = VideoPlayer(vc!);
      break;
    case 'voice':
      leftMsg = msg(Icons.keyboard_voice, "voice".tr);
      break;
    case 'file':
      leftMsg = msg(Icons.insert_drive_file, "file".tr);
      break;
    default:
      leftMsg = largeTxt(
          reply['text'], txtColor.value.withOpacity(0.65), close ? 19 : 17);
  }
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              reply['sender'] == myId
                  ? txt("me".tr, txtColor.value, 21, false)
                  : txt(
                      user['name'] ?? "",
                      isSender
                          ? mainColor.value
                          : txtColor.value.withOpacity(0.85),
                      20,
                      false),
            ],
          ),
          Space(0, 3),
          leftMsg
        ],
      ),
      rightMsg ?? Space(0, 0)
    ],
  );
}

Widget reactMsgIcon(String icon, String msgId, var reacts) {
  var size = 32.0.obs;
  return GestureDetector(
      child: Obx(() => txt(icon, txtColor.value, size.value, true)),
      onTap: () async {
        print(icon);
        Get.back();
        await chatController.reactMsg(msgId, icon);
      });
}

Widget MsgOptionItem(IconData icon, String title, Map msg, Color favColor) {
  String id = msg['id'], text = msg['text'], newTxt = "";
  return ListTile(
    contentPadding: EdgeInsets.all(0),
    leading: myIcon(icon, favColor, 32, () {}),
    title: txt(title, txtColor.value, 22, false),
    onTap: () async {
      if (title == "Reply") {
        chatController.toggleReply(true, msg, msg['isSender']);
      } else if (title == "Forward") {
        Get.back();
        Timer(Duration(milliseconds: 500), () {
          Get.toNamed("/newGroup", arguments: ["Send to", msg]);
        });
//
      } else if (title == "Edit") {
        Timer(Duration(milliseconds: 500), () {
          if (text.isNotEmpty) {
            EditBox("Message", text, (val) => newTxt = val, () async {
              Get.back();
              print(newTxt);
              if (newTxt != text) {
                print(id);
                await chatController.editMsg(id, newTxt);
              }
            });
          } else {
//            DialogMsg("rrr", "Only text can be edited");
          }
        });
      } else {
//        Get.back();
//        deleteOptions(id);
        Timer(Duration(milliseconds: 500), () => deleteOptions(id));
      }
      Get.back();
//      chatController.changeChatKey();
      mainController.changeHomeKey();
    },
  );
}

deleteOptions(String id) {
//  Get.back();
  Get.defaultDialog(
      backgroundColor: boxColor.value,
      title: "Delete For",
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TxtBtn("Me", txtColor.value, 2, () async {
            Get.back();
            await mainController.editField("deletedMsgs", id, true);
            print(chatController.chatData['deletedMsgs']);
//            chatController.msgKey.value = Key(randomString(5));
          }),
          TxtBtn("Every One", txtColor.value, 2, () {
            Get.back();
            chatController.removerMsg(id);
          }),
        ],
      ));
}

void showMsgOptions(Map msgData, Color favColor) {
  String id = msgData['id'], msgTxt = msgData['text'];
  bool isSender = msgData['isSender'];
  var react = msgData['react'];
  Get.defaultDialog(
      backgroundColor: boxColor.value,
      title: "Make Action",
      titleStyle: TextStyle(color: boxColor.value, height: 0),
      content: Column(
        children: [
          MsgOptionItem(Icons.reply, "reply".tr, msgData, favColor),
          MsgOptionItem(Icons.forward, "forward".tr, msgData, favColor),
          isSender && msgTxt != " "
              ? MsgOptionItem(Icons.edit, "edit".tr, msgData, favColor)
              : Space(0, 0),
          MsgOptionItem(Icons.delete, "delete".tr, msgData, favColor),
          Space(0, 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              reactMsgIcon("❤", id, react),
              reactMsgIcon("😂", id, react),
              reactMsgIcon("😮", id, react),
              reactMsgIcon("😢", id, react),
              reactMsgIcon("☹", id, react),
            ],
          )
        ],
      ));
}

Widget Item(String text, IconData icon, Color color, action) {
  return ListTile(
    leading: myIcon(icon, color, 28, () {}),
    title: txt(text, txtColor.value, 19, false),
    onTap: action,
  );
}

void groupMemberOptions(Map userData, Color color) {
  bool isMe = userData['id'] == myId,
      isAdmin = myId == chatController.chatData['creator'];
  Get.defaultDialog(
      backgroundColor: boxColor.value,
      title: "",
      titleStyle: TextStyle(color: boxColor.value, height: 0),
      content: Column(
        children: [
          Item(
            "View Profile",
            Icons.person,
            color,
            () {
              isMe
                  ? Get.toNamed("/myProfile")
                  : Get.toNamed("/userProfile", arguments: userData);
              Get.back();
            },
          ),
          !isMe
              ? Item("Send Message", Icons.messenger, color, () {
//                  mainController.goToChat(userData);
//                  Get.back();
                })
              : Space(0, 0),
          (isMe || isAdmin)
              ? Item(
                  isMe ? "Leave group" : "Delete from group",
                  Icons.delete,
                  color,
                  () async {
                    Get.back();
                    await chatController.deleteMember(userData['id']);
                  },
                )
              : Space(0, 0),
        ],
      ));
}

String duration(int sec) {
  Duration d = Duration(seconds: sec);
  String dur = d.toString().substring(2, 7);
  return dur;
}

Widget FileMsg(String name) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      myIcon(Icons.insert_drive_file, txtColor.value, 30, null),
      txt(name, txtColor.value, 22, false)
    ],
  );
}

Widget MediaMsg(bool img, String url, String caption, bool isSender) {
  VideoPlayerController _controller = VideoPlayerController.network(url)
    ..initialize();
  bool playing = _controller.value.isPlaying;
  return GestureDetector(
    onDoubleTap: () => Get.to(ZoomMedia(img ? "img" : "video", url)),
    child: Column(
      children: [
        SizedBox(
          width: Get.width * 0.45,
          height: Get.height * 0.25,
          child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: url.isEmpty
                  ? null
                  : (img
                      ? Image.network(
                          url,
                          fit: BoxFit.fill,
                        )
                      : VideoPlayer(_controller))),
        ),
        caption == " "
            ? Space(0, 0)
            : Padding(
                padding: const EdgeInsets.only(top: 5),
                child: txt(caption, txtColor.value, 18, false),
              )

//          caption.isNotEmpty ? CaptionBox(caption, isSender) : Space(0, 0)
      ],
    ),
  );
}

Widget CaptionBox(String caption, bool isSender) {
  const r = Radius.circular(12);
  return Transform.translate(
    offset: Offset(0, -6),
    child: Container(
      width: Get.width * 0.45,
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 7),
      decoration: BoxDecoration(
          color: isSender ? boxColor.value.withOpacity(0.7) : mainColor.value,
          borderRadius: BorderRadius.only(bottomLeft: r, bottomRight: r)),
      child: txt(caption, txtColor.value, 20, false),
    ),
  );
}

var Space = (double w, double h) => SizedBox(width: w, height: h);
var Divide = () => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 1,
      color: txtColor.value.withOpacity(0.3),
    );
Widget Btn(Color color, double w, double h, Widget child, bool border, f) {
  return GestureDetector(
      child: Container(
          width: w,
          height: h,
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: color,
              border:
                  Border.all(color: mainColor.value, width: border ? 2 : 0)),
          child: Center(child: child)),
      onTap: f);
}

Widget SliderIcon(IconData icon, double dimension, func) {
  return GestureDetector(
    child: Container(
        width: dimension,
        height: dimension,
        color: bodyColor.value.withOpacity(0.6),
        child: Icon(icon, color: txtColor.value, size: 30)),
    onTap: func,
  );
}

void EditBox(String title, String val, change, action) {
//  String result="";
  Get.defaultDialog(
    radius: 0,
//    contentPadding: EdgeInsets.only(bottom: 0),
    title: "edit".tr + " $title",
    titleStyle: TextStyle(color: mainColor.value, height: 2, fontSize: 22),
    barrierDismissible: true,
    content: Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TxtInput("", "", val, false, TextInputType.text, txtColor.value,
              Colors.transparent, change),

//          Row(
//            mainAxisAlignment: MainAxisAlignment.center,
//            children: [
//              Btn(
//                  Colors.transparent,
//                  Get.width * 0.34,
//                  38,
//                  txt("cancel".tr, mainColor.value, 20, false),
//                  true,
//                  () => Get.back()),
//              Btn(mainColor.value, Get.width * 0.34, 38,
//                  txt("confirm".tr, Colors.white, 20, false), false, action)
//            ],
//          )
        ],
      ),
    ),
    confirm: mainBtn(mainColor.value, 0, false, true, "confirm".tr, action),
    cancel: mainBtn(
        Colors.transparent, 0, true, true, "cancel".tr, () => Get.back()),
    backgroundColor: boxColor.value,
  );
}

void loadBox() {
  Get.defaultDialog(
      barrierDismissible: false,
      backgroundColor: boxColor.value,
      title: "wait".tr,
      titleStyle: TextStyle(color: txtColor.value, fontSize: 22),
      content: CircularProgressIndicator(
        color: mainColor.value,
      ));
}

Widget reactsBox(Color color) {
  var data = chatController.msgReacts.value;
  String text =
      data.length == 1 ? "1 " + "react".tr : "${data.length} " + "reacts".tr;
  return AnimatedPositioned(
      duration: const Duration(milliseconds: 500),
      bottom: chatController.showReactBox.isTrue ? 0 : -(Get.height * 0.7),
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.all(0),
        decoration: radiusBox(bodyColor.value),
        child: Column(
          children: [
            Container(
                padding: const EdgeInsets.all(8),
                width: Get.width,
                decoration: radiusBox(color),
                child: ListTile(
                  leading: txt(text, Colors.white, 22, true),
                  trailing: myIcon(
                    Icons.close,
                    Colors.grey,
                    26,
                    () => chatController.showReactBox.value = false,
                  ),
                )),
            data.length > 0
                ? Container(
                    constraints: BoxConstraints(
                        minHeight: 10, maxHeight: Get.height * 0.3),
                    child: ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, int i) {
                          var user = mainController.getUser(data[i]['person']);
                          String img =
                              mainController.getFriendImg(user['imgUrl']);
                          var date =
                              mainController.msgDate(data[i]['time'], false);
                          return ListTile(
                            leading:
                                ProfileImg(25, img, "user", mainColor.value),
                            title: txt(user['name'], txtColor.value, 22, false),
                            subtitle: txt(date, Colors.grey, 19, false),
                            trailing:
                                txt(data[i]['react'], Colors.grey, 26, false),
                          );
                        }))
                : Space(0, 0)
          ],
        ),
      ));
}

radiusBox(Color color) {
  return BoxDecoration(
    color: color,
    borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(15), topRight: Radius.circular(13)),
  );
}

void confirmBox(
    String title, var body, String confirmTxt, confirmAction, cancelAction) {
  var type = body.runtimeType;
//  print("type $type");
  Get.defaultDialog(
    radius: 0,
    backgroundColor: boxColor.value,
    title: title,
    titleStyle: TextStyle(color: mainColor.value, fontSize: 19, height: 1.3),
    content: type == String
        ? txt(body, txtColor.value.withOpacity(0.8), 21, false)
        : body,
    confirm:
        mainBtn(mainColor.value, 0, false, true, "confirm".tr, confirmAction),
    cancel:
        mainBtn(Colors.transparent, 0, true, true, "cancel".tr, cancelAction),
  );
}

Widget UsersListItem(String img, String imgType, String title, String subT,
    bool con, var trail, tap) {
  return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 5),
      leading: Stack(
        children: [
          ProfileImg(36, "$img", imgType, mainColor.value),
          con ? Online(con, 8, 8) : Space(0, 0)
        ],
      ),
      title: txt(title, txtColor.value, 18, false),
      horizontalTitleGap: 0,
      minVerticalPadding: 2,
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: txt(subT, txtColor.value.withOpacity(0.6), 17, false),
      ),
      trailing: trail,
      onTap: tap);
}

Widget GroupedRadio(String groupVal, List options, bool disable, change) {
  List<Widget> radios = [];
  for (int i = 0; i < options.length; i++) {
    var row = Row(
      children: [
        Radio(
            activeColor: mainColor.value,
            value: options[i].toLowerCase(),
            groupValue: groupVal,
            onChanged: disable ? null : change),
        Space(6, 0),
        txt("${options[i]}".tr, txtColor.value, 18, false),
      ],
    );
    radios.add(row);
  }
  return Column(
    children: radios,
  );
}

Widget FileIcon(String text, String type, String sender) {
  IconData icon = Icons.photo;
  String fileName = "";
  switch (type) {
    case "img":
      icon = Icons.photo;
      fileName = text.isNotEmpty ? text : "photo".tr;
      break;
    case "file":
      icon = Icons.insert_drive_file;
      fileName = text.isNotEmpty ? text : "file".tr;
      break;
    case "audio":
      icon = Icons.settings_voice_sharp;
      fileName = duration(int.parse(text));
      break;
    case "video":
      icon = Icons.videocam;
      fileName = text.isNotEmpty ? text : "video".tr;
      break;
    case "location":
      icon = Icons.location_on;
      fileName = "location".tr;
      break;
  }
  return Row(
    mainAxisSize: MainAxisSize.min,
    textDirection:
        mainController.lang == 'en' ? TextDirection.ltr : TextDirection.rtl,
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      txt("$sender :", txtColor.value.withOpacity(0.7), 18, false),
      SizedBox(height: 30, child: myIcon(icon, mainColor.value, 20, () {})),
      txt(fileName, txtColor.value.withOpacity(0.7), 18, false)
    ],
  );
}

Widget Pattern(click) {
  return Flexible(
      child: PatternLock(
          selectedColor: mainColor.value,
          notSelectedColor: txtColor.value,
          pointRadius: 9,
          dimension: 4,
          showInput: true,
          onInputComplete: click));
}

Widget Pass(String title, action, ver) {
  return Padding(
    padding: EdgeInsets.only(top: Get.height * 0.04),
    child: PasscodeScreen(
      backgroundColor: bodyColor.value,
      title: txt("$title".tr, txtColor.value, 25, true),
      passwordEnteredCallback: action,
      cancelButton: txt("cancel".tr, txtColor.value, 22, false),
      deleteButton: txt("delete".tr, txtColor.value, 22, false),
      shouldTriggerVerification: ver,
      circleUIConfig: CircleUIConfig(
          borderWidth: 2,
          borderColor: txtColor.value,
          fillColor: txtColor.value,
          circleSize: 17),
      keyboardUIConfig: KeyboardUIConfig(
        digitBorderWidth: 0,
        primaryColor: Colors.transparent,
        keyboardSize: Size(Get.width * 0.7, Get.height * 0.65),
        digitTextStyle: TextStyle(
            color: txtColor.value, fontSize: 30, fontWeight: FontWeight.w700),
        deleteButtonTextStyle: TextStyle(color: txtColor.value),
      ),
      cancelCallback: () => Get.back(),
      bottomWidget: Transform.translate(
        offset: Offset(0, -Get.height * 0.008),
        child: lockBtn("pass", 0.5),
      ),
    ),
  );
}

class FilterPeople {
  List users = [];
  Widget FilterBox(BuildContext context, List data, Color color) {
    return StatefulBuilder(builder: (context, StateSetter set) {
      return data.length > 0
          ? SizedBox(
              width: Get.width,
              height: Get.height * 0.8,
              child: ListView.builder(
                  padding: EdgeInsets.only(top: 10),
                  itemCount: data.length,
                  itemBuilder: (context, i) {
                    var user = data[i];
                    String name = user['name'].toString().isEmpty
                        ? user['username']
                        : user['name'];
                    String img = mainController.getFriendImg(user['imgUrl']);
                    return ListTile(
                      leading: ProfileImg(26, img, "user", mainColor.value),
                      title: txt(name, txtColor.value, 22, false),
//                            subtitle:txt(user['email'], Colors.grey, 19, false),
                      trailing: myIcon(
                          user['selected']
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color,
                          30, () {
                        set(() {
                          user['selected'] = !user['selected'];
                          user['selected']
                              ? users.add(user['id'])
                              : users.remove(user['id']);
//                          print(users);
                        });
                      }),
                      selected: user['selected'],
                    );
                  }))
          : loadingMsg("no".tr + " " + "users".tr);
    });
  }
}

void waiting(Color color) {
  Get.defaultDialog(
      barrierDismissible: false,
      backgroundColor: boxColor.value,
      title: "wait".tr,
      titleStyle: TextStyle(color: color),
      content: Container(
        child: Center(
            child: CircularProgressIndicator(
          color: txtColor.value.withOpacity(0.8),
        )),
      ));
}

void waitingTimer() {
  int i = 0;
  Timer.periodic(Duration(seconds: 1), (timer) {
    if (i < 60)
      i++;
    else
      Get.back();
  });
  print(i);
}

//app
//https://www.linkedin.com/posts/ahmed-abdelkader-022676204_flutter-ugcPost-6893572818207129600-jDOj
