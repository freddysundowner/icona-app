import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/models/category.dart';
import 'package:tokshop/widgets/search_layout.dart';

import '../../main.dart';
import '../../models/tokshow.dart';
import '../../widgets/live/no_items.dart';
import '../home/widget/tokshow_card.dart';
import '../live/live_tokshows.dart';

class _HorizontalCategoryStrip extends StatelessWidget {
  const _HorizontalCategoryStrip({
    super.key,
    required this.items,
    required this.onTap,
    this.height = 130,
    this.itemWidth = 240,
    this.padding = const EdgeInsets.symmetric(horizontal: 1),
  });

  final List<ProductCategory> items;
  final ValueChanged<ProductCategory> onTap;
  final double height;
  final double itemWidth;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: height,
      child: ListView.separated(
        padding: padding,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, i) => _HorizontalCategoryCard(
          category: items[i],
          width: itemWidth,
          onTap: () => onTap(items[i]),
        ),
      ),
    );
  }
}

class _HorizontalCategoryCard extends StatelessWidget {
  const _HorizontalCategoryCard({
    super.key,
    required this.category,
    required this.onTap,
    required this.width,
  });

  final ProductCategory category;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(10);

    return InkWell(
      onTap: onTap,
      borderRadius: radius,
      child: Ink(
        width: width,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor, // yellow vibe
          borderRadius: radius,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            borderRadius: radius,
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    category.iconUrl(),
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    color: Colors.black.withOpacity(0.25),
                    colorBlendMode: BlendMode.darken,
                  ),
                ),
                // title
                Positioned(
                  left: 12,
                  right: 12,
                  top: 12,
                  child: Text(
                    category.name ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                // viewers pill
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: _MiniViewersPill(viewers: category.viewersCount ?? 0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniViewersPill extends StatelessWidget {
  const _MiniViewersPill({required this.viewers});
  final int viewers;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // red dot
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: 6),
            decoration: const BoxDecoration(
              color: Colors.redAccent,
              shape: BoxShape.circle,
            ),
          ),
          Text(
            "viewers".trParams({'count': _formatViewers(viewers)}),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

String _formatViewers(int v) {
  if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
  if (v >= 1000) return '${(v / 1000).toStringAsFixed(v % 1000 == 0 ? 0 : 1)}K';
  return '$v';
}

class CategoryView extends StatelessWidget {
  ProductCategory category;
  CategoryView({super.key, required this.category}) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      productController.currentCategory.value = category;
      tokShowController.getTokshows(
        category: category.id!,
        status: "active",
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: Container(
          margin: EdgeInsets.only(top: 20),
          child: SearchLayout(
            function: (text) {
              tokShowController.getTokshows(
                  category: productController.currentCategory.value!.id!,
                  text: text);
            },
            padding: EdgeInsets.only(right: 10),
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Obx(
                    () => Text(
                      productController.currentCategory.value!.name!,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  onTap: () {
                    tokShowController.followCategory(
                        productController.currentCategory.value!);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Obx(
                      () => Text(
                          productController.currentCategory.value?.followers
                                      ?.indexWhere((element) =>
                                          element ==
                                          authController.currentuser!.id) ==
                                  -1
                              ? 'follow'.tr
                              : "unfollow".tr,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: theme.colorScheme.surface)),
                    ),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Obx(() => productController.currentCategory.value == null ||
                    productController.currentCategory.value!.sub!.isEmpty
                ? const SizedBox.shrink()
                : _HorizontalCategoryStrip(
                    items: productController.currentCategory.value!.sub!,
                    height: 80,
                    itemWidth: 180,
                    onTap: (c) {
                      productController.currentCategory.value = c;
                      productController.currentCategory.refresh();
                      tokShowController.getTokshows(category: c.id!);
                    },
                  )),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: Obx(
                () => tokShowController.isLoading.isTrue
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : tokShowController.channelRoomsList.isEmpty
                        ? NoItems(content: Text("no_shows".tr))
                        : GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 2 / 3.8,
                              crossAxisSpacing: 16.w,
                              mainAxisSpacing: 16.h,
                            ),
                            itemCount:
                                tokShowController.channelRoomsList.length,
                            itemBuilder: (context, index) {
                              Tokshow tokShow =
                                  tokShowController.channelRoomsList[index];
                              return InkWell(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                onTap: () {
                                  Get.to(() => LiveShowPage(
                                        roomId: tokShow.id!,
                                      ));
                                },
                                child: TokshowCard(
                                  tokShow: tokShow,
                                ),
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
