import 'dart:async';
import 'package:chatting/call/call_controller.dart';
import 'package:chatting/common/shared.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'profile_img.dart';

class UserProfile extends StatelessWidget {
  CallController callController = Get.put(CallController());
  String userName = "", img = "", contactN = "";
  var user = Get.arguments;
  @override
  Widget build(BuildContext context) {
    contactN = mainController.isContact(user['phone']);
    img = mainController.getFriendImg(user['imgUrl']);
    userName = contactN.isNotEmpty ? contactN : user['username'];
    return Scaffold(
        backgroundColor: bodyColor.value,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: bodyColor.value,
          leading:
              myIcon(Icons.arrow_back, mainColor.value, 30, () => Get.back()),
        ),
        body: ListView(
          padding: EdgeInsets.symmetric(horizontal: 12),
          children: [
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    child: Stack(
                      children: [
                        ProfileImg(76, img, "user", mainColor.value),
                        Online(user['connected'], 18, 11)
                      ],
                    ),
                    onTap: () async {
                      var imgs = user['imgUrl'];
                      if (imgs.length > 0) {
//                        print(imgs);
                        Get.to(ProfileImgViewer(false, userName, imgs, () {}));
                      }
                    },
                  ),
                  Space(0, 10),
                  txt(userName, mainColor.value, 28, true),
                  Space(0, 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      circleIcon(boxColor.value, txtColor.value,
                          Icons.messenger_outlined, 24, "", false, () async {
                        user['img'] = img;
                        user['name'] = userName;
                        mainController
                            .goToChat("", userName, img, 'chat', [user['id']]);
                      }),
                      Space(10, 0),
                      circleIcon(boxColor.value, txtColor.value, Icons.phone,
                          24, "", false, () async {
                        String token =
                            await FirebaseMessaging.instance.getToken() ?? "";
                        await chatController.notify(token, "Fatma Alaa",
                            "Audio Call", "gd34t783g3yufgjhw");
                      }),
                      Space(10, 0),
                      circleIcon(
                          boxColor.value,
                          txtColor.value,
                          Icons.video_call,
                          24,
                          "",
                          false,
                          () async => makeCall("Video")),
                      Space(10, 0),
                      circleIcon(boxColor.value, txtColor.value, Icons.block,
                          24, "", false, () => block()),
                    ],
                  )
                ],
              ),
            ),
            Space(0, 15),
            ListItem(Icons.person, "name".tr, user['username']),
            ListItem(Icons.email, "email".tr, user["email"]),
            mainController.isPrivate('phonePrivacy', user["phone"])
                ? Space(0, 0)
                : ListItem(Icons.phone, "phone".tr, user["phone"]),
            ListItem(Icons.access_time_sharp, "join".tr,
                user["joined"] ?? "12/12/2021"),
          ],
        ));
  }

  Widget ListItem(IconData icon, String title, String val) {
    return ListTile(
      leading: Icon(icon, size: 34, color: mainColor.value),
      title: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: txt(title, txtColor.value.withOpacity(0.6), 17, false),
      ),
      subtitle: txt(val, txtColor.value, 20, false),
    );
  }

  void block() {
    String name = user['name'];
    confirmBox("${'block'.tr} $name", 'blockDec'.tr, 'block'.tr, () async {
      await mainController.block(user['id']);
      mainController.blockedUsers.remove(user['id']);
      Get.back();
      Get.back();
      Timer(Duration(seconds: 1),
          () => snackMsg("done".tr + " " + "youBlocked".tr + " $name"));
    }, () => Get.back());
  }

  makeCall(String type) async {
    if (user['connected']) {
      if (type == "Video") {
        await mainController.handlePermission(Permission.camera);
        await mainController.handlePermission(Permission.microphone);
      } else {
        await mainController.handlePermission(Permission.microphone);
      }
      Map call = {
        "type": type,
        "receivers": [user['id']]
      };
      callController.callImg.value = img;
      callController.callName.value = userName;
//    await callController.initCall(type, [user['id']]);
      Get.toNamed("/${type.toLowerCase()}Call", arguments: [true, call]);
    } else {
      snackMsg("$userName is offline");
    }
  }
}
