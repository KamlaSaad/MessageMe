import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import '../common/shared.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool locked = true;
  @override
  build(BuildContext context) {
    return Obx(() => Scaffold(
          backgroundColor: bodyColor.value,
          appBar: AppBar(
            backgroundColor: bodyColor.value,
            leading:
                myIcon(Icons.arrow_back, mainColor.value, 22, () => Get.back()),
            title: txt("settings".tr, txtColor.value, 24, true),
          ),
          body: ListView(
            padding: EdgeInsets.all(10),
            children: [
              ListItem(
                  Icons.nightlight_round,
                  txtColor.value.withOpacity(0.8),
                  "mood".tr,
                  mainController.dark.value ? "on".tr : "off".tr,
                  Switch(
                      value: mainController.dark.value,
                      onChanged: (val) {
                        mainController.initController();
                        mainController.storageBox.write("darkVal", val);
                        mainController.dark.value = !mainController.dark.value;
                        mainController.toggleDark();
                      }),
                  () {}),
              ListItem(
                  Icons.notifications_active,
                  mainColor.value,
                  "status".tr,
                  "",
                  Switch(
                      value: mainController.activeStatus.value,
                      onChanged: (val) async {
                        mainController.initController();
                        if (mainController.connected.value) {
                          mainController.activeStatus.value = val;
                          mainController.storageBox.write("activeStatus", val);
//                          await mainController.editField(
//                              "status", val ? "online" : "", false);
                        } else
                          snackMsg("noNet".tr + " " + "tryAgain".tr);
                      }),
                  () {}),
              ListItem(
                  Icons.lock,
                  txtColor.value,
                  "lockScreen".tr,
                  "",
                  Switch(
                      value: mainController.locked.value,
                      onChanged: (val) {
                        mainController.locked.value = val;
                        if (mainController.locked.value) {
                          List options = ['pattern', 'PIN'];
                          var groupVal = "${mainController.lockType.value}".obs;
                          confirmBox(
                              "Lock Screen".tr,
                              Container(
                                  child: Obx(() => GroupedRadio(
                                          groupVal.value, options, false,
                                          (val) {
                                        groupVal.value = val;
                                      }))),
                              "confirm".tr, () async {
                            Get.back();
                            mainController.locked.value = false;
                            groupVal.value == "pattern"
                                ? Get.toNamed("/setPattern")
                                : Get.toNamed("/setPass");
                          }, () => Get.back());
                        } else {
                          print(mainController.lockType.value);
                          mainController.locked.value = true;
                          confirmBox("cancel".tr + " " + "lockScreen".tr,
                              "lockScreenDec".tr, "confirm".tr, () {
                            Get.back();
                            String val = mainController.lockType.value;
                            Get.toNamed(
                                val == "PIN" ? "/checkPass" : "/checkPattern",
                                arguments: true);
                          }, () => Get.back());
                        }
                      }),
                  () {}),
              ListItem(Icons.language, Colors.blue, "lang".tr, "", null, () {
                List options = ['en', 'ar'];
                var groupVal = "${mainController.lang.value}".obs;
                confirmBox(
                    "lang".tr,
                    Container(
                        child: Obx(() =>
                            GroupedRadio(groupVal.value, options, false, (val) {
                              print("val $val");
                              groupVal.value = val;
                            }))),
                    "confirm".tr, () async {
                  mainController.lang.value = groupVal.value;
                  mainController.storageBox
                      .write("lang", mainController.lang.value);
                  Get.updateLocale(Locale(groupVal.value));
                  Get.back();
                }, () => Get.back());
              }),
              ListItem(Icons.color_lens, txtColor.value, "mainColor".tr, "",
                  null, () => showColorPicker()),
              ListItem(
                  Icons.person, txtColor.value, "accountPrivacy".tr, "", null,
                  () async {
                await change(mainController.accountPrivacy, "accountPrivacy",
                    "whoSeeProfile", false);
              }),
              ListItem(
                  Icons.photo, Colors.deepPurple, "profilePicture".tr, "", null,
                  () async {
                await change(mainController.imgPrivacy, "profilePicture",
                    "whoSeePhoto", true);
              }),
              ListItem(Icons.phone, Colors.green, "phone".tr,
                  mainController.phonePrivacy.value.tr, null, () async {
                await change(mainController.phonePrivacy, "phonePrivacy",
                    "whoSeePhone", false);
              }),
              ListItem(Icons.amp_stories, mainColor.value, "storyPrivacy".tr,
                  mainController.storyPrivacy.value.tr, null, () async {
                await change(mainController.storyPrivacy, "storyPrivacy",
                    "whoSeeStory", true);
              }),
              ListItem(
                  Icons.block,
                  Colors.redAccent,
                  "blockedPeople".tr,
                  "${mainController.blockedUsers.length} ${'block'.tr}",
                  null,
                  () => Get.toNamed("/blockedPeople")),
              ListItem(
                  Icons.logout, Colors.deepPurpleAccent, "logout".tr, "", null,
                  () {
                if (mainController.connected.value) {
                  confirmBox("logout".tr, "logoutDec".tr, "confirm".tr,
                      () async {
                    await mainController.auth.signOut();
                    Get.offAllNamed("/verify");
                  }, () => Get.back());
                } else
                  snackMsg("noNet".tr + " " + "tryAgain".tr);
              }),
            ],
          ),
        ));
  }

  Widget ListItem(
      IconData icon, Color color, String title, String sub, var trail, tap) {
    double p = mainController.lang.value == "en" ? 3 : 0;
    return ListTile(
      leading: myIcon(icon, color, 35, () {}),
      title: txt(title, txtColor.value, 20, false),
      minVerticalPadding: 1,
      trailing: trail,
      onTap: tap,
      contentPadding: const EdgeInsets.symmetric(vertical: 0),
    );
  }

  change(var controllerVal, String privacy, String title, bool except) async {
    List options = ['public', 'contacts'];
    bool disable = false;
    var aP = mainController.accountPrivacy.value, groupVal = "".obs;
    if (except) {
      options = aP == "public"
          ? ['public', 'contacts', 'contactsExcept']
          : ['contacts', 'contactsExcept'];
    }
    if (privacy == "phonePrivacy") {
      disable = aP == "contacts";
    }
    groupVal.value = controllerVal.value;
    confirmBox(
        title.tr,
        Container(
            child:
                Obx(() => GroupedRadio(groupVal.value, options, disable, (val) {
                      groupVal.value = val;
                    }))),
        "confirm".tr, () async {
      Get.back();
      print(groupVal.value);
      if (controllerVal.value != groupVal.value || disable == false) {
        if (mainController.connected.value) {
          if (groupVal.value == 'contactsexcept') {
            mainController.resetSelectedUsers();
            Get.toNamed("/exceptions", arguments: privacy);
          } else {
//            equal
            controllerVal.value = groupVal.value;
            mainController.storageBox.write("$privacy", groupVal);
            print("${controllerVal.value}");
//            await mainController.editField(privacy, groupVal.value, false);
          }
        } else
          snackMsg("noNet".tr + " " + "tryAgain".tr);
      }
    }, () => Get.back());
  }

  showColorPicker() {
    Color pColor = mainColor.value;
    Get.defaultDialog(
      backgroundColor: boxColor.value,
      title: "mainColor".tr,
      titleStyle: TextStyle(color: mainColor.value),
      content: Center(
        child: ColorPicker(
            pickerColor: pColor, onColorChanged: (color) => pColor = color),
      ),
      confirm: TxtBtn("confirm".tr, pColor, 5, () {
        print(pColor);
        mainColor.value = pColor;
        mainController.favColor.value = pColor.value;
        mainController.storageBox.write("color", pColor.value);
        Get.back();
      }),
      cancel: TxtBtn("cancel".tr, txtColor.value, 5, () => Get.back()),
    );
  }
}
