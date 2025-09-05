import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/socket_controller.dart';
import 'package:tokshop/main.dart';
import 'package:tokshop/models/giveaway.dart';

class GiveawayWidget extends StatelessWidget {
  GiveAway giveAway;
  GiveawayWidget({super.key, required this.giveAway}) {
    giveAwayController.startTimer(
        giveAway.duration ?? 0, giveAway.startedtime ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        giveAwayController.expanded.value = !giveAwayController.expanded.value;
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "giveaway".tr,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.card_giftcard, color: Colors.white, size: 25),
                SizedBox(width: 5),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      giveAway.participants.length.toString(),
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "entries_text".tr,
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            Obx(
              () => Text(
                giveAwayController.formatedTimeString.value,
                style: TextStyle(
                  color: Colors.yellow,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GiveawayExpandedWidget extends StatelessWidget {
  GiveAway giveAway;
  GiveawayExpandedWidget({super.key, required this.giveAway});
  SocketController socketController = Get.put(SocketController());
  @override
  Widget build(BuildContext context) {
    bool isFollowingHost = tokShowController.currentRoom.value!.owner?.followers
            .indexWhere((p) => p.id == authController.currentuser?.id) !=
        -1;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Obx(() => giveAwayController.findingwinner.isTrue
          ? Column(
              children: [
                Text(
                  "finding_winner".tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const CircularProgressIndicator(),
              ],
            )
          : tokShowController.currentRoom.value!.giveAway!.status == "ended"
              ? tokShowController.currentRoom.value!.giveAway!.winner != null
                  ? GiveawayWinnerWidget(
                      username: tokShowController
                              .currentRoom.value!.giveAway!.winner!.firstName ??
                          "",
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: Text(
                            "no_winner".tr,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(Icons.cancel_outlined, size: 20),
                          color: Colors.red,
                          onPressed: () =>
                              giveAwayController.expanded.value = false,
                        ),
                      ],
                    )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text(
                              "${giveAway.name} #${giveAwayController.giveawayslist.indexWhere((g) => g.id == giveAway.id)}" ??
                                  "",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Row(
                              children: [
                                SizedBox(width: 6),
                                Icon(Icons.card_giftcard,
                                    color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'entries'.trParams({
                                    "count":
                                        giveAway.participants.length.toString()
                                  }),
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            InkWell(
                              child: Icon(Icons.zoom_out_map,
                                  color: Colors.white, size: 20),
                              onTap: () {
                                giveAwayController.expanded.value = false;
                              },
                            ),
                            Obx(
                              () => Text(
                                giveAwayController.formatedTimeString.value,
                                style: TextStyle(
                                  color: Colors.yellow,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (giveAway.user?.id == authController.currentuser?.id)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: () {
                          giveAwayController.findingwinner.value = true;
                          socketController.endGiveaway(giveAway);
                        },
                        child: Text(
                          "end_giveaway".tr,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    if (giveAway.user?.id != authController.currentuser?.id)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 5),
                        ),
                        onPressed: () {
                          int? i = tokShowController
                              .currentRoom.value?.giveAway?.participants
                              .indexWhere((element) =>
                                  element.id == authController.currentuser?.id);
                          if (i != -1) {
                            return;
                          }

                          bool canEnter = false;
                          if (giveAway.whocanenter == "everyone") {
                            canEnter = true;
                          }
                          if (giveAway.whocanenter == "followers" &&
                              isFollowingHost == false) {
                            socketController.followUser();
                            canEnter = true;
                          } else {
                            canEnter = true;
                          }
                          if (canEnter) {
                            socketController.joinGiveaway(giveAway);
                            giveAwayController.expanded.value = false;
                          }
                        },
                        child: Text(
                          giveAway.whocanenter == "followers" &&
                                  isFollowingHost == false
                              ? 'follow_to_host_and_enter'.tr
                              : tokShowController.currentRoom.value?.giveAway
                                          ?.participants
                                          .indexWhere((p) =>
                                              p.id ==
                                              authController.currentuser?.id) ==
                                      -1
                                  ? "enter_giveaway".tr
                                  : "already_entered".tr,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                  ],
                )),
    );
  }
}

class GiveawayWinnerWidget extends StatelessWidget {
  final String username;

  const GiveawayWinnerWidget({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "giveaway_winner".tr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: "you_won".tr,
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CongratulationsBubbles extends StatefulWidget {
  const CongratulationsBubbles({super.key});

  @override
  State<CongratulationsBubbles> createState() => _CongratulationsBubblesState();
}

class _CongratulationsBubblesState extends State<CongratulationsBubbles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 5))
          ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: List.generate(15, (index) {
              final animationValue = _controller.value;
              final dx = _random.nextDouble() *
                  MediaQuery.of(context).size.width; // random x
              final dy = animationValue *
                  MediaQuery.of(context).size.height *
                  0.3; // move down

              return Positioned(
                top: dy,
                left: dx,
                child: Opacity(
                  opacity: 1 - animationValue,
                  child: Text(
                    index % 2 == 0 ? "🎉" : "🥳",
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
