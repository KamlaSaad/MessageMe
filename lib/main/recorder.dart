import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:random_string/random_string.dart';
import 'package:record_mp3/record_mp3.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:path/path.dart';
import '../common/shared.dart';
import 'dart:async';
import 'dart:io';
import 'timer.dart';

class Recorder extends StatefulWidget {
  @override
  _RecorderState createState() => _RecorderState();
}

class _RecorderState extends State<Recorder> {
  TimerController tController = Get.put(TimerController());
  Timer? timer;
  String statusText = "Start Recording", btnTxt = "Start";
  IconData btnIcon = Icons.play_arrow;
  bool isComplete = false, displayIndicator = false;
  double lowerValue = 0, upperValue = 0;
  double val = 0.0;
  int current = 1;
  int seconds = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bodyColor.value,
      appBar: AppBar(
        backgroundColor: bodyColor.value,
        leading:
            myIcon(Icons.arrow_back, mainColor.value, 25, () => Get.back()),
        title: txt('Recorder', txtColor.value, 21, true),
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        CircleAvatar(
          radius: Get.height * 0.16,
          backgroundColor: mainColor.value,
          child: CircleAvatar(
              radius: Get.height * 0.15,
              backgroundColor: boxColor.value,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  myIcon(Icons.mic, mainColor.value, 40, () {}),
                  Space(0, 15),
                  Obx(() =>
                      txt(tController.result.value, txtColor.value, 22, false)),
                ],
              )),
        ),
        txt(statusText, mainColor.value, 20, false),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            circleIcon(
                boxColor.value, txtColor.value, Icons.close, 22, "", false, () {
              stopRecord(true);
              tController.stopTimer();
            }),
            circleIcon(mainColor.value, Colors.white, btnIcon, 26, "", false,
                () => toggleRecord()),
            circleIcon(
                boxColor.value, txtColor.value, Icons.done, 22, "", false, () {
              stopRecord(false);
              tController.stopTimer();
              setState(() => isComplete = true);
            }),
          ],
        ),
        Column(
          children: [
            displayIndicator
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: Get.height * 0.05),
                    child: LinearPercentIndicator(
                      alignment: MainAxisAlignment.center,
                      width: Get.width * 0.8,
                      lineHeight: 10.0,
                      percent: val,
                      animation: true,
                      animationDuration: seconds,
                      animateFromLastPercent: true,
                      backgroundColor: Colors.grey,
                      progressColor: mainColor.value,
                    ),
                  )
                : Space(0, 0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Btn(Colors.transparent, Get.width * 0.36, 46,
                    txt("Play Record", mainColor.value, 20, false), true, () {
                  if (isComplete) {
                    seconds = tController.duration.value.inSeconds;
                    play();
                    timer = Timer.periodic(
                        Duration(seconds: 1), (timer) => increment());
                    setState(() => displayIndicator = true);
                  } else {
                    snackMsg("Make Record First");
                  }
                }),
                Space(Get.width * 0.02, 0),
                Btn(mainColor.value, Get.width * 0.36, 46,
                    txt("Send Record", Colors.white, 20, false), true, () {
                  isComplete ? uploadRecord() : snackMsg("Make Record First");
                }),
              ],
            ),
          ],
        )
      ]),
    );
  }

  increment() {
    if (seconds > 0 && current < seconds) {
      setState(() {
        current += 1;
        val = ((current / seconds * 100) / 100).toDouble();
      });
    } else {
      setState(() {
        timer?.cancel();
        current = 0;
        val = 0;
      });
    }
  }

  Future<bool> checkPermission() async {
    if (!await Permission.microphone.isGranted) {
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  void startRecord() async {
    bool hasPermission = await checkPermission();
    if (hasPermission) {
      recordFilePath = await getFilePath();
      isComplete = false;
      RecordMp3.instance.start(recordFilePath, (type) {
        statusText = "Record error--->$type";
      });
    } else {
      statusText = "No microphone permission";
    }
  }

  void stopRecord(bool cancel) {
    bool s = RecordMp3.instance.stop();
    tController.stopTimer();
    if (s) {
      if (cancel) recordFilePath = "";
      setState(() {
        statusText = cancel ? "Record Canceled" : "Record Completed";
        btnIcon = Icons.play_arrow;
      });
    }
  }

  void pauseRecord() {
    RecordMp3.instance.pause();
  }

  void resumeRecord() {
    RecordMp3.instance.resume();
  }

  void toggleRecord() {
    RecordStatus status = RecordMp3.instance.status;
    if (status == RecordStatus.RECORDING) {
      pauseRecord();
      tController.stopTimer(resets: false);
      setState(() {
        statusText = "Recording paused";
        btnIcon = Icons.stop;
        isComplete = true;
      });
    } else if (status == RecordStatus.PAUSE) {
      resumeRecord();
      tController.startTimer(resets: false);
      setState(() {
        statusText = "Recording...";
        btnIcon = Icons.pause;
      });
    } else {
      startRecord();
      tController.startTimer();
      setState(() {
        statusText = "Recording...";
        btnIcon = Icons.pause;
      });
    }
  }

  String recordFilePath = "";
  File file = File("");
  play() async {
    if (recordFilePath.isNotEmpty && File(recordFilePath).existsSync()) {
      AudioPlayer audioPlayer = AudioPlayer();
      await audioPlayer.play(recordFilePath, isLocal: true);
      setState(() => statusText = "Playing Record");
    }
  }

  uploadRecord() async {
    seconds = tController.duration.value.inSeconds;
    print("seconds $seconds");
    loadBox();
    String name = basename(recordFilePath);
    String url =
        await mainController.storeFile("audios", name, File(recordFilePath));
    if (url.isNotEmpty) {
      await chatController.createMsg("$seconds", url, "audio", "");
      Get.back();
    }
    Get.back();
  }

  Future<String> getFilePath() async {
    Directory storageDirectory = await getApplicationDocumentsDirectory();
    String sdPath = storageDirectory.path + "/record";
    var d = Directory(sdPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
    return sdPath + randomString(6) + ".mp3";
  }
}
