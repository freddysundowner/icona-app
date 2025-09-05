import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/auction_controller.dart';
import 'package:tokshop/controllers/room_controller.dart';
import 'package:tokshop/main.dart';
import 'package:tokshop/pages/products/product_detail.dart';
import 'package:tokshop/utils/helpers.dart';

import '../../models/auction.dart';
import '../../models/tokshow.dart';

class AuctionProductWidget extends StatelessWidget {
  Auction auction;
  Tokshow tokshow;

  AuctionProductWidget(
      {super.key, required this.auction, required this.tokshow}) {}
  AuctionController auctionController = Get.find<AuctionController>();
  TokShowController tokShowController = Get.find<TokShowController>();
  showWinningWidget() {
    return Obx(() =>
        tokShowController.currentRoom.value?.activeauction!.winning == null
            ? SizedBox.shrink()
            : Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: tokShowController.currentRoom.value
                              ?.activeauction!.winning!.profilePhoto ??
                          "",
                      fit: BoxFit.contain,
                      width: 18,
                      height: 18,
                      placeholder: (context, url) => Center(
                        child:
                            CircularProgressIndicator(), // Placeholder while loading
                      ),
                      errorWidget: (context, url, error) => Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Icon(
                          Icons.person,
                          color: Colors.grey,
                        ),
                      ), // Error icon
                    ),
                  ),
                  SizedBox(
                    width: 3,
                  ),
                  Text(
                    tokShowController.currentRoom.value!.activeauction!.winning!
                            .firstName ??
                        "",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Theme.of(Get.context!).primaryColor),
                  ),
                  Text(
                    " winning".tr,
                    style: TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  )
                ],
              ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          showWinningWidget(),
          SizedBox(
            height: 5,
          ),
          InkWell(
            onTap: () {
              Get.to(() => ProductDetails(product: auction.product!));
            },
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: auction.product!.images!.isEmpty
                      ? Image.asset(
                          "assets/images/image_placeholder.jpg",
                          fit: BoxFit.cover,
                          width: 60,
                          height: 60,
                        )
                      : CachedNetworkImage(
                          imageUrl: auction.product!.images!.first,
                          fit: BoxFit.cover,
                          width: 60,
                          height: 60,
                          placeholder: (context, url) => Center(
                            child:
                                CircularProgressIndicator(), // Placeholder while loading
                          ),
                          errorWidget: (context, url, error) => Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: Icon(
                              Icons.person,
                              color: Colors.grey,
                            ),
                          ), // Error icon
                        ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auction.product!.name!.capitalizeFirst ?? "",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                                color: Theme.of(context).colorScheme.surface),
                        maxLines: 1,
                      ),
                      if (auction.product!.productCategory != null)
                        Text(
                          auction.product!.productCategory!.name!
                                  .capitalizeFirst ??
                              "",
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.surface),
                        ),
                      Obx(() => Text(
                            "${priceHtmlFormat(shippingController.shippingEstimate["amount"])} ${'shipping'.tr} + tax",
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.surface),
                          ))
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      priceHtmlFormat(auction.baseprice),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Theme.of(context).colorScheme.surface),
                    ),
                    Obx(() {
                      final activeAuction =
                          tokShowController.currentRoom.value?.activeauction;
                      final time = auctionController.formatedTimeString.value;

                      if (activeAuction == null ||
                          !auctionController.isAuctionActive(activeAuction)) {
                        return Text("sold".tr,
                            style: TextStyle(color: Colors.deepOrange));
                      }

                      if (activeAuction.started == true &&
                          activeAuction.ended == false) {
                        return Text(time,
                            style: TextStyle(color: Colors.deepOrange));
                      }

                      return SizedBox.shrink();
                    })
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
