import 'package:chatting/common/shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'profile_img.dart';

class MyProfile extends StatelessWidget {
  var userName = "${mainController.userData.value['username']}".obs,
      userEmail = "${mainController.userData.value['email']}".obs,
      userPhone = "${mainController.userData.value['phone']}".obs;

  @override
  build(BuildContext context) {
    List userData = [
      {"icon": Icons.person, "title": "name", "val": userName},
      {"icon": Icons.email, "title": "email", "val": userEmail},
      {"icon": Icons.phone, "title": "phone", "val": userPhone}
    ];
    return Obx(() => Scaffold(
        backgroundColor: bodyColor.value,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: bodyColor.value,
          leading:
              myIcon(Icons.arrow_back, txtColor.value, 28, () => Get.back()),
          title: txt('myProfile'.tr, mainColor.value, 26, true),
        ),
        body: ListView(
          padding: const EdgeInsets.all(15),
          children: [
            Space(0, 10),
            Center(
                child: Stack(
              children: [
                GestureDetector(
                  child: ProfileImg(
                      Get.width * 0.21,
                      "${mainController.userImg.value}",
                      "user",
                      mainColor.value),
                  onTap: () async {
                    var data =
                        mainController.getUser(mainController.userData['id']);
                    if (data['imgUrl'].length > 0) {
                      print(data['imgUrl']);
                      Get.to(ProfileImgViewer(
                          false,
                          mainController.userData.value['username'],
                          data['imgUrl'],
                          () {}));
                    }
                  },
                ),
                Positioned(
                    bottom: 0,
                    right: 10,
                    child: circleIcon(mainColor.value, Colors.white,
                        Icons.camera_alt, 25, "", false, () async {
                      if (mainController.connected.value) {
                        List imgData = await mainController
                            .uploadFile(false, ['jpg', 'png', 'jpeg']);
                        print("imgData $imgData");
                        if (imgData[0] != null) {
                          Get.to(ProfileImgViewer(
                              true,
                              mainController.userData.value['username'],
                              [imgData[0]["file"]], () async {
                            String url = await mainController.storeFile(
                                "imgs", imgData[0]["name"], imgData[0]["file"]);
                            print("url $url");
                            if (url != null) {
                              Get.back();
                              mainController.userImg.value = url;
                              await mainController.updateProfileImg(url);
                              mainController.userData.value = mainController
                                  .getUser(mainController.userData['id']);
                            }
                          }));
                        }
                      } else {
                        snackMsg("noNet".tr + " " + "tryAgain".tr);
                      }
                    }))
              ],
            )),
            Space(0, Get.height * 0.04),
            SizedBox(
              height: Get.height * 0.55,
              child: ListView.separated(
                  separatorBuilder: (BuildContext context, int index) =>
                      Divide(),
                  itemBuilder: (BuildContext context, int i) {
                    String title = userData[i]['title'],
                        val = userData[i]['val'].value,
                        txtValue = "";
                    return ListTile(
                      leading: Icon(userData[i]['icon'],
                          size: 26, color: mainColor.value),
                      title: txt(
                          title.tr, txtColor.value.withOpacity(0.6), 17, false),
                      minVerticalPadding: 10,
                      subtitle: Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: txt(userData[i]['val'].value, txtColor.value,
                              19, false)),
                      onTap: () {
                        EditBox("${userData[i]['title']}".tr, val,
                            (val) => txtValue = val, () async {
                          Get.back();
                          if (txtValue.isNotEmpty) {
                            if (mainController.connected.value) {
                              if (title != "phone") {
                                await mainController.editField(
                                    title.toLowerCase(), txtValue, false);
                                UpdateValues();
                              } else {
                                mainController.updatePhone(txtValue, false);
                              }
                            } else {
                              snackMsg("noNet".tr + " " + "tryAgain".tr);
                            }
                          }
                        });
                      },
                    );
                  },
                  itemCount: 3),
            ),
          ],
        )));
  }

  UpdateValues() {
    userName.value = "${mainController.userData.value['username']}";
    userEmail.value = "${mainController.userData.value["email"]}";
  }
}
