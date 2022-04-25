import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chatting/common/shared.dart';

class ProfileImgViewer extends StatelessWidget {
  bool review = false;
  String userName = "";
  List imgs = [];
  var counter = 0.obs;
  Function action = () {};
  int length = 0;
  ProfileImgViewer(review, userName, imgs, action) {
    this.review = review;
    this.userName = userName;
    this.imgs = imgs;
    this.action = action;
  }
  String title = "upload".tr + " " + "photo".tr;
  @override
  Widget build(BuildContext context) {
    length = imgs.length;
    counter.value = length > 1 ? length - 1 : 0;
    return Scaffold(
      backgroundColor: bodyColor.value,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bodyColor.value,
        leading: myIcon(Icons.arrow_back, mainColor.value, 30, () => Get.back()),
        titleSpacing: 2,
        title: txt(review ? title : userName, txtColor.value, 21, false),
      ),
      body: Stack(
        children: [
          Container(
            width: Get.width,
            height: Get.height,
            child: review
                ? Image.file(imgs[0]['file'])
                : Obx(() => Image.network(
                      imgs[counter.value],
                      fit: BoxFit.cover,
                    )),
          ),
          length > 1
              ? Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SliderIcon(Icons.arrow_back_ios, 50, () => decrement()),
                      SliderIcon(
                          Icons.arrow_forward_ios, 50, () => increment()),
                    ],
                  ),
                )
              : Space(0, 0),
          review
              ? Positioned(
                  bottom: 15,
                  right: 15,
                  child: GestureDetector(
                    onTap: () async => await action(),
                    child: CircleAvatar(
                      radius: 30,
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 25,
                      ),
                      backgroundColor: mainColor.value,
                    ),
                  ),
                )
              : Space(0, 0),
        ],
      ),
//      floatingActionButton: review
//          ? FloatingActionButton(
//              backgroundColor: mainColor.value,
//              child: Icon(
//                Icons.send,
//                color: Colors.white,
//                size: 25,
//              ),
//              onPressed: () async => await action,
//            )
//          : null,
    );
  }

  void increment() {
    if (counter.value < length - 1) counter.value++;
    print(counter.value);
  }

  void decrement() {
    if (counter.value > 0) counter.value--;
    print(counter.value);
  }
}
