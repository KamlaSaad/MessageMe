import "package:agora_rtc_engine/rtc_local_view.dart" as RtcLocalView;
import "package:agora_rtc_engine/rtc_remote_view.dart" as RtcRemoteView;
import 'package:chatting/common/shared.dart';
import 'package:chatting/main/timer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:get/get.dart';
import 'dart:async';

class CallController extends GetxController {
  CollectionReference calls = FirebaseFirestore.instance.collection("calls");
  String appId = "6771f37375c543c98b3a6e0ae4f0e3f7";
  late TimerController tc;
  static final _users = <int>[];
  late RtcEngine _engine;
  var waitTimer = Timer(Duration(seconds: 0), () => {}).obs,
      callTimer = TimerController().obs,
      channelName = "".obs,
      muted = false.obs,
      calling = false.obs,
      callName = "".obs,
      callImg = "".obs,
      chatId = "".obs,
      callType = "".obs,
      callId = "".obs,
      users = [].obs,
      callerId = "".obs,
      receivers = [].obs,
      remoteUid = 0.obs,
      localUid = 0.obs,
      i = 0.obs;

  @override
  void onInit() async {
    super.onInit();
    ever(calling, (callback) {
      if (calling.value) {
        tc = TimerController();
        tc.startTimer();
      } else {
        tc.stopTimer();
      }
    });
  }

  void incrementWaitTimer() {
    if (remoteUid.value != 0) {
      waitTimer.value.cancel();
      calling.value = true;
    } else if (i.value < 60 && remoteUid.value == 0) {
      i.value++;
    } else {
      leaveCall();
      chatController.addMsg("Missed ${callType.value} call", "", "call",
          chatId.value, users.value, "");
    }
  }

  joinCall() async {
    await _engine.joinChannel(null, channelName.value, null, 0);
  }

  leaveCall() async {
    _users.clear();
    waitTimer.value.cancel();
    callTimer.value.stopTimer(resets: true);
    _engine.leaveChannel();
    _engine.destroy();
    Get.back();
    print("=====left chall=====");
    await deleteCall();
  }

  Future<void> initCall(String type, List receivers) async {
    bool audio = type == "Audio";
    _engine = await RtcEngine.create(appId);
    audio ? await _engine.enableAudio() : await _engine.enableVideo();
    channelName.value = Uuid().v4();
    callType.value = type;
    users.value = receivers;
    await addAgoraEventHandlers();
    String token = await FirebaseMessaging.instance.getToken() ?? "";
    await chatController.notify(
        token, "Fatma Alaa", "$type Call", channelName.value);
    await joinCall();
//    await addCallDoc();
  }

  addAgoraEventHandlers() async {
    _engine.setEventHandler(RtcEngineEventHandler(
      error: (code) {
        print("Error: $code");
      },
      joinChannelSuccess: (channel, uid, elapsed) {
        users.add(myId);
        localUid.value = uid;
        print("==============sucess===============");
        print('onJoinChannel: $channel, uid: $uid');
        waitTimer.value = Timer.periodic(
            Duration(seconds: 1), (timer) => incrementWaitTimer());
      },
      leaveChannel: (stats) {
        print("==============left channel===============");
        _users.clear();
      },
      userJoined: (uid, elapsed) {
        print('userJoined: $uid');
        _users.add(uid);
      },
      userOffline: (uid, reason) {
        print('========userOffline: $uid , reason: $reason=======');
        _users.remove(uid);
      },
      connectionLost: () async => await leaveCall(),
      firstRemoteVideoFrame: (uid, width, height, elapsed) {
        print('firstRemoteVideoFrame: $uid');
      },
    ));
  }

  addCallDoc() async {
    var result = await calls.add({
      "channel": channelName.value,
      "type": callType.value,
      "callerId": myId,
      "receivers": users,
    });
    callId.value = result.id;
    print("added call ${result.id}");
  }

  setRemoteUid(int uid) async {
    await calls.doc(callId.value).update({"receiverUid": uid});
  }

  deleteCall() async {
    await calls.doc(callId.value).delete();
  }

  getCallById(String id) async {
    Map call = {};
    calls.doc(id).get().then((value) {
      print(value.data());
    });
  }

  void toggleMute() {
    muted.value = !muted.value;
    _engine.muteLocalAudioStream(muted.value);
  }

  void switchCamera() {
    _engine.switchCamera();
  }

  //current User View
  Widget LocalView() {
    return RtcLocalView.SurfaceView();
  }

//remote User View
  Widget RemoteView(int uid) {
    return uid != 0
        ? RtcRemoteView.SurfaceView(uid: uid)
        : Center(child: txt("Calling …", mainColor.value, 22, true));
  }
}
