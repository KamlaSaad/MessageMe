import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../common/shared.dart';
import 'dart:io';

var storage = GetStorage();

class SignUp extends StatelessWidget {
  SignUpController controller = SignUpController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bodyColor.value,
      appBar: null,
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Stack(
            children: [
              backCircle(Get.height * 0.6),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Space(0, Get.height * 0.1),
                  txt("logo".tr, txtColor.value, 36, true),
                  Space(0, Get.height * 0.04),
                  ImageBox(
                      Obx(() => ProfileImg(100, controller.imgUrl.value, "user",
                          mainColor.value)), () {
                    Map fileData = mainController
                        .uploadFile(false, ['jpg', 'png', 'jpeg']);
                    Get.back();
                  }),
                  Space(0, Get.height * 0.04),
                  TxtInput(
                      "name".tr,
                      "",
                      "",
                      false,
                      TextInputType.text,
                      bodyColor.value,
                      Colors.transparent,
                      (val) => controller.userName.value = val),
                  TxtInput(
                      "email".tr,
                      "",
                      "",
                      false,
                      TextInputType.emailAddress,
                      bodyColor.value,
                      Colors.transparent,
                      (val) => controller.email.value = val),
                  Space(0, Get.height * 0.12),
                  Btn(
                      mainColor.value,
                      Get.width * 0.9,
                      50,
                      Obx(() => controller.loading.value
                          ? CircularProgressIndicator(
                              color: txtColor.value,
                            )
                          : txt("confirm".tr, txtColor.value, 20, true)),
                      false,
                      () => controller.storeData()),
                  Space(0, Get.height * 0.03),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget imgBtn(IconData icon, String t, click) => FlatButton(
        onPressed: click,
        child: Row(
          children: [
            Icon(
              icon,
              color: mainColor.value,
              size: 32,
            ),
            Space(8, 0),
            txt(t, txtColor.value, 22, false),
          ],
        ),
      );
}

class SignUpController extends GetxController {
  var email = "".obs,
      userName = "".obs,
      loading = false.obs,
      imgUrl = "".obs,
      imgSrc = "".obs,
      imgName = "".obs,
      videoName = "".obs,
      snackStatus = SnackbarStatus.CLOSED.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  void storeData() async {
    mainController.getContacts();
    var user = FirebaseAuth.instance.currentUser,
        token = await FirebaseMessaging.instance.getToken();
    if (email.isNotEmpty && userName.isNotEmpty) {
      loading.value = true;
      var imgN = imgName.value, imgF = mainController.imgFile.value;
      if (imgN.isNotEmpty && imgF != null) {
        imgUrl.value = mainController.storeFile("imgs", imgN, imgF);
      }
      var dtime = user?.metadata.creationTime;
      var joined = DateFormat.yMd().format(dtime!);
      await mainController.users.doc(user?.uid).set({
        "username": userName.value,
        "phone": mainController.phone.value,
        "email": email.value,
        "token": token,
        "imgUrl": imgUrl.value,
        "blocked": [],
        "status": "",
        "accountPrivacy": "public",
        "storyPrivacy": "public",
        "phonePrivacy": "public",
        "imgPrivacy": "public",
        "storyExceptions": [],
        "joined": joined
      }).then((value) => Get.offNamed("/home"));
      imgName.value = "";
      mainController.imgFile.value = File("");
    } else {
      loading.value = false;
      snackMsg("err1".tr + " " + "enter".tr + " " + "data".tr);
    }
  }
}
