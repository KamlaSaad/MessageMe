import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import '../common/shared.dart';

class ZoomMedia extends StatefulWidget {
  String type = "", url = "";

  ZoomMedia(type, url) {
    this.type = type;
    this.url = url;
  }
  @override
  _ZoomMediaState createState() => _ZoomMediaState();
}

class _ZoomMediaState extends State<ZoomMedia> {
  late VideoPlayerController vc;
  var isPlaying = false.obs;

  void initState() {
    super.initState();
    vc = VideoPlayerController.network(widget.url)..initialize();
  }

  @override
  void dispose() {
    vc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: Get.width,
        height: Get.height,
        color: bodyColor.value,
        child: widget.url.isEmpty
            ? null
            : widget.type == "img"
                ? Image.network(
                    widget.url,
                    fit: BoxFit.fill,
                  )
                : GestureDetector(
                    child: VideoPlayer(vc),
                    onTap: () async {
                      isPlaying.value = !isPlaying.value;
                      print(isPlaying.value);
                      isPlaying.value ? vc.play() : vc.pause();
                    },
                  ),
      ),
    );
  }
}
