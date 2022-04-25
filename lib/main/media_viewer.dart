import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:random_string/random_string.dart';
import 'package:video_player/video_player.dart';
import '../story/story_controller.dart';
import '../common/shared.dart';

StoryController storyController = Get.put(StoryController());
var c = TextEditingController();

class MediaViewer extends StatefulWidget {
  String folder = "", type = "";
  List filesData = [];
  MediaViewer(type, folder, files) {
    this.type = type;
    this.folder = folder;
    this.filesData = files;
  }
  @override
  _MediaViewerState createState() => _MediaViewerState();
}

class _MediaViewerState extends State<MediaViewer> {
  String title = "", caption = "", fileType = "", fileName = "";
  var counter = 0.obs;

  @override
  Widget build(BuildContext context) {
    fileType = widget.folder.substring(0, widget.folder.length - 1);
    fileName = widget.filesData[counter.value]['name'];
    title = widget.type == "msg"
        ? "${'send'.tr} $fileType to ${chatController.chatData['name']}"
        : "Add Story";
    return Scaffold(
      backgroundColor: bodyColor.value,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        leading:
            myIcon(Icons.arrow_back, mainColor.value, 30, () => Get.back()),
        titleSpacing: 2,
        title: txt(title, txtColor.value, 23, false),
        actions: [
          widget.filesData.length > 1
              ? myIcon(Icons.clear, mainColor.value, 30, () {
                  this.setState(() {
                    widget.filesData.remove(widget.filesData[counter.value]);
                  });
                  if (widget.filesData.length == 0) Get.back();
                })
              : Space(10, 0),
        ],
      ),
      body: Container(
        width: Get.width,
        height: Get.height,
        child: Stack(
          children: [
            Center(
              child: Container(
                  width: Get.width,
                  height: Get.height * 0.55,
                  child: widget.filesData.length >= 1 ? Box() : null),
            ),
            widget.filesData.length > 1
                ? Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.arrow_back_ios, () => decrement()),
                        Icon(Icons.arrow_forward_ios, () => increment()),
                      ],
                    ),
                  )
                : Space(0, 0),
            Positioned(
              bottom: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: Get.width * 0.8,
                    height: 45,
                    child: TxtInput(
                        "Add caption",
                        "",
                        "",
                        false,
                        TextInputType.text,
                        mainColor.value,
                        Colors.transparent,
                        (val) => caption = val),
                  ),
                  Space(10, 0),
                  CircleAvatar(
                    backgroundColor: mainColor.value,
                    radius: 24,
                    child: myIcon(Icons.send, Colors.white, 26, () async {
                      Get.back();
                      loadBox();
                      for (int i = 0; i < widget.filesData.length; i++) {
                        String url = await mainController.storeFile(
                            widget.folder,
                            widget.filesData[i]['name'],
                            widget.filesData[i]['file']);
                        print("url $url");
                        if (url.isNotEmpty) {
                          if (widget.type == "msg") {
                            await chatController.createMsg(
                                caption, url, fileType, "");
                            Get.back();
                          } else {
                            await storyController.addStory(
                                fileType,
                                caption,
                                url,
                                widget.filesData[i]['name'],
                                bodyColor.value,
                                txtColor.value);
                            storyController.storyKey.value =
                                Key(randomString(5));
                            Get.back();
                          }

//                          } else {
//                            DialogMsg("Network Error",
//                                "Please check your internet connection");
//                          }
                        }
                      }
                    }),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  addMsg(String url, String id) async {
    await chatController.addMsg(
        caption, url, fileType, id, chatController.chatData['receivers'], "");
  }

  Widget Box() {
    bool playing = false;
    VideoPlayerController vc =
        VideoPlayerController.file(widget.filesData[counter.value]['file'])
          ..initialize();
    var child = widget.folder == "imgs"
        ? Image.file(
            widget.filesData[counter.value]['file'],
            fit: BoxFit.cover,
          )
        : GestureDetector(
            child: VideoPlayer(vc),
            onTap: () {
              this.setState(() {
                playing = !playing;
              });
              playing ? vc.play() : vc.pause();
              print(playing);
            },
          );
    return child;
  }

  Widget Icon(IconData icon, click) {
    return GestureDetector(
      child: Container(
          width: 60,
          height: 60,
          color: bodyColor.value.withOpacity(0.5),
          child: myIcon(icon, txtColor.value, 30, () => click)),
      onTap: () => print(counter.value),
    );
  }

  void increment() {
    if (counter.value < widget.filesData.length - 1) counter.value++;
  }

  void decrement() {
    if (counter.value > 0) counter.value--;
    print(counter.value);
  }
}
