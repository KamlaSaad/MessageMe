import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../common/shared.dart';

class RecordMsg extends StatefulWidget {
  int seconds;
  String url;
  RecordMsg(this.seconds, this.url);
  @override
  _RecordMsgState createState() => _RecordMsgState();
}

class _RecordMsgState extends State<RecordMsg> {
  Timer? timer;
  bool playing = false;
  int i = 0;
  double val = 0.0;
  IconData icon = Icons.play_arrow;
  Color color = Colors.grey;
  String current = "00:00", total = "";
  @override
  Widget build(BuildContext context) {
    total = total = duration(widget.seconds);
    double width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38,
              child: myIcon(icon, txtColor.value, 36, () async {
                toggleRecord();
                AudioPlayer audioPlayer = AudioPlayer();
                print(widget.url);
                if (playing) {
                  timer?.cancel();
                  audioPlayer.pause();
                } else {
                  await audioPlayer.play(widget.url);
                  setState(() {
                    i = 0;
                    i = 0;
                    val = 0;
                    current = "";
                  });
                  timer = Timer.periodic(
                      Duration(seconds: 1), (timer) => startTimer());
                }
                setState(() {
                  playing = !playing;
                  icon = playing ? Icons.pause : Icons.stop;
                });
              }),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  LinearPercentIndicator(
                    alignment: MainAxisAlignment.center,
                    width: width * 0.4,
                    lineHeight: 8.0,
                    percent: val,
                    animation: true,
                    animationDuration: widget.seconds,
                    animateFromLastPercent: true,
                    backgroundColor: Colors.grey,
                    progressColor: color,
                  ),
//                  AnimatedPositioned(
//                    duration: Duration(seconds: widget.seconds),
//                    left: i.toDouble(),
//                    child: Container(
//                      height: 14,
//                      width: 14,
//                      decoration: BoxDecoration(
//                          shape: BoxShape.circle, color: txtColor.value),
//                    ),
//                  ),
                ],
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            txt(current, txtColor.value, 16, false),
            txt(total, txtColor.value, 16, false),
          ],
        )
      ],
    );
  }

  startTimer() {
    setState(() {
      if (widget.seconds > 0 && i < widget.seconds) {
        i += 1;
        val = ((i / widget.seconds * 100) / 100).toDouble();
        current = duration(i);
        setState(() => color = mainColor.value);
      } else if (i == widget.seconds) {
        playing = false;
        setState(() => color = Colors.grey);
        icon = Icons.play_arrow;
        timer?.cancel();
      }
    });
  }

  toggleRecord() async {
    AudioPlayer audioPlayer = AudioPlayer();
    AudioPlayerState state = audioPlayer.state;
    print(state);
    if (state == AudioPlayerState.PLAYING) {
      timer?.cancel();
      audioPlayer.pause();
      setState(() => icon = Icons.stop);
    } else if (state == AudioPlayerState.PAUSED ||
        state == AudioPlayerState.STOPPED) {
      await audioPlayer.play(widget.url);
      timer = Timer.periodic(Duration(seconds: 1), (timer) => startTimer());
      setState(() => icon = Icons.pause);
    } else {
      timer?.cancel();
      setState(() => icon = Icons.play_arrow);
    }
  }
}
