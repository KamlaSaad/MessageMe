import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../common/shared.dart';

class Exceptions extends StatefulWidget {
  @override
  _ExceptionsState createState() => _ExceptionsState();
}

class _ExceptionsState extends State<Exceptions> {
  FilterPeople filterPeople = FilterPeople();
  String title = Get.arguments ?? "";
  List users = [];
  var data = [].obs;
  @override
  Widget build(BuildContext context) {
    data.value = mainController.exceptPeople(mainController.allUsers.value);
    addExceptions();
    users = filterPeople.users;
    return Scaffold(
      backgroundColor: bodyColor.value,
      appBar: AppBar(
        backgroundColor: bodyColor.value,
        leading: myIcon(Icons.arrow_back, mainColor.value, 24, () => Get.back()),
        title: txt("$title".tr, txtColor.value, 22, false),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [filterPeople.FilterBox(context, data, mainColor.value)],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: mainColor.value,
          child: Icon(Icons.check, color: txtColor.value, size: 30),
          onPressed: () async {
            if (title.contains("story"))
              save(mainController.storyExceptions, mainController.storyPrivacy,
                  "story");
            else
              save(mainController.imgExceptions, mainController.imgPrivacy,
                  "img");
          }),
    );
  }

  void addExceptions() {
    var list = title.contains("story")
        ? mainController.storyExceptions
        : mainController.imgExceptions;
    for (int i = 0; i < list.length; i++) {
      for (int j = 0; j < data.value.length; j++) {
        if (data.value[j]['id'] == list[i]) {
          setState(() {
            data.value[j]['selected'] = true;
            users.add(data[j]['id']);
          });
        }
      }
    }
  }

  save(var controllerVal, var privacy, String text) async {
    print(users);
    var u = users.toSet().toList();
    print(u);
    print(controllerVal.value);
    if (!listEquals(controllerVal.value, u)) {
      controllerVal.value = u;
      mainController.storageBox.write(text + "Exception", u);
      privacy.value = "contactsexcept";
      mainController.storageBox.write(text + "Privacy", "contactsexcept");
      print("done");
//      await mainController.editField(text + "Exception", u, false);
//      await mainController.editField(text + "Privacy", "contactsexcept", false);
    }
    Get.back();
  }
}
