import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tokshop/pages/home/widget/product_card.dart';
import 'package:tokshop/pages/home/widget/tokshow_card.dart';
import 'package:tokshop/pages/live/live_tokshows.dart';

import '../../controllers/global.dart';
import '../../controllers/product_controller.dart';
import '../../controllers/room_controller.dart';
import '../../controllers/search_controller.dart';
import '../../models/product.dart';
import '../../models/tokshow.dart';
import '../../widgets/live/no_items.dart';
import '../live/widgets/shows_header.dart';
import '../products/product_swipe_card.dart';

class BodyViews extends StatelessWidget {
  BodyViews({super.key}) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.getAllroducts(type: "home");
    });
  }

  final ProductController productController = Get.find<ProductController>();
  final TokShowController tokShowController = Get.find<TokShowController>();
  final GlobalController _global = Get.find<GlobalController>();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          floating: true,
          delegate: StickyShowsDelegate(),
        ),

        // First 6 TokShows Grid
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          sliver: Obx(() {
            if (tokShowController.isLoading.isTrue) {
              return _buildLoadingGrid();
            } else if (tokShowController.channelRoomsList.isEmpty) {
              return SliverToBoxAdapter(
                child: SizedBox(
                  height: 200,
                  child: NoItems(
                    content: Text(
                      'no_tokshow'.tr,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface),
                      textAlign: TextAlign.center,
                    ),
                    iconSize: 35,
                  ),
                ),
              );
            } else {
              // Show only the first 6 TokShows before showing products
              List<Tokshow> firstSixTokShows =
                  tokShowController.channelRoomsList.take(6).toList();
              return SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  childAspectRatio: 2 / 3.8,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    Tokshow tokShow = firstSixTokShows[index];
                    return InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      onTap: () {
                        Get.to(() => LiveShowPage(
                              roomId: tokShow.id!,
                            ));
                      },
                      child: TokshowCard(tokShow: tokShow),
                    );
                  },
                  childCount: firstSixTokShows.length,
                ),
              );
            }
          }),
        ),

        // Horizontal Scroll Products Section
        SliverToBoxAdapter(
          child: Obx(() {
            if (productController.homeallproducts.isEmpty) {
              return SizedBox.shrink(); // Hide if no products are available
            }
            return _buildHorizontalProductSection();
          }),
        ),

        // Continue showing the rest of the TokShows
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
          sliver: Obx(() {
            if (tokShowController.isLoading.isTrue) {
              return _buildLoadingGrid();
            } else {
              // Show the remaining TokShows after the product section
              List<Tokshow> remainingTokShows =
                  tokShowController.channelRoomsList.skip(6).toList();
              return SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: Platform.isIOS ? 0.42.h : 0.50,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    Tokshow tokShow = remainingTokShows[index];
                    return InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      onTap: () {
                        Get.to(() => LiveShowPage(
                              roomId: tokShow.id!,
                            ));
                        // Get.to(LiveShowPage(roomId: tokShow.id!));
                      },
                      child: TokshowCard(tokShow: tokShow),
                    );
                  },
                  childCount: remainingTokShows.length,
                ),
              );
            }
          }),
        ),
      ],
    );
  }

  // Function to show loading shimmer for TokShows
  Widget _buildLoadingGrid() {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return Shimmer.fromColors(
            baseColor: Theme.of(context).colorScheme.onSecondaryContainer,
            highlightColor: Theme.of(context).colorScheme.onSecondaryContainer,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
              ),
              margin: EdgeInsets.symmetric(vertical: 8.0),
            ),
          );
        },
        childCount: 6,
      ),
    );
  }

  // Function to build the horizontal product section
  Widget _buildHorizontalProductSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "tranding_products".tr, // Section Title
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              InkWell(
                child: Text("show_all".tr),
                onTap: () {
                  Get.find<BrowseController>().currentsearchtab.value = 0;
                  _global.tabPosition.value = 1;
                },
              )
            ],
          ),
        ),
        SizedBox(
          height: 220, // Adjust height as needed
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: productController.homeallproducts.length,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              Product product = productController.homeallproducts[index];
              return Container(
                width: 160, // Adjust item width
                margin: EdgeInsets.only(right: 10),
                child: InkWell(
                  onTap: () {
                    productController.currentProductIndexSwiper.value = index;
                    Get.to(() => ProductSwipeCard(
                          list: productController.homeallproducts,
                        ));
                  },
                  child: ProductHomeCard(product: product),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
