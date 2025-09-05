import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/cart_controller.dart';
import 'package:tokshop/controllers/product_controller.dart';
import 'package:tokshop/pages/products/seller_info.dart';
import 'package:tokshop/pages/products/widgets/product_action.dart';
import 'package:tokshop/utils/helpers.dart';

import '../../controllers/auction_controller.dart';
import '../../controllers/product_image_controller.dart';
import '../../main.dart';
import '../../models/product.dart';
import '../../services/user_api.dart';
import '../profile/widgets/product_metrics_card.dart';
import 'buy_now_sheet.dart';
import 'images_slider.dart';

class ProductDetails extends StatelessWidget {
  Product product;

  ProductDetails({super.key, required this.product}) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.getProductById(product);
      if (product.ownerId != null) {
        userController.getUserProfile(product.ownerId!.id!);
        productController.getAllroducts(
          userid: product.ownerId!.id!,
          limit: "6",
          page: "1",
        );
      }
      shippingController.getShippingEstimate(data: {
        'weight': product.shipping_profile?.weight,
        "update": false,
        "owner": product.ownerId?.id,
        "customer": authController.currentuser?.id,
      });
    });
  }
  ProductImageSwiper productImageSwiper = Get.put(ProductImageSwiper());
  CartController cartController = Get.put(CartController());
  ProductController productController = Get.put(ProductController());
  buy() {
    if (product.colors != null &&
        product.colors!.isNotEmpty &&
        cartController.selectedcolor.value.isEmpty) {
      return false;
    }
    if (product.sizes!.isNotEmpty &&
        cartController.selectedsize.value.isEmpty) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        body: Obx(() => productController.loadingSingleProduct.isTrue
            ? Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  if (productController.currentProduct.value != null)
                    Stack(
                      children: [
                        if (productController
                            .currentProduct.value!.images!.isNotEmpty)
                          ProductImageSlider(
                            images: productController
                                    .currentProduct.value?.images ??
                                [],
                          ),
                        if (productController
                            .currentProduct.value!.images!.isNotEmpty)
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
                                begin:
                                    Alignment.topCenter, // Start from the top
                                end:
                                    Alignment.bottomCenter, // End at the bottom
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
                          productController.currentProduct.value?.name ??
                              "".toUpperCase(),
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
                              'available_count'.trParams({
                                "count":
                                    productController.currentProduct.value ==
                                            null
                                        ? "0"
                                        : productController
                                            .currentProduct.value!.quantity
                                            .toString()
                              }),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Text(
                                  priceHtmlFormat(
                                      productController
                                          .currentProduct.value?.price!,
                                      currency: '\$'),
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                Text(
                                  " + ${priceHtmlFormat(shippingController.shippingEstimate["amount"], currency: '\$')} ${'shipping'.tr}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                          fontSize: 12.sp),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: theme.dividerColor,
                                        )),
                                    child: Center(
                                      child: InkWell(
                                        onTap: () async {
                                          int? i = productController
                                              .currentProduct.value?.favorited
                                              ?.indexWhere((element) =>
                                                  element ==
                                                  FirebaseAuth.instance
                                                      .currentUser!.uid);
                                          if (i != -1) {
                                            productController
                                                .currentProduct.value?.favorited
                                                ?.removeAt(i!);
                                            await UserAPI.deleteFromFavorite(
                                                productController
                                                    .currentProduct.value!.id!);
                                          } else {
                                            productController
                                                .currentProduct.value?.favorited
                                                ?.add(FirebaseAuth
                                                    .instance.currentUser!.uid);
                                            await UserAPI.saveFovite(
                                                productController
                                                    .currentProduct.value!.id!);
                                          }
                                          productController.currentProduct
                                              .refresh();
                                        },
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.local_offer,
                                              size: 16.sp,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Obx(
                                              () => Text(
                                                productController.currentProduct
                                                    .value!.favorited!.length
                                                    .toString(),
                                                style: TextStyle(
                                                    fontSize: 14.sp,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    )),
                                InkWell(
                                  onTap: () async {
                                    await productController.shareProduct(
                                        productController
                                            .currentProduct.value!);
                                  },
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.4,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: theme.dividerColor,
                                        )),
                                    child: Icon(
                                      Icons.share,
                                      size: 16.sp,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        if (authController.currentuser!.id !=
                            productController.currentProduct.value?.ownerId?.id)
                          ProductMetricsCard(
                            theme: theme,
                            product: productController.currentProduct.value!,
                          ),
                        if (productController
                            .currentProduct.value!.sizes!.isNotEmpty)
                          SizedBox(height: 8.h),
                        if (productController
                            .currentProduct.value!.sizes!.isNotEmpty)
                          Text(
                            "sizes".tr,
                            style: theme.textTheme.bodyLarge,
                          ),
                        if (productController
                            .currentProduct.value!.sizes!.isNotEmpty)
                          Obx(
                            () => Wrap(
                              children: productController
                                  .currentProduct.value!.sizes!
                                  .map((size) {
                                return Padding(
                                  padding: EdgeInsets.only(right: 8.w),
                                  child: ChoiceChip(
                                    label: Text(size),
                                    selected:
                                        cartController.selectedsize.value ==
                                            size,
                                    onSelected: (selected) {
                                      cartController.selectedsize.value = size;
                                    },
                                    selectedColor:
                                        cartController.selectedsize.value ==
                                                size
                                            ? Colors.yellow
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                    checkmarkColor:
                                        Theme.of(context).colorScheme.surface,
                                    labelStyle: TextStyle(
                                        color: size ==
                                                cartController
                                                    .selectedsize.value
                                            ? Theme.of(context)
                                                .colorScheme
                                                .surface
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                        fontSize: 10.sp),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        if (productController
                            .currentProduct.value!.sizes!.isNotEmpty)
                          SizedBox(height: 16.h),
                        if (productController
                            .currentProduct.value!.colors!.isNotEmpty)
                          Text(
                            "colors".tr,
                            style: theme.textTheme.bodyLarge,
                          ),
                        if (productController
                            .currentProduct.value!.colors!.isNotEmpty)
                          Obx(
                            () => Wrap(
                              direction: Axis.horizontal,
                              children: productController
                                  .currentProduct.value!.colors!
                                  .map((size) {
                                final colorMap = productController
                                    .availableColors
                                    .firstWhere(
                                        (element) => element["name"] == size,
                                        orElse: () =>
                                            {"color": Colors.grey}); // Defaul
                                return InkWell(
                                  splashColor: Colors.transparent,
                                  onTap: () {
                                    cartController.selectedcolor.value = size;
                                  },
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 4.w),
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      margin: EdgeInsets.symmetric(vertical: 4),
                                      decoration: BoxDecoration(
                                        color: cartController
                                                    .selectedcolor.value ==
                                                size
                                            ? null
                                            : colorMap[
                                                "color"], // Set background color
                                        shape:
                                            BoxShape.circle, // Make it circular
                                        border: Border.all(
                                          color: cartController
                                                      .selectedcolor.value ==
                                                  size
                                              ? Colors.yellow
                                              : theme.scaffoldBackgroundColor,
                                          width: 2,
                                        ),
                                      ),
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        margin: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: cartController
                                                      .selectedcolor.value ==
                                                  size
                                              ? colorMap["color"]
                                              : null,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        if (productController
                            .currentProduct.value!.colors!.isNotEmpty)
                          SizedBox(height: 16.h),
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
                            productController.productdetailsTabIndex.value = i;
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
                        Obx(() =>
                            productController.productdetailsTabIndex.value == 0
                                ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(top: 10.h),
                                        child: Text(
                                          productController.currentProduct
                                                  .value!.description ??
                                              "",
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
                                            productController
                                                    .currentProduct
                                                    .value!
                                                    .productCategory
                                                    ?.name ??
                                                "",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                        ],
                                      )
                                    ],
                                  )
                                : SellerInfo(
                                    user: productController
                                        .currentProduct.value!.ownerId!.id!))
                      ],
                    ),
                  ),
                ],
              )),
        bottomNavigationBar: productController
                    .currentProduct.value?.ownerId?.id ==
                FirebaseAuth.instance.currentUser!.uid
            ? Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding:
                    EdgeInsets.only(bottom: MediaQuery.of(context).padding.top),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Divider(
                      color: theme.dividerColor,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ProductAction(
                      function: () {
                        productController.inventorySelectedProducts
                            .add(productController.currentProduct.value!);
                        productController.assingLiveShow(context,
                            showOptions: true);
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              )
            : Obx(() => productController.currentProduct.value == null ||
                    productController.currentProduct.value!.reviews!.isEmpty
                ? productController.currentProduct.value?.listing_type ==
                        "auction"
                    ? Container(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).padding.bottom),
                        height: 65.h,
                        margin: EdgeInsets.symmetric(horizontal: 20.w),
                        child: ElevatedButton(
                          onPressed: () {
                            Get.find<AuctionController>().prebidBottomSheet(
                                context,
                                productController.currentProduct.value!);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            productController
                                        .currentProduct.value!.auction?.bids
                                        ?.indexWhere((b) =>
                                            b.bidder.id ==
                                            authController.currentuser!.id) ==
                                    -1
                                ? 'pre_bid'.tr
                                : 'my_bid'.trParams({
                                    "bid": priceHtmlFormat(productController
                                        .currentProduct.value!.auction?.bids!
                                        .where((b) =>
                                            b.bidder.id ==
                                            authController.currentuser!.id)
                                        .toList()
                                        .first
                                        .amount
                                        .toString())
                                  }),
                            style: TextStyle(
                              color: theme.colorScheme.surface,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        height: 35.h,
                        margin: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 10.h),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: buy() == false
                              ? null
                              : () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors
                                        .transparent, // Ensures rounded corners
                                    builder: (context) => BuyNowSheet(
                                        product: productController
                                            .currentProduct.value!),
                                  );
                                },
                          label: Text(
                            'buy_now'.tr,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary),
                          ),
                        ),
                      )
                : SizedBox(
                    height: 80.h,
                    child: ReviewsWithButton(
                        product: productController.currentProduct.value!,
                        buy: buy()))),
      ),
    );
  }
}

class ReviewsWithButton extends StatelessWidget {
  Product product;
  bool buy;
  ReviewsWithButton({super.key, required this.product, required this.buy});
  final ProductController productController = Get.find<ProductController>();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "reviews".tr,
            style: Theme.of(context)
                .textTheme
                .displaySmall
                ?.copyWith(fontSize: 14, fontWeight: FontWeight.w400),
          ),
          SizedBox(
            height: 15.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SizedBox(
                  height: 40.h,
                  child: Stack(
                    clipBehavior: Clip.none, // Allows overlap
                    children: [
                      for (int i = 0; i < product.reviews!.length; i++)
                        Positioned(
                          left: i * 30.w, // Adjust the overlap distance
                          child: product.reviews![i].reviewerImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(20.w),
                                  child: CachedNetworkImage(
                                      imageUrl:
                                          product.reviews![i].reviewerImage!,
                                      fit: BoxFit.cover))
                              : CircleAvatar(
                                  radius: 20.w,
                                  backgroundImage: AssetImage(
                                      'assets/images/image_placeholder.jpg'),
                                ),
                        ),
                      Positioned(
                        left: 90
                            .w, // Position for the +585 badge after last avatar
                        child: CircleAvatar(
                          radius: 20.w,
                          backgroundColor:
                              Theme.of(context).colorScheme.surface,
                          child: Text(
                            '+${product.reviews!.length}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  child: Container(
                    height: 35.h,
                    width: MediaQuery.of(context).size.width * 0.9,
                    margin: EdgeInsets.only(right: 10.h),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: buy == false
                          ? null
                          : () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors
                                    .transparent, // Ensures rounded corners
                                builder: (context) =>
                                    BuyNowSheet(product: product),
                              );
                            },
                      label: Text(
                        'buy_now'.tr,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.surface),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
