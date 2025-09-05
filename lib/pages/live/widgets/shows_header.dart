import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tokshop/widgets/search_layout.dart';

import '../../../controllers/global.dart';
import '../../../controllers/search_controller.dart';
import '../../../main.dart';
import '../../notifications/notifications.dart';

class StickyShowsDelegate extends SliverPersistentHeaderDelegate {
  final RxBool isSearching = false.obs;
  final RxList<String> suggestedSearches = <String>[].obs;
  final GlobalController _global = Get.find<GlobalController>();
  final TextEditingController searchController = TextEditingController();
  final BrowseController browseController = Get.put(BrowseController());
  final FocusNode searchFocusNode = FocusNode(); // FocusNode to track focus

  StickyShowsDelegate() {
    searchFocusNode.addListener(() {
      if (searchFocusNode.hasFocus) {
        _global.tabPosition.value = 1;
        browseController.currentsearchtab.value = 3;
      }
    });
  }

  void onSearchChanged(String query) {
    if (query.isEmpty) {
      isSearching.value = true; // Keep overlay visible when focused
      suggestedSearches.clear();
    } else {
      isSearching.value = true;
      suggestedSearches.value = productController.categories
          .where((category) =>
              category.name?.toLowerCase().contains(query.toLowerCase()) ??
              false)
          .map((category) => category.name ?? "")
          .toList();
    }
  }

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Stack(
      children: [
        Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          padding: EdgeInsets.only(top: 10),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: SearchLayout(
                      controller: searchController,
                      focusNode: searchFocusNode, // Attach FocusNode
                      function: onSearchChanged,
                      searchHint: "search_tokshow".tr,
                      margin: EdgeInsets.zero,
                      height: 50,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.notifications,
                        color: Theme.of(context).colorScheme.onSurface),
                    onPressed: () {
                      Get.to(() => Notifications());
                    },
                  ),
                ],
              ),
              Obx(
                () => DefaultTabController(
                  length: productController.categories.length + 1,
                  child: TabBar(
                    labelPadding: EdgeInsets.symmetric(horizontal: 8.0),
                    tabAlignment: TabAlignment.start,
                    isScrollable: true,
                    labelColor: Theme.of(context).colorScheme.onSurface,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Theme.of(context).colorScheme.onSurface,
                    dividerColor: Theme.of(context).dividerColor,
                    tabs: [
                      Tab(text: "For You".tr),
                      ...productController.categories.map((category) {
                        return Tab(
                          child: Text(category.name ?? "",
                              style: TextStyle(fontSize: 16.sp)),
                        );
                      }),
                    ],
                    onTap: (index) {
                      if (index == 0) {
                        tokShowController.getTokshows(
                            category: 'all', status: "active");
                        return;
                      }
                      tokShowController.getTokshows(
                          category: productController.categories[index - 1].id!,
                          status: "active");
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        // Search Overlay with Suggestions
        Obx(() {
          if (!isSearching.value) return SizedBox.shrink();
          return Positioned(
            top: 55, // Position under search bar
            left: 16,
            right: 16,
            child: Material(
              color: Theme.of(context).cardColor,
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: Column(
                children: suggestedSearches
                    .map(
                      (suggestion) => ListTile(
                        title: Text(suggestion),
                        onTap: () {
                          searchController.text = suggestion;
                          isSearching.value = false;
                          searchFocusNode.unfocus(); // Hide keyboard
                          // tokShowController.searchTokShows(suggestion);
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          );
        }),
      ],
    );
  }

  @override
  double get maxExtent => 120;
  @override
  double get minExtent => 120;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
