import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:tokshop/controllers/room_controller.dart';

import '../../../main.dart';
import '../../../widgets/slogan_icon_card.dart';
import '../new_tokshow.dart';
import 'auction_store_widget.dart';

class LiveActions extends StatelessWidget {
  LiveActions({super.key});
  TokShowController tokShowController = Get.find<TokShowController>();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 8),
        if (tokShowController.currentRoom.value?.owner?.id ==
                authController.currentuser?.id &&
            !tokShowController
                .checkDateGreaterthaNow(tokShowController.currentRoom.value))
          InkWell(
            onTap: () async {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Theme.of(context).colorScheme.surface,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (BuildContext context) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (FirebaseAuth.instance.currentUser!.uid ==
                            tokShowController.currentRoom.value?.owner!.id)
                          SloganIconCard(
                            title: "edit".tr,
                            leftIcon: Icons.edit,
                            backgroundColor: Colors.transparent,
                            rightIcon: Icons.arrow_forward_ios_outlined,
                            function: () {
                              Get.back();
                              Get.to(() => NewTokshow(
                                  roomModel:
                                      tokShowController.currentRoom.value));
                            },
                          ),
                        if (FirebaseAuth.instance.currentUser!.uid ==
                            tokShowController.currentRoom.value?.owner!.id)
                          SloganIconCard(
                            title: "delete".tr,
                            backgroundColor: Colors.transparent,
                            leftIcon: Icons.delete,
                            rightIcon: Icons.arrow_forward_ios_outlined,
                            function: () {
                              Get.back();
                            },
                            titleStyle: TextStyle(
                                color: Colors.red,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          )
                      ],
                    ),
                  );
                },
              );
            },
            child: Column(
              children: [
                Icon(
                  Icons.more_horiz,
                  color: Colors.white,
                  size: 28,
                ),
                Text(
                  'more'.tr,
                  style: TextStyle(color: Colors.white, fontSize: 10.sp),
                )
              ],
            ),
          ),
        SizedBox(height: 8),
        if (tokShowController.currentRoom.value?.owner?.id ==
                authController.currentuser?.id &&
            tokShowController.currentRoom.value?.started == true)
          InkWell(
            onTap: () async {
              await tokShowController.switchCamera();
            },
            child: Column(
              children: [
                Icon(
                  Icons.switch_camera_outlined,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  'switch'.tr,
                  style: TextStyle(color: Colors.white, fontSize: 10.sp),
                )
              ],
            ),
          ),
        SizedBox(height: 8),
        InkWell(
          onTap: () async {
            await tokShowController
                .muteUnMute(tokShowController.audioMuted.value);
          },
          child: Obx(
            () => Column(
              children: [
                Icon(
                  tokShowController.audioMuted.isFalse
                      ? Ionicons.mic
                      : Ionicons.mic_off,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  tokShowController.audioMuted.isFalse
                      ? 'mute'.tr
                      : 'unmute'.tr,
                  style: TextStyle(color: Colors.white, fontSize: 10.sp),
                )
              ],
            ),
          ),
        ),
        SizedBox(height: 8),
        InkWell(
          splashColor: Colors.transparent,
          onTap: () {
            tokShowController.shareTokshow();
          },
          child: Center(
            child: Column(
              children: [
                SvgPicture.asset(
                  width: 28,
                  "assets/icons/share_icon.svg",
                  color: Colors.white,
                ),
                SizedBox(
                  height: 5,
                ),
                Text("Share", style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
        SizedBox(height: 10),
        // Heart Button
        InkWell(
          onTap: () {
            Get.to(() => AuctionStoreWidget());
          },
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1,
                      ),
                    ),
                    child: Center(
                        child: Icon(
                      Icons.store_rounded,
                      color: Colors.white,
                      size: 25,
                    )),
                  ),
                  Positioned(
                    right: -4,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: Colors.white),
                      child: Text(
                        productController.roomallproducts.length.toString(),
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(color: Colors.black, fontSize: 11.sp),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                "shop".tr,
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
