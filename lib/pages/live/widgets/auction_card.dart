import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:tokshop/models/product.dart';
import 'package:tokshop/pages/inventory/add_edit_product_screen.dart';
import 'package:tokshop/pages/products/product_detail.dart';

import '../../../controllers/auction_controller.dart';
import '../../../controllers/room_controller.dart';
import '../../../controllers/socket_controller.dart';
import '../../../main.dart';
import '../../../utils/helpers.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/slogan_icon_card.dart';

class AuctionCard extends StatelessWidget {
  Product product;
  AuctionCard({super.key, required this.product});
  final TokShowController _tokshowcontroller = Get.find<TokShowController>();
  final AuctionController auctionController = Get.find<AuctionController>();
  final SocketController socketController = Get.find<SocketController>();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        productController.currentProduct.value = product;
        Get.to(() => ProductDetails(product: product));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 20),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  product.images?.isNotEmpty == true
                      ? CachedNetworkImage(
                          imageUrl: product.images!.first,
                          fit: BoxFit.cover,
                          width: 100,
                          height: 100,
                        )
                      : Image.asset(
                          'assets/images/image_placeholder.jpg',
                          fit: BoxFit.cover,
                          width: 100,
                          height: 100,
                        ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: InkWell(
                      onTap: () {
                        productController.addToFavorite(product);
                      },
                      child: Obx(() {
                        return CircleAvatar(
                          radius: 12,
                          backgroundColor: _check_bg(context),
                          child: Icon(
                            Icons.notifications_outlined,
                            size: 16,
                            color: check_color()
                                ? Colors.white
                                : Theme.of(context).colorScheme.primary,
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name!.capitalizeFirst ?? "",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold, fontSize: 12.sp),
                    maxLines: 2,
                  ),
                  Text(
                    "${"qty".tr} ${product.auction?.quantity} · ${product.productCategory == null ? "" : product.productCategory?.name}",
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(fontSize: 12.sp),
                  ),
                  Text(priceHtmlFormat(product.price),
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontSize: 12.sp)),
                  SizedBox(
                    height: 5,
                  ),
                  if (productController.liveactivetab.value == 0)
                    Text(
                      "${product.auction == null ? 0 : product.auction?.bids!.length.toString()} ${"bids".tr}",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 14.sp, fontWeight: FontWeight.normal),
                    ),
                  SizedBox(
                    height: 5,
                  ),
                  if (authController.usermodel.value!.id ==
                      _tokshowcontroller.currentRoom.value!.owner!.id)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomButton(
                          text: "start".tr,
                          function: () {
                            if (!_tokshowcontroller.checkDateGreaterthaNow(
                                _tokshowcontroller.currentRoom.value)) {
                              Get.snackbar(
                                  "sorry".tr, 'tokshow_not_live_yet'.tr,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white);
                              return;
                            }
                            auctionController.createAution(product, context);
                          },
                          borderRadius: 20,
                          height: 35,
                          width: 90.w,
                          fontSize: 14.sp,
                          textColor: Theme.of(context).colorScheme.onSurface,
                          backgroundColor:
                              Theme.of(context).colorScheme.secondaryContainer,
                        ),
                        InkWell(
                          splashColor: Colors.transparent,
                          child: Container(
                            height: 35,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer),
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Icon(Icons.more_horiz),
                          ),
                          onTap: () {
                            auction_actions(context);
                          },
                        ),
                        InkWell(
                          splashColor: Colors.transparent,
                          onTap: () {
                            socketController.pinAuction(null, context,
                                product: product,
                                tokshow: _tokshowcontroller.currentRoom.value);
                            Get.back();
                          },
                          child: Container(
                            height: 35,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: _tokshowcontroller
                                              .currentRoom.value!.pinned !=
                                          null &&
                                      _tokshowcontroller
                                              .currentRoom.value!.pinned!.id ==
                                          product.id
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer,
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: SvgPicture.asset("assets/icons/pin.svg"),
                          ),
                        ),
                      ],
                    ),
                  if (authController.usermodel.value!.id !=
                      _tokshowcontroller.currentRoom.value!.owner!.id)
                    CustomButton(
                      text: "preBid".tr,
                      function: () {
                        auctionController.prebidBottomSheet(context, product);
                      },
                      borderRadius: 20,
                      height: 35,
                      fontSize: 12.sp,
                      textColor: Theme.of(context).colorScheme.onSurface,
                      backgroundColor:
                          Theme.of(context).colorScheme.secondaryContainer,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool check_color() {
    return productController.roomallproducts.isNotEmpty &&
        productController
                .roomallproducts[productController.roomallproducts.indexWhere(
                            (element) => element.id == product.id) ==
                        -1
                    ? 0
                    : productController.roomallproducts
                        .indexWhere((element) => element.id == product.id)]
                .favorited
                ?.indexWhere((element) =>
                    element == FirebaseAuth.instance.currentUser!.uid) !=
            -1;
  }

  Color _check_bg(BuildContext context) {
    return check_color()
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.onPrimary;
  }

  void auction_actions(BuildContext context) {
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
                    productController.populateProductFields(product: product);
                    Get.to(() => AddEditProductScreen(
                          product: product,
                        ));
                  },
                ),
              if (FirebaseAuth.instance.currentUser!.uid ==
                  tokShowController.currentRoom.value?.owner!.id)
                SloganIconCard(
                  title: "delete".tr,
                  backgroundColor: Colors.transparent,
                  leftIcon: Icons.delete,
                  rightIcon: Icons.arrow_forward_ios_outlined,
                  function: () async {
                    int i = productController.roomallproducts
                        .indexWhere((p) => p.id == product.id);
                    productController.roomallproducts.removeAt(i);
                    productController.roomallproducts.refresh();
                    await productController.updateManyProducts(
                        [product.id], context, {'tokshow': null});
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
  }
}
