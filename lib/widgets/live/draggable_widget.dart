import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/auction_controller.dart';
import 'package:tokshop/controllers/room_controller.dart';
import 'package:tokshop/models/tokshow.dart';
import 'package:tokshop/utils/helpers.dart';

import '../../main.dart';
import '../../models/auction.dart';
import '../../pages/live/live_tokshows.dart';
import '../custom_button.dart';

class BiddingWidget extends StatelessWidget {
  Auction auction;
  Tokshow tokshow;
  BiddingWidget({super.key, required this.auction, required this.tokshow});
  AuctionController auctionController = Get.find<AuctionController>();

  @override
  Widget build(BuildContext context) {
    final double backgroundWidth = MediaQuery.of(context).size.width -
        32; // For example, screen width minus padding
    final double draggableWidth = 140;
    return SafeArea(
      bottom: true,
      top: false,
      child: Container(
        padding: EdgeInsets.only(top: 15),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Row(
          children: [
            InkWell(
              onTap: () {
                if ((authController.usermodel.value!.address == null ||
                        authController.usermodel.value!.defaultpaymentmethod ==
                            null) &&
                    checkOwner() == false) {
                  showAlert(context);
                  return;
                }
                _showBottomSheet(context);
              },
              child: Container(
                height: 48,
                width: 100.w,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: Text(
                  "custom".tr, // Translation Key
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'SchibstedGrotesk', // Custom font
                      fontSize: 12.sp),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Center(
                // Ensure centering, not full width of Expanded
                child: SizedBox(
                  width: backgroundWidth,
                  height: 48,
                  child: Obx(() {
                    return GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        final newPosition =
                            auctionController.dragPosition.value +
                                details.delta.dx;

                        auctionController.dragPosition.value =
                            newPosition.clamp(
                          0.0,
                          backgroundWidth - draggableWidth,
                        );
                      },
                      onHorizontalDragEnd: (details) {
                        auctionController.handleDragEnd(auction, context);
                      },
                      child: Stack(
                        clipBehavior: Clip.hardEdge, // Important!
                        alignment: Alignment.centerLeft,
                        children: [
                          // Background button (fills Container)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              ),
                            ),
                            alignment: Alignment.center,
                          ),
                          // Draggable button (Positioned)
                          Positioned(
                            left: auctionController.dragPosition.value,
                            child: Container(
                              height: 40,
                              width: draggableWidth,
                              margin: EdgeInsets.only(left: 4),
                              decoration: BoxDecoration(
                                color: auctionController.dragPosition.value >
                                        (backgroundWidth - draggableWidth) * 0.2
                                    ? Colors.white
                                    : Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "bid".trParams({
                                      "amount":
                                          priceHtmlFormat(auction.newbaseprice)
                                    }),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'SchibstedGrotesk',
                                        ),
                                  ),
                                  const SizedBox(width: 4),
                                  SvgPicture.asset(
                                    'assets/icons/double_arrow.svg',
                                    height: 30,
                                    width: 30,
                                    color: Colors.black,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context) {
    TokShowController tokShowController = Get.find<TokShowController>();
    AuctionController auctionController = Get.find<AuctionController>();
    Auction auction = tokShowController.currentRoom.value!.activeauction!;
    tokShowController.custombid.value =
        tokShowController.currentRoom.value!.activeauction!.baseprice;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    auction.product!.name!,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Spacer(),
                  Text(
                    priceHtmlFormat(
                        auctionController.winningCurrentPrice.value),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                  margin: const EdgeInsets.only(right: 15),
                  child: Obx(
                    () => Text(auctionController.formatedTimeString.value,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.red)),
                  )),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        tokShowController.custombid -= 1;
                        tokShowController.currentRoom.refresh();
                      },
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Colors.white),
                        child: Text(
                          "-",
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(color: Colors.black),
                        ),
                      ),
                    ),
                    Container(
                        margin: const EdgeInsets.only(right: 15),
                        child: Obx(
                          () => Text(
                              priceHtmlFormat(tokShowController.custombid),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 30)),
                        )),
                    InkWell(
                      onTap: () {
                        tokShowController.custombid += 1;
                        tokShowController.currentRoom.refresh();
                      },
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Colors.white),
                        child: Text(
                          "+",
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(color: Colors.black),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Max Bid",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                            "Turn this on if you would like us to do the bidding for you"),
                      ),
                      Obx(
                        () => Switch(
                            value: auctionController.autobid.value,
                            onChanged: (v) {
                              auctionController.autobid.value =
                                  !auctionController.autobid.value;
                            }),
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomButton(
                    function: () {
                      Get.back();
                    },
                    text: 'cancel'.tr,
                    backgroundColor:
                        Theme.of(context).colorScheme.onSecondaryContainer,
                    textColor: Theme.of(context).colorScheme.onSurface,
                  ),
                  CustomButton(
                    function: () {
                      auctionController.bid(tokShowController.custombid.value,
                          tokShowController.currentRoom.value!.activeauction!);
                      Get.back();
                    },
                    text: 'confirm'.tr,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    textColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
