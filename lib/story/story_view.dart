import 'dart:async';
import 'package:chatting/common/shared.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'story_controller.dart';

class StoryViewer extends StatefulWidget {
  var data = [];
  bool isMyStory = false;
  StoryViewer(list, my) {
    this.data = list;
    this.isMyStory = my;
  }
  @override
  _StoryViewerState createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer> {
  List stories = [];
  String type = "",
      url = "",
      text = "",
      time = "",
      profileImg = "",
      name = "",
      id = "",
      react = "";
  double size = 26;
  bool showViewsBox = false, makeReact = false;
  var views = [],
      counter = 0,
      textColor = txtColor.value.value,
      backColor = bodyColor.value.value;
  var constraints = const BoxConstraints(
      minHeight: double.infinity, minWidth: double.infinity);
  StoryController storyController = Get.put(StoryController());

//  @override
  @override
  Widget build(BuildContext context) {
    updateVals();
    print(text.length);
    print("url $url");
    if (!widget.isMyStory) {
      storyController.viewStory(id, "");
    }

//    VideoPlayerController vc =
//        VideoPlayerController.network(type == "video" ? url : "")..initialize();
//    if (type == "video") {
//      vc = VideoPlayerController.network(url);
//    }

    return Scaffold(
      backgroundColor: type == "text" ? Color(backColor) : bodyColor.value,
      body: SafeArea(
        child: Container(
            width: Get.width,
            height: Get.height,
            decoration: type == "img"
                ? BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage(url), fit: BoxFit.fill))
                : null,
            child: type != "img"
                ? Stack(
                    children: [
                      type == "text"
                          ? Center(child: largeTxt(text, Color(textColor), size)
//                              SizedBox(
//                                width: Get.width * 0.77,
//                                height: Get.height * 0.78,
//                                child: Center(
//                                  child: ListView(
//                                    children: [
//                                      Column(
//                                        mainAxisAlignment:
//                                            MainAxisAlignment.center,
//                                        mainAxisSize: MainAxisSize.min,
//                                        children: [
////                                    Align(
////                                      alignment: Alignment.centerRight,
////                                      child:
//                                          largeTxt(
//                                              text, Color(textColor), size),
////                                    ),
//                                        ],
//                                      )
////                                  ),
//                                    ],
//                                  ),
//                                ),
//                              ),
                              )
                          : SizedBox(
                              width: Get.width,
                              height: Get.height,
                              child: null,
                            ),
                      TopSections(),
                      AnimatedPositioned(
                          duration: const Duration(seconds: 1),
                          left: Get.width * 0.46,
                          bottom: makeReact ? Get.height * 0.7 : 0,
                          child: AnimatedOpacity(
                            duration: const Duration(seconds: 1),
                            opacity: makeReact ? 0 : 1,
                            child: txt(react, txtColor.value, 38, false),
                          )),
                      AnimatedPositioned(
                          duration: const Duration(milliseconds: 500),
                          bottom: showViewsBox ? 0 : -(Get.height * 0.7),
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(0),
                            decoration: radiusBox(bodyColor.value),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  width: Get.width,
                                  decoration: radiusBox(mainColor.value),
                                  child: ListTile(
                                    leading: txt(
                                        '${"viewed".tr} ${views.length}',
                                        Colors.white,
                                        20,
                                        false),
                                    trailing: myIcon(
                                        Icons.close,
                                        Colors.grey,
                                        26,
                                        () => setState(
                                            () => showViewsBox = false)),
                                  ),
                                ),
                                views.length > 0
                                    ? Container(
                                        constraints: BoxConstraints(
                                            minHeight: 10,
                                            maxHeight: Get.height * 0.2),
                                        child: ListView(
                                          children: Views(),
                                        ),
                                        color: Colors.black)
                                    : Space(0, 0),
                              ],
                            ),
                          ))
                    ],
                  )
                : TopSections()),
      ),
    );
  }

  Widget TopSections() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              myIcon(Icons.close, Colors.grey, 30, () => Get.back()),
              CircleAvatar(
                  radius: 26,
                  backgroundColor: mainColor.value,
                  child: ProfileImg(24, profileImg, "user", mainColor.value)),
              Space(10, 0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  txt(name, mainColor.value, 22, true),
                  txt("$time", Color(textColor).withOpacity(0.6), 18, false)
                ],
              ),
              Spacer(),
              widget.isMyStory
                  ? PopupMenuButton(
                      padding: EdgeInsets.all(0),
                      color: bodyColor.value,
                      child: const Icon(
                        Icons.more_vert,
                        color: Colors.grey,
                        size: 30,
                      ),
                      itemBuilder: (context) => [
                            PopupMenuItem(
                                child: Row(
                                  children: [
                                    myIcon(Icons.delete, mainColor.value, 26,
                                        () => null),
                                    txt("delete".tr, txtColor.value, 22, false),
                                  ],
                                ),
                                onTap: () {
                                  Timer(
                                      Duration(milliseconds: 400),
                                      () => confirmBox(
                                              "delete".tr + " " + 'story'.tr,
                                              "confirmDel".tr,
                                              "delete".tr, () async {
                                            Get.back();
                                            Get.back();
                                            if (stories.length == 1) {
                                              Get.back();
                                            } else {
                                              setState(() => counter++);
                                            }
                                            await storyController
                                                .deleteStory(id);
                                          }, () => Get.back()));
                                }),
                            PopupMenuItem(
                              child: GestureDetector(
                                child: Row(
                                  children: [
                                    myIcon(Icons.edit, mainColor.value, 26,
                                        () => null),
                                    txt("edit".tr, txtColor.value, 22, false),
                                  ],
                                ),
                                onTap: () {
                                  String txtValue = "";
                                  Timer(
                                      Duration(milliseconds: 400),
                                      () => EditBox("story".tr + " " + "txt".tr,
                                              text, (val) => txtValue = val,
                                              () async {
                                            Get.back();
                                            if (txtValue.isNotEmpty) {
                                              await storyController
                                                  .editStoryTxt(id, txtValue);
                                              Get.back();
                                              Get.back();
                                            }
                                          }));
                                },
                              ),
                              value: 2,
                            ),
                          ])
                  : Space(0, 0),
//              myIcon(Icons.more_vert, Colors.grey, 30, () async {
//                storyController.deleteStory(id);
//              }),
            ],
          ),
        ),
        Spacer(),
        widget.data.length > 1
            ? Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SliderIcon(Icons.arrow_back_ios, 46, () => decrement()),
                    SliderIcon(Icons.arrow_forward_ios, 46, () => increment()),
                  ],
                ),
              )
            : Space(0, 0),
        Spacer(),
        //caption
        type != "text"
            ? Container(
                width: Get.width,
                padding: const EdgeInsets.symmetric(vertical: 5),
                color: bodyColor.value.withOpacity(0.6),
                child: Center(child: largeTxt(text, Colors.white, 20)),
              )
            : Space(0, 0),
        !widget.isMyStory
            ? Container(
                width: Get.width,
                height: Get.height * 0.1,
                padding: const EdgeInsets.all(12),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Btn(
                        bodyColor.value,
                        Get.width * 0.4,
                        Get.height * 0.1,
                        txt("reply".tr, mainColor.value, size, false),
                        true, () {
                      reply();
                    }),
                    reactIcon("❤"),
                    reactIcon("😂"),
                    reactIcon("😢"),
                    reactIcon("☹"),
                  ],
                ),
              )
            : Center(
                child: myIcon(Icons.remove_red_eye_rounded, mainColor.value, 26,
                    () {
                  for (int i = 0; i < views.length; i++) {
                    if (views[i]['name'] == null) {
                      Map userData =
                          mainController.getUser(views[i]['viewerId']);
                      String name = mainController.isContact(userData['phone']);
                      views[i]['name'] =
                          name.isNotEmpty ? name : userData["username"];
                      views[i]['img'] =
                          mainController.getFriendImg(userData["imgUrl"]);
                    }
                  }
                  setState(() {
                    storyController.storyId.value = id;
                    showViewsBox = !showViewsBox;
                  });
                }),
              ),
      ],
    );
  }

  Widget reactIcon(String icon) {
    return GestureDetector(
        child: Padding(
          padding: const EdgeInsets.only(top: 5, left: 4, right: 4),
          child: txt(icon, txtColor.value, 36, true),
        ),
        onTap: () async {
          setState(() {
            react = icon;
            makeReact = true;
          });
          await storyController.viewStory("$id", "${react}");
//          setState(() => makeReact = false);
        });
  }

  void increment() {
    if (counter < widget.data.length - 1) setState(() => counter++);
    if (!widget.isMyStory) {
      storyController.viewStory(id, "");
    }
  }

  void decrement() {
    if (counter > 0) setState(() => counter--);
  }

  Views() {
    List<Widget> ViewsItems = [];
    var storyViews = mainController.sortByDate(views, false);
    if (storyViews.length > 0) {
      for (int i = 0; i < storyViews.length; i++) {
        var data = storyViews[i],
            time = mainController.convertDate(data['date']);
        print('data $data');
        ViewsItems.add(ListTile(
          contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
          leading: ProfileImg(25, "${data['img']}", "user", mainColor.value),
          title: txt("${data['name']}", mainColor.value, 20, true),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: txt(time, Colors.grey, 17, false),
          ),
          trailing: txt("${data['react']}", txtColor.value, 22, false),
        ));
      }
    }
    return ViewsItems;
  }

  updateVals() {
    var data = widget.data;
    setState(() {
      id = data[counter]['id'];
      url = "${data[counter]['mediaUrl']}";
      text = data[counter]['text'] ?? "";
      type = data[counter]['type'].toString();
      time = data[counter]['time'];
      name = data[counter]['name'].toString();
      profileImg = data[counter]['img'];
      textColor = data[counter]['textColor'] ?? txtColor.value.value;
      backColor = data[counter]['backgroundColor'] ?? bodyColor.value.value;
      size = text.length < 150 ? 26 : 22;
      views = data[counter]['views'] ?? [];
    });
  }

  reply() {
    var userId = widget.data[0]['senderId'],
        userData = mainController.getUser(userId),
        userName = userData['name'].isNotEmpty
            ? userData['name']
            : userData['username'],
        img = mainController.getFriendImg(userData['imgUrl']);

    Map defaultChat =
            chatController.defaultChatData(userName, img, 'chat', [userId]),
        chat = mainController.getChatByUsers(userId);
    chatController.chatData.value = chat.isEmpty ? defaultChat : chat;
//    Message(msgD, chatType)
//    chatController.toggleReply(true, msg, false);
    Get.toNamed("/chat");
  }
}
