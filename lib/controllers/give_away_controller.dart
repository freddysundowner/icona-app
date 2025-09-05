import 'dart:async';

import 'package:get/get.dart';
import 'package:tokshop/services/give_away_api.dart';

import '../models/giveaway.dart';

class GiveAwayController extends GetxController {
  RxList<GiveAway> giveawayslist = RxList([]);
  RxString whocanenter = "everyone".obs;
  var loadinggiveaways = false.obs;
  RxString giveawayid = "".obs;
  var findingwinner = false.obs;
  var loadinggiveaway = false.obs;
  var expanded = false.obs;
  Rxn<GiveAway> giveaway = Rxn<GiveAway>(GiveAway());
  Timer? timer;

  RxString formatedTimeString = "00:00".obs;
  Timer? _timer;

  isTimeRemaining(GiveAway giveaway) {
    if (giveaway.duration != null) {
      DateTime started =
          DateTime.tryParse(giveaway.startedtime!) ?? DateTime.now();
      DateTime endTime = started.add(Duration(seconds: giveaway.duration!));
      DateTime now = DateTime.now();
      if (giveaway.status == "ended") {
        return false;
      }
      if (now.isAfter(endTime)) {
        return false;
      } else {
        return true;
      }
    } else {
      return false;
    }
  }

  void startTimer(int durationInSeconds, String startedTime) {
    _timer?.cancel(); // stop old timer if running

    DateTime started = DateTime.tryParse(startedTime) ?? DateTime.now();
    DateTime endTime = started.add(Duration(seconds: durationInSeconds));

    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      final remaining = endTime.difference(DateTime.now());
      if (remaining.isNegative) {
        formatedTimeString.value = "00:00";
        _timer?.cancel();
      } else {
        formatedTimeString.value = _formatDuration(remaining);
      }
    });
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  getGiveAways(
      {String userId = "",
      String status = "active",
      String name = "",
      String room = ""}) async {
    try {
      loadinggiveaways.value = true;
      var response = await GiveAwayApi.getGiveAways(name: name, room: room);
      loadinggiveaways.value = false;
      List list = response["giveaways"];
      List<GiveAway> giveaways = list.map((e) => GiveAway.fromJson(e)).toList();
      giveawayslist.value = giveaways;
    } catch (e) {
      print(e);
    }
  }

  // void startTimer(int duration) {
  //   const oneSec = Duration(seconds: 1);
  //   timer = Timer.periodic(
  //     oneSec,
  //     (Timer timer) {
  //       if (duration <= 0) {
  //         formatedTimeString.value = formatedTime(timeInSecond: 0);
  //         timer.cancel();
  //       } else {
  //         formatedTimeString.value = formatedTime(timeInSecond: duration--);
  //         formatedTimeString.refresh();
  //       }
  //       print("formatedTimeString $formatedTimeString");
  //     },
  //   );
  // }
  //
  // formatedTime({required int timeInSecond}) {
  //   int sec = timeInSecond % 60;
  //   int min = (timeInSecond / 60).floor();
  //   String minute = min.toString().length <= 1 ? "0$min" : "$min";
  //   String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
  //   return "$minute : $second";
  // }

  void getGiveAwayById(GiveAway giveAway) async {
    try {
      loadinggiveaway.value = true;
      var response = await GiveAwayApi.getGiveAwayById(giveAway.id);
      loadinggiveaway.value = false;
      giveaway.value = GiveAway.fromJson(response);
    } catch (e) {
      print(e);
    }
  }

  deleteGiveAway(String s) async {
    try {
      var response = await GiveAwayApi.deleteGiveAway(s);
    } catch (e) {
      print(e);
    }
  }
}
