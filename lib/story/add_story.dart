import 'package:chatting/common/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';
import 'package:random_string/random_string.dart';
import 'story_controller.dart';

StoryController storyController = Get.put(StoryController());

class AddStory extends StatefulWidget {
  String storyType = "";
  List fileData = [];
  AddStory(String type, List data) {
    this.storyType = type;
    this.fileData = data;
  }
  @override
  _AddStoryState createState() => _AddStoryState();
}

class _AddStoryState extends State<AddStory> {
  String text = "";
  Color backgroundColor = bodyColor.value, textColor = txtColor.value;
  double textSize = 28.0;
  bool dark = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: backgroundColor,
        title: ProfileImg(
            23, mainController.userImg.value, "user", mainColor.value),
        actions: widget.storyType == "text"
            ? [
                myIcon(Icons.text_fields, textColor, 31, () {
                  setState(() {
                    dark = !dark;
                    textColor = dark ? Colors.white : Colors.black;
                  });
                }),
                myIcon(Icons.color_lens, mainColor.value, 32, showColorPicker),
                Space(10, 0)
              ]
            : [],
      ),
      body: Container(
        width: Get.width,
        height: Get.height,
        color: backgroundColor,
        child: Center(child: TxtBox()),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: mainColor.value,
        child: const Icon(
          Icons.send,
          color: Colors.white,
          size: 26,
        ),
        onPressed: () async {
          Get.back();
          if (text.isNotEmpty) {
            await storyController.addStory(
                widget.storyType, text, "", "", backgroundColor, textColor);
            print("done!");
            storyController.storyKey.value = Key(randomString(5));
          } else {
            snackMsg("Error" + " " + "typeSomething".tr);
          }
        },
      ),
    );
  }

  Widget TxtBox() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: TextField(
        minLines: 5,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        cursorHeight: 30,
        cursorColor: mainColor.value,
        autofocus: true,
        textAlign: TextAlign.center,
        style: TextStyle(color: textColor, fontSize: textSize),
        decoration: const InputDecoration(
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
        ),
        onChanged: (val) {
          setState(() {
            text = val;
            textSize = text.length > 100 ? 22 : 28;
          });
        },
      ),
    );
  }

  showColorPicker() {
    Get.defaultDialog(
        backgroundColor: boxColor.value,
        title: "backColor".tr,
        titleStyle: TextStyle(color: mainColor.value),
        content: Center(
          child: ColorPicker(
            pickerColor: bodyColor.value,
            onColorChanged: (color) {
              setState(() => backgroundColor = color);
            },
          ),
        ));
  }
}
