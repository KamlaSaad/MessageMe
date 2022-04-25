import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../common/shared.dart';
import 'dart:io';

class AddGroup extends StatefulWidget {
  @override
  _AddGroupState createState() => _AddGroupState();
}

class _AddGroupState extends State<AddGroup> {
  FilterPeople filter = FilterPeople();
  var groupName = "", users = [], checkIcon = Icons.check_box_outline_blank;
  bool checked = false, isGroup = false;
  String title = Get.arguments[0] ?? "", imgName = "";
  var img, data = mainController.exceptPeople(mainController.allUsers);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bodyColor.value,
      appBar: AppBar(
        backgroundColor: bodyColor.value,
        leading:
            myIcon(Icons.arrow_back, mainColor.value, 24, () => Get.back()),
        title: txt(title, txtColor.value, 22, false),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              leading: GestureDetector(
                child: FileImg(26, img, "group", mainColor.value),
                onTap: () async {
                  List filesData = await mainController
                      .uploadFile(true, ['jpg', 'png', 'jpeg', 'jif']);
                  if (filesData.isNotEmpty) {
                    setState(() => img = filesData[0]['file']);
                    imgName = filesData[0]['name'];
                  }
                },
              ),
              title: TxtInput(
                "groupName".tr,
                "",
                "",
                false,
                TextInputType.text,
                mainColor.value,
                Colors.transparent,
                (val) => setState(() => groupName = val),
              ),
            ),
            filter.FilterBox(context, data, mainColor.value),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: mainColor.value,
          child: Icon(
            Icons.check,
            color: Colors.white,
            size: 30,
          ),
          onPressed: () async {
            users = filter.users;
            Map check = mainController.userChats
                .singleWhere((it) => it['name'] == groupName, orElse: () => {});
            if (groupName.isEmpty)
              snackMsg('err1'.tr +
                  " " +
                  "enter".tr +
                  " " +
                  "groupName".tr.toLowerCase());
            else if (check.isNotEmpty) {
              snackMsg("err1".tr + " " + "nameExist".tr);
            } else if (users.length < 2)
              snackMsg('err1'.tr + ' ' + 'group Contain'.tr);
            else {
              loadBox();
              users.insert(0, myId);
              String url = "";
              if (img != null) {
                url = await mainController.storeFile("imgs", imgName, img);
              }
              String id = await chatController.addChat(
                  "", mainColor.value, groupName, url, "group", users);
              print("id $id");
              if (id.isEmpty) {
                Get.back();
                snackMsg('err1'.tr + ' ' + 'err2'.tr);
              } else {
                Get.back();
                Map chat = mainController.getChatById(id);
                print(chat);
                users.remove(myId);
                await chatController.addMsg(
                    "created this group", "", "hint", id, users, "");

                chat['name'] = groupName;
                chatController.chatData.value = chat;
                setState(() {
                  groupName = "";
                  users = [];
                });
                mainController.changeHomeKey();
                Get.offNamed("/chat");
              }
            }
          }),
    );
  }
}
