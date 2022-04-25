import 'package:chatting/common/shared.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:random_string/random_string.dart';
import 'package:flutter/material.dart';
import "package:collection/collection.dart";
import 'package:get/get.dart';

class StoryController extends GetxController {
  var storiesDb = FirebaseFirestore.instance.collection("stories"),
      storyKey = Key("").obs,
      stories = [].obs,
      friendData = {},
      storyData = [].obs,
      storyViews = [].obs,
      storyId = "".obs;

  @override
  void onInit() async {
//    stories.value = await getAllStories();
    ever(storyId, (callback) async {
//      storyViews.value = await getStoryViews(storyId.value);
    });
    super.onInit();
  }

  dateTimeVal(int val) {
    return val < 10 ? "0$val" : "$val";
  }

  getAllStories() async {
    var data = [], newMap = {};
    await storiesDb.get().then((value) async {
      print("value ${value.docs[0].data()}");
      for (var i = 0; i < value.docs.length; i++) {
        Map d = value.docs[i].data();
        if (d.isNotEmpty) {
          var userData = mainController.getUser(d['senderId']);
          bool except = exceptStory(userData);
          if (!except) {
            String contactName =
                mainController.isContact("${userData['phone']}");
            if (userData.isNotEmpty) {
              var name =
                  contactName.isEmpty ? "${userData['username']}" : contactName;
              String img = mainController.getFriendImg(userData['imgUrl']);
              d['id'] = value.docs[i].id;
              d['name'] = name;
              d['img'] = img;
              d['time'] = mainController.convertDate(d['date']);
              data.add(d);
              stories.add(d);
            }
          }
        }
      }
    });
    newMap = groupBy(data, (dynamic obj) => obj["senderId"]);
    return newMap;
  }

  exceptStory(Map user) {
    bool except = false;
//    print("user $user");
    String sP = user['storyPrivacy'];
    List sEx = user['storyExceptions'], contacts = user['contacts'];
    print("${user['username']} Privacy $sP");
    if (sP == "public") {
      except = false;
      print("post");
    } else if (sP == "contacts") {
      String exist = contacts.singleWhere((x) => x == myId, orElse: () => "");
      except = exist.isEmpty;
    } else {
      String excepted = sEx.singleWhere((x) => x == myId, orElse: () => "");
      except = excepted.isNotEmpty;
    }
    return except;
  }

  getUserStories() async {
    var data;
    data = stories.length > 0 ? stories.value : await getAllStories();
    print("stories.length ${stories.length}");
    Map newMap = groupBy(data, (dynamic obj) => obj["senderId"]);
    return newMap;
  }

  getStoryId() async {
    String id = "";
    await storiesDb
        .where('senderId', isEqualTo: "${mainController.user?.uid}")
        .get()
        .then((value) {
      id = value.docs.length == 1 ? value.docs[0].id : "";
    });
    return id;
  }

  addStory(String type, String text, String mediaUrl, String mediaName,
      Color backgroundColor, Color textColor) async {
    var now = DateTime.now(),
        story = {
          "type": type,
          "date": now.toString(),
          "text": text,
          "mediaUrl": mediaUrl,
          "mediaName": mediaName,
          "backgroundColor": backgroundColor.value,
          "textColor": textColor.value,
          "views": [],
//          "senderId": "1vkf1MmKFpAvJ01RhSdU",
          "senderId": myId,
        };
    await storiesDb.add(story);
    storyKey.value = Key(randomString(5));
  }

  addView(String id, Map react) async {
    await storiesDb.doc(id).set({
      "views": FieldValue.arrayUnion([react])
    }, SetOptions(merge: true));
  }

  viewStory(String id, String reactTxt) async {
    var now = DateTime.now(),
        react = {"viewerId": myId, "react": reactTxt, "date": now.toString()};
    await storiesDb.doc(id).get().then((value) async {
      List views = value['views'];
      if (views.isNotEmpty) {
        Map view =
            views.singleWhere((it) => it['viewerId'] == myId, orElse: () => {});
        if (view.isEmpty) {
          await addView(id, react);
        } else {
          if (reactTxt.isNotEmpty) {
            view['react'] = reactTxt;
            views.removeWhere((element) => element['viewerId'] == myId);
            views.add(view);
            await storiesDb.doc(id).update({"views": views});
          }
        }
      } else {
        await addView(id, react);
      }
    });
    await getAllStories();
  }

  deleteStory(String id) async {
    await storiesDb.doc(id).delete();
//    await getAllStories();
    storyKey.value = Key(randomString(5));
  }

  editStoryTxt(String id, String val) async {
    await storiesDb.doc(id).set({"text": val}, SetOptions(merge: true));
    storyKey.value = Key(randomString(5));
  }

  timeFinish(String d) {
    bool finish = false;
    DateTime now = DateTime.now(), date = DateTime.parse(d);
    finish = date.difference(now).inDays == 1 ? true : false;
    return finish;
  }
}
