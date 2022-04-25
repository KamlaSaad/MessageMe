import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../common/shared.dart';

class Contacts extends StatelessWidget {
  List contacts = [];
  var usersBtnBorder = false.obs,
      contactsBtnBorder = true.obs,
      name = "username".obs;
//  var data = mainController.getAllUsers().obs;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bodyColor.value,
      appBar: appBar(),
      body: Container(
          padding: EdgeInsets.only(bottom: 5),
          width: Get.width,
          height: Get.height,
          child: Stack(
            children: [
              Column(
                children: [
                  Space(0, 15),
                  Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          //all users
                          Btn(
                              usersBtnBorder.value
                                  ? bodyColor.value
                                  : mainColor.value,
                              Get.width * 0.37,
                              40,
                              txt(
                                  "all".tr + " " + "users".tr,
                                  usersBtnBorder.value
                                      ? txtColor.value
                                      : Colors.white,
                                  18,
                                  false),
                              usersBtnBorder.value, () {
                            name.value = "username";
                            usersBtnBorder.value = false;
                            contactsBtnBorder.value = true;
                          }),
                          // contacts
                          Btn(
                              contactsBtnBorder.value
                                  ? bodyColor.value
                                  : mainColor.value,
                              Get.width * 0.37,
                              40,
                              txt(
                                  "contacts".tr,
                                  contactsBtnBorder.value
                                      ? txtColor.value
                                      : Colors.white,
                                  20,
                                  false),
                              contactsBtnBorder.value, () async {
                            usersBtnBorder.value = true;
                            contactsBtnBorder.value = false;
                            contacts = await mainController.getContacts();

//                            await mainController.updateContacts(newContacts);
                          }),
                        ],
                      )),
                  Space(0, 12),
                  Obx(() => Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      height: Get.height * 0.65,
                      child: FutureBuilder(
                          future: contactsBtnBorder.value
                              ? mainController.getFriends()
                              : mainController.getContacts(),
                          builder: (context, AsyncSnapshot snap) {
                            switch (snap.connectionState) {
                              case ConnectionState.none:
                                return Center(
                                    child: txt(
                                        "noNet".tr, txtColor.value, 22, true));
                              case ConnectionState.active:
                              case ConnectionState.waiting:
                                return Center(
                                    child: txt(
                                        "load".tr, txtColor.value, 22, true));
                              case ConnectionState.done:
                                if (snap.hasError) {
                                  print(snap.error);
                                }
                                var data = snap.data;
                                if (usersBtnBorder.value) {
                                  mainController.userContacts.value = data;
                                }
                                return data.length > 0
                                    ? ListView.builder(
                                        itemCount: data.length,
                                        itemBuilder: (context, i) {
                                          var user = data[i],
                                              img = mainController
                                                  .getFriendImg(user['imgUrl']),
                                              contact = mainController
                                                  .isContact(user['phone']),
                                              subT = contact.isEmpty
                                                  ? user['email']
                                                  : user['phone'];
                                          print(
                                              "${user['username']} blocked ${mainController.isBlocked(user['id'])}");
                                          return UsersListItem(
                                            img,
                                            "user",
                                            user['name'].isEmpty
                                                ? user['username']
                                                : user['name'],
                                            subT,
                                            user['connected'],
                                            null,
                                            () async {
                                              Get.toNamed("/userProfile",
                                                  arguments: user);
//                                              await chatController.notify();
                                            },
                                          );
                                        })
                                    : !mainController.connected.value
                                        ? loadingMsg("noNet".tr)
                                        : (usersBtnBorder.value
                                            ? loadingMsg(
                                                "no".tr + " " + "contacts".tr)
                                            : loadingMsg(
                                                "no".tr + " " + "users".tr));
                            }
                          }))),
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
                          txtColor.value, "/home"),
                      BottomIcon("people".tr, Icons.people_alt_sharp,
                          mainColor.value, null),
                      BottomIcon("stories".tr, Icons.amp_stories,
                          txtColor.value, "/stories")
                    ],
                  ),
                ),
              )
            ],
          )),
    );
  }
}
