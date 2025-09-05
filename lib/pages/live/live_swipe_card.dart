import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tokshop/controllers/auction_controller.dart';
import 'package:tokshop/pages/live/live_tokshows.dart';
import 'package:tokshop/pages/products/product_detail.dart';

import '../../main.dart';
import '../../models/product.dart';
import '../../models/tokshow.dart';
import '../../models/user.dart';
import '../../services/user_api.dart';
import '../../utils/helpers.dart';
import '../products/buy_now_sheet.dart';

class LiveSwipeCard extends StatelessWidget {
  List<Tokshow> list;

  LiveSwipeCard({super.key, required this.list}) {}

  PageController swipeproductController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: PageController(
          initialPage: tokShowController.currentTokshowIndexSwiper.value,
        ),
        itemCount: list.length,
        onPageChanged: (index) {
          tokShowController.currentTokshowIndexSwiper.value = index;
          tokShowController.initRoom(list[index].id);
        },
        itemBuilder: (context, index) {
          return LiveShowPage(roomId: list[index].id!);
        },
      ),
    );
  }
}

class ProductCard extends StatefulWidget {
  final Product product;

  ProductCard({super.key, required this.product}) {
    // shippingController.getShippingEstimate(product.id!);
  }

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  int currentImageIndex = 0;
  final PageController _imagePageController = PageController(); // ✅ Fix 3️⃣

  @override
  Widget build(BuildContext context) {
    int i = widget.product.ownerId == null
        ? -1
        : widget.product.ownerId!.followers.indexWhere(
            (element) => element.id == FirebaseAuth.instance.currentUser!.uid);
    return Stack(
      children: [
        Positioned.fill(
          child: CachedNetworkImage(
            imageUrl: widget.product.images![currentImageIndex],
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.black.withOpacity(0.8),
                  Colors.black.withOpacity(0.8),
                  Colors.black.withOpacity(0.75),
                  Colors.black.withOpacity(0.75),
                  Colors.grey.withOpacity(0.75),
                ],
              ),
            ),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              GestureDetector(
                onHorizontalDragUpdate: (details) =>
                    _imagePageController.jumpTo(
                  _imagePageController.offset - details.primaryDelta!,
                ),
                child: PageView.builder(
                  controller:
                      _imagePageController, // ✅ Fix 3️⃣ - Use PageController
                  physics:
                      BouncingScrollPhysics(), // ✅ Fix 3️⃣ - Ensures smooth scrolling
                  itemCount: widget.product.images!.length,
                  scrollDirection: Axis.horizontal,
                  onPageChanged: (index) {
                    setState(() {
                      currentImageIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return CachedNetworkImage(
                      imageUrl: widget.product.images![index],
                    );
                  },
                ),
              ),
              Positioned(
                bottom: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.product.images!.length,
                    (index) => Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      width: currentImageIndex == index ? 20.w : 6.w,
                      height: currentImageIndex == index ? 10.h : 6.h,
                      decoration: BoxDecoration(
                        color: currentImageIndex == index
                            ? Colors.yellow
                            : Colors.grey,
                        shape: currentImageIndex == index
                            ? BoxShape.rectangle
                            : BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(5.sp),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(top: 40.h, left: 20.w, right: 20.w),
                height: 120.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.sp),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black
                          .withOpacity(0.6), // Dark background for visibility
                      Colors.black.withOpacity(0.4),
                      Colors.black.withOpacity(0.2),
                      Colors.transparent, // Fades out smoothly
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(
                              widget.product.ownerId?.profilePhoto ?? ''),
                          radius: 18.sp,
                        ),
                        SizedBox(width: 8.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.product.ownerId?.firstName ?? "Seller",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                      color: Colors.white, fontSize: 12.sp),
                            ),
                            Row(
                              children: [
                                InkWell(
                                  child: Icon(Icons.star,
                                      color: widget.product.ownerId
                                                  ?.averagereviews ==
                                              0
                                          ? Colors.grey
                                          : Colors.yellow,
                                      size: 16.sp),
                                ),
                                Text(
                                  widget.product.ownerId?.averagereviews
                                          .toString() ??
                                      "0",
                                  style: TextStyle(
                                      fontSize: 11.sp, color: Colors.white),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                if (i == -1)
                                  InkWell(
                                    onTap: () async {
                                      if (widget.product.ownerId == null) {
                                        return;
                                      }
                                      if (i != -1) {
                                        widget.product.ownerId!.followers
                                            .removeAt(i);
                                        setState(() {});
                                        await UserAPI().unFollowAUser(
                                            FirebaseAuth
                                                .instance.currentUser!.uid,
                                            widget.product.ownerId!.id!);
                                      } else {
                                        widget.product.ownerId!.followers.add(
                                            UserModel(
                                                id: FirebaseAuth.instance
                                                    .currentUser!.uid));
                                        setState(() {});

                                        await UserAPI().followAUser(
                                            FirebaseAuth
                                                .instance.currentUser!.uid,
                                            widget.product.ownerId!.id!);
                                      }
                                    },
                                    child: Text(
                                      "follow".tr,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.onPrimary),
                        child: Icon(Icons.clear),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            color: Colors.transparent,
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  child: Container(
                    padding: EdgeInsets.only(bottom: 8.h),
                    decoration: BoxDecoration(
                        color: Theme.of(context)
                            .scaffoldBackgroundColor
                            .withValues(alpha: 0.8)
                            .withValues(alpha: 8),
                        borderRadius: BorderRadius.circular(16.sp)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(16.sp),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.onSurface,
                            borderRadius: BorderRadius.circular(16.sp),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12.sp),
                                child: CachedNetworkImage(
                                  imageUrl: widget.product.images!.first,
                                  fit: BoxFit.cover,
                                  width: 80,
                                  height: 80,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          widget.product.name
                                                  ?.capitalizeFirst ??
                                              "",
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium
                                              ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary),
                                        ),
                                        Spacer(),
                                        InkWell(
                                          onTap: () {
                                            Get.to(() => ProductDetails(
                                                product: widget.product));
                                          },
                                          child: Icon(
                                            Icons.zoom_out_map,
                                            color: Colors.black,
                                          ),
                                        )
                                      ],
                                    ),
                                    Text(
                                      'qty_available'.trParams({
                                        'qty':
                                            widget.product.quantity.toString(),
                                        'category': widget
                                            .product.productCategory!.name!
                                      }),
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    Text.rich(
                                      TextSpan(
                                        text:
                                            "${priceHtmlFormat(widget.product.price)} + ", // Normal Style
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary,
                                            ),
                                        children: [
                                          TextSpan(
                                            text:
                                                "${priceHtmlFormat(shippingController.shippingEstimate['amount'])} shipping + taxes", // Styled Part
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineMedium
                                                ?.copyWith(
                                                    fontSize: 13.sp,
                                                    color: Colors.grey,
                                                    fontWeight:
                                                        FontWeight.normal),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            InkWell(
                              onTap: () async {
                                setState(() {});
                                await productController
                                    .addToFavorite(widget.product);
                              },
                              child: Row(
                                children: [
                                  Icon(Icons.local_offer),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    widget.product.favorited!.length.toString(),
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 50,
                            ),
                            InkWell(
                              onTap: () {},
                              child: SvgPicture.asset(
                                "assets/icons/share_icon.svg",
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  onTap: () {
                    Get.to(() => ProductDetails(product: widget.product));
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    if (widget.product.listing_type == "auction")
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Get.find<AuctionController>()
                                .prebidBottomSheet(context, widget.product);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            widget.product.auction?.bids?.indexWhere((b) =>
                                        b.bidder.id ==
                                        authController.currentuser!.id) ==
                                    -1
                                ? 'pre_bid'.tr
                                : 'my_bid'.trParams({
                                    "bid": priceHtmlFormat(widget
                                        .product.auction!.bids!
                                        .where((b) =>
                                            b.bidder.id ==
                                            authController.currentuser!.id)
                                        .toList()
                                        .first
                                        .amount
                                        .toString())
                                  }),
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    if (widget.product.listing_type == "buy_now")
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor:
                                  Colors.transparent, // Ensures rounded corners
                              builder: (context) =>
                                  BuyNowSheet(product: widget.product),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.yellow,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'buy_now'.tr,
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
