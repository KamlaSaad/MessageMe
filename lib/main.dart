// @dart=2.8
import 'package:chatting/pattern/check_pass.dart';
import 'package:chatting/pattern/check_pattern.dart';
import 'package:chatting/pattern/set_pass.dart';
import 'package:chatting/pattern/set_pattern.dart';
import 'package:chatting/sign/signup.dart';
import 'package:chatting/sign/verify.dart';
import 'package:chatting/story/story.dart';
import 'package:chatting/translate.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import 'call/audio_call.dart';
import 'call/video_call.dart';
import 'common/main_controller.dart';
import 'common/shared.dart';
import 'main/add-member.dart';
import 'main/add_group.dart';
import 'main/blocke_people.dart';
import 'main/chat.dart';
import 'main/chat_settings.dart';
import 'main/contacts.dart';
import 'main/home.dart';
import 'main/my_profile.dart';
import 'main/new_chat.dart';
import 'main/recorder.dart';
import 'main/settings.dart';
import 'main/user_profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
//  await GetStorage.init();
//  Get.;
  runApp(App());
}

MainController mainController = Get.put(MainController());

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      translations: Translate(),
      locale: Locale(mainController.lang.value),
      home: Direction(Home()),
      getPages: [
        GetPage(name: "/verify", page: () => VerifyUser()),
        GetPage(name: "/signup", page: () => SignUp()),
        GetPage(name: "/home", page: () => Home()),
        GetPage(name: "/contacts", page: () => Contacts()),
        GetPage(name: "/stories", page: () => Story()),
//        GetPage(name: "/storyViewer", page: () => StoryViewer()),
        GetPage(name: "/userProfile", page: () => UserProfile()),
        GetPage(name: "/myProfile", page: () => MyProfile()),
        GetPage(name: "/chat", page: () => Chat()),
        GetPage(name: "/chatSettings", page: () => ChatSettings()),
        GetPage(name: "/newChat", page: () => NewChat()),
        GetPage(name: "/newGroup", page: () => AddGroup()),
        GetPage(name: "/settings", page: () => Settings()),
        GetPage(name: "/addMember", page: () => AddMember()),
//        GetPage(name: "/filterPeople", page: () => FilterPeople()),
        GetPage(name: "/blockedPeople", page: () => BlockedPeople()),
        GetPage(name: "/recorder", page: () => Recorder()),
        GetPage(name: "/audioCall", page: () => AudioCallScreen()),
        GetPage(name: "/videoCall", page: () => VideoCall()),
        GetPage(name: "/setPattern", page: () => SetPattern()),
        GetPage(name: "/setPass", page: () => SetPass()),
        GetPage(name: "/checkPass", page: () => CheckPass()),
        GetPage(name: "/checkPattern", page: () => CheckPattern()),
//        GetPage(name: "/testCall", page: () => MyHomePage()),
      ],
    );
  }

  Widget DefaultPage() {
    if (mainController.user != null) {
      return Direction(VerifyUser());
    } else if (mainController.locked.value) {
      return mainController.lockPattern.isNotEmpty
          ? Direction(CheckPattern())
          : Direction(CheckPass());
    } else {
      return Direction(Home());
    }
  }
}
