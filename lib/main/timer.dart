import 'package:get/get.dart';
import 'dart:async';
import '../common/shared.dart';

class TimerController extends GetxController {
  Timer? timer;
  var duration = Duration().obs, result = "00:00".obs;
  @override
  void onInit() {
    stopTimer(resets: true);
    ever(duration,
        (callback) => result.value = duration.toString().substring(2, 7));
  }

  reset() {
    duration.value = Duration();
  }

  void addTime() {
    final addSeconds = 1;
    final seconds = duration.value.inSeconds + addSeconds;
    if (seconds < 0) {
      timer?.cancel();
    } else {
      duration.value = Duration(seconds: seconds);
    }
  }

  void startTimer({bool resets = true}) {
    if (resets) reset();
    timer = Timer.periodic(Duration(seconds: 1), (_) => addTime());
  }

  void stopTimer({bool resets = true}) {
    if (resets) reset();
    timer?.cancel();
  }
}
