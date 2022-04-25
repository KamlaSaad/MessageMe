import 'package:chatting/common/shared.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

var c = TextEditingController();

class VerifyUser extends StatelessWidget {
  VerifyController controller = Get.put(VerifyController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: bodyColor.value,
        body: ListView(padding: const EdgeInsets.all(12), children: [
          Stack(
            children: [
              backCircle(Get.height * 0.64),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Space(0, Get.height * 0.22),
                  txt("logo".tr, Colors.white, 35, true),
                  Space(0, Get.height * 0.12),
                  SizedBox(
                    width: Get.width * 0.9,
                    child: TxtInput(
                        "phone".tr,
                        "",
                        "",
                        false,
                        TextInputType.phone,
                        bodyColor.value,
                        Colors.transparent,
                        (val) => controller.phone.value = val),
                  ),
                  Space(0, Get.height * 0.06),
                  Btn(
                      bodyColor.value,
                      Get.width * 0.9,
                      56,
                      Obx(() => controller.loading.value
                          ? CircularProgressIndicator(color: mainColor.value)
                          : txt("confirm".tr, mainColor.value, 22, true)),
                      false, () async {
                    bool connected = await mainController.checkConnection();
                    connected
                        ? controller.verifyUser()
                        : snackMsg("failed".tr + " " + "tryAgain".tr);
                  }),
                ],
              )
            ],
          )
        ]));
  }
}

class VerifyController extends GetxController {
  var phone = "".obs,
      code = "".obs,
      loading = false.obs,
      loading2 = false.obs,
      connected = false.obs,
      phoneExist = false.obs;

  @override
  void onInit() async {
//    connected.value = await DataConnectionChecker().hasConnection;
    // TODO: implement onInit
    super.onInit();
  }

  verifyUser() async {
    if (phone.value != "") {
      loading.value = true;
      FirebaseAuth _auth = FirebaseAuth.instance;
      _auth.verifyPhoneNumber(
        phoneNumber: "+2${phone.value}",
        timeout: Duration(seconds: 100),
        verificationCompleted: (AuthCredential credential) {
          loading.value = false;
          print("credential $credential");
        },
        verificationFailed: (exception) {
          print(exception);
          loading.value = false;
          snackMsg("failed".tr + " " + "tryAgain".tr);
        },
        codeSent: (String verificationId, [int? forceResendingToken]) {
          loading.value = false;
          loading2.value = false;
          Get.defaultDialog(
            title: 'verify'.tr,
            titleStyle: TextStyle(color: mainColor.value, fontSize: 23),
            content: TxtInput("", "code".tr, "", false, TextInputType.number,
                txtColor.value, Colors.transparent, (val) => code.value = val),
//            contentPadding: const EdgeInsets.all(10),
            barrierDismissible: false,
            backgroundColor: bodyColor.value,
            actions: <Widget>[
              Btn(
                  Colors.transparent,
                  Get.width * 0.5,
                  56,
                  Obx(() => loading2.value
                      ? CircularProgressIndicator(
                          color: mainColor.value,
                        )
                      : txt("Done", txtColor.value, 20, false)),
                  false, () async {
                bool connected = await mainController.checkConnection();
                if (connected) {
                  loading2.value = true;
                  AuthCredential credential = PhoneAuthProvider.credential(
                      verificationId: verificationId,
                      smsCode: code.value.trim());
                  var result = await _auth.signInWithCredential(credential);
                  if (result.user != null) {
                    print("phoneExist ${phoneExist.value}");
                    var result = await mainController.hasAccount(phone.value);
                    phoneExist.value = result['phone'] != null ? true : false;
                    print("phoneExist ${phoneExist.value}");
                    if (phoneExist.value) {
                      updateToken();
                      Get.offAllNamed("/home");
                      mainController.getUser(myId);
                    } else {
                      Get.offAllNamed("/signup");
                    }
                    mainController.storageBox.write("phone", phone.value);
                  } else {
                    loading2.value = false;
                    print("Error");
                    Get.back();
                    snackMsg("failed".tr + " " + "tryAgain".tr);
                  }
                } else {
                  Get.back();
                  snackMsg("failed".tr + " " + "noNet".tr);
                }
              }),
            ],
          );
        },
        codeAutoRetrievalTimeout: (s) {
          print(s);
          loading.value = false;
          Get.back();
          snackMsg("failed".tr + " " + "tryAgain".tr);
        },
      );
    } else {
      snackMsg("err1".tr + " " + "enter".tr + " " + "phone".tr);
    }
  }

  updateToken() async {
    await mainController.users
        .doc(mainController.user?.uid)
        .update({"token": mainController.token});
  }
}
