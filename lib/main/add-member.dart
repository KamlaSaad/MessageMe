import 'package:chatting/common/shared.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddMember extends StatelessWidget {
  FilterPeople filter = FilterPeople();
  List groupList = Get.arguments[0],
      list = mainController.exceptPeople(mainController.allUsers);
  Color favColor = Get.arguments[1];
  @override
  Widget build(BuildContext context) {
    List data = mainController.exceptGroupList(list, groupList);
    return Scaffold(
      backgroundColor: bodyColor.value,
      appBar: AppBar(
        backgroundColor: bodyColor.value,
        leading: myIcon(Icons.arrow_back, favColor, 24, () => Get.back()),
        title: txt("Add new member", txtColor.value, 21, true),
      ),
      body: filter.FilterBox(context, data, favColor),
      floatingActionButton: FloatingActionButton(
        backgroundColor: favColor,
        child: Icon(
          Icons.check,
          color: Colors.white,
          size: 30,
        ),
        onPressed: () async {
          print(filter.users);
          mainController.OnlineAction(
              await chatController.addMember(filter.users));
          Get.back();
        },
      ),
    );
  }
}
