import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/auction_controller.dart';
import 'package:tokshop/controllers/give_away_controller.dart';
import 'package:tokshop/controllers/order_controller.dart';
import 'package:tokshop/controllers/socket_controller.dart';
import 'package:tokshop/main.dart';
import 'package:tokshop/models/giveaway.dart';
import 'package:tokshop/pages/activities/order_details_page.dart';
import 'package:tokshop/pages/activities/purchase_details.dart';
import 'package:tokshop/pages/inventory/add_edit_product_screen.dart';
import 'package:tokshop/pages/inventory/my_inventory.dart';
import 'package:tokshop/pages/products/give_away_details.dart';
import 'package:tokshop/utils/helpers.dart';
import 'package:tokshop/widgets/search_layout.dart';

import '../../../controllers/room_controller.dart';
import '../../../models/order.dart';
import '../../../models/product.dart';
import '../../../widgets/bottom_sheet_dialog.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/live/no_items.dart';
import '../../../widgets/show_image.dart';
import '../../../widgets/slogan_icon_card.dart';
import '../../products/product_detail.dart';
import '../../profile/tip/send_tip.dart';
import '../../profile/view_profile.dart';
import '../sold_giveaway_details.dart';
import '../sold_order_details.dart';
import 'auction_card.dart';

class AuctionStoreWidget extends StatelessWidget {
  AuctionStoreWidget({super.key}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (productController.liveactivetab.value == 0) {
        productController.productTab.value == "auction";
        productController.getAllroducts(
            roomid: tokshowcontroller.currentRoom.value!.id!,
            type: "room",
            saletype: "auction",
            status: 'active');
      } else if (productController.liveactivetab.value == 1) {
        productController.productTab.value == "buy_now";
        productController.getAllroducts(
            saletype: "buy_now",
            roomid: tokshowcontroller.currentRoom.value!.id!,
            type: "room");
      } else if (productController.liveactivetab.value == 2) {
        productController.productTab.value == "give_away";
        giveAwayController.getGiveAways(
          userId: tokshowcontroller.currentRoom.value!.owner!.id!,
          room: tokshowcontroller.currentRoom.value!.id!,
        );
      } else if (productController.liveactivetab.value == 3) {
        productController.productTab.value == "order";
        orderController.getOrders(
          userId: tokshowcontroller.currentRoom.value!.owner!.id!,
          tokshow: tokshowcontroller.currentRoom.value!.id!,
        );
      }
    });
  }
  final TokShowController tokshowcontroller = Get.find<TokShowController>();
  final GiveAwayController giveAwayController = Get.find<GiveAwayController>();
  final OrderController orderController = Get.find<OrderController>();
  final AuctionController auctionController = Get.find<AuctionController>();
  final SocketController socketController = Get.find<SocketController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "sellerLiveShop".trParams({
                      "seller":
                          tokshowcontroller.currentRoom.value!.owner!.firstName!
                    }),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close,
                        color: Theme.of(context).iconTheme.color),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Search Bar
              SearchLayout(
                function: (v) {
                  if (productController.liveactivetab.value == 0) {
                    productController.productTab.value = "auction";
                    auctionController.getAllAuctions(
                      roomId: tokshowcontroller.currentRoom.value!.id!,
                    );
                  } else if (productController.liveactivetab.value == 1) {
                    productController.productTab.value = "buy_now";
                    productController.getAllroducts(
                      saletype: productController.productTab.value,
                      type: 'room',
                      roomid: productController.productTab.value == 'auction' ||
                              productController.productTab.value == 'offers'
                          ? tokshowcontroller.currentRoom.value!.id!
                          : "",
                      userid: tokshowcontroller.currentRoom.value!.owner!.id!,
                      title: v,
                    );
                  } else if (productController.liveactivetab.value == 2) {
                    productController.productTab.value = "giveaway";
                  } else if (productController.liveactivetab.value == 3) {
                    productController.productTab.value = "offers";
                  }
                },
                margin: EdgeInsets.zero,
                padding: EdgeInsets.zero,
              ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterTab(context, "auction".tr, 0, (i) {
                    productController.productTab.value = "auction";
                    productController.getAllroducts(
                      saletype: "auction",
                      roomid: tokshowcontroller.currentRoom.value!.id!,
                      type: "room",
                    );
                  }),
                  SizedBox(
                    width: 20,
                  ),
                  _buildFilterTab(context, "buyItNow".tr, 1, (i) {
                    productController.productTab.value = "buy_now";
                    productController.getAllroducts(
                        saletype: "buy_now",
                        type: "room",
                        roomid: tokshowcontroller.currentRoom.value!.id!);
                  }),
                  SizedBox(
                    width: 20,
                  ),
                  _buildFilterTab(context, "giveaway".tr, 2, (i) {
                    productController.productTab.value = "giveaway";
                    giveAwayController.getGiveAways(
                        room: tokshowcontroller.currentRoom.value!.id!);
                  }),
                  SizedBox(
                    width: 20,
                  ),
                  _buildFilterTab(context, "sold".tr, 3, (i) {
                    productController.productTab.value = "sold";
                    orderController.getOrders(
                        tokshow: tokshowcontroller.currentRoom.value!.id!);
                  })
                ],
              ),
              const SizedBox(height: 16),
              if (productController.liveactivetab.value == 0)
                Expanded(child: _buildAuction(context)),
              if (productController.liveactivetab.value == 1)
                Expanded(child: _buildProductItem(context)),
              if (productController.liveactivetab.value == 2)
                Expanded(child: _buildGiveawayItem(context)),
              if (productController.liveactivetab.value == 3)
                Expanded(child: _buildSoldItem(context)),

              if (tokshowcontroller.currentRoom.value?.owner!.id !=
                  FirebaseAuth.instance.currentUser!.uid)
                Row(
                  children: [
                    ShowImage(
                      image: tokshowcontroller
                          .currentRoom.value!.owner!.profilePhoto!,
                      width: 30,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tokshowcontroller
                                    .currentRoom.value!.owner!.firstName ??
                                "",
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          if (tokshowcontroller
                              .currentRoom.value!.owner!.bio!.isNotEmpty)
                            Text(
                              tokshowcontroller.currentRoom.value!.owner!.bio ??
                                  "",
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    CustomButton(
                      function: () {
                        Get.to(() => TipScreen(
                            user: tokshowcontroller.currentRoom.value!.owner!));
                      },
                      text: 'send_tip'.tr,
                      backgroundColor: Colors.transparent,
                      height: 50,
                      borderColor: Colors.grey.withValues(alpha: 0.2),
                      iconData: Icons.card_giftcard_outlined,
                      iconColor: Colors.white,
                      borderRadius: 10,
                    )
                  ],
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: Obx(() => authController.currentuser!.id !=
                  tokshowcontroller.currentRoom.value!.owner!.id ||
              productController.productTab.value == "sold"
          ? SizedBox.shrink()
          : FloatingActionButton(
              child: Icon(
                Icons.add,
                color: Theme.of(context).colorScheme.surface,
              ),
              onPressed: () {
                showFilterBottomSheet(
                    context,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        SloganIconCard(
                          leftIcon: Icons.local_offer,
                          title: 'create_a_product'.tr,
                          backgroundColor: Colors.transparent,
                          titleStyle: TextStyle(fontSize: 21),
                          function: () {
                            Get.back();
                            productController.clearProductFields();
                            Get.to(() => AddEditProductScreen(
                                  product: null,
                                  from: "room",
                                  giveaway: null,
                                ));
                          },
                        ),
                        SizedBox(height: 8),
                        SloganIconCard(
                          leftIcon: Icons.import_export,
                          title: 'import_from_inventory'.tr,
                          backgroundColor: Colors.transparent,
                          titleStyle: TextStyle(fontSize: 21),
                          function: () {
                            Get.back();
                            Get.to(() => MyInventory(
                                  from: 'create_show',
                                  function: () async {
                                    String type =
                                        productController.liveactivetab.value ==
                                                0
                                            ? "auction"
                                            : "buy_now";
                                    String? roomId =
                                        tokshowcontroller.currentRoom.value!.id;
                                    productController.updateManyProducts(
                                        productController
                                            .inventorySelectedProducts
                                            .map((p) => p.id)
                                            .toList(),
                                        context,
                                        {
                                          "tokshow": roomId,
                                          "listing_type": type
                                        });

                                    productController.getAllroducts(
                                        roomid: roomId!,
                                        saletype: type,
                                        type: 'room');
                                  },
                                ));
                          },
                        ),
                      ],
                    ),
                    initialChildSize: 0.25);
              })),
    );
  }

  Widget _buildFilterTab(
      BuildContext context, String label, int index, Function function) {
    return Obx(
      () => InkWell(
        splashColor: Colors.transparent,
        onTap: () {
          productController.liveactivetab.value = index;
          productController.liveactivetab.refresh();
          function(index);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: productController.liveactivetab.value == index
                      ? Theme.of(context).colorScheme.onSurface
                      : Colors.grey.shade700),
            ),
            SizedBox(
              height: 5,
            ),
            Container(
              width: 60, // 👈 force full width
              height: 2,
              color: productController.liveactivetab.value == index
                  ? Theme.of(context).colorScheme.onSurface
                  : Colors.transparent, // only show for active tab
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuction(BuildContext context) {
    return Obx(() => productController.loading.isTrue
        ? Center(child: CircularProgressIndicator())
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "products_with_count".trParams({
                  "count": productController.roomallproducts.length.toString()
                }),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Expanded(
                  child: productController.roomallproducts.isEmpty
                      ? NoItems(
                          content: Text("no_auctions".tr,
                              style: Theme.of(context).textTheme.headlineSmall),
                        )
                      : ListView.builder(
                          itemCount: productController.roomallproducts.length,
                          itemBuilder: (context, index) {
                            Product product =
                                productController.roomallproducts[index];
                            return AuctionCard(product: product);
                          },
                        )),
            ],
          ));
  }

  Widget _buildProductItem(BuildContext context) {
    return Obx(() => productController.loading.isTrue
        ? Center(child: CircularProgressIndicator())
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "products_with_count".trParams({
                  "count": productController.roomallproducts.length.toString()
                }),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Expanded(
                  child: productController.roomallproducts.isEmpty
                      ? NoItems(
                          content: Text("no_products_to_buy".tr,
                              style: Theme.of(context).textTheme.headlineSmall),
                        )
                      : ListView.builder(
                          itemCount: productController.roomallproducts.length,
                          itemBuilder: (context, index) {
                            Product product =
                                productController.roomallproducts[index];
                            return InkWell(
                              splashColor: Colors.transparent,
                              onTap: () {
                                productController.currentProduct.value =
                                    product;
                                Get.to(() => ProductDetails(product: product));
                              },
                              child: Container(
                                margin: EdgeInsets.only(bottom: 20),
                                child: Row(
                                  children: [
                                    if (product.images?.isNotEmpty == true)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Stack(
                                          children: [
                                            SizedBox(
                                              width: 120,
                                              height: 120,
                                              child: product
                                                          .images?.isNotEmpty ==
                                                      true
                                                  ? CachedNetworkImage(
                                                      imageUrl:
                                                          product.images!.first,
                                                      fit: BoxFit.cover,
                                                    )
                                                  : Image.asset(
                                                      'assets/images/image_placeholder.jpg',
                                                      fit: BoxFit.cover,
                                                    ),
                                            ),
                                            Positioned(
                                              top: 4,
                                              right: 4,
                                              child: InkWell(
                                                onTap: () {
                                                  productController
                                                      .addToFavorite(product);
                                                },
                                                child: Obx(() {
                                                  return CircleAvatar(
                                                    radius: 12,
                                                    backgroundColor: productController
                                                                .roomallproducts[productController.roomallproducts.indexWhere((element) =>
                                                                            element.id ==
                                                                            product
                                                                                .id) ==
                                                                        -1
                                                                    ? 0
                                                                    : productController
                                                                        .roomallproducts
                                                                        .indexWhere((element) =>
                                                                            element.id ==
                                                                            product
                                                                                .id)]
                                                                .favorited
                                                                ?.indexWhere((element) =>
                                                                    element ==
                                                                    FirebaseAuth
                                                                        .instance
                                                                        .currentUser!
                                                                        .uid) !=
                                                            -1
                                                        ? Theme.of(context)
                                                            .colorScheme
                                                            .error
                                                        : Theme.of(context)
                                                            .colorScheme
                                                            .onPrimary,
                                                    child: Icon(
                                                      Icons
                                                          .notifications_outlined,
                                                      size: 16,
                                                      color: productController
                                                                  .roomallproducts[productController.roomallproducts.indexWhere((element) =>
                                                                              element.id ==
                                                                              product
                                                                                  .id) ==
                                                                          -1
                                                                      ? 0
                                                                      : productController.roomallproducts.indexWhere((element) =>
                                                                          element
                                                                              .id ==
                                                                          product
                                                                              .id)]
                                                                  .favorited
                                                                  ?.indexWhere((element) =>
                                                                      element ==
                                                                      FirebaseAuth
                                                                          .instance
                                                                          .currentUser!
                                                                          .uid) !=
                                                              -1
                                                          ? Colors.white
                                                          : Theme.of(context)
                                                              .colorScheme
                                                              .primary,
                                                    ),
                                                  );
                                                }),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (product.images?.isNotEmpty == true)
                                      const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.name!.capitalizeFirst ?? "",
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineSmall
                                                ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12.sp),
                                            maxLines: 2,
                                          ),
                                          if (productController
                                                  .liveactivetab.value !=
                                              0)
                                            Text(
                                              "${"qty".tr} ${product.quantity} · ${product.productCategory?.name}",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                          productController
                                                      .liveactivetab.value ==
                                                  0
                                              ? Text(
                                                  priceHtmlFormat(product
                                                      .auction?.baseprice),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headlineSmall)
                                              : Text(
                                                  priceHtmlFormat(
                                                      product.price),
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary,
                                                      ),
                                                ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          if (productController
                                                  .liveactivetab.value ==
                                              0)
                                            Text(
                                              "${product.auction?.bids!.length.toString()} ${"bids".tr}",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.normal),
                                            ),
                                          if (productController
                                                      .liveactivetab.value ==
                                                  1 &&
                                              authController.currentuser!.id !=
                                                  product.ownerId?.id)
                                            CustomButton(
                                              text: "buy_now".tr,
                                              function: () {
                                                Get.to(() => ProductDetails(
                                                    product: product));
                                              },
                                              fontSize: 12.sp,
                                            ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )),
            ],
          ));
  }

  Widget _buildGiveawayItem(BuildContext context) {
    return Obx(() => giveAwayController.loadinggiveaways.isTrue
        ? Center(child: CircularProgressIndicator())
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "giveaway_with_count".trParams({
                  "count": giveAwayController.giveawayslist.length.toString()
                }),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Expanded(
                  child: giveAwayController.giveawayslist.isEmpty
                      ? NoItems(
                          content: Text("no_giveaways".tr,
                              style: Theme.of(context).textTheme.headlineSmall),
                        )
                      : ListView.separated(
                          itemCount: giveAwayController.giveawayslist.length,
                          separatorBuilder: (context, index) => Divider(
                            color: Colors.grey.shade800,
                          ),
                          itemBuilder: (context, index) {
                            GiveAway giveAway =
                                giveAwayController.giveawayslist[index];
                            return InkWell(
                              splashColor: Colors.transparent,
                              onTap: () {
                                Get.to(
                                    () => GiveAwayDetails(giveAway: giveAway));
                              },
                              child: Container(
                                margin: EdgeInsets.only(bottom: 5, top: 5),
                                child: Row(
                                  children: [
                                    if (giveAway.images!.isNotEmpty)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child:
                                            giveAway.images?.isNotEmpty == true
                                                ? CachedNetworkImage(
                                                    imageUrl:
                                                        giveAway.images!.first,
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
                                      ),
                                    if (giveAway.images!.isNotEmpty)
                                      const SizedBox(width: 16),
                                    Container(
                                      width: 200.w,
                                      margin: const EdgeInsets.only(bottom: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            giveAway.name!.capitalizeFirst ??
                                                "",
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineSmall
                                                ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14.sp),
                                            maxLines: 2,
                                          ),
                                          Text(
                                            '${'giveaway'.tr}! #${index + 1}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineSmall
                                                ?.copyWith(fontSize: 13.sp),
                                            maxLines: 2,
                                          ),
                                          Text(
                                            '${giveAway.description}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineSmall
                                                ?.copyWith(
                                                    fontSize: 12.sp,
                                                    color: Colors.grey),
                                            maxLines: 2,
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          if (authController.currentuser!.id ==
                                              giveAway.user!.id)
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: InkWell(
                                                    onTap: tokshowcontroller
                                                                .currentRoom
                                                                .value!
                                                                .started ==
                                                            false
                                                        ? () {
                                                            Get.snackbar(
                                                                'error'.tr,
                                                                'cannot_start_giveaway'
                                                                    .tr,
                                                                backgroundColor:
                                                                    Colors.red,
                                                                colorText:
                                                                    Colors
                                                                        .white);
                                                          }
                                                        : () {
                                                            socketController
                                                                .pinGiveaway(
                                                                    giveAway,
                                                                    context);
                                                            Get.back();
                                                          },
                                                    child: Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              right: 10),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 5,
                                                          vertical: 8),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .secondaryContainer,
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons.card_giftcard,
                                                            size: 18.sp,
                                                          ),
                                                          SizedBox(
                                                            width: 8,
                                                          ),
                                                          Text("run".tr)
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 20,
                                                ),
                                                InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  child: Container(
                                                    height: 35,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .secondaryContainer),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 5),
                                                    child:
                                                        Icon(Icons.more_horiz),
                                                  ),
                                                  onTap: () {
                                                    showModalBottomSheet(
                                                      context: context,
                                                      isScrollControlled: true,
                                                      backgroundColor:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .surface,
                                                      shape:
                                                          const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.vertical(
                                                                top: Radius
                                                                    .circular(
                                                                        16)),
                                                      ),
                                                      builder: (BuildContext
                                                          context) {
                                                        return Container(
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 10,
                                                                  horizontal:
                                                                      15),
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              if (FirebaseAuth
                                                                      .instance
                                                                      .currentUser!
                                                                      .uid ==
                                                                  tokShowController
                                                                      .currentRoom
                                                                      .value
                                                                      ?.owner!
                                                                      .id)
                                                                SloganIconCard(
                                                                  title:
                                                                      "edit".tr,
                                                                  leftIcon:
                                                                      Icons
                                                                          .edit,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .transparent,
                                                                  rightIcon: Icons
                                                                      .arrow_forward_ios_outlined,
                                                                  function: () {
                                                                    Get.back();
                                                                    Get.to(() =>
                                                                        AddEditProductScreen(
                                                                            giveaway:
                                                                                giveAway));
                                                                  },
                                                                ),
                                                              if (FirebaseAuth
                                                                      .instance
                                                                      .currentUser!
                                                                      .uid ==
                                                                  tokShowController
                                                                      .currentRoom
                                                                      .value
                                                                      ?.owner!
                                                                      .id)
                                                                SloganIconCard(
                                                                  title:
                                                                      "delete"
                                                                          .tr,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .transparent,
                                                                  leftIcon: Icons
                                                                      .delete,
                                                                  rightIcon: Icons
                                                                      .arrow_forward_ios_outlined,
                                                                  function:
                                                                      () async {
                                                                    int i = giveAwayController
                                                                        .giveawayslist
                                                                        .indexWhere((p) =>
                                                                            p.id ==
                                                                            giveAway.id);
                                                                    giveAwayController
                                                                        .giveawayslist
                                                                        .removeAt(
                                                                            i);
                                                                    giveAwayController
                                                                        .giveawayslist
                                                                        .refresh();
                                                                    await giveAwayController
                                                                        .deleteGiveAway(
                                                                            giveAway.id!);
                                                                    Get.back();
                                                                  },
                                                                  titleStyle: TextStyle(
                                                                      color: Colors
                                                                          .red,
                                                                      fontSize:
                                                                          20,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                )
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              ],
                                            )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )),
            ],
          ));
  }

  Widget _buildSoldItem(BuildContext context) {
    return Obx(() => orderController.ordersLoading.isTrue
        ? Center(child: CircularProgressIndicator())
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "order_with_count".trParams(
                    {"count": orderController.orders.length.toString()}),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Expanded(
                  child: orderController.orders.isEmpty
                      ? NoItems(
                          content: Text("no_orders".tr,
                              style: Theme.of(context).textTheme.headlineSmall),
                        )
                      : ListView.builder(
                          itemCount: orderController.orders.length,
                          itemBuilder: (context, index) {
                            Order order = orderController.orders[index];
                            if (order.ordertype == "giveaway") {
                              GiveAway? giveAway = order.giveaway;
                              return InkWell(
                                splashColor: Colors.transparent,
                                onTap: () {
                                  if (order.seller?.id !=
                                      authController.currentuser?.id) {
                                    Get.to(() =>
                                        SoldGiveawayDetails(order: order));
                                  } else {
                                    Get.to(() =>
                                        PurchaseDetailsPage(order: order));
                                  }
                                },
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 20),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: giveAway?.images?.isNotEmpty ==
                                                true
                                            ? CachedNetworkImage(
                                                imageUrl:
                                                    giveAway?.images?.first ??
                                                        "",
                                                fit: BoxFit.cover,
                                                width: 100,
                                                height: 100,
                                              )
                                            : Image.asset(
                                                "assets/images/image_placeholder.jpg",
                                                fit: BoxFit.cover,
                                                width: 100,
                                                height: 100,
                                              ),
                                      ),
                                      const SizedBox(width: 16),
                                      Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              giveAway?.name?.capitalizeFirst ??
                                                  "",
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineSmall
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14.sp),
                                              maxLines: 2,
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "winner".tr,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headlineSmall
                                                      ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 12.sp),
                                                  maxLines: 2,
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    Get.to(() => ViewProfile(
                                                        user: order
                                                            .customer!.id!));
                                                  },
                                                  child: Text(
                                                    " ${order.customer?.firstName ?? ''}",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .headlineSmall
                                                        ?.copyWith(
                                                            fontSize: 12.sp,
                                                            color: Colors.blue),
                                                    maxLines: 2,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              'giveaway'.tr,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headlineSmall
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 12.sp),
                                              maxLines: 2,
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            return InkWell(
                              splashColor: Colors.transparent,
                              onTap: () {
                                if (order.seller?.id ==
                                    FirebaseAuth.instance.currentUser!.uid) {
                                  Get.to(
                                      () => ShipmentDetailsPage(order: order));
                                  return;
                                }
                                Get.to(() => SoldOrderDetails(order: order));
                              },
                              child: Container(
                                margin: EdgeInsets.only(bottom: 20),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: order.items?.first.product?.images
                                                  ?.isNotEmpty ==
                                              true
                                          ? CachedNetworkImage(
                                              imageUrl: order.items?.first
                                                      .product?.images?.first ??
                                                  "",
                                              fit: BoxFit.cover,
                                              width: 100,
                                              height: 100,
                                            )
                                          : SizedBox.shrink(),
                                    ),
                                    const SizedBox(width: 16),
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            order.items?.first.product?.name
                                                    ?.capitalizeFirst ??
                                                "",
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineSmall
                                                ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14.sp),
                                            maxLines: 2,
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                order.ordertype == "giveaway"
                                                    ? "winner".tr
                                                    : "buyer".tr,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headlineSmall
                                                    ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12.sp),
                                                maxLines: 2,
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  Get.to(() => ViewProfile(
                                                      user:
                                                          order.customer!.id!));
                                                },
                                                child: Text(
                                                  " ${order.customer?.firstName ?? ''}",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headlineSmall
                                                      ?.copyWith(
                                                          fontSize: 12.sp,
                                                          color: Colors.blue),
                                                  maxLines: 2,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            order.ordertype == "giveaway"
                                                ? 'giveaway'.tr
                                                : 'sold_for'.trParams({
                                                    'cost': priceHtmlFormat(
                                                        order.items?.fold(
                                                            0.0,
                                                            (previousValue,
                                                                    element) =>
                                                                previousValue +
                                                                element
                                                                    .subTotal))
                                                  }),
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineSmall
                                                ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12.sp),
                                            maxLines: 2,
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )),
            ],
          ));
  }
}
