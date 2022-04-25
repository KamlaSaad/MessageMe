import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../common/shared.dart';

class FileViewer extends StatefulWidget {
  String folder = "";
  List filesData = [];

  FileViewer(title, files) {
    this.folder = title;
    this.filesData = files;
  }

  @override
  _FileViewerState createState() => _FileViewerState();
}

class _FileViewerState extends State<FileViewer> {
  String title = "",
      caption = "",
      fileType = "",
      fileName = "",
      duration = "03:05";
  var counter = 0.obs;

  @override
  Widget build(BuildContext context) {
    fileType = widget.folder.substring(0, widget.folder.length - 1);
    fileName = widget.filesData[counter.value]['name'];

    title = "Send $fileType to ${mainController.receiverData['name']}";

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
          widget.filesData.length == 1
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
          child: ListView.builder(
              itemCount: widget.filesData.length,
              itemBuilder: (context, i) => Item(i))),
      floatingActionButton: FloatingActionButton(
        backgroundColor: mainColor.value,
        child: myIcon(Icons.send, txtColor.value, 30, () => send()),
        onPressed: () => null,
      ),
    );
  }

  Widget Item(int i) {
    bool playing = false;
    IconData icon =
        widget.folder == "files" ? Icons.file_copy : Icons.play_circle_fill;
    return ListTile(
      leading: myIcon(icon, mainColor.value, 40, () => null),
      title: txt(widget.filesData[i]['name'], txtColor.value, 20, false),
      subtitle: txt("${widget.filesData[i]['size']}",
          txtColor.value.withOpacity(0.7), 18, false),
      trailing: myIcon(Icons.delete, mainColor.value, 30, () {
        this.setState(() {
          widget.filesData.remove(widget.filesData[i]);
        });
        if (widget.filesData.length == 0) Get.back();
      }),
    );
  }

  void send() async {
    Get.back();
//    DialogMsg("Please wait", "your message will be loaded within seconds");
    for (int i = 0; i < widget.filesData.length; i++) {
      String url = await mainController.storeFile(widget.folder,
          widget.filesData[i]['name'], widget.filesData[i]['file']);
      print("url $url");
      if (url.isNotEmpty) {
        chatController.updateDateTime();
        chatController.addMsg(
            fileType == "file" ? widget.filesData[i]['name'] : duration,
            url,
            fileType,
            chatController.chatData.value['id'],
            mainController.receiverData['id'],
            "");
      }
    }
  }
}
