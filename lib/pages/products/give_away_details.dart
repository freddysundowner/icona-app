import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/cart_controller.dart';
import 'package:tokshop/controllers/give_away_controller.dart';
import 'package:tokshop/models/giveaway.dart';
import 'package:tokshop/pages/products/seller_info.dart';

import '../../controllers/product_image_controller.dart';
import '../../main.dart';
import '../profile/widgets/giveaway_metrics_card.dart';
import 'images_slider.dart';

class GiveAwayDetails extends StatelessWidget {
  GiveAway giveAway;

  GiveAwayDetails({super.key, required this.giveAway}) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      giveAwayController.getGiveAwayById(giveAway);
      userController.getUserProfile(giveAway.user!.id!);
      shippingController.getShippingEstimate(data: {
        "weight": giveAway.shipping_profile?.weight,
        "update": false,
        "owner": giveAway.user?.id,
        "customer": authController.currentuser?.id,
      });
    });
  }
  ProductImageSwiper productImageSwiper = Get.put(ProductImageSwiper());
  CartController cartController = Get.put(CartController());
  GiveAwayController giveAwayController = Get.put(GiveAwayController());

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return SafeArea(
      child: DefaultTabController(
        length: 2,
        initialIndex: 0,
        child: Scaffold(
          body: Obx(() => productController.loadingSingleProduct.isTrue
              ? Center(child: CircularProgressIndicator())
              : ListView(
                  children: [
                    Stack(
                      children: [
                        ProductImageSlider(
                          images: giveAway.images ?? [],
                        ),
                        Container(
                          height: 80.h,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context)
                                    .colorScheme
                                    .surface
                                    .withOpacity(0.4), // Top color
                                Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.03), // Bottom color
                              ],
                              begin: Alignment.topCenter, // Start from the top
                              end: Alignment.bottomCenter, // End at the bottom
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                                onPressed: () {
                                  Get.back();
                                },
                                icon: Icon(Icons.clear),
                                color: Theme.of(context).colorScheme.onSurface),
                          ],
                        )
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16.h),
                          Text(
                            giveAway.name ?? "".toUpperCase(),
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Circular"),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'available_count'.trParams(
                                    {"count": giveAway.quantity.toString()}),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              InkWell(
                                onTap: () async {
                                  await productController.shareProduct(
                                      productController.currentProduct.value!);
                                },
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: theme.dividerColor,
                                      )),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.share,
                                        size: 16.sp,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text("share".tr)
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          if (authController.currentuser!.id !=
                              giveAway.user!.id)
                            GiveawayMetricsCard(
                              theme: theme,
                              giveAway: giveAway,
                            ),
                          TabBar(
                            isScrollable: true,
                            indicatorColor: theme.colorScheme.primary,
                            labelColor: theme.textTheme.bodyLarge!.color,
                            unselectedLabelColor:
                                theme.textTheme.bodyMedium!.color,
                            labelPadding: EdgeInsets.only(right: 20),
                            padding: EdgeInsets.zero,
                            tabAlignment: TabAlignment.start,
                            labelStyle: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold, fontSize: 16),
                            onTap: (i) {
                              productController.productdetailsTabIndex.value =
                                  i;
                              // if (i == 1) {
                              //   userController.getUserProfile(productController
                              //       .currentProduct.value!.ownerId!.id!);
                              //   productController.getAllroducts(
                              //       userid: productController
                              //           .currentProduct.value!.ownerId!.id!,
                              //       limit: "6",
                              //       page: "1");
                              // }
                            },
                            tabs: [
                              Tab(text: 'details'.tr),
                              Tab(text: 'seller_info'.tr)
                            ],
                          ),
                          Obx(() => productController
                                      .productdetailsTabIndex.value ==
                                  0
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(top: 10.h),
                                      child: Text(
                                        giveAway.description ?? "",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                      ),
                                    ),
                                    Divider(
                                      color: theme.dividerColor,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "category".tr,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Text(
                                          giveAway.category?.name ?? "",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      ],
                                    )
                                  ],
                                )
                              : SellerInfo(user: giveAway.user!.id!))
                        ],
                      ),
                    ),
                  ],
                )),
        ),
      ),
    );
  }
}
