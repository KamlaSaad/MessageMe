import 'dart:convert';
import 'package:chatting/main/profile_img.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:random_string/random_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../common/shared.dart';

class ChatController extends GetxController {
  ScrollController scrollController = ScrollController();
  CollectionReference chats = FirebaseFirestore.instance.collection("chats"),
      users = FirebaseFirestore.instance.collection("users");
  var isListReady = false.obs, isDataChanged = false.obs;
  final DatabaseReference messagesRef =
          FirebaseDatabase.instance.reference().child('messages'),
      reactRef = FirebaseDatabase.instance.reference().child('reacts');
  File imgFile = File(""), videoFile = File("");
  var msgKey = Key("").obs,
      replyMsg = {}.obs,
      showReplyBox = false.obs,
      showReactBox = false.obs,
      isSender = false.obs,
      chatKey = Key("list").obs,
      imgName,
      videoName,
      data = [],
      chatData = {}.obs,
      chatMembers = [].obs,
      chatId = "".obs,
      chatName = "".obs,
      chatImg = "".obs,
      chatBackground = "".obs,
      chatColor = Color(mainColor.value.value).obs,
      chatPhotos = [].obs,
      chatVideos = [].obs,
      Masseges = [].obs,
      msgReacts = [].obs;
  var queryMsg;
  @override
  void onInit() async {
    ever(chatData, (callback) {
      chatName.value = chatData['name'];
      chatColor.value = Color(chatData['mainColor']);
      chatBackground.value = chatData['background'];
      chatImg.value = chatData['img'];
      chatMembers.value = chatData['users'];

      print("======changed======");
    });
    isListReady.value = scrollController.hasClients;
    ever(isListReady, (_) {
      print(isListReady.value);
      isListReady.value = !isListReady.value;
      print(isListReady.value);
    });
    super.onInit();
  }

  //date time.................
  String date = "";
  dateTimeVal(int val) {
    return val < 10 ? "0$val" : "$val";
  }

  var h, m;

  void updateDateTime() {
    var now = DateTime.now();
    h = dateTimeVal(now.hour);
    m = dateTimeVal(now.minute);
    date = DateFormat('dd/MM/yyyy').format(now);
  }

  String msgDate(String mDate, String mTime) {
    var now = DateTime.now();
    String result = "", today = DateFormat('dd/MM/yyyy').format(now);
    DateTime msgDate = DateFormat('dd/MM/yyyy').parse(mDate),
        currentDate = DateFormat('dd/MM/yyyy').parse(today);
    var compare = currentDate.difference(msgDate).inDays;
    return compare == 0 ? mTime : (compare == 1 ? "Yesterday" : mDate);
  }

  void toggleReply(bool show, Map reply, bool sender) {
    showReplyBox.value = show;
    replyMsg.value = reply;
    isSender.value = sender;
  }

  Map defaultChatData(String name, String img, String type, List receivers) {
    Map defaultChat = {
      'id': "",
      'name': name,
      'img': img,
      'receivers': receivers,
      'mainColor': mainColor.value.value,
      'background': "",
      'type': type,
      'deletedFor': []
    };
    return defaultChat;
  }

  getContactChatData(List users) async {
    var chat;
    bool isCurrentUser = users[0] == mainController.userData['id'];
    var chatUsers = isCurrentUser ? users : users.reversed.toList();
    await chats.where("users", isEqualTo: chatUsers).get().then((value) {
      if (value.docs.length == 1) {
        var data = value.docs[0];
        chat = {
          "id": data.id,
          "background": data['background'],
          "mainColor": data['mainColor'],
          "users": data['users'],
          "type": data['type'],
        };
      }
    });
    return chat;
  }

  createMsg(
      String text, String url, String type, String userMentionedInHint) async {
    if (chatController.chatId.isEmpty) {
      String id = "";
      List friend = chatData['receivers'];
      id = await chatController
          .addChat("", mainColor.value, "", "", "chat", [myId, friend[0]]);
      if (id.isNotEmpty) {
        chatId.value = id;
        queryMsg.value = chatController.messagesRef
            .orderByChild("chatId")
            .equalTo(chatId.value);
        await addMsg(text, url, type, chatId.value, chatData['receivers'],
            userMentionedInHint);
        msgKey.value = Key(randomString(5));
        mainController.newChat.value = !mainController.newChat.value;
      }
      return id;
    } else {
      await addMsg(text, url, type, chatId.value, chatData['receivers'],
          userMentionedInHint);
    }
  }

  deleteChatFor(String id) async {
    await chatController.hideChatMessages(chatData['id']);
    mainController.changeHomeKey();
    Get.back();
    Get.back();
    Get.back();
  }

  removeChat(String id) async {
    var chat = await mainController.getChatOnline(chatData['id']);
    if (chat != null) {
      bool eq = mainController.arrEqual(chat['deletedFor'], chat['users']);
      print(eq);
      if (eq) {
        await chats.doc(id).delete();
        await removeChatMessages(chatData['id']);
        print("chat deleted ");
      }
    }
  }

  changeChatImg() async {
    List fileData =
        await mainController.uploadFile(true, ['jpg', 'png', 'jpeg', 'jif']);
    if (fileData.isNotEmpty) {
      Get.to(ProfileImgViewer(true, "upload".tr + "" + "photo".tr, fileData,
          () async {
        Get.back();
        print(fileData);
        loadBox();
        String url = await mainController.storeFile(
            "imgs", fileData[0]['name'], fileData[0]['file']);
        if (url.isNotEmpty) {
          chatImg.value = url;
          chatData['img'] = chatData['img'];
          await changeChatData("img", url);
          addMsg("changed chat picture", "", "hint", chatData['id'],
              chatMembers, "");
        }
      }));
      Get.back();
    }
  }

  changeBackground() async {
    List fileData =
        await mainController.uploadFile(false, ['jpg', 'png', 'jpeg']);
    if (fileData.isNotEmpty) {
      Get.to(ProfileImgViewer(true, "upload".tr + "" + "photo".tr, fileData,
          () async {
        Get.back();
        if (mainController.connected.value) {
          waiting(chatColor.value);
          String url = await mainController.storeFile(
              "imgs", fileData[0]['name'], fileData[0]['file']);
          if (url.isNotEmpty) {
            chatController.chatBackground.value = url;
            chatController.chatData['background'] = url;
            await chatController.changeChatData("background", url);
            addMsg("changed chat background", "", "hint", chatData['id'],
                chatMembers, "");
          }
        } else
          snackMsg("noNet".tr + " " + "tryAgain".tr);
        Get.back();
      }));
    }
  }

  changeChatName(String val) async {
    chatName.value = val;
    chatData.value = chatData.value;
    await chats.doc(chatData['id']).update({"name": val});
    mainController.changeHomeKey();
    addMsg("changed chat name", "", "hint", chatData['id'], chatMembers, "");
  }

  addMember(List members) async {
    print(chatMembers);
    if (members.isNotEmpty) {
      for (int i = 0; i < members.length; i++) chatMembers.add(members[i]);
      print(chatMembers);
      chatData['users'] = chatData['users'];
      await chats.doc(chatData['id']).update({"users": chatMembers});
      for (int i = 0; i < members.length; i++)
        addMsg("added ", "", "hint", chatData['id'], chatMembers, members[i]);
    }
  }

  deleteMember(String userId) async {
    chatMembers.remove(userId);
    chatData['users'] = chatData['users'];
    await chats.doc(chatData['id']).update({"users": chatData["users"]});
    addMsg("deleted ", "", "hint", chatData['id'], chatMembers, userId);
  }

  getMsgsLength(String chatId) async {
    int l = 0;
    bool deleted = false;
    Map chat = mainController.userChats
        .singleWhere((it) => it['id'] == chatId, orElse: () => {});
    if (chat.isNotEmpty) {
      await messagesRef
          .orderByChild("chatId")
          .equalTo(chatId)
          .once()
          .then((data) {
        if (data.value != null) {
          data.value.forEach((key, val) {
            deleted = mainController.msgDeleted(key);
            if (val['type'] != "hint" && !deleted) l++;
          });
        }
      });
    }
    return l;
  }

  getMessages(String chatId) async {
    List msgs = [];
    await messagesRef
        .orderByChild("chatId")
        .equalTo(chatId)
        .once()
        .then((data) {
      if (data.value != null) {
        data.value.forEach((key, val) {
          val['id'] = key;
          msgs.add(val);
        });
      }
    });
    return msgs;
  }

  removeChatMessages(String chatId) async {
    await messagesRef
        .orderByChild("chatId")
        .equalTo(chatId)
        .once()
        .then((data) {
      if (data.value != null) {
        data.value.forEach((key, val) {
          messagesRef.child(key).remove();
        });
      }
    });
  }

  hideChatMessages(String chatId) async {
    await messagesRef
        .orderByChild("chatId")
        .equalTo(chatId)
        .once()
        .then((data) {
      if (data.value != null) {
        data.value.forEach((key, val) async {
          print(key);
          await mainController.editField("deletedMsgs", key, true);
        });
      }
    });
  }

  getMessageById(String id) async {
    var msg;
    await messagesRef.orderByKey().equalTo(id).once().then((data) {
      if (data.value != null) {
        data.value.forEach((key, values) {
          values['id'] = key;
          msg = values;
          print(msg);
        });
      }
    });
    return msg;
  }

  getChatMedia(String type) async {
    var media = [];
    String id = "${chatData.value['id']}";
    await messagesRef.orderByChild('chatId').equalTo(id).once().then((data) {
      if (data.value != null) {
        data.value.forEach((key, values) {
          if (values['type'] == type) {
            media.add({
              "url": values['mediaUrl'],
              "caption": values['text'],
              "sender": values['senderId']
            });
          }
        });
      }
    });
    return media;
  }

  removerMsg(String id) async {
    await messagesRef.child(id).remove();
  }

  removerReact() async {
//    await reactRef.reference().remove();
    await reactRef
        .orderByChild("msgId")
        .equalTo("-MqW9_W6XsY9Fzb_2xdI")
        .reference()
        .remove();
  }

  editMsg(String id, String txt) async {
    await messagesRef.child(id).update({"text": txt});
  }

  removeAllMessages() {
    messagesRef.reference().remove();
  }

  getReacts(String msgId) async {
    List reacts = [];
    await reactRef.orderByChild("msgId").equalTo(msgId).once().then((data) {
      if (data.value != null) {
        data.value.forEach((key, val) {
          val['id'] = key;
          reacts.add(val);
        });
      }
    });
//    Timer(Duration(seconds: 1), () => null);
    return reacts;
  }

  reactMsg(String msgId, String reactTxt) async {
    var now = DateTime.now(),
        react = {
          "msgId": msgId,
          "person": myId,
          "react": reactTxt,
          "time": now.toString()
        };
    var allReacts = await getReacts(msgId);
    Map oldReact =
        allReacts.singleWhere((it) => it["person"] == myId, orElse: () => {});
    if (oldReact.isEmpty) {
      reactRef.push().set(react).asStream();
    } else {
      reactRef.child(oldReact['id']).update({"react": reactTxt});
    }
    msgKey.value = Key(randomString(5));
  }

  getLastMsg(String chatId) async {
    var msg;
    await messagesRef
        .orderByChild("chatId")
        .equalTo(chatId)
        .limitToLast(1)
        .once()
        .then((data) {
      if (data.value != null) {
        data.value.forEach((key, values) {
          values['id'] = key;
          msg = values;
        });
      }
    });
    return msg;
  }

  addMsg(String text, String url, String type, String chatId, var receivers,
      String userMentionedInHint) async {
    var now = DateTime.now().toString(),
        msg = {
          "text": text,
          "mediaUrl": url,
          "type": type,
          "status": "notSent",
          "senderId": myId,
//          "senderId": 'cvRpM64y9PSddzFlv2Nx',
          "reply": replyMsg.value,
          "receivers": receivers,
          "hintedUser": userMentionedInHint,
          "chatId": chatId,
          "date": now,
          "react": []
        };
    print(msg["reply"]);
    if (chatId.isNotEmpty) {
      await messagesRef.push().set(msg).asStream();
      toggleReply(false, {}, false);
      mainController.userChats.value = await mainController.getChats();
      mainController.changeHomeKey();
    }
  }

  listenNotifications() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        print('============Notification Message============');
        print(message.notification?.title);
        print(message.notification?.body);
        if ("${message.notification?.body}".contains("Call")) {
          Map call = {
            "type": message.notification?.body,
            "channel": message.data["channel"],
            "name": message.notification?.title
          };
          Get.toNamed("/comingCall", arguments: call);
        }
      }
    });
  }

  notify(String token, String title, String body, String channel) async {
    final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    await firebaseMessaging.requestPermission(
      sound: false,
      badge: false,
      alert: false,
      provisional: false,
    );
    String serverToken =
        "AAAAMSVmjMc:APA91bHsstboG1bIbEbnm1vf8Yyz6gbFfc7Iw70QF32TzRcmNMUH8e-NepM9OFHIdbu5eIaH2W97bNfhXH5JpsTJlXfBEQ4zgT_WffVx3LElnKZjFwJwIhITWNZYL8mqACXBKkskCton";
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverToken',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{
              'title': title,
              'body': body,
            },
            'priority': 'high',
            'data': <String, dynamic>{
              'channel': channel,
            },
            'to': token
          },
        ),
      );
      print("done");
    } catch (e) {
      print("error $e");
    }
  }

  addChat(
    String background,
    Color color,
    String name,
    String img,
    String type,
    users,
  ) async {
    DocumentReference chat = await chats.add({
      "background": background,
      "mainColor": color.value,
      "name": name,
      "img": img,
      "type": type,
      "users": users,
      "creator": myId,
    });
    if (chat.id.isNotEmpty) {
      mainController.userChats.value = await mainController.getChats();
      mainController.changeHomeKey();
    }
    return chat.id;
  }

  changeChatData(String field, val) async {
    await chats.doc(chatData['id']).update({field: val});
  }

  void scrollToBottom(ScrollController scrollC) {
    final position = scrollC.position.maxScrollExtent;
    scrollC.jumpTo(position);
  }

  void scrollToTop(ScrollController scrollC) {
    final position = scrollC.position.minScrollExtent;
    scrollC.jumpTo(position);
  }

  void changeChatKey() {
    chatKey.value = Key(randomString(5));
  }
}
